/*
**	xpkCBR0.c -- xpkCBR0.library V1.1 "Cmp Byte Run 0 Packer"
**
**	C reconstruction of the shipped binary
**	(idstring "xpkCBR0 v1.1", no $VER: cookie).
**
**	CBR0 is an XPK chunk packer using the simplest possible
**	byte-oriented RLE:
**	    <h><lit bytes>   literal run: h < 0x80, n = h+1    (1..128)
**	    <h><byte>        repeat run:  h >= 0x80, n = 257-h (2..129)
**	no terminator; the decoder stops when the input is
**	exhausted.
**
**	Unlike xpkFRLE/xpkRLEN, the XpkInfo and XpkMode
**	descriptors are NOT static data -- LibInit writes every
**	field into the library base (dataSize 0xaa embeds
**	XpkInfo at +0x28 and XpkMode at +0x80) and
**	XpksPackerInfo returns a pointer into the base.
**
**	Shipped-binary quirks kept/documented (see okf/findings/):
**	  - the encoder's literal-vs-run test reads one byte past
**	    the input end when the last byte is reached
**	    (cmpb at srcend; the reconstruction bounds the read);
**	  - the encoder aborts with -17 when the output would
**	    reach dst+insize (an incompressible-data expansion
**	    guard) and with -10 on dst+256+param overflow;
**	  - the decoder bound is dst + 256 + params[3], not the
**	    plain output-buffer size;
**	  - runs are emitted in <=128-byte segments; a run of 2
**	    suffices even mid-literal.
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
    STRPTR xi_LongName;		/* 0x0c "Cmp Byte Run 0 Packer v1.1"	   */
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
 * field, exactly as the shipped init routine does.
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

/* LibNull (LVO -24 ExtFunc): moveq #0,d0 / rts */
LONG LibNull(void)
{
    return 0;
}

/* LibRts (LVO -42/-48/-60 unused sublib slots): bare rts in
 * the original -- returns whatever d0 happens to hold. */
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
**	h >= 0x80  -> repeat run of 257-h bytes  (2..129)
**
**	The shipped output bound is dst + 0x100 + params[3],
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
	    ULONG n = 257 - h;		/* 2..129 */
	    while (n--) {
		if (w > bound)
		    return -10;		/* output overflow */
		*w++ = v;
	    }
	} else {
	    ULONG n = h + 1;		/* 1..128 */
	    while (n--) {
		if (w > bound)
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
**	before the next equal pair.
**
**	Shipped-bound semantics: -10 when a write would pass
**	dst+256+params[3], -17 when the output reaches
**	dst+insize (expansion guard), -11 when the input is
**	>= 0xfffc bytes.
**
**	Original defect NOT reproduced: the run-detection test
**	reads srcend[0] when the input's last byte is examined
**	(the `bhis` boundary includes equality).  The C version
**	bounds the peek; behaviour on valid buffers is
**	identical.
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
    if (len >= 0xfffc)
	return -11;			/* input too big */

    while (src < end) {
	UBYTE b = src[0];

	if (src + 1 < end && src[1] == b) {
	    /* repeat run of >= 2, emitted in <=128-byte pieces */
	    ULONG n = 0;
	    while (n < 128 && src < end && *src == b) {
		src++;
		n++;
	    }
	    if (w + 2 > bound)
		return -10;		/* output overflow    */
	    if (w + 2 >= explim)
		return -17;		/* would expand input */
	    *w++ = (UBYTE)(257 - n);	/* h: 0x81..0xff      */
	    *w++ = b;
	    continue;
	}

	/* literal run: bytes until an equal pair follows */
	{
	    UBYTE *hdr = w++;
	    ULONG n = 0;

	    while (n < 128 && src < end) {
		if (src + 1 < end && src[1] == src[0])
		    break;		/* run starts here   */
		if (w + 1 > bound)
		    return -10;
		if (w + 1 >= explim)
		    return -17;
		*w++ = *src++;
		n++;
	    }
	    *hdr = (UBYTE)(n - 1);	/* h: 0x00..0x7f     */
	}
    }

    p->xsp_OutLen = w - dst;
    return 0;
}
