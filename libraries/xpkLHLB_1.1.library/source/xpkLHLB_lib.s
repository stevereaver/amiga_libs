|||
|||	xpkLHLB_lib.s -- resident module header for
|||	xpkLHLB.library v1.1 (5.4.98) -- LHL preprocessor for
|||	lh.library, packaged as an XPK sublibrary.
|||
|||	Single code hunk: entry stubs, framework code, absolute-
|||	longword AUTOINIT functab, InitStruct datatab, strings and
|||	the XpkInfo/XpkMode descriptor blocks.
|||
|||	dataSize = 0x30: bare library + seglist + SysBase + lhbase
|||	(lh.library is OpenLibrary'd by the init routine).
|||

	.section .text

_start:
	moveq	#-1,d0			| module entry returns -1
	rts
	nop
_LibNull:				| hunk+6 in the original
	moveq	#0,d0
	rts
	nop

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endskip		| RT_ENDSKIP (orig: XpkMode start)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| "lh.library" -- opened by LibInit via pc-relative lea
	.globl	_lhlibname
_lhlibname:
	.ascii	"lh.library"
	.byte	0
	.even

||| InitTable: dataSize, funcTable, dataTable, initRoutine
_inittab:
	.long	0x30			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 ExtFunc
	.long	_XpksPackerInfo		| LVO -30
	.long	_XpksPackChunk		| LVO -36
	.long	_XpkFree		| LVO -42 XpksPackFree
	.long	_LibNull		| LVO -48 XpksPackReset
	.long	_XpksUnpackChunk	| LVO -54
	.long	_XpkFree		| LVO -60 XpksUnpackFree
	.long	-1

_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type = NT_LIBRARY
	.byte	9,0
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version = 1
	.word	1
	.byte	0x90,22			| INITWORD  lib_Revision = 1
	.word	1
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

_libname:
	.ascii	"xpkLHLB.library"
	.byte	0,0,0,0,0			| padded as in original
_idstr:
	.ascii	"xpkLBLB 1.1 (5.4.98)"	| "LBLB" typo is in the binary
	.byte	0xd,0xa,0
_s_desc:
	.ascii	"preprocessor for lh.library"
	.byte	0
_s_lname:
	.ascii	"Fast and good compression usable for all data"
	.byte	0
_s_name:
	.ascii	"LHLB"
	.byte	0

||| XpkMode/XpkInfo descriptor blocks -- code-hunk resident here
||| (single-hunk library), referenced by XpksPackerInfo.
	.even
_endskip:				| orig RT_ENDSKIP -> XpkMode
	.globl	_xpkmode
_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0x12c40			| xm_PackMemory = 76864
	.long	0x1194			| xm_UnpackMemory = 4500
	.long	140			| xm_PackSpeed
	.long	1043			| xm_UnpackSpeed
	.word	45			| xm_Ratio
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0			| xm_Description[10]

	.globl	_xpkinfo
_xpkinfo:
	.word	0			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	1			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "LHLB"
	.long	_s_lname		| xi_LongName
	.long	_s_desc			| xi_Description
	.long	0x4c484c42		| xi_ID         'LHLB'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x8000			| xi_MaxPkInChunk
	.long	0			| xi_MinPkInChunk
	.long	0x8000			| xi_DefPkInChunk
	.long	0			| xi_PackMsg
	.long	0			| xi_UnpackMsg
	.long	0			| xi_PackedMsg
	.long	0			| xi_UnpackedMsg
	.word	100			| xi_DefMode
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

	.end
