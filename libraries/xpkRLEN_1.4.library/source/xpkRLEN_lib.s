|||
|||	xpkRLEN_lib.s -- resident module header for
|||	xpkRLEN.library 1.4 (1.12.2010)
|||
|||	Single code hunk: "moveq #-1,d0 / rts" entry stub, RomTag
|||	(version 1 / revision 4, no $VER cookie), name/id strings,
|||	AUTOINIT InitTable (dataSize 0x2a), InitStruct data table and
|||	the static XpkMode/XpkInfo descriptor blocks.
|||
|||	The AUTOINIT function table is a word-offset table generated
|||	by genfunctab.py (functab.s) and linked separately.
|||

	.section .text

_start:
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP: end of module in original
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2a			| dataSize = sizeof(struct XpkSubBase)
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
	.word	4
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.word	0			| InitStruct terminator

_libname:
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:
	.ascii	"xpkRLEN 1.4 (1.12.2010)"	| no $VER: prefix in this binary
	.byte	0xd,0xa,0
	.byte	0			| alignment pad

_s_name:
	.ascii	"RLEN"
	.byte	0
_s_lname:
	.ascii	"Run Length"
	.byte	0
_s_desc:
	.ascii	"Fast and simple compression usable for simple data"
	.byte	0
	.even

||| XpkMode descriptor (linked from xi_ModeDesc; stored before
||| the XpkInfo block in the original binary).
	.globl	_xpkmode
_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	140			| xm_PackSpeed
	.long	1043			| xm_UnpackSpeed
	.word	45			| xm_Ratio (45.0%)
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0			| xm_Description[10]

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	0			| xi_MasterVersion (0 as shipped)
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "RLEN"
	.long	_s_lname		| xi_LongName   "Run Length"
	.long	_s_desc			| xi_Description
	.long	0x524c454e		| xi_ID         'RLEN'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x7fffffff		| xi_MaxPkInChunk
	.long	0			| xi_MinPkInChunk
	.long	0x4004			| xi_DefPkInChunk (0x4004 as shipped)
	.long	0			| xi_PackMsg
	.long	0			| xi_UnpackMsg
	.long	0			| xi_PackedMsg
	.long	0			| xi_UnpackedMsg
	.word	50			| xi_DefMode
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

	.end
