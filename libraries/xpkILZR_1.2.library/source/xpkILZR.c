/*
**	xpkILZR.c -- xpkILZR.library 1.2 "Incremental LZ-Renau"
**
**	C reconstruction of the shipped binary (idstring "xpkILZR
**	v1.3" / $VER: xpkILZR.library 1.2 (Feb 19 1994) Jose Renau).
**	XPK sublibrary: hash-chain LZSS with an MSB-first bit
**	stream:
**
**	    stream = <inlen:u16>{ token }*
**	    token  = 1 + byte			literal  (9 bits)
**	    token  = 0 + pos(w bits) + (len-3)(4)	match  (5+w bits)
**
**	`pos` is an ABSOLUTE input/output index (out==in position,
**	emission is aligned with scanning).  w starts at 8 and grows
**	whenever the cursor passes base+2^w (pack: input cursor;
**	unpack: output cursor).
**
**	Unlike the later 1.5 rebuild this library makes a PRIVATE
**	COPY of itself on every Open (allocates 0x114+0x3c bytes,
**	copies [base-0x3c, base+0xfc) -- vectors, header and the
**	descriptor block -- and returns the copy).  base+0x32 is a
**	back-pointer to the master, +0x36 = 0x3c (copy bias), +0x2e
**	a fixup-offsets list pointer that is ALWAYS 0 (dead code).
**	LibInit copies a 192-byte block (idstring + XpkInfo + mode
**	record) from the hunk into base+0x3c; xi_ModeDesc is stored
**	as a block-relative offset (0x38) that the dead fixup loop
**	in Open was meant to relocate -- it stays 0x38.
**
**	Workmem comes from a pool sub-allocator (LAB_0069): fresh
**	AllocMem of max(req,minsize)+20 per call, blocks linked onto
**	a freelist at base+0x110 (append-only, never consumed or
**	freed), chunk markers scribbled inside, returns block+20.
**	    xsp_Sub[0] = chain (0x8024 request -> word-indexed by pos)
**	    xsp_Sub[1] = head[0x8000] words (0x10000 request)
**
**	Shipped behaviour kept:
**	  - chain[] is NEVER cleared (uninitialised AllocMem) --
**	    garbage candidates are filtered by the d3<=d4 ordering
**	    check and the 18-failure budget, but garbage links still
**	    reach the precheck and can source phantom matches.
**	  - XpksPackFree merely zeroes xsp_Sub[0..1] -- BOTH blocks
**	    leak (and stay linked on the freelist).
**	  - XpksPackReset clears only head[]; stale chains remain.
**	  - runcap tail budget: the packer pre-scans to the input
**	    end (cap 19); once the scan pointer trips, each inserted
**	    position decrements the budget.  Arithmetic lands the
**	    stop exactly at consumed == InLen -- every byte is
**	    packed, and the budget doubles as a match-length clamp
**	    (best <= remaining) so no token reaches past the end.
**	    Mid-stream the budget sits at 17, so emitted matches
**	    are capped at length 17 (the finder can find 18 but the
**	    emit clamp reduces it -- the len-3 field only ever
**	    carries 0..14).
**	  - hash seed reads in[1]/in[2] whenever runcap>1 -- OOB
**	    for InLen <= 2 (in[1] also for InLen == 1).
**	  - precheck/cmpm reads run up to ~25 bytes past InLen.
**	  - the decoder bounds-checks the header word against
**	    xsp_OutBufLen (-10) and then WRITES the declared length
**	    into xsp_OutBufLen (+0x0c); no production bound.
**	  - suballoc fields live at base+0x108..0x110 -- zeroed by
**	    InitStruct's null-datatab clear, never written by init.
*/

#ifdef HOST_TEST
typedef short		 SHORT;
typedef signed char	 BYTE;
typedef unsigned char	 UBYTE;
typedef unsigned short	 UWORD;
typedef short		 WORD;
typedef unsigned int	 ULONG;	/* 32-bit on m68k AND host */
typedef int		 LONG;
typedef void		*APTR;
typedef ULONG		 BPTR;
typedef char		*STRPTR;
#define NT_LIBRARY	9
#ifndef NULL
#define NULL ((void *)0)
#endif
#define LIBF_DELEXP	0x08
#else
#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */
#endif

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c out buf size; decoder rewrites it */
    ULONG xsp_OutLen;		/* 0x10 pack: bytes produced		   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18					   */
    ULONG xsp_Mode;		/* 0x1c (unused -- single mode)	   */
    STRPTR xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    APTR  xsp_Arg[3];		/* 0x28					   */
    APTR  xsp_Sub[4];		/* 0x34 sublib private data		   */
};

