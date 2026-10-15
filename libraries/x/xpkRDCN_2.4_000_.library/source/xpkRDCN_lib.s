||||
||||	xpkRDCN_lib.s -- RomTag, init table, data table,
||||	descriptor and LibInit for dxpkRDCN.library 2.4.
|||||
||||	Reconstructed layout (original hunk offsets):
||||	  0x00  EndSkip (moveq #0,d0; rts)
||||	  0x04  RomTag 0x4afc / AUTOINIT, rt_Version 2
||||	  0x1e  "xpkRDCN.library"
||||	  0x2e  "$VER: xpkRDCN V2.4 (1 Oct 2013) by Niklas Sjoeberg"
||||	  0x64  init struct (dataSize 0x26, functab@0x94, datatab@0x74,
||||	        initfunc@0xac)
||||	  0x94  function table (word offsets, -1 marker + 10 entries)
||||	  0x5fe XpkInfo descriptor, mode chain, strings
||||	  0x6ec vestigial tail 72 00 00 08
||||

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
	.byte	2			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkRDCN.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkRDCN V2.4 (1 Oct 2013) by Niklas Sjoeberg"
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
	.byte	0x90,0x14		/* version = 2		    */
	.word	0x0002
	.byte	0x90,0x16		/* revision = 4		    */
	.word	0x0004
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	2			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "RDCN"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x5244434e		/* xi_ID = 'RDCN'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0xffdc			/* xi_DefPkInChunk	    */
	.long	0			/* xi_PackMsg		    */
	.long	0			/* xi_UnpackMsg		    */
	.long	0			/* xi_PackedMsg		    */
	.long	0			/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode0		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_mode0:
	.long	_s_mode1		/* xm_Next		    */
	.long	79			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x4004			/* xm_PackMemory		    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x83			/* xm_PackSpeed = 131	    */
	.long	0x1e0			/* xm_UnpackSpeed = 480	    */
	.word	0x0149			/* xm_Ratio = 329	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"speedy"
	.byte	0,0,0,0			/* name field padded to 10  */

_s_mode1:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x48004			/* xm_PackMemory		    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x27			/* xm_PackSpeed = 39	    */
	.long	0x1ef			/* xm_UnpackSpeed = 495	    */
	.word	0x018e			/* xm_Ratio = 398	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"crawling"
	.byte	0,0			/* name field padded to 10  */

_s_name:
	.ascii	"RDCN"
	.byte	0
_s_longname:
	.ascii	"Ross Data Compression V2.4"
	.byte	0
_s_basedesc:
	.ascii	"Very fast, but yet efficient packer"
	.byte	0

/*
|||	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
|||	Stores the seglist at base+34.
*/
	.even
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts
