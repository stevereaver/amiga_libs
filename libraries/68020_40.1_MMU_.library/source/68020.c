/*
**	68020.c -- 68020.library 40.1 (MMU) (The MMU.lib development
**	group, THOR, (4.12.99)).
**
**	C reconstruction of the shipped binary
**	($VER: 68020.library 40.1 (4.12.99) (c) 1999 The MMU.lib
**	 development group, THOR).
**
**	68020.library is the MMULib CPU driver for the 68020.  Its
**	init routine refuses to stay resident on anything but a plain
**	68020 (AFF_68020 set, AFF_68030 clear -- the flags are
**	cumulative, so 030/040/060 all carry bit 2), patches a set of
**	exec vectors with SetFunction (CacheClearU trampolines, a
**	hardware-interrupt-based GetMsg, an Alert-on-AddConfigDev and
**	a ColdReboot hook that shuts the PMMU down), patches
**	input.device BeginIO (icache flush on IND_ADDHANDLER) and
**	expansion.library AddConfigDev, and -- only when a 68881/882
**	FPU is present -- installs TRAP #0..#6 exception handlers.
**
**	The only real public vector besides the standard ones is
**	FPUControl at LVO -222 (get/set the FPU flags byte at lib+34).
**	LVOs -30..-216 are dead-vector stubs raising
**	Alert(0x3f000001) and returning 0.
**
**	The patch stubs, the supervisor code (pmove/movec/rte) and the
**	68881 exception handlers live in 68020_patch.s.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/alerts.h>
#include <dos/dos.h>		/* BPTR */
#include <inline/exec.h>

/* ------------------------------------------------------------------ */
/* private library base (InitTable dataSize is 0x70)			  */
/* ------------------------------------------------------------------ */

struct Lib68020Base
{
    struct Library	b_Lib;	    /* 0x00 standard library node (34 b.)  */
    UBYTE		b_FPUFlags; /* 0x22 FPUControl flag byte	    */
    UBYTE		b_pad23;    /* 0x23 unused			    */
    ULONG		b_Magic;    /* 0x24 'THOR' signature		    */
    UWORD		b_pad28;    /* 0x28 unused			    */
    UBYTE		b_pad2a;    /* 0x2a unused			    */
    UBYTE		b_CPUFlags; /* 0x2b bit0: no 68881, bit1: no MMU */
    BPTR		b_SegList;  /* 0x2c seglist from LibInit	    */
    struct ExecBase    *b_SysBase;  /* 0x30 cached ExecBase		    */
    struct Library     *b_Utility;  /* 0x34 utility.library base	    */
    struct Library     *b_Expansion;/* 0x38 expansion.library base	    */
    ULONG		b_pad3c;    /* 0x3c unused			    */
    ULONG		b_pad40;    /* 0x40 unused			    */
    struct Library     *b_MMU;	    /* 0x44 mmu.library base		    */
    struct Node	       *b_Input;    /* 0x48 input.device (FindName)	    */
    ULONG		b_pad4c;    /* 0x4c unused			    */
    ULONG		b_TrapSave[7];/* 0x50..0x68 saved TRAP vectors	    */
    ULONG		b_pad6c;    /* 0x6c unused			    */
};				    /* total: 0x70 bytes		    */

#define CPUFLAG_NO68881	1	/* b_CPUFlags: no 68881/68882 present   */
#define CPUFLAG_NOMMU	2	/* b_CPUFlags: mmu.library type == NONE */

/* strings and patch tables in the data hunk (68020_lib.s) */
extern const char libname[];	/* "68020.library"			  */
extern const char idstr[];	/* id string				  */
extern const char expansionname[];
extern const char utilityname[];
extern const char mmuname[];
extern const char inputname[];

extern UWORD patchtable_a[];	/* ColdReboot patch			  */
extern UWORD patchtable_b[];	/* exec + input.device + expansion	  */
extern UWORD patchtable_c[];	/* TRAP #0-6 exception vectors	  */

