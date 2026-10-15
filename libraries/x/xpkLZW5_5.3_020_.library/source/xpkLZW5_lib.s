|||
|||	xpkLZW5.library 5.3 (020) - RomTag, InitTable, descriptors
|||	reconstructed from the shipped binary.
|||
|||	Hunk map of the original (single hunk, 1560 bytes):
|||	  0x00  moveq #-1,d0 / rts   entry stub (shared null target)
|||	  0x04  RomTag               AUTOINIT, ver 1, NT_LIBRARY
|||	  0x1e  "xpkLZW5.library"
|||	  0x2e  "$VER: xpkLZW5 V5.3 (1 Oct 2013) by Niels Froehling"
|||	  0x64  InitTable            dataSize 0x26
|||	  0x74  datatab              InitStruct stream
|||	  0x94  functab              -1 marker, word offsets rel 0x94
|||	  0xac  LibInit              seglist @ +0x22 + AFB_68020 gate
|||	  0xc2  Open / 0xd0 Close / 0xe2 Expunge
|||	  0x120 XpksPackFree         FreeMem(xsp_Sub-4, buf[0])
|||	  0x138 XpksPackReset        downward fill (overruns 90,668B)
|||	  0x18c XpksPackerInfo       -> descriptor 0x468
|||	  0x194 XpksPackChunk        tiered lazy-matching LZ encoder
|||	  0x3b8 XpksUnpackChunk      2-bit flag-long decoder
|||	  0x468 XpkInfo (64B) / 0x4c0 XpkMode x3 / strings
|||

	.text
	.globl	_start
	.globl	_LibInit
_start:
	moveq	#0,%d0
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
	.ascii	"xpkLZW5.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkLZW5 V5.3 (1 Oct 2013) by Niels Froehling\r\n"
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
	.long	0x90140005		|||| initword @20 = 5 (lib_Version)
	.long	0x90160003		|||| initword @22 = 3 (lib_Revision)
	.long	0x80180000		|||| initlong @24 = _idstr
	.long	0x0000002e
	.long	0x00000000		|||| end

|||| LibInit -- store seglist, then gate on AFB_68020: on a plain
|||| 68000 the branch into the shared null stub returns d0=0 and the
|||| resident init fails, which is how the (020) tag is enforced.

_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		|||| seglist @ +0x22
	moveal	4:w,%a0
	btst	#1,%a0@(297)		|||| AttnFlags AFB_68020
	beqw	_start			|||| -> moveq #0,d0/rts: fail init
	rts

|||| static XpkInfo descriptor (XpksPackerInfo returns its address)
|||| ------------------------------------------------------------------

	.even
	.globl	_s_xpkinfo
_s_xpkinfo:
	.word	1			|||| xi_XpkInfoVersion
	.word	5			|||| xi_LibVersion
	.word	2			|||| xi_MasterVersion
	.word	0			|||| xi_ModesVersion
	.long	_s_lzspeeder		|||| xi_Name
	.long	_s_longname		|||| xi_LongName
	.long	_s_desc			|||| xi_Description
	.long	0x4c5a5735		|||| xi_ID = 'LZW5'
	.long	0x8009			|||| xi_Flags
	.long	0x7fffffff		|||| xi_MaxPkInChunk
	.long	0			|||| xi_MinPkInChunk
	.long	0x50000			|||| xi_DefPkInChunk = 327680
	.long	_s_annihilate		|||| xi_PackMsg
	.long	_s_reanimate		|||| xi_UnpackMsg
	.long	_s_ohgod		|||| xi_PackedMsg
	.long	_s_hehe			|||| xi_UnpackedMsg
	.word	50			|||| xi_DefMode -> "ashes"
	.word	0			|||| xi_Pad
	.long	_s_mode0		|||| xi_ModeDesc
	.long	0,0,0,0,0,0		|||| xi_Reserved

|||| XpkMode chain (32 bytes each + name).  xm_Upto/34 selects the
|||| lazy match budget: 33->0, 67->1, 100->2.

_s_mode0:
	.long	_s_mode1		|||| xm_Next
	.long	33			|||| xm_Upto
	.long	1			|||| xm_Flags
	.long	0x80004			|||| xm_PackMemory = workmem size
	.long	0			|||| xm_UnpackMemory
	.long	18			|||| xm_PackSpeed
	.long	545			|||| xm_UnpackSpeed
	.word	395			|||| xm_Ratio
	.word	0			|||| xm_ChunkSize
_s_cremation:
	.ascii	"cremation"
	.byte	0,0,0
_s_mode1:
	.long	_s_mode2
	.long	67
	.long	1
	.long	0x80004
	.long	0
	.long	8
	.long	545
	.word	408
	.word	0
_s_ashes:
	.ascii	"ashes"
	.byte	0,0,0,0,0
_s_mode2:
	.long	0
	.long	100
	.long	1
	.long	0x80004
	.long	0
	.long	6
	.long	545
	.word	412
	.word	0
_s_oblivion:
	.ascii	"oblivion"
	.byte	0

_s_lzspeeder:
	.ascii	"LZ-Speeder"
	.byte	0
_s_longname:
	.ascii	"LZ-Welsh (not Welch) 020+ V5.3"
	.byte	0
_s_desc:
	.ascii	"Very Similar to TDCS"
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
