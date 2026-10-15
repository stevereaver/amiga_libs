|||
|||	xpkfast_lib.s -- RomTag, init table, data table,
|||	descriptor and LibInit for xpkFAST.library V1.06.
||||
||||	Original code-hunk layout:
||||	  0x00  EndSkip stub (moveq #-1,d0; rts -- returns -1!)
||||	  0x04  RomTag 0x4afc / AUTOINIT
||||	  0x1e  "xpkFAST.library"
||||	  0x2e  "$VER: xpkFAST.library V1.06 (27-Jul-94)"
||||	  0x58  init struct (dataSize 0x4a, functab, datatab, initfunc)
||||	  0x68  function table (LONG absolute entries + -1)
||||	  0x94  data table
||||	  0xb4  LibInit (execbase@34, seglist@38)
||||	  0x1dc XpkInfo descriptor + mode chain + strings
|||

	.section .text

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_inittab		/* EndSkip -> init struct (0x58)  */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkFAST.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkFAST.library V1.06 (27-Jul-94)"
	.byte	13,10,0
	.even

	.globl	_inittab
_inittab:
	.long	0x4a			/* dataSize 74: Library+34+38 */
	.long	_functab
	.long	_datatab
	.long	_LibInit

	.globl	_functab
_functab:
	.long	_LibOpen		/* -6   Open		    */
	.long	_LibClose		/* -12  Close		    */
	.long	_LibExpunge		/* -18  Expunge		    */
	.long	_LibNull		/* -24  ExtFunc stub	    */
	.long	_XpksPackerInfo		/* -30  XpksPackerInfo	    */
	.long	_XpksPackChunk		/* -36  XpksPackChunk	    */
	.long	_XpksPackFree		/* -42  XpksPackFree	    */
	.long	_LibNull		/* -48  XpksPackReset stub  */
	.long	_XpksUnpackChunk	/* -54  XpksUnpackChunk	    */
	.long	_LibNull		/* -60  UnpackReset stub    */
	.long	-1			/* terminator		    */

_datatab:
	.byte	0xa0,0x0c		/* byte @0x0c = 9 -- the    */
	.byte	0x09,0x00		/* original writes ln_Type  */
					/* at +12 (inside ln_Name,  */
					/* overwritten next) not +8 */
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* lib_Version = 1	    */
	.word	0x0001
	.byte	0x90,0x16		/* lib_Revision = 6	    */
	.word	0x0006
	.byte	0x80,0x18		/* lib_IdString		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

_LibInit:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(34)		/* execbase		    */
	movel	%a0,%a5@(38)		/* seglist		    */
	moveal	%sp@+,%a5
	rts

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
	.ascii	"FAST V1.06 alias WOOP or LZRW++"
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
