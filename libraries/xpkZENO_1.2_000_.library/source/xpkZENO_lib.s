|||
|||	xpkZENO_lib.s -- resident/AutoInit structure, XPK info
|||	descriptor and LibInit for xpkZENO.library 1.2.
||||
||||	Reconstructed layout (original hunk offsets):
||||	  0x00  EndSkip (moveq #0,d0; rts)
||||	  0x04  RomTag 0x4afc / AUTOINIT
||||	  0x1e  "xpkZENO.library"
||||	  0x2e  "$VER: xpkZENO V1.2 (1 Oct 2013) by Gerhard Tuenkler"
||||	  0x64  init struct (dataSize 0x26, functab, datatab, initfunc)
||||	  0x74  data table
||||	  0x94  function table (word offsets, -1 marker + 10 entries)
||||	  0xac  LibInit (store seglist @34)
||||	  0x56a XpkInfo descriptor, mode chain, strings
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
	.ascii	"xpkZENO.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkZENO V1.2 (1 Oct 2013) by Gerhard Tuenkler"
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
	.long	_s_name			/* xi_Name "ZENO"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x5a454e4f		/* xi_ID = 'ZENO'	    */
	.long	0xa009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x8000			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode12		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_mode12:
	.long	_s_mode13		/* xm_Next		    */
	.long	33			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x7808			/* xm_PackMemory 5*(2^12+800h)+8 */
	.long	0x3004			/* xm_UnpackMemory 3*2^12+4 */
	.long	70			/* xm_PackSpeed	    */
	.long	155			/* xm_UnpackSpeed	    */
	.word	0x012d			/* xm_Ratio = 301	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"12 bit"
	.byte	0,0,0,0			/* name field padded to 10  */

_s_mode13:
	.long	_s_mode14		/* xm_Next		    */
	.long	66			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0xc808			/* xm_PackMemory 5*(2^13+800h)+8 */
	.long	0x6004			/* xm_UnpackMemory 3*2^13+4 */
	.long	74			/* xm_PackSpeed	    */
	.long	155			/* xm_UnpackSpeed	    */
	.word	0x0149			/* xm_Ratio = 329	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"13 bit"
	.byte	0,0,0,0

_s_mode14:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x16808			/* xm_PackMemory 5*(2^14+800h)+8 */
	.long	0xc004			/* xm_UnpackMemory 3*2^14+4 */
	.long	81			/* xm_PackSpeed	    */
	.long	155			/* xm_UnpackSpeed	    */
	.word	0x014e			/* xm_Ratio = 334	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"14 bit"
	.byte	0,0,0,0

_s_name:
	.ascii	"ZENO"
	.byte	0
_s_longname:
	.ascii	"ZENO V1.2"
	.byte	0
_s_basedesc:
	.ascii	"LZW 12-14 bit"
	.byte	0
_s_packmsg:
	.ascii	"Compressing"
	.byte	0
_s_unpackmsg:
	.ascii	"Expanding"
	.byte	0
_s_packedmsg:
	.ascii	"Compressed"
	.byte	0
_s_unpackedmsg:
	.ascii	"Expanded"
	.byte	0
	.byte	0

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
