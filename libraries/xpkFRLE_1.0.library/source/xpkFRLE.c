/*
**	xpkFRLE.c -- xpkFRLE.library V1.0 "Fast Run Length Encoder"
**
**	C reconstruction of the shipped binary
**	(idstring "xpkFRLE.library 1.0 (31-Jan-93)", RT_IDSTRING points
**	past the "$VER: " cookie prefix).
**
**	FRLE is an XPK chunk packer using an XOR-obfuscated ByteRun
**	variant ("cache-optimized RLE").  Compressed stream:
**	    <hdr><byte>          repeat run:  hdr = (n-2) ^ 0x9f, n <= 129
**	    <hdr><lit bytes>     literal run: hdr = (len-1) ^ 0x1f, len <= 128
**	no terminator; the decoder stops when the input is exhausted.
**	The XOR headers keep bit7 as the repeat flag and scatter the
**	length bits, which the vendor billed as "cache-optimized".
**
**	V1.0 is the original implementation (later rebuilt as 1.1/1.2).
**	The literal scanner is a four-phase sliding-pair state machine
**	with a 32-count loop budget whose worst case lands exactly on
**	128 emitted bytes; the run scanner is a 15+7*16 unrolled
**	compare block that counts at most 127 matching bytes after the
**	initial pair, capping runs at 129 -- both at the format max.
**
**	Encoder quirks of the original (see okf/findings/):
**	  - a run needs only 2 equal bytes at a segment start but a
**	    triple (3 equal bytes) inside a literal stretch;
**	  - all scanners read past the input end (the run block up to
**	    ~127 bytes, the literal machine up to ~126) and rely on
**	    emit-time clamping -- the reconstruction bounds reads;
**	  - the literal-capacity check uses the unclamped scanned
**	    length (possibly past the input end);
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
**	literal stretch is scanned by a four-phase sliding-pair
**	machine looking for three consecutive equal bytes; the
**	literal ends three bytes before a found triple.  The machine
**	has a 32-count budget whose worst case emits exactly 128
**	literal bytes (header (len-1)^0x1f + data).
**
**	Output is bounded by xsp_OutBuf + xsp_OutBufLen.
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

    for (;;) {
	const UBYTE *lit = src;
	const UBYTE *a1;
	ULONG n;
	UBYTE d0 = 0, d1 = 0, v = 0;
	LONG budget;
	LONG cnt;

	/* head pair check: two equal bytes at a segment start
	** begin a repeat run (the original reads unconditionally,
	** possibly past srcend). */
	if (src + 1 < srcend && src[0] == src[1]) {
	    v = *src;
	    src += 2;
	    /* unrolled compare block: 15 + 7*16 = 127 more bytes */
	    cnt = 127;
	    while (cnt-- && src < srcend && *src == v)
		src++;
	    n = src - lit;
	    if (out >= dstlim)		/* original checks 1 byte */
		return -17;		/* XPKERR_EXPANSION */
	    if (src < srcend) {
		*out++ = (UBYTE)((n - 2) ^ 0x9f);
		*out++ = v;
		continue;
	    }
	    n = srcend - lit;
	    if (!n)
		break;
	    *out++ = (UBYTE)((n - 2) ^ 0x9f);
	    *out++ = v;
	    break;
	}

	src += 2;			/* two head bytes consumed */
	a1 = src;
	if (a1 >= srcend)
	    goto emit;		/* tail: a1[-1] would read OOB */

	/* literal scanner: four-phase sliding-pair machine.
	** d0/d1 hold the current byte window; each phase reads one
	** byte and checks it against the previous.  An equal pair
	** enters a confirm path (P1..P4) which reads a third byte:
	** three equal bytes end the literal three bytes back.
	** Budget d3 counts down from 31 once per machine cycle. */
	budget = 31;
	d0 = a1[-1];
	goto L4;
	for (;;) {
	L2: if (a1 >= srcend)
		goto emit;
	    d1 = *a1++;
	    if (d0 == d1)
		goto P1;
	L3: if (a1 >= srcend)
		goto emit;
	    d0 = *a1++;
	    if (d1 == d0)
		goto P2;
	L4: if (a1 >= srcend)
		goto emit;
	    d1 = *a1++;
	    if (d0 == d1)
		goto P3;
	L1: if (a1 >= srcend)
		goto emit;
	    d0 = *a1++;
	    if (d1 == d0)
		goto P4;
	    if (--budget < 0)
		goto emit;
	    continue;
	P1: if (a1 >= srcend)
		goto emit;
	    d0 = *a1++;
	    if (d1 == d0) {
		a1 -= 3;
		goto emit;
	    }
	    goto L4;
	P2: if (a1 >= srcend)
		goto emit;
	    d1 = *a1++;
	    if (d0 == d1) {
		a1 -= 3;
		goto emit;
	    }
	    goto L1;
	P3: if (a1 >= srcend)
		goto emit;
	    d0 = *a1++;
	    if (d1 == d0) {
		a1 -= 3;
		goto emit;
	    }
	    if (--budget < 0)
		goto emit;
	    goto L2;
	P4: if (a1 >= srcend)
		goto emit;
	    d1 = *a1++;
	    if (d0 == d1) {
		a1 -= 3;
		goto emit;
	    }
	    if (--budget < 0) {
		a1 -= 1;
		goto emit;
	    }
	    goto L3;
	}

    emit:
	/* the capacity check uses the unclamped scanned length */
	n = a1 - lit;
	if (out + 1 + n >= dstlim)
	    return -17;			/* XPKERR_EXPANSION */
	if (a1 >= srcend) {
	    n = srcend - lit;
	    if (!n)
		break;
	    *out++ = (UBYTE)((n - 1) ^ 0x1f);
	    while (n--)
		*out++ = *lit++;
	    break;
	}
	*out++ = (UBYTE)((n - 1) ^ 0x1f);
	while (n--)
	    *out++ = *lit++;
	src = a1;
    }

    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Decoder: reads headers until the input is exhausted (the
**	original dispatches through a computed-goto into unrolled
**	store blocks, which is semantically identical to this loop).
**	hdr bit7 set   -> repeat:  n = 33 - (hdr&0x1f) + 32*((hdr&0x7f)>>5)
**	hdr bit7 clear -> literal: n = 32 - (hdr&0x1f) + 32*(hdr>>5)
**	xsp_OutLen is written (unlike the 1.2 rebuild, which dropped it).
**	No output bounds checking is performed; corrupt or truncated
**	streams read/write past the buffers.
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
	    n = 33 - (h & 0x1f) + 32 * ((h & 0x7f) >> 5);
	    v = *src++;
	    while (n--)
		*out++ = v;
	} else {
	    n = 32 - (h & 0x1f) + 32 * (h >> 5);
	    while (n--)
		*out++ = *src++;
	}
    }

    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}
