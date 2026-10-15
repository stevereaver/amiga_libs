/*
**	version.c -- version.library 1.1 (Workbench 1.1)
**
**	C reconstruction of the shipped binary
**	"version_1.1(WB1.1).library" ($VER: mylib 1.1 (04 Nov 1985)).
**
**	version.library is a resource-tracking stub: it publishes a
**	version/revision through its library node but exports no user
**	functions.  All four vectors are the standard library skeleton:
**	Open, Close, Expunge and a reserved null entry.
**
**	NOTE: the original 1.1 Expunge is buggy (it calls exec Remove()
**	with the node in a0 instead of a1, and computes the FreeMem
**	block/size from longword reads at lib_NegSize).  That code
**	cannot be expressed in C; it is reproduced verbatim in
**	expunge.s.
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

/* LibExpunge (LVO -18) lives in expunge.s -- see header note. */
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

/* LibNull (LVO -24, ExtFunc/reserved) lives in expunge.s so that the
   object link order matches the original binary's function layout
   (Init, Open, Close, Expunge, Null). */
