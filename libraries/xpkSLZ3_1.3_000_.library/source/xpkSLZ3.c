/*
**	xpkSLZ3.c -- xpkSLZ3.library 1.3 (000) "Simple & Fast LZSS"
**	C reconstruction of the shipped binary by Niels Froehling,
**	based on Adisak Pochanayon's workshop.
**
**	LZSS with interleaved flag bytes: each flag byte (MSB
**	first, 1 = match, 0 = literal) directly precedes the 8
**	items it describes.  Match token = [dist_hi4 | len-2]
**	[dist_lo8], dist 1..4095, len 3..17.  A match token whose
**	first byte is 0 is the end-of-stream marker.
**
**	Workmem (allocated lazily in the first XpksPackChunk,
**	0x44004 bytes = size word + hash table + chain ring):
**
**	    sub+0x00000  ULONG hash[65536]  last position per hash
**	    sub+0x40000  ULONG chain[4097]  prev pos ring, pos & 0xfff
**
**	hash = (b0 << 8) | ((b1 + b2) & 0xff).  The original keeps
**	the hash index as a negative long (moveq #-1 trick) so a
**	single base register at sub+0x40000 serves both tables;
**	this reconstruction uses the hash base directly.
**
**	Shipped quirks preserved where deterministic:
**	  - the flag byte is padded with 1-bits at stream end, so
**	    the decoder consumes the 0 terminator as a "match"
**	  - encoder seeds/match-scans read up to ~17 bytes past
**	    the input end (documented, not guarded)
**	  - output bound is outbuf+inlen (xsp_OutBufLen ignored),
**	    checked AFTER each item -> small overrun possible
**	  - PackReset zeroes the hash table by filling DOWN from
**	    its top and runs ~15 KB past the bottom of the block;
**	    the chain ring is never initialised
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size (unused)	   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18					   */
    ULONG xsp_Mode;		/* 0x1c					   */
    APTR  xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Tags[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34 sublib private data		   */
};

struct XpkSubBase		/* InitTable dataSize = 0x26		   */
{
    struct Library xsb_Lib;	/* 0x00					   */
    BPTR   xsb_SegList;		/* 0x22					   */
};

extern const UBYTE s_xpkinfo[];	/* XpkInfo + XpkMode descriptor block  */

/* ------------------------------------------------------------------ */
/* Exec LVOs								  */
/* ------------------------------------------------------------------ */

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_size __asm("d0") = (ULONG)(__size);\
  register ULONG __p_flags __asm("d1") = (ULONG)(___flags);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_size), "d"(__p_flags), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "a0" );})

#define __Remove(__node) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_node __asm("a1") = (APTR)(__node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->xsb_SegList = seglist;
    return (struct Library *)base;
}

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"));

LONG LibClose(struct XpkSubBase *base __asm("a6"))
{
    LONG res = 0;

    if (!--base->xsb_Lib.lib_OpenCnt &&
	(base->xsb_Lib.lib_Flags & LIBF_DELEXP))
	res = (LONG)LibExpunge(base);

    return res;
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    BPTR seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->xsb_SegList;
    __Remove(&base->xsb_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->xsb_Lib.lib_NegSize,
	      (ULONG)base->xsb_Lib.lib_NegSize + base->xsb_Lib.lib_PosSize);

    return seg;
}

/* null vector -- ExtFunc and XpksUnpackFree share the entry stub */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* xpksub vectors							  */
/* ------------------------------------------------------------------ */

/* -30 XpksPackerInfo */
const void *XpksPackerInfo(void)
{
    return s_xpkinfo;
}

#define WORKMEM_SIZE	0x44004		/* size word + hash + chain  */

/* -42 XpksPackFree: free the workmem block (size stored at buf[0]) */
LONG XpksPackFree(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *blk = sub - 1;		/* back up to the size word */
	__FreeMem(blk, blk[0]);
    }

    return 0;
}

/*
**	-48 XpksPackReset
**
**	The shipped code fills DOWNWARD with pre-decrement movem
**	writes starting at sub+0x40000 (the top of the hash
**	table), 1260 * 220 + 12 = 277,212 bytes -- the whole
**	256 KB hash plus ~15 KB BELOW the block (shipped
**	underflow).  The chain ring above sub+0x40000 is never
**	initialised.  This version clears the intended region.
*/
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"))
{
    ULONG *sub = (ULONG *)p->xsp_Sub[0];

    if (sub) {
	ULONG *w = sub, *end = sub + 0x10000;	/* hash[65536] */
	while (w < end)
	    *w++ = 0;
    }

    return 0;
}

/*
**	-36 XpksPackChunk -- greedy LZSS encoder
**
**	Stream: [flag][item]... flag byte MSB-first before the 8
**	items it describes; match token 2 bytes, literal 1 byte;
**	0x00 byte terminates.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *out, *outend;
    ULONG  *hash, *chain;
    ULONG   remaining, best, flag;
    UBYTE  *flagslot, *cur, *cand;

    if (!p->xsp_Sub[0]) {
	ULONG *buf = (ULONG *)__AllocMem(WORKMEM_SIZE, 0);
	if (!buf)
	    return -7;
	buf[0] = WORKMEM_SIZE;
	p->xsp_Sub[0] = (ULONG)(buf + 1);
    }

    XpksPackReset(p);

    hash  = (ULONG *)p->xsp_Sub[0];
    chain = hash + 0x10000;

    cur    = (UBYTE *)p->xsp_InBuf;
    out    = (UBYTE *)p->xsp_OutBuf;
    outend = out + p->xsp_InLen;		/* bound = inlen */
    remaining = p->xsp_InLen;

    flagslot = out++;			/* first flag slot */
    flag = 1;				/* sentinel */

    /* seed position 0 (reads up to cur[2]) */
    {
	ULONG h = ((cur[0] << 8) | ((cur[1] + cur[2]) & 0xff));
	cand = (UBYTE *)hash[h];
	hash[h] = (ULONG)cur;
	chain[(ULONG)cur & 0xfff] = (ULONG)cand;
    }

    for (;;) {
	/* candidate walk: best match >= 17 wins instantly,
	   else the best >= 3 after the chain is exhausted */
	best = 2;

	ULONG bestdist = 0;

	/* the shipped code keeps the best pair in d5 as
	   [dist:len]; the emit uses ITS distance, not the
	   chain-end pointer's */
	while ((ULONG)(cur - cand) <= 0xfff) {
	    ULONG len;
	    ULONG dist = (ULONG)(cur - cand);

	    if (cur[best] != cand[best])
		goto next;

	    /* full compare, bytes 1..16 (byte 0 implied by
	       the hash) -- reads up to cur[16] */
	    len = 1;
	    while (len < 17 && cur[len] == cand[len])
		len++;

	    if ((ULONG)len > remaining)
		len = remaining;

	    if (len >= best) {
		best = len;
		bestdist = dist;
		if (len >= 17)
		    break;
	    }
	next:
	    cand = (UBYTE *)chain[(ULONG)cand & 0xfff];
	}

	if (best >= 3) {
	    /* match token: [dist_hi4 | len-2][dist_lo8] */
	    *out++ = (UBYTE)(((bestdist >> 4) & 0xf0) | (best - 2));
	    *out++ = (UBYTE)bestdist;
	    flag = (flag << 1) | 1;
	} else {
	    *out++ = cur[0];
	    best = 1;
	    flag = flag << 1;
	}

	if (flag & 0x100) {			/* flag byte full */
	    *flagslot = (UBYTE)flag;
	    flagslot = out++;
	    flag = 1;
	}

	if (out >= outend) {
	    p->xsp_OutLen = 0;
	    return -17;
	}

	remaining -= best;
	if (!remaining)
	    break;

	/* seed the consumed positions */
	while (best--) {
	    ULONG h;
	    cur++;
	    h = ((cur[0] << 8) | ((cur[1] + cur[2]) & 0xff));
	    cand = (UBYTE *)hash[h];
	    hash[h] = (ULONG)cur;
	    chain[(ULONG)cur & 0xfff] = (ULONG)cand;
	}
    }

    /* pad the last flag byte: one 1-bit (forces the decoder's
       match branch onto the terminator), then 0-bits -- the
       shipped orib #16 / addxb / addb sequence */
    flag = (flag << 1) | 1;
    while (!(flag & 0x100))
	flag = flag << 1;
    *flagslot = (UBYTE)flag;

    *out++ = 0;				/* terminator */

    p->xsp_OutLen = (ULONG)(out - (UBYTE *)p->xsp_OutBuf);
    return 0;
}

/*
**	-54 XpksUnpackChunk -- decoder
**
**	flag byte MSB-first: 0 -> literal, 1 -> match token.
**	Match first byte 0 -> end of stream.
**
**	The shipped flag mechanism: the register starts at 0x80
**	so the first shift reads a flag byte; the byte is loaded
**	as (f << 1) | 1 -- the inserted sentinel bit marks the
**	end of the 8 items, so a flag byte serves exactly 8
**	items and the consumed bit arrives via the shift-out
**	carry.  Modelled here with a 9-bit shift register.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"))
{
    UBYTE *src = (UBYTE *)p->xsp_InBuf;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    ULONG  d0 = 0x80;			/* moveq #-128 / first shift */

    for (;;) {
	ULONG bit;

	d0 = (d0 << 1) & 0x1ff;
	if (!(d0 & 0xff))		/* low byte empty -> reload flag */
	    d0 = (*src++ << 1) | 1;

	bit = (d0 >> 8) & 1;		/* shifted-out bit = item type */
	d0 &= 0xff;

	if (bit) {
	    /* match: [dist_hi4 | len-2][dist_lo8] */
	    ULONG t = *src++;
	    ULONG len;

	    if (!t)
		break;

	    len = (t & 0xf) + 2;
	    {
		UBYTE *m = dst - (((t << 4) & 0xf00) | *src++);
		while (len--)
		    *dst++ = *m++;
	    }
	} else {
	    *dst++ = *src++;
	}
    }

    p->xsp_OutLen = (ULONG)(dst - (UBYTE *)p->xsp_OutBuf);
    return 0;
}
