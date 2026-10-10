/*
**	wbstart.c -- wbstart.library 45.2 (16.07.01)
**	"Emulation by Stephan Rupprecht"
**
**	C reconstruction of the shipped binary (1760 bytes, sha256
**	c0b12320ccbce1727d196ba31f35f26fede2aa0a71987f4a878696b50b01adc9).
**
**	Two-hunk module: the code hunk holds everything code-ish
**	(entry stubs, init, the four exec vectors, the WBStart
**	vector and its private helpers) while the DATA hunk
**	carries the function table, name/id strings, InitTable,
**	RomTag and EndSkip.
**
**	This 45.2 is a clean-room style emulation of the original
**	45.1: same library base layout (0x38) and same public
**	vector (LVO -36, tags in a0, base in a6, 0 = ok /
**	20 = RETURN_ERROR on failure), but the object start is
**	implemented differently:
**
**	  - "VOL:" (trailing colon)  -> OpenWorkbenchObjectA(name)
**	  - "vol:dir/file"           -> Lock(name) or Lock(name.info);
**	                              on success CurrentDir() into the
**	                              lock's parent and open FilePart()
**	  - bare "name"              -> same lock probe in the current
**	                              dir; on failure iterate the
**	                              Workbench search path obtained via
**	                              WorkbenchControlA(
**	                                WBCTRLA_DuplicateSearchPath);
**	                              if nothing matches, print a
**	                              dos fault via PrintFault()
**
**	The lock probe LockObjectOrInfo() first tries Lock(name) and
**	falls back to Lock("<name>.info") built in a 256-byte stack
**	buffer with two bounded copy/append helpers.  Two further
**	libc-style string routines in the code hunk (strcat/strcpy
**	shapes) are never called -- dead code, kept for parity.
**
**	Public API (names reconstructed -- the binary ships no fd):
**	  LVO -36  WBStart(tagList) -> 0 ok / 20 fail
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
**	Quirks reproduced faithfully:
**	  - RomTag says RT_VERSION 2 and init writes lib_Revision = 2
**	    and ALSO patches the RomTag RT_VERSION byte at runtime.
**	  - If any init OpenLibrary fails, CloseLibs() calls
**	    CloseLibrary() on all three slots unconditionally --
**	    including NULL ones (would crash; preserved as-is).
**	  - The tag loop tests the NextTagItem result with the
**	    68000-illegal TST.L A0 opcode (0x4a88); semantics kept.
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

#define WBS_RETURN_FAIL 20		/* binary returns 20 = RETURN_ERROR */

/*
 * Private library base, InitTable dataSize = 0x38 (56) -- same
 * layout as the original 45.1.
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

/*
 * Workbench search path list element: a BPTR-chained list of
 * {next, dirlock} pairs, duplicated/freed via WorkbenchControlA()
 * WBCTRLA_DuplicateSearchPath / WBCTRLA_FreeSearchPath.
 */
struct WBSearchPath
{
    BPTR sp_Next;                 /* BPTR to next element      */
    BPTR sp_Lock;                 /* BPTR dir lock of element  */
};

extern const char _libname[];
extern const char _idstr[];
extern UBYTE rtversion[];          /* RomTag RT_VERSION byte      */

/* string literals land in the code hunk, as in the original */
static const char wbname[]   = "workbench.library";
static const char dosname[]  = "dos.library";
static const char utilname[] = "utility.library";

/* ------------------------------------------------------------------ */
/* bounded string helpers (compiler runtime in the original)          */
/* ------------------------------------------------------------------ */

/*
 * copypad(dst, src, n) -- original LAB_003D.
 * Copies src to dst for at most n+1 bytes; when the source NUL is
 * reached the rest of the n+1 byte field is zero-filled.  No NUL is
 * appended when src is longer than n.
 */
static void copypad(STRPTR dst, const UBYTE *src, LONG n)
{
    LONG i;

    for (i = 0; i <= n; i++) {
        dst[i] = src[i];
        if (src[i] == 0) {
            while (++i <= n)
                dst[i] = 0;
            return;
        }
    }
}

/*
 * appendn(dst, src, n) -- original LAB_0037.
 * Bounded strcat: appends at most n bytes of src at the end of dst
 * and always leaves the result NUL-terminated.
 */
static void appendn(STRPTR dst, const UBYTE *src, LONG n)
{
    while (*dst)
        dst++;
    while (n-- > 0) {
        if ((*dst++ = *src++) == 0)
            return;
    }
    *dst = 0;
}

/*
 * Dead code in the original binary: classic strcat/strcpy runtime
 * routines that are never called.  Kept (non-static, so they stay
 * in the code hunk) to mirror the shipped layout.
 */
STRPTR wbs_strcat(STRPTR dst, const UBYTE *src)
{
    STRPTR d = dst;
    while (*d)
        d++;
    while ((*d++ = *src++) != 0)
        ;
    return dst;
}

STRPTR wbs_strcpy(STRPTR dst, const UBYTE *src)
{
    STRPTR d = dst;
    while ((*d++ = *src++) != 0)
        ;
    return dst;
}

/* ------------------------------------------------------------------ */
/* init / open / close / expunge                                      */
/* ------------------------------------------------------------------ */

/*
 * OpenLibs -- original LAB_000E.  Opens workbench.library v45,
 * dos.library v40, utility.library v40 into the base slots.
 * Returns 1 when all three opened, 0 otherwise.  Slots of failed
 * opens stay NULL (the original does not close partial opens here;
 * the caller's CloseLibs() hits the NULL slots).
 */
static LONG OpenLibs(struct WBStartBase *b)
{
    struct ExecBase *sys = b->wb_SysBase;

    if (!(b->wb_WBBase = __OpenLibrary_base(sys, (STRPTR)wbname, 45)))
        return 0;
    if (!(b->wb_DOSBase = __OpenLibrary_base(sys, (STRPTR)dosname, 40)))
        return 0;
    b->wb_UtBase = __OpenLibrary_base(sys, (STRPTR)utilname, 40);
    return b->wb_UtBase != NULL;
}

/*
 * CloseLibs -- original LAB_0012.  Closes all three support
 * libraries unconditionally (CloseLibrary(NULL) on unopened
 * slots -- a crash quirk of the original, kept verbatim).
 */
static void CloseLibs(struct WBStartBase *b)
{
    struct ExecBase *sys = b->wb_SysBase;

    __CloseLibrary_base(sys, b->wb_WBBase);
    __CloseLibrary_base(sys, b->wb_DOSBase);
    __CloseLibrary_base(sys, b->wb_UtBase);
}

/*
 * LibInit -- MakeLibrary initFunc, d0 = base, a0 = seglist,
 * a6 = SysBase.  On success also patches the RomTag RT_VERSION
 * byte with 2 (self-modifying write into the data hunk).
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

    if (OpenLibs(b)) {
        rtversion[0] = 2;			/* RomTag version patch */
        return (struct Library *)b;
    }

    CloseLibs(b);

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

    CloseLibs(base);

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

/* ------------------------------------------------------------------ */
/* private helpers for WBStart                                        */
/* ------------------------------------------------------------------ */

/*
 * LockObjectOrInfo -- original LAB_001A.
 * Returns a dos Lock() on 'name' (ACCESS_READ); when that fails,
 * builds "<name>.info" in a 256-byte stack buffer (bounded
 * copy + append) and locks that instead.  Returns the lock or 0.
 */
static BPTR LockObjectOrInfo(STRPTR name, struct WBStartBase *base)
{
    struct Library *dos = base->wb_DOSBase;
    UBYTE           buf[260];
    BPTR            lock;

    lock = __Lock_base(dos, name, ACCESS_READ);
    if (!lock) {
        copypad((STRPTR)buf, name, 256);
        appendn((STRPTR)buf, (const UBYTE *)".info", 256);
        lock = __Lock_base(dos, (STRPTR)buf, ACCESS_READ);
    }
    return lock;
}

/*
 * StartObject -- original LAB_001C.
 * Opens the Workbench object 'name' with the pre-built tag list.
 * Returns the (word-extended) boolean result of
 * OpenWorkbenchObjectA(), or 0.
 */
static LONG StartObject(STRPTR name, struct TagItem *wbtags,
                        struct WBStartBase *base)
{
    struct Library *dos = base->wb_DOSBase;
    struct Library *wb  = base->wb_WBBase;
    STRPTR          s   = name;
    LONG            res;
    BPTR            lock, parent, old;
    UBYTE           c;

    if (*s) {
        /* scan for ':' */
        for (;;) {
            c = *s++;
            if (c == ':') {
                if (!*s) {
                    /* "VOL:" -- open the volume root directly */
                    return (LONG)(WORD)
                        __OpenWorkbenchObjectA_base(wb, name, wbtags);
                }
                /* "dev:dir/file" -- probe lock first */
                lock = LockObjectOrInfo(name, base);
                if (!lock)
                    return 0;
                parent = __ParentDir_base(dos, lock);
                old    = __CurrentDir_base(dos, parent);
                res = (LONG)(WORD)
                    __OpenWorkbenchObjectA_base(wb,
                        (STRPTR)__FilePart_base(dos, name), wbtags);
                __UnLock_base(dos, __CurrentDir_base(dos, old));
                __UnLock_base(dos, lock);
                return res;
            }
            if (!*s)
                break;		/* end of string, no colon */
        }
    }

    /* unqualified name -- try the current directory first */
    lock = LockObjectOrInfo(name, base);
    if (lock) {
        res = (LONG)(WORD)
            __OpenWorkbenchObjectA_base(wb, name, wbtags);
        __UnLock_base(dos, lock);
        return res;
    }

    /* walk the Workbench search path */
    {
        BPTR                 pathlist = 0;
        struct WBSearchPath *node;
        struct TagItem       ctags[2];
        struct TagItem       ftags[2];

        ctags[0].ti_Tag  = WBCTRLA_DuplicateSearchPath;
        ctags[0].ti_Data = (ULONG)&pathlist;
        ctags[1].ti_Tag  = TAG_DONE;
        __WorkbenchControlA_base(wb, NULL, ctags);

        if (!pathlist)
            return 0;

        node = BADDR(pathlist);
        while (node) {
            old  = __CurrentDir_base(dos, node->sp_Lock);
            lock = LockObjectOrInfo(name, base);
            if (lock) {
                res = (LONG)(WORD)
                    __OpenWorkbenchObjectA_base(wb, name, wbtags);
                __CurrentDir_base(dos, old);
                __UnLock_base(dos, lock);
                break;
            }
            __CurrentDir_base(dos, old);
            node = BADDR(node->sp_Next);
        }
        if (!node)
            __PrintFault_base(dos, __IoErr_base(dos), name);

        ftags[0].ti_Tag  = WBCTRLA_FreeSearchPath;
        ftags[0].ti_Data = (ULONG)pathlist;
        ftags[1].ti_Tag  = TAG_DONE;
        __WorkbenchControlA_base(wb, NULL, ftags);

        return node ? res : 0;
    }
}

/* ------------------------------------------------------------------ */
/* WBStart (LVO -36)                                                  */
/* ------------------------------------------------------------------ */

/*
 * WBStart (LVO -36): open a Workbench object with optional arg
 * pairs and an optional current-directory override.
 *
 *	a0:	struct TagItem *tags
 *	a6:	library base
 *
 * Returns 0 when the object could be opened, 20 (RETURN_ERROR)
 * otherwise -- including "no WBSTARTA_Name tag".
 */
LONG WBStart(struct TagItem *tags __asm("a0"),
             struct WBStartBase *base __asm("a6"))
{
    struct ExecBase *sys    = base->wb_SysBase;
    struct Library  *dos    = base->wb_DOSBase;
    struct Library  *ut     = base->wb_UtBase;
    STRPTR           name   = NULL;
    BPTR             lock   = 0;
    BPTR             oldcd  = 0;
    ULONG            nargs  = 0;
    ULONG           *args   = NULL;
    LONG             ret    = WBS_RETURN_FAIL;
    struct TagItem  *wbtags = NULL;
    struct TagItem  *state  = tags;
    struct TagItem  *ti;
    ULONG            i;

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

    if (lock)
        oldcd = __CurrentDir_base(dos, lock);

    if (StartObject(name, wbtags, base))
        ret = 0;

    if (lock)
        __CurrentDir_base(dos, oldcd);

    __FreeVec_base(sys, wbtags);

out:
    __UnLock_base(dos, lock);
    return ret;
}
