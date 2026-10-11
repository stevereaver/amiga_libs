	.file	"xpkHFMN_lib.s"
	.text

/*
**	xpkHFMN_lib.s -- resident module header for
**	xpkHFMN.library 1.4 "Huffman 020+ V1.4" (1 Oct 2013).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub (also the
**	init-fail return and the -24 vector target via a negative
**	offset); packed RomTag (RTF_AUTOINIT, ver 1, NT_LIBRARY);
**	InitTable with dataSize 0x26 and a word-offset FUNCTABLE
**	(genfunctab.py); LibInit stores the seglist at base+34 and
**	requires AttnFlags bit 1 (68020) -- otherwise branches back
**	to the entry stub which returns 0.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 entry stub (moveq #0,rts; off -0x92)
**	  -12 Close          -30 XpksPackerInfo
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 XpksPackReset (workmem wipe)
**	                     -54 XpksUnpackChunk
**	                     -60 XpksUnpackFree (== PackFree)
*/

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_start			/* rt_EndSkip -> hunk+0 (sic) */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkHFMN.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkHFMN V1.4 (1 Oct 2013) by Martin Hauner"
	.byte	13,10,0
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
	.byte	0x90,0x16		/* revision = 4		    */
	.word	0x0004
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.even

/* ------------------------------------------------------------------ */
/* static XpkInfo descriptor (XpksPackerInfo returns its address)	    */
/* ------------------------------------------------------------------ */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x48464d4e		/* xi_ID = 'HFMN'	    */
	.long	9			/* xi_Flags		    */
	.long	0xfffe			/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0xfffe			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* XpkMode "dynamic": verbatim fields from the original. */
_s_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x1a0e			/* xm_PackMemory	    */
	.long	0x1004			/* xm_UnpackMemory	    */
	.long	0x9d			/* xm_PackSpeed	    */
	.long	0x133			/* xm_UnpackSpeed	    */
	.word	0xf7			/* xm_Ratio = 247	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"dynamic"
	.byte	0,0,0

_s_name:
	.ascii	"Huffman"
	.byte	0
_s_longname:
	.ascii	"Huffman 020+ V1.4"
	.byte	0
_s_basedesc:
	.ascii	"Fast Dynamic Huffman Statistic Compression"
	.byte	0
_s_packmsg:
	.ascii	"Coding"
	.byte	0
_s_unpackmsg:
	.ascii	"Decoding"
	.byte	0
_s_packedmsg:
	.ascii	"Coded"
	.byte	0
_s_unpackedmsg:
	.ascii	"Decoded"
	.byte	0,0,0,0

/*
**	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
**	Stores the seglist at base+34, then requires a 68020
**	(AttnFlags & AFB_68020); on older CPUs it branches back to
**	the entry stub which returns d0=0, failing the init.
*/
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	moveal	4:w,%a0
	btst	#1,%a0@(297)		/* AttnFlags bit AFB_68020  */
	beq	_start
	rts
