	.file	"xpkLZBS_lib.s"
	.text

/*
**	xpkLZBS_lib.s -- resident module header for
**	xpkLZBS.library 2.1 "LZStreamer" (1 Oct 2013, Niels Froehling).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub (also the
**	init-fail return and the -24/-60 vector targets via negative
**	offsets); packed RomTag (RTF_AUTOINIT, rt_Version 2,
**	NT_LIBRARY); InitTable dataSize 0x26 (Library + seg@34);
**	word-offset FUNCTABLE (genfunctab.py, no leading marker);
**	LibInit stores the seglist at base+34 (no CPU gate).
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 entry stub (moveq #0,rts)
**	  -12 Close          -30 XpksPackerInfo (lea _xpkinfo)
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 XpksPackReset (clear hash table)
**	                     -54 XpksUnpackChunk
**	                     -60 entry stub
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
	.byte	2			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkLZBS.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkLZBS V2.1 (1 Oct 2013) by Niels Froehling"
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
	.byte	0x90,0x16		/* revision = 1		    */
	.word	0x0001
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
	.word	2			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x4c5a4253		/* xi_ID = 'LZBS'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x00050000		/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_xmodes			/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* ------------------------------------------------------------------ */
/* mode chain: 12 records, 42 bytes each, verbatim fields.	    */
/* { next, upto, flags, packmem, unpackmem, pspeed, uspeed, ratio,    */
/*   pad, name[10] }						    */
/* ------------------------------------------------------------------ */

.macro	XM next, upto, pmem, ps, us, rat, name
	.long	\next
	.long	\upto
	.long	1
	.long	\pmem
	.long	0
	.long	\ps
	.long	\us
	.word	\rat
	.word	0
	.ascii	"\name"
.endm

_xmodes:
	XM _xm1, 1,   0x40014, 33, 54, 0x31,  "2 bits\0\0\0\0"
_xm1:	XM _xm2, 10,  0x40024, 33, 53, 0x55,  "3 bits\0\0\0\0"
_xm2:	XM _xm3, 20,  0x40044, 33, 53, 0x62,  "4 bits\0\0\0\0"
_xm3:	XM _xm4, 30,  0x40084, 34, 53, 0x8b,  "5 bits\0\0\0\0"
_xm4:	XM _xm5, 40,  0x40104, 35, 54, 0xbc,  "6 bits\0\0\0\0"
_xm5:	XM _xm6, 50,  0x40204, 36, 56, 0xeb,  "7 bits\0\0\0\0"
_xm6:	XM _xm7, 60,  0x40404, 36, 58, 0x10c, "8 bits\0\0\0\0"
_xm7:	XM _xm8, 70,  0x40804, 36, 60, 0x126, "9 bits\0\0\0\0"
_xm8:	XM _xm9, 80,  0x41004, 35, 62, 0x13a, "10 bits\0\0\0"
_xm9:	XM _xm10, 90, 0x42004, 33, 64, 0x148, "11 bits\0\0\0"
_xm10:	XM _xm11, 98, 0x44004, 30, 65, 0x14f, "12 bits\0\0\0"
_xm11:	XM 0,    100, 0x48004, 26, 67, 0x150, "13 bits\0\0\0"

_s_name:
	.ascii	"LZStreamer"
	.byte	0
_s_longname:
	.ascii	"BSI Bitstream Packer V2.1"
	.byte	0
_s_basedesc:
	.ascii	"LZSS family with 2-13 bits window"
	.byte	0
_s_packmsg:
	.ascii	"BSsss..."
	.byte	0
_s_unpackmsg:
	.ascii	"UnnnBS..."
	.byte	0
_s_packedmsg:
	.ascii	"Oh god, It is done!"
	.byte	0
_s_unpackedmsg:
	.ascii	"Hehe, fast hew."
	.byte	0
	.even

/*
**	LibInit -- a0 = seglist, d0 = libbase.
**	Stores the seglist at base+34, returns.  (68000 build: no
**	AttnFlags gate.)
*/
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts

	.globl	_TagEnd
_TagEnd:
