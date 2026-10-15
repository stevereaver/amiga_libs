/*
**	boards.c -- boards.library 1.0 (14.4.96), Richard Koerber.
**
**	C reconstruction of the shipped binary "boards_1.0.library".
**
**	Init opens "expname.library" v1 and keeps its base in a
**	code-resident cell (see boards_func.s).  The single public
**	vector (-30) relays to expname.library's own -30 and returns
**	the bitwise complement of the result (see boards_func.s).
**
**	Library base (dataSize 0x2c):
**	  0x00  struct Library
**	  0x22  unused byte
**	  0x23  private expunge-request flag (bit 0)
**	  0x24  ExecBase (stored at init, used by expunge test)
**	  0x28  segment list
**
**	Exec calls go through the absolute ExecBase at $0004,
**	matching the original.
*/

#define EXEC_BASE_NAME (*(struct ExecBase **)4UL)

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <inline/exec.h>

struct BoardsBase {
    struct Library   bb_Lib;        /* 0x00-0x21 */
    UBYTE            bb_pad;        /* 0x22 (unused) */
    UBYTE            bb_ExpungeReq; /* 0x23 bit0: deferred expunge */
    struct ExecBase *bb_SysBase;    /* 0x24 */
    ULONG            bb_SegList;    /* 0x28 */
};                                  /* dataSize = 0x2c */

/* code-hunk data cells, defined in boards_func.s */
extern struct Library *selfbase;      /* written at init, never read */
extern struct Library *expnamebase;   /* expname.library base */
extern char            expnamename[]; /* "expname.library" */

static ULONG DoExpunge(struct BoardsBase *base)
{
    ULONG seglist;

    /* original loads the stored SysBase into a6 first, but still
       performs the exec calls via absolute $4 */
    if (base->bb_Lib.lib_OpenCnt) {
        base->bb_ExpungeReq |= 1;           /* private flag, +0x23 bit0 */
        return 0;
    }
    seglist = base->bb_SegList;
    Remove((struct Node *)base);
    if (expnamebase)
        CloseLibrary(expnamebase);
    FreeMem((UBYTE *)base - base->bb_Lib.lib_NegSize,
            (ULONG)base->bb_Lib.lib_NegSize + base->bb_Lib.lib_PosSize);
    return seglist;
}

/*
** LibInit -- d0 = libbase, a0 = seglist, a6 = ExecBase.
** Stores base into the dead code cell, SysBase->+0x24, seg->+0x28,
** opens expname.library v1 into the second cell.  Returns the base,
** or NULL if expname.library could not be opened (the library then
** fails to load).
*/
struct Library *LibInit(register struct BoardsBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"));

struct Library *LibInit(register struct BoardsBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"))
{
    register struct ExecBase *eb __asm("a6");

    selfbase        = (struct Library *)base;
    base->bb_SysBase = eb;
    base->bb_SegList = seglist;
    expnamebase = __OpenLibrary_base(eb, expnamename, 1);
    if (!expnamebase)
        return NULL;
    return (struct Library *)base;
}

/* LVO -6 */
struct Library *LibOpen(void);
struct Library *LibOpen(void)
{
    register struct BoardsBase *base __asm("a6");
    base->bb_Lib.lib_OpenCnt++;
    base->bb_ExpungeReq &= ~1;      /* bclr #0,35(a6) */
    return (struct Library *)base;
}

/* LVO -12 */
ULONG LibClose(void);
ULONG LibClose(void)
{
    register struct BoardsBase *base __asm("a6");
    ULONG seg = 0;

    if (--base->bb_Lib.lib_OpenCnt == 0 && (base->bb_ExpungeReq & 1))
        seg = DoExpunge(base);
    return seg;
}

/* LVO -18 */
ULONG LibExpunge(void);
ULONG LibExpunge(void)
{
    register struct BoardsBase *base __asm("a6");
    return DoExpunge(base);
}

/* LVO -24 (reserved) */
LONG LibNull(void);
LONG LibNull(void)
{
    return 0;
}
