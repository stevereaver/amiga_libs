/*
**	xpkSMPL.c -- C reconstruction of xpkSMPL.library 1.0
**	"Sample packer 1.0" (1.11.93) -- the first SMPL release.
**
**	XPK sublibrary: dynamic Huffman compression with delta
**	precoding.  Vector map (AUTOINIT word-offset functab):
**
**	  -6  LibOpen         -24 LibNull (moveq #0,rts stub)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 XpksPackReset (bare rts)
**	                      -54 XpksUnpackChunk
**	                      -60 XpksUnpackFree (== PackFree)
**
**	Differences from 1.2: pointer-field 24-byte nodes, byte
**	lentab, len>=15 emits an 8-bit `len-31` escape (same bits
**	as the nibble form for 15..30), separate pack/unpack
**	workmem allocations via an AllocMem(+4,size-long) helper,
**	and PackFree clears xsp_Sub[0] (1.2 leaves it stale).
**
**	Pack workmem (0x3710 usable; alloc is 0x3714, Sub[0]=+4):
**	  a5+0       xsp pointer
**	  a5+4       saved SP for the -17 bailout
**	  a5+8       inbuf / a5+12 inlen (copied at entry)
**	  a5+16      sorted-list head node
**	  a5+40      24-byte node arena {link@0, freq@4.w, sym@6.w,
**	             parent@8, left@12, right@16, mark@20.w}
**	  a5+12304   lentab BYTE[256]
**	  a5+12560   codetab ULONG[256]
**	  a5+13456   freq U16[256] histogram (640B cleared)
**
**	Unpack workmem (0x1000 usable; alloc 0x1004, Sub[0]=+4):
**	  a5+0       binary trie: 4B nodes, U16 child offsets
**	  a5+2048    1024-entry 10-bit fast decode table
**
**	Both allocs go through the same `AllocMem(sz+4)` helper
**	which stores the size long at alloc[0] and returns +4.
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

/* 24-byte huffman node (raw pointer fields on m68k) */
struct pnode {
    ULONG   link;		/* 0x00 sorted-list next	    */
    UWORD   freq;		/* 0x04				    */
    SHORT   sym;		/* 0x06 leaf sym; <0 sentinel	    */
    ULONG   parent;		/* 0x08				    */
    ULONG   left;		/* 0x0c				    */
    ULONG   right;		/* 0x10				    */
    UWORD   mark;		/* 0x14 0x4000/0x8000/0(root)	    */
    UWORD   pad;		/* 0x16 24-byte stride		    */
};

/* pack workmem offsets (a5 == Sub[0] == alloc+4) */
#define PWK_XSP     0
#define PWK_SP      4
#define PWK_HEAD    16
#define PWK_NODES   40
#define PWK_LENTAB  12304
#define PWK_CODETAB 12560
#define PWK_HIST    13456
#define PWK_SIZE    0x3710

/* unpack workmem */
#define UWK_DECTAB  2048
#define UWK_SIZE    0x1000

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

/* workmem nodes: the original accesses them with plain
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

/* the shared alloc helper: AllocMem(sz+4), size at [0], ret +4 */
static APTR wk_Alloc(ULONG usable)
{
    APTR a = exec_AllocMem(usable + 4);
    if (a) {
	*(ULONG *)a = usable + 4;
	a = (UBYTE *)a + 4;
    }
    return a;
}

/* free via the size long at Sub[0]-4 */
static void wk_Free(ULONG sub0)
{
    if (sub0) {
	UBYTE *p = (UBYTE *)sub0 - 4;
	exec_FreeMem(p, *(ULONG *)p);
    }
}

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

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge */
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

/* -30: return the static descriptor (in the asm it's returned
 * in both a0 and d0; the master's ABI only needs a pointer)   */
char *XpksPackerInfo(struct XpkSubParams *xsp __asm("a0"),
		     register struct SmplBase *b __asm("a6"))
{
    extern char xpkinfo[];
    return xpkinfo;
}

/* -------------------------------------------------------------- */
/* packer							    */
/* -------------------------------------------------------------- */

/*
**	emit: `space` free low bits in the accumulator; a flush
**	writes the high word when a new value would underflow --
**	`d5` word budget counts those flushes, DBF exhaustion is the
**	original's -17 bailout via saved SP.
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
    UWORD *freq;
    UBYTE *lentab;
    ULONG *codetab;
    struct emit e;
    const UBYTE *src;
    ULONG inlen;
    int sym;
    LONG ret = 0;

    if (!wk) {
	wk = (UBYTE *)wk_Alloc(PWK_SIZE);
	if (!wk)
	    return -7;
	xsp->xsp_Sub[0] = (ULONG)wk;
    }
    base = wk;				/* a5 */

    *(ULONG *)(base + PWK_XSP) = (ULONG)xsp;
    *(ULONG *)(base + PWK_SP)  = 0;	/* saved SP (longjmp)   */
    *(const UBYTE **)(base + 8) = (const UBYTE *)xsp->xsp_InBuf;
    *(ULONG *)(base + 12) = xsp->xsp_InLen;

    arena   = (struct pnode *)(base + PWK_NODES);
    lentab  = base + PWK_LENTAB;
    codetab = (ULONG *)(base + PWK_CODETAB);
    freq    = (UWORD *)(base + PWK_HIST);

    {
	int i;
	for (i = 0; i < 256; i++) {
	    freq[i] = 0;
	    lentab[i] = 0;
	}
    }

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
    head = (struct pnode *)(base + PWK_HEAD);
    head->link = 0;
    head->freq = 0;
    slot = arena;
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
    slot->sym = (SHORT)0xff00;		/* `st a4@(6)` sentinel */

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
    for (n = arena; n->sym >= 0; n++) {
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
	lentab[n->sym]  = (UBYTE)(32 - d1);
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

    /* len table: 0 -> 4-bit 0; <15 -> nibble + code raw;
     * >=15 -> 8-bit (len-31) escape + code via split emit.
     * codetab is read sequentially for all 256 entries.      */
    {
	int i;
	for (i = 0; i < 256; i++) {
	    int len = lentab[i];
	    ULONG code = codetab[i];
	    if (!len) {
		if (emit_bits(&e, 0, 4)) {
		    ret = -17;
		    goto pack_out;
		}
	    } else if (len < 15) {
		if (emit_bits(&e, (ULONG)len, 4) ||
		    emit_bits(&e, code, len)) {
		    ret = -17;
		    goto pack_out;
		}
	    } else {
		if (emit_bits(&e, (ULONG)((len - 31) & 0xff), 8) ||
		    emit_code(&e, code, len)) {
		    ret = -17;
		    goto pack_out;
		}
	    }
	}
    }

    /* delta data; SUBQ.L/DBF count -- inlen 0 wraps */
    {
	ULONG count = inlen - 1;
	UBYTE prev = 0;
	const UBYTE *p = src;
	for (;;) {
	    UBYTE c = *p++;
	    UBYTE delta = (UBYTE)(c - prev);
	    prev = c;
	    if (emit_code(&e, codetab[delta], lentab[delta])) {
		ret = -17;
		goto pack_out;
	    }
	    if ((UWORD)count-- == 0)
		break;
	}
    }

    wr32(e.out, e.acc);			/* final padded long */
    e.out += 4;
    xsp->xsp_OutLen = (ULONG)(e.out - (UBYTE *)xsp->xsp_OutBuf);

pack_out:
    return ret;
}

/* -------------------------------------------------------------- */
/* unpacker							    */
/* -------------------------------------------------------------- */

struct reader {
    ULONG   win;
    LONG    bits;
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
	wk = (UBYTE *)wk_Alloc(UWK_SIZE);
	if (!wk)
	    return -7;
	xsp->xsp_Sub[0] = (ULONG)wk;
    }
    base = wk;				/* a5 */

    r.in   = (const UBYTE *)xsp->xsp_InBuf + 2;
    r.bits = 16;
    r.win  = NRD16(r.in);
    r.in  += 2;

    dectab = (UWORD *)(base + UWK_DECTAB);
    NWR32(base, 0);			/* root {0,0} */
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
 * long and clear xsp_Sub[0] (1.0 clears it; 1.2 leaves stale). */
LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"))
{
    ULONG p = xsp->xsp_Sub[0];
    xsp->xsp_Sub[0] = 0;
    wk_Free(p);
    return 0;
}
