	.file	"xpkMASH_lib.s"
	.text

/*
**	xpkMASH_lib.s -- resident module header + lifecycle for
**	xpkMASH.library 2.0 "Mashiner V2.0" (Zdenek Kadelac,
**	1 Oct 2013) -- the 68000 build.
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub at code+0
**	(also the -24/-48/-60 vector targets via a negative word
**	offset -146 in the FUNCTABLE); packed RomTag (RTF_AUTOINIT,
**	rt_Version 2, NT_LIBRARY, rt_EndSkip = 0); InitTable with
**	dataSize 38 (Library + seglist long), a word-offset
**	FUNCTABLE (ffff marker + offsets relative to the marker),
**	the 8x/9x/ax-series InitStruct DATATAB (offset-in-opcode
**	form, verbatim), and initRoutine = LibInit.
**
**	NOTE: the shipped binary's first RELOC32 entry patches
**	code+0 -- the entry stub is corrupted by the load-time base
**	add -- so -24/-48/-60 jump to `moveq #base>>16+` garbage.
**	This rebuild does not reproduce the bad relocation; the
**	stub stays a working `moveq #0,rts`.
**
**	Original vector map (offsets relative to _functab):
**	  -6  LibOpen        -30 XpksPackerInfo
**	  -12 LibClose       -36 XpksPackChunk
**	  -18 LibExpunge     -42 XpksPackFree (leaves dangling ptr)
**	  -24 _start         -48 _start
**	                     -54 XpksUnpackChunk
**	                     -60 _start
*/

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag			/* rt_MatchTag	    */
	.long	0			/* rt_EndSkip = 0   */
	.byte	0x80			/* RTF_AUTOINIT	    */
	.byte	2			/* rt_Version	    */
	.byte	9			/* NT_LIBRARY	    */
	.byte	0			/* rt_Pri	    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_libname
_libname:
	.ascii	"xpkMASH.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"$VER: xpkMASH V2.0 (1 Oct 2013) by Zdenek Kadelac"
	.byte	13,10,0
	.even

	.globl	_inittab
_inittab:
	.long	38			/* Library + seglist    */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* InitStruct stream, verbatim 8x/9x/ax command bytes:
 *   ax = byte init, offset in low byte, 1 data byte + pad
 *   9x = word init, offset in low byte
 *   8x = long init, offset in low byte			    */
_datatab:
	.word	0xa008			/* byte@8  ln_Type	    */
	.byte	9,0
	.word	0x800a			/* long@10 ln_Name	    */
	.long	_libname
	.word	0xa00e			/* byte@14 lib_Flags = 6    */
	.byte	6,0
	.word	0x9014,2		/* word@20 version = 2	    */
	.word	0x9016,0		/* word@22 revision = 0	    */
	.word	0x8018			/* long@24 idstring	    */
	.long	_idstr
	.word	0			/* end			    */
	.even

/* FUNCTABLE: ffff marker + word offsets relative to the marker.
 * Generated after a first-pass link by genfunctab.py -- the file
 * functab.s is produced by the Makefile, not edited by hand.	    */

/* ------------------------------------------------------------------ */
/*	LibInit -- d0 = libbase, a0 = seglist			    */
/* ------------------------------------------------------------------ */
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts				/* no cpu gate (000 build)  */

/* ------------------------------------------------------------------ */
/*	lifecycle							    */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6 */
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 */
	subqw	#1,%a6@(32)
	bnes	9f			/* orig: bra to bare rts  */
	btst	#3,%a6@(14)
	beqs	9f
	/* fall through to expunge */
	.globl	_LibExpunge
_LibExpunge:				/* -18 */
	tstw	%a6@(32)
	beqs	1f
	bset	#3,%a6@(14)		/* LIBF_DELEXP		    */
	moveq	#0,%d0
	rts
1:	moveml	%d2/%a5-%a6,%sp@-
	movel	%a6@(34),%d2		/* seglist		    */
	moveal	%a6,%a5
	moveal	%a5,%a1
	moveal	0x4,%a6			/* SysBase		    */
	jsr	%a6@(-252)		/* Remove		    */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* NegSize		    */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* +PosSize		    */
	jsr	%a6@(-210)		/* FreeMem		    */
	movel	%d2,%d0			/* return seglist	    */
	moveml	%sp@+,%d2/%a5-%a6
9:	rts

/* ------------------------------------------------------------------ */
/*	-30 XpksPackerInfo: return the descriptor pointer		    */
/* ------------------------------------------------------------------ */
	.globl	_XpksPackerInfo
_XpksPackerInfo:
	lea	_xpkinfo(%pc),%a0
	movel	%a0,%d0
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

	.globl	_XpksPackFree
_XpksPackFree:				/* -42 */
	movel	%a0,%sp@-
	jsr	_C_PackFree
	addql	#4,%sp
	rts

	.globl	_XpksUnpackChunk
_XpksUnpackChunk:			/* -54 */
	movel	%a0,%sp@-
	jsr	_C_UnpackChunk
	addql	#4,%sp
	rts

/* ------------------------------------------------------------------ */
/*	static XpkInfo descriptor (XpksPackerInfo returns its address)  */
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
	.long	0x4d415348		/* xi_ID = 'MASH'	    */
	.long	9			/* xi_Flags		    */
	.long	0x10000			/* xi_MaxPkInChunk = 64KB   */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x10000			/* xi_DefPkInChunk = 64KB   */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	100			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_xmodes			/* xi_ModeDesc		    */

/* single mode record {0..100}: " -->"				    */
_xmodes:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x00040010		/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	7			/* xm_PackSpeed	    */
	.long	120			/* xm_UnpackSpeed	    */
	.word	473			/* xm_Ratio		    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	" -->"
	.byte	0,0,0,0,0,0
	.even

_s_name:
	.ascii	"Mashiner"
	.byte	0
_s_longname:
	.ascii	"Mashiner V2.0"
	.byte	0
_s_basedesc:
	.ascii	"WindowSize: 32KB, 2 mixed streams"
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
