/*
**	loader.c -- C reconstruction of the Phase5
**	68040.library 46.5 loader stub
**	(68040.library 46.5 (19.10.99) © 1994-1999 by Phase5,
**	 written by Ralph Schmidt)
**
**	Pure loader/redirection stub: only the four system vectors
**	exist (Open/Close/Expunge/ExtFunc -- the latter three are all
**	null stubs in the original; Close does NOT decrement the
**	open count, a deliberate keep-resident leak).
**
**	Init logic recovered from the disassembly:
**	  - DOSBase = OpenLibrary("dos.library",0), fail if NULL
**	  - requires AFB_68040 set in ExecBase->AttnFlags, else fail
**	  - runs a Supervisor() probe (`movec pcr,a1` under an
**	    illegal-instruction handler; PCR is a 68060-only
**	    register, so the probe returns 1 on a 68060 and 0 on a
**	    real 68040):
**	      probe == 1 (68060): OpenLibrary("68060.library",0) is
**	          stored in pb_OpenLib and init returns the base --
**	          LibOpen hands out the 060 support library instead
**	      probe == 0 (real 68040): LoadSeg+InitResident of
**	          "LIBS:68040new.library", else "LIBS:68040old.library";
**	          init then returns NULL either way -- the stub dies
**	          but the preloaded library stays resident
**
**	LibOpen returns pb_OpenLib when set, so an
**	OpenLibrary("68040.library") caller transparently gets the
**	real library's base (and its full LVO table) instead.
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/libraries.h>
#include <exec/resident.h>
#include <dos/dos.h>

/*
 * Library base (dataSize 0x38 = 56 bytes), recovered layout:
 *   +0x00  struct Library
 *   +0x22  private flag byte (bclr #3 on every LibOpen)
 *   +0x24  SysBase
 *   +0x28  openLib  (OpenLibrary("68060.library") result)
 *   +0x2c  loadLib  (LoadSeg+InitResident result)
 *   +0x30  segList
 *   +0x34  DOSBase
 */
struct P5Base
{
    struct Library      pb_Lib;     /* 0x00 */
    UBYTE               pb_Flags;   /* 0x22 private flag byte */
    UBYTE               pb_pad23;   /* 0x23 */
    struct ExecBase    *pb_SysBase; /* 0x24 */
    struct Library     *pb_OpenLib; /* 0x28 */
    struct Library     *pb_LoadLib; /* 0x2c */
    BPTR                pb_SegList; /* 0x30 */
    struct DosLibrary  *pb_DOSBase; /* 0x34 */
};                                  /* 0x38 */

/* exec proto macros take the library base from a `base` variable
   in scope at every call site; dos calls use helpers.s shims
   (inline/dos.h evaluates DOS_BASE_NAME at file scope) */
#define EXEC_BASE_NAME (base->pb_SysBase)
#include <proto/exec.h>

/* string labels emitted by loader_lib.s (C 'x' -> asm '_x') */
extern const char str_68060[];      /* "LIBS:68060.library"    */
extern const char str_68040old[];   /* "LIBS:68040old.library" */
extern const char str_68040new[];   /* "LIBS:68040new.library" */
extern const char str_dos[];        /* "dos.library"           */

/* asm helpers (helpers.s) */
ULONG ProbeBody(void);           /* supervisor func: movec pcr probe */
APTR InitResidentD0(struct ExecBase *eb __asm("a6"),
                    APTR res __asm("a1"), ULONG seglist __asm("d0"));
BPTR DOSLoadSeg(struct DosLibrary *db __asm("a6"), const char *name __asm("d1"));
BOOL DOSUnLoadSeg(struct DosLibrary *db __asm("a6"), BPTR seg __asm("d1"));

struct Library *LibInit(struct P5Base *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
LONG LibClose(void);
LONG LibExpunge(void);
LONG LibNull(void);

/*
 * Scan a LoadSeg()d seglist for a Resident structure: each segment
 * starts with a BPTR to the next segment, the long before the
 * segment holds the allocation size; words are scanned for 0x4afc
 * whose rt_MatchTag (@rt+2) points back at the matchword.
 */
static struct Resident *FindRomTag(BPTR seglist)
{
    ULONG seg = (ULONG)seglist;

    while (seg) {
        UBYTE *addr  = (UBYTE *)(seg << 2);         /* BPTR -> addr */
        LONG   count = *(LONG *)(addr - 4);         /* block size   */
        UWORD *p     = (UWORD *)(addr + 4);         /* hunk data    */

        seg = *(ULONG *)addr;                       /* next segment */
        for (;;) {
            count -= 2;
            if (count <= 0)
                break;
            if (*p++ == RTC_MATCHWORD) {
                struct Resident *rt = (struct Resident *)(p - 1);
                if (*(ULONG *)(((UBYTE *)rt) + 2) == (ULONG)rt)
                    return rt;
            }
        }
    }
    return NULL;
}

/*
 * LoadSeg + InitResident helper.  The original is called with the
 * name pointing past the "LIBS:" prefix and subtracts 5 to get the
 * path back; the found RomTag's resident is initialised with the
 * seglist passed in d0 (not the usual d1).
 */
static APTR LoadAndInit(struct P5Base *base, char *basename)
{
    BPTR seg = DOSLoadSeg(base->pb_DOSBase, basename - 5);
    struct Resident *rt;

    if (!seg)
        return NULL;
    rt = FindRomTag(seg);
    if (!rt) {
        DOSUnLoadSeg(base->pb_DOSBase, seg);
        return NULL;
    }
    return InitResidentD0(base->pb_SysBase, rt, (ULONG)seg);
}

/*
 * LibInit: InitResident calls with d0=base, a0=seglist, a6=SysBase.
 */
struct Library *LibInit(struct P5Base *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->pb_SysBase = sysbase;
    base->pb_SegList = seglist;
    base->pb_DOSBase = (struct DosLibrary *)OpenLibrary((CONST_STRPTR)str_dos, 0);
    if (!base->pb_DOSBase)
        return NULL;

    if (!(sysbase->AttnFlags & AFF_68040))
        return NULL;

    if (Supervisor((ULONG (*)())ProbeBody) == 1) {
        /* 68060 (060 systems report AFB_68040): forward opens to
           the already-installed 68060.library */
        base->pb_OpenLib = OpenLibrary((CONST_STRPTR)(str_68060 + 5), 0);
        if (!base->pb_OpenLib)
            return NULL;
        return (struct Library *)base;
    }

    /* real 68040: preload the real support library, then die */
    base->pb_LoadLib = (struct Library *)LoadAndInit(base, (char *)str_68040new + 5);
    if (!base->pb_LoadLib)
        base->pb_LoadLib = (struct Library *)LoadAndInit(base, (char *)str_68040old + 5);
    return NULL;
}

/*
 * LibOpen (LVO -6): OpenCnt++, clear the private flag bit 3,
 * force ln_Type=NT_LIBRARY, return pb_OpenLib if set else self.
 */
struct Library *LibOpen(void)
{
    register struct P5Base *base __asm("a6"); /* a6 = library base */

    base->pb_Lib.lib_OpenCnt++;
    base->pb_Flags &= ~8;
    base->pb_Lib.lib_Node.ln_Type = NT_LIBRARY;
    if (base->pb_OpenLib)
        return base->pb_OpenLib;
    return (struct Library *)base;
}

/* LibClose (LVO -12): null stub -- the original never decrements
   the open count, so the library can never be expunged. */
LONG LibClose(void)
{
    return 0;
}

/* LibExpunge (LVO -18): null stub. */
LONG LibExpunge(void)
{
    return 0;
}

/* LibNull (LVO -24, ExtFunc): null stub. */
LONG LibNull(void)
{
    return 0;
}
