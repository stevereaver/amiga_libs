/*
**	version.c -- version.library 44.2 (Workbench 3.5)
**
**	C reconstruction of the shipped binary
**	"version_44.2(WB3.5).library" ($VER: version 44.2 (11.8.99)).
**
**	version.library has no public functions; the vector table
**	holds only the four system vectors Open/Close/Expunge/ExtFunc,
**	and Expunge+ExtFunc share one moveq#0,rts stub.
**
**	Two quirks versus the 39/40.x builds (see okf/findings/):
**	  - LibInit additionally stores a self-pointer, a hardcoded
**	    date 0x11081999, and the address of a hidden semaphore
**	    probe routine (version_check.s) in the extended base.
**	  - LibClose unlinks/frees the library unconditionally when
**	    OpenCnt reaches 0 (no LIBF_DELEXP check); Expunge is a
**	    non-functional stub.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "versionbase.h"

/* __FreeMem_base / exec inline stubs (register-args a1/d0, a6=base) */
#include <inline/exec.h>

extern char _CheckSemaphore;	/* version_check.s */

struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
LONG LibNull(void);

/*
 * LibInit: InitResident calls the AUTOINIT init routine with
 * d0=base, a0=seglist, a6=SysBase.  Besides SysBase/seglist and
 * lib_Revision it stores a self-pointer, the hardcoded build date
 * 0x11081999 (11.8.1999 -- kept unchanged in all 44.x/45.x builds),
 * and the address of the hidden semaphore probe.  The probe address
 * is taken pc-relative like the original (lea sym(pc)), so no
 * RELOC32 is introduced into the code hunk.
 */
struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */
    APTR check;

    __asm volatile ("lea _CheckSemaphore(%%pc),%0" : "=a"(check));

    base->vb_SysBase = sysbase;
    base->vb_SegList = seglist;
    base->vb_Lib.lib_Revision = 2;
    base->vb_Self    = (struct Library *)base;
    base->vb_Date    = 0x11081999;
    base->vb_Check   = check;

    return (struct Library *)base;
}

/*
 * LibOpen (LVO -6): addq.w #1,lib_OpenCnt(a6); move.l a6,d0; rts.
 * No LIBF_DELEXP handling anywhere in this library.
 */
struct Library *LibOpen(void)
{
    register struct VersionBase *vb __asm("a6");   /* a6 = library base */
    vb->vb_Lib.lib_OpenCnt++;
    return (struct Library *)vb;
}

/*
 * LibClose (LVO -12): OpenCnt--; if it hits 0 the library removes
 * itself from the exec library list and FreeMem()s its allocation
 * (NegSize+PosSize below/above the base), returning the seglist.
 *
 * The binary returns with a stale d0 on the still-open path (it just
 * branches to rts); the reconstruction returns NULL there -- the
 * documented contract only specifies the seglist on the expunge path.
 */
BPTR LibClose(void)
{
    register struct VersionBase *vb __asm("a6");

    if (--vb->vb_Lib.lib_OpenCnt == 0) {
        BPTR          seg  = vb->vb_SegList;
        APTR          mem  = (APTR)((UBYTE *)vb - vb->vb_Lib.lib_NegSize);
        ULONG         size = (ULONG)vb->vb_Lib.lib_NegSize
                           + (ULONG)vb->vb_Lib.lib_PosSize;
        struct Node  *node = (struct Node *)vb;

        /* inlined Remove(): unlink node from the library list */
        node->ln_Pred->ln_Succ = node->ln_Succ;
        node->ln_Succ->ln_Pred = node->ln_Pred;

        __FreeMem_base(vb->vb_SysBase, mem, size); /* jsr -210(a6) */
        return seg;
    }
    return 0;
}

/*
 * LibNull: shared stub for Expunge (LVO -18) and ExtFunc (LVO -24).
 * The real Expunge does nothing; cleanup happens in LibClose.
 */
LONG LibNull(void)
{
    return 0;
}
