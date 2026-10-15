/*
**	xpkDLTA.c -- xpkDLTA.library v0.2 (1992) by Stephan Fuhrmann
**
**	C reconstruction of the shipped binary
**	("xpkDLTA.library v0.2", no $VER cookie).
**
**	DLTA is a delta ("bytemode") filter packer.  Unlike V0.3 this
**	older version carries one byte of state across chunks through
**	the parameter block: when xsp_Sub[0] is non-zero the differencing
**	continues from xsp_Sub[1] (the last byte of the previous chunk),
**	and every call stores the new last byte back to xsp_Sub[1].
**
**	The XpkInfo/XpkMode descriptors are embedded in the 0xfc-byte
**	library base and initialised by the InitStruct data table
**	(xpkDLTA_lib.s); LibInit links the mode block into xi_ModeDesc.
**	Both codec paths bound InLen to 64K (the byte loops count with
**	a word register) and to the output buffer size.
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

struct XpkSubBase		/* InitTable dataSize = 0xfc		   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node (34 b.)  */
    BPTR  xsb_SegList;		/* 0x22 seglist, stored by LibInit	   */
    UBYTE xsb_Info[88];		/* 0x26 embedded XpkInfo (InitStruct)  */
    UBYTE xsb_Mode[42];		/* 0x7e embedded XpkMode (InitStruct)  */
    UBYTE xsb_Reserved[0xfc - 0xa8];	/* 0xa8..0xfb unused		   */
};

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

/* InitRoutine: stores the seglist and links the embedded mode
** descriptor into the embedded info block (xi_ModeDesc at 0x62). */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    base->xsb_SegList = seglist;
    *(APTR *)((UBYTE *)base + 0x62) = (APTR)base->xsb_Mode;

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

/* LibClose falls through to LibExpunge on DELEXP in the original;
** same semantics here. */
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

/* XpksPackerInfo (LVO -30): the info block is embedded in the
** library base at offset 0x26 (lea a6@(38),a0 as shipped). */
APTR XpksPackerInfo(struct XpkSubBase *base __asm("a6"))
{
    return (APTR)base->xsb_Info;
}

/*
**	XpksPackChunk (LVO -36)
**
**	Delta-encode: first byte raw, then in[i]-in[i-1].
**	Bounds: InLen > OutBufLen -> XPKERR_SMALLBUF (-10),
**	        InLen > 64K       -> XPKERR_LARGEBUF (-11).
**	If xsp_Sub[0] is set the chain continues from xsp_Sub[1]
**	(the previous chunk's last byte); the new last byte is stored
**	back to xsp_Sub[1].  The original stores/loads the carry as a
**	full longword whose upper bits are whatever the byte ops left
**	behind; only the low byte is ever used.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    ULONG  n   = p->xsp_InLen;
    UBYTE  prev;

    if (n > p->xsp_OutBufLen)
	return -10;			/* XPKERR_SMALLBUF */
    if (n > 0x10000)
	return -11;			/* XPKERR_LARGEBUF */
    p->xsp_OutLen = n;

    prev = *in++;
    *out++ = prev;
    n--;
    if (p->xsp_Sub[0])
	prev = (UBYTE)p->xsp_Sub[1];

    while (n--) {
	UBYTE d = *in++ - prev;
	*out++ = d;
	prev += d;			/* == current input byte */
    }

    p->xsp_Sub[1] = prev;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Delta-decode: first byte raw, then accumulate the differences.
**	Same bounds checks and the same xsp_Sub[0]/xsp_Sub[1] carry
**	scheme as the encoder.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    ULONG  n   = p->xsp_InLen;
    UBYTE  acc;

    if (n > p->xsp_OutBufLen)
	return -10;			/* XPKERR_SMALLBUF */
    if (n > 0x10000)
	return -11;			/* XPKERR_LARGEBUF */
    p->xsp_OutLen = n;

    acc = *in++;
    *out++ = acc;
    n--;
    if (p->xsp_Sub[0])
	acc = (UBYTE)p->xsp_Sub[1];

    while (n--) {
	acc += *in++;
	*out++ = acc;
    }

    p->xsp_Sub[1] = acc;
    return 0;
}
