||
|||	xpkHUFF_lib.s -- resident/AutoInit structure, XPK info
|||	descriptor and LibInit for xpkHUFF.library 1.0.
|||
|||	Reconstructed layout (original hunk offsets):
|||	  0x00  EndSkip (moveq #0,d0; rts)
|||	  0x04  RomTag 0x4afc / AUTOINIT
|||	  0x1e  "xpkHUFF.library"
|||	  0x2e  "$VER: xpkHUFF V1.0 (1 Oct 2013) by Marc Zimmerman"
|||	  0x62  init struct (dataSize 0x26, functab, datatab, initfunc)
|||	  0x72  data table
|||	  0x92  function table (word offsets, -1 marker + 10 entries)
|||	  0xaa  LibInit (store seglist @34)
|||

	.section .text

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
	.ascii	"xpkHUFF.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkHUFF V1.0 (1 Oct 2013) by Marc Zimmerman"
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
	.byte	0x90,0x16		/* revision = 0		    */
	.word	0x0000
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "Huffman"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x48554646		/* xi_ID = 'HUFF'	    */
	.long	0x2009			/* xi_Flags (0x2000 = pw?)  */
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

_s_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x3208			/* xm_PackMemory	    */
	.long	0x1004			/* xm_UnpackMemory	    */
	.long	0x67			/* xm_PackSpeed = 103	    */
	.long	0xbf			/* xm_UnpackSpeed = 191	    */
	.word	0xf1			/* xm_Ratio = 241	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"dynamic"
	.byte	0

_s_name:
	.ascii	"Huffman"
	.byte	0
_s_longname:
	.ascii	"Huffman V1.0"
	.byte	0
_s_basedesc:
	.ascii	"Dynamic Huffman Statistic Compression"
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
	.byte	0x21			/* trailing '!' byte	    */

/*
**	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
**	Stores the seglist at base+34.
*/
	.even
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts
