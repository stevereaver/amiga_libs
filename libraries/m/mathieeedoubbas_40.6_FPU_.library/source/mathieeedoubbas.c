/*
**	mathieeedoubbas.c -- framework + integer vectors for
**	mathieeedoubbas.library 40.6 "for 68881/82"
**	(id: "mathieeedoubbas 40.6 (7.4.95) for 68881/82",
**	"(c) 1995 by Martin Berndt").
**
**	C reconstruction of the shipped binary (896 bytes).
**	FPU vectors live in math.s; this file holds
**	init/open/close/expunge plus the pure-integer vectors
**	IEEEDPCmp, IEEEDPTst, IEEEDPAbs and IEEEDPNeg.
**
**	Shipped-binary semantics are identical to the sibling
**	mathieeesingtrans 40.6 build: init gates on
**	AFF_68020 && AFF_68881 and the DELEXP dance uses a private
**	flag byte at base+0x2a bit3, not lib_Flags.
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
 * (+0x26), then requires AFF_68020 && AFF_68881 in AttnFlags.
 */
struct Library *LibInit(struct MDBBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */

    base->mdb_Lib.lib_OpenCnt = 0;
    base->mdb_SysBase = sysbase;
    base->mdb_SegList = seglist;

    if (!(sysbase->AttnFlags & AFF_68020) ||
        !(sysbase->AttnFlags & AFF_68881))
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
 * as bit patterns in (l0,l1) and (r0,r1).  Pure integer code in
 * the original: sign tests first, magnitude compares after;
 * +0 == -0 on both sides of zero.
 */
LONG IEEEDPCmp(ULONG l0 __asm("d0"), ULONG l1 __asm("d1"),
	       ULONG r0 __asm("d2"), ULONG r1 __asm("d3"))
{
    if ((LONG)l0 < 0) {
	if ((LONG)r0 < 0) {
	    /* both negative: order of the bit patterns is
	     * reversed under signed compare -- mirrored branches */
	    if ((LONG)r0 < (LONG)l0) return -1;
	    if ((LONG)r0 > (LONG)l0) return 1;
	    if (l1 < r1) return 1;
	    if (l1 > r1) return -1;
	    return 0;
	}
	/* left < 0 <= right: -1 unless both are zero patterns */
	if (r0 || r1 || l1 || (l0 << 1))
	    return -1;
	return 0;
    }
    if ((LONG)r0 < 0) {
	/* left >= 0 > right: +1 unless both are zero patterns */
	if (l0 || l1 || r1 || (r0 << 1))
	    return 1;
	return 0;
    }
    /* both positive */
    if ((LONG)l0 < (LONG)r0) return -1;
    if ((LONG)l0 > (LONG)r0) return 1;
    if (r1 < l1) return 1;
    if (r1 != l1) return -1;
    return 0;
}

/*
 * IEEEDPTst (LVO -48): sign of x held in (l0,l1); -0 counts as 0.
 * The original shifts l0 left once: carry holds the sign, the
 * remaining bits plus l1 decide.
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
