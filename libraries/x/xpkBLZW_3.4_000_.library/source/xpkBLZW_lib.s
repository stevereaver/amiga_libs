||||
||||	xpkBLZW_lib.s -- RomTag, init table, data table,
||||	descriptor and LibInit for xpkBLZW.library 3.4.
|||||
||||	Reconstructed layout (original hunk offsets):
||||	  0x00  EndSkip (moveq #0,d0; rts)
||||	  0x04  RomTag 0x4afc, rt_EndSkip = 0 (literal)
||||	  0x1e  "xpkBLZW.library"
||||	  0x2e  "$VER: xpkBLZW V3.4 (1 Oct 2013) by Bryan Ford"
||||	  0x5e  init struct (dataSize 0x26, functab@0x8e, datatab@0x6e,
||||	        initfunc)
||||	  0x6e  data table (AUTOINIT)
||||	  0x8e  function table (word offsets, -1 marker + 10 entries)
||||	  0x4d2 XpkInfo descriptor, mode chain (9..15 bits), strings
||||	  0x6ec tail long 0x18
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
	.long	0			/* EndSkip: literal 0	    */
	.byte	0x80			/* RTF_COLDSTART	    */
	.byte	3			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkBLZW.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkBLZW V3.4 (1 Oct 2013) by Bryan Ford"
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
	.byte	0x90,0x14		/* version = 3		    */
	.word	0x0003
	.byte	0x90,0x16		/* revision = 4		    */
	.word	0x0004
	.byte	0x80,0x18		/* lib_IdString		    */
	.long	_idstr
	.byte	0,0,0,0		/* terminator		    */

||||	functab is emitted by genfunctab.py on pass 2;
||||	functab_stub.s provides the placeholder for pass 1.

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	3			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "BLZW"	    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x424c5a57		/* xi_ID = 'BLZW'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x00020000		/* xi_DefPkInChunk = 128K   */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode0		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_mode0:
	.long	_s_mode1		/* xm_Next		    */
	.long	14			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x00000f06		/* xm_PackMemory	  641*6 */
	.long	0x00000800		/* xm_UnpackMemory	  4<<9  */
	.long	100			/* xm_PackSpeed		    */
	.long	182			/* xm_UnpackSpeed	    */
	.word	0x00f3			/* xm_Ratio		    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"9 bits"
	.byte	0,0,0,0

_s_mode1:
	.long	_s_mode2
	.long	28
	.long	1
	.long	0x00001e12		/* 1283*6		    */
	.long	0x00001000		/* 4<<10		    */
	.long	89
	.long	199
	.word	0x0125
	.word	0
	.ascii	"10 bits"
	.byte	0,0,0

_s_mode2:
	.long	_s_mode3
	.long	42
	.long	1
	.long	0x00003c72		/* 2579*6		    */
	.long	0x00002000		/* 4<<11		    */
	.long	86
	.long	210
	.word	0x013d
	.word	0
	.ascii	"11 bits"
	.byte	0,0,0

_s_mode3:
	.long	_s_mode4
	.long	57
	.long	1
	.long	0x000078a2		/* 5147*6		    */
	.long	0x00004000		/* 4<<12		    */
	.long	85
	.long	218
	.word	0x0144
	.word	0
	.ascii	"12 bits"
	.byte	0,0,0

_s_mode4:
	.long	_s_mode5
	.long	71
	.long	1
	.long	0x0000f012		/* 10243*6		    */
	.long	0x00008000		/* 4<<13		    */
	.long	87
	.long	225
	.word	0x0149
	.word	0
	.ascii	"13 bits"
	.byte	0,0,0

_s_mode5:
	.long	_s_mode6
	.long	85
	.long	1
	.long	0x0001e012		/* 20483*6		    */
	.long	0x00010000		/* 4<<14		    */
	.long	89
	.long	231
	.word	0x014b
	.word	0
	.ascii	"14 bits"
	.byte	0,0,0

_s_mode6:
	.long	0			/* xm_Next = end	    */
	.long	100
	.long	1
	.long	0x0003c006		/* 40961*6		    */
	.long	0x00020000		/* 4<<15		    */
	.long	95
	.long	237
	.word	0x0151
	.word	0
	.ascii	"15 bits"
	.byte	0,0,0

_s_name:
	.ascii	"BLZW"
	.byte	0
_s_longname:
	.ascii	"Bryan's turbo-charged LZW"
	.byte	0
_s_basedesc:
	.ascii	"Fast compression and decompression, ratio much like 'compress' or 'zoo'"
	.byte	0
_s_packmsg:
	.ascii	"Compressing"
	.byte	0
_s_unpackmsg:
	.ascii	"Decompressing"
	.byte	0
_s_packedmsg:
	.ascii	"Compressed"
	.byte	0
_s_unpackedmsg:
	.ascii	"Decompressed"
	.byte	0

||||
||||	LibInit -- a0 = seglist, d0 = libbase.  Stores the seglist
||||	at base+34.
||||
	.even
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts
