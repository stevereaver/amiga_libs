/*
**	intuisupport.c -- intuisupport.library 1.1
**
**	C reconstruction of the shipped two-hunk binary (2100 bytes).
**	The original was produced by a code generator that emitted a
**	non-standard resident module: the RomTag's rt_Init was patched
**	by a hunk-1 relocation to point at an InitTable stored in the
**	DATA hunk, and that table's funcTable/initRoutine fields hold
**	raw code offsets (0x67c / 0x20), not relocated pointers -- so
**	the shipped file cannot be bootstrapped by exec InitResident
**	directly; it must have been loaded by a custom loader that added
**	the code-hunk base to those fields.  See okf/findings/.
**
**	This rebuild uses a conventional AUTOINIT InitTable in .data so
**	the library loads under a stock exec; the runtime semantics are
**	identical once resident:
**
**	  - LibInit populates the Library node by hand, copies a
**	    124-byte private template (the shipped DATA hunk) into the
**	    library base at +46, then runs a (dead) fixup list whose
**	    count field sits at template+124, and opens
**	    intuition.library / graphics.library at version 0, storing
**	    the bases at priv+124 / priv+128.
**
**	  - All entry points use the same register-parameter ABI as the
**	    original (arguments in d0-d7 / a0-a5, library base in a6).
**
**	Vectors:
**	    -6  Open        -12 Close       -18 Expunge     -24 reserved(0)
**	    -30 Make3DBorder(w,h,x,y,penA,penB,next)  -> Border* pair
**	    -36 FreeBorder(b)                          free the pair
**	    -42 AllocBufList(size)                     -> 36B double buffer
**	    -48 FreeBufList(h)
**	    -54 ResetBufList(obj)                      obj+34 -> header
**	    -60 FillBuf(dst,byte,len)
**	    -66 ClrBuf(dst,len)
**	    -72 StrLen(s)
**	    -78 ISCopyMem(src,dst,len)                 exec CopyMem thunk
**	    -84 AbortAlert(text,callback)              DisplayAlert + jsr cb
**	    -90 DrawText(obj,pen,bgpen,x,y,text)       rp at obj+50
**
**	Defects preserved from the original (see okf/findings/defects.md):
**	  - Make3DBorder leaks the 24-byte coordinate block when the third
**	    allocation fails and returns the caller's `next` pointer.
**	  - AbortAlert measures the caller text for centring but never
**	    copies it into the alert buffer; alert y-coord low byte is
**	    taken from *callback (unconditional -- NULL callback reads
**	    absolute page zero).
**	  - ResetBufList leaves the last byte of each buffer uncleared
**	    (count stored is size-1).
**	  - Expunge frees the private-area block size handed to it by
**	    exec's Neg/PosSize fields; identical behaviour.
*/

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef short          WORD;
typedef long           LONG;
typedef void          *APTR;

struct ISBorder			/* 16 bytes, = struct Border */
{
	WORD	LeftEdge;
	WORD	TopEdge;
	UBYTE	FrontPen;
	UBYTE	DrawMode;
	WORD	Count;
	WORD	*XY;
	struct ISBorder *NextBorder;
};

struct ISBufList		/* 36 bytes */
{
	UBYTE	*BufA;		/* +0  first buffer		  */
	UBYTE	*BufB;		/* +4  second buffer		  */
	UWORD	F8;		/* +8  state word (reset to 0)	  */
	UWORD	Count;		/* +10 buffer size - 1		  */
	UWORD	F12;		/* +12 state word		  */
	UWORD	F14;		/* +14 state word		  */
	UBYTE	Rest[20];	/* +16 .. +35			  */
};

/* private area at base+46: 124-byte template copy + two lib bases */
struct ISPriv
{
	ULONG	TPad;		/* +0   0			  */
	ULONG	TDataSize;	/* +4   0xb2  (dead inittab image) */
	ULONG	TFuncTab;	/* +8   0x67c (dead inittab image) */
	ULONG	TDataTab;	/* +12  0     (dead inittab image) */
	ULONG	TInitR;		/* +16  0x20  (dead inittab image) */
	UBYTE	AbortMsg[61];	/* +20  "Nach Betaetigung ..."	  */
	UBYTE	AlertPad[3];	/* +81  00 00 00			  */
	UBYTE	AlertHi2;	/* +84  0x00 -> buf[5+len]	  */
	UBYTE	AlertLo2;	/* +85  0x50 -> buf[6+len]	  */
	UBYTE	AlertYHi;	/* +86  0x10 -> buf[2]		  */
	UBYTE	AlertYLo;	/* +87  0x1c -> buf[7+len]	  */
	char	IntuName[18];	/* +88  "intuition.library"	  */
	char	GfxName[17];	/* +106 "graphics.library"	  */
	UBYTE	Pad123;		/* +123				  */
	APTR	IntuitionBase;	/* +124				  */
	APTR	GfxBase;	/* +128				  */
};				/* = 132 bytes */

struct ISBase			/* 178 bytes = InitTable dataSize */
{
	UBYTE	LibNode[14];	/* ln_Succ..ln_Type..ln_Name	  */
	UBYTE	LibFlags;	/* +14 */
	UBYTE	LibPad;
	UWORD	NegSize;	/* +16 */
	UWORD	PosSize;	/* +18 */
	UWORD	Version;	/* +20 */
	UWORD	Revision;	/* +22 */
	ULONG	IdString;	/* +24 */
	ULONG	Sum;		/* +28 */
	UWORD	OpenCnt;	/* +32 */
	ULONG	SegList;	/* +34 */
	UBYTE	Pad[8];		/* +38 .. +45 */
	struct ISPriv Priv;	/* +46 .. +177 */
};

extern const UBYTE istempl[];	/* DATA hunk image (128 bytes) */
extern char idstr[];

/* ------------------------------------------------------------------ */
/* exec/intuition/graphics primitives -- absolute-4 SysBase as in the   */
/* original (moveal 4,a6 before every call)				  */
/* ------------------------------------------------------------------ */

#define SYSBASE()	(*(void **)4)

static APTR is_AllocMem(ULONG size, ULONG flags)
{
	register ULONG d0 __asm("d0") = size;
	register ULONG d1 __asm("d1") = flags;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-198)"
			: "+r"(d0) : "r"(d1), "r"(a6)
			: "a0","a1","memory");
	return (APTR)d0;
}

static void is_FreeMem(APTR ptr, ULONG size)
{
	register ULONG d0 __asm("d0") = size;
	register void *a1 __asm("a1") = ptr;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-210)" :: "r"(d0), "r"(a1), "r"(a6)
			: "a0","d1","memory");
}

static APTR is_OpenLibrary(const char *name, ULONG ver)
{
	register ULONG d0 __asm("d0") = ver;
	register void *a1 __asm("a1") = (void *)name;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-552)"
			: "+r"(d0) : "r"(a1), "r"(a6)
			: "a0","d1","memory");
	return (APTR)d0;
}

static void is_CloseLibrary(APTR lib)
{
	register void *a1 __asm("a1") = lib;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-414)" :: "r"(a1), "r"(a6)
			: "a0","d0","d1","memory");
}

static void is_Remove(APTR node)
{
	register void *a1 __asm("a1") = node;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-252)" :: "r"(a1), "r"(a6)
			: "a0","d0","d1","memory");
}

static void is_CopyMem(APTR src, APTR dst, ULONG len)
{
	register void *a0 __asm("a0") = src;
	register void *a1 __asm("a1") = dst;
	register ULONG d0 __asm("d0") = len;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-624)" :: "r"(a0), "r"(a1), "r"(d0), "r"(a6)
			: "d1","memory");
}

/* intuition/graphics calls used by AbortAlert / DrawText */
static void is_DisplayAlert(APTR intu, ULONG num, UBYTE *str, ULONG h)
{
	register ULONG d0 __asm("d0") = num;
	register void *a0 __asm("a0") = str;
	register ULONG d1 __asm("d1") = h;
	register void *a6 __asm("a6") = intu;
	__asm volatile ("jsr a6@(-90)" :: "r"(d0), "r"(a0), "r"(d1), "r"(a6)
			: "a1","memory");
}
static void is_SetAPen(APTR gfx, APTR rp, ULONG pen)
{
	register ULONG d0 __asm("d0") = pen;
	register void *a1 __asm("a1") = rp;
	register void *a6 __asm("a6") = gfx;
	__asm volatile ("jsr a6@(-342)" :: "r"(d0), "r"(a1), "r"(a6)
			: "a0","d1","memory");
}
static void is_SetBPen(APTR gfx, APTR rp, ULONG pen)
{
	register ULONG d0 __asm("d0") = pen;
	register void *a1 __asm("a1") = rp;
	register void *a6 __asm("a6") = gfx;
	__asm volatile ("jsr a6@(-348)" :: "r"(d0), "r"(a1), "r"(a6)
			: "a0","d1","memory");
}
static void is_Move(APTR gfx, APTR rp, LONG x, LONG y)
{
	register ULONG d0 __asm("d0") = x;
	register ULONG d1 __asm("d1") = y;
	register void *a1 __asm("a1") = rp;
	register void *a6 __asm("a6") = gfx;
	__asm volatile ("jsr a6@(-240)" :: "r"(d0), "r"(d1), "r"(a1), "r"(a6)
			: "a0","memory");
}
static void is_Text(APTR gfx, APTR rp, UBYTE *s, ULONG len)
{
	register ULONG d0 __asm("d0") = len;
	register void *a0 __asm("a0") = s;
	register void *a1 __asm("a1") = rp;
	register void *a6 __asm("a6") = gfx;
	__asm volatile ("jsr a6@(-60)" :: "r"(d0), "r"(a0), "r"(a1), "r"(a6)
			: "d1","memory");
}

#define IS_MEMFLAGS	0x00010001	/* MEMF_PUBLIC | MEMF_CLEAR */

/* ------------------------------------------------------------------ */
/* library init / lifecycle						  */
/* ------------------------------------------------------------------ */

static LONG is_bootstrap(struct ISPriv *p)
{
	p->IntuitionBase = is_OpenLibrary(p->IntuName, 0);
	if (!p->IntuitionBase)
		return -1;
	p->GfxBase = is_OpenLibrary(p->GfxName, 0);
	if (!p->GfxBase) {
		is_CloseLibrary(p->IntuitionBase);
		return -1;
	}
	return 0;
}

/* entry: d0 = library base, a0 = segment list, a6 = SysBase */
struct ISBase *LibInit(register struct ISBase *base __asm("d0"),
			register APTR seglist __asm("a0"),
			register void *sysbase __asm("a6"))
{
	struct ISPriv *p = &base->Priv;
	const ULONG *fix;
	LONG n, i;

	base->SegList = (ULONG)seglist;
	base->LibNode[8] = 9;				/* ln_Type */
	*(ULONG *)&base->LibNode[10] = (ULONG)"intuisupport.library";
	base->LibFlags = 6;				/* SUMUSED|CHANGED */
	base->Version  = 1;
	base->Revision = 1;
	base->IdString = (ULONG)idstr;

	for (i = 0; i < 124; i++)
		((UBYTE *)p)[i] = istempl[i];

	/* fixup pass over the copied block; shipped count (template
	** +124) is zero, so the mechanism is dead in practice */
	n = *(const ULONG *)&istempl[124];
	fix = (const ULONG *)&istempl[128];
	for (i = 0; i < n; i++)
		*(ULONG *)((UBYTE *)p + fix[i]) += (ULONG)p;

	if (is_bootstrap(p))
		return 0;
	return base;
}

struct ISBase *LibOpen(register struct ISBase *base __asm("a6"))
{
	base->OpenCnt++;
	base->LibFlags &= ~8;		/* clear LIBF_DELEXP */
	return base;
}

ULONG LibClose(register struct ISBase *base __asm("a6"));

ULONG LibExpunge(register struct ISBase *base __asm("a6"))
{
	struct ISPriv *p = &base->Priv;
	ULONG seg;
	if (base->OpenCnt) {
		base->LibFlags |= 8;	/* LIBF_DELEXP */
		return 0;
	}
	is_CloseLibrary(p->IntuitionBase);
	is_CloseLibrary(p->GfxBase);
	seg = base->SegList;
	is_Remove(base);
	is_FreeMem((UBYTE *)base - base->NegSize,
		   base->NegSize + base->PosSize);
	return seg;
}

ULONG LibClose(register struct ISBase *base __asm("a6"))
{
	ULONG seg = 0;
	if (--base->OpenCnt == 0 && (base->LibFlags & 8))
		seg = LibExpunge(base);
	return seg;
}

