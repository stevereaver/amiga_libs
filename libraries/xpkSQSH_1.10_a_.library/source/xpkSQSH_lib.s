	.file	"xpkSQSH_lib.s"
	.text

/*
**	xpkSQSH_lib.s -- resident module header for
**	xpksqsh.library 1.10 "xpkSQSH 1.10 (6.3.94)" by John Hendrikx.
**
**	Code hunk is byte-identical to xpkSQSH_1.00; only the idstring,
**	lib revision (10) and longname ("Squash 1.10") differ.  The
**	source file is also a 2232-byte prefix of xpkSQSH_1.10.library
**	(2936 B, which appends a 704-byte post-HUNK_END overlay) and is
**	itself truncated: it ends right at the HUNK_END type word.
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub; packed RomTag
**	(RTF_AUTOINIT, ver 1, NT_LIBRARY); InitTable dataSize 0xa8 --
**	the private area holds the seglist (+34), the XpkInfo (+0x26)
**	and the XpkMode descriptor (+0x7e), all built at run time by
**	LibInit.  ABSOLUTE-LONGWORD functab (10 entries + -1), unlike
**	the word-offset tables of the 1.2 siblings.  No CPU gate.
**
**	Vector map:
**	  -6  LibOpen        -24 _LibZero (moveq #0,rts)
**	  -12 LibClose       -30 XpksPackerInfo (lib+0x26)
**	  -18 LibExpunge     -36 XpksPackChunk
**	                     -42 _LibNull (bare rts)
**	                     -48 _LibNull
**	                     -54 XpksUnpackChunk
**	                     -60 _LibNull
*/

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_end			/* rt_EndSkip -> hunk end   */
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
	.ascii	"xpkSQSH 1.10 (6.3.94)"
	.byte	13,10,0,0,0
	.even

	.globl	_inittab
_inittab:
	.long	0xa8			/* dataSize 168		    */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* absolute-longword function table, terminated by -1 */
	.globl	_functab
_functab:
	.long	_LibOpen		/* -6			    */
	.long	_LibClose		/* -12			    */
	.long	_LibExpunge		/* -18			    */
	.long	_LibZero		/* -24  -> 0		    */
	.long	_PackerInfo		/* -30  XpksPackerInfo	    */
	.long	_XpksPackChunk		/* -36			    */
	.long	_LibNull		/* -42			    */
	.long	_LibNull		/* -48			    */
	.long	_XpksUnpackChunk	/* -54			    */
	.long	_LibNull		/* -60			    */
	.long	-1

_datatab:
	.byte	0xa0,0x08		/* ln_Type = 9		    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 1		    */
	.word	0x0001
	.byte	0x90,0x16		/* revision = 10		    */
	.word	0x000a
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.even

/*
**	LibInit -- d0 = libbase, a0 = seglist.
**	Stores the seglist at base+34, then builds the XpkMode
**	descriptor at base+0x7e and the XpkInfo at base+0x26.
**	All pointers are hunk-relative symbols (relocated at load).
*/
	.globl	_LibInit
_LibInit:
	moveml	%d0-%a6,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* seglist		    */
	moveml	%d0-%a6,%sp@-

	lea	%a5@(126),%a1		/* mode descriptor at +0x7e */
	movel	#0,%a1@(0)		/* xm_Next		    */
	movel	#100,%a1@(4)		/* xm_Upto		    */
	movel	#1,%a1@(8)		/* xm_Flags		    */
	movel	#0x22080,%a1@(12)	/* xm_PackMemory	    */
	movel	#0,%a1@(16)		/* xm_UnpackMemory	    */
	movel	#25,%a1@(20)		/* xm_PackSpeed	    */
	movel	#300,%a1@(24)		/* xm_UnpackSpeed	    */
	movew	#424,%a1@(28)		/* xm_Ratio		    */
	movew	#32,%a1@(30)		/* xm_ChunkSize	    */
	movel	#0x6e6f726d,%a1@(32)	/* "norm"		    */
	movew	#0x616c,%a1@(36)	/* "al"			    */
	movew	#0,%a1@(38)

	lea	%a5@(38),%a1		/* XpkInfo at +0x26	    */
	movew	#1,%a1@(0)		/* xi_XpkInfoVersion	    */
	movew	#1,%a1@(2)		/* xi_LibVersion	    */
	movew	#1,%a1@(4)		/* xi_MasterVersion	    */
	movew	#0,%a1@(6)		/* xi_ModesVersion	    */
	lea	_s_name,%a0
	movel	%a0,%a1@(8)		/* xi_Name		    */
	lea	_s_longname,%a0
	movel	%a0,%a1@(12)		/* xi_LongName	    */
	lea	_s_basedesc,%a0
	movel	%a0,%a1@(16)		/* xi_Description	    */
	movel	#0x53515348,%a1@(20)	/* xi_ID = 'SQSH'	    */
	movel	#0x2009,%a1@(24)	/* xi_Flags		    */
	movel	#0x8000,%a1@(28)	/* xi_MaxPkInChunk	    */
	movel	#0x10,%a1@(32)		/* xi_MinPkInChunk = 16    */
	movel	#0x8000,%a1@(36)	/* xi_DefPkInChunk	    */
	lea	_s_packmsg,%a0
	movel	%a0,%a1@(40)		/* xi_PackMsg		    */
	lea	_s_unpackmsg,%a0
	movel	%a0,%a1@(44)		/* xi_UnpackMsg	    */
	lea	_s_packedmsg,%a0
	movel	%a0,%a1@(48)		/* xi_PackedMsg	    */
	lea	_s_unpackedmsg,%a0
	movel	%a0,%a1@(52)		/* xi_UnpackedMsg	    */
	movew	#100,%a1@(56)		/* xi_DefMode		    */
	movew	#0,%a1@(58)		/* xi_Pad		    */
	lea	%a5@(126),%a0
	movel	%a0,%a1@(60)		/* xi_ModeDesc	    */
	clrl	%a1@(64)
	clrl	%a1@(68)
	clrl	%a1@(72)
	clrl	%a1@(76)
	clrl	%a1@(80)
	clrl	%a1@(84)		/* xi_Reserved[6]	    */
	moveml	%sp@+,%d0-%a6
	moveml	%sp@+,%d0-%a6
	rts

/* ------------------------------------------------------------------ */
/* small vector targets						    */
/* ------------------------------------------------------------------ */

_LibZero:				/* -24: returns 0	    */
	moveq	#0,%d0
	rts
_LibNull:				/* -42/-48/-60: bare rts    */
	rts

	.globl	_PackerInfo
_PackerInfo:				/* -30: XpksPackerInfo	    */
	movel	%a6,%d0
	addil	#38,%d0			/* lib + 0x26		    */
	rts

/* ------------------------------------------------------------------ */
/* strings referenced by the run-time descriptor			    */
/* ------------------------------------------------------------------ */

_s_name:
	.ascii	"SQSH"
	.byte	0,0,0,0
_s_longname:
	.ascii	"Squash 1.10"
	.byte	0,0
_s_basedesc:
	.ascii	"LZ based cruncher; special algorithms for 8 bit sound data; fast decrunching"
	.byte	0,0,0,0
_s_packmsg:
	.ascii	"Squashing"
	.byte	0,0,0
_s_unpackmsg:
	.ascii	"UnSquashing"
	.byte	0
_s_packedmsg:
	.ascii	"Squashed"
	.byte	0,0,0,0
_s_unpackedmsg:
	.ascii	"UnSquashed"
	.byte	0,0
	.even

	.globl	_end
_end:
