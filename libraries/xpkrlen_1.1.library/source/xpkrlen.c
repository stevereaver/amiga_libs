/*
**	xpkrlen.c -- xpkRLEN.library V1.0/1.1 "Run Length"
**
**	C reconstruction of the shipped SAS/C-built binary
**	(xpkRLEN, RLEN 1.1, Nov 2 1992).  XPK sublibrary: a
**	byte-run RLE with a single count byte per token:
**
**	    stream = { token }* 00
**	    token  = n(>0)   + n literal bytes	  literal run
**	    token  = n(<0)   + byte		  byte run (-n times)
**	    token  = 0				  terminator
**
**	The packer scans for 3-in-a-row to start a run, flushes
**	pending literals when a run starts / 127 literals accrue /
**	input ends, and caps runs at 127.  Literal emit reserves
**	4 output bytes of headroom (count + terminator slack).
**
**	Shipped behaviour kept:
**	  - the 3-in-a-row lookahead reads in[cur+1]/in[cur+2]
**	    unconditionally -- past InLen at the tail (values
**	    only gate the run branch)
**	  - literal flush writes the count THEN checks the
**	    4-byte headroom -- the count is already stored
**	    when -17 could fire (it can't: headroom checked
**	    before, but the run emit writes 2 unchecked bytes)
**	  - run emit (-count,byte) has NO bound check at all
**	  - unpacker has NO bound check; negative->replicate,
**	    0->stop, writes nothing about outlen
**	  - PackFree/PackReset/UnpackFree are stubs; the
**	    original returns d0-untouched (here 0 -- no
**	    observable difference)
**
**	The library is a two-hunk SAS/C build: xpkrlen_lib.s
**	carries the DATA-hunk template that INITFUNCTION copies
**	to base+58 and relocates; XpksPackerInfo returns
**	base+224 (the XpkInfo inside the copied block).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

struct XpkSubParams		/* argument block for the codec LVOs   */
{
    APTR  xsp_InBuf;		/* 0x00 input data			   */
    ULONG xsp_InLen;		/* 0x04 input length			   */
    APTR  xsp_OutBuf;		/* 0x08 output buffer			   */
    ULONG xsp_OutBufLen;	/* 0x0c output buffer size		   */
    ULONG xsp_OutLen;		/* 0x10 bytes produced (result)	   */
    ULONG xsp_Flags;		/* 0x14					   */
    ULONG xsp_Number;		/* 0x18					   */
    ULONG xsp_Mode;		/* 0x1c					   */
    STRPTR xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Arg[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34					   */
};

/* base is 0x13a bytes: Library(0x22)+seglist(4)+gap(0x14)
** +template(0x100) copied by INITFUNCTION to base+58 */
struct RLENBase
{
    struct Library rb_Lib;	/* 0x00 standard library node	   */
    BPTR  rb_SegList;		/* 0x22 seglist, stored by init	   */
    UBYTE rb_Gap[0x14];		/* 0x26 unused			   */
    UBYTE rb_Template[0x100];	/* 0x3a copied template (descr)  */
};

/* ------------------------------------------------------------------ */
/* Exec LVO calls (via absolute SysBase at 4.W, as the original does) */
/* ------------------------------------------------------------------ */

#define SYSBASE	(*(struct ExecBase **)4)

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct RLENBase *base __asm("a6"))
{
    base->rb_Lib.lib_OpenCnt++;
    base->rb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

BPTR LibExpunge(struct RLENBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->rb_Lib.lib_OpenCnt) {
	base->rb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->rb_SegList;
    __Remove(sys, &base->rb_Lib.lib_Node);
    __FreeMem((UBYTE *)base - base->rb_Lib.lib_NegSize,
	      (ULONG)base->rb_Lib.lib_NegSize + base->rb_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct RLENBase *base __asm("a6"))
{
    if (--base->rb_Lib.lib_OpenCnt == 0) {
	if (base->rb_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/* XpksPackerInfo (LVO -30): returns the XpkInfo inside the
 * template block INITFUNCTION copies to base+58 (+166) */
APTR XpksPackerInfo(struct RLENBase *base __asm("a6"))
{
    return (APTR)((UBYTE *)base + 58 + 166);
}

/*
**	XpksPackChunk (LVO -36) -- RLE packer.
**
**	  cur = scan cursor, lit = literal-flush cursor.
**	  3-in-a-row starts a run; flush literals on run /
**	  127-literal bound / input end; runs cap at 127.
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct RLENBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *end = in + p->xsp_InLen;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    UBYTE *cap = out + p->xsp_OutBufLen;
    UBYTE *cur = in, *lit = in;

    for (;;) {
	LONG run = (cur[1] == cur[0] && cur[2] == cur[0]);
	LONG n   = (LONG)(cur - lit);

	if (out + n + 4 > cap)		/* headroom check  */
	    return -17;

	if (run || n == 127 || cur == end) {
	    if (n) {			/* flush literals  */
		*out++ = (UBYTE)n;
		while (n--)
		    *out++ = *lit++;
	    }
	    if (cur == end) {		/* terminator      */
		*out++ = 0;
		break;
	    }
	    lit = cur;
	}

	if (run) {			/* emit the run    */
	    LONG rl = 3;
	    /* extend while in[cur+rl] equals its predecessor
	     * (a contiguous equal-byte run), capped at 127  */
	    for (;;) {
		UBYTE *a2 = cur + rl;
		if (a2 >= end || a2[-1] != a2[0] || rl >= 127)
		    break;
		rl++;
	    }
	    out[0] = (UBYTE)(-rl);	/* -count          */
	    out[1] = *cur;		/* byte            */
	    out += 2;
	    lit = cur + rl;		/* literal cursor  */
	    cur = lit;			/* scan = run end  */
	} else {
	    cur++;
	}
    }

    p->xsp_OutLen = (ULONG)(out - (UBYTE *)p->xsp_OutBuf);
    return 0;
}

/* XpksPackFree (LVO -42): stub -- original returns d0
 * unchanged; 0 is observably identical to the host.     */
LONG XpksPackFree(struct XpkSubParams *p __asm("a0"),
		  struct RLENBase *base __asm("a6"))
{
    return 0;
}

/* XpksPackReset (LVO -48): stub (original returns 0).     */
LONG XpksPackReset(struct XpkSubParams *p __asm("a0"),
		   struct RLENBase *base __asm("a6"))
{
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54) -- RLE decoder.
**
**	  count>0 -> copy that many literals
**	  count<0 -> replicate the next byte -count times
**	  count=0 -> stop.  No bound check, no OutLen store.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct RLENBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    LONG   c;

    while ((c = (BYTE)*in++) != 0) {
	if (c > 0) {
	    while (c--)
		*out++ = *in++;
	} else {
	    UBYTE b = *in++;
	    c = -c;
	    while (c--)
		*out++ = b;
	}
    }
    return 0;
}

/* XpksUnpackFree (LVO -60): stub like PackFree.          */
LONG XpksUnpackFree(struct XpkSubParams *p __asm("a0"),
		    struct RLENBase *base __asm("a6"))
{
    return 0;
}
