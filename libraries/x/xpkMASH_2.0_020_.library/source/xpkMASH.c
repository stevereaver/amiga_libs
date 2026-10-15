/*
 * xpkMASH.library 2.0 -- "Mashiner 020+ V2.0" XPK sublibrary
 * Reconstruction of binary/xpkMASH_2.0(020).library
 *   $VER: xpkMASH V2.0 (1 Oct 2013) by Zdenek Kadelac
 *
 * Bit-packed LZ77, 32KB window ("WindowSize: 32KB, 2 mixed streams").
 * Same wire format family as V1.16, but V2.0 is a 68020+ build
 * (scaled-index addressing + AFB_68020 init gate) with a
 * completely different matcher: pass1 builds a per-position "gap"
 * array (distance to previous occurrence of the byte pair starting at
 * each index, from a 64K-entry rolling-key head table at wk+0), pass2
 * is a lazy matcher that walks gap chains and forward-scans for better
 * matches emitting {pos.w, dist<<16|len} records back over the head
 * table, and a third pass emits the bit stream while literals are
 * copied raw through the same output cursor ("2 mixed streams": the
 * emitter reserves a flag-slot byte when a pending-bit group starts
 * and fills it when 8 bits accumulate).
 *
 * Stream format (MSB-first):
 *   run:   '0'                       -> 0 literals
 *          '1'^n '0'                 -> n literals (n = 1..5)
 *          '1'^6 '1'^k '0' + g(k+1)  -> run = rclass[k+1].base + g + 6
 *   match: '00' + dist(9b)                  -> len 2
 *          '01' + class3 + bcs-gamma        -> len 3
 *          '1'  + '1'^k '0' + g(k+1)        -> len-2 = lclass[k].base+g
 *            then class3 + bcs-gamma dist  -> dist <= 32415
 * The bcs-gamma seeds d4 with a table word and shifts bits in while
 * the shifted-out bit is 1, then adds the table base; when the bit
 * accumulator runs dry mid-field and d4 >= 0xff00 a whole input byte
 * is grabbed into d4 (8 bits at once) before the acc reload -- a pure
 * optimisation, bit-equivalent to 8 sequential reads.
 *
 * DEFECTS reproduced / noted (see okf/):
 *   - pass1 reads in[inlen] for even inlen (1 byte past InBuf) since
 *     it always consumes exactly 1 + 2*pairs bytes.
 *   - PackFree frees the work buffer but never clears xsp_Work;
 *     the next pack silently reuses the freed memory (UAF).
 *   - pass2 record output overlaps the still-live gap table once
 *     records exceed 0x20000 bytes: inlen > ~43690 (< MaxPkIn 64K)
 *     can corrupt unread gaps -> bogus matches.
 *   - literal runs >= 32776 hang the original (emit_gamma's 16-bit
 *     span register wraps to 0 -> infinite loop).
 *   - len-2 matches with dist >= 512 are dropped to a literal
 *     (two checks, incl. the tail2 path).
 *   - pack bound is OutBuf + InLen - 10: output must beat the input
 *     by at least 11 bytes or PackChunk returns -17 (so inlen <= 10
 *     always fails; inlen 1 also underflows the bound pointer).
 *   - decoder: a 0x00 flag byte consumed inside a distance gamma
 *     loses its trailing zero bits (the acc reload misses the +1
 *     sentinel when X is clear); distance-0 matches read unwritten
 *     output; the final '00' end marker makes the decoder consume
 *     bits/bytes past the packed stream and may write 2 bytes past
 *     OutBuf end.
 *   - the original's first RELOC32 entry patches code+0, corrupting
 *     the entry stub on load -> reserved vectors (-24/-48/-60)
 *     would execute garbage if called.  This rebuild does not
 *     relocate offset 0.
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef short          WORD;
typedef unsigned int   ULONG;	/* 32-bit on m68k AND host */
typedef int            LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0x00 */
	ULONG xsp_InLen;	/* +0x04 */
	APTR  xsp_OutBuf;	/* +0x08 */
	ULONG xsp_pad0c;	/* +0x0c */
	ULONG xsp_OutLen;	/* +0x10 pack: outlen; unpack: outsize */
	ULONG xsp_pad14[8];	/* +0x14..0x33 */
	APTR  xsp_Work;		/* +0x34 cached work allocation    */
	ULONG xsp_WorkSize;	/* +0x38 alloc size for PackFree   */
	APTR  xsp_Bound;	/* +0x3c = out + inlen - 10        */
	ULONG xsp_Tries;	/* +0x40 = 1024: chain budget seed */
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

