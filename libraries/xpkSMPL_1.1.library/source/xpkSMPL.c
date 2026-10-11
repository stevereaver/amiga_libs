/*
**	xpkSMPL.c -- C reconstruction of xpkSMPL.library 1.1
**	"Sample packer" -- dynamic huffman crunch algorithm with
**	delta precoding.
**
**	Vectors (word-offset functab):
**	  -6  LibOpen        -24 LibNull         -42 XpksPackFree
**	  -12 LibClose       -30 XpksPackerInfo  -48 LibNull (PackReset)
**	  -18 LibExpunge     -36 XpksPackChunk   -54 XpksUnpackChunk
**	                       -60 XpksPackFree
**
**	Both wrappers share a prologue: if xsp_Sub[0] is NULL,
**	AllocVec(0x3800) is stored there (returns -7 on failure);
**	XpksPackFree releases it via FreeVec.
**
**	Workmem layout (0x3800 bytes):
**	  wk+0x0000  pack: {xsp, pad, src, inlen} slots
**	           unpack: binary trie, U32 per node
**	                   {bit0-child off, bit1-child off} or
**	                   0xffffff00|sym leaf; root at +0
**	  wk+0x0010  pack: sorted-list head node
**	  wk+0x0028  pack: 24-byte node arena, 514 entries max
**	  wk+0x0800  unpack: 1024-entry U16 fast table;
**	                   leaf -> (unconsumed<<8)|sym, else
**	                   node offset - 0x800 (negative)
**	  wk+0x3010  pack: 256-byte code-length table
**	  wk+0x3110  pack: 256 x U32 code-value table
**	  wk+0x3510  pack: 256 x U16 delta histogram
**
**	Shipped quirks reproduced verbatim:
**	  - inlen is decremented as a WORD; a low word of 0 runs
**	    exactly 0x10000 samples regardless of the real length.
**	  - the inlen<2 guard tests the LOW WORD (`lsrw; subq; bcs`),
**	    so inlen 0x10000/0x10001 is rejected.
**	  - the len-0 length-table path decrements space by 4 with
**	    no flush check and clears the whole accumulator,
**	    dropping pending bits; space can then drift so negative
**	    that a later `lsll` count wraps mod 64 -- corrupts the
**	    stream for sparse histograms.
**	  - the length-table code emit uses the inline writer
**	    (single flush only): lens >16+space leave `space`
**	    negative and the lsl count wraps mod 64 -- codes longer
**	    than 16 bits are mis-emitted in the LENS table while the
**	    DATA emit (0x42c) handles them correctly.  Deep trees
**	    produce un-decodable output; reproduced as shipped.
**	  - lens >= 31 emit `len-31` truncated to 8 bits -- nibble
**	    becomes 0 ("absent symbol") -- also unreachable in
**	    practice.
**	  - the decode count is `subql/subqw`: outlen wraps mod
**	    0x10000 (outlen 0x10001 decodes 1 byte; outlen 0 runs
**	    0x10000 iterations).
**	  - the unpacker reads up to 2 bytes past the compressed
**	    tail; the packer always appends a 4-byte pad long.
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

/* workmem offsets */
#define WK_TRIE    0x0000
#define WK_HEAD    0x0010
#define WK_NODES   0x0028
#define WK_DECTAB  0x0800
#define WK_LENTAB  0x3010
#define WK_CODETAB 0x3110
#define WK_HIST    0x3510
#define WK_SIZE    0x3800

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

/* -------------------------------------------------------------- */
/* exec calls							    */
/* -------------------------------------------------------------- */

#ifdef HOST_TEST
extern APTR host_AllocVec(ULONG sz);
extern void host_FreeVec(APTR p);
extern void host_Remove(void *n);
extern void host_FreeMem(void *p, ULONG sz);
#define AllocVec(sz) host_AllocVec(sz)
#define FreeVec(p)   host_FreeVec(p)
#else
static APTR AllocVec(ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register ULONG __p_sz __asm("d0") = sz;
    register APTR __r __asm("d0");
    __asm volatile ("jsr %/a6@(-684:W)\n"
        : "=r" (__r)
        : "a" (__p_sys), "r" (__p_sz)
        : "a0", "a1", "d1", "memory");
    return __r;
}

static void FreeVec(APTR p)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_p __asm("a1") = p;
    __asm volatile ("jsr %/a6@(-690:W)\n"
        :
        : "a" (__p_sys), "a" (__p_p)
        : "a0", "d0", "d1", "memory");
}