#ifdef HOST_TEST
struct Node {
    struct Node *ln_Succ, *ln_Pred;
    UBYTE ln_Type;
    BYTE  ln_Pri;
    char *ln_Name;
    ULONG ln_pad[3];		/* pad to lib+20			    */
};
struct Library {
    struct Node	 lib_Node;	/* +0..+13			   */
    UBYTE	 lib_Flags;	/* +14				   */
    UBYTE	 lib_Version;	/* +15				   */
    UWORD	 lib_NegSize;	/* +16				   */
    UWORD	 lib_PosSize;	/* +18				   */
    ULONG	 lib_pad20[2];	/* +20..+27 (version/rev, idstr)   */
    ULONG	 lib_Revision;	/* -- placeholder name		   */
    UWORD	 lib_OpenCnt;	/* +32				   */
    ULONG	 lib_pad34;
};
#define lib_IdString lib_pad20[1]
#endif

struct IlzrBase			/* InitTable dataSize = 0x114	   */
{
    struct Library ib_Lib;	/* 0x00 standard library node	   */
    BPTR  ib_SegList;		/* 0x22 seglist, stored by LibInit   */
    ULONG ib_pad26[2];		/* 0x26				   */
    ULONG ib_RelocList;		/* 0x2e fixup offsets (always 0)	   */
    APTR  ib_Master;		/* 0x32 master back-pointer	   */
    ULONG ib_BaseOff;		/* 0x36 = 0x3c			   */
    UBYTE ib_DescBlk[192];	/* 0x3c copy of hunk descblock	   */
    ULONG ib_padFC[3];		/* 0xfc				   */
    ULONG ioerr;		/* 0x108 suballoc error code	   */
    ULONG memflags;		/* 0x10c suballoc flags (0)	   */
    ULONG freelist;		/* 0x110 suballoc block list	   */
};				/* = 0x114			   */

/* descriptor block emitted by xpkILZR_lib.s (copied to base+0x3c) */
extern const char descblock[];   /* asm: _descblock */
#ifdef HOST_TEST
char _descblock[192];		/* stubs -- real block lives in the .s */
const char _libname_s[16], _idstr_s[16];
#define libname _libname_s
#define idstr _idstr_s
#define descblock _descblock
APTR host_AllocMem(ULONG, ULONG);
void  host_FreeMem(APTR, ULONG);
void  host_Remove(APTR);
#define ASMREG(x)
#else
#define ASMREG(x)	__asm(x)
#endif

/* ------------------------------------------------------------------ */
/* Exec LVO calls (via absolute SysBase at 4.W, as the original does) */
/* ------------------------------------------------------------------ */

#ifndef HOST_TEST
#define SYSBASE	(*(struct ExecBase **)4)

static APTR __AllocMem(ULONG __size, ULONG ___flags)
{
  register void * __p_sys ASMREG("a6") = SYSBASE;
  register ULONG __p_size ASMREG("d0") = (ULONG)(__size);
  register ULONG __p_flags ASMREG("d1") = (ULONG)(___flags);
  register APTR __p_res ASMREG("d0");
  __asm volatile ("jsr %/a6@(-198:W)\n"
		   : "=r"(__p_res)
		   : "d"(__p_size), "d"(__p_flags), "a"(__p_sys)
		   : "cc", "memory", "a0", "a1" );
  return __p_res;
}

static void __FreeMem(APTR __blk, ULONG ___size)
{
  register void * __p_sys ASMREG("a6") = SYSBASE;
  register APTR __p_blk ASMREG("a1") = (APTR)(__blk);
  register ULONG __p_size ASMREG("d0") = (ULONG)(___size);
  __asm volatile ("jsr %/a6@(-210:W)\n"
		   : /* no outputs */
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)
		   : "cc", "memory", "d1", "a0" );
}

static void __Remove(void *__sys, void *__node)
{
  register void * __p_sys ASMREG("a6") = __sys;
  register void * __p_node ASMREG("a1") = __node;
  __asm volatile (
		   "jsr %/a6@(-252:W)\n"
		   : /* no outputs */
		   : "a"(__p_node), "a"(__p_sys)
		   : "cc", "memory", "d0", "d1", "a0" );
}

static void __CacheClearU(void)
{
  register void * __p_sys ASMREG("a6") = SYSBASE;
  __asm volatile (
		   "jsr %/a6@(-636:W)\n"
		   : /* no outputs */
		   : "a"(__p_sys)
		   : "cc", "memory", "d0", "d1", "a0", "a1" );
}
#else
static APTR __AllocMem(ULONG s, ULONG f) { return host_AllocMem(s, f); }
static void __FreeMem(APTR p, ULONG s)   { host_FreeMem(p, s); }
static void __Remove(void *s, void *n)   { (void)s; host_Remove(n); }
static void __CacheClearU(void)	     {}
#define SYSBASE 0
#endif

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

BPTR LibExpunge(struct IlzrBase *base ASMREG("a6"));	/* fwd decl */

/*
** LibInit (0x1b2): manual init -- there is no InitStruct datatab.
** Stores the seglist, sets ln_Type/ln_Name/flags=6/version 1.2/
** idstring, copies the 192-byte descriptor block from the hunk
** into base+0x3c, and stashes +0x2e=0 (dead fixup list),
** +0x32=base (self), +0x36=0x3c.  Returns the base.
*/
extern const char libname[], idstr[]; /* asm: _libname/_idstr */

struct Library *LibInit(struct IlzrBase *base ASMREG("d0"),
			BPTR seglist ASMREG("a0"))
{
    int i;
    base->ib_SegList = seglist;
    base->ib_Lib.lib_Node.ln_Type = NT_LIBRARY;
    base->ib_Lib.lib_Node.ln_Name = (char *)libname;
    base->ib_Lib.lib_Flags = 6;
    base->ib_Lib.lib_Version = 1;
    base->ib_Lib.lib_Revision = 2;
    base->ib_Lib.lib_IdString = (char *)idstr;
    for (i = 0; i < 192; i++)
	base->ib_DescBlk[i] = descblock[i];
    base->ib_RelocList = 0;
    base->ib_Master = base;
    base->ib_BaseOff = 0x3c;
    return (struct Library *)base;
}

/*
** LibOpen: PRIVATE-COPY open.  Allocates 0x114+0x3c (MEMF_CLEAR|
** MEMF_PUBLIC = 0x10001), copies [base-0x3c, base+0xfc) (vectors +
** node + descriptor block), and returns the copy's base.  The
** copy's +0x32 still holds the master pointer -> back-pointer.
** +0x2e on the copy is cleared; the master fixup walk (LAB_0024)
** never runs because master+0x2e is always 0 -- reproduced as-is.
** CacheClearU runs after the copy (vectors count as new code).
*/
struct Library *LibOpen(struct IlzrBase *base ASMREG("a6"))
{
    struct IlzrBase *master, *nb;
    ULONG i;

    base->ib_Lib.lib_OpenCnt++;
    base->ib_Lib.lib_Flags &= ~(1 << 3);	/* bclr #3 = LIBF_DELEXP */

    master = (struct IlzrBase *)base->ib_Master;
    nb = (struct IlzrBase *)__AllocMem(0x114 + master->ib_BaseOff,
				       0x10001 /* MEMF_CLEAR|PUBLIC */);
    if (!nb) {
	master->ib_Lib.lib_OpenCnt--;
	return NULL;
    }
    {
	const UBYTE *src = (const UBYTE *)base - master->ib_BaseOff;
	UBYTE *dst = (UBYTE *)nb;
	for (i = 0; i < 0xfc + master->ib_BaseOff; i++)
	    *dst++ = *src++;
    }
    nb = (struct IlzrBase *)((UBYTE *)nb + master->ib_BaseOff);
    nb->ib_RelocList = 0;

    /* dead fixup: rebase copy-relative offsets (never runs) */
    {
	ULONG *rl = (ULONG *)master->ib_RelocList;
	if (rl) {
	    ULONG *lp = rl + 1;
	    LONG   cnt = (LONG)*rl;
	    UBYTE *cb = (UBYTE *)nb + master->ib_BaseOff;
	    while (cnt-- > 0) {
		ULONG *f = (ULONG *)(cb + *lp++);
		*f += (ULONG)cb;
	    }
	}
    }
    __CacheClearU();
    return (struct Library *)nb;
}

/*
** LibClose: frees the private copy (FreeMem(copy-0x3c, 0x150)),
** then decrements the (resolved master) open count; DELEXP at
** count 0 expunges.  Quirk: Open on a copy bumps the COPY count
** but Close of the resulting grandchild still decrements the
** master -> count drift (shipped).
*/
LONG LibClose(struct IlzrBase *base ASMREG("a6"))
{
    struct IlzrBase *master = (struct IlzrBase *)base->ib_Master;
    struct IlzrBase *b = base;
    BPTR seg = 0;

    if (master != base) {
	__FreeMem((UBYTE *)base - master->ib_BaseOff,
		  0xd8 + master->ib_BaseOff + 60);	/* =0x150 */
	b = master;
    }
    if (--b->ib_Lib.lib_OpenCnt == 0) {
	if (b->ib_Lib.lib_Flags & (1 << 3))
	    seg = LibExpunge(b);
    }
    return (LONG)seg;
}

/*
** LibExpunge: resolves to the MASTER via +0x32 (works when called
** on a copy too), sets DELEXP on it; at open count 0 does
** Remove + FreeMem(base - NegSize, NegSize+PosSize).
*/
BPTR LibExpunge(struct IlzrBase *base ASMREG("a6"))
{
    struct IlzrBase *m = (struct IlzrBase *)base->ib_Master;
    BPTR seg = 0;

    m->ib_Lib.lib_Flags |= (1 << 3);	/* bset #3 = LIBF_DELEXP */
    if (m->ib_Lib.lib_OpenCnt == 0) {
	seg = m->ib_SegList;
	__Remove(SYSBASE, &m->ib_Lib.lib_Node);
	__FreeMem((UBYTE *)m - m->ib_Lib.lib_NegSize,
		  (ULONG)m->ib_Lib.lib_NegSize + m->ib_Lib.lib_PosSize);
    }
    return seg;
}

/* the entry stub's moveq #0,d0/rts serves LVO -24 via a BACKWARD
 * word offset; -60 is a bare `rts` in xpkILZR_lib.s (d0 undefined) */

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/*
** XpksPackerInfo (LVO -30): lea 158(a6) -- the XpkInfo INSIDE the
** per-library copied block (base+0x3c + 0x62 = base+0x9e).
*/
APTR XpksPackerInfo(struct IlzrBase *base ASMREG("a6"))
{
    return (APTR)((UBYTE *)base + 0x9e);
}

/*
** pool sub-allocator (LAB_0069): always a fresh AllocMem of
** max(req,minsize)+20 -- minsize = base+0xf8 (0), flags =
** base+0x10c (0).  The block is linked onto the freelist at
** base+0x110 (append-only -- nothing ever walks or frees it) and
** chunk descriptors are scribbled inside it:
**   [0]=next [4]=size [8]=slack-4 or 0 [12]=0x8000|[14]=size>>2
**   and, when slack>4, a trailer at block+16+req.
** Returns block+16; on failure ioerr=12 (base+0x108), ret 0.
*/
static UBYTE *suballoc(ULONG req, struct IlzrBase *base)
{
    ULONG *blk, *a1;
    ULONG  actual, slack;
    UWORD *a0;

    if (!req) {
	base->ioerr = 22;
	return NULL;
    }
    req = (req + 3) & ~3UL;
    actual = req;
    {
	ULONG m = *(ULONG *)((UBYTE *)base + 0xf8);
	if ((LONG)actual < (LONG)m)
	    actual = m;
    }
    blk = (ULONG *)__AllocMem(actual + 20, base->memflags);
    if (!blk) {
	base->ioerr = 12;
	return NULL;
    }
    a1 = blk;
    *a1++ = base->freelist;		/* blk[0] = next	  */
    base->freelist = (ULONG)blk;
    *a1++ = actual;			/* blk[1] = size	  */
    a1[1] = base->memflags;		/* blk[3] = flags	  */
    slack = actual - req;
    a0 = (UWORD *)(blk + 4);		/* a0 = block+16	  */
    if (slack && slack != 4) {
	slack -= 4;
	*a1 = slack;			/* blk[2] = slack-4	  */
	*a0++ = 0x8000;			/* [+16].w: chunk marker  */
	{
	    UWORD *t = (UWORD *)((UBYTE *)a0 + 2 + req); /* blk+20+req */
	    ULONG rq = req >> 2, sl = slack >> 2;
	    *a0++ = (UWORD)rq;		/* [+18].w: req words	  */
	    sl |= 0x8000;
	    *t++ = (UWORD)rq;		/* trailer: size words	  */
	    *t = (UWORD)sl;		/* trailer: slack|0x8000  */
	}
    } else {
	*a0++ = 0x8000;			/* [+16].w		  */
	*a1 = 0;			/* blk[2] = 0		  */
	*a0++ = (UWORD)((actual >> 2) | 0x8000);	/* [+18].w	  */
    }
    return (UBYTE *)a0;			/* block+20		  */
}

