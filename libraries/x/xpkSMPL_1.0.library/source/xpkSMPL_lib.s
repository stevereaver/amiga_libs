	.file	"xpkSMPL_lib.s"
	.text

/*
**	xpkSMPL_lib.s -- resident module header for
**	xpkSMPL.library 1.0 "Sample packer 1.0" (1.11.93).
**
**	Single code hunk; "moveq #-1,d0 / rts" entry stub; packed
**	RomTag (RTF_AUTOINIT, ver 1, NT_LIBRARY); InitTable with
**	dataSize 0x26 and a word-offset FUNCTABLE (genfunctab.py);
**	LibInit stores the seglist at base+34.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 LibNull (moveq #0,d0/rts stub)
**	  -12 Close          -30 XpksPackerInfo
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 XpksPackReset (bare rts)
**	                     -54 XpksUnpackChunk
**	                     -60 XpksUnpackFree (== PackFree)
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endmodule
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkSMPL.library"
	.byte	0
	.ascii	"$VER: "
_idstr:
	.ascii	"xpkSMPL.library 1.0 (1.11.93)"
	.byte	10,13,0
	.even

	.globl	_inittab
_inittab:
	.long	0x26			/* dataSize 38: Library+seg@34 */
	.long	_functab
	.long	_datatab
	.long	_LibInit

_datatab:
	.byte	0xa0,0x08		/* ln_Type = 9		    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 1		    */
	.word	0x0001
	.byte	0x90,0x16		/* revision = 0		    */
	.word	0x0000
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00

/* ------------------------------------------------------------------ */
/* static XpkInfo descriptor (XpksPackerInfo returns its address)	    */
/* ------------------------------------------------------------------ */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	0			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "SMPL"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x534d504c		/* xi_ID = 'SMPL'	    */
	.long	9			/* xi_Flags		    */
	.long	0xfffe			/* xi_MaxPkInChunk	    */
	.long	0x200			/* xi_MinPkInChunk	    */
	.long	0xfffe			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_s_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* XpkMode "normal": verbatim fields from the original. */
_s_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x3710			/* xm_PackMemory	    */
	.long	0x1000			/* xm_UnpackMemory	    */
	.long	0x97			/* xm_PackSpeed	    */
	.long	0x162			/* xm_UnpackSpeed	    */
	.word	0x43			/* xm_Ratio = 67	    */
	.word	0x3f			/* xm_ChunkSize = 63	    */
	.ascii	"normal"
	.byte	0
	.even

_s_name:
	.ascii	"SMPL"
	.byte	0
_s_longname:
	.ascii	"Sample packer 1.0"
	.byte	0
_s_basedesc:
	.ascii	"Dynamic huffman crunch algorithm with delta precoding"
	.byte	0
_s_packmsg:
	.ascii	"Crunching"
	.byte	0
_s_unpackmsg:
	.ascii	"Decrunching"
	.byte	0
_s_packedmsg:
	.ascii	"Crunched"
	.byte	0
_s_unpackedmsg:
	.ascii	"Decrunched"
	.byte	0
	.even				/* LibInit must be word-aligned */

/*
**	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
**	Stores the seglist at base+34.
*/
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts

/* -24 dedicated null stub (the hunk-0 stub returns -1 in 1.0) */
	.globl	_LibNull
_LibNull:
	moveq	#0,%d0
	rts

/* -48 PackReset: bare rts in the original */
	.globl	_XpksPackReset
_XpksPackReset:
	rts
