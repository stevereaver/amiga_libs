/*
**	freeanim.c -- freeanim.library 40.9 (11.8.95)
**
**	C reconstruction of the shipped binary
**	"freeanim_40.9.library" (id: "freeanim.library 40.9
**	(11.8.95)").
**
**	Real AUTOINIT library, but with no public API: the function
**	table holds only the four system vectors.  The -24 slot is a
**	shared `moveq #0,rts` stub.  The base carries just the
**	segment list at +0x22 (dataSize 0x26).
**
**	Exec calls are made against the absolute ExecBase at $0004,
**	matching the original (movea.l ABSEXECBASE.W,a6).
*/

#define EXEC_BASE_NAME (*(struct ExecBase **)4UL)

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <inline/exec.h>

struct FreeAnimBase {
    struct Library  fa_Lib;     /* 0x00-0x21 */
    ULONG           fa_SegList; /* 0x22 */
};                              /* dataSize = 0x26 */

static ULONG DoExpunge(struct FreeAnimBase *base)
{
    ULONG seglist;

    if (base->fa_Lib.lib_OpenCnt) {
        /* still in use: request delayed expunge */
        base->fa_Lib.lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    seglist = base->fa_SegList;
    Remove((struct Node *)base);
    FreeMem((UBYTE *)base - base->fa_Lib.lib_NegSize,
            (ULONG)base->fa_Lib.lib_NegSize + base->fa_Lib.lib_PosSize);
    return seglist;
}

/*
** LibInit -- d0 = library base, a0 = segment list, a6 = ExecBase.
** Stores the seglist at +0x22 and returns the base in d0.
*/
struct Library *LibInit(register struct FreeAnimBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"));

struct Library *LibInit(register struct FreeAnimBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"))
{
    base->fa_SegList = seglist;
    return (struct Library *)base;
}

/* LVO -6 */
struct Library *LibOpen(void);
struct Library *LibOpen(void)
{
    register struct FreeAnimBase *base __asm("a6");
    base->fa_Lib.lib_OpenCnt++;
    return (struct Library *)base;
}

/*
** LVO -12.  Original keeps the would-be segment list in d7; a
** guarded decrement (opencnt checked before subtracting) and a
** conditional Expunge when count reaches 0 with DELEXP set.
*/
ULONG LibClose(void);
ULONG LibClose(void)
{
    register struct FreeAnimBase *base __asm("a6");
    ULONG seg = 0;

    if (base->fa_Lib.lib_OpenCnt)
        base->fa_Lib.lib_OpenCnt--;
    if (!base->fa_Lib.lib_OpenCnt &&
        (base->fa_Lib.lib_Flags & LIBF_DELEXP))
        seg = DoExpunge(base);
    return seg;
}

/* LVO -18 */
ULONG LibExpunge(void);
ULONG LibExpunge(void)
{
    register struct FreeAnimBase *base __asm("a6");
    return DoExpunge(base);
}

/* LVO -24 (reserved/ExtFunc): shared null stub */
LONG LibNull(void);
LONG LibNull(void)
{
    return 0;
}
