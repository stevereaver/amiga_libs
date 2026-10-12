/*
**	xpkRDCN.c -- C reconstruction of xpkRDCN.library V2.4
**	"Ross Data Compression V2.4" (Niklas Sjoeberg, 1 Oct 2013).
**
**	XPK sublibrary: LZ77 + RLE hybrid with two packers, selected by
**	xsp_Mode (unsigned <= 79 = "speedy", >= 80 = "crawling").
**	Vector map (AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 _start (ret 0)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 XpksPackReset (clears hash tables)
**	                      -54 XpksUnpackChunk
**	                      -60 _start (XpksUnpackFree no-op)
**
**	Stream layout: [ctrl word BE][16 tokens][ctrl][16 tokens]...
**	ctrl bits are consumed MSB first; bit set = compressed token,
**	bit clear = literal byte.  Token classes (first byte b, hi=b>>4):
**	  hi >= 3  MATCH2B  2B: [len<<4|dlo][dhi]   len 3..15, dist+3 12-bit
**	  hi == 2  MATCH3B  3B: [0x20|dlo][dhi][len-16]   len 16..271
**	  hi == 0  RLE2B    2B: [len-3][byte]            len 3..18
**	  hi == 1  RLE3B    3B: [0x10|llo][lhi][byte]    len 19..4114
**
**	Pack workmem (AllocMem with size prefix for PackFree):
**	  speedy   alloc 0x4004 : hash table, u32[4096]
**	                   h = ((b0&0xf)<<8|b1) ^ (((BYTE)b0>>4)|(b2<<4))
**	                   (the arithmetic .b shift sign-fills the nibble
**	                   for b0>=0x80 -- faithful quirk)
**	  crawling alloc 0x48004: hash table u32[65536]
**	                   h = (b0<<8) | ((b1+b2)&0xff)
**	                 + chain table u32[8192] at +0x40000 indexed by
**	                   (pointer & 0x1fff) -- ADDRESS aliasing, not
**	                   position; same quirk as the original.
**
**	Shipped quirks reproduced verbatim:
**	  - PackReset clears only the hash table(s); the crawling
**	    chain table at +0x40000 keeps stale links between resets.
**	  - speedy reads one byte past the input end while measuring
**	    a run/match that reaches the end of the buffer.
**	  - speedy refuses inputs <= 18 bytes (-17); crawling has no
**	    minimum.
**	  - speedy overflow limit = outbuf + outbuflen - 48 checked
**	    once per 16-token group; crawling limit = outbuf + inlen
**	    checked once per token.
**	  - crawling dist 1..2 never emitted (chain skips them);
**	    speedy CAN emit dist 1..2 (encoded as dist-3 underflow
**	    into the 12-bit field -- reproduced).
**	  - RLE wins ties against equal-length LZ matches.
*/

#define SYSBASE (*(APTR *)4)

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t        UBYTE;
typedef uint16_t       UWORD;
typedef uint32_t       ULONG;
typedef int32_t        LONG;
typedef void          *APTR;
typedef char          *STRPTR;
typedef ULONG          BPTR;
#define LIBF_DELEXP 0x08
struct Node { struct Node *ln_Succ,*ln_Pred; UBYTE ln_Type; char ln_Pri; };
struct Library {
    struct Node lib_Node;
    UBYTE  lib_Flags, lib_pad;
    UWORD  lib_NegSize, lib_PosSize, lib_Version, lib_Revision;
    APTR   lib_IdString;
    ULONG  lib_Sum;
    UWORD  lib_OpenCnt;
};
#else
#include <exec/types.h>
#include <exec/libraries.h>
#endif

#ifdef HOST_TEST
#define PTRV(p) ((ULONG)(uintptr_t)(p))
#else
#define PTRV(p) ((ULONG)(p))
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

struct RdcnBase {
    struct Library lib;
    ULONG   b_SegList;		/* 0x22 */
};

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
struct Library *LibOpen(struct RdcnBase *b __asm("a6"))
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

/* expunge body: removes + frees the library; returns the seglist */
static ULONG expunge_body(struct RdcnBase *b)
{
    ULONG seg = b->b_SegList;
    ULONG  sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
    exec_Remove(b);
    exec_FreeMem(p, sz);
    return seg;
}

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge;
 * otherwise returns 0 via the hunk+0 entry stub.		    */
