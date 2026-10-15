/*
**	xpkBLZW.c -- xpkBLZW.library 3.3
**
**	C reconstruction of the shipped "Bryan's turbo-charged LZW"
**	XPK sublibrary (mode 15 => 15-bit codes max).
**
**	  -30	XpksPackerInfo -> static descriptor
**	  -36	XpksPackChunk    LZW encoder (0xa001-entry hash table)
**	  -42	XpksPackFree     free the xsp_Sub workmem
**	  -48	XpksPackReset    -> null
**	  -54	XpksUnpackChunk  LZW decoder (bit stack + chain table)
**	  -60	XpksUnpackFree   same free routine
**
**	Stream layout:
**	  word0 = max code width used (9..15, selects table size 4<<w0)
**	  word1 = max string length & ~3  (decoder stack bytes)
**	  MSB-first code stream of 9..width-bit codes;
**	  0..255 literals, 0x100 END, 0x101 RESET, 0x102 WIDTH-UP.
**
**	Packer hash record = {u16 byte, u16 prevcode, u16 code};
**	key = ((byte<<7) ^ prevcode) & 0xffff, index = key*6 with a
**	fixed second-probe step (key*6 - 0x3c006 + 6).  NOTE: keys
**	>= 0xa001 index past the 0x3c006-byte table -- the original
**	reads/writes heap memory up to ~128 KB past the allocation
**	(latent defect; see okf/findings/defects.md).
**
**	Decoder table record = {u16 char-or-tag, u16 2*prevcode}.
**	word0 < 0x8000: literal char; 0xff00+i: string leaf;
**	0x8000/1/2: END / RESET / WIDTH-UP (detected by the
**	"subq #3,bvs / addq #1" overflow trick in the original).
**
**	External calls: exec AllocMem(-198), FreeMem(-210),
**	Remove(-252) only.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size		   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18 chunk number			   */
    ULONG xsp_Mode;		/* 0x1c packing mode			   */
    STRPTR xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Arg[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34 sublib private data		   */
};				/* xsp_Sub[0] = workmem ptr (@52),	   */
				/* xsp_Sub[1] = workmem size (@56)	   */

struct BlzwBase			/* InitTable dataSize = 0x28	   */
{
    struct Library b_Lib;	/* 0x00 standard library node	   */
    UWORD  b_Pad;		/* 0x22					   */
    BPTR   b_SegList;		/* 0x24 seglist, stored by LibInit   */
};				/* = 0x28				   */

#define SYSBASE	(*(struct ExecBase **)4)

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_d0), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

/* ------------------------------------------------------------------ */
/* standard vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct BlzwBase *b __asm("a6"))
{
    b->b_Lib.lib_OpenCnt++;
    b->b_Lib.lib_Flags &= ~8;		/* LIBF_DELEXP		   */
    return (struct Library *)b;
}

BPTR LibExpunge(struct BlzwBase *b __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (b->b_Lib.lib_OpenCnt) {
	b->b_Lib.lib_Flags |= 8;
	return 0;
    }

    seg = b->b_SegList;
    __Remove(sys, &b->b_Lib.lib_Node);
    __FreeMem((UBYTE *)b - b->b_Lib.lib_NegSize,
	      (ULONG)b->b_Lib.lib_NegSize + b->b_Lib.lib_PosSize);
    return seg;
}

LONG LibClose(struct BlzwBase *b __asm("a6"))
{
    if (--b->b_Lib.lib_OpenCnt == 0) {
	if (b->b_Lib.lib_Flags & 8)
	    return (LONG)LibExpunge(b);
    }
    return 0;
}

LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* workmem management (LAB_0047): keep the AllocMem'd block in	   */
/* xsp_Sub[0..1]; reuse it when large enough, else free+realloc.	   */
/* AllocMem flags = MEMF_ANY (the original passes a garbage-free	   */
/* d1=0).  Free is unconditional (LAB_0043 frees whatever ptr it	   */
/* finds, NULL included).						   */
/* ------------------------------------------------------------------ */

