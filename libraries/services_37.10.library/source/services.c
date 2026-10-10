/*
 * services.library 37.10 (16.12.92) -- Commodore nipc service
 * registrar.  Reconstructed in C from the shipped binary.
 *
 * The library has exactly two public vectors:
 *   -30  SvcControl -- registers/resolves a service through
 *        nipc.library entities (call sequence decoded from the
 *        binary; nipc LVO semantics inferred -- no nipc fd
 *        ships with the NDK).
 *   -36  SvcFormat  -- RawDoFmt into a caller buffer.
 *
 * Library base (dataSize 0x9a):
 *   +0x22 nipc library base       +0x26 utility library base
 *   +0x2a SysBase                 +0x2e seglist
 *   +0x32 SignalSemaphore (InitSemaphore)
 *   +0x60 List of 342-byte nodes (NewList)
 *   +0x6c SignalSemaphore (Obtain/Release around nipc open)
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/semaphores.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <utility/tagitem.h>
#include <dos/dos.h>
#include <exec/memory.h>

struct SvcBase {
    struct Library	 lib;		/* +0x00..+0x21 */
    APTR		 nipc;		/* +0x22 */
    APTR		 utility;	/* +0x26 */
    struct ExecBase	*sys;		/* +0x2a */
    BPTR		 seg;		/* +0x2e */
    struct SignalSemaphore sem1;	/* +0x32 (34B)  */
    UBYTE		 pad1[0x60 - 0x54];
    struct List		 nodes;		/* +0x60 */
    struct SignalSemaphore sem2;	/* +0x6c (34B)  */
    UBYTE		 pad2[0x9a - 0x8e];
};

extern const UBYTE svcblob[];		/* {0x7800,"Services"}   */
extern const UBYTE utilityname[];	/* "utility.library"     */
extern const UBYTE nipcname[];		/* "nipc.library"        */
extern void SvcPutch(void);		/* moveb d0,a3@+         */

/* nipc.library LVOs used (no nipc fd ships with the NDK;
   names inferred from the call sites) */
#define NIPC_REG	(-66)	/* client register/unregister (a0)   */
#define NIPC_CREATE	(-126)	/* entity create, a0=taglist -> obj  */
#define NIPC_ALLOBJ	(-114)	/* request object alloc, a0=taglist  */
#define NIPC_FIND	(-138)	/* entity find/bind a0,a1,a2,a3&code */
#define NIPC_SUBMIT	(-150)	/* transaction submit a0,a1          */
#define NIPC_REL	(-144)	/* release entity ref a0             */
#define NIPC_DELETE	(-120)	/* destroy entity a1                 */
#define NIPC_CLEAN	(-132)	/* tag-based cleanup a0              */

/* service tag constants observed in the binary */
#define STAG_RES1	0x800b1004	/* -> &out slot for nipc-126      */
#define STAG_SVCBLOB	0x800b1001	/* -> {0x7800,"Services"}         */
#define STAG_SZ1	0x800b1101	/* -> 0x80                        */
#define STAG_SZ2	0x800b1102	/* -> 0x40                        */
#define CTAG_STR1	0x80000803	/* caller tag: string -> obj+0x6a */
#define CTAG_STR2	0x80000804	/* caller tag: string -> obj+0x8a */
#define CTAG_RESULT	0x80000802	/* caller tag: <- ti_Data result  */

#define SYSBASE	(*(struct ExecBase **)4)

/* generic single-address-arg LVO call on an explicit base */
#define __STR_(__x) #__x
#define __STR(__x) __STR_(__x)

#define __LVO_a0(__base,__lvo,__a0) ({\
  register APTR __p_base __asm("a6") = (APTR)(__base);\
  register APTR __p_a0 __asm("a0") = (APTR)(__a0);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(" __STR(__lvo) ":W)\n"\
  : "=r"(__p_res) : "a"(__p_base), "a"(__p_a0)\
  : "cc","memory","d1","a1");\
  __p_res; })

#define __LVO_a1(__base,__lvo,__a1) ({\
  register APTR __p_base __asm("a6") = (APTR)(__base);\
  register APTR __p_a1 __asm("a1") = (APTR)(__a1);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(" __STR(__lvo) ":W)\n"\
  : "=r"(__p_res) : "a"(__p_base), "a"(__p_a1)\
  : "cc","memory","d1","a0");\
  __p_res; })

/* OpenLibrary(name a1, version d0) */
#define __OpenLibrary(__name,__ver) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_name __asm("a1") = (APTR)(__name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(__ver);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
  : "=r"(__p_res) : "a"(__p_sys), "a"(__p_name), "r"(__p_ver)\
  : "cc","memory","d1","a0");\
  __p_res; })

#define __CloseLibrary(__lib) __LVO_a1(SYSBASE,-414,__lib)
#define __InitSemaphore(__sem) __LVO_a0(SYSBASE,-558,__sem)
#define __ObtainSemaphore(__sem) __LVO_a0(SYSBASE,-564,__sem)
#define __ReleaseSemaphore(__sem) __LVO_a0(SYSBASE,-570,__sem)
#define __RemHead(__list) __LVO_a0(SYSBASE,-258,__list)

