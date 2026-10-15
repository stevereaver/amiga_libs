/*
**	mathieeedoubtrans.c -- framework for
**	mathieeedoubtrans.library 40.6 "for 68881/82"
**	(id: "mathieeedoubtrans 40.6 (7.4.95) for 68881/82",
**	"(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (1000 bytes).
**	All 17 public vectors are 68881 code in math.s; this file
**	holds init/open/close/expunge only.
**
**	Shipped-binary semantics are identical to the sibling
**	mathieeedoubbas/mathieeesingtrans 40.6 builds: init gates
**	on AFF_68020 && AFF_68881 and the DELEXP dance uses a
**	private flag byte at base+0x2a bit3, not lib_Flags.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "mdtbase.h"

/* __Remove_base / __FreeMem_base (register-args, a6 = exec base) */
#include <inline/exec.h>

struct Library *LibInit(struct MDTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
BPTR LibExpunge(void);

/*
 * LibInit: clears OpenCnt, stores SysBase (+0x22) and seglist
 * (+0x26), then requires AFF_68020 && AFF_68881 in AttnFlags.
 */
struct Library *LibInit(struct MDTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mdt_Lib.lib_OpenCnt = 0;
    base->mdt_SysBase = sysbase;
    base->mdt_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68020) ||
        !(sysbase->AttnFlags & AFF_68881))
        return NULL;
    return (struct Library *)base;
}

struct Library *LibOpen(void)
{
    register struct MDTBase *b __asm("a6");        /* a6 = library base */
    b->mdt_Lib.lib_OpenCnt++;
    b->mdt_Flags &= ~MDTF_DELEXP;
    return (struct Library *)b;
}

static BPTR DoExpunge(struct MDTBase *b)
{
    struct ExecBase *sys = b->mdt_SysBase;
    BPTR             seg = b->mdt_SegList;
    APTR             mem = (APTR)((UBYTE *)b - b->mdt_Lib.lib_NegSize);
    ULONG            size = (ULONG)b->mdt_Lib.lib_NegSize
                          + (ULONG)b->mdt_Lib.lib_PosSize;

    __Remove_base(sys, (struct Node *)b);          /* jsr -252(a6) */
    __FreeMem_base(sys, mem, size);                /* jsr -210(a6) */
    return seg;
}

BPTR LibClose(void)
{
    register struct MDTBase *b __asm("a6");

    if (--b->mdt_Lib.lib_OpenCnt)
        return 0;
    if (!(b->mdt_Flags & MDTF_DELEXP))
        return 0;
    return DoExpunge(b);
}

BPTR LibExpunge(void)
{
    register struct MDTBase *b __asm("a6");

    if (b->mdt_Lib.lib_OpenCnt) {
        b->mdt_Flags |= MDTF_DELEXP;
        return 0;
    }
    return DoExpunge(b);
}
