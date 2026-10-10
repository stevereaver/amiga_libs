||||
||||	xpkSLZ3_lib.s -- resident/tag/table block plus the static
||||	XpkInfo/XpkMode descriptors for xpkSLZ3.library 1.3
||||	(000), reconstructed.
||||
||||	Hunk map of the original (single hunk, 1084 bytes):
||||	  0x00  moveq #0,d0 / rts      entry stub (shared null target)
||||	  0x04  RomTag                AUTOINIT, ver 1, NT_LIBRARY
||||	  0x1e  "xpkSLZ3.library"
||||	  0x2e  "$VER: xpkSLZ3 V1.3 (1 Oct 2013) by Niels Froehling"
||||	  0x64  InitTable             dataSize 0x26
||||	  0x74  datatab               InitStruct stream
||||	  0x94  functab               -1 marker, word offsets rel 0x94
||||	  0xac  LibInit               seglist @ +0x22
||||	  0xb4  Open / 0xc2 Close / 0xd4 Expunge
||||	  0x112 XpksPackFree          FreeMem(xsp_Sub-4, buf[0])
||||	  0x12a XpksPackReset         zero-fills hash at sub..sub+0x40000
||||	                              (down from top; ~15KB underflow)
||||	  0x17e XpksPackerInfo        -> descriptor 0x368
||||	  0x186 XpksPackChunk         LZSS encoder (workmem 0x44004)
||||	  0x2fe XpksUnpackChunk       decoder
||||	  0x368 XpkInfo (88B) / 0x3c0 XpkMode (42B) / strings
||||
||||	Workmem layout (xsp_Sub, 0x44000 bytes after the size word):
||||	  +0x00000  ULONG hash[65536]   last position per 16-bit hash
||||	  +0x40000  ULONG chain[4097]   ring: prev pos, indexed pos&0xfff
||||
||||	The shipped code uses a moveq #-1 trick to keep a negative
||||	table offset: d1 = (0xffff0000|hash)<<2 == hash*4-0x40000,
||||	so indexing a5=sub+0x40000 lands at sub+hash*4.  The C
||||	version uses the hash base directly.
||||

	.text

	.globl	_start
	.globl	_LibInit
	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_LibNull
	.globl	_XpksPackerInfo
	.globl	_XpksPackChunk
	.globl	_XpksPackFree
	.globl	_XpksPackReset
	.globl	_XpksUnpackChunk
	.globl	_s_xpkinfo

|||| entry point -- returns 0 (also the functab null target)

_start:
	moveq	#0,d0
	rts

|||| resident tag

_romtag:
	.word	0x4afc			|||| RTC_MATCHWORD
	.long	_romtag			|||| RT_MATCHTAG
	.long	_endmodule		|||| RT_ENDSKIP
	.byte	0x80			|||| RTF_AUTOINIT
	.byte	1			|||| RT_VERSION
	.byte	9			|||| NT_LIBRARY
	.byte	0			|||| RT_PRI
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"xpkSLZ3.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkSLZ3 V1.3 (1 Oct 2013) by Niels Froehling"
	.byte	0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x26			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

|||| InitStruct data stream

_datatab:
	.byte	0xa0,0x08		|||| INITBYTE ln_Type = NT_LIBRARY
	.word	0x0900
	.byte	0x80,0x0a		|||| INITLONG ln_Name
	.long	_libname
	.byte	0xa0,0x0e		|||| INITBYTE lib_Flags = 6
	.word	0x0600
	.byte	0x90,0x14		|||| INITWORD lib_Version = 1
	.word	0x0001
	.byte	0x90,0x16		|||| INITWORD lib_Revision = 3
	.word	0x0003
	.byte	0x80,0x18		|||| INITLONG lib_IdString
	.long	_idstr
	.word	0x0000			|||| terminator

|||| ------------------------------------------------------------------
|||| static XpkInfo descriptor (XpksPackerInfo returns its address)
|||| ------------------------------------------------------------------

	.even
_s_xpkinfo:
	.word	1			|||| xi_XpkInfoVersion
	.word	1			|||| xi_LibVersion
	.word	2			|||| xi_MasterVersion
	.word	0			|||| xi_ModesVersion
	.long	_s_fastslz		|||| xi_Name
	.long	_s_longname		|||| xi_LongName
	.long	_s_basedesc		|||| xi_Description
	.long	0x534c5a33		|||| xi_ID = 'SLZ3'
	.long	9			|||| xi_Flags = PK_CHUNK|UP_CHUNK
	.long	0x7fffffff		|||| xi_MaxPkInChunk
	.long	0			|||| xi_MinPkInChunk
	.long	0x10000			|||| xi_DefPkInChunk = 65536
	.long	0			|||| xi_PackMsg
	.long	0			|||| xi_UnpackMsg
	.long	0			|||| xi_PackedMsg
	.long	0			|||| xi_UnpackedMsg
	.word	100			|||| xi_DefMode
	.word	0			|||| xi_Pad
	.long	_s_xpkmode		|||| xi_ModeDesc
	.long	0,0,0,0,0,0		|||| xi_Reserved

|||| XpkMode (42 bytes)

_s_xpkmode:
	.long	0			|||| xm_Next
	.long	100			|||| xm_Upto
	.long	1			|||| xm_Flags = XPKMF_A3000SPEED
	.long	0x44004			|||| xm_PackMemory = workmem size
	.long	0			|||| xm_UnpackMemory
	.long	54			|||| xm_PackSpeed
	.long	646			|||| xm_UnpackSpeed
	.word	392			|||| xm_Ratio
	.word	0			|||| xm_ChunkSize
_s_fastlz:
	.ascii	"fastLZ"
	.byte	0,0

	.even
_s_slz3:
	.ascii	"SLZ3"
	.byte	0
_s_fastslz:
	.ascii	"FastSLZ"
	.byte	0
_s_longname:
	.ascii	"Simple & Fast LZSS V1.3"
	.byte	0
_s_basedesc:
	.ascii	"Based upon a workshop of Adisak Pochanayon ("
	.byte	0xae,0x29,0

	.even
