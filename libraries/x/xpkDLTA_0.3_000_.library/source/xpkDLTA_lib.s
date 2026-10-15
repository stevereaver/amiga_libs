|||
|||	xpkDLTA_lib.s -- resident module header for
|||	xpkDLTA.library V0.3 (1 Oct 2013) by Stephan Fuhrmann
|||
|||	Single code hunk: "moveq #0,d0 / rts" entry stub (doubles as
|||	RT_ENDSKIP target and shared "return 0" vector), RomTag
|||	(version 0 / revision 3), name/id strings, AUTOINIT InitTable
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
	.byte	0			| RT_VERSION (0 as shipped)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"xpkDLTA.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkDLTA V0.3 (1 Oct 2013) by Stephan Fuhrmann"
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
	.word	0
	.byte	0x90,22			| INITWORD  lib_Revision
	.word	3
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
	.even
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	0			| xi_LibVersion
	.word	2			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "Delta"
	.long	_s_lname		| xi_LongName   "Delta Encryptor V0.3"
	.long	_s_desc			| xi_Description
	.long	0x444c5441		| xi_ID         'DLTA'
	.long	0x2009			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK|XPKIF_ENCRYPTION
	.long	0x10000			| xi_MaxPkInChunk (64K)
	.long	0			| xi_MinPkInChunk
	.long	0x10000			| xi_DefPkInChunk (64K)
	.long	_s_pack			| xi_PackMsg    "Enciphering"
	.long	_s_unpack		| xi_UnpackMsg  "Deciphering"
	.long	_s_packed		| xi_PackedMsg  "Enciphered"
	.long	_s_unpacked		| xi_UnpackedMsg "Deciphered"
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
	.long	531			| xm_PackSpeed
	.long	743			| xm_UnpackSpeed
	.word	0			| xm_Ratio
	.word	0			| xm_ChunkSize
	.ascii	"bytemode"
	.byte	0,0			| xm_Description[10]

_s_name:
	.ascii	"Delta"
	.byte	0
_s_lname:
	.ascii	"Delta Encryptor V0.3"
	.byte	0
_s_desc:
	.ascii	"DELTA-Encryption Routines \251 1992 Stephan Fuhrmann"
	.byte	0
_s_pack:
	.ascii	"Enciphering"
	.byte	0
_s_unpack:
	.ascii	"Deciphering"
	.byte	0
_s_packed:
	.ascii	"Enciphered"
	.byte	0
_s_unpacked:
	.ascii	"Deciphered"
	.byte	0
	.even

	.end
