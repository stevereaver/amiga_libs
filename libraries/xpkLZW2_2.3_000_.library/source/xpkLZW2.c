/*
 * xpkLZW2.library 2.3 -- "LZ-Welsh (not Welch) V2.3"
 * XPK sublibrary by Niels Froehling, 1 Oct 2013.
 * Reconstructed in C from the shipped binary.
 *
 * Predecessor of xpkLZW3 3.3 -- same LZ77 family ("LZ-Welsh"):
 * a 16K-entry hash of the 4-byte window w(p)^w(p+2) plus a
 * 65536-entry chain ring indexed by the position's low 16
 * bits, both tables storing raw pointers inside a 320KB+4
 * workmem (xsp_Sub[0]).
 *
 * Stream format (identical to LZW3):
 *   [flaglong][32 items] ... [flaglong][items] [0x0000 token]
 *     flag long = next 32 items, LSB first, 1 = match / 0 =
 *                 literal; a zero flag long = 32 literals
 *                 (decoder fast path)
 *     literal   = 1 raw byte
 *     match     = [-dist:u16][len-4:u8]; dist 1..0xffff,
 *                 len 4..259; token word 0 terminates
 *
 * Differences from the 3.3 rebuild:
 *   - hash mask is 0x3fff (16K entries, 64KB table) instead
 *     of 0xffff (64K entries, 256KB table); workmem 0x50004.
 *   - lazy insertion: after a match of length L only the
 *     positions cur+1..cur+3 and cur+L are hashed; positions
 *     inside the match are skipped (packs faster, chains are
 *     sparser).  LZW3 seeds every position.
 *   - PackReset's downward fill runs 5,040 bytes below the
 *     block (LZW3 runs only 68 bytes under).
 *
 * Register-level quirks preserved from the original:
 *   - the best match is carried packed as [dist:len] in one
 *     register (swap d2 keeps dist in the high word), so the
 *     emit is literally swap+negw -> the negated distance.
 *   - the decoder seeds d1 with moveq #-1 so reloading the
 *     token word sign-extends it -> dst + (-dist) = backward
 *     copy.  Word 0 is the terminator.
 *   - output bound = outbuf + inlen (xsp_OutBufLen ignored),
 *     checked after each item; -17 on overrun.
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

struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->xsb_SegList = seglist;
    return (struct Library *)base;
}

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

/*
**	-30 XpksPackerInfo
*/
LONG XpksPackerInfo(void)
{
    return (LONG)s_xpkinfo;
}

/*
**	-42 XpksPackFree
**
**	xsp_Sub[0] points at the workmem's first usable long;
**	the AllocMem size sits in the long just below it.
**	If PackReset ran first, that size word is already zero
**	(PackReset's underflow), so this frees 0 bytes -- the
**	320KB workmem leaks.  Preserved as shipped.
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
**	-48 XpksPackReset
**
**	The shipped code fills DOWNWARD with pre-decrement movem
**	writes starting at sub+0x10000 (the top of the hash
**	table): one 4-long frame, then 252 iterations of five
**	14-long frames = 4 + 252*5*14 = 17,644 longs = 70,576
**	bytes -- the whole 64 KB hash plus 5,040 bytes BELOW the
**	block (which includes the buf[0] size word!).  The 256 KB
**	chain ring above sub+0x10000 is never initialised.
**	This version clears the intended region.
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *w = sub, *end = sub + 0x4000;	/* hash[16384] */
	while (w < end)
	    *w++ = 0;
    }

    return 0;
}

