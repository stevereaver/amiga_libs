/*
**	fastlayers.c -- fastlayers.library 40.48 (A. Kneer / T. Abt)
**
**	C reconstruction of the shipped 3-hunk binary (16.03.98).
**	"FastLayers" is a layers.library accelerator: at library
**	init it copies the layers resident module out of ROM into
**	an AllocVec'd RAM block, rewrites the module's internal
**	`jmp pc@(d16)' tail-calls to SwapBitsRastPortClipRect
**	(layers LVO -126) into `jsr a6@(-126)' vector calls so the
**	copy stays self-consistent, re-points every layers vector
**	that still targets the ROM at the relocated copy, and
**	finally installs five hand-written replacement routines:
**
**	  -186 CreateUpfrontHookLayer  SIMPLE/SMART non-backdrop
**		layers take a cheap create path (forced
**		LAYERSIMPLE create via CreateBehindHookLayer +
**		UpfrontLayer, refresh flags cleared, BackFill=1)
**	  -36  CreateUpfrontLayer	 wrapper -> new CUHL, hook=0
**	  -60  MoveLayer		 wrapper -> new MoveSizeLayer
**	  -180 MoveSizeLayer		 SMART layers that are not
**		occluded and overlap no front layer are briefly
**		remapped to LAYERSIMPLE so the real routine uses
**		the fast blit path
**	  -66  SizeLayer		 wrapper -> new MoveSizeLayer
**
**	Expunge is a no-op stub: once installed the patches are
**	permanent until reboot.
**
**	Shipped behaviour kept:
**	  - private DELEXP-style flag byte at base+34 (never set)
**	  - functab walk skips table word 0 and starts the vector
**	    scan at LVO -6 (see okf/findings)
**	  - datatab writes ln_Pri = 0xb0 (-80)
**	  - dead DoHookClipRects block (sentinel a3 always == 1)
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/memory.h>

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

struct FLBase			/* dataSize = 0x3c		   */
{
    struct Library fl_Lib;	/* 0x00 standard library node	   */
    volatile UBYTE fl_Flag;	/* 0x22 private DELEXP flag byte   */
    UBYTE  fl_Pad;		/* 0x23				   */
    struct ExecBase *fl_Sys;	/* 0x24				   */
    struct Library *fl_Gfx;	/* 0x28 graphics.library	   */
    struct Library *fl_Uty;	/* 0x2c utility.library		   */
    struct Library *fl_Lay;	/* 0x30 layers.library		   */
    APTR   fl_Seg;		/* 0x34 seglist			   */
    APTR   fl_Copy;		/* 0x38 relocated layers module    */
};

/* packed Resident used by the original (26 bytes: MatchTag @2,
 * EndSkip @6, Init @22)					     */
struct PackedResident
{
    UWORD  pr_MatchWord;	/* 0x00		*/
    APTR   pr_MatchTag;	/* 0x02		*/
    APTR   pr_EndSkip;	/* 0x06		*/
    UBYTE  pr_Flags;	/* 0x0a		*/
    UBYTE  pr_Version;	/* 0x0b		*/
    UBYTE  pr_Type;		/* 0x0c		*/
    BYTE   pr_Pri;		/* 0x0d		*/
    APTR   pr_Name;		/* 0x0e		*/
    APTR   pr_IdString;	/* 0x12		*/
    APTR   pr_Init;		/* 0x16		*/
};				/* 0x1a = 26	*/

/* minimum fields of struct Layer used by the patched code
 * (offsets match <graphics/clip.h>)			     */
struct FLLayer
{
    struct FLLayer *front;	/* 0x00		*/
    struct FLLayer *back;	/* 0x04		*/
    struct FLClipRect *ClipRect;/* 0x08		*/
    APTR   rp;			/* 0x0c		*/
    WORD   bx0, by0, bx1, by1;	/* 0x10 bounds	*/
    APTR   nlink;		/* 0x18		*/
    UWORD  priority;		/* 0x1c		*/
    UWORD  Flags;		/* 0x1e		*/
    ULONG  pad20[9];		/* 0x20..0x43	*/
    APTR   LayerInfo;		/* 0x44		*/
    ULONG  pad48[11];		/* 0x48..0x73	*/
    UWORD  pad74;		/* 0x74		*/
    APTR   BackFill;		/* 0x76		*/
    ULONG  pad7a[8];		/* 0x7a..0x99	*/
    UWORD  pad9a;		/* 0x9a		*/
    APTR   DamageList;		/* 0x9c		*/
};

struct FLClipRect		/* <graphics/clip.h> ClipRect	   */
{
    struct FLClipRect *next;	/* 0x00		*/
    APTR   prev;		/* 0x04		*/
    struct FLLayer *lobs;	/* 0x08		*/
};

struct FLLayerInfo		/* only top_layer is used	   */
{
    struct FLLayer *top_layer;	/* 0x00		*/
};

struct PatchEntry		/* mirrors hunk0+0x22a		   */
{
    LONG   lvo;			/* SetFunction offset		   */
    APTR   newfunc;		/* replacement routine	   */
    APTR   saved;		/* original routine (runtime)   */
};

extern APTR flbase;		/* _flbase in fastlayers_lib.s  */
extern struct PatchEntry patchtab[];	/* _patchtab		    */
extern char gfxname[], utyname[], layname[];

/* ------------------------------------------------------------------ */
/* exec LVO calls							  */
/* ------------------------------------------------------------------ */

#define SYSBASE ((struct ExecBase *)4)

#define OL(sys,name,ver) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register const char * __p_name __asm("a1") = (name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(ver);\
  register struct Library * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=r"(__p_res), "+a"(__p_name)\
    : "a"(__p_sys), "d"(__p_ver)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})

#define FINDRESIDENT(sys,name) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register const char * __p_name __asm("a1") = (name);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-96:W)\n"\
    : "=r"(__p_res), "+a"(__p_name)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})

#define ALLOCVEC(sys,size,fl) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-684:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

#define COPYMEM(sys,src,dst,n) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_src __asm("a0") = (APTR)(src);\
  register APTR __p_dst __asm("a1") = (APTR)(dst);\
  register ULONG __p_n __asm("d0") = (ULONG)(n);\
  __asm volatile ("jsr %/a6@(-624:W)\n"\
    : "+a"(__p_src), "+a"(__p_dst), "+d"(__p_n)\
    : "a"(__p_sys)\
    : "d1","fp0","fp1","cc","memory");})

#define SETFUNC(sys,lib,off,fn) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_lib __asm("a1") = (APTR)(lib);\
  register APTR __p_off __asm("a0") = (APTR)(off);\
  register APTR __p_fn __asm("d0") = (APTR)(fn);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-420:W)\n"\
    : "=r"(__p_res), "+a"(__p_lib), "+a"(__p_off)\
    : "a"(__p_sys), "d"(__p_fn)\
    : "d1","fp0","fp1","cc","memory");\
  __p_res;})

#define FORBID(sys) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  __asm volatile ("jsr %/a6@(-132:W)\n" :: "a"(__p_sys) : "d0","d1","a0","a1","cc","memory");})

#define PERMIT(sys) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  __asm volatile ("jsr %/a6@(-138:W)\n" :: "a"(__p_sys) : "d0","d1","a0","a1","cc","memory");})

#define CACHECLEAR(sys) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  __asm volatile ("jsr %/a6@(-636:W)\n" :: "a"(__p_sys) : "d0","d1","a0","a1","cc","memory");})

/* ------------------------------------------------------------------ */
/* layers LVO calls (a6 = layers.library base)			  */
/* ------------------------------------------------------------------ */

#define L_LockLayerInfo(lay,li) ({\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_li __asm("a0") = (APTR)(li);\
  __asm volatile ("jsr %/a6@(-120:W)\n" : "+a"(__p_li) : "a"(__p_lay) : "d0","d1","a1","cc","memory");})

#define L_UnlockLayerInfo(lay,li) ({\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_li __asm("a0") = (APTR)(li);\
  __asm volatile ("jsr %/a6@(-138:W)\n" : "+a"(__p_li) : "a"(__p_lay) : "d0","d1","a1","cc","memory");})

#define L_UpfrontLayer(lay,dum,l) ({\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_dum __asm("a0") = (APTR)(dum);\
  register APTR __p_l __asm("a1") = (APTR)(l);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-48:W)\n"\
    : "=r"(__p_res), "+a"(__p_dum), "+a"(__p_l)\
    : "a"(__p_lay) : "d1","cc","memory");\
  __p_res;})

/* CreateBehindHookLayer(li a0, bm a1, x0-y1 d0-d3, flags d4,
 * hook a3, bm2 a2)						     */
#define L_CBHL(lay,li,bm,x0,y0,x1,y1,fl,hook,bm2) ({\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_li __asm("a0") = (APTR)(li);\
  register APTR __p_bm __asm("a1") = (APTR)(bm);\
  register LONG __p_x0 __asm("d0") = (LONG)(x0);\
  register LONG __p_y0 __asm("d1") = (LONG)(y0);\
  register LONG __p_x1 __asm("d2") = (LONG)(x1);\
  register LONG __p_y1 __asm("d3") = (LONG)(y1);\
  register LONG __p_fl __asm("d4") = (LONG)(fl);\
  register APTR __p_hook __asm("a3") = (APTR)(hook);\
  register APTR __p_bm2 __asm("a2") = (APTR)(bm2);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-192:W)\n"\
    : "=r"(__p_res), "+a"(__p_li), "+a"(__p_bm), "+a"(__p_hook), "+a"(__p_bm2), "+d"(__p_y0), "+d"(__p_x1), "+d"(__p_y1), "+d"(__p_fl)\
    : "a"(__p_lay), "d"(__p_x0)\
    : "fp0","fp1","cc","memory");\
  __p_res;})

#define L_DoHookClipRects(lay,hook,rp,rect) ({\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_hook __asm("a0") = (APTR)(hook);\
  register APTR __p_rp __asm("a1") = (APTR)(rp);\
  register APTR __p_rect __asm("a2") = (APTR)(rect);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-216:W)\n"\
    : "=r"(__p_res), "+a"(__p_hook), "+a"(__p_rp), "+a"(__p_rect)\
    : "a"(__p_lay) : "d1","cc","memory");\
  __p_res;})

/* graphics ClearRegion(region a0), a6 = gfx base		     */
#define G_ClearRegion(gfx,reg) ({\
  register APTR __p_gfx __asm("a6") = (APTR)(gfx);\
  register APTR __p_reg __asm("a0") = (APTR)(reg);\
  __asm volatile ("jsr %/a6@(-528:W)\n" : "+a"(__p_reg) : "a"(__p_gfx) : "d0","d1","a1","cc","memory");})

/* ------------------------------------------------------------------ */
/* indirect calls: jsr a1@ with a6 = layers base and bound args	  */
/* ------------------------------------------------------------------ */

/* call CreateUpfrontHookLayer-shaped routine at fn; like the
 * original the function pointer rides in a5		     */
#define CALL_CUHL(fn,lay,li,bm,x0,y0,x1,y1,fl,hook,bm2) ({\
  register APTR __p_fn __asm("a5") = (APTR)(fn);\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_li __asm("a0") = (APTR)(li);\
  register APTR __p_bm __asm("a1") = (APTR)(bm);\
  register LONG __p_x0 __asm("d0") = (LONG)(x0);\
  register LONG __p_y0 __asm("d1") = (LONG)(y0);\
  register LONG __p_x1 __asm("d2") = (LONG)(x1);\
  register LONG __p_y1 __asm("d3") = (LONG)(y1);\
  register LONG __p_fl __asm("d4") = (LONG)(fl);\
  register APTR __p_hook __asm("a3") = (APTR)(hook);\
  register APTR __p_bm2 __asm("a2") = (APTR)(bm2);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %%a5@\n"\
    : "=r"(__p_res), "+a"(__p_li), "+a"(__p_bm), "+a"(__p_fn), "+a"(__p_hook), "+a"(__p_bm2), "+d"(__p_y0), "+d"(__p_x1), "+d"(__p_y1), "+d"(__p_fl)\
    : "a"(__p_lay), "d"(__p_x0)\
    : "fp0","fp1","cc","memory");\
  __p_res;})

/* call MoveSizeLayer-shaped routine at fn			     */
#define CALL_MSL(fn,lay,l,dx,dy,dw,dh) ({\
  register APTR __p_fn __asm("a1") = (APTR)(fn);\
  register APTR __p_lay __asm("a6") = (APTR)(lay);\
  register APTR __p_l __asm("a0") = (APTR)(l);\
  register LONG __p_dx __asm("d0") = (LONG)(dx);\
  register LONG __p_dy __asm("d1") = (LONG)(dy);\
  register LONG __p_dw __asm("d2") = (LONG)(dw);\
  register LONG __p_dh __asm("d3") = (LONG)(dh);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %%a1@\n"\
    : "=r"(__p_res), "+a"(__p_l), "+a"(__p_fn), "+d"(__p_dy), "+d"(__p_dw), "+d"(__p_dh)\
    : "a"(__p_lay), "d"(__p_dx)\
    : "fp0","fp1","cc","memory");\
  __p_res;})

/* ------------------------------------------------------------------ */
/* overlap test -- the original lives in hunk2, called as	      */
/* RectOverlap(a0, a1) with register args; returns 1 if the	      */
/* rectangles are not disjoint.				      */
/* ------------------------------------------------------------------ */
struct FLRect { WORD x0, y0, x1, y1; };

static WORD RectOverlap(struct FLRect *a __asm("a0"), struct FLRect *b __asm("a1"))
{
    if (a->x1 < b->x0) return 0;
    if (a->x0 > b->x1) return 0;
    if (a->y1 < b->y0) return 0;
    if (a->y0 > b->y1) return 0;
    return 1;
}

/* ------------------------------------------------------------------ */
/* library vectors							  */
/* ------------------------------------------------------------------ */

LONG LibExpunge(struct FLBase *b __asm("a6"));

struct Library *LibOpen(struct FLBase *b __asm("a6"))
{
    b->fl_Lib.lib_OpenCnt++;
    b->fl_Flag &= ~8;		/* clear private delayed-expunge  */
    return (struct Library *)b;
}

LONG LibClose(struct FLBase *b __asm("a6"))
{
    /* the original does btst #3,flag34; beq out; bsr Expunge --
     * keep the (dead) call so the flag test survives	      */
    if (--b->fl_Lib.lib_OpenCnt == 0 && (b->fl_Flag & 8))
	__asm volatile ("bsr _LibExpunge\n"
	    ::: "d0","d1","a0","a1","cc","memory");
    return 0;
}

LONG LibExpunge(struct FLBase *b __asm("a6"))
{
    return 0;			/* never expunge		   */
}

/* ------------------------------------------------------------------ */
/* LibInit -- the whole point of the library			  */
/*	called with d0 = new library base, a0 = seglist, a6 = SysBase */
/* ------------------------------------------------------------------ */

APTR LibInit(struct FLBase *b __asm("d0"), APTR seg __asm("a0"),
	     struct ExecBase *sys __asm("a6"))
{
    struct PackedResident *res;
    APTR   lay, copy, orig126;
    ULONG  size;
    LONG   delta;
    UBYTE *p, *end;

    flbase = b;
    b->fl_Sys = sys;
    b->fl_Seg = seg;

    /* the original opens layers first, then graphics, utility --
     * order of the string lea's in the binary		      */
    lay = (APTR)OL(sys, layname, 39);
    b->fl_Lay = (struct Library *)lay;
    if (!lay) return 0;
    b->fl_Gfx = OL(sys, gfxname, 39);
    if (!b->fl_Gfx) return 0;
    b->fl_Uty = OL(sys, utyname, 39);
    if (!b->fl_Uty) return 0;

    /* layers' LVO -126 (SwapBitsRastPortClipRect) target: the
     * address field of the jmp in the vector slot at base-126   */
    orig126 = *(APTR *)((UBYTE *)lay - 124);

    res = (struct PackedResident *)FINDRESIDENT(sys,
	((struct Library *)lay)->lib_Node.ln_Name);
    if (!res) return 0;

    size = (ULONG)((UBYTE *)res->pr_EndSkip - (UBYTE *)res);
    copy = ALLOCVEC(sys, size, 0);
    b->fl_Copy = copy;
    if (!copy) return 0;

    COPYMEM(sys, res, copy, size);
    delta = (LONG)((UBYTE *)copy - (UBYTE *)res);

    FORBID(sys);

    /* scan the resident for `jmp pc@(d16)' (0x4eba) tail-calls
     * that land on the SwapBitsRastPortClipRect routine; in the
     * RAM copy rewrite them as `jsr a6@(-126)' (0x4eae 0xff82)  */
    p   = (UBYTE *)res + 26;
    end = (UBYTE *)res + size;
    while (p < end) {
	if (*(UWORD *)p == 0x4eba) {
	    if ((UBYTE *)(p + 2) + (SHORT)*(UWORD *)(p + 2) == (UBYTE *)orig126) {
		UWORD *w = (UWORD *)(p + delta);
		*w++ = 0x4eae;
		*w   = 0xff82;
	    }
	    p += 4;
	} else {
	    p += 2;
	}
    }

    /* walk layers' own function table (word offsets) -- skip the
     * first word, then for each remaining entry check the real
     * vector at LVO -(6k) and, if it still points at the ROM
     * original, re-point it into the copy			      */
    {
	APTR   init = res->pr_Init;
	APTR   ftab = *(APTR *)((UBYTE *)init + 4);
	WORD  *w    = (WORD *)ftab + 1;
	LONG   d2;

	for (d2 = -6; ; d2 -= 6) {
	    WORD off = *w++;
	    UBYTE *func;
	    if (off == -1) break;
	    func = (UBYTE *)ftab + (UWORD)off;
	    if (*(ULONG *)((UBYTE *)lay + 2 + d2) == (ULONG)func)
		SETFUNC(sys, lay, (APTR)d2, func + delta);
	}
    }

    /* install the five custom patches, saving the originals    */
    {
	struct PatchEntry *e;
	for (e = patchtab; e->lvo != -1; e++)
	    e->saved = SETFUNC(sys, lay, (APTR)e->lvo, e->newfunc);
    }

    CACHECLEAR(sys);
    PERMIT(sys);

    return b;
}

/* ------------------------------------------------------------------ */
/* patched layers routines -- all run with a6 = layers base	  */
/* ------------------------------------------------------------------ */

/* -186: new CreateUpfrontHookLayer(li a0, bm a1, x0-y1 d0-d3,
 * flags d4, hook a3, bm2 a2)				     */
struct FLLayer *NewCreateUpfrontHookLayer(
    APTR  li    __asm("a0"),
    APTR  bm    __asm("a1"),
    LONG  x0    __asm("d0"),
    LONG  y0    __asm("d1"),
    LONG  x1    __asm("d2"),
    LONG  y1    __asm("d3"),
    ULONG flags __asm("d4"),
    APTR  hook  __asm("a3"),
    APTR  bm2   __asm("a2"),
    struct Library *lay __asm("a6"))
{
    if (flags & 0x44)	/* LAYERSUPER|LAYERBACKDROP -> original */
	return (struct FLLayer *)CALL_CUHL(patchtab[0].saved, lay,
	    li, bm, x0, y0, x1, y1, flags, hook, bm2);

    /* fast path for simple/smart layers */
    L_LockLayerInfo(lay, li);
    {
	struct FLLayer *l;
	ULONG  fl2 = (flags & ~3) | 1;	/* force LAYERSIMPLE	   */
	APTR   sentinel = (APTR)1;	/* a3 = 1 -> hook arg	   */

	l = (struct FLLayer *)L_CBHL(lay, li, bm, x0, y0, x1, y1,
				     fl2, sentinel, bm2);
	if (!l) {
	    L_UnlockLayerInfo(lay, li);
	    return 0;
	}
	L_UpfrontLayer(lay, 0, l);

	/* restore the caller's refresh-type bits, mark the
	 * BackFill hook with the (Hook*)1 sentinel, and clear
	 * the damage region					      */
	l->Flags = (l->Flags & ~3) | (flags & 3);
	l->BackFill = sentinel;
	G_ClearRegion(((struct FLBase *)flbase)->fl_Gfx, l->DamageList);
	l->Flags &= ~0x680;	/* REFRESH|IREFRESH|IREFRESH2, SIMPLE kept */

	if (sentinel != (APTR)1)	/* dead code in the binary */
	    L_DoHookClipRects(lay, sentinel, l->rp, bm2);

	L_UnlockLayerInfo(lay, li);
	return l;
    }
}

/* -36: new CreateUpfrontLayer(li a0, bm a1, x0-y1 d0-d3,
 * flags d4, bm2 a2) -- tail-call to the new CUHL with hook=0   */
struct FLLayer *NewCreateUpfrontLayer(
    APTR  li    __asm("a0"),
    APTR  bm    __asm("a1"),
    LONG  x0    __asm("d0"),
    LONG  y0    __asm("d1"),
    LONG  x1    __asm("d2"),
    LONG  y1    __asm("d3"),
    ULONG flags __asm("d4"),
    APTR  bm2   __asm("a2"),
    struct Library *lay __asm("a6"))
{
    return (struct FLLayer *)CALL_CUHL(NewCreateUpfrontHookLayer, lay,
	li, bm, x0, y0, x1, y1, flags, (APTR)0, bm2);
}

/* -180: new MoveSizeLayer(l a0, dx d0, dy d1, dw d2, dh d3)    */
LONG NewMoveSizeLayer(
    struct FLLayer *l __asm("a0"),
    LONG dx __asm("d0"), LONG dy __asm("d1"),
    LONG dw __asm("d2"), LONG dh __asm("d3"),
    struct Library *lay __asm("a6"))
{
    WORD flag;
    struct FLRect nb;
    struct FLLayerInfo *li;
    LONG ret;

    if ((l->Flags & 7) != 2)	/* not LAYERSMART -> original   */
	return (LONG)CALL_MSL(patchtab[3].saved, lay, l, dx, dy, dw, dh);

    if (!dx && !dy && !dw && !dh)
	return 1;		/* mid-instruction `moveq #1,d4' */

    nb.x0 = (WORD)(l->bx0 + dx);
    nb.y0 = (WORD)(l->by0 + dy);
    nb.x1 = (WORD)(l->bx1 + dx + dw);
    nb.y1 = (WORD)(l->by1 + dy + dh);
    if (nb.x1 < nb.x0 || nb.y1 < nb.y0)
	return 0;

    flag = 1;
    li   = (struct FLLayerInfo *)l->LayerInfo;
    L_LockLayerInfo(lay, li);

    if (l != li->top_layer) {
	struct FLClipRect *cr;
	struct FLLayer *f;

	for (cr = l->ClipRect; cr; cr = cr->next)
	    if (cr->lobs) { flag = 0; break; }

	if (flag)
	    for (f = l->front; f; f = f->front)
		if (RectOverlap(&nb, (struct FLRect *)&f->bx0)) {
		    flag = 0;
		    break;
		}
    }

    if (flag)
	l->Flags = (l->Flags & ~2) | 1;		/* -> LAYERSIMPLE  */

    ret = (LONG)CALL_MSL(patchtab[3].saved, lay, l, dx, dy, dw, dh);

    if (flag)
	l->Flags = (l->Flags & ~1) | 2;		/* -> LAYERSMART   */

    L_UnlockLayerInfo(lay, l->LayerInfo);
    return ret;
}

/* -60: new MoveLayer(dummy a0, l a1, dx d0, dy d1)		    */
LONG NewMoveLayer(
    APTR  dummy __asm("a0"),
    struct FLLayer *l __asm("a1"),
    LONG dx __asm("d0"), LONG dy __asm("d1"),
    struct Library *lay __asm("a6"))
{
    return (LONG)CALL_MSL(NewMoveSizeLayer, lay, l, dx, dy, 0, 0);
}

/* -66: new SizeLayer(dummy a0, l a1, dw d0, dh d1)		    */
LONG NewSizeLayer(
    APTR  dummy __asm("a0"),
    struct FLLayer *l __asm("a1"),
    LONG dw __asm("d0"), LONG dh __asm("d1"),
    struct Library *lay __asm("a6"))
{
    return (LONG)CALL_MSL(NewMoveSizeLayer, lay, l, 0, 0, dw, dh);
}
