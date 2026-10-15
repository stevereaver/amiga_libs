	.file	"xpkNUKE_lib.s"
	.text

/*
**	xpkNUKE_lib.s -- resident module header for
**	xpkNUKE.library 1.7 "Nuke" (06.06.1997).
**
**	Older-generation skeleton than xpkNUKE 1.8/1.9: TWO hunks
**	(HUNK_CODE + HUNK_DATA for the XpkMode/XpkInfo descriptors),
**	an ABSOLUTE-address function table (longwords, -1 terminator,
**	no 0xffff word-offset marker), dataSize 0x22 (plain Library --
**	the seglist is NOT kept in the base but in a code-segment slot
**	at code+0x7a), and the entry stub returns -1 (sic).
**
**	Original vector map (absolute longs at code+0x2e):
**	  -6  Open  (0x9e)   -24 LibNull24 (0x104, own stub)
**	  -12 Close (0xac)   -30 XpksPackerInfo (0x848, lea info.L)
**	  -18 Expunge(0xc0)  -36 XpksPackChunk  (0x952 wrapper)
**	                     -42 XpksPackFree   (0x8b6)
**	                     -48 LibNull (0x134)
**	                     -54 XpksUnpackChunk (0x9c6 wrapper)
**	                     -60 LibNull (0x134)
**
**	Everything through the -24 null stub (0x104) is reproduced
**	byte-for-byte; rt_EndSkip (0x106) points just past it.
*/

	.globl	_start
_start:					/* 0x000 */
	moveq	#-1,%d0			/* sic: entry stub returns -1 */
	rts

	.globl	_romtag
_romtag:				/* 0x004 */
	.word	0x4afc
	.long	_romtag
	.long	_TagEnd			/* rt_EndSkip = 0x106	     */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_inittab
_inittab:				/* 0x01e */
	.long	0x22			/* dataSize 34 = Library only */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* absolute-address functab (0x02e): ten longs + 0xffffffff terminator */
	.globl	_functab
_functab:
	.long	_LibOpen		/* -6   Open		0x9e  */
	.long	_LibClose		/* -12  Close		0xac  */
	.long	_LibExpunge		/* -18  Expunge		0xc0  */
	.long	_libnull24		/* -24  reserved	0x104 */
	.long	_XpksPackerInfo		/* -30  PackerInfo	0x848 */
	.long	_XpksPackChunk		/* -36  PackChunk	0x952 */
	.long	_XpksPackFree		/* -42  PackFree	0x8b6 */
	.long	_libnull		/* -48  reserved	0x134 */
	.long	_XpksUnpackChunk	/* -54  UnpackChunk	0x9c6 */
	.long	_libnull		/* -60  reserved	0x134 */
	.long	-1

_datatab:				/* 0x05a */
	.byte	0xa0,0x08		/* ln_Type = 9		    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 1		    */
	.word	0x0001
	.byte	0x90,0x16		/* revision = 7		    */
	.word	0x0007
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00
	.word	0			/* pad word @0x78	    */

/* Runtime seglist slot (0x07a).  In this generation the seglist is
** stored in the code hunk, not in the library base (dataSize=0x22 has
** no room for it).  LibInit writes it; Expunge reads it PC-relative. */
	.globl	_seglist
_seglist:
	.long	0

/*
**	LibInit -- a0 = seglist, d0 = libbase.  Calls the (stubbed)
**	PostInit hook at _libnull; on its 0 return the libbase is
**	returned, on nonzero the hook is called again and 0 is
**	returned (dead path -- the stub always returns 0).
*/
	.globl	_LibInit
_LibInit:				/* 0x07e */
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,_seglist		/* seglist -> code+0x7a	    */
	bsrw	_libnull		/* PostInit hook (stub)	    */
	tstl	%d0
	bnes	1f
	movel	%a5,%d0			/* return libbase	    */
2:	moveal	%sp@+,%a5
	rts
1:	bsrw	_libnull
	moveq	#0,%d0			/* init failed -> 0	    */
	bras	2b

/* ------------------------------------------------------------------ */
/* Lifecycle vectors -- transcribed from the original (code 0x9e..).   */
/* ------------------------------------------------------------------ */

	.globl	_LibOpen
_LibOpen:				/* -6  (0x9e) */
	addqw	#1,%a6@(32)		/* lib_OpenCnt++	    */
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

	.globl	_LibClose
_LibClose:				/* -12 (0xac) */
	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* --lib_OpenCnt	    */
	bnes	1f
	btst	#3,%a6@(14)		/* LIBF_DELEXP?		    */
	beqs	1f
	bsrs	_LibExpunge		/* tail call via bsr        */
1:	rts

	.globl	_LibExpunge
_LibExpunge:				/* -18 (0xc0) */
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5			/* lib base		    */
	moveal	4,%a6			/* SysBase		    */
	tstw	%a5@(32)		/* open count		    */
	beqs	1f
	bset	#3,%a5@(14)		/* set LIBF_DELEXP	    */
	moveq	#0,%d0
	bras	2f
1:	movel	%pc@(_seglist-2-.),%d2	/* seglist (code slot)	    */
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove(lib)		    */
	bsrs	_libnull		/* sic: calls stub, discards */
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0		/* negsize		    */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + possize = total	    */
	moveal	4,%a6			/* SysBase (redundant, sic) */
	jsr	%a6@(-210)		/* FreeMem		    */
	movel	%d2,%d0			/* return seglist	    */
2:	moveml	%sp@+,%d2/%a5-%a6
	rts

/* -24 vector target (0x104): its own null stub, distinct from
** _libnull at 0x134.  rt_EndSkip = 0x106 points mid-stub at the
** rts -- sic. */
_libnull24:
	moveq	#0,%d0
	.globl	_TagEnd			/* rt_EndSkip -> stub rts   */
_TagEnd:
	rts

_libname:				/* 0x108 */
	.ascii	"xpkNUKE.library"
	.byte	0
_idstr:					/* 0x118 */
	.ascii	"xpkNUKE 1.7 (06.06.1997)"	/* sic: no "$VER:" cookie */
	.byte	13,10,0,0

/* -48/-60 vector target (0x134): also the PostInit hook stub called
** by LibInit and (pointlessly) by Expunge. */
	.globl	_libnull
_libnull:
	moveq	#0,%d0
	rts

/* ------------------------------------------------------------------ */
/* Descriptor strings -- code-hunk residents in the original           */
/* (0x852..0x8b5), the data-hunk XpkInfo points up here.               */
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

/* ------------------------------------------------------------------ */
/* Data hunk (hunk1 in the original, 0x84 bytes): XpkMode "normal" at   */
/* +0x00, one pad word, XpkInfo at +0x2a.  XpksPackerInfo (0x848) does */
/* lea (hunk1+0x2a).l so XpkInfo deliberately sits at an odd offset.   */
/* ------------------------------------------------------------------ */

	.data
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

	.word	0			/* pad: XpkInfo @ +0x2a   */

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
	.byte	0,0			/* pad to 0x84		    */