static void Remove_LVO(struct Library *n)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register struct Library *__p_n __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)\n"
        :
        : "a" (__p_sys), "a" (__p_n)
        : "a0", "d0", "d1", "memory");
}

static void FreeMem_LVO(APTR p, ULONG sz)
{
    register APTR __p_sys __asm("a6") = SYSBASE;
    register APTR __p_p __asm("a1") = p;
    register ULONG __p_sz __asm("d0") = sz;
    __asm volatile ("jsr %/a6@(-210:W)\n"
        :
        : "a" (__p_sys), "a" (__p_p), "r" (__p_sz)
        : "a0", "d1", "memory");
}
#endif

/* -------------------------------------------------------------- */
/* library lifecycle						    */
/* -------------------------------------------------------------- */

struct Library *LibOpen(struct SmplBase *b __asm("a6"))
{
    b->lib.lib_OpenCnt++;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

BPTR LibExpunge(struct SmplBase *b __asm("a6"))
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    } else {
	BPTR seg = (BPTR)b->b_SegList;
#ifdef HOST_TEST
	host_Remove(&b->lib);
	host_FreeMem(&b->lib, (ULONG)-((SHORT)b->lib.lib_NegSize) + b->lib.lib_PosSize);
#else
	Remove_LVO(&b->lib);
	FreeMem_LVO(&b->lib, (ULONG)-((SHORT)b->lib.lib_NegSize) + b->lib.lib_PosSize);
#endif
	return seg;
    }
}

LONG LibClose(struct SmplBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt)
	return 0;
    if (b->lib.lib_Flags & LIBF_DELEXP)
	return (LONG)LibExpunge(b);
    return 0;
}

LONG LibNull(void)
{
    return 0;
}

/* -------------------------------------------------------------- */
/* packer							    */
/* -------------------------------------------------------------- */

/* 24-byte node record.  Fields hold raw pointers on the m68k
 * binary; here they hold wk-relative byte offsets so the layout
 * stays 24 bytes on any host (0 = null link).			    */
struct SmplNode {
    ULONG  n_next;		/* +0 */
    UWORD  n_freq;		/* +4 */
    UWORD  n_sym;		/* +6 */
    ULONG  n_parent;		/* +8 */
    ULONG  n_c0, n_c1;		/* +12,+16 */
    UWORD  n_edge;		/* +20 */
    UWORD  n_pad;		/* +22 */
};
#define ND(wk, off) ((struct SmplNode *)((wk) + (off)))

/* Inline writer (0x39c/0x3b0): `space` is a BYTE counter
 * (subq.b/add.b/sub.b on d6); the flush check is a byte-borrow
 * test, and the lsl count wraps mod 64.  len >16+space leaves
 * `space` negative so the code is mis-emitted in the LENS table
 * while the DATA emit splits correctly -- shipped defect.
 * Reproduced verbatim.						    */
struct bitw {
    UBYTE  *p;			/* a6: output cursor */
    ULONG   acc;		/* d7: accumulator   */
    int     space;		/* d6.b: free bits, signed byte */
};

static ULONG lsl_mod64(ULONG code, int space)
{
    int c = space & 63;
    return c >= 32 ? 0 : code << c;
}

static void emit_inline(struct bitw *b, ULONG code, int len)
{
    UBYTE s = (UBYTE)b->space;
    UBYTE ns = (UBYTE)(s - (UBYTE)len);
    if (ns > s) {			/* sub.b borrow */
	b->acc = (b->acc >> 16) | (b->acc << 16);	/* rol16 */
	wr16(b->p, (UWORD)b->acc);
	b->p += 2;
	ns = (UBYTE)(ns + 16);
	b->acc &= 0xffff0000;			/* clrw d7 */
    }
    b->space = (int)(signed char)ns;
    b->acc |= lsl_mod64(code, (UBYTE)ns);
}

/* Data-path writer (0x42c): len >=16 splits into two <=16 emits.  */
static void emit_code(struct bitw *b, ULONG code, int len)
{
    if (len >= 16) {
	UWORD lo = (UWORD)code;
	code = (code >> 16) | (code << 16);	/* rol16 */
	emit_inline(b, code, len - 16);
	len = 16;
	code = lo;
    }
    emit_inline(b, code, len);
}

