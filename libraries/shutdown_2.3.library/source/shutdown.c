/*
**	shutdown.c -- shutdown.library 2.3
**
**	C reconstruction of the shipped SAS/C far-data binary.
**	A shutdown-hook registry: each opener gets a context
**	at base+48 holding lazily-opened dos/utility bases,
**	two SignalSemaphores and a MinList of named hook
**	nodes.
**
**	  -30	(stub, returns 0)
**	  -36	RegisterShutdown(callback@a0, name@a1) -> node
**	  -42	UnregisterShutdown(node@a0) -> 1/0
**	  -48	FireShutdown(flags@d0) -> run the hook list
**
**	dataSize 0xe0 (base + 176-byte context).
**
**	External calls: exec Remove/FreeMem/AllocVec/FreeVec,
**	AddTail, Remove, InitSemaphore, ObtainSemaphore,
**	AttemptSemaphore, ReleaseSemaphore, OpenLibrary,
**	CloseLibrary, FindTask.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/semaphores.h>
#include <exec/tasks.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <dos/dos.h>

/* context block at base+48 (dataSize 0xe0) */
struct Ctx
{
    UBYTE  pad0[20];
    struct Library *dos;		/* +68  dos.library base	    */
    struct Library *util;	/* +72  utility.library base	    */
    UBYTE  flag;		/* +76  registered flag	    */
    UBYTE  pad1[43];
    struct MinList list;		/* +120 hook node list	    */
    UBYTE  pad2[12];
    struct SignalSemaphore sem1;	/* +132 list semaphore	    */
    UBYTE  pad3[6];
    struct SignalSemaphore sem2;	/* +178 fire semaphore	    */
};					/* size ~0xd8 -> base+48.. */

struct SdBase
{
    struct Library b_Lib;	/* 0x00 standard		    */
    ULONG  b_Pad22;		/* 0x22				   */
    struct ExecBase *b_Sys;	/* 0x24 execbase		   */
    ULONG  b_Pad28;
    BPTR   b_Seg;			/* 0x2c seglist		   */
    struct Ctx b_Ctx;		/* 0x30 context		   */
};

/* a registered shutdown hook node */
struct Hook
{
    struct MinNode node;		/* +0  list linkage	    */
    UBYTE *name;			/* +8  name copy	    */
    APTR   callback;		/* +12 callback		    */
    UBYTE  namebuf[];		/* +16 inline name	    */
};

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* exec calls							  */
/* ------------------------------------------------------------------ */

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_d0), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

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

#define __InitSemaphore(__sem) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_sem __asm("a0") = (APTR)(__sem);\
  __asm volatile ("jsr %/a6@(-558:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_sem), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a1" );})

#define __ObtainSemaphore(__sem) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_sem __asm("a0") = (APTR)(__sem);\
  __asm volatile ("jsr %/a6@(-564:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_sem), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a1" );})

#define __AttemptSemaphore(__sem) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_sem __asm("a0") = (APTR)(__sem);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-576:W)\n"\
		   : "=d"(__p_d0)\
		   : "a"(__p_sem), "a"(__p_sys)\
		   : "cc", "memory", "d1","a1" );\
  __p_d0;})

#define __ReleaseSemaphore(__sem) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_sem __asm("a0") = (APTR)(__sem);\
  __asm volatile ("jsr %/a6@(-570:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_sem), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a1" );})

#define __AddTail(__list, ___node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_list __asm("a0") = (APTR)(__list);\
  register APTR __p_node __asm("a1") = (APTR)(___node);\
  __asm volatile ("jsr %/a6@(-246:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_list), "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1" );})

#define __Remove2(__node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_node __asm("a1") = (APTR)(__node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0","a0" );})

#define __AllocVec(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-684:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeVec(__blk) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  __asm volatile ("jsr %/a6@(-690:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0" );})

/* ------------------------------------------------------------------ */
/* standard vectors						  */
/* ------------------------------------------------------------------ */

static void ctx_init(struct Ctx *c)
{
    static const char dosn[] = "dos.library";
    static const char utiln[] = "utility.library";
    c->dos = (struct Library *)__OpenLibrary(SYSBASE, dosn, 33);
    c->util = (struct Library *)__OpenLibrary(SYSBASE, utiln, 33);
    c->flag = 0;
    c->list.mlh_Head = (struct MinNode *)&c->list.mlh_Tail;
    c->list.mlh_TailPred = (struct MinNode *)&c->list.mlh_Head;
    __InitSemaphore(&c->sem1);
    __InitSemaphore(&c->sem2);
}

static void ctx_free(struct Ctx *c)
{
    if (c->dos)
	__CloseLibrary(SYSBASE, c->dos);
    if (c->util)
	__CloseLibrary(SYSBASE, c->util);
}

struct Library *LibOpen(struct SdBase *base __asm("a6"))
{
    base->b_Lib.lib_OpenCnt++;
    base->b_Lib.lib_Flags &= ~LIBF_DELEXP;
    if (base->b_Lib.lib_OpenCnt == 1)
	ctx_init(&base->b_Ctx);
    return (struct Library *)base;
}

BPTR LibExpunge(struct SdBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->b_Lib.lib_OpenCnt) {
	base->b_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    ctx_free(&base->b_Ctx);
    seg = base->b_Seg;
    __Remove(sys, &base->b_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->b_Lib.lib_NegSize,
	      (ULONG)base->b_Lib.lib_NegSize + base->b_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct SdBase *base __asm("a6"))
{
    if (--base->b_Lib.lib_OpenCnt == 0) {
	ctx_free(&base->b_Ctx);
	if (base->b_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* public functions						  */
/* ------------------------------------------------------------------ */

/* -30: stub, returns 0						*/
LONG sdStub(void)
{
    return 0;
}

/* -36 RegisterShutdown(callback@a0, name@a1) -> node	*/
struct Hook *RegisterShutdown(APTR cb __asm("a0"),
			      const char *name __asm("a1"),
			      struct SdBase *b __asm("a6"))
{
    struct Ctx *c = &b->b_Ctx;
    struct Hook *h;
    ULONG   len;

    if (c->flag || !cb || !name)
	return 0;
    for (len = 0; name[len]; )
	len++;
    h = (struct Hook *)__AllocVec(16 + len + 1, 0x00010001);
    if (!h)
	return 0;
    __ObtainSemaphore(&c->sem1);
    h->callback = cb;
    h->name = h->namebuf;
    {
	UBYTE *d = h->namebuf;
	const UBYTE *s = (const UBYTE *)name;
	while ((*d++ = *s++))
	    ;
    }
    __AddTail(&c->list, &h->node);
    __ReleaseSemaphore(&c->sem1);
    return h;
}

/* -42 UnregisterShutdown(node@a0) -> 1/0			*/
LONG UnregisterShutdown(struct Hook *node __asm("a0"),
			struct SdBase *b __asm("a6"))
{
    struct Ctx *c = &b->b_Ctx;
    struct MinNode *p;

    if (c->flag || !node)
	return 0;
    __ObtainSemaphore(&c->sem1);
    for (p = c->list.mlh_Head; p->mln_Succ; p = p->mln_Succ) {
	if (p == (struct MinNode *)node) {
	    __Remove2(node);
	    __FreeVec(node);
	    __ReleaseSemaphore(&c->sem1);
	    return 1;
	}
    }
    __ReleaseSemaphore(&c->sem1);
    return 0;
}

/* -48 FireShutdown(flags@d0): grab the fire semaphore and
 * run every registered hook's callback.			    */
LONG FireShutdown(ULONG flags __asm("d0"), struct SdBase *b __asm("a6"))
{
    struct Ctx *c = &b->b_Ctx;
    struct MinNode *p;

    if (!__AttemptSemaphore(&c->sem2))
	return 0;
    for (p = c->list.mlh_Head; p->mln_Succ; p = p->mln_Succ) {
	struct Hook *h = (struct Hook *)p;
	if (h->callback) {
	    /* call hook->callback(flags) through a5-based
	     * convention like the original's thunk		*/
	    register APTR a0 __asm("a0") = h->callback;
	    register ULONG d0 __asm("d0") = flags;
	    __asm volatile ("jsr (%/a0)\n"
			    : "+d"(d0)
			    : "a"(a0)
			    : "cc","memory","d1","d2","a1","a2");
	}
    }
    __ReleaseSemaphore(&c->sem2);
    return 1;
}
