/*
**	xpkCYB1.c -- xpkCYB1.library v1.0 (24.04.1996)
**	by Alexis Nasr (The Cyborg/NGC)
**
**	C reconstruction of the shipped binary
**	("$VER:xpkCYB1.library v1.0 (24.04.1996) by Alexis Nasr
**	(The Cyborg/NGC)").
**
**	"Crunch?Yes...Better!  The totally adaptive Xpk SubLib!!!"
**	Despite the advertising this binary is a STUB sublibrary:
**	XpksPackerInfo returns a populated XpkInfo block (claiming
**	PK_CHUNK|UP_CHUNK support and a 500% ratio), while every codec
**	LVO is a shared "move.l #-1,d0 / rts" stub.  There is no real
**	packer or unpacker in the shipped code and none is invented
**	here.
**
**	Base layout is wider than the standard sublibs (dataSize
**	0x4a): the InitRoutine stores SysBase at +0x22 and the seglist
**	at +0x26, and LibExpunge uses the stored SysBase rather than
**	re-reading 4.W.
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

struct XpkSubBase		/* InitTable dataSize = 0x4a		   */
{
    struct Library  xsb_Lib;	/* 0x00 standard library node (34 b.)  */
    struct ExecBase *xsb_SysBase;/* 0x22 SysBase, stored by LibInit	   */
    BPTR   xsb_SegList;		/* 0x26 seglist, stored by LibInit	   */
    UBYTE  xsb_Reserved[0x4a - 0x2a];	/* 0x2a..0x49 unused		   */
};

/* XpkInfo/XpkMode descriptor blocks (xpkCYB1_lib.s, code hunk) */
extern const char xpkinfo[];

/* ------------------------------------------------------------------ */
/* Exec LVO calls							  */
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

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* InitRoutine (AUTOINIT).  a6 holds ExecBase when exec calls the
** init routine; the shipped code stores it in the base and uses it
** later in Expunge instead of reading 4.W again. */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->xsb_SysBase = sys;
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
    struct ExecBase *sys = base->xsb_SysBase;	/* stored SysBase */
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

/* XpksPackerInfo (LVO -30): hand xpkmaster the descriptor block.
** (The original computes it as move.l a0,d0 / lea info,a0 /
** exg d0,a0 -- net effect: d0 = &info, a0 restored.) */
APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/* The codec LVOs (-36, -42, -48, -54, -60) are all the shared
** "move.l #-1,d0 / rts" stub in the shipped binary; there is no
** real codec behind this sublibrary.  See _xneg in xpkCYB1_lib.s. */
