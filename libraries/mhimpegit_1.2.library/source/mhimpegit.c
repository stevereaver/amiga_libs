/*
**	mhimpegit.c -- mhimpegit.library 1.2 (20.01.2017) by Thomas Wenzel
**
**	C reconstruction of the shipped two-hunk binary (2200 bytes).
**	Earlier sibling of mhimpegit 4.0: same prelude.library wrapper
**	architecture, but built non-AUTOINIT -- the packed RomTag lives in
**	the DATA hunk at +0x3c (flags 0, ver 1, type NT_LIBRARY, pri 0)
**	and rt_Init -> code+4 is a stub that calls MakeLibrary+AddLibrary
**	itself.  Globals (exec/dos/lib/prelude bases) are four longs in the
**	DATA hunk instead of a separate BSS hunk.
**
**	Vectors (register ABI: args in a0/d0/d1, obj in a3, lib in a6):
**	    -6  Open     -12 Close    -18 Expunge   -24 stub(0)
**	    -30 Create(tag0=a0,tag1=d0)     -> obj*
**	    -36 Destroy(obj=a3)
**	    -42 Append(v0=a0,v1=d0,obj=a3)  -> 1
**	    -48 Pop(obj=a3)                 -> node data0
**	    -54 Query(obj=a3)               -> !obj || !pl_flag
**	    -60 Iterate(obj=a3)             prelude@-60 per unmarked node
**	    -66 Drain(obj=a3)               prelude@-84/-36, Delay(35), free all
**	    -72 bare stub (stale d0)
**	    -78 Classify(code=d1)           -> bool / string ptr / stale residue
**	    -84 Dispatch(op=d0,val=d1,obj=a3)   prelude@-90 single tag
**
**	Obj layout:  {+0 tag0, +4 tag1, +8 count, +12 MinList*}  (16 bytes)
**	Node layout: {+0 succ, +4 pred, +8 d0, +12 d1, +16 flag.w} (18 bytes)
**
**	Defects preserved (see okf/findings/defects.md):
**	  - LibInit never checks the dos.library OpenLibrary result; a
**	    missing dos leaves a NULL base that Drain later calls through.
**	  - Create leaves prelude.library open on every failure path and
**	    stores it into the global slot before validating it.
**	  - Create does not check the 12-byte list AllocVec; on OOM the
**	    NewList helper dereferences NULL.
**	  - Destroy frees the object and nodes but never frees the 12-byte
**	    MinList block; Destroy(NULL) leaves prelude open.
**	  - Pop's gate compares the shared prelude counter against the
**	    object count; underflow of obj+8 is avoided but the check is
**	    `pending < count`, not a real availability test.
**	  - Classify falls through returning a stale subtraction residue
**	    (code - 1011) for unknown codes instead of 0.
**	  - Append never checks the node AllocVec result.
**	  - Dispatch bounds-checks only d0.w; high garbage is ignored.
*/

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef void          *APTR;

/* data-hunk globals (defined in mhimpegit_lib.s at shipped offsets) */
extern ULONG g_exec;		/* data+0x92 */
extern ULONG g_dos;		/* data+0x96 */
extern ULONG g_lib;		/* data+0x9a */
extern ULONG g_prelude;		/* data+0x114 */

extern ULONG g_functab[];	/* data+0x56 */
extern ULONG g_create_tmpl[];	/* data+0xac, 8 longs */
extern ULONG g_dispatch_tmpl[];	/* data+0x104, 4 longs */

extern const char g_name[];	/* data+0x00 */
extern const char g_idstr[];	/* data+0x12 */
extern const char g_doslib[];	/* data+0x9e */
extern const char g_prelib[];	/* data+0xcc */
extern const char g_mpegit[];	/* data+0xdc */
extern const char g_ver[];	/* data+0xe4 */
extern const char g_author[];	/* data+0xf6 */

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

static APTR mh_MakeLibrary(APTR vectab, APTR init, APTR initfn,
			   ULONG dsize, ULONG seg)
{
	register APTR a0 __asm("a0") = vectab;
	register APTR a1 __asm("a1") = init;
	register APTR a2 __asm("a2") = initfn;
	register ULONG d0 __asm("d0") = dsize;
	register ULONG d1 __asm("d1") = seg;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-84)"
			: "+r"(d0)
			: "r"(a0), "r"(a1), "r"(a2), "r"(d1), "r"(a6)
			: "memory","cc");
	return (APTR)d0;
}

static void mh_AddLibrary(APTR lib)
{
	register APTR a1 __asm("a1") = lib;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-396)" :: "r"(a1), "r"(a6)
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
	register APTR a6 __asm("a6") = (APTR)g_dos;
	__asm volatile ("jsr a6@(-198)" :: "r"(d1), "r"(a6)
			: "d0","a0","a1","memory");
}

/* prelude calls: a6 = prelude base, offsets -90/-60/-84/-36 */
static void pl_90(ULONG *tags)
{
	register ULONG *a0 __asm("a0") = tags;
	register APTR a6 __asm("a6") = (APTR)g_prelude;
	__asm volatile ("jsr a6@(-90)" :: "r"(a0), "r"(a6)
			: "d0","d1","d2","a1","memory","cc");
}

