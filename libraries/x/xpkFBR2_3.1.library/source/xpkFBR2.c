/*
**	xpkFBR2.c -- xpkFBR2.library 3.1 "FastByteRun"
**
**	C reconstruction of the shipped binary (xpkFBR2
**	3.1 (3.5.2011) by Niels Froehling).  XPK sublibrary
**	implementing a three-mode byte-run RLE:
**
**	    stream = <tag>{<count><payload>}*
**	    tag:    33 LongByte (4-byte counts), 67 WordByte
**	            (2-byte), 100 ByteByte (1-byte)
**	    count >= 0:  repeat next byte count+1 times
**	    count <  0:  copy 1-count literal bytes
**
**	Mode selected by xsp_Mode against xm_Upto: <=33 is
**	LongByte, <=67 WordByte, everything else ByteByte.
**	There is NO AutoSize pass in 3.1 -- the "Autosizing"
**	mode descriptor exists in the XpkMode list (upto 0)
**	but selecting it just packs LongByte.
**
**	Differences vs V4.1 (the later rewrite):
**	  - all three tags are CORRECT (100/67/33); V4.1
**	    broke ByteByte by emitting selector value 90.
**	  - run thresholds differ (extras >= 6/4/3 mid-
**	    stream, >= 7/5/4 at the tail).
**	  - WordByte/ByteByte scan in "windows" of 32767/127
**	    positions with a consumed-counter (d7) checked
**	    only between emitted items; inputs smaller than
**	    the first window read past the input end and the
**	    scanned garbage is emitted into the stream (the
**	    decoder happily writes it out).  Reproduced.
**	  - LongByte bounds each literal block against
**	    OutBufLen-5; the W/B emitters have no output
**	    bound check at all.
**	  - entry stub returns -1; the four unused vectors
**	    share a separate moveq #0,d0/rts.
**	  - UnpackChunk decodes while src < inbuf+inlen-1,
**	    never writes xsp_OutLen, no output bound check.
**
**	Other shipped quirks kept:
**	  - xi_UnpackMsg == xi_PackMsg ("Running" twice).
**	  - "Autosizing" mode advertises upto 0, packspeed 1,
**	    ratio 0 -- and packs as LongByte.
**	  - descriptor still says "better then" (typo).
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

/* the shared moveq #0,d0/rts at 0x26c serves LVO -24
 * (ExtFunc), -42 (PackFree), -48 (PackReset) and -60
 * (UnpackFree) */
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
/* LongByte encoder (mode <= 33, tag 33, 4-byte counts)		  */
/* ------------------------------------------------------------------ */

/*
**	Whole-input greedy run scanner.  d2 = input budget,
**	d4 = pending literal bytes, d6 = current run length
**	(counting the failed compare iteration mid-stream,
**	minus one at the tail).
**
**	Only bound check in this path: a pending literal
**	block must fit in OutBufLen-5 or the pack fails -17;
**	run items write without any check.  The seed read
**	* a1 at loop top is unconditional and reads past
**	the input end on the absorb path.
*/
static LONG enc_long(struct XpkSubParams *p)
{
    const UBYTE *in = (const UBYTE *)p->xsp_InBuf;
    UBYTE *w = (UBYTE *)p->xsp_OutBuf;
    const UBYTE *a1 = in, *a2 = in;
    LONG a5 = (LONG)p->xsp_OutBufLen - 5;
    LONG d2 = (LONG)p->xsp_InLen;
    LONG d4 = 0, d6 = 0;
    UBYTE d3;

    *w++ = 33;

    for (;;) {
	d3 = *a1;
	d4 += d6;
	d6 = -1;
	for (;;) {
	    d6++;
	    if (*a1++ != d3)
		break;
	    if (--d2 <= 0)
		break;
	}
	a1--;

	if (d2 > 0) {
	    if (d6 < 6)
		continue;		/* short run: absorb   */
	} else {
	    if (d6 < 6)
		d4++;			/* seed becomes literal*/
	    else
		d6++;			/* tail fixup	   */
	}

	/* emit the pending literal block */
	if (d4) {
	    LONG n = d4, c;
	    if (n > a5)
		return -17;
	    c = 1 - n;			/* -(d4-1): neg=literal*/
	    *w++ = (UBYTE)(c >> 24); *w++ = (UBYTE)(c >> 16);
	    *w++ = (UBYTE)(c >> 8);  *w++ = (UBYTE)c;
	    do {
		*w++ = *a2++;
	    } while (--n > 0);
	    d4 = 0;
	}

	/* emit the run; d6 resets to 0 after the count word
	 * (0x2f6 in the original) so the loop-top d4 += d6
	 * fold adds nothing */
	a2 += d6;
	d6--;
	if (d6 < 0)
	    break;			/* fin		   */
	*w++ = (UBYTE)(d6 >> 24); *w++ = (UBYTE)(d6 >> 16);
	*w++ = (UBYTE)(d6 >> 8);  *w++ = (UBYTE)d6;
	d6 = 0;
	*w++ = d3;

	if (d2 <= 0)
	    break;			/* fin		   */
    }

    /* fin: OutLen = written-1 checked <= 0 -> -17 */
    {
	LONG outlen = (w - (UBYTE *)p->xsp_OutBuf) - 1;
	if (outlen <= 0)
	    return -17;
	p->xsp_OutLen = (ULONG)(outlen + 1);
	return 0;
    }
}

/* ------------------------------------------------------------------ */
/* WordByte / ByteByte encoders (windows of 32767 / 127)		  */
/* ------------------------------------------------------------------ */

/*
**	Shared register machine for the 2- and 1-byte count
**	paths.  The scan runs inside a "window" budget (d2)
**	decremented once per scanned position; a consumed
**	counter (d7) decides when the window is refilled:
**
**	    while d7 < a5:  window = 32767 (or 127)
**	    else:           window = a5+win-d7  (~remaining)
**
**	with a5 = InLen-1-win.  For inputs smaller than one
**	window (a5 < 0) the very first pass already scans
**	win bytes -- reading past the input end -- and the
**	garbage is emitted before the exit check can fire.
**	No output bound check anywhere in these paths.
**
**	win:   32767 (WordByte) or 127 (ByteByte)
**	minr:  4 (WordByte) or 3 (ByteByte) extras mid-stream
**	cs:    2 or 1 (count field width)
**	tag:   67 or 100
*/
static LONG enc_win(struct XpkSubParams *p, UBYTE tag, LONG minr,
		    LONG win, int cs)
{
    const UBYTE *in = (const UBYTE *)p->xsp_InBuf;
    UBYTE *w = (UBYTE *)p->xsp_OutBuf;
    const UBYTE *a1 = in, *a2 = in;
    LONG a5 = ((LONG)p->xsp_InLen - 1) - win;
    LONG d7 = 0, d2 = win, d4 = 0, d6 = 0;
    UBYTE d3;

#define EMITCNT(v) do {						\
    LONG _v = (LONG)(v);					\
    if (cs == 2)						\
	*w++ = (UBYTE)(_v >> 8);				\
    *w++ = (UBYTE)_v;						\
} while (0)

    *w++ = tag;

    for (;;) {
	/* seed + scan one item */
	for (;;) {
	    d3 = *a1;
	    d4 += d6;
	    d6 = -1;
	    for (;;) {
		d6++;
		if (*a1++ != d3)
		    break;		/* dbne exit: mismatch  */
		if (--d2 < 0)
		    break;		/* window exhausted     */
	    }
	    a1--;
	    if (d2 >= 0) {
		if (d6 < minr)
		    continue;		/* absorb, next seed    */
		break;			/* qualifying run: emit */
	    }
	    /* window exhausted mid-item: force emit */
	    if (d6 < minr)
		d4++;
	    else
		d6++;
	    break;
	}

	/* literal block: no bound check (d4==0 tested as
	 * word in the WordByte path, long in ByteByte) */
	if (cs == 2 ? (SHORT)d4 != 0 : d4 != 0) {
	    LONG n = d4;
	    d7 += n;
	    EMITCNT(-(n - 1));
	    do {
		*w++ = *a2++;
	    } while (--n > 0);
	    d4 = 0;
	}

	/* run item */
	a2 += (SHORT)d6;		/* lea a2@(0,d6:w)   */
	d7 += d6;
	d6--;
	if (d6 >= 0) {
	    EMITCNT(d6);
	    *w++ = d3;
	}

	if (d2 < 0)
	    a1++;			/* unread-byte fixup   */
	d6 = 0;
	if (d7 < a5) {
	    d2 = win;			/* fresh window	     */
	    continue;
	}
	d2 = a5 + win - d7;		/* remaining	     */
	if (d2 > 0)
	    continue;
	break;
    }

    {
	LONG outlen = (w - (UBYTE *)p->xsp_OutBuf) - 1;
	if (outlen <= 0)
	    return -17;
	p->xsp_OutLen = (ULONG)(outlen + 1);
	return 0;
    }
#undef EMITCNT
}

/* ------------------------------------------------------------------ */
/* vectors								  */
/* ------------------------------------------------------------------ */

/*
**	XpksPackChunk (LVO -36)
**
**	  mode <= 33:  LongByte, tag 33,  4-byte counts
**	  mode <= 67:  WordByte, tag 67,  2-byte counts
**	  else:	     ByteByte, tag 100, 1-byte counts
**
**	The shipped dispatch uses cmpb -- only the LOW BYTE
**	of xsp_Mode is tested, so e.g. mode 0x121 selects
**	LongByte.  Unlike V4.1 every emitted tag is accepted
**	by this library's own decoder -- but the "Autosizing"
**	mode (upto 0) still silently packs LongByte.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct FbrBase *base __asm("a6"))
{
    UBYTE mode = (UBYTE)p->xsp_Mode;	/* cmpb dispatch    */

    if (mode <= 33)
	return enc_long(p);
    if (mode <= 67)
	return enc_win(p, 67, 4, 32767, 2);
    return enc_win(p, 100, 3, 127, 1);
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Tag dispatch + count decoder: 100 -> 1-byte, 67 ->
**	2-byte, 33 -> 4-byte signed counts, else -12.
**	Positive counts repeat the next byte count+1 times;
**	negative counts copy 1-count literal bytes.
**
**	The loop guard is src < inbuf+inlen-1 -- a count
**	field landing on the final byte is never read.
**	No OutLen write, no output bound check.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct FbrBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *end = src + p->xsp_InLen - 1;
    UBYTE *w = (UBYTE *)p->xsp_OutBuf;
    int tag = *src++;

    if (tag == 100) {
	while (src < end) {
	    BYTE c = (BYTE)*src++;
	    if (c < 0) {
		ULONG n = 1 - (ULONG)c;
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
	while (src < end) {
	    SHORT c = (SHORT)((src[0] << 8) | src[1]);
	    src += 2;
	    if (c < 0) {
		ULONG n = 1 - (ULONG)c;
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
	while (src < end) {
	    LONG c = (LONG)(((ULONG)src[0] << 24) | (src[1] << 16) |
			    (src[2] << 8) | src[3]);
	    src += 4;
	    if (c < 0) {
		ULONG n = 1 - (ULONG)c;
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