/* ------------------------------------------------------------------ */
/* bit emitter (0x4ce): acc = pending byte + sentinel (0 = empty).    */
/* On entry with empty acc a flag-slot byte is reserved at epos and   */
/* filled when 8 bits accumulate; >=8 remaining bits mid-field go out */
/* as a raw byte at epos, then a fresh flag slot is reserved.         */
/* ------------------------------------------------------------------ */

struct ectx {
	UBYTE *epos;
	UBYTE *eslot;
	ULONG  eacc;
};

static ULONG ror32(ULONG v, ULONG n)
{
	return (v >> n) | (v << (32 - n));
}

/* emit n+1 bits of d0 (MSB first) -- the callers pass count-1, the
 * dbf-style accounting is transliterated */
static void emit(struct ectx *c, ULONG d0, ULONG n)
{
	LONG cnt = (LONG)n;

	for (;;) {
		if (!c->eacc) {
			c->eslot = c->epos++;
			c->eacc = 1;
		}
		for (;;) {
			ULONG b = d0 >> 31;
			ULONG ov;
			d0 <<= 1;
			ov = c->eacc & 0x80;
			c->eacc = ((c->eacc << 1) | b) & 0xff;
			if (ov)
				break;		/* flag byte complete */
			if (--cnt < 0)
				return;		/* done, acc pending */
		}
		*c->eslot = (UBYTE)c->eacc;
		c->eacc = 0;
		cnt -= 8;
		if (cnt >= 0) {			/* >=8 more: raw byte */
			d0 = (d0 << 8) | (d0 >> 24);
			cnt -= 8;
			*c->epos++ = (UBYTE)d0;
		}
		cnt += 8;
		if (--cnt < 0)			/* dbf exit: acc empty */
			return;
	}
}

/* shared gamma emit (0x500): unary class long in pat, doubling span
 * buckets.  NOTE: span is a 16-bit register -- v >= 32768 wraps it to
 * 0 and the original loops forever (literal runs / lengths in that
 * range hang). */
static void emit_gamma(struct ectx *c, ULONG v, ULONG span,
		       ULONG bits, ULONG pat)
{
	while ((UWORD)v >= (UWORD)span) {
		v = (v - span) & 0xffff;
		pat <<= 1;
		bits += 2;
		span = (span << 1) & 0xffff;
	}
	pat |= v;
	emit(c, ror32(pat, bits), bits - 1);
}

/* literal-run code (0x4bc); table496 words = code<<8 | nbits-1 */
static const UWORD runw[8] = {
	0x0000, 0x8001, 0xc002, 0xe003, 0xf004, 0xf805, 0xfc07, 0xfd07
};

static void emit_run(struct ectx *c, ULONG gap)
{
	if (gap < 8) {
		ULONG w = runw[gap];
		emit(c, w << 16, w & 0xff);
		return;
	}
	emit_gamma(c, gap - 8, 4, 10, 0xfffffff8UL);
}

/* match length code (0x4a6); L = len - 2 */
static const UWORD lenw[16] = {	/* table476 */
	0x0001, 0x4001, 0x8002, 0xa002, 0xc004, 0xc804, 0xd004, 0xd804,
	0xe006, 0xe206, 0xe406, 0xe606, 0xe806, 0xea06, 0xec06, 0xee06
};

static void emit_len(struct ectx *c, ULONG L)
{
	if (L < 16) {
		ULONG w = lenw[L];
		emit(c, w << 16, w & 0xff);
		return;
	}
	emit_gamma(c, L - 16, 16, 9, 0xffffffe0UL);
}

/* distance code (0x236 class walk + field emit) */
static const UWORD distw[8][2] = {	/* table436 {bits, span} */
	{8, 0x20}, {10, 0x80}, {12, 0x200}, {13, 0x400},
	{14, 0x800}, {15, 0x1000}, {16, 0x2000}, {17, 0x4000}
};
static const ULONG distor[8] = {	/* table456: class << (bits-3) */
	0, 0x80, 0x400, 0xc00, 0x2000, 0x5000, 0xc000, 0x1c000
};

static void emit_dist(struct ectx *c, ULONG dist)
{
	ULONG d0 = dist, bits;
	int   i = 0;

	while ((UWORD)d0 >= distw[i][1]) {
		d0 -= distw[i][1];
		i++;
	}
	d0 |= distor[i];
	bits = distw[i][0];
	emit(c, ror32(d0, bits), bits - 1);
}

/* ------------------------------------------------------------------ */
/* pass1 (0x26e): gap array.  gaps[i] = distance from the byte pair  */
/* starting at index i to its previous occurrence, or -1.             */
/* head[] = 64K UWORD table at work base (rolling 16-bit key).        */
/* a4 is a 1-based "position" counter: pair starting at index i is    */
/* recorded at gaps[i] with a4 = i+1 when its second byte is read.    */
/* Exactly `pairs` longs are written; reads = 1 + 2*pairs bytes       */
/* (1 byte past InBuf end for even inlen).                            */
/* ------------------------------------------------------------------ */

#define WINFLOOR	32415	/* 0x7e9f: max encoded distance */

static void pass1(UBYTE *in, UWORD *head, WORD *gaps, ULONG inlen)
{
	UBYTE *a0 = in;
	ULONG  a4;
	ULONG  d1;
	WORD  *a2w = gaps;	/* original writes longs; on host the
				 * two word slots are spelled out so
				 * the byte order can't bite */
	LONG   pairs = (LONG)(inlen >> 1);
	LONG   itA, itB, i;

	d1 = *a0++;
	a4 = 1;

	if (pairs < 16203) {
		itA = pairs;		/* bra-into-dbf: pairs bodies */
		itB = 0;
	} else {
		itA = 16203;
		itB = pairs - 16203;
	}

	/* phase A: first ~32K positions, no distance clamp */
	for (i = 0; i < itA; i++) {
		UWORD *h, prev, gA, gB;
		d1 = ((d1 << 8) | *a0++) & 0xffff;
		a4++;
		h = head + d1;
		prev = *h;
		*h = (UWORD)a4;
		gA = prev ? (UWORD)(a4 - prev) : 0xffff;
		d1 = ((d1 << 8) | *a0++) & 0xffff;
		a4++;
		h = head + d1;
		prev = *h;
		*h = (UWORD)a4;
		gB = prev ? (UWORD)(a4 - prev) : 0xffff;
		*a2w++ = (WORD)gA;
		*a2w++ = (WORD)gB;
	}
	/* phase B: same but gap >= 32415 -> -1 */
	for (i = 0; i < itB; i++) {
		UWORD *h, prev, gA, gB;
		d1 = ((d1 << 8) | *a0++) & 0xffff;
		a4++;
		h = head + d1;
		prev = *h;
		*h = (UWORD)a4;
		gA = (prev && (UWORD)(a4 - prev) < WINFLOOR)
		   ? (UWORD)(a4 - prev) : 0xffff;
		d1 = ((d1 << 8) | *a0++) & 0xffff;
		a4++;
		h = head + d1;
		prev = *h;
		*h = (UWORD)a4;
		gB = (prev && (UWORD)(a4 - prev) < WINFLOOR)
		   ? (UWORD)(a4 - prev) : 0xffff;
		*a2w++ = (WORD)gA;
		*a2w++ = (WORD)gB;
	}
	/* 0x312-0x316: sentinel -- gaps[inlen-1] = -1 */
	gaps[inlen - 1] = (WORD)0xffff;
}

/* ------------------------------------------------------------------ */
/* pass2 (0x320): lazy matcher.  Records {UWORD pos; ULONG info} go  */
/* to the head table at wk+0; gaps[] doubles as the chain (gap[i] is */
/* the link to the previous same-pair position).  a1 is a BYTE       */
/* cursor into gaps (hops are 2*gap bytes); d0 is only ever          */
/* word-written after `moveq #0` so d0.hi stays 0 and the pointer    */
/* subtractions use the unsigned 16-bit value (a negative gap hops   */
/* forward ~64K, into garbage -- faithful).                          */
/* ------------------------------------------------------------------ */

/* pass2 writes records of three words {pos, dist, len-2} over the
 * head table -- the original stores pos+info as movew+movel, i.e. a
 * 6-byte record.  The 020-vs-000 difference is elsewhere: the 020
 * build uses scaled-index addressing (%a2@(d3:w:2) etc, 68020+ only)
 * and gates LibInit on AFB_68020.
 * Using a word cursor keeps host byte order out of it. */
static void pass2(UBYTE *in, WORD *gaps, UWORD *recs,
		  UBYTE *end, ULONG tries)
{
	UBYTE *a0 = in;
	UBYTE *d7 = end;
	WORD  *a2 = gaps + 1;
	UWORD *a3 = recs;
	UBYTE *a1 = 0;
	UBYTE *a4 = 0, *a5 = 0, *a6, *d4 = 0;
	ULONG  d0 = 0, d1 = 0, d2 = 0, d3 = 0;
	ULONG  d6;
	ULONG  d5 = (tries << 16) | 0x100;	/* 0x04000100 */

litadv:						/* 0x332 */
	a0++;
	if (a0 >= d7)
		goto fin;
read:						/* 0x340 */
	a1 = (UBYTE *)a2;
	d0 = (UWORD)*a2++;
	if ((WORD)d0 < 0)
		goto litadv;
	/* eval setup (0x346): d1 = budget seed, a6->d4 = window floor */
	d1 = ror32(d5, 16);			/* 0x01000400: budget .w */
	a6 = a0 - WINFLOOR;
	a5 = a0;
	d4 = a6;
	d6 = (ULONG)(long)a0;
	d2 = 0;
	a1 -= d0; a5 -= d0; a1 -= d0;		/* slot & candidate hop */

eval:						/* 0x35c */
	a4 = a0 + 2;
	a6 = a5 + 2;
	while (*a4++ == *a6++)			/* cmpmb */
		;
	if (d6 < (ULONG)(long)a4) {		/* improves */
		d3 = (UWORD)(ULONG)(long)a0;
		d6 = (d6 & 0xffff0000UL) | ((ULONG)(long)a4 & 0xffff);
		d3 = (d3 & 0xffff0000UL) |
		     (((UWORD)d3 - (UWORD)(ULONG)(long)a5) & 0xffff); /* dist */
		d5 = (d5 & ~0xffUL) | *--a4;	/* filt = byte after end */
		d3 = (d3 << 16) | (UWORD)(ULONG)(a4 - a0);	/* | len */
		if (a2[(UWORD)d3 - 2] < 0)	/* gaps[cur+len-1] < 0? */
			goto tail2;
		if ((UWORD)d3 >= (UWORD)d5)	/* len >= 0x100|filtb */
			goto accept;
	}
chain:						/* 0x384 */
	d0 = (UWORD)*(WORD *)a1;
	if ((WORD)d0 < 0)
		goto done;
chainmid:					/* 0x388 */
	a1 -= d0;
	a5 -= d0;
	a1 -= d0;
	if (a5[(UWORD)d3] == (UBYTE)d5) {	/* cand[len] == filt */
		if (a5 >= d4)			/* in window? */
			goto eval;
		*(WORD *)(a1 + 2 * d0) = (WORD)-1;	/* poison */
		goto done;
	}
	d1 = (d1 - 1) & 0xffff;			/* dbeq: loop while neq */
	if ((WORD)d1 != (WORD)-1)
		goto chain;
	goto done;

done:						/* 0x3a2 */
	if (d2) {
		if ((UWORD)d2 >= (UWORD)d3)
			goto emitold;		/* keep best */
		d2 = d3;
		if ((UWORD)d3 < 15)
			goto fwd;
		goto accept2;
	}
	d2 = d3;
	if ((UWORD)d2 == 2 && d2 >= 0x02000000UL)	/* len2, dist>=512 */
		goto litadv;
	goto fwd;

tail2:						/* 0x3ea */
	if ((UWORD)d3 == 2 && d3 >= 0x02000000UL)
		goto litadv;
accept:						/* 0x3fa */
	d2 = d3;
accept2:					/* 0x3fc */
	a2++;					/* skip gaps[p+1] */
	if ((UWORD)d2 < 32700)
		goto emitdo;
	d2 = (d2 & 0xffff0000UL) | 32700;
	a0++;
emitold:					/* 0x40a */
	a0--;
emitdo:						/* 0x40c */
	d2 -= 2;				/* info = dist<<16|len-2 */
	a3[0] = (UWORD)(ULONG)(long)a0;		/* pos  */
	a3[1] = (UWORD)(d2 >> 16);		/* dist */
	a3[2] = (UWORD)d2;			/* len-2 */
	a3 += 3;
	a2 += (UWORD)d2;			/* skip inside-match gaps */
	a0 += (UWORD)d2 + 2;			/* cur += len */
	if (a0 < d7)
		goto read;			/* 0x41a -> 0x340 */
	/* 0x420: trailing overshoot clamp */
	d0 = (ULONG)(a0 - 1 - d7);
	if ((LONG)d0 >= 0) {
		UWORD w = ((UWORD)d2 >= (UWORD)d0)
			? (UWORD)(d2 - d0) : 0;
		a3[-1] = w;
	}
	return;

fwd:						/* 0x3b8 */
	d6 = (ULONG)(long)a0;
	a1 = (UBYTE *)a2;
	d6 += 5;
	/* 0x3be: one scan step, then chain-walk */
	d1 = (UWORD)*a2++;
	a0++;
	d4++;
	d0 = d1;
	d1 = (d1 - 1) & 0xffff;			/* gap-1; gap==1 -> keep 0 */
	if (d1)
		d1 = ror32(d5, 16);		/* reload budget */
	a5 = a0;
	d5 = (d5 & ~0xffUL) | a0[(UWORD)d3];	/* filt = in[cur+bestlen] */
	if (a2[(UWORD)d3 - 2] < 0)
		goto emitold;
	goto chainmid;				/* 0x388 with d0 = gap */

fin:						/* 0x338 */
	a3[0] = (UWORD)(ULONG)(long)a0;
	a3[1] = 0;
	a3[2] = 0;
}

/* ------------------------------------------------------------------ */
/* emit pass (0x200): walks records, emits literal runs + match       */
/* codes; literals copied raw to the output cursor.                   */
/* ------------------------------------------------------------------ */

static LONG emit_all(UBYTE *in, UBYTE *out, UBYTE *bound, UBYTE *end,
		     UWORD *recs)
{
	struct ectx c;
	UWORD *a3 = recs;
	UBYTE *a0 = in;

	c.epos = out;
	c.eslot = 0;
	c.eacc = 0;

	for (;;) {
		UWORD pos = *a3++;
		ULONG gap, info;
		if (c.epos >= bound)
			return 0;		/* -> -17 */
		info = ((ULONG)a3[0] << 16) | a3[1];
		a3 += 2;
		gap = (UWORD)(pos - (UWORD)(ULONG)(long)a0);
		emit_run(&c, gap);
		while (gap--)
			*c.epos++ = *a0++;
		a0 += (UWORD)info + 2;		/* len */
		if (!(UWORD)info)
			emit(&c, info << 5, 10);	/* '00' + dist 9b */
		else {
			emit_len(&c, (UWORD)info);
			emit_dist(&c, info >> 16);
		}
		if (a0 >= end)
			break;
	}
	emit(&c, 0, 7);				/* end marker + flush */
	return (LONG)(c.epos - out);
}

/* ------------------------------------------------------------------ */
/* C_PackChunk -- LIBFUNC -36 (0x140).                                 */
/* ------------------------------------------------------------------ */

static void memzero(UBYTE *p, ULONG n)
{
	while (n--)
		*p++ = 0;
}

static LONG pack_body(struct XpkSubParams *xp, UBYTE *wk)
{
	UBYTE *in    = (UBYTE *)xp->xsp_InBuf;
	ULONG  inlen = xp->xsp_InLen;
	UBYTE *out   = (UBYTE *)xp->xsp_OutBuf;
	WORD  *gaps  = (WORD *)(wk + 0x20000);

	/* 0x1b2: clear the 128KB head table [wk, wk+0x20000) */
	memzero(wk, 0x20000);

	pass1(in, (UWORD *)wk, gaps, inlen);
	pass2(in, gaps, (UWORD *)wk, in + inlen, xp->xsp_Tries);
	return emit_all(in, out, (UBYTE *)xp->xsp_Bound, in + inlen,
			(UWORD *)wk);
}

LONG C_PackChunk(struct XpkSubParams *xp)
{
	ULONG inlen = xp->xsp_InLen;
	UBYTE *wk;
	ULONG size;
	LONG  ret;

	if (!xp->xsp_Work) {
		size = 2 * inlen + 0x20010;
		wk = (UBYTE *)ALLOCMEM(size, 0);
		xp->xsp_Work = wk;
		if (!wk)
			return -7;
		xp->xsp_Tries    = 1024;
		xp->xsp_WorkSize = size;
	} else
		wk = (UBYTE *)xp->xsp_Work;

	xp->xsp_Bound = (APTR)((UBYTE *)xp->xsp_OutBuf + inlen - 10);

	ret = pack_body(xp, wk);
	xp->xsp_OutLen = (ULONG)ret;
	return ret ? 0 : -17;
}

/* LIBFUNC -42 (0x126): frees the work buffer -- and leaves the
 * pointer dangling (UAF on the next pack), like the original. */
void C_PackFree(struct XpkSubParams *xp)
{
	if (xp->xsp_Work)
		FREEMEM(xp->xsp_Work, xp->xsp_WorkSize);
}

/* ------------------------------------------------------------------ */
/* decoder (0x518): straight-line bit extraction, sentinel/X-bit acc  */
/* ------------------------------------------------------------------ */

struct dstate {
	UBYTE *in;
	ULONG  acc;	/* byte accumulator + sentinel */
};

static ULONG dbit(struct dstate *s)
{
	ULONG a = s->acc;
	ULONG x = a & 0x80;	/* carry out of addb = the bit */

	a = (a << 1) & 0xff;
	if (!a) {		/* byte spent -> reload; X propagates */
		a = ((ULONG)*s->in++ << 1) | (x ? 1 : 0);
		x = a & 0x100;
		a &= 0xff;
	}
	s->acc = a;
	return x ? 1 : 0;
}

/* distance field: BCS-seeded gamma (0x604-0x61a).  When the acc runs
 * dry mid-field and d4 >= 0xff00 a whole input byte is grabbed into
 * d4 before the acc reload -- equivalent to 8 sequential bit reads. */
static ULONG dec_dist(struct dstate *s, ULONG seed)
{
	ULONG d4 = seed;

	for (;;) {
		ULONG a = s->acc, x, c;
		x = a & 0x80;
		a = (a << 1) & 0xff;
		if (!a) {
			if (d4 >= 0xff00)	/* byte grab (0x60e) */
				d4 = ((d4 << 8) | *s->in++) & 0xffff;
			a = ((ULONG)*s->in++ << 1) | (x ? 1 : 0);
			x = a & 0x100;
			a &= 0xff;
		}
		s->acc = a;
		c = d4 & 0x8000;
		d4 = ((d4 << 1) | (x ? 1 : 0)) & 0xffff;
		if (!c)
			break;
	}
	return d4;
}

/* BCC gamma used by the run/len tables: shift bits until bit15 of
 * the seed overflows. */
static ULONG dec_gamma(struct dstate *s, ULONG seed)
{
	ULONG d = seed;

	for (;;) {
		ULONG b = dbit(s);
		ULONG c = d & 0x8000;
		d = ((d << 1) | b) & 0xffff;
		if (c)
			break;
	}
	return d;
}

/* distance class table at 0x638: {base, seed} */
static const UWORD dclass[8][2] = {
	{0x0000, 0xf000}, {0x0020, 0xfc00}, {0x00a0, 0xff00},
	{0x02a0, 0xff80}, {0x06a0, 0xffc0}, {0x0ea0, 0xffe0},
	{0x1ea0, 0xfff0}, {0x3ea0, 0xfff8}
};

