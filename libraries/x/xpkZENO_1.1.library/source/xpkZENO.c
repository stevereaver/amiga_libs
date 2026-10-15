/*
**	xpkZENO.c -- C reconstruction of xpkZENO.library 1.1
**	"xpkZENO 1.1" (LZ78 12-14bit; an earlier generation than
**	the 1.2/2013 rebuild).
**
**	XPK sublibrary: variable-width LZW over raw bytes with an
**	optional password hash in the stream header.  Vector map
**	(AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 LibNull (entry stub)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 LibNull (PackReset no-op)
**	                      -54 XpksUnpackChunk
**	                      -60 XpksUnpackFree (own routine, 4-byte
**	                        under-free vs the unpack alloc)
**
**	Stream layout:
**	  u32 hash       pwhash(xsp_Password), or 0
**	  u8  bits       max code width 12..14 (mode 1-33/34-66/67-100)
**	  u8  namelen    pad so the code stream lands long-aligned;
**	                 the packer writes 3-(ptr&3) pad bytes and
**	                 leaves them UNWRITTEN (stale buffer content)
**	  ...            MSB-first LZW codes in u32 longs, width 9->bits;
**	                 0x100 = EOI, 0x101 = dictionary reset;
**	                 literal codes are raw bytes; dict codes run
**	                 0x103..(emitted value = stored code - 1)
**
**	xsp_Mode byte (low byte of xsp_Mode) selects bits via a
**	signed clamp 1..99; bits = (mode-1)/33+12 (signed divide).
**
**	Pack workmem (AllocMem(7*D3+8, MEMF_CLEAR); D3=(1<<bits)+0x800):
**	  alloc+0      u32 stored hash long (copied to stream[0..4])
**	  alloc+4      T_code u16[D3]  hash-slot -> dict code
**	  +4+2*D3      T_pref u16[D3]  hash-slot -> prevcode+1 (0 = free)
**	  +4+4*D3      DEAD 2*D3+4 byte gap (never touched)
**	  +8+6*D3      T_char u8[D3]   hash-slot -> extension byte
**
**	Unpack workmem (AllocMem(4*Tsize+8, MEMF_CLEAR)):
**	  alloc+0      u32 stored hash result
**	  alloc+4      T_prev u16[Tsize]
**	  +4+2*Tsize   T_char u8[Tsize]
**	  string unwind stack = outbuf + xsp_OutBufLen (descending)
**
**	Shipped quirks reproduced verbatim:
**	  - InLen < 128 (signed) returns -17 without touching outbuf.
**	  - the packer tests tst.l (a1) on xsp_Password -- a NULL
**	    pointer crashes; an empty string selects plaintext 0.
**	  - AllocMem failure does NOT return: the mode byte is
**	    rewritten (>=67 -> 50, 34..66 -> 0) and the alloc is
**	    retried at a smaller dictionary; mode < 34 -> -7.
**	    an identical orphan fallback block sits at 0x5bc
**	    (unreachable -- dead code).
**	  - the dictionary reset compares emitted-bytes-per-1024-input
**	    against previous delta + 128 (signed .l compare), then
**	    rewinds prevdelta to 0xfffff.
**	  - hash-probe rehash restarts at 0x7ff + (byte<<shift) and
**	    steps by prevcode+1 with a SINGLE wrap subtract of the
**	    per-width modulus (code-resident table at hunk+0xb2).
**	  - dictionary clear zeroes ONLY T_pref (2*D3 bytes), both at
**	    init and on reset; T_code/T_char keep stale contents.
**	  - the RESET code is emitted at the old grown width, then
**	    width/maxcode are reset.
**	  - OutLen = (emit cursor + 8) - outbuf: the cursor points at
**	    the last partially-written long, so the +8 covers the
**	    header slop, not the trailing bytes.
**	  - decoder nextcode starts at 0x103 but resets to 0x102
**	    (one dead slot absorbs the boundary-spanning entry).
**	  - decoder inserts only while nextcode < Tsize-2.
**	  - decoder reads its bit stream with a signed byte counter
**	    (d6); a data start congruent to 3 mod 4 loses the first
**	    code's low bit (dead read of the next long's top bit) --
**	    unreachable because the packer aligns data to longs.
**	  - output production may overshoot the OutLen field by up to
**	    12 bytes; the unwind stack sits at the END of the output
**	    buffer (outbuf + xsp_OutBufLen).
**	  - final validity check: produced-12 <= xsp_OutLen else -14.
**	  - XpksUnpackFree frees 4*Tsize+4 while the unpacker
**	    allocates 4*Tsize+8 (4-byte under-free defect).
*/

#define SYSBASE (*(APTR *)4)

#ifdef HOST_TEST
#define REGPARM_A0
#define REGPARM_A6
#else
#define REGPARM_A0 __asm("a0")
#define REGPARM_A6 __asm("a6")
#endif

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
#define exec_AllocMemAttr(sz,at) host_AllocMem(sz)
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

static APTR exec_AllocMemAttr(ULONG sz, ULONG attr)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register ULONG __p_sz __asm("d0") = sz;
    register ULONG __p_at __asm("d1") = attr;
    register APTR __r __asm("d0");
    __asm volatile ("jsr %/a6@(-198:W)\n"
	: "=r" (__r)
	: "a" (__p_sys), "r" (__p_sz), "r" (__p_at)
	: "a0","a1","memory");
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
struct Library *LibOpen(struct ZenoBase *b REGPARM_A6)
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
LONG LibClose(struct ZenoBase *b REGPARM_A6)
{
    if (--b->lib.lib_OpenCnt == 0 &&
	(b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge: OpenCnt>0 -> set DELEXP, return 0; else expunge now */
LONG LibExpunge(struct ZenoBase *b REGPARM_A6)
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return (LONG)expunge_body(b);
}

/* -------------------------------------------------------------- */
/* LibInit -- a0 = seglist, d0 = libbase, a6 = execbase	    */
/*	initializes the library header fields itself (datatab = 0),  */
/*	stores the seglist at base+34, clones the 20-byte InitTable  */
/*	image at base+48 and runs the (empty) fixup list over it.    */
/* -------------------------------------------------------------- */

#ifndef HOST_TEST
extern ULONG inittab_img[];	/* [pad0, inittab(4), fixup count] */
extern const char libname[], idstr[];

APTR LibInit(struct ZenoBase *b __asm("d0"), ULONG seglist REGPARM_A0)
{
    b->b_SegList = seglist;				/* +34	    */
    ((UBYTE *)b)[8] = 9;				/* ln_Type    */
    *(const char **)((UBYTE *)b + 10) = libname;	/* ln_Name    */
    ((UBYTE *)b)[14] = 6;				/* ln_Flags   */
    *(UWORD *)((UBYTE *)b + 20) = 1;			/* version    */
    *(UWORD *)((UBYTE *)b + 22) = 1;			/* revision   */
    *(ULONG *)((UBYTE *)b + 24) = (ULONG)idstr;	/* IdString   */
    {
	/* copy the 20 bytes at _inittab_img (pad long + the
	 * InitTable) into base+48, then apply the fixup list:
	 * count = img[5], offsets follow -- each adds the image
	 * base to the addressed long.  The shipped image has
	 * count 0, so the loop is dead.			    */
	ULONG *dst = (ULONG *)((UBYTE *)b + 48);
	const ULONG *src = inittab_img;
	ULONG count, *fx;
	int i;
	for (i = 0; i < 20; ++i)
	    ((UBYTE *)dst)[i] = ((const UBYTE *)src)[i];
	count = src[5];
	fx = (ULONG *)(src + 6);
	while ((LONG)count > 0) {
	    *(ULONG *)((UBYTE *)dst + *fx) += (ULONG)dst;
	    ++fx;
	    --count;
	}
    }
    return (APTR)b;
}
#endif

/* -------------------------------------------------------------- */
/* password hash (LAB_0046 at 0x846)				    */
/*	d0 = 0; d2 = 0;					    */
/*	per char: d0 = (d0<<4) | c (byte OR into low byte);	    */
/*		  d2 += c;					    */
/*	return d0 + d2;						    */
/* -------------------------------------------------------------- */

static ULONG pwhash(STRPTR pw)
{
    ULONG d0 = 0, d2 = 0;
    UBYTE c;
    while ((c = (UBYTE)*pw++)) {
	d0 <<= 4;
	d0 |= c;
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
/* -42 XpksPackFree						    */
/*	recomputes 7*D3+8 from Sub[3].b and frees Sub[0];	    */
/*	clears Sub[0] before the call.				    */
/* -------------------------------------------------------------- */

void XpksPackFree(struct XpkSubParams *xsp REGPARM_A0)
{
    ULONG body = xsp->xsp_Sub[0];
    if (body) {
	UBYTE *p = (UBYTE *)body;
	ULONG bits = ((UBYTE *)xsp)[67];
	ULONG d3 = (1UL << bits) + 0x800;
	ULONG size = 7 * d3 + 8;
	xsp->xsp_Sub[0] = 0;
	exec_FreeMem(p, size);
    }
}

/* -------------------------------------------------------------- */
/* -60 XpksUnpackFree						    */
/*	same shape but frees 4*Tsize+4 -- FOUR BYTES SHORT of	    */
/*	the 4*Tsize+8 the unpacker allocates (shipped defect).	    */
/* -------------------------------------------------------------- */

void XpksUnpackFree(struct XpkSubParams *xsp REGPARM_A0)
{
    ULONG body = xsp->xsp_Sub[0];
    if (body) {
	UBYTE *p = (UBYTE *)body;
	ULONG bits = ((UBYTE *)xsp)[67];
	ULONG tsize = 1UL << bits;
	xsp->xsp_Sub[0] = 0;
	exec_FreeMem(p, 4 * tsize + 4);
    }
}

/* -------------------------------------------------------------- */
/* pack-side helpers						    */
/* -------------------------------------------------------------- */

/* nostdlib build -- local byte clear (orig uses clrl bursts) */
static void zclr(UBYTE *p, ULONG n)
{
    while (n--)
	*p++ = 0;
}

/* per-width rehash modulus: the original reads these words out of
 * code bytes at hunk+0xb2+2*(bits-12); only bits 12..14 reachable */
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

LONG XpksPackChunk(struct XpkSubParams *xsp REGPARM_A0)
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
    ULONG prevdelta;
    UBYTE *body;

    /* InLen < 128 (signed) -> -17 -- no output written	    */
    if ((LONG)xsp->xsp_InLen < 128)
	return -17;

    if (xsp->xsp_Sub[0] == 0) {
	BYTE mode;
	ULONG size;
	UBYTE *alloc;
	xsp->xsp_Sub[1] = 0;
	xsp->xsp_Sub[2] = 0;
	/* the clamp runs once on entry; alloc-fail retries at
	 * 0x554 bypass it and use the raw reloaded byte, so the
	 * first retry happens at the OLD mode before the
	 * downgraded byte is re-read on the next failure.	    */
	mode = (BYTE)xsp->xsp_Mode;	/* byte at xsp+31	    */
	if (mode < 1)
	    mode = 1;
	if (mode > 0x63)
	    mode = 0x63;
	for (;;) {
	    bits = (UWORD)((SHORT)(UWORD)(mode - 1) / 0x21) + 0x0c;
	    ((UBYTE *)xsp)[67] = (UBYTE)bits;
	    D3 = (1UL << bits) + 0x800;
	    size = 7 * D3 + 8;
	    alloc = exec_AllocMemAttr(size, 0x10001);
	    xsp->xsp_Sub[0] = (ULONG)alloc;
	    xsp->xsp_Sub[1] = (ULONG)(alloc + 4 + 2 * D3);
	    xsp->xsp_Sub[2] = (ULONG)(alloc + 8 + 6 * D3);
	    if (alloc != 0)
		break;
	    /* alloc-fail fallback: shrink the mode and retry	    */
	    mode = (BYTE)xsp->xsp_Mode;
	    if (mode >= 0x43) {
		((UBYTE *)xsp)[31] = 50;
	    } else if (mode >= 0x22) {
		((UBYTE *)xsp)[31] = 0;
	    } else {
		return -7;
	    }
	}
	{
	    ULONG hv = 0;
	    /* tst.l (a1) -- dereferences the password pointer    */
	    if (NRD32(xsp->xsp_Password) != 0)
		hv = pwhash(xsp->xsp_Password);
	    NWR32(alloc, hv);
	}
    }

    body = (UBYTE *)xsp->xsp_Sub[0];
    bits = ((UBYTE *)xsp)[67];
    D3 = (1UL << bits) + 0x800;
    bound = D3;
    hshift = bits - 8;
    modulus = zeno_modulus((UWORD)bits);
    mask = (UWORD)((1UL << bits) - 1);

    T_code = (UWORD *)(body + 4);
    T_pref = (UWORD *)xsp->xsp_Sub[1];
    T_char = (UBYTE *)xsp->xsp_Sub[2];

    /* clear T_pref only: D3/2 longs == 2*D3 bytes		    */
    zclr((UBYTE *)T_pref, 2 * D3);

    a2 = (UBYTE *)xsp->xsp_InBuf;		/* input cursor	    */
    a1 = a2 + xsp->xsp_InLen;			/* input end	    */
    a0 = (UBYTE *)xsp->xsp_OutBuf;		/* emit cursor	    */
    a4 = a0 + xsp->xsp_InLen;			/* output budget end   */

    /* header: hash long, bits byte, name-length pad byte;
     * namelen = 3-(ptr&3) aligns the code stream; the pad
     * bytes themselves are skipped, not written.	    */
    NWR32(a0, NRD32(body)); a0 += 4;
    *a0++ = (UBYTE)bits;
    {
	ULONG namelen = 3 - ((ULONG)a0 & 3);
	*a0++ = (UBYTE)namelen;
	a0 += namelen;
    }
    NWR32(a0, 0);				/* pre-clear emit long */
    xsp->xsp_OutLen = 0;

    checkpoint = a2 + 1024;
    lastemit = a0;
    prevdelta = 0x000fffff;

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
	    break;				/* done		    */
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
	/* miss: emit prevcode, insert at empty slot h	    */
	ZEMIT(prevcode1 - 1);
	if (nextcode < mask) {
	    T_char[h] = (UBYTE)d3;
	    NWR16((UBYTE *)T_pref + 2 * h, (UWORD)prevcode1);
	    NWR16((UBYTE *)T_code + 2 * h, (UWORD)nextcode);
	    ++nextcode;
	}
	prevcode1 = d3 + 1;
	if (a2 >= checkpoint) {
	    ULONG delta, thr;
	    checkpoint = a2 + 1024;
	    thr = prevdelta + 128;
	    delta = a0 - lastemit;
	    prevdelta = delta;
	    lastemit = a0;
	    if ((LONG)delta >= (LONG)thr) {
		/* adaptive dictionary reset: emit 0x101 at    */
		/* the old width, then restart		    */
		prevdelta = 0x000fffff;
		zclr((UBYTE *)T_pref, 2 * D3);
		nextcode = 0x104;
		ZEMIT(0x101);
		width = 9;
		maxcode = 0x1ff;
	    }
	}
	if (a0 >= a4)
	    return -17;
    }

    /* drain						    */
    ZEMIT(prevcode1 - 1);
    ZEMIT(0x100);				/* EOI		    */
    xsp->xsp_OutLen = (ULONG)(a0 + 8 - (UBYTE *)xsp->xsp_OutBuf);
    return 0;
#undef ZEMIT
}

/* -------------------------------------------------------------- */
/* -54 XpksUnpackChunk						    */
/* -------------------------------------------------------------- */

LONG XpksUnpackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
    UBYTE *a2 = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *a3 = (UBYTE *)xsp->xsp_OutBuf;
    UBYTE *outbase;
    UBYTE *stk;
    UBYTE *bound;
    UWORD *T_prev;
    UBYTE *T_char;
    ULONG bits, Tsize;
    ULONG width, mask, nextcode, threshold;
    BYTE  bitrem;			/* d6: signed bit counter  */
    ULONG prevcode;
    UBYTE firstchar;
    ULONG code, raw;
    LONG  depth;

    if (xsp->xsp_Sub[0] == 0) {
	ULONG size;
	UBYTE *alloc;
	LONG i;
	ULONG hv = 0;
	if (NRD32(a2) != 0) {
	    hv = pwhash(xsp->xsp_Password);
	    if (hv != NRD32(a2))
		return -32;
	}
	xsp->xsp_Sub[1] = hv;
	{
	    BYTE b = (BYTE)a2[4];
	    if (b < 12)
		b = 12;
	    if (b > 14)
		b = 14;
	    ((UBYTE *)xsp)[67] = (UBYTE)b;
	    bits = (UBYTE)b;
	}
	Tsize = 1UL << bits;
	xsp->xsp_Sub[2] = Tsize;
	size = 4 * Tsize + 8;
	alloc = exec_AllocMemAttr(size, 0x10001);
	xsp->xsp_Sub[0] = (ULONG)alloc;
	if (alloc == 0) {
	    /* the original calls XpksUnpackFree (Sub[0]==0, a
	     * no-op) and returns -7			    */
	    XpksUnpackFree(xsp);
	    return -7;
	}
	NWR32(alloc, xsp->xsp_Sub[1]);
	xsp->xsp_Sub[1] = 0;
	xsp->xsp_Sub[1] = (ULONG)(alloc + 4 + 2 * Tsize);
	/* identity table, filled top-down		    */
	for (i = 255; i >= 0; --i)
	    ((UBYTE *)xsp->xsp_Sub[1])[i] = (UBYTE)i;
    }

    bits = ((UBYTE *)xsp)[67];
    Tsize = xsp->xsp_Sub[2];
    T_prev = (UWORD *)(xsp->xsp_Sub[0] + 4);
    T_char = (UBYTE *)xsp->xsp_Sub[1];

    /* data start: in + 6 + namelen			    */
    {
	UBYTE *data = a2 + 6 + a2[5];
	ULONG off = (ULONG)data & 3;
	a2 = (UBYTE *)((ULONG)data & ~3UL);
	bitrem = (BYTE)(3 - (BYTE)off);
	if (bitrem != 0) {
	    bitrem = (BYTE)((bitrem << 3) - 1);
	    code = (NRD32(a2) >> (UBYTE)bitrem) & 0x1ff;
	    bitrem = (BYTE)(bitrem - 9);
	} else {
	    /* data & 3 == 3: first code loses its low bit --
	     * the next long's top bit is read but discarded  */
	    code = (NRD32(a2) << 1) & 0x1ff;
	    a2 += 4;
	    (void)(NRD32(a2) >> 31);
	    bitrem = 22;
	}
    }

    width = 9; mask = 0x1ff; nextcode = 0x103;
    threshold = 0x1fd;
    prevcode = code;
    firstchar = (UBYTE)code;
    outbase = a3;
    bound = a3 + xsp->xsp_OutLen;		/* xsp+16: emit bound    */
    stk = a3 + xsp->xsp_OutBufLen;	/* xsp+12: unwind top    */
    *a3++ = (UBYTE)code;			/* emit first byte   */

    for (;;) {
	/* grow when nextcode hits threshold (width<bits)	    */
	if (nextcode >= threshold && width < bits) {
	    mask = mask * 2 + 1;
	    threshold = mask - 2;
	    ++width;
	    --bitrem;
	}
	/* bit reader, MSB-first within u32 longs; bitrem is a
	 * signed byte counter (low-bit index of next code)    */
	if (bitrem > 0) {
	    code = (NRD32(a2) >> (UBYTE)bitrem) & mask;
	    bitrem = (BYTE)(bitrem - width);
	} else if (bitrem == 0) {
	    code = NRD32(a2) & mask;
	    a2 += 4;
	    bitrem = (BYTE)(32 - width);
	} else {
	    code = (NRD32(a2) << (-(BYTE)bitrem)) & mask;
	    a2 += 4;
	    bitrem = (BYTE)(bitrem + 32);
	    code += (NRD32(a2) >> (UBYTE)bitrem) & mask;
	    bitrem = (BYTE)(bitrem - width);
	}
	if (code > 0x101)
	    goto decode;
	if (a3 >= bound)
	    goto done;
	if (code == 0x100)
	    goto done;
	if (code != 0x101)
	    goto decode;
	/* reset: nextcode 0x102 (one dead slot), width 9	    */
	nextcode = 0x102;
	bitrem = (BYTE)(bitrem + width - 9);
	if (bitrem >= 32)
	    bitrem = (BYTE)(bitrem - 32);
	width = 9;
	threshold = 0x1fd;
	mask = 0x1ff;
	continue;

    decode:
	raw = code;
	depth = 0;
	if (code == nextcode) {			/* KwKwK	    */
	    *--stk = firstchar;
	    code = prevcode;
	    depth = 1;
	}
	if (code > 0x100) {
	    /* unwind through T_char/T_prev; loop while >0x100   */
	    do {
		*--stk = T_char[code];
		++depth;
		code = NRD16((UBYTE *)T_prev + 2 * code);
	    } while (code > 0x100);
	    firstchar = T_char[code];
	    *--stk = firstchar;
	    {
		LONG n = depth;
		do {
		    *a3++ = *stk++;
		} while (n-- > 0);
	    }
	} else {
	    firstchar = T_char[code];
	    *a3++ = firstchar;
	    if (depth)
		*a3++ = *stk++;
	}
	/* dict insert while nextcode < Tsize-2		    */
	if (nextcode < Tsize - 2) {
	    NWR16((UBYTE *)T_prev + 2 * nextcode, (UWORD)prevcode);
	    T_char[nextcode] = firstchar;
	    ++nextcode;
	}
	prevcode = raw;
    }

done:
    /* valid iff produced - 12 <= xsp_OutLen		    */
    if ((LONG)(a3 - outbase - 12) <= (LONG)xsp->xsp_OutLen)
	return 0;
    return -14;
}
