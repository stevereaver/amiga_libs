/*
**	xpkLHLB.c -- xpkLHLB.library v1.1 (5.4.98)
**
**	C reconstruction of the shipped binary
**	("xpkLBLB 1.1 (5.4.98)" -- the "LBLB" typo is in the
**	idstring of the original).
**
**	LHLB is a thin XPK sublibrary *wrapper* around lh.library:
**	LibInit OpenLibrary()s "lh.library" (version 1); the codec
**	LVOs lazily allocate a control block via lh's -30 vector
**	(mode 0 = pack, mode 1 = unpack), delegate the chunk work to
**	lh vectors -42 (pack) / -48 (unpack), and release everything
**	via lh -36.  A 36 KiB scratch buffer holds packed data before
**	it is CopyMem'd into the caller's output buffer.
**
**	Stream/packed layout is entirely lh.library's; this library
**	is only an adapter.
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

struct XpkSubBase		/* InitTable dataSize = 0x30		   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node (34 b.)  */
    UWORD xsb_Pad;		/* 0x22				   */
    BPTR  xsb_SegList;		/* 0x24 seglist, stored by LibInit	   */
    struct ExecBase *xsb_SysBase;	/* 0x28			   */
    struct Library *xsb_LhBase;	/* 0x2c lh.library base		   */
};

/* XpkInfo/XpkMode descriptor blocks (xpkLHLB_lib.s, code hunk) */
extern const char xpkinfo[];
extern const char lhlibname[];	/* "lh.library" */

/* ------------------------------------------------------------------ */
/* Exec LVO calls							  */
/* ------------------------------------------------------------------ */

#define __OpenLibrary(__sys, ___name, ___ver) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register STRPTR __p_name __asm("a1") = (STRPTR)(___name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(___ver);\
  __asm volatile (\
		   "jsr %/a6@(-552:W)\n"\
		   : "=r"(__p_sys)\
		   : "a"(__p_name), "d"(__p_ver), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  (void *)__p_sys; })

#define __CloseLibrary(__sys, ___lib) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_lib __asm("a1") = (void *)(___lib);\
  __asm volatile (\
		   "jsr %/a6@(-414:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_lib), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __AllocMem(__sys, ___size, ___flags) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  register ULONG __p_flags __asm("d1") = (ULONG)(___flags);\
  __asm volatile (\
		   "jsr %/a6@(-198:W)\n"\
		   : "=r"(__p_sys)\
		   : "d"(__p_size), "d"(__p_flags), "a"(__p_sys)\
		   : "cc", "memory", "a0" );\
  (void *)__p_sys; })

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

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

/* lh.library vectors (names inferred from use):
 *   -30  lhAlloc  (d0 = mode: 0 pack, 1 unpack) -> control block
 *   -36  lhFree   (a0 = control block)
 *   -42  lhPack   (a0 = control block {inbuf,inlen,outbuf,outbuflen})
 *   -48  lhUnpack (a0 = control block, same layout)                */
#define __lhAlloc(__lh, ___mode) ({\
  register void * __p_lh __asm("a6") = (void *)(__lh);\
  register ULONG __p_mode __asm("d0") = (ULONG)(___mode);\
  __asm volatile (\
		   "jsr %/a6@(-30:W)\n"\
		   : "=r"(__p_lh)\
		   : "d"(__p_mode), "a"(__p_lh)\
		   : "cc", "memory", "d1", "a0" );\
  (void *)__p_lh; })

#define __lhFree(__lh, ___blk) ({\
  register void * __p_lh __asm("a6") = (void *)(__lh);\
  register void * __p_blk __asm("a0") = (void *)(___blk);\
  __asm volatile (\
		   "jsr %/a6@(-36:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "a"(__p_lh)\
		   : "cc", "memory", "d0", "d1", "a1" );})

#define __lhPack(__lh, ___blk) ({\
  register void * __p_lh __asm("a6") = (void *)(__lh);\
  register void * __p_blk __asm("a0") = (void *)(___blk);\
  __asm volatile (\
		   "jsr %/a6@(-42:W)\n"\
		   : "=r"(__p_lh)\
		   : "a"(__p_blk), "a"(__p_lh)\
		   : "cc", "memory", "d1", "a1" );\
  (ULONG)__p_lh; })

#define __lhUnpack(__lh, ___blk) ({\
  register void * __p_lh __asm("a6") = (void *)(__lh);\
  register void * __p_blk __asm("a0") = (void *)(___blk);\
  __asm volatile (\
		   "jsr %/a6@(-48:W)\n"\
		   : "=r"(__p_lh)\
		   : "a"(__p_blk), "a"(__p_lh)\
		   : "cc", "memory", "d1", "a1" );\
  (ULONG)__p_lh; })

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* LibInit(d0=base, a0=seglist, a6=SysBase): keep seglist/sysbase,
 * then OpenLibrary("lh.library",1).  On failure the routine
 * FreeMem's the freshly allocated base and returns NULL. */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->xsb_SegList = seglist;
    base->xsb_SysBase = sys;
    base->xsb_LhBase  = __OpenLibrary(sys, lhlibname, 1);

    if (!base->xsb_LhBase) {
	__FreeMem(sys, (UBYTE *)base - base->xsb_Lib.lib_NegSize,
		  (ULONG)base->xsb_Lib.lib_NegSize +
		  base->xsb_Lib.lib_PosSize);
	return NULL;
    }
    return (struct Library *)base;
}

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;
    base->xsb_Lib.lib_OpenCnt++;

    return (struct Library *)base;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    BPTR seg;

    base->xsb_Lib.lib_Flags |= LIBF_DELEXP;	/* set unconditionally */
    if (base->xsb_Lib.lib_OpenCnt)
	return 0;

    __CloseLibrary(base->xsb_SysBase, base->xsb_LhBase);

    seg = base->xsb_SegList;
    __Remove(base->xsb_SysBase, &base->xsb_Lib.lib_Node);
    __FreeMem(base->xsb_SysBase,
	      (UBYTE *)base - base->xsb_Lib.lib_NegSize,
	      (ULONG)base->xsb_Lib.lib_NegSize +
	      base->xsb_Lib.lib_PosSize);
    return seg;
}

LONG LibClose(struct XpkSubBase *base __asm("a6"))
{
    /* the original skips the decrement entirely on a 0 count */
    if (base->xsb_Lib.lib_OpenCnt)
	--base->xsb_Lib.lib_OpenCnt;
    if (base->xsb_Lib.lib_OpenCnt == 0 &&
	(base->xsb_Lib.lib_Flags & LIBF_DELEXP))
	return (LONG)LibExpunge(base);

    return 0;
}

/* LibNull (LVO -24 reserved, and XpksPackReset) */
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
**	On first use, allocates an lh control block (lh -30, mode 0)
**	into xsp_Sub[0] and a 0x9000-byte scratch buffer (AllocMem)
**	into xsp_Sub[1].  The lh block receives {InBuf, InLen,
**	scratch, 0x8000} and lh -42 is called; a nonzero result
**	smaller than xsp_OutBufLen is CopyMem'd to xsp_OutBuf and
**	stored as xsp_OutLen.  Errors: -7 alloc, -17 expansion.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    ULONG *blk = (ULONG *)p->xsp_Sub[0];
    ULONG  ret;

    if (!blk) {
	blk = __lhAlloc(base->xsb_LhBase, 0);	/* mode 0 = pack */
	p->xsp_Sub[0] = (ULONG)blk;
	if (!blk)
	    return -7;
	p->xsp_Sub[1] = (ULONG)__AllocMem(base->xsb_SysBase,
					  0x9000, 0);
	if (!p->xsp_Sub[1])
	    return -7;
    }

    blk[0] = (ULONG)p->xsp_InBuf;
    blk[1] = p->xsp_InLen;
    blk[2] = p->xsp_Sub[1];
    blk[3] = 0x8000;
    ret = __lhPack(base->xsb_LhBase, blk);
    if (ret == 0 || ret >= p->xsp_OutBufLen)
	return -17;				/* XPKERR_EXPANSION */

    p->xsp_OutLen = ret;
    __CopyMem(base->xsb_SysBase, (void *)p->xsp_Sub[1],
	      p->xsp_OutBuf, ret);
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	On first use, clears xsp_Sub[1] and allocates an lh control
**	block (lh -30, mode 1) into xsp_Sub[0].  The lh block
**	receives {InBuf, InLen, OutBuf, OutBufLen} and lh -48 is
**	called; its return value becomes xsp_OutLen.
**
**	The shipped code tests the CCR Z flag left by the lh call
**	(seq + and #-14): it returns -14 when lh came back with Z
**	set (failure), else 0.  lh's own convention makes that
**	equivalent to a zero return value, which is what we test.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    ULONG *blk = (ULONG *)p->xsp_Sub[0];
    ULONG  ret;

    if (!blk) {
	p->xsp_Sub[1] = 0;
	blk = __lhAlloc(base->xsb_LhBase, 1);	/* mode 1 = unpack */
	p->xsp_Sub[0] = (ULONG)blk;
	if (!blk)
	    return -7;
    }

    blk[0] = (ULONG)p->xsp_InBuf;
    blk[1] = p->xsp_InLen;
    blk[2] = (ULONG)p->xsp_OutBuf;
    blk[3] = p->xsp_OutBufLen;
    ret = __lhUnpack(base->xsb_LhBase, blk);
    p->xsp_OutLen = ret;

    return ret ? 0 : -14;
}

/*
**	XpkFree (LVO -42 XpksPackFree, LVO -60 XpksUnpackFree)
**
**	Shared cleanup: FreeMem's the 0x9000 scratch buffer and
**	lh -36's the control block; clears both xsp_Sub slots.
**	The shipped routine returns whatever d0 happened to hold.
*/
LONG XpkFree(struct XpkSubParams *p __asm("a0"),
	     struct XpkSubBase *base __asm("a6"))
{
    if (p->xsp_Sub[1]) {
	__FreeMem(base->xsb_SysBase, (void *)p->xsp_Sub[1], 0x9000);
	p->xsp_Sub[1] = 0;
    }
    if (p->xsp_Sub[0]) {
	__lhFree(base->xsb_LhBase, (void *)p->xsp_Sub[0]);
	p->xsp_Sub[0] = 0;
    }
    return 0;
}
