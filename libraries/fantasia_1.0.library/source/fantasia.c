/*
**	fantasia.c -- fantasia.library 1.0
**
**	C reconstruction of the shipped binary "fantasia_1.0.library"
**	(id: "fantasia.library 1.0").
**
**	Joystick helper library: two public vectors read the
**	custom-chip JOY1DAT/POTGOR and CIAA PRA registers (see
**	fantasia_hw.s -- they return in d3/d2, not d0).
**
**	Library base (dataSize 0x30):
**	  0x00  struct Library
**	  0x22  ExecBase (stored at init)
**	  0x26  dos.library base (opened at init, closed at expunge)
**	  0x2a  segment list
**	  0x2e  private expunge-request flag (bit 3)
**
**	All exec calls in the original go through the stored SysBase
**	(base+0x22), not the absolute $4.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <inline/exec.h>

struct FantasiaBase {
    struct Library   fb_Lib;        /* 0x00-0x21 */
    struct ExecBase *fb_SysBase;    /* 0x22 */
    struct Library  *fb_DOSBase;    /* 0x26 */
    ULONG            fb_SegList;    /* 0x2a */
    UBYTE            fb_ExpungeReq; /* 0x2e bit3: deferred expunge */
    UBYTE            fb_pad;        /* 0x2f */
};                                  /* dataSize = 0x30 */

extern char dosname[];             /* "dos.library" (fantasia_lib.s) */

static ULONG DoExpunge(struct FantasiaBase *base)
{
    struct ExecBase *eb = base->fb_SysBase;
    ULONG seglist;

    if (base->fb_Lib.lib_OpenCnt) {
        base->fb_ExpungeReq |= 8;           /* bset #3,46(a5) */
        return 0;
    }
    seglist = base->fb_SegList;             /* +0x2a */
    __Remove_base(eb, (struct Node *)base);
    __CloseLibrary_base(eb, base->fb_DOSBase);
    __FreeMem_base(eb, (UBYTE *)base - base->fb_Lib.lib_NegSize,
                   (ULONG)base->fb_Lib.lib_NegSize +
                   base->fb_Lib.lib_PosSize);
    return seglist;
}

/*
** LibInit -- d0 = libbase, a0 = seglist, a6 = ExecBase.
** Stores SysBase->+0x22, seglist->+0x2a, opens dos.library v1 ->
** +0x26.  The original ends with `bne.l +4` (66ff 0000 0004, a
** never-taken 68020-form branch) so the base is returned whether or
** not the open succeeded -- preserved here.
*/
struct Library *LibInit(register struct FantasiaBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"));

struct Library *LibInit(register struct FantasiaBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"))
{
    register struct ExecBase *eb __asm("a6");

    base->fb_SysBase = eb;
    base->fb_SegList = seglist;
    base->fb_DOSBase = __OpenLibrary_base(eb, dosname, 1);
    return (struct Library *)base;
}

/* LVO -6 */
struct Library *LibOpen(void);
struct Library *LibOpen(void)
{
    register struct FantasiaBase *base __asm("a6");
    base->fb_Lib.lib_OpenCnt++;
    base->fb_ExpungeReq &= ~8;              /* bclr #3,46(a6) */
    return (struct Library *)base;
}

/*
** LVO -12.  Original tests the flag through a5 -- which was never
** set in this routine (it still holds the CALLER's a5): an original
** bug, reproduced.  Effective condition: byte at caller-a5+0x2e,
** bit 3.
*/
ULONG LibClose(void);
ULONG LibClose(void)
{
    register struct FantasiaBase *base  __asm("a6");
    register struct FantasiaBase *bogus __asm("a5");
    ULONG seg = 0;

    if (--base->fb_Lib.lib_OpenCnt == 0 && (bogus->fb_ExpungeReq & 8))
        seg = DoExpunge(base);
    return seg;
}

/*
** LVO -18.  Original pushes d1/a5/a6 but pops d2/a5/a6 -- caller's
** d2 ends up holding caller's old d1.  Harmless register-side-effect
** quirk; the C version saves/restores correctly.
*/
ULONG LibExpunge(void);
ULONG LibExpunge(void)
{
    register struct FantasiaBase *base __asm("a6");
    return DoExpunge(base);
}

/* LVO -24 (reserved) */
LONG LibNull(void);
LONG LibNull(void)
{
    return 0;
}
