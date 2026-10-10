||||	xpkLZW3.library 3.3 (020) - RomTag, InitTable, descriptors
||||	reconstructed from the shipped binary.
||||
||||	Hunk map of the original (single hunk, 1144 bytes):
||||	  0x00  moveq #0,d0 / rts    entry stub (shared null target)
||||	  0x04  RomTag               AUTOINIT, ver 1, NT_LIBRARY
||||	  0x1e  "xpkLZW3.library"
||||	  0x2e  "$VER: xpkLZW3 V3.3 (1 Oct 2013) by Niels Froehling"
||||	  0x64  InitTable            dataSize 0x26
||||	  0x74  datatab              InitStruct stream
||||	  0x94  functab              -1 marker, word offsets rel 0x94
||||	  0xac  LibInit              seglist @ +0x22
||||	  0xc2  Open / 0xd0 Close / 0xe2 Expunge
||||	  0x120 XpksPackFree         FreeMem(xsp_Sub-4, buf[0])
||||	  0x138 XpksPackReset        zero-fills hash, ~68B underflow
||||	                             (zeroes the AllocMem size word)
||||	  0x18c XpksPackerInfo       -> descriptor 0x36c
||||	  0x194 XpksPackChunk        LZ encoder (workmem 0x80004)
||||	  0x2f8 XpksUnpackChunk      decoder
||||	  0x36c XpkInfo (60B) / 0x3c4 XpkMode (32B) / strings

	.text
	.globl	_start
	.globl	_LibInit
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
	.ascii	"xpkLZW3.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkLZW3 V3.3 (1 Oct 2013) by Niels Froehling"
	.byte	0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x26			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

_datatab:
	.long	0xa0080900		|||| initbyte @8  = 9 (ln_Type NT_LIBRARY)
	.long	0x800a0000		|||| initlong @10 = _libname
	.long	0x0000001e
	.long	0xa00e0600		|||| initbyte @14 = 6 (lib_Flags)
	.long	0x90140003		|||| initword @20 = 3 (lib_Version)
	.long	0x90160003		|||| initword @22 = 3 (lib_Revision)
	.long	0x80180000		|||| initlong @24 = _idstr
	.long	0x0000002e
	.long	0x00000000		|||| end

|||| static XpkInfo descriptor (XpksPackerInfo returns its address)
|||| ------------------------------------------------------------------

	.even
	.globl	_s_xpkinfo
_s_xpkinfo:
	.word	1			|||| xi_XpkInfoVersion
	.word	3			|||| xi_LibVersion
	.word	2			|||| xi_MasterVersion
	.word	0			|||| xi_ModesVersion
	.long	_s_lzspeeder		|||| xi_Name
	.long	_s_longname		|||| xi_LongName
	.long	_s_desc			|||| xi_Description
	.long	0x4c5a5733		|||| xi_ID = 'LZW3'
	.long	9			|||| xi_Flags = PK_CHUNK|UP_CHUNK
	.long	0x7fffffff		|||| xi_MaxPkInChunk
	.long	0			|||| xi_MinPkInChunk
	.long	0x50000			|||| xi_DefPkInChunk = 327680
	.long	_s_annihilate		|||| xi_PackMsg
	.long	_s_reanimate		|||| xi_UnpackMsg
	.long	_s_ohgod		|||| xi_PackedMsg
	.long	_s_hehe			|||| xi_UnpackedMsg
	.word	100			|||| xi_DefMode
	.word	0			|||| xi_Pad
	.long	_s_xpkmode		|||| xi_ModeDesc
	.long	0,0,0,0,0,0		|||| xi_Reserved

|||| XpkMode (32 bytes)

_s_xpkmode:
	.long	0			|||| xm_Next
	.long	100			|||| xm_Upto
	.long	1			|||| xm_Flags = XPKMF_A3000SPEED
	.long	0x80004			|||| xm_PackMemory = workmem size
	.long	0			|||| xm_UnpackMemory
	.long	22			|||| xm_PackSpeed
	.long	600			|||| xm_UnpackSpeed
	.word	333			|||| xm_Ratio
	.word	0			|||| xm_ChunkSize

_s_cremation:
	.ascii	"cremation"		|||| dead string, unreferenced
	.byte	0
_s_lzspeeder:
	.ascii	"LZ-Speeder"
	.byte	0
_s_longname:
	.ascii	"LZ-Welsh (not Welch) 020+ V3.3"
	.byte	0
_s_desc:
	.ascii	"LZW2 compatible, better compressing"
	.byte	0
_s_annihilate:
	.ascii	"Annihilate"
	.byte	0
_s_reanimate:
	.ascii	"Reanimate"
	.byte	0
_s_ohgod:
	.ascii	"Oh god, It is done!"
	.byte	0
_s_hehe:
	.ascii	"Hehe, fast hew."
	.byte	0
	.align	2