#define __Alert(__num) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d7 __asm("d7") = (ULONG)(__num);\
  __asm volatile ("jsr %/a6@(-108:W)\n" : : "a"(__p_sys), "r"(__p_d7)\
  : "cc","memory","d0","d1","a0","a1"); })

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
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "a0" );})

#define __Remove(__node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_node __asm("a1") = (APTR)(__node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FindTagItem(__util,__tag,__list) ({\
  register APTR __p_base __asm("a6") = (APTR)(__util);\
  register ULONG __p_tag __asm("d0") = (ULONG)(__tag);\
  register APTR __p_list __asm("a0") = (APTR)(__list);\
  register struct TagItem * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-30:W)\n"\
  : "=r"(__p_res) : "a"(__p_base), "r"(__p_tag), "a"(__p_list)\
  : "cc","memory","d1","a1");\
  __p_res; })

/* ------------------------------------------------------------------ */

static void CloseLibs(struct SvcBase *b)
{
    __CloseLibrary(b->nipc);
    __CloseLibrary(b->utility);
}

struct Library *LibInit(struct SvcBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->sys = sys;
    base->seg = seglist;

    base->utility = (APTR)__OpenLibrary(utilityname, 37);
    if (!base->utility) {
	/* shipped path: close both bases (nipc field is clear-
	   allocated, so this is CloseLibrary(NULL)), then
	   Alert(0x3800c) and init fails */
	CloseLibs(base);
	__Alert(0x3800c);
	return 0;
    }

    __InitSemaphore(&base->sem1);

    /* NewList(&base->nodes) -- inlined in the original */
    base->nodes.lh_Head = (struct Node *)&base->nodes.lh_Tail;
    base->nodes.lh_Tail = 0;
    base->nodes.lh_TailPred = (struct Node *)&base->nodes.lh_Head;

    __InitSemaphore(&base->sem2);

    base->nipc = 0;
    return (struct Library *)base;
}

struct Library *LibOpen(struct SvcBase *base __asm("a6"))
{
    if (!base->nipc) {
	__ObtainSemaphore(&base->sem2);
	base->nipc = __OpenLibrary(nipcname, 0);
	if (base->nipc)
	    __LVO_a0(base->nipc, NIPC_REG, base);   /* register client */
	__ReleaseSemaphore(&base->sem2);
    }
    base->lib.lib_OpenCnt++;
    base->lib.lib_Flags &= ~LIBF_DELEXP;
    return base->nipc ? (struct Library *)base : 0;
}

BPTR LibExpunge(struct SvcBase *base __asm("a6"));

LONG LibClose(struct SvcBase *base __asm("a6"))
{
    base->lib.lib_OpenCnt--;
    if (base->lib.lib_Flags & LIBF_DELEXP) {
	if (!base->lib.lib_OpenCnt)
	    return (LONG)LibExpunge(base);
	base->lib.lib_Flags &= ~LIBF_DELEXP;
    }
    return 0;
}

static void FreeNodeList(struct SvcBase *base)
{
    struct Node *n;
    while ((n = (struct Node *)__RemHead(&base->nodes)))
	__FreeMem(n, 342);
}

