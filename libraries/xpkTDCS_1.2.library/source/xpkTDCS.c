/*
 * xpkTDCS.library 1.2 -- "The Doom that Came over Sarnath"
 * XPK sublibrary by Niels Froehling, 20.01.2012.
 * Reconstructed in C from the shipped binary.
 *
 * Earlier generation of the tiered-token LZ family than the 1.5
 * sibling: same 2-bit flag stream (00 literal / 01 [tok>>2:u14]
 * [len-3:u2] / 10 [tok>>4:u12][len-3:u4] / 11 [tok:u16][len-3:u8]),
 * but the matcher keeps per-bucket growable position arrays in an
 * exec memory POOL (CreatePool/AllocPooled/FreePooled/DeletePool)
 * instead of a flat head/chain workspace.  A single published mode
 * ("direct match", upto 49, packmem 0x800a0).
 *
 * Hash: key = ((b0<<8)|b1) ^ b2 into tab[65536] entries of
 * {cap, blk}; blk = long array {used, pos[0..used-1]} grown by
 * doubling while cap<=63 then +64 steps, shrunk by -64 when
 * cap>64 && cap/2>=used && used>1.  Stale positions
 * (dist>65535) are dropped from the front of the array on find.
 *
 * Shipped quirks reproduced verbatim:
 *  - lazy matching: find(cur+1) runs each iteration; the chain
 *    ADOPTS the lookahead item whenever lenL - 1 > pending len,
 *    emitting cur's literal (+ inserting its position) and sliding
 *    forward; the pending item may be adopted repeatedly.  (The
 *    gate slots sp@(74/78/82) are word-written via their low-word
 *    aliases sp@(76/80/84) -- easy to misread as always-zero.)
 *  - candidate walk starts at blk[used-1] (newest) to blk[0];
 *    pre-checks compare words {best-1,best} and {1,2}; the long
 *    compare starts at +3 counting len from 6, and cmpml a0@+/a2@+
 *    post-increments BOTH pointers even on mismatch, so the
 *    word/byte tail refinement backs up to the failing long.
 *  - the insert-time 259-entry trim fires when
 *    cur - blk[used-259] == 259 (dense inserts), then shifts the
 *    whole block down one long via a 516-long copy that overruns
 *    the block and clobbers blk[0] (used) with a position pointer.
 *  - the realloc copy loop moves 2*used longs (two movels per
 *    4-byte decrement of used*4) -- overruns both blocks; the
 *    shrink case can scribble up to ~used longs past the new
 *    (cap-64)+2-long block into the next pooled allocation.
 *  - emit clamps len at sp@(150) == LOW WORD of the remaining
 *    counter (sp@(148)), i.e. `if (len >= (SHORT)remaining)`.
 *  - tier bounds are 2x too wide: tier1 checks dist >= -16385 but
 *    the signed (tok<<2)|l3 field only holds [-8192,8191]; tier2
 *    checks -4097 but holds [-2048,2047]; tier3's word field is
 *    signed16 while the find window reaches -65535.  Out-of-range
 *    distances wrap to positive tokens -> forward decode -> corrupt
 *    output (the decoder itself is fine: moveq #-1 then movew
 *    sign-extends d1, and asrl gives the negative dist).
 *  - OutLen IS written back on success (0x10), errors return
 *    -7 (alloc) / -17 (output overrun, out >= outend) and skip
 *    the writeback.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c					   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18					   */
    ULONG xsp_Mode;		/* 0x1c					   */
    APTR  xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Tags[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34					   */
};

struct XpkSubBase
{
    struct Library	xsb_Lib;
    ULONG		xsb_Unk;	/* +0x22: unused		   */
    BPTR		xsb_SegList;	/* +0x26: seglist, NOT +0x22	   */
};

extern const UBYTE s_xpkinfo[];

#define SYSBASE	(*(struct ExecBase **)4)

#define __Remove(__node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_node __asm("a1") = (APTR)(__node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "a0" );})

#define __CreatePool(__flags, __pud, __thr) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_flags __asm("d0") = (ULONG)(__flags);\
  register ULONG __p_pud __asm("d1") = (ULONG)(__pud);\
  register ULONG __p_thr __asm("d2") = (ULONG)(__thr);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-696:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_flags), "d"(__p_pud), "d"(__p_thr), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __DeletePool(__pool) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_pool __asm("a0") = (APTR)(__pool);\
  __asm volatile ("jsr %/a6@(-702:W)\n"\
		   : : "a"(__p_pool), "a"(__p_sys)\
		   : "cc", "memory", "a1" );})

#define __AllocPooled(__pool, __size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_pool __asm("a0") = (APTR)(__pool);\
  register ULONG __p_size __asm("d0") = (ULONG)(__size);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-708:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_pool), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "a1" );\
  __p_res;})

#define __FreePooled(__pool, __blk, __size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_pool __asm("a0") = (APTR)(__pool);\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(__size);\
  __asm volatile ("jsr %/a6@(-714:W)\n"\
		   : : "a"(__p_pool), "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory" );})

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"));

LONG LibClose(struct XpkSubBase *base __asm("a6"))
{
    LONG res = 0;

    if (!--base->xsb_Lib.lib_OpenCnt &&
	(base->xsb_Lib.lib_Flags & LIBF_DELEXP))
	res = (LONG)LibExpunge(base);

    return res;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    BPTR seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->xsb_SegList;
    __Remove(&base->xsb_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->xsb_Lib.lib_NegSize,
	      (ULONG)base->xsb_Lib.lib_NegSize + base->xsb_Lib.lib_PosSize);

    return seg;
}

/* ------------------------------------------------------------------ */
/* xpksub vectors							  */
/* ------------------------------------------------------------------ */

/* -30 XpksPackerInfo */
const void *XpksPackerInfo(void)
{
    return s_xpkinfo;
}

/*
**	bucket table: tab[h*2] = cap, tab[h*2+1] = blk (field0/field1).
**	blk is a longword array: blk[0] = used, positions blk[1..used].
**
**	chain_insert helper (shipped code at 0x49a): appends cur,
**	dead-trims when cur - blk[0] == 259 (blk[0] is the OLD used
**	count, so never), grows cap (<=63: double, >63: +64) when
**	cap<=used, shrinks by 64 when used>1 && cap/2>=used && cap>64.
**	On realloc it copies `used+1` longs verbatim.
*/
static LONG tdcs_insert(ULONG *e, UBYTE *cur, APTR pool)
{
    LONG   cap = (LONG)e[0];
    ULONG *blk;
    ULONG  used, i;
    LONG   d7 = 0;

    if (!cap) {
	ULONG *n = __AllocPooled(pool, 16);
	if (!n)
	    return -1;
	e[1] = (ULONG)n;
	e[0] = 2;
	n[0] = 1;
	n[1] = (ULONG)cur;
	return 0;
    }

    blk  = (ULONG *)e[1];
    used = blk[0];
    blk[1 + used] = (ULONG)cur;
    used++;
    if (used >= 259) {
	/* 0x4c2-0x4dc: if the entry 259 back is exactly 259 behind
	   cur (dense single-bucket inserts), drop it by shifting
	   the whole block down one long.  The copy runs 258
	   iterations of TWO movels per 4-byte count: 516 longs
	   from blk[1], clobbering blk[0] with a position pointer
	   and overrunning the block.  Reproduced verbatim.       */
	if ((ULONG)cur - blk[used - 259] == 259) {
	    used--;
	    for (i = 0; i < 516; i++)
		blk[i] = blk[i + 1];
	}
    }

    if (cap > (LONG)used) {		/* slack -> maybe shrink */
	if (used > 1 && (cap >> 1) >= (LONG)used && cap > 64)
	    d7 = -64;
    } else {				/* cap <= used -> grow   */
	d7 = (cap > 63) ? 64 : cap;
    }

    if (d7) {
	ULONG  ncap = (ULONG)(cap + d7);
	ULONG *nb = __AllocPooled(pool, ncap * 4 + 8);
	if (!nb)
	    return -1;
	/* shipped copy loop moves 8 bytes per 4 bytes counted ->
	   2*used longs, overrunning old and new blocks           */
	for (i = 0; i < 2 * used; i++)
	    nb[i] = blk[i];
	__FreePooled(pool, blk, (ULONG)cap * 4 + 8);
	e[1] = (ULONG)nb;
	e[0] = ncap;
	blk  = nb;
    }

    blk[0] = used;
    return 0;
}

/*
**  find: hash cur, create the bucket if virgin (empty), trim the
**  stale prefix (dist > 65535, stops at first in-window), then walk
**  newest -> oldest.  Returns best length (2 when no match), *dp
**  gets the (negative) distance.  -32768 on pool failure.
*/
static SHORT tdcs_find(UBYTE *cur, ULONG *tab, LONG *dp, APTR pool)
{
    ULONG  key = (((ULONG)cur[0] << 8) | cur[1]) ^ cur[2];
    ULONG *e = &tab[key * 2];
    ULONG *blk = (ULONG *)e[1];
    SHORT  best = 2;
    LONG   i;

    if (!blk) {
	ULONG *n = __AllocPooled(pool, 16);
	if (!n)
	    return -32768;
	e[0] = 2;
	e[1] = (ULONG)n;
	n[0] = 0;
	return 2;
    }

    {
	ULONG used = blk[0], drop = 0;

	if ((LONG)used > 0) {
	    for (i = 0; i < (LONG)used; i++) {
		if ((LONG)((ULONG)cur - blk[1 + i]) <= 65535)
		    break;
		drop++;
	    }
	    if (drop) {
		ULONG j;
		used -= drop;
		for (j = 0; j < used; j++)
		    blk[1 + j] = blk[1 + drop + j];
	    }
	    blk[0] = used;
	}

	for (i = (LONG)used - 1; i >= 0; i--) {
	    const UBYTE *c = (const UBYTE *)blk[1 + i];
	    const UBYTE *s;
	    WORD  len;

	    if (*(const UWORD *)(cur + (SHORT)best - 1) !=
		*(const UWORD *)(c + (SHORT)best - 1))
		continue;
	    if (*(const UWORD *)(cur + 1) != *(const UWORD *)(c + 1))
		continue;
	    s = cur + 3; c += 3;
	    len = 6;
	    for (;;) {
		/* cmpml a0@+,a2@+ -- post-increment: pointers
		   move past the compared long even on mismatch  */
		ULONG sw = *(const ULONG *)s, cw = *(const ULONG *)c;
		s += 4; c += 4;
		if (sw != cw)
		    break;
		len += 4;
		if (len > 260)
		    break;
	    }
	    if (len <= best)
		continue;
	    s -= 4; c -= 4;		/* start of last-compared long */
	    if (*(const UWORD *)s == *(const UWORD *)c) {
		s += 2; c += 2;
	    } else {
		len -= 2; s -= 2; c -= 2;
	    }
	    if (*s != *c)
		len--;
	    if (len <= best)
		continue;
	    best = len;
	    *dp = (LONG)(c - s);		/* cand - cur: negative */
	    if ((UWORD)best >= 257) {	/* bhis: len 257 -> 258!  */
		best = 258;
		break;
	    }
	}
    }
    return best;
}

LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *cur, *out, *outend, *flagslot;
    LONG   remaining;
    ULONG  flagacc;
    LONG   bitcnt;
    APTR   pool;
    ULONG *tab;
    SHORT  len;
    LONG   dist;
    int    i;

    cur       = (UBYTE *)p->xsp_InBuf;
    remaining = (LONG)p->xsp_InLen;
    out       = (UBYTE *)p->xsp_OutBuf;

    pool = __CreatePool(0, 0x8000, 0x1000);
    if (!pool)
	return -7;
    tab = __AllocPooled(pool, 0x80000);
    if (!tab) {
	__DeletePool(pool);
	return -7;
    }
    for (i = 0; i < 0x20000; i++)
	tab[i] = 0;

    outend   = out + p->xsp_InLen;
    flagslot = out;
    out     += 4;
    flagacc  = 0;
    bitcnt   = 15;

    if (remaining > 0) {
	for (;;) {
	    dist = 0;
	    len = tdcs_find(cur, tab, &dist, pool);
	    if (len == -32768) {		/* find-side alloc fail */
		__DeletePool(pool);
		return -7;
	    }

	    if (len <= 257) {
		/* lazy chain (0x256..0x3e8): look ahead at cur+1; if
		   it beats the pending item by >1, emit cur literal
		   (+ insert its position) and slide; repeat until the
		   lookahead stops improving or the adopted len is
		   >=257.  dist slot = sp@(108)/emit sp@(94).       */
		for (;;) {
		    LONG ldist = 0;
		    SHORT llen;

		    cur++;
		    llen = tdcs_find(cur, tab, &ldist, pool);
		    if (llen == -32768) {
			__DeletePool(pool);
			return -7;
		    }
		    if (llen - 1 <= len) {	/* reject */
			cur--;
			break;
		    }
		    /* adopt: literal for cur + emit the lookahead */
		    len  = llen;
		    dist = ldist;
		    cur--;
		    {
			ULONG key = (((ULONG)cur[0] << 8) | cur[1])
				    ^ cur[2];
			if (tdcs_insert(&tab[key * 2], cur, pool)) {
			    __DeletePool(pool);
			    return -7;
			}
		    }
		    *out++ = *cur;
		    cur++;
		    remaining--;
		    if (--bitcnt < 0) {
			flagslot[0] = (UBYTE)(flagacc >> 24);
			flagslot[1] = (UBYTE)(flagacc >> 16);
			flagslot[2] = (UBYTE)(flagacc >> 8);
			flagslot[3] = (UBYTE)flagacc;
			flagslot = out;
			out    += 4;
			flagacc = 0;
			bitcnt  = 15;
		    }
		    if (out > outend) {	/* bhiw: strictly >   */
			__DeletePool(pool);
			return -17;
		    }
		    if (len >= 257)	/* bhis: emit, no more lazy */
			break;
		}
	    }

	    /* sp@(150) aliases the LOW WORD of remaining (sp@(148)):
	       clamp the emitted length to the input left.  Both the
	       258-path (0x3e8) and normal path share this at 0x3fe. */
	    if (len >= (SHORT)remaining)
		len = (SHORT)remaining;

	    if ((SHORT)(len - 3) < 0) {
		*out++ = *cur;			/* flag 00 literal */
		len = 1;
	    } else {
		ULONG l3 = (ULONG)(SHORT)(len - 3);
		ULONG nd = (ULONG)dist;		/* negative -> low16 */
		ULONG tag;

		if ((LONG)l3 <= 3 && dist >= -16385) {
		    /* 01: (dist<<2)|l3  -- note: dist, not -dist  */
		    *out++ = (UBYTE)(((nd << 2) | l3) >> 8);
		    *out++ = (UBYTE)((nd << 2) | l3);
		    tag = 1;
		} else if ((LONG)l3 <= 15 && dist >= -4097) {
		    /* 10: (dist<<4)|l3                          */
		    *out++ = (UBYTE)(((nd << 4) | l3) >> 8);
		    *out++ = (UBYTE)((nd << 4) | l3);
		    tag = 2;
		} else {
		    /* 11: word dist + byte l3                   */
		    *out++ = (UBYTE)(nd >> 8);
		    *out++ = (UBYTE)nd;
		    *out++ = (UBYTE)l3;
		    tag = 3;
		}
		flagacc |= tag << (bitcnt * 2);
	    }

	    remaining -= (LONG)len;

	    /* insert the `len` emitted positions into the chains */
	    {
		LONG n = (LONG)len - 1;
		if (n >= 0) {
		    do {
			if (tdcs_insert(
				&tab[((((ULONG)cur[0] << 8) | cur[1])
				      ^ cur[2]) * 2], cur, pool)) {
			    __DeletePool(pool);
			    return -7;
			}
			cur++;
		    } while (--n >= 0);
		}
	    }

	    if (--bitcnt < 0) {
		flagslot[0] = (UBYTE)(flagacc >> 24);
		flagslot[1] = (UBYTE)(flagacc >> 16);
		flagslot[2] = (UBYTE)(flagacc >> 8);
		flagslot[3] = (UBYTE)flagacc;
		flagslot = out;
		out    += 4;
		flagacc = 0;
		bitcnt  = 15;
	    }

	    if (out >= outend) {		/* bhis: unsigned >= */
		__DeletePool(pool);
		return -17;
	    }
	    if (remaining <= 0)
		break;
	}
    }

    /* terminator: flag 11 at the current slot + zero word        */
    flagacc |= 3UL << (bitcnt * 2);
    flagslot[0] = (UBYTE)(flagacc >> 24);
    flagslot[1] = (UBYTE)(flagacc >> 16);
    flagslot[2] = (UBYTE)(flagacc >> 8);
    flagslot[3] = (UBYTE)flagacc;
    *out++ = 0;
    *out++ = 0;

    {
	LONG outlen = (LONG)(out - (UBYTE *)p->xsp_OutBuf);
	__DeletePool(pool);
	p->xsp_OutLen = (ULONG)outlen;
    }
    return 0;
}

/*
**	-54 XpksUnpackChunk -- flag-long decoder
**
**	d1 is pre-set to -1 (moveq) and reloaded per token with
**	`movew a1@+,d1` -- which on 68k leaves the UPPER word alone,
**	so d1 = 0xffff0000|tok = sign16(tok).  asrl then shifts
**	arithmeticly and `lea a0@(0,d1:l)` yields dst+NEGATIVE dist
**	(backward reference).  The stream round-trips correctly.
**
**	16 items per flag long, MSB-first, 2 bits each:
**	  flaglong==0 -> 16 literals via four movel copies.
**	  00 literal byte.
**	  01 word: d = (s16)tok>>2, len = (tok&3)+3.
**	  10 word: d = (s16)tok>>4; field==0 -> len 3, else merges
**	    into the 11 tail computing len = (field&7)+3 + 8*(field>>3).
**	  11 word d + byte len-3; d==0 -> terminator (return 0).
**	No xsp_OutLen writeback; no input-length check.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;

    for (;;) {
	ULONG flag = ((ULONG)src[0] << 24) | ((ULONG)src[1] << 16) |
		     ((ULONG)src[2] << 8)  | src[3];
	SHORT items = 15;

	src += 4;
	if (!flag) {
	    /* flag long == 0 -> 16 literals at once (four movels) */
	    dst[0]=src[0];  dst[1]=src[1];  dst[2]=src[2];  dst[3]=src[3];
	    dst[4]=src[4];  dst[5]=src[5];  dst[6]=src[6];  dst[7]=src[7];
	    dst[8]=src[8];  dst[9]=src[9];  dst[10]=src[10];dst[11]=src[11];
	    dst[12]=src[12];dst[13]=src[13];dst[14]=src[14];dst[15]=src[15];
	    dst += 16; src += 16;
	    continue;
	}

	do {
	    ULONG hi = flag >> 30;	/* next 2 bits, MSB first */
	    flag <<= 2;

	    if (hi == 0) {
		*dst++ = *src++;
	    } else if (hi == 1) {
		ULONG tok = ((ULONG)src[0] << 8) | src[1];
		const UBYTE *m;
		LONG  l;
		src += 2;
		m = dst + (((LONG)(SHORT)tok) >> 2);	/* signed */
		l = (tok & 3) + 3;
		while (l--)
		    *dst++ = *m++;
	    } else if (hi == 2) {
		ULONG tok = ((ULONG)src[0] << 8) | src[1];
		const UBYTE *m;
		LONG  l;
		src += 2;
		m = dst + (((LONG)(SHORT)tok) >> 4);	/* signed */
		l = tok & 15;
		if (!l) {
		    l = 3;
		    while (l--)
			*dst++ = *m++;
		} else {
		    LONG blk = l >> 3;
		    l = (l & 7) + 3;
		    while (l--)
			*dst++ = *m++;
		    while (blk-- > 0) {
			LONG j;
			for (j = 0; j < 8; j++)
			    *dst++ = *m++;
		    }
		}
	    } else {
		ULONG tok = ((ULONG)src[0] << 8) | src[1];
		const UBYTE *m;
		LONG  l, blk;
		src += 2;
		if (!tok)
		    return 0;		/* terminator           */
		m = dst + (LONG)(SHORT)tok;		/* signed16 */
		l = (LONG)*src++;
		blk = l >> 3;
		l = (l & 7) + 3;
		while (l--)
		    *dst++ = *m++;
		while (blk-- > 0) {
		    LONG j;
		    for (j = 0; j < 8; j++)
			*dst++ = *m++;
		}
	    }
	} while (--items >= 0);
    }
}
