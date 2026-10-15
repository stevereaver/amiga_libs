/*
**	lsdetect.c -- lsdetect.library 1.0
**	"LightShock EnvDetector V1.0"
**
**	C reconstruction of the shipped binary (1160 bytes, sha256
**	a10b42269e2c80dc830d84bc4649d0adf3645ff702fc9bfacd55bc09f992ddf9).
**
**	Environment detector for the LightShock game engine:
**	  - LSDetectLanguage (-30): returns a language index 0
**	    (Italiano) / 1 (English, default) / 2 (Deutsch), from
**	    lowlevel GetLanguageSelection(), else the locale's
**	    language-name prefix, else a RAW: window that asks the
**	    user to hit F1/F2/F3.  Result is cached in a base byte.
**	  - LSBorrowScreen (-42): stashes Intuition's ActiView, saves
**	    colour 0, blacks it and LoadView(0)s -- one-shot.
**	  - LSReleaseScreen (-36): puts the saved view back and
**	    restores colour 0.
**
**	Init opens graphics, lowlevel, dos and locale libraries with
**	no failure checks; the detection chain tolerates each being
**	missing at call time.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <graphics/gfxbase.h>
#include <inline/exec.h>
#include <inline/dos.h>
#include <inline/graphics.h>
#include <inline/lowlevel.h>
#include <inline/locale.h>

/* lowlevel.library -36 = GetLanguageSelection */
#define LSL_ITALIANO 0
#define LSL_ENGLISH  1
#define LSL_DEUTSCH  2

/*
 * Private library base, InitTable dataSize = 0x44 (68).
 */
struct LSDBase
{
    struct Library   lb_Lib;      /* 0x00 */
    UBYTE            lb_Flags;    /* 0x22 bit 3 = deferred expunge */
    BYTE             lb_Lang;     /* 0x23 cached result, -1 unset */
    struct ExecBase *lb_SysBase;  /* 0x24 */
    struct Library  *lb_GfxBase;  /* 0x28 graphics.library  */
    struct Library  *lb_LLBase;   /* 0x2c lowlevel.library  */
    struct Library  *lb_LocBase;  /* 0x30 locale.library    */
    struct Library  *lb_DOSBase;  /* 0x34 dos.library       */
    APTR             lb_SavedView;/* 0x38 borrowed ActiView */
    ULONG            lb_SavedRGB; /* 0x3c saved colour 0    */
    BPTR             lb_SegList;  /* 0x40 */
};

extern const char _libname[];
extern const char _idstr[];

static const char gfxname[] = "graphics.library";
static const char llname[]  = "lowlevel.library";
static const char dosname[] = "dos.library";
static const char locname[] = "locale.library";
static const char rawname[] = "RAW:0/0/600/120/Language Selection";
static const char prompt[]  =
    "\n Please select your preferred language:\n"
    "\n   F1 - Italiano\n"
    "\n   F2 - English\n"
    "\n   F3 - Deutsch\n";

/*
 * LibInit (d0 = base, a0 = seglist, a6 = SysBase): store pointers,
 * open the four libraries (unchecked), mark language unknown.
 */
struct Library *LibInit(struct LSDBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6");

    base->lb_SysBase  = sysbase;
    base->lb_SegList  = seglist;
    base->lb_GfxBase  = __OpenLibrary_base(sysbase, (STRPTR)gfxname, 0);
    base->lb_LLBase   = __OpenLibrary_base(sysbase, (STRPTR)llname, 0);
    base->lb_DOSBase  = __OpenLibrary_base(sysbase, (STRPTR)dosname, 0);
    base->lb_LocBase  = __OpenLibrary_base(sysbase, (STRPTR)locname, 0);
    base->lb_Lang     = -1;
    base->lb_SavedView = 0;
    return (struct Library *)base;
}

/* LVO -6 */
struct Library *LibOpen(struct LSDBase *base __asm("a6"))
{
    base->lb_Lib.lib_OpenCnt++;
    return (struct Library *)base;
}

static BPTR DoExpunge(struct LSDBase *base)
{
    struct ExecBase *sys = base->lb_SysBase;
    BPTR             seg = base->lb_SegList;
    UBYTE           *block;
    ULONG            size;

    /* original unlinks with an open-coded Remove */
    __Remove_base(sys, (struct Node *)base);

    if (base->lb_LocBase) __CloseLibrary_base(sys, base->lb_LocBase);
    if (base->lb_DOSBase) __CloseLibrary_base(sys, base->lb_DOSBase);
    if (base->lb_LLBase)  __CloseLibrary_base(sys, base->lb_LLBase);
    if (base->lb_GfxBase) __CloseLibrary_base(sys, base->lb_GfxBase);

    block = (UBYTE *)base - base->lb_Lib.lib_NegSize;
    size  = (ULONG)base->lb_Lib.lib_NegSize + base->lb_Lib.lib_PosSize;
    __FreeMem_base(sys, block, size);
    return seg;
}

