/*
 * xpkLZW3.library 3.3 (020) -- "LZ-Welsh (not Welch) 020+"
 * XPK sublibrary by Niels Froehling, 1 Oct 2013.
 * Reconstructed in C from the shipped binary.
 *
 * Despite the 'LZW3' id this is an LZ77 variant in the same
 * family as xpkSLZ3: a 64K-entry hash of the 4-byte window
 * w(p)^w(p+2) plus a 65536-entry chain ring indexed by the
 * position's low 16 bits, both tables storing raw pointers
 * inside a 512KB+4 workmem.
 *
 * Stream format:
 *   [flaglong][32 items] ... [flaglong][items] [0x0000 token]
 *     flag long = next 32 items, LSB first, 1 = match / 0 =
 *                 literal; a zero flag long = 32 literals
 *                 (decoder fast path)
 *     literal   = 1 raw byte
 *     match     = [-dist:u16][len-4:u8]; dist 1..0xffff,
 *                 len 4..259; token word 0 terminates
 *
 * Register-level quirks of the original that matter:
 *   - the best match is carried packed as [dist:len] in one
 *     register (swap d2 keeps dist in the high word), so the
 *     emit is literally swap+negw -> the negated distance.
 *   - the decoder seeds d1 with moveq #-1 so reloading the
 *     token word sign-extends it -> dst + (-dist) = backward
 *     copy.  Word 0 is the terminator.
 *   - output bound = outbuf + inlen (xsp_OutBufLen ignored),
 *     checked after each item.
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
**	As shipped: reads the size long the allocator wrote at
**	buf[0].  PackReset's underflow zeroes that word, so a
**	PackReset followed by PackFree calls FreeMem(ptr, 0) --
**	the 512KB workmem is never freed (shipped leak).
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
**	writes starting at sub+0x40000 (the top of the hash
**	table): 3 + 4*1260*13 = 65,523 longs = 262,092 bytes --
**	the whole 256 KB hash plus 68 bytes BELOW the block
**	(which includes the buf[0] size word!).  The 256 KB
**	chain ring above sub+0x40000 is never initialised.
**	This version clears the intended region.
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *w = sub, *end = sub + 0x10000;	/* hash[65536] */
	while (w < end)
	    *w++ = 0;
    }

    return 0;
}

/*
**	-36 XpksPackChunk -- greedy LZ encoder
**
**	Workmem layout (allocated lazily, 0x80004 bytes):
**	    buf[0]       allocation size word
**	    sub+0x00000  ULONG hash[65536]  last pos per 16-bit hash
**	    sub+0x40000  ULONG chain[65536] prev pos ring, pos&0xffff
**
**	hash = w(cur) ^ w(cur+2)  (4-byte window; only seeded
**	while 4+ input bytes remain -- tail bytes go literal).
**
**	Match walk: dist = cur - cand, stop at 64KB; quick-check
**	cur[best]==cand[best]; full compare capped at
**	min(259, remaining); accept len>=best (later candidates
**	win ties -> farthest distance); emit early at maxlen.
**
**	Flags: d3 counts 0..31, match sets bit d3 of the group
**	long; a full group is stored big-endian at the reserved
**	slot and a new 4-byte slot is reserved in-stream.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *out, *outend;
    ULONG *hash, *chain;
    ULONG  remaining, best, flag, d3;
    UBYTE *flagslot, *cur;

    if (!p->xsp_Sub[0]) {
	ULONG *buf = (ULONG *)__AllocMem(0x80004, 0);
	if (!buf)
	    return -7;
	buf[0] = 0x80004;
	p->xsp_Sub[0] = (ULONG)(buf + 1);
    }

    XpksPackReset(p);

    hash  = (ULONG *)p->xsp_Sub[0];
    chain = hash + 0x10000;

    cur    = (UBYTE *)p->xsp_InBuf;
    out    = (UBYTE *)p->xsp_OutBuf;
    outend = out + p->xsp_InLen;		/* bound = inlen */
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
	    ULONG i;

	    /* seed 'best' positions (advance + insert each) */
	    for (i = 0; i < best; i++) {
		ULONG h;
		cur++;
		h = ((ULONG)cur[0] << 8 | cur[1]) ^
		    ((ULONG)cur[2] << 8 | cur[3]);
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

		/* bytes 0..best-1 already implied equal by the
		   quick-check structure? no -- shipped verifies
		   them first via the cmpml/cmpmb pair */
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
**	Flag long: if 0 -> copy 32 literal longs; else 32 items,
**	LSB first (0 = literal byte, 1 = match token).
**	Match token word 0 -> end; else it is the NEGATED
**	distance (d1 was seeded with moveq #-1 so the movew
**	reload sign-extends: a2 = a1 + (-dist)).
**	len = byte + 4 (byte 0 -> 4 via the unrolled table).
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
	    /* flag long 0 -> 32 literals via 8 longs */
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
