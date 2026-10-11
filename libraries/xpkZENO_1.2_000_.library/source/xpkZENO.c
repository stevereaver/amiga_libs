/*
**	xpkZENO.c -- C reconstruction of xpkZENO.library 1.2
**	"ZENO V1.2" (Gerhard Tuenkler, 1 Oct 2013).
**
**	XPK sublibrary: variable-width LZW ("LZW 1-14 bit") over
**	raw bytes, with an optional password hash in the stream
**	header.  Vector map (AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 LibNull (entry stub via 0xff6c wrap)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 LibNull (PackReset no-op)
**	                      -54 XpksUnpackChunk
**	                      -60 XpksUnpackFree (== PackFree)
**
**	Stream layout:
**	  u32 hash       pwhash(xsp_Password), or 0
**	  u8  bits       max code width 12..14 (mode 1-33/34-66/67-100)
**	  u8  namelen    embedded-name length (packer writes 0)
**	  ...            MSB-first LZW codes in u32 longs, width 9->bits;
**	                 0x100 = EOI, 0x101 = dictionary reset;
**	                 literal codes are raw bytes; dict codes run
**	                 0x103..(emitted value = stored code - 1)
**
**	xsp_Mode selects bits: 0->1, >99->99, bits = (mode-1)/33+12.
**
**	Pack workmem (AllocMem(5*D3+8); D3 = (1<<bits)+0x800):
**	  alloc+0    u32 size prefix
**	  alloc+4    stored hash long (copied to stream[0..4])
**	  alloc+8    T_code u16[D3]   hash-slot -> dict code
**	  +8+2*D3    T_pref u16[D3]   hash-slot -> prevcode+1 (0 = free)
**	  +8+4*D3    T_char u8[D3]    hash-slot -> extension byte
**
**	Unpack workmem (AllocMem(3*T+4); T = 1<<bits):
**	  alloc+0    u32 size prefix
**	  alloc+4    T_prev u16[T]    dict -> prefix code
**	  +4+2*T     T_char u8[T]     dict -> last char
**	  string unwind stack = outbuf + OutBufLen (descending)
**
**	The original keeps probe/emit state swap-packed in d2/d5/d6/d7
**	(hi/lo word pairs exchanged around each emit).  The C version
**	uses separate variables with identical semantics.
**
**	Shipped quirks reproduced verbatim:
**	  - the packer dereferences xsp_Password unconditionally
**	    (tst.l (a1)) -- a NULL pointer crashes; an empty string
**	    (first long zero) selects the plaintext marker 0.
**	  - the dictionary reset compares emitted-bytes-per-1024-input
**	    against previous delta + 128 -- signed .l compare.
**	  - hash-probe rehash restarts at 0x7ff + (byte<<shift) and
**	    steps by prevcode+1 with a SINGLE wrap subtract of the
**	    per-width modulus (read out of code bytes at 0x3da+).
**	  - dictionary clear zeroes [T_pref-2*D3+256, T_pref end):
**	    all of T_pref but only T_code[128..).
**	  - the RESET code is emitted at the old grown width, then
**	    width/maxcode are reset.
**	  - decoder nextcode starts at 0x103 but resets to 0x102
**	    (one dead slot absorbs the boundary-spanning entry).
**	  - unpacker stores bits/Tsize into xsp_Sub[3]/Sub[2] and
**	    never writes xsp_OutLen.
**	  - no output bound check on unpack; the unwind stack lives
**	    at the END of the output buffer.
**	  - decoder inserts only while nextcode < Tsize-2.
**	  - emit adds (add.l) into pre-cleared longs; +4 tail slop.
*/