/* LVO -18 */
BPTR LibExpunge(struct LSDBase *base __asm("a6"))
{
    if (base->lb_Lib.lib_OpenCnt) {
        /* deferred: bit 3 of the private byte, not lib_Flags */
        base->lb_Flags |= 0x08;
        return 0;
    }
    return DoExpunge(base);
}

/* LVO -12 */
BPTR LibClose(struct LSDBase *base __asm("a6"))
{
    base->lb_Lib.lib_OpenCnt--;
    if (base->lb_Lib.lib_OpenCnt == 0 && (base->lb_Flags & 0x08))
        return DoExpunge(base);
    return 0;
}

/*
 * LVO -30: detect language, cached at base+35.
 *
 * lowlevel GetLanguageSelection(): 6 -> 0, 3 -> 2, else 1.
 * locale: OpenLocale(0)->loc_LanguageName prefix
 *   "ital" -> 0, "deut" -> 2, else 1.
 * else open a RAW: console, print the prompt, read RAW-key
 * bytes: skip until 0x9b (CSI), then take digit '0'..'2'.
 */
LONG LSDetectLanguage(struct LSDBase *base __asm("a6"))
{
    LONG  lang;
    LONG  ret;
    int   try_dos = 0;

    lang = base->lb_Lang;
    if (lang >= 0)
        return lang;

    if (base->lb_LLBase) {
        LONG sel = __GetLanguageSelection_base(base->lb_LLBase);
        if (sel == 6)      ret = LSL_ITALIANO;
        else if (sel == 3) ret = LSL_DEUTSCH;
        else               ret = LSL_ENGLISH;
    } else if (base->lb_LocBase) {
        struct Locale *loc;
        loc = __OpenLocale_base(base->lb_LocBase, 0);
        if (loc) {
            STRPTR lname = *(STRPTR *)((UBYTE *)loc + 4);
            LONG   target = LSL_ENGLISH;
            if (*(ULONG *)lname == 0x6974616c)      /* "ital" */
                target = LSL_ITALIANO;
            else if (*(ULONG *)lname == 0x64657574) /* "deut" */
                target = LSL_DEUTSCH;
            __CloseLocale_base(base->lb_LocBase, loc);
            ret = target;
        } else {
            try_dos = 1;            /* OpenLocale failed */
        }
    } else {
        try_dos = 1;                /* neither ll nor locale */
    }

    if (try_dos) {
        register struct Library *dos = base->lb_DOSBase;
        ret = LSL_ENGLISH;
        if (dos) {
            BPTR fh = __Open_base(dos, (STRPTR)rawname, MODE_OLDFILE);
            if (fh) {
                UBYTE k;
                LONG  ch;
                __Write_base(dos, fh, (APTR)prompt, 94);
                for (;;) {
                    if (__Read_base(dos, fh, &k, 1) == -1)
                        break;
                    if (k != 0x9b)
                        continue;
                    if (__Read_base(dos, fh, &k, 1) == -1)
                        break;
                    ch = k - '0';
                    if (ch >= 0 && ch <= 2) {
                        __Close_base(dos, fh);
                        ret = ch;
                        goto done;
                    }
                }
                __Close_base(dos, fh);
            }
        }
    }

done:
    base->lb_Lang = (BYTE)ret;
    return ret;
}

/*
 * LVO -36: put the borrowed view back and restore colour 0.
 */
void LSReleaseScreen(struct LSDBase *base __asm("a6"))
{
    APTR view = base->lb_SavedView;
    if (!view)
        return;
    {
        struct Library *gfx = base->lb_GfxBase;
        ULONG rgb  = base->lb_SavedRGB;
        APTR cm    = *(APTR *)view;   /* first field = ColorMap */

        __LoadView_base(gfx, view);
        __WaitTOF_base(gfx);
        __WaitTOF_base(gfx);
        __SetRGB4_base(gfx, cm, 0, (rgb >> 8) & 0xf,
                       (rgb >> 4) & 0xf, rgb & 0xf);
    }
    base->lb_SavedView = 0;
}

/*
 * LVO -42: borrow Intuition's ActiView once: save it plus
 * colour entry 0, set entry 0 to black, LoadView(0), WaitTOF x2.
 */
LONG LSBorrowScreen(struct LSDBase *base __asm("a6"))
{
    struct GfxBase *gfx = (struct GfxBase *)base->lb_GfxBase;
    APTR view;

    if (base->lb_SavedView)
        return 0;
    view = gfx->ActiView;
    if (view) {
        struct Library *g  = base->lb_GfxBase;
        APTR            cm = *(APTR *)view;   /* ColorMap pointer */

        base->lb_SavedView = view;
        /* verbatim: GetRGB4 is called on *(cm+4), the ColorTable
           pointer -- not on the ColorMap itself */
        base->lb_SavedRGB =
            __GetRGB4_base(g, *(APTR *)((UBYTE *)cm + 4), 0);
        __SetRGB4_base(g, cm, 0, 0, 0, 0);
        __LoadView_base(g, 0);
        __WaitTOF_base(g);
        __WaitTOF_base(g);
    }
    return 0;
}