LONG LibClose(struct RdcnBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt == 0 &&
	(b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge: OpenCnt>0 -> set DELEXP, return 0; else expunge now */
LONG LibExpunge(struct RdcnBase *b __asm("a6"))
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return (LONG)expunge_body(b);
}

/* -------------------------------------------------------------- */
/* -30 XpksPackerInfo: return the XpkInfo descriptor		    */
/* -------------------------------------------------------------- */

extern UBYTE xpkinfo[];

APTR XpksPackerInfo(void)
{
    return xpkinfo;
}

/*
**	PackFree -- -42: free Sub[0] (size stored at mem-4).
*/
void XpksPackFree(struct XpkSubParams *xsp __asm("a0"),
		  struct RdcnBase *b __asm("a6"))
{
    ULONG mem = xsp->xsp_Sub[0];

    if (mem) {
	ULONG *m = (ULONG *)mem;
	exec_FreeMem(m - 1, m[-1]);
    }
}

/*
**	PackReset -- -48: clear the hash table(s).
**	Clears 0x40000 bytes (crawling, flag != 0) or 0x4000 bytes
**	(speedy, flag == 0) starting at Sub[0].  The original walks
**	downward from Sub[0]+size with movem pre-decrement stores;
**	the crawling chain table above +0x40000 is never cleared.
*/
void XpksPackReset(struct XpkSubParams *xsp __asm("a0"),
		   struct RdcnBase *b __asm("a6"))
{
    if (xsp->xsp_Sub[0]) {
	ULONG *p = (ULONG *)xsp->xsp_Sub[0];
	ULONG  n = xsp->xsp_Sub[1] ? 0x10000 : 0x1000;	/* longs */
	while (n--)
	    *p++ = 0;
    }
}

/* -------------------------------------------------------------- */
/* shared token emitters					    */
/* -------------------------------------------------------------- */

/* ctrl helpers: flush writes the BE ctrl word into its slot */
#define CTRL_FLUSH() do { \
	slot[1] = (UBYTE)(bits & 0xff); \
	slot[0] = (UBYTE)(bits >> 8);   \
    } while (0)

static void emit_rle(UBYTE **d, ULONG len, UBYTE v)
{
    if (len <= 0x12) {
	*(*d)++ = (UBYTE)(len - 3);
	*(*d)++ = v;
    } else {
	ULONG f = len - 0x13;
	*(*d)++ = (UBYTE)(0x10 | (f & 0xf));
	*(*d)++ = (UBYTE)(f >> 4);
	*(*d)++ = v;
    }
}

static void emit_match(UBYTE **d, ULONG len, ULONG enc /* dist-3 */)
{
    if (len <= 0xf) {
	*(*d)++ = (UBYTE)((len << 4) | (enc & 0xf));
	*(*d)++ = (UBYTE)(enc >> 4);
    } else {
	*(*d)++ = (UBYTE)(0x20 | (enc & 0xf));
	*(*d)++ = (UBYTE)(enc >> 4);
	*(*d)++ = (UBYTE)(len - 0x10);
    }
}

/* -------------------------------------------------------------- */
/* -36 XpksPackChunk -- speedy packer (xsp_Mode <= 79)		    */
/* single 4096-long 3-byte hash, window 0x1002, greedy.		    */
/* -------------------------------------------------------------- */

static ULONG hsmall(const UBYTE *p)
{
    ULONG b0 = p[0];
    ULONG h = ((b0 & 0xf) << 8) | p[1];
    ULONG x = (UBYTE)((BYTE)b0 >> 4);	/* asr.b: sign-fills nibble */
    x |= p[2] << 4;
    return (h ^ x) & 0xfff;
}

static LONG pk_speedy(struct XpkSubParams *xsp)
{
    UBYTE *a1 = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *a0 = (UBYTE *)xsp->xsp_OutBuf;	/* ctrl slot */
    UBYTE *a2 = a0 + 2;			/* data cursor */
    UBYTE *lim = a0 - 48 + xsp->xsp_OutBufLen;
    UBYTE *a3e = a1 + xsp->xsp_InLen;
    ULONG *htab = (ULONG *)xsp->xsp_Sub[0];
    LONG  cnt = 16;
    UWORD bits = 0;
    UBYTE *slot;

    if (xsp->xsp_InLen <= 0x12)
	return -17;

    while (a1 < a3e) {
	UBYTE *a4;
	UBYTE  b0;
	ULONG  d5;
	ULONG *hp;
	UBYTE *cand;
	LONG   d4, len, d7;

	if (--cnt < 0) {
	    slot = a0;
	    CTRL_FLUSH();
	    bits = 0;
	    cnt = 15;
	    a0 = a2;
	    a2 += 2;
	    if (a2 > lim)
		return -17;
	}

	a4 = a1;
	b0 = *a1++;
	if (*a1++ == b0 && *a1++ == b0) {
	    /* ---- RLE run (>= 3 equal bytes) ---- */
	    if (a1 > a3e)
		goto literal;
	    len = 0x100f;
	    for (d7 = 0x100f;;) {
		if (*a1++ != b0)
		    break;
		if (a1 > a3e)
		    break;
		if (--d7 < 0) {
		    d7 = 0;
		    break;
		}
	    }
	    a1--;			/* subq #1,a1: unconditional */
	    len -= d7;			/* extra equals beyond first 3 */
	    emit_rle(&a2, len + 3, b0);
	    goto compressed;
	}
	/* ---- LZ try: need 3 bytes for the hash ---- */
	if ((LONG)((UWORD)(ULONG)a3e - (UWORD)(ULONG)a4) - 2 <= 0) {
literal:
	    *a2++ = b0;
	    a1 = a4 + 1;
	    continue;
	}
	d5 = hsmall(a4);
	hp = &htab[d5];
	cand = (UBYTE *)*hp;
	*hp = (ULONG)a4;
	a1 = a4;
	d4 = (LONG)((ULONG)a1 - (ULONG)cand);
	if (d4 > 0x1002)
	    goto literal;
	len = 0x10f;
	for (d7 = 0x10f;;) {
	    if (*cand++ != *a1++)
		break;
	    if (a4 < cand)	/* overlap stop (cmpa a5,a4; bcs) */
		break;
	    if (a1 > a3e)
		break;
	    if (--d7 < 0) {
		d7 = 0;
		break;
	    }
	}
	a1--;				/* subq #1,a1: unconditional */
	len -= d7;			/* match length */
	if (len <= 2)
	    goto literal;
	emit_match(&a2, len, (ULONG)(d4 - 3));
compressed:
	bits |= 1 << cnt;
    }
    slot = a0;
    CTRL_FLUSH();
    xsp->xsp_OutLen = (ULONG)a2 - (ULONG)xsp->xsp_OutBuf;
    return 0;
}

/* -------------------------------------------------------------- */
/* crawling packer (xsp_Mode >= 80): 65536-long hash + 8192-slot    */
/* chain (indexed by ADDRESS & 0x1fff), window 0x1002.		    */
/* -------------------------------------------------------------- */

static LONG pk_crawl(struct XpkSubParams *xsp)
{
    UBYTE *a6 = (UBYTE *)xsp->xsp_OutBuf;	/* data cursor */
    UBYTE *a2 = (UBYTE *)xsp->xsp_InBuf;
    LONG   d7 = (LONG)xsp->xsp_InLen;	/* remaining */
    ULONG *htab = (ULONG *)xsp->xsp_Sub[0];
    ULONG *chain = (ULONG *)((UBYTE *)htab + 0x40000);
    UBYTE *lim = a6 + xsp->xsp_InLen;	/* limit = out + inlen */
    UBYTE *a3 = a6;			/* ctrl slot */
    LONG   bit = 15;
    UWORD  bits = 0;
    LONG   d5 = 1;			/* previous item length */

    a6 += 2;
    a2--;

    for (;;) {
	LONG   i;
	ULONG  d0, d1;
	ULONG  best, bdist = 0, maxlen, rle, enc;
	UBYTE  rb;

	if (d7 < 3) {
	    a2 += d5;
	    goto literal;
	}
	/* insert the positions skipped by the previous token */
	for (i = d5; i-- > 0;) {
	    a2++;
	    d1 = ((a2[0] << 8) | a2[1]);
	    d1 = (d1 & 0xff00) | ((d1 + a2[2]) & 0xff);	/* add.b wraps */
	    d0 = htab[d1];
	    htab[d1] = PTRV(a2);
	    chain[PTRV(a2) & 0x1fff] = d0;
	}
	best = 2;
	maxlen = d7 < 0x10f ? d7 : 0x10f;
	/* hash-chain walk: d0 = predecessor of current pos */
	for (;;) {
	    UBYTE *a0p;
	    ULONG  dist, m, k;
	    dist = PTRV(a2) - d0;
	    if ((LONG)dist >= 0x1003)
		break;
	    if ((LONG)dist >= 3) {
		a0p = (UBYTE *)d0;
		/* skip unless candidate extends past best len */
		if (a2[best] == a0p[best]) {
		    for (k = 0; k < best && a0p[k] == a2[k]; k++)
			;
		    if (k == best) {
			m = best;
			while (m < maxlen && a0p[m] == a2[m])
			    m++;
			if (m > best) {
			    best = m;
			    bdist = dist;
			    if (m >= maxlen)
				break;
			}
		    }
		}
	    }
	    d0 = chain[d0 & 0x1fff];
	}
	/* RLE run check: wins ties against LZ.  len = min(run, cap),
	   cap = min(0x1012, remaining); original reads one byte past
	   cap on a maxed run (decision-equivalent here). */
	{
	    ULONG cap = d7 < 0x1012 ? (ULONG)d7 : 0x1012;
	    rb = a2[0];
	    rle = 0;
	    if (a2[1] == rb && a2[2] == rb) {
		rle = 3;
		while (rle < cap && a2[rle] == rb)
		    rle++;
	    }
	}
	if (rle >= 3 && (LONG)rle >= (LONG)best) {
	    d5 = rle;
	    emit_rle(&a6, rle, rb);
	    goto compressed;
	}
	if (best < 3) {
literal:
	    d5 = 1;
	    *a6++ = *a2;
	    goto nextitem;
	}
	d5 = best;
	enc = bdist - 3;
	emit_match(&a6, best, enc);
compressed:
	bits |= 1 << bit;
nextitem:
	if (--bit < 0) {
	    UBYTE *slot = a3;
	    CTRL_FLUSH();
	    a3 = a6;
	    a6 += 2;
	    bit = 15;
	    bits = 0;
	}
	if (a6 >= lim)
	    return -17;
	d7 -= d5;
	if (d7 <= 0) {
	    if (bit != 15) {
		UBYTE *slot = a3;
		CTRL_FLUSH();
	    } else {
		a6 -= 2;
	    }
	    break;
	}
    }
    xsp->xsp_OutLen = (ULONG)a6 - (ULONG)xsp->xsp_OutBuf;
    return 0;
}

