/*
 * xpkACCA.library 1.2 -- "Andre's Code Compression" XPK sublibrary
 * Reconstruction of binary/xpkACCA_1.2(000).library
 *   $VER: xpkACCA V1.2 (1 Oct 2013) by Andre Osterhues
 *
 * ACCA is a variant of Ed Ross' RDC ("Ross Data Compression") scheme:
 * a flag-bit stream and a token/literal byte stream are interleaved
 * in 16-symbol groups: [u16 flags][bytes of the 16 symbols]...
 * Flag bits are consumed MSB-first; 0 = literal byte, 1 = token.
 * Token byte = class<<4 | low4:
 *   class 0     +1 byte B  -> run of B, len = lo+3        (3..18)
 *   class 1     +2 bytes   -> long run: N = lo+16*b1, byte b2,
 *                             emits N+19 copies           (19..4114)
 *   class 2                -> emit table16[lo] twice (common pair)
 *   class 3..13 +1 byte    -> match: len = class,
 *                             dist = 16*b2 + lo + 3       (3..4098)
 *   class 14               -> zero run, len = lo+3        (3..18)
 *   class 15    +2 bytes   -> long match: len = b3+14 (13..268),
 *                             dist = (b2<<4 | lo) + 3
 * table16 = {00 01 02 03 04 08 10 20 40 55 60 80 aa c0 e0 ff}
 *
 * Two packers, selected by xsp_Mode (> 79 -> "crawling", else "turbo"):
 *   turbo:    one-candidate matcher, 12-bit hash over 3 bytes
 *             (h = (b0b1 ^ rol4(b0b2)) & 0xfff), heads = 4096 longs
 *             at workbuf+0; out bound = OutBuf + OutBufLen - 48.
 *   crawling: hash-chain matcher, heads = 65536 longs at workbuf+0
 *             (h = (b0<<8)|((b1+b2)&0xff)), ring of 8192 longs at
 *             workbuf+0x40000 chaining previous same-hash positions;
 *             best match tracked as (dist<<16)|len in one register;
 *             out bound = OutBuf + InLen (pack FAILS, -17, if the
 *             output does not shrink below the input size).
 * Workmem is allocated once by the first pack call (4-byte size
 * header + body), cached in xsp_Sub0; xsp_Sub1 = 0 or 15 selects the
 * PackReset clear extent.
 *
 * DEFECTS reproduced faithfully (see okf/findings/defects.md):
 *   - PackReset clears DOWNWARD from Sub0+0x4000 (+0x3c000 more when
 *     Sub1 != 0) in 160-byte chunks x105 per pass x(Sub1+1) passes:
 *     turbo clears [Sub0-0x1a0, +0x4000) -- wiping the stored
 *     alloc-size long at Sub0-4, so PackFree calls FreeMem(ptr,0);
 *     crawling clears [Sub0-0x1a00, +0x40000) -- the whole hash
 *     table + the header, but NOT the ring table at +0x40000, which
 *     keeps AllocMem garbage -> nondeterministic chain candidates.
 *   - workmem is allocated on the FIRST pack call only; a later call
 *     in the other mode reuses it (turbo-on-big works, crawling-on-
 *     turbo smashes the heap).
 *   - PackFree does not clear xsp_Sub0 -> reuse-after-free.
 *   - crawling emits a run of exactly 18 via class-1 with N = -1
 *     (encodes 0x1f 0xff) -> decodes to a 4114-byte run.
 *   - turbo can emit a len-2 match as a class-2 "common pair" token
 *     -> decoder writes table16[(dist-3)&15] twice (corrupt output,
 *     stream stays in sync).
 *   - crawling's class-2 emit path is dead code (best len floors at
 *     2, so run len 2 always loses to the literal).
 *   - turbo's loop-end test is cursor > in_end: input ending on the
 *     boundary reads/emits one byte past the input.
 *   - the decoder reads the next flag word BEFORE the in-end check:
 *     always reads 2 bytes past the packed stream.
 *   - crawling's bound is out+InLen, ignoring OutBufLen: it writes
 *     up to inlen bytes regardless of the caller's buffer size.
 *   - UnpackChunk stores the produced length at xsp+12
 *     (the OutBufLen field), not xsp_OutLen (+16).
 *   - the original stores absolute pointers in its tables and keys
 *     the ring by (address & 0x1fff): packing depends on the load
 *     address.  The reconstruction stores input-relative offsets,
 *     keeping the same collision structure deterministically.
 */

typedef unsigned char  UBYTE;
typedef short          SHORT;
typedef signed char    BYTE;
typedef unsigned short UWORD;
typedef short          WORD;
typedef unsigned int   ULONG;	/* 32-bit on m68k AND host */
typedef int            LONG;
typedef void          *APTR;

struct XpkSubParams {
	APTR  xsp_InBuf;	/* +0x00 */
	ULONG xsp_InLen;	/* +0x04 */
	APTR  xsp_OutBuf;	/* +0x08 */
	ULONG xsp_OutBufLen;	/* +0x0c -- unpack writes outlen here */
	ULONG xsp_OutLen;	/* +0x10 -- pack writes outlen here   */
	ULONG xsp_pad14[2];	/* +0x14..0x1b */
	ULONG xsp_Mode;		/* +0x1c = 28 */
	ULONG xsp_pad20[5];	/* +0x20..0x33 */
	APTR  xsp_Sub0;		/* +0x34 = 52: workmem body ptr       */
	ULONG xsp_Sub1;		/* +0x38 = 56: mode flag 0/15         */
};

#define LIBF_DELEXP	0x08
struct Node {			/* minimal for expunge unlink */
	struct Node *ln_Succ, *ln_Pred;
	UBYTE ln_Type;
	BYTE  ln_Pri;
	char *ln_Name;
};
struct Library {
	struct Node	 lib_Node;
	UBYTE		 lib_Flags;	/* +14		    */
	UBYTE		 lib_Version;
	UWORD		 lib_NegSize;	/* +16		    */
	UWORD		 lib_PosSize;	/* +18		    */
	/* ... */
	UWORD		 lib_pad[5];	/* +20..+29	    */
	UWORD		 lib_pad2;
	UWORD		 lib_OpenCnt;	/* +32		    */
};
struct AccaBase {
	struct Library	 lib;
	APTR		 seglist;	/* +34		    */
};

extern char xpkinfo[];		/* descriptor in xpkACCA_lib.s	    */

/* exec calls; SysBase is the pointer STORED AT location 4 */
#ifdef HOST_TEST
#define ASMREG(x)
APTR host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
void host_Remove(APTR);
#define ALLOCMEM(sz,fl) host_AllocMem(sz,fl)
#define FREEMEM(p,sz)   host_FreeMem(p,sz)
#define REMOVENODE(n)   host_Remove(n)
#else
#define ALLOCMEM_E(size,fl) ({\
  register APTR __p_sys ASMREG("a6") = *(APTR *)4;\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define FREEMEM_E(mem,sz) ({\
  register APTR __p_sys ASMREG("a6") = *(APTR *)4;\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#define REMOVENODE_E(node) ({\
  register APTR __p_sys ASMREG("a6") = *(APTR *)4;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define ASMREG(x)	__asm(x)
#define ALLOCMEM(sz,f)	ALLOCMEM_E(sz,f)
#define FREEMEM(p,s)	FREEMEM_E(p,s)
#define REMOVENODE(n)	REMOVENODE_E(n)
#endif

static const UBYTE tab16[16] = {
	0x00,0x01,0x02,0x03,0x04,0x08,0x10,0x20,
	0x40,0x55,0x60,0x80,0xaa,0xc0,0xe0,0xff
};

#define ALLOCSMALL	0x4004		/* turbo workmem	   */
#define ALLOCBIG	0x48004		/* crawling workmem	   */

/* ---------------------------------------------------------------- */
/* -48 PackReset (0x12a): wipe DOWNWARD in 148-byte chunks, 105	  */
/* inner passes x (Sub1+1) outer passes, starting below Sub0+0x4000	  */
/* (+0x3c000 when Sub1 set).  Overruns / wipes the size long --	  */
/* faithful.							  */
/* ---------------------------------------------------------------- */
void XpksPackReset(struct XpkSubParams *xp ASMREG("a0"))
{
	UBYTE *a6;
	ULONG rounds, i;

	if (!xp->xsp_Sub0)
		return;
	a6 = (UBYTE *)xp->xsp_Sub0;
	if (xp->xsp_Sub1)
		a6 += 0x3c000;
	a6 += 0x4000;
	rounds = xp->xsp_Sub1 + 1;		/* turbo 1, crawling 16 */
	while (rounds--) {
		for (i = 0; i < 105; i++) {
			ULONG *p;
			int k;
			a6 -= 160;			/* 4 + 3x13 longs */
			p = (ULONG *)a6;
			for (k = 0; k < 40; k++)
				p[k] = 0;
		}
	}
}

/* ---------------------------------------------------------------- */
/* -42 PackFree (0x112): free workmem via the size long at Sub0-4.	  */
/* xsp_Sub0 is left dangling -- as in the original.			  */
/* ---------------------------------------------------------------- */
LONG XpksPackFree(struct XpkSubParams *xp ASMREG("a0"))
{
	UBYTE *p = (UBYTE *)xp->xsp_Sub0;
	ULONG  sz;
	if (!p)
		return 0;
	p -= 4;
	sz = *(ULONG *)p;
	FREEMEM(p, sz);
	return 0;
}

/* ---------------------------------------------------------------- */
/* turbo packer (0x1e8): one candidate per 12-bit hash		  */
/* ---------------------------------------------------------------- */
static LONG pack_turbo(struct XpkSubParams *xp, UBYTE *wk)
{
	UBYTE *in  = (UBYTE *)xp->xsp_InBuf;
	UBYTE *a1  = in;				/* input cursor	 */
	UBYTE *a3  = in + xp->xsp_InLen;	/* input end	 */
	UBYTE *out = (UBYTE *)xp->xsp_OutBuf;
	UBYTE *a2  = out + 2;			/* token bytes	 */
	UBYTE *a0  = out;			/* flag slot	 */
	UBYTE *d6b = out + xp->xsp_OutBufLen - 48;/* out bound	 */
	UBYTE *a4, *a5, *a1w;
	ULONG  d0 = 15, d1, d2, d3 = 0, d4, d5, d7, sv;
	ULONG *htab = (ULONG *)wk;		/* 4096 longs	 */

	for (;;) {
		a4 = a1;
		d1 = *a1++;
		if (*a1++ == d1 && *a1++ == d1) {	/* run of >= 3  */
			if (a1 > a3)
				goto literal;
			d2 = 4111;
			d7 = 4111;
			for (;;) {			/* dbcs loop  */
				if (*a1++ != d1)
					break;
				if (a1 > a3)
					break;
				if (--d7 == (ULONG)-1) {
					d7 = 0;
					break;
				}
			}
			a1--;				/* un-eat byte */
			d2 -= d7;			/* E = R - 3	 */
			if (d2 > 15) {			/* R >= 19	   */
				*a2++ = (UBYTE)(0x10 | (d2 & 15));
				*a2++ = (UBYTE)(((WORD)d2 >> 4) - 1);
				*a2++ = (UBYTE)d1;
			} else if (d1 == 0) {
				*a2++ = (UBYTE)(d2 | 0xe0); /* zero run  */
			} else {
				*a2++ = (UBYTE)d2;	    /* byte run  */
				*a2++ = (UBYTE)d1;
			}
			d3 |= 1UL << d0;
		} else {
			if ((SHORT)((a3 - a4) - 2) < 0)
				goto literal;
			a1w = a4;
			d5 = ((ULONG)a1w[0] << 8) | a1w[1];
			d7 = ((ULONG)a1w[0] << 8) | a1w[2];
			d7 = ((d7 << 4) | (d7 >> 12)) & 0xffff;
			d5 = (d5 ^ d7) & 0xfff;		/* hash	     */
			/* table holds off+1; 0 models the original's
			 * NULL pointer head (dist = cur-0 = huge)	    */
			sv = htab[d5];
			a5 = in + (sv ? sv - 1 : 0);
			htab[d5] = (ULONG)(a4 - in) + 1;
			d4 = sv ? (ULONG)(a4 - in) - (sv - 1) - 3
				: 0x7fffffff;
			if ((LONG)d4 <= 4095) {
				ULONG len;
				a1w = a4;
				if (*a5++ == *a1w++ &&
				    *a5++ == *a1w++) {
					d2 = 269;
					d7 = 267;
					for (;;) {
						if (*a5++ != *a1w++)
							break;
						if (a5 > a4)
							break;
						if (a1w > a3)
							break;
						if (--d7 == (ULONG)-1) {
							d7 = 0;
							break;
						}
					}
					len = d2 - d7;		/* 2+E	   */
					if (len >= 2) {
						a1 = a1w - 1;
						if (len > 13) {
							*a2++ = (UBYTE)
							 (0xf0 |
							  (d4 & 15));
							*a2++ = (UBYTE)
								(d4 >> 4);
							*a2++ = (UBYTE)
								(len - 14);
						} else {
							/* len 2 lands on
							 * class-2 pair
							 * token (defect) */
							*a2++ = (UBYTE)
							 ((len << 4) |
							  (d4 & 15));
							*a2++ = (UBYTE)
								(d4 >> 4);
						}
						d3 |= 1UL << d0;
						goto next;
					}
				}
			}
			if (a4[1] == d1) {		/* pair?	   */
				LONG i;
				for (i = 0; i < 16; i++)
					if (tab16[i] == d1)
						break;
				if (i < 16) {		/* class-2 token */
					*a2++ = (UBYTE)(0x20 | i);
					a1 = a4 + 2;
					d3 |= 1UL << d0;
					goto next;
				}
			}
			literal:
			a1 = a4 + 1;
			*a2++ = (UBYTE)d1;
		}
next:;
		if (a1 > a3)
			goto done;
		if (d0-- == 0)
			goto flush;
		continue;
flush:
		a0[0] = (UBYTE)(d3 >> 8);
		a0[1] = (UBYTE)d3;
		a0 = a2;
		a2 += 2;
		if (a2 >= d6b)
			return -17;
		d3 = 0;
		d0 = 15;
	}
done:
	a0[0] = (UBYTE)(d3 >> 8);
	a0[1] = (UBYTE)d3;
	xp->xsp_OutLen = (ULONG)(a2 - out);
	return 0;
}

/* ---------------------------------------------------------------- */
/* crawling packer (0x35c): hash-chain matcher, 288KB workmem	  */
/* ---------------------------------------------------------------- */
static LONG pack_big(struct XpkSubParams *xp, UBYTE *wk)
{
	UBYTE *in   = (UBYTE *)xp->xsp_InBuf;
	UBYTE *out  = (UBYTE *)xp->xsp_OutBuf;
	ULONG *head = (ULONG *)wk;			/* 65536 longs */
	ULONG *ring = (ULONG *)(wk + 0x40000);		/* 8192 longs  */
	UBYTE *a2   = in - 1;				/* cur pos     */
	LONG   d7   = (LONG)xp->xsp_InLen;		/* remaining   */
	UBYTE *a6   = out + 2;				/* byte cursor */
	UBYTE *a3   = out;				/* flag slot   */
	UBYTE *d4b  = out + d7;				/* bound	     */
	LONG   d3   = 15;				/* bit index   */
	ULONG  d6   = 0;				/* flag accum  */
	ULONG  d5   = 1;				/* hops/packed */
	ULONG  d0 = 0, d1, d2;
	UBYTE *a0p, *a1p;

	for (;;) {
		if (d7 < 3) {
			a2 += (SHORT)d5;		/* +consumed   */
			goto biglit;
		}
		{   /* insert loop: dbf d5 runs (WORD)d5 hops		    */
			WORD hops = (WORD)d5;
			while (--hops >= 0) {
				ULONG h;
				a2++;
				h = ((ULONG)a2[0] << 8) |
				    ((a2[1] + a2[2]) & 0xff);
				d0 = head[h];
				head[h] = (ULONG)(a2 - in) + 1;
				ring[((ULONG)(a2 - in)) & 0x1fff] = d0;
			}
		}
		d5 = 2;					/* best len    */
		d1 = (d7 < 269) ? (ULONG)d7 : 269;	/* cap	     */
		for (;;) {
			UBYTE *cand;
			ULONG  dist;
			LONG   nl, ext;
			/* table holds off+1; 0 = the original's NULL	    */
			if (!d0)
				break;
			dist = (ULONG)(a2 - in) - (d0 - 1);
			if ((LONG)dist >= 4099)
				break;			/* -> emit   */
			if ((LONG)dist < 3)
				goto nextcand;
			cand = in + d0 - 1;
			/* filter: byte at offset bestlen must match	    */
			a0p = cand;
			if (a0p[d5 & 0xffff] != a2[d5 & 0xffff])
				goto nextcand;
			/* dbne: compare bestlen bytes 0..d5-1		    */
			a1p = a2;
			d2 = (d5 & 0xffff) - 1;
			for (;;) {
				if (*a0p++ != *a1p++)
					goto nextcand;
				if (--d2 == (ULONG)-1)
					break;
			}
			/* extension: up to cap-d5-1 more bytes		    */
			ext = (LONG)d1 - (LONG)(d5 & 0xffff) - 1;
			for (;;) {
				if (*a0p++ != *a1p++)
					break;
				if (--ext == -1)
					break;
			}
			nl = (LONG)d1 - ext - 1;		/* new len  */
			if (nl >= (LONG)(d5 & 0xffff)) {
				d5 = (dist << 16) | (ULONG)nl;
				if (nl >= (LONG)d1)
					break;		/* len>=cap */
			}
nextcand:
			d0 = ring[(d0 - 1) & 0x1fff];
		}
		/* ---------- run detection (cap 4114) ----------	    */
		d1 = (d7 < 4114) ? (ULONG)d7 : 4114;
		a0p = a2;
		d0 = *a0p++;
		d2 = 0;
		if (*a0p++ == (UBYTE)d0) {
			d2 = 2;
			if (*a0p++ == (UBYTE)d0) {
				d2 = d1 - 3;
				for (;;) {
					if (*a0p++ != (UBYTE)d0)
						break;
					if (--d2 == (ULONG)-1) {
						d2 = 0;
						break;
					}
				}
				d2 = d1 - d2;		/* R	     */
			}
		}
		if ((UWORD)d5 >= (UWORD)d2)
			goto bigmatch;
		/* ---------- run emit ----------			    */
		/* (the class-2 pair emit at 0x464 is dead code)	    */
		d5 = d2;				/* consumed=R */
		if (d2 >= 18) {				/* R=18 BUG!! */
			LONG n = (LONG)d2 - 19;
			*a6++ = (UBYTE)(0x10 | (n & 15));
			*a6++ = (UBYTE)(((UWORD)n >> 4) & 0xff);
			*a6++ = (UBYTE)d0;
		} else {
			LONG e = (LONG)d2 - 3;
			if ((UBYTE)d0 == 0)
				*a6++ = (UBYTE)(e | 0xe0);
			else {
				*a6++ = (UBYTE)e;
				*a6++ = (UBYTE)d0;
			}
		}
		goto tokout;
bigmatch:
		if ((SHORT)(d5 & 0xffff) < 3) {
biglit:
			d5 = 1;
			*a6++ = *a2;			/* literal    */
			goto flagdone;
		}
		{
			ULONG distm3 = (d5 >> 16) - 3;	/* dist-3   */
			ULONG len    = d5 & 0xffff;
			if (len >= 13) {		/* class 15   */
				*a6++ = (UBYTE)(0xf0 | (distm3 & 15));
				*a6++ = (UBYTE)((distm3 >> 4) & 0xff);
				*a6++ = (UBYTE)(len - 14);
			} else {
				*a6++ = (UBYTE)((len << 4) |
						(distm3 & 15));
				*a6++ = (UBYTE)((distm3 >> 4) & 0xff);
			}
		}
tokout:
		d5 = (ULONG)(SHORT)(d5 & 0xffff);	/* consumed   */
		d6 |= 1U << d3;				/* flag bit   */
flagdone:
		if (--d3 < 0) {				/* slot full  */
			a3[0] = (UBYTE)(d6 >> 8);
			a3[1] = (UBYTE)d6;
			a3 = a6;
			a6 += 2;
			d3 = 15;
			d6 = 0;
		}
		if (a6 >= d4b)
			return -17;
		d7 -= (LONG)d5;
		if (d7 <= 0)
			break;
	}
	if (d3 == 15)
		a6 -= 2;				/* empty slot   */
	else {
		a3[0] = (UBYTE)(d6 >> 8);
		a3[1] = (UBYTE)d6;
	}
	xp->xsp_OutLen = (ULONG)(a6 - out);
	return 0;
}

/* ---------------------------------------------------------------- */
/* -36 PackChunk: select packer by mode, alloc+reset workmem	  */
/* ---------------------------------------------------------------- */
LONG XpksPackChunk(struct XpkSubParams *xp ASMREG("a0"),
		   struct AccaBase *base ASMREG("a6"))
{
	ULONG allocsz, sub1;
	UBYTE *wk;
	LONG  (*core)(struct XpkSubParams *, UBYTE *);

	if (xp->xsp_Mode <= 79) {	/* cmpl 79,mode; bcc -> turbo  */
		sub1    = 0;
		allocsz = ALLOCSMALL;
		core    = pack_turbo;
	} else {			/* crawling		     */
		sub1    = 15;
		allocsz = ALLOCBIG;
		core    = pack_big;
	}
	if (!xp->xsp_Sub0) {
		wk = (UBYTE *)ALLOCMEM(allocsz, 0);
		if (!wk)
			return -7;
		*(ULONG *)wk = allocsz;
		xp->xsp_Sub0 = wk + 4;
		xp->xsp_Sub1 = sub1;
	}
	XpksPackReset(xp);
	return core(xp, (UBYTE *)xp->xsp_Sub0);
}

/* ---------------------------------------------------------------- */
/* -54 UnpackChunk (0x54a)						  */
/* ---------------------------------------------------------------- */
LONG XpksUnpackChunk(struct XpkSubParams *xp ASMREG("a0"),
		     struct AccaBase *base ASMREG("a6"))
{
	UBYTE *a3 = (UBYTE *)xp->xsp_InBuf;	/* input cursor  */
	UBYTE *a5 = a3 + xp->xsp_InLen;		/* input end	   */
	UBYTE *a4 = (UBYTE *)xp->xsp_OutBuf;	/* output cursor */
	UBYTE *a2 = a4;				/* output base   */
	ULONG  d2, d1, d0;
	LONG   d3;
	ULONG  cls;

	for (;;) {
		d2 = ((ULONG)a3[0] << 8) | a3[1];	/* flag word BE */
		a3 += 2;			/* over-reads end!*/
		if (a3 >= a5)
			break;
		for (d3 = 15; d3 >= 0; d3--) {
			if (!(d2 & (1UL << d3))) {
				*a4++ = *a3++;		/* literal  */
				continue;
			}
			d1 = *a3++;
			cls = d1 >> 4;
			d1 &= 15;
			if (cls == 0) {			/* byte run   */
				ULONG r;
				d0 = *a3++;
				*a4++ = (UBYTE)d0;
				*a4++ = (UBYTE)d0;
				*a4++ = (UBYTE)d0;
				r = d1;
				while (r--)
					*a4++ = (UBYTE)d0;
			} else if (cls == 1) {		/* long run   */
				LONG N = (LONG)d1 + ((LONG)*a3++ << 4);
				UBYTE b = *a3++;
				LONG t;
				if ((ULONG)a4 & 1) {	/* align	    */
					*a4++ = b;
					N--;
				}
				{			/* fixed 18 bytes */
					ULONG dd = 0x01010101U * b;
					ULONG *q = (ULONG *)a4;
					*q++ = dd; *q++ = dd;
					*q++ = dd; *q++ = dd;
					*(UWORD *)q = (UWORD)dd;
					a4 += 18;
				}
				if (N < 0)
					continue;
				t = N & 3;
				N = (N >> 2) - 1;
				if (N >= 0) {
					ULONG dd = 0x01010101U * b;
					ULONG *q = (ULONG *)a4;
					do {
						*q++ = dd;
					} while (N--);
					a4 = (UBYTE *)q;
				}
				do {
					*a4++ = b;
				} while (t--);
			} else if (cls == 2) {		/* common pair  */
				d0 = tab16[d1];
				*a4++ = (UBYTE)d0;
				*a4++ = (UBYTE)d0;
			} else if (cls == 14) {		/* zero run   */
				ULONG r = d1;
				*a4++ = 0; *a4++ = 0; *a4++ = 0;
				while (r--)
					*a4++ = 0;
			} else if (cls == 15) {		/* long match */
				ULONG dist = d1 + 3 +
					     ((ULONG)*a3++ << 4);
				UBYTE *src;
				LONG  cnt = *a3++ + 13;
				src = a4 - dist;
				if (dist & 1) {		/* byte path    */
					do {
						*a4++ = *src++;
					} while (cnt--);
				} else {
					if ((ULONG)src & 1) {
						*a4++ = *src++;
						cnt--;
					}
					{
						LONG n4 = (cnt >> 2) - 1;
						LONG tb = cnt & 3;
						if (n4 >= 0) {
							do {
							 *(ULONG *)a4 =
							  *(ULONG *)src;
							 a4 += 4; src += 4;
							} while (n4--);
						}
						do {
							*a4++ = *src++;
						} while (tb--);
					}
				}
			} else {			/* cls 3..13   */
				ULONG dist = 16 * (ULONG)*a3++ + d1 + 3;
				UBYTE *src = a4 - dist;
				LONG  n = (LONG)cls;
				do {
					*a4++ = *src++;
				} while (--n != 0);
			}
		}
	}
	xp->xsp_OutBufLen = (ULONG)(a4 - a2);	/* writes at +12! */
	return 0;
}

/* ---------------------------------------------------------------- */
/* -30 PackerInfo							  */
/* ---------------------------------------------------------------- */
char *XpksPackerInfo(struct XpkSubParams *xp ASMREG("a0"),
		     struct AccaBase *base ASMREG("a6"))
{
	return xpkinfo;
}

/* ---------------------------------------------------------------- */
/* lifecycle							  */
/* ---------------------------------------------------------------- */
struct Library *LibOpen(struct AccaBase *b ASMREG("a6"))
{
	++b->lib.lib_OpenCnt;
	b->lib.lib_Flags &= ~LIBF_DELEXP;
	return (struct Library *)b;
}

static ULONG expunge_body(struct AccaBase *b)
{
	ULONG seg = (ULONG)b->seglist;
	ULONG sz  = b->lib.lib_NegSize + b->lib.lib_PosSize;
	UBYTE *p  = (UBYTE *)b - b->lib.lib_NegSize;
	REMOVENODE(&b->lib.lib_Node);
	FREEMEM(p, sz);
	return seg;
}

LONG LibClose(struct AccaBase *b ASMREG("a6"))
{
	if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
		return (LONG)expunge_body(b);
	return 0;
}

ULONG LibExpunge(struct AccaBase *b ASMREG("a6"))
{
	if (b->lib.lib_OpenCnt) {
		b->lib.lib_Flags |= LIBF_DELEXP;
		return 0;
	}
	return expunge_body(b);
}
