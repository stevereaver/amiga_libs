/*
**	xpkDMCB.c -- xpkDMCB.library 1.1
**
**	C reconstruction of the shipped DMC (Dynamic Markov
**	Compression) XPK sublibrary -- a binary arithmetic
**	coder over a state-cloning Markov model, computed in
**	68881 extended precision.  Requires 68020 + 68881
**	(LibInit checks AFB_68020 + AFB_68881 in AttnFlags and
**	refuses to init without them).
**
**	  -30	XpksPackerInfo -> static descriptor
**	  -36	XpksPackChunk    DMC encoder
**	  -54	XpksUnpackChunk  DMC decoder
**	  (-24/-42/-48/-60 -> moveq #0,d0/rts nulls)
**
**	Model: 2 MB workmem = 1 MB freq table (2 x float per
**	state, contexts 0..0x1fffe) + 1 MB transition table
**	(2 x long per state).  States 0..0xfffe form a static
**	255-node x 256-row graph; states 0x10000..0x1fffe are
**	cloned dynamically.  Clone fires when the chosen
**	transition count >= 10.0 AND (target_total - count)
**	>= 10.0; the clone takes a count/total fraction of the
**	target's frequencies.  At mfree==0x1ffff the whole
**	model is re-initialised mid-update.
**
**	Stream: [4B unpacked length][3-byte-arith-coded bits].
**
**	External calls: exec AllocMem(-198), FreeMem(-210),
**	Remove(-252) only.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size		   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18 chunk number			   */
    ULONG xsp_Mode;		/* 0x1c packing mode			   */
    STRPTR xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Arg[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34 sublib private data		   */
};

struct DmcbBase			/* InitTable dataSize = 0x2a	   */
{
    struct Library b_Lib;	/* 0x00 standard library node	   */
    BPTR   b_SegList;		/* 0x22 seglist, stored by LibInit   */
    UBYTE  b_Flags;		/* 0x26 DELEXP lives at +38	   */
    UBYTE  b_Pad;
};				/* = 0x2a				   */

#define SYSBASE	(*(struct ExecBase **)4)

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_d0), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

/* ------------------------------------------------------------------ */
/* model state							  */
/* ------------------------------------------------------------------ */

#define WORKMEM		0x200000UL	/* 2 MB			   */
#define LINK_OFF	0x100000UL	/* link table offset	   */
#define CLONE_THRESH	10.0f		/* fcmps #10.0	   */
#define FREE_TOP	0x1ffff		/* mfree ceiling	   */
#define RANGE_TOP	0x01000000UL	/* 24-bit code range	   */

static float  *m_freq;		/* freq[state*2+bit]		   */
static ULONG  *m_link;		/* link[state*2+bit]		   */
static ULONG   m_ctx;		/* current state (a4)		   */
static ULONG   m_free;		/* next clone slot (a5)		   */

/* re-initialise the whole model: 256 rows x 255 nodes.
 * row p occupies states p*256 .. p*256+254; inner states
 * (c<127) link to {a2+2c+1, a2+2c+2} in the same row; leaf
 * states (c>=127) link to {(c+1)<<8, (c-127)<<8}.	   */
static void model_init(void)
{
    float  *f = m_freq;
    ULONG  *lk = m_link;
    ULONG   a2 = 0;
    int     p, c;

    for (p = 0; p < 256; p++) {
	for (c = 0; c < 127; c++) {
	    f[2*c]   = 1.0f;
	    f[2*c+1] = 1.0f;
	    lk[2*c]   = a2 + 2*c + 1;
	    lk[2*c+1] = a2 + 2*c + 2;
	}
	for (c = 127; c < 255; c++) {
	    f[2*c]   = 1.0f;
	    f[2*c+1] = 1.0f;
	    lk[2*c]   = (ULONG)(c + 1)   << 8;
	    lk[2*c+1] = (ULONG)(c - 127) << 8;
	}
	f  += 512;
	lk += 512;
	a2 += 256;
    }
    m_ctx  = 0;
    m_free = 0x10000;
}

/* state update for one emitted bit (the original's 0x352 helper) */
static void update(ULONG bit)
{
    long double fp6 = (long double)m_freq[m_ctx*2 + bit];
    ULONG       tgt = m_link[m_ctx*2 + bit];

    if (fp6 >= CLONE_THRESH) {
	long double tot = (long double)m_freq[tgt*2]
			+ (long double)m_freq[tgt*2+1];
	if (tot - fp6 >= CLONE_THRESH) {
	    ULONG nw = ++m_free;
	    if (nw == FREE_TOP)
		model_init();		/* resets m_ctx/m_free */
	    {
		long double sc0 = (long double)m_freq[tgt*2]
				* fp6 / tot;
		long double sc1 = (long double)m_freq[tgt*2+1]
				* fp6 / tot;
		if (bit == 0) {
		    m_link[nw*2]   = nw;
		    m_link[nw*2+1] = m_link[tgt*2+1];
		} else {
		    m_link[nw*2]   = m_link[tgt*2];
		    m_link[nw*2+1] = nw;
		}
		m_freq[nw*2]   = (float)sc0;
		m_freq[nw*2+1] = (float)sc1;
		m_freq[tgt*2]   = (float)((long double)m_freq[tgt*2] - sc0);
		m_freq[tgt*2+1] = (float)((long double)m_freq[tgt*2+1] - sc1);
	    }
	}
    }
    {
	ULONG d1 = m_ctx*2 + bit;
	m_freq[d1] += 1.0f;
	m_ctx = m_link[d1];
    }
}

/* probability of bit==0 in the current state, 68881 extended */
static long double prob0(void)
{
    long double p0 = (long double)m_freq[m_ctx*2];
    long double tt = (long double)m_freq[m_ctx*2+1];
    tt += p0;
    return p0 / tt;
}

static APTR workmem_alloc(void)
{
    return __AllocMem(WORKMEM, MEMF_PUBLIC | MEMF_CLEAR);
}

/* ------------------------------------------------------------------ */
/* standard vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct DmcbBase *b __asm("a6"))
{
    b->b_Lib.lib_OpenCnt++;
    b->b_Flags &= ~8;
    return (struct Library *)b;
}

BPTR LibExpunge(struct DmcbBase *b __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (b->b_Lib.lib_OpenCnt) {
	b->b_Flags |= 8;
	return 0;
    }

    seg = b->b_SegList;
    __Remove(sys, &b->b_Lib.lib_Node);
    __FreeMem((UBYTE *)b - b->b_Lib.lib_NegSize,
	      (ULONG)b->b_Lib.lib_NegSize + b->b_Lib.lib_PosSize);
    return seg;
}

LONG LibClose(struct DmcbBase *b __asm("a6"))
{
    if (--b->b_Lib.lib_OpenCnt == 0) {
	if (b->b_Flags & 8)
	    return (LONG)LibExpunge(b);
    }
    return 0;
}

LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* public functions						  */
/* ------------------------------------------------------------------ */

extern const char xpkinfo[];

APTR XpksPackerInfo(void)
{
    return (APTR)xpkinfo;
}

/* -36 XpksPackChunk: DMC encoder				   */
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE  *wm = (UBYTE *)workmem_alloc();
    UBYTE  *src, *dst, *out, *bound;
    ULONG   len, hi, lo, byt;
    int     bit, b;

    if (!wm)
	return -7;

    m_freq = (float *)wm;
    m_link = (ULONG *)(wm + LINK_OFF);

    hi = 1;
    model_init();

    src = (UBYTE *)xsp->xsp_InBuf;
    lo  = 0;
    len = xsp->xsp_InLen;
    dst = (UBYTE *)xsp->xsp_OutBuf;
    out = dst;
    *(ULONG *)dst = len;
    out += 4;
    hi = RANGE_TOP;
    bound = out + len + 36;

    for (; len; len--) {
	byt = *src++;
	for (b = 7; b >= 0; b--) {
	    long double p0 = prob0();
	    ULONG   split;

	    bit = (int)((byt >> b) & 1);
	    update((ULONG)bit);
	    split = (ULONG)((long)((long double)(hi - lo - 1) * p0) + lo);
	    if (split == lo)
		split++;
	    if (split == hi - 1)
		split--;
	    if (!bit)
		hi = split;
	    else
		lo = split;
	    if (hi - lo < 256) {
		hi -= (ULONG)bit;
		*out++ = (UBYTE)((lo >> 16) & 0xff);
		if (out >= bound) {
		    __FreeMem(wm, WORKMEM);
		    return -17;
		}
		lo = (lo & 0xffff) << 8;
		hi = (hi & 0xffff) << 8;
		if (lo >= hi)
		    hi = RANGE_TOP;
	    }
	}
    }

    /* flush low in 3 bytes (bits 23..0, big-endian)	*/
    *out++ = (UBYTE)((lo >> 16) & 0xff);
    *out++ = (UBYTE)((lo >> 8)  & 0xff);
    *out++ = (UBYTE)( lo        & 0xff);

    xsp->xsp_OutLen = (ULONG)(out - dst);

    __FreeMem(wm, WORKMEM);
    return 0;
}

/* -54 XpksUnpackChunk: DMC decoder				   */
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
    UBYTE  *wm = (UBYTE *)workmem_alloc();
    UBYTE  *src, *out;
    ULONG   len, hi, lo, code, acc;
    int     bit, b;

    if (!wm)
	return -7;

    m_freq = (float *)wm;
    m_link = (ULONG *)(wm + LINK_OFF);

    src = (UBYTE *)xsp->xsp_InBuf;
    model_init();
    out = (UBYTE *)xsp->xsp_OutBuf;

    hi  = RANGE_TOP;
    len = *(ULONG *)src;
    src += 4;
    lo  = 0;
    code = ((ULONG)src[0] << 16) | ((ULONG)src[1] << 8) | src[2];
    src += 3;

    for (; len; len--) {
	acc = 0;
	for (b = 7; b >= 0; b--) {
	    long double p0 = prob0();
	    ULONG   split;

	    split = (ULONG)((long)((long double)(hi - lo - 1) * p0) + lo);
	    if (split == lo)
		split++;
	    if (split == hi - 1)
		split--;
	    if (code >= split) {
		lo = split;
		bit = 1;
	    } else {
		hi = split;
		bit = 0;
	    }
	    acc = (acc << 1) | (ULONG)bit;
	    update((ULONG)bit);
	    if (hi - lo < 256) {
		code = ((code & 0xffff) << 8) | *src++;
		hi -= (ULONG)bit;
		lo = (lo & 0xffff) << 8;
		hi = (hi & 0xffff) << 8;
		if (lo >= hi)
		    hi = RANGE_TOP;
	    }
	}
	*out++ = (UBYTE)acc;
    }

    __FreeMem(wm, WORKMEM);
    return 0;
}
