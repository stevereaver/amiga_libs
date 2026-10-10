|||
|||	xpkRLEN_lib.s -- resident module header for
|||	xpkRLEN.library V1.5 (1 Oct 2013) by Urban Dominik Muller
|||
|||	Single code hunk: "moveq #0,d0 / rts" entry stub, RomTag
|||	(version 1 / revision 5), name/id strings, AUTOINIT InitTable
|||	(dataSize 0x26), InitStruct data table and the static
|||	XpkInfo/XpkMode descriptor blocks.
|||
|||	The AUTOINIT function table is a word-offset table generated
|||	by genfunctab.py (functab.s) and linked separately.
|||

	.section .text

_start:
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_start			| RT_ENDSKIP: offset 0 in original
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkRLEN V1.5 (1 Oct 2013) by Urban Dominik Muller"
	.byte	0xd,0xa,0

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
	.word	5
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
	.even
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	2			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "RLEN"
	.long	_s_lname		| xi_LongName   "RunLength Packer V1.5"
	.long	_s_desc			| xi_Description
	.long	0x524c454e		| xi_ID         'RLEN'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x7fffffff		| xi_MaxPkInChunk
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

_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	372			| xm_PackSpeed
	.long	1150			| xm_UnpackSpeed
	.word	48			| xm_Ratio (48.0%)
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0			| xm_Description[10]

_s_name:
	.ascii	"RLEN"
	.byte	0
_s_lname:
	.ascii	"RunLength Packer V1.5"
	.byte	0
_s_desc:
	.ascii	"Fast and simple RLE compression"
	.byte	0

	.end
