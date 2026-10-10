|||
|||	xpkFRLE_lib.s -- resident module header for
|||	xpkFRLE.library V1.2 "Fast Run Length Encoder V1.2"
|||	(1 Oct 2013) by Jorma Oksanen.
|||
|||	Compact layout: entry stub + RomTag + strings + InitTable +
|||	datatab + word-offset functab + code + static descriptors.
|||	The entry stub is "moveq #0,d0 / rts" -- it doubles as the
|||	null vector (functab entries for ExtFunc and the reserved
|||	slots are NEGATIVE offsets back to _start) and as a return
|||	trampoline: LibClose/Expunge branch into its rts/hunk+0 for
|||	the "return / return 0" tails.
|||
|||	Original hunk map (offset -> contents):
|||	  0x000 moveq #0,d0 / rts    entry + null vector + ret trampoline
|||	  0x004 RomTag               RTF_AUTOINIT, ver 1, EndSkip=0!
|||	  0x01e "xpkFRLE.library"
|||	  0x02e "$VER: xpkFRLE V1.2 (1 Oct 2013) by Jorma Oksanen\r\n"
|||	  0x062 InitTable            dataSize 0x26
|||	  0x072 datatab              InitStruct (flags 6, ver 1, rev 2)
|||	  0x092 functab              -1, 10 word offsets, -1
|||	  0x0aa LibInit              moveal d0,a1; movel a0,(0x22,a1); rts
|||	  0x0b2 LibOpen / 0x0c0 LibClose / 0x0d2 LibExpunge
|||	  0x110 XpksPackerInfo       lea (pc+...),a0
|||	  0x118 XpksPackChunk        encoder
|||	  0x1ea XpksUnpackChunk      unrolled computed-goto decoder
|||	  0x2ae XpkInfo              88 bytes
|||	  0x306 XpkMode              42 bytes "normal"
|||	  0x330 "FastRLE" / lname / desc strings
|||	  0x36d "EVE"                unterminated easter-egg tag at end
|||

	.section .text

	.globl	_start
_start:					| module entry AND null vector
	moveq	#0,d0			|   (functab refs point back here)
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	0			| RT_ENDSKIP = 0 in the original!
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"xpkFRLE.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkFRLE V1.2 (1 Oct 2013) by Jorma Oksanen"
	.byte	0xd,0xa,0,0

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x26			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab		| generated word-offset table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type = NT_LIBRARY
	.byte	9,0
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version
	.word	1
	.byte	0x90,22			| INITWORD  lib_Revision
	.word	2
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

||| (functab lives here in the original; the generated functab.s
|||  is linked separately)

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
||| In the original this block sits past the code at hunk+0x2ae.
	.even
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	2			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "FastRLE"
	.long	_s_lname		| xi_LongName   "Fast Run Length Encoder V1.2"
	.long	_s_desc			| xi_Description
	.long	0x46524c45		| xi_ID         'FRLE'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x7fffffff		| xi_MaxPkInChunk = 2G-1 (!)
	.long	0			| xi_MinPkInChunk = 0 (!)
	.long	0x8000			| xi_DefPkInChunk = 32768
	.long	0			| xi_PackMsg    = NULL (v1.2 drops msgs)
	.long	0			| xi_UnpackMsg  = NULL
	.long	0			| xi_PackedMsg  = NULL
	.long	0			| xi_UnpackedMsg = NULL
	.word	100			| xi_DefMode = 100
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	370			| xm_PackSpeed
	.long	1150			| xm_UnpackSpeed
	.word	48			| xm_Ratio (48.0%)
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0		| xm_Description[10]

_s_name:
	.ascii	"FastRLE"
	.byte	0
_s_lname:
	.ascii	"Fast Run Length Encoder V1.2"
	.byte	0
_s_desc:
	.ascii	"Optimized RLE for 68000"
	.byte	0
_s_eve:
	.ascii	"EVE"			| unterminated easter-egg tag at
					|   the very end of the hunk

	.end
