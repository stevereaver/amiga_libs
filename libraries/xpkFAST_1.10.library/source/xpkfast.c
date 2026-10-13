/*
**	xpkfast.c -- C reconstruction of xpkFAST.library V1.10 (20.09.1998)
**	"FAST alias WOOP or LZRW++" (Christian von Roques).
**
**	XPK sublibrary: LZ77 over a 4095-byte window with two packers,
**	selected by the mode field (<= 80 = "speedy", > 80 = "crawling"
**	-- note the boundary moved vs 1.06 where mode 80 was crawling).
**
**	Vector map (AUTOINIT functab, LONG absolute entries):
**
**	  -6  LibOpen          -30 XpksPackerInfo
**	  -12 LibClose         -36 XpksPackChunk
**	  -18 LibExpunge       -42 XpksPackFree
**	  -24 stub (ret 0)     -48 stub (ret 0)
**	                       -54 XpksUnpackChunk
**	                       -60 stub (ret 0)
**
**	1.10 differences vs 1.06 (the packers/decoder are unchanged):
**	  - dataSize 0x22: no private lib struct at all.  Exec calls
**	    reload a6 via `moveal 4:w,a6` and the seglist is kept in a
**	    self-modifying longword slot inside the consumed datatab
**	    (code+0x7a, written through an ABSOLUTE.LONG address that
**	    the hunk reloc turns into code+0x7a).
**	  - initfunc calls the return-0 stub (dead hook), same for the
**	    expunge body.
**	  - AllocMem flags = 1 (MEMF_PUBLIC bit), 1.06 passed 0.
**	  - PackChunk frees a mismatched workmem by calling its own
**	    -42 vector (jsr a6@(-42)); 1.06 inlined the PackFree body.
**	  - UnpackChunk wrapper does not preserve a1 (decoder clobbers
**	    it as the output cursor; harmless ABI scratch reg).
**	  - mode boundary: <= 80 speedy (1.06: < 80).
**	  - idstr "xpkFAST 1.10 (20.09.1998)" lost the "$VER:" prefix
**	    and the datatab writes ln_Type at the CORRECT offset +8
**	    (1.06 had an a0 0c quirk writing +12, inside ln_Name).
**
**	Stream layout: literal bytes grow forward from OutBuf; flag and
**	match words grow BACKWARD from OutBuf + (InLen & ~3); on finish
**	the control tail is compacted down behind the literals.
**	  flag word = 16 items, MSB first; 0 = literal, 1 = match; a
**	  match pulls the NEXT backward word  w = (off<<4)|(18-len),
**	  len 3..18, off 1..4095.
**
**	Workmem (AllocMem'd on first PackChunk, freed/realloc'd when the
**	mode's size differs):
**	  speedy   0x10000: hash table u32[16384] at the base, filled
**	           with the input-end pointer as "empty" marker.
**	  crawling 0x44000: hash table u32[65536] at the base reached
**	           through a negative-biased long index (index =
**	           (0xffff0000|gram)<<2 into a base at work+0x40000, so
**	           slots land at work+0..work+0x40000), chain table
**	           u32[4096] at work+0x40000, all filled with
**	           InBuf-4096.
**
**	Shipped quirks reproduced verbatim (see okf/findings/defects.md):
**	  - vectors -24/-48/-60 are return-0 stubs; PackReset (-48)
**	    does NOT clear the tables (mode switch only reallocates).
**	  - crawler literal loop end-checks only at flag-word
**	    boundaries -> emits bytes read PAST the input end.
**	  - crawler drain injects pad flag bit = 1 (X from the last
**	    hash shift), not 0.
**	  - decoder post-literal-A / post-match-B paths lack the
**	    flag-register exhaustion check: a popped sentinel bit is
**	    treated as a real match flag (desync quirk).
**	  - decoder has no output bound; it runs until the forward
**	    literal cursor meets the backward control cursor.
**	  - packer returns 0 on stream collision -> wrapper maps to -17.
*/

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t        UBYTE;
typedef uint16_t       UWORD;
typedef uint32_t       ULONG;
typedef int32_t        LONG;
typedef void          *APTR;
typedef char          *STRPTR;
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
    ULONG   xsp_Sub[4];		/* 0x34: [0]=workmem, [1]=alloc size */
};

/* -------------------------------------------------------------- */
/* exec calls -- 1.10 has no execbase field; the original reloads   */
/* a6 via `moveal 4:w,a6` (SysBase absolute)			    */
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
    register APTR  __p_sys __asm("a6") = *(APTR *)4;
    register ULONG __p_sz  __asm("d0") = sz;
    register APTR  __r     __asm("d0");
    __asm volatile ("moveq #1,%/d1\n\tjsr %/a6@(-198:W)\n"
	: "=r" (__r)
	: "a" (__p_sys), "r" (__p_sz)
	: "a0","a1","d1","memory");
    return __r;
}

static void exec_Remove(void *n)
{
    register APTR __p_sys __asm("a6") = *(APTR *)4;
    register APTR __p_n   __asm("a1") = n;
    __asm volatile ("jsr %/a6@(-252:W)\n"
	:
	: "a" (__p_sys), "a" (__p_n)
	: "a0","d0","d1","memory");
}

static void exec_FreeMem(void *p, ULONG sz)
{
    register APTR __p_sys __asm("a6") = *(APTR *)4;
    register APTR __p_p   __asm("a1") = p;
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
struct Library *LibOpen(struct Library *b __asm("a6"))
{
    ++b->lib_OpenCnt;
    b->lib_Flags &= ~LIBF_DELEXP;
    return b;
}

extern ULONG segslot;		/* code-hunk slot at the datatab tail */
LONG LibStub(void);

/* expunge body: Remove + FreeMem; returns the seglist */
static ULONG expunge_body(struct Library *b)
{
    ULONG seg = segslot;
    ULONG sz = b->lib_NegSize + b->lib_PosSize;
    UBYTE *p = (UBYTE *)b - b->lib_NegSize;
    exec_Remove(b);
    LibStub();			/* dead hook -- the original bsr's
				   the return-0 stub here too */
    exec_FreeMem(p, sz);
    return seg;
}

/* -12 Close: --OpenCnt; last close with DELEXP -> expunge */
LONG LibClose(struct Library *b __asm("a6"))
{
    if (--b->lib_OpenCnt == 0 &&
	(b->lib_Flags & LIBF_DELEXP))
	return (LONG)expunge_body(b);
    return 0;
}

/* -18 Expunge: OpenCnt>0 -> set DELEXP, return 0; else expunge now */
LONG LibExpunge(struct Library *b __asm("a6"))
{
    if (b->lib_OpenCnt) {
	b->lib_Flags |= LIBF_DELEXP;
	return 0;
    }
    return (LONG)expunge_body(b);
}

/* -24/-48/-60: return-0 stubs; also the dead initfunc/expunge hook */
LONG LibStub(void)
{
    return 0;
}

/* -------------------------------------------------------------- */
/* -30 XpksPackerInfo						    */
/* -------------------------------------------------------------- */

extern UBYTE xpkinfo[];

APTR XpksPackerInfo(struct XpkSubParams *xsp __asm("a0"),
		    struct Library *b __asm("a6"))
{
    return xpkinfo;
}

/* -------------------------------------------------------------- */
/* packers							    */
/* -------------------------------------------------------------- */

/* control stream is written as big-endian words descending from
   ctop = out + (InLen & ~3) */
#define CWPUT(cw, w)	do { (cw) -= 2; (cw)[0] = (UBYTE)((w) >> 8); \
			     (cw)[1] = (UBYTE)(w); } while (0)
#define CWSTORE(at, w)	do { (at)[0] = (UBYTE)((w) >> 8); \
			     (at)[1] = (UBYTE)(w); } while (0)

/* shared finish: check the literal/control gap, write (gap&3)
   zero pad bytes (dbf loop -- can be ZERO pad bytes), compact the
   control block behind the literals, return packed length or 0
   (streams collided -> wrapper sees -17) */
static ULONG pk_finish(UBYTE *out, UBYTE *o, UBYTE *cw, UBYTE *ctop)
{
    LONG gap = (LONG)(cw - o);
    ULONG n, size;

    if (gap < 0)
	return 0;
    n = (ULONG)(gap & 3);
    while (n--)
	*o++ = 0;
    size = (ULONG)(ctop - cw);
    while (size--)
	*o++ = *cw++;
    return (ULONG)(o - out);
}

/*
**	Speedy packer (mode <= 80), code+0x138.
**	One-candidate hash match; flag accumulator d3 seeded to 0xffff
**	per word (literal = addw<<1, match = rolw -- inserts old bit15
**	which is still 1 while <= 16 items accumulate).
**	Two phases: head checks the input bound only when a flag word
**	completes; the last 288 bytes run "tail" with a per-item check.
*/
static ULONG pk_speedy(UBYTE *in, ULONG inlen, UBYTE *out, ULONG *tab)
{
    const UBYTE *a0 = in;			/* position cursor */
    const UBYTE *in_end = in + inlen;
    const UBYTE *bound;				/* d5 */
    UBYTE  *o = out;				/* a1 */
    UBYTE  *ctop = (UBYTE *)((ULONG)(out + inlen) & ~3UL); /* a4 top */
    UBYTE  *cw = ctop;				/* a4 */
    UBYTE  *slot;				/* a5 */
    ULONG   h = 0;				/* d1, stateful hash */
    UWORD   d3 = 0xffff;			/* flag accumulator */
    LONG    cnt = 15;				/* d2 head / d6 tail */
    int     tail = 0;
    ULONG   i;

    for (i = 0; i < 16384; i++)
	tab[i] = (ULONG)in_end;
    bound = in_end - 288;

    /* entry jumps to the head thunk's phase check (no word stored) */
    if (a0 >= bound)
	goto tail_slot;
head_slot:
    cw -= 2; slot = cw; cnt = 15; d3 = 0xffff;

    for (;;) {
	const UBYTE *p = a0;
	const UBYTE *cand;
	ULONG dist;
	LONG len = 0;

	/* hash in[p..p+2]; d1 keeps bits 8..15 between tokens */
	h = (h & 0xff00) | p[0];
	h = (h << 3) & 0xffff;
	h = (h & 0xff00) | (((h & 0xff) + p[1]) & 0xff);
	h = (h << 3) & 0xffff;
	h = (h & 0xff00) | (((h & 0xff) + p[2]) & 0xff);
	h = (h << 2) & 0xffff;

	cand = (const UBYTE *)tab[h >> 2];
	tab[h >> 2] = (ULONG)a0;
	dist = (ULONG)a0 - (ULONG)cand;
	if (dist < 0x1000)
	    while (len < 18 && cand[len] == p[len])
		len++;

	if (len < 3) {
	    *o++ = *p;			/* literal */
	    a0 = p + 1;
	    d3 <<= 1;			/* flag 0 */
	} else {
	    CWPUT(cw, (UWORD)((dist << 4) | (18 - len)));
	    a0 = p + len;
	    d3 = (UWORD)((d3 << 1) | (d3 >> 15));	/* flag 1 */
	}

	if (tail) {
	    /* tail thunk: end check first, then flag-word counter */
	    if (a0 >= in_end)
		break;
	    if (--cnt >= 0)
		continue;
	    CWSTORE(slot, d3);
	    goto tail_slot;
	}
	if (--cnt >= 0)
	    continue;
	/* head word completed: store, phase check, new slot */
	CWSTORE(slot, d3);
	if (a0 >= bound) {
	    tail = 1;
	    bound = in_end;
	    goto tail_slot;
	}
	goto head_slot;

tail_slot:
	cw -= 2; slot = cw; cnt = 15; d3 = 0xffff;
	tail = 1;
    }

    /* drain: lslw cnt,d3 top-aligns the pending flags, store */
    d3 = (UWORD)(d3 << cnt);
    CWSTORE(slot, d3);
    return pk_finish(out, o, cw, ctop);
}

/*
**	Crawling packer (mode > 80), code+0x358.
**	Hash index g = (b0<<8) | ((b1+b2)&0xff) -> u32[65536] at work
**	base via the biased pointer; chain table u32[4096] at
**	work+0x40000, filled (with the hash table) to InBuf-4096.
**	Window floor = a0 - 4095; greedy chain walk for the longest
**	match, min len_field 2 (decoded length = len_field+1 >= 3).
**	Flag register d7 = sentinel+flags (starts 1, insert via
**	addxw; carry-out -> store word).
**
**	Only the gram's LAST byte plus the forward extension are
**	byte-compared; the first two bytes are trusted to the hash.
*/
static ULONG pk_crawl(UBYTE *in, ULONG inlen, UBYTE *out, ULONG *work)
{
    ULONG *htab = work;			/* u32[65536] */
    ULONG *chain = work + 0x10000;	/* u32[4096] @ work+0x40000 */
    const UBYTE *a0;
    const UBYTE *in_end2 = in + inlen + 2;	/* d1 bound */
    const UBYTE *floor;				/* d2 */
    const UBYTE *d5 = in;				/* candidate */
    UBYTE  *o = out;
    UBYTE  *ctop = out + (inlen & ~3UL);
    UBYTE  *cw = ctop, *slot;			/* a4 / a3 */
    ULONG   best;				/* d3: dist<<16|lf */
    ULONG   c;
    UWORD   d7;
    ULONG   i;

    for (i = 0; i < 0x11000; i++)
	work[i] = (ULONG)(in - 4096);

    /* prime gram at in[0..2], stored position = in+2 (gram end) */
    htab[(((ULONG)in[0] << 8) | (((ULONG)in[1] + in[2]) & 0xff))] =
	(ULONG)(in + 2);
    a0 = in + 2;

    cw -= 2; slot = cw;			/* reserve first flag slot */
    d7 = 1;				/* sentinel at bit0 */
    floor = a0 - 0xfff;			/* d2 = a0 - 4095 */

    /* enter on the literal path, just like the original */
    goto literal;

    for (;;) {
	/* shared candidate eval: reached after every literal insert
	   AND after every match, with d5 = last hash head read
	   (post-match this is the stale head of the last rehashed
	   gram -> the original can emit back-to-back matches) */
	if (d5 >= floor) {
	    const UBYTE *q, *r;
	    LONG lf;

	    best = 1;
	    do {
		/* compare gram's 3rd byte + extension; lf counts the
		   FAILED compare too (a5 ran past it) -> wire length
		   is lf+1 = equal+2 on a fail, 18 when all 16 pass */
		q = d5; r = a0;
		for (lf = 0; lf < 16 && q[lf] == r[lf]; lf++)
		    ;
		if (lf)
		    lf++;
		if (lf > (LONG)(best & 0xffff)) {
		    best = (((ULONG)a0 - (ULONG)d5) << 16) | (ULONG)lf;
		    if (lf >= 17)
			break;
		}
		d5 = (const UBYTE *)chain[(ULONG)d5 & 0xfff];
	    } while (d5 >= floor);

	    if ((best & 0xffff) >= 2) {
		ULONG n;

		/* match: token = (dist<<4) | (17 - len_field) */
		CWPUT(cw, (UWORD)(((best >> 16) << 4) |
				  (17 - (best & 0xffff))));
		floor += (best & 0xffff) + 1;	/* d2 += lf+1 */

		/* rehash lf+1 grams (dbf runs d3.w+1 times); d5 is
		   left holding the last rehashed gram's old head */
		for (n = (best & 0xffff) + 1; n; n--) {
		    ULONG g2 = (((ULONG)a0[-1] << 8) |
				(((ULONG)a0[0] + a0[1]) & 0xff));
		    a0++;
		    d5 = (const UBYTE *)htab[g2];
		    htab[g2] = (ULONG)a0;
		    chain[(ULONG)a0 & 0xfff] = (ULONG)d5;
		}
		if (a0 >= in_end2) {
		    /* drain: rotate d7 until the sentinel pops; the
		       first injected bit is X = carry of the last
		       asll = 1 */
		    ULONG x = 1;
		    do {
			c = d7 >> 15;
			d7 = (UWORD)((d7 << 1) | x);
			x = c;
		    } while (!c);
		    CWSTORE(slot, d7);
		    goto fin;
		}
		/* flag 1 for the match (X=1 left by the last asll) */
		c = d7 >> 15;
		d7 = (UWORD)((d7 << 1) | 1);
		if (c) {
		    CWSTORE(slot, d7);
		    cw -= 2; slot = cw; d7 = 1;
		    if (a0 >= in_end2) {
			cw += 2;	/* unreserve fresh empty slot */
			goto fin;
		    }
		}
		continue;		/* eval stale d5 */
	    }
	}

literal:
	{
	    ULONG g;

	    *o++ = a0[-2];		/* literal = byte at gram-1 */
	    /* hash gram at a0-1..a0+1; store a0+1 (post-inc) */
	    g = (((ULONG)a0[-1] << 8) | (((ULONG)a0[0] + a0[1]) & 0xff));
	    a0++;
	    floor++;			/* d2 stays a0 - 4095 */
	    d5 = (const UBYTE *)htab[g];
	    htab[g] = (ULONG)a0;
	    chain[(ULONG)a0 & 0xfff] = (ULONG)d5;
	}
	/* flag 0 for the literal (X=0 left by the aslw) */
	c = d7 >> 15;
	d7 = (UWORD)(d7 << 1);
	if (c) {
	    CWSTORE(slot, d7);
	    cw -= 2; slot = cw; d7 = 1;
	    if (a0 >= in_end2) {
		cw += 2;		/* unreserve fresh empty slot */
		goto fin;
	    }
	}
    }

fin:
    return pk_finish(out, o, cw, ctop);
}

/* -------------------------------------------------------------- */
/* vectors							    */
/* -------------------------------------------------------------- */

/* -42 XpksPackFree: frees the workmem (ptr at Sub[0], size at
   Sub[1]); PackChunk invokes it through its own vector (a6@-42) */
LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"),
		  struct Library *b __asm("a6"))
{
    APTR  p;
    ULONG sz;

