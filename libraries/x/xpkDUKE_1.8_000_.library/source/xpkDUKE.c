/*
 * xpkDUKE.library V1.8(000) -- "Duke" XPK sublibrary
 * Reconstruction of binary/xpkDUKE_1.8(000).library
 *   idstr: "$VER: xpkDUKE V1.8 (1 Oct 2013) by Christian von Roques"
 *
 * "NUKE with a delta preprocessor": the pack and unpack cores are
 * byte-identical to xpkNUKE 1.8(000); DUKE differs only in
 *   - a delta transform around the codec: pack first computes
 *     d[i] = in[i] - in[i-1] into a work+92 scratch buffer and runs
 *     the NUKE cruncher on the deltas; unpack runs the NUKE decoder
 *     then integrates in place (out[i] += running, 8-byte groups);
 *   - workspace is 226700 bytes (0x3758c): +92 delta buf (0x7530),
 *     +0x758c tab1[64K w], +0x2758c tab2[32K w].  PackFree still frees
 *     the NUKE size 0x3005c (sic).
 *
 * LZ77 cruncher with a pair-hash chain window of 0x6a8f and four
 * interleaved output streams multiplexed into one byte stream in
 * consumption order:
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
	ULONG xsp_OutLen;	/* +16 (asm stores outlen at +16) */
	ULONG xsp_pad2[8];	/* +20 .. +51 */
	APTR  xsp_Sub[1];	/* +52 workmem */
};

#ifdef HOST_TEST
LONG host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
LONG host_Remove(APTR);
#define REGPARM_A0
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz) host_FreeMem(p,sz)
#define REMOVE(p) host_Remove(p)
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
#define REMOVE(node) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#endif

/* ---------------- packer ---------------- */

#define ALLOCSIZE 0x3758c	/* 226700: 92 hdr + 0x7530 delta + tabs  */
#define FREESIZE  0x3005c	/* 196700: PackFree frees NUKE size (sic) */
#define DELTABUF  92		/* a4@(0) -> work+92                    */
#define NUKEWIN   0x6a8f	/* hash chain window */
#ifdef HOST_TEST
#define DELTAOFF  ((int)sizeof(struct Work))	/* LP64-safe placement */
#else
#define DELTAOFF  DELTABUF
#endif

/* workspace layout (register names from the disassembly) */
struct Work {
	UBYTE *src;		/* +0  a0: -> work+92, delta'd input   */
	UBYTE *dst;		/* +4      output base                */
	UWORD *tab1;		/* +8  a3: pair->pos head, -> +0x758c */
	UWORD *tab2;		/* +12 a6: pos->prev chain, ->+0x2758c*/
	UBYTE *outcur;		/* +16     next stream slot           */
	UBYTE *litptr;		/* +20     literal write ptr (backwd) */
	UBYTE *srcend;		/* +24     delta + inlen              */
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

/* class tables @0x712..0x7b9 -- ONE contiguous block exactly like the
** original: the class walk advances a pointer through the threshold
** list, then reads at[16] (= nbtab) and at[32] (= codetab) relative to
** that pointer.  Do NOT split into separate arrays. */
static const UWORD clstab[80] = {
	/* +0x00 (@0x71a) threshold walks: len<=1 [0..3], len==2 [4..9],
	** len>=3 [10..15] -- the len2/len3 lists share the tail */
	0x0010, 0x0040, 0x0100, 0x0200,
	0x0010, 0x0080, 0x0200, 0x0800, 0x2000, 0x4000,
	0x0020, 0x0080, 0x0200, 0x0800, 0x2000, 0x4000,
	/* +0x20 (@0x73a) residual bit counts per class */
	4,6,8,9, 4,7,9,11,13,14, 5,7,9,11,13,14,
	/* +0x40 (@0x75a) class code nibbles (identity) */
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
	/* +0x60 (@0x77a) cumulative bases */
	0x0000, 0x0010, 0x0050, 0x0150,
	0x0000, 0x0010, 0x0090, 0x0290, 0x0a90, 0x2a90,
	0x0000, 0x0020, 0x00a0, 0x02a0, 0x0aa0, 0x2aa0,
	/* +0x80 (@0x79a) decoder jump offsets */
	0x20, 0x20, 0x20, 0x20,
	0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
/* @0x712: selector for the class table by min(lencode,3) */
static const UWORD seltab_712[4] = { 0, 0, 4, 10 };

/* decoder tables @0x73a/0x77a/0x79a, indexed by the 4-bit class code */
static const UWORD dec_nbtab[16] = {
	4,6,8,9, 4,7,9,11,13,14, 5,7,9,11,13,14
};
static const UWORD dec_basetab[16] = {
	0x0000, 0x0010, 0x0050, 0x0150,
	0x0000, 0x0010, 0x0090, 0x0290, 0x0a90, 0x2a90,
	0x0000, 0x0020, 0x00a0, 0x02a0, 0x0aa0, 0x2aa0
};
static const UWORD dec_copytab[16] = {
	0x20, 0x20, 0x20, 0x20,
	0x1e, 0x1e, 0x1e, 0x1e, 0x1e, 0x1e,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

/*
 * flush_lit -- the 0x208 subroutine: emit the pending literal run.
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

/* -36 XpksPackChunk */
LONG XpksPackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	struct Work *w;
	register UBYTE *src, *dst;
	register UWORD *tab1, *tab2;
	register ULONG d0, d2, d3;
	register LONG d4;
	register UWORD d5, d6, d7;
	register UBYTE *a1, *a2, *a5;
	ULONG pair;

	if (!xsp->xsp_Sub[0]) {
#ifdef HOST_TEST
		/* LP64: struct Work exceeds the 92-byte m68k header, so the
		 * delta buffer and tables (which must not overlap the header
		 * fields) are placed after the host struct. */
		w = (struct Work *)ALLOCMEM(sizeof(struct Work) +
					    0x7530 + 0x30000, 0);
		xsp->xsp_Sub[0] = w;
		if (!w)
			return -7;
		w->tab1 = (UWORD *)((UBYTE *)w + sizeof(struct Work) + 0x7530);
		w->tab2 = (UWORD *)((UBYTE *)w->tab1 + 0x20000);
#else
		w = (struct Work *)ALLOCMEM(ALLOCSIZE, 0); /* MEMF_ANY (sic) */
		xsp->xsp_Sub[0] = w;
		if (!w)
			return -7;
		w->tab1 = (UWORD *)((UBYTE *)w + 0x758c);
		w->tab2 = (UWORD *)((UBYTE *)w + 0x2758c);
#endif
		/* alloc-only: clrl x3 at a4+80 -> the scratch staging area */
		for (d0 = 0; d0 < 12; d0++)
			w->scratch[d0] = 0;
	} else {
		w = (struct Work *)xsp->xsp_Sub[0];
	}

	/* delta preprocessor (0x182..0x1a4): work[92+i] = in[i]-in[i-1]
	 * (in[-1] = 0).  dbf pre-decremented loop: runs inlen.w times
	 * (inlen == 0 -> 0x10000 iterations, running into tab1). */
	{
		const UBYTE *in = (const UBYTE *)xsp->xsp_InBuf;
		UBYTE *out = (UBYTE *)w + DELTAOFF;
		UWORD c = (UWORD)(xsp->xsp_InLen - 1);
		UBYTE acc = 0;
		do {
			UBYTE d = (UBYTE)(*in++ - acc);
			*out++ = d;
			acc = (UBYTE)(acc + d);
		} while ((UWORD)--c != 0xffff);
	}

	w->src = (UBYTE *)w + DELTAOFF;		/* a4@(0) = delta buffer */
	w->dst = xsp->xsp_OutBuf;
	w->inlen = (UWORD)xsp->xsp_InLen;
	w->outmax = (UWORD)(xsp->xsp_OutBufLen - 4);

	/* both hash tables are cleared on EVERY call (common path):
	 * tab1 = 0x2000*16 bytes, tab2 = 0x2000*8 bytes = 0x30000 total */
	{
		UBYTE *p = (UBYTE *)w->tab1;
		for (d0 = 0x30000; d0; d0--)
			*p++ = 0;
	}

	/* clrl a4@(44)..a4@(63) (ctr1-4 + acc1-4); then a0=a4+80 is
	 * stored at +64..+79 = ptr1-4 */
	w->ctr1 = 0; w->ctr2 = 0; w->ctr3 = 0; w->ctr4 = 0;
	w->acc1 = 0; w->acc2 = 0; w->acc3 = 0; w->acc4 = 0;
	a5 = w->scratch;
	w->ptr1 = a5;
	w->ptr2 = a5;
	w->ptr3 = a5;
	w->ptr4 = a5;

	src = w->src;			/* moveml a4@ -> a0,a1,a3,a6 */
	dst = w->dst;
	tab1 = w->tab1;
	tab2 = w->tab2;
	w->t2front = (ULONG *)tab2;
	w->window = NUKEWIN;
	w->outcur = dst;
	w->litptr = dst + (SHORT)w->outmax;	/* addaw: sign-extends */
	w->srcend = src + (SHORT)w->inlen;	/* addaw: sign-extends */
	d5 = 1;
	w->lastpos = (UWORD)(w->inlen - 1);
	w->litcnt = -1;
	w->litstart = 0;
	d0 = d6 = d7 = 0;

	/* ---------------- main position loop ---------------- */
	for (;;) {
		UBYTE *litp;
		LONG nlits;

main_loop:
		pair = ((ULONG)src[d5 - 1] << 8) | src[d5];
		d6 = tab1[pair];
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
		if (d5 >= w->window) {
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
					break;	/* cmpw d4,d6; bls: cand <= window
						   edge (or sentinel 0): search ends */
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
		/* pending literals first (flag '0' + count), else flag '1' */
		if (w->litcnt >= 0)
			flush_lit(w, (UWORD)w->litcnt);
		else
			putflag(w, 1);
		/* offset class */
		{
			const UWORD *at;
			d0 = (d2 > 3) ? 3 : d2;
			at = clstab + seltab_712[d0];
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
		if (d5 != w->inlen) {
			if (++w->litcnt == 0)
				w->litstart = d5;
		}
		if (++w->litcnt == 0)
			w->litstart = d5;
		d7 = (UWORD)w->litcnt;
		flush_lit(w, d7);

		/* final stream flush (0x68c) */
		wr16(w->ptr1, (UWORD)(w->acc1 << w->ctr1));
		wr16(w->ptr2, (UWORD)(w->acc2 << w->ctr2));
		wr32(w->ptr3, w->acc3 >> w->ctr3);
		wr16(w->ptr4, (UWORD)(w->acc4 << w->ctr4));

		/* literal tail + pad + writeback (0x6cc).  Overflow test:
		 * proceed iff litptr >= outcur (bge on litptr-outcur).
		 * nlits = dst + sext(outmax) - litptr (addaw + suba.l, full
		 * width); pad loop emits 0xfb until (outcur+nlits)&3 == 0;
		 * copy loop entered at the dbf -> copies exactly nlits.w. */
		a2 = w->outcur;
		a1 = w->litptr;
		if ((LONG)(w->litptr - w->outcur) < 0) {
			a2 = (UBYTE *)-1;
		} else {
			ULONG n;
			nlits = (LONG)((UBYTE *)dst + (SHORT)w->outmax - a1);
			while (((ULONG)(a2 + nlits) & 3) != 0)
				*a2++ = 0xfb;
			litp = a1;
			n = nlits & 0xffff;
			while (n != 0) {
				n--;
				*a2++ = *litp++;
			}
			a2 -= (ULONG)dst;
		}
		xsp->xsp_OutLen = (ULONG)a2;	/* xsp+16 via saved xsp+8 */
		if ((LONG)a2 < 0)
			return -17;
		if ((ULONG)a2 <= xsp->xsp_InLen)	/* bls: <= is success */
			return 0;
		return -17;
	}
}

/* -42 XpksPackFree: frees the workspace but does NOT clear
** xsp_Sub[0] (sic: the pointer stays stale; a later PackChunk would
** reuse the freed block).  Frees 0x3005c bytes even though the block
** was allocated with 0x3758c (sic -- copied from NUKE).  Returns
** d0 = wm (0) when nothing cached, else whatever FreeMem leaves in d0. */
LONG XpksPackFree(struct XpkSubParams *xsp REGPARM_A0)
{
	APTR wm = xsp->xsp_Sub[0];
	if (!wm)
		return 0;
#ifdef HOST_TEST
	FREEMEM(wm, FREESIZE);
	return 0;
#else
	{
		register APTR sys __asm("a6") = *(APTR *)4;
		register APTR mm  __asm("a1") = wm;
		register ULONG sz __asm("d0") = FREESIZE;
		__asm volatile ("jsr %/a6@(-210:W)\n"
			: "+d"(sz)
			: "a"(sys), "a"(mm)
			: "a0","fp0","fp1","cc","memory");
		return (LONG)sz;	/* FreeMem's leftover d0 (sic) */
	}
#endif
}

/* ---------------- decoder ---------------- */

/* the NUKE-format bitstream decode (code+0x7ba..0x90b is byte-identical
** to NUKE 1.8's 0x79c..0x8b7 modulo addresses; a0 is additionally saved
** because the caller still needs xsp for the delta pass) */
static void decode_core(struct XpkSubParams *xsp REGPARM_A0)
{
	register const UBYTE *a5;	/* stream read (forward)  */
	register const UBYTE *a4;	/* literal read (backward)  */
	register UBYTE *a0;		/* out write                */
	register UBYTE *a2;		/* out end                  */
	register UBYTE *a1;		/* match source             */
	UWORD d2, d3;
	ULONG d4;
	LONG d5;
	ULONG d6;
	LONG d7;
	UWORD X;
	ULONG d0, d1;

	a4 = (const UBYTE *)xsp->xsp_InBuf + xsp->xsp_InLen;
	a0 = (UBYTE *)xsp->xsp_OutBuf;
	a2 = a0 + xsp->xsp_OutLen;		/* xsp+16 = unpacked len */
	a5 = (const UBYTE *)xsp->xsp_InBuf;
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
			d4 = rd32(a5); a5 += 4;			\
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

flag_loop:			/* 0x888 */
	{
		int c = (SHORT)d2 < 0;
		X = (UWORD)c;
		d2 <<= 1;
		if (!c)
			goto second;
		if (d2)
			goto match;
		d2 = rd16(a5); a5 += 2;
		c = (SHORT)d2 < 0;	/* carry of the addxw below */
		d2 = (UWORD)(d2 + d2 + X);
		X = (UWORD)c;
		if (c)
			goto match;
	}
second:				/* 0x894 */
	{
		int c = (SHORT)d2 < 0;
		X = (UWORD)c;
		d2 <<= 1;
		if (!d2) {
			ULONG w16;
			X = (UWORD)c;
			w16 = rd16(a5); a5 += 2;
			c = (SHORT)w16 < 0;
			d2 = (UWORD)(w16 + w16 + X);
			X = (UWORD)c;
		}
		if (!c)
			goto litcount;
	}
	/* single literal 0x89e */
	*a0++ = *--a4;
	if (a0 < a2)
		goto match;
	return;

litcount:			/* 0x8ac: counted literal run */
	for (;;) {
		int c;
		d0 = 0;
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1;
		if (!d3) {
			ULONG w16 = rd16(a5); a5 += 2;
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
			*a0++ = *--a4; *a0++ = *--a4; *a0++ = *--a4;
			continue;
		case 2:			/* 01: +4 */
			*a0++ = *--a4; *a0++ = *--a4;
			*a0++ = *--a4; *a0++ = *--a4;
			break;
		case 4:			/* 10: +3 */
			*a0++ = *--a4; *a0++ = *--a4; *a0++ = *--a4;
			break;
		case 6:			/* 11: +2 */
			*a0++ = *--a4; *a0++ = *--a4;
			break;
		}
		if (a0 < a2)
			goto match;	/* literals are always followed
					   by a match (no flag bit) */
		return;
	}

match:				/* 0x82c */
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
			ULONG t = rd16(a5); a5 += 2;
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
		a1 = a0 - off;					/* subaw d6    */
		d0 = dec_copytab[cls];				/* a6@(0x60)   */
	}
	if (d0 == 0x20) {		/* classes 0-3: 2 copies */
		*a0++ = *a1++; *a0++ = *a1++;
		goto flag_loop;
	}
	if (d0 == 0x1e) {		/* classes 4-9: 3 copies */
		*a0++ = *a1++; *a0++ = *a1++; *a0++ = *a1++;
		goto flag_loop;
	}
	/* classes 10-15: 3 copies + 2-bit length extension */
	*a0++ = *a1++; *a0++ = *a1++; *a0++ = *a1++;
	{
		int c;
		d0 = 0;
		c = (SHORT)d3 < 0; X = (UWORD)c; d3 <<= 1;
		if (!d3) {
			ULONG w16 = rd16(a5); a5 += 2;
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
		*a0++ = *a1++; *a0++ = *a1++; *a0++ = *a1++;
		goto flag_loop;
	case 4:		/* v=2 -> +2 */
		*a0++ = *a1++; *a0++ = *a1++;
		goto flag_loop;
	case 6:		/* v=3 -> +1 */
		*a0++ = *a1++;
		goto flag_loop;
	}
	/* v=0 -> +3 then nibble extension loop (0x8f8/0x908) */
	*a0++ = *a1++; *a0++ = *a1++; *a0++ = *a1++;
	for (;;) {
		int n;
		NIBBLE();
		n = (int)(d0 >> 1);
		if (n == 0) {
			int k;			/* nibble 0: +15, loop */
			d0 = 0;			/* the moveq at 0x8d4 */
			for (k = 0; k < 15; k++)
				*a0++ = *a1++;
			continue;		/* tstb d0 -> 0 -> next nibble */
		}
		{
			int k, cnt = 16 - n;
			for (k = 0; k < cnt; k++)
				*a0++ = *a1++;
		}
		goto flag_loop;
	}
}

/* -54 XpksUnpackChunk */
LONG XpksUnpackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	decode_core(xsp);

	/* delta integration (0x7f4): un-delta the decoded stream in
	 * place -- out[i] += running, processed in 8-byte groups with a
	 * dbf counter, i.e. (OutLen+7)/8 groups rounding the tail UP to
	 * a multiple of 8 bytes (writes past OutLen, sic). */
	{
		ULONG n = (xsp->xsp_OutLen + 7) >> 3;
		UBYTE *q = (UBYTE *)xsp->xsp_OutBuf;
		UWORD c = (UWORD)(n - 1);
		UBYTE s = 0;
		do {
			int k;
			for (k = 0; k < 8; k++) {
				s = (UBYTE)(s + *q);
				*q++ = s;
			}
		} while ((UWORD)--c != 0xffff);
	}
	return 0;
}

/* ---------------- lifecycle ---------------- */
/* LibOpen/LibClose/LibExpunge/LibNull/LibInit live in xpkDUKE_lib.s --
 * the library base arrives in a6 (m68k LVO convention), which the C ABI
 * cannot express; they are transcribed directly from the original. */

/* LibInit lives in xpkDUKE_lib.s (stores seglist@34, no CPU gate). */

#ifndef HOST_TEST
extern const UBYTE xpkinfo[];
/* -30 XpksPackerInfo: lea descriptor,a0; movel a0,d0; rts */
const UBYTE *XpksPackerInfo(void) { return xpkinfo; }
#endif
