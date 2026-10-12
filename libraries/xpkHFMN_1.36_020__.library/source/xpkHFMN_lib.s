	.file	"xpkHFMN_lib.s"
	.text

/*
**	xpkHFMN_lib.s -- resident module header for
**	xpkHFMN.library 1.36 "dyn. Huffman.020+ Version 1.36"
**	(Martin Hauner, 68020+ build, 13 Jun 1995).
**
**	Single code hunk; "moveq #-1,d0 / rts" entry stub; RomTag
**	RTF_AUTOINIT ver 1 NT_LIBRARY pri 0; InitTable dataSize 0x2a
**	(Library + seglist@34 + xpkdesc@38); InitStruct uses the
**	a0/e0/90/80 command encoding; FUNCTABLE = LONG offsets
**	relative to lib base, 0xffffffff terminator; LibInit stores
**	seglist@34 and the descriptor pointer @38.
**
**	Original vector map (offsets relative to lib base):
**	  -6  Open           -36 XpksPackChunk
**	  -12 Close          -42 bare rts stub (no PackFree -- per-call alloc)
**	  -18 Expunge        -48 bare rts stub (no PackReset -- MEMF_CLEAR)
**	  -24 return-0 stub  -54 XpksUnpackChunk
**	  -30 XpksPackerInfo -60 bare rts stub (no UnpackFree)
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
	.byte	0			/* rt_Pri = 0	    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkHFMN.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkHFMN V1.36 (Tue Jun 13 17:55:56 1995)"
	.byte	13,10,0
	.ascii	"by Martin Hauner 68020+ Version"
	.byte	0
	.even

	.globl	_inittab
_inittab:
	.long	0x2a			/* dataSize 42	    */
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
	.long	_retrts - _start	/* -42 bare rts	    */
	.long	_retrts - _start	/* -48 bare rts	    */
	.long	_XpksUnpackChunk - _start
	.long	_retrts - _start	/* -60 bare rts	    */
	.long	0xffffffff

/* InitStruct command stream (verbatim from the original):
 *   a0 off = byte, 90 off = word, 80 off = long; 0000 ends.	    */
_datatab:
	.byte	0xa0,0x08		/* ln_Type = 9	    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name	    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 1	    */
	.word	0x0001
	.byte	0x90,0x16		/* revision = 36    */
	.word	0x0024
	.byte	0x80,0x18		/* idstring	    */
	.long	_idstr
	.byte	0x00,0x00
	.even

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
	.long	0x48464d4e		/* xi_ID = 'HFMN'	    */
	.long	9			/* xi_Flags		    */
	.long	0xffff			/* xi_MaxPkInChunk	    */
	.long	0x0c			/* xi_MinPkInChunk = 12   */
	.long	0xffff			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg	    */
	.long	_s_unpackmsg		/* xi_UnpackMsg	    */
	.long	_s_packedmsg		/* xi_PackedMsg	    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0			/* xi_DefMode		    */
	.word	0			/* xi_Pad		    */
	.long	_s_xpkmode		/* xi_ModeDesc	    */
	.long	0,0,0,0,0,0		/* xi_Reserved	    */

/* XpkMode " normal ": verbatim fields from the original. */
_s_xpkmode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	0			/* xm_Flags		    */
	.long	0x1a0a			/* xm_PackMemory	    */
	.long	0x19fa			/* xm_UnpackMemory	    */
	.long	0x103			/* xm_PackSpeed = 259	    */
	.long	0xd1			/* xm_UnpackSpeed = 209    */
	.word	0xf7			/* xm_Ratio = 247	    */
	.word	0x3f			/* xm_ChunkSize = 63	    */
	.ascii	" normal "
	.byte	0,0			/* xm_Description[10]	    */

_s_name:
	.ascii	"HFMN"
	.byte	0
_s_longname:
	.ascii	"dyn. Huffman.020+ Version 1.36 "
	.byte	0
_s_basedesc:
	.ascii	"fast dynamic Huffman compression/decompression."
	.byte	0
_s_packmsg:
	.ascii	"packing"
	.byte	0
_s_unpackmsg:
	.ascii	"unpacking"
	.byte	0
_s_packedmsg:
	.ascii	"packed"
	.byte	0
_s_unpackedmsg:
	.ascii	"unpacked"
	.byte	0
	.even

/* ------------------------------------------------------------------ */
/*	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.	    */
/*	Stores seglist@34 and the descriptor pointer @38.	    */
/* ------------------------------------------------------------------ */
	.globl	_LibInit
_LibInit:
	moveml	%a4/%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* seglist		    */
	lea	_xpkinfo(%pc),%a4	/* descriptor (PC-rel, no reloc) */
	movel	%a4,%a5@(38)
	moveml	%sp@+,%a4/%a5
	rts

/* ------------------------------------------------------------------ */
/*	stubs								    */
/* ------------------------------------------------------------------ */
	.globl	_ret0
_ret0:					/* -24 */
	moveq	#0,%d0
	rts

	.globl	_retrts
_retrts:				/* -42/-48/-60 */
	rts
