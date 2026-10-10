/*
**	mathieeedoubbas.c -- framework + integer vectors for
**	mathieeedoubbas.library 40.6 "for 68040"
**	(id: "mathieeedoubbas 40.6 (7.4.95) for 68040",
**	"(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (900 bytes).
**	Same code as the "for 68881/82" build -- even the FPU
**	vectors are identical (fintrz/fint trap into the 68040
**	FPSP on a real '040).  Only the idstring and the init
**	gate differ:
**
**	  require AFF_68040;  under exec lib_Version >= 39 also
**	  require AFF_FPU40 (AttnFlags bit 6) -- the FPSP is
**	  bundled with the 68040 support on OS3.x.
**
**	DELEXP dance uses the private flag byte at base+0x2a
**	bit3, not lib_Flags (same as the other Berndt builds).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

#include "mdbbase.h"

/* __Remove_base / __FreeMem_base (register-args, a6 = exec base) */
#include <inline/exec.h>

struct Library *LibInit(struct MDBBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
BPTR LibExpunge(void);

/*
 * LibInit: clears OpenCnt, stores SysBase (+0x22) and seglist
 * (+0x26), then the 68040 gate:
 *   btst #3,AttnFlags (AFF_68040)   -- required
 *   if lib_Version >= 39: also require btst #6 (AFF_FPU40)
 * Older exec has no FPU40 flag, so 68040 alone suffices there.
 */
struct Library *LibInit(struct MDBBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mdb_Lib.lib_OpenCnt = 0;
    base->mdb_SysBase = sysbase;
    base->mdb_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68040))
        return NULL;
    if (sysbase->LibNode.lib_Version >= 39 &&
        !(sysbase->AttnFlags & AFF_FPU40))
        return NULL;
    return (struct Library *)base;
}

struct Library *LibOpen(void)
{
    register struct MDBBase *b __asm("a6");        /* a6 = library base */
    b->mdb_Lib.lib_OpenCnt++;
    b->mdb_Flags &= ~MDBF_DELEXP;
    return (struct Library *)b;
}

static BPTR DoExpunge(struct MDBBase *b)
{
    struct ExecBase *sys = b->mdb_SysBase;
    BPTR             seg = b->mdb_SegList;
    APTR             mem = (APTR)((UBYTE *)b - b->mdb_Lib.lib_NegSize);
    ULONG            size = (ULONG)b->mdb_Lib.lib_NegSize
                          + (ULONG)b->mdb_Lib.lib_PosSize;

    __Remove_base(sys, (struct Node *)b);          /* jsr -252(a6) */
    __FreeMem_base(sys, mem, size);                /* jsr -210(a6) */
    return seg;
}

BPTR LibClose(void)
{
    register struct MDBBase *b __asm("a6");

    if (--b->mdb_Lib.lib_OpenCnt)
        return 0;
    if (!(b->mdb_Flags & MDBF_DELEXP))
        return 0;
    return DoExpunge(b);
}

BPTR LibExpunge(void)
{
    register struct MDBBase *b __asm("a6");

    if (b->mdb_Lib.lib_OpenCnt) {
        b->mdb_Flags |= MDBF_DELEXP;
        return 0;
    }
    return DoExpunge(b);
}

/* ------------------------------------------------------------------ */
/* public vectors -- pure integer (no FPU ops needed)		      */
/* ------------------------------------------------------------------ */

/*
 * IEEEDPCmp (LVO -42): three-way compare of two IEEE doubles held
 * as bit patterns in (l0,l1) and (r0,r1).  Pure integer code:
 * sign tests first, magnitude compares after; +0 == -0.
 */
LONG IEEEDPCmp(ULONG l0 __asm("d0"), ULONG l1 __asm("d1"),
	       ULONG r0 __asm("d2"), ULONG r1 __asm("d3"))
{
    if ((LONG)l0 < 0) {
	if ((LONG)r0 < 0) {
	    if ((LONG)r0 < (LONG)l0) return -1;
	    if ((LONG)r0 > (LONG)l0) return 1;
	    if (l1 < r1) return 1;
	    if (l1 > r1) return -1;
	    return 0;
	}
	if (r0 || r1 || l1 || (l0 << 1))
	    return -1;
	return 0;
    }
    if ((LONG)r0 < 0) {
	if (l0 || l1 || r1 || (r0 << 1))
	    return 1;
	return 0;
    }
    if ((LONG)l0 < (LONG)r0) return -1;
    if ((LONG)l0 > (LONG)r0) return 1;
    if (r1 < l1) return 1;
    if (r1 != l1) return -1;
    return 0;
}

/*
 * IEEEDPTst (LVO -48): sign of x held in (l0,l1); -0 counts as 0.
 */
LONG IEEEDPTst(ULONG l0 __asm("d0"), ULONG l1 __asm("d1"))
{
    if (!(l0 << 1) && !l1)
	return 0;
    return (l0 & 0x80000000UL) ? -1 : 1;
}

/* IEEEDPAbs (LVO -54): bclr #31,d0 -- low word passes through. */
ULONG IEEEDPAbs(ULONG l0 __asm("d0"), ULONG l1 __asm("d1"))
{
    return l0 & 0x7fffffffUL;
}

/* IEEEDPNeg (LVO -60): bchg #31,d0. */
ULONG IEEEDPNeg(ULONG l0 __asm("d0"), ULONG l1 __asm("d1"))
{
    return l0 ^ 0x80000000UL;
}
