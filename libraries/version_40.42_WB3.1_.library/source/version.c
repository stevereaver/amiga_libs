/*
**	version.c -- version.library 40.42 (Workbench 3.1)
**
**	C reconstruction of the shipped binary
**	"version_40.42(WB3.1).library" ($VER: version 40.42 (18.2.94)).
**
**	version.library has no public functions; the vector table
**	holds only the four system vectors Open/Close/Expunge/ExtFunc,
**	and Expunge+ExtFunc share one moveq#0,rts stub.
**
**	Unusual detail: LibClose unlinks the library from the exec
**	list and frees its memory unconditionally once OpenCnt reaches
**	0 -- there is no LIBF_DELEXP check.  The Expunge vector is a
**	non-functional stub (see okf/findings/CloseSemantics.md).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "versionbase.h"

/* __FreeMem_base / exec inline stubs (register-args a1/d0, a6=base) */
#include <inline/exec.h>

struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
LONG LibNull(void);

/*
 * LibInit: InitResident calls the AUTOINIT init routine with
 * d0=base, a0=seglist, a6=SysBase.  The original stores SysBase at
 * +0x22, the seglist at +0x26 and stamps lib_Revision with the build
 * revision (42 for "version 40.42"); the return value is the base
 * itself (kept in d0 across an exg d0,a5 pair).
 */
struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->vb_SysBase = sysbase;
    base->vb_SegList = seglist;
    base->vb_Lib.lib_Revision = 42;

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
