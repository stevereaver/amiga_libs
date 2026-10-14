	.file	"xpkhuff_lib.s"
	.text

/*
**	xpkhuff_lib.s -- resident module header for
**	xpkHUFF.library 0.62 "$VER: xpkHUFF.library V.0.62 ($DATE:.
**	Mon Aug 10 10:31:44 1992 by M.Zimmermann
**	(zimerma@helios.ibr.cs.tu-bs.de))".
**
**	1992 ancestor of xpkHUFF 0.64: same 'HUFF' wire format and
**	workmem maps, earlier skeleton.  Single code hunk; the entry
**	point is a dos.library "You can't execute" Write stub.
**	RomTag RTF_AUTOINIT, ver 0, NT_LIBRARY; InitTable dataSize
**	0xa8 -- the private area holds the seglist (+34), the
**	XpkInfo (+0x26) and the XpkMode descriptor (+0x7e), all
**	built at run time by LibInit.  ABSOLUTE-LONGWORD functab
**	(10 entries + -1).  No CPU gate, no baserel.
**
**	Vector map:
**	  -6  LibOpen        -24 _LibZero (moveq #0,rts)
**	  -12 LibClose       -30 XpksPackerInfo (lib+0x26)
**	  -18 LibExpunge     -36 XpksPackChunk
**	                     -42 _LibNull (bare rts)
**	                     -48 _LibNull
**	                     -54 XpksUnpackChunk
**	                     -60 _LibNull
**
**	Reconstructed layout (original hunk offsets):
**	  0x00  dos entry stub ("You can't execute" Write)
**	  0x38  "dos.library"  0x44 128B message   0xc4 RomTag
**	  0xee  "$VER: " prefix (rt_IdString points past it, +6)
**	  0xf4  idstring       0x160 InitTable     0x170 functab
**	  0x19c datatab        0x1bc LibInit       0x2d4 strings
**	  0x368 LibOpen  0x376 LibClose  0x38a LibExpunge
**	  0x3d0 -24 stub  0x3d4 subnoop  0x3e0 PackerInfo
**	  0x3ea pack wrap  0x3f6/-42 rts  0x3f8/-48 rts
**	  0x3fa unpack wrap  0x408/-60 rts
**	  0x40a dead data  0x414 pack body  0x73e unpack body
*/

	.globl	_start
_start:
	moveq	#0,%d0
	lea	%pc@(_dosname),%a1	/* "dos.library"	    */
	moveal	4,%a6
	jsr	%a6@(-552:W)		/* OpenLibrary		    */
	tstl	%d0
	beqs	1f
	moveal	%d0,%a6
	jsr	%a6@(-60:W)		/* Output()		    */
	movel	%d0,%d1
	movel	#_climsg,%d2		/* message (relocated)	    */
	movel	#128,%d3		/* fixed length 128	    */
	jsr	%a6@(-48:W)		/* Write		    */
	moveal	%a6,%a1
	moveal	4,%a6
	jsr	%a6@(-414:W)		/* CloseLibrary		    */
1:	moveq	#0,%d0
	rts

_dosname:
	.ascii	"dos.library"
	.byte	0
_climsg:
	.ascii	"\nYou can't execute xpkHUFF.library V\2400.62!\n($DATE:\240Mon Aug 10 10:31:44 1992 by M.Zimmermann (zimerma@helios.ibr.cs.tu-bs.de))\n\n"
	.byte	0
	.even

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_end			/* rt_EndSkip -> hunk end   */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0			/* version 0		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkHUFF.library"
	.byte	0
_verstr:
	.ascii	"$VER: "		/* prefix skipped by	    */
_idstr:					/*   rt_IdString (+6)	    */
	.ascii	"xpkHUFF.library\240V\2400.62 ($DATE:\240Mon Aug 10 10:31:44 1992 by M.Zimmermann (zimerma@helios.ibr.cs.tu-bs.de))"
	.byte	0,0
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
	.byte	0x90,0x14		/* version = 0		    */
	.word	0x0000
	.byte	0x90,0x16		/* revision = 62	    */
	.word	0x003e
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.even

