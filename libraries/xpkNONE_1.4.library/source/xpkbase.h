#ifndef XPKBASE_H
#define XPKBASE_H

#include <exec/types.h>
#include <exec/libraries.h>

/*
 * Private library base for xpkNONE.library 1.4.
 * InitTable dataSize = 0x2a (42): struct Library (34) + SegList + SysBase.
 * Unlike the fwfiltertype skeleton, SysBase is kept in the base --
 * Expunge and XpksUnpackChunk use it instead of reading 4.w.
 */
struct XpkSubBase {
	struct Library	xsb_Lib;	/* 0x00..0x21 */
	BPTR		xsb_SegList;	/* 0x22, stored by LibInit,
					   returned by Expunge */
	struct ExecBase *xsb_SysBase;	/* 0x26, stored by LibInit */
};

/*
 * XPK sublibrary LVOs (from the XPK developer archive,
 * Include/ASM/lvo/xpksub_lib.i).
 */
#define LVOXpksPackerInfo	(-30)
#define LVOXpksPackChunk	(-36)
#define LVOXpksPackFree		(-42)
#define LVOXpksPackReset	(-48)
#define LVOXpksUnpackChunk	(-54)
#define LVOXpksUnpackFree	(-60)

#define XPKERR_OK		0
#define XPKERR_EXPANSION	(-17)	/* would have caused data expansion */

/*
 * Chunk parameters for XpksPackChunk/XpksUnpackChunk (XpkSubParams ABI:
 * InBuf @0, InLen @4, OutBuf @8, OutBufLen @12, OutLen @16 -- the first
 * five fields are the only ones this sublibrary touches).
 */
struct XpkSubParams {
	APTR	xsp_InBuf;
	ULONG	xsp_InLen;
	APTR	xsp_OutBuf;
	ULONG	xsp_OutBufLen;
	ULONG	xsp_OutLen;
};

/*
 * XPK mode descriptor (XpkMode ABI) and packer info (XpkInfo ABI)
 * as returned by XpksPackerInfo.
 */
struct XpkMode {
	struct XpkMode *xm_Next;
	ULONG	xm_Upto;		/* mode range covered (0..100) */
	ULONG	xm_Flags;
	ULONG	xm_PackMemory;
	ULONG	xm_UnpackMemory;
	ULONG	xm_PackSpeed;		/* K per second */
	ULONG	xm_UnpackSpeed;
	UWORD	xm_Ratio;		/* compression factor in 0.1% */
	UWORD	xm_ChunkSize;		/* desired chunk size in K */
	UBYTE	xm_Description[10];
};

struct XpkInfo {
	UWORD	xi_XpkInfoVersion;
	UWORD	xi_LibVersion;
	UWORD	xi_MasterVersion;
	UWORD	xi_ModesVersion;
	STRPTR	xi_Name;
	STRPTR	xi_LongName;
	STRPTR	xi_Description;
	ULONG	xi_ID;			/* four-char packer id, 'NONE' */
	ULONG	xi_Flags;		/* 9 = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK */
	ULONG	xi_MaxPkInChunk;
	ULONG	xi_MinPkInChunk;
	ULONG	xi_DefPkInChunk;
	STRPTR	xi_PackMsg;
	STRPTR	xi_UnpackMsg;
	STRPTR	xi_PackedMsg;
	STRPTR	xi_UnpackedMsg;
	UWORD	xi_DefMode;
	UWORD	xi_Pad;
	struct XpkMode *xi_ModeDesc;
	ULONG	xi_Reserved[6];
};

#endif