/* slots inside the patch region (68020_patch.s) */
extern ULONG patch_sysbase;	/* ExecBase copy for the non-exec stubs */
extern ULONG patch_lib;		/* this library's base		  */

/* asm helpers (68020_patch.s) */
extern void  LibAlert(ULONG code __asm("d0"),
		      struct Lib68020Base *base __asm("a6"));
extern void  InstallExcVecs(struct Lib68020Base *base __asm("a6"));

/* ------------------------------------------------------------------ */
/* third-party LVO calls (not in the NDK inline headers)		  */
/* ------------------------------------------------------------------ */

/* mmu.library/GetMMUType() -- LVO -54 */
#define __GetMMUType_base(__in_base) ({\
  register void * __p__in_base __asm("a6") = (void *)(__in_base);\
  register ULONG __v0 __asm("d0");\
  __asm volatile (\
		   "jsr %/a6@(-54:W)\n"\
		   : "=d"(__v0)\
		   : "a"(__p__in_base)\
		   : "fp0", "fp1", "cc", "memory", "d1", "a0", "a1" );\
  __v0;})

/* ------------------------------------------------------------------ */
/* PatchTable / UnpatchTable -- drive the {liboff, vecoff, fnoff}	  */
/* record tables through exec/SetFunction.				  */
/* ------------------------------------------------------------------ */

static void PatchTable(struct Lib68020Base *base, UWORD *tab)
{
    UBYTE		  *region = (UBYTE *)*(ULONG *)tab;
    register struct ExecBase *sys  = base->b_SysBase;

    tab += 2;
    __Disable_base(sys);
    while (*tab) {
	struct Library *tlib = *(struct Library **)((UBYTE *)base + tab[0]);
	LONG		vecoff = (LONG)(WORD)tab[1];
	UBYTE	       *fn     = region + tab[2];
	APTR		old;

	tab += 3;
	if (tlib) {
	    old = __SetFunction_base(sys, tlib, vecoff, fn);
	    *(APTR *)(fn - 4) = old;		/* slot before the stub */
	} else {
	    *(ULONG *)fn = 0;	/* shipped quirk: stores at fn, not fn-4 */
	}
    }
    __Enable_base(sys);
}

static void UnpatchTable(struct Lib68020Base *base, UWORD *tab)
{
    UBYTE		  *region = (UBYTE *)*(ULONG *)tab;
    register struct ExecBase *sys  = base->b_SysBase;

    tab += 2;
    __Disable_base(sys);
    while (*tab) {
	struct Library *tlib = *(struct Library **)((UBYTE *)base + tab[0]);
	LONG		vecoff = (LONG)(WORD)tab[1];
	UBYTE	       *fn     = region + tab[2];
	APTR		old    = *(APTR *)(fn - 4);

	tab += 3;
	if (old && tlib)
	    __SetFunction_base(sys, tlib, vecoff, old);
    }
    __Enable_base(sys);
}

/* ------------------------------------------------------------------ */
/* LibInit -- init vector, called by MakeLibrary/InitResident with	  */
/* d0 = library base, a0 = seglist, a6 = SysBase.  Fills the library	  */
/* node by hand (the InitTable carries no InitStruct data), opens the	  */
/* support libraries, installs the vector patches and reports the	  */
/* MMU type.  On any failure the library frees its own base memory	  */
/* and init fails.							  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct Lib68020Base *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    struct ExecBase *sys;
    UBYTE	     attn;

    /* entry a6 = SysBase; keep it in a plain variable so the
    ** LVO stubs can reload a6 as needed (LibAlert uses a6 for the
    ** library base). */
    __asm volatile ("movel %%a6,%0" : "=r"(sys));

    base->b_SysBase = sys;
    base->b_SegList = seglist;

    /* exactly a 68020: AFF_68030 must be clear, AFF_68020 set */
    attn = (UBYTE)sys->AttnFlags;
    if (attn & AFF_68030)
	goto fail;
    if (!(attn & AFF_68020))
	goto fail;
    if (!(attn & AFF_68881))
	base->b_CPUFlags |= CPUFLAG_NO68881;

    base->b_Lib.lib_Node.ln_Type = NT_LIBRARY;
    base->b_Lib.lib_Flags        = LIBF_SUMUSED | LIBF_CHANGED;
    base->b_Lib.lib_Node.ln_Name = (char *)libname;
    base->b_Lib.lib_IdString     = (char *)idstr;
    base->b_Lib.lib_Version      = 40;
    base->b_Lib.lib_Revision     = 1;
    base->b_Magic                = 'THOR';

    base->b_Expansion = __OpenLibrary_base(sys, (char *)expansionname, 37);
    if (!base->b_Expansion) {
	LibAlert(0x3f02800a, base);
	goto cleanup;
    }

    base->b_Utility = __OpenLibrary_base(sys, (char *)utilityname, 37);
    if (!base->b_Utility) {
	LibAlert(0x3f02800c, base);
	goto cleanup;
    }

    __Forbid_base(sys);
    base->b_Input = __FindName_base(sys, &sys->DeviceList,
				    (char *)inputname);
    __Permit_base(sys);
    if (!base->b_Input) {
	LibAlert(0x3f028021, base);
	goto cleanup;
    }

    /* store the region slots and install the ColdReboot patch */
    patch_sysbase = (ULONG)sys;
    patch_lib     = (ULONG)base;
    PatchTable(base, patchtable_a);

    base->b_MMU = __OpenLibrary_base(sys, (char *)mmuname, 0);
    if (!base->b_MMU) {
	LibAlert(0x3f02803e, base);
	UnpatchTable(base, patchtable_a);
	goto cleanup;
    }

    if (__GetMMUType_base(base->b_MMU) == 0)
	base->b_CPUFlags |= CPUFLAG_NOMMU;

    if (!(base->b_CPUFlags & CPUFLAG_NO68881))
	InstallExcVecs(base);

    PatchTable(base, patchtable_b);

    return (struct Library *)base;

cleanup:
    if (base->b_MMU)
	__CloseLibrary_base(sys, base->b_MMU);
    if (base->b_Utility)
	__CloseLibrary_base(sys, base->b_Utility);
    if (base->b_Expansion)
	__CloseLibrary_base(sys, base->b_Expansion);
fail:
    {
	UBYTE *block = (UBYTE *)base - base->b_Lib.lib_NegSize;
	ULONG  size  = (ULONG)base->b_Lib.lib_NegSize +
		       (ULONG)base->b_Lib.lib_PosSize;

	__FreeMem_base(sys, block, size);
    }
    return NULL;
}

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/* LibOpen (LVO -6): bump open count, clear a pending delayed expunge */
struct Library *LibOpen(struct Lib68020Base *base __asm("a6"))
{
    base->b_Lib.lib_Flags &= ~LIBF_DELEXP;
    base->b_Lib.lib_OpenCnt++;

    return (struct Library *)base;
}

/* LibClose (LVO -12): decrement the open count, never expunges */
LONG LibClose(struct Lib68020Base *base __asm("a6"))
{
    if (base->b_Lib.lib_OpenCnt)
	base->b_Lib.lib_OpenCnt--;

    return 0;
}

/* LibExpunge (LVO -18): stub -- the driver never expunges once resident */
LONG LibExpunge(struct Lib68020Base *base __asm("a6"))
{
    return 0;
}

/* LibNull (LVO -24, ExtFunc/reserved): always returns 0 */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* public functions							  */
/* ------------------------------------------------------------------ */

/* FPUControl (LVO -222): atomically merge "flags" into the byte at
** lib+34 under mask and return the previous value.  The corresponding
** entry in the 680x0 dispatcher documents the same call. */
ULONG FPUControl(ULONG flags __asm("d0"),
		 ULONG mask __asm("d1"),
		 struct Lib68020Base *base __asm("a6"))
{
    ULONG old;

    flags &= mask;
    __Disable_base(base->b_SysBase);
    old = (ULONG)base->b_FPUFlags;
    base->b_FPUFlags = (UBYTE)((old & ~mask) | flags);
    __Enable_base(base->b_SysBase);

    return old;
}
