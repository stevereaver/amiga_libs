/*
**	loader.c -- C reconstruction of 68040.library 46.9
**	($VER: 040/060-Loader.library 46.9 (21.11.2020) by
**	 Holger 'Lynxx' Hippenstiel.)
**
**	Pure loader stub: only the four system vectors exist
**	(Open/Close/Expunge/ExtFunc -- the last three all point at
**	the same null routine in the original).
**
**	Init logic recovered from the disassembly:
**	  - obtains a dos.library base via exec LVO -810
**	    (TaggedOpenLibrary(4) on exec V45+; the result is stored
**	    unconditionally, no NULL check)
**	  - requires AFB_68040 set in ExecBase->AttnFlags, else fail
**	  - runs a Supervisor() probe (`movec pcr,a1` under an
**	    illegal-instruction handler):
**	      probe != 0 (68060): OpenLibrary("060.library",0) is
**	          stored in lb_OpenLib and returned by LibOpen --
**	          OpenLibrary("68040.library") callers get the
**	          060 support library's base instead
**	      probe == 0 (68040): LoadSeg("bs:68040mmu.library") +
**	          InitResident() is attempted (a +2 pointer quirk in
**	          the original means the LoadSeg name misses the
**	          first two chars, so it always fails), result is
**	          discarded and init returns NULL anyway -- the stub
**	          unloads itself, leaving the preloaded lib resident
**
**	The "+2" name quirks are deliberate reproductions of the
**	binary's behaviour, not typos: the original lea targets land
**	two bytes into "68060.library" and "Libs:68040mmu.library".
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/libraries.h>
#include <exec/resident.h>
#include <dos/dos.h>

/*
 * Library base (dataSize 0x34 = 52 bytes), recovered layout:
 *   +0x00  struct Library
 *   +0x22  private flag byte (bclr #3 on every LibOpen)
 *   +0x24  SysBase
 *   +0x28  segList
 *   +0x2c  DOSBase (TaggedOpenLibrary(4) result)
 *   +0x30  openLib  (OpenLibrary("060.library") result)
 */
struct LynxxBase
{
    struct Library      lb_Lib;     /* 0x00 */
    UBYTE               lb_Flags;   /* 0x22 private flag byte */
    UBYTE               lb_pad23;   /* 0x23 */
    struct ExecBase    *lb_SysBase; /* 0x24 */
    BPTR                lb_SegList; /* 0x28 */
    struct DosLibrary  *lb_DOSBase; /* 0x2c */
    struct Library     *lb_OpenLib; /* 0x30 */
};                                  /* 0x34 */

/* the exec proto macros take the library base from a `base`
   variable that is in scope at every call site (keeps the lib
   hunk-free of .data/.bss, like the original single-hunk binary).
   dos.library calls go through helpers.s shims instead, because
   inline/dos.h evaluates DOS_BASE_NAME at file scope. */
#define EXEC_BASE_NAME (base->lb_SysBase)
#include <proto/exec.h>

/* string labels emitted by loader_lib.s (leading '_' is the C->asm
   name mangling: str_68060 -> _str_68060) */
extern const char str_68060[];   /* "68060.library"          */
extern const char str_mmu[];     /* "Libs:68040mmu.library"  */

/* asm helpers (helpers.s) */
ULONG ProbeBody(void);           /* supervisor func: movec pcr probe */
struct Library *TaggedOpenLib(struct ExecBase *eb __asm("a1"),
                              ULONG tag __asm("d0"));
APTR InitResidentD0(struct ExecBase *eb __asm("a6"),
                    APTR res __asm("a1"), ULONG seglist __asm("d0"));
BPTR DOSLoadSeg(struct DosLibrary *db __asm("a6"), const char *name __asm("d1"));
BOOL DOSUnLoadSeg(struct DosLibrary *db __asm("a6"), BPTR seg __asm("d1"));

struct Library *LibInit(struct LynxxBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
LONG LibClose(void);

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
 * LoadSeg + InitResident helper.  The original passes the LoadSeg
 * name pointer unmodified and hands the seglist to InitResident()
 * in d0 (not the usual d1) -- reproduced by InitResidentD0().
 */
static APTR LoadAndResident(struct LynxxBase *base, const char *name)
{
    BPTR seg = DOSLoadSeg(base->lb_DOSBase, name);
    struct Resident *rt;

    if (!seg)
        return NULL;
    rt = FindRomTag(seg);
    if (!rt) {
        DOSUnLoadSeg(base->lb_DOSBase, seg);
        return NULL;
    }
    return InitResidentD0(base->lb_SysBase, rt, (ULONG)seg);
}

/*
 * LibInit: InitResident calls with d0=base, a0=seglist, a6=SysBase.
 */
struct Library *LibInit(struct LynxxBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->lb_SysBase = sysbase;
    base->lb_SegList = seglist;
    base->lb_DOSBase = (struct DosLibrary *)TaggedOpenLib(sysbase, 4);

    if (!(sysbase->AttnFlags & AFF_68040))
        return NULL;

    if (Supervisor((ULONG (*)())ProbeBody)) {
        /* 68060: forward opens to the already-installed 060 lib */
        base->lb_OpenLib = OpenLibrary((CONST_STRPTR)(str_68060 + 2), 0);
        if (!base->lb_OpenLib)
            return NULL;
        return (struct Library *)base;
    }

    /* real 68040: try to preload the MMU-support library, then die */
    (void)LoadAndResident(base, str_mmu + 2);    /* "bs:68040mmu.library" */
    return NULL;
}

/*
 * LibOpen (LVO -6): OpenCnt++, clear the private flag bit 3,
 * force ln_Type=NT_LIBRARY, return lb_OpenLib if set else self.
 */
struct Library *LibOpen(void)
{
    register struct LynxxBase *base __asm("a6"); /* a6 = library base */

    base->lb_Lib.lib_OpenCnt++;
    base->lb_Flags &= ~8;
    base->lb_Lib.lib_Node.ln_Type = NT_LIBRARY;
    if (base->lb_OpenLib)
        return base->lb_OpenLib;
    return (struct Library *)base;
}

/* LibClose (LVO -12) -- also serves as Expunge (-18) and
   ExtFunc (-24): all three table slots hold this stub's address. */
LONG LibClose(void)
{
    return 0;
}
