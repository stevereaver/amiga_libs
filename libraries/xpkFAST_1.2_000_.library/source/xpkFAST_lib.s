|||
|||	xpkFAST_lib.s -- RomTag, init table, data table,
|||	descriptor and LibInit for xpkFAST.library 1.2.
||||
||||	Reconstructed layout (original hunk offsets):
||||	  0x00  EndSkip (moveq #0,d0; rts)
||||	  0x04  RomTag 0x4afc / AUTOINIT
||||	  0x1e  "xpkFAST.library"
||||	  0x2e  "$VER: xpkFAST V1.2 (1 Oct 2013) by Christian von Roques"
||||	  0x68  init struct (dataSize 0x26, functab, datatab, initfunc)
||||	  0x78  data table
||||	  0x98  function table (word offsets, -1 marker + 10 entries)
||||	  0xb0  LibInit (store seglist @34)
||||	  0x57e XpkInfo descriptor, mode chain, strings
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
	.long	_start			/* EndSkip -> moveq/rts stub	    */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkFAST.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkFAST V1.2 (1 Oct 2013) by Christian von Roques"
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
	.byte	0x90,0x16		/* revision = 2		    */
	.word	0x0002
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "fasTcinator"    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x46415354		/* xi_ID = 'FAST'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x10000			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg "Tieing"	    */
	.long	_s_unpackmsg		/* xi_UnpackMsg -> "Compressed"(!) */
	.long	_s_packedmsg		/* xi_PackedMsg -> "Untieing"(!)   */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg "Decompressed" */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode0		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_mode0:
	.long	_s_mode1		/* xm_Next		    */
	.long	79			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x10004			/* xm_PackMemory		    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x91			/* xm_PackSpeed = 145	    */
	.long	0x2e4			/* xm_UnpackSpeed = 740	    */
	.word	0x0157			/* xm_Ratio = 343	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"speedy"
	.byte	0,0,0,0			/* name field padded to 10  */

_s_mode1:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x44004			/* xm_PackMemory		    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x37			/* xm_PackSpeed = 55	    */
	.long	0x2e4			/* xm_UnpackSpeed = 740	    */
	.word	0x0189			/* xm_Ratio = 393	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"crawling"
	.byte	0,0			/* name field padded to 10  */

_s_name:
	.ascii	"fasTcinator"
	.byte	0
_s_longname:
	.ascii	"FAST V1.2 alias WOOP or LZRW++"
	.byte	0
_s_basedesc:
	.ascii	"LZ77-family, windowsize: 4095, no quotecount, 2 streams"
	.byte	0
_s_packmsg:
	.ascii	"Tieing"
	.byte	0
_s_unpackmsg:
	.ascii	"Compressed"		/* stored middle strings swapped */
	.byte	0
_s_packedmsg:
	.ascii	"Untieing"
	.byte	0
_s_unpackedmsg:
	.ascii	"Decompressed"
	.byte	0
	.byte	0,0x21,0xe2,0x34	/* vestigial tail bytes	    */

/*
||	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
||	Stores the seglist at base+34.
*/
	.even
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts
