	.file	"xpkACCA_lib.s"
	.text

/*
**	xpkACCA_lib.s -- resident module header for
**	xpkACCA.library 1.2 "Andre's Code Compression V1.2"
**	(1 Oct 2013) by Andre Osterhues.
**
**	Single code hunk; "moveq #0,d0 / rts" entry stub (also the
**	-24 AND -60 vector targets via a negative offset); packed
**	RomTag (RTF_AUTOINIT, ver 1, NT_LIBRARY); InitTable with
**	dataSize 0x26 and a word-offset FUNCTABLE (genfunctab.py);
**	LibInit stores the seglist at base+34.
**
**	Original vector map (offsets relative to functab):
**	  -6  Open           -24 entry stub (moveq #0,rts; off -0x94)
**	  -12 Close          -30 XpksPackerInfo
**	  -18 Expunge        -36 XpksPackChunk
**	                     -42 XpksPackFree
**	                     -48 XpksPackReset (workmem wipe)
**	                     -54 XpksUnpackChunk
**	                     -60 XpksUnpackFree == entry stub (sic)
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
	.ascii	"xpkACCA.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkACCA V1.2 (1 Oct 2013) by Andr\351 Osterhues"
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
	.long	0x41434341		/* xi_ID = 'ACCA'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0xffdc			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x64			/* xi_DefMode = 100	    */
	.word	0			/* xi_Pad		    */
	.long	_s_xpkmode0		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* mode list: an empty 28-byte head record (sic), then turbo, crawling */
_s_xpkmode0:
	.long	_s_xpkmode1		/* xm_Next		    */
	.long	0,0,0,0,0,0
_s_xpkmode1:
	.long	_s_xpkmode2		/* xm_Next		    */
	.long	79			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x4004			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x9d			/* xm_PackSpeed	    */
	.long	0x190			/* xm_UnpackSpeed	    */
	.word	0x151			/* xm_Ratio = 337	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"turbo"
	.byte	0,0,0,0,0
_s_xpkmode2:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x48004			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x28			/* xm_PackSpeed	    */
	.long	0x190			/* xm_UnpackSpeed	    */
	.word	0x190			/* xm_Ratio = 400	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"crawling"
	.byte	0,0

_s_name:
	.ascii	"ACCA"
	.byte	0
_s_longname:
	.ascii	"Andre's Code Compression V1.2"
	.byte	0
_s_basedesc:
	.ascii	"Similar to RDCN, but more efficient"
	.byte	0
_s_packmsg:
	.ascii	"Crunching"
	.byte	0
_s_unpackmsg:
	.ascii	"Decrunching"
	.byte	0
_s_packedmsg:
	.ascii	"Crunched"
	.byte	0
_s_unpackedmsg:
	.ascii	"Decrunched"
	.byte	0
	.even

/*
**	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
**	Stores the seglist at base+34 and returns.
*/
	.balign	2,0
	.globl	_LibInit
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* seglist		    */
	rts
