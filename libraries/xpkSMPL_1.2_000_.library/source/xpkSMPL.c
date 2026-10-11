/*
**	xpkSMPL.c -- C reconstruction of xpkSMPL.library 1.2
**	"Sample Huffman V1.2" (Jorma Oksanen, 1 Oct 2013).
**
**	XPK sublibrary: dynamic Huffman compression with delta
**	precoding.  Vector map (AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 LibNull (entry stub)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 LibNull (PackReset no-op)
**	                      -54 XpksUnpackChunk
**	                      -60 XpksUnpackFree (== PackFree)
**
**	Workmem is allocated lazily on first use with AllocMem
**	(flags 0 -- NOT cleared) and stored at xsp->xsp_Sub[0]
**	(size long + payload); PackFree releases it via FreeMem.
**
**	Pack workmem (12808 = 0x3208 bytes; a5 == Sub[0] == alloc+4):
**	  a5+0        saved SP for the -17 bailout
**	  a5+4        head node (22B slot: link head, freq cleared)
**	  a5+26       leaf arena: 22-byte nodes
**	              {link@0, freq@4.w, sym@6.w, parent@8,
**	               left@12, right@16, mark@20.w}
**	              then a 0xFF sentinel byte at next-slot sym,
**	              then internal nodes in the same arena
**	  a5+11268    freq[256] U16 histogram, reused as lentab
**	  a5+11780    code[256] U32
**
**	Unpack workmem (4100 = 0x1004 bytes; a5 == Sub[0] == alloc+4):
**	  a5+0        trie root long {left@0.w, right@2.w} + node
**	              arena (4B nodes, word offsets from a5;
**	              leaves are 0xFFFFFF00+sym)
**	  a5+2048     1024-entry U16 fast table for 10-bit prefixes:
**	              leaf -> (unconsumed<<8)|sym, else
**	              node offset - 0x800 (negative)
**
**	Shipped quirks reproduced verbatim:
**	  - the -36 vector reads xsp from the caller's d7 (saved on
**	    the stack) for the output pointer / data-loop base,
**	    while everything else uses a0; the master passes xsp
**	    in both registers.
**	  - the output flush budget is computed with WORD ops
**	    (lsrw/subqw): only the low 16 bits of inlen count.
**	  - the histogram / data counters are SUBQ.L/DBF word
**	    loops: inlen == 0 wraps to 65536 samples and reads far
**	    past the buffer.
**	  - an all-zero histogram walks a NULL list head and reads
**	    address 0 (inlen 0 path).
**	  - len-table emit: len>=15 emits 8-bit (len-31); len>=31
**	    truncates to a nibble<15 and desyncs the decoder; len 31
**	    specifically emits nibble 0 == "absent symbol".
**	  - codes longer than 32 bits abort -17 via the walk guard.
**	  - the decode count is outlen-1 via SUBQ.L/DBF: outlen 0
**	    wraps to 65536 iterations.
**	  - the unpacker reads up to 2 bytes past the compressed
**	    tail; the packer always appends a 4-byte pad long.
**	  - PackFree leaves a stale pointer in xsp_Sub[0].
*/

#define SYSBASE (*(APTR *)4)

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t        UBYTE;
typedef uint16_t       UWORD;
typedef uint32_t       ULONG;
typedef int32_t        LONG;
typedef int16_t        SHORT;
typedef void          *APTR;
typedef char          *STRPTR;
typedef ULONG          BPTR;
#define LIBF_DELEXP 0x08
struct Library {
    UBYTE  ln_pad[14];
    UWORD  lib_Flags;
    UWORD  lib_NegSize;
    UWORD  lib_PosSize;
    UWORD  lib_Version;
    UWORD  lib_Revision;
    ULONG  lib_IdString;
    ULONG  lib_Sum;
    UWORD  lib_OpenCnt;
};
#else
#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#endif

struct XpkSubParams {
    APTR    xsp_InBuf;		/* 0x00 */
    ULONG   xsp_InLen;		/* 0x04 */
    APTR    xsp_OutBuf;		/* 0x08 */
    ULONG   xsp_OutBufLen;	/* 0x0c */
    ULONG   xsp_OutLen;		/* 0x10 */
    ULONG   xsp_Flags;		/* 0x14 */
    ULONG   xsp_Number;		/* 0x18 */
    ULONG   xsp_Mode;		/* 0x1c */
    STRPTR  xsp_Password;	/* 0x20 */
    UWORD   xsp_LibVersion;	/* 0x24 */
    UWORD   xsp_Pad;		/* 0x26 */
    ULONG   xsp_Arg[3];		/* 0x28 */
    ULONG   xsp_Sub[4];		/* 0x34 */
};

struct SmplBase {
    struct Library lib;
    ULONG   b_SegList;		/* 0x22 seglist, stored by LibInit */
};

/* 22-byte huffman node inside the pack arena (packed: the
 * original uses a 22-byte stride on unaligned longs)        */
struct __attribute__((packed)) pnode {
    ULONG   link;		/* 0x00 sorted-list next	    */
    UWORD   freq;		/* 0x04				    */
    SHORT   sym;		/* 0x06 leaf sym; <0 sentinel	    */
    ULONG   parent;		/* 0x08				    */
    ULONG   left;		/* 0x0c				    */
    ULONG   right;		/* 0x10				    */
    UWORD   mark;		/* 0x14 0x4000/0x8000/0(root)	    */
};

/* workmem offsets (a5 == Sub[0] == alloc+4) */
#define PWK_NODES   4
#define PWK_HIST    11268
#define PWK_CODETAB 11780
#define PWK_SIZE    0x3208

#define UWK_DECTAB  2048
#define UWK_SIZE    0x1004

static void wr16(UBYTE *p, UWORD v)
{
    p[0] = (UBYTE)(v >> 8); p[1] = (UBYTE)v;
}

static UWORD rd16(const UBYTE *p)
{
    return (UWORD)((p[0] << 8) | p[1]);
}

static void wr32(UBYTE *p, ULONG v)
{
    p[0] = (UBYTE)(v >> 24); p[1] = (UBYTE)(v >> 16);
    p[2] = (UBYTE)(v >> 8);  p[3] = (UBYTE)v;
}

static ULONG rd32(const UBYTE *p)
{
    return ((ULONG)p[0] << 24) | ((ULONG)p[1] << 16) |
           ((ULONG)p[2] << 8)  | (ULONG)p[3];
}

/* unpack workmem nodes: the original accesses them with plain
 * move.w/move.l (big-endian).  Use native access on the target;
 * the explicit BE helpers keep the host test model identical.   */
#ifdef HOST_TEST
#define NRD16(p)	rd16(p)
#define NWR16(p, v)	wr16((UBYTE *)(p), (v))
#define NRD32(p)	rd32(p)
#define NWR32(p, v)	wr32((UBYTE *)(p), (v))
#else
#define NRD16(p)	(*(const UWORD *)(p))
#define NWR16(p, v)	(*(UWORD *)(p) = (v))
#define NRD32(p)	(*(const ULONG *)(p))
#define NWR32(p, v)	(*(ULONG *)(p) = (v))
#endif

/* -------------------------------------------------------------- */
/* exec calls							    */
/* -------------------------------------------------------------- */

#ifdef HOST_TEST
extern APTR host_AllocMem(ULONG sz);
extern void host_Remove(void *n);
extern void host_FreeMem(void *p, ULONG sz);
#define exec_AllocMem(sz)  host_AllocMem(sz)
#define exec_Remove(n)     host_Remove(n)
#define exec_FreeMem(p,sz) host_FreeMem(p,sz)
#else
static APTR exec_AllocMem(ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register ULONG __p_sz __asm("d0") = sz;
    register APTR __r __asm("d0");
    __asm volatile ("jsr %/a6@(-198:W)\n"
	: "=r" (__r)
	: "a" (__p_sys), "r" (__p_sz)
	: "a0","a1","d1","memory");
    return __r;
}

static void exec_Remove(void *n)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_n __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)\n"
	:
	: "a" (__p_sys), "a" (__p_n)
	: "a0","d0","d1","memory");
}

static void exec_FreeMem(void *p, ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_p __asm("a1") = p;
    register ULONG __p_sz __asm("d0") = sz;
    __asm volatile ("jsr %/a6@(-210:W)\n"
	:
	: "a" (__p_sys), "a" (__p_p), "r" (__p_sz)
	: "a0","d1","memory");
}
#endif

/* -------------------------------------------------------------- */
/* lifecycle							    */
/* -------------------------------------------------------------- */

/* -6 Open: ++OpenCnt; clear DELEXP; return base */
struct Library *LibOpen(struct SmplBase *b __asm("a6"))
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

/* expunge body: removes + frees the library; returns the seglist */
static BPTR expunge_body(struct SmplBase *b)
{
    BPTR seg = b->b_SegList;
    ULONG  sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
    exec_Remove(b);
    exec_FreeMem(p, sz);
    return seg;
}

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge;
 * otherwise returns via the entry stub (the DELEXP-clear path
 * branches to hunk+2 past the moveq, leaving d0 stale).     */
LONG LibClose(struct SmplBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge */
BPTR LibExpunge(struct SmplBase *b __asm("a6"))
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return expunge_body(b);
}

/* -24/-48: null vectors landing on the entry stub */
LONG LibNull(void)
{
    return 0;
}

/* -------------------------------------------------------------- */
/* XPK interface						    */
/* -------------------------------------------------------------- */

/* -30 XpksPackerInfo: return the static descriptor */
APTR XpksPackerInfo(void)
{
    extern char xpkinfo[];
    return xpkinfo;
}

/* -------------------------------------------------------------- */
/* -36 XpksPackChunk						    */
/* -------------------------------------------------------------- */

/*
**	bit emitter: `acc` is MSB-first, `space` counts free bits
**	at the bottom; a 16-bit flush decrements `budget`
**	((inlen_lo>>1)-1 flushes).  Returns nonzero on budget
**	exhaustion -- the original's -17 bailout via saved SP.
*/

struct emit {
    ULONG   acc;
    LONG    space;
    UBYTE  *out;
    LONG    budget;
};

/* raw emit, n <= 16 */
static int emit_bits(struct emit *e, ULONG bits, int n)
{
    e->space -= n;
    if (e->space < 0) {
	if (--e->budget < 0)
	    return -1;
	wr16(e->out, (UWORD)(e->acc >> 16));
	e->out += 2;
	e->acc <<= 16;
	e->space += 16;
    }
    e->acc |= bits << e->space;
    return 0;
}

/* split emit for codes of arbitrary length (hi16 then lo16) */
static int emit_code(struct emit *e, ULONG code, int n)
{
    if (n > 16) {
	if (emit_bits(e, code >> 16, n - 16))
	    return -1;
	code &= 0xffff;
	n = 16;
    }
    return emit_bits(e, code, n);
}

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   register struct SmplBase *b __asm("a6"))
{
    UBYTE *wk = (UBYTE *)xsp->xsp_Sub[0];
    UBYTE *base;
    struct pnode *arena, *head, *m, *cur, *sec, *slot, *n;
    UWORD *freq, *lentab;
    ULONG *codetab;
    struct emit e;
    const UBYTE *src;
    ULONG inlen;
    int sym;
    LONG ret = 0;

    if (!wk) {
	wk = exec_AllocMem(PWK_SIZE);
	if (!wk)
	    return -7;
	*(ULONG *)wk = PWK_SIZE;
	xsp->xsp_Sub[0] = (ULONG)wk + 4;
    }
    base = (UBYTE *)xsp->xsp_Sub[0];	/* == wk+4, a5 */

    arena   = (struct pnode *)(base + PWK_NODES);
    lentab  = (UWORD *)(base + PWK_HIST);
    codetab = (ULONG *)(base + PWK_CODETAB);
    freq    = lentab;			/* histogram shares it */

    for (sym = 0; sym < 256; sym++)
	freq[sym] = 0;

    src   = (const UBYTE *)xsp->xsp_InBuf;
    inlen = xsp->xsp_InLen;

    /* delta histogram; SUBQ.L/DBF -- inlen 0 wraps to 65536 */
    {
	ULONG count = inlen - 1;
	UBYTE prev = 0;
	const UBYTE *p = src;
	for (;;) {
	    UBYTE c = *p++;
	    UBYTE delta = (UBYTE)(c - prev);
	    prev = c;
	    ++freq[delta];
	    if ((UWORD)count-- == 0)
		break;
	}
    }

    /* sorted leaf list, ascending freq, inserted BEFORE the
     * first node with freq >= new (before-equals)             */
    head = arena;
    head->link = 0;
    head->freq = 0;
    slot = arena + 1;
    for (sym = 255; sym >= 0; sym--) {
	UWORD f = freq[sym];
	struct pnode *p, *nxt;
	if (!f)
	    continue;
	slot->freq = f;
	slot->sym  = sym;
	for (p = head; (nxt = (struct pnode *)p->link) != 0 &&
		      f > nxt->freq; p = nxt)
	    ;
	slot->link = (ULONG)nxt;
	p->link    = (ULONG)slot;
	slot++;
    }
    ((UBYTE *)&slot->sym)[0] = 0xff;	/* `st a4@(6)` sentinel */

    /* merge two smallest until one node remains */
    cur = (struct pnode *)head->link;
    for (;;) {
	if (!cur->link) {		/* single element: pseudo-root */
	    cur->mark = 0x4000;
	    m = slot++;
	    m->left = (ULONG)cur;
	    cur->parent = (ULONG)m;
	    m->mark = 0;
	    break;
	}
	sec = (struct pnode *)cur->link;
	m = slot++;
	cur->mark = 0x4000;
	sec->mark = 0x8000;
	m->freq   = (UWORD)(cur->freq + sec->freq);
	m->left   = (ULONG)cur;
	m->right  = (ULONG)sec;
	cur->parent  = (ULONG)m;
	sec->parent  = (ULONG)m;
	cur = (struct pnode *)sec->link;	/* rest head */
	if (!cur) {			/* merged the last two */
	    m->mark = 0;
	    break;
	}
	if (m->freq <= cur->freq) {
	    m->link = (ULONG)cur;	/* insert before rest-head */
	    cur = m;
	} else {
	    struct pnode *pred = cur, *nn = (struct pnode *)cur->link;
	    while (nn && m->freq > nn->freq) {
		pred = nn;
		nn = (struct pnode *)nn->link;
	    }
	    pred->link = (ULONG)m;
	    m->link    = (ULONG)nn;
	    if (!cur->link) {		/* dead path in the original */
		m->mark = 0;
		break;
	    }
	}
    }

    /* leaves -> (len,code): parent-marker walk, bits collected
     * MSB-first via roxr; guard 32 -> -17 bailout              */
    for (n = arena + 1; n->sym >= 0; n++) {
	struct pnode *w;
	ULONG c = 0;
	LONG d1 = 32;

	for (w = n; w->mark; w = (struct pnode *)w->parent) {
	    c = (c >> 1) | ((w->mark & 0x8000) ? 0x80000000UL : 0);
	    if (--d1 == -1) {
		ret = -17;
		goto pack_out;
	    }
	}
	c >>= d1;			/* lsrl d1,d2 */
	lentab[n->sym]  = (UWORD)(32 - d1);
	codetab[n->sym] = c;
    }

    /* emit: signature 1, len table, then delta data */
    e.acc = 0;
    e.space = 32;
    e.out = (UBYTE *)xsp->xsp_OutBuf;
    e.budget = (LONG)(SHORT)((UWORD)((inlen & 0xffff) >> 1) - 1);
    if (e.budget < 0) {
	ret = -17;
	goto pack_out;
    }
    wr16(e.out, 1);
    e.out += 2;

    {
	const UWORD *lt = lentab;
	const ULONG *ct = codetab;
	for (sym = 0; sym < 256; sym++) {
	    UWORD len = *lt++;
	    if (!len) {
		if (emit_bits(&e, 0, 4))
		    goto pack_fail;
		ct++;
	    } else if (len < 15) {
		if (emit_bits(&e, len, 4))
		    goto pack_fail;
		if (emit_bits(&e, *ct++, len))
		    goto pack_fail;
	    } else {
		if (emit_bits(&e, (ULONG)(len - 31) & 0xff, 8))
		    goto pack_fail;
		if (emit_code(&e, *ct++, len))
		    goto pack_fail;
	    }
	}
    }

    {
	ULONG count = inlen - 1;
	UBYTE prev = 0;
	const UBYTE *p = src;
	for (;;) {
	    UBYTE c = *p++;
	    UBYTE delta = (UBYTE)(c - prev);
	    prev = c;
	    if (emit_code(&e, codetab[delta], lentab[delta]))
		goto pack_fail;
	    if ((UWORD)count-- == 0)
		break;
	}
    }

    wr32(e.out, e.acc);			/* final padded long */
    e.out += 4;
    xsp->xsp_OutLen = (ULONG)(e.out - (UBYTE *)xsp->xsp_OutBuf);
    return 0;

pack_fail:
    ret = -17;
pack_out:
    return ret;
}

/* -------------------------------------------------------------- */
/* -54 XpksUnpackChunk						    */
/* -------------------------------------------------------------- */

/*
**	bit reader: `win` right-justified, `bits` = pending count
**	in the low bits; consumes from the top of the pending
**	region.  Refill is swap+word-load -- modelled as
**	win = (win<<16)|word, valid because pending <= 9 at any
**	refill point.
*/

struct reader {
    ULONG        win;
    LONG         bits;
    const UBYTE *in;
};

static ULONG getbits(struct reader *r, int n)
{
    r->bits -= n;
    if (r->bits < 0) {
	r->win = (r->win << 16) | NRD16(r->in);
	r->in += 2;
	r->bits += 16;
    }
    return r->win >> r->bits;
}

/* split read for lengths >16 (n-16 bits then a 16-bit word) */
static ULONG getcode(struct reader *r, int n)
{
    if (n > 16) {
	ULONG hi = getbits(r, n - 16) & 0xffff;
	ULONG lo = getbits(r, 16) & 0xffff;
	return (hi << 16) | lo;
    }
    return getbits(r, n);
}

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     register struct SmplBase *b __asm("a6"))
{
    UBYTE *wk = (UBYTE *)xsp->xsp_Sub[0];
    UBYTE *base;
    UWORD *dectab;
    struct reader r;
    UBYTE *out;
    ULONG arenapos;
    LONG sym;

    if (NRD16((const UBYTE *)xsp->xsp_InBuf) != 1)
	return -26;

    if (!wk) {
	wk = exec_AllocMem(UWK_SIZE);
	if (!wk)
	    return -7;
	*(ULONG *)wk = UWK_SIZE;
	xsp->xsp_Sub[0] = (ULONG)wk + 4;
    }
    base = (UBYTE *)xsp->xsp_Sub[0];	/* == wk+4, a5 */

    r.in   = (const UBYTE *)xsp->xsp_InBuf + 2;
    r.bits = 16;
    r.win  = NRD16(r.in);
    r.in  += 2;

    dectab = (UWORD *)(base + UWK_DECTAB);
    NWR32(base, 0);		/* root {0,0} */
    arenapos = 4;

    /* read 256 (len,code) entries, insert each into the trie */
    for (sym = -256; sym; sym++) {
	ULONG len = getbits(&r, 4) & 15;
	ULONG code;
	LONG d1;
	ULONG d2;
	UBYTE *a1;
	if (!len)
	    continue;
	if (len == 15)
	    len = 15 + (getbits(&r, 4) & 15);
	code = getcode(&r, (int)len);
	d2 = code << (32 - len);	/* left-justified */
	d1 = (LONG)len - 1;		/* len steps */
	a1 = base;			/* trie root */
	for (;;) {
	    ULONG bit = d2 & 0x80000000UL;
	    UWORD off;
	    d2 <<= 1;
	    if (bit) {
		off = NRD16(a1 + 2);
		if (!off) {
		    NWR16(a1 + 2, (UWORD)arenapos);
		    a1 = base + arenapos;
		    arenapos += 4;
		    NWR32(a1, 0);
		    goto step_done;
		}
	    } else {
		off = NRD16(a1);
		if (!off) {
		    NWR16(a1, (UWORD)arenapos);
		    a1 = base + arenapos;
		    arenapos += 4;
		    NWR32(a1, 0);
		    goto step_done;
		}
	    }
	    a1 = base + off;
step_done:
	    if (--d1 == -1)
		break;
	}
	NWR32(a1, 0xffffff00UL | (ULONG)(sym & 0xff));
    }

    /* single-branch root fixup: mirror left into right */
    if (!NRD16(base + 2))
	NWR16(base + 2, NRD16(base));

    /* build the 1024-entry 10-bit fast table */
    {
	UBYTE *cur = base + UWK_DECTAB;
	UWORD pfx = 0;
	for (;;) {
	    ULONG d3 = NRD32(base);	/* root node long */
	    LONG d1 = 9;
	    UWORD d0 = pfx, d4 = 0;
	    for (;;) {
		UWORD old = d0;
		d0 = (UWORD)(d0 << 1);
		if (!(old & 0x8000))	/* bit==0 -> swap to hi (left) */
		    d3 = (d3 << 16) | (d3 >> 16);
		d4 = (UWORD)d3;
		d3 = NRD32(base + (SHORT)d4);
		if ((LONG)d3 < 0)	/* leaf -> exit */
		    break;
		if (--d1 == -1)
		    break;
	    }
	    if ((LONG)d3 < 0)
		NWR16(cur, (UWORD)(((UWORD)(UBYTE)d1 << 8) | (d3 & 0xff)));
	    else
		NWR16(cur, (UWORD)(d4 - 0x800));
	    cur += 2;
	    pfx = (UWORD)(pfx + 0x40);
	    if (!pfx)
		break;
	}
    }

    /* delta decode via fast table / trie walk */
    out = (UBYTE *)xsp->xsp_OutBuf;
    {
	ULONG count = xsp->xsp_OutLen - 1;
	UBYTE acc = 0;
	for (;;) {
	    SHORT ent;
	    r.bits -= 10;
	    if (r.bits < 0) {
		r.win = (r.win << 16) | NRD16(r.in);
		r.in += 2;
		r.bits += 16;
	    }
	    ent = (SHORT)NRD16((const UBYTE *)dectab +
				 (((r.win >> r.bits) & 0x3ff) << 1));
	    if (ent >= 0) {
		acc += (UBYTE)ent;
		*out++ = acc;
		r.bits += (ent >> 8) & 0xff;
	    } else {
		ULONG node = NRD32(base + UWK_DECTAB + ent);
		if (--r.bits == -1) {	/* entry dbf -> refill */
		    r.win = (r.win << 16) | NRD16(r.in);
		    r.in += 2;
		    r.bits = 15;
		}
		for (;;) {
		    if (!(r.win & (1UL << r.bits)))
			node = (node << 16) | (node >> 16);
		    node = NRD32(base + (SHORT)node);
		    if ((LONG)node < 0)	/* leaf -> emit */
			break;
		    if (--r.bits == -1) {	/* window out -> refill */
			r.win = (r.win << 16) | NRD16(r.in);
			r.in += 2;
			r.bits = 15;
		    }
		}
		acc += (UBYTE)node;
		*out++ = acc;
	    }
	    if ((UWORD)count-- == 0)
		break;
	}
    }
    return 0;
}

/* -42/-60 PackFree/UnpackFree: free the workmem via its size
 * long; leaves xsp_Sub[0] stale (shipped).                  */
LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"))
{
    ULONG p = xsp->xsp_Sub[0];
    if (p) {
	p -= 4;
	exec_FreeMem((void *)p, *(ULONG *)p);
    }
    return 0;
}
