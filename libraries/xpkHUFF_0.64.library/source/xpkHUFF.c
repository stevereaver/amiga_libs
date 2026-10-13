/*
**	xpkHUFF.c -- C reconstruction of xpkHUFF.library 0.64
**	"xpkHUFF 0.64 (01.04.1997)".
**
**	XPK sublibrary: dynamic Huffman compression over raw bytes
**	with an optional password layer (u32 hash + chained add/XOR
**	scramble keyed on xsp_Password).  Earlier ancestor of the
**	xpkHUFF 1.0 rewrite; the stream format is the same family.
**
**	Vector map (AUTOINIT, ABSOLUTE-LONG functab, 10 vectors):
**
**	  -6  LibOpen         -24 null stub
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 null stub
**	                      -48 null stub
**	                      -54 XpksUnpackChunk
**	                      -60 null stub
**
**	Library structure: dataSize 0x22 (bare Library, no seglist
**	field).  LibInit stashes the seglist in a code cell (the
**	spare long after the datatab at code+0x7a); LibExpunge reads
**	it back pc-relative.  LibInit also contains two dead BSRs
**	into the null stub at 0x130 (vestigial init/cleanup calls)
**	and pops a5 where it pushed a6.
**
**	Stream layout:
**	  u16 0                    flag word (nonzero -> -26)
**	  u32 hash                 0xABADCAFE when no password,
**	                           pwhash(password) otherwise
**	  256-entry code table     byte (len-1) or 0xFF absent;
**	                           then ceil(len/8) code bytes,
**	                           left-justified MSB-first
**	  data                     MSB-first bit stream of codes
**
**	Scramble (pack, over out[6..outLen)):
**	  c = (plain ^ pw[i mod pwlen]) + prev_cipher; prev = c,
**	  seeded prev = pw[0].  Unpack inverts it over in[6..inLen)
**	  into a workmem buffer.
**
**	Pack workmem (alloc 29476 = 0x7324, transient per call):
**	  +0      xsp, +4 libbase
**	  +8      u16 hist[256]
**	  +520..  shadow copies of xsp fields (+520 in, +524 inlen,
**	          +528 outbuf, +536 OutBufLen; +532/+540 get outlen)
**	  +544    leaf nodes, 32B each (contiguous, flag!=0 marks used)
**	  +8768   internal nodes, 32B each (255 slots)
**	  +16928  root pointer
**	  +16932  u32 codetab[256] -> code record
**	  +21028  code records {len-1, ceil(len/8) code bytes}
**	          (exactly 256*33 bytes to end of alloc)
**
**	Node record (32B): link L@0, count W@4, sym B@6, flag B@7,
**	parent L@8, child0 L@12, child1 L@16, mark W@20.
**	Leaf flag = 4, internal = 1, root = 5, root mark = -1.
**
**	Unpack workmem (alloc 70682 = 0x1141a, transient per call):
**	  +0      xsp, +4 libbase, +8 magic u16, +10 hash u32
**	  +14     data start (in+6 or descramble buf)
**	  +18     bit-stream start (after table), +22 outbuf
**	  +26     inlen-6, +30 expected outlen, +34 trie root
**	  +38     trie nodes, 10B each (510 slots + root)
**	  +5148   descramble buffer (0xfffe = MaxPkInChunk bytes)
**
**	Trie node (10B): mark B@0 (0 = internal, 0xff = leaf),
**	sym B@1, left L@2 (bit 0), right L@6 (bit 1).  A node word
**	{mark,sym} >= 0 means "keep walking", negative = leaf.
**
**	Shipped quirks reproduced verbatim:
**	  - pwhash seeds d1=0xC0DE then reloads only d1.b per byte:
**	    every character contributes 0xC0xx to both the sum and
**	    the xor/rol stage.  An empty password hashes to
**	    0xCAFEABAD (the swapped seed), NULL to 0xABADCAFE.
**	  - the output budget is outbuf+inlen; xsp+12 is merely
**	    sanity-checked (>6) and never bounds anything.
**	  - budget/pad overflow returns -10 when a password pointer
**	    is set, -17 otherwise.
**	  - pack frees its workmem even on error; -42/-48/-60 are
**	    null stubs.
**	  - leaf selection is a MAX-count rescan taking the last
**	    equal-count leaf; equal-frequency alphabets therefore
**	    still end up byte-ordered in the list.
**	  - node-count sums are u16 (wrap past 64k inputs), and the
**	    histogram, emit, scramble and descramble loops are all
**	    dbf word-counters on (count-1): inputs > 64k only ever
**	    process (count & 0xffff) items.  inlen = 64k+1 packs
**	    just ONE symbol.
**	  - the 510-slot trie arena can overflow by 10 bytes into
**	    the descramble buffer when a full 256-leaf tree is built
**	    on a password stream (256 leaves + 255 internal + root
**	    = 512 nodes).
**	  - unpack decodes remain-1 full input bytes (dbf word
**	    counter), then a tail loop that emits (expected-produced)
**	    more SYMBOLS (d0 is only decremented after an emit, so
**	    the bit walk is unbounded): it reads past the input
**	    buffer and can write past outbuf+expected.
**	  - an overshoot (produced > expected) makes the tail
**	    counter wrap to ~64k emits of garbage.
**	  - Expunge calls the null stub (0x130) between Remove and
**	    FreeMem (vestigial subresource free).
**	  - Expunge-while-open writes LIBF_DELEXP to ExecBase+14,
**	    not the library's flags (a5/a6 bug): deferred expunge
**	    can never fire.
*/

