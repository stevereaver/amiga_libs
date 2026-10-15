/*
 * xpkTDCS.library 1.5 (020) -- "Sarnath's Doom"
 * XPK sublibrary by Niels Froehling, 1 Oct 2013.
 * Reconstructed in C from the shipped binary.
 *
 * TDCS ("LZSS family") is the original of the tiered-token Froehling
 * LZ family; xpkLZW5's own description says "Very Similar to TDCS".
 * Same 512KB+4 workmem with head[65536] at sub+0 and chain[65536]
 * at sub+0x40000, same 3-byte hash key b0<<8 | ((b1+b2)&0xff), same
 * lazy match walk, same 2-bit flags MSB-first, 16 items per flag
 * long.  Differences versus LZW5:
 *   - tiered match token uses [len-3] fields (LZW5 uses [len-2]):
 *       01  [-dist:u14][len-3:u2]   len 3..6,   dist <= 16384
 *       10  [-dist:u12][len-3:u4]   len 3..18,  dist <= 4096
 *       11  [-dist:u16][len-3:u8]   len 3..258, dist <= 65535
 *   - terminator is flag 11 + zero token word, and ONLY the 11 path
 *     tests for a zero word (LZW5 tests on any non-literal flag)
 *   - lazy budget is xsp_Mode/34 (modes "cremation" 33, "ashes" 67,
 *     "oblivion" 100 -> budgets 0..2)
 *
 * Register-level quirks of the original that matter:
 *   - the best match is carried packed as [dist:len] in one register
 *     (swap keeps dist in the high word through the compares), so the
 *     emit is literally swap+negw -> the negated distance.
 *   - head table is addressed with a NEGATIVE index off sub+0x40000
 *     (d1 = 0xffff0000|key, so d1.l*4 wraps to sub+0 + key*4); the
 *     key's add.b only touches the low byte, no carry into b0's half.
 *   - PackReset fills DOWNWARD with pre-decrement movem writes from
 *     sub+0x40000: 3 + 14 + 14*4*1260 = 70,577 longs = 282,308 bytes
 *     -- it clears the whole head table and then 20,164 bytes BELOW
 *     the allocation start.  The chain ring above sub+0x40000 is
 *     never initialised; stale entries are harmless because distance
 *     >= 64KB terminates the walk.
 *   - insert() checks the <3-remaining guard once up front, so a
 *     match reaching into the last two input bytes still inserts its
 *     whole tail, reading up to 2 bytes past the input end.
 *   - decoder: only the 11 path reads the token word with a zero
 *     test; a zero word under 01/10 is decoded as a real (corrupt)
 *     token.  outlen is never written back (xsp_OutLen untouched).
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
**	-48 XpksPackReset -- the downward fill
**
**	The shipped movem fill writes 3 + 14 + 14*4*1260 = 70,577
**	longs DOWNWARD from sub+0x40000: the entire 64K-long head
**	table is zeroed and then the fill continues 20,164 bytes
**	past the start of the allocation.  Modelled faithfully:
**	clear head[65536], then clobber the 5,041 longs below sub.
**	The chain ring above sub+0x40000 is left stale on purpose
**	(dist >= 64KB kills any garbage candidate).
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *w = sub + 0x10000;		/* one past head end */
	LONG  i;
	for (i = 0; i < 70577; i++)	/* shipped count */
	    *--w = 0;
    }

    return 0;
}

/*
**	-36 XpksPackChunk -- tiered lazy-matching LZ encoder
**
**	tab[k] = head[key], tab[0x10000 + (p & 0xffff)] = chain.
**	key = b0<<8 | ((b1+b2)&0xff).
*/

static void tdcs_putl(UBYTE *p, ULONG v)	/* movel (a6)+ -- big endian */
{
    p[0] = (UBYTE)(v >> 24); p[1] = (UBYTE)(v >> 16);
    p[2] = (UBYTE)(v >> 8);  p[3] = (UBYTE)v;
}

static void tdcs_putw(UBYTE *p, ULONG v)	/* movew (a6)+ -- big endian */
{
    p[0] = (UBYTE)(v >> 8);  p[1] = (UBYTE)v;
}

/* returns packed [dist:len] like the original's d5 */
static ULONG tdcs_find(UBYTE *cur, ULONG remaining, ULONG *tab)
{
    ULONG cand, best = 2, dist = 0, maxlen;

    if (remaining < 3)
	return 1;			/* d5 = 1 -> literal */

    maxlen = remaining < 258 ? remaining : 258;
    cand = tab[(cur[0] << 8) | ((ULONG)(cur[1] + cur[2]) & 0xff)];

    /* walk: signed dist < 64K; quick byte at [best], then verify */
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

    return (dist << 16) | best;
}

static void tdcs_insert(UBYTE **curp, ULONG remaining, ULONG len,
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
    ULONG remaining, flagacc;
    SHORT bitpos;
    ULONG budget;

    if (!p->xsp_Sub[0]) {
	ULONG *buf = (ULONG *)__AllocMem(0x80004, 0);
	if (!buf)
	    return -7;
	buf[0] = 0x80004;
	p->xsp_Sub[0] = (ULONG)(buf + 1);
    }

    XpksPackReset(p);

    tab = (ULONG *)p->xsp_Sub[0];		/* head at sub+0 */

    cur    = (UBYTE *)p->xsp_InBuf;
    out    = (UBYTE *)p->xsp_OutBuf;
    outend = out + p->xsp_InLen;		/* bound = inlen */
    remaining = p->xsp_InLen;

    /* d3 high word = xsp_Mode / 34 (divuw), low word = bitpos */
    {
	ULONG d3 = p->xsp_Mode;
	__asm volatile ("divuw #34,%0" : "+d"(d3));
	budget = (UWORD)d3;
    }

    flagacc  = 0;
    bitpos   = 30;
    flagslot = out;
    out += 4;

    for (;;) {
	ULONG curpk, bestpk;
	UWORD adv;

	curpk = tdcs_find(cur, remaining, tab);	/* [dist:len] */
	bestpk = curpk;

	/* ---- lazy lookahead ------------------------------------------ */
	if (budget && (UWORD)curpk != 258) {
	    adv = 1;
	    for (;;) {
		SHORT gain;

		cur++;
		remaining--;
		curpk = tdcs_find(cur, remaining, tab);
		gain = (SHORT)((UWORD)curpk - adv);	/* nlen - adv */

		if (gain <= (SHORT)(UWORD)bestpk)
		    goto exhausted;

		/* adopt: rewind to base, literalise the gap */
		bestpk = curpk;
		cur -= adv;
		remaining += adv;
		while (adv) {
		    UBYTE *o = cur;
		    *out++ = *o;			/* literal */
		    tdcs_insert(&o, remaining, 1, tab);
		    cur = o;
		    remaining--;
		    bitpos -= 2;			/* flag tick */
		    if (bitpos < 0) {
			tdcs_putl(flagslot, flagacc);
			flagslot = out;
			out += 4;
			bitpos = 30;
			flagacc = 0;
		    }
		    if (out >= outend)
			return -17;
		    adv--;
		}
		if ((UWORD)bestpk == 258)
		    break;
		adv = 1;
		continue;

exhausted:
		adv++;
		if ((SHORT)adv < (SHORT)budget)
		    continue;
		/* rewind the failed advances: cur was at
		   best+adv, back to best+1 */
		cur -= adv;
		cur++;
		remaining += adv;
		remaining--;
		break;
	    }
	}
	curpk = bestpk;

	/* ---- emit ----------------------------------------------------- */
	if ((UWORD)curpk < 3) {
	    /* literal: raw byte, tag 00 (nothing or'd) */
	    *out++ = *cur;
	    curpk = 1;
	} else {
	    /* token: d0 = swap+negw of packed -> [-dist:u16][len] */
	    ULONG len = curpk & 0xffff;
	    UWORD ndist = (UWORD)(0 - (UWORD)(curpk >> 16));
	    ULONG l3 = len - 3, tag;

	    /* tier tests are UNSIGNED compares on the raw emitted
	       word (cmpl.w #$bfff/bls, #$efff/bls): dist <= 16384
	       picks short, dist <= 4096 medium.  Note dist 8192-
	       16383 at len 3..6 and dist = 4096 at len 3..18 emit
	       tokens that lose the sign bit when shifted -- the
	       shipped defect, reproduced verbatim. */
	    if (l3 <= 3 && ndist > 0xbfff) {
		/* 01: (-dist)<<2 | (len-3) */
		tdcs_putw(out, (UWORD)((ndist << 2) | l3));
		out += 2;
		tag = 1;
	    } else if (l3 <= 15 && ndist > 0xefff) {
		/* 10: (-dist)<<4 | (len-3) */
		tdcs_putw(out, (UWORD)((ndist << 4) | l3));
		out += 2;
		tag = 2;
	    } else {
		/* 11: [-dist:u16][len-3:u8] */
		tdcs_putw(out, ndist);
		out += 2;
		*out++ = (UBYTE)l3;
		tag = 3;
	    }
	    flagacc |= tag << bitpos;
	}

	bitpos -= 2;				/* flag tick */
	if (bitpos < 0) {
	    tdcs_putl(flagslot, flagacc);
	    flagslot = out;
	    out += 4;
	    bitpos = 30;
	    flagacc = 0;
	}

	tdcs_insert(&cur, remaining, (UWORD)curpk, tab);

	if (out >= outend)
	    return -17;

	remaining -= (UWORD)curpk;
	if ((LONG)remaining <= 0)
	    break;
    }

    /* terminator: flag 3 lsl'd into place (moveq #3 / lsl.l d3 /
       or.l), then a zero token word -- decoder exits on the 11
       path's beq. */
    flagacc |= 3UL << bitpos;
    tdcs_putl(flagslot, flagacc);
    tdcs_putw(out, 0);
    out += 2;

    p->xsp_OutLen = (ULONG)(out - (UBYTE *)p->xsp_OutBuf);
    return 0;
}

