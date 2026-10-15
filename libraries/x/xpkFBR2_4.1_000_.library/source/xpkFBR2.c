/*
**	xpkFBR2.c -- xpkFBR2.library V4.1 "FastBytesRunner"
**
**	C reconstruction of the shipped binary ($VER: xpkFBR2
**	V4.1 (1 Oct 2013) by Niels Froehling).  XPK sublibrary
**	implementing a multi-mode byte-run RLE:
**
**	    stream = <tag>{<count><payload>}*
**	    tag:    33 LongByte (4-byte counts), 67 WordByte
**	            (2-byte), 90 ByteByte (1-byte)
**	    count >= 0:  repeat next byte count+1 times
**	    count <  0:  copy 1-count literal bytes
**	    count = 0:   1-byte run (== literal-1)
**
**	Mode selected by xsp_Mode against the xm_Upto values
**	33/67/90/100; >90 runs AutoSize: all three encoders are
**	tried into the same output buffer and the smallest is
**	kept (LongByte/WordByte winners are re-encoded for
**	real; a ByteByte winner is already in place).
**
**	Shipped-binary quirks kept/documented (see okf/findings/):
**	  - THE BIG ONE: ByteByte mode emits stream tag 90 but
**	    the decoder only accepts 100/67/33 -- a ByteByte
**	    stream (and any AutoSize run where ByteByte wins)
**	    is rejected by this library's own unpacker (-12).
**	    V3.1 emitted tag 100 correctly; the V4.1 rewrite
**	    switched the encoder to the mode-selector values
**	    (33/67/90) while the decoder kept the old tag map.
**	    xi_DefMode = 90, so the DEFAULT mode produces
**	    undecodable output.  Reproduced faithfully.
**	  - UnpackChunk never writes xsp_OutLen and performs no
**	    output bound check at all (corrupt input overruns
**	    the destination).
**	  - the encoder's -17 expansion guard is checked only
**	    after data-byte writes; the count-field emitters
**	    write without any bound check;
**	  - the run test near the input tail requires 3 equal
**	    bytes (d2 = inend-2) but the literal scanner's
**	    cmpmb pair check reads srcend[0] when looking for
**	    the last possible pair (bounded here; identical
**	    output either way);
**	  - xi_UnpackMsg points at "Running" again (same as
**	    xi_PackMsg); xi_LongName still says "FastBytesRunner
**	    V4.0" in the V4.1 binary;
**	  - LibInit stores only the seglist (dataSize 0x26);
**	    LibClose/LibExpunge use the correct DELEXP bit.
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

struct FbrBase			/* InitTable dataSize = 0x26	   */
{
    struct Library fb_Lib;	/* 0x00 standard library node	   */
    BPTR  fb_SegList;		/* 0x22 seglist, stored by LibInit   */
};				/* = 0x26				   */

/* descriptor emitted by xpkFBR2_lib.s */
extern const char xpkinfo[];

/* ------------------------------------------------------------------ */
/* Exec LVO calls (via absolute SysBase at 4.W, as the original does) */
/* ------------------------------------------------------------------ */

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__sys, ___blk, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_blk __asm("a1") = (void *)(___blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile (\
		   "jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* LibInit: store the seglist at base+0x22, return the base. */
struct Library *LibInit(struct FbrBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    base->fb_SegList = seglist;
    return (struct Library *)base;
}

struct Library *LibOpen(struct FbrBase *base __asm("a6"))
{
    base->fb_Lib.lib_OpenCnt++;
    base->fb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

BPTR LibExpunge(struct FbrBase *base __asm("a6"));

BPTR LibExpunge(struct FbrBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->fb_Lib.lib_OpenCnt) {
	base->fb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->fb_SegList;
    __Remove(sys, &base->fb_Lib.lib_Node);
    __FreeMem(sys, (UBYTE *)base - base->fb_Lib.lib_NegSize,
	      (ULONG)base->fb_Lib.lib_NegSize + base->fb_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct FbrBase *base __asm("a6"))
{
    if (--base->fb_Lib.lib_OpenCnt == 0) {
	if (base->fb_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* ExtFunc (LVO -24), PackFree, PackReset, UnpackFree all map
 * to the module entry stub: moveq #0,d0 / rts. */
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

/* ------------------------------------------------------------------ */
/* the shared encoder core						  */
/* ------------------------------------------------------------------ */

/* count emitter widths: 1 = ByteByte, 2 = WordByte, 4 = LongByte */
#define EMITCNT(v) do {						\
    ULONG _v = (ULONG)(v);					\
    if (csize == 4) {						\
	*w++ = (UBYTE)(_v >> 24); *w++ = (UBYTE)(_v >> 16);	\
    }								\
    if (csize >= 2)						\
	*w++ = (UBYTE)(_v >> 8);				\
    *w++ = (UBYTE)_v;						\
} while (0)

/*
**	Shared RLE encoder (original core at 0x1cc).
**
**	tag:    stream tag byte (33/67/90)
**	minrun: minimum run length worth encoding (8/5/3)
**	limit:  max count piece (inlen/0x8000/0x80)
**	csize:  count-field width in bytes (4/2/1)
**
**	Returns 0 with xsp_OutLen set, or -17 when the output
**	cursor reaches dst+inlen (expansion guard; checked
**	after each data-byte write, never on count writes).
*/
static LONG enc(struct XpkSubParams *p, UBYTE tag, ULONG minrun,
		ULONG limit, int csize)
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *end = src + p->xsp_InLen;
    const UBYTE *e2 = end - 2;		/* d2 = a4-2	    */
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    UBYTE *lim = dst + p->xsp_InLen;	/* a2 = out+inlen   */
    const UBYTE *a5 = src;		/* read cursor	    */
    const UBYTE *a6 = src;		/* literal start    */
    UBYTE *w = dst;
    ULONG d3 = 0;			/* pending literals */
    ULONG d5 = 0;			/* scan length	    */
    UBYTE d1;

    *w++ = tag;

    for (;;) {
	if (a5 >= end)
	    goto fin;

	d5 = 0;
	d1 = *a5++;			/* current byte	    */

	if (a5 < e2 && a5[0] == d1 && a5[1] == d1) {
	    /* repeat-run candidate: >= 3 equal bytes */
	    const UBYTE *a0 = a5 + 2;
	    d5 = 3;
	    while (a0 < end && *a0++ == d1)
		d5++;
	    if (d5 >= minrun)
		goto flush;
	    /* short run falls through to the literal scan */
	}

	/* literal scan: count positions until the next
	 * adjacent-equal pair (or input end).  The shipped
	 * cmpmb loop reads one byte past the input when the
	 * pair test reaches the tail; bounded here. */
	d5 = 1;
	{
	    const UBYTE *a0 = a5 + 1;
	    for (;;) {
		if (a0 >= end)
		    break;
		if (*a0 == *a5)
		    break;
		a0++; a5++; d5++;
	    }
	}
	d3 += d5;
	continue;

    flush:
	/* emit pending literals in <=limit pieces, then the run */
	while (d3) {
	    ULONG n = d3 > limit ? limit : d3;
	    LONG cnt;
	    d3 -= n;
	    cnt = 1 - (LONG)n;
	    EMITCNT(cnt);		/* negative = literal */
	    do {
		*w++ = *a6++;
		if (w >= lim)
		    return -17;		/* expansion guard  */
	    } while (++cnt <= 0);
	}
	d3 = 0;
	if (d5 > 0) {
	    a5 += d5 - 1;		/* consume the run    */
	    a6 = a5;			/* new literal start  */
	    while (d5) {
		ULONG n = d5 > limit ? limit : d5;
		d5 -= n;
		EMITCNT(n - 1);		/* positive = run     */
		*w++ = d1;
		if (w >= lim)
		    return -17;		/* expansion guard    */
	    }
	}
	continue;

    fin:
	if (d3) {
	    d5 = 0;
	    goto flush;
	}
	p->xsp_OutLen = w - dst;
	return 0;
    }
}

/*
**	XpksPackChunk (LVO -36)
**
**	Mode dispatch on xsp_Mode (the xm_Upto value):
**	  <=33  LongByte:  tag 33, minrun 8, 4-byte counts
**	  <=67  WordByte:  tag 67, minrun 5, 2-byte counts
**	  <=90  ByteByte:  tag 90, minrun 3, 1-byte counts
**	  >90   AutoSize:  try all three, keep the smallest
**
**	The shipped tag defect is preserved: ByteByte emits 90
**	while the decoder expects 100 for the 1-byte path.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct FbrBase *base __asm("a6"))
{
    ULONG mode = p->xsp_Mode;

    if (mode <= 33)
	return enc(p, 33, 8, p->xsp_InLen, 4);
    if (mode <= 67)
	return enc(p, 67, 5, 0x8000, 2);
    if (mode <= 90)
	return enc(p, 90, 3, 0x80, 1);

    /* AutoSize: try all three into the same buffer */
    {
	ULONG *sub = p->xsp_Sub;
	LONG r;

	sub[0] = sub[1] = sub[2] = 0;
	if (!(r = enc(p, 33, 8, p->xsp_InLen, 4)))
	    sub[0] = p->xsp_OutLen;
	if (!(r = enc(p, 67, 5, 0x8000, 2)))
	    sub[1] = p->xsp_OutLen;
	if (!(r = enc(p, 90, 3, 0x80, 1)))
	    sub[2] = p->xsp_OutLen;

	/* pick the smallest nonzero size; ties prefer the
	 * wider count field (LongByte < WordByte < ByteByte) */
	if (sub[0] && (!sub[1] || sub[0] <= sub[1])) {
	    if (!sub[2] || sub[0] <= sub[2])
		return enc(p, 33, 8, p->xsp_InLen, 4);
	    return 0;			/* ByteByte stays   */
	}
	if (sub[1]) {
	    if (!sub[2] || sub[1] <= sub[2])
		return enc(p, 67, 5, 0x8000, 2);
	    return 0;			/* ByteByte stays   */
	}
	if (sub[2])
	    return 0;			/* ByteByte stays   */
	return -17;
    }
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Tag dispatch + count decoder.  Tags: 100 -> 1-byte,
**	67 -> 2-byte, 33 -> 4-byte signed counts; anything
**	else -> -12.  Positive counts repeat the next byte
**	count+1 times; negative counts copy 1-count literals.
**
**	NOTE: the encoder's ByteByte tag 90 is NOT accepted --
**	the shipped defect is preserved.  The decoder writes
**	no output bound check and never sets xsp_OutLen.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct FbrBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *end = src + p->xsp_InLen;
    UBYTE *w = (UBYTE *)p->xsp_OutBuf;
    int tag = *src++;

    if (tag == 100) {
	/* 1-byte counts */
	while (src < end) {
	    BYTE c = (BYTE)*src++;
	    if (c < 0) {
		ULONG n = 1 - (LONG)c;
		while (n--)
		    *w++ = *src++;
	    } else {
		UBYTE v = *src++;
		ULONG n = (ULONG)c + 1;
		while (n--)
		    *w++ = v;
	    }
	}
    } else if (tag == 67) {
	/* 2-byte counts */
	while (src < end) {
	    SHORT c = (SHORT)((src[0] << 8) | src[1]);
	    src += 2;
	    if (c < 0) {
		ULONG n = 1 - (LONG)c;
		while (n--)
		    *w++ = *src++;
	    } else {
		UBYTE v = *src++;
		ULONG n = (ULONG)c + 1;
		while (n--)
		    *w++ = v;
	    }
	}
    } else if (tag == 33) {
	/* 4-byte counts */
	while (src < end) {
	    LONG c = (LONG)(((ULONG)src[0] << 24) | (src[1] << 16) |
			    (src[2] << 8) | src[3]);
	    src += 4;
	    if (c < 0) {
		ULONG n = 1 - c;
		while (n--)
		    *w++ = *src++;
	    } else {
		UBYTE v = *src++;
		ULONG n = (ULONG)c + 1;
		while (n--)
		    *w++ = v;
	    }
	}
    } else {
	return -12;			/* unknown tag	    */
    }

    return 0;
}