BPTR LibExpunge(struct SvcBase *base __asm("a6"))
{
    BPTR seg;

    if (base->lib.lib_OpenCnt) {
	base->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    if (base->nipc)
	__LVO_a0(base->nipc, NIPC_REG, 0);	  /* unregister client */

    seg = base->seg;
    __Remove(&base->lib.lib_Node);
    CloseLibs(base);
    FreeNodeList(base);
    __FreeMem((UBYTE *)base - base->lib.lib_NegSize,
	      (ULONG)base->lib.lib_NegSize + base->lib.lib_PosSize);

    return seg;
}

/* ------------------------------------------------------------------ */
/* -30  SvcControl(name a0, str a1, out a2, taglist a3)		  */
/* ------------------------------------------------------------------ */

ULONG SvcControl(STRPTR name __asm("a0"), STRPTR str __asm("a1"),
		 APTR out __asm("a2"), struct TagItem *tags __asm("a3"),
		 struct SvcBase *svc __asm("a6"))
{
    ULONG t1out = 0, res2 = 0, code = 0, r12 = 0;
    ULONG r1, r2;
    struct TagItem tl1[3] = {
	{ STAG_RES1,    (ULONG)&t1out  },
	{ STAG_SVCBLOB, (ULONG)svcblob },
	{ TAG_END,      0              },
    };
    struct TagItem tl2[3] = {
	{ STAG_SZ1, 0x80 },
	{ STAG_SZ2, 0x40 },
	{ TAG_END,  0    },
    };

    r1 = __LVO_a0(svc->nipc, NIPC_CREATE, tl1);
    if (r1) {
	r2 = __LVO_a0(svc->nipc, NIPC_ALLOBJ, tl2);
	if (r2) {
	    if (out) {
		UBYTE *buf = (UBYTE *)__AllocMem(256, MEMF_PUBLIC|MEMF_CLEAR);
		if (buf) {
		    ULONG r3;
		    if (name) {
			UBYTE *d = buf; STRPTR s = name;
			while ((*d++ = *s++)) ;
		    }
		    {
			register APTR __p_a3 __asm("a3") = &code;
			register APTR __p_a2 __asm("a2") = (APTR)r1;
			register APTR __p_a1 __asm("a1") = (APTR)"Services";
			register APTR __p_a0 __asm("a0") = buf;
			register APTR __p_a6 __asm("a6") = svc->nipc;
			register ULONG __p_res __asm("d0");
			__asm volatile ("jsr %/a6@(-138:W)\n"
			    : "=r"(__p_res)
			    : "a"(__p_a6), "a"(__p_a0), "a"(__p_a1),
			      "a"(__p_a2), "a"(__p_a3)
			    : "cc","memory","d1");
			r3 = __p_res;
		    }
		    if (r3) {
			struct TagItem *t;
			UBYTE *o = (UBYTE *)r2;

			{   /* strcpy(str -> r2+0x2a) */
			    STRPTR s = str; UBYTE *d = o + 0x2a;
			    while ((*d++ = *s++)) ;
			}
			o[0x6a] = 0;
			o[0x8a] = 0;

			t = __FindTagItem(svc->utility, CTAG_STR1, tags);
			if (t) {
			    STRPTR s = (STRPTR)t->ti_Data;
			    UBYTE *d = o + 0x6a;
			    while ((*d++ = *s++)) ;
			}
			t = __FindTagItem(svc->utility, CTAG_STR2, tags);
			if (t) {
			    STRPTR s = (STRPTR)t->ti_Data;
			    UBYTE *d = o + 0x8a;
			    while ((*d++ = *s++)) ;
			}

			o[0x1c] = 100;
			*(UWORD *)(o + 0x42) = 10;

			{   /* nipc -150(r2, r1) */
			    register APTR __p_a1 __asm("a1") = (APTR)r1;
			    register APTR __p_a0 __asm("a0") = (APTR)r2;
			    register APTR __p_a6 __asm("a6") = svc->nipc;
			    __asm volatile ("jsr %/a6@(-150:W)\n"
				: : "a"(__p_a6), "a"(__p_a0), "a"(__p_a1)
				: "cc","memory","d0","d1");
			}
			__LVO_a0(svc->nipc, NIPC_REL, buf);

			code = *(ULONG *)(o + 0x1e);
			if (!code) {
			    register APTR __p_a3 __asm("a3") = &res2;
			    register APTR __p_a2 __asm("a2") = out;
			    register APTR __p_a1 __asm("a1") = o + 0x36;
			    register APTR __p_a0 __asm("a0") = buf;
			    register APTR __p_a6 __asm("a6") = svc->nipc;
			    register ULONG __p_res __asm("d0");
			    __asm volatile ("jsr %/a6@(-138:W)\n"
				: "=r"(__p_res)
				: "a"(__p_a6), "a"(__p_a0), "a"(__p_a1),
				  "a"(__p_a2), "a"(__p_a3)
				: "cc","memory","d1");
			    r12 = __p_res;
			}
		    }
		}
	    }
	    __FreeMem((UBYTE *)r2, 256);
	}
	__LVO_a1(svc->nipc, NIPC_DELETE, r1);
	__LVO_a0(svc->nipc, NIPC_CLEAN, tags);
    }

    {
	ULONG d7 = code ? code : res2;
	struct TagItem *t = __FindTagItem(svc->utility, CTAG_RESULT, tags);
	if (t)
	    t->ti_Data = d7;
    }

    return r12;
}

/* ------------------------------------------------------------------ */
/* -36  SvcFormat(dst, fmt, ...) -- RawDoFmt into a caller buffer	  */
/*									  */
/* Stack-arg function: dst = sp@(20), fmt = sp@(24),		  */
/* varargs = &sp@(28).  The putch hook appends the byte and		  */
/* advances the cursor in a3 (so RawDoFmt's a3 is the write pos).	  */
/* ------------------------------------------------------------------ */

ULONG SvcFormat(UBYTE *dst, STRPTR fmt, ...)
{
    register struct ExecBase * __p_sys __asm("a6") = SYSBASE;
    register STRPTR __p_a0 __asm("a0") = fmt;
    register APTR __p_a1 __asm("a1") = (APTR)(&fmt + 1);
    register APTR __p_a2 __asm("a2") = (APTR)SvcPutch;
    register UBYTE * __p_a3 __asm("a3") = dst;
    __asm volatile ("jsr %/a6@(-522:W)\n"
	: : "a"(__p_sys), "a"(__p_a0), "a"(__p_a1),
	    "a"(__p_a2), "a"(__p_a3)
	: "cc","memory","d0","d1");
    return 0;
}

/* -24 null vector (real function returning 0 at 0x1d2) */
LONG LibNull(void)
{
    return 0;
}
