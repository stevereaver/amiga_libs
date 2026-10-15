/*
 * xpkLZBS.library 2.1 (000) -- "LZStreamer" XPK sublibrary
 * Reconstruction of binary/xpkLZBS_2.1(000).library
 *   $VER: xpkLZBS V2.1 (1 Oct 2013) by Niels Froehling
 *
 * LZSS variant ("BSI Bitstream Packer"):
 *   - first output byte holds the window size in bits (2..13, from
 *     xsp_Mode via a threshold table)
 *   - hash chains over 3-byte keys into a 65536-entry head table
 *     plus a (1<<bits)-entry ring of previous links
 *   - tokens are emitted least-significant bit first; the decoder
 *     collects the stream the same way, so field values pass
 *     through verbatim:
 *       '0' + 8 raw bits              -> literal byte
 *       '1' + len-2 (8b) + dist (db)  -> match, len 3..257
 *       '1' + 0 (8b) + count (12b)    -> long literal run, count raw bytes
 *     the match distance field width db is chosen per token as the
 *     bit width of min(outpos, window) via a power-of-two table.
 *   - literal runs >= 21 bytes switch to the run escape (break-even
 *     at 21 bytes: 21+8n vs 9n bits)
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef short          WORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0  */
	ULONG xsp_InLen;	/* +4  */
	APTR  xsp_OutBuf;	/* +8  */
	ULONG xsp_pad;		/* +12 */
	ULONG xsp_OutLen;	/* +16 */
	ULONG xsp_pad2;		/* +20 */
	ULONG xsp_pad3;		/* +24 */
	ULONG xsp_Mode;		/* +28 (asm reads 28(a3)) */
	ULONG xsp_pad4[5];	/* +32 .. +51 */
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

/* distance field-width table @LAB_0032: first boundary <= pos wins */
static const UWORD dtab[13] = {
	0x1000,0x0800,0x0400,0x0200,0x0100,0x0080,0x0040,
	0x0020,0x0010,0x0008,0x0004,0x0002,0x0001
};

static int distbits(ULONG bound)
{
	int i;
	for (i = 0; i < 13; i++)
		if (bound >= dtab[i])
			return 13 - i;
	return 2;
}

/* LIBFUNC_4 (-48): zero the 65536-entry head table (0x40000 bytes),
 * descending from Sub+0x40000.  Also the explicit packer reset. */
void XpksPackReset(struct XpkSubParams *xp)
{
	ULONG *p = (ULONG *)xp->xsp_Sub[0];
	ULONG *q;
	int i;
	if (!p)
		return;
	q = p + 0x10000;
	for (i = 0; i < 0x10000; i++)
		*--q = 0;
}

/* LIBFUNC_3 (-42): free the work block (size stored in its first
 * long).  Leaves xsp_Sub[0] stale, exactly like the original. */
void XpksPackFree(struct XpkSubParams *xp)
{
	ULONG *p = (ULONG *)xp->xsp_Sub[0];
	if (!p)
		return;
	FREEMEM(p - 1, p[-1]);
}

/* LIBFUNC_2 (-36): pack one chunk */
LONG XpksPackChunk(struct XpkSubParams *xp)
{
	ULONG *sub, *head, *chain;
	UBYTE *cur, *instart, *out, *oend;
	LONG rem;
	ULONG mask;
	int bits;
	ULONG acc = 0;		/* d3 bit accumulator   */
	ULONG nbits = 0;	/* pending bit count    */
	UWORD lits = 0;		/* d6.w literal counter */

	/* mode -> window bits (word compares, as in the original) */
	{
		WORD m = (WORD)xp->xsp_Mode;
		if (m <= 1) bits = 2;
		else if (m <= 0x0a) bits = 3;
		else if (m <= 0x14) bits = 4;
		else if (m <= 0x1e) bits = 5;
		else if (m <= 0x28) bits = 6;
		else if (m <= 0x32) bits = 7;
		else if (m <= 0x3c) bits = 8;
		else if (m <= 0x46) bits = 9;
		else if (m <= 0x50) bits = 10;
		else if (m <= 0x5a) bits = 11;
		else if (m <= 0x62) bits = 12;
		else bits = 13;
	}
	mask = 1UL << bits;

	sub = (ULONG *)xp->xsp_Sub[0];
	if (!sub) {
		ULONG sz = mask * 4 + 0x40004;
		APTR m = ALLOCMEM(sz, 0);
		if (!m)
			return -7;
		*(ULONG *)m = sz;
		sub = (ULONG *)m + 1;
		xp->xsp_Sub[0] = sub;
	}

	XpksPackReset(xp);

	head  = sub;					/* a5 - 0x40000 */
	chain = sub + 0x10000;				/* a5 = Sub+0x40000 */
	out   = (UBYTE *)xp->xsp_OutBuf;			/* a6 */
	cur   = (UBYTE *)xp->xsp_InBuf;				/* a2 */
	rem   = (LONG)xp->xsp_InLen;				/* d7 */
	instart = cur;						/* a3 */
	oend  = out + rem;					/* a4 */
	mask -= 1;						/* d4 */
	*out++ = (UBYTE)bits;

/* emit n bits of v, least-significant bit first */
#define EMIT(v,n) do {						\
		ULONG _v = (v); int _n = (n);			\
		nbits += _n;					\
		while (_n--) { acc = (acc << 1) | (_v & 1); _v >>= 1; } \
		while (nbits >= 8) {				\
			nbits -= 8;				\
			*out++ = (UBYTE)(acc >> nbits);		\
			if (out >= oend)			\
				return -17;			\
		}						\
	} while (0)

/* LAB_002A: hash-insert the next n positions at cur; advance cur */
#define INSERT(n) do {						\
		ULONG _n = (n);					\
		if (rem < 3)					\
			cur += _n;				\
		else while (_n--) {				\
			ULONG _h = ((ULONG)cur[0] << 8)		\
				 | (UBYTE)(cur[1] + cur[2]);	\
			ULONG _s = ((ULONG)cur) & mask;		\
			chain[_s] = (ULONG)head[_h];		\
			head[_h] = (ULONG)cur;			\
			cur++;					\
		}						\
	} while (0)

	for (;;) {
		ULONG len = 2, dist = 0;	/* d5 = dist<<16 | len */
		if (rem >= 3) {
			LONG maxlen = rem < 0x101 ? rem : 0x101;
			ULONG h = ((ULONG)cur[0] << 8)
				| (UBYTE)(cur[1] + cur[2]);
			UBYTE *cand = (UBYTE *)head[h];
			for (;;) {
				ULONG d = (ULONG)(cur - cand);
				if (d > mask)
					break;
				if (cur[len] == cand[len]) {
					UBYTE *a = cur, *b = cand;
					LONG i = maxlen;
					while (--i >= 0 && *a++ == *b++)
						;
					i = maxlen - i - 1;
					if (i > (LONG)len) {
						len = i;
						dist = d;
						if (len >= (ULONG)maxlen)
							break;
					}
				}
				cand = (UBYTE *)chain[((ULONG)cand) & mask];
			}
		}
		if (len < 3) {
			lits++;
			len = 1;
			INSERT(1);
			if (lits != 0xfff)
				goto consume;
		}
	flush:
		if (lits) {				/* LAB_0021: flush run */
			UBYTE *a0 = cur - lits;
			if (lits >= 0x15) {
				EMIT(((ULONG)lits << 9) | 1, 21);
				do {
					EMIT(*a0++, 8);
				} while (--lits);
			} else {
				do {
					EMIT((UWORD)*a0++ << 1, 9);
				} while (--lits);
			}
		}
		if (len >= 3) {				/* LAB_0024: match */
			ULONG bound = (ULONG)(cur - instart);
			int db;
			if (bound > mask)
				bound = mask;
			db = distbits(bound);
			EMIT(1 | ((len - 2) << 1) | (dist << 9), 9 + db);
			INSERT(len);
		}
	consume:
		rem -= (LONG)len;
		if (rem > 0)
			continue;
		/* stream end: len=0 re-enters the literal flush once */
		len = 0;
		if (lits)
			goto flush;
		break;
	}
	if (nbits) {			/* pad the partial byte */
		acc <<= 8 - nbits;
		*out++ = (UBYTE)acc;
	}
	xp->xsp_OutLen = (ULONG)(out - (UBYTE *)xp->xsp_OutBuf);
	return 0;

#undef EMIT
#undef INSERT
}

/* LIBFUNC_5 (-54): unpack one chunk; no work memory needed */
LONG XpksUnpackChunk(struct XpkSubParams *xp)
{
	UBYTE *in = (UBYTE *)xp->xsp_InBuf;	/* a1 */
	UBYTE *out = (UBYTE *)xp->xsp_OutBuf;	/* a5 */
	UBYTE *ostart = out;			/* a4 */
	UBYTE *oend;
	ULONG mask;
	ULONG bitbuf = 0;			/* d5 */
	LONG bleft = 0;				/* d7 */

	oend = out + xp->xsp_OutLen;		/* a3 */
	mask = (1UL << (*in++)) - 1;		/* d4 */

/* LAB_003D: collect n bits; first stream bit lands in result bit 0 */
#define GET(n) ({						\
		ULONG _r = 0; int _i;				\
		for (_i = 0; _i < (n); _i++) {			\
			if (--bleft < 0) {			\
				bleft = 7;			\
				bitbuf = *in++;			\
			}					\
			_r = (_r >> 1) | ((bitbuf & 0x80) << 24);	\
			bitbuf = (bitbuf << 1) & 0xff;		\
		}						\
		_r >> (32 - (n));				\
	})

	while (out < oend) {
		ULONG t;
		if (!GET(1)) {
			*out++ = (UBYTE)GET(8);
			continue;
		}
		t = GET(8);
		if (t == 0) {				/* long literal run */
			LONG c = (LONG)GET(12) - 1;
			for (; c >= 0; c--)
				*out++ = (UBYTE)GET(8);
			continue;
		}
		{					/* match */
			ULONG bound = (ULONG)(out - ostart);
			ULONG dist;
			LONG len;
			if (bound > mask)
				bound = mask;
			dist = GET(distbits(bound));
			len = (LONG)t + 1;
			for (; len >= 0; len--) {
				*out = out[-(LONG)dist];
				out++;
			}
		}
	}
	return 0;

#undef GET
}

/* ---------------- lifecycle ---------------- */

struct LZBSLib { UBYTE pad[0x26]; };

LONG LibOpen(struct LZBSLib *lib)
{
	((UWORD *)lib)[0x10] += 1;
	((UBYTE *)lib)[14] &= ~8;
	return (LONG)lib;
}

LONG LibExpunge(struct LZBSLib *lib);

LONG LibClose(struct LZBSLib *lib)
{
	if (!--((UWORD *)lib)[0x10])
		if (((UBYTE *)lib)[14] & 8)
			return LibExpunge(lib);
	return 0;
}

LONG LibExpunge(struct LZBSLib *lib)
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

/* LibInit lives in xpkLZBS_lib.s (stores seglist@34, no CPU gate). */

#ifndef HOST_TEST
extern const UBYTE xpkinfo[];
/* -30 XpksPackerInfo: returns the descriptor address */
const UBYTE *XpksPackerInfo(void) { return xpkinfo; }
#endif
