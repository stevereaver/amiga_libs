/*
 * xpkSQSH.library 1.2 (020) -- "Squash" XPK sublibrary
 * Reconstruction of binary/xpkSQSH_1.2(020).library
 *   $VER: xpk V1.2 (1 Oct 2013) by John Hendrikx
 *
 * LZ cruncher specialised for 8-bit sound data:
 *   - literals are emitted as signed DELTAS from the previous byte
 *   - a two-slot hash chain sorts candidates by full/partial last match
 *   - past 7 literal-pressure tokens, deltas narrow to 2..8 bits via a
 *     remap table and the literal-vs-match marker bit inverts
 *   - token choice is a per-item cost comparison (bits*4/items)
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
	ULONG xsp_OutLen;	/* +16 (asm stores outlen at +16) */
	ULONG xsp_pad2[8];	/* +20 .. +51 */
	APTR  xsp_Sub[1];	/* +52 workmem */
};

#ifdef HOST_TEST
LONG host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
LONG host_Remove(APTR);
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz) host_FreeMem(p,sz)
#define REMOVE(p) host_Remove(p)
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
#define REMOVE_E(node) ({\
  register APTR __p_sys __asm("a6") = *(APTR *)4;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define ALLOCMEM(sz,f)	ALLOCMEM_E(sz,f)
#define FREEMEM(p,s)	FREEMEM_E(p,s)
#define REMOVE(p)	REMOVE_E(p)
#endif

/* ---------------- tables ---------------- */

/* match-length prefix words, indexed by len 0..47 (table @0x28c) */
static const UWORD lentab[48] = {
	0,0,
	0x0004,0x0005,0x000c,0x000d,0x001c,0x001d,
	0x00f0,0x00f1,0x00f2,0x00f3,0x00f4,0x00f5,0x00f6,0x00f7,
	0x03e0,0x03e1,0x03e2,0x03e3,0x03e4,0x03e5,0x03e6,0x03e7,
	0x03e8,0x03e9,0x03ea,0x03eb,0x03ec,0x03ed,0x03ee,0x03ef,
	0x03f0,0x03f1,0x03f2,0x03f3,0x03f4,0x03f5,0x03f6,0x03f7,
	0x03f8,0x03f9,0x03fa,0x03fb,0x03fc,0x03fd,0x03fe,0x03ff
};

/* match+lencode extra bits per len (LAB_0021), index = len 0..47 */
static const UBYTE lenextra[48] = {
	3,3,3,3, 4,4,5,5,
	8,8,8,8,8,8,8,8,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10,
	10,10,10,10,10,10,10,10
};

/* literal-width remap flat table (LAB_0053): index (prevw-2)*8 + i */
static const UBYTE widtab[56] = {
	2,3,4,5,6,7,8,0,
	3,2,4,5,6,7,8,0,
	4,3,5,2,6,7,8,0,
	5,4,6,2,3,7,8,0,
	6,5,7,2,3,4,8,0,
	7,6,8,2,3,4,5,0,
	8,7,6,2,3,4,5,0
};

/* delta-token {bits,value} pairs, flat [prevw-2][(w-2)*2] (@0x400) */
static const UBYTE deltok[7][14] = {
	{0x01,0x01, 0x03,0x02, 0x04,0x06, 0x06,0x1c, 0x06,0x1d, 0x06,0x1e, 0x06,0x1f},
	{0x03,0x02, 0x01,0x01, 0x04,0x06, 0x06,0x1c, 0x06,0x1d, 0x06,0x1e, 0x06,0x1f},
	{0x06,0x1c, 0x03,0x02, 0x01,0x01, 0x04,0x06, 0x06,0x1d, 0x06,0x1e, 0x06,0x1f},
	{0x06,0x1c, 0x06,0x1d, 0x03,0x02, 0x01,0x01, 0x04,0x06, 0x06,0x1e, 0x06,0x1f},
	{0x06,0x1c, 0x06,0x1d, 0x06,0x1e, 0x03,0x02, 0x01,0x01, 0x04,0x06, 0x06,0x1f},
	{0x06,0x1c, 0x06,0x1d, 0x06,0x1e, 0x06,0x1f, 0x03,0x02, 0x01,0x01, 0x04,0x06},
	{0x06,0x1c, 0x06,0x1d, 0x06,0x1e, 0x06,0x1f, 0x04,0x06, 0x03,0x02, 0x01,0x01}
};

/* ---------------- packer ---------------- */

struct pk {
	UBYTE *in, *out;
	LONG   inlen, bitbud, bitpos, pos;
	LONG   prevhash, mlen;
	ULONG  token;  LONG tokbits;
	LONG   d0h, d0l;	/* packed d0 pair */
	LONG   litpress;	/* a5 */
	UWORD *head;		/* hash heads, workmem+0 */
	UWORD *node;		/* 2-slot links, workmem+0x2080, 4B/node */
};

static void putbits(struct pk *p, ULONG v, LONG w)
{
	while (w-- > 0) {
		if ((v >> w) & 1)
			p->out[p->bitpos >> 3] |= 0x80 >> (p->bitpos & 7);
		p->bitpos++;
	}
}

/* literal alternative cost (bits*4/items); sets *w,*run,*tokp.
 * Mirrors LAB_0026/0027/002C/002D.  tokp=0 -> single '0' bit. */
static LONG litcost(struct pk *p, LONG *w, LONG *run, const UBYTE **tokp)
{
	UBYTE *dp;
	LONG d5, acc, cnt;

	if (p->litpress <= 7) {
		*w = 8; *run = 1; *tokp = 0;
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
		/* bfffo acc{24:7} -> w = 33-offset = bitwidth+1 */
		LONG bw = 0, t = acc;
		while (t) { bw++; t >>= 1; }
		*w = bw + 1;
		*run = (*w == 8) ? 2 : 5;
	}
	if (*w >= 7 && p->d0h < 20) {
		*w = 8; *run = 1;
	}
	*tokp = &deltok[p->d0l - 2][(*w - 2) * 2];
	return (*run * *w + (*tokp)[0]) * 4 / *run;
}

/* LAB_0014: pack core -> bitpos, or -7 on bit-budget overflow */
static LONG sqsh_core(struct pk *p)
{
	LONG a2cnt = 1, i;
	for (i = 0; i < 0x1000; i++) p->head[i] = 0;
	for (i = 0; i < 0x8000 * 2; i++) p->node[i] = 0;
	p->prevhash = 0; p->d0h = 0; p->d0l = 0; p->litpress = 0;
	p->pos = 0; p->bitpos = 24;
	p->out[2] = p->in[0];

next_token:;
	/* inner scan: insert a2cnt positions; walk chain at each and keep
	 * the last position's best candidate in (floor,rem) */
	LONG d4 = a2cnt - 1;
	UBYTE *scan = p->in + p->pos + 1;
	LONG d5 = p->prevhash;
	LONG floor = 0, rem = 46;
	{
		LONG a1 = p->pos;
		for (;;) {
			a1++;
			LONG d3 = (scan[0] << 4) ^ scan[1];
			if (!d4 || d3 != d5) {
				LONG d7 = 46;
				LONG d2 = p->head[d3];
				if (!d2) {
					p->head[d3] = (UWORD)a1;
					floor = 0;
				} else {
					floor = a1 - 0x5100;
					for (;;) {
						UBYTE *ca = p->in + d2, *cb = scan;
						LONG r = 46;
						for (;;)
							if (*ca++ != *cb++ || --r < 0)
								break;
						UWORD *sp = &p->node[d2 * 2 + (r > 0)];
						if (!((char)d7 < (char)r) &&
						    !((short)d2 <= (short)floor)) {
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
	p->mlen = len;

	ULONG mtok = 0; LONG mbits = 0, mcost = 0x7fff;
	if (len > 1) {
		LONG dist = p->pos - floor - 1;
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
		if (p->litpress > 7) {
			mbits--;
			mtok &= ~(1L << mbits);
			mbits += 2;
		}
		p->token = mtok; p->tokbits = mbits;
		mcost = mbits * 4 / len;
	}
	LONG w, run; const UBYTE *tokp;
	LONG lcost = litcost(p, &w, &run, &tokp);

	if (len > 1 && lcost > mcost) {
		/* emit match: d7=len-1; len>=4 -> litpress-=2, ==3 -> -1 */
		a2cnt = len;
		LONG t = len - 1;
		if (t > 0) {
			t -= 2;
			if (t >= 0) {
				if (t > 0) p->litpress--;
				p->litpress--;
				if (p->litpress < 0) p->litpress = 0;
			}
		}
		putbits(p, p->token, p->tokbits);
		{ LONG t2 = p->d0h; p->d0h = p->d0l; p->d0l = t2; } /* swap d0 */
	} else {
		/* emit literal run */
		LONG bits = tokp ? tokp[0] : 1;
		ULONG val = tokp ? tokp[1] : 0;
		putbits(p, val, bits);
		a2cnt = run;
		UBYTE *lp = p->in + p->pos - 1;
		LONG pv = *lp++;
		/* movew d3,d0; swap -> {w, oldH}; +8 to low(H) when run>=2 */
		{ LONG old = p->d0h; p->d0h = w; p->d0l = old; }
		if (run - 1 != 0)
			p->d0l += 8;
		{
			LONG k = run;
			do {
				LONG nb = *lp++;
				LONG dv = (char)(pv - nb);
				putbits(p, (UBYTE)dv, w);
				pv = nb;
			} while (--k > 0);
		}
		if (p->litpress != 31) p->litpress++;
	}
	p->d0l -= (UWORD)p->d0l >> 3;
	{ LONG t = p->d0h; p->d0h = p->d0l; p->d0l = t; }
	if (p->bitpos >= p->bitbud) return -7;
	if ((UWORD)(p->pos + a2cnt) < (UWORD)p->inlen)
		goto next_token;
	return p->bitpos;
}

/* -36 XpksPackChunk */
LONG XpksPackChunk(struct XpkSubParams *xsp)
{
	struct pk P;
	LONG r;
	if (!xsp->xsp_Sub[0]) {
		xsp->xsp_Sub[0] = ALLOCMEM(0x22080, 0);
		if (!xsp->xsp_Sub[0])
			return -7;
	}
	P.in = xsp->xsp_InBuf;
	P.out = xsp->xsp_OutBuf;
	P.inlen = xsp->xsp_InLen;
	P.bitbud = P.inlen * 8;
	P.head = (UWORD *)xsp->xsp_Sub[0];
	P.node = (UWORD *)((UBYTE *)xsp->xsp_Sub[0] + 0x2080);
	P.out[0] = (UBYTE)(P.inlen >> 8);	/* inlen word, big-endian */
	P.out[1] = (UBYTE)P.inlen;
	r = sqsh_core(&P);
	if (r == -7)
		return -17;
	xsp->xsp_OutLen = (r + 7) >> 3;
	return 0;
}

/* -42 XpksPackFree / -60 (same routine in the original) */
LONG XpksPackFree(struct XpkSubParams *xsp)
{
	APTR wm = xsp->xsp_Sub[0];
	if (wm)
		FREEMEM(wm, 0x22080);
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
	if (v & (1L << (w - 1))) v -= 1L << w;
	return v;
}

/* -54 XpksUnpackChunk */
LONG XpksUnpackChunk(struct XpkSubParams *xsp)
{
	UBYTE *src = xsp->xsp_InBuf, *out = xsp->xsp_OutBuf;
	UBYTE *end = out + ((src[0] << 8) | src[1]);
	src += 2;
	LONG bitpos = 0;
	LONG litpress = 0, acc = 0, prev = 0, prevw = 0, offbase = 0;

	prev = *src++; *out++ = prev;

	for (;;) {
		LONG wid, run;
		if (litpress < 8) {
			if (getbit(src, bitpos)) goto match;
			bitpos++;
			run = 0; wid = 8;
		} else if (getbit(src, bitpos)) {
			bitpos++;
			wid = 8;
			if (prevw == 8) {
				run = acc >= 20;
				if (run) acc += 8;
			} else {
				wid = prevw;
				run = 4; acc += 8;
			}
		} else {
			LONG slot;
			bitpos++;
			if (!getbit(src, bitpos)) goto match;
			bitpos++;
			if (!getbit(src, bitpos++)) {
				slot = 1;
			} else if (!getbit(src, bitpos++)) {
				slot = 2;
			} else {
				slot = 3 + (LONG)getbits(src, bitpos, 2);
				bitpos += 2;
			}
			wid = widtab[(prevw - 2) * 8 + slot];
			if (wid == 8) {
				run = acc >= 20;
				if (run) acc += 8;
			} else {
				run = 4; acc += 8;
			}
		}
		{
			LONG k = run + 1;
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
		acc -= acc >> 3;
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
		LONG cls;
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
		len -= 3;
		if (len >= 0) {
			if (len > 0) litpress--;
			litpress--;
			if (litpress < 0) litpress = 0;
		}
		{
			UBYTE *mp = out - 1 + offbase - fld;
			LONG n = len + 3;
			while (n-- > 0) *out++ = *mp++;
			prev = out[-1];
		}
		goto tail;
	}
	return 0;
}

/* ---------------- lifecycle ---------------- */

struct SQSHLib { UBYTE pad[0x26]; };

LONG LibOpen(struct SQSHLib *lib)
{
	((UWORD *)lib)[0x10] += 1;
	((UBYTE *)lib)[14] &= ~8;
	return (LONG)lib;
}

LONG LibExpunge(struct SQSHLib *lib);

LONG LibClose(struct SQSHLib *lib)
{
	if (!--((UWORD *)lib)[0x10])
		if (((UBYTE *)lib)[14] & 8)
			return LibExpunge(lib);
	return 0;
}

LONG LibExpunge(struct SQSHLib *lib)
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

/* LibInit lives in xpkSQSH_lib.s (stores seglist@34, 020 gate). */

#ifndef HOST_TEST
extern const UBYTE xpkinfo[];
/* -30 XpksPackerInfo: returns the descriptor address */
const UBYTE *XpksPackerInfo(void) { return xpkinfo; }
#endif
