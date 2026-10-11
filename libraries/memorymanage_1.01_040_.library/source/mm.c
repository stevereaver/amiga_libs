/*
**	memorymanage.library 1.01 -- reconstructed implementation
**	"$VER:memorymanage 1.01 (c) 2000"
**
**	68040 MMU page-table manager.  Three-level table (128x32MB
**	root, 128x256KB mid, 64x4KB leaf), AllocVec'd on demand; each
**	table block carries a 16-byte trailer node {next,alloc,slotptr,
**	olddesc} feeding a free-list that Detach walks to un-patch and
**	release everything.
**
**	Transparent-translation registers are never used (both profiles
**	load 0x00ff4000 = disabled TTRs); if the MMU is already enabled
**	at attach the existing SRP table is adopted (active flag)
**	instead of building a new one.
**
**	Library base (dataSize 0x53):
**	  +34 seglist, +38 root node|adopted SRP, +42 freelist,
**	  +46 regionbuf, +50 saved MMU block (28B: URP,SRP,DTT0,DTT1,
**	  ITT0,ITT1,TC.w,MMUSR.w)  +80 refcount(w)  +82 own-config flag
**
**	Defects reproduced: OpenCnt wrap returns -1 via _start, refcount
**	leak on alloc failure, MMUMap/MMUDetach/Translate return the
**	pushed entry-d0 (leaf ptr stored to a2 is movm'd away), detach
**	"restore" writes the same patched profile it installed (both
**	blocks identical, and both get FreeVec's return at +4/+12 =
**	SRP/DTT1), partial tail page of a region is never mapped.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/memory.h>

struct MMBase {
	struct Library	 lib;		/* +0x00 (OpenCnt +0x20)    */
	APTR		 seglist;	/* +0x22		    */
	ULONG		*root;		/* +0x26 block node|SRP	    */
	ULONG		*freeblks;	/* +0x2a trailer node list  */
	ULONG		*regionbuf;	/* +0x2e extent scratch	    */
	ULONG		 saved[6];	/* +0x32 URP..ITT1 snapshot */
	USHORT		 saved_tc;	/* +0x4a TC		    */
	USHORT		 saved_mmusr;	/* +0x4c MMUSR		    */
	UWORD		 pad4e;		/* +0x4e		    */
	UWORD		 refcnt;	/* +0x50 attach count	    */
	UBYTE		 active;	/* +0x52 MMU already up	    */
};

/* Supervisor-mode bodies in mm_lib.s (privileged MOVEC/PTEST)	    */
void sv_loadregs(void);			/* a0 = 28B block to write   */
void sv_readregs(void);			/* a0 = 28B block to fill    */
void sv_ptest(void);			/* a0 = addr -> d0 = MMUSR   */

extern ULONG prof_att[];		/* LAB_001D: written at attach */
extern ULONG prof_det[];		/* LAB_001E: written at detach */

/* -------- exec (all sites reload SysBase via movea.l 4:w,a6) ------ */
static APTR allocvec(ULONG sz, ULONG fl)
{
	register ULONG __p_sz __asm("d0") = sz;
	register ULONG __p_fl __asm("d1") = fl;
	register APTR  __p_res __asm("d0");
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-684:W)\n"
		: "=r"(__p_res), "=a"(__p_sys), "+d"(__p_fl)
		: "d"(__p_sz)
		: "a0","a1","fp0","fp1","cc","memory");
	return __p_res;
}
static ULONG freevec(APTR p)
{
	register APTR __p_p __asm("a1") = p;
	register ULONG __p_res __asm("d0");
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-690:W)\n"
		: "=r"(__p_res), "=a"(__p_sys), "+a"(__p_p)
		:
		: "d1","a0","fp0","fp1","cc","memory");
	return __p_res;
}
static ULONG availmem(ULONG req)
{
	register ULONG __p_r __asm("d1") = req;
	register ULONG __p_res __asm("d0");
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-216:W)\n"
		: "=r"(__p_res), "=a"(__p_sys), "+d"(__p_r)
		:
		: "a0","a1","fp0","fp1","cc","memory");
	return __p_res;
}
static ULONG typeofmem(APTR p)
{
	register APTR __p_p __asm("a1") = p;
	register ULONG __p_res __asm("d0");
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-534:W)\n"
		: "=r"(__p_res), "=a"(__p_sys), "+a"(__p_p)
		:
		: "d1","a0","fp0","fp1","cc","memory");
	return __p_res;
}
static void remnode(APTR node)
{
	register APTR __p_n __asm("a1") = node;
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-252:W)\n"
		: "=a"(__p_sys), "+a"(__p_n)
		:
		: "d0","d1","a0","fp0","fp1","cc","memory");
}
static void freemem(APTR m, ULONG sz)
{
	register APTR __p_m __asm("a1") = m;
	register ULONG __p_s __asm("d0") = sz;
	register struct ExecBase *__p_sys __asm("a6");
	__asm volatile ("moveal 4:w,%/a6\n\tjsr %/a6@(-210:W)\n"
		: "=a"(__p_sys), "+a"(__p_m), "+d"(__p_s)
		:
		: "d1","a0","fp0","fp1","cc","memory");
}

/* forbid; a0 survives via the stack through Supervisor(thunk); permit.
** The thunk sees a0 = its argument (standard exec convention).	    */
#define SUPERVISED(thunk, arg)					\
	__asm volatile (					\
		"moveal 4:w,%/a6\n"				\
		"movel %0,%/sp@-\n"				\
		"jsr %%a6@(-132:W)\n"				\
		"moveml %%sp@,%%a0\n"				\
		"lea " #thunk "(%%pc),%%a5\n"			\
		"jsr %%a6@(-30:W)\n"				\
		"jsr %%a6@(-138:W)\n"				\
		"addql #4,%%sp\n"				\
		:: "a"(arg)					\
		: "d0","d1","a1","a6","fp0","fp1","cc","memory")

/* -------- LibInit (datatab is NULL) ------------------------------ */
struct MMBase * LibInit(struct MMBase *b __asm("d0"),
			APTR seglist __asm("a0"))
{
	b->freeblks = NULL;
	b->root     = NULL;
	b->refcnt   = 0;
	b->seglist  = seglist;
	b->active   = 0;
	return b;
}

/* -------- -6 LibOpen --------------------------------------------- */
struct MMBase * LibOpen(struct MMBase *b __asm("a6"))
{
	b->lib.lib_Flags &= ~LIBF_DELEXP;
	if (!++b->lib.lib_OpenCnt)
		return (struct MMBase *)-1L; /* _start's moveq #-1 */
	return b;
}

APTR LibExpunge(struct MMBase *b __asm("a6"));

/* -------- -12 LibClose ------------------------------------------- */
LONG LibClose(struct MMBase *b __asm("a6"))
{
	if (!b->lib.lib_OpenCnt)
		return 0;
	if (!--b->lib.lib_OpenCnt && (b->lib.lib_Flags & LIBF_DELEXP))
		return (LONG)LibExpunge(b);
	return 0;
}

/* -------- -18 LibExpunge ----------------------------------------- */
APTR LibExpunge(struct MMBase *b __asm("a6"))
{
	APTR seg;

	b->lib.lib_Flags |= LIBF_DELEXP;
	if (b->lib.lib_OpenCnt)
		return NULL;
	remnode(b);
	seg = b->seglist;
	freemem((UBYTE *)b - b->lib.lib_NegSize,
		b->lib.lib_NegSize + b->lib.lib_PosSize);
	return seg;
}

/* -------- -24 reserved ------------------------------------------- */
LONG LibNull(struct MMBase *b __asm("a6"))
{
	return 0;
}

/* -------- -54 MMUReadRegs (LIBFUNC_4) ---------------------------- */
/* a0 -> 28-byte block: URP,SRP,DTT0,DTT1,ITT0,ITT1,TC.w,MMUSR.w	    */
void MMUReadRegs(ULONG *blk __asm("a0"))
{
	SUPERVISED(_sv_readregs, blk);
}
/* -------- -60 MMUWriteRegs (LIBFUNC_5) --------------------------- */
/* a0 -> block; installs all registers + PFLUSHA			    */
void MMUWriteRegs(ULONG *blk __asm("a0"))
{
	SUPERVISED(_sv_loadregs, blk);
}
/* -------- -66 MMUTranslate (LIBFUNC_6) --------------------------- */
ULONG MMUTranslate(ULONG vaddr __asm("a0"), struct MMBase *b __asm("a6"))
{
	ULONG phys;

	if (!b->root) {
		__asm volatile ("movel %%d0,%0" : "=r"(phys));
		return phys;		/* d0 garbage: a0 param      */
	}
	__asm volatile (
		"moveal 4:w,%/a6\n"
		"movel %1,%/sp@-\n"
		"jsr %%a6@(-132:W)\n"
		"moveml %%sp@,%%a0\n"
		"lea _sv_ptest(%%pc),%%a5\n"
		"jsr %%a6@(-30:W)\n"
		"jsr %%a6@(-138:W)\n"
		"addql #4,%%sp\n"
		: "=d"(phys)
		: "a"(vaddr)
		: "d1","a1","a6","fp0","fp1","cc","memory");
	return (phys & ~0xfffUL) | (vaddr & 0xfff);
}

/* -------- extent walker (LAB_0011) ------------------------------- */
/* TypeOfMem() probe in 256KB steps; returns the 512KB-aligned extent
** {*start,*len} containing memory matching 'mask' and advances *pp.   */
static void next_extent(APTR *pp, ULONG mask, ULONG *start, ULONG *len)
{
	register UBYTE *p = *pp;

	do
		p += 0x40000;
	while (!(typeofmem(p) & mask));
	*start = (ULONG)p & 0xfff80000;
	do
		p += 0x40000;
	while (typeofmem(p) & mask);
	*pp = p;
	*len = ((ULONG)p & 0xfff80000) - *start;
}

ULONG MMUMap(ULONG vaddr __asm("a0"), ULONG paddr __asm("a1"),
	     ULONG len __asm("d0"), ULONG flags __asm("d1"),
	     struct MMBase *b __asm("a6"));

/* -------- -48 MMUMapIdentity (LIBFUNC_3) ------------------------- */
ULONG MMUMapIdentity(ULONG addr __asm("a0"), ULONG len __asm("d0"),
		     struct MMBase *b __asm("a6"))
{
	return MMUMap(addr, addr, len, 0, b);
}

/* -------- -30 MMUAttach (LIBFUNC_0) ------------------------------ */
ULONG MMUAttach(struct MMBase *b __asm("a6"))
{
	ULONG *rg, *tab, avail, patch;
	APTR scan;
	ULONG i;

	if (b->root)
		goto out;
	MMUReadRegs(b->saved);
	if ((b->saved[2] | b->saved[3] | b->saved[4] | b->saved[5])
	    & 0x8000)
		return 0;		/* a TTR is already enabled    */
	if (!++b->refcnt)
		return 0;
	if (b->saved_tc & 0x8000) {	/* MMU already enabled	    */
		b->active = ~0;		/* adopt the live SRP table  */
		b->freeblks = NULL;
		b->root = (ULONG *)(b->saved[1] & ~0x1ffUL);
		goto out;
	}
	rg = allocvec(0x100, MEMF_PUBLIC | MEMF_CLEAR);
	b->regionbuf = rg;
	if (!rg)
		return 0;		/* refcnt stays bumped -- leak */
	avail = availmem(0x00080004);	/* MEMF_KICK|MEMF_FAST       */
	scan = NULL;
	for (;;) {
		ULONG s, l;
		next_extent(&scan, 4 /*MEMF_FAST*/, &s, &l);
		rg[0] = s;
		rg[1] = l;
		rg += 2;
		if ((LONG)(avail -= l) <= 0)
			break;
	}
	tab = allocvec(0x410, MEMF_PUBLIC | MEMF_CLEAR);
	if (!tab)
		return 0;
	{
		ULONG *node, v = 0;
		ULONG *rt = (ULONG *)(((ULONG)tab + 0x1ff) & ~0x1ffUL);
		for (i = 0; i < 128; i++, v += 0x02000000)
			rt[i] = v;
		node = rt + 128;	/* trailer at table+0x200    */
		node[0] = v;		/* wraps to 0		    */
		b->freeblks = node;
		b->root = node;		/* +38 = node, NOT the table */
		node[1] = (ULONG)tab;
		node[2] = node[3] = 0;
	}
	MMUMapIdentity(0, 0x01000000, b);		/* first 16MB	    */
	for (rg = b->regionbuf; rg[1]; rg += 2)
		if (rg[0] >= 0x01000000)
			MMUMapIdentity(rg[0], rg[1], b);
	patch = freevec(b->regionbuf);
	prof_att[1] = prof_att[3] = patch;	/* SRP + DTT1 slots  */
	prof_det[1] = prof_det[3] = patch;
	MMUWriteRegs(prof_att);
out:
	return (ULONG)b->root;
}

/* -------- -36 MMUDetach (LIBFUNC_1) ------------------------------ */
void MMUDetach(struct MMBase *b __asm("a6"))
{
	ULONG *n;

	if (--b->refcnt)
		return;
	if (b->freeblks) {
		if (!b->active)
			MMUWriteRegs(prof_det);
		for (n = b->freeblks; n; n = (ULONG *)n[0]) {
			ULONG *slot = (ULONG *)n[2];
			if (slot)
				*slot = n[3];	/* un-patch desc */
		}
		for (n = b->freeblks; n; n = (ULONG *)n[0])
			freevec((APTR)n[1]);
		b->freeblks = NULL;
	}
	b->root = NULL;
}

/* -------- -42 MMUMap (LIBFUNC_2) --------------------------------- */
/* d0=len a0=vaddr a1=paddr d1=flags.  Walk/alloc the 3-level table
** and emit 4KB page descriptors.  The original returns the entry d0
** (len) -- the leaf ptr it computes lands in a2 which the movm
** restores; reproduced by returning len.				    */
ULONG MMUMap(ULONG vaddr __asm("a0"), ULONG paddr __asm("a1"),
	     ULONG len __asm("d0"), ULONG flags __asm("d1"),
	     struct MMBase *b __asm("a6"))
{
	ULONG *root, *mid, *leaf, *blk, desc, ret = len;
	ULONG i1, i2, i3;

	if (!b->root)
		return ret;
	desc = (paddr & ~0xfffUL)
	     | ((flags << 5) & 0x40)
	     | ((flags << 4) & 0x20)
	     | (flags & 4)
	     | (~flags & 1);
	root = b->root;
	if (!b->active)
		root = (ULONG *)((root[1] + 0x1ff) & ~0x1ffUL);

	for (;;) {
		i1 = (vaddr >> 25) & 0x7f;		/* rol7  */
		if (!(root[i1] & 2)) {
			ULONG d4, *node;
			blk = allocvec(0x410, MEMF_PUBLIC | MEMF_CLEAR);
			if (!blk)
				return ret;
			mid = (ULONG *)(((ULONG)blk + 0x1ff) & ~0x1ffUL);
			d4 = root[i1] & 0xfffc0000;
			for (i2 = 0; i2 < 128; i2++, d4 += 0x40000)
				mid[i2] = d4;
			node = mid + 128;
			node[0] = (ULONG)b->freeblks;
			b->freeblks = node;
			node[1] = (ULONG)blk;
			node[2] = (ULONG)&root[i1];
			node[3] = root[i1];
			root[i1] = (ULONG)mid + 2;	/* DT=2 table  */
		} else
			mid = (ULONG *)(root[i1] & ~0x1ffUL);

		i2 = (vaddr >> 18) & 0x7f;		/* rol14 */
		if (!(mid[i2] & 2)) {
			ULONG d4, *node;
			blk = allocvec(0x210, MEMF_PUBLIC | MEMF_CLEAR);
			if (!blk)
				return ret;
			leaf = (ULONG *)(((ULONG)blk + 0xff) & ~0xffUL);
			d4 = mid[i2] & 0xfffff000;
			for (i3 = 0; i3 < 64; i3++, d4 += 0x1000)
				leaf[i3] = d4;
			node = leaf + 64;
			node[0] = (ULONG)b->freeblks;
			b->freeblks = node;
			node[1] = (ULONG)blk;
			node[2] = (ULONG)&mid[i2];
			node[3] = mid[i2];
			mid[i2] = (ULONG)leaf + 2;
		} else
			leaf = (ULONG *)(mid[i2] & ~0x1ffUL);

		i3 = (vaddr >> 12) & 0x3f;		/* ror12 */
		while (len >= 0x1000) {
			leaf[i3] = desc;
			desc  += 0x1000;
			vaddr += 0x1000;
			len   -= 0x1000;
			if (!len)
				return ret;
			if (++i3 >= 64)
				break;		/* re-walk 256KB  */
		}
		if (len < 0x1000)
			return ret;			/* tail unmapped */
	}
}
