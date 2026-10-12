/*
**	mhimpegit.c -- mhimpegit.library 4.0 (22.05.2022) by Thomas Wenzel
**
**	C reconstruction of the shipped three-hunk binary (2132 bytes).
**	The original is a 68020+ build: it uses BSR.L, memory-indirect
**	addressing (a3@(38)@(15)) and DIVU.L, and relies on the DATA hunk
**	holding the AUTOINIT InitTable (rt_Init is a data-hunk reloc).
**
**	The library is a thin wrapper around prelude.library ("MPEGit"):
**	create opens prelude v4, builds a 3-tag list and calls prelude@-90;
**	object helpers maintain a private MinList of 24-byte records; a
**	quality dispatcher rewrites single-tag lists into prelude@-90.
**
**	State:
**	  BSS+0  library base      BSS+8  DOSBase
**	  BSS+4  ExecBase          BSS+12 PreludeBase
**	  lib+34 seglist   lib+38 ExecBase   lib+42 DOSBase
**
**	Vectors:
**	    -6  Open     -12 Close    -18 Expunge   -24 reserved(0)
**	    -30 Create(tag0=a0,tag1=d0)     -> obj*
**	    -36 Destroy(obj=a3)
**	    -42 Append(v0=a0,v1=d1wait d0,obj=a3) -> 1
**	    -48 Pop(obj=a3)                 -> node data0 (gated on flag)
**	    -54 Query(obj=a3)               -> (obj&~0xff)|!flag (sloppy)
**	    -60 Iterate(obj=a3)             prelude@-60 per unmarked node
**	    -66 Drain(obj=a3)               prelude@-84/-36, Delay(35), free all
**	    -72 bare rts (returns stale d0)
**	    -78 Classify(code=d1)           -> bool / version-string ptr
**	    -84 Dispatch(op=d0,val=d1,obj=a3)   prelude@-90 single tag
**
**	Defects preserved (see okf/findings/defects.md):
**	  - Append never checks the AllocVec result (NULL deref on OOM).
**	  - Create re-opens prelude on every call; a second Create leaks the
**	    previous prelude base (Destroy clears BSS+12 only once).
**	  - Iterate's walk starts ON the list header block and reads its
**	    +12/+16 -- outside the 12-byte allocation; whether prelude@-60
**	    is called for the header depends on neighbouring heap bytes.
**	  - Query returns the object pointer's upper 24 bits in d0.
**	  - Append's failure path returns (arg1 & 0xffff0000), not 0.
**	  - Dispatch bounds-checks only d0.w; high garbage is ignored.
*/

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef void          *APTR;

/* BSS hunk image -- absolute refs in the original, a symbol here */
extern ULONG gbss[4];
#define G_LIB		gbss[0]
#define G_EXEC		gbss[1]
#define G_DOS		gbss[2]
#define G_PRELUDE	gbss[3]

extern const char str_doslib[];
extern const char str_prelib[];
extern const char str_mpegit[];
extern const char str_ver[];
extern const char str_author[];

/* ------------------------------------------------------------------ */
/* primitives							      */
/* ------------------------------------------------------------------ */

static APTR mh_OpenLibrary(const char *name, ULONG ver)
{
	register ULONG d0 __asm("d0") = ver;
	register APTR a1 __asm("a1") = (APTR)name;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-552)"
			: "+r"(d0) : "r"(a1), "r"(a6)
			: "a0","d1","memory");
	return (APTR)d0;
}

static void mh_CloseLibrary(APTR lib)
{
	register APTR a1 __asm("a1") = lib;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-414)" :: "r"(a1), "r"(a6)
			: "a0","d0","d1","memory");
}

static APTR mh_AllocVec(ULONG size, ULONG flags)
{
	register ULONG d0 __asm("d0") = size;
	register ULONG d1 __asm("d1") = flags;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-684)"
			: "+r"(d0) : "r"(d1), "r"(a6)
			: "a0","a1","memory");
	return (APTR)d0;
}

static void mh_FreeVec(APTR p)
{
	register APTR a1 __asm("a1") = p;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-690)" :: "r"(a1), "r"(a6)
			: "a0","d0","d1","memory");
}

static APTR mh_RemHead(APTR list)
{
	register APTR a0 __asm("a0") = list;
	register APTR d0 __asm("d0");
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-258)"
			: "=r"(d0) : "r"(a0), "r"(a6)
			: "a1","memory");
	return d0;
}

static void mh_AddTail(APTR list, APTR node)
{
	register APTR a0 __asm("a0") = list;
	register APTR a1 __asm("a1") = node;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-246)" :: "r"(a0), "r"(a1), "r"(a6)
			: "d0","d1","memory");
}

static void mh_Remove(APTR node)
{
	register APTR a1 __asm("a1") = node;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-252)" :: "r"(a1), "r"(a6)
			: "a0","d0","d1","memory");
}

static void mh_FreeMem(APTR p, ULONG size)
{
	register APTR a1 __asm("a1") = p;
	register ULONG d0 __asm("d0") = size;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-210)" :: "r"(a1), "r"(d0), "r"(a6)
			: "a0","d1","memory");
}

static void mh_Delay(ULONG ticks)
{
	register ULONG d1 __asm("d1") = ticks;
	register APTR a6 __asm("a6") = (APTR)G_DOS;
	__asm volatile ("jsr a6@(-198)" :: "r"(d1), "r"(a6)
			: "d0","a0","a1","memory");
}

/* prelude calls: a6 = prelude base, offsets -90/-60/-84/-36 */
static void pl_90(ULONG *tags)
{
	register ULONG *a0 __asm("a0") = tags;
	register APTR a6 __asm("a6") = (APTR)G_PRELUDE;
	__asm volatile ("jsr a6@(-90)" :: "r"(a0), "r"(a6)
			: "d0","d1","d2","a1","memory","cc");
}

static void pl_60(ULONG v0, ULONG v1)
{
	register APTR a0 __asm("a0") = (APTR)v0;
	register ULONG d0 __asm("d0") = v1;
	register ULONG d1 __asm("d1") = 0x1008;	/* original: movew on stale d1 */
	register ULONG d2 __asm("d2") = 0;
	register APTR a6 __asm("a6") = (APTR)G_PRELUDE;
	__asm volatile ("jsr a6@(-60)" :: "r"(a0), "r"(d0), "r"(d1), "r"(d2), "r"(a6)
			: "a1","memory","cc");
}

static void pl_84_36(ULONG d0val)
{
	register ULONG d0 __asm("d0") = d0val;
	register APTR a6 __asm("a6") = (APTR)G_PRELUDE;
	__asm volatile ("jsr a6@(-84)\n\tjsr a6@(-36)" :: "r"(d0), "r"(a6)
			: "d1","d2","a0","a1","memory","cc");
}

/* prelude internals (memory-indirect refs in the original) */
#define PL_CAPS(pb)	(*(UBYTE **)((UBYTE *)(pb) + 0x38) + 0x15)
#define PL_FLAGADDR(pb)	((ULONG *)(*(ULONG *)((UBYTE *)(pb) + 0x8e) + 0x10))
#define PL_FLAG(pb)	(*PL_FLAGADDR(pb))

/* ------------------------------------------------------------------ */
/* init helpers (stack-ABI like the original's 0x192/0x1ce/0x1f0/0x688) */
/* ------------------------------------------------------------------ */

ULONG mh_open_dos(ULONG *lib)		/* helper @0x192 */
{
	APTR ex = *(APTR *)4;
	APTR d;
	G_EXEC = (ULONG)ex;
	lib[38/4] = (ULONG)ex;
	d = mh_OpenLibrary(str_doslib, 36);
	G_DOS = (ULONG)d;
	if (!d)
		return 0;
	lib[42/4] = (ULONG)d;
	return 1;
}

void mh_close_dos(void)			/* helper @0x1ce */
{
	APTR d = (APTR)G_DOS;
	if (d)
		mh_CloseLibrary(d);
	G_DOS = 0;
}

