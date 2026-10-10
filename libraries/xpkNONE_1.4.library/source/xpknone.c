/*
 * xpknone.c -- C reconstruction of xpkNONE.library 1.4 (19.07.1998)
 *
 * XPK "store" sublibrary: a dummy packer that performs no compression.
 * Four standard system vectors plus the XPK sublibrary interface:
 * XpksPackerInfo (-30), XpksPackChunk (-36, always fails with
 * XPKERR_EXPANSION) and XpksUnpackChunk (-54, a plain CopyMem).
 * The remaining slots (-42 PackFree, -48 PackReset, -60 UnpackFree)
 * share the null stub with the reserved vector (-24).
 *
 * Quirks of the original reproduced here:
 *  - LibInit calls its own reserved null stub and treats a nonzero
 *    result as init failure (dead code -- the stub always returns 0).
 *  - LibExpunge sets LIBF_DELEXP unconditionally before testing
 *    lib_OpenCnt.
 *  - The IdString has no "$VER:" cookie.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include "xpkbase.h"

APTR LibNull(void);

/* InitVector: d0 = library base, a0 = seglist, a6 = SysBase */
struct XpkSubBase *LibInit(struct XpkSubBase *base __asm("d0"),
			   BPTR seglist __asm("a0"),
			   struct ExecBase *sysbase __asm("a6"))
{
	base->xsb_SegList = seglist;
	base->xsb_SysBase = sysbase;

	/* the original BSRs its reserved stub and frees the base on a
	 * nonzero result; the stub is moveq #0/rts, so this never fires */
	if (LibNull() != NULL) {
		__FreeMem_base(sysbase,
			       (UBYTE *)base - base->xsb_Lib.lib_NegSize,
			       (ULONG)base->xsb_Lib.lib_NegSize +
			       base->xsb_Lib.lib_PosSize);
		return NULL;
	}
	return base;
}

/* LibOpen (LVO -6): clear deferred expunge, bump open count, return base */
struct XpkSubBase *LibOpen(struct XpkSubBase *base __asm("a6"))
{
	base->xsb_Lib.lib_Flags &= ~LIBF_DELEXP;
	base->xsb_Lib.lib_OpenCnt++;
	return base;
}

APTR LibExpunge(struct XpkSubBase *base __asm("a6"));

/* LibClose (LVO -12): decrement open count; expunge if deferred */
APTR LibClose(struct XpkSubBase *base __asm("a6"))
{
	if (--base->xsb_Lib.lib_OpenCnt == 0 &&
	    (base->xsb_Lib.lib_Flags & LIBF_DELEXP))
		return LibExpunge(base);
	return NULL;
}

/*
 * LibExpunge (LVO -18): the original sets LIBF_DELEXP unconditionally,
 * *then* tests lib_OpenCnt; when open it returns 0.  Otherwise Remove()
 * the node, free the base block (NegSize + PosSize as word reads),
 * return the seglist.  SysBase comes from the base, not 4.w.
 */
APTR LibExpunge(struct XpkSubBase *base __asm("a6"))
{
	APTR            seglist = NULL;
	struct ExecBase *sysbase;

	base->xsb_Lib.lib_Flags |= LIBF_DELEXP;
	if (base->xsb_Lib.lib_OpenCnt != 0)
		return NULL;

	sysbase = base->xsb_SysBase;
	__Remove_base(sysbase, (struct Node *)base);

	seglist = (APTR)(ULONG)base->xsb_SegList;
	__FreeMem_base(sysbase,
		       (UBYTE *)base - base->xsb_Lib.lib_NegSize,
		       (ULONG)base->xsb_Lib.lib_NegSize +
		       base->xsb_Lib.lib_PosSize);

	return seglist;
}

/* LibNull (LVO -24, -42, -48, -60 shared stub): always returns 0 */
APTR LibNull(void)
{
	return NULL;
}

/*
 * Packer info block as stored in the original (mode descriptor followed
 * by the XpkInfo struct -- the two are adjacent in the code hunk).
 */
static const struct XpkMode _xpkmode = {
	NULL,		/* xm_Next */
	100,		/* xm_Upto */
	1,		/* xm_Flags */
	0,		/* xm_PackMemory */
	0,		/* xm_UnpackMemory */
	1918,		/* xm_PackSpeed K/s */
	2477,		/* xm_UnpackSpeed K/s */
	0,		/* xm_Ratio (no compression) */
	0,		/* xm_ChunkSize */
	"normal"	/* xm_Description[10] */
};

static const struct XpkInfo _xpkinfo = {
	0,				/* xi_XpkInfoVersion */
	1,				/* xi_LibVersion */
	1,				/* xi_MasterVersion */
	0,				/* xi_ModesVersion */
	"NONE",				/* xi_Name */
	"NoPacker",			/* xi_LongName */
	"A dummy library that does no compression",
	0x4e4f4e45,			/* xi_ID = 'NONE' */
	9,				/* xi_Flags: chunk pack+unpack */
	0x8000,				/* xi_MaxPkInChunk */
	0x14,				/* xi_MinPkInChunk */
	0x8000,				/* xi_DefPkInChunk */
	"Writing",			/* xi_PackMsg */
	"Reading",			/* xi_UnpackMsg */
	"Wrote",			/* xi_PackedMsg */
	"Read",				/* xi_UnpackedMsg */
	0x32,				/* xi_DefMode */
	0,				/* xi_Pad */
	&_xpkmode,			/* xi_ModeDesc */
	{ 0, 0, 0, 0, 0, 0 }		/* xi_Reserved */
};

/* XpksPackerInfo (LVO -30): return the static XpkInfo descriptor */
const struct XpkInfo *XpksPackerInfo(void)
{
	return &_xpkinfo;
}

/*
 * XpksPackChunk (LVO -36): always returns XPKERR_EXPANSION (-17) --
 * "packing" raw data can only expand it, so this sublib never packs;
 * xpkmaster stores the chunk itself.
 */
LONG XpksPackChunk(void)
{
	return XPKERR_EXPANSION;
}

/*
 * XpksUnpackChunk (LVO -54): a stored chunk unpacks by copy.
 * Copies xsp_InBuf -> xsp_OutBuf for xsp_InLen bytes, writes
 * xsp_OutLen = xsp_InLen, returns XPKERR_OK (0).
 */
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     struct XpkSubBase *base __asm("a6"))
{
	ULONG len = xsp->xsp_InLen;

	xsp->xsp_OutLen = len;
	__CopyMem_base(base->xsb_SysBase, xsp->xsp_InBuf, xsp->xsp_OutBuf,
		       len);
	return XPKERR_OK;
}