#define SYSBASE (*(APTR *)4)

#ifdef HOST_TEST
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
typedef uint8_t		UBYTE;
typedef int8_t		BYTE;
typedef uint16_t	UWORD;
typedef int16_t		SHORT;
typedef uint32_t	ULONG;
typedef int32_t		LONG;
typedef uint8_t *	STRPTR;
typedef void *		APTR;
typedef uintptr_t	XPTR;	/* pointer-sized int */
typedef uint32_t	BPTR;

#define REGPARM_A0
#define REGPARM_A6

/* stream header fields are big-endian in the file */
#define RDW(p)	((UWORD)(((const UBYTE *)(p))[0] << 8 |	\
			 ((const UBYTE *)(p))[1]))
#define RDL(p)	((ULONG)(((const UBYTE *)(p))[0] << 24 |	\
			 ((const UBYTE *)(p))[1] << 16 |	\
			 ((const UBYTE *)(p))[2] << 8 |	\
			 ((const UBYTE *)(p))[3]))
#define WRW(p,v) do { ((UBYTE *)(p))[0] = (UBYTE)((v) >> 8);	\
		      ((UBYTE *)(p))[1] = (UBYTE)(v); } while (0)
#define WRL(p,v) do { ((UBYTE *)(p))[0] = (UBYTE)((v) >> 24);	\
		      ((UBYTE *)(p))[1] = (UBYTE)((v) >> 16);	\
		      ((UBYTE *)(p))[2] = (UBYTE)((v) >> 8);	\
		      ((UBYTE *)(p))[3] = (UBYTE)(v); } while (0)

struct Library {
    APTR	ln_Succ, ln_Pred;
    UBYTE	ln_Type;
    BYTE	ln_Pri;
    STRPTR	ln_Name;
    UBYTE	lib_Flags, ln_Pad;
    UWORD	lib_NegSize, lib_PosSize;
    UWORD	lib_Version, lib_Revision;
    STRPTR	lib_IdString;
    UWORD	lib_OpenCnt;
};
#define NT_LIBRARY	9
#define LIBF_DELEXP	8

extern APTR  h_AllocMem(ULONG, ULONG);
extern void  h_FreeMem(APTR, ULONG);
extern void  h_Remove(APTR);
#define exec_AllocMem(sz,at) h_AllocMem(sz,at)
#define exec_FreeMem(p,sz)   h_FreeMem(p,sz)
#define exec_Remove(n)       h_Remove(n)

static UBYTE h_execbase[32];	/* SysBase stand-in */
#define EXECBASE ((APTR)h_execbase)

#else
#include <exec/types.h>
#include <exec/libraries.h>
#define EXECBASE SYSBASE
typedef ULONG BPTR;		/* seglist handle, dos.h type */
typedef ULONG XPTR;
#define REGPARM_A0 __asm("a0")
#define REGPARM_A6 __asm("a6")
#define RDW(p)	(*(const UWORD *)(p))
#define RDL(p)	(*(const ULONG *)(p))
#define WRW(p,v) (*(UWORD *)(p) = (UWORD)(v))
#define WRL(p,v) (*(ULONG *)(p) = (ULONG)(v))

static APTR exec_AllocMem(ULONG sz, ULONG attr)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register ULONG __p_sz __asm("d0") = sz;
    register ULONG __p_at __asm("d1") = attr;
    register APTR __r __asm("d0");
    __asm volatile ("jsr %/a6@(-198:W)\n"
	: "=r" (__r)
	: "a" (__p_sys), "r" (__p_sz), "r" (__p_at)
	: "a0","a1","memory");
    return __r;
}

static void exec_FreeMem(APTR p, ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_p __asm("a1") = p;
    register ULONG __p_sz __asm("d0") = sz;
    __asm volatile ("jsr %/a6@(-210:W)\n"
	:
	: "a" (__p_sys), "r" (__p_p), "r" (__p_sz)
	: "a0","d1","memory");
}

static void exec_Remove(APTR n)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_n __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)\n"
	:
	: "a" (__p_sys), "r" (__p_n)
	: "a0","d0","d1","memory");
}
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

struct HuffBase {
    struct Library lib;
};

extern APTR xpkinfo;		/* descriptor in the glue file */
extern ULONG segcell;		/* code-resident seglist cell   */

/* ---------------------------------------------------------------- */
/* password hash: seeds d1=0xC0DE, reloads only d1.b per byte	    */
/* ---------------------------------------------------------------- */

static ULONG pwhash(const UBYTE *pw)
{
    ULONG h = 0xabadcafe;
    UWORD t = 0xc0de;
    const UBYTE *p = pw;

    while (*p) {			/* stage 1: sum */
	t = (UWORD)((t & 0xff00) | *p++);/* moveb leaves t.hi=0xc0 */
	h = (h & 0xffff0000) | ((h + t) & 0xffff);
    }
    h = (h << 16) | (h >> 16);		/* swap */
    p = pw;
    while (*p) {			/* stage 2: xor + rol8 */
	UWORD w;
	t = (UWORD)((t & 0xff00) | *p++);
	w = (UWORD)(h ^ t);
	h = (h & 0xffff0000) | (((w << 8) | (w >> 8)) & 0xffff);
    }
    return h;
}

/* ---------------------------------------------------------------- */
/* lifecycle							    */
/* ---------------------------------------------------------------- */

struct Library *LibOpen(struct HuffBase *b REGPARM_A6)
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

static BPTR expunge_body(struct HuffBase *b)
{
    BPTR seg = segcell;		/* code cell, not lib+34 */
    ULONG sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
    exec_Remove(b);
    exec_FreeMem(p, sz);		/* the 0x130 stub call is a no-op */
    return seg;
}