void mh_newlist(ULONG *l)		/* helper @0x688 */
{
	l[2] = (ULONG)l;		/* tailpred = &head */
	l += 1;
	*l = 0;				/* tail = 0 */
	l[-1] = (ULONG)l;		/* head = &tail */
}

void mh_destroy_obj(ULONG *obj)		/* helper @0x1f0 */
{
	APTR pb;
	if (obj) {
		ULONG *lb = (ULONG *)obj[8/4];
		if (lb) {
			APTR n;
			while ((n = mh_RemHead(lb)) != 0)
				mh_FreeVec(n);
			mh_FreeVec(lb);
		}
		mh_FreeVec(obj);
	}
	pb = (APTR)G_PRELUDE;
	if (pb)
		mh_CloseLibrary(pb);
	G_PRELUDE = 0;
}

/* ------------------------------------------------------------------ */
/* lifecycle							      */
/* ------------------------------------------------------------------ */

ULONG mh_expunge_body(ULONG lib);		/* helper @0xa4 */

ULONG mh_init(ULONG lib, ULONG seglist, ULONG sysbase)
{
	ULONG *l = (ULONG *)lib;
	G_LIB = lib;
	l[38/4] = sysbase;
	l[34/4] = seglist;
	if (mh_open_dos(l))
		return G_LIB;
	mh_close_dos();
	mh_FreeMem((APTR)(lib - ((UWORD *)lib)[8]),
		   ((UWORD *)lib)[8] + ((UWORD *)lib)[9]);
	return 0;
}

ULONG mh_open(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	((UWORD *)l)[16] += 1;			/* OpenCnt @+32 */
	l[14] &= ~8;				/* flags byte  @+14 */
	return lib;
}

ULONG mh_close(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	((UWORD *)l)[16] -= 1;
	if (((UWORD *)l)[16])
		return 0;
	if (!(l[14] & 8))
		return 0;
	return mh_expunge_body(lib);
}

ULONG mh_expunge(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	if (((UWORD *)l)[16]) {
		l[14] |= 8;
		return 0;
	}
	return mh_expunge_body(lib);
}

ULONG mh_expunge_body(ULONG lib)
{
	ULONG *l = (ULONG *)lib;
	ULONG seg = l[34/4];
	mh_Remove(l);
	mh_close_dos();
	mh_FreeMem((APTR)(lib - ((UWORD *)lib)[8]),
		   ((UWORD *)lib)[8] + ((UWORD *)lib)[9]);
	return seg;
}

/* ------------------------------------------------------------------ */
/* public functions						      */
/* ------------------------------------------------------------------ */

ULONG mh_Create(ULONG arg0, ULONG arg1)		/* -30 */
{
	APTR pb;
	ULONG *obj, *lb;
	ULONG taglist[7];

	pb = mh_OpenLibrary(str_prelib, 4);
	G_PRELUDE = (ULONG)pb;
	if (!pb)
		goto fail;
	if (!(*PL_CAPS(pb) & 1))
		goto fail;
	obj = (ULONG *)mh_AllocVec(18, 0x10000);	/* CLEAR, private mem */
	if (!obj)
		goto fail;
	obj[0] = arg0;
	obj[1] = arg1;
	lb = (ULONG *)mh_AllocVec(12, 0x10001);		/* PUBLIC|CLEAR */
	obj[2] = (ULONG)lb;
	if (!lb) {
		mh_destroy_obj(obj);
		return 0;
	}
	mh_newlist(lb);
	taglist[0] = 0x80000032;	taglist[1] = arg0;
	taglist[2] = 0x80000033;	taglist[3] = arg1;
	taglist[4] = 0x8000003f;	taglist[5] = 100;
	taglist[6] = 0;
	pl_90(taglist);
	PL_FLAG(pb) = 0;
	return (ULONG)obj;

fail:
	mh_destroy_obj(0);
	return 0;
}

void mh_Destroy(ULONG *obj)			/* -36 */
{
	mh_destroy_obj(obj);
}

