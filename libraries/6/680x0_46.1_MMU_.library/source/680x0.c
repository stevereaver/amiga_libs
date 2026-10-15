/*
**	680x0.c -- 680x0.library 40.4 (The MMU.lib development group, THOR)
**
**	C reconstruction of the shipped binary
**	($VER: 680x0.library 40.4 (25.11.2001) (c) 1999,2001 The MMU.lib
**	 development group, THOR).
**
**	680x0.library is a small dispatcher/driver loader: its init
**	routine detects the installed CPU from ExecBase->AttnFlags (with
**	a supervisor-mode PCR probe for the 68060, see cpuprobe.s),
**	opens the matching CPU-specific driver library "680N0.library"
**	(68020/68030/68040/68060.library, version >= 46) and refuses to
**	stay resident when the driver cannot be loaded.
**
**	Public vectors: CPUType and FPUType report the CPU/FPU model as
**	an ASCII digit ('0','1','2','3','4','6'), MMUType is forwarded
**	to mmu.library/GetMMUType (LVO -54) and SetFPUExceptions is
**	forwarded to the CPU driver's FPUControl (LVO -222).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */
#include <inline/exec.h>

/* ------------------------------------------------------------------ */
/* release constants							  */
/* ------------------------------------------------------------------ */

#define LIB_VERSION	46	/* this library's version		  */
#define LIB_REVISION	1	/* this library's revision		  */
#define DRIVER_VERSION	46	/* minimum version of the 680N0 driver   */
#define APOLLO_CHECK	0	/* no Apollo-core detection before V47	  */

/* ------------------------------------------------------------------ */
/* private library base (InitTable dataSize is 0x40)			  */
/* ------------------------------------------------------------------ */

struct MC680X0Base
{
    struct Library	b_Lib;	    /* 0x00 standard library node (34 b.)  */
    UWORD		b_pad22;    /* 0x22 alignment pad		    */
    ULONG		b_Magic;    /* 0x24 'THOR' signature		    */
    ULONG		b_pad28;    /* 0x28 unused			    */
    BPTR		b_SegList;  /* 0x2c seglist from LibInit	    */
    ULONG		b_pad30;    /* 0x30 unused			    */
    ULONG		b_pad34;    /* 0x34 unused			    */
    struct ExecBase    *b_SysBase;  /* 0x38 cached ExecBase		    */
    UBYTE		b_CPUType;  /* 0x3c CPU type ASCII digit	    */
    UBYTE		b_pad3d[3]; /* 0x3d unused			    */
};				    /* total: 0x40 bytes		    */

/* strings in the data hunk (680x0_lib.s) */
extern const char libname[];	/* "680x0.library"			  */
extern const char mmuname[];	/* "mmu.library"			  */
extern const char idstr[];	/* id string				  */

/* supervisor-mode CPU probe (cpuprobe.s) */
extern ULONG Probe060(void);

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

/* 680N0.library/FPUControl(flags d0, mask d1) -- LVO -222 */
#define __FPUControl_base(__in_base, ___flags, ___mask) ({\
  register void * __p__in_base __asm("a6") = (void *)(__in_base);\
  register ULONG __v0 __asm("d0") = (ULONG)(___flags);\
  register ULONG __v1 __asm("d1") = (ULONG)(___mask);\
  __asm volatile (\
		   "jsr %/a6@(-222:W)\n"\
		   : "+d"(__v0), "+d"(__v1)\
		   : "a"(__p__in_base)\
		   : "fp0", "fp1", "cc", "memory", "a0", "a1" );\
  __v0;})

/* ------------------------------------------------------------------ */
/* OpenCPUDriver -- open the CPU specific driver library.		  */
/* Builds "680N0.library" (N = detected CPU digit) on the stack and	  */
/* opens it with DRIVER_VERSION as the minimum acceptable version.	  */
/* ------------------------------------------------------------------ */

static struct Library *OpenCPUDriver(struct MC680X0Base *base)
{
    char  name[32];
    char *s = (char *)libname;
    char *d = name;

#if APOLLO_CHECK
    if (base->b_CPUType > '9')
        return NULL;		/* 'A' (Apollo core): no driver to load */
#endif

    while ((*d++ = *s++) != 0)	/* copy "680x0.library" */
	;
    name[3] = (char)base->b_CPUType;	/* 'x' -> CPU digit	*/

    return __OpenLibrary_base(base->b_SysBase, name, DRIVER_VERSION);
}

/* ------------------------------------------------------------------ */
/* LibInit -- init vector, called by MakeLibrary/InitResident with	  */
/* d0 = library base, a0 = seglist, a6 = SysBase.  Fills the library	  */
/* node by hand (the InitTable carries no InitStruct data), detects	  */
/* the CPU, then loads the CPU driver.  On any failure the library	  */
/* frees its own base memory and init fails.				  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct MC680X0Base *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    register struct ExecBase *sys __asm("a6");	/* entry a6 = SysBase */
    UBYTE attn;
    char  cpu;

    base->b_SysBase = sys;
    base->b_SegList = seglist;

    /* needs Kickstart 2.0 (exec V36) or better */
    if (sys->LibNode.lib_Version < 36)
	goto fail;

    /* highest CPU flag in AttnFlags wins */
    attn = (UBYTE)sys->AttnFlags;
    cpu  = '0';
    if (attn & AFF_68010) cpu = '1';
    if (attn & AFF_68020) cpu = '2';
    if (attn & AFF_68030) cpu = '3';
    if (attn & AFF_68040) cpu = '4';
    if (cpu == '4' && (LONG)__Supervisor_base(sys, Probe060))
	cpu = '6';			/* PCR readable -> 68060	    */

    base->b_CPUType              = (UBYTE)cpu;
    base->b_Lib.lib_Node.ln_Type = NT_LIBRARY;
    base->b_Lib.lib_Flags        = LIBF_SUMUSED | LIBF_CHANGED;
    base->b_Lib.lib_Node.ln_Name = (char *)libname;
    base->b_Lib.lib_IdString     = (char *)idstr;
    base->b_Lib.lib_Version      = LIB_VERSION;
    base->b_Lib.lib_Revision     = LIB_REVISION;
    base->b_Magic                = 'THOR';

    if (OpenCPUDriver(base))
	return (struct Library *)base;

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
struct Library *LibOpen(struct MC680X0Base *base __asm("a6"))
{
    base->b_Lib.lib_Flags &= ~LIBF_DELEXP;
    base->b_Lib.lib_OpenCnt++;

    return (struct Library *)base;
}

/* LibClose (LVO -12): decrement the open count, never expunges */
LONG LibClose(struct MC680X0Base *base __asm("a6"))
{
    if (base->b_Lib.lib_OpenCnt)
	base->b_Lib.lib_OpenCnt--;

    return 0;
}

/* LibExpunge (LVO -18): the dispatcher never expunges once resident */
LONG LibExpunge(struct MC680X0Base *base __asm("a6"))
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

/* CPUType (LVO -30): ASCII digit of the detected CPU ('0'..'6') */
char CPUType(struct MC680X0Base *base __asm("a6"))
{
    return (char)base->b_CPUType;
}

/* FPUType (LVO -36): 0, '1' (68881), '2' (68882) or the CPU digit for
** the integrated FPUs of the 68040/68060 */
char FPUType(struct MC680X0Base *base __asm("a6"))
{
    UBYTE attn = (UBYTE)base->b_SysBase->AttnFlags;
    char  fpu  = 0;

    if (attn & AFF_FPU40)
	fpu = (char)base->b_CPUType;	/* integrated 040/060 FPU	*/
    else if (attn & AFF_68882)
	fpu = '2';
    else if (attn & AFF_68881)
	fpu = '1';

    return fpu;
}

/* MMUType (LVO -42): forwarded to mmu.library/GetMMUType, 0 if the
** mmu.library cannot be opened */
char MMUType(struct MC680X0Base *base __asm("a6"))
{
    struct ExecBase *sys = base->b_SysBase;
    struct Library  *mmu;
    ULONG            res = 0;

    mmu = __OpenLibrary_base(sys, (char *)mmuname, 0);
    if (mmu) {
	res = __GetMMUType_base(mmu);
	__CloseLibrary_base(sys, mmu);
    }

    return (char)res;
}

/* SetFPUExceptions (LVO -48): forwarded to the CPU driver's
** FPUControl (LVO -222).  Returns 0 when no suitable driver (version
** >= 40, vector table covering LVO -222) is installed. */
ULONG SetFPUExceptions(ULONG flags __asm("d0"),
		       ULONG mask __asm("d1"),
		       struct MC680X0Base *base __asm("a6"))
{
    struct ExecBase *sys = base->b_SysBase;
    struct Library  *drv;
    ULONG            res = 0;

    drv = OpenCPUDriver(base);
    if (drv) {
	if (drv->lib_Version >= 40 && drv->lib_NegSize >= 0xde)
	    res = __FPUControl_base(drv, flags, mask);
	__CloseLibrary_base(sys, drv);
    }

    return res;
}
