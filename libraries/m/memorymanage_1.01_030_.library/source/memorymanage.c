/*
 * memorymanage.c -- memorymanage.library 1.01 (c) 2000
 *
 * 68030 PMMU page-table library: mm_enable builds (or adopts) a
 * 3-level descriptor tree, mm_map re-describes ranges with per-page
 * flags, mm_saveregs/mm_loadregs stash/restore the whole MMU context,
 * and mm_vatophys translates via ptestr.
 *
 * Vectors:
 *   -30  mm_enable()              -> rootinfo / 0
 *   -36  mm_disable()             (releases tables when count hits 0)
 *   -42  mm_map(len,va,pa,flags)  -> a2 last table   [memorymanage_lib.s]
 *   -48  mm_mapid(len,va)         -> a2              [memorymanage_lib.s]
 *   -54  mm_saveregs(block)       store 30B MMU ctx via Supervisor
 *   -60  mm_loadregs(block)       load 28B MMU ctx + pflusha
 *   -66  mm_vatophys(va)          -> phys addr
 *
 * Descriptor tree (TC = 0x80c07760: 4KB pages, TIA/TIB/TIC/TID=7/7/6/0):
 *   root table    128 entries x 32MB, allocated 0x220 via AllocVec
 *   level-B table 128 entries x 256KB, ditto
 *   level-C table  64 entries x 4KB, allocated 0x120
 * each table block trails a freelist node {next, block, descaddr,
 * olddesc} so mm_disable can restore every parent descriptor before
 * FreeVec.
 *
 * Shipped quirks (all preserved, see okf/findings):
 *   - RT_ENDSKIP = 0 and a bogus RELOC32 fixup lands on hunk+0;
 *   - the TT0/TT1 "in use" tests check bit 7 of the mask byte and the
 *     TC test checks TIA's MSB -- the real enable bits are missed;
 *   - when the saved TC bit is set the library adopts the foreign root
 *     (base+38 = CRP & ~15) and registers no tables to free;
 *   - mm_disable does NOT restore the saved MMU state, it installs the
 *     canned LAB_0018 image (invalid CRP, TC E=0) and switches the MMU
 *     off entirely;
 *   - mm_map's un-initialised path jumps into the movem epilogue with
 *     no frame pushed (return through garbage), and its level-B
 *     descend-for-remainder branch targets the C fill loop instead of
 *     the descend code (wild descriptor writes -- see lib.s);
 *   - table allocs are tight: only 16 bytes of slack for alignment,
 *     an 8-mod-16 block would overflow the AllocVec.
 */

typedef long           LONG;
typedef unsigned long  ULONG;
typedef unsigned short UWORD;
typedef unsigned char  UBYTE;
typedef void          *APTR;

struct MMBase {
	APTR	succ;			/* +0  */
	APTR	pred;			/* +4  */
	UBYTE	type;			/* +8  */
	UBYTE	pri;			/* +9  */
	APTR	name;			/* +10 */
	UBYTE	flags;			/* +14 LIBF_DELEXP = bit3 */
	UBYTE	pad15;
	UWORD	negsize;		/* +16 */
	UWORD	possize;		/* +18 */
	UWORD	version;		/* +20 */
	UWORD	revision;		/* +22 */
	APTR	idstring;		/* +24 */
	ULONG	sum;			/* +28 */
	UWORD	opencnt;		/* +32 */
	APTR	seglist;		/* +34 */
	APTR	rootinfo;		/* +38 foreign root | own freelist node */
	APTR	freelist;		/* +42 chain of table nodes */
	UBYTE	saved[30];		/* +46 CRP,SRP,TT0,TT1,TC,PSR */
	UWORD	count;			/* +76 */
	UBYTE	foreign;		/* +78 0xff = adopted foreign MMU */
};					/* = 79 bytes (init dataSize 0x4f) */

/* from memorymanage_lib.s */
extern UBYTE mm_ctx_enable[];		/* 28B MMU-on image (CRP/SRP patched) */
extern UBYTE mm_ctx_disable[];		/* 28B MMU-off image */
extern void  mm_sup_load(void);		/* pmove block->regs + pflusha + rte */
extern void  mm_sup_save(void);		/* pmove regs->block + rte */
extern void  mm_sup_ptest(void);	/* ptestr #1,(a0),#7,a1 + rte */

/* ---- exec helpers: original reloads ExecBase for every call -------- */

static APTR ex_allocvec(ULONG sz, ULONG fl)
{
	register ULONG _s __asm("d0") = sz;
	register ULONG _f __asm("d1") = fl;
	__asm volatile("movem.l a6,-(sp)\n\t"
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-684)\n\t"		/* AllocVec */
		"movem.l (sp)+,a6"
		: "+d"(_s), "+d"(_f)
		:
		: "a0","a1","cc","memory");
	return (APTR)_s;
}

static void ex_freevec(APTR p)
{
	register APTR _p __asm("a1") = p;
	__asm volatile("movem.l a6,-(sp)\n\t"
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-690)\n\t"		/* FreeVec */
		"movem.l (sp)+,a6"
		: "+a"(_p)
		:
		: "d0","d1","a0","cc","memory");
}

static void ex_freemem(APTR p, ULONG sz)
{
	register APTR _p __asm("a1") = p;
	register ULONG _s __asm("d0") = sz;
	__asm volatile("movem.l a6,-(sp)\n\t"
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-210)\n\t"		/* FreeMem */
		"movem.l (sp)+,a6"
		: "+a"(_p), "+d"(_s)
		:
		: "d1","a0","cc","memory");
}

/* Forbid + Supervisor(code in a5, arg in a0) + Permit; returns a1.
 * Pushes a6 (libbase) and a0 (the arg) like the original wrappers. */
static APTR sup(void *code, APTR arg)
{
	register APTR _a __asm("a0") = arg;
	register APTR _c __asm("a5") = code;
	register APTR _r __asm("a1");
	__asm volatile(
		"movem.l a6/a0,-(sp)\n\t"
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-132)\n\t"		/* Forbid */
		"movem.l (sp),a0\n\t"
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-30)\n\t"		/* Supervisor(a5) */
		"movea.l 4.w,a6\n\t"
		"jsr a6@(-138)\n\t"		/* Permit */
		"movem.l (sp)+,a0/a6"
		: "=a"(_r), "+a"(_a), "+a"(_c)
		:
		: "d0","d1","cc","memory");
	return _r;
}

/* ---- lifecycle ---------------------------------------------------- */

/* initfunc(d0 = libbase, a0 = seglist) -- hunk 0x5e */
APTR mm_initfunc(APTR d0 __asm("d0"), APTR seg __asm("a0"))
{
	struct MMBase *b = (struct MMBase *)d0;
	b->freelist = 0;
	b->rootinfo = 0;
	b->count = 0;
	b->seglist = seg;
	b->foreign = 0;
	return b;
}

/* -6 Open -- hunk 0x82 */
APTR mm_open(struct MMBase *b __asm("a6"))
{
	b->flags &= ~8;
	if (++b->opencnt == 0)
		return (APTR)-1;		/* wraps: returns -1 */
	return b;
}

/* -12 Close -- hunk 0x94 */
APTR mm_close(struct MMBase *b __asm("a6"));

APTR mm_expunge(struct MMBase *b __asm("a6"));

APTR mm_close(struct MMBase *b __asm("a6"))
{
	if (b->opencnt == 0)
		return 0;
	--b->opencnt;
	if (b->flags & 8)
		return mm_expunge(b);
	return 0;
}

/* -18 Expunge -- hunk 0xaa */
APTR mm_expunge(struct MMBase *b __asm("a6"))
{
	struct MMBase *p, *s;
	APTR start;
	ULONG sz;
	b->flags |= 8;
	if (b->opencnt)
		return 0;
	p = (struct MMBase *)b->pred;
	s = (struct MMBase *)b->succ;
	s->pred = (APTR)p;
	p->succ = (APTR)s;
	start = (APTR)((UBYTE *)b - b->negsize);
	sz = (ULONG)b->negsize + b->possize;
	ex_freemem(start, sz);
	return b->seglist;
}

/* -24 reserved -- hunk 0xa6 */
APTR mm_reserved(void)
{
	return 0;
}

/* ---- API ------------------------------------------------------------ */

/* -30 mm_enable() -> rootinfo / 0 -- hunk 0xe8 */
APTR mm_enable(struct MMBase *b __asm("a6"))
{
	ULONG *root, *t, *node, d2;
	APTR blk;
	if (b->rootinfo)
		return b->rootinfo;
	sup(mm_sup_save, b->saved);		/* save current MMU ctx */
	if (b->saved[18] & 0x80)			/* TT0 mask MSB (not E!) */
		return 0;
	if (b->saved[22] & 0x80)			/* TT1 mask MSB */
		return 0;
	if (++b->count == 0)
		return 0;
	if (b->saved[26] & 0x80) {		/* "TC on": TIA MSB */
		b->foreign = 0xff;
		b->freelist = 0;
		b->rootinfo = (APTR)(*(ULONG *)(b->saved + 4) & ~15UL);
	} else {
		blk = ex_allocvec(0x220, 1);	/* MEMF_PUBLIC */
		if (!blk)
			return 0;
		root = (ULONG *)(((ULONG)blk + 8 + 7) & ~15UL);
		t = root;
		d2 = 0;
		do {				/* 128 identity early-term */
			ULONG e = d2 + 1;	/*    page descriptors */
			*t++ = e;
			d2 += 0x02000000;
		} while (d2);
		node = t;			/* node at table+512 */
		node[0] = 0;			/* next */
		b->freelist = node;
		b->rootinfo = node;
		node[1] = (ULONG)blk;		/* block for FreeVec */
		node[2] = 0;			/* descaddr */
		node[3] = 0;			/* olddesc */
		*(ULONG *)(mm_ctx_enable + 4)  = (ULONG)root;
		*(ULONG *)(mm_ctx_enable + 12) = (ULONG)root;
		sup(mm_sup_load, mm_ctx_enable); /* install MMU ctx */
	}
	return b->rootinfo;
}

/* -36 mm_disable() -- hunk 0x1ac */
void mm_disable(struct MMBase *b __asm("a6"))
{
	ULONG *n;
	if (--b->count != 0)
		return;
	if (b->freelist) {
		if (!b->foreign)
			sup(mm_sup_load, mm_ctx_disable); /* MMU off */
		for (n = b->freelist; n; n = (ULONG *)n[0]) {
			ULONG *da = (ULONG *)n[2];
			if (da)
				*da = n[3];	/* restore parent desc */
		}
		for (n = b->freelist; n; ) {
			ULONG *next = (ULONG *)n[0];
			ex_freevec((APTR)n[1]);
			n = next;
		}
		b->freelist = 0;
	}
	b->rootinfo = 0;
}

/* -54 mm_saveregs(a0 = 30B block) -- hunk 0x53c */
void mm_saveregs(APTR blk __asm("a0"), struct MMBase *b __asm("a6"))
{
	sup(mm_sup_save, blk);
}

/* -60 mm_loadregs(a0 = 28B block) -- hunk 0x214 */
void mm_loadregs(APTR blk __asm("a0"), struct MMBase *b __asm("a6"))
{
	sup(mm_sup_load, blk);
}

/* -66 mm_vatophys(a0 = va) -> phys addr -- hunk 0x4e4 */
ULONG mm_vatophys(ULONG d0 __asm("d0"), UBYTE *va __asm("a0"),
		 struct MMBase *b __asm("a6"))
{
	ULONG *dp;
	if (!b->rootinfo)
		return d0;			/* shipped: caller's d0 */
	dp = sup(mm_sup_ptest, va);
	return (*dp & ~0xfffUL) + ((ULONG)va & 0xfff);
}
