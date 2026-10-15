|||
|||	xpkHUFF_lib.s -- resident/AutoInit structure, XPK info
|||	descriptor and LibInit for xpkHUFF.library 0.64
|||	(01.04.1997).
|||
|||	Reconstructed layout (original hunk offsets):
|||	  0x00  entry stub (moveq #0,d0; rts), EndSkip
|||	  0x04  RomTag 0x4afc / AUTOINIT
|||	  0x1e  InitTable {dataSize 0x22, functab@0x2e,
|||	        datatab@0x5a, initfunc@0x7e}
|||	  0x2e  absolute-long functab, 10 vectors + -1
|||	  0x5a  data table (type/name/flags/ver/rev/idstr)
|||	  0x7a  seglist cell (LibInit writes, Expunge reads)
|||	  0x7e  LibInit
|||	  0x9e  LibOpen   0xac LibClose   0xc0 LibExpunge
|||	  0x100 null stub (-24)   0x130 null stub (-42/-48/-60)
|||	  0x134 XpksPackerInfo    0x13c pack   0x474 unpack
|||	  0x104 "xpkHUFF.library" 0x114 "xpkHUFF 0.64 ..."
|||	  0x740 XpkInfo descriptor / mode record / strings
|||

	.section .text

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endmodule
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0			/* version 0		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_inittab
_inittab:
	.long	0x22			/* dataSize 34: bare Library */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* absolute-longword function table, 10 vectors		    */
	.globl	_functab
_functab:
	.long	_LibOpen		/* -6			    */
	.long	_LibClose		/* -12			    */
	.long	_LibExpunge		/* -18			    */
	.long	_libret0		/* -24			    */
	.long	_XpksPackerInfo		/* -30			    */
	.long	_XpksPackChunk		/* -36			    */
	.long	_libnull		/* -42			    */
	.long	_libnull		/* -48			    */
	.long	_XpksUnpackChunk	/* -54			    */
	.long	_libnull		/* -60			    */
	.long	-1			/* terminator		    */

	.globl	_datatab
_datatab:
	.byte	0xa0,0x08		/* ln_Type = 9		    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 0		    */
	.word	0x0000
	.byte	0x90,0x16		/* revision = 64	    */
	.word	0x0040
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

/* code-resident seglist cell: LibInit stores the seglist here
 * (the original's `move.l a0,$7a` absolute store gets a hunk
 * relocation, so it lands on this cell at runtime); LibExpunge
 * reads it back pc-relative.					    */
	.globl	_segcell
_segcell:
	.long	0

/*	LibInit -- a0 = seglist, d0 = libbase, a6 = execbase.
**	Stores the seglist in the code cell.  The two BSRs to
**	_libnull are the original's dead vestigial init/cleanup
**	calls; the second is unreachable (stub returns d0=0). */
	.even
	.globl	_LibInit
_LibInit:
	movel	%a5,-(%sp)
	moveal	%d0,%a5
	movel	%a0,_segcell
	bsr.s	_libnull		/* dead call		    */
	tstl	%d0
	bnes	1f
	movel	%a5,%d0
2:	moveal	(%sp)+,%a5
	rts
1:	bsr.s	_libnull		/* unreachable		    */
	moveq	#0,%d0
	bra.s	2b

/* the two null stubs (0x100 / 0x130 in the original)	    */
	.even
	.globl	_libret0
_libret0:
	moveq	#0,%d0
	rts
	.globl	_libnull
_libnull:
	moveq	#0,%d0
	rts

/* ------------------------------------------------------------ */
/* strings							    */
/* ------------------------------------------------------------ */

	.globl	_libname
_libname:
	.ascii	"xpkHUFF.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"xpkHUFF 0.64 (01.04.1997)"
	.byte	13,10,0
	.even

/* ------------------------------------------------------------ */
/* XpkInfo descriptor + mode record + strings		    */
/* ------------------------------------------------------------ */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	0			/* xi_LibVersion	    */
	.word	1			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "HUFF"	    */
	.long	_s_longname		/* xi_LongName "Huffman"    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x48554646		/* xi_ID = 'HUFF'	    */
	.long	0x2009			/* xi_Flags		    */
	.long	0xfffe			/* xi_MaxPkInChunk	    */
	.long	1			/* xi_MinPkInChunk	    */
	.long	0xfffe			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg "Crunching"   */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode			/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_mode:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x7324			/* xm_PackMemory = 29476    */
	.long	0x1141a			/* xm_UnpackMemory = 70682  */
	.long	0x58			/* xm_PackSpeed = 88	    */
	.long	0x8a			/* xm_UnpackSpeed = 138	    */
	.word	0xf1			/* xm_Ratio = 241	    */
	.word	0x3f			/* xm_ChunkSize = 63?	    */
	.ascii	"normal"
	.byte	0,0,0,0			/* name padded to 10	    */

_s_name:
	.ascii	"HUFF"
	.byte	0
_s_longname:
	.ascii	"Huffman"
	.byte	0
_s_basedesc:
	.ascii	"Dynamic huffman crunch algorithm, cache optimized byte decrunch algorithm"
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

	.globl	_endmodule
_endmodule:
