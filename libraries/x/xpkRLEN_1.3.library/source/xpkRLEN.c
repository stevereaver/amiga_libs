/*
**	xpkRLEN.c -- xpkRLEN.library v1.3 (01.04.1997)
**	by Urban Dominik Muller
**
**	C reconstruction of the shipped binary
**	("xpkRLEN 1.3 (01.04.1997)" -- no $VER: tag).
**
**	RLEN is a PackBits-style chunk packer.  Compressed stream:
**	    <code><lit bytes>	 1 <= code <= 127	 literal run
**	    <code><byte>	 -127 <= code <= -1	 repeat run
**	    0x00					 terminator
**
**	The encoder advances one input byte at a time and starts a
**	repeat run whenever the next three bytes are equal; it emits
**	a literal when a run starts, when the literal hits 127
**	bytes, or when the input ends.  It returns XPKERR_EXPANSION
**	(-17) when out + litlen + 4 reaches OutBuf + OutBufLen.
**
**	Differences vs. v1.5: output bound is OutBufLen (not InLen),
**	and the literal budget is a hard 127-byte cap rather than a
**	125/126 lookahead budget.
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

struct XpkSubBase		/* InitTable dataSize = 0x22 (bare lib) */
{
    struct Library xsb_Lib;	/* 0x00 standard library node (34 b.)  */
};

/* seglist slot in code space (xpkRLEN_lib.s): the 0x22-byte base
 * has no room for it; LibInit stores it, LibExpunge reads it. */
extern BPTR segslot;

/* XpkInfo/XpkMode descriptor blocks (xpkRLEN_lib.s, data hunk) */
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

/* LibInit: the original also bsr's a user hook (a moveq#0/rts
 * stub) twice -- once to init, once to "clean up" on the dead
 * failure path.  Both are no-ops, so the net effect is just
 * storing the seglist and returning the base. */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    segslot = seglist;

    return (struct Library *)base;
}

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;

    return (struct Library *)base;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = segslot;
    __Remove(sys, &base->xsb_Lib.lib_Node);
    /* the original bsr's the same no-op user hook here */
    __FreeMem(sys, (UBYTE *)base - base->xsb_Lib.lib_NegSize,
	      (ULONG)base->xsb_Lib.lib_NegSize + base->xsb_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct XpkSubBase *base __asm("a6"))
{
    if (--base->xsb_Lib.lib_OpenCnt == 0) {
	if (base->xsb_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }

    return 0;
}

/* LibNull (LVO -24 reserved, and the unimplemented sublib slots) */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/* XpksPackerInfo (LVO -30): hand xpkmaster the descriptor block
 * (absolute lea into the data hunk in the original). */
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/*
**	XpksPackChunk (LVO -36)
**
**	Encoder, faithful to the shipped routine.  Registers in the
**	original: src = a5, lit = a4, out = a2, srcend = a3,
**	dstlim = sp@(32) = OutBuf + OutBufLen.
**
**	The original reads src[0..2] at the top of every iteration
**	with no in-bounds check, so the last two input bytes are
**	always followed by out-of-bounds reads (and an all-equal
**	over-read can even flip a tail literal into a spurious run).
**	This version reproduces the same data flow; the emitted
**	stream is identical for inputs where the OOB bytes differ.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    UBYTE *src    = (UBYTE *)p->xsp_InBuf;
    UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *out    = (UBYTE *)p->xsp_OutBuf;
    UBYTE *dstlim = out + p->xsp_OutBufLen;
    UBYTE *lit    = src;
    LONG   litlen, run;

    for (;;) {
	/* run flag: src[0]==src[1]==src[2] -- read unconditionally
	 * (OOB near the buffer end, as shipped) */
	run = (src[0] == src[1] && src[1] == src[2]);
	litlen = src - lit;

	/* capacity check, evaluated every iteration: emit needs
	 * litlen + 4 bytes free (bcc: out+litlen+4 < dstlim) */
	if (out + litlen + 4 >= dstlim)
	    return -17;			/* XPKERR_EXPANSION */

	if (run || litlen == 127 || src == srcend) {
	    if (litlen) {		/* emit literal token */
		*out++ = (UBYTE)litlen;
		while (litlen--)
		    *out++ = *lit++;
	    }
	    if (src == srcend) {
		*out++ = 0;		/* stream terminator */
		break;
	    }
	    lit = src;
	}
	if (!run) {
	    src++;				/* literal scan advance */
	    continue;
	}

	/* >=3 equal bytes: extend while the next byte equals the
	 * previous, bounded by srcend and the 127-byte code max */
	run = 3;
	while (src + run < srcend &&
	       src[run - 1] == src[run] && run < 127)
	    run++;
	out[0] = (UBYTE)-run;			/* run code = -length */
	out[1] = src[0];
	out += 2;
	src += run;
	lit = src;
    }

    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Decoder: positive code copies <code> literal bytes, negative
**	code repeats the next byte <-code> times, a 0 code ends the
**	stream.  OutLen is an input here and is not written back.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    BYTE   code;
    LONG   n;

    for (;;) {
	code = (BYTE)*in++;
	if (code == 0)
	    break;
	if (code > 0) {
	    n = code;
	    while (n--)
		*out++ = *in++;
	} else {
	    UBYTE v = *in++;
	    n = -code;
	    while (n--)
		*out++ = v;
	}
    }

    return 0;
}
