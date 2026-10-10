/*
**	version.c -- version.library 47.2 (Workbench 3.2)
**
**	C reconstruction of the shipped binary
**	"version.library_47.2(WB3.2)" ($VER: version 47.2 (10.4.2021)).
**
**	version.library has no public functions; the vector table
**	holds only the four system vectors Open/Close/Expunge/ExtFunc.
**
**	The 47.x line is a return to textbook semantics: LibOpen
**	clears LIBF_DELEXP, LibClose expunges only when OpenCnt hits
**	0 *and* DELEXP is set, and LibExpunge is a real routine that
**	either marks DELEXP (while open) or performs the expunge.
**	LVO -24 ExtFunc is a separate moveq#0,rts stub.
**
**	This differs from the 39/40.x builds (unconditional expunge
**	in Close, Expunge a shared null stub) and from the 44.x/45.x
**	builds (extra base fields + hidden semaphore probe).
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
BPTR LibExpunge(void);
LONG LibNull(void);

/*
 * LibInit: InitResident calls the AUTOINIT init routine with
 * d0=base, a0=seglist, a6=SysBase.  Stores SysBase at +0x22 and
 * the seglist at +0x26 via an exg d0,a5 pair and stamps
 * lib_Revision = 2; the base stays in d0 across the swap back.
 */
struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->vb_SysBase = sysbase;
    base->vb_SegList = seglist;
    base->vb_Lib.lib_Revision = 2;

    return (struct Library *)base;
}

/*
 * LibOpen (LVO -6): addq.w #1,lib_OpenCnt(a6); bclr #LIBF_DELEXP,
 * lib_Flags(a6); move.l a6,d0; rts.  Textbook open vector.
 */
struct Library *LibOpen(void)
{
    register struct VersionBase *vb __asm("a6");   /* a6 = library base */
    vb->vb_Lib.lib_OpenCnt++;
    vb->vb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)vb;
}

/*
 * DoExpunge: shared tail of LibClose/LibExpunge -- unlink the base
 * node, FreeMem(NegSize+PosSize) via SysBase, return the seglist.
 */
static BPTR DoExpunge(struct VersionBase *vb)
{
    BPTR         seg  = vb->vb_SegList;
    APTR         mem  = (APTR)((UBYTE *)vb - vb->vb_Lib.lib_NegSize);
    ULONG        size = (ULONG)vb->vb_Lib.lib_NegSize
                      + (ULONG)vb->vb_Lib.lib_PosSize;
    struct Node *node = (struct Node *)vb;

    /* inlined Remove(): unlink node from the library list */
    node->ln_Pred->ln_Succ = node->ln_Succ;
    node->ln_Succ->ln_Pred = node->ln_Pred;

    __FreeMem_base(vb->vb_SysBase, mem, size);     /* jsr -210(a6) */
    return seg;
}

/*
 * LibClose (LVO -12): subq.w #1,lib_OpenCnt; when it reaches 0 and
 * LIBF_DELEXP is set, expunge and return the seglist, else 0.
 */
BPTR LibClose(void)
{
    register struct VersionBase *vb __asm("a6");

    if (--vb->vb_Lib.lib_OpenCnt)
        return 0;
    if (vb->vb_Lib.lib_Flags & LIBF_DELEXP)
        return DoExpunge(vb);
    return 0;
}

/*
 * LibExpunge (LVO -18): while still open only mark LIBF_DELEXP and
 * return 0; with OpenCnt 0 perform the expunge immediately.
 */
BPTR LibExpunge(void)
{
    register struct VersionBase *vb __asm("a6");

    if (vb->vb_Lib.lib_OpenCnt) {
        vb->vb_Lib.lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    return DoExpunge(vb);
}

/*
 * LibNull (LVO -24 ExtFunc): standalone moveq #0,d0; rts stub.
 * Unlike the 39/40.x builds this is NOT shared with Expunge --
 * this build has a real expunge routine at -18.
 */
LONG LibNull(void)
{
    return 0;
}