/*
**	-54 XpksUnpackChunk -- flag-long decoder
**
**	flag long 0 -> 16 literals; else 16 items MSB first, 2 bits
**	each: 00 literal / 01 short / 10 medium / 11 long.
**	Only the 11 path tests the token word for zero (terminator);
**	under 01/10 the word is decoded unconditionally.
**	Short: dist = asr(tok,2), len = (tok&3)+3.
**	Medium: dist = asr(tok,4), len = (tok&15)+3.
**	Long: dist = tok (negated), len = byte + 3.
**	No outlen writeback.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *src = (UBYTE *)p->xsp_InBuf;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;

    for (;;) {
	ULONG flag = ((ULONG)src[0] << 24) | ((ULONG)src[1] << 16) |
		     ((ULONG)src[2] << 8) | src[3];
	ULONG items = 16;

	src += 4;
	if (!flag) {
	    ULONG i;				/* 16 literals */
	    for (i = 0; i < 16; i++)
		*dst++ = *src++;
	    continue;
	}

	while (items--) {
	    ULONG f2;

	    f2 = flag & 0x80000000UL; flag <<= 1;
	    if (!f2) {				/* 0x */
		if (flag & 0x80000000UL) {	/* 01 short */
		    ULONG tok;
		    flag <<= 1;
		    tok = ((ULONG)src[0] << 8) | src[1];
		    src += 2;
		    {
			LONG dist = (SHORT)tok >> 2;	/* asr */
			ULONG len = (tok & 3) + 3;
			const UBYTE *m = dst + dist;
			while (len--)
			    *dst++ = *m++;
		    }
		} else {			/* 00 literal */
		    flag <<= 1;
		    *dst++ = *src++;
		}
	    } else {				/* 1x */
		if (flag & 0x80000000UL) {	/* 11 long */
		    LONG dist;
		    ULONG len;
		    ULONG tok;
		    flag <<= 1;
		    tok = ((ULONG)src[0] << 8) | src[1];
		    src += 2;
		    if (!tok)
			return 0;
		    dist = (SHORT)tok;
		    len = (ULONG)*src++ + 3;
		    {
			const UBYTE *m = dst + dist;
			while (len--)
			    *dst++ = *m++;
		    }
		} else {			/* 10 medium */
		    ULONG tok;
		    LONG dist;
		    ULONG len;
		    flag <<= 1;
		    tok = ((ULONG)src[0] << 8) | src[1];
		    src += 2;
		    dist = (SHORT)tok >> 4;	/* asr */
		    len = (tok & 15) + 3;
		    {
			const UBYTE *m = dst + dist;
			while (len--)
			    *dst++ = *m++;
		    }
		}
	    }
	}
    }
}
