/*
**	xpkRLEN.c -- xpkRLEN.library V1.5 (1 Oct 2013) by Urban Dominik Muller
**
**	C reconstruction of the shipped binary
**	($VER: xpkRLEN V1.5 (1 Oct 2013) by Urban Dominik Muller).
**
**	RLEN is a PackBits-style chunk packer.  Compressed stream:
**	    <code><lit bytes>	 1 <= code <= 127	 literal run
**	    <code><byte>	 -127 <= code <= -1	 repeat run
**	    0x00					 terminator
**	The encoder emits a repeat run whenever the next byte equals
**	the two bytes just seen; otherwise it gathers literal bytes
**	until a run start or the 125/126-byte lookahead budget runs
**	out.  It returns XPKERR_EXPANSION (-17) when the output would
**	not be smaller than the input.
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

struct XpkSubBase		/* InitTable dataSize = 0x26		   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node (34 b.)  */
    BPTR  xsb_SegList;		/* 0x22 seglist, stored by LibInit	   */
};

/* XpkInfo/XpkMode descriptor blocks (xpkRLEN_lib.s, code hunk) */
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

struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
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

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->xsb_SegList;
    __Remove(sys, &base->xsb_Lib.lib_Node);
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

/* XpksPackerInfo (LVO -30): hand xpkmaster the descriptor block */
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/*
**	XpksPackChunk (LVO -36)
**
**	Encoder, faithful to the shipped routine.  State:
**	  src = a1, lit = a5, out = a3, srcend = a2, dstlim = a4 = out+inlen,
**	  budget = d2, d0/d1 = lookahead bytes.
**
**	The original reads up to the lookahead budget past the end of
**	the input buffer while scanning; the emitted token lengths are
**	always clamped against srcend, so this version stops reading at
**	srcend (byte-identical output, no out-of-bounds read).
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    UBYTE *src    = (UBYTE *)p->xsp_InBuf;
    UBYTE *out    = (UBYTE *)p->xsp_OutBuf;
    UBYTE *dst    = out;
    UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *dstlim = dst + p->xsp_InLen;	/* output bound: inlen bytes */
    UBYTE *lit;
    LONG   budget;
    UBYTE  d0, d1;

    for (;;) {				/* LAB_0017: next token */
	lit = src;
	budget = 124;
	d1 = *src++;
	d0 = *src++;
	if (d1 == d0)
	    goto run;

	for (;;) {
	    /* LAB_0018 */
	    if (src >= srcend)
		goto emitlit;
	    d1 = *src++;
	    if (d0 == d1) {
		if (d1 == *src)
		    goto litback;	/* three equal -> literal done */
		if (--budget < 0)
		    goto emitlit;
	    } else if (--budget < 0) {
		goto emitlit;
	    }
	    /* LAB_0019 */
	    if (src >= srcend)
		goto emitlit;
	    d0 = *src++;
	    if (d1 == d0) {
		if (d0 == *src)
		    goto litback;
		if (--budget < 0)
		    goto emitlit;
	    } else if (--budget < 0) {
		goto emitlit;
	    }
	}

    litback:				/* LAB_001A */
	src -= 2;

    emitlit:				/* LAB_001B */
	{
	    ULONG litlen = src - lit;

	    /* the original fails when out + 1 + litlen >= dstlim (bcc):
	     * one byte of slack is always kept for the terminator */
	    if (out + litlen + 1 >= dstlim)
		return -17;		/* XPKERR_EXPANSION */
	    if (src >= srcend) {		/* LAB_001D: final literal */
		litlen = srcend - lit;
		if (litlen == 0)
		    goto done;
		*out++ = (UBYTE)litlen;
		while (litlen--)
		    *out++ = *lit++;
		goto done;
	    }
	    *out++ = (UBYTE)litlen;	/* literal code byte = length */
	    while (litlen--)
		*out++ = *lit++;
	}
	continue;

    run:				/* LAB_0014 */
	for (;;) {
	    if (src >= srcend)
		break;
	    d0 = *src++;
	    if (d0 != d1) {
		src--;			/* undo consume of mismatch */
		break;
	    }
	    if (--budget < 0)		/* budget exhausted on match */
		break;
	}

	if (out >= dstlim)
	    return -17;			/* XPKERR_EXPANSION */
	if (src < srcend) {			/* LAB_0016 */
	    UBYTE len = (UBYTE)(src - lit);
	    *out++ = (UBYTE)-len;		/* run code = -length */
	    *out++ = d1;
	    continue;
	}
	{					/* run reached srcend */
	    UBYTE len = (UBYTE)(srcend - lit);
	    if (len == 0)
		goto done;
	    *out++ = (UBYTE)-len;
	    *out++ = d1;
	    goto done;
	}
    }

done:					/* LAB_001F */
    *out++ = 0;				/* stream terminator */
    p->xsp_OutLen = out - dst;
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

    for (;;) {
	code = (BYTE)*in++;
	if (code == 0)
	    break;
	if (code < 0) {
	    UBYTE v = *in++;
	    UBYTE n = (UBYTE)-code;
	    while (n--)
		*out++ = v;
	} else {
	    UBYTE n = (UBYTE)code;
	    while (n--)
		*out++ = *in++;
	}
    }

    return 0;
}