static LONG pack_body(struct XpkSubParams *xsp, UBYTE *wk)
{
    UBYTE *src = (UBYTE *)xsp->xsp_InBuf;
    ULONG  inlen = xsp->xsp_InLen;
    ULONG *slot = (ULONG *)wk;
    UWORD *hist = (UWORD *)(wk + WK_HIST);
    UBYTE *lentab = wk + WK_LENTAB;
    ULONG *codetab = (ULONG *)(wk + WK_CODETAB);
    struct SmplNode *head = (struct SmplNode *)(wk + WK_HEAD);
    struct SmplNode *arena = (struct SmplNode *)(wk + WK_NODES);
    struct SmplNode *n;
    ULONG np;
    struct bitw bw;
    int i, prev, cnt;

    slot[0] = (ULONG)xsp;
    slot[2] = (ULONG)src;
    slot[3] = inlen;

    /* clear 512B hist + 256B lentab (one 16-pass moveml loop) */
    for (i = 0; i < 256; i++) {
	hist[i] = 0;
	lentab[i] = 0;
    }

    /* delta histogram -- word-length loop count */
    cnt = (UWORD)inlen;
    if (!cnt)
	cnt = 0x10000;
    prev = 0;
    for (i = 0; i < cnt; i++) {
	int d = src[i];
	hist[(d - prev) & 0xff]++;
	prev = d;
    }

    /* sorted leaf list (descending freq), head at wk+0x10 */
    head->n_next = 0;
    head->n_freq = 0;
    np = WK_NODES;
    for (i = 255; i >= 0; i--) {
	UWORD f = hist[i];
	ULONG cur, nxt;
	if (!f)
	    continue;
	cur = WK_HEAD;
	while ((nxt = ND(wk, cur)->n_next) && f >= ND(wk, nxt)->n_freq)
	    cur = nxt;
	ND(wk, np)->n_next = nxt;
	ND(wk, np)->n_freq = f;
	ND(wk, np)->n_sym = (UWORD)i;
	ND(wk, cur)->n_next = np;
	np += 24;
    }
    ND(wk, np)->n_sym = 0xffff;	/* st a4@(6): sentinel high byte */

    /* merge: sorted pair-merge huffman */
    {
	ULONG a0 = head->n_next, root = 0;
	for (;;) {
	    ULONG n0 = a0, n1 = ND(wk, n0)->n_next, rest, nn;
	    if (!n1) {
		/* single node: fake parent in the sentinel slot */
		ND(wk, n0)->n_edge = 0x4000;
		ND(wk, np)->n_c0 = n0;
		ND(wk, n0)->n_parent = np;
		root = np;
		break;
	    }
	    ND(wk, n0)->n_edge = 0x4000;
	    ND(wk, n1)->n_edge = 0x8000;
	    nn = np;
	    np += 24;
	    ND(wk, nn)->n_freq = ND(wk, n0)->n_freq + ND(wk, n1)->n_freq;
	    ND(wk, nn)->n_c0 = n0;
	    ND(wk, nn)->n_c1 = n1;
	    ND(wk, n0)->n_parent = ND(wk, n1)->n_parent = nn;
	    rest = ND(wk, n1)->n_next;
	    if (!rest) {
		root = nn;
		break;
	    }
	    if (ND(wk, nn)->n_freq < ND(wk, rest)->n_freq) {
		ND(wk, nn)->n_next = rest;
		a0 = nn;
		continue;
	    }
	    {
		ULONG pv = rest, c = ND(wk, rest)->n_next;
		while (c && ND(wk, nn)->n_freq >= ND(wk, c)->n_freq) {
		    pv = c;
		    c = ND(wk, c)->n_next;
		}
		ND(wk, pv)->n_next = nn;
		ND(wk, nn)->n_next = c;
		a0 = rest;
	    }
	}
	ND(wk, root)->n_edge = 0;
    }

    /* walk up the tree assigning codes; edge bits pushed into the
     * MSB then right-justified.  Stops at the first arena slot
     * with sym >= 0x8000 (internal nodes inherit the sentinel).  */
    for (n = arena; (SHORT)n->n_sym >= 0; n++) {
	ULONG a1 = (ULONG)((UBYTE *)n - wk);
	ULONG code = 0;
	int len = 0;
	while (ND(wk, a1)->n_edge && len < 32) {
	    /* addw d0,d0 + roxrl #1,d2: each edge shifts the
	     * accumulated code right and enters at bit31 --
	     * leaf edge ends up LSB, root edge MSB.	    */
	    code = (code >> 1) |
		((ND(wk, a1)->n_edge & 0x8000) ? 0x80000000UL : 0);
	    a1 = ND(wk, a1)->n_parent;
	    len++;
	}
	code >>= (32 - len);
	lentab[n->n_sym] = (UBYTE)len;
	codetab[n->n_sym] = code;
    }

    /* `lsrw #1; subqw #1; bcs` on the long: inlen low word < 2
     * rejects (incl. 0x10000).  Checked AFTER the tree build.    */
    if ((UWORD)inlen < 2)
	return -17;

    /* emit: BE16(1) sig + 256 nibbled lens + delta codes + pad */
    bw.p = (UBYTE *)xsp->xsp_OutBuf;
    wr16(bw.p, 1);
    bw.p += 2;
    bw.acc = 0;
    bw.space = 32;
    for (i = 0; i < 256; i++) {
	int len = lentab[i];
	if (!len) {
	    /* shipped: subq.b #4 (byte, no flush check, wraps
	     * mod 256), then moveq #0,d7 wipes ALL pending bits */
	    bw.space = (int)(signed char)((UBYTE)bw.space - 4);
	    bw.acc = 0;
	} else {
	    if (len < 15)
		emit_inline(&bw, (ULONG)len, 4);	/* inline 4b len */
	    else
		emit_inline(&bw, (ULONG)((len - 31) & 0xff), 8); /* inline 8b len */
	    emit_code(&bw, codetab[i], len);	/* bsr 0x3ec */
	}
    }

    /* `subqw #1; bnes` on the long: count = inlen low word,
     * 0 wraps to 0x10000 iterations.				    */
    prev = 0;
    cnt = (int)(UWORD)inlen;
    if (!cnt)
	cnt = 0x10000;
    for (i = 0; i < cnt; i++) {
	int cur = src[i];
	int delta = (cur - prev) & 0xff;
	prev = cur;
	emit_code(&bw, codetab[delta], lentab[delta]);
    }
    wr32(bw.p, bw.acc);
    bw.p += 4;
    xsp->xsp_OutLen = (ULONG)(bw.p - (UBYTE *)xsp->xsp_OutBuf);
    return 0;
}

/* -------------------------------------------------------------- */
/* unpacker							    */
/* -------------------------------------------------------------- */

/* bit reader: d7 = window (pending bits above index `left`),
 * d6 = next-bit index counting down.				    */
struct bitr {
    const UBYTE *p;
    ULONG   win;
    int     left;
};

static void refill(struct bitr *r)
{
    /* rol d4,d7; movew a6@+,d7 -- the low word is REPLACED,
     * not ORed: rol16 parks consumed bits there.		    */
    r->win = ((r->win >> 16) | (r->win << 16)) & 0xffff0000UL;
    r->win |= rd16(r->p);
    r->p += 2;
    r->left += 16;
}

static ULONG getbits(struct bitr *r, int n)
{
    r->left -= n;
    if (r->left < 0)
	refill(r);
    return (r->win >> r->left) & ((1UL << n) - 1);
}

static LONG unpack_body(struct XpkSubParams *xsp, UBYTE *wk)
{
    const UBYTE *in = (const UBYTE *)xsp->xsp_InBuf;
    UBYTE *out = (UBYTE *)xsp->xsp_OutBuf;
    ULONG outlen = xsp->xsp_OutLen;	/* caller-set size */
    UWORD *tab = (UWORD *)(wk + WK_DECTAB);
    struct bitr br;
    int sym, i;

    if (rd16(in) != 1)
	return -26;
    in += 2;

    br.p = in;
    br.win = rd16(br.p);
    br.p += 2;
    br.left = 16;

    /* per-symbol lens -> decode trie at wk+0 (U16 offsets) */
    wr32(wk, 0);			/* clrl a5@: root {0,0} */
    {
	UWORD alloc = 4;
	for (sym = 0; sym < 256; sym++) {
	    ULONG nib = getbits(&br, 4);
	    int len, bit;
	    ULONG code;
	    UWORD off;
	    if (!nib)
		continue;
	    len = (nib == 15) ? (int)(15 + getbits(&br, 4)) : (int)nib;
	    if (len >= 16) {
		code = (getbits(&br, len - 16) << 16) | getbits(&br, 16);
	    } else {
		code = getbits(&br, len);
	    }
	    code <<= (32 - len);	/* MSB-justify */
	    off = 0;
	    for (bit = 0; bit < len; bit++) {
		int b = (code & 0x80000000) != 0;
		UWORD w;
		code <<= 1;
		w = rd16(wk + off + (b ? 2 : 0));
		if (!w) {
		    w = alloc;
		    alloc += 4;
		    wr16(wk + off + (b ? 2 : 0), w);
		    wr32(wk + w, 0);
		}
		off = w;
	    }
	    wr32(wk + off, 0xffffff00UL | (ULONG)sym);
	}
    }

    /* root fixup: bit1 field empty -> copy bit0 link */
    if (!rd16(wk + 2))
	wr16(wk + 2, rd16(wk));

    /* 1024-entry fast table: walk the trie per 10-bit prefix */
    for (i = 0; i < 1024; i++) {
	ULONG idx = (ULONG)i << 6;
	ULONG node = rd32(wk);
	int steps = 9;
	UWORD link = 0;
	for (;;) {
	    if (idx & 0x8000)
		link = (UWORD)node;	/* field2 = bit1 child */
	    else
		link = (UWORD)(node >> 16); /* field0 = bit0 child */
	    idx <<= 1;
	    node = rd32(wk + link);
	    if (node & 0x80000000) {
		tab[i] = (UWORD)((steps << 8) | (node & 0xff));
		break;
	    }
	    if (--steps < 0) {
		tab[i] = (UWORD)(link - 0x800);
		break;
	    }
	}
    }

    /* decode: huffman -> delta accumulate -> byte out.
     * count = 1 + (UWORD)(outlen-1): wraps mod 0x10000.	    */
    {
	int acc = 0;
	ULONG cnt = (ULONG)(UWORD)(outlen - 1) + 1;
	while (cnt--) {
	    ULONG e = getbits(&br, 10);
	    SHORT te = (SHORT)tab[e];
	    if (te < 0) {
		ULONG node = rd32(wk + 0x800 + (SHORT)te);
		/* entry consumes one bit; the walk decrements the
		 * bit index per step (dbmi semantics)	    */
		br.left--;
		if (br.left < 0) {
		    br.win = ((br.win >> 16) | (br.win << 16)) & 0xffff0000UL;
		    br.win |= rd16(br.p);
		    br.p += 2;
		    br.left = 15;
		}
		for (;;) {
		    if (!(br.win & (1UL << br.left)))
			node = (node >> 16) | (node << 16);
		    node = rd32(wk + (UWORD)node);
		    if (node & 0x80000000) {
			acc = (acc + (node & 0xff)) & 0xff;
			break;
		    }
		    if (--br.left < 0) {
			br.win = ((br.win >> 16) | (br.win << 16)) & 0xffff0000UL;
			br.win |= rd16(br.p);
			br.p += 2;
			br.left = 15;
		    }
		}
	    } else {
		acc = (acc + (te & 0xff)) & 0xff;
		br.left += (te >> 8) & 0xff;
	    }
	    *out++ = (UBYTE)acc;
	}
    }
    return 0;
}

/* -------------------------------------------------------------- */
/* public vectors						    */
/* -------------------------------------------------------------- */

APTR XpksPackerInfo(void)
{
    extern char xpkinfo[];
    return xpkinfo;
}

/* shared wrapper: alloc wk if absent, then run the codec body   */
static UBYTE *get_wk(struct XpkSubParams *xsp, LONG *err)
{
    UBYTE *wk = (UBYTE *)xsp->xsp_Sub[0];
    if (!wk) {
	wk = AllocVec(WK_SIZE);
	xsp->xsp_Sub[0] = (ULONG)wk;
	if (!wk)
	    *err = -7;
    }
    return wk;
}

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    LONG err = 0;
    UBYTE *wk = get_wk(xsp, &err);
    return err ? err : pack_body(xsp, wk);
}

LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    LONG err = 0;
    UBYTE *wk = get_wk(xsp, &err);
    return err ? err : unpack_body(xsp, wk);
}

LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"))
{
    APTR wk = (APTR)xsp->xsp_Sub[0];
    xsp->xsp_Sub[0] = 0;
    FreeVec(wk);
    return 0;
}
