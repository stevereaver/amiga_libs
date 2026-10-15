/*
**	patchtest.c -- patchtest.library V1.00 (c)1996 Hans B|hler
**	(part of dev/misc/Palis.lha)
**
**	C reconstruction of the shipped binary.
**
**	A minimal test library: every LibOpen OpenLibrary()s
**	"intuition.library" (version 0, result unchecked -- the
**	shipped init returns success even on failure), every
**	LibClose CloseLibrary()s it, and the single public vector
**	calls intuition's DisplayBeep(NULL) through the stored base.
**
**	The original is a SAS/C build with the "private data copy
**	per opener" runtime (each Open duplicates the jump table +
**	library base + data tail).  Semantically that only means
**	one OpenLibrary per open and one CloseLibrary per close,
**	which this reconstruction keeps; see okf/findings.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

struct PTBase			/* dataSize 0x2a		    */
{
    struct Library pt_Lib;	/* 0x00				    */
    BPTR  pt_SegList;		/* 0x22				    */
    struct Library *pt_Intuition; /* 0x26 intuition base	    */
};

extern const char s_intuition[];	/* "intuition.library"    */

/* ------------------------------------------------------------------ */
/* Exec / intuition LVO calls					  */
/* ------------------------------------------------------------------ */

#define __OpenLibrary(__sys, ___name, ___ver) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register const char * __p_name __asm("a1") = (const char *)(___name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(___ver);\
  register void * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-408:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "d"(__p_ver), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define __CloseLibrary(__sys, ___lib) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_lib __asm("a1") = (void *)(___lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
		   : : "a"(__p_lib), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__sys, ___blk, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_blk __asm("a1") = (void *)(___blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

/* intuition.library LVO -96 = DisplayBeep(screen a0) */
#define __DisplayBeep(__intu, ___screen) ({\
  register void * __p_intu __asm("a6") = (void *)(__intu);\
  register void * __p_screen __asm("a0") = (void *)(___screen);\
  __asm volatile ("jsr %/a6@(-96:W)\n"\
		   : : "a"(__p_screen), "a"(__p_intu)\
		   : "cc", "memory", "d0", "d1", "a1" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct PTBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->pt_SegList = seglist;

    return (struct Library *)base;
}

struct Library *LibOpen(struct PTBase *base __asm("a6"))
{
    base->pt_Lib.lib_OpenCnt++;
    base->pt_Lib.lib_Flags &= ~LIBF_DELEXP;
    /* the shipped per-open init ignores OpenLibrary failure */
    base->pt_Intuition =
	(struct Library *)__OpenLibrary(SYSBASE, s_intuition, 0);

    return (struct Library *)base;
}

BPTR LibExpunge(struct PTBase *base __asm("a6"));

LONG LibClose(struct PTBase *base __asm("a6"))
{
    BPTR seg = 0;

    /* per-open cleanup: CloseLibrary only when it was opened */
    if (base->pt_Intuition)
	__CloseLibrary(SYSBASE, base->pt_Intuition);

    if (!--base->pt_Lib.lib_OpenCnt) {
	if (base->pt_Lib.lib_Flags & LIBF_DELEXP)
	    seg = LibExpunge(base);
    }

    return (LONG)seg;
}

BPTR LibExpunge(struct PTBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->pt_Lib.lib_OpenCnt) {
	base->pt_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->pt_SegList;
    __Remove(sys, &base->pt_Lib.lib_Node);
    __FreeMem(sys, (UBYTE *)base - base->pt_Lib.lib_NegSize,
	      (ULONG)base->pt_Lib.lib_NegSize + base->pt_Lib.lib_PosSize);

    return seg;
}

/* ------------------------------------------------------------------ */
/* public vector							  */
/* ------------------------------------------------------------------ */

/*
**	PTBeep (LVO -30)
**
**	Calls intuition's DisplayBeep(NULL) through the stored
**	intuition base -- like the original, no NULL check: if the
**	per-open OpenLibrary failed this dereferences NULL.
*/
LONG PTBeep(struct PTBase *base __asm("a6"))
{
    __DisplayBeep(base->pt_Intuition, NULL);

    return 0;
}
