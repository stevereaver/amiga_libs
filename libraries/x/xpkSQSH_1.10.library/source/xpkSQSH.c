/*
 * xpkSQSH.library 1.10 -- "Squash" XPK sublibrary
 * Reconstruction of binary/xpkSQSH_1.10.library
 *   idstring: "xpkSQSH 1.10 (6.3.94)"  by John Hendrikx
 *
 * The code hunk is BYTE-IDENTICAL to xpkSQSH_1.00.library -- the only
 * loadable-image differences are the idstring, the lib revision field
 * (10 vs 0) and the "Squash 1.10" longname.  Same codec source as 1.00.
 * The file also appends 704 bytes of dead data after HUNK_END (a
 * btst-based 68000-style decoder fragment, unreferenced by the hunk);
 * it is not part of the loadable image.
 *
 * LZ cruncher specialised for 8-bit sound data:
 *   - literals are emitted as signed DELTAS from the previous byte
 *   - a two-slot per-position chain walks match candidates, sorted by the
 *     sign of the first mismatched byte
 *   - literal widths narrow from 8 to 2..7 via a state remap table once
 *     "literal pressure" reaches 8
 *   - token choice is a per-item cost comparison (bits*4/items)
 *
 * 1.00-specific layout vs the 1.2 sibling: absolute-longword functab,
 * LibInit builds the XpkInfo + mode descriptor into library private data
 * (dataSize 0xa8), and there is no 68020 CPU gate even though the codec
 * uses bfins/bfext/bfffo.
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0  */
	ULONG xsp_InLen;	/* +4  */
	APTR  xsp_OutBuf;	/* +8  */
	ULONG xsp_pad;		/* +12 */
	ULONG xsp_OutLen;	/* +16 */
	ULONG xsp_pad2[8];	/* +20 .. +51 */
	APTR  xsp_Sub[1];	/* +52 workmem (pack) */
	ULONG xsp_saved;	/* +56 saved libbase (pack wrapper) */
};

#ifdef HOST_TEST
LONG host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
LONG host_Remove(APTR);
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz) host_FreeMem(p,sz)
#define REMOVE(p) host_Remove(p)
#define REGPARM_A0
#define REGPARM_A6
#else
#define REGPARM_A0 __asm("a0")
#define REGPARM_A6 __asm("a6")
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
    : "d1","d2","d3","d4","d5","d6","d7","a0","fp0","fp1","cc","memory");})
#define REMOVE_E(node) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","d2","d3","d4","d5","d6","d7","a0","fp0","fp1","cc","memory");})
#define ALLOCMEM(sz,f)	ALLOCMEM_E(sz,f)
#define FREEMEM(p,s)	FREEMEM_E(p,s)
#define REMOVE(p)	REMOVE_E(p)
#endif

/* ---------------- tables ---------------- */

/* match-length prefix words, indexed by len 0..47 (table @0x604) */
static const UWORD lentab[48] = {
	0,0,
	0x0004,0x0005,0x000c,0x000d,0x001c,0x001d,
	0x00f0,0x00f1,0x00f2,0x00f3,0x00f4,0x00f5,0x00f6,0x00f7,
	0x03e0,0x03e1,0x03e2,0x03e3,0x03e4,0x03e5,0x03e6,0x03e7,
	0x03e8,0x03e9,0x03ea,0x03eb,0x03ec,0x03ed,0x03ee,0x03ef,
	0x03f0,0x03f1,0x03f2,0x03f3,0x03f4,0x03f5,0x03f6,0x03f7,
	0x03f8,0x03f9,0x03fa,0x03fb,0x03fc,0x03fd,0x03fe,0x03ff
};

/* match+lencode extra bits per len 0..47 (@0x666; the first pair doubles
 * as the {1,0} single-literal tag) */
static const UBYTE lenextra[48] = {
	3,3,3,3, 4,4,5,5,
	8,8,8,8,8,8,8,8,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10
};

/* literal-width remap (@0x7fa): widtab[prevw*8 + slot - 17].
 * Rows for prevw 2..8, 8 bytes each; last byte of each row is a 0 pad. */
static const UBYTE widtab[56] = {
	2,3,4,5,6,7,8,0,
	3,2,4,5,6,7,8,0,
	4,3,5,2,6,7,8,0,
	5,4,6,2,3,7,8,0,
	6,5,7,2,3,4,8,0,
	7,6,8,2,3,4,5,0,
	8,7,6,2,3,4,5,0
};

/* literal tag {bits,value} words, flat index (prevw*8 + w) - 18.
 * Table lives at 0x570..0x603 in the binary; indices 0..17 overlap code
 * and are unreachable (prevw >= 2).  w==8 wraps into the next row's col0
 * by construction; w==9 lands on a col1 0x0000 pad and emits a zero-bit
 * tag (latent desync defect). */
static const UWORD deltok[56] = {
	/* prevw 2 */ 0x0101,0x0302,0x0406,0x061c,0x061d,0x061e,0x061f,
	/* pad idx25 */ 0x0000,
	/* prevw 3 */ 0x0302,0x0101,0x0406,0x061c,0x061d,0x061e,0x061f,
	/* pad idx33 */ 0x0000,
	/* prevw 4 */ 0x061c,0x0302,0x0101,0x0406,0x061d,0x061e,0x061f,
	/* pad idx41 */ 0x0000,
	/* prevw 5 */ 0x061c,0x061d,0x0302,0x0101,0x0406,0x061e,0x061f,
	/* pad idx49 */ 0x0000,
	/* prevw 6 */ 0x061c,0x061d,0x061e,0x0302,0x0101,0x0406,0x061f,
	/* pad idx57 */ 0x0000,
	/* prevw 7 */ 0x061c,0x061d,0x061e,0x061f,0x0302,0x0101,0x0406,
	/* pad idx65 */ 0x0000,
	/* prevw 8 */ 0x061c,0x061d,0x061e,0x061f,0x0406,0x0302,0x0101,
	/* pad idx73 */ 0x0000
};

/* ---------------- packer ---------------- */

/* litpress "greater than 7" gate.  The original encoder tests with
 * `cmpaw #7,a5' + bhi (0x62) / bls (0x63) -- strictly-greater, so the
 * narrow-width ladder and the '00' match marker engage at litpress>=8,
 * matching the decoder's `cmpw #8,d1' + bcc threshold. */
#define LITGT7(a5) ((a5) > 7)

struct pk {
	UBYTE *in, *out;
	LONG   inlen, bitbud, bitpos, pos;
	LONG   prevhash;
	ULONG  token;  LONG tokbits;
	LONG   mom, prevw;	/* asm packs these in d0: hi=mom, lo=prevw */
	LONG   litpress;	/* a5 */
	UWORD *head;		/* hash heads, workmem+0, 4096 entries */
	UWORD *node;		/* 2-slot links, workmem+0x2080, 4B/position */
};

static void putbits(struct pk *p, ULONG v, LONG w)
{
	/* original uses bfins -- every bit position is written, 0 or 1 */
	while (w-- > 0) {
		UBYTE m = 0x80 >> (p->bitpos & 7);
		if ((v >> w) & 1)
			p->out[p->bitpos >> 3] |= m;
		else
			p->out[p->bitpos >> 3] &= ~m;
		p->bitpos++;
	}
}

/* literal alternative cost (bits*4/items); sets *w,*run,*tokw.
 * litpress<=7 takes the forced-'0' single-literal path. */
static LONG litcost(struct pk *p, LONG *w, LONG *run, UWORD *tokw)
{
	UBYTE *dp;
	LONG d5, acc, cnt;

	if (!LITGT7(p->litpress)) {
		*w = 8; *run = 1; *tokw = 0x0100;	/* {1,0} = '0' */
		return 36;
	}
	dp = p->in + p->pos - 1;
	d5 = *dp++; acc = 0; cnt = 4;
	for (;;) {
		LONG nb = *dp++;
		LONG dl = (char)(d5 - nb);
		if (dl < 0) dl = -dl - 1;
		acc |= dl & 0xff;
		d5 = nb;
		if (--cnt < 0) break;
	}
	if (acc <= 1) {
		*w = 2; *run = 5;
	} else {
		LONG bw = 0, t = acc;
		while (t) { bw++; t >>= 1; }
		*w = bw + 1;			/* bfffo acc{24:0}: w = 33-ffo */
		*run = (*w == 8) ? 2 : 5;
	}
	if (*w >= 7 && p->mom < 20) {
		*w = 8; *run = 1;
	}
	*tokw = deltok[p->prevw * 8 + *w - 18];
	return (*run * *w + (*tokw >> 8)) * 4 / *run;
}

/* pack core -> bitpos, or -7 on bit-budget overflow */
static LONG sqsh_core(struct pk *p)
{
	LONG a2cnt = 1;
	{	/* asm clears all 0x22080 bytes of the workspace */
		UBYTE *cb = (UBYTE *)p->head;
		LONG ci;
		for (ci = 0; ci < 0x22080; ci++) cb[ci] = 0;
	}
	p->prevhash = 0; p->mom = 0; p->prevw = 0; p->litpress = 0;
	p->pos = 0; p->bitpos = 24;
	p->out[2] = p->in[0];

next_token:;
	/* inner scan: insert a2cnt positions, skipping same-hash repeats
	 * except on the last (d4==0) which is always walked; the emitted
	 * token describes the match at the LAST inserted position */
	LONG d4 = a2cnt - 1;
	UBYTE *scan = p->in + p->pos + 1;
	LONG d5 = p->prevhash;
	LONG floor = 0, rem = 46;
	{
		LONG a1 = p->pos;
		for (;;) {
			a1++;
			LONG d3 = ((scan[0] << 4) ^ scan[1]) & 0xfff;
			if (!d4 || d3 != d5) {
				LONG d7 = 46;
				LONG d2 = p->head[d3];
				if (!d2) {
					p->head[d3] = (UWORD)a1;
				} else {
					floor = (UWORD)(a1 - 0x5100);
					for (;;) {
						UBYTE *ca = p->in + d2, *cb = scan;
						LONG r = 46;
						for (;;)
							if (*ca++ != *cb++ || --r < 0)
								break;
						/* child slot: sign of last byte diff;
						 * <= 0 -> +0, > 0 -> +2 */
						LONG m = 46 - r;
						UWORD *sp = &p->node[d2 * 2 +
						  ((char)scan[m] - (char)p->in[d2 + m] > 0 ? 1 : 0)];
						if ((char)d7 >= (char)r &&
						    (short)d2 > (short)floor) {
							floor = d2;
							d7 = r;
						}
						d2 = *sp;
						if (d2) continue;
						*sp = (UWORD)a1;
						break;
					}
				}
				rem = d7;
				d5 = d3;
			}
			scan++;
			if (--d4 < 0) break;
		}
		p->pos = a1;
	}
	p->prevhash = d5;
	LONG len = 46 - rem;

	ULONG mtok = 0; LONG mbits = 0, mcost = 0x7fff;
	if (len > 1) {
		LONG dist = p->pos - floor - 1;		/* "dist-1" field base */
		mtok = (ULONG)lentab[len] << 16;
		if (dist < 0x100) {
			mbits = 10; mtok >>= 6;
		} else if (dist < 0x1100) {
			mbits = 13; mtok >>= 3; mtok |= 1L << 12;
			dist -= 0x100;
		} else {
			mbits = 16; mtok |= 1L << 14;
			dist -= 0x1100;
		}
		mtok |= (UWORD)dist;
		mbits += lenextra[len];
		if (LITGT7(p->litpress)) {	/* '1' marker -> '00' (see defects) */
			mbits--;
			mtok &= ~(1L << mbits);
			mbits += 2;
		}
		p->token = mtok; p->tokbits = mbits;
		mcost = mbits * 4 / len;
	}
	LONG w = 8, run = 1; UWORD tokw = 0x0000;
	LONG lcost = litcost(p, &w, &run, &tokw);
	int ismatch = (len > 1 && lcost > mcost);

	if (ismatch) {
		/* emit match */
		a2cnt = len;
		LONG t = len - 1;
		if (t > 0) {			/* len>=4 -> -2, len==3 -> -1 */
			t -= 2;
			if (t >= 0) {
				if (t > 0) p->litpress--;
				p->litpress--;
				if (p->litpress < 0) p->litpress = 0;
			}
		}
		putbits(p, p->token, p->tokbits);
	} else {
		/* emit literal tag + run deltas */
		putbits(p, tokw & 0xff, tokw >> 8);
		a2cnt = run;
		{
			UBYTE *lp = p->in + p->pos - 1;
			LONG pv = *lp++;
			if (run - 1 != 0)
				p->mom += 8;
			LONG k = run;
			do {
				LONG nb = *lp++;
				LONG dv = (char)(pv - nb);
				putbits(p, (UBYTE)dv, w);
				pv = nb;
			} while (--k > 0);
		}
		if (p->litpress != 31) p->litpress++;
		p->prevw = w;
	}
	p->mom -= (UWORD)p->mom >> 3;		/* shared tail: mom *= 7/8 */

	if (p->bitpos >= p->bitbud) return -7;
	if ((UWORD)(p->pos + a2cnt) < (UWORD)p->inlen)
		goto next_token;
	return p->bitpos;
}

/* -36 XpksPackChunk */
LONG XpksPackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	struct pk P;
	LONG r;
	APTR ws = ALLOCMEM(0x22080, 0);
	if (!ws)
		return -7;
	xsp->xsp_Sub[0] = ws;
	P.in = xsp->xsp_InBuf;
	P.out = xsp->xsp_OutBuf;
	P.inlen = xsp->xsp_InLen;
	P.bitbud = P.inlen * 8;
	P.head = (UWORD *)ws;
	P.node = (UWORD *)((UBYTE *)ws + 0x2080);
	P.out[0] = (UBYTE)(P.inlen >> 8);	/* inlen word, big-endian */
	P.out[1] = (UBYTE)P.inlen;
	r = sqsh_core(&P);
	FREEMEM(ws, 0x22080);
	if (r == -7) {
		xsp->xsp_OutLen = 0;
		return -17;
	}
	xsp->xsp_OutLen = (r + 7) >> 3;
	return 0;
}

/* ---------------- decoder ---------------- */

static __inline LONG getbit(const UBYTE *s, LONG p)
{
	return (s[p >> 3] >> (7 - (p & 7))) & 1;
}
static __inline ULONG getbits(const UBYTE *s, LONG p, LONG w)
{
	ULONG v = 0;
	while (w-- > 0) v = (v << 1) | getbit(s, p++);
	return v;
}
static __inline LONG getbits_s(const UBYTE *s, LONG p, LONG w)
{
	LONG v = (LONG)getbits(s, p, w);
	if (w && (v & (1L << (w - 1)))) v -= 1L << w;
	return v;
}

/* -54 XpksUnpackChunk */
LONG XpksUnpackChunk(struct XpkSubParams *xsp REGPARM_A0)
{
	UBYTE *src = xsp->xsp_InBuf, *out = xsp->xsp_OutBuf;
	ULONG ulen = (src[0] << 8) | src[1];
	UBYTE *end = out + ulen;
	xsp->xsp_OutLen = ulen;
	src += 2;
	LONG bitpos = 0;
	LONG litpress = 0, mom = 0, prevw = 0;

	LONG prev = *src++; *out++ = prev;

	for (;;) {
		LONG wid, run;
		if (litpress < 8) {
			if (getbit(src, bitpos)) goto match;
			bitpos++;
			run = 1; wid = 8;
		} else if (getbit(src, bitpos)) {
			bitpos++;
			wid = 8;
			if (prevw == 8) {
				run = mom >= 20 ? 2 : 1;
				if (run == 2) mom += 8;
			} else {
				wid = prevw;
				run = 5; mom += 8;
			}
		} else {
			LONG slot;
			bitpos++;
			if (!getbit(src, bitpos)) goto match;
			bitpos++;
			if (!getbit(src, bitpos)) {
				slot = 2; bitpos++;
			} else if (!getbit(src, bitpos + 1)) {
				slot = 3; bitpos += 2;
			} else {
				/* bfextu reads 3 bits AT the tested bit -- the '1' is
				 * the field's top bit, so slot is always 4..7 */
				bitpos++;
				slot = (LONG)getbits(src, bitpos, 3); bitpos += 3;
			}
			wid = widtab[prevw * 8 + slot - 17];
			if (wid == 8) {
				run = mom >= 20 ? 2 : 1;
				if (run == 2) mom += 8;
			} else {
				run = 5; mom += 8;
			}
		}
		{
			LONG k = run;
			do {
				LONG dv = getbits_s(src, bitpos, wid);
				bitpos += wid;
				prev = (UBYTE)(prev - dv);
				*out++ = prev;
			} while (--k > 0);
		}
		if (litpress != 31) litpress++;
		prevw = wid;
	tail:
		mom -= mom >> 3;
		if (out < end) continue;
		return 0;

	match:;
		LONG len;
		bitpos++;			/* consume marker bit */
		if (!getbit(src, bitpos)) {
			len = 2 + getbit(src, bitpos + 1);
			bitpos += 2;
		} else {
			bitpos++;
			if (!getbit(src, bitpos)) {
				len = 4 + getbit(src, bitpos + 1);
				bitpos += 2;
			} else {
				bitpos++;
				if (!getbit(src, bitpos)) {
					len = 6 + getbit(src, bitpos + 1);
					bitpos += 2;
				} else {
					bitpos++;
					if (!getbit(src, bitpos)) {
						len = 8 + (LONG)getbits(src, bitpos + 1, 3);
						bitpos += 4;
					} else {
						len = 16 + (LONG)getbits(src, bitpos + 1, 5);
						bitpos += 6;
					}
				}
			}
		}
		LONG cls, offbase;
		if (getbit(src, bitpos)) {
			bitpos++;
			cls = 12; offbase = -0x100;
		} else {
			bitpos++;
			if (getbit(src, bitpos)) {
				cls = 14; offbase = -0x1100;
			} else {
				cls = 8; offbase = 0;
			}
			bitpos++;
		}
		LONG fld = (LONG)getbits(src, bitpos, cls);
		bitpos += cls;
		{
			LONG t = len - 3;		/* litpress: >=4 -2, ==3 -1, <=2 0 */
			if (t >= 0) {
				if (t > 0) litpress--;
				litpress--;
				if (litpress < 0) litpress = 0;
			}
		}
		{
			UBYTE *mp = out - 1 + offbase - fld;
			LONG n = len;
			while (n-- > 0) *out++ = *mp++;
			prev = out[-1];
		}
		goto tail;
	}
	return 0;
}

/* ---------------- lifecycle ---------------- */

struct SQSHLib { UBYTE pad[0xa8]; };

LONG LibOpen(struct SQSHLib *lib REGPARM_A6)
{
	((UWORD *)lib)[0x10] += 1;
	((UBYTE *)lib)[14] &= ~8;
	return (LONG)lib;
}

LONG LibExpunge(struct SQSHLib *lib REGPARM_A6);

LONG LibClose(struct SQSHLib *lib REGPARM_A6)
{
	if (!--((UWORD *)lib)[0x10])
		if (((UBYTE *)lib)[14] & 8)
			return LibExpunge(lib);
	return 0;
}

LONG LibExpunge(struct SQSHLib *lib REGPARM_A6)
{
	ULONG d2;
	if (((UWORD *)lib)[0x10]) {
		((UBYTE *)lib)[14] |= 8;
		return 0;
	}
	d2 = ((ULONG *)lib)[0x22/4];
	REMOVE(lib);
	FREEMEM((UBYTE *)lib - ((UWORD *)lib)[8],
		(ULONG)((UWORD *)lib)[8] + ((UWORD *)lib)[9]);
	return d2;
}
