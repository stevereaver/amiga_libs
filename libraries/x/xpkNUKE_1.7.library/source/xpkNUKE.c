/*
 * xpkNUKE.library 1.7 -- "Nuke" XPK sublibrary
 * Reconstruction of binary/xpkNUKE_1.7.library
 *   idstr: "xpkNUKE 1.7 (06.06.1997)"   (sic: no "$VER:" cookie)
 *
 * Same codec as xpkNUKE 1.9: LZ77 cruncher with a pair-hash chain
 * window of 0x6a8f and four interleaved output streams multiplexed
 * into one byte stream in consumption order:
 *   stream1 (word accum, MSB-first): token flags. 1 = match,
 *           0+'1' = single literal, 0+'0' = counted literal run.
 *           A literal run is always followed by a match token with no
 *           intervening flag bit.
 *   stream2 (word accum, 2-bit codes): literal-run counts and the
 *           match-length extension of classes 10-15.
 *   stream3 (long accum, nibbles):   offset-class code, then the
 *           long-match-length extension nibbles.
 *   stream4 (long accum, MSB-first): offset residual bits.
 * Literals are stored BACKWARD from outbuf+outbuflen-4 and appended
 * after the stream data, 0xfb-padded so the run ends long-aligned.
 *
 * Positions are 1-based file indices: "pos p" is byte src[p-1]; the
 * pair hash for pos p is the word (src[p-1]<<8)|src[p].
 *
 * Generational differences vs 1.9 (this is the older skeleton):
 *  - the XpkSubParams-facing entry points are wrapper functions that
 *    marshal the workspace and call the real pack/unpack cores with
 *    bsr; the workmem is THREE separate AllocMems (92-byte cleared
 *    header + 0x20000 tab1 + 0x10000 tab2, tables NOT cleared by
 *    AllocMem -- the PackChunk wrapper memsets both every call).
 *  - decoder dispatches the 2-bit codes and copy-counts through
 *    `jmp pc@(tab,d0:w)` jump tables instead of compare chains.
 *  - match-search window-edge test is `d6 < d4` (blss), where 1.9
 *    uses `d6 <= d4` (bls).
 *  - the literal-tail copy runs when litptr >= outcur, i.e. the
 *    overflow check only fails when outcur PASSES litptr; 1.9 fails
 *    at equality too.
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef short          SHORT;
typedef long           LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0  */
	ULONG xsp_InLen;	/* +4  */
	APTR  xsp_OutBuf;	/* +8  */
	ULONG xsp_OutBufLen;	/* +12 */
	ULONG xsp_OutLen;	/* +16 (wrapper stores rc/outlen here) */
	ULONG xsp_pad2[8];	/* +20 .. +51 */
	APTR  xsp_Sub[1];	/* +52 workmem */
};

#ifdef HOST_TEST
LONG host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
#define REGPARM_A0
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz) host_FreeMem(p,sz)
#else
#define REGPARM_A0 __asm("a0")
#define ALLOCMEM(sz,fl) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register ULONG __p_size __asm("d0") = (ULONG)(sz);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define FREEMEM(mem,sz) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#endif

/* ---------------- packer ---------------- */

#define HDRSIZE   92		/* workmem header alloc		*/
#define TAB1SIZE  0x20000	/* pair->pos head  (64K words)	*/
#define TAB2SIZE  0x10000	/* pos->prev chain (32K words)	*/
#define NUKEWIN   0x6a8f	/* hash chain window		*/

