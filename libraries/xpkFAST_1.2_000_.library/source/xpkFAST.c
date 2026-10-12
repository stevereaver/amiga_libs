/*
**	xpkFAST.c -- C reconstruction of xpkFAST.library V1.2
**	"FAST V1.2 alias WOOP or LZRW++" (Christian von Roques, 1 Oct 2013).
**
**	XPK sublibrary: LZ77 over a 4096-byte window with two packers,
**	selected by xsp_Mode (< 79 = "speedy", >= 79 = "crawling").
**	Vector map (AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 _start (ret 0)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 XpksPackReset (clears tables)
**	                      -54 XpksUnpackChunk
**	                      -60 _start (XpksUnpackFree no-op)
**
**	Stream layout (LZRW-style, "2 streams"):
**	  literal bytes grow forward from the output buffer start,
**	  control words + match words grow BACKWARD from
**	  outbuf + (InLen & ~3); on finish the control tail is
**	  compacted down behind the data.
**	  ctrl word = 16 items, MSB first; bit 0 = literal,
**	  bit 1 = match; a match pulls the NEXT backward word
**	  w = (offset<<4) | (18-len), len 3..18, off 1..4095.
**
**	Pack workmem (AllocMem(0x10004 speedy / 0x44004 crawling)):
**	  alloc+0        u32 size prefix (for PackFree)
**	  alloc+4        hash table, u32[] --
**	    speedy   : 16384 entries, h = ((b0*8+b1)*8+b2) with the
**	               byte adds wrapping mod 256 (fits exactly)
**	    crawling : 65536 entries indexed by a negative-biased
**	               index (a5 = mem+0x40004, idx = 4*(h-0x10000)),
**	               h = (b0<<8) | ((b1+b2)&0xff)
**	  alloc+0x40004  chain table u32[4096] (crawling only)
**
**	Shipped quirks reproduced verbatim:
**	  - PackReset clears only the hash table(s); the crawling
**	    chain table at +0x40000 keeps stale links between resets.
**	  - crawling match eval trusts byte0 (guaranteed by the hash)
**	    and compares bytes 1..17 only.
**	  - the tail copier drops an odd trailing ctrl byte
**	    (copied = size & ~1; sizes are always even anyway).
**	  - gap==0 at finish (data ends exactly at ctrl bottom)
**	    truncates outlen to the data part only.
**	  - the pad writes (gap & 3) + 1 zero bytes before the tail
**	    copy -- always at least one byte of padding.
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

struct FastBase {
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
struct Library *LibOpen(struct FastBase *b __asm("a6"))
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

/* expunge body: removes + frees the library; returns the seglist */
static BPTR expunge_body(struct FastBase *b)
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
LONG LibClose(struct FastBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt == 0 &&
	(b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge: OpenCnt>0 -> set DELEXP, return 0; else expunge now */
LONG LibExpunge(struct FastBase *b __asm("a6"))
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
		  struct FastBase *b __asm("a6"))
{
    ULONG mem = xsp->xsp_Sub[0];

    if (mem) {
	ULONG *m = (ULONG *)mem;
	exec_FreeMem(m - 1, m[-1]);
    }
}

/*
**	PackReset -- -48: clear the hash tables.  Clears
**	(Sub[1]+1) * 0x10000 bytes below Sub[0] + 0x10000*(1+Sub[1]>>1...):
**	original computes a6 = Sub[0] + (Sub[1] ? 0x30000 : 0) + 0x10000
**	then zero-fills (Sub[1]+1) 64KB blocks downward.
**	Equivalently: big clears [Sub[0], Sub[0]+0x40000), small clears
**	[Sub[0], Sub[0]+0x10000).  The chain table is never cleared.
*/
static void pk_reset(ULONG sub0, ULONG sub1)
{
    ULONG *p = (ULONG *)sub0;
    ULONG n = (sub1 + 1) * 0x4000;	/* longs: 0x4000 or 0x10000 */

    while (n--)
	*p++ = 0;
}

void XpksPackReset(struct XpkSubParams *xsp __asm("a0"),
		   struct FastBase *b __asm("a6"))
{
    if (xsp->xsp_Sub[0])
	pk_reset(xsp->xsp_Sub[0], xsp->xsp_Sub[1]);
}

/*
**	3-byte hashes.  Both reproduce the original's mixed-width
**	arithmetic: .b adds wrap the low byte only.
*/
static ULONG hspeedy(const UBYTE *p)	/* 0..16383 */
{
    ULONG h = p[0];
    h = (h << 3) & 0xffff;
    h = (h & 0xff00) | ((h + p[1]) & 0xff);
    h = (h << 3) & 0xffff;
    h = (h & 0xff00) | ((h + p[2]) & 0xff);
    return h;
}

static ULONG hcrawl(const UBYTE *p)	/* 0..65535 */
{
    ULONG h = p[0];
    h = (h << 8) & 0xffff;
    h = (h & 0xff00) | ((h + p[1]) & 0xff);	/* move.b = replace */
    h = (h & 0xff00) | ((h + p[2]) & 0xff);	/* add.b wraps */
    return h;
}

/*
**	pk_tail -- the finish code shared by both packers.
**	bits  = pending control accumulator (with sentinel)
**	slot  = current control slot (already stored words sit above it)
**	cw    = control/match word cursor
**	o     = data cursor
**	ctop  = control region top = out + (InLen & ~3)
**	Returns -17 on overrun, else stores outlen and returns 0.
*/
static LONG pk_tail(struct XpkSubParams *xsp, UBYTE *o, UWORD *cw,
		    UWORD *slot, ULONG bits, UBYTE *ctop)
{
    LONG gap;
    ULONG size, n;
    UBYTE *s;

    /* finish the pending ctrl word: shift until the sentinel
       carries out, then store at the current slot */
    while (!((bits <<= 1) & 0x10000))
	;
    *slot = (UWORD)bits;

    gap = (UBYTE *)cw - o;
    if (gap < 0)
	return -17;
    if (gap) {
	/* pad: (gap & 3) + 1 zero bytes */
	n = (gap & 3) + 1;
	while (n--)
	    *o++ = 0;

	/* compact the backward-written control tail behind the
	   data.  Faithful to the original bit-cascade copier:
	   bit1->word, bit2->long, bit3->2 longs, bit4->4 longs,
	   then 8-long pairs per (size>>5) -- i.e. size & ~1:
	   an odd trailing byte is dropped. */
	size = (UBYTE *)ctop - (UBYTE *)cw;
	s = (UBYTE *)cw;
	n = size & ~1UL;
	while (n--)
	    *o++ = *s++;
    }
    xsp->xsp_OutLen = (ULONG)o - (ULONG)xsp->xsp_OutBuf;
    return 0;
}

/*
**	Speedy packer (xsp_Mode < 79): single 16384-long 3-byte hash
**	table, greedy single-candidate match, window 4095, len 3..18.
*/
static LONG pk_speedy(struct XpkSubParams *xsp, ULONG *tab)
{
    UBYTE *src = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *o = (UBYTE *)xsp->xsp_OutBuf;
    LONG left = (LONG)xsp->xsp_InLen;
    UBYTE *ctop = o + (left & ~3);
    UWORD *cw = (UWORD *)ctop - 1;
    UWORD *slot = cw;
    ULONG bits = 1;
    LONG pend = 1;
    UBYTE *cand;

    src--;				/* pre-decrement like A2 */
    for (;;) {
	ULONG off;
	LONG len;

	/* hash `pend` positions forward; last evicted entry is the
	   match candidate */
	pend--;
	do {
	    ULONG h;

	    src++;
	    h = hspeedy(src);
	    cand = (UBYTE *)tab[h];
	    tab[h] = (ULONG)src;
	} while (--pend >= 0);

	off = (ULONG)src - (ULONG)cand;
	len = 0;
	if ((LONG)off <= 0xfff) {
	    /* up to 18-byte compare */
	    const UBYTE *a = cand, *b = src;
	    do {
		if (*a++ != *b++)
		    break;
		len++;
	    } while (len < 18);
	}
	if (len < 3) {
	    /* literal */
	    *o++ = *src;
	    pend = 1;
	    bits <<= 1;
	    if (bits & 0x10000) {
		*slot = (UWORD)bits;
		slot = --cw;
		bits = 1;
	    }
	    left -= 1;
	} else {
	    /* match: word = (off<<4) | (18-len) */
	    *--cw = (UWORD)((off << 4) | (18 - len));
	    pend = len;
	    bits = (bits << 1) | 1;
	    if (bits & 0x10000) {
		*slot = (UWORD)bits;
		slot = --cw;
		bits = 1;
	    }
	    left -= len;
	}
	if (left <= 0)
	    break;
    }
    return pk_tail(xsp, o, cw, slot, bits, ctop);
}

/*
**	Crawling packer (xsp_Mode >= 79): 65536-long hash table at
**	mem+4 plus a 4096-long chain table at mem+0x40004; follows
**	eviction links for the best match (len cap 18).
*/
static LONG pk_crawl(struct XpkSubParams *xsp, ULONG *htab)
{
    ULONG *chain = (ULONG *)((UBYTE *)htab + 0x40000);
    UBYTE *src = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *o = (UBYTE *)xsp->xsp_OutBuf;
    LONG left = (LONG)xsp->xsp_InLen;
    UBYTE *ctop = o + (left & ~3);
    UWORD *cw = (UWORD *)ctop - 1;
    UWORD *slot = cw;
    ULONG bits = 1;
    LONG pend = 1;
    ULONG cand;

    src--;
    for (;;) {
	ULONG bestoff;
	LONG best;

	/* insert `pend` positions into hash + chain */
	pend--;
	do {
	    ULONG h;

	    src++;
	    h = hcrawl(src);
	    cand = htab[h];
	    htab[h] = (ULONG)src;
	    chain[(ULONG)src & 0xfff] = cand;
	} while (--pend >= 0);

	/* chase the chain for the best match */
	best = 2;
	bestoff = 0;
	for (;;) {
	    ULONG d;
	    LONG len;

	    d = (ULONG)src - cand;
	    if ((LONG)d > 0xfff)
		break;
	    /* quick reject on the byte at +best, then a full
	       compare from byte 1 (byte0 is implied by the equal
	       hash).  The original's 17-step chain yields
	       len = compares-executed, so a full run undercounts
	       an 18-byte match as 17 -- cap is 17, and the
	       best>=18 early-out is dead code in the original. */
	    if (src[best] == ((UBYTE *)cand)[best]) {
		const UBYTE *a = (UBYTE *)cand + 1, *b = src + 1;

		len = 1;
		while (len < 17 && *a++ == *b++)
		    len++;
		if (len > left)
		    len = left;
		if (len > best) {
		    best = len;
		    bestoff = d;
		    if (best >= 18)
			break;
		}
	    }
	    cand = chain[cand & 0xfff];
	}
	if (best < 3) {
	    *o++ = *src;
	    pend = 1;
	    bits <<= 1;
	    if (bits & 0x10000) {
		*slot = (UWORD)bits;
		slot = --cw;
		bits = 1;
	    }
	    left -= 1;
	} else {
	    *--cw = (UWORD)((bestoff << 4) | (18 - best));
	    pend = best;
	    bits = (bits << 1) | 1;
	    if (bits & 0x10000) {
		*slot = (UWORD)bits;
		slot = --cw;
		bits = 1;
	    }
	    left -= best;
	}
	if (left <= 0)
	    break;
    }
    return pk_tail(xsp, o, cw, slot, bits, ctop);
}

/*
**	PackChunk -- -36.  Allocates workmem on first use
**	(0x10004 speedy / 0x44004 crawling), clears tables, packs.
*/
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   struct FastBase *b __asm("a6"))
{
    ULONG size, flag;

    if (xsp->xsp_Mode < 79) {
	flag = 0;
	size = 0x10004;
    } else {
	flag = 3;
	size = 0x44004;
    }
    if (xsp->xsp_Sub[0] == 0) {
	ULONG *m;

	m = (ULONG *)exec_AllocMem(size);
	if (!m)
	    return -7;
	*m++ = size;
	xsp->xsp_Sub[0] = (ULONG)m;
	xsp->xsp_Sub[1] = flag;
    }
    pk_reset(xsp->xsp_Sub[0], xsp->xsp_Sub[1]);
    if (xsp->xsp_Sub[1])
	return pk_crawl(xsp, (ULONG *)xsp->xsp_Sub[0]);
    return pk_speedy(xsp, (ULONG *)xsp->xsp_Sub[0]);
}

/*
**	UnpackChunk -- -54.  Data bytes forward, ctrl/match words
**	backward; done when the two cursors meet.
*/
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     struct FastBase *b __asm("a6"))
{
    UBYTE *s = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *d = (UBYTE *)xsp->xsp_OutBuf;
    UWORD *bp = (UWORD *)(s + xsp->xsp_InLen);
    UWORD bits = 0;

    for (;;) {
	ULONG off;
	LONG len;
	UBYTE *m;
	ULONG bit;

	if (!bits) {
	    /* reload: consume bit15, sentinel enters via X at bit0 */
	    UWORD w;

	    if (s >= (UBYTE *)bp)
		break;
	    w = *--bp;
	    bit = w >> 15;
	    bits = (UWORD)((w << 1) | 1);
	} else {
	    bit = bits >> 15;
	    bits <<= 1;
	    if (!bits)
		continue;	/* popped bit was the sentinel, reload */
	}
	if (!bit) {
	    *d++ = *s++;
	    continue;
	}
	{
	    UWORD w = *--bp;

	    off = w >> 4;
	    len = 18 - (w & 15);
	}
	m = d - off;
	while (len--)
	    *d++ = *m++;
    }
    return 0;
}
