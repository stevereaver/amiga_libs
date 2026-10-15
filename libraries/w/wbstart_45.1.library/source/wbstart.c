/*
**	wbstart.c -- wbstart.library 45.1 (16.12.00)
**
**	C reconstruction of the shipped binary (1008 bytes, sha256
**	2f627e3c293159a651d12068ee384e7879e928d48902edad5dd8950c21646460).
**
**	Two-hunk module: the code hunk holds everything code-ish
**	(entry stubs, init, the four exec vectors and the one real
**	function) while the DATA hunk carries the function table,
**	name/id strings, InitTable, RomTag and EndSkip.
**
**	Library opens workbench.library v45, utility.library v40 and
**	dos.library v40 at init.  Its single entry point
**	WBStart(tags) (LVO -36) converts a tag list into a
**	workbench OpenWorkbenchObjectA() call, optionally after a
**	directory change to a supplied lock or to the directory of
**	the named object.
**
**	Public API (names reconstructed -- the binary ships no fd):
**	  LVO -36  WBStart(tagList) -> 0 ok / 20 (RETURN_ERROR) fail
**	  LVO -30  reserved stub returning 0
**
**	Tags (TAG_USER+1 .. TAG_USER+7):
**	  WBSTARTA_Name    0x80000001  object name (required)
**	  WBSTARTA_Lock    0x80000002  BPTR of dir to CD to (Lock'ed copy)
**	  WBSTARTA_DupLock 0x80000003  BPTR of dir to CD to (DupLock'ed)
**	  (TAG_USER+4,+5 are accepted and ignored)
**	  WBSTARTA_NumArgs 0x80000006  number of {lock,name} arg pairs
**	  WBSTARTA_Args    0x80000007  array of {lock,name} pairs
**
**	Args are converted into a WBOPENA_ArgLock/WBOPENA_ArgName
**	tag list which is passed to OpenWorkbenchObjectA().
**
**	Quirk reproduced faithfully: the RomTag says RT_VERSION 2 and
**	the init routine writes lib_Revision = 2, although the
**	IdString advertises 45.1.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <utility/tagitem.h>
#include <workbench/workbench.h>
#include <inline/exec.h>
#include <inline/dos.h>
#include <inline/utility.h>
#include <inline/wb.h>

/* wbstart.library private tags (TAG_USER based), names reconstructed */
#define WBSTARTA_Name    (TAG_USER + 1)	/* STRPTR object to open	*/
#define WBSTARTA_Lock    (TAG_USER + 2)	/* BPTR dir, Lock()ed copy	*/
#define WBSTARTA_DupLock (TAG_USER + 3)	/* BPTR dir, DupLock()ed	*/
#define WBSTARTA_NumArgs (TAG_USER + 6)	/* LONG arg pair count		*/
#define WBSTARTA_Args    (TAG_USER + 7)	/* LONG pairs: lock, name	*/

#define WBS_RETURN_FAIL 20		/* binary returns 20 = RETURN_FAIL */

/*
 * Private library base, InitTable dataSize = 0x38 (56).
 */
struct WBStartBase
{
    struct Library   wb_Lib;      /* 0x00 */
    BPTR             wb_SegList;  /* 0x24 */
    struct ExecBase *wb_SysBase;  /* 0x28 */
    struct Library  *wb_WBBase;   /* 0x2c workbench.library v45 */
    struct Library  *wb_UtBase;   /* 0x30 utility.library v40   */
    struct Library  *wb_DOSBase;  /* 0x34 dos.library v40       */
};

extern const char _libname[];
extern const char _idstr[];

/* string literals land in the code hunk, as in the original */
static const char wbname[]   = "workbench.library";
static const char dosname[]  = "dos.library";
static const char utilname[] = "utility.library";

/*
 * LibInit -- MakeLibrary initFunc, d0 = base, a0 = seglist,
 * a6 = SysBase.  Opens the three support libraries (workbench v45,
 * dos v40, utility v40); on any failure closes whatever was opened,
 * frees the base and returns 0.
 */
struct Library *LibInit(struct WBStartBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6");
    struct WBStartBase *b = base;
    UBYTE *block;
    ULONG  size;

    b->wb_SysBase = sysbase;
    b->wb_SegList = seglist;
    b->wb_Lib.lib_Revision = 2;		/* shipped binary writes 2 */

    if (!(b->wb_WBBase = __OpenLibrary_base(sysbase,
                                          (STRPTR)wbname, 45)))
        goto fail;
    if (!(b->wb_DOSBase = __OpenLibrary_base(sysbase,
                                           (STRPTR)dosname, 40)))
        goto fail;
    if (!(b->wb_UtBase = __OpenLibrary_base(sysbase,
                                          (STRPTR)utilname, 40)))
        goto fail;

    return (struct Library *)b;

fail:
    __CloseLibrary_base(sysbase, b->wb_WBBase);
    __CloseLibrary_base(sysbase, b->wb_DOSBase);
    __CloseLibrary_base(sysbase, b->wb_UtBase);

    block = (UBYTE *)b - b->wb_Lib.lib_NegSize;
    size  = (ULONG)b->wb_Lib.lib_NegSize + b->wb_Lib.lib_PosSize;
    __FreeMem_base(sysbase, block, size);
    return 0;
}

/*
 * LibOpen (LVO -6): clear LIBF_DELEXP, bump lib_OpenCnt, return base.
 */
struct Library *LibOpen(struct WBStartBase *base __asm("a6"))
{
    base->wb_Lib.lib_Flags &= ~LIBF_DELEXP;
    base->wb_Lib.lib_OpenCnt++;
    return (struct Library *)base;
}

static BPTR DoExpunge(struct WBStartBase *base)
{
    struct ExecBase *sys = base->wb_SysBase;
    BPTR             seg;
    UBYTE           *block;
    ULONG            size;

    __CloseLibrary_base(sys, base->wb_WBBase);
    __CloseLibrary_base(sys, base->wb_DOSBase);
    __CloseLibrary_base(sys, base->wb_UtBase);

    __Remove_base(sys, (struct Node *)base);
    seg = base->wb_SegList;

    block = (UBYTE *)base - base->wb_Lib.lib_NegSize;
    size  = (ULONG)base->wb_Lib.lib_NegSize + base->wb_Lib.lib_PosSize;
    __FreeMem_base(sys, block, size);
    return seg;
}

/*
 * LibExpunge (LVO -18): if still in use just set LIBF_DELEXP and
 * return 0; otherwise close the support libraries, unlink the
 * base, free it and return the seglist.
 */
BPTR LibExpunge(struct WBStartBase *base __asm("a6"))
{
    if (base->wb_Lib.lib_OpenCnt) {
        base->wb_Lib.lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    return DoExpunge(base);
}

/*
 * LibClose (LVO -12): decrement lib_OpenCnt; when it reaches zero
 * (or already was zero) with LIBF_DELEXP set, expunge.
 */
BPTR LibClose(struct WBStartBase *base __asm("a6"))
{
    UWORD old = base->wb_Lib.lib_OpenCnt;

    if (old)
        --base->wb_Lib.lib_OpenCnt;
    if ((old == 0 || old == 1) &&
        (base->wb_Lib.lib_Flags & LIBF_DELEXP))
        return DoExpunge(base);
    return 0;
}

/*
 * WBStart (LVO -36): open a Workbench object with optional arg
 * pairs and an optional current-directory override.
 *
 *	a0:	struct TagItem *tags
 *	a6:	library base
 *
 * Returns 0 when OpenWorkbenchObjectA() succeeded, RETURN_ERROR
 * (20) otherwise -- including "no WBSTARTA_Name tag".
 */
LONG WBStart(struct TagItem *tags __asm("a0"),
             struct WBStartBase *base __asm("a6"))
{
    struct ExecBase *sys    = base->wb_SysBase;
    struct Library  *dos    = base->wb_DOSBase;
    struct Library  *ut     = base->wb_UtBase;
    struct Library  *wb     = base->wb_WBBase;
    STRPTR           name   = NULL;   /* d6 */
    BPTR             lock   = 0;      /* d5 */
    BPTR             oldcd  = 0;      /* d7 */
    ULONG            nargs  = 0;      /* d3 */
    ULONG           *args   = NULL;   /* a2 -- {lock,name} pairs */
    struct TagItem  *wbtags = NULL;   /* 40(sp) */
    struct TagItem  *state;
    struct TagItem  *ti;
    LONG             ret    = WBS_RETURN_FAIL; /* a4 = 0x14 */
    ULONG            i;
    STRPTR           p;
    UBYTE            saved;

    state = tags;
    while ((ti = __NextTagItem_base(ut, &state))) {
        ULONG data = ti->ti_Data;
        switch (ti->ti_Tag) {
        case WBSTARTA_Name:
            name = (STRPTR)data;
            break;
        case WBSTARTA_Lock:
            if (data) {
                __UnLock_base(dos, lock);
                lock = __Lock_base(dos, (STRPTR)data, ACCESS_READ);
            }
            break;
        case WBSTARTA_DupLock:
            if (data) {
                __UnLock_base(dos, lock);
                lock = __DupLock_base(dos, (BPTR)data);
            }
            break;
        case WBSTARTA_NumArgs:
            nargs = data;
            break;
        case WBSTARTA_Args:
            args = (ULONG *)data;
            break;
        default:
            break;			/* +4, +5, others: ignored */
        }
    }

    if (!name)
        goto out;

    /* build the WBOPENA_ArgLock/ArgName tag list */
    if (nargs && args) {
        wbtags = __AllocVec_base(sys, (nargs + 1) * 16, 0);
        if (wbtags) {
            struct TagItem *t = wbtags;
            for (i = 0; i < nargs; i++) {
                t->ti_Tag  = WBOPENA_ArgLock;
                t->ti_Data = args[i * 2];
                t++;
                t->ti_Tag  = WBOPENA_ArgName;
                t->ti_Data = args[i * 2 + 1];
                t++;
            }
            t->ti_Tag = TAG_DONE;
        } else {
            wbtags = (struct TagItem *)-1;
        }
    }

    if (wbtags == (struct TagItem *)-1)
        goto out;

    if (lock) {
        oldcd = __CurrentDir_base(dos, lock);
    } else {
        p = __PathPart_base(dos, name);
        if (p != name) {
            saved = *p;
            *p    = 0;
            lock  = __Lock_base(dos, name, ACCESS_READ);
            if (lock)
                oldcd = __CurrentDir_base(dos, lock);
            *p   = saved;
            name = p;
            if (saved == '/')
                name++;
        }
    }

    if (__OpenWorkbenchObjectA_base(wb, name, wbtags))
        ret = 0;

    if (lock)
        __CurrentDir_base(dos, oldcd);

    __FreeVec_base(sys, wbtags);

out:
    __UnLock_base(dos, lock);
    return ret;
}
