/*
**	xpkNONE.c -- xpkNONE.library V1.5 (1 Oct 2013) by Dirk Stoecker
**
**	C reconstruction of the shipped binary
**	($VER: xpkNONE V1.5 (1 Oct 2013) by Dirk Stoecker).
**
**	"NONE" is the identity packer of the XPK system: it registers
**	the packer ID 'NONE' but cannot compress anything.  Its
**	XpksPackChunk always fails with XPKERR_EXPANSION (-17), which
**	tells xpkmaster.library to store the chunk uncompressed, and
**	XpksUnpackChunk copies the stored data back out via CopyMem.
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

/* XpkInfo/XpkMode descriptor blocks (xpkNONE_lib.s, in the code hunk) */
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

#define __CopyMem(__sys, ___src, ___dst, ___len) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_src __asm("a0") = (void *)(___src);\
  register void * __p_dst __asm("a1") = (void *)(___dst);\
  register ULONG __p_len __asm("d0") = (ULONG)(___len);\
  __asm volatile (\
		   "jsr %/a6@(-624:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_src), "a"(__p_dst), "d"(__p_len), "a"(__p_sys)\
		   : "cc", "memory", "d1" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* LibInit: initRoutine from the InitTable; remembers the seglist */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    base->xsb_SegList = seglist;

    return (struct Library *)base;
}

/* LibOpen (LVO -6): bump open count, clear a pending delayed expunge */
struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;

    return (struct Library *)base;
}

/* LibExpunge (LVO -18): remove and free the library when no one has
** it open, else mark it for delayed expunge.  Returns the seglist. */
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

/* LibClose (LVO -12): drop the open count, expunge if delayed */
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

/* XpksPackChunk (LVO -36): "NONE" cannot compress; -17 tells the
** master library to store the chunk without packing instead. */
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    return -17;			/* XPKERR_EXPANSION */
}

/* XpksUnpackChunk (LVO -54): a stored chunk is copied back verbatim.
** xsp_OutLen receives the (unchanged) chunk length. */
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    p->xsp_OutLen = p->xsp_InLen;
    __CopyMem(SYSBASE, p->xsp_InBuf, p->xsp_OutBuf, p->xsp_InLen);

    return 0;
}
