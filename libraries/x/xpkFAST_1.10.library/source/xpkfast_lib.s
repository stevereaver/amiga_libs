|||
|||	xpkfast_lib.s -- RomTag, init table, data table,
|||	descriptor and LibInit for xpkFAST.library V1.10.
||||
|||	Original code-hunk layout:
|||	  0x00  EndSkip stub (moveq #-1,d0; rts -- returns -1!)
|||	  0x04  RomTag 0x4afc / AUTOINIT
|||		(matchtag longword NOT relocated in the shipped
|||		 binary -- it stays the literal offset 4; same
|||		 quirk as 1.06.  Reproduced verbatim.)
|||	  0x1e  init struct (dataSize 0x22 = bare Library)
|||	  0x2e  function table (LONG absolute entries + -1)
|||	  0x5a  data table (ln_Type fixed to +8 in 1.10)
|||	  0x7a  segslot -- the consumed datatab tail is reused as
|||		the seglist cell via an ABSOLUTE.LONG store that a
|||		hunk reloc redirects to code+0x7a
|||	  0x7e  LibInit
|||	  tail  XpkInfo descriptor + mode chain + strings
|||

	.section .text

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	4			/* rt_MatchTag -- UNRELOCATED
					   literal offset, as shipped */
	.long	_libname		/* EndSkip -> libname (0x108) */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_inittab
_inittab:
	.long	0x22			/* dataSize 34: bare Library   */
	.long	_functab
	.long	_datatab
	.long	_LibInit

	.globl	_functab
_functab:
	.long	_LibOpen		/* -6   Open		    */
	.long	_LibClose		/* -12  Close		    */
	.long	_LibExpunge		/* -18  Expunge		    */
	.long	_LibStub		/* -24  ExtFunc stub	    */
	.long	_XpksPackerInfo		/* -30  XpksPackerInfo	    */
	.long	_XpksPackChunk		/* -36  XpksPackChunk	    */
	.long	_XpksPackFree		/* -42  XpksPackFree	    */
	.long	_LibStub		/* -48  XpksPackReset stub  */
	.long	_XpksUnpackChunk	/* -54  XpksUnpackChunk	    */
	.long	_LibStub		/* -60  UnpackReset stub    */
	.long	-1			/* terminator		    */

_datatab:
	.byte	0xa0,0x08		/* byte @0x08 = 9 -- ln_Type  */
	.byte	0x09,0x00		/* at the correct offset in   */
					/* 1.10 (1.06 wrote +12)	    */
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6		    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* lib_Version = 1	    */
	.word	0x0001
	.byte	0x90,0x16		/* lib_Revision = 10	    */
	.word	0x000a
	.byte	0x80,0x18		/* lib_IdString		    */
	.long	_idstr
	.word	0			/* InitStruct end	    */
	.word	0			/* pad -- original had the   */
					/* same dead cell before the */
					/* slot			    */
	.globl	_segslot
_segslot:
	.long	0			/* seglist cell -- LibInit   */
					/* writes it post-InitStruct */

_LibInit:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,_segslot		/* abs.L store, relocated ->   */
					/* the slot above		    */
	bsrw	_LibStub		/* dead hook (stub returns 0)  */
	tstl	%d0
	bnes	.Lfail			/* never taken		    */
	movel	%a5,%d0
.Lout:
	moveal	%sp@+,%a5
	rts
.Lfail:
	bsrw	_LibStub		/* dead cleanup path	    */
	moveq	#0,%d0
	bras	.Lout

_libname:
	.ascii	"xpkFAST.library"
	.byte	0
_idstr:
	.ascii	"xpkFAST 1.10 (20.09.1998)"
	.byte	13,10,0			/* no $VER: cookie in 1.10   */
	.even

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	1			/* xi_LibVersion	    */
	.word	2			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "fasTcinator"    */
	.long	_s_longname		/* xi_LongName		    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x46415354		/* xi_ID = 'FAST'	    */
	.long	0x8009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0			/* xi_MinPkInChunk	    */
	.long	0x10000			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg "tieing"	    */
	.long	_s_unpackmsg		/* xi_UnpackMsg "untieing"  */
	.long	_s_packedmsg		/* xi_PackedMsg "compressed"*/
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode0		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

_s_name:
	.ascii	"fasTcinator"
	.byte	0
	.even
_s_longname:
	.ascii	"FAST alias WOOP or LZRW++"
	.byte	0
	.even
_s_basedesc:
	.ascii	"LZ77-family, windowsize: 4095, no quotecount, 2 streams"
	.byte	0
_s_packmsg:
	.ascii	"tieing"
	.byte	0
_s_packedmsg:
	.ascii	"compressed"
	.byte	0
_s_unpackmsg:
	.ascii	"untieing"
	.byte	0
_s_unpackedmsg:
	.ascii	"decompressed"
	.byte	0
	.even

_s_mode0:
	.long	_s_mode1		/* xm_Next		    */
	.long	79			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x10000			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x1ac			/* xm_PackSpeed = 428	    */
	.long	0x41f			/* xm_UnpackSpeed = 1055    */
	.word	0x0147			/* xm_Ratio = 327	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"speedy"
	.byte	0,0,0,0			/* name padded to 10	    */

_s_mode1:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	1			/* xm_Flags		    */
	.long	0x44000			/* xm_PackMemory	    */
	.long	0			/* xm_UnpackMemory	    */
	.long	0x46			/* xm_PackSpeed = 70	    */
	.long	0x448			/* xm_UnpackSpeed = 1096    */
	.word	0x0189			/* xm_Ratio = 393	    */
	.word	0			/* xm_ChunkSize		    */
	.ascii	"crawling"
	.byte	0,0			/* name padded to 10	    */
