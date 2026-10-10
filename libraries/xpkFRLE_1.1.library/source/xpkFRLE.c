/*
**	xpkFRLE.c -- xpkFRLE.library V1.1 "Fast Run Length Encoder"
**
**	C reconstruction of the shipped binary
**	(idstring "xpkFRLE v1.1", no $VER: cookie).
**
**	FRLE is an XPK chunk packer using an XOR-obfuscated ByteRun
**	variant ("cache-optimized RLE").  Compressed stream:
**	    <hdr><byte>          repeat run:  hdr = (n-2) ^ 0x9f, n >= 2
**	    <hdr><lit bytes>     literal run: hdr = (len-1) ^ 0x1f, len <= 128
**	no terminator; the decoder stops when the input is exhausted.
**	The XOR headers keep bit7 as the repeat flag and scatter the
**	length bits, which the vendor billed as "cache-optimized".
**
**	Encoder quirks of the original (see okf/findings/):
**	  - a run needs only 2 equal bytes at a segment start but a
**	    triple (3 equal bytes) inside a literal stretch;
**	  - the literal scanner reads past the input end (bounded
**	    only by its ~4-byte-group budget) and relies on emit-time
**	    clamping -- the reconstruction bounds reads instead;
**	  - the original permits literals of up to ~130 bytes which
**	    overflow the header XOR (bit7 set -> decoded as repeat);
**	    the reconstruction caps literals at 128, the format max;
**	  - the repeat-emit path checks only one byte of output
**	    headroom before writing two.
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

/* XpkInfo/XpkMode descriptor blocks (xpkFRLE_lib.s, code hunk) */
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
**	At each segment start a pair of equal bytes begins a repeat
**	run (n <= 129; header (n-2)^0x9f + the byte).  Otherwise a
**	literal stretch is gathered until a run of three equal bytes
**	is found (the literal ends before it) or the chunk reaches
**	128 bytes (the original's looser budget allows ~130 and
**	overflows the header -- see okf/findings/).  Literal header:
**	(len-1)^0x1f followed by the raw bytes.
**
**	Returns 0, or -17 (XPKERR_EXPANSION) when the output buffer
**	is too small.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src    = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *out    = (UBYTE *)p->xsp_OutBuf;
    UBYTE *dstlim = out + p->xsp_OutBufLen;

    while (src < srcend) {
	const UBYTE *lit = src;
	UBYTE b = *src++;
	ULONG n;

	if (src < srcend && *src == b) {
	    /* repeat run of >= 2 at a segment start, capped at 129 */
	    n = 2;
	    src++;
	    while (n < 129 && src < srcend && *src == b) {
		n++;
		src++;
	    }
	    if (out >= dstlim)		/* original checks 1 byte */
		return -17;		/* XPKERR_EXPANSION */
	    *out++ = (UBYTE)((n - 2) ^ 0x9f);
	    *out++ = b;
	    continue;
	}

	/* literal: bytes until a 3-run begins, capped at 128 */
	while (src - lit < 128) {
	    if (src >= srcend)
		break;
	    if (src[0] == src[-1] && src + 1 < srcend &&
		src[1] == src[0]) {
		src--;			/* end before the run start */
		break;
	    }
	    src++;
	}

	n = src - lit;
	if (out + 1 + n > dstlim)
	    return -17;			/* XPKERR_EXPANSION */
	*out++ = (UBYTE)((n - 1) ^ 0x1f);
	while (n--)
	    *out++ = *lit++;
    }

    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Decoder: reads headers until the input is exhausted.
**	hdr bit7 set   -> repeat:  n = (hdr&0x7f) - 2*(hdr&0x1f) + 0x21
**	hdr bit7 clear -> literal: n =  hdr      - 2*(hdr&0x1f) + 0x20
**	The original performs no output bounds checking; corrupt or
**	truncated streams read/write past the buffers.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src    = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;

    while (src < srcend) {
	UBYTE h = *src++;
	ULONG n;

	if (h & 0x80) {
	    UBYTE v;
	    n = (h & 0x7f) - 2 * (h & 0x1f) + 0x21;
	    v = *src++;
	    while (n--)
		*out++ = v;
	} else {
	    n = h - 2 * (h & 0x1f) + 0x20;
	    while (n--)
		*out++ = *src++;
	}
    }

    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}
