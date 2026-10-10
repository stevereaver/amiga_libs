/*
**	version.c -- version.library 34.1
**
**	C reconstruction of the shipped binary
**	"version_34.1.library" ($VER: versionlib 34.1 (06 JUL 1988)).
**
**	version.library is a resource-tracking stub: it publishes a
**	version/revision through its library node but exports no user
**	functions.  All four vectors are the standard library skeleton:
**	Open, Close, Expunge and a reserved null entry.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>            /* BPTR */
#include <proto/exec.h>

/*
 * Private library base.  The InitTable dataSize is 0x2c:
 * struct Library (34 bytes) + SysBase + SegList + one private flag
 * byte + pad.  The original keeps the deferred-expunge flag as bit 3
 * of the byte at base+42, not in lib_Flags.
 */
struct VersionBase
{
    struct Library   vb_Lib;      /* 0x00 */
    struct ExecBase *vb_SysBase;  /* 0x22 */
    BPTR             vb_SegList;  /* 0x26 */
    UBYTE            vb_Flags;    /* 0x2a private flags */
    UBYTE            vb_Pad;      /* 0x2b */
};

#define VBF_DELEXP  0x08          /* delayed expunge pending */

/*
 * LibInit -- init vector, called by InitResident/MakeLibrary with
 * d0 = library base, a0 = seglist, a6 = SysBase.
 * Stores the two pointers the skeleton needs later and returns the
 * base unchanged in d0.
 */
struct Library *LibInit(struct VersionBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->vb_SysBase = sysbase;
    base->vb_SegList = seglist;

    return (struct Library *)base;
}

/*
 * LibOpen (LVO -6): bump the open count, clear a pending delayed
 * expunge, return the base.
 */
struct Library *LibOpen(struct VersionBase *base __asm("a6"))
{
    base->vb_Lib.lib_OpenCnt++;
    base->vb_Flags &= ~VBF_DELEXP;

    return (struct Library *)base;
}

BPTR LibExpunge(struct VersionBase *base __asm("a6"));

/*
 * LibClose (LVO -12): decrement the open count; when it reaches zero
 * and an expunge was deferred while the library was busy, run it now.
 * Returns 0, or the seglist when the library was expunged.
 */
BPTR LibClose(struct VersionBase *base __asm("a6"))
{
    if (--base->vb_Lib.lib_OpenCnt == 0 && (base->vb_Flags & VBF_DELEXP))
        return LibExpunge(base);

    return 0;
}

/*
 * LibExpunge (LVO -18): while the library is still open, just set the
 * deferred-expunge flag and fail (return 0).  Otherwise unlink the
 * library node, free the base memory block (NegSize before the base
 * plus PosSize/dataSize bytes) and return the seglist.
 */
BPTR LibExpunge(struct VersionBase *base __asm("a6"))
{
    struct ExecBase *sys = base->vb_SysBase;
    UBYTE           *block;
    ULONG            size;
    BPTR             seg;

    if (base->vb_Lib.lib_OpenCnt != 0) {
        base->vb_Flags |= VBF_DELEXP;
        return 0;
    }

    seg = base->vb_SegList;

    __Remove_base(sys, (struct Node *)base);

    block = (UBYTE *)base - base->vb_Lib.lib_NegSize;
    size  = (ULONG)base->vb_Lib.lib_NegSize + base->vb_Lib.lib_PosSize;
    __FreeMem_base(sys, block, size);

    return seg;
}

/* LibNull (LVO -24, ExtFunc/reserved): always returns 0 */
LONG LibNull(void)
{
    return 0;
}