static APTR wm_grab(struct XpkSubParams *xsp, ULONG want)
{
    APTR  old = (APTR)xsp->xsp_Sub[0];
    ULONG have = xsp->xsp_Sub[1];

    if (old && want <= have)
	return old;
    if (old) {
	xsp->xsp_Sub[0] = 0;
	__FreeMem(old, have);
    }
    xsp->xsp_Sub[1] = want;
    old = __AllocMem(want, 0);
    xsp->xsp_Sub[0] = (ULONG)old;
    return old;
}

/* ------------------------------------------------------------------ */
/* XpksPackerInfo						   */
/* ------------------------------------------------------------------ */

extern const char xpkinfo[];

APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/* ------------------------------------------------------------------ */
/* the encoder (LAB_0028)						   */
/* ------------------------------------------------------------------ */

#define HTSZ	0x3c006		/* hash table bytes		   */
#define PACKMEM	HTSZ
#define PKMODE	15		/* hardcoded mode / max width	   */

static UBYTE  *pk_outp;		/* bit-writer cursor (a1)	   */
static LONG    pk_bits;		/* bits left in window (d2)	   */
static UWORD   pk_width;		/* current code width (a3)	   */
static UBYTE  *pk_bound;		/* expansion bound		   */

/* LAB_003C -- MSB-first bit writer; return -1 on bound overflow   */
static int pk_emit(ULONG code)
{
    ULONG v;
    pk_bits -= pk_width;
    if (pk_bits < 0) {
	pk_outp += 2;
	if (pk_outp >= pk_bound)
	    return -1;
	pk_bits += 16;
    }
    v = code << (pk_bits & 63);		/* asl.l dn -- 68k masks count */
    pk_outp[0] |= v >> 24;
    pk_outp[1] |= v >> 16;
    pk_outp[2] |= v >> 8;
    pk_outp[3] |= v;
    return 0;
}

static LONG blzw_pack(UBYTE *in, ULONG inlen, UBYTE *out, UWORD *tab)
{
    ULONG  i, d6, key, limit, chk_in, chk_out, ratio;
    LONG   nxt;
    UWORD  prev, byte, slen, maxstrlen;
    int    shift;

    if (inlen <= 0x7f)
	return 0;

    /* zero the bit-write window [out, out+(inlen&~31))		  */
    {
	ULONG *z = (ULONG *)out;
	ULONG  n = (inlen & ~31UL) >> 2;
	while (n--) *z++ = 0;
    }
    pk_outp  = out + 4;
    pk_bits  = 32;
    pk_bound = out + (inlen & ~31UL) - 8;
    pk_width = 9;
    maxstrlen = 0;
    shift   = PKMODE - 8;

    /* LAB_002B: clear table (word0 of every record = 0xffff)	  */
    {
	LONG k;
	for (k = 0; k <= 0xa000; k++)
	    tab[k*3] = 0xffff;
    }
    nxt   = 0x103;
    limit = 0x200;
    i     = 0;
    prev  = in[i++];
    chk_in = chk_out = ratio = 0;

    for (;;) {
	slen = 4;
	for (;;) {
	    UWORD *e;
	    LONG   a4;
	    if (i >= inlen)
		goto tail;
	    byte = in[i++];
	    key = (((ULONG)byte << shift) ^ prev) & 0xffff;
	    d6  = key * 6;
	    e = tab + (d6 >> 1);		/* home slot	   */
	    if ((SHORT)e[0] >= 0) {		/* occupied	   */
		if (e[1] != prev || e[0] != byte) {
		    a4 = (LONG)d6 - HTSZ + 6;	/* step frozen once */
		    for (;;) {			/* LAB_0030/31	   */
			d6 += a4;
			if ((LONG)d6 < 0)
			    d6 += HTSZ;
			e = tab + (d6 >> 1);
			if ((SHORT)e[0] < 0)
			    break;
			if (e[1] == prev && e[0] == byte)
			    break;
		    }
		}
	    }
	    if ((SHORT)e[0] >= 0) {		/* LAB_002D: hit	   */
		prev = e[2];
		slen++;
		continue;
	    }
	    break;				/* miss -> insert    */
	}

	/* LAB_0032: insert + emit					  */
	if (slen > maxstrlen)
	    maxstrlen = slen;
	{
	    UWORD *e = tab + (d6 >> 1);
	    e[2] = (UWORD)nxt;			/* code field first   */
	    if (nxt < 0 || nxt >= 0x8000) {
		/* frozen table -- LAB_0038 countdown + ratio check	  */
		nxt--;
		if ((nxt & 0xff) == 0) {
		    /* divu.w: 32-bit dividend / 16-bit divisor; on
		     * overflow (quot>0xffff) or divisor 0 the
		     * destination is left unchanged (low word keeps
		     * (num&0xff)<<8) -- faithful to the 68k.	   */
		    ULONG dd = (i - chk_in) << 8;
		    ULONG den = (ULONG)(pk_outp - out) - chk_out;
		    UWORD r;
		    __asm volatile ("divu %1,%0"
				    : "+d"(dd)
				    : "d"((UWORD)den));
		    r = (UWORD)dd;
		    if (r < ratio && (inlen - i) > 127) {
			/* ratio worsened: flush + RESET		  */
			if (pk_emit(prev) || pk_emit(byte)
			    || pk_emit(0x101))
			    return 0;
			{
			    LONG k;
			    for (k = 0; k <= 0xa000; k++)
				tab[k*3] = 0xffff;
			}
			nxt = 0x103; limit = 0x200; pk_width = 9;
			prev = in[i++];
			continue;
		    } else if ((SHORT)(r - (UWORD)ratio) >= 0) {
			chk_in = i;
			chk_out = pk_outp - out;
			ratio = r;
		    }
		}
		if (pk_emit(prev))
		    return 0;
		prev = byte;
		continue;
	    }
	    e[0] = byte;			/* record key fields  */
	    e[1] = prev;
	    nxt++;
	    if ((ULONG)nxt >= limit) {		/* LAB_0036	   */
		if (pk_width == PKMODE) {
		    /* LAB_0037: freeze table; header w0 = mode	  */
		    out[0] = 0;
		    out[1] = PKMODE;
		    nxt   = -1;
		    chk_in  = i;
		    chk_out = pk_outp - out;
		    ratio   = 0;
		} else if (prev < limit) {
		    /* pending code still fits -- emit only	  */
		} else {
		    if (pk_emit(0x102))	/* WIDTH-UP at old width */
			return 0;
		    pk_width++;
		    limit <<= 1;
		}
	    }
	    if (pk_emit(prev))
		return 0;
	    prev = byte;
	}
    }

tail:
    /* LAB_003E: trailing width-up if the last code needs it	  */
    if (prev >= limit) {
	if (pk_emit(0x102))
	    return 0;
	pk_width++;
    }
    if (pk_emit(prev) || pk_emit(0x100))
	return 0;
    pk_outp += 4;
    {
	UWORD m = maxstrlen & 0xfffc;
	out[2] = (UBYTE)(m >> 8);
	out[3] = (UBYTE)m;
    }
    if (out[0] == 0 && out[1] == 0) {	/* tst.w -- hdrw0 written at freeze */
	out[0] = (UBYTE)(pk_width >> 8);
	out[1] = (UBYTE)pk_width;
    }
    return (LONG)(pk_outp - out);
}

/* ------------------------------------------------------------------ */
/* XpksPackChunk (-36)						   */
/* ------------------------------------------------------------------ */

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UWORD *tab;
    LONG   rc;

    tab = (UWORD *)wm_grab(xsp, PACKMEM);
    if (!tab)
	return -7;
    rc = blzw_pack((UBYTE *)xsp->xsp_InBuf, xsp->xsp_InLen,
		   (UBYTE *)xsp->xsp_OutBuf, tab);
    xsp->xsp_OutLen = (ULONG)rc;
    return rc ? 0 : -17;
}

/* ------------------------------------------------------------------ */
/* the decoder (LIBFUNC_5)					   */
/* ------------------------------------------------------------------ */

static UBYTE  *up_inp;		/* bit-reader cursor (a0)	   */
static LONG    up_bits;		/* bits consumed in window (d0)	   */
static UWORD   up_width;		/* current code width (a2)	   */
static UWORD   up_mask;		/* code mask (d2)		   */

static UWORD rd_code(void)
{
    ULONG v;
    up_bits -= up_width;
    if (up_bits < 0) {
	up_inp += 2;
	up_bits += 16;
    }
    v = ((ULONG)up_inp[0] << 24) | ((ULONG)up_inp[1] << 16)
      | ((ULONG)up_inp[2] << 8)  |  (ULONG)up_inp[3];
    return (UWORD)(v >> (up_bits & 63)) & up_mask;
}

static LONG blzw_unpack(UBYTE *in, UBYTE *out, ULONG explen, UBYTE *wm)
{
    UWORD  w0 = ((UWORD)in[0] << 8) | in[1];
    ULONG  stacksz = ((ULONG)in[2] << 8) | in[3];
    UWORD *tab = (UWORD *)(wm + stacksz);	/* a5 = table	   */
    UBYTE *sp  = (UBYTE *)tab;			/* a4 stack, grows down */
    ULONG  free, budget;
    UWORD  code, w, d4, d6;
    UBYTE *o = out;
    ULONG  k;

    for (k = 0; k < 256; k++)
	tab[k*2] = 0xff00 + k;
    tab[0x100*2] = 0x8000;
    tab[0x101*2] = 0x8001;
    tab[0x102*2] = 0x8002;
    free = 259;					/* a6 = a5+0x40c	   */
    up_inp = in + 4;
    up_bits = 32;

    /* LAB_0057 -- (re)init width/mask/budget and read a literal	  */
reset:
    up_width = 9;
    up_mask  = 0x1ff;
    budget   = (1UL << w0) - 0x103;
    free     = 259;
    code = rd_code();
    *o++   = (UBYTE)code;			/* first = literal    */
    d6     = code & 0xff;
    d4     = code * 2;

    for (;;) {
	ULONG idx;
	code = rd_code();			/* LAB_004E	   */
	idx  = code;
	if (idx >= free) {			/* deferred KwKwK   */
	    *--sp = (UBYTE)d6;
	    idx = d4 >> 1;
	}
	while ((w = tab[idx*2]) < 0x8000) {	/* chain walk	   */
	    *--sp = (UBYTE)w;
	    idx = tab[idx*2 + 1] >> 1;
	}
	if (w <= 0x8002) {			/* subq #3; bvs	   */
	    k = w & 3;
	    if (k == 0)
		break;				/* END		   */
	    if (k == 1)
		goto reset;			/* RESET	   */
	    up_width++;				/* WIDTH-UP	   */
	    up_mask = (up_mask << 1) | 1;
	    continue;
	}
	/* literal leaf 0xffxx						  */
	*o++ = (UBYTE)w;
	d6 = (UBYTE)w;
	while (sp != (UBYTE *)tab)		/* drain stack	   */
	    *o++ = *sp++;
	if (budget) {
	    budget--;
	    tab[free*2]     = d6;		/* char		   */
	    tab[free*2 + 1] = d4;		/* doubled prev	   */
	    free++;
	}
	d4 = code * 2;				/* LAB_004D	   */
    }
    /* LAB_0059: produced must equal expected unpacked length	  */
    if ((ULONG)(o - out) != explen)
	return -14;
    return 0;
}

/* ------------------------------------------------------------------ */
/* XpksUnpackChunk (-54)						   */
/* ------------------------------------------------------------------ */

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE *in = (UBYTE *)xsp->xsp_InBuf;
    ULONG  w0 = ((ULONG)in[0] << 8) | in[1];
    ULONG  want = (4UL << w0) + (((ULONG)in[2] << 8) | in[3]);
    UBYTE *wm;

    wm = (UBYTE *)wm_grab(xsp, want);
    if (!wm)
	return -7;
    return blzw_unpack(in, (UBYTE *)xsp->xsp_OutBuf,
		       xsp->xsp_OutLen, wm);
}

/* ------------------------------------------------------------------ */
/* XpksPackFree (-42) / XpksUnpackFree (-60)			   */
/* ------------------------------------------------------------------ */

LONG XpksFreeWork(struct XpkSubParams *xsp __asm("a0"))
{
    APTR p = (APTR)xsp->xsp_Sub[0];
    xsp->xsp_Sub[0] = 0;
    __FreeMem(p, xsp->xsp_Sub[1]);
    return 0;
}
