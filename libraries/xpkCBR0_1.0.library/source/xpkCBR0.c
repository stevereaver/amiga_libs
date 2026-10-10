/*
**	xpkCBR0.c -- xpkCBR0.library V1.0 "Cmp Byte Run 0 Packer"
**
**	C reconstruction of the shipped binary
**	($VER: "xpkCBR0.library V1.0 © by Bilbo 1st of
**	Hypenosis on 23-Aug-1992.", 0xa0 NBSP separators;
**	lib_IdString is the bare word "xpkCBR0").
**
**	CBR0 is an XPK chunk packer using the simplest possible
**	byte-oriented RLE:
**	    <h><lit bytes>   literal run: h < 0x80, n = h+1    (1..128)
**	    <h><byte>        repeat run:  h >= 0x80, n = 257-h (2..128)
**	no terminator; the decoder stops when the input is
**	exhausted.
**
**	Like the 1.1 rebuild, the XpkInfo and XpkMode
**	descriptors are NOT static data -- LibInit writes every
**	field into the library base (dataSize 0xaa embeds
**	XpkInfo at +0x28 and XpkMode at +0x80) and
**	XpksPackerInfo returns a pointer into the base.
**
**	Shipped-binary quirks kept/documented (see okf/findings/):
**	  - the deferred-expunge flag is manipulated with
**	    "bclr/bset/btst #8,lib_Flags" -- a byte-wide bit op,
**	    so bit 8 wraps to bit 0 (LIBF_SUMMING), NOT bit 3
**	    (LIBF_DELEXP) as in the later V1.1 rebuild.  The
**	    library is still self-consistent: expunge-while-open
**	    sets bit 0, close tests bit 0;
**	  - the encoder's literal loop reads srcend[0] once when
**	    the run test examines the last input byte (bounded
**	    here; identical output either way);
**	  - the encoder aborts with -17 when the output would
**	    reach dst+insize (expansion guard) and with -10 on
**	    dst+256+outbuflen overflow;
**	  - the decoder bound is dst + 256 + OutBufLen, checked
**	    before every emitted byte (returns -10 past it);
**	  - pack rejects insize > 0xfffc but accepts ==0xfffc,
**	    while unpack rejects insize >= 0xfffc;
**	  - a run of exactly 2 bytes is emitted even mid-stream;
**	  - the -17 error path jsr's a bare rts (dead call);
**	  - "V1.0 (23-Aug-1992)" is a dead string and the
**	    helper at 0x404 is a save/restore+rts no-op.
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

struct XpkMode			/* 42 bytes -- xm_* at base+0x80	   */
{
    APTR  xm_Next;		/* 0x00 mode chain			   */
    ULONG xm_Upto;		/* 0x04 usable up to rate (100)	   */
    ULONG xm_Flags;		/* 0x08 XPKMF_A3000SPEED		   */
    ULONG xm_PackMemory;	/* 0x0c					   */
    ULONG xm_UnpackMemory;	/* 0x10					   */
    ULONG xm_PackSpeed;		/* 0x14 410				   */
    ULONG xm_UnpackSpeed;	/* 0x18 1918				   */
    UWORD xm_Ratio;		/* 0x1c 31				   */
    UWORD xm_ChunkSize;		/* 0x1e 63 (shipped value)	   */
    char  xm_Description[10];	/* 0x20 "normal"			   */
};				/* = 0x2a				   */

struct XpkInfo			/* 88 bytes -- xi_* at base+0x28	   */
{
    UWORD  xi_XpkInfoVersion;	/* 0x00 1				   */
    UWORD  xi_LibVersion;	/* 0x02 1				   */
    UWORD  xi_MasterVersion;	/* 0x04 1				   */
    UWORD  xi_ModesVersion;	/* 0x06 0				   */
    STRPTR xi_Name;		/* 0x08 "CBR0"			   */
    STRPTR xi_LongName;		/* 0x0c "Cmp Byte Run 0 Packer V1.0"   */
    STRPTR xi_Description;	/* 0x10				   */
    ULONG  xi_ID;		/* 0x14 'CBR0'			   */
    ULONG  xi_Flags;		/* 0x18 9 = PK_CHUNK|UP_CHUNK	   */
    ULONG  xi_MaxPkInChunk;	/* 0x1c 0xfffc			   */
    ULONG  xi_MinPkInChunk;	/* 0x20 0				   */
    ULONG  xi_DefPkInChunk;	/* 0x24 0xfffc			   */
    STRPTR xi_PackMsg;		/* 0x28 "Compressing"		   */
    STRPTR xi_UnpackMsg;	/* 0x2c "Decompressing"		   */
    STRPTR xi_PackedMsg;	/* 0x30 "Compressed"		   */
    STRPTR xi_UnpackedMsg;	/* 0x34 "Decompressed"		   */
    UWORD  xi_DefMode;		/* 0x38 50				   */
    UWORD  xi_Pad;		/* 0x3a 0				   */
    APTR   xi_ModeDesc;		/* 0x3c -> base+0x80		   */
    ULONG  xi_Reserved[6];	/* 0x40				   */
};				/* = 0x58				   */

struct XpkSubBase		/* InitTable dataSize = 0xaa	   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node	   */
    UWORD xsb_Pad0;		/* 0x22					   */
    BPTR  xsb_SegList;		/* 0x24 seglist, stored by LibInit	   */
    struct XpkInfo xsb_Info;	/* 0x28 runtime-filled descriptor	   */
    struct XpkMode xsb_Mode;	/* 0x80 runtime-filled mode desc	   */
};				/* = 0xaa				   */

/* strings emitted by xpkCBR0_lib.s */
extern const char s_name[], s_lname[], s_desc[];
extern const char s_pack[], s_unpack[], s_packed[], s_unpacked[];
extern const char s_mode[];

/* V1.0 deferred-expunge quirk: the original uses
 * "bclr/bset/btst #8,lib_Flags" -- a memory BYTE bit op, so
 * the bit number wraps modulo 8 and bit 0 (LIBF_SUMMING) is
 * manipulated instead of bit 3 (LIBF_DELEXP). */
#define DELEXP_V10	(1<<0)		/* shipped bit, wraps from #8 */

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


/*
 * LibInit: store the seglist, then fill the embedded XpkMode
 * (+0x80) and XpkInfo (+0x28) descriptor blocks field by
 * field, exactly as the shipped init routine does (helper at
 * 0x2fa writes immediates into the base).
 */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    register struct XpkMode *m = &base->xsb_Mode;
    register struct XpkInfo *x = &base->xsb_Info;

    base->xsb_SegList = seglist;

    m->xm_Next		= NULL;
    m->xm_Upto		= 100;
    m->xm_Flags		= 1;		/* XPKMF_A3000SPEED */
    m->xm_PackMemory	= 0;
    m->xm_UnpackMemory	= 0;
    m->xm_PackSpeed	= 410;
    m->xm_UnpackSpeed	= 1918;
    m->xm_Ratio		= 31;		/* 0x1f -- shipped    */
    m->xm_ChunkSize	= 63;		/* 0x3f -- shipped    */
    /* xm_Description[10] = "normal" (tail left zeroed) */
    *(ULONG *)&m->xm_Description[0] = 0x6e6f726d;	/* "norm" */
    *(ULONG *)&m->xm_Description[4] = 0x616c0000;	/* "al"   */

    x->xi_XpkInfoVersion = 1;
    x->xi_LibVersion	 = 1;
    x->xi_MasterVersion	 = 1;
    x->xi_ModesVersion	 = 0;
    x->xi_Name		 = (STRPTR)s_name;
    x->xi_LongName	 = (STRPTR)s_lname;
    x->xi_Description	 = (STRPTR)s_desc;
    x->xi_ID		 = 0x43425230;	/* 'CBR0' */
    x->xi_Flags		 = 9;		/* XPKIF_PK_CHUNK|XPKIF_UP_CHUNK */
    x->xi_MaxPkInChunk	 = 0xfffc;
    x->xi_MinPkInChunk	 = 0;
    x->xi_DefPkInChunk	 = 0xfffc;
    x->xi_PackMsg	 = (STRPTR)s_pack;
    x->xi_UnpackMsg	 = (STRPTR)s_unpack;
    x->xi_PackedMsg	 = (STRPTR)s_packed;
    x->xi_UnpackedMsg	 = (STRPTR)s_unpacked;
    x->xi_DefMode	 = 50;		/* 0x32 -- shipped    */
    x->xi_Pad		 = 0;
    x->xi_ModeDesc	 = (APTR)&base->xsb_Mode;
    x->xi_Reserved[0] = 0;
    x->xi_Reserved[1] = 0;
    x->xi_Reserved[2] = 0;
    x->xi_Reserved[3] = 0;
    x->xi_Reserved[4] = 0;
    x->xi_Reserved[5] = 0;

    return (struct Library *)base;
}

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~DELEXP_V10;	/* bclr #8 -> bit 0 */

    return (struct Library *)base;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"));

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= DELEXP_V10;	/* bset #8 -> bit 0 */
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
	if (base->xsb_Lib.lib_Flags & DELEXP_V10) /* btst #8 -> bit 0 */
	    return (LONG)LibExpunge(base);
    }

    return 0;
}

/* LibNull (LVO -24 ExtFunc): moveq #0,d0 / rts */
LONG LibNull(void)
{
    return 0;
}

/* LibRts (LVO -42/-48/-60 unused sublib slots): bare rts in
 * the original -- returns whatever d0 happens to hold.
 * LVO -66's error path even jsr's the -48 slot as a nop. */
void LibRts(void)
{
}

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/* XpksPackerInfo (LVO -30): the descriptor lives inside the base */
APTR XpksPackerInfo(struct XpkSubBase *base __asm("a6"))
{
    return (APTR)&base->xsb_Info;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Decoder: headers until the input is exhausted.
**	h < 0x80   -> literal run of h+1 bytes   (1..128)
**	h >= 0x80  -> repeat run of 257-h bytes  (2..128)
**
**	The shipped output bound is dst + 0x100 + OutBufLen,
**	checked before every emitted byte (returns -10 past
**	it).  Corrupt or truncated input overreads the source
**	buffer, same as the original.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    ULONG len = p->xsp_InLen;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    UBYTE *bound = dst + 256 + p->xsp_OutBufLen;
    const UBYTE *end = src + len;
    UBYTE *w = dst;

    if (!len) {
	p->xsp_OutLen = 0;
	return 0;
    }
    if (len >= 0xfffc)
	return -11;			/* input too big */

    while (src < end) {
	UBYTE h = *src++;
	if (h & 0x80) {
	    UBYTE v = *src++;
	    ULONG n = 257 - h;		/* 2..128 */
	    while (n--) {
		if (w >= bound)
		    return -10;		/* output overflow */
		*w++ = v;
	    }
	} else {
	    ULONG n = h + 1;		/* 1..128 */
	    while (n--) {
		if (w >= bound)
		    return -10;
		*w++ = *src++;
	    }
	}
    }

    p->xsp_OutLen = w - dst;
    return 0;
}

/*
**	XpksPackChunk (LVO -36)
**
**	Encoder: at each segment start two equal bytes open a
**	repeat run (<=128 emitted per header); otherwise a
**	literal stretch of <=128 bytes is gathered, ending
**	before the next equal pair.  A single leftover byte
**	emits a literal-1 segment.
**
**	Shipped-bound semantics: literal copies abort with -10
**	when the write cursor reaches dst+256+OutBufLen and
**	with -17 when it reaches dst+insize (expansion guard);
**	the 2-byte run/literal-1 emits check the same bounds
**	with the shipped comparison operators (>= for the run
**	emit, > for the single-byte emit).
**
**	Original defect NOT reproduced: the literal loop's
**	run test reads srcend[0] when the last byte is
**	examined; the reconstruction bounds the peek.
**	Behaviour is identical either way (the OOB byte only
**	steers the last byte between the literal and the
**	single-byte emit path, which produce the same bytes).
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    ULONG len = p->xsp_InLen;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    UBYTE *bound = dst + 256 + p->xsp_OutBufLen;
    const UBYTE *end = src + len;
    UBYTE *explim = dst + len;		/* expansion guard  */
    UBYTE *w = dst;

    if (!len) {
	p->xsp_OutLen = 0;
	return 0;
    }
    if (len > 0xfffc)
	return -11;			/* input too big */

    while (src < end) {
	UBYTE b = *src;

	if (src + 1 >= end) {
	    /* last input byte: emit literal-1 */
	    if (w + 2 > bound)
		return -10;		/* output overflow    */
	    if (w + 2 > explim)
		return -17;		/* would expand input */
	    *w++ = 0;
	    *w++ = b;
	    break;
	}

	if (src[1] == b) {
	    /* repeat run of >= 2, <= 128 bytes per header */
	    UBYTE h;
	    WORD d4 = 127;

	    if (w + 2 >= bound)
		return -10;		/* output overflow    */
	    if (w + 2 >= explim)
		return -17;		/* would expand input */

	    for (;;) {
		if (*src != b) {	/* mismatch (consumed) */
		    h = (UBYTE)(d4 - 126);	/* 257-n    */
		    break;
		}
		src++;
		if (src >= end) {	/* run hits input end */
		    h = (UBYTE)(d4 - 127);	/* 257-n    */
		    break;
		}
		if (--d4 == -1) {	/* 128-byte cap	    */
		    h = 0x81;
		    break;
		}
	    }
	    *w++ = h;
	    *w++ = b;
	    continue;
	}

	/* literal run: bytes until an equal pair follows */
	{
	    UBYTE *hdr = w++;		/* header slot	   */
	    UBYTE *lit = w;		/* write cursor    */
	    WORD d4 = 127;

	    for (;;) {
		if (lit >= bound)
		    return -10;		/* output overflow    */
		if (lit >= explim)
		    return -17;		/* would expand input */
		if (src[1] == b) {	/* run starts (OOB at tail) */
		    *hdr = (UBYTE)(126 - d4);	/* literals-1 */
		    w = lit;
		    break;
		}
		*lit++ = *src++;
		if (src >= end) {
		    *hdr = (UBYTE)(127 - d4);	/* literals-1 */
		    w = lit;
		    goto done;
		}
		b = *src;
		if (--d4 == -1) {
		    *hdr = 127;		/* literal-128	    */
		    w = lit;
		    break;
		}
	    }
	}
    }

done:
    p->xsp_OutLen = w - dst;
    return 0;
}
