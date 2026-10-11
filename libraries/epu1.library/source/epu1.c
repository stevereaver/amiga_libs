/*
**	epu1.library 1.1 -- front end for lh.library ("easy pack").
**
**	Reconstruction in C from the 1,564-byte original (4 hunks).
**	Two public functions:
**	  -30  EpuPack(a0=src, a1=maxout, d0=srclen, d1=dst, a2=callname)
**	       -> lh -42 with blk = {src, srclen, dst}; fails -2 when the
**	       packed result >= caller's a1 bound.
**	  -36  EpuUnpack(a0=src, a1=outlen, d0=srclen, d1=dst, a2=callname)
**	       -> lh -48 with blk = {src, srclen, dst, outlen}; same -2 rule.
**	Both allocate a 58-byte MEMF_CLEAR context (fail -> -1), fetch an
**	lh control block via lh -30 (mode 0/1; on failure an AutoRequest
**	offers RETRY/CANCEL), run the op, lh -36 the block, free the ctx.
**
**	Library base (48 bytes): Library(34) + exec@34 + dos@38 +
**	seglist@42 + flagbyte@46 (bit3 = deferred expunge).
**	lh/intuition/dos-mirror live as code-space statics (hunk
**	0x2fc/0x304/0x30c in the original, surrounded by dead slots).
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>

struct EpuBase {
	struct Library eb_Lib;	/* +0  (34 bytes) */
	APTR  eb_Exec;		/* +34 */
	APTR  eb_Dos;		/* +38 */
	APTR  eb_Seg;		/* +42 */
	UBYTE eb_Flags;		/* +46  bit3 = expunge pending */
	UBYTE eb_pad;
};

struct IntuiText {
	UBYTE it_FrontPen, it_BackPen, it_DrawMode, it_pad;
	SHORT it_LeftEdge, it_TopEdge;
	APTR  it_ITextFont;
	UBYTE *it_IText;
	struct IntuiText *it_NextText;
};

/* 58-byte call context; field order matches the pop order
** of the original's push-a0/a1/d0/d1/a2 AllocMem helper. */
struct EpuCtx {
	APTR  src;	/* +0  caller a0 */
	ULONG dst;	/* +4  caller d1 */
	ULONG slen;	/* +8  caller d0 */
	APTR  bound;	/* +12 caller a1 */
	APTR  name;	/* +16 caller a2 */
	APTR  blk;	/* +20 lh control block */
	LONG  res;	/* +24 lh result */
	UBYTE tail[30];	/* +28..57 unused tail */
};

extern void *s_lh, *s_intui, *s_doscopy;
extern char s_epuname[], s_lhname[], s_cantopen[];
extern char s_oomtitle[], s_callname[], s_retry[], s_cancel[];
extern char dosname[], intuiname[];
extern APTR LibExpunge(struct EpuBase *eb __asm("a6"));

#define SYSBASE (*(APTR *)4)

/* ---- raw LVO callers (named-register convention) ------------------ */

#define ALLOCMEM(sz,fl) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_sz __asm("d0") = (ULONG)(sz);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res), "+d"(__p_fl)\
    : "a"(__p_sys), "d"(__p_sz)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

#define FREEMEM(blk,sz) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_b __asm("a1") = (APTR)(blk);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_b), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})

#define OPENLIB(nm) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register const char * __p_n __asm("a1") = (nm);\
  register ULONG __p_v __asm("d0") = 0;\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=r"(__p_res), "+a"(__p_n)\
    : "a"(__p_sys), "d"(__p_v)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})

#define CLOSLIB(lib) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})

/* the original calls Remove with the node in a0 (not the
** documented a1) -- verbatim quirk */
#define REMOVE_A0(node) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_n __asm("a0") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})

#define ALERT(num) ({\
  register APTR __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_a __asm("d7") = (ULONG)(num);\
  __asm volatile ("jsr %/a6@(-108:W)\n"\
    : "+d"(__p_a)\
    : "a"(__p_sys)\
    : "d0","d1","a0","a1","fp0","fp1","cc","memory");})

/* lh.library: -30 alloc(d0=mode) -36 free(a0=blk)
** -42 pack(a0=blk) -48 unpack(a0=blk) */
#define LHALLOC(mode) ({\
  register APTR __p_lh __asm("a6") = s_lh;\
  register ULONG __p_m __asm("d0") = (ULONG)(mode);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-30:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_lh), "d"(__p_m)\
    : "d1","a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

#define LHFREE(blk) ({\
  register APTR __p_lh __asm("a6") = s_lh;\
  register APTR __p_b __asm("a0") = (APTR)(blk);\
  __asm volatile ("jsr %/a6@(-36:W)\n"\
    : "+a"(__p_b)\
    : "a"(__p_lh)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})

#define LHOP(lvo,blk) ({\
  register APTR __p_lh __asm("a6") = s_lh;\
  register APTR __p_b __asm("a0") = (APTR)(blk);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #lvo ":W)\n"\
    : "=r"(__p_res), "+a"(__p_b)\
    : "a"(__p_lh)\
    : "d1","a1","fp0","fp1","cc","memory");\
  __p_res;})

/* AutoRequest(-348): a0=window a1=body a2=pos a3=neg
** d0=pflag d1=nflag d2=width d3=height */
#define AUTOREQ(body,pos,neg) ({\
  register APTR __p_in __asm("a6") = s_intui;\
  register APTR __p_w __asm("a0") = 0;\
  register APTR __p_b __asm("a1") = (APTR)(body);\
  register APTR __p_p __asm("a2") = (APTR)(pos);\
  register APTR __p_g __asm("a3") = (APTR)(neg);\
  register ULONG __p_pf __asm("d0") = 0;\
  register ULONG __p_nf __asm("d1") = 0;\
  register ULONG __p_ww __asm("d2") = 310;\
  register ULONG __p_hh __asm("d3") = 68;\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-348:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_in), "a"(__p_w), "a"(__p_b), "a"(__p_p), "a"(__p_g),\
      "d"(__p_pf), "d"(__p_nf), "d"(__p_ww), "d"(__p_hh)\
    : "fp0","fp1","cc","memory");\
  __p_res;})

/* ---- the AutoRequest dialog ---------------------------------------
** Frame copies of the original's IntuiText templates.  TopEdges are
** 3/13/23 so the lines render arg3 (top), arg2 (mid), arg1 (bottom).
** The original's third chain node keeps its template NextText into
** the static data records -- two extra NULL-text nodes trail the
** real message (verbatim quirk). */

static struct IntuiText it_tail1 =
	{ 0,1,1,0, 5,23, 0,0, 0 };
static struct IntuiText it_tail2 =
	{ 0,1,1,0, 5,13, 0,0, &it_tail1 };
static struct IntuiText it_retry =
	{ 0,1,1,0, 6,3, 0, (UBYTE *)s_retry, 0 };
static struct IntuiText it_cancel =
	{ 0,1,1,0, 6,3, 0, (UBYTE *)s_cancel, 0 };

static LONG show_req(UBYTE *t1, UBYTE *t2, UBYTE *t3)
{
	struct IntuiText it[3];

	it[0] = it_tail1;		/* T=23, arg1 (bottom line) */
	it[1] = it_tail2;		/* T=13, arg2 */
	it[2] = it_tail1;
	it[2].it_TopEdge = 3;		/* T=3, arg3 (top line) */
	it[0].it_NextText = &it[1];
	it[1].it_NextText = &it[2];
	it[2].it_NextText = &it_tail2;	/* stale template link */
	it[0].it_IText = t1;
	it[1].it_IText = t2;
	it[2].it_IText = t3;
	return AUTOREQ(&it[0], &it_retry, &it_cancel);
}

/* ---- call-context helpers ----------------------------------------- */

static struct EpuCtx *ctx_alloc(APTR src, ULONG d1v, ULONG slen,
				APTR bound, APTR name)
{
	struct EpuCtx *c = ALLOCMEM(58, 0x10000);	/* MEMF_CLEAR */
	if (!c)
		return 0;
	c->name = name;
	c->dst = d1v;
	c->slen = slen;
	c->bound = bound;
	c->src = src;
	return c;
}

/* lhAlloc(-30) with OOM AutoRequest retry; returns NULL on CANCEL */
static APTR blk_retry(struct EpuCtx *c, ULONG mode)
{
	for (;;) {
		c->blk = LHALLOC(mode);
		if (c->blk)
			return c->blk;
		if (!show_req((UBYTE *)s_oomtitle, (UBYTE *)s_callname,
			      (UBYTE *)c->name))
			return 0;
	}
}

static void blk_free(struct EpuCtx *c)
{
	LHFREE(c->blk);
}

/* ---- public functions --------------------------------------------- */

LONG EpuPack(APTR src __asm("a0"), APTR bound __asm("a1"),
	     ULONG slen __asm("d0"), ULONG dst __asm("d1"),
	     APTR name __asm("a2"))
{
	struct EpuCtx *c = ctx_alloc(src, dst, slen, bound, name);
	ULONG *blk;
	LONG r;

	if (!c)
		return -1;
	if (!(blk = blk_retry(c, 0))) {
		r = -1;
	} else {
		blk[0] = (ULONG)c->src;
		blk[1] = c->slen;
		blk[2] = c->dst;
		c->res = LHOP(42, blk);			/* lhPack */
		blk_free(c);
		r = ((ULONG)c->res < (ULONG)c->bound) ? c->res : -2;
	}
	FREEMEM(c, 58);
	return r;
}

LONG EpuUnpack(APTR src __asm("a0"), APTR bound __asm("a1"),
	       ULONG slen __asm("d0"), ULONG dst __asm("d1"),
	       APTR name __asm("a2"))
{
	struct EpuCtx *c = ctx_alloc(src, dst, slen, bound, name);
	ULONG *blk;
	LONG r;

	if (!c)
		return -1;
	if (!(blk = blk_retry(c, 1))) {
		r = -1;
	} else {
		blk[0] = (ULONG)c->src;
		blk[1] = c->slen;
		blk[2] = c->dst;
		blk[3] = (ULONG)c->bound;
		c->res = LHOP(48, blk);			/* lhUnpack */
		blk_free(c);
		r = ((ULONG)c->res < (ULONG)c->bound) ? c->res : -2;
	}
	FREEMEM(c, 58);
	return r;
}

/* ---- lifecycle ------------------------------------------------------ */

APTR LibInit(APTR base __asm("d0"), APTR seg __asm("a0"))
{
	struct EpuBase *eb = base;

	eb->eb_Exec = SYSBASE;
	eb->eb_Seg = seg;
	eb->eb_Dos = OPENLIB(dosname);
	s_doscopy = eb->eb_Dos;			/* dead mirror */
	if (!eb->eb_Dos)
		ALERT(0x38007);
	s_intui = OPENLIB(intuiname);
	if (!s_intui)
		ALERT(0x38007);
	for (;;) {
		s_lh = OPENLIB(s_lhname);
		if (s_lh)
			break;
		show_req((UBYTE *)s_epuname, (UBYTE *)s_cantopen,
			 (UBYTE *)s_lhname);		/* result ignored */
	}
	return eb;
}

APTR LibOpen(struct EpuBase *eb __asm("a6"))
{
	eb->eb_Lib.lib_OpenCnt++;
	eb->eb_Flags &= ~8;	/* bclr #3 */
	return eb;
}

APTR LibClose(struct EpuBase *eb __asm("a6"))
{
	if (!--eb->eb_Lib.lib_OpenCnt && (eb->eb_Flags & 8))
		return LibExpunge(eb);
	return 0;
}

APTR LibExpunge(struct EpuBase *eb __asm("a6"))
{
	APTR seg;

	if (eb->eb_Lib.lib_OpenCnt) {
		eb->eb_Flags |= 8;
		return 0;
	}
	seg = eb->eb_Seg;
	REMOVE_A0(eb);				/* Remove via a0 (quirk) */
	CLOSLIB(eb->eb_Dos);				/* CloseLibrary */
	CLOSLIB(s_intui);
	CLOSLIB(s_lh);
	FREEMEM((APTR)((char *)eb - eb->eb_Lib.lib_NegSize),
		(ULONG)eb->eb_Lib.lib_NegSize + eb->eb_Lib.lib_PosSize);
	return seg;
}

LONG LibNull(void)
{
	return 0;
}
