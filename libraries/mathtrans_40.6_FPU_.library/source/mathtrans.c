/*
**	mathtrans.c -- framework for mathtrans.library 40.6
**	"for 68881/82" (id: "mathtrans 40.6 (7.4.95) for
**	68881/82", "(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (912 bytes).
**	All 17 user vectors live in math.s: they are FFP-format
**	(Amiga fast floating point) wrappers around 68881
**	single-precision operations plus the FFP<->IEEE-single
**	converters SPTieee/SPFieee.  This file holds only
**	init/open/close/expunge.
**
**	Shipped-binary semantics are identical to the sibling
**	mathieeesingtrans/mathieeedoubbas 40.6 builds: init gates
**	on AFF_68020 && AFF_68881 and the DELEXP dance uses a
**	private flag byte at base+0x2a bit3, not lib_Flags.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "mtbase.h"

/* __Remove_base / __FreeMem_base (register-args, a6 = exec base) */
#include <inline/exec.h>

struct Library *LibInit(struct MTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
BPTR LibExpunge(void);

/*
 * LibInit: clears OpenCnt, stores SysBase (+0x22) and seglist
 * (+0x26), then requires AFF_68020 && AFF_68881 in AttnFlags.
 */
struct Library *LibInit(struct MTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mt_Lib.lib_OpenCnt = 0;
    base->mt_SysBase = sysbase;
    base->mt_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68020) ||
        !(sysbase->AttnFlags & AFF_68881))
        return NULL;
    return (struct Library *)base;
}

struct Library *LibOpen(void)
{
    register struct MTBase *b __asm("a6");         /* a6 = library base */
    b->mt_Lib.lib_OpenCnt++;
    b->mt_Flags &= ~MTF_DELEXP;
    return (struct Library *)b;
}

static BPTR DoExpunge(struct MTBase *b)
{
    struct ExecBase *sys = b->mt_SysBase;
    BPTR             seg = b->mt_SegList;
    APTR             mem = (APTR)((UBYTE *)b - b->mt_Lib.lib_NegSize);
    ULONG            size = (ULONG)b->mt_Lib.lib_NegSize
                          + (ULONG)b->mt_Lib.lib_PosSize;

    __Remove_base(sys, (struct Node *)b);          /* jsr -252(a6) */
    __FreeMem_base(sys, mem, size);                /* jsr -210(a6) */
    return seg;
}

BPTR LibClose(void)
{
    register struct MTBase *b __asm("a6");

    if (--b->mt_Lib.lib_OpenCnt)
        return 0;
    if (!(b->mt_Flags & MTF_DELEXP))
        return 0;
    return DoExpunge(b);
}

BPTR LibExpunge(void)
{
    register struct MTBase *b __asm("a6");

    if (b->mt_Lib.lib_OpenCnt) {
        b->mt_Flags |= MTF_DELEXP;
        return 0;
    }
    return DoExpunge(b);
}