    p = (APTR)xsp->xsp_Sub[0];
    if (!p)
	return 0;
    xsp->xsp_Sub[0] = 0;
    sz = xsp->xsp_Sub[1];
    xsp->xsp_Sub[1] = 0;
    exec_FreeMem(p, sz);
    return 0;
}

#ifdef HOST_TEST
#define vec_packfree(b, xsp)	XpksPackFree(xsp, b)
#else
/* the original calls its own -42 slot so a SetFunction patch would
   be honored; keep that indirection */
static LONG vec_packfree(struct Library *b __asm("a6"),
			 struct XpkSubParams *xsp)
{
    register struct Library      *__p_b   __asm("a6") = b;
    register struct XpkSubParams *__p_xsp __asm("a0") = xsp;
    register LONG                 __r     __asm("d0");
    __asm volatile ("jsr %/a6@(-42:W)\n"
	: "=r" (__r)
	: "a" (__p_b), "a" (__p_xsp)
	: "a1","a2","d1","memory");
    return __r;
}
#endif

/*
** -36 XpksPackChunk.  Mode <= 80 -> speedy (0x10000 workmem),
** > 80 -> crawling (0x44000).  If a workmem of the other size is
** still attached it is freed via the -42 vector and reallocated.
** -7 alloc fail, -17 packer returned 0 (stream collision).
*/
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   struct Library *b __asm("a6"))
{
    ULONG size, pk, (*pack)(UBYTE *, ULONG, UBYTE *, ULONG *);
    APTR m;

    if (xsp->xsp_Mode <= 80) {
	size = 0x10000;
	pack = pk_speedy;
    } else {
	size = 0x44000;
	pack = pk_crawl;
    }
    if (xsp->xsp_Sub[0] == 0)
	goto alloc;
    if (xsp->xsp_Sub[1] == size)
	goto have;
    vec_packfree(b, xsp);
alloc:
    xsp->xsp_Sub[1] = size;	/* stored before AllocMem */
    m = exec_AllocMem(size);
    xsp->xsp_Sub[0] = (ULONG)m;
    if (!m)
	return -7;
have:
    pk = pack((UBYTE *)xsp->xsp_InBuf, xsp->xsp_InLen,
	      (UBYTE *)xsp->xsp_OutBuf, (ULONG *)xsp->xsp_Sub[0]);
    if (!pk)
	return -17;
    xsp->xsp_OutLen = pk;
    return 0;
}

/*
** -54 XpksUnpackChunk: literals forward at a0, flag/token words
** backward at a4 = in+inlen.  Four ping-pong paths; the flag
** register d1 carries a low sentinel bit so exhaustion lands on
** the reload check -- except after matchB/literalA where the check
** is missing (a popped sentinel becomes a spurious match flag).
*/
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     struct Library *b __asm("a6"))
{
    UBYTE *a0 = (UBYTE *)xsp->xsp_InBuf;
    UBYTE *a1 = (UBYTE *)xsp->xsp_OutBuf;
    UBYTE *a4 = a0 + xsp->xsp_InLen;
    ULONG  d1, c;

#define NEXTW()	(((ULONG)a4[-2] << 8) | a4[-1])
#define POP()	(c = d1 >> 15, d1 = (d1 << 1) & 0xffff, c)
#define MATCH()	do { ULONG _w = NEXTW(); a4 -= 2; \
		     const UBYTE *_s = a1 - (_w >> 4); \
		     LONG _n = 18 - (LONG)(_w & 15); \
		     while (_n--) *a1++ = *_s++; } while (0)
#define RELOAD() do { ULONG _w = NEXTW(); a4 -= 2; \
		      c = _w >> 15; \
		      d1 = ((_w << 1) | 1) & 0xffff; } while (0)

    /* init: sentinel injected at bit0 (X=1 from the 0x8000+0x8000) */
    {
	ULONG w = NEXTW();
	a4 -= 2;
	c = w >> 15;
	d1 = ((w << 1) | 1) & 0xffff;
    }
    if (c)
	goto matchB;
litA:
    *a1++ = *a0++;
    if (POP())
	goto matchA;		/* no exhaustion check (quirk) */
    goto litC;

matchA:
    MATCH();
    if (!POP())
	goto litA;
    if (d1)
	goto matchB;
    if (a0 >= a4)
	return 0;
    RELOAD();
    if (!c)
	goto litA;
matchB:
    MATCH();
    if (POP())
	goto matchA;		/* no exhaustion check (quirk) */
litC:
    *a1++ = *a0++;
    if (!POP())
	goto litA;
    if (d1)
	goto matchB;
    if (a0 >= a4)
	return 0;
    RELOAD();
    if (!c)
	goto litA;
    goto matchB;
}
