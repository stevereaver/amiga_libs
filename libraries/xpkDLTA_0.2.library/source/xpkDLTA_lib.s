|||
|||	xpkDLTA_lib.s -- resident module header for
|||	xpkDLTA.library v0.2 (1992) by Stephan Fuhrmann
|||
|||	Single code hunk: "moveq #0,d0 / rts" entry stub, RomTag
|||	(version 0 / revision 2, no $VER cookie), name/id strings,
|||	AUTOINIT InitTable (dataSize 0xfc!) and the InitStruct data
|||	table.
|||
|||	Unusual: the XpkInfo/XpkMode descriptors live INSIDE the
|||	library base (offsets 0x26 and 0x7e of a 0xfc byte base) and
|||	are written by InitStruct when exec builds the base.  LibInit
|||	only stores the seglist and links the mode block into
|||	xi_ModeDesc.
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
	.long	_endcode		| RT_ENDSKIP (trailing nop in original)
	.byte	0x80			| RTF_AUTOINIT
	.byte	0			| RT_VERSION (0 as shipped)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_s_id:
	.ascii	"DLTA"
	.byte	0
_s_lname:
	.ascii	"DELTA v0.2"
	.byte	0
_libname:
	.ascii	"xpkDLTA.library"
	.byte	0
_idstr:
	.ascii	"xpkDLTA.library v0.2"		| no $VER: prefix in this binary
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

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0xfc			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab		| generated word-offset table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

||| InitStruct data.  Inits the library node, then the embedded
||| XpkInfo at base+0x26 and the embedded XpkMode at base+0x7e.
||| (XpkInfo=88 bytes -> 0x26..0x7d; XpkMode=42 bytes -> 0x7e..0xa7;
||| the base tail to 0xfc stays zero.)
_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type
	.byte	9,0			|   = NT_LIBRARY
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version
	.word	0
	.byte	0x90,22			| INITWORD  lib_Revision
	.word	2
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr

	.byte	0x80,0x82		| INITLONG  @0x82 xm_Upto = 100
	.long	100
	.byte	0x80,0x9e		| INITLONG  @0x9e xm_Description[0]
	.long	0x42797465		|   'Byte'
	.byte	0x80,0xa2		| INITLONG  @0xa2 xm_Description[4]
	.long	0x4d6f6465		|   'Mode'

	.byte	0x90,0x26		| INITWORD  @0x26 xi_XpkInfoVersion = 1
	.word	1
	.byte	0x90,0x28		| INITWORD  @0x28 xi_LibVersion = 0
	.word	0
	.byte	0x90,0x2a		| INITWORD  @0x2a xi_MasterVersion = 1
	.word	1
	.byte	0x90,0x2c		| INITWORD  @0x2c xi_ModesVersion = 0
	.word	0
	.byte	0x80,0x2e		| INITLONG  @0x2e xi_Name
	.long	_s_id
	.byte	0x80,0x32		| INITLONG  @0x32 xi_LongName
	.long	_s_lname
	.byte	0x80,0x36		| INITLONG  @0x36 xi_Description
	.long	_s_desc
	.byte	0x80,0x3a		| INITLONG  @0x3a xi_ID = 'DLTA'
	.long	0x444c5441
	.byte	0x80,0x3e		| INITLONG  @0x3e xi_Flags = 0x2000
	.long	0x2000			|   XPKIF_ENCRYPTION only, as shipped
	.byte	0x80,0x42		| INITLONG  @0x42 xi_MaxPkInChunk
	.long	0x10000			|   64K (matches word loop counter)
	.byte	0x80,0x46		| INITLONG  @0x46 xi_MinPkInChunk = 1
	.long	1
	.byte	0x80,0x4a		| INITLONG  @0x4a xi_DefPkInChunk
	.long	0x10000
	.byte	0x80,0x4e		| INITLONG  @0x4e xi_PackMsg
	.long	_s_pack
	.byte	0x80,0x52		| INITLONG  @0x52 xi_UnpackMsg
	.long	_s_unpack
	.byte	0x80,0x56		| INITLONG  @0x56 xi_PackedMsg
	.long	_s_packed
	.byte	0x80,0x5a		| INITLONG  @0x5a xi_UnpackedMsg
	.long	_s_unpacked
	.byte	0x90,0x5e		| INITWORD  @0x5e xi_DefMode = 100
	.word	100
	.word	0			| InitStruct terminator

_endcode:
	.end
