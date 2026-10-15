	.file	"xpkSMPL_lib.s"
	.text

/*
**	xpkSMPL_lib.s -- resident module header for
**	xpkSMPL.library 1.2 "Sample Huffman V1.2" (Jorma Oksanen).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub; packed
**	RomTag (RTF_AUTOINIT, ver 1, NT_LIBRARY); InitTable with
**	dataSize 0x26 and a word-offset FUNCTABLE (genfunctab.py);
**	LibInit stores the seglist at base+34.
**
**	Hunk map of the original (offset -> contents):
**	  0x00  moveq #0,d0 / rts
**	  0x04  RomTag / strings ("xpkSMPL.library", $VER)
**	  0x62  InitTable (dataSize 0x26)
**	  0x72  datatab
**	  0x92  functab: ffff marker, 10 word offsets, ffff
**	  0xaa  LibInit (store seglist @34)
**	  0xb2  Open/Close/Expunge/PackFree/PackerInfo
**	  0x130 -36 pack: delta histogram -> sorted-list Huffman ->
**	        nibble len table + code emit
**	  0x390 -54 unpack: len table -> 4B trie -> 1024-entry
**	        10-bit fast table -> delta decode
**	  0x532 XpkInfo + XpkMode "dynamic" + strings
*/

	.globl	_start
_start:
	moveq	#0,%d0
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
_idstr:
	.ascii	"$VER: xpkSMPL V1.2 (1 Oct 2013) by Jorma Oksanen"
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
	.byte	0x90,0x16		/* revision = 2	    */
	.word	0x0002
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
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "Huffman"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x534d504c		/* xi_ID = 'SMPL'	    */
	.long	9			/* xi_Flags		    */
	.long	0xfffe			/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0xfffe			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
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
	.long	0x3208			/* xm_PackMemory	    */
	.long	0x1004			/* xm_UnpackMemory	    */
	.long	0x62			/* xm_PackSpeed	    */
	.long	0xc7			/* xm_UnpackSpeed	    */
	.word	0x58			/* xm_Ratio = 88	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"dynamic"
	.byte	0,0,0,0

_s_name:
	.ascii	"Huffman"
	.byte	0,0,0,0
_s_longname:
	.ascii	"Sample Huffman V1.2"
	.byte	0
_s_basedesc:
	.ascii	"Dynamic Huffman Compression with delta precoding"
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
