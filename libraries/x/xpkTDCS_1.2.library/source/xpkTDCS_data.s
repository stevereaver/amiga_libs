|||
|||	xpkTDCS.library 1.2 - XpkInfo descriptor, strings, mode table
|||	reconstructed from the shipped binary (code hunk tail).
|||

	.section .text

||||| static XpkInfo descriptor (XpksPackerInfo returns its address)
||||| ------------------------------------------------------------------

	.even
	.globl	_s_xpkinfo
_s_xpkinfo:
	.word	1			|||| xi_XpkInfoVersion
	.word	1			|||| xi_LibVersion
	.word	2			|||| xi_MasterVersion
	.word	0			|||| xi_ModesVersion
	.long	_s_sarnath		|||| xi_Name
	.long	_s_longname		|||| xi_LongName
	.long	_s_desc			|||| xi_Description
	.long	0x54444353		|||| xi_ID = 'TDCS'
	.long	0x8009			|||| xi_Flags
	.long	0x7fffffff		|||| xi_MaxPkInChunk
	.long	4			|||| xi_MinPkInChunk
	.long	0x4ffff			|||| xi_DefPkInChunk = 327679
	.long	_s_annihilate		|||| xi_PackMsg
	.long	_s_reanimate		|||| xi_UnpackMsg
	.long	_s_ohgod		|||| xi_PackedMsg
	.long	_s_hehe			|||| xi_UnpackedMsg
	.word	100			|||| xi_DefMode
	.word	0			|||| xi_Pad
	.long	_s_mode0		|||| xi_ModeDesc
	.long	0,0,0,0,0,0		|||| xi_Reserved

||||| library name / idstr -- stored here in the shipped hunk tail,
||||| referenced by the RomTag at the head.

	.globl	_libname
_libname:
	.ascii	"xpkTDCS.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"xpkTDCS 1.2 (20.01.2012)\r\n"
	.byte	0

_s_sarnath:
	.ascii	"The Doom that Came over Sarnath"
	.byte	0
_s_longname:
	.ascii	"Lempel-Ziv-77 implementation with big window"
	.byte	0
_s_desc:
	.ascii	"Based upon some experiments with packer, \251DYNA-Tech"
	.byte	0
_s_annihilate:
	.ascii	"(annihilate) Even eternity will die ..."
	.byte	0
_s_reanimate:
	.ascii	"(reanimate.) I got it, yeah, ... ready"
	.byte	0
_s_ohgod:
	.ascii	"Oh god, It is done!"
	.byte	0
_s_hehe:
	.ascii	"Hehe, fast hew."
	.byte	0

||||| single XpkMode descriptor ("direct match") -- 32 bytes then
||||| the inline name.  packmem 0x800a0 covers the 512KB table plus
||||| pool overhead for the bucket arrays.

	.even
_s_mode0:
	.long	0			|||| xm_Next
	.long	49			|||| xm_Upto
	.long	1			|||| xm_Flags
	.long	0x800a0			|||| xm_PackMemory
	.long	0			|||| xm_UnpackMemory
	.long	20			|||| xm_PackSpeed
	.long	1500			|||| xm_UnpackSpeed
	.word	500			|||| xm_Ratio
	.word	0			|||| xm_ChunkSize
_s_directmatch:
	.ascii	"direct match"
	.byte	0