/* workspace layout (register names from the disassembly) --
** identical to the 1.9 layout; only the allocation differs. */
struct Work {
	UBYTE *src;		/* +0  a5: input base                 */
	UBYTE *dst;		/* +4      output base                */
	UWORD *tab1;		/* +8  a3: pair->pos head  (64K w)    */
	UWORD *tab2;		/* +12 a6: pos->prev chain (32K w)    */
	UBYTE *outcur;		/* +16     next stream slot           */
	UBYTE *litptr;		/* +20     literal write ptr (backwd) */
	UBYTE *srcend;		/* +24     src + inlen                */
	ULONG *t2front;		/* +28     lazy-clear frontier        */
	UWORD inlen;		/* +32                                */
	UWORD outmax;		/* +34     outbuflen - 4              */
	UWORD lastpos;		/* +36     inlen - 1                  */
	UWORD litstart;		/* +38     first pending literal pos  */
	SHORT litcnt;		/* +40     pending literals - 1       */
	UWORD window;		/* +42     = 0x6a8f                   */
	SHORT ctr1;		/* +44     flag-stream bit counter    */
	SHORT ctr2;		/* +46     2-bit-stream counter       */
	SHORT ctr3;		/* +48     nibble-stream counter      */
	SHORT ctr4;		/* +50     xbits-stream counter       */
	UWORD acc1;		/* +52     flag accum (asl)           */
	UWORD acc2;		/* +54     2-bit accum (asl)          */
	ULONG acc3;		/* +56     nibble accum (rorl #4)     */
	ULONG acc4;		/* +60     xbits accum (asll|v)       */
	UBYTE *ptr1;		/* +64     pending slot, stream1      */
	UBYTE *ptr2;		/* +68     pending slot, stream2      */
	UBYTE *ptr3;		/* +72     pending slot, stream3      */
	UBYTE *ptr4;		/* +76     pending slot, stream4      */
	UBYTE scratch[12];	/* +80..91 staging for first flush  */
};

static __inline void wr16(UBYTE *p, UWORD v)
{
	p[0] = (UBYTE)(v >> 8); p[1] = (UBYTE)v;
}
static __inline void wr32(UBYTE *p, ULONG v)
{
	p[0] = (UBYTE)(v >> 24); p[1] = (UBYTE)(v >> 16);
	p[2] = (UBYTE)(v >> 8);  p[3] = (UBYTE)v;
}
static __inline UWORD rd16(const UBYTE *p)
{
	return (UWORD)((p[0] << 8) | p[1]);
}
static __inline ULONG rd32(const UBYTE *p)
{
	return ((ULONG)p[0] << 24) | ((ULONG)p[1] << 16) |
	       ((ULONG)p[2] << 8) | p[3];
}
static __inline ULONG ror32(ULONG v, int n)
{
	return (v >> n) | (v << (32 - n));
}
static __inline ULONG rol32(ULONG v, int n)
{
	n &= 31;
	return n ? ((v << n) | (v >> (32 - n))) : v;
}

/* flag stream: 1 bit per emit, MSB-first in word accums.  The first
** flush writes the initial accumulator to the scratch slot, so each
** stream's leading word is the discarded staging write. */
static __inline void putflag(struct Work *w, int bit)
{
	if (--w->ctr1 < 0) {
		wr16(w->ptr1, w->acc1);
		w->ptr1 = w->outcur;
		w->outcur += 2;
		w->ctr1 = 15;
	}
	w->acc1 = (UWORD)(w->acc1 + w->acc1 + bit);
}

/* 2-bit code stream (literal-run counts, match-length codes) */
static __inline void put2(struct Work *w, ULONG v)
{
	if ((w->ctr2 -= 2) < 0) {
		wr16(w->ptr2, w->acc2);
		w->ptr2 = w->outcur;
		w->outcur += 2;
		w->ctr2 = 14;
	}
	w->acc2 = (UWORD)((w->acc2 << 2) | v);
}

/* nibble stream (offset class + long-len extension) */
static __inline void put4(struct Work *w, ULONG v)
{
	if ((w->ctr3 -= 4) < 0) {
		wr32(w->ptr3, w->acc3);
		w->ptr3 = w->outcur;
		w->outcur += 4;
		w->ctr3 = 28;
		w->acc3 = 0;
	}
	w->acc3 = ror32(w->acc3 | v, 4);
}

/* offset residual bits stream (MSB-first, word granularity) */
static __inline void putx(struct Work *w, ULONG v, ULONG nb)
{
	ULONG d0 = (w->acc4 << nb) | v;
	if ((w->ctr4 -= (SHORT)nb) < 0) {
		ULONG o = (ULONG)(UWORD)-w->ctr4;
		ULONG t = ror32(d0, o);
		wr16(w->ptr4, (UWORD)t);
		w->ptr4 = w->outcur;
		w->outcur += 2;
		d0 = rol32(t, o);
		w->ctr4 = (SHORT)(16 - o);
	}
	w->acc4 = d0;
}