/*
**	LibInit -- d0 = libbase, a0 = seglist.
**	Stores the seglist at base+34, then builds the XpkMode
**	descriptor at base+0x7e and the XpkInfo at base+0x26.
**	String pointers are pc-relative lea's (as in the original).
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
	movel	#0x7324,%a1@(12)	/* xm_PackMemory = 29476    */
	movel	#0x1141a,%a1@(16)	/* xm_UnpackMemory = 70682  */
	movel	#0x58,%a1@(20)		/* xm_PackSpeed = 88	    */
	movel	#0x8a,%a1@(24)		/* xm_UnpackSpeed = 138	    */
	movew	#0xf1,%a1@(28)		/* xm_Ratio = 241	    */
	movew	#0x3f,%a1@(30)		/* xm_ChunkSize = 63	    */
	movel	#0x6e6f726d,%a1@(32)	/* "norm"		    */
	movew	#0x616c,%a1@(36)	/* "al"			    */
	movew	#0,%a1@(38)		/* only 8 of 10 name bytes  */

	lea	%a5@(38),%a1		/* XpkInfo at +0x26	    */
	movew	#1,%a1@(0)		/* xi_XpkInfoVersion	    */
	movew	#0,%a1@(2)		/* xi_LibVersion	    */
	movew	#1,%a1@(4)		/* xi_MasterVersion	    */
	movew	#0,%a1@(6)		/* xi_ModesVersion	    */
	lea	%pc@(_s_name),%a0
	movel	%a0,%a1@(8)		/* xi_Name "HUFF"	    */
	lea	%pc@(_s_longname),%a0
	movel	%a0,%a1@(12)		/* xi_LongName		    */
	lea	%pc@(_s_basedesc),%a0
	movel	%a0,%a1@(16)		/* xi_Description	    */
	movel	#0x48554646,%a1@(20)	/* xi_ID = 'HUFF'	    */
	movel	#0x2009,%a1@(24)	/* xi_Flags		    */
	movel	#0xfffe,%a1@(28)	/* xi_MaxPkInChunk	    */
	movel	#1,%a1@(32)		/* xi_MinPkInChunk	    */
	movel	#0xfffe,%a1@(36)	/* xi_DefPkInChunk	    */
	lea	%pc@(_s_packmsg),%a0
	movel	%a0,%a1@(40)		/* xi_PackMsg		    */
	lea	%pc@(_s_unpackmsg),%a0
	movel	%a0,%a1@(44)		/* xi_UnpackMsg	    */
	lea	%pc@(_s_packedmsg),%a0
	movel	%a0,%a1@(48)		/* xi_PackedMsg	    */
	lea	%pc@(_s_unpackedmsg),%a0
	movel	%a0,%a1@(52)		/* xi_UnpackedMsg	    */
	movew	#0x32,%a1@(56)		/* xi_DefMode = 50	    */
	movew	#0,%a1@(58)		/* xi_Pad		    */
	lea	%a5@(126),%a0
	movel	%a0,%a1@(60)		/* xi_ModeDesc		    */
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
/* descriptor strings (referenced from LibInit via pc-relative lea)    */
/* ------------------------------------------------------------------ */

_s_name:
	.ascii	"HUFF"
	.byte	0,0
_s_longname:
	.ascii	"Huffman V\2400.62"
	.byte	0,0
_s_basedesc:
	.ascii	"Dynamic huffman crunch algorithm, cache optimized byte decrunch algorithm"
	.byte	0
	.even
_s_packmsg:
	.ascii	"Crunching"
	.byte	0,0,0
_s_unpackmsg:
	.ascii	"Decrunching"
	.byte	0
_s_packedmsg:
	.ascii	"Crunched"
	.byte	0,0,0,0
_s_unpackedmsg:
	.ascii	"Decrunched"
	.byte	0,0
	.even

/* ------------------------------------------------------------------ */
/* small vector targets						    */
/* ------------------------------------------------------------------ */

	.globl	_LibZero
_LibZero:				/* -24: returns 0	    */
	moveq	#0,%d0
	rts

/*	register-neutral nop: moveml/nop/moveml/rts, the dead call
 *	LibExpunge makes between its bookkeeping steps (original 0x3d4) */
	.globl	_subnoop
_subnoop:
	moveml	%d0-%a6,%sp@-
	nop
	moveml	%sp@+,%d0-%a6
	rts

	.globl	_PackerInfo
_PackerInfo:				/* -30: XpksPackerInfo	    */
	movel	%a6,%d0
	addil	#38,%d0			/* lib + 0x26		    */
	rts

_LibNull:				/* -42/-48/-60: bare rts    */
	rts

/*	dead data at the vector tail (original 0x40a): an
 *	unreferenced {long 0, word 8, long 0x32e} remnant	    */
_dead:
	.long	0
	.word	8
	.long	0x32e

	.globl	_end
_end:
