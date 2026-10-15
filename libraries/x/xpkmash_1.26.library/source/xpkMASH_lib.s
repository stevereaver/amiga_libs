	.file	"xpkMASH_lib.s"
	.text

/*
**	xpkMASH_lib.s -- resident module header for
**	xpkMASH.library 1.26 "Mashiner".
**
**	Single code hunk; RomTag RTF_AUTOINIT v1; InitTable
**	dataSize 0x4a (Library + exec@34 + seglist@38);
**	InitStruct data uses the word-offset command stream
**	(e000=byte, d000=word, c000=long);
**	FUNCTABLE = LONG offsets relative to lib base,
**	terminated by 0xffffffff.
**
**	Original vector map (offsets relative to lib base):
**	  -6  Open           -36 XpksPackChunk
**	  -12 Close          -42 return-0 stub
**	  -18 Expunge        -48 return-0 stub
**	  -24 return-0 stub  -54 XpksUnpackChunk
**	  -30 XpksPackerInfo -60 return-0 stub
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag			/* rt_MatchTag	    */
	.long	_endmodule		/* rt_EndSkip	    */
	.byte	0x80			/* RTF_AUTOINIT	    */
	.byte	1			/* rt_Version	    */
	.byte	9			/* NT_LIBRARY	    */
	.byte	0x81			/* rt_Pri = -127    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkMASH.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkMASH.library V1.26"
	.byte	13,10,0
	.even

	.globl	_inittab
_inittab:
	.long	0x4a			/* dataSize 74	    */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* FUNCTABLE: long offsets relative to lib base, -1L terminator */
	.globl	_functab
_functab:
	.long	_LibOpen - _start
	.long	_LibClose - _start
	.long	_LibExpunge - _start
	.long	_ret0 - _start		/* -24 Reserved	    */
	.long	_XpksPackerInfo - _start
	.long	_XpksPackChunk - _start
	.long	_ret0 - _start		/* -42		    */
	.long	_ret0 - _start		/* -48		    */
	.long	_XpksUnpackChunk - _start
	.long	_ret0 - _start		/* -60		    */
	.long	0xffffffff

/* InitStruct command stream (verbatim from the original):
 *   e000 off16 = byte write, d000 off16 = word write,
 *   c000 off16 = long write; 0000 ends.			    */
_datatab:
	.word	0xe000,0x000c		/* byte @ +0x0c	    */
	.byte	0x09,0x00
	.word	0xc000,0x000a		/* ln_Name	    */
	.long	_libname
	.word	0xe000,0x000e		/* lib_Flags = 6    */
	.byte	0x06,0x00
	.word	0xd000,0x0014		/* version = 1	    */
	.word	1
	.word	0xd000,0x0016		/* revision = 26    */
	.word	0x1a
	.word	0xc000,0x0018		/* idstring	    */
	.long	_idstr
	.word	0x0000,0x0000

/* ------------------------------------------------------------------ */
/* static XpkInfo descriptor (XpksPackerInfo returns its address)	    */
/* ------------------------------------------------------------------ */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName	    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x4d415348		/* xi_ID = 'MASH'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x00100000		/* xi_MaxPkInChunk+pad    */
	.long	0x50			/* xi_MinPkInChunk = 80   */
	.long	0x00010000		/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg	    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	100			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_xmodes			/* xi_ModeDesc	    */

/* single mode record {0..100}: " -->    "			    */
_xmodes:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	17			/* xm_PackSpeed	    */
	.long	400			/* xm_UnpackSpeed	    */
	.word	472			/* xm_Ratio		    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	" -->    "
	.byte	0,0,0,0
	.word	0x7ff8
	.even

_s_name:
	.ascii	"Mashiner"
	.byte	0
_s_longname:
	.ascii	"MASH V1.26, good packer"
	.byte	0
_s_basedesc:
	.ascii	"WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"
	.byte	0
_s_packmsg:
	.ascii	"Mashing"
	.byte	0
_s_unpackmsg:
	.ascii	"UnMashing"
	.byte	0
_s_packedmsg:
	.ascii	"Mashed"
	.byte	0
_s_unpackedmsg:
	.ascii	"UnMashed"
	.byte	0
	.even

/* ------------------------------------------------------------------ */
/*	LibInit -- d0 = libbase, a0 = seglist, a6 = exec		    */
/* ------------------------------------------------------------------ */
	.globl	_LibInit
_LibInit:
	exg	%d0,%a5
	movel	%a6,%a5@(34)		/* exec base		    */
	movel	%a0,%a5@(38)		/* seglist		    */
	exg	%d0,%a5
	rts

/* ------------------------------------------------------------------ */
/*	lifecycle (asm for byte-faithful register behaviour)	    */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6 */
	addql	#1,%a6@(32)
	bclr	#3,%a6@(14)
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 */
	moveq	#0,%d0
	subql	#1,%a6@(32)
	bnes	1f
	btst	#3,%a6@(14)
	beqs	1f
	jra	_LibExpunge
1:	rts

	.globl	_LibExpunge
_LibExpunge:				/* -18 */
	moveml	%d1-%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(34),%a6		/* exec base		    */
	tstl	%a5@(32)
	beqs	1f
	bset	#3,%a5@(14)		/* LIBF_DELEXP		    */
	moveq	#0,%d0
	bras	2f
1:	movel	%a5@(38),%d2		/* seglist		    */
	moveal	%a5,%a1
	jsr	%a6@(-252:W)		/* Remove		    */
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0		/* NegSize		    */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* +PosSize		    */
	jsr	%a6@(-210:W)		/* FreeMem		    */
	movel	%d2,%d0
2:	moveml	%sp@+,%d1-%d2/%a5-%a6
	rts

_ret0:
	moveq	#0,%d0
	rts

/* ------------------------------------------------------------------ */
/*	-30 XpksPackerInfo: return descriptor ptr (exg trick as	    */
/*	in the original: d0 = old a0, a0 = desc, swap)		    */
/* ------------------------------------------------------------------ */
	.globl	_XpksPackerInfo
_XpksPackerInfo:
	movel	%a0,%d0
	lea	_xpkinfo(%pc),%a0
	exg	%a0,%d0
	rts

/* ------------------------------------------------------------------ */
/*	vector entry stubs: the xpk sublib protocol passes xsp in	    */
/*	a0; push it so the C body can use the standard ABI.		    */
/* ------------------------------------------------------------------ */
	.globl	_XpksPackChunk
_XpksPackChunk:				/* -36 */
	movel	%a0,%sp@-
	jsr	_C_PackChunk
	addql	#4,%sp
	rts

	.globl	_XpksUnpackChunk
_XpksUnpackChunk:			/* -54 */
	movel	%a0,%sp@-
	jsr	_C_UnpackChunk
	addql	#4,%sp
	rts
