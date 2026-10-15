/*
**	xpkHUFF.c -- C reconstruction of xpkHUFF.library 1.0
**	"Huffman V1.0" (Marc Zimmerman, 1 Oct 2013).
**
**	XPK sublibrary: dynamic Huffman compression over raw bytes
**	with an optional password layer (stream hash + chained-XOR
**	scramble keyed on xsp_Password).  Vector map (AUTOINIT
**	word-offset functab):
**
**	  -6  LibOpen         -24 LibNull (entry stub)
**	  -12 LibClose        -30 XpksPackerInfo
**	  -18 LibExpunge      -36 XpksPackChunk
**	                      -42 XpksPackFree
**	                      -48 LibNull (PackReset no-op)
**	                      -54 XpksUnpackChunk
**	                      -60 XpksUnpackFree (== PackFree)
**
**	Stream layout:
**	  u16 0                    flag word (nonzero -> -26)
**	  u32 0xABADCAFE           plaintext marker, or password hash
**	  256 x len table          byte (len-1), or 0xFF for absent;
**				   len!=0: ceil(len/8) code bytes,
**				   code left-justified MSB-first
**	  data                     MSB-first bit stream of codes
**
**	When a password is set the packer writes the name hash
**	instead of 0xABADCAFE and scrambles all bytes from
**	offset 6 with c = (plain ^ pw[i]) + prev_cipher
**	(pw cycled, prev_cipher seeded with pw[0]).  The unpacker
**	re-verifies the hash (-32 on mismatch/missing password)
**	and unscrambles into workmem+0x1000.
**
**	Pack workmem (alloc 0x3208; a5 == Sub[0] == alloc+4):
**	  a5+0        saved SP for the -17/-27 bailout (longjmp)
**	  a5+4        list-head slot (22B node)
**	  a5+26       leaf/internal arena, 22B nodes
**	              {link@0, freq@4.w, sym@6.w, parent@8,
**	               left@12, right@16, mark@20.w}
**	  a5+11268    freq[256] U16 histogram, reused as lentab
**	  a5+11780    code[256] U32
**
**	Unpack workmem (alloc 0x1004 + inlen; a5 == Sub[0]):
**	  a5+0        trie: 4B nodes {u16 '0'child@0, u16 '1'child@2}
**		    word byte-offsets from a5; leaf longs are
**		    0xFFFFFF00+sym (negative = leaf)
**	  a5+2048     1024-entry U16 fast table for 10-bit prefixes:
**		    leaf -> (10-len)<<8 | sym; else nodeoff-0x800
**		    (negative, doubles as an A4-relative node offset)
**	  a5+4096     descramble buffer (inlen bytes, password only)
**
**	Shipped quirks reproduced verbatim:
**	  - unpack's magic test is CMPI.L #0xABADCAFE,(a1) at offset
**	    0 while the marker lives at offset 2: it can never hit
**	    (the flag word must be 0), so the +inlen allocation is
**	    taken unconditionally.
**	  - the descramble loop runs inlen-1+1 = inlen iterations
**	    starting at in+6: reads 5-6 bytes past the input buffer.
**	  - the name hash seeds d1=0xC0DE and only reloads d1.b per
**	    character: every byte contributes 0xC0xx, not the byte.
**	  - histogram/data counters are SUBQ.W/DBF loops: inlen 0
**	    wraps to 65536 samples and reads far past the buffer.
**	  - the output budget is a WORD register: only the low 16
**	    bits of inlen bound the emit loop.
**	  - emit bailout longjmps to the saved SP and reports -27
**	    when a password is set, -17 otherwise.
**	  - unpack reuses xsp_Sub[0] unconditionally; a packed
**	    0x3208 buffer is smaller than the 0x1004+inlen an
**	    encrypted stream needs when inlen > 0x2204.
**	  - the decode count is outlen-1 via SUBQ.L/DBF: outlen 0
**	    loops 65535 times writing past the output buffer.
**	  - a table where only the root's '0' side exists mirrors it
**	    to '1' (tst.w 2(a5)/move.w (a5),2(a5)).
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

struct HuffBase {
    struct Library lib;
    ULONG   b_SegList;		/* 0x22 seglist, stored by LibInit */
};

