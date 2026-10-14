	.file	"xpkDUKE_lib.s"
	.text

/*
**	xpkDUKE_lib.s -- resident module header for
**	xpkDUKE.library V1.8(000) "Duke" (1 Oct 2013, C. von Roques).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub; RomTag
**	(RTF_AUTOINIT, ver 1, NT_LIBRARY); rt_EndSkip = 0 (sic);
**	InitTable dataSize 0x26; InitStruct datatab; relative-offset
**	FUNCTABLE (genfunctab.py); LibInit stores the seglist at base+34.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 LibNull (entry stub at code+0)
**	  -12 Close          -30 XpksPackerInfo (lea _xpkinfo)
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 LibNull (stub)
**	                     -54 XpksUnpackChunk
**	                     -60 LibNull (stub)
**
**	The -24/-48/-60 vectors point at the entry stub at code+0
**	(functab offset -functab), not at a separate LibNull.
*/

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	0			/* rt_EndSkip = 0 (sic)	    */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkDUKE.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkDUKE V1.8 (1 Oct 2013) by Christian von Roques"
	.byte	13,10,0
	.even

	.globl	_inittab
_inittab:
	.long	0x26			/* dataSize 38		    */
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
	.byte	0x90,0x16		/* revision = 8		    */
	.word	0x0008
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.even

/* ------------------------------------------------------------------ */
/* XpkInfo descriptor (0x90c in the original).			    */
/* ------------------------------------------------------------------ */
	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion = 2     */
	.word	0			/* xi_ModesVersion = 0      */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x44554b45		/* xi_ID = 'DUKE'	    */
	.long	9			/* xi_Flags		    */
	.long	0x7530			/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk = 0      */
	.long	0x7530			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* XpkMode "normal" (0x964 in the original), xi_ModeDesc target. */
	.globl	_xpkmode
_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x3758c			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x27			/* xm_PackSpeed	    */
	.long	0x15e			/* xm_UnpackSpeed	    */
	.word	0x143			/* xm_Ratio = 323	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"normal"
	.byte	0,0

_s_name:
	.ascii	"DUKE"
	.byte	0
_s_longname:
	.ascii	"Duke V1.8"
	.byte	0
_s_basedesc:
	.ascii	"NUKE with a delta preprocessor"
	.byte	0
_s_packmsg:
	.ascii	"Duking"
	.byte	0
_s_unpackmsg:
	.ascii	"Unduking"
	.byte	0
_s_packedmsg:
	.ascii	"Duked"
	.byte	0
_s_unpackedmsg:
	.ascii	"Unduked"
	.byte	0
	.even

/*
**	LibInit -- a0 = seglist, d0 = libbase.  Stores the seglist at
**	base+34 (base is 38 bytes) and returns d0.  No CPU gate.
*/
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts

/* ------------------------------------------------------------------ */
/* Lifecycle vectors -- transcribed from the original (code 0xb8..).   */
/* The library base arrives in a6 per the LVO convention.  The null    */
/* vectors -24/-48/-60 land on the code+0 stub via the functab.        */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6 */
	addqw	#1,%a6@(32)		/* lib_OpenCnt++	    */
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 */
	subqw	#1,%a6@(32)		/* --lib_OpenCnt	    */
	jne	_start			/* !=0: ret 0 via stub	    */
	btst	#3,%a6@(14)		/* LIBF_DELEXP?	    */
	jeq	_start			/* not set: ret 0	    */
	/* fall through to Expunge */

	.globl	_LibExpunge
_LibExpunge:				/* -18 */
	tstw	%a6@(32)
	beqs	1f			/* opencnt==0: do it	    */
	bset	#3,%a6@(14)		/* set LIBF_DELEXP	    */
	jbra	_start			/* ret 0 via stub	    */
1:	moveml	%d2/%a5-%a6,%sp@-
	movel	%a6@(34),%d2		/* seglist		    */
	moveal	%a6,%a5
	moveal	%a5,%a1
	moveal	4,%a6			/* SysBase		    */
	jsr	%a6@(-252)		/* Remove(lib)		    */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* negsize		    */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + possize = total	    */
	jsr	%a6@(-210)		/* FreeMem		    */
	movel	%d2,%d0			/* return seglist	    */
	moveml	%sp@+,%d2/%a5-%a6
	rts

/* rt_EndSkip in the original is 0; _TagEnd is still defined by tail.s
** (linked last) for bookkeeping but is no longer referenced. */
	.globl	_TagEnd
