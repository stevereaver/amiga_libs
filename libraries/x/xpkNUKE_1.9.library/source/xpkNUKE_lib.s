	.file	"xpkNUKE_lib.s"
	.text

/*
**	xpkNUKE_lib.s -- resident module header for
**	xpkNUKE.library 1.9 "Nuke" (05.08.2011).
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub; packed RomTag
**	(RTF_AUTOINIT, ver 1, NT_LIBRARY); rt_EndSkip points at end of
**	hunk; InitTable dataSize 0x26 (Library + seglist@38); word-offset
**	FUNCTABLE (genfunctab.py); LibInit stores the seglist at base+38.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 LibNull (moveq #0,rts)
**	  -12 Close          -30 XpksPackerInfo (lea _xpkinfo)
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 LibNull
**	                     -54 XpksUnpackChunk
**	                     -60 LibNull
*/

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_TagEnd			/* rt_EndSkip -> end of hunk */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkNUKE.library"
	.byte	0
_idstr:
	.ascii	"xpkNUKE 1.9 (05.08.2011)"	/* sic: no "$VER:" cookie */
	.byte	13,10,0
	.even

	.globl	_inittab
_inittab:
	.long	0x26			/* dataSize 38: Library+seg@38 */
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
	.byte	0x90,0x16		/* revision = 9		    */
	.word	0x0009
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.even

/* ------------------------------------------------------------------ */
/* Descriptor strings, XpkMode, XpkInfo -- verbatim from the original  */
/* ------------------------------------------------------------------ */

_s_name:
	.ascii	"NUKE"
	.byte	0,0
_s_longname:
	.ascii	"Nuke"
	.byte	0,0
_s_basedesc:
	.ascii	"A relatively efficient packer that unpacks very quickly"
	.byte	0
_s_packmsg:
	.ascii	"Nuking"
	.byte	0,0
_s_unpackmsg:
	.ascii	"Unnuking"
	.byte	0,0
_s_packedmsg:
	.ascii	"Nuked"
	.byte	0
_s_unpackedmsg:
	.ascii	"Unnuked"
	.byte	0
	.even

/* XpkMode "normal" (0xf6 in the original), xi_ModeDesc target. */
	.globl	_xpkmode
_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x3005c			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x24			/* xm_PackSpeed	    */
	.long	0x276			/* xm_UnpackSpeed	    */
	.word	0x1c6			/* xm_Ratio = 454	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"normal"
	.byte	0,0
	.even

/* XpkInfo (0x120 in the original), XpksPackerInfo returns its address. */
	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	0			/* xi_MasterVersion	    */
	.word	1			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name		    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x4e554b45		/* xi_ID = 'NUKE'	    */
	.long	9			/* xi_Flags		    */
	.long	0x7530			/* xi_MaxPkInChunk	    */
	.long	10			/* xi_MinPkInChunk	    */
	.long	0x7530			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_xpkmode		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

	.word	0x4e71			/* stray filler word @0x17a  */

/*
**	LibInit -- a0 = seglist, d0 = libbase.  Stores the seglist at
**	base+38 and returns d0 (the libbase).  No CPU gate.
*/
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(38)		/* seglist		    */
	rts

/* ------------------------------------------------------------------ */
/* Lifecycle vectors -- transcribed from the original (code 0x244..).  */
/* The library base arrives in a6 per the LVO convention.              */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6 */
	addqw	#1,%a6@(32)		/* lib_OpenCnt++	    */
	andib	#-9,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 */
	subqw	#1,%a6@(32)		/* --lib_OpenCnt	    */
	bnes	_LibNull
	btst	#3,%a6@(14)		/* LIBF_DELEXP?	    */
	beqs	_LibNull
	/* fall through to Expunge */

	.globl	_LibExpunge
_LibExpunge:				/* -18 */
	tstw	%a6@(32)
	bnes	1f
	moveal	%a6,%a1
	movel	%a6@(38),%sp@-		/* seglist		    */
	movel	%a6,%sp@-		/* lib base		    */
	moveal	4,%a6			/* SysBase		    */
	jsr	%a6@(-252)		/* Remove(lib)		    */
	moveal	%sp@,%a0
	moveal	%sp@,%a1
	moveq	#0,%d0
	movew	%a0@(16),%d0		/* negsize		    */
	subal	%d0,%a1
	addw	%a0@(18),%d0		/* + possize = total	    */
	jsr	%a6@(-210)		/* FreeMem		    */
	moveal	%sp@+,%a6
	movel	%sp@+,%d0		/* seglist		    */
	rts
1:	orib	#8,%a6@(14)		/* set LIBF_DELEXP	    */

/* LibNull -- target of the unused vectors -24/-48/-60 (0x296 in the
** original).  Returns 0 like _start but is a distinct routine there. */
	.globl	_LibNull
_LibNull:
	moveq	#0,%d0
	rts

/* _TagEnd is defined in tail.s, which links last, so rt_EndSkip points
** past the end of the whole code hunk (as in the original: 0x928). */
	.globl	_TagEnd
