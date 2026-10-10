/*
**	xpkRLEN.c -- xpkRLEN.library 1.4 (1.12.2010)
**
**	C reconstruction of the shipped binary
**	("xpkRLEN 1.4 (1.12.2010)", no $VER cookie).
**
**	RLEN is a PackBits-style chunk packer.  Compressed stream:
**	    <code><lit bytes>	 1 <= code <= 127	 literal run
**	    <code><byte>	 -127 <= code <= -1	 repeat run
**	    0x00					 terminator
**
**	This V1.4 encoder is a different (earlier) implementation than
**	the V1.5 rewrite: it scans forward tracking the pending literal
**	length, detects runs of three equal bytes, caps literals at 127
**	and repeat runs at 127, and bounds the output against
**	xsp_OutBufLen (not the input length).  XPKERR_EXPANSION (-17) is
**	returned when the output buffer would overflow.
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

struct XpkSubBase		/* InitTable dataSize = 0x2a		   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node (34 b.)  */
    BPTR  xsb_SegList;		/* 0x22 seglist, stored by LibInit	   */
    ULONG xsb_Unused;		/* 0x26 reserved by dataSize, untouched  */
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

/* XpksPackerInfo (LVO -30): hand xpkmaster the descriptor block.
** (The original computes the address by a PC-relative LEA; the
** stored "info pointer" slot at base+0x26 is never initialised
** or read -- LibInit only stores the seglist.) */
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/*
**	XpksPackChunk (LVO -36)
**
**	V1.4 encoder, faithful to the shipped routine:
**	  src = a1, lit = a4, out = a5, srcend = a3 = inbuf+inlen,
**	  outlim = a6 = outbuf+outbuflen, runlen = d2, pend = d6.
**
**	Reads src[1] and src[2] unconditionally each pass, so the last
**	two input bytes are sampled past the buffer end (as shipped).
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    UBYTE *src     = (UBYTE *)p->xsp_InBuf;
    UBYTE *out     = (UBYTE *)p->xsp_OutBuf;
    UBYTE *dst     = out;
    UBYTE *srcend  = src + p->xsp_InLen;
    UBYTE *outlim  = out + p->xsp_OutBufLen;
    UBYTE *lit     = src;
    ULONG  pend, runlen;

    for (;;) {				/* LAB_0023 */
	runlen = 0;
	if (src[0] == src[1] && src[1] == src[2])
	    runlen = 2;			/* three equal bytes ahead */

	pend = src - lit;
	if (out + 4 + pend > outlim)	/* literal + token must fit */
	    return -17;			/* XPKERR_EXPANSION */

	if (runlen == 0) {		/* LAB_0025 */
	    if (pend != 0x7f && src != srcend) {
		src++;			/* LAB_002A: extend literal */
		continue;
	    }
	}

	if (pend) {			/* LAB_0026/0027: flush literals */
	    ULONG n = pend;
	    *out++ = (UBYTE)pend;
	    while (n--)
		*out++ = *lit++;
	}

	if (src == srcend)		/* LAB_0029 */
	    break;			/* -> LAB_002D */
	lit = src;
	if (runlen == 0) {		/* LAB_002A */
	    src++;
	    continue;
	}

	/* LAB_002B: extend the repeat run (max 127 bytes) */
	for (;;) {
	    UBYTE *probe;
	    runlen++;
	    probe = src + runlen;
	    if (probe >= srcend)
		break;
	    if (*probe != *(probe - 1))
		break;
	    if ((BYTE)runlen >= 0x7f)
		break;
	}

	/* LAB_002C: emit repeat run */
	lit += runlen;
	*out++ = (UBYTE)(-(WORD)runlen);	/* code = -length */
	*out++ = src[0];			/* repeated byte */
	src = lit;
    }

    /* LAB_002D */
    *out++ = 0;				/* stream terminator */
    p->xsp_OutLen = out - dst;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Decoder: positive code copies <code> literal bytes, negative
**	code repeats the next byte <-code> times (code 0x80 writes
**	nothing), a 0 code ends the stream.  OutLen is an input and
**	is left untouched.
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
	    BYTE  n = -code;		/* -128 stays negative: emits 0 */
	    while (n > 0) {
		*out++ = v;
		n--;
	    }
	} else {
	    BYTE n = code;
	    while (n > 0) {
		*out++ = *in++;
		n--;
	    }
	}
    }

    return 0;
}
