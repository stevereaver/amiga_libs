/*
**	xpkFRLE.c -- xpkFRLE.library V1.2 "Fast Run Length Encoder V1.2"
**		     (1 Oct 2013) by Jorma Oksanen
**
**	C reconstruction of the shipped binary.
**	Complete V1.2 rewrite of the V1.1 codec -- same stream format:
**	    <hdr><byte>          repeat run:  hdr = (n-2) ^ 0x9f, n <= 129
**	    <hdr><lit bytes>     literal run: hdr = (len-1) ^ 0x1f, len <= 128
**	no terminator; the decoder stops when the input is exhausted.
**
**	V1.2 differences from V1.1 (see okf/findings/):
**	  - the output bound is OutBuf + InLen: xsp_OutBufLen is never
**	    read, and a packed stream may never reach the input size;
**	  - InLen == 0 always returns -17 (XPKERR_EXPANSION) after
**	    reading a few bytes past the input (the scan runs before
**	    any end check); we bound the reads but keep the -17;
**	  - the decoder uses two computed-goto unrolled 32-byte store
**	    loops and NEVER writes xsp_OutLen;
**	  - the literal scanner still reads past the input end during
**	    run detection (bounded by the d2 counters), corrected by
**	    emit-time clamping -- the reconstruction bounds reads;
**	  - entry stub returns 0 (not -1) and doubles as the null
**	    vector/return trampoline (functab offsets are negative);
**	  - PackMsg/UnpackMsg/PackedMsg/UnpackedMsg are NULL, and
**	    MinPkInChunk is 0 (vs 16 in V1.1).
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
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size (UNUSED!) */
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
**	The null vectors (-24/-42/-48/-60) and the module entry all
**	point at the hunk+0 "moveq #0,d0 / rts" stub in the original.
**
**	Segments: a pair of equal bytes at a segment start begins a
**	repeat run (n <= 128 this version; header (n-2)^0x9f + byte).
**	Otherwise a literal stretch is gathered until a run of three
**	equal bytes is found (the literal ends before it) or ~127
**	bytes are scanned; header (len-1)^0x1f + the raw bytes.
**	A one-byte tail emits a 0x1f literal.
**
**	The output bound is OutBuf + InLen (xsp_OutBufLen is never
**	read): packing may never reach the input size, else -17.
**	Returns 0, or -17 (XPKERR_EXPANSION).  InLen == 0 also
**	returns -17 in the original -- after reading OOB; we skip
**	the reads but keep the error.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src    = (const UBYTE *)p->xsp_InBuf;
    const UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *out    = (UBYTE *)p->xsp_OutBuf;
    UBYTE *dstlim = out + p->xsp_InLen;	/* NOT OutBufLen */

    /* shipped: OOB-scan then fails its capacity check -> -17 */
    if (!p->xsp_InLen)
	return -17;

    while (src < srcend) {
	const UBYTE *lit = src;
	ULONG n;

	if (srcend - src >= 2 && src[0] == src[1]) {
	    /* repeat run of >= 2 at a segment start, capped at 128 */
	    UBYTE b = *src;
	    n = 2;
	    src += 2;
	    while (n < 128 && src < srcend && *src == b) {
		n++;
		src++;
	    }
	    if (out >= dstlim)		/* original checks 1 byte */
		return -17;		/* XPKERR_EXPANSION */
	    *out++ = (UBYTE)((n - 2) ^ 0x9f);
	    *out++ = b;
	    continue;
	}

	/* literal: bytes until a 3-equal run begins, cap ~127 */
	n = 0;
	while (n < 127 && src + n + 2 < srcend) {
	    if (src[n] == src[n + 1] && src[n + 1] == src[n + 2])
		break;
	    n++;
	}
	if (src + n + 2 >= srcend) {
	    /* tail literal: the shipped scan OOB-reads to the ~127
	       cap and capacity-checks the INFLATED length, so a
	       literal that reaches the input end almost always
	       fails with -17 (deviation: we model the OOB scan
	       deterministically as running to the cap) */
	    if (out + 1 + 127 >= dstlim)
		return -17;		/* XPKERR_EXPANSION */
	    n = srcend - src;
	} else {
	    if (out + 1 + n >= dstlim)	/* strict < in the original */
		return -17;		/* XPKERR_EXPANSION */
	}
	if (!n)
	    break;
	*out++ = (UBYTE)((n - 1) ^ 0x1f);
	src += n;
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
**	(same counts as V1.1: 33-m+32k and 32-m+32k with m=hdr&31,
**	 k=hdr>>5 -- the header XOR is just an obfuscated split of
**	 the count into "stores skipped" + "32-blocks".)
**
**	The original performs the copies with two computed-goto
**	unrolled 32-byte-store loops, does NOT bounds-check anything
**	and does NOT write xsp_OutLen -- the reconstruction keeps the
**	shipped behaviour.
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

    /* NOTE: the shipped V1.2 unpacker does NOT store xsp_OutLen */
    return 0;
}