/*
**	-36 XpksPackChunk -- encoder
**
**	hash[16384] at sub+0, chain[65536] at sub+0x10000.
**	The chain ring is indexed by the candidate pointer's low
**	16 bits, so it acts as a 64K-position window ring.
**
**	Lazy seeding (the shipped scheme): after an item of
**	length L only cur+1..cur+3 (one for a literal) and cur+L
**	itself are inserted into the hash; the positions inside
**	a match are skipped entirely.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"))
{
    ULONG *hash, *chain;
    UBYTE *cur, *out, *outend, *flagslot;
    LONG remaining, best;
    ULONG flag, d3;

    if (!p->xsp_Sub[0]) {
	ULONG *buf = __AllocMem(0x50004, 0);

	if (!buf)
	    return -7;
	buf[0] = 0x50004;
	p->xsp_Sub[0] = (ULONG)(buf + 1);
    }

    XpksPackReset(p);

    hash  = (ULONG *)p->xsp_Sub[0];
    chain = hash + 0x4000;		/* sub + 0x10000 */

    cur       = (UBYTE *)p->xsp_InBuf;
    out       = (UBYTE *)p->xsp_OutBuf;
    outend    = out + p->xsp_InLen;	/* bound = inlen */
    remaining = p->xsp_InLen;

    flagslot = out;
    out += 4;				/* first flag-long slot */
    d3   = 0;
    flag = 0;
    best = 1;

    cur--;				/* a2 = inbuf - 1 */

    for (;;) {
	ULONG cand = 0, bestdist = 0;

	if (remaining >= 4) {
	    ULONG i, seed = (best == 1) ? 1 : 3;

	    /* lazy seeding: cur+1..cur+seed, then skip to
	       cur+best and insert the new position */
	    for (i = 0; i < seed; i++) {
		ULONG h;
		cur++;
		h = (((ULONG)cur[0] << 8 | cur[1]) ^
		     ((ULONG)cur[2] << 8 | cur[3])) & 0x3fff;
		cand = hash[h];
		hash[h] = (ULONG)cur;
		chain[(ULONG)cur & 0xffff] = cand;
	    }
	    if (best > 1) {
		ULONG h;
		cur += best - 4;	/* skip the match body */
		cur++;
		h = (((ULONG)cur[0] << 8 | cur[1]) ^
		     ((ULONG)cur[2] << 8 | cur[3])) & 0x3fff;
		cand = hash[h];
		hash[h] = (ULONG)cur;
		chain[(ULONG)cur & 0xffff] = cand;
	    }
	} else {
	    cur += best;		/* consume previous item */
	    goto literal;
	}

	best = 3;
	{
	    ULONG maxlen = remaining < 259 ? remaining : 259;

	    while ((ULONG)(cur - (UBYTE *)cand) < 0x10000) {
		ULONG len;

		if (cur[best] != ((UBYTE *)cand)[best])
		    goto next;

		/* quick-check passed: verify the first best
		   bytes, then extend toward maxlen */
		len = 0;
		while (len < maxlen && cur[len] == ((UBYTE *)cand)[len])
		    len++;

		if (len >= best) {
		    best = len;
		    bestdist = (ULONG)(cur - (UBYTE *)cand);
		    if (len >= maxlen)
			break;
		}
	    next:
		cand = chain[(ULONG)cand & 0xffff];
	    }

	    if (best >= 4)
		goto emit;
	}

    literal:
	best = 1;
	*out++ = cur[0];
	goto after;

    emit:
	*(UWORD *)out = (UWORD)(-(WORD)bestdist);	/* -dist */
	out += 2;
	*out++ = (UBYTE)(best - 4);			/* len-4 */
	flag |= 1UL << d3;				/* match bit */

    after:
	d3++;
	if (d3 == 32) {
	    *(ULONG *)flagslot = flag;
	    flagslot = out;
	    out += 4;
	    d3 = 0;
	    flag = 0;
	}

	if (out >= outend) {
	    p->xsp_OutLen = 0;
	    return -17;
	}

	remaining -= best;
	if (!remaining)
	    break;
    }

    /* terminator: a match flag bit + a zero token word */
    flag |= 1UL << d3;
    *(ULONG *)flagslot = flag;
    *(UWORD *)out = 0;
    out += 2;

    p->xsp_OutLen = (ULONG)(out - (UBYTE *)p->xsp_OutBuf);
    return 0;
}

/*
**	-54 XpksUnpackChunk -- decoder
**
**	Flag long: if 0 -> copy 32 literal bytes; else 32 items,
**	LSB first (0 = literal byte, 1 = match token).
**	Match token word 0 -> end; else it is the NEGATED
**	distance (d1 was seeded with moveq #-1 so the movew
**	reload sign-extends: a2 = a1 + (-dist)).
**	len = byte + 4.  No input or output bound checks, and
**	xsp_OutLen is never written -- both as shipped.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *src = (UBYTE *)p->xsp_InBuf;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;

    for (;;) {
	ULONG flag = ((ULONG)src[0] << 24) | ((ULONG)src[1] << 16) |
		     ((ULONG)src[2] << 8) | src[3];
	ULONG bits;

	src += 4;
	if (!flag) {
	    ULONG i;
	    for (i = 0; i < 32; i++)
		*dst++ = *src++;
	    continue;
	}

	bits = 32;
	while (bits--) {
	    if (flag & 1) {
		ULONG len;
		UWORD tok = ((UWORD)src[0] << 8) | src[1];

		src += 2;
		if (!tok)
		    return 0;

		len = *src++ + 4;
		{
		    /* d1 keeps its moveq #-1 upper word, so the
		       16-bit token sign-extends: dst + (tok-0x10000)
		       = dst - dist even for dist > 0x8000 */
		    UBYTE *m = dst + (LONG)tok - 0x10000;
		    while (len--)
			*dst++ = *m++;
		}
	    } else {
		*dst++ = *src++;
	    }
	    flag >>= 1;
	}
    }
}