/* ------------------------------------------------------------------ */
/* -30: Make3DBorder(w,h,x,y,penA,penB,next) -> ISBorder *		  */
/* ------------------------------------------------------------------ */
/*
**  Two-Border raised box of size w x h at offset (x,y):
**  border 1 traces (0,h)-(0,0)-(w,0) in penA (top/left highlight),
**  border 2 traces (w,1)-(w,h)-(1,h) in penB (right/bottom shadow).
**  Both borders share one 24-byte coordinate block: b1.XY -> pairs
**  0-2, b2.XY -> pairs 3-5.
**
**  Alloc order: xy(24), b1(16), b2(16).  If the b2 allocation fails
**  the original frees b1, returns the caller's `next` and LEAKS xy
**  -- reproduced faithfully.
*/
struct ISBorder *is_Make3DBorder(ULONG w, ULONG h, ULONG x, ULONG y,
				 ULONG penA, ULONG penB,
				 struct ISBorder *next, struct ISBase *base)
{
	WORD *xy;
	struct ISBorder *b1, *b2;

	/* the original clears a0 at entry: next is dead, the stored
	** NextBorder and the b2-failure return are always NULL */
	next = 0;

	xy = (WORD *)is_AllocMem(24, IS_MEMFLAGS);
	if (!xy)
		return 0;
	b1 = (struct ISBorder *)is_AllocMem(16, IS_MEMFLAGS);
	if (!b1) {
		is_FreeMem(xy, 24);
		return 0;
	}
	b2 = (struct ISBorder *)is_AllocMem(16, IS_MEMFLAGS);
	if (!b2) {
		is_FreeMem(b1, 16);
		return next;		/* xy leaked -- original defect */
	}
	xy[0]=0;  xy[1]=h;   xy[2]=0;  xy[3]=0;
	xy[4]=w;  xy[5]=0;   xy[6]=w;  xy[7]=1;
	xy[8]=w;  xy[9]=h;   xy[10]=1; xy[11]=h;
	b1->LeftEdge=x; b1->TopEdge=y;
	b1->FrontPen=penA; b1->DrawMode=0; b1->Count=3;
	b1->XY=xy;   b1->NextBorder=b2;
	b2->LeftEdge=x; b2->TopEdge=y;
	b2->FrontPen=penB; b2->DrawMode=0; b2->Count=3;
	b2->XY=xy+6; b2->NextBorder=0;
	return b1;
}

/* -36: FreeBorder(b) */
void is_FreeBorder(struct ISBorder *b, struct ISBase *base)
{
	if (b->XY)         is_FreeMem(b->XY, 24);
	if (b->NextBorder) is_FreeMem(b->NextBorder, 16);
	is_FreeMem(b, 16);
}

/* ------------------------------------------------------------------ */
/* -42/-48/-54: double buffer list					  */
/* ------------------------------------------------------------------ */

/* -42: AllocBufList(size) -> header or 0.
**  Alloc order: bufA(size), bufB(size), header(36). */
struct ISBufList *is_AllocBufList(ULONG size, struct ISBase *base)
{
	UBYTE *bufA, *bufB;
	struct ISBufList *h;

	bufA = (UBYTE *)is_AllocMem(size, IS_MEMFLAGS);
	if (!bufA)
		return 0;
	bufB = (UBYTE *)is_AllocMem(size, IS_MEMFLAGS);
	if (!bufB) {
		is_FreeMem(bufA, size);
		return 0;
	}
	h = (struct ISBufList *)is_AllocMem(36, IS_MEMFLAGS);
	if (!h) {
		is_FreeMem(bufA, size);
		is_FreeMem(bufB, size);
		return 0;
	}
	h->BufA  = bufA;
	h->BufB  = bufB;
	h->F8    = 0;
	h->Count = size - 1;
	h->F12   = 0;
	return h;
}

/* -48: FreeBufList(h) -- NULL-safe on the buffers */
void is_FreeBufList(struct ISBufList *h, struct ISBase *base)
{
	ULONG sz;
	if (!h)
		return;
	sz = h->Count + 1;
	if (h->BufA) is_FreeMem(h->BufA, sz);
	if (h->BufB) is_FreeMem(h->BufB, sz);
	is_FreeMem(h, 36);
}

/* -54: ResetBufList(obj) -- obj+34 holds the header pointer.
**  Clears Count bytes of each buffer (last byte survives -- the
**  stored count is size-1) and zeroes F8/F12/F14. */
void is_ResetBufList(UBYTE *obj, struct ISBase *base)
{
	struct ISBufList *h = (struct ISBufList *)*(ULONG *)((UBYTE *)obj + 34);
	ULONG i;
	for (i = 0; i < h->Count; i++) {
		h->BufA[i] = 0;
		h->BufB[i] = 0;
	}
	h->F8 = h->F12 = h->F14 = 0;
}

/* ------------------------------------------------------------------ */
/* -60/-66/-72/-78: small memory helpers				  */
/* ------------------------------------------------------------------ */

/* -60: FillBuf(dst,byte,len) */
void is_FillBuf(UBYTE *dst, ULONG byte, ULONG len, struct ISBase *base)
{
	ULONG i;
	for (i = 0; i < len; i++)
		dst[i] = byte;
}

/* -66: ClrBuf(dst,len) -- FillBuf with byte 0 */
void is_ClrBuf(UBYTE *dst, ULONG len, struct ISBase *base)
{
	ULONG i;
	for (i = 0; i < len; i++)
		dst[i] = 0;
}

/* normal-ABI helper used by vectors and internally */
static ULONG is_strlen(const UBYTE *s)
{
	ULONG n = 0;
	while (s[n])
		n++;
	return n;
}

/* -72: StrLen(s) -> length */
ULONG is_StrLen(UBYTE *s, struct ISBase *base)
{
	return is_strlen(s);
}

/* -78: ISCopyMem(src,dst,len) -- thin exec CopyMem thunk */
void is_ISCopyMem(APTR src, APTR dst, ULONG len, struct ISBase *base)
{
	is_CopyMem(src, dst, len);
}

/* ------------------------------------------------------------------ */
/* -84: AbortAlert(text, callback)					  */
/* ------------------------------------------------------------------ */
/*
**  Builds a DisplayAlert string on the stack and shows it, then tail-
**  calls the caller-supplied abort routine.
**
**  Wire format observed from the original (DisplayAlert pieces are
**  {UWORD x, UWORD y, text, NUL}):
**      buf+0      centered x for `text' (320 - 4*len), big-endian
**      buf+2      template byte +86 (0x10)
**      buf+3      *callback  -- first byte of the callback's code!
**      buf+4      `len' zero bytes -- the caller text is measured
**                 for centring but NEVER copied in (defect)
**      buf+4+len  0xcc, template +84/+85 (00 50), template +87 (0x1c)
**      buf+8+len  abort message ("Nach Betaetigung ..."), strlen bytes
**      then       NUL terminator (from the cleared buffer)
*/
ULONG is_AbortAlert(UBYTE *text, void (*cb)(void), struct ISBase *base)
{
	struct ISPriv *p = &base->Priv;
	UBYTE frame[272];
	UBYTE *buf = frame + 44;
	ULONG len = is_strlen(text);
	UWORD x = 320 - 4 * len;
	UBYTE *q;
	ULONG i;

	for (i = 0; i < 256; i++)		/* clear string area */
		buf[4 + i] = 0;
	buf[0] = x >> 8;
	buf[1] = x;
	buf[2] = p->AlertYHi;
	buf[3] = *(UBYTE *)cb;		/* unconditional deref */
	q = buf + 4 + len;
	q[0] = 0xcc;
	q[1] = p->AlertHi2;
	q[2] = p->AlertLo2;
	q[3] = p->AlertYLo;
	is_CopyMem(p->AbortMsg, q + 4, is_strlen(p->AbortMsg));

	is_DisplayAlert(p->IntuitionBase, 0, buf, 40);
	if (cb)
		cb();
	return (ULONG)cb;
}

/* ------------------------------------------------------------------ */
/* -90: DrawText(obj,pen,bgpen,x,y,text) -- rastport at obj+50	  */
/* ------------------------------------------------------------------ */
ULONG is_DrawText(UBYTE *obj, ULONG pen, ULONG bgpen,
		  ULONG x, ULONG y, UBYTE *text, struct ISBase *base)
{
	struct ISPriv *p = &base->Priv;
	APTR rp = (APTR)*(ULONG *)((UBYTE *)obj + 50);	/* obj+50 = RastPort */
	ULONG len;

	is_SetAPen(p->GfxBase, rp, pen);
	is_SetBPen(p->GfxBase, rp, bgpen);
	is_Move(p->GfxBase, rp, x, y);
	len = is_strlen(text);
	is_Text(p->GfxBase, rp, text, len);
	return len;
}
