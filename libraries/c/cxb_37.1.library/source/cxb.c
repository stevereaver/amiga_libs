/*
**	cxb.c -- cxb.library 37.1 (Captain Crossbones / FR-SoftWorks)
**
**	C reconstruction of the shipped SAS/C-built binary
**	(20.01.98).  A small utility library: per-opener "task
**	contexts" indexed by (ThisTask & 0x380), 16 slots of
**	{task,ctx} each, every context lazily opening
**	dos/intuition/graphics for that opener.  Four public
**	functions:
**
**	  -30  cxbFileInfo(name)	Lock+Examine+UnLock -> 0/-1
**	  -36  cxbMult(a,b)		a * b
**	  -42  cxbMult209(a)		a * 209
**	  -48  cxbRequest(...)		EasyRequestArgs with a
**					"(C) 1998 by Captain
**					Crossbones" gadget text
**
**	AUTOINIT dataSize 0x430.  This library uses a CUSTOM
**	flag byte at base+34 (where struct Library would put
**	lib_SegList) for the delayed-expunge bit; the real
**	seglist lives at base+44, execbase at base+36, and a
**	128-long context table at base+48.
**
**	Shipped behaviour kept:
**	  - context table indexed by (ThisTask & 0x380) -- the
**	    TASK POINTER's bits 7-9, not tc_Type
**	  - Open scans 16 slots under Forbid; full -> returns 0
**	  - Close frees the slot whose task matches ThisTask
**	  - datatab sets lib_IdString to the lib NAME, not the
**	    "$VER:" string (reproduced byte-for-byte)
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/tasks.h>
#include <dos/dos.h>		/* BPTR */
#include <dos/dosextens.h>	/* FileInfoBlock */
#include <intuition/intuition.h>/* EasyStruct */

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

#define CTX_ALLOC	0x638	/* per-context AllocMem size	   */
#define DELEXP_BIT	3	/* custom flag bit at base+34	   */

struct CxbBase			/* dataSize = 0x430		   */
{
    struct Library cb_Lib;	/* 0x00 standard library node	   */
    UBYTE  cb_Flags;		/* 0x22 custom DELEXP flag byte    */
    UBYTE  cb_Pad23;		/* 0x23				   */
    struct ExecBase *cb_Sys;	/* 0x24 stored by INITFUNCTION	   */
    ULONG  cb_Pad28;		/* 0x28				   */
    BPTR   cb_SegList;		/* 0x2c seglist			   */
    struct { APTR task, ctx; } cb_Ctx[128];	/* 0x30 {task,ctx} slots */
};

/* the per-opener context (0x638): lib bases + buffers, laid
 * out so the used fields match the original's a4 offsets    */
struct Ctx
{
    APTR  mem;			/* -64 the 0x638 block itself    */
    ULONG pad60, pad56;
    struct Library *gfx;	/* -52 graphics.library	   */
    struct Library *intuition;/* -48 intuition.library	   */
    struct Library *dos;	/* -44 dos.library		   */
    struct ExecBase *sys;	/* -40				   */
    ULONG pad[9];
    /* a4-relative buffers (fib, requester text) follow      */
};

/* ------------------------------------------------------------------ */
/* Exec LVO calls (absolute SysBase at 4.W, as the original does)	  */
/* ------------------------------------------------------------------ */

#define SYSBASE	(*(struct ExecBase **)4)

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_size __asm("d0") = (ULONG)(__size);\
  register ULONG __p_flags __asm("d1") = (ULONG)(___flags);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_size), "d"(__p_flags), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __Forbid(__sys) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  __asm volatile ("jsr %/a6@(-132:W)\n"\
		   : /* no outputs */ : "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0","a1" );})

#define __Permit(__sys) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  __asm volatile ("jsr %/a6@(-138:W)\n"\
		   : /* no outputs */ : "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0","a1" );})

#define __OpenLibrary(__sys, ___name, ___ver) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register const char * __p_name __asm("a1") = (___name);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___ver);\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
		   : "+d"(__p_d0)\
		   : "a"(__p_name), "a"(__p_sys)\
		   : "cc", "memory", "a0" );\
  (APTR)__p_d0;})