/* 22-byte huffman node inside the pack arena */
struct __attribute__((packed)) pnode {
    ULONG   link;		/* 0x00 sorted-list next	    */
    UWORD   freq;		/* 0x04				    */
    SHORT   sym;		/* 0x06 leaf sym; <0 sentinel	    */
    ULONG   parent;		/* 0x08				    */
    ULONG   left;		/* 0x0c '0' side (smaller freq)	    */
    ULONG   right;		/* 0x10 '1' side		    */
    UWORD   mark;		/* 0x14 0x4000/0x8000/0(root)	    */
};

/* pack workmem offsets (a5 == Sub[0] == alloc+4) */
#define PWK_SAVESP  0
#define PWK_HEAD    4
#define PWK_ARENA   26
#define PWK_HIST    11268
#define PWK_CODETAB 11780
#define PWK_ALLOC   0x3208

/* unpack workmem offsets */
#define UWK_FAST    2048		/* 1024-entry u16 prefix table  */
#define UWK_DEOB    0x1000		/* descramble buffer	    */
#define UWK_ALLOC   0x1004		/* base alloc (before +inlen) */

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

/* the original uses plain move.w/move.l (big-endian).  Use native
 * access on the target; the explicit BE helpers keep the host test
 * model identical.					      */
#ifdef HOST_TEST
#define NRD16(p)	rd16((const UBYTE *)(p))
#define NWR16(p, v)	wr16((UBYTE *)(p), (v))
#define NRD32(p)	rd32((const UBYTE *)(p))
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
struct Library *LibOpen(struct HuffBase *b __asm("a6"))
{
    ++b->lib.lib_OpenCnt;
    b->lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)b;
}

/* expunge body: removes + frees the library; returns the seglist */
static BPTR expunge_body(struct HuffBase *b)
{
    BPTR seg = b->b_SegList;
    ULONG  sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
    exec_Remove(b);
    exec_FreeMem(p, sz);
    return seg;
}

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge;
 * otherwise returns 0 via the hunk+0 entry stub.		    */
LONG LibClose(struct HuffBase *b __asm("a6"))
{
    if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge */
BPTR LibExpunge(struct HuffBase *b __asm("a6"))
{
    if (b->lib.lib_OpenCnt) {
	b->lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return expunge_body(b);
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

/*
**	password hash: d0 = 0xABADCAFE, d1 = 0xC0DE with only the
**	low byte reloaded per char (the 0xC0 prefix persists, so
**	every char contributes 0xC0xx).  Phase 1 adds each word
**	into d0's low half; phase 2 (after swap) xors each char
**	word into the low half and rol.w #8s it.
*/
static ULONG pwhash(const UBYTE *pw)
{
    ULONG d0 = 0xabadcafe;
    ULONG d1 = 0xc0de;
    const UBYTE *p;

    for (p = pw; ; p++) {
	d1 = (d1 & 0xff00) | *p;
	if (!*p)
	    break;
	d0 = (d0 & 0xffff0000) | ((d0 + d1) & 0xffff);
    }
    d0 = (d0 >> 16) | (d0 << 16);
    for (p = pw; ; p++) {
	ULONG lo;
	d1 = (d1 & 0xff00) | *p;
	if (!*p)
	    break;
	lo = (d0 ^ d1) & 0xffff;		/* eor.w d1,d0 */
	lo = ((lo << 8) | (lo >> 8)) & 0xffff;	/* rol.w #8 */
	d0 = (d0 & 0xffff0000) | lo;
    }
    return d0;
}

/* -------------------------------------------------------------- */
/* -36 XpksPackChunk						    */
/* -------------------------------------------------------------- */

/*
**	bit emitter: `acc` holds pending bits MSB-first, `space`
**	is the free-bit count at the bottom; emit ORs the code in
**	at [space..space+len-1] then flushes whole bytes while
**	space < 24.  Every written byte decrements the UWORD
**	budget (inlen-7); underflow is the -17/-27 bailout.
*/
struct emit {
    ULONG   acc;
    LONG    space;
    UBYTE  *out;
    UWORD   budget;
};

static int put_byte(struct emit *e, UBYTE b)
{
    if (!e->budget)
	return -1;
    --e->budget;
    *e->out++ = b;
    return 0;
}

static int emit_bits(struct emit *e, ULONG bits, int n)
{
    e->space -= n;
    e->acc |= bits << e->space;
    while (e->space < 24) {
	if (put_byte(e, (UBYTE)(e->acc >> 24)))
	    return -1;
	e->acc <<= 8;
	e->space += 8;
    }
    return 0;
}

/* split emit for len>16: (len-16) high bits then the low 16 */
static int emit_code(struct emit *e, ULONG code, int len)
{
    if (len > 16) {
	if (emit_bits(e, code >> 16, len - 16))
	    return -1;
	code &= 0xffff;
	len = 16;
    }
    return emit_bits(e, code, len);
}

LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   register struct HuffBase *b __asm("a6"))
{
    UBYTE *base;
    struct pnode *head, *arena, *m, *cur, *sec, *slot, *n;
    UWORD *hist, *lentab;
    ULONG *codetab;
    struct emit e;
    const UBYTE *src, *pw;
    ULONG inlen, outlen;
    int sym, i;

    base = (UBYTE *)xsp->xsp_Sub[0];
    if (!base) {
	base = exec_AllocMem(PWK_ALLOC);
	if (!base)
	    return -7;
	NWR32(base, PWK_ALLOC);
	base += 4;
	xsp->xsp_Sub[0] = (ULONG)base;
    }

    head    = (struct pnode *)(base + PWK_HEAD);
    arena   = (struct pnode *)(base + PWK_ARENA);
    lentab  = (UWORD *)(base + PWK_HIST);
    codetab = (ULONG *)(base + PWK_CODETAB);
    hist    = lentab;			/* histogram shares it */

    for (sym = 0; sym < 256; sym++)
	NWR16(&hist[sym], 0);

    src   = (const UBYTE *)xsp->xsp_InBuf;
    inlen = xsp->xsp_InLen;
    pw    = (const UBYTE *)xsp->xsp_Password;

    /* plain byte histogram; SUBQ.W/DBF -- inlen 0 wraps to 65536 */
    {
	UWORD cnt = (UWORD)(inlen - 1);
	const UBYTE *p = src;
	for (;;) {
	    UBYTE c = *p++;
	    NWR16(&hist[c], (UWORD)(NRD16(&hist[c]) + 1));
	    if (--cnt == (UWORD)-1)
		break;
	}
    }

    /* sorted leaf list, ascending freq, inserted BEFORE the
     * first node with freq >= new (before-equals); leaf slots
     * are allocated in symbol order 255..0		      */
    head->link = 0;
    head->freq = 0;
    slot = arena;
    for (sym = 255; sym >= 0; sym--) {
	UWORD f = NRD16(&hist[sym]);
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
	m->freq     = (UWORD)(cur->freq + sec->freq);
	m->left     = (ULONG)cur;
	m->right    = (ULONG)sec;
	cur->parent = (ULONG)m;
	sec->parent = (ULONG)m;
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
     * MSB-first via roxr; guard 32 -> bailout		      */
    for (n = arena; n->sym >= 0; n++) {
	struct pnode *w;
	ULONG c = 0;
	LONG d1 = 32;

	for (w = n; w->mark; w = (struct pnode *)w->parent) {
	    c = (c >> 1) | ((w->mark & 0x8000) ? 0x80000000UL : 0);
	    if (--d1 == -1)
		goto pack_bail;
	}
	c >>= d1;			/* lsrl d1,d2 */
	NWR16(&lentab[n->sym], (UWORD)(32 - d1));
	NWR32(&codetab[n->sym], c);
    }

    /* emit: flag, hash, len table, then data */
    e.acc    = 0;
    e.space  = 32;
    e.out    = (UBYTE *)xsp->xsp_OutBuf;
    e.budget = (UWORD)(inlen - 7);	/* SUBQ.W #7, then per byte */
    if ((UWORD)inlen < 7)
	goto pack_bail;			/* BCS -> bailout, pre-flag */

    wr16(e.out, 0);
    e.out += 2;
    wr32(e.out, pw ? pwhash(pw) : 0xabadcafe);
    e.out += 4;

    for (sym = 0; sym < 256; sym++) {
	UWORD len = NRD16(&lentab[sym]);
	if (!len) {
	    if (put_byte(&e, 0xff))
		goto pack_bail;
	} else {
	    ULONG code;
	    if (put_byte(&e, (UBYTE)(len - 1)))
		goto pack_bail;
	    code = NRD32(&codetab[sym]) << (32 - len);
	    for (i = 0; i < (((len - 1) >> 3) + 1); i++) {
		if (put_byte(&e, (UBYTE)(code >> 24)))
		    goto pack_bail;
		code <<= 8;
	    }
	}
    }

    {
	UWORD cnt = (UWORD)(inlen - 1);
	const UBYTE *p = src;
	for (;;) {
	    UBYTE c = *p++;
	    if (emit_code(&e, NRD32(&codetab[c]), NRD16(&lentab[c])))
		goto pack_bail;
	    if (--cnt == (UWORD)-1)
		break;
	}
    }

    if (e.space != 32) {		/* flush pending bits, 1 byte */
	if (put_byte(&e, (UBYTE)(e.acc >> 24)))
	    goto pack_bail;
    }

    outlen = (ULONG)(e.out - (UBYTE *)xsp->xsp_OutBuf);
    xsp->xsp_OutLen = outlen;

    /* password scramble: c = (plain ^ pw[i]) + prev_cipher */
    if (pw) {
	UBYTE *q = (UBYTE *)xsp->xsp_OutBuf + 6;
	const UBYTE *pp = pw;
	UBYTE d3 = pw[0];
	UWORD cnt = (UWORD)(outlen - 7);
	for (;;) {
	    UBYTE d1 = *q;
	    UBYTE k = *pp++;
	    if (!k) {
		pp = pw;
		k = *pp++;
	    }
	    d1 = (UBYTE)((d1 ^ k) + d3);
	    *q++ = d1;
	    d3 = d1;
	    if (--cnt == (UWORD)-1)
		break;
	}
    }
    return 0;

pack_bail:				/* LAB_0034: longjmp path */
    return pw ? -27 : -17;
}

/* -------------------------------------------------------------- */
/* -54 XpksUnpackChunk						    */
/* -------------------------------------------------------------- */

/*
**	bit reader: `win` is a left-draining buffer (refill shifts
**	old bits up, new byte in low).  `pos` tracks buffered bits
**	minus the 10-bit window size: valid bits are [0..pos+9],
**	the next 10 stream bits sit at [pos..pos+9], and deeper
**	bits descend from pos-1.
*/
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     register struct HuffBase *b __asm("a6"))
{
    UBYTE *base;
    const UBYTE *in, *ip;
    UBYTE *tab, *op;
    ULONG inlen, win;
    LONG pos;
    int i, sym;

    in = (const UBYTE *)xsp->xsp_InBuf;
    if (NRD16(in))
	return -26;

    /* CMPI.L #0xABADCAFE,(a1) at offset 0 -- can never match the
     * real marker at offset 2, so +inlen is taken always       */
    inlen = xsp->xsp_InLen;
    {
	ULONG memsz = UWK_ALLOC;
	if (rd32(in) != 0xabadcafe)
	    memsz += inlen;
	base = (UBYTE *)xsp->xsp_Sub[0];
	if (!base) {
	    base = exec_AllocMem(memsz);
	    if (!base)
		return -7;
	    NWR32(base, memsz);
	    base += 4;
	    xsp->xsp_Sub[0] = (ULONG)base;
	}
    }

    ip = in + 2;
    {
	ULONG stored = rd32(ip);
	ip += 4;
	if (stored != 0xabadcafe) {
	    const UBYTE *pw = (const UBYTE *)xsp->xsp_Password;
	    UBYTE *dst, *deob;
	    const UBYTE *pp;
	    UBYTE d3;
	    UWORD cnt;

	    if (!pw)
		return -32;
	    if (pwhash(pw) != stored)
		return -32;

	    /* unscramble inlen bytes from in+6 -> base+0x1000
	     * (overreads ~6 bytes past the input buffer)        */
	    dst = deob = base + UWK_DEOB;
	    pp = pw;
	    d3 = pw[0];
	    cnt = (UWORD)(inlen - 1);
	    for (;;) {
		UBYTE c = *ip++;
		UBYTE k = *pp++;
		if (!k) {
		    pp = pw;
		    k = *pp++;
		}
		*dst++ = (UBYTE)((c - d3) ^ k);
		d3 = c;
		if (--cnt == (UWORD)-1)
		    break;
	    }
	    ip = deob;
	}
    }

    /* trie build: nodes {u16 '0'child@0, u16 '1'child@2};
     * leaf nodes hold 0xFFFFFF00+sym			      */
    {
	UWORD next = 4;
	NWR32(base, 0);			/* clr root */
	for (sym = 0; sym < 256; sym++) {
	    int lb = *ip++;
	    ULONG code;
	    UBYTE *cur;
	    if (lb == 0xff)
		continue;
	    code = 0;
	    for (i = 0; i < ((lb >> 3) + 1); i++)
		code = (code << 8) | *ip++;
	    code <<= (32 - (((lb >> 3) + 1) << 3));	/* left-justify */
	    cur = base;
	    for (i = 0; i <= lb; i++) {			/* len = lb+1 bits */
		UBYTE *cw;
		UWORD off;
		if (code & 0x80000000UL) {		/* '1' -> word@2 */
		    cw = cur + 2;
		} else {				/* '0' -> word@0 */
		    cw = cur;
		}
		code <<= 1;
		off = NRD16(cw);
		if (!off) {
		    NWR16(cw, next);
		    cur = base + next;
		    next += 4;
		    NWR32(cur, 0);
		} else {
		    cur = base + off;
		}
	    }
	    NWR32(cur, 0xffffff00 | (ULONG)sym);
	}
	/* mirror root '0' side when '1' is empty */
	if (!NRD16(base + 2))
	    NWR16(base + 2, NRD16(base));
    }

    /* 1024-entry fast table: walk the trie along each 10-bit
     * prefix; leaf -> {10-len, sym}, else nodeoff-0x800	      */
    tab = base + UWK_FAST;
    {
	UBYTE *tp = tab;
	UWORD d2 = 0;				/* index << 6 */
	do {
	    ULONG d3 = NRD32(base);		/* root node long */
	    UWORD d0 = d2;
	    int d1 = 9;
	    for (;;) {
		UWORD child = (d0 & 0x8000) ?
		    (UWORD)d3 : (UWORD)(d3 >> 16);
		d0 = (UWORD)(d0 + d0);
		d3 = NRD32(base + child);
		if ((LONG)d3 < 0) {		/* leaf */
		    *tp++ = (UBYTE)d1;
		    *tp++ = (UBYTE)d3;
		    break;
		}
		if (--d1 < 0) {			/* 10 bits, internal */
		    NWR16(tp, (UWORD)(child - 0x800));
		    tp += 2;
		    break;
		}
	    }
	    d2 = (UWORD)(d2 + 0x40);
	} while (d2);
    }

    /* decode: 10-bit fast path + deep trie walk */
    op  = (UBYTE *)xsp->xsp_OutBuf;
    win = 0;
    pos = 0;
    {
	UWORD cnt = (UWORD)(xsp->xsp_OutLen - 1);
	for (;;) {
	    UWORD prefix;
	    SHORT e;
	    pos -= 10;
	    while (pos < 0) {
		win = (win << 8) | *ip++;
		pos += 8;
	    }
	    prefix = (UWORD)((win >> pos) & 0x3ff);
	    e = (SHORT)NRD16(tab + prefix * 2);
	    if (e >= 0) {
		*op++ = (UBYTE)e;
		pos += ((UWORD)e) >> 8;
	    } else {
		ULONG node = NRD32(tab + e);	/* a4+neg -> trie */
		for (;;) {
		    UWORD child;
		    --pos;
		    if (pos < 0) {
			win = (win << 8) | *ip++;
			pos = 7;
		    }
		    child = ((win >> pos) & 1) ?
			(UWORD)node : (UWORD)(node >> 16);
		    node = NRD32(base + child);
		    if ((LONG)node < 0)
			break;
		}
		*op++ = (UBYTE)node;
	    }
	    if (--cnt == (UWORD)-1)
		break;
	}
    }
    return 0;
}

/* -42/-60 XpksPackFree: release the lazy workmem via its size
 * prefix; leaves a stale xsp_Sub[0] pointer (shipped quirk)   */
LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"))
{
    ULONG sub = xsp->xsp_Sub[0];
    if (sub) {
	UBYTE *p = (UBYTE *)sub - 4;
	exec_FreeMem(p, NRD32(p));
    }
    return 0;
}
