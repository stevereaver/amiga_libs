/* newicon.c -- C reconstruction of newicon.library 44.0 (30.12.99)
 * "emulation (C) 2000 by Stephan Rupprecht".
 *
 * The binary is a thin emulation layer over icon.library v44: it loads
 * native v44 color icons via GetIconTagList/IconControlA and repackages
 * their images+palettes into the 16-byte "newicon image record" format
 * used by the original NewIcons system, exposing them through a 12-byte
 * handle { DiskObject*, imgrec1*, imgrec2* }.
 *
 * Decode notes (all offsets byte-exact vs the shipped binary):
 *   - DiskObject fields used with the v44 layout: +12/+14 gadget w/h,
 *     +16 ga_Flags, +22 ga_GadgetRender, +54 do_ToolTypes, +78 FreeList.
 *   - Open refuses callers whose program FilePart is a prefix of
 *     "newicons" (incl. the empty string) -- the emulation must not be
 *     loaded by the real NewIcons commodity itself.
 *   - Icons that are not palette-mapped fall back to their DEFAULTIMAGE
 *     tooltype (recursion with mode=2).
 *   - remap() swaps palette entry 0 <-> transparent pen and rewrites
 *     pen 0 pixels to the transparent pen.  The mirrored compare can
 *     never fire for a positive pen (0xffffff00|px vs a small positive
 *     long), so the "swap back" half of the pixel loop is dead code.
 *   - AddFreeList is invoked with its size argument = the just-returned
 *     AllocMem pointer (register was never reloaded) -- sic.
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef short          WORD;
typedef short          SHORT;
typedef char           BYTE;
typedef void          *APTR;
typedef char          *STRPTR;

#ifndef REGPARM_A0
#define REGPARM_A0 __asm("a0")
#define REGPARM_A1 __asm("a1")
#define REGPARM_A2 __asm("a2")
#define REGPARM_A6 __asm("a6")
#define REGPARM_D0 __asm("d0")
#define REGPARM_D1 __asm("d1")
#define REGPARM_D2 __asm("d2")
#define REGPARM_D3 __asm("d3")
#define REGPARM_D4 __asm("d4")
#endif

/* bss globals (newicon_lib.s) */
extern APTR g_icon;			/* icon.library v44 base */
extern APTR g_sys;			/* SysBase copy made by init */

/* icon tag ids (ICONA_Dummy = TAG_USER+0x9000) */
#define ITAG(n)  (0x80009000UL + (n))
#define TAG_DONE_ 0
#define TAG_IGNORE_ 1

/* DiskObject offsets as used by the original (v44 struct) */
#define DO_GAW      12		/* ga_Width   */
#define DO_GAH      14		/* ga_Height  */
#define DO_GAF      16		/* ga_Flags   */
#define DO_GAREND   22		/* ga_GadgetRender (Image*) */
#define DO_TTYPES   54		/* do_ToolTypes (STRPTR*) */
#define DO_FREEL    78		/* v44 freelist pointer   */

#define MEMF_CHIP_  2
#define MEMF_PUB_   1

/* ------------------------------------------------------------------ */
/* library-call wrappers (register-level, matching the original ABI)  */

static APTR e_allocmem(ULONG sz, ULONG fl) {
    register APTR a6 __asm("a6") = g_sys;
    register ULONG s __asm("d0") = sz;
    register ULONG f __asm("d1") = fl;
    register APTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-198:W)" : "=r"(r), "+d"(f)
        : "d"(s), "a"(a6) : "a0","a1","fp0","fp1","cc","memory");
    return r;
}
static void e_freemem(APTR m, ULONG sz) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR mm __asm("a1") = m;
    register ULONG s __asm("d0") = sz;
    __asm volatile ("jsr %/a6@(-210:W)" : "+a"(mm), "+d"(s)
        : "a"(a6) : "d1","a0","fp0","fp1","cc","memory");
}
static void e_remove(APTR n) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR nn __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)" : "+a"(nn)
        : "a"(a6) : "d0","d1","a0","fp0","fp1","cc","memory");
}
static APTR e_findtask(APTR n) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR nn __asm("a1") = n;
    register APTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-294:W)" : "=r"(r), "+a"(nn)
        : "a"(a6) : "d1","a0","fp0","fp1","cc","memory");
    return r;
}
static void e_closelib(APTR l) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR ll __asm("a1") = l;
    __asm volatile ("jsr %/a6@(-414:W)" : "+a"(ll)
        : "a"(a6) : "d0","d1","a0","fp0","fp1","cc","memory");
}
static APTR e_openlib(STRPTR n, LONG v) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR nn __asm("a1") = n;
    register LONG vv __asm("d0") = v;
    register APTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-552:W)" : "=r"(r), "+a"(nn)
        : "d"(vv), "a"(a6) : "d1","a0","fp0","fp1","cc","memory");
    return r;
}
static void e_copymem(APTR s, APTR d, ULONG l) {
    register APTR a6 __asm("a6") = g_sys;
    register APTR ss __asm("a0") = s;
    register APTR dd __asm("a1") = d;
    register ULONG ll __asm("d0") = l;
    __asm volatile ("jsr %/a6@(-624:W)" : "+a"(ss), "+a"(dd), "+d"(ll)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
}

static LONG i_ctrl(APTR o, ULONG *t) {			/* IconControlA */
    register APTR a6 __asm("a6") = g_icon;
    register APTR oo __asm("a0") = o;
    register ULONG *tt __asm("a1") = t;
    register LONG r __asm("d0");
    __asm volatile ("jsr %/a6@(-156:W)" : "=r"(r), "+a"(oo), "+a"(tt)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}
static APTR i_gettags(STRPTR n, ULONG *t) {		/* GetIconTagList */
    register APTR a6 __asm("a6") = g_icon;
    register STRPTR nn __asm("a0") = n;
    register ULONG *tt __asm("a1") = t;
    register APTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-180:W)" : "=r"(r), "+a"(nn), "+a"(tt)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}
static LONG i_puttags(STRPTR n, APTR o, ULONG *t) {	/* PutIconTagList */
    register APTR a6 __asm("a6") = g_icon;
    register STRPTR nn __asm("a0") = n;
    register APTR oo __asm("a1") = o;
    register ULONG *tt __asm("a2") = t;
    register LONG r __asm("d0");
    __asm volatile ("jsr %/a6@(-186:W)" : "=r"(r), "+a"(nn), "+a"(oo), "+a"(tt)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}
static APTR i_dup(APTR o, ULONG *t) {			/* DupDiskObjectA */
    register APTR a6 __asm("a6") = g_icon;
    register APTR oo __asm("a0") = o;
    register ULONG *tt __asm("a1") = t;
    register APTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-150:W)" : "=r"(r), "+a"(oo), "+a"(tt)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}
static APTR i_newdob(LONG t) {				/* NewDiskObject */
    register APTR a6 __asm("a6") = g_icon;
    register LONG r __asm("d0") = t;		/* arg in, result out */
    __asm volatile ("jsr %/a6@(-174:W)" : "+r"(r)
        : "a"(a6) : "d1","a0","a1","fp0","fp1","cc","memory");
    return (APTR)r;
}
static void i_freedob(APTR o) {				/* FreeDiskObject */
    register APTR a6 __asm("a6") = g_icon;
    register APTR oo __asm("a0") = o;
    __asm volatile ("jsr %/a6@(-90:W)" : "+a"(oo)
        : "a"(a6) : "d0","d1","a1","fp0","fp1","cc","memory");
}
static STRPTR i_findtt(APTR tt, STRPTR s) {		/* FindToolType */
    register APTR a6 __asm("a6") = g_icon;
    register APTR t0 __asm("a0") = tt;
    register STRPTR ss __asm("a1") = s;
    register STRPTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-96:W)" : "=r"(r), "+a"(t0), "+a"(ss)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}
static WORD i_addfl(APTR fl, APTR m, ULONG sz, ULONG fl2) { /* AddFreeList */
    register APTR a6 __asm("a6") = g_icon;
    register APTR f0 __asm("a0") = fl;
    register APTR mm __asm("a1") = m;
    register ULONG ss __asm("d0") = sz;
    register ULONG f1 __asm("d1") = fl2;
    __asm volatile ("jsr %/a6@(-72:W)" : "+d"(ss), "+a"(f0), "+a"(mm), "+d"(f1)
        : "a"(a6) : "fp0","fp1","cc","memory");
    return (WORD)ss;
}
static WORD i_layout(APTR o, APTR s, APTR t) {		/* LayoutIconA */
    register APTR a6 __asm("a6") = g_icon;
    register APTR oo __asm("a0") = o;
    register APTR ss __asm("a1") = s;
    register APTR tt __asm("a2") = t;
    register WORD r __asm("d0");
    __asm volatile ("jsr %/a6@(-192:W)" : "=r"(r), "+a"(oo), "+a"(ss), "+a"(tt)
        : "a"(a6) : "d1","fp0","fp1","cc","memory");
    return r;
}

static WORD d_getprog(APTR dos, STRPTR b, ULONG l) {	/* GetProgramName */
    register APTR a6 __asm("a6") = dos;
    register STRPTR bb __asm("d1") = b;
    register ULONG ll __asm("d2") = l;
    register WORD r __asm("d0");
    __asm volatile ("jsr %/a6@(-576:W)" : "=r"(r), "+d"(bb), "+d"(ll)
        : "a"(a6) : "a0","a1","fp0","fp1","cc","memory");
    return r;
}
static STRPTR d_filepart(APTR dos, STRPTR s) {		/* FilePart */
    register APTR a6 __asm("a6") = dos;
    register STRPTR ss __asm("d1") = s;
    register STRPTR r __asm("d0");
    __asm volatile ("jsr %/a6@(-870:W)" : "=r"(r), "+d"(ss)
        : "a"(a6) : "a0","a1","fp0","fp1","cc","memory");
    return r;
}

/* ------------------------------------------------------------------ */
/* helpers                                                             */

/* case-insensitive compare: lowercases the LEFT string only.
 * Returns 0 ("equal") when the left string is exhausted -- i.e. any
 * left string that is a prefix of the right one counts as a match. */
static LONG stri(STRPTR a, STRPTR b) {
    BYTE c;
    for (;;) {
        c = *a++;
        if (!c) break;
        c |= 0x20;
        c -= *b++;
        if (c) break;
    }
    return (LONG)c;
}

/* AllocMem + track it on the icon's freelist (0x222).
 * Quirk: AddFreeList's size arg is the returned mem pointer (d0 was
 * never reloaded after AllocMem). */
static APTR alloctrack(APTR fl, ULONG size, ULONG flags) {
    APTR mem = e_allocmem(size, flags);
    if (!mem) return 0;
    if (!i_addfl(fl, mem, (ULONG)mem, flags)) {	/* sic: size=mem */
        e_freemem(mem, size);
        return 0;
    }
    return mem;
}

/* swap palette entry 0 <-> transparent pen and rewrite pen-0 pixels
 * (0x262).  Dead branch note: the "px==transp -> 0" compare can only
 * match negative transp values, which the ble gate already rejects. */
static void remap(UBYTE *data, UBYTE *pal, LONG w, LONG h, LONG t) {
    LONG  t3;
    WORD  np, i;
    UBYTE *p;
    if (t <= 0) return;
    t3 = t * 3;
    np = (WORD)((SHORT)h * (SHORT)w);
    p = pal + 2;
    for (i = 2; i >= 0; i--) {
        UBYTE b = p[0];
        p[0] = p[t3]; p[t3] = b;
        p--;
    }
    i = np - 1;
    if (i == -1) return;
    do {
        UBYTE px = *data;
        if (!px) *data = (UBYTE)t;
        else if ((LONG)(0xffffff00UL | px) == t) *data = 0;
        data++;
    } while (i-- != 0);
}

/* ------------------------------------------------------------------ */
/* structures                                                          */

struct NI {			/* 12-byte handle returned by xget */
    APTR ni_dob;		/* +0 DiskObject */
    APTR ni_i1;			/* +4 image record 1 */
    APTR ni_i2;			/* +8 image record 2 (16B past i1)     */
};

struct NI_Img {			/* 16-byte image record */
    UWORD im_w, im_h;		/* +0,+2 */
    UWORD im_psz;		/* +4  palette size  */
    UWORD im_flag;		/* +6  bit0 transp, bit1 drop-chunky */
    APTR  im_pal;		/* +8  */
    APTR  im_data;		/* +12 */
};

/* ------------------------------------------------------------------ */
/* core fetch routine (0x2c8)                                          */

static APTR xget(STRPTR name, APTR lib, ULONG dtype, LONG mode) {
    ULONG tq[6];
    ULONG mapped = 0;
    struct NI *h;
    UBYTE *dob;

    tq[0] = ITAG(50); tq[1] = 0;			/* RemapIcon = FALSE */
    /* name == NULL -> GetDefaultType=dtype; else TAG_IGNORE (sic) */
    tq[2] = name ? TAG_IGNORE_ : ITAG(45);
    tq[3] = dtype & 0xffff;
    tq[4] = TAG_DONE_; tq[5] = 0;

    dob = (UBYTE*)i_gettags(name, tq);
    if (!dob) return 0;

    h = (struct NI*)alloctrack(dob + DO_FREEL, 12, MEMF_PUB_);
    if (!h) {
        i_freedob(dob);
        return 0;
    }
    h->ni_dob = dob;
    h->ni_i1 = 0;
    h->ni_i2 = 0;

    {
        ULONG q[4] = { ITAG(42), (ULONG)&mapped, TAG_DONE_, 0 };
        i_ctrl(dob, q);				/* IsPaletteMapped */
    }

    if (!*(APTR*)(dob + DO_GAREND)) {
        /* no gadget render: install a 1x1x1 solid Image */
        UBYTE *im = (UBYTE*)alloctrack(dob + DO_FREEL, 22, MEMF_CHIP_);
        UWORD *iw;
        if (!im) {
            if (h) i_freedob(*(APTR*)h);	/* FreeDiskObject(*h) */
            return 0;
        }
        iw = (UWORD*)im;
        iw[0] = 0; iw[1] = 0;			/* Left/Top */
        iw[2] = 1; iw[3] = 1; iw[4] = 1;		/* W/H/Depth */
        *(APTR*)(im + 10) = im + 20;		/* ImageData -> data word */
        im[14] = 1;				/* PlanePick  */
        im[15] = 0;				/* PlaneOnOff */
        *(APTR*)(im + 16) = 0;			/* NextImage  */
        iw[10] = 0xffff;			/* the 1-pixel data  */
        *(APTR*)(dob + DO_GAREND) = im;
        *(UWORD*)(dob + DO_GAF) &= ~3;		/* ga_Flags: solid fill */
    }

    if (!mapped) {
        /* not a palette-mapped icon: follow the DEFAULTIMAGE tooltype */
        STRPTR tt = i_findtt(*(APTR*)(dob + DO_TTYPES), "DEFAULTIMAGE");
        if (!tt) return h;
        if (h) i_freedob(*(APTR*)h);		/* drop this diskobject */
        return xget(tt, lib, 0, 2);
    }

    /* extract both images from the mapped icon */
    {
        ULONG v48, v44, v40, v36, v32, v28, v24, v20, v16, v12, v8;
        ULONG qq[23];
        struct NI_Img *pr;

        qq[0]  = ITAG(17); qq[1]  = (ULONG)&v48;	/* GetTranspColor1 */
        qq[2]  = ITAG(21); qq[3]  = (ULONG)&v44;	/* GetPalette1     */
        qq[4]  = ITAG(25); qq[5]  = (ULONG)&v40;	/* GetPaletteSize1 */
        qq[6]  = ITAG(29); qq[7]  = (ULONG)&v36;	/* GetImageData1   */
        qq[8]  = ITAG(39); qq[9]  = (ULONG)&v32;	/* GetWidth        */
        qq[10] = ITAG(41); qq[11] = (ULONG)&v28;	/* GetHeight       */
        qq[12] = ITAG(19); qq[13] = (ULONG)&v24;	/* GetTranspColor2 */
        qq[14] = ITAG(23); qq[15] = (ULONG)&v20;	/* GetPalette2     */
        qq[16] = ITAG(27); qq[17] = (ULONG)&v16;	/* GetPaletteSize2 */
        qq[18] = ITAG(31); qq[19] = (ULONG)&v12;	/* GetImageData2   */
        qq[20] = ITAG(1);  qq[21] = (ULONG)&v8;	/* ErrorCode       */
        qq[22] = TAG_DONE_; qq[23] = 0;

        i_ctrl(dob, qq);

        if (v8)   return h;			/* error -> partial handle */
        if (!v36) return h;
        if (!v44) return h;

        pr = (struct NI_Img*)alloctrack(dob + DO_FREEL, 32, MEMF_PUB_);
        if (!pr) return h;

        pr->im_w    = (UWORD)v32;
        pr->im_h    = (UWORD)v28;
        pr->im_psz  = (UWORD)v40;
        pr->im_flag = (v48 != -1) ? 1 : (mode != 0);
        pr->im_pal  = (APTR)v44;
        pr->im_data = (APTR)v36;
        h->ni_i1 = pr;
        remap((APTR)v36, (APTR)v44, (UWORD)v32, (UWORD)v28, v48);

        if (!v12 || !v20) return h;

        pr++;
        pr->im_w    = (UWORD)v32;
        pr->im_h    = (UWORD)v28;
        pr->im_psz  = (UWORD)v16;
        pr->im_flag = (v24 != -1) ? 1 : (mode != 0);
        pr->im_pal  = (APTR)v20;
        pr->im_data = (APTR)v12;
        h->ni_i2 = pr;
        remap((APTR)v12, (APTR)v20, (UWORD)v32, (UWORD)v28, v24);
    }
    return h;
}

/* ------------------------------------------------------------------ */
/* vector entry points                                                 */

/* -30/-78 entry: a0=name, a1=lib, d0=dtype, d1=mode (set by asm stubs) */
APTR ni_xgeticon(STRPTR name REGPARM_A0, APTR lib REGPARM_A1,
                 ULONG dtype REGPARM_D0, LONG mode REGPARM_D1) {
    return xget(name, lib, dtype, mode);
}

/* -36: write a handle's images back into a (possibly duped) diskobject */
WORD ni_puticon(STRPTR name REGPARM_A0, struct NI *h REGPARM_A1) {
    STRPTR nm = name;
    APTR   d2;
    WORD   d5 = 0;
    WORD   d3 = 1;
    LONG   nat = 0;
    struct NI_Img *r;

    d2 = h->ni_dob;

    {
        ULONG q[4] = { ITAG(80), (ULONG)&nat, TAG_DONE_, 0 };
        i_ctrl(d2, q);				/* IsNativeIcon */
    }
    if (!nat) {
        d2 = i_dup(d2, (APTR)0);		/* DupDiskObjectA(dob, NULL) */
        if (!d2) return 0;
    }

    r = (struct NI_Img*)h->ni_i1;
    if (r && (r->im_flag & 2)) {
        d5 = 1;					/* skip image uploads */
    } else if (r) {
        ULONG qq[16];
        qq[0]  = ITAG(38); qq[1]  = r->im_w;			/* SetWidth        */
        qq[2]  = ITAG(40); qq[3]  = r->im_h;			/* SetHeight       */
        qq[4]  = ITAG(36); qq[5]  = 0x11;			/* SetAspectRatio  */
        qq[6]  = ITAG(28); qq[7]  = (ULONG)r->im_data;		/* SetImageData1   */
        qq[8]  = ITAG(20); qq[9]  = (ULONG)r->im_pal;		/* SetPalette1     */
        qq[10] = ITAG(24); qq[11] = r->im_psz;			/* SetPaletteSize1 */
        qq[12] = ITAG(16); qq[13] = (r->im_flag & 1) ? 0 : -1L;	/* SetTranspColor1 */
        qq[14] = TAG_DONE_; qq[15] = 0;
        if (i_ctrl(d2, qq) != 7) {
            d3 = 0;
        } else {
            r = (struct NI_Img*)h->ni_i2;
            if (r) {
                ULONG q2[10];
                q2[0] = ITAG(30); q2[1] = (ULONG)r->im_data;	/* SetImageData2   */
                q2[2] = ITAG(22); q2[3] = (ULONG)r->im_pal;	/* SetPalette2     */
                q2[4] = ITAG(26); q2[5] = r->im_psz;		/* SetPaletteSize2 */
                q2[6] = ITAG(18); q2[7] = (r->im_flag & 1) ? 0 : -1L;
                q2[8] = TAG_DONE_; q2[9] = 0;
                if (i_ctrl(d2, q2) != 4) d3 = 0;
            }
        }
    }

    if (d3) {
        ULONG pq[8];
        pq[0] = ITAG(57); pq[1] = d5 & 1;	/* DropChunkyIconImage    */
        pq[2] = ITAG(58); pq[3] = 1;		/* DropNewIconToolTypes   */
        pq[4] = ITAG(53); pq[5] = 1;		/* NotifyWorkbench        */
        pq[6] = TAG_DONE_; pq[7] = 0;
        d3 = (WORD)i_puttags(nm, d2, pq);
    }

    if (!nat) i_freedob(d2);			/* drop the temporary dup */
    return d3;
}

/* -66: build a default icon from a caller-supplied image record;
 * returns a 24-byte block { 20-byte Image copy, DiskObject* } or 0. */
APTR ni_mkdef(struct NI_Img *rec REGPARM_A0, APTR scr REGPARM_A1) {
    UBYTE  *dob, *h;
    LONG   err = 0;
    ULONG  qq[18];

    dob = (UBYTE*)i_newdob(3);				/* NewDiskObject(3) */
    if (!dob) return 0;

    h = (UBYTE*)alloctrack(dob + DO_FREEL, 24, MEMF_PUB_);
    if (!h) {
        i_freedob(dob);
        return 0;
    }

    qq[0]  = ITAG(38); qq[1]  = rec->im_w;
    qq[2]  = ITAG(40); qq[3]  = rec->im_h;
    qq[4]  = ITAG(36); qq[5]  = 0x11;
    qq[6]  = ITAG(28); qq[7]  = (ULONG)rec->im_data;
    qq[8]  = ITAG(24); qq[9]  = rec->im_psz;
    qq[10] = ITAG(20); qq[11] = (ULONG)rec->im_pal;
    qq[12] = ITAG(16); qq[13] = (rec->im_flag & 1) ? 0 : -1L;
    qq[14] = ITAG(1);  qq[15] = (ULONG)&err;		/* ErrorCode -> &err */
    qq[16] = TAG_DONE_; qq[17] = 0;
    i_ctrl(dob, qq);
    if (err) {
        i_freedob(dob);
        return 0;
    }

    *(UWORD*)(dob + DO_GAW) = rec->im_w;
    *(UWORD*)(dob + DO_GAH) = rec->im_h;

    if (!i_layout(dob, scr, 0)) {
        i_freedob(dob);
        return 0;
    }

    e_copymem(*(APTR*)(dob + DO_GAREND), h, 20);
    *(APTR*)(h + 20) = dob;
    return h;
}

/* ------------------------------------------------------------------ */
/* library lifecycle                                                   */

static WORD openicon(void) {				/* 0x198 */
    g_icon = e_openlib("icon.library", 44);
    return g_icon ? 1 : 0;
}

static void closeicon(void) {				/* 0x1ba */
    e_closelib(g_icon);
}

APTR ni_init(APTR lib REGPARM_D0, APTR seg REGPARM_A0, APTR sys REGPARM_A6) {
    UBYTE *l = (UBYTE*)lib;
    ULONG ns, ps;

    g_sys = sys;
    *(APTR*)(l + 34) = seg;				/* seglist */
    *(UWORD*)(l + 22) = 0;				/* revision */

    if (*(UBYTE*)((UBYTE*)sys + 297) & 2) {		/* AFF_68020 */
        if (openicon()) {
            return lib;
        }
        closeicon();
    }
    ns = *(UWORD*)(l + 16);
    ps = *(UWORD*)(l + 18);
    e_freemem(l - ns, ns + ps);
    return 0;
}

APTR ni_open(APTR lib REGPARM_A6) {
    UBYTE  *l = (UBYTE*)lib;
    char    buf[80];
    STRPTR  s, name;
    APTR    dos, task;

    dos = e_openlib("dos.library", 40);
    if (!dos) return 0;

    if (d_getprog(dos, buf, 80)) {
        s = buf;
    } else {
        task = e_findtask(0);
        s = *(STRPTR*)((UBYTE*)task + 10);	/* task->ln_Name */
    }
    name = d_filepart(dos, s);

    if (stri(name, "newicons") == 0) {
        e_closelib(dos);
        return 0;
    }
    ((UBYTE*)l)[14] &= ~8;				/* clear LIBF_DELEXP */
    *(UWORD*)(l + 32) += 1;				/* lib_OpenCnt++    */
    e_closelib(dos);
    return lib;
}

static APTR do_expunge(UBYTE *l) {
    ULONG ns, ps;
    APTR  seg;

    if (*(UWORD*)(l + 32)) {
        l[14] |= 8;					/* LIBF_DELEXP */
        return 0;
    }
    closeicon();
    e_remove(l);
    seg = *(APTR*)(l + 34);
    ns = *(UWORD*)(l + 16);
    ps = *(UWORD*)(l + 18);
    e_freemem(l - ns, ns + ps);
    return seg;
}

APTR ni_close(APTR lib REGPARM_A6) {
    UBYTE *l = (UBYTE*)lib;
    UWORD  cnt = *(UWORD*)(l + 32);
    if (cnt) {
        *(UWORD*)(l + 32) = cnt - 1;
        if (cnt != 1) return 0;
    }
    if (l[14] & 8)
        return do_expunge(l);
    return 0;
}

APTR ni_expunge(APTR lib REGPARM_A6) {
    return do_expunge((UBYTE*)lib);
}