static void pl_60(ULONG v0, ULONG v1)
{
	register APTR a0 __asm("a0") = (APTR)v0;
	register ULONG d0 __asm("d0") = v1;
	register ULONG d1 __asm("d1") = 0x1008;
	register ULONG d2 __asm("d2") = 22050;
	register APTR a6 __asm("a6") = (APTR)g_prelude;
	__asm volatile ("jsr a6@(-60)" :: "r"(a0), "r"(d0), "r"(d1), "r"(d2), "r"(a6)
			: "a1","memory","cc");
}

static void pl_84_36(ULONG d0val)
{
	register ULONG d0 __asm("d0") = d0val;
	register APTR a6 __asm("a6") = (APTR)g_prelude;
	__asm volatile ("jsr a6@(-84)\n\tjsr a6@(-36)" :: "r"(d0), "r"(a6)
			: "d1","d2","a0","a1","memory","cc");
}

/* prelude internals (memory-indirect refs in the original) */
#define PL_CAPS(pb)	(*(UBYTE **)((UBYTE *)(pb) + 0x38) + 0x15)
#define PL_FLAGADDR(pb)	((ULONG *)(*(ULONG *)((UBYTE *)(pb) + 0x8e) + 0x10))
#define PL_FLAG(pb)	(*PL_FLAGADDR(pb))

/* ------------------------------------------------------------------ */
/* helpers							      */
/* ------------------------------------------------------------------ */

ULONG mh_expunge_body(ULONG lib);

void mh_newlist(ULONG *l)		/* helper @0x5c4/0x5c8 */
{
	l[1] = 0;			/* tail = 0 */
	l[2] = (ULONG)l;		/* tailpred = &head */
	l[0] = (ULONG)&l[1];		/* head = &tail */
}

/* ------------------------------------------------------------------ */
/* lifecycle							      */
/* ------------------------------------------------------------------ */

ULONG mh_boot(ULONG seglist, ULONG sysbase)	/* rt_Init body */
{
	ULONG *l;
	ULONG lib;

	g_exec = sysbase;
	g_dos = (ULONG)mh_OpenLibrary(g_doslib, 0);	/* unchecked */
	lib = (ULONG)mh_MakeLibrary(g_functab, 0, 0, 42, 0);
	g_lib = lib;
	if (!lib)
		return 0;
	l = (ULONG *)lib;
	((UBYTE *)l)[8] = 9;			/* ln_Type NT_LIBRARY */
	*(ULONG *)((UBYTE *)l + 10) = (ULONG)g_name;
	((UBYTE *)l)[14] = 6;			/* flags */
	((UWORD *)l)[10] = 1;			/* version */
	((UWORD *)l)[11] = 2;			/* revision */
	l[24/4] = (ULONG)g_idstr;
	*(ULONG *)((UBYTE *)l + 34) = seglist;
	*(ULONG *)((UBYTE *)l + 38) = sysbase;
	mh_AddLibrary((APTR)lib);
	return g_lib;
}

ULONG mh_open(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	((UWORD *)l)[16] += 1;			/* OpenCnt @+32 */
	l[14] &= ~8;
	return lib;
}

ULONG mh_close(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	ULONG r = 0;
	if (((UWORD *)l)[16] > 0) {
		((UWORD *)l)[16] -= 1;
		if (!((UWORD *)l)[16] && (l[14] & 8))
			r = mh_expunge_body(lib);
	}
	return r;
}

ULONG mh_expunge(ULONG lib)
{
	UBYTE *l = (UBYTE *)lib;
	if (((UWORD *)l)[16] > 0) {
		l[14] |= 8;
		return 0;
	}
	return mh_expunge_body(lib);
}

ULONG mh_expunge_body(ULONG lib)
{
	ULONG *l = (ULONG *)lib;
	ULONG seg = *(ULONG *)((UBYTE *)l + 34);
	ULONG neg, pos;
	mh_Remove(l);
	neg = ((UWORD *)l)[8];
	pos = ((UWORD *)l)[9];
	mh_FreeMem((APTR)(lib - neg), neg + pos);
	if (g_dos)
		mh_CloseLibrary((APTR)g_dos);
	g_dos = 0;
	return seg;
}

/* ------------------------------------------------------------------ */
/* public functions						      */
/* ------------------------------------------------------------------ */

ULONG mh_Create(ULONG arg0, ULONG arg1)		/* -30 */
{
	APTR pb;
	ULONG *obj;
	ULONG taglist[8];
	int i;

	pb = mh_OpenLibrary(g_prelib, 5);
	g_prelude = (ULONG)pb;
	if (!pb)
		return 0;
	if (((UWORD *)pb)[10] == 5 && ((UWORD *)pb)[11] < 2)	/* ver 5.x rev<2 */
		return 0;
	if (!(*PL_CAPS(pb) & 1))
		return 0;
	obj = (ULONG *)mh_AllocVec(16, 0x10000);	/* PUBLIC|CLEAR */
	if (!obj)
		return 0;
	obj[0] = arg0;
	obj[1] = arg1;
	obj[3] = (ULONG)mh_AllocVec(12, 0x10001);
	mh_newlist((ULONG *)obj[3]);		/* unchecked: NULL deref on OOM */
	for (i = 0; i < 8; i++)
		taglist[i] = g_create_tmpl[i];
	taglist[1] = obj[0];
	taglist[3] = obj[1];
	taglist[5] = 99;
	pl_90(taglist);
	PL_FLAG(pb) = 0;
	return (ULONG)obj;
}

void mh_Destroy(ULONG *obj)			/* -36 */
{
	APTR n;
	if (!obj)
		return;
	mh_CloseLibrary((APTR)g_prelude);
	while ((n = mh_RemHead((APTR)obj[3])) != 0)
		mh_FreeVec(n);
	mh_FreeVec(obj);
}

ULONG mh_Append(ULONG v0, ULONG v1, ULONG *obj)	/* -42 */
{
	ULONG *n;
	if (!obj)
		return v1 & 0xffff0000;		/* original: clrw on stale arg */
	n = (ULONG *)mh_AllocVec(18, 0x10001);	/* unchecked in original */
	n[8/4]  = v0;
	n[12/4] = v1;
	((UWORD *)n)[8] = 0;
	mh_AddTail((APTR)obj[3], n);
	obj[2] += 1;
	if (PL_FLAG((APTR)g_prelude)) {
		((UWORD *)n)[8] = 1;
		pl_60(v0, v1);
	}
	return 1;
}

ULONG mh_Pop(ULONG *obj)			/* -48 */
{
	ULONG *n;
	ULONG r = 0;
	if (!obj)
		return 0;
	if (PL_FLAG((APTR)g_prelude) >= obj[2])	/* unsigned BCC */
		return 0;
	n = (ULONG *)mh_RemHead((APTR)obj[3]);
	if (n) {
		r = n[8/4];
		mh_FreeVec(n);
	}
	if (obj[2])
		obj[2] -= 1;
	return r;
}

ULONG mh_Query(ULONG *obj)			/* -54 */
{
	if (!obj)
		return 1;
	return PL_FLAG((APTR)g_prelude) ? 0 : 1;
}

void mh_Iterate(ULONG *obj)			/* -60 */
{
	ULONG *n;
	if (!obj)
		return;
	n = (ULONG *)*(ULONG *)obj[3];		/* lh_Head */
	for (;;) {
		if (!((UWORD *)n)[8]) {
			pl_60(n[2], n[3]);
			((UWORD *)n)[8] = 1;
		}
		n = (ULONG *)n[0];
		if (!n[0])
			break;
	}
}

void mh_Drain(ULONG *obj)			/* -66 */
{
	APTR n;
	if (!obj)
		return;
	pl_84_36(128);
	mh_Delay(35);
	while ((n = mh_RemHead((APTR)obj[3])) != 0)
		mh_FreeVec(n);
	PL_FLAG((APTR)g_prelude) = 0;
	obj[2] = 0;
}

ULONG mh_Classify(ULONG code)			/* -78 */
{
	ULONG r = code;
	if (!(r -= 1))		return 1;	/* 1 */
	if (!(r -= 1))		return 1;	/* 2 */
	if (!(r -= 1))		return 1;	/* 3 */
	if (!(r -= 7))		return 1;	/* 10 */
	if (!(r -= 1))		return 1;	/* 11 */
	if (!(r -= 1))		return 1;	/* 12 */
	if (!(r -= 8))		return 1;	/* 20 */
	if (!(r -= 1))		return 1;	/* 21 */
	if (!(r -= 9))		return 1;	/* 30 */
	if (!(r -= 1))		return 1;	/* 31 */
	if (!(r -= 9))		return 1;	/* 40 */
	if (!(r -= 1))		return 1;	/* 41 */
	if (!(r -= 959))	return (ULONG)g_mpegit;	/* 1000 */
	if (!(r -= 1))		return (ULONG)g_ver;		/* 1001 */
	if (!(r -= 1))		return (ULONG)g_author;	/* 1002 */
	if (!(r -= 8))		return 1;			/* 1010 */
	return 0;	/* fall-through lands on a hidden moveq #0 */
}

void mh_Dispatch(ULONG op, ULONG val, ULONG *obj)	/* -84 */
{
	ULONG tags[4];
	ULONG v, i;

	for (i = 0; i < 4; i++)
		tags[i] = g_dispatch_tmpl[i];	/* {0x8000003f,0,0,0} */
	if (!obj)
		return;
	if ((op & 0xffff) >= 7)
		return;
	v = val;
	if (v > 100)
		v = 100;
	switch (op & 0xffff) {
	case 0:
		tags[1] = v;
		break;
	case 3:
		tags[0] = 0x8000003c;
		tags[1] = (v * 15) / 50;
		break;
	case 5:
		tags[0] = 0x8000003d;
		tags[1] = (v * 15) / 50;
		break;
	case 6:
		tags[0] = 0x8000003b;
		tags[1] = (v * 15) / 50;
		break;
	default:				/* ops 1,2,4: no call */
		return;
	}
	pl_90(tags);
}