/* class tables @0x138..0x19f -- in the original the 4-word selector
** list sits right before the threshold block; the class walk advances
** a pointer through the threshold list, then reads at[16] (= nbtab)
** and at[32] (= codetab) relative to that pointer. */
static const UWORD seltab_138[4] = { 0, 0, 4, 10 };	/* @0x138 */
static const UWORD clstab[48] = {
	/* +0x00 (@0x140) threshold walks: len<=1 [0..3], len==2 [4..9],
	** len>=3 [10..15] -- the len2/len3 lists share the tail */
	0x0010, 0x0040, 0x0100, 0x0200,
	0x0010, 0x0080, 0x0200, 0x0800, 0x2000, 0x4000,
	0x0020, 0x0080, 0x0200, 0x0800, 0x2000, 0x4000,
	/* +0x20 (@0x160) residual bit counts per class */
	4,6,8,9, 4,7,9,11,13,14, 5,7,9,11,13,14,
	/* +0x40 (@0x180) class code nibbles (identity) */
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
};

/* decoder tables @0x1a0/0x1c0/0x1e0, indexed by the 4-bit class code */
static const UWORD dec_nbtab[16] = {
	4,6,8,9, 4,7,9,11,13,14, 5,7,9,11,13,14
};
static const UWORD dec_basetab[16] = {
	0x0000, 0x0010, 0x0050, 0x0150,
	0x0000, 0x0010, 0x0090, 0x0290, 0x0a90, 0x2a90,
	0x0000, 0x0020, 0x00a0, 0x02a0, 0x0aa0, 0x2aa0
};
static const UWORD dec_copytab[16] = {
	/* in the original these are JUMP-TABLE OFFSETS: the decoder
	** does jmp pc@(0x7a0,d0:w) so 0x20 lands on the 2-copy tail,
	** 0x1e on the 3-copy tail, 0 on the 3-copy+extension entry */
	0x20, 0x20, 0x20, 0x20,
	0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

/*
 * flush_lit -- the 0x200 subroutine: emit the pending literal run.
 * Emits flag '0', copies litcnt+1 source bytes backward into the
 * literal area, then emits '1' (single) or '0' + 2-bit count codes.
 * d7 = w->litcnt on entry.
 */
static void flush_lit(struct Work *w, UWORD d7)
{
	UBYTE *a5, *a1;
	UWORD d0;

	putflag(w, 0);
	w->litcnt = -1;
	a5 = w->src + w->litstart - 1;	/* first literal byte */
	a1 = w->litptr;
	d0 = d7;
	do {
		*--a1 = *a5++;
	} while ((SHORT)--d0 >= 0);
	w->litptr = a1;
	if (d7 == 0) {
		putflag(w, 1);		/* "01": exactly one literal   */
		return;
	}
	d0 = d7;
	putflag(w, 0);			/* "00": counted run follows   */
	for (;;) {
		if (d0 > 3) {
			put2(w, 0);
			d0 -= 3;
		} else {
			put2(w, (UWORD)(-(SHORT)d0) & 3);
			return;
		}
	}
}

/* pack_init -- the 0x60e subroutine: zeroes the stream counters and
** accumulators, parks ptr1..4 on the scratch slot, then loads the
** register working set (a3=tab1, a5=src, a6=tab2) and derives the
** pointer/word fields.  d5=1, d1=d6=0 on return (set by caller). */
static void pack_init(struct Work *w)
{
	w->ctr1 = 0; w->ctr2 = 0; w->ctr3 = 0; w->ctr4 = 0;
	w->acc1 = 0; w->acc2 = 0; w->acc3 = 0; w->acc4 = 0;
	w->ptr4 = w->scratch;		/* movel a0,a4@(0x3c+..)   */
	w->ptr3 = w->scratch;
	w->ptr2 = w->scratch;
	w->ptr1 = w->scratch;
	w->t2front = (ULONG *)w->tab2;
	w->window = NUKEWIN;		/* movew #0x6a90; subqw #1 */
	w->outcur = w->dst;
	w->litptr = w->dst + (SHORT)w->outmax;	/* addaw: sign-extends */
	w->srcend = w->src + (SHORT)w->inlen;	/* addaw: sign-extends */
	w->lastpos = (UWORD)(w->inlen - 1);
	w->litcnt = -1;
	w->litstart = 0;
}

/* pack_finish -- the 0x696 subroutine: force the trailing literal(s)
** into the pending run and flush it, then drain the four stream
** accumulators (0x6b8). */
static void pack_finish(struct Work *w, UWORD d5)
{
	if (d5 != w->inlen) {
		if (++w->litcnt == 0)
			w->litstart = d5;
	}
	if (++w->litcnt == 0)
		w->litstart = d5;
	flush_lit(w, (UWORD)w->litcnt);

	/* final stream flush (0x6b8): acc4 is flushed from its LOW
	 * word (movew a4@(62)) which is equivalent for a word store */
	wr16(w->ptr1, (UWORD)(w->acc1 << w->ctr1));
	wr16(w->ptr2, (UWORD)(w->acc2 << w->ctr2));
	wr32(w->ptr3, w->acc3 >> w->ctr3);
	wr16(w->ptr4, (UWORD)(w->acc4 << w->ctr4));
}

/* pack_tail -- the 0x6fa subroutine: append the backward-stored
** literal area after the stream data, 0xfb-padded so the literal run
** ends long-aligned.  Returns the total output length, or -1 when the
** streams overran the literal area (outcur > litptr; equality is OK
** here -- 1.9 fails at equality). */
static LONG pack_tail(struct Work *w)
{
	UBYTE *dst = w->dst, *a1, *a2;
	LONG nlits;
	ULONG n;

	if ((LONG)(w->litptr - w->outcur) < 0)
		return -1;
	a2 = w->litptr;
	nlits = (LONG)((dst + (SHORT)w->outmax) - a2);
	a1 = w->outcur;
	while (((ULONG)(a1 + nlits) & 3) != 0)
		*a1++ = 0xfb;
	n = nlits & 0xffff;		/* dbf count: low word */
	while (n-- != 0)
		*a1++ = *a2++;		/* forward copy */
	return (LONG)(a1 - dst);
}

/* pack_core -- the 0x2fa subroutine (a4 = &Work): the actual LZ77
** cruncher.  Same algorithm as 1.9; the only semantic difference is
** the `d6 < d4` window-edge test (1.9: `d6 <= d4`). */
static LONG pack_core(struct Work *w)
{
	register UBYTE *src, *dst;
	register UWORD *tab1, *tab2;
	register ULONG d0, d2, d3;
	register LONG d4;
	register UWORD d5, d6, d7;
	register UBYTE *a1, *a2, *a5;
	ULONG pair;

	pack_init(w);
#ifdef NUKE_TRACE
	NUKE_TRACE_INIT(w->tab1, w->tab2, w->tab1[0]);
#endif

	src = w->src;
	dst = w->dst;
	tab1 = w->tab1;
	tab2 = w->tab2;
	d5 = 1;
	d0 = d6 = d7 = 0;

	/* ---------------- main position loop ---------------- */
	for (;;) {
main_loop:
		pair = ((ULONG)src[d5 - 1] << 8) | src[d5];
		d6 = tab1[pair];
#ifdef NUKE_TRACE
		NUKE_TRACE_MAIN(d5, pair, d6, (UWORD)w->litcnt);
#endif
		if (d6 == 0)
			goto literal;
		if (src[d5 - 1] == src[d5]) {
			/* RLE: run of src[d5-1] continuing at index d5+1 */
			UWORD d4w = (UWORD)(w->lastpos - d5);
			a5 = src + d5 + 1;
			a1 = a5;
			for (;;) {
				if (*a5++ != src[d5 - 1])
					break;
				if (--d4w == 0xffff)
					break;
			}
			d2 = (ULONG)a5;
			if (d2 > (ULONG)w->srcend)
				d2 = (ULONG)w->srcend;
			d2 -= (ULONG)a1;
			if (d2 > 2) {
				d3 = 1;
				d2--;
				if (++w->litcnt == 0)
					w->litstart = d5;
				d5++;
				goto emit;
			}
		}

		/* general match search over the pair chain */
		if (d5 > w->window) {
			ULONG *p = w->t2front;
			UBYTE *lim = (UBYTE *)tab2 + 2 * (d5 - w->window);
			do {
				*p++ = 0;
			} while ((UBYTE *)p <= lim);
			w->t2front = p;
		}
		d4 = (d5 >= w->window) ? (LONG)(d5 - w->window) : 0;
		a5 = src + d5 + 2;
		d2 = (ULONG)a5;			/* best end ptr */
		d7 = *--a5;				/* src[d5+1] */
		d0 = (ULONG)a5;				/* = src+d5+1 */
		d3 = (ULONG)(src + d6 + 2);
		a2 = src;				/* drifting compare base */
		tab2[0] = d5;				/* sentinel */
		for (;;) {
			while (a2[d6 + 1] != d7)
				d6 = tab2[d6];
			if (d6 == d5)
				break;
			/* compare candidate d6 forward */
			a5 = src + d6 + 1;
			a1 = (UBYTE *)d0;
			while (*a5++ == *a1++)
				;
			if (d2 < (ULONG)a1) {
				if ((UWORD)d6 <= (UWORD)d4)
					break;	/* cmpw d4,d6; bls: cand at/below
							   window edge: search ends, better
							   match discarded */
				a2 += a1 - (UBYTE *)d2;	/* drift */
				d2 = (ULONG)a1;
				d7 = a1[-1];
				d3 = (ULONG)a5;
			}
			d6 = tab2[d6];
		}
		d3 = (ULONG)((UBYTE *)d2 - (UBYTE *)d3);	/* offset */
		if (d2 > (ULONG)w->srcend)
			d2 = (ULONG)w->srcend;
		d2 -= d0;					/* len code */
		if (d2 <= 1 && d3 >= 336) {
			tab2[d5] = tab1[pair];
			goto literal;
		}
		goto emit;

literal:
		if (++w->litcnt == 0)
			w->litstart = d5;
		tab1[pair] = d5;
		if ((SHORT)++d5 < (SHORT)w->lastpos)
			goto main_loop;
		goto finish;

emit:
#ifdef NUKE_TRACE
		NUKE_TRACE_EMIT(d5, d2, d3, (UWORD)w->litcnt);
#endif
		/* pending literals first (flag '0' + count), else flag '1' */
		if (w->litcnt >= 0)
			flush_lit(w, (UWORD)w->litcnt);
		else
			putflag(w, 1);
		/* offset class */
		{
			const UWORD *at;
			d0 = (d2 > 3) ? 3 : d2;
			at = clstab + seltab_138[d0];
			while ((SHORT)d3 >= (SHORT)at[0])
				d3 -= *at++;
			put4(w, at[32]);	/* code nibble   */
			putx(w, d3, at[16]);	/* residual bits */
		}
		if (d2 > 2) {			/* match-length code */
			d0 = d2;
			if (d0 <= 5) {
				put2(w, (~(d0 - 3)) & 3);	/* 3,4,5 -> 3,2,1 */
			} else {
				put2(w, 0);
				d0 -= 6;
				while (d0 > 14) {
					put4(w, 0);
					d0 -= 15;
				}
				put4(w, (~d0) & 15);
			}
		}
		/* hash update for all covered positions d5..d5+d2 */
		{
			UBYTE *q = src + d5 + 1;
			ULONG h = pair;
			ULONG cnt = d2;
			for (;;) {
				UWORD *pw = &tab1[h];
				tab2[d5] = *pw;
				*pw = d5;
				d5++;
				if ((LONG)--cnt < 0)
					break;
				h = ((h << 8) | *q++) & 0xffff;
			}
		}
		if ((SHORT)d5 < (SHORT)w->lastpos)
			goto main_loop;

finish:
		pack_finish(w, d5);
		return pack_tail(w);
	}
}

/* pack_alloc -- the 0x902 subroutine: allocates the workmem as THREE
** separate blocks: the 92-byte header (MEMF_CLEAR, so the tab pointers
** start NULL), then tab1 0x20000 and tab2 0x10000 WITHOUT the clear
** flag (PackChunk memsets them itself).  On any failure it runs
** XpksPackFree and returns NULL. */
LONG XpksPackFree(struct XpkSubParams *xsp REGPARM_A0);

static APTR pack_alloc(struct XpkSubParams *xsp)
{
	struct Work *w;

	w = (struct Work *)ALLOCMEM(HDRSIZE, 0x10000);	/* MEMF_CLEAR */
	xsp->xsp_Sub[0] = w;
	if (w) {
		w->tab1 = (UWORD *)ALLOCMEM(TAB1SIZE, 0);
		if (w->tab1) {
			w->tab2 = (UWORD *)ALLOCMEM(TAB2SIZE, 0);
			if (w->tab2)
				return w;
		}
	}
	XpksPackFree(xsp);
	return 0;
}

/* -42 XpksPackFree: frees the three blocks AND clears xsp_Sub[0];
** returns d0 = 0 when nothing cached, else whatever the last FreeMem
** leaves in d0 (the original returns d0 straight through -- the final
** jsr was FreeMem(w,92), so this is the 0x5c leftover). */
LONG XpksPackFree(struct XpkSubParams *xsp REGPARM_A0)
{
	struct Work *w = (struct Work *)xsp->xsp_Sub[0];
	if (!w)
		return 0;
	if (w->tab1)
		FREEMEM(w->tab1, TAB1SIZE);
	if (w->tab2)
		FREEMEM(w->tab2, TAB2SIZE);
#ifdef HOST_TEST
	FREEMEM(w, HDRSIZE);
	xsp->xsp_Sub[0] = 0;
	return 0;
#else
	{
		register APTR sys __asm("a6") = *(APTR *)4;
		register APTR mm  __asm("a1") = w;
		register ULONG sz __asm("d0") = HDRSIZE;
		__asm volatile ("jsr %/a6@(-210:W)\n"
			: "+d"(sz)
			: "a"(sys), "a"(mm)
			: "a0","fp0","fp1","cc","memory");
		xsp->xsp_Sub[0] = 0;
		return (LONG)sz;	/* FreeMem's leftover d0 (sic) */
	}
#endif
}

/* -36 XpksPackChunk: the 0x952 wrapper.  Allocates the workmem on
** first use, marshals the xsp fields, memsets both tables EVERY call
** (they are AllocMem'd uncleared), runs pack_core, stores the raw
** result at xsp+16 (even the -1), and maps it to the return code. */
LONG XpksPackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	struct Work *w;
	register UBYTE *a1;
	ULONG n;
	LONG rc;

	w = (struct Work *)xsp->xsp_Sub[0];
	if (!w) {
		w = (struct Work *)pack_alloc(xsp);
		if (!w)
			return -7;
	}

	w->src = (UBYTE *)xsp->xsp_InBuf;
	w->dst = (UBYTE *)xsp->xsp_OutBuf;
	w->inlen = (UWORD)xsp->xsp_InLen;
	w->outmax = (UWORD)(xsp->xsp_OutBufLen - 4);

	/* the 0x9e8 subroutine: backward byte memset; tables are
	 * cleared unconditionally on every pack call */
	a1 = (UBYTE *)w->tab1;		/* clear tab1: 0x20000 */
	for (n = TAB1SIZE; n; n--)
		*a1++ = 0;
	a1 = (UBYTE *)w->tab2;		/* clear tab2: 0x10000 */
	for (n = TAB2SIZE; n; n--)
		*a1++ = 0;

	rc = pack_core(w);

	xsp->xsp_OutLen = (ULONG)rc;
	if (rc < 0)
		return -17;
	if ((ULONG)rc < xsp->xsp_InLen)
		return 0;
	return -17;
}

/* ---------------- decoder ---------------- */

/* unpack_core -- the 0x73c subroutine.  The register contract from the
** 0x9c6 wrapper: a5 = packed stream start (read forward), a4 = packed
** buffer end (literal area, read backward), a0 = out write, a2 = out
** end.  Returns the final out pointer in d0 (the wrapper ignores it
** and always returns 0).  Same bit mechanics as the 1.9 decoder; the
** original dispatches the copy counts and 2-bit codes through
** `jmp pc@(tab,d0:w)` tables instead of compare chains. */
static LONG unpack_core(const UBYTE *a5, const UBYTE *a4,
			UBYTE *a0, UBYTE *a2)
{
	register const UBYTE *aa5 = a5;	/* stream read (forward)  */
	register const UBYTE *aa4 = a4;	/* literal read (backward)  */
	register UBYTE *aa0 = a0;	/* out write                */
	register UBYTE *aa2 = a2;	/* out end                  */
	register const UBYTE *a1;	/* match source             */
	UWORD d2, d3;
	ULONG d4;
	LONG d5;
	ULONG d6;
	LONG d7;
	UWORD X;
	ULONG d0, d1;

	d2 = 0x8000;
	d4 = 0; d5 = 0; d6 = 0; d7 = 0; X = 0;
	d3 = d2;

/* Transcribed instruction-faithfully, including the bit-barrel
** boundary semantics (empty-word reload through addx) and the roxr
** X-chain of the nibble reader.  d2 = flag bits, d3 = 2-bit codes,
** d4/d5 = nibble stream, d6/d7 = offset-extra-bits buffer,
** a5 = shared stream pointer, a6 = decoder tables (C arrays). */

#define NIBBLE() do {						\
		X = (UWORD)(d5 == 0);				\
		if (--d5 < 0) {					\
			d5 = 7;					\
			d4 = rd32(aa5); aa5 += 4;			\
			X = (UWORD)(d4 >> 31);			\
			d4 <<= 1;				\
		}						\
		d0 = d4 & 30;					\
		{ int _i; for (_i = 0; _i < 4; _i++) {		\
			UWORD _nx = (UWORD)(d4 & 1);		\
			d4 = (d4 >> 1) | ((ULONG)X << 31);	\
			X = _nx;				\
		} }						\
	} while (0)

flag_loop:			/* 0x7c4 */
	{
		int c = (SHORT)d2 < 0;
		X = (UWORD)c;
		d2 <<= 1;
		if (!c)
			goto second;
		if (d2)
			goto match;
		d2 = rd16(aa5); aa5 += 2;
		c = (SHORT)d2 < 0;	/* carry of the addxw below */
		d2 = (UWORD)(d2 + d2 + X);
		X = (UWORD)c;
		if (c)
			goto match;
	}
second:				/* 0x7d0 */
	{
		int c = (SHORT)d2 < 0;
		X = (UWORD)c;
		d2 <<= 1;
		if (!d2) {
			ULONG w16;
			X = (UWORD)c;
			w16 = rd16(aa5); aa5 += 2;
			c = (SHORT)w16 < 0;
			d2 = (UWORD)(w16 + w16 + X);
			X = (UWORD)c;
		}
		if (!c)
			goto litcount;
	}
	/* single literal 0x7da */
	*aa0++ = *--aa4;
	if (aa0 < aa2)
		goto match;
	return (LONG)aa0;

litcount:			/* 0x7e8: counted literal run */
	for (;;) {
		int c;
		d0 = 0;
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1;
		if (!d3) {
			ULONG w16 = rd16(aa5); aa5 += 2;
			c = (SHORT)w16 < 0;
			d3 = (UWORD)(w16 + w16 + X);
			X = (UWORD)c;
		}
		d0 = d0 + d0 + (UWORD)X;	/* addxw: bit into d0 */
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1; /* no reload! */
		d0 = d0 + d0 + (UWORD)X;
		d0 <<= 1;
		switch (d0) {
		case 0:			/* '00': +3, then another code */
			*aa0++ = *--aa4; *aa0++ = *--aa4; *aa0++ = *--aa4;
			continue;
		case 2:			/* 01: +4 */
			*aa0++ = *--aa4; *aa0++ = *--aa4;
			*aa0++ = *--aa4; *aa0++ = *--aa4;
			break;
		case 4:			/* 10: +3 */
			*aa0++ = *--aa4; *aa0++ = *--aa4; *aa0++ = *--aa4;
			break;
		case 6:			/* 11: +2 */
			*aa0++ = *--aa4; *aa0++ = *--aa4;
			break;
		}
		if (aa0 < aa2)
			goto match;	/* literals are always followed
					   by a match (no flag bit) */
		return (LONG)aa0;
	}

match:				/* 0x768 */
	NIBBLE();
	{
		ULONG cls = d0 >> 1;
		ULONG off;
		d1 = dec_nbtab[cls];			/* a6@(0,d0)   */
		d6 &= 0xffff0000;				/* clrw d6     */
		d6 = rol32(d6, d1);				/* roll d1,d6  */
		X = (UWORD)(((d7 & 0xffff) + d1) >> 16);	/* addw d1,d7  */
		d7 = (SHORT)(d7 + d1);
		if (d7 > 0) {
			ULONG t = rd16(aa5); aa5 += 2;
			X = 0;					/* asll x-out  */
			t <<= d7;				/* asll d7,d1  */
			t = (t >> 16) | (t << 16);		/* swap        */
			d6 |= t;				/* orl d1,d6   */
			X = (UWORD)((UWORD)d7 < 16);		/* subw a3,d7  */
			d7 = (SHORT)(d7 - 16);
		}
		X = (UWORD)(((d6 & 0xffff) + dec_basetab[cls]) >> 16);
		d6 = (d6 + dec_basetab[cls]) & 0xffffffff;	/* addw base   */
		off = (UWORD)d6;
		a1 = aa0 - off;					/* subaw d6    */
		d0 = dec_copytab[cls];				/* a6@(0x40)   */
	}
	if (d0 == 0x20) {		/* classes 0-3: 2 copies */
		*aa0++ = *a1++; *aa0++ = *a1++;
		goto flag_loop;
	}
	if (d0 == 0x1e) {		/* classes 4-9: 3 copies */
		*aa0++ = *a1++; *aa0++ = *a1++; *aa0++ = *a1++;
		goto flag_loop;
	}
	/* classes 10-15: 3 copies + 2-bit length extension */
	*aa0++ = *a1++; *aa0++ = *a1++; *aa0++ = *a1++;
	{
		int c;
		d0 = 0;
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1;
		if (!d3) {
			ULONG w16 = rd16(aa5); aa5 += 2;
			c = (SHORT)w16 < 0;
			d3 = (UWORD)(w16 + w16 + X);
			X = (UWORD)c;
		}
		d0 = d0 + d0 + (UWORD)X;
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1; /* no reload! */
		d0 = d0 + d0 + (UWORD)X;
		d0 <<= 1;
	}
	switch (d0) {
	case 2:		/* v=1 -> +3 */
		*aa0++ = *a1++; *aa0++ = *a1++; *aa0++ = *a1++;
		goto flag_loop;
	case 4:		/* v=2 -> +2 */
		*aa0++ = *a1++; *aa0++ = *a1++;
		goto flag_loop;
	case 6:		/* v=3 -> +1 */
		*aa0++ = *a1++;
		goto flag_loop;
	}
	/* v=0 -> +3 then nibble extension loop (0x82a/0x834) */
	*aa0++ = *a1++; *aa0++ = *a1++; *aa0++ = *a1++;
	for (;;) {
		int n;
		NIBBLE();
		n = (int)(d0 >> 1);
		if (n == 0) {
			int k;			/* nibble 0: +15, loop */
			d0 = 0;			/* the moveq at 0x810 */
			for (k = 0; k < 15; k++)
				*aa0++ = *a1++;
			continue;		/* tstb d0 -> 0 -> next nibble */
		}
		{
			int k, cnt = 16 - n;
			for (k = 0; k < cnt; k++)
				*aa0++ = *a1++;
		}
		goto flag_loop;
	}
}

/* -54 XpksUnpackChunk: the 0x9c6 wrapper.  Derives the four register
** pointers from the xsp and runs the core; always returns 0. */
LONG XpksUnpackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	const UBYTE *in = (const UBYTE *)xsp->xsp_InBuf;
	UBYTE *out = (UBYTE *)xsp->xsp_OutBuf;

	unpack_core(in,				/* a5: stream read */
		    in + xsp->xsp_InLen,		/* a4: literal end */
		    out,				/* a0: out write */
		    out + xsp->xsp_OutLen);		/* a2: out end   */
	return 0;
}

#ifndef HOST_TEST
extern const UBYTE xpkinfo[];
/* -30 XpksPackerInfo (0x848): `lea xpkinfo.l,a0; movel a0,d0; rts` --
** the descriptor lives in the DATA hunk (cross-hunk reloc). */
const UBYTE *XpksPackerInfo(void) { return xpkinfo; }
#endif
