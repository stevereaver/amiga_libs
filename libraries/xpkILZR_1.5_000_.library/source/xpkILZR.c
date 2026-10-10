/*
**	xpkILZR.c -- xpkILZR.library 1.5 "Incremental LZ-Renau"
**
**	C reconstruction of the shipped binary (xpkILZR V1.5
**	(1 Oct 2013) by Jose Reanu).  XPK sublibrary: hash-chain
**	LZSS with a bit stream written MSB-first:
**
**	    stream = <outlen.w>{ token }*
**	    token  = 1 + byte		literal      (9 bits)
**	    token  = 0 + pos(w bits) + (len-3)(4)	match
**	    w      = bit width of the output position,
**	             min 8, grown as output grows
**
**	The match "pos" field is an ABSOLUTE output index
**	(not a distance) -- the decoder copies len bytes
**	from out[pos].
**
**	Workmem (0x18004 bytes incl. 4-byte size prefix) is
**	lazily AllocMem'd into xsp_Sub[0]; layout:
**	    +0x00000  head[0x8000]  word hash heads (positions)
**	    +0x10000  chain[0x8000] word next-links
**	Position 0 reads as "empty" (head init 0) so it can
**	never be a match source.
**
**	Shipped behaviour kept:
**	  - hash seed reads in[0]/in[1] unconditionally
**	    (InLen < 2 reads OOB)
**	  - candidate pre-check reads in[cur+best] and the
**	    cmpm scan reads up to 17 bytes at the tail --
**	    both may run past InLen (values unused)
**	  - output guard: byte written, THEN a6 < out+inlen
**	    tested -- the boundary byte is already stored
**	    when -17 is returned; the final pad byte is not
**	    checked at all
**	  - XpksPackFree frees the block but leaves
**	    xsp_Sub[0] dangling -> a later pack reuses
**	    freed memory (use-after-free)
**	  - UnpackChunk compares the stream's outlen word
**	    against the caller-preset xsp_OutLen (-14),
**	    writes exactly outlen bytes, no bound check,
**	    never writes xsp_OutLen
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

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

struct IlzrBase			/* InitTable dataSize = 0x26	   */
{
    struct Library ib_Lib;	/* 0x00 standard library node	   */
    BPTR  ib_SegList;		/* 0x22 seglist, stored by LibInit   */
};				/* = 0x26				   */

/* descriptor emitted by xpkILZR_lib.s */
extern const char xpkinfo[];

/* ------------------------------------------------------------------ */
/* Exec LVO calls (via absolute SysBase at 4.W, as the original does) */
/* ------------------------------------------------------------------ */

#define SYSBASE	(*(struct ExecBase **)4)

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
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* LibInit: store the seglist at base+0x22, return the base. */
struct Library *LibInit(struct IlzrBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    base->ib_SegList = seglist;
    return (struct Library *)base;
}