/*
** XpksPackFree (LVO -42): `clr.l 52(a0); clr.l 56(a0)` -- drops the
** workmem pointers WITHOUT freeing the blocks.  Both allocations
** (and their freelist links) leak.  Shipped as-is.
*/
LONG XpksPackFree(struct XpkSubParams *p ASMREG("a0"),
		  struct IlzrBase *base ASMREG("a6"))
{
    p->xsp_Sub[0] = 0;
    p->xsp_Sub[1] = 0;
    return 0;
}

/*
** XpksPackReset (LVO -48): clears the 64KB head[] table
** (xsp_Sub[1]) byte-wise, 65536 iterations.  The chain table is
** never cleared.
*/
LONG XpksPackReset(struct XpkSubParams *p ASMREG("a0"),
		   struct IlzrBase *base ASMREG("a6"))
{
    UBYTE *h = (UBYTE *)p->xsp_Sub[1];
    ULONG  i;

    if (!h)
	return 0;
    for (i = 0; i < 0x10000; i++)
	h[i] = 0;
    return 0;
}

/*
** XpksPackChunk (LVO -36)
**
**	  Register machine decoded from the binary:
**	  a2 = input cursor, a4 = InBuf, a5 = output bit-byte
**	  cursor (one MSB-first stream), a6 = chain table,
**	  d4 = candidate pos, d5 = bit mask, d6 = failure budget,
**	  d7 = position width, head[]/chain[] keyed by absolute
**	  position.
**
**	  `runcap` (75(sp)) is the tail budget: initialised to
**	  (scancount-2) where scancount counts positions to the
**	  input end capped at 19; once the end-scan trips, every
**	  inserted position decrements it.  Packing stops at 0 --
**	  so for InLen >= 19 the last byte is never emitted.
*/
LONG XpksPackChunk(struct XpkSubParams *p ASMREG("a0"),
		   struct IlzrBase *base ASMREG("a6"))
{
    const UBYTE *in = (const UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    UBYTE *w = out;			/* a5: flag-byte cursor   */
    UBYTE *outend = out + p->xsp_OutBufLen;
    const UBYTE *inend = in + p->xsp_InLen;
    const UBYTE *a2 = in;		/* input cursor	   */
    const UBYTE *scan = in;		/* 100(sp) end-scan pos   */
    UWORD *head, *chn;
    ULONG  hash = 0;			/* 84(sp) rolling hash	   */
    ULONG  d5 = 0x80;			/* bit mask		   */
    ULONG  wdt = 8;			/* d7: pos width	   */
    const UBYTE *wlmt = in + 256;	/* a0 = in + (1<<wdt)	   */
    LONG   runcap;			/* 75(sp)		   */
    LONG   best = 0, bpos = 0;		/* d2, 96(sp)		   */
    UWORD  cand = 0;			/* d4: last old-head	   */
    int    atend = 0;			/* 87(sp)		   */
    LONG   i;

    /* --- workmem: first call only (Sub[0] is the flag) --- */
    if (!p->xsp_Sub[0]) {
	UBYTE *b1 = suballoc(0x10000, base);	/* head	 */
	UBYTE *b0;
	if (!b1)
	    return -7;
	b0 = suballoc(0x8024, base);		/* chain */
	if (!b0)
	    return -7;
	p->xsp_Sub[0] = b0;
	p->xsp_Sub[1] = b1;
    }
    chn  = (UWORD *)p->xsp_Sub[0];
    head = (UWORD *)p->xsp_Sub[1];

    /* head[] clear: 64KB, byte-wise (LAB_0032: 65536 iters) */
    {
	UBYTE *h = (UBYTE *)head;
	for (i = 0; i < 0x10000; i++)
	    h[i] = 0;
    }

#define NEXTBIT() do {					\
    d5 >>= 1;						\
    if (!d5) {						\
	if (++w >= outend)				\
	    return -17;					\
	*w = 0;						\
	d5 = 0x80;					\
    }							\
} while (0)

#define PUTBIT(v) do {					\
    if (v)						\
	*w |= (UBYTE)d5;				\
    NEXTBIT();						\
} while (0)

    *w = 0;					/* first flag byte */

    /* ---- 16-bit inlen header, MSB-first (LAB_0033) ---- */
    {
	ULONG d6 = 0x8000;
	while (d6) {
	    PUTBIT(p->xsp_InLen & d6);
	    d6 >>= 1;
	}
    }

    /* ---- scan: count positions to end, cap 19 (LAB_0036) ---- */
    {
	ULONG cnt = 1;
	for (;;) {
	    if (scan >= inend)
		atend = 1;
	    cnt++;
	    scan++;
	    if (cnt > 0x12 || atend)
		break;
	}
	runcap = (LONG)(cnt & 0xff) - 2;
    }

    if (runcap > 1)
	hash = ((in[1] << 5) ^ in[2]) & 0x7fff;

    for (;;) {
	ULONG d3;

	/* LAB_0057: stop when the tail budget ran out ------- */
	if (runcap <= 0)
	    break;

	/* LAB_0039/003A: clamp & emit ------------------------ */
	if (best > runcap)
	    best = runcap;
	if (best < 3) {
	    /* literal: '1' + 8 data bits (LAB_003B/003C)      */
	    ULONG v, m;
	    *w |= (UBYTE)d5;			/* flag bit 1   */
	    NEXTBIT();
	    v = a2[0];
	    m = 0x80;
	    while (m) {
		PUTBIT(v & m);
		m >>= 1;
	    }
	    d3 = 1;
	} else {
	    /* match: '0' + pos:wdt + len-3:4 (LAB_0040..0049) */
	    ULONG v, m;
	    if (a2 > wlmt) {			/* width bump */
		wdt++;
		wlmt = in + (1UL << wdt);
	    }
	    NEXTBIT();				/* flag bit 0   */
	    v = (ULONG)bpos;
	    m = 1UL << (wdt - 1);
	    while (m) {
		PUTBIT(v & m);
		m >>= 1;
	    }
	    v = ((ULONG)best - 3) & 0xff;
	    m = 8;
	    while (m) {
		PUTBIT(v & m);
		m >>= 1;
	    }
	    d3 = (ULONG)best;
	}

	/* LAB_004A/004B/004D: insert the consumed span ------- */
	for (i = 0; i < (LONG)d3; i++) {
	    if (atend)
		runcap--;
	    else {
		const UBYTE *q = scan++;
		if (q >= inend)
		    atend = 1;
	    }
	    a2++;
	    hash = ((hash << 5) ^ a2[2]) & 0x7fff;
	    {
		ULONG pos = (ULONG)(a2 - in);
		cand = head[hash];
		head[hash] = (UWORD)pos;
		chn[pos] = (UWORD)cand;
	    }
	}

	/* ---- finder (LAB_0056): walk candidates ----------- */
	{
	    const UBYTE *lim;
	    UBYTE  prebyte;
	    UWORD  nxt;
	    int    fail = 0;

	    /* cand = d4 = last insert's old head = first
	     * candidate; 96(sp) = d4 (bpos updated on
	     * improvement only) */
	    bpos = cand;
	    if (in + cand > a2)			/* cand > cur */
		continue;			/* -> LAB_0057 */
	    prebyte = a2[2];
	    lim = a2 + 18;
	    best = 2;
	    nxt = cand;
	    for (;;) {
		const UBYTE *a5, *ap, *bp;
		LONG   len;
		if (nxt == 0)
		    break;
		if (cand < nxt)			/* need d4 >= d3 */
		    break;
		cand = nxt;
		a5 = in + cand;
		if (a5[best] != prebyte)
		    goto failed;
		ap = a5;
		bp = a2;
		if (*bp++ != *ap++)
		    goto failed;		/* cmpm byte0 */
		if (*bp++ != *ap++)
		    goto failed;		/* cmpm byte1 */
		{
		    int g = 8;
		    for (;;) {
			if (*bp++ != *ap++)
			    break;
			if (--g == 0) {
			    if (bp - 1 < lim) {
				g = 8;
				continue;
			    }
			    break;
			}
		    }
		}
		len = (bp - 1) - a2;		/* matched len  */
		if (len <= best)
		    goto nextcand;
		best = len;
		bpos = cand;
		if (len >= 18)
		    goto emit;			/* LAB_0057     */
		prebyte = a2[best];		/* in[cur+best] */
		goto nextcand;
	    failed:
		if (++fail > 17)
		    goto emit;			/* d6 budget    */
	    nextcand:
		nxt = chn[cand];			/* LAB_0055   */
	    }
	}
    emit:;
    }

    /* epilogue: OutLen = produced byte count (w - out + 1) */
    p->xsp_OutLen = (ULONG)(w - out) + 1;
    return 0;
