	.file	"xpkSQSH_lib.s"
	.text

/*
**	xpkSQSH_lib.s -- resident module header for
**	xpkSQSH.library 1.2 "Squash 020+ V1.2" (1 Oct 2013).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub (also the
**	init-fail return and the -24/-48/-60 vector targets via
**	negative offsets); packed RomTag (RTF_AUTOINIT, ver 1,
**	NT_LIBRARY); InitTable dataSize 0x26 (Library + seg@34);
**	word-offset FUNCTABLE (genfunctab.py); LibInit stores the
**	seglist at base+34 and requires AttnFlags bit 1 (68020) --
**	otherwise branches back to the entry stub returning 0.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 entry stub (moveq #0,rts)
**	  -12 Close          -30 XpksPackerInfo (lea _xpkinfo)
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 entry stub
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
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkSQSH.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpk V1.2 (1 Oct 2013) by John Hendrikx"
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
	.long	0x53515348		/* xi_ID = 'SQSH'	    */
	.long	9			/* xi_Flags		    */
	.long	0x8000			/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x8000			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* XpkMode "normal": verbatim fields from the original. */
_s_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x22080			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0xf			/* xm_PackSpeed	    */
	.long	0xe9			/* xm_UnpackSpeed	    */
	.word	0x1a8			/* xm_Ratio = 424	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"normal"
	.byte	0,0,0
	.even

_s_name:
	.ascii	"Squash"
	.byte	0
_s_longname:
	.ascii	"Squash 020+ V1.2"
	.byte	0
_s_basedesc:
	.ascii	"LZ based cruncher, special algorithms for 8 bit sound data, fast decrunching"
	.byte	0
_s_packmsg:
	.ascii	"Squashing"
	.byte	0
_s_unpackmsg:
	.ascii	"UnSquashing"
	.byte	0
_s_packedmsg:
	.ascii	"Squashed"
	.byte	0
_s_unpackedmsg:
	.ascii	"UnSquashed"
	.byte	0
	.even

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

	.globl	_TagEnd
_TagEnd:
