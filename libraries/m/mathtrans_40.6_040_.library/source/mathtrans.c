/*
**	mathtrans.c -- framework for mathtrans.library 40.6
**	"for 68040" (id: "mathtrans 40.6 (7.4.95) for 68040",
**	"(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (6188 bytes).
**	Unlike the tiny 68881/82 sibling, the 68040 build
**	contains full software implementations of all 17
**	FFP (fast floating point) SP* transcendental
**	vectors: the '040 FPU lacks fsin/fcos/fatan/fexp/
**	flog10/fsinh/etc, so every function is a
**	double-precision polynomial/rational kernel in
**	math.s (argument reduction, Cody-Waite style
**	subtraction, bit-level exponent handling, inline
**	IEEE-64 coefficient pool).
**
**	This file holds only init/open/close/expunge --
**	identical structure to the sibling 40.6 builds:
**	private DELEXP flag byte at base+0x2a bit3 (not
**	lib_Flags), OpenCnt/seglist bookkeeping.
**
**	Init gate: AFF_68040 always required; when
**	SysBase->lib_Version >= 39 the new AFB_FPU40
**	attention bit must also be set.  This mirrors the
**	standard C= 40.6 68040 pattern (FPSP availability).
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
 * (+0x26), then requires AFF_68040; for exec V39+ it also
 * requires AFF_FPU40.
 */
struct Library *LibInit(struct MTBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mt_Lib.lib_OpenCnt = 0;
    base->mt_SysBase = sysbase;
    base->mt_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68040))
        return NULL;
    if (sysbase->LibNode.lib_Version >= 39 &&
        !(sysbase->AttnFlags & AFF_FPU40))
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