#undef PUTBIT
#undef NEXTBIT
}

/*
** XpksUnpackChunk (LVO -54)
**
**	  d7 = declared outlen word; -10 when it exceeds
**	  xsp_OutBufLen (+0x0c), which is then OVERWRITTEN with
**	  the declared length.  a2 = stream, d4 = bit index in
**	  the current byte, a3 = out cursor, a5 = out base,
**	  d5 = position width (bumped when outpos > base+2^w).
**	  Writes exactly d7 bytes; a trailing match may run past
**	  the declared length (no bound -- shipped).
*/
LONG XpksUnpackChunk(struct XpkSubParams *p ASMREG("a0"),
		     struct IlzrBase *base ASMREG("a6"))
{
    const UBYTE *a2 = (const UBYTE *)p->xsp_InBuf;
    UBYTE *a3 = (UBYTE *)p->xsp_OutBuf;
    UBYTE *a5 = a3;				/* out base	   */
    LONG  d7;					/* remaining	   */
    ULONG d4 = 0;				/* bit index	   */
    ULONG d5 = 8;				/* pos width	   */
    UBYTE *a4;					/* bump threshold  */

#define RD32(p) (((ULONG)(p)[0] << 24) | ((ULONG)(p)[1] << 16) |	\
		 ((ULONG)(p)[2] << 8) | (ULONG)(p)[3])

    d7 = (LONG)((a2[0] << 8) | a2[1]);
    a2 += 2;
    if ((ULONG)d7 > p->xsp_OutBufLen)
	return -10;
    a4 = a5 + 256;
    p->xsp_OutBufLen = (ULONG)d7;		/* declared len -> +0x0c */

    while (d7 > 0) {
	ULONG flag;

	flag = (0x80 >> d4) & a2[0];
	d4++;
	if (flag) {					/* literal   */
	    if (d4 > 7) {
		a2++;
		d4 = 0;
	    }
	    *a3++ = (UBYTE)(RD32(a2) >> (24 - d4));
	    a2++;
	    d7--;
	} else {					/* match     */
	    ULONG pos, len;
	    if (d4 > 7) {
		a2++;
		d4 = 0;
	    }
	    if (a3 > a4) {				/* width++   */
		d5++;
		a4 = a5 + (1UL << d5);
	    }
	    pos = (RD32(a2) >> (32 - d5 - d4)) & ((1UL << d5) - 1);
	    d4 += d5;
	    a2++;
	    d4 -= 8;
	    if (d4 > 7) {
		d4 -= 8;
		a2++;
	    }
	    len = (RD32(a2) >> (28 - d4)) & 15;
	    d4 += 4;
	    if (d4 > 7) {
		d4 -= 8;
		a2++;
	    }
	    len += 3;
	    {
		const UBYTE *s = a5 + pos;		/* ABS pos  */
		d7 -= (LONG)len;
		while (len--)
		    *a3++ = *s++;
	    }
	}
    }
    return 0;
#undef RD32
}