ULONG mh_Append(ULONG v0, ULONG v1, ULONG *obj)	/* -42 */
{
	APTR pb = (APTR)G_PRELUDE;
	ULONG *n;
	if (!obj)
		return v1 & 0xffff0000;		/* original: clrw d0 on stale arg */
	n = (ULONG *)mh_AllocVec(18, 0x10001);	/* unchecked in original */
	n[8/4]  = v0;
	n[12/4] = v1;
	((UWORD *)n)[8] = 0;
	mh_AddTail((APTR)obj[2], n);
	obj[3] += 1;
	if (PL_FLAG(pb)) {
		((UWORD *)n)[8] = 1;
		pl_60(v0, v1);
	}
	return 1;
}

ULONG mh_Pop(ULONG *obj)			/* -48 */
{
	APTR pb = (APTR)G_PRELUDE;
	ULONG *n;
	ULONG d2;
	if (!obj)
		return 0;
	if (PL_FLAG(pb) >= obj[3])	/* unsigned BCC */
		return 0;
	n = (ULONG *)mh_RemHead((APTR)obj[2]);
	if (!n)
		d2 = 0;
	else {
		d2 = n[8/4];
		mh_FreeVec(n);
	}
	if (obj[3])
		obj[3] -= 1;
	return d2;
}

ULONG mh_Query(ULONG *obj)			/* -54 */
{
	APTR pb = (APTR)G_PRELUDE;
	if (!obj)
		return 1;
	return ((ULONG)obj & 0xffffff00) | (PL_FLAG(pb) ? 0 : 1);
}

void mh_Iterate(ULONG *obj)			/* -60 */
{
	ULONG *a2;
	if (!obj)
		return;
	a2 = (ULONG *)obj[2];			/* list header block */
	if (!*a2)
		return;
	for (;;) {
		if (!((UWORD *)a2)[8]) {
			pl_60(a2[2], a2[3]);
			((UWORD *)a2)[8] = 1;
		}
		a2 = (ULONG *)*a2;
		if (!*a2)
			break;
	}
}

void mh_Drain(ULONG *obj)			/* -66 */
{
	APTR pb = (APTR)G_PRELUDE;
	APTR n;
	if (!obj)
		return;
	pl_84_36(((ULONG)obj & 0xffff0000) | 0x80);	/* movew #128 on stale d0 */
	mh_Delay(35);
	while ((n = mh_RemHead((APTR)obj[2])) != 0)
		mh_FreeVec(n);
	PL_FLAG(pb) = 0;
	obj[3] = 0;
}

ULONG mh_Classify(ULONG code)			/* -78 */
{
	if (code <= 31) {
		if (code >= 30)
			return 1;
		if (code > 12)
			return (1 >= code - 20) ? 1 : 0;
		if (code >= 10)
			return 1;
		return (2 >= code - 1) ? 1 : 0;
	}
	if (code == 1000)
		return (ULONG)str_mpegit;
	if (code < 1000)
		return (1 >= code - 40) ? 1 : 0;
	if (code == 1002)
		return (ULONG)str_author;
	if (code >= 1002)
		return (code == 1010) ? 1 : 0;
	return (ULONG)str_ver;				/* code == 1001 */
}

void mh_Dispatch(ULONG op, ULONG val, ULONG *obj)	/* -84 */
{
	ULONG tags[4];
	ULONG tag, v;
	if (!obj)
		return;
	if ((op & 0xffff) > 6)
		return;
	tag = 0x8000003f;
	v = val;
	if (v > 100)
		v = 100;
	switch (op & 0xffff) {
	case 0:
		break;					/* {3f, min} */
	case 1:
		tag = 0x8000003a;			/* {3a, min} */
		break;
	case 2:
	case 4:
		return;					/* no call */
	case 3:
		tag = 0x8000003c;
		v = (15 * v) / 50;
		break;
	case 5:
		tag = 0x8000003d;
		v = (15 * v) / 50;
		break;
	default:					/* case 6 */
		tag = 0x8000003b;
		v = (15 * v) / 50;
		break;
	}
	tags[0] = tag;
	tags[1] = v;
	tags[2] = 0;
	tags[3] = 0;
	pl_90(tags);
}