LONG LibClose(struct HuffBase *b REGPARM_A6)
{
    if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

BPTR LibExpunge(struct HuffBase *b REGPARM_A6)
{
    if (b->lib.lib_OpenCnt) {
	/* original bug: a6 was reloaded with SysBase before the
	   flag write, so "bset #3,14(a6)" lands on ExecBase+14
	   instead of the library's flags -- deferred expunge
	   can never fire, Close-to-zero is a plain Close */
	((UBYTE *)EXECBASE)[14] |= LIBF_DELEXP;
	return 0;
    }
    return expunge_body(b);
}

LONG LibNull(struct HuffBase *b REGPARM_A6)
{
    (void)b;
    return 0;
}

APTR XpksPackerInfo(struct XpkSubParams *xsp REGPARM_A0,
		    struct HuffBase *b REGPARM_A6)
{
    (void)xsp; (void)b;
    return &xpkinfo;
}

/* ---------------------------------------------------------------- */
/* pack								    */
/* ---------------------------------------------------------------- */

struct HuffN {			/* 32-byte node record	    */
    struct HuffN *link;		/* +0  sorted-list link	    */
    UWORD  count;		/* +4  symbol count	    */
    UBYTE  sym;			/* +6  byte value	    */
    UBYTE  flag;		/* +7  4=leaf 1=int 5=root */
    struct HuffN *parent;	/* +8  parent link	    */
    struct HuffN *c0, *c1;	/* +12/+16 children	    */
    UWORD  dmark;		/* +20 0/1 branch, -1 root */
    UBYTE  pad[10];
};

#define PACKALLOC  29476
#define PACK_HIST  8		/* u16 hist[256]	    */
#define PACK_LEAF  544		/* 32B leaf records	    */
#define PACK_INT   8768		/* 32B internal records    */
#define PACK_ROOT  16928	/* root ptr		    */
#define PACK_TAB   16932	/* u32 codetab[256]	    */
#define PACK_REC   21028	/* code records		    */

LONG XpksPackChunk(struct XpkSubParams *xsp REGPARM_A0,
		   struct HuffBase *b REGPARM_A6)
{
    UBYTE *a5, *in, *out, *a1, *a4, *rec;
    ULONG inlen, i;
    UWORD *hist;
    struct HuffN *leaves, *freei, *n, *head, *a0p, *a1p, *a2p, *a3p;
    ULONG *tab;
    LONG d0, d1, d2, d3, d4, d5, d6;
    const UBYTE *pw;

    a5 = (UBYTE *)exec_AllocMem(PACKALLOC, 0x10001);
    if (!a5) return -7;
    WRL(a5, (ULONG)(XPTR)xsp);
    WRL(a5 + 4, (ULONG)(XPTR)b);
    in    = (UBYTE *)xsp->xsp_InBuf;
    inlen = xsp->xsp_InLen;
    out   = (UBYTE *)xsp->xsp_OutBuf;
    WRL(a5 + 520, (ULONG)(XPTR)in);
    *(ULONG *)(a5 + 524) = inlen;
    WRL(a5 + 528, (ULONG)(XPTR)out);
    *(ULONG *)(a5 + 536) = xsp->xsp_OutBufLen;

    /* ---- histogram (u16 counts, dbf word-bound loop) ---- */
    hist = (UWORD *)(a5 + PACK_HIST);
    {
	UWORD cnt = (UWORD)(inlen - 1);
	const UBYTE *p = in;
	for (;;) {
	    hist[*p++]++;
	    if (--cnt == 0xffff)
		break;
	}
    }

    /* ---- leaf records for used bytes (contiguous) ---- */
    leaves = (struct HuffN *)(a5 + PACK_LEAF);
    a1p = leaves;
    for (i = 0; i < 256; i++)
	if (hist[i]) {
	    a1p->link  = (struct HuffN *)(XPTR)-1;
	    a1p->count = hist[i];
	    a1p->sym   = (UBYTE)i;
	    a1p->flag  = 4;
	    a1p++;
	}
    /* next slot's flag stays 0 (MEMF_CLEAR) = scan terminator */

    /* ---- sorted list: rescan for the max-count unlinked leaf,
       prepend -> head ends ordered ascending ---- */
    head = 0;
    for (;;) {
	struct HuffN *best = 0;
	UWORD bc = 0;
	for (n = leaves; n->flag; n++) {
	    if ((XPTR)n->link != (XPTR)-1)
		continue;			/* already linked */
	    if (bc > n->count)
		continue;			/* BHI: worse   */
	    bc = n->count;			/* take when bc
						   <= count    */
	    best = n;
	}
	if (!best)
	    break;
	best->link = head;
	head = best;
    }

    /* ---- pairwise merge into the Huffman tree ---- */
    freei = (struct HuffN *)(a5 + PACK_INT);
    a0p = head;
    if (a0p->link == 0) {
	/* single-symbol input: build a pseudo internal root so the
	   leaf still gets a 1-bit code '0' */
	a2p = freei++;
	a0p->dmark = 0;
	a2p->c0 = a0p;
	a0p->parent = a2p;
	a0p = a2p;
    } else {
	for (;;) {
	    if (a0p->link == 0)		/* single node -> root */
		break;
	    a1p = a0p->link;			/* second node   */
	    a2p = freei++;
	    a0p->dmark = 0;
	    a1p->dmark = 1;
	    a2p->count = (UWORD)(a0p->count + a1p->count);
	    a2p->flag = 1;
	    a2p->c0 = a0p;
	    a2p->c1 = a1p;
	    a0p->parent = a2p;
	    a1p->parent = a2p;
	    a0p = a1p->link;			/* new head      */
	    if (!a0p)
		a0p = a2p;			/* merged last 2 */
	    else {
		/* reinsert a2p into the ascending list after a0p */
		d0 = a2p->count;
		if ((UWORD)d0 <= a0p->count) {
		    a2p->link = a0p;
		    a0p = a2p;
		} else {
		    a3p = a0p;
		    for (;;) {
			if (a3p->link == 0) {
			    a3p->link = a2p;
			    a2p->link = 0;
			    break;
			}
			a1p = a3p;
			a3p = a3p->link;
			if ((UWORD)d0 <= a3p->count) {
			    a1p->link = a2p;
			    a2p->link = a3p;
			    break;
			}
		    }
		}
	    }
	}
    }
    a0p->flag = 5;
    a0p->dmark = 0xffff;
    *(struct HuffN **)(a5 + PACK_ROOT) = a0p;

    /* ---- serialize: per leaf, emit {len-1, code MSB-first} ---- */
    tab = (ULONG *)(a5 + PACK_TAB);
    rec = a5 + PACK_REC;
    {
	UWORD path[512];
	for (n = leaves; n->flag; n++) {
	    struct HuffN *p;
	    LONG len = -1;
	    int npush = 0;
	    for (p = n; (SHORT)p->dmark >= 0; p = p->parent) {
		path[npush++] = p->dmark;	/* leaf -> root  */
		len++;
	    }
	    tab[n->sym] = (XPTR)rec;
	    *rec++ = (UBYTE)len;
	    d2 = 0; d3 = 7;
	    while (len-- >= 0) {
		d2 = (d2 << 1) | path[--npush];	/* root -> leaf  */
		if (--d3 < 0) { d3 = 7; *rec++ = (UBYTE)d2; }
	    }
	    if (d3 != 7) { d3++; d2 <<= d3; *rec++ = (UBYTE)d2; }
	}
    }

    /* ---- output budget sanity check ---- */
    if (*(ULONG *)(a5 + 536) <= 6)
	goto budget;

    a1 = out;
    a4 = out + inlen;			/* budget: outbuf + inlen */
    WRW(a1, 0); a1 += 2;
    pw = (const UBYTE *)xsp->xsp_Password;
    WRL(a1, pw ? pwhash(pw) : 0xabadcafe);
    a1 += 4;

    /* ---- emit code table: 0xff absent, else len-1 + code ---- */
    for (i = 0; i < 256; i++) {
	ULONG rp = tab[i];
	if (!rp) {
	    *a1++ = 0xff;
	    if (a1 >= a4) goto budget;
	} else {
	    UBYTE *r = (UBYTE *)(XPTR)rp;
	    LONG len = *r++;
	    *a1++ = (UBYTE)len;
	    if (a1 >= a4) goto budget;
	    len >>= 3;
	    do {
		*a1++ = *r++;
		if (a1 >= a4) goto budget;
	    } while (len-- > 0);
	}
    }

    /* ---- emit input data: codes MSB-first into bytes;
	   symbol loop is dbf word-bound like the original ---- */
    d4 = 7;			/* bits left in accumulator */
    d6 = 0;
    {
	UWORD cnt = (UWORD)(inlen - 1);
	const UBYTE *p = in;
	for (;;) {
	    UBYTE *r = (UBYTE *)(XPTR)tab[*p++];
	    LONG bits = *r++;
	    d3 = 0;
	    while (bits-- >= 0) {
		if (--d3 < 0) { d3 = 7; d5 = *r++; }
		d6 = (d6 << 1) | ((d5 >> 7) & 1);
		d5 = (d5 << 1) & 0xff;
		if (--d4 < 0) {
		    d4 = 7;
		    *a1++ = (UBYTE)d6;
		    if (a1 >= a4) goto budget;
		}
	    }
	    if (--cnt == 0xffff)
		break;
	}
    }
    if (d4 != 7) {
	if (a1 >= a4) goto budget;
	d4++;
	d6 <<= d4;
	*a1++ = (UBYTE)d6;
    }

    d1 = (LONG)(a1 - out);
    *(ULONG *)(a5 + 532) = d1;
    *(ULONG *)(a5 + 540) = d1;
    xsp->xsp_OutLen = (ULONG)d1;

    /* ---- scramble over out[6..outLen) when password set;
	   subq.w + dbf: the count is word-bound ---- */
    if (pw) {
	const UBYTE *a3 = pw;
	UBYTE *q = out + 6;
	UWORD cnt = (UWORD)((LONG)xsp->xsp_OutLen - 7);
	LONG p = *a3;
	for (;;) {
	    LONG c = *q;
	    LONG k = *a3++;
	    if (!k) { a3 = pw; k = *a3++; }
	    c = (UBYTE)((UBYTE)(c ^ k) + (UBYTE)p);
	    *q++ = (UBYTE)c;
	    p = c;
	    if (--cnt == 0xffff)
		break;
	}
    }

    exec_FreeMem(a5, PACKALLOC);
    return 0;

budget:
    exec_FreeMem(a5, PACKALLOC);
    return xsp->xsp_Password ? -10 : -17;
}

/* ---------------------------------------------------------------- */
/* unpack							    */
/* ---------------------------------------------------------------- */

/* 10-byte trie node: mark@0 (0=int/0xff=leaf), sym@1,
   left@2 (bit0), right@6 (bit1) -- raw bytes, unaligned longs.
   HOST_TEST uses a padded struct (pointers are 64-bit there);
   the m68k layout is the faithful 10 bytes.		     */
#ifdef HOST_TEST
struct TrieN { UBYTE mark, sym; UBYTE pad[2]; UBYTE *left, *right; };
#define TNODESZ	    sizeof(struct TrieN)
#define TN_LEFT(p)  (((struct TrieN *)(p))->left)
#define TN_RIGHT(p) (((struct TrieN *)(p))->right)
#define TN_SETL(p,v) (((struct TrieN *)(p))->left = (v))
#define TN_SETR(p,v) (((struct TrieN *)(p))->right = (v))
#else
#define TNODESZ	    10
#define TN_LEFT(p)  ((UBYTE *)(XPTR)RDL((p) + 2))
#define TN_RIGHT(p) ((UBYTE *)(XPTR)RDL((p) + 6))
#define TN_SETL(p,v) WRL((p) + 2, (ULONG)(XPTR)(v))
#define TN_SETR(p,v) WRL((p) + 6, (ULONG)(XPTR)(v))
#endif

#define UNPACKALLOC 70682
#define UPK_TRIE    38		/* 10B nodes, 511 slots    */
#define UPK_DESCR   5148	/* descramble buffer	    */

LONG XpksUnpackChunk(struct XpkSubParams *xsp REGPARM_A0,
		     struct HuffBase *b REGPARM_A6)
{
    UBYTE *a5, *a0, *a1;
    const UBYTE *in, *pw;
    UBYTE *out;
    ULONG inlen, expected;
    LONG d0, d4;
    UBYTE *root, *next, *cur;

    a5 = (UBYTE *)exec_AllocMem(UNPACKALLOC, 0x10001);
    if (!a5) return -7;
    WRL(a5, (ULONG)(XPTR)xsp);
    WRL(a5 + 4, (ULONG)(XPTR)b);
    in = (const UBYTE *)xsp->xsp_InBuf;
    inlen = xsp->xsp_InLen;
    out = (UBYTE *)xsp->xsp_OutBuf;
    expected = xsp->xsp_OutLen;
    *(ULONG *)(a5 + 26) = inlen - 6;
    WRL(a5 + 22, (ULONG)(XPTR)out);
    *(ULONG *)(a5 + 30) = expected;
    WRW(a5 + 8, RDW(in));
    WRL(a5 + 10, RDL(in + 2));

    if (RDW(a5 + 8) != 0)
	goto bad;

    pw = (const UBYTE *)xsp->xsp_Password;
    a0 = (UBYTE *)in + 6;
    if (pw) {
	const UBYTE *a3;
	if (pwhash(pw) != RDL(a5 + 10))
	    goto wrongpw;
	/* descramble in[6..inlen) into a5+5148; subq.w +
	   dbf: the count is word-bound ---- */
	{
	    UBYTE *dst = a5 + UPK_DESCR;
	    const UBYTE *src = in + 6;
	    UWORD cnt = (UWORD)((LONG)(inlen - 6) - 1);
	    LONG prev = *pw;
	    a3 = pw;
	    for (;;) {
		LONG c = *src++;
		LONG pc = c;
		LONG k = *a3++;
		if (!k) { a3 = pw; k = *a3++; }
		c = (UBYTE)(c - (UBYTE)prev);
		c = (UBYTE)(c ^ k);
		*dst++ = (UBYTE)c;
		prev = pc;
		if (--cnt == 0xffff)
		    break;
	    }
	    a0 = a5 + UPK_DESCR;
	}
    }
    WRL(a5 + 14, (ULONG)(XPTR)a0);

    /* ---- build the decode trie ---- */
    root = a5 + UPK_TRIE;
    WRL(a5 + 34, (ULONG)(XPTR)root);
    root[0] = 0;			/* root mark: internal */
    next = root + TNODESZ;
    {
	LONG i, byteidx = -1, d4b = 0, bitcnt = 0;
	for (i = 0; i < 256; i++) {
	    LONG len, b;
	    byteidx++;
	    len = *a0++;
	    if (len == 0xff)		/* absent */
		continue;
	    cur = root;
	    bitcnt = 0;
	    for (b = len; b >= 0; b--) {
		UBYTE *ch;
		if (--bitcnt < 0) {
		    d4b = *a0++;
		    bitcnt = 7;
		}
		if (d4b & 0x80) {	/* addb MSB -> carry */
		    ch = TN_RIGHT(cur);
		    if (!ch) { ch = next; TN_SETR(cur, ch); next += TNODESZ; }
		} else {
		    ch = TN_LEFT(cur);
		    if (!ch) { ch = next; TN_SETL(cur, ch); next += TNODESZ; }
		}
		cur = ch;
		d4b = (d4b << 1) & 0xff;
	    }
	    cur[1] = (UBYTE)byteidx;
	    cur[0] = 0xff;
	}
    }
    WRL(a5 + 18, (ULONG)(XPTR)a0);	/* bit-stream start */

    /* ---- decode: remain-1 full input bytes ---- */
    a0 = (UBYTE *)(XPTR)RDL(a5 + 18);
    a1 = out;
    cur = root;
    {
	/* d0 is a dbf counter: only its low word is tested, so
	   counts >= 64k or negative wrap like the original */
	LONG remain = (LONG)((UBYTE *)(XPTR)RDL(a5 + 14) +
			     *(ULONG *)(a5 + 26) - a0) - 2;
	UWORD cnt = (UWORD)remain;
	LONG d2b = 0;
	int bit;
	for (;;) {
	    d2b = *a0++;
	    for (bit = 0; bit < 8; bit++) {
		cur = (d2b & 0x80) ? TN_RIGHT(cur) : TN_LEFT(cur);
		d2b = (d2b << 1) & 0xff;
		if (cur[0]) {		/* 0xff -> leaf */
		    *a1++ = cur[1];
		    cur = root;
		}
	    }
	    if (--cnt == 0xffff)
		break;
	}

	/* ---- tail: emit (expected - produced) more symbols; the
	   dbf on d0 only runs after an emit, so the bit walk is
	   unbounded and reads a0 past the input end.  The zero
	   test is on the full long, the count on the word ---- */
	d0 = (LONG)expected - (a1 - out);
	if (d0) {
	    cnt = (UWORD)(d0 - 1);
	    d4 = 0;
	    for (;;) {
		if (--d4 < 0) { d2b = *a0++; d4 = 7; }
		cur = (d2b & 0x80) ? TN_RIGHT(cur) : TN_LEFT(cur);
		d2b = (d2b << 1) & 0xff;
		if (!cur[0])
		    continue;	    /* non-leaf: next bit */
		*a1++ = cur[1];
		cur = root;
		if (--cnt == 0xffff)
		    break;
	    }
	}
    }

    exec_FreeMem(a5, UNPACKALLOC);
    return 0;

bad:
    exec_FreeMem(a5, UNPACKALLOC);
    return -26;
wrongpw:
    exec_FreeMem(a5, UNPACKALLOC);
    return -32;
}