#define __CloseLibrary(__sys, ___lib) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register APTR __p_lib __asm("a1") = (APTR)(___lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_lib), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0" );})

/* DOS calls through the per-context dos.library base		*/
#define __DosLock(__dos, ___name, ___mode) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register const char * __p_name __asm("d1") = (___name);\
  register ULONG __p_mode __asm("d2") = (ULONG)(___mode);\
  register BPTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-84:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_name), "d"(__p_mode), "a"(__p_dos)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __DosUnLock(__dos, ___lock) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register BPTR __p_lock __asm("d1") = (___lock);\
  __asm volatile ("jsr %/a6@(-90:W)\n"\
		   : /* no outputs */\
		   : "d"(__p_lock), "a"(__p_dos)\
		   : "cc", "memory", "d0","a0","a1" );})

#define __DosExamine(__dos, ___lock, ___fib) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register BPTR __p_lock __asm("d1") = (___lock);\
  register void * __p_fib __asm("d2") = (___fib);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-102:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_lock), "d"(__p_fib), "a"(__p_dos)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

/* Intuition call through the per-context intuition.library base */
#define __EasyRequestArgs(__intu, ___win, ___es, ___idc, ___args) ({\
  register void * __p_intu __asm("a6") = (void *)(__intu);\
  register APTR __p_win __asm("a0") = (APTR)(___win);\
  register APTR __p_es __asm("a1") = (APTR)(___es);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___idc);\
  register APTR __p_args __asm("a2") = (APTR)(___args);\
  __asm volatile ("jsr %/a6@(-588:W)\n"\
		   : "+d"(__p_d0)\
		   : "a"(__p_win), "a"(__p_es), "a"(__p_args), "a"(__p_intu)\
		   : "cc", "memory", "a3" );\
  (LONG)__p_d0;})

/* ------------------------------------------------------------------ */
/* context machinery						  */
/* ------------------------------------------------------------------ */

/* the task-indexed slot region: (ThisTask & 0x380) picks a
 * 16-entry run of {task,ctx} slots starting at base+48+idx  */
static APTR *slotbase(struct CxbBase *b)
{
    struct ExecBase *sys = SYSBASE;
    ULONG idx = (ULONG)sys->ThisTask & 0x380;
    return (APTR *)((UBYTE *)b->cb_Ctx + idx);
}

/* context setup (the original's ENDSKIP): AllocMem 0x638,
 * open the three libraries into it			      */
static struct Ctx *newctx(struct ExecBase *sys)
{
    static const char dosn[] = "dos.library";
    static const char intn[] = "intuition.library";
    static const char gfn[] = "graphics.library";
    struct Ctx *c = (struct Ctx *)__AllocMem(CTX_ALLOC, 0);
    if (!c)
	return 0;
    c->mem = c;
    c->sys = sys;
    c->intuition = (struct Library *)__OpenLibrary(sys, intn, 33);
    if (!c->intuition)
	goto fail;
    c->gfx = (struct Library *)__OpenLibrary(sys, gfn, 33);
    if (!c->gfx)
	goto fail;
    c->dos = (struct Library *)__OpenLibrary(sys, dosn, 33);
    if (!c->dos)
	goto fail;
    return c;
fail:
    if (c->gfx)
	__CloseLibrary(sys, c->gfx);
    if (c->intuition)
	__CloseLibrary(sys, c->intuition);
    __FreeMem(c, CTX_ALLOC);
    return 0;
}

static void freectx(struct Ctx *c, struct ExecBase *sys)
{
    if (c->dos)
	__CloseLibrary(sys, c->dos);
    if (c->gfx)
	__CloseLibrary(sys, c->gfx);
    if (c->intuition)
	__CloseLibrary(sys, c->intuition);
    __FreeMem(c, CTX_ALLOC);
}

/* find the current task's context in the slot region	*/
static struct Ctx *findctx(struct CxbBase *b)
{
    struct ExecBase *sys = SYSBASE;
    APTR *slot = slotbase(b);
    int   i;
    for (i = 0; i < 16; i++, slot += 2) {
	if (slot[0] == (APTR)sys->ThisTask)
	    return (struct Ctx *)slot[1];
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct CxbBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    APTR *slot;
    int   i;

    base->cb_Lib.lib_OpenCnt++;
    base->cb_Flags &= ~(1 << DELEXP_BIT);

    __Forbid(sys);
    slot = slotbase(base);
    for (i = 0; i < 16; i++, slot += 2) {
	if (!slot[0]) {			/* empty slot */
	    __Permit(sys);
	    {
		struct Ctx *c = newctx(sys);
		if (!c)
		    return 0;
		slot[0] = (APTR)sys->ThisTask;
		slot[1] = c;
	    }
	    return (struct Library *)base;
	}
    }
    __Permit(sys);
    return 0;
}

BPTR LibExpunge(struct CxbBase *base __asm("a6"))
{
    struct ExecBase *sys = base->cb_Sys;
    BPTR   seg;

    if (base->cb_Lib.lib_OpenCnt) {
	base->cb_Flags |= (1 << DELEXP_BIT);
	return 0;
    }

    seg = base->cb_SegList;
    __Remove(sys, &base->cb_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->cb_Lib.lib_NegSize,
	      (ULONG)base->cb_Lib.lib_NegSize + base->cb_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct CxbBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    APTR *slot;
    int   i;

    slot = slotbase(base);
    for (i = 0; i < 16; i++, slot += 2) {
	if (slot[0] == (APTR)sys->ThisTask) {
	    struct Ctx *c = (struct Ctx *)slot[1];
	    slot[0] = 0;
	    slot[1] = 0;
	    freectx(c, sys);
	    break;
	}
    }

    if (--base->cb_Lib.lib_OpenCnt == 0) {
	if (base->cb_Flags & (1 << DELEXP_BIT))
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

LONG LibReserved(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* public functions (4)						  */
/* ------------------------------------------------------------------ */

/* cxbFileInfo (LVO -30): Lock(name,ACCESS_READ)+Examine+
 * UnLock -- returns 0 on success, -1 on any failure.      */
LONG cxbFileInfo(char *name __asm("a0"), struct CxbBase *b __asm("a6"))
{
    struct Ctx *c = findctx(b);
    APTR dos;
    BPTR   lock;
    struct FileInfoBlock *fib;
    LONG   ok = -1;
    UBYTE  fibmem[sizeof(struct FileInfoBlock) + 4];

    if (!c || !c->dos)
	return -1;
    dos = (struct DosBase *)c->dos;
    fib = (struct FileInfoBlock *)(((ULONG)fibmem + 3) & ~3);

    lock = __DosLock(dos, name, ACCESS_READ);
    if (!lock)
	return -1;
    if (__DosExamine(dos, lock, fib))
	ok = 0;
    __DosUnLock(dos, lock);
    return ok;
}

/* cxbMult (LVO -36): a * b.				    */
LONG cxbMult(LONG a __asm("d0"), LONG b __asm("d1"),
	     struct CxbBase *base __asm("a6"))
{
    return a * b;
}

/* cxbMult209 (LVO -42): a * 209.				    */
LONG cxbMult209(LONG a __asm("d0"), struct CxbBase *base __asm("a6"))
{
    return a * 0xd1;
}

/* the static EasyStruct + "(C) 1998 by Captain Crossbones"
 * gadget text live in cxb_lib.s				      */
extern const struct EasyStruct cxbeasy;

/* cxbRequest (LVO -48): EasyRequestArgs on the static
 * EasyStruct (window/IDCMP/args NULL).			    */
LONG cxbRequest(ULONG a __asm("a0"), ULONG c __asm("a1"),
		ULONG e __asm("a2"), struct CxbBase *b __asm("a6"))
{
    struct Ctx *ctx = findctx(b);
    if (!ctx || !ctx->intuition)
	return 0;
    return __EasyRequestArgs(ctx->intuition, NULL,
			     (struct EasyStruct *)&cxbeasy,
			     NULL, NULL);
}