/* length class table at 0x658 (a5 = 0x654, walked from +4):
 * {seed, base}; index = count of '1' bits after the ext flag.
 * Entry 15 is the bytes actually at 0x694 (start of rclass). */
static const UWORD lclass[16][2] = {
	{0x8000, 0x0002}, {0x4000, 0x0004}, {0x2000, 0x0008},
	{0x1000, 0x0010}, {0x0800, 0x0020}, {0x0400, 0x0040},
	{0x0200, 0x0080}, {0x0100, 0x0100}, {0x0080, 0x0200},
	{0x0040, 0x0400}, {0x0020, 0x0800}, {0x0010, 0x1000},
	{0x0008, 0x2000}, {0x0004, 0x4000}, {0x0002, 0x8000},
	{0x8000, 0x0000}	/* 0x694: read for k = 15 */
};

/* literal-run class table at 0x690 (a4 = 0x690, walked from +4):
 * {seed, base}; index 0 unreachable, index k+1 for k extra '1's;
 * run = base + gamma + 6 (the +6 = 1 dbf copy + 5 fall-through
 * copies at 0x59c-0x5a4) */
static const UWORD rclass[17][2] = {
	{0x0002, 0x8000},	/* dead entry (never indexed) */
	{0x8000, 0x0000}, {0x4000, 0x0002}, {0x2000, 0x0006},
	{0x1000, 0x000e}, {0x0800, 0x001e}, {0x0400, 0x003e},
	{0x0200, 0x007e}, {0x0100, 0x00fe}, {0x0080, 0x01fe},
	{0x0040, 0x03fe}, {0x0020, 0x07fe}, {0x0010, 0x0ffe},
	{0x0008, 0x1ffe}, {0x0004, 0x3ffe}, {0x0002, 0x7ffe},
	{0x0001, 0xfffe}
};

static ULONG dec_dist3(struct dstate *s)
{
	ULONG c, d4 = 0;
	ULONG d1;

	/* three unrolled bit reads -> 3-bit class (0x5e2..0x5fe) */
	c = dbit(s); d4 = (d4 << 1) | c;
	c = dbit(s); d4 = (d4 << 1) | c;
	c = dbit(s); d4 = (d4 << 1) | c;
	d1 = ((ULONG)dclass[d4][0] << 16) | dclass[d4][1];
	return dec_dist(s, d1 & 0xffff) + (d1 >> 16);
}

static void mash2_unpack(UBYTE *in, UBYTE *out, UBYTE *oend)
{
	struct dstate s;
	ULONG run, len, dist, d2;

	s.in  = in;
	s.acc = 0x80;

	while (out < oend) {
		if (dbit(&s)) {			/* literal run */
			ULONG n = 1;
			while (n < 6 && dbit(&s))
				n++;
			if (n < 6)
				run = n;
			else {
				ULONG k = 0;
				/* original walks a2 past the table on
				 * desynced streams; capped for host */
				while (dbit(&s) && k < 15)
					k++;
				run = dec_gamma(&s, rclass[1 + k][0])
				    + rclass[1 + k][1] + 6;
			}
			while (run--)
				*out++ = *s.in++;
		}
		/* match -- always follows the run */
		if (dbit(&s)) {
			ULONG k = 0;
			while (dbit(&s) && k < 15)
				k++;
			d2 = dec_gamma(&s, lclass[k][0]) + lclass[k][1];
			len = d2 + 2;
			dist = dec_dist3(&s);
		} else if (dbit(&s)) {
			len = 3;
			dist = dec_dist3(&s);
		} else {
			dist = dec_dist(&s, 0xff00);	/* 9-bit field */
			len  = 2;
		}
		{
			UBYTE *src = out - dist;
			while (len--)
				*out++ = *src++;
		}
	}
}

LONG C_UnpackChunk(struct XpkSubParams *xp)
{
	UBYTE *out = (UBYTE *)xp->xsp_OutBuf;

	mash2_unpack((UBYTE *)xp->xsp_InBuf, out, out + xp->xsp_OutLen);
	return 0;
}
