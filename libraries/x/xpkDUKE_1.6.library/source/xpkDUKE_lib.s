	.file	"xpkDUKE_lib.s"
	.text

/*
**	xpkDUKE_lib.s -- resident module header for
**	xpkDUKE.library 1.6 (08.06.1997, C. von Roques).
**
**	Two-hunk original: CODE + DATA (descriptors live in DATA,
**	strings in CODE).  "moveq #-1,d0 / rts" entry stub (the -1
**	-- not 0 -- is a 1.x-generation detail); RomTag with
**	RTF_AUTOINIT and rt_EndSkip = code+0x106 (just past the -24
**	stub); InitTable dataSize 0x22 = bare struct Library (no
**	private data -- the seglist lives in a self-modifying cell
**	at code+0x7a); longword-pointer FUNCTABLE (10 vectors +
**	0xffffffff), NOT the word-offset form of the 1.8 libs.
**
**	Original vector map (all entries absolute longwords):
**	  -6  Open              -30 XpksPackerInfo (lea info,a0)
**	  -12 Close             -36 XpksPackChunk
**	  -18 Expunge           -42 XpksPackFree
**	  -24 null (0x104)      -48 null (0x134)
**	                        -54 XpksUnpackChunk
**	                        -60 XpksUnpackFree (real fn: frees
**	                            the 0x8000 delta/decode scratch)
*/

	.globl	_start
_start:
	moveq	#-1,%d0			/* sic: -1, not 0 */
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endscan		/* rt_EndSkip -> end of -24 stub */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_inittab
_inittab:
	.long	0x22			/* dataSize 34 = bare Library */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* longword-absolute functab, -1 terminated (1.x style) */
	.globl	_functab
_functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_Stub0			/* -24 null: moveq #0;rts   */
	.long	_XpksPackerInfo		/* -30			   */
	.long	_XpksPackChunk		/* -36			   */
	.long	_XpksPackFree		/* -42			   */
	.long	_LibNull		/* -48 null		   */
	.long	_XpksUnpackChunk	/* -54			   */
	.long	_XpksUnpackFree		/* -60			   */
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
	.byte	0x90,0x16		/* revision = 6		    */
	.word	0x0006
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.word	0			/* pad -- the cell lands at  */
	.globl	_segcell		/* the same place as in the  */
_segcell:
	.long	0			/* original (code+0x7a): the */
					/* seglist, stored by LibInit*/
					/* and read back by Expunge. */

/*
**	LibInit -- a0 = seglist, d0 = libbase.  Stores the seglist
**	into the in-code cell _segcell (original: absolute store to
**	code+0x7a, operand relocated).  Calls the null stub and tests
**	d0 -- dead code in the original (stub returns 0 always);
**	reproduced verbatim.
*/
	.globl	_LibInit
_LibInit:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,_segcell		/* seglist -> in-code cell   */
	bsrw	_LibNull		/* dead check: always d0=0   */
	tstl	%d0
	bnes	1f
	movel	%a5,%d0			/* return libbase	    */
5:	moveal	%sp@+,%a5
	rts
1:	bsrw	_LibNull
	moveq	#0,%d0
	bras	5b			/* return 0 via restore/rts  */

/* ------------------------------------------------------------------ */
/* Lifecycle vectors -- transcribed from the original (code 0x9e..).  */
/* The library base arrives in a6 per the LVO convention.		   */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6 */
	addqw	#1,%a6@(32)		/* lib_OpenCnt++	    */
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 */
	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* --lib_OpenCnt	    */
	jne	2f
	btst	#3,%a6@(14)		/* LIBF_DELEXP?		    */
	jeq	2f
	bsrs	_LibExpunge
2:	rts

	.globl	_LibExpunge
_LibExpunge:				/* -18 */
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	4,%a6			/* SysBase		    */
	tstw	%a5@(32)
	jeq	3f			/* opencnt==0: do it	    */
	bset	#3,%a5@(14)		/* set LIBF_DELEXP	    */
	moveq	#0,%d0
	jbra	4f
3:	movel	_segcell,%d2		/* saved seglist	    */
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove(lib)		    */
	bsrw	_LibNull		/* dead call (sic)	    */
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0		/* negsize		    */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + possize = total	    */
	moveal	4,%a6
	jsr	%a6@(-210)		/* FreeMem		    */
	movel	%d2,%d0			/* return seglist	    */
4:	moveml	%sp@+,%d2/%a5-%a6
	rts

	.globl	_Stub0			/* -24 null vector	    */
_Stub0:
	moveq	#0,%d0
_endscan:				/* rt_EndSkip lands here    */
	rts

_libname:
	.ascii	"xpkDUKE.library"
	.byte	0
_idstr:
	.ascii	"xpkDUKE 1.6 (08.06.1997)"	/* sic: no $VER: prefix */
	.byte	13,10,0
	.even

	.globl	_LibNull		/* -48 null vector; also    */
_LibNull:				/* called by LibInit/Expunge*/
	moveq	#0,%d0
	rts

/* ------------------------------------------------------------------ */
/* XpksPackerInfo -- original is "lea <data-hunk info>,a0; movel a0,d0" */
/* ------------------------------------------------------------------ */
	.globl	_XpksPackerInfo
_XpksPackerInfo:			/* -30 */
	moveal	#_xpkinfo,%a0
	movel	%a0,%d0
	rts

/* ------------------------------------------------------------------ */
/* Descriptor strings (CODE hunk in the original).			   */
/* ------------------------------------------------------------------ */
_s_name:
	.ascii	"DUKE"
	.byte	0,0
_s_longname:
	.ascii	"Duke"
	.byte	0,0,0
_s_basedesc:
	.ascii	"NUKE with a delta preprocessor"
	.byte	0,0
_s_packmsg:
	.ascii	"Duking"
	.byte	0,0
_s_unpackmsg:
	.ascii	"Unduking"
	.byte	0,0
_s_packedmsg:
	.ascii	"Duked"
	.byte	0,0
_s_unpackedmsg:
	.ascii	"Unduked"
	.byte	0
	.even

/* ------------------------------------------------------------------ */
/* Descriptors -- DATA hunk in the original.				   */
/*									   */
/* XpkMode "normal": Next=0 Upto=100 Flags=1 PackMemory=0x3805c	   */
/*   (= 92 hdr + 0x20000 tab1 + 0x10000 tab2 + 0x8000 scratch)	   */
/*   UnpackMemory=0x8000 PackSpeed=0x24 UnpackSpeed=0x276		   */
/*   Ratio=0x1c6 ChunkSize=0 "normal"					   */
/* ------------------------------------------------------------------ */
	.data
	.globl	_xpkmode
_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x3805c			/* xm_PackMemory	    */
	.long	0x8000			/* xm_UnpackMemory	    */
	.long	0x24			/* xm_PackSpeed	    */
	.long	0x276			/* xm_UnpackSpeed	    */
	.word	0x1c6			/* xm_Ratio = 454	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"normal"
	.byte	0,0

	.word	0			/* pad -- XpkInfo starts at  */
					/* +0x2a in the original     */
	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	0			/* xi_MasterVersion = 0     */
	.word	1			/* xi_ModesVersion = 1      */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x44554b45		/* xi_ID = 'DUKE'	    */
	.long	9			/* xi_Flags		    */
	.long	0x7530			/* xi_MaxPkInChunk	    */
	.long	10			/* xi_MinPkInChunk = 10     */
	.long	0x7530			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */
