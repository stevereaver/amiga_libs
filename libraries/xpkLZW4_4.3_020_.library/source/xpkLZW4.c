/*
 * xpkLZW4.library 4.3 (020) -- "LZ-Welsh (not Welch) 020+"
 * XPK sublibrary by Niels Froehling, 1 Oct 2013.
 * Reconstructed in C from the shipped binary.
 *
 * Successor of xpkLZW3 in the same family: a 64K-entry head
 * table plus a 65536-entry chain ring indexed by the position's
 * low 16 bits, both storing raw pointers inside a 512KB+4
 * workmem.  The 4.x changes versus 3.x:
 *   - hash key is a 3-byte window w(p)+b(p+2) (was w(p)^w(p+2)
 *     over 4 bytes)
 *   - flag long is consumed MSB first (was LSB); emitted by
 *     shifting a sentinel one through the register
 *   - match token is [-dist:u16][len-3:u8], len 3..258
 *     (was len-4, len 4..259)
 *   - lazy matching: up to budget = (xsp_Mode-1)/25 positions
 *     ahead are tried per item; a later match replaces the best
 *     so far if its length minus the skipped distance beats it.
 *     The four shipped modes ("cremation" 25 / "ashes" 50 /
 *     "grave" 75 / "oblivion" 100) give budgets 0..3.
 *   - LibInit gates on AFB_68020 and PackReset fills exactly
 *     the 65536-long head table (the 3.3 fill underflowed 68
 *     bytes into the allocation header -- fixed in 4.x).
 *
 * Stream format:
 *   [flaglong][32 items] ... [flaglong][items] [0x0000 token]
 *     flag long = next 32 items, MSB first, 1 = match / 0 =
 *                 literal; a zero flag long = 32 literals
 *                 (decoder fast path)
 *     literal   = 1 raw byte
 *     match     = [-dist:u16][len-3:u8]; dist 1..0xffff,
 *                 len 3..258; token word 0 terminates
 *
 * Register-level quirks of the original that matter:
 *   - the best match is carried packed as [dist:len] in one
 *     register (swap keeps dist in the high word through the
 *     compares), so the emit is literally swap+negw -> the
 *     negated distance.
 *   - the head table is addressed with a NEGATIVE index off a
 *     base planted at sub+0x40000 (d1 = 0xffff0000|key, so
 *     d1.l*4 wraps to sub+0 + key*4); the key itself is
 *     b0<<8 | ((b1+b2)&0xff) -- the add.b only touches the
 *     low byte, no carry into b0's half.
 *   - the decoder seeds d1 with moveq #-1 so reloading the
 *     token word sign-extends it -> dst + (-dist) = backward
 *     copy.  Word 0 is the terminator.
 *   - output bound = outbuf + inlen (xsp_OutBufLen ignored),
 *     checked after each emitted item.
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
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size (unused)	   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18					   */
    ULONG xsp_Mode;		/* 0x1c					   */
    APTR  xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Tags[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34 sublib private data		   */
};

struct XpkSubBase
{
    struct Library	xsb_Lib;
    BPTR		xsb_SegList;	/* +0x22 */
};

extern const UBYTE s_xpkinfo[];	/* XpkInfo + XpkMode descriptor block  */

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_size __asm("d0") = (ULONG)(__size);\
  register ULONG __p_flags __asm("d1") = (ULONG)(___flags);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_size), "d"(__p_flags), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "a0" );})

#define __Remove(__node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_node __asm("a1") = (APTR)(__node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define SYSBASE	(*(struct ExecBase **)4)

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
**	-42 XpksPackFree -- FreeMem(xsp_Sub-4, buf[0])
**
**	Reads the size long the packer stored at buf[0].  Unlike
**	3.3 the reset fill no longer tramples it, so the 512KB
**	workmem frees correctly here.
*/
LONG XpksPackFree(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *blk = sub - 1;		/* back up to the size word */
	__FreeMem(blk, blk[0]);
    }

    return 0;
}

/*
**	-48 XpksPackReset -- clear the head table
**
**	Fills DOWNWARD with pre-decrement movem writes starting
**	at sub+0x40000: 3 + 13 + 4*1260*13 = 65,536 longs --
**	exactly the 256 KB head table and not a byte more (the
**	68-byte underflow of the 3.3 fill is gone).  The 256 KB
**	chain ring above sub+0x40000 is still never initialised;
**	stale entries are harmless because a distance >= 64 KB
**	terminates the walk before they can be followed.
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *w = sub, *end = sub + 0x10000;	/* head[65536] */
	while (w < end)
	    *w++ = 0;
    }

    return 0;
}

/*
**	-36 XpksPackChunk -- lazy-matching LZ encoder
**
**	Workmem layout (allocated lazily, 0x80004 bytes):
**	    buf[0]       allocation size word
**	    sub+0x00000  ULONG head[65536]  newest pos per key
**	    sub+0x40000  ULONG chain[65536] prev pos ring, pos&0xffff
**
**	One flat ULONG table models both halves: head[k] = tab[k]
**	and chain[p] = tab[0x10000 + (p & 0xffff)].
**
**	key = b0<<8 | ((b1+b2)&0xff)  (the original's
**	move.w+add.b leaves the b0 half untouched).
**
**	Match walk: dist = cur - cand, stop at signed dist >=
**	64KB; quick-check cur[best]==cand[best], then verify
**	0..best-1 and extend to min(258, remaining); strictly
**	longer wins (newest-first walk -> nearest match preferred).
**
**	Lazy pass: while the mode budget lasts, positions ahead
**	of the item are tried; a match whose length minus the
**	skipped distance beats the best literalises the gap and
**	becomes the new best (earlier bests are discarded).
**
**	Insert: every consumed input position gets its 3-byte
**	key chained (LAB_0029 in the original) -- the <3-remaining
**	guard is checked once up front, so a match reaching into
**	the last two input bytes still inserts its whole tail,
**	reading up to 2 bytes past the input end.
*/

static void lzw4_putl(UBYTE *p, ULONG v)	/* movel (a6)+ -- big endian */
{
    p[0] = (UBYTE)(v >> 24); p[1] = (UBYTE)(v >> 16);
    p[2] = (UBYTE)(v >> 8);  p[3] = (UBYTE)v;
}

static void lzw4_putw(UBYTE *p, ULONG v)	/* movew (a6)+ -- big endian */
{
    p[0] = (UBYTE)(v >> 8);  p[1] = (UBYTE)v;
}

static ULONG lzw4_find(UBYTE *cur, ULONG remaining, ULONG *tab,
		       ULONG *distp)
{
    ULONG cand, best = 2, dist = 0, maxlen;

    if (remaining < 3) {
	*distp = 0;			/* packed d5 = 1 -> dist half 0 */
	return 1;
    }

    maxlen = remaining < 258 ? remaining : 258;
    cand = tab[(cur[0] << 8) | ((ULONG)(cur[1] + cur[2]) & 0xff)];

    while ((LONG)((ULONG)cur - cand) < 0x10000) {
	const UBYTE *c = (const UBYTE *)cand;

	if (cur[best] == c[best]) {
	    ULONG len = 0;
	    while (len < maxlen && cur[len] == c[len])
		len++;
	    if (len > best) {
		best = len;
		dist = (ULONG)cur - cand;
		if (len >= maxlen)
		    break;
	    }
	}
	cand = tab[0x10000 + (cand & 0xffff)];
    }

    *distp = dist;
    return best;
}

static void lzw4_insert(UBYTE **curp, ULONG remaining, ULONG len,
			ULONG *tab)
{
    UBYTE *cur = *curp;
    ULONG i;

    if (remaining < 3) {
	*curp = cur + len;
	return;
    }
    for (i = 0; i < len; i++, cur++) {
	ULONG key = (cur[0] << 8) | ((ULONG)(cur[1] + cur[2]) & 0xff);
	tab[0x10000 + ((ULONG)cur & 0xffff)] = tab[key];
	tab[key] = (ULONG)cur;
    }
    *curp = cur;
}

LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"))
{
    ULONG *tab;
    UBYTE *out, *outend, *flagslot, *cur;
    ULONG remaining, flag, carry;
    UWORD budget;

    if (!p->xsp_Sub[0]) {
	ULONG *buf = (ULONG *)__AllocMem(0x80004, 0);
	if (!buf)
	    return -7;
	buf[0] = 0x80004;
	p->xsp_Sub[0] = (ULONG)(buf + 1);
    }

    XpksPackReset(p);

    tab = (ULONG *)p->xsp_Sub[0];

    cur    = (UBYTE *)p->xsp_InBuf;
    out    = (UBYTE *)p->xsp_OutBuf;
    outend = out + p->xsp_InLen;		/* bound = inlen */
    remaining = p->xsp_InLen;

    {					/* d3 = (xsp_Mode-1)/25 */
	ULONG d3 = p->xsp_Mode;
	if (d3) {
	    d3 = (d3 & ~0xffUL) | ((d3 - 1) & 0xff);	/* subqb */
	    __asm volatile ("divuw #25,%0"
			    : "+d"(d3));		/* overflow: unchanged */
	}
	budget = (UWORD)d3;
    }

    flagslot = out;
    out += 4;				/* first flag-long slot */
    flag = 1;				/* sentinel */

    for (;;) {
	ULONG best, bestdist;

	best = lzw4_find(cur, remaining, tab, &bestdist);

	/* lazy pass: try positions ahead while the net gain
	   (len - advance) beats the current best */
	if (budget && best != 258) {
	    UWORD adv = 1;

	    for (;;) {
		ULONG nlen, ndist;

		cur++;
		remaining--;
		nlen = lzw4_find(cur, remaining, tab, &ndist);

		if ((SHORT)((UWORD)nlen - adv) <= (SHORT)(UWORD)best) {
		    /* no improvement */
		    if ((SHORT)++adv >= (SHORT)budget) {
			/* exhausted: a2 sits at best+d2-1,
			   rewind d2 to the best position */
			cur -= adv;
			cur++;
			remaining += adv;
			remaining--;
			break;
		    }
		    continue;
		}

		/* adopt: rewind, literalise the gap */
		best = nlen;
		bestdist = ndist;
		cur -= adv;
		remaining += adv;
		while (adv--) {
		    *out++ = *cur;
		    lzw4_insert(&cur, remaining, 1, tab);
		    remaining--;

		    carry = flag;
		    flag <<= 1;			/* literal = 0 */
		    if (carry & 0x80000000UL) {
			lzw4_putl(flagslot, flag);
			flagslot = out;
			out += 4;
			flag = 1;
		    }
		    if (out >= outend)
			return -17;
		}
		if (best == 258)
		    break;
		adv = 1;
	    }
	}

	/* emit the item */
	if (best < 3) {
	    *out++ = *cur;
	    best = 1;
	    carry = flag;
	    flag <<= 1;				/* literal = 0 */
	} else {
	    lzw4_putw(out, (UWORD)(-(WORD)bestdist));	/* -dist */
	    out += 2;
	    *out++ = (UBYTE)(best - 3);			/* len-3 */
	    carry = flag;
	    flag = (flag << 1) | 1;			/* match = 1 */
	}
	if (carry & 0x80000000UL) {
	    lzw4_putl(flagslot, flag);
	    flagslot = out;
	    out += 4;
	    flag = 1;
	}

	lzw4_insert(&cur, remaining, best, tab);

	if (out >= outend)
	    return -17;

	remaining -= best;
	if ((LONG)remaining <= 0)	/* ext.l/sub.l/bgt -- signed */
	    break;
    }

    /* terminator: a match-flagged zero token */
    carry = flag;
    flag = (flag << 1) | 1;
    if (!(carry & 0x80000000UL)) {
	do {
	    carry = flag;
	    flag <<= 1;
	} while (!(carry & 0x80000000UL));
    }
    lzw4_putl(flagslot, flag);
    lzw4_putw(out, 0);
    out += 2;

    p->xsp_OutLen = (ULONG)(out - (UBYTE *)p->xsp_OutBuf);
    return 0;
}

/*
**	-54 XpksUnpackChunk -- decoder
**
**	Flag long: if 0 -> copy 32 literal bytes; else 32 items,
**	MSB first (0 = literal byte, 1 = match token).
**	Match token word 0 -> end; else it is the NEGATED
**	distance (the shipped code seeds d1 with moveq #-1 so
**	the movew reload sign-extends).  len = byte + 3; a zero
**	len byte gives len 3 via the unrolled-copy entry point.
**	No outlen writeback.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *src = (UBYTE *)p->xsp_InBuf;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;

    for (;;) {
	ULONG flag = ((ULONG)src[0] << 24) | ((ULONG)src[1] << 16) |
		     ((ULONG)src[2] << 8) | src[3];
	ULONG bits = 32;

	src += 4;
	if (!flag) {
	    /* flag long 0 -> 32 literals via 8 longs */
	    ULONG i;
	    for (i = 0; i < 32; i++)
		*dst++ = *src++;
	    continue;
	}

	while (bits--) {
	    ULONG bit = flag & 0x80000000UL;

	    flag <<= 1;
	    if (!bit) {
		*dst++ = *src++;
		continue;
	    }

	    {
		/* moveq #-1,d1 / move.w (a0)+,d1 -> d1 = 0xffff0000|tok,
		   i.e. dst + tok - 0x10000: the token is the negated
		   distance, so 1..0xffff reaches back 0xffff..1. */
		ULONG tok = ((ULONG)src[0] << 8) | src[1];
		ULONG len;

		src += 2;
		if (!tok)
		    return 0;

		len = (ULONG)*src++ + 3;
		{
		    const UBYTE *m = dst - (0x10000UL - tok);
		    while (len--)
			*dst++ = *m++;
		}
	    }
	}
    }
}
