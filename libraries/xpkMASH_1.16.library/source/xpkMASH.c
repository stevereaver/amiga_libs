/*
 * xpkMASH.library 1.16 -- "Mashiner" XPK sublibrary
 * Reconstruction of binary/xpkMASH_1.16.library
 *   $VER: xpkMASH.library V1.16
 *
 * LZ77-family, 32KB window (bound = cur - 32415), "2 mixed streams":
 * bit-codes and raw literal bytes share one output pointer -- the bit
 * emitter reserves a byte slot at a1 (filled when it completes) while
 * literal runs are copied verbatim to a1, so code bytes and literals
 * interleave in emission order.
 *
 * Token stream (MSB-first bit packing, d6 slot accumulator); the
 * stream alternates [literal-run][match] with no marker between:
 *   run:   '0'          -> 0 literals, match follows directly
 *          '1'+code     -> 1..5 as '10/110/1110/11110/111110',
 *                          6,7 as '111111'+b (table r<8); r>=8 via
 *                          '11111'+unary class + excess; copies r raw
 *                          bytes through the same output pointer
 *   match: '00' + dist(9b)     -> len 2 (raw 11-bit field; dist<512)
 *          '01' + class+dist   -> len 3
 *          '1' + '1'^w '0'+ext -> len = lclass[w].base + ext + 2
 *          dist = 3-bit class + payload(5..14b) + class base
 *
 * Packer uses two tables: alloc1 64KB (chain = word @ sext16(pw)*2
 * from +0x8000) and alloc2 512<<shift bytes (0x20000 -> 0x800 halved
 * dynamically; head = ((b1<<shift)&0xff00 | b0) hash table).
 *
 * DEFECTS reproduced faithfully (documented in okf):
 *   - len-2 matches with dist >= 512 emit a token whose '00' prefix
 *     is polluted by dist bits 9-10 -> decodes as a different token
 *     and corrupts/desyncs the output stream.
 *   - chain table indexed by sign-extended ptr-low-word*2: positions
 *     mod 0x8000 alias; for input low16 >= 0x8000 the table wraps into
 *     its own low half (alloc1 holds only 32K slots).
 *   - block-clear underwrites each work allocation by 0x100 bytes.
 *   - decoder unary walks index past their class tables on desynced
 *     streams (reads table-adjacent hunk memory; capped here).
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef short          WORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0x00 */
	ULONG xsp_InLen;	/* +0x04 */
	APTR  xsp_OutBuf;	/* +0x08 */
	ULONG xsp_pad0c;	/* +0x0c */
	ULONG xsp_OutLen;	/* +0x10 */
	ULONG xsp_pad14[2];	/* +0x14..0x1b */
	ULONG xsp_Mode;		/* +0x1c */
	ULONG xsp_pad20[6];	/* +0x20..0x37 */
	ULONG xsp_pad38;	/* +0x38 */
	APTR  xsp_Bound;	/* +0x3c 60(a4): outbuf+inlen-50 */
	ULONG xsp_Tries;	/* +0x40 64(a4): 1 << (mode/10)  */
};

#ifdef HOST_TEST
APTR host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz)   host_FreeMem(p,sz)
#else
#define ALLOCMEM_E(size,fl) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define FREEMEM_E(mem,sz) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#define ALLOCMEM(sz,f)	ALLOCMEM_E(sz,f)
#define FREEMEM(p,s)	FREEMEM_E(p,s)
#endif

/* ---- codec state (asm registers), stack-allocated so the image
 * stays a single code hunk like the original ---------------------- */

struct pctx {
	UBYTE *chain;		/* a2: alloc1+0x8000, word @ pos.w*2   */
	UWORD *head;		/* a3: alloc2 hash head table          */
	ULONG  shift;		/* d5: hash shift                      */
	UBYTE *end;		/* d7: input end                       */
	ULONG  tries;		/* 64(a4): candidate-skip limit        */
	UBYTE *epos;		/* a1: next free byte (codes+literals) */
	UWORD  eacc;		/* d6: accumulator + sentinel          */
	UBYTE *eslot;		/* a6: reserved slot                   */
};

#define CHAIN(c,pw)	(*(UWORD *)((c)->chain + (WORD)((pw) * 2u)))

static void emit(struct pctx *c, ULONG d0, ULONG d1)
{						/* emit d1+1 bits, MSB first */
	for (d1++; d1--; ) {
		if (!c->eacc) {
			c->eslot = c->epos++;
			c->eacc  = 1;
		}
		c->eacc = (c->eacc << 1) | ((d0 >> 31) & 1);
		d0 = (d0 << 1) & 0xffffffff;	/* ULONG is 64-bit on host */
		if (c->eacc & 0x100) {
			*c->eslot = (UBYTE)c->eacc;
			c->eacc = 0;
		}
	}
}

/* ---- LAB_002B: fill downward from end, 256B blocks ---------------- */

static void filldown(UBYTE *end, ULONG blocks, UWORD val)
{
	while (blocks--) {
		ULONG i;
		end -= 256;
		for (i = 0; i < 128; i++)
			((UWORD *)end)[i] = val;
	}
}

/* ---- literal-run length code (LAB_0053/LAB_004F) ------------------ */

static const UWORD runw[8] = {
	0x0000, 0x8001, 0xc002, 0xe003, 0xf004, 0xf805, 0xfc07, 0xfd07
};

static ULONG ror32(ULONG v, ULONG n)
{
	return (v >> n) | (v << (32 - n));
}

static void emit_run(struct pctx *c, ULONG r)
{
	ULONG w;
	if (r < 8) {
		w = runw[r];
		emit(c, w << 16, w & 0xff);
		return;
	}
	/* extended unary: '1'^(7+k) + (3+k)-bit excess; the leading ones
	 * extend the decoder's unary walk to class k+1 */
	{
		ULONG d2 = r - 8, d0 = 4, d1 = 6, d4 = 3;
		for (;;) {
			d2 -= d0;
			if ((LONG)d2 < 0) {
				d2 += d0;
				break;
			}
			d1++; d4++; d0 <<= 1;
		}
		emit(c, 0xffffffff, d1);
		emit(c, ror32(d2, d4), d4 - 1);
	}
}

/* ---- match length code (LAB_004E/LAB_0050) ------------------------ */

static const UWORD lenw[16] = {
	0x0001, 0x4001, 0x8002, 0xa002, 0xc004, 0xc804, 0xd004, 0xd804,
	0xe006, 0xe206, 0xe406, 0xe606, 0xe806, 0xea06, 0xec06, 0xee06
};

static void emit_len(struct pctx *c, ULONG L)		/* L = len - 2 */
{
	ULONG w;
	if (L < 16) {
		w = lenw[L];
		emit(c, w << 16, w & 0xff);
		return;
	}
	{
		ULONG d2 = L - 16, d0 = 16, d1 = 3, d4 = 5;
		for (;;) {
			d2 -= d0;
			if ((LONG)d2 < 0) {
				d2 += d0;
				break;
			}
			d1++; d4++; d0 <<= 1;
		}
		emit(c, 0xffffffff, d1);
		emit(c, ror32(d2, d4), d4 - 1);
	}
}

/* ---- distance code (LAB_0043 walk + LAB_003E emit) ---------------- */

static const UWORD distw[8][2] = {	/* {bits, limit} */
	{8, 0x20}, {10, 0x80}, {12, 0x200}, {13, 0x400},
	{14, 0x800}, {15, 0x1000}, {16, 0x2000}, {17, 0x4000}
};
static const ULONG distor[8] = {	/* 3-bit class prefix << (bits-3) */
	0, 0x80, 0x400, 0xc00, 0x2000, 0x5000, 0xc000, 0x1c000
};

static void emit_dist(struct pctx *c, ULONG dist)
{
	ULONG d0 = dist, field, bits;
	int   i = 0;
	while (d0 >= distw[i][1]) {
		d0 -= distw[i][1];
		i++;
	}
	field = distor[i] | d0;
	bits  = distw[i][0];
	emit(c, field << (32 - bits), bits - 1);
}

/* ---- match finder (LAB_0044) ---------------------------------------
 * inserts cur into hash head + chain unconditionally, then walks the
 * chain.  Filter byte: in[cur+len] -- only candidates whose byte at
 * the current best length matches are tried (limited by 64(xsp)).
 * Returns dist<<16 | (len-2); negative low word = no match.          */

static LONG find(struct pctx *c, UBYTE *cur, UWORD hint)
{
	UBYTE *bound = cur - 32415;
	UBYTE *cand, *best, *p, *cd;
	UBYTE  filt;
	UWORD  pw = (UWORD)(ULONG)cur;
	ULONG  h  = (((ULONG)cur[1] << c->shift) & 0xff00) | cur[0];
	UWORD  dist = (UWORD)(pw - c->head[h]);
	UWORD  len = hint;
	LONG   d3 = 0, tries = c->tries;

	c->head[h]    = pw;
	CHAIN(c, pw)  = dist;
	cand          = cur - dist;
	if (cand < bound)
		return -1;
	best = cur;
	filt = cur[hint];
	for (;;) {				/* LAB_0045: eval candidate */
		LONG n;
		p = cur; cd = cand;
		if (*p++ != *cd++)
			goto done;		/* byte0 mismatch -> done */
		if (*p++ != *cd++)
			goto walk;		/* byte1 mismatch -> chain */
		n = 0x20a;
		while (*p++ == *cd++) {
			if (!--n)
				break;
		}
		if (p > best) {
			best = p;
			filt = *--p;		/* a4@-: p back to match end */
			d3   = ((LONG)(pw - (UWORD)(ULONG)cand)) << 16;
			if (p >= c->end) {
				len = (UWORD)(c->end - cur);
				goto done;
			}
			len = (UWORD)(p - cur);
			if (len >= 0x100)
				goto done;
		}
walk:		for (;;) {		/* LAB_0047/48: chain + filter */
			cand -= CHAIN(c, (UWORD)(ULONG)cand);
			if (cand < bound)
				goto done;
			if (cand[len] == filt)
				break;		/* dbeq: accept -> eval */
			if ((LONG)--tries < 0)
				goto done;	/* rejects exhausted */
		}
	}
done:
	/* LAB_0049 tail: `subq.w #2,d3` then, for len-2 only,
	 * `addi.l #0xfe000000,d0` (d0 = dist<<16) -- its carry lands in
	 * the caller's BCS, so a len-2 match with dist >= 512 returns
	 * "no match" and the corrupt '00'+9-bit token is never emitted. */
	len -= 2;
	if (!len && (d3 >> 16) >= 0x200)
		return -1;
	return d3 | (UWORD)len;
}

/* ---- hash-insert one position (LAB_003B body) ---------------------- */

static void insert(struct pctx *c, UBYTE *p)
{
	UWORD pw = (UWORD)(ULONG)p;
	ULONG h  = (((ULONG)p[1] << c->shift) & 0xff00) | p[0];
	WORD   d = (WORD)(pw - c->head[h]);
	c->head[h] = pw;
	CHAIN(c, pw)  = (UWORD)d;
}

/* ---- packer core (LAB_0033) ---------------------------------------- */

static LONG pack_core(struct XpkSubParams *xp, UBYTE *alloc1,
		      UBYTE *alloc2, ULONG hshift)
{
	UBYTE *in    = (UBYTE *)xp->xsp_InBuf;
	ULONG  inlen = xp->xsp_InLen;
	UBYTE *out   = (UBYTE *)xp->xsp_OutBuf;
	UBYTE *a0 = in, *litstart;
	LONG   d3;
	int    final = 0;

	struct pctx ctx, *c = &ctx;
	c->chain = alloc1 + 0x8000;
	c->head  = (UWORD *)alloc2;
	c->shift = hshift;
	c->end   = in + inlen;
	c->tries = xp->xsp_Tries;

	filldown(alloc1 + 0x10000, 0x101, 0xffff);	/* 0x10100: underwrites */
	filldown(alloc2 + (512 << hshift),		/* seed = in.w */
		 ((512 << hshift) >> 8) + 1, (UWORD)(ULONG)a0);

	c->epos = out; c->eacc = 0; c->eslot = 0;
	litstart = a0;
	a0++;						/* find starts at in+1 */

	for (;;) {
		if (!final) {
			d3 = find(c, a0, 1);
			if ((WORD)d3 < 0) {
				if (++a0 < c->end)
					continue;
				d3 = 0;
				final = 1;
			} else {
				LONG prev = d3, nx;
				for (;;) {		/* lazy eval */
					if (++a0 >= c->end) {
						d3 = prev; a0--;
						break;
					}
					nx = find(c, a0, (UWORD)prev);
					if ((WORD)nx < 0 ||
					    (UWORD)prev >= (UWORD)nx) {
						d3 = prev; a0--;
						break;
					}
					prev = nx;
				}
			}
		}
		if (c->epos >= (UBYTE *)xp->xsp_Bound)
			return 0;
		{					/* literal run + copy */
			ULONG run = (ULONG)(a0 - litstart);
			emit_run(c, run);
			while (litstart < a0)
				*c->epos++ = *litstart++;
		}
		{					/* hash-insert match pos */
			WORD i = (WORD)(UWORD)d3;
			a0++;
			for (;;) {
				a0++;
				if (--i == -1)
					break;
				insert(c, a0);
			}
		}
		if ((UWORD)d3 == 0)
			emit(c, ((ULONG)d3) << 5, 10);	/* '00'+dist9b */
		else {
			emit_len(c, (UWORD)d3);
			emit_dist(c, (UWORD)(d3 >> 16));
		}
		litstart = a0;
		if (final || a0 >= c->end)
			break;
	}
	emit(c, 0, 7);					/* end marker + flush */
	return (LONG)(c->epos - out);
}

/* ---- LIBFUNC_1 (-36): XpksPackChunk -------------------------------- */

LONG C_PackChunk(struct XpkSubParams *xp)
{
	APTR  alloc1, alloc2;
	ULONG size2 = 0x20000;
	LONG  shift = 8, ret;

	alloc1 = ALLOCMEM(0x10000, 1);
	if (!alloc1)
		return -7;
	for (;;) {
		alloc2 = ALLOCMEM(size2, 1);
		if (alloc2)
			break;
		size2 >>= 1;
		shift >>= 1;
		if (shift < 1) {
			FREEMEM(alloc1, 0x10000);
			return -7;
		}
	}

	xp->xsp_Bound = (APTR)((UBYTE *)xp->xsp_OutBuf
				+ xp->xsp_InLen - 50);
	xp->xsp_Tries = 1UL << (UWORD)(((short)xp->xsp_Mode) / 10);

	ret = pack_core(xp, (UBYTE *)alloc1, (UBYTE *)alloc2,
			(ULONG)shift);
	xp->xsp_OutLen = (ULONG)ret;

	FREEMEM(alloc2, size2);
	FREEMEM(alloc1, 0x10000);
	return ret ? 0 : -17;
}

/* ---- LIBFUNC_4 (-54): XpksUnpackChunk ------------------------------ */

static const UWORD dclass[8][2] = {	/* {base, bits-1} LAB_007B */
	{0, 4}, {0x20, 6}, {0xa0, 8}, {0x2a0, 9},
	{0x6a0, 10}, {0xea0, 11}, {0x1ea0, 12}, {0x3ea0, 13}
};
static const UWORD lclass[10][2] = {	/* {bits-1, base} LAB_007C */
	{0, 2}, {1, 4}, {2, 8}, {3, 16}, {4, 32},
	{5, 64}, {6, 128}, {7, 256}, {8, 512}, {9, 1024}
};
static const UWORD rclass[16][2] = {	/* {bits-1, base} LAB_007D+2 */
	{0, 0}, {1, 2}, {2, 6}, {3, 14}, {4, 30}, {5, 62},
	{6, 126}, {7, 254}, {8, 510}, {9, 1022}, {10, 2046},
	{11, 4094}, {12, 8190}, {13, 16382}, {14, 32766}, {15, 65534}
};

struct dstate {
	UBYTE *in;
	ULONG  acc;
};

static ULONG dbit(struct dstate *s)
{
	ULONG a = s->acc, c;
	a <<= 1;
	c = a >> 8;
	a &= 0xff;
	if (!a) {			/* sentinel out -> reload */
		a = *s->in++;
		a = (a << 1) | 1;	/* addx.b d3,d3 with X=1 */
		c = a >> 8;
		a &= 0xff;
	}
	s->acc = a;
	return c;
}

static ULONG dbits(struct dstate *s, ULONG n)
{
	ULONG v = 0;
	while (n--)
		v = (v << 1) | dbit(s);
	return v;
}

static void mash_unpack(UBYTE *in, UBYTE *out, UBYTE *oend)
{
	struct dstate s;
	s.in  = in;
	s.acc = 0x80;
	while (out < oend) {
		if (dbit(&s)) {				/* literal run */
			ULONG cnt, k = 0;
			while (k < 5 && dbit(&s))
				k++;
			if (k < 5)
				cnt = k + 1;
			else {
				ULONG w = 0;
				/* original walks a2 past the table on desynced
				 * streams (reads hunk memory); capped here so a
				 * host build does not index out of bounds */
				while (dbit(&s) && w < 15)
					w++;
				cnt = dbits(&s, rclass[w][0] + 1)
				    + rclass[w][1] + 6;
			}
			while (cnt--)
				*out++ = *s.in++;
		}
		{					/* match -- always */
			ULONG len, dist;
			if (dbit(&s)) {
				ULONG w = 0, d2;
				/* same cap: a2 can walk past lclass */
				while (dbit(&s) && w < 9)
					w++;
				d2 = dbits(&s, lclass[w][0] + 1)
				   + lclass[w][1];
				{
					ULONG c = dbits(&s, 3);
					dist = dbits(&s, dclass[c][1] + 1)
					     + dclass[c][0];
				}
				len = d2 + 2;
			} else if (dbit(&s)) {
				ULONG c = dbits(&s, 3);
				dist = dbits(&s, dclass[c][1] + 1)
				     + dclass[c][0];
				len  = 3;
			} else {
				dist = dbits(&s, 9);
				len  = 2;
			}
			{
				UBYTE *src = out - dist;
				while (len--)
					*out++ = *src++;
			}
		}
	}
}

LONG C_UnpackChunk(struct XpkSubParams *xp)
{
	UBYTE *out = (UBYTE *)xp->xsp_OutBuf;
	mash_unpack((UBYTE *)xp->xsp_InBuf, out, out + xp->xsp_OutLen);
	return 0;
}