struct Library *LibOpen(struct IlzrBase *base __asm("a6"))
{
    base->ib_Lib.lib_OpenCnt++;
    base->ib_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

BPTR LibExpunge(struct IlzrBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->ib_Lib.lib_OpenCnt) {
	base->ib_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->ib_SegList;
    __Remove(sys, &base->ib_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->ib_Lib.lib_NegSize,
	      (ULONG)base->ib_Lib.lib_NegSize + base->ib_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct IlzrBase *base __asm("a6"))
{
    if (--base->ib_Lib.lib_OpenCnt == 0) {
	if (base->ib_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* the entry stub's moveq #0,d0/rts serves LVO -24 (ExtFunc)
 * and -60 (UnpackFree) via a backward word offset */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/* XpksPackerInfo (LVO -30): static descriptor via lea */
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

#define WORKMEM_SIZE	0x18004	/* alloc incl. 4-byte size prefix */
#define HASH_SIZE	0x8000	/* word entries per table	   */

/*
**	XpksPackFree (LVO -42)
**
**	  frees xsp_Sub[0]-4 with the stored size -- and
**	  leaves the dangling pointer in xsp_Sub[0]
**	  (shipped; a following pack reuses freed memory).
*/
LONG XpksPackFree(struct XpkSubParams *p __asm("a0"),
		  struct IlzrBase *base __asm("a6"))
{
    ULONG *blk = (ULONG *)p->xsp_Sub[0];

    if (blk) {
	blk--;				/* movel -(a1),d0   */
	__FreeMem(blk, *blk);
    }
    return 0;
}

/*
**	XpksPackReset (LVO -48)
**
**	  clears the 64KB head[] table: the original fills
**	  downward from workmem+0x10004 to workmem+4 with
**	  movem (315*208+16 = 65536 bytes), leaving the
**	  size prefix and the (uninitialised) chain intact.
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"),
		   struct IlzrBase *base __asm("a6"))
{
    UWORD *head = (UWORD *)p->xsp_Sub[0];
    LONG   i;

    if (!head)
	return 0;
    for (i = 0; i < HASH_SIZE; i++)
	head[i] = 0;
    return 0;
}

/*
**	XpksPackChunk (LVO -36)
**
**	  Register machine decoded from the binary:
**	  a2 scan cursor, a3 input base, a4 chain base,
**	  a5 head base, a6 output cursor, a5?? ->
**	  d3 rolling hash (<<5 ^ b)&0x7fff over in[p..p+2],
**	  d5 [cand:len] best-match pair / item length,
**	  d7 low word remaining (bit19 = width seed 8).
**
**	  deferred insertion: each loop head inserts the
**	  just-consumed span + the new current position
**	  (dbf entered via the dbf itself -> d5 iterations).
**	  remaining < 3 skips hashing and emits literals.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct IlzrBase *base __asm("a6"))
{
    const UBYTE *in = (const UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    UBYTE *w = out;
    UBYTE *cap = out + p->xsp_InLen;	/* a6 < cap guard  */
    const UBYTE *a2;
    UWORD *head, *chn;
    ULONG *blk;
    ULONG hash, acc;
    LONG  rem, plen, nb, pos;
    int   i;

    if (!p->xsp_Sub[0]) {
	blk = (ULONG *)__AllocMem(WORKMEM_SIZE, 0);
	if (!blk)
	    return -7;
	*blk = WORKMEM_SIZE;
	p->xsp_Sub[0] = (ULONG)(blk + 1);
    }
    XpksPackReset(p, base);

    head = (UWORD *)p->xsp_Sub[0];
    chn  = head + HASH_SIZE;

    *w++ = (UBYTE)(p->xsp_InLen >> 8);	/* 16-bit outlen   */
    *w++ = (UBYTE)p->xsp_InLen;

    a2   = in - 1;
    rem  = (LONG)(p->xsp_InLen & 0xffff);
    hash = ((in[0] << 5) ^ in[1]) & 0x7fff;
    plen = 1;
    acc  = 0;
    nb   = 0;

/* append <bits> bits of <tok> MSB-first; per-byte
 * write-then-check against cap (-17) */
#define EMIT(tok, bits) do {					\
    acc = (acc << (bits)) | (ULONG)(tok); nb += (bits);	\
    while (nb >= 8) {						\
	nb -= 8;						\
	*w++ = (UBYTE)(acc >> nb);				\
	if (w >= cap)						\
	    return -17;						\
    }								\
    acc &= (1UL << nb) - 1;					\
} while (0)

    for (;;) {
	LONG best, bpos, cand;

	if (rem < 3) {
	    a2 += plen;			/* tail literals */
	    EMIT(0x100 | a2[0], 9);
	    plen = 1;
	    if (--rem <= 0)
		break;
	    continue;
	}

	/* insert the consumed span + new current pos */
	for (i = plen; i > 0; i--) {
	    a2++;
	    hash = ((hash << 5) ^ a2[2]) & 0x7fff;
	    pos = (LONG)(a2 - in);
	    chn[pos] = head[hash];
	    head[hash] = (UWORD)pos;
	}
	pos = (LONG)(a2 - in);

	best = 2; bpos = 0;
	for (cand = chn[pos]; cand; cand = chn[cand]) {
	    if (a2[best] == in[cand + best]) {	/* precheck */
		LONG l = 0;
		while (l < 18 && in[cand + l] == a2[l])
		    l++;
		if (l > rem)
		    l = rem;
		if (l > best) {
		    best = l; bpos = cand;
		    if (best >= 18)
			goto match;
		}
	    }
	}
	if (best < 3) {
	    EMIT(0x100 | a2[0], 9);		/* literal    */
	    plen = 1;
	} else {
match:;
	    int wdt = 8;
	    while (a2 > in + (1L << wdt))
		wdt++;
	    EMIT(((ULONG)bpos << 4) | (ULONG)(best - 3),
		 5 + wdt);
	    plen = best;
	}
	rem -= plen;
	if (rem <= 0)
	    break;
    }

    /* flush: pending bits shift left into the top of the
     * last byte -- unchecked write like the original    */
    *w++ = (UBYTE)(acc << (8 - nb));
#undef EMIT

    p->xsp_OutLen = (ULONG)(w - out);
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	  reads the outlen word; -14 when it exceeds the
**	  caller-preset xsp_OutLen.  Bit reader mirrors the
**	  original: d3 accumulator shifted in bytes, d4 =
**	  consumed-bit index, peeked fields MSB-first.
**	  Writes exactly outlen bytes; no bound check.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct IlzrBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    UBYTE *w = (UBYTE *)p->xsp_OutBuf;
    UBYTE *outbase = w;
    LONG  rem;
    ULONG acc = 0;
    int   nb = 0, width = 8;
    ULONG wcap;

    rem = (src[0] << 8) | src[1];	/* move.w (a2)+  */
    src += 2;
    if ((ULONG)rem > p->xsp_OutLen)
	return -14;

    wcap = 256;			/* a4 = out + (1<<width) */

    while (rem > 0) {
	ULONG tok;

	while (nb < 9) {		/* refill to 9+ bits  */
	    acc = (acc << 8) | *src++;
	    nb += 8;
	}
	tok = acc >> (nb - 9);		/* peek 9 bits	  */
	if (tok & 0x100) {
	    nb -= 9;
	    acc &= (1UL << nb) - 1;
	    *w++ = (UBYTE)tok;		/* literal	  */
	    rem--;
	    continue;
	}
	/* match: consume flag + peeked bits, need width+4
	 * more bits beyond the flag -> total 5+width    */
	nb -= 9;
	acc &= (1UL << nb) - 1;
	while ((ULONG)(w - outbase) > wcap) {
	    width++;
	    wcap = 1UL << width;
	}
	while (nb < width + 4) {
	    acc = (acc << 8) | *src++;
	    nb += 8;
	}
	{
	    ULONG field = (tok & 0xff) << (width - 4);
	    nb -= width - 4;
	    field |= acc >> nb;
	    acc &= (1UL << nb) - 1;
	    {
		ULONG pos = field >> 4;
		LONG  ln = (field & 15) + 3;
		const UBYTE *s = outbase + pos;
		rem -= ln;
		while (ln--)
		    *w++ = *s++;
	    }
	}
    }
    return 0;
}
