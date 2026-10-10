/*
**	xpkDLTA.c -- xpkDLTA.library V0.1 "DELTA-Encryption
**	Routines (c) 1992 Stephan Fuhrmann".
**
**	C reconstruction of the shipped binary (960 bytes,
**	"$VER: xpkDLTA.library v0.1").
**
**	DLTA is an XPK chunk packer doing plain byte-delta
**	coding ("encryption" is marketing):
**	    pack:   out[0] = in[0]; out[i] = in[i] - in[i-1]
**	    unpack: out[0] = in[0]; out[i] = out[i-1] + in[i]
**	The transform is size-preserving (outlen = inlen).
**	Chunk-link state is carried in the caller's params:
**	xsp_Sub[0] = "continued" flag (input), xsp_Sub[1] =
**	last reconstructed byte (in/out).  With the flag set,
**	the first byte is treated as a delta from the saved
**	state instead of being copied raw.
**
**	The library base (dataSize 0xfc) embeds the XpkInfo at
**	+0x26 and XpkMode at +0x7e; every descriptor field is
**	written by the InitStruct stream except xi_ModeDesc,
**	which LibInit patches (see xpkDLTA_lib.s).
**
**	Shipped quirks (see okf/findings/):
**	  - empty input (inlen 0) falls into the dbf kernel
**	    with d2 = -2 and runs ~65k write iterations --
**	    a catastrophic overread/overwrite.  Guarded in
**	    the reconstruction;
**	  - dead code: word/long delta kernels at the hunk
**	    tail are unreachable from the functab (a planned
**	    multi-width "ByteMode" feature that was never
**	    wired up);
**	  - entry stub returns 0 (not -1 like most sublibs).
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
    ULONG xsp_Number;		/* 0x18 chunk number			   */
    ULONG xsp_Mode;		/* 0x1c packing mode			   */
    STRPTR xsp_Password;	/* 0x20					   */
    UWORD xsp_LibVersion;	/* 0x24					   */
    UWORD xsp_Pad;		/* 0x26					   */
    ULONG xsp_Arg[3];		/* 0x28					   */
    ULONG xsp_Sub[4];		/* 0x34 sublib private data		   */
};				/*  Sub[0] = continued flag (input)	   */
				/*  Sub[1] = running delta state (in/out)  */

struct XpkMode			/* 42 bytes -- xm_* at base+0x7e	   */
{
    APTR  xm_Next;		/* 0x00					   */
    ULONG xm_Upto;		/* 0x04 100 (InitStruct)		   */
    ULONG xm_Flags;		/* 0x08 0				   */
    ULONG xm_PackMemory;	/* 0x0c					   */
    ULONG xm_UnpackMemory;	/* 0x10					   */
    ULONG xm_PackSpeed;		/* 0x14					   */
    ULONG xm_UnpackSpeed;	/* 0x18					   */
    UWORD xm_Ratio;		/* 0x1c					   */
    UWORD xm_ChunkSize;		/* 0x1e					   */
    char  xm_Description[10];	/* 0x20 "ByteMode" (InitStruct)	   */
};				/* = 0x2a				   */

struct XpkInfo			/* 88 bytes -- xi_* at base+0x26	   */
{
    UWORD  xi_XpkInfoVersion;	/* 0x00 1				   */
    UWORD  xi_LibVersion;	/* 0x02 0 (v0.1!)			   */
    UWORD  xi_MasterVersion;	/* 0x04 1				   */
    UWORD  xi_ModesVersion;	/* 0x06 0				   */
    STRPTR xi_Name;		/* 0x08 "DLTA"			   */
    STRPTR xi_LongName;		/* 0x0c "DELTA v0.1"		   */
    STRPTR xi_Description;	/* 0x10				   */
    ULONG  xi_ID;		/* 0x14 'DLTA'			   */
    ULONG  xi_Flags;		/* 0x18 0x2000			   */
    ULONG  xi_MaxPkInChunk;	/* 0x1c 0x10000			   */
    ULONG  xi_MinPkInChunk;	/* 0x20 1				   */
    ULONG  xi_DefPkInChunk;	/* 0x24 0x10000			   */
    STRPTR xi_PackMsg;		/* 0x28 "Enciphering"		   */
    STRPTR xi_UnpackMsg;	/* 0x2c "Deciphering"		   */
    STRPTR xi_PackedMsg;	/* 0x30 "Enciphered"		   */
    STRPTR xi_UnpackedMsg;	/* 0x34 "Deciphered"		   */
    UWORD  xi_DefMode;		/* 0x38 100				   */
    UWORD  xi_Pad;		/* 0x3a					   */
    APTR   xi_ModeDesc;		/* 0x3c -> base+0x7e (LibInit)	   */
    ULONG  xi_Reserved[6];	/* 0x40					   */
};				/* = 0x58				   */

struct XpkSubBase		/* InitTable dataSize = 0xfc	   */
{
    struct Library xsb_Lib;	/* 0x00 standard library node	   */
    BPTR  xsb_SegList;		/* 0x22 seglist, stored by LibInit	   */
    struct XpkInfo xsb_Info;	/* 0x26 InitStruct-filled		   */
    struct XpkMode xsb_Mode;	/* 0x7e InitStruct-filled		   */
    UBYTE xsb_Priv[0x54];	/* 0xa8..0xfb reserved/unused	   */
};				/* = 0xfc				   */

/* ------------------------------------------------------------------ */
/* Exec LVO calls (via absolute SysBase at 4.W, as the original does) */
/* ------------------------------------------------------------------ */

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__sys, ___blk, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_blk __asm("a1") = (void *)(___blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile (\
		   "jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

/*
 * LibInit: store the seglist at +0x22 and patch the
 * xi_ModeDesc field (base+0x62) to point at the embedded
 * XpkMode (base+0x7e).  Everything else in the base is
 * already set up by the InitStruct stream.
 */
struct Library *LibInit(struct XpkSubBase *base __asm("d0"),
			BPTR seglist __asm("a0"))
{
    base->xsb_SegList = seglist;
    base->xsb_Info.xi_ModeDesc = (APTR)&base->xsb_Mode;

    return (struct Library *)base;
}

struct Library *LibOpen(struct XpkSubBase *base __asm("a6"))
{
    base->xsb_Lib.lib_OpenCnt++;
    base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;

    return (struct Library *)base;
}

/* cleanup hook: the shipped expunge calls an empty rts
 * before Remove -- a subclass/extension placeholder. */
static void SubCleanup(struct XpkSubBase *base)
{
}

BPTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->xsb_Lib.lib_OpenCnt) {
	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    SubCleanup(base);

    seg = base->xsb_SegList;
    __Remove(sys, &base->xsb_Lib.lib_Node);
    __FreeMem(sys, (UBYTE *)base - base->xsb_Lib.lib_NegSize,
	      (ULONG)base->xsb_Lib.lib_NegSize + base->xsb_Lib.lib_PosSize);

    return seg;
}

LONG LibClose(struct XpkSubBase *base __asm("a6"))
{
    if (--base->xsb_Lib.lib_OpenCnt == 0) {
	if (base->xsb_Lib.lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }

    return 0;
}

/* LibNull (LVO -24 and the unimplemented sublib slots) */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* sub-library functions						  */
/* ------------------------------------------------------------------ */

/* XpksPackerInfo (LVO -30): XpkInfo lives at base+0x26 */
APTR XpksPackerInfo(struct XpkSubBase *base __asm("a6"))
{
    return (APTR)&base->xsb_Info;
}

/*
**	XpksPackChunk (LVO -36)
**
**	Delta encoder, size-preserving:
**	  continued (xsp_Sub[0] != 0):
**	      every byte emitted as  in[i] - prev, starting
**	      from prev = xsp_Sub[1];
**	  fresh (xsp_Sub[0] == 0):
**	      first byte copied raw, then deltas.
**	Rolling state is kept as the reconstructed byte
**	(prev += delta) and written back to xsp_Sub[1].
**
**	Returns 0; -10 when inlen > outbuflen, -11 when
**	inlen > 0x10000.  Empty input returns 0 with
**	outlen 0 (the original would overrun the buffer --
**	see findings).
*/
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
		   struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    ULONG n = p->xsp_InLen;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    UBYTE prev;
    ULONG i;

    if (n > p->xsp_OutBufLen)
	return -10;			/* output too small  */
    if (n > 0x10000)
	return -11;			/* input too big     */

    p->xsp_OutLen = n;

    if (!n)
	return 0;			/* shipped code     */
					/* would loop ~64KB */

    if (!p->xsp_Sub[0]) {
	dst[0] = src[0];
	prev = src[0];
	i = 1;
    } else {
	prev = (UBYTE)p->xsp_Sub[1];
	i = 0;
    }

    for (; i < n; i++) {
	UBYTE delta = (UBYTE)(src[i] - prev);
	dst[i] = delta;
	prev = (UBYTE)(prev + delta);
    }

    p->xsp_Sub[1] = prev;
    return 0;
}

/*
**	XpksUnpackChunk (LVO -54)
**
**	Delta decoder, size-preserving:
**	  continued: every output byte = prev + in[i],
**	      starting from prev = xsp_Sub[1];
**	  fresh: first packed byte copied raw, then
**	      out[i] = out[i-1] + in[i].
**	Same guards and state handling as the encoder.
*/
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
    const UBYTE *src = (const UBYTE *)p->xsp_InBuf;
    ULONG n = p->xsp_InLen;
    UBYTE *dst = (UBYTE *)p->xsp_OutBuf;
    UBYTE prev;
    ULONG i;

    if (n > p->xsp_OutBufLen)
	return -10;
    if (n > 0x10000)
	return -11;

    p->xsp_OutLen = n;

    if (!n)
	return 0;

    if (!p->xsp_Sub[0]) {
	dst[0] = src[0];
	prev = src[0];
	i = 1;
    } else {
	prev = (UBYTE)p->xsp_Sub[1];
	i = 0;
    }

    for (; i < n; i++) {
	prev = (UBYTE)(prev + src[i]);
	dst[i] = prev;
    }

    p->xsp_Sub[1] = prev;
    return 0;
}

/* ------------------------------------------------------------------ */
/* dead code in the shipped binary -- word and long delta	  */
/* kernels at hunk tail, unreachable from any vector		  */
/* ------------------------------------------------------------------ */

/* 16-bit delta encode (orig hunk+0x2e0): count halved with
 * lsrl, movew in/out, subw/addw the running value. */
static void DeltaEncode16(const UWORD *src, UWORD *dst,
			  ULONG words, UWORD prev)
{
    ULONG i;
    for (i = 0; i < words; i++) {
	UWORD delta = (UWORD)(src[i] - prev);
	dst[i] = delta;
	prev = (UWORD)(prev + delta);
    }
}

/* 16-bit delta decode (orig hunk+0x2f2) */
static void DeltaDecode16(const UWORD *src, UWORD *dst,
			  ULONG words, UWORD prev)
{
    ULONG i;
    for (i = 0; i < words; i++) {
	prev = (UWORD)(prev + src[i]);
	dst[i] = prev;
    }
}

/* 32-bit delta encode (orig hunk+0x300): count quartered
 * with lsrl.  Note the shipped encode uses subw on the
 * low word but addl for the accumulator -- the decode
 * (hunk+0x312) uses addl only. */
static void DeltaEncode32(const ULONG *src, ULONG *dst,
			  ULONG longs, ULONG prev)
{
    ULONG i;
    for (i = 0; i < longs; i++) {
	ULONG delta = (ULONG)((UWORD)(src[i] - prev));
	dst[i] = delta;
	prev += delta;
    }
}

/* 32-bit delta decode (orig hunk+0x312) */
static void DeltaDecode32(const ULONG *src, ULONG *dst,
			  ULONG longs, ULONG prev)
{
    ULONG i;
    for (i = 0; i < longs; i++) {
	prev += src[i];
	dst[i] = prev;
    }
}
