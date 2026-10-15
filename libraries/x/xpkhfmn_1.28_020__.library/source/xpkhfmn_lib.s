/*
** xpkhfmn.library V1.28 -- reconstruction skeleton
** "xpkHFMN.library Version 1.28 (Thu Sep 22 18:47:29 1994)
**  (c) Martin Hauner 68020+ Version"
**
** AUTOINIT library with LONG-offset function table (the 1.4
** sibling uses word offsets).  DataSize 0x2a = Library(34) +
** seglist(4) + descriptor ptr(4).  Init stores the seglist at
** +34 and a pointer to the xpk descriptor at +38.
**
** Vectors:
**   -6  LibOpen            -36 XpksPackChunk   (020+ Huffman pack)
**  -12  LibClose           -42 rts stub
**  -18  LibExpunge         -48 rts stub
**  -24  reserved (0)       -54 XpksUnpackChunk (codegen decoder)
**  -30  XpksPackerInfo     -60 rts stub
*/

	.text
	.even

/* ---- hunk+0x00: stub + vestigial alloc-size words ----------------- */
	moveq	#-1,d0				/* 0x00 70ff	    */
	rts					/* 0x02 4e75	    */
	.word	0x1a0a				/* pack workmem	    */
	.word	0x19fa				/* unpack workmem   */

/* ---- RomTag -------------------------------------------------------- */
	.globl	_RomTag
_RomTag:
	.word	0x4afc
	.long	_RomTag
	.long	_TagEnd
	.byte	0x80,1				/* RTF_AUTOINIT, ver 1 */
	.byte	9,0				/* NT_LIBRARY, pri 0  */
	.long	_hfmn_name
	.long	_hfmn_idstr
	.long	_hfmn_init

/* ---- strings -------------------------------------------------------- */
_hfmn_name:
	.ascii	"xpkHFMN.library"
	.byte	0
	.even
_hfmn_idstr:
	.ascii	"xpkHFMN.library Version 1.28 (Thu Sep 22 18:47:29 1994) \251 Martin Hauner 68020+ Version"
	.byte	0
	.even

/* ---- AUTOINIT table ------------------------------------------------- */
	.balign	4,0
_hfmn_init:
	.long	0x2a				/* dataSize 42	    */
	.long	_hfmn_functab
	.long	_hfmn_datatab
	.long	_hfmn_initfn

/* ---- LONG-offset function table ------------------------------------- */
_hfmn_functab:
	.long	_LibOpen			/* -6		    */
	.long	_LibClose			/* -12		    */
	.long	_LibExpunge			/* -18		    */
	.long	_hfmn_reserved			/* -24		    */
	.long	_XpksPackerInfo			/* -30		    */
	.long	_XpksPackChunk			/* -36		    */
	.long	_hfmn_rts42			/* -42		    */
	.long	_hfmn_rts48			/* -48		    */
	.long	_XpksUnpackChunk		/* -54		    */
	.long	_hfmn_rts60			/* -60		    */
	.long	-1

/* ---- data table ------------------------------------------------------ */
_hfmn_datatab:
	.byte	0xa0,0x08,0x09,0x00		/* byte  @8  = 9   ln_Type    */
	.byte	0x80,0x0a
	.long	_hfmn_name			/* long  @10     ln_Name    */
	.byte	0xa0,0x0e,0x06,0x00		/* byte  @14 = 6   lib_Flags  */
	.byte	0x90,0x14
	.word	1				/* word  @20     lib_Version */
	.byte	0x90,0x16
	.word	28				/* word  @22     lib_Revision*/
	.byte	0x80,0x18
	.long	_hfmn_idstr			/* long  @24     lib_IdString*/
	.word	0				/* terminator		    */
	.even

/* ---- init function: store seglist + descriptor ptr ------------------- */
_hfmn_initfn:
	moveml	a4-a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)			/* seglist	    */
	lea	_hfmn_xpkinfo(%pc),%a4
	movel	%a4,%a5@(38)			/* descriptor ptr    */
	moveml	%sp@+,a4-a5
	rts

/* ---- dedicated vector stubs ----------------------------------------- */
_hfmn_rts42:
	rts
_hfmn_rts48:
	rts
_hfmn_rts60:
	rts
_hfmn_reserved:
	moveq	#0,%d0
	rts

/* ---- dead example bytes from the original (generated-code sample,
**      never referenced -- kept for fidelity) ------------------------- */
_hfmn_dead:
	.word	0x4e71				/* nop		    */
	.word	0xd080,0x6400,0x0000		/* example node	    */
	.word	0x7200,0x14c1,0x7200		/* example leaf	    */
	.word	0x51cf,0x0000
	.word	0x47e5

/* ---- XPK sublibrary descriptor (88 bytes) ----------------------------- */
	.even
_hfmn_xpkinfo:
	.word	1				/* xi_XpkInfoVersion  */
	.word	1				/* xi_LibVersion	    */
	.word	2				/* xi_MasterVersion    */
	.word	0				/* xi_ModesVersion    */
	.long	_s_xname			/* xi_Name -> "HFMN"  */
	.long	_s_xlongname			/* xi_LongName	    */
	.long	_s_xdesc			/* xi_Description	    */
	.long	0x48464d4e			/* xi_ID = 'HFMN'	    */
	.long	9				/* xi_Flags	    */
	.long	0xffff				/* xi_MaxPkInChunk    */
	.long	0x0c				/* xi_MinPkInChunk=12 */
	.long	0xffff				/* xi_DefPkInChunk    */
	.long	_s_xpackmsg			/* xi_PackMsg	    */
	.long	_s_xunpackmsg			/* xi_UnpackMsg	    */
	.long	_s_xpackedmsg			/* xi_PackedMsg	    */
	.long	_s_xunpackedmsg			/* xi_UnpackedMsg    */
	.word	0				/* xi_DefMode = 0	    */
	.word	0				/* xi_Pad		    */
	.long	_hfmn_xmodes			/* xi_ModeDesc	    */
	.long	0,0,0,0,0,0			/* xi_Reserved	    */

_s_xname:
	.ascii	"HFMN"
	.byte	0
_s_xlongname:
	.ascii	"dyn. Huffman.020+ Version 1.28 "
	.byte	0
_s_xdesc:
	.ascii	"fast dynamic Huffman compression/decompression."
	.byte	0
_s_xpackmsg:
	.ascii	"packing"
	.byte	0
_s_xunpackmsg:
	.ascii	"unpacking"
	.byte	0
_s_xpackedmsg:
	.ascii	"packed"
	.byte	0
_s_xunpackedmsg:
	.ascii	"unpacked"
	.byte	0
	.even

/* ---- mode table: one mode, inline name ------------------------------- */
_hfmn_xmodes:
	.long	0				/* xm_Next	    */
	.long	0x64				/* xm_Upto = 100	    */
	.long	0				/* xm_Flags	    */
	.long	0x1a0a				/* xm_PackMemory    */
	.long	0x19fa				/* xm_UnpackMemory  */
	.long	0x103				/* xm_PackSpeed	    */
	.long	0xd1				/* xm_UnpackSpeed   */
	.word	0x00f7				/* xm_Ratio	    */
	.word	0x003f				/* xm_ChunkSize	    */
	.ascii	" normal "			/* xm_Name inline    */
	.byte	0
	.even

	.globl	_TagEnd
_TagEnd:
