/*
**	xpkSLZ3.c -- xpkSLZ3.library 1.1
**
**	C reconstruction of the shipped "SpeedLZ" XPK sublibrary
**	(Speed Lempel-Ziv77 for graphics data and fast decompress,
**	based on an Adisak Pochanayon workshop).
**
**	  -30	XpksPackerInfo -> static descriptor
**	  -36	XpksPackChunk    LZ77 encoder (256 KB 2-byte-context LRU)
**	  -42/-48/-60      -> null
**	  -54	XpksUnpackChunk  stream decoder (no outlen writeback)
**
**	Stream layout: a flag byte per group of 8 items; bit set =
**	2-byte match token, bit clear = literal.  Flag byte 0x00 is
**	special-cased: the decoder copies 8 literals verbatim.
**	Match token = ((off>>4)&0xf0)|(len-2), off&0xff -- 12-bit
**	backward offset, length 3..17.  A zero token byte ends the
**	stream (the packer forces the next flag bit high so the
**	decoder always enters the token path to see it; a full flag
**	group is terminated by an 0xff flag + zero token instead).
**
**	Packing starts at input position 1: buf[1] is pre-seeded with
**	src[0] and the flag counter starts at 1 so the seeded literal
**	occupies flag bit 7.  The workmem is a 4096-entry context
**	table (ctx = (b[i]&63)<<6 | (b[i+1]&63)) of 16-deep position
**	LRU lists; if no candidate yields length 17 the packer scans
**	every older window position down to pos-4095.
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
};

struct SlzBase			/* InitTable dataSize = 0x26 (38)	   */
{
    struct Library b_Lib;	/* 0x00 standard library node	   */
    ULONG  b_Pad;		/* 0x22 .. 0x25			   */
    BPTR   b_SegList;		/* 0x26 seglist, stored by LibInit   */
};				/* +38 is past the 38-byte PosSize;  */
				/* AllocMem rounds 38 -> 40 so the   */
				/* store lands in allocator padding  */

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

struct Library *LibOpen(struct SlzBase *b __asm("a6"))
{
    b->b_Lib.lib_OpenCnt++;
    b->b_Lib.lib_Flags &= ~8;		/* LIBF_DELEXP		   */
    return (struct Library *)b;
}

BPTR LibExpunge(struct SlzBase *b __asm("a6"))
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

LONG LibClose(struct SlzBase *b __asm("a6"))
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

/* XpksPackerInfo (-30)						   */
extern const UBYTE xpkinfo[];
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/* ------------------------------------------------------------------ */
/* XpksUnpackChunk (-54)						   */
/* ------------------------------------------------------------------ */

/* a0 = xsp; a1 = xsp_InBuf; a0 = xsp_OutBuf.  Decompresses the
 * flag-grouped LZ77 stream; a zero token byte terminates.  Does NOT
 * write xsp_OutLen back -- the original returns d0=0 only.	   */

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    const UBYTE *src = (const UBYTE *)xsp->xsp_InBuf;
    UBYTE *dst = (UBYTE *)xsp->xsp_OutBuf;

    for (;;) {
	ULONG flag = *src++;
	ULONG n;

	if (!flag) {			/* 8 raw literals	   */
	    dst[0] = src[0];  dst[1] = src[1];
	    dst[2] = src[2];  dst[3] = src[3];
	    dst[4] = src[4];  dst[5] = src[5];
	    dst[6] = src[6];  dst[7] = src[7];
	    src += 8;  dst += 8;
	    continue;
	}

	n = 8;
	do {
	    UBYTE tok;

	    flag += flag;		/* shift out the top bit    */
	    if (!(flag & 0x100)) {	/* literal		   */
		*dst++ = *src++;
		continue;
	    }

	    tok = *src++;
	    if (!tok)
		return 0;		/* end of stream	   */

	    {
		ULONG len = (tok & 15) + 2;
		ULONG off = ((tok << 4) & 0xf00) | *src++;
		const UBYTE *m = dst - off;

		while (len--)
		    *dst++ = *m++;
	    }
	} while (--n);
    }
}

/* ------------------------------------------------------------------ */
/* XpksPackChunk (-36)						   */
/* ------------------------------------------------------------------ */

/* context table: 4096 contexts x 16 LONGs (256 KB + 2 pad)	   */
#define CT_CTX(b0, b1)	((((b0) & 63) << 6) | ((b1) & 63))

/* ctxins -- shift the context's 16-position LRU right and insert
 * pos at the head (hunk 0x13c).					   */
static void ctxins(LONG *tab, ULONG b0, ULONG b1, ULONG pos)
{
    LONG *lst = &tab[CT_CTX(b0, b1) << 4];
    LONG  i;

    for (i = 15; i > 0; i--)
	lst[i] = lst[i - 1];
    lst[0] = (LONG)pos;
}

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE *src = (UBYTE *)xsp->xsp_InBuf;
    LONG   limit = (LONG)xsp->xsp_InLen - 1;	/* last index  */
    UBYTE *out = (UBYTE *)xsp->xsp_OutBuf;
    LONG  *tab;
    UBYTE  buf[20];
    LONG   pos, d6, remaining, flagw, count, eof;

    tab = (LONG *)__AllocMem(0x40002, MEMF_PUBLIC);
    {
	ULONG i;
	for (i = 0; i < 0x10000; i++)
	    tab[i] = -1;
    }

    /* seed: context of bytes 0,1 gets position 0		   */
    tab[CT_CTX(src[0], src[1]) << 4] = 0;

    flagw = 0;
    count = 1;			/* seeded literal occupies bit 7   */
    d6 = 2;
    buf[1] = src[0];
    pos = 1;
    remaining = limit;
    eof = 0;

    for (;;) {
	LONG bottom = pos - 4095;
	LONG bestlen = 0;
	LONG bestpos = 0;
	LONG *lst = &tab[CT_CTX(src[pos], src[pos + 1]) << 4];
	LONG  tries = 16;
	LONG  cand = -1;
	LONG  c, d3;

	if (bottom < 0)
	    bottom = 0;

	/* 16-entry context LRU candidates, then an exhaustive
	 * backward scan to the window bottom when the list did
	 * not already produce a length-17 match		   */
	for (;;) {
	    LONG upd = 0;

	    if (tries) {
		tries--;
		if (!tries)
		    break;		/* list exhausted	   */
		cand = *lst++;
		if (cand >= bottom)
		    goto cmpcand;
		break;			/* out of window	   */
	    }
	cmpcand:
	    d3 = 0;
	    for (;;) {
		if (src[cand + d3] != src[pos + d3])
		    break;
		if (d3 >= 17)
		    break;
		d3++;
	    }
	    if (d3 > bestlen) {
		if (pos + d3 <= limit) {
		    bestlen = d3;
		    bestpos = cand;
		} else if (limit - pos > bestlen) {
		    bestlen = limit - pos;
		    bestpos = cand;
		}
		upd = 1;
	    }
	    if (upd && bestlen == 17)
		break;
	}

	/* exhaustive scan: last candidate position -1 .. bottom */
	for (c = cand; c >= bottom; c--) {
	    d3 = 0;
	    for (;;) {
		if (src[c + d3] != src[pos + d3])
		    break;
		if (d3 >= 17)
		    break;
		d3++;
	    }
	    if (d3 > bestlen) {
		if (pos + d3 <= limit) {
		    bestlen = d3;
		    bestpos = c;
		} else if (limit - pos > bestlen) {
		    bestlen = limit - pos;
		    bestpos = c;
		}
	    }
	    if (bestlen == 17)
		break;
	}

	if (bestlen > 2) {
	    LONG off = pos - bestpos;
	    LONG i;

	    flagw |= 0x80 >> count;
	    buf[d6]     = (UBYTE)(((off >> 4) & 0xf0) | (bestlen - 2));
	    buf[d6 + 1] = (UBYTE)off;
	    d6 += 2;
	    remaining -= bestlen;
	    for (i = 0; i < bestlen; i++) {
		ctxins(tab, src[pos], src[pos + 1], pos);
		pos++;
	    }
	} else {
	    buf[d6] = src[pos];
	    d6++;
	    ctxins(tab, src[pos], src[pos + 1], pos);
	    pos++;
	    remaining--;
	}

	if (remaining <= 0)
	    eof = 1;
	count++;

	if (count < 8 && !eof)
	    continue;
	if (!eof) {
	    LONG i;

	    buf[0] = (UBYTE)flagw;
	    for (i = 0; i < d6; i++)
		*out++ = buf[i];
	    d6 = 1;
	    count = 0;
	    flagw = 0;
	    continue;
	}

	/* final block						   */
	if (count == 8) {
	    LONG i;

	    buf[0] = (UBYTE)flagw;
	    for (i = 0; i < d6; i++)
		*out++ = buf[i];
	    *out++ = 0xff;
	    *out++ = 0;
	} else {
	    LONG i;

	    buf[0] = (UBYTE)(flagw | (0x80 >> count));
	    for (i = 0; i < d6; i++)
		*out++ = buf[i];
	    *out++ = 0;
	}
	break;
    }

    __FreeMem(tab, 0x40002);
    xsp->xsp_OutLen = (ULONG)(out - (UBYTE *)xsp->xsp_OutBuf);
    return 0;
}
