/*
**	xpkNONE.c -- xpkNONE.library 1.2 (01.04.1997)
**
**	C reconstruction of the shipped binary
**	("xpkNONE 1.2 (01.04.1997)", no $VER cookie).
**
**	This is the older SAS/C-skeleton flavour of the "no
**	compression" sublibrary: the seglist lives in a code-section
**	longword (the library base is just a struct Library), LibInit
**	calls xInitCode() and LibExpunge calls xExitCode() -- both are
**	the same shared "return 0" stub.  Unusually for a NONE packer
**	XpksPackChunk refuses with XPKERR_EXPANSION (-17); only the
**	unpack side copies bytes through CopyMem.
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

/* dataSize is 0x22: the library base is a bare struct Library. */

/* Code-section seglist longword (xpkNONE_lib.s) */
extern BPTR SegList;

/* XpkInfo/XpkMode descriptor blocks (xpkNONE_lib.s, code hunk) */
extern const char xpkinfo[];

/* Shared "return 0" stub in xpkNONE_lib.s: serves as the SAS/C
** skeleton's xInitCode()/xExitCode() hooks.  The original calls it
** with the library base in a5 (which the stub ignores); declaring
** an a5-bound argument ICEs this GCC (a5 is the reserved frame
** pointer), so the base is placed in a5 via a register variable
** and the stubs are declared without parameters. */
LONG  xInitCode(void);
void  xExitCode(void);

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

#define __CopyMem(__sys, ___src, ___dst, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_src __asm("a0") = (void *)(___src);\
  register void * __p_dst __asm("a1") = (void *)(___dst);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile (\
		   "jsr %/a6@(-624:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_src), "a"(__p_dst), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* InitRoutine (AUTOINIT): stashes the seglist in the code-section
** global, runs xInitCode(); on failure runs xExitCode() and reports
** failure.  The stub always returns 0, so the base is always
** accepted -- faithful to the shipped binary. */
struct Library *LibInit(struct Library *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    register struct Library *b __asm("a5") = base;	/* movea.l d0,a5 */

    SegList = seglist;

    if (xInitCode()) {
	xExitCode();
	return 0;
    }

    return b;
}

struct Library *LibOpen(struct Library *base __asm("a6"))
{
    base->lib_OpenCnt++;
    base->lib_Flags &= ~LIBF_DELEXP;

    return base;
}

BPTR LibExpunge(struct Library *base __asm("a6"));

BPTR LibExpunge(struct Library *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->lib_OpenCnt) {
	base->lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = SegList;			/* read from the code-section global */
    __Remove(sys, &base->lib_Node);
    xExitCode();			/* skeleton hook (shared stub, a5=base) */
    __FreeMem(sys, (UBYTE *)base - base->lib_NegSize,
	      (ULONG)base->lib_NegSize + base->lib_PosSize);

    return seg;
}

LONG LibClose(struct Library *base __asm("a6"))
{
    if (--base->lib_OpenCnt == 0) {
	if (base->lib_Flags & LIBF_DELEXP)
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

/* XpksPackChunk (LVO -36): the shipped routine is a bare
** "moveq #-17,d0 / rts" -- this sublib refuses to pack
** (XPKERR_EXPANSION). */
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct Library *base __asm("a6"))
{
    return -17;
}

/* XpksUnpackChunk (LVO -54): copy InLen bytes InBuf -> OutBuf via
** Exec CopyMem, set OutLen = InLen, return XPKERR_OK. */
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct Library *base __asm("a6"))
{
    p->xsp_OutLen = p->xsp_InLen;
    __CopyMem(SYSBASE, p->xsp_InBuf, p->xsp_OutBuf, p->xsp_InLen);

    return 0;
}