#define SYSBASE (*(APTR *)4)

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t        UBYTE;
typedef uint16_t       UWORD;
typedef uint32_t       ULONG;
typedef int32_t        LONG;
typedef int16_t        SHORT;
typedef int8_t         BYTE;
typedef void          *APTR;
typedef char          *STRPTR;
typedef ULONG          BPTR;
#define LIBF_DELEXP 0x08
struct Library {
    UBYTE  ln_pad[14];
    UWORD  lib_Flags;
    UWORD  lib_NegSize;
    UWORD  lib_PosSize;
    UWORD  lib_Version;
    UWORD  lib_Revision;
    ULONG  lib_IdString;
    ULONG  lib_Sum;
    UWORD  lib_OpenCnt;
};
#else
#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#endif

struct XpkSubParams {
    APTR    xsp_InBuf;		/* 0x00 */
    ULONG   xsp_InLen;		/* 0x04 */
    APTR    xsp_OutBuf;		/* 0x08 */
    ULONG   xsp_OutBufLen;	/* 0x0c */
    ULONG   xsp_OutLen;		/* 0x10 */
    ULONG   xsp_Flags;		/* 0x14 */
    ULONG   xsp_Number;		/* 0x18 */
    ULONG   xsp_Mode;		/* 0x1c */
    STRPTR  xsp_Password;	/* 0x20 */
    UWORD   xsp_LibVersion;	/* 0x24 */
    UWORD   xsp_Pad;		/* 0x26 */
    ULONG   xsp_Arg[3];		/* 0x28 */
    ULONG   xsp_Sub[4];		/* 0x34 */
};

struct ZenoBase {
    struct Library lib;
    ULONG   b_SegList;		/* 0x22 seglist, stored by LibInit */
};

static void wr16(UBYTE *p, UWORD v)
{
    p[0] = (UBYTE)(v >> 8); p[1] = (UBYTE)v;
}

static void wr32(UBYTE *p, ULONG v)
{
    p[0] = (UBYTE)(v >> 24); p[1] = (UBYTE)(v >> 16);
    p[2] = (UBYTE)(v >> 8);  p[3] = (UBYTE)v;
}

static ULONG rd32(const UBYTE *p)
{
    return ((ULONG)p[0] << 24) | ((ULONG)p[1] << 16) |
	   ((ULONG)p[2] << 8)  | (ULONG)p[3];
}

/* the original uses plain move.w/move.l (big-endian).  Use native
 * access on the target; explicit BE helpers keep the host test
 * model identical.					      */
#ifdef HOST_TEST
#define NRD16(p)	((UWORD)(((const UBYTE *)(p))[0] << 8 | \
				((const UBYTE *)(p))[1]))
#define NWR16(p, v)	wr16((UBYTE *)(p), (v))
#define NRD32(p)	rd32((const UBYTE *)(p))
#define NWR32(p, v)	wr32((UBYTE *)(p), (v))
#else
#define NRD16(p)	(*(const UWORD *)(p))
#define NWR16(p, v)	(*(UWORD *)(p) = (v))
#define NRD32(p)	(*(const ULONG *)(p))
#define NWR32(p, v)	(*(ULONG *)(p) = (v))
#endif

/* -------------------------------------------------------------- */
/* exec calls							    */
/* -------------------------------------------------------------- */

#ifdef HOST_TEST
extern APTR host_AllocMem(ULONG sz);
extern void host_Remove(void *n);
extern void host_FreeMem(void *p, ULONG sz);
#define exec_AllocMem(sz)  host_AllocMem(sz)
#define exec_Remove(n)     host_Remove(n)
#define exec_FreeMem(p,sz) host_FreeMem(p,sz)
#else
static APTR exec_AllocMem(ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register ULONG __p_sz __asm("d0") = sz;
    register APTR __r __asm("d0");
    __asm volatile ("jsr %/a6@(-198:W)\n"
	: "=r" (__r)
	: "a" (__p_sys), "r" (__p_sz)
	: "a0","a1","d1","memory");
    return __r;
}

static void exec_Remove(void *n)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_n __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)\n"
	:
	: "a" (__p_sys), "a" (__p_n)
	: "a0","d0","d1","memory");
}

static void exec_FreeMem(void *p, ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_p __asm("a1") = p;
    register ULONG __p_sz __asm("d0") = sz;
    __asm volatile ("jsr %/a6@(-210:W)\n"
	:
	: "a" (__p_sys), "a" (__p_p), "r" (__p_sz)
	: "a0","d1","memory");
}
#endif

/* -------------------------------------------------------------- */
/* lifecycle							    */
/* -------------------------------------------------------------- */

/* -6 Open: ++OpenCnt; clear DELEXP; return base */
struct Library *LibOpen(struct ZenoBase *b __asm("a6"))
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

/* expunge body: removes + frees the library; returns the seglist */
static BPTR expunge_body(struct ZenoBase *b)
{
    BPTR seg = b->b_SegList;
    ULONG  sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
    exec_Remove(b);
    exec_FreeMem(p, sz);
    return seg;
}

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge;
 * otherwise returns 0 via the hunk+0 entry stub.		    */
LONG LibClose(struct ZenoBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt == 0 &&
	(b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge: OpenCnt>0 -> set DELEXP, return 0; else expunge now */
LONG LibExpunge(struct ZenoBase *b __asm("a6"))
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return (LONG)expunge_body(b);
}

/* -------------------------------------------------------------- */
/* password hash (LAB_003F)					    */
/*	d0 = 0; d2 = 0;					    */
/*	per char: d0 = (d0<<4) | c (byte OR into shifted d0);	    */
/*		  d2 += c;					    */
/*	return d0 + d2;						    */
/* -------------------------------------------------------------- */

static ULONG pwhash(STRPTR pw)
{
    ULONG d0 = 0, d2 = 0;
    UBYTE c;
    while ((c = (UBYTE)*pw++)) {
	d0 <<= 4;
	d0 = (d0 & 0xffffff00) | ((d0 | c) & 0xff);
	d2 += c;
    }
    return d0 + d2;
}

/* -------------------------------------------------------------- */
/* -30 XpksPackerInfo: return the XpkInfo descriptor		    */
/* -------------------------------------------------------------- */

extern UBYTE xpkinfo[];

APTR XpksPackerInfo(void)
{
    return xpkinfo;
}

/* -------------------------------------------------------------- */
/* -42/-60 XpksPackFree / XpksUnpackFree			    */
/*	frees Sub[0]-4 via its size prefix; leaves a stale	    */
/*	pointer in Sub[0] (faithful).				    */
/* -------------------------------------------------------------- */

void XpksPackFree(struct XpkSubParams *xsp __asm("a0"))
{
    ULONG body = xsp->xsp_Sub[0];
    if (body) {
	UBYTE *alloc = (UBYTE *)body - 4;
	exec_FreeMem(alloc, NRD32(alloc));
    }
}

/* -------------------------------------------------------------- */
/* pack-side helper state					    */
/* -------------------------------------------------------------- */

/* nostdlib build -- local byte clear (orig uses movem bursts)    */
static void zclr(UBYTE *p, ULONG n)
{
    while (n--)
	*p++ = 0;
}

/* per-width rehash modulus: the original reads these words out of
 * code bytes at hunk+0x3c2+2*bits; only bits 12..14 reachable    */
static UWORD zeno_modulus(UWORD bits)
{
    switch (bits) {
    case 12: return 0x1003;
    case 13: return 0x2011;
    case 14: return 0x47fb;
    default: return 0x87f7;		/* bits 15 table slot     */
    }
}

/* -------------------------------------------------------------- */
/* -36 XpksPackChunk						    */
/* -------------------------------------------------------------- */

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE *a2, *a1, *a0, *a4;
    UWORD *T_code, *T_pref;
    UBYTE *T_char;
    ULONG bits, D3, bound, hshift, modulus;
    ULONG width, maxcode, nextcode;
    LONG  bitspace;
    ULONG prevcode1;			/* d4: prev code + 1    */
    ULONG h;				/* d1: hash slot	    */
    ULONG d3;				/* current byte	    */
    UWORD mask;				/* (1<<bits)-1, insert bound */
    UBYTE *checkpoint, *lastemit;
    ULONG thresh;
    UBYTE *body;

    if (xsp->xsp_Sub[0] == 0) {
	ULONG mode = xsp->xsp_Mode;
	ULONG size;
	UBYTE *alloc;
	if (mode == 0)
	    mode = 1;
	else if ((BYTE)mode > 0x63)
	    mode = 0x63;
	bits = (UWORD)((SHORT)(UWORD)(mode - 1) / 0x21) + 0x0c;
	xsp->xsp_Sub[3] = bits;
	D3 = (1UL << bits) + 0x800;
	size = 5 * D3 + 8;
	alloc = exec_AllocMem(size);
	if (alloc == 0)
	    return -7;
	NWR32(alloc, size);		/* size prefix		*/
	body = alloc + 4;
	xsp->xsp_Sub[0] = (ULONG)body;
	xsp->xsp_Sub[1] = (ULONG)(body + 4 + 2 * D3);
	xsp->xsp_Sub[2] = (ULONG)(body + 4 + 4 * D3);
	{
	    ULONG hv = 0;
	    /* tst.l (a1) -- dereferences the password pointer    */
	    if (NRD32(xsp->xsp_Password) != 0)
		hv = pwhash(xsp->xsp_Password);
	    NWR32(body, hv);
	}
    }

    body = (UBYTE *)xsp->xsp_Sub[0];
    bits = xsp->xsp_Sub[3];
    D3 = (1UL << bits) + 0x800;
    bound = D3;
    hshift = bits - 8;
    modulus = zeno_modulus((UWORD)bits);
    mask = (UWORD)((1UL << bits) - 1);

    T_code = (UWORD *)(body + 4);		/* a6 after (a6)+	    */
    T_pref = (UWORD *)xsp->xsp_Sub[1];		/* a3		    */
    T_char = (UBYTE *)xsp->xsp_Sub[2];		/* a5		    */

    /* clear: 4*D3-256 bytes ending at T_pref end ==
     * all of T_pref plus T_code[128..]			    */
    {
	UBYTE *p = (UBYTE *)T_pref + 2 * D3;
	zclr(p - (4 * D3 - 256), 4 * D3 - 256);
    }

    a2 = (UBYTE *)xsp->xsp_InBuf;		/* input cursor	    */
    a1 = a2 + xsp->xsp_InLen;			/* input end	    */
    a0 = (UBYTE *)xsp->xsp_OutBuf;		/* emit cursor	    */
    a4 = a0 + xsp->xsp_InLen;			/* output budget end   */

    /* header: hash long, bits byte, name-length byte (0)	    */
    NWR32(a0, NRD32(body)); a0 += 4;
    *a0++ = (UBYTE)bits;
    *a0++ = 0;
    NWR32(a0, 0);				/* pre-clear emit long */

    checkpoint = a2 + 1024;
    lastemit = a0;
    thresh = 0x000fffff;

    width = 9; maxcode = 0x1ff; nextcode = 0x104;
    bitspace = 32;

    prevcode1 = (ULONG)*a2++ + 1;		/* first byte, +1 bias */

#define ZEMIT(codev)						    \
    do {							    \
	ULONG _c = (codev);					    \
	if (nextcode >= maxcode && width < bits) {		    \
	    maxcode = maxcode * 2 + 1;				    \
	    ++width;						    \
	}							    \
	bitspace -= width;					    \
	if (bitspace <= 0) {					    \
	    LONG _o;						    \
	    ULONG _s = _c;					    \
	    bitspace += 32;					    \
	    _o = 32 - bitspace;	/* overflow bits (-old space) */ \
	    NWR32(a0, NRD32(a0) + (_s >> _o));			    \
	    a0 += 4;						    \
	    NWR32(a0, 0);					    \
	    _c = _s;						    \
	}							    \
	if (bitspace < 32)					    \
	    NWR32(a0, NRD32(a0) + (_c << bitspace));		    \
    } while (0)

    for (;;) {
	ULONG w;
	int hit = 0;
	if (a2 >= a1)
	    break;				/* LAB_0022 done    */
	d3 = *a2++;
	w = (d3 << hshift) & 0xffff;
	h = w ^ prevcode1;			/* u16 hash	    */
	/* probe -- a hit skips emit/insert/checkpoint		    */
	if (NRD16((UBYTE *)T_pref + 2 * h) == prevcode1 &&
	    T_char[h] == (UBYTE)d3)
	    hit = 1;
	else if (NRD16((UBYTE *)T_pref + 2 * h) != 0) {
	    /* collision chain: restart at 0x7ff + (b<<shift),   */
	    /* step prevcode1, single modulus wrap		    */
	    h = (0x7ff + w) & 0xffff;
	    for (;;) {
		ULONG m;
		h = (h + prevcode1) & 0xffff;
		if (h >= bound)
		    h -= modulus;
		m = NRD16((UBYTE *)T_pref + 2 * h);
		if (m == prevcode1 &&
		    T_char[h] == (UBYTE)d3) {
		    hit = 1;
		    break;
		}
		if (m == 0)
		    break;
	    }
	}
	if (hit) {
	    prevcode1 = NRD16((UBYTE *)T_code + 2 * h);
	    continue;
	}
	/* LAB_001F: emit prevcode, insert at empty slot h	    */
	ZEMIT(prevcode1 - 1);
	if (nextcode < mask) {
	    T_char[h] = (UBYTE)d3;
	    NWR16((UBYTE *)T_pref + 2 * h, (UWORD)prevcode1);
	    NWR16((UBYTE *)T_code + 2 * h, (UWORD)nextcode);
	    ++nextcode;
	}
	prevcode1 = d3 + 1;
	if (a2 >= checkpoint) {
	    ULONG delta, oldt;
	    checkpoint = a2 + 1024;
	    delta = a0 - lastemit;
	    oldt = thresh;
	    thresh = delta;
	    lastemit = a0;
	    if (delta >= oldt + 128) {
		/* adaptive dictionary reset: emit 0x101 at	    */
		/* the old width, then restart		    */
		UBYTE *p;
		thresh = 0x000fffff;
		p = (UBYTE *)T_pref + 2 * D3;
		zclr(p - (4 * D3 - 256), 4 * D3 - 256);
		nextcode = 0x104;
		ZEMIT(0x101);
		width = 9;
		maxcode = 0x1ff;
	    }
	}
	if (a0 >= a4)
	    return -17;				/* LAB_0023	    */
    }

    /* LAB_0022: drain					    */
    ZEMIT(prevcode1 - 1);
    ZEMIT(0x100);				/* EOI		    */
    xsp->xsp_OutLen = (ULONG)(a0 + 4 - (UBYTE *)xsp->xsp_OutBuf);
    return 0;
#undef ZEMIT
}

/* -------------------------------------------------------------- */
/* -54 XpksUnpackChunk						    */
/* -------------------------------------------------------------- */

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE *a2 = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *a3 = (UBYTE *)xsp->xsp_OutBuf;
    UBYTE *stk;
    UWORD *T_prev;
    UBYTE *T_char;
    ULONG bits, Tsize;
    ULONG width, mask, nextcode;
    LONG  bitpos;
    ULONG threshold;
    ULONG prevcode;
    UBYTE firstchar;
    ULONG code, d4, d7;
    LONG  depth;

    if (xsp->xsp_Sub[0] == 0) {
	ULONG size;
	UBYTE *alloc, *body;
	if (NRD32(a2) != 0) {
	    if (pwhash(xsp->xsp_Password) != NRD32(a2))
		return -32;
	}
	bits = a2[4];
	xsp->xsp_Sub[3] = bits;
	Tsize = 1UL << bits;
	xsp->xsp_Sub[2] = Tsize;
	size = 3 * Tsize + 4;
	alloc = exec_AllocMem(size);
	if (alloc == 0)
	    return -7;
	NWR32(alloc, size);
	body = alloc + 4;
	xsp->xsp_Sub[0] = (ULONG)body;
	xsp->xsp_Sub[1] = (ULONG)(body + 2 * Tsize);
    }

    bits = xsp->xsp_Sub[3];
    Tsize = xsp->xsp_Sub[2];
    T_prev = (UWORD *)xsp->xsp_Sub[0];
    T_char = (UBYTE *)xsp->xsp_Sub[1];

    a2 += 6 + a2[5];				/* header + name    */
    stk = a3 + xsp->xsp_OutBufLen;		/* unwind stack top  */

    width = 9; mask = 0x1ff; nextcode = 0x103;
    bitpos = 23;
    code = (NRD32(a2) >> 23) & 0x1ff;		/* first 9-bit code  */
    prevcode = code;
    threshold = 0x1fd;
    firstchar = (UBYTE)code;			/* d1 keeps it	    */
    *a3++ = (UBYTE)code;			/* emit literal byte */

    for (;;) {
	/* LAB_0030: grow when nextcode hits mask-2 (width<bits)  */
	if (nextcode >= threshold && width < bits) {
	    mask = mask * 2 + 1;
	    threshold = mask - 2;
	    ++width;
	}
	/* LAB_0031: bit reader, MSB-first within u32 longs	    */
	d4 = 0;
	bitpos -= width;
	if (bitpos > 0) {
	    d4 = (NRD32(a2) >> bitpos) & mask;
	} else if (bitpos == 0) {
	    d4 = NRD32(a2) & mask;
	    a2 += 4;
	    bitpos = 32;
	} else {
	    d4 = (NRD32(a2) << (-bitpos)) & mask;
	    a2 += 4;
	    bitpos += 32;
	    d4 += (NRD32(a2) >> bitpos) & mask;
	}
	code = d4;
	if (code > 0x101) {
	    /* dict string					    */
	} else if (code == 0x101) {
	    /* reset: nextcode 0x102 (one dead slot), width 9	    */
	    nextcode = 0x102;
	    width = 9;
	    threshold = 0x1fd;
	    mask = 0x1ff;
	    continue;
	} else if (code == 0x100) {
	    return 0;				/* EOI		    */
	}
	/* LAB_0036: decode					    */
	d7 = code;
	depth = 0;
	if (code == nextcode) {			/* KwKwK	    */
	    *--stk = firstchar;
	    code = prevcode;
	    depth = 1;
	}
	if (code > 0x100) {
	    /* LAB_0038: unwind through T_char/T_prev		    */
	    do {
		*--stk = T_char[code];
		++depth;
		code = NRD16((UBYTE *)T_prev + 2 * code);
	    } while (code > 0x100);
	    firstchar = (UBYTE)code;
	    *--stk = firstchar;
	    /* LAB_0039: copy depth+1 bytes			    */
	    {
		LONG n = depth;
		do {
		    *a3++ = *stk++;
		} while (n-- > 0);
	    }
	} else {
	    /* LAB_003A: literal (or KwKwK root)		    */
	    firstchar = (UBYTE)code;
	    *a3++ = firstchar;
	    if (depth)
		*a3++ = *stk++;
	}
	/* LAB_002E: dict insert while nextcode < Tsize-2	    */
	if (nextcode < Tsize - 2) {
	    NWR16((UBYTE *)T_prev + 2 * nextcode, (UWORD)prevcode);
	    T_char[nextcode] = firstchar;
	    ++nextcode;
	}
	prevcode = d7;
    }
}