/*
**	PackChunk -- -36: mode dispatch, workmem alloc, reset, pack.
*/
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   struct RdcnBase *b __asm("a6"))
{
    if (xsp->xsp_Mode <= 79) {
	if (xsp->xsp_Sub[0] == 0) {
	    ULONG *m = exec_AllocMem(0x4004);
	    if (m == 0)
		return -7;
	    *m++ = 0x4004;
	    xsp->xsp_Sub[0] = (ULONG)m;
	    xsp->xsp_Sub[1] = 0;
	}
	XpksPackReset(xsp, b);
	return pk_speedy(xsp);
    }
    if (xsp->xsp_Sub[0] == 0) {
	ULONG *m = exec_AllocMem(0x48004);
	if (m == 0)
	    return -7;
	*m++ = 0x48004;
	xsp->xsp_Sub[0] = (ULONG)m;
	xsp->xsp_Sub[1] = 15;
    }
    XpksPackReset(xsp, b);
    return pk_crawl(xsp);
}

/* -------------------------------------------------------------- */
/* -54 XpksUnpackChunk -- token decoder				    */
/* -------------------------------------------------------------- */

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     struct RdcnBase *b __asm("a6"))
{
    UBYTE *a1 = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *a3e = a1 + xsp->xsp_InLen;
    UBYTE *a2 = (UBYTE *)xsp->xsp_OutBuf;

    for (;;) {
	UWORD  ctrl;
	LONG   bit;

	ctrl = (UWORD)((a1[0] << 8) | a1[1]);
	a1 += 2;
	bit = 15;
	if ((LONG)(a1 - a3e) >= 0)
	    return 0;
	for (;;) {
	    if (ctrl & (1 << bit)) {
		UBYTE  b = *a1++;
		UBYTE  hi = b >> 4;
		ULONG  lo = b & 0xf;
		if (hi >= 3) {
		    /* MATCH2B: dist = (lo|next<<4)+3, len = hi */
		    UBYTE *s = a2 - 3 - lo - ((ULONG)*a1++ << 4);
		    LONG   n = hi - 2;
		    *a2++ = *s++;
		    do {
			*a2++ = *s++;
		    } while (n-- > 0);
		} else if (hi == 0) {
		    /* RLE2B: len = lo+3 */
		    UBYTE v = *a1++;
		    LONG  n = (LONG)lo;
		    *a2++ = v;
		    *a2++ = v;
		    do {
			*a2++ = v;
		    } while (n-- > 0);
		} else if (hi == 1) {
		    /* RLE3B: len = (lo|next<<4)+19 */
		    ULONG L = lo + ((ULONG)*a1++ << 4);
		    UBYTE v = *a1++;
		    ULONG n = L + 19;
		    do {
			*a2++ = v;
		    } while (--n);
		} else {
		    /* MATCH3B: dist = (lo|next<<4)+3, len = next2+16 */
		    UBYTE *s = a2 - (lo + 3 + ((ULONG)*a1++ << 4));
		    ULONG  n = *a1++ + 16;
		    do {
			*a2++ = *s++;
		    } while (--n);
		}
	    } else {
		*a2++ = *a1++;
	    }
	    if (--bit < 0)
		break;
	}
    }
}
