/*
**	mathieeesingtrans.c -- framework functions for
**	mathieeesingtrans.library 40.6 "for 68881/82"
**	(id: "mathieeesingtrans 40.6 (7.4.95) for 68881/82",
**	"(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (816 bytes).
**	The 17 public vectors are verbatim 68881 stubs and live in
**	math.s; this file holds init/open/close/expunge.
**
**	Shipped-binary semantics:
**	- LibInit (AUTOINIT initFunc, d0=base, a0=seglist,
**	  a6=SysBase) clears lib_OpenCnt, stores SysBase/SegList,
**	  then gates on AttnFlags: AFF_68020 and AFF_68881 must both
**	  be set or init fails (returns NULL).
**	- The DELEXP dance uses a private flag byte at base+0x2a
**	  bit3, NOT lib_Flags/LIBF_DELEXP.
**	- LibExpunge does the remove+free inline: ExecBase is
**	  reloaded from base+0x22, Remove then FreeMem
**	  (NegSize+PosSize), seglist returned.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "mstbase.h"

/* __Remove_base / __FreeMem_base (register-args, a6 = exec base) */
#include <inline/exec.h>

struct Library *LibInit(struct MSTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
BPTR LibExpunge(void);

/*
 * LibInit: clears OpenCnt, stores SysBase (+0x22) and seglist
 * (+0x26), then requires AFF_68020 && AFF_68881 in AttnFlags
 * (btst #1 / btst #4 on the flag low byte in the original).
 * Failure returns NULL -> InitResident abandons the library.
 */
struct Library *LibInit(struct MSTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mst_Lib.lib_OpenCnt = 0;
    base->mst_SysBase = sysbase;
    base->mst_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68020) ||
        !(sysbase->AttnFlags & AFF_68881))
        return NULL;
    return (struct Library *)base;
}

/*
 * LibOpen (LVO -6): addq.w #1,lib_OpenCnt; bclr #3,flags(base+0x2a);
 * move.l a6,d0; rts.
 */
struct Library *LibOpen(void)
{
    register struct MSTBase *b __asm("a6");        /* a6 = library base */
    b->mst_Lib.lib_OpenCnt++;
    b->mst_Flags &= ~MSTF_DELEXP;
    return (struct Library *)b;
}

/*
 * DoExpunge: shared tail of Close/Expunge -- reload ExecBase from
 * base+0x22, Remove() the base node, FreeMem(NegSize+PosSize),
 * return the seglist in d0.
 */
static BPTR DoExpunge(struct MSTBase *b)
{
    struct ExecBase *sys = b->mst_SysBase;
    BPTR             seg = b->mst_SegList;
    APTR             mem = (APTR)((UBYTE *)b - b->mst_Lib.lib_NegSize);
    ULONG            size = (ULONG)b->mst_Lib.lib_NegSize
                          + (ULONG)b->mst_Lib.lib_PosSize;

    __Remove_base(sys, (struct Node *)b);          /* jsr -252(a6) */
    __FreeMem_base(sys, mem, size);                /* jsr -210(a6) */
    return seg;
}

/*
 * LibClose (LVO -12): OpenCnt--; non-zero -> 0.  At zero it falls
 * into the expunge tail only when the private DELEXP bit is set.
 * d0 was cleared on entry (moveq #0,d0) and the still-open path
 * branches to a shared rts -- returns 0.
 */
BPTR LibClose(void)
{
    register struct MSTBase *b __asm("a6");

    if (--b->mst_Lib.lib_OpenCnt)
        return 0;
    if (!(b->mst_Flags & MSTF_DELEXP))
        return 0;
    return DoExpunge(b);
}

/*
 * LibExpunge (LVO -18): while open only set the private DELEXP bit
 * and return 0; with OpenCnt 0 unlink and free the base.
 */
BPTR LibExpunge(void)
{
    register struct MSTBase *b __asm("a6");

    if (b->mst_Lib.lib_OpenCnt) {
        b->mst_Flags |= MSTF_DELEXP;
        return 0;
    }
    return DoExpunge(b);
}
