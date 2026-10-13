|||
|||	xpkTDCS.library 1.2 - RomTag, InitTable, datatab, LibInit
|||	reconstructed from the shipped binary.
|||
|||	Hunk map of the original (single hunk, 2084 bytes):
|||	  0x00  moveq #0,d0 / rts   entry stub (shared null target)
|||	  0x04  RomTag              AUTOINIT, ver 1, NT_LIBRARY
|||	  0x1e  InitTable           dataSize 0x26
|||	  0x2e  functab             -1 marker, word offsets rel 0x2e
|||	  0x46  datatab             InitStruct stream
|||	  0x62  pad long
|||	  0x66  LibInit             seglist @ +0x26 + AFB_68020 gate
|||	  0x7c  Open / 0x8a Close / 0x98 Expunge / 0xce null
|||	  0xd2  XpksPackerInfo      -> descriptor 0x680
|||	  0xda  XpksPackChunk       pool-backed hash-chain LZ encoder
|||	  0x5ec XpksUnpackChunk     2-bit flag-long decoder
|||	  0x680 XpkInfo (64B) / 0x6d8 libname / 0x6e8 idstr / strings
|||	  0x7f8 XpkMode (32B) + "direct match"
|||
|||	The PackFree (-42), PackReset (-48) and UnpackFree (-60)
|||	vectors all point at the _start stub (return 0): the codec
|||	is stateless per chunk, its workspace is a per-call exec
|||	memory pool.
|||

	.text
	.globl	_start
	.globl	_LibInit
_start:
	moveq	#0,%d0
	rts

||||| resident tag

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

||||| InitTable (AUTOINIT) -- strings live at the tail of the hunk

	.even
_inittab:
	.long	0x26			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

_datatab:				|||| byte-serial InitStruct stream
	.byte	0xa0,0x08,9,0		|||| initbyte @8  = 9 (ln_Type)
	.byte	0x80,0x0a		|||| initlong @10 = _libname
	.long	_libname
	.byte	0xa0,0x0e,6,0		|||| initbyte @14 = 6 (lib_Flags)
	.byte	0x90,0x14,0,1		|||| initword @20 = 1 (lib_Version)
	.byte	0x90,0x16,0,2		|||| initword @22 = 2 (lib_Revision)
	.byte	0x80,0x18		|||| initlong @24 = _idstr
	.long	_idstr
	.long	0x00000000		|||| end

||||| LibInit -- store seglist at +38, then gate on AFB_68020 via
||||| SysBase (a0): on a plain 68000 the branch into _start returns
||||| d0=0 and the resident init fails.  Returns the lib base.

_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(38)		|||| seglist @ +0x26
	moveal	4:w,%a0
	btst	#1,%a0@(297)		|||| AttnFlags AFB_68020
	beqs	_start			|||| -> moveq #0,d0/rts: fail init
	movel	%a1,%d0
	rts
