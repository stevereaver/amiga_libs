|||
|||	xpkNONE_lib.s -- resident module header for
|||	xpkNONE.library 1.2 (01.04.1997)
|||
|||	Single code hunk, matching the shipped binary's layout:
|||	"moveq #-1,d0 / rts" entry stub, RomTag (version 1 /
|||	revision 2, no $VER cookie), AUTOINIT InitTable
|||	(dataSize 0x22 -- just struct Library, the seglist lives in
|||	a code-section longword), the InitStruct data table, the
|||	absolute-longword function table and the static
|||	XpkInfo/XpkMode descriptor blocks.
|||
|||	The function table is the "absolute pointer" variant
|||	(first entry's high word is not -1), terminated by -1L.
|||

	.section .text

_start:
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x22			| dataSize = sizeof(struct Library)
	.long	_functab		| absolute-long function table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

||| AUTOINIT function table, absolute-longword variant.
||| Order: Open Close Expunge Reserved PackerInfo PackChunk
|||        PackFree PackReset UnpackChunk UnpackFree
_functab:
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	_xstub			| -24 reserved -> return 0
	.long	_XpksPackerInfo		| -30
	.long	_XpksPackChunk		| -36 (returns -17 as shipped)
	.long	_xstub			| -42 PackFree   -> return 0
	.long	_xstub			| -48 PackReset  -> return 0
	.long	_XpksUnpackChunk	| -54
	.long	_xstub			| -60 UnpackFree -> return 0
	.long	-1			| table terminator

||| InitStruct data: standard six-entry library node init + terminator.
_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type
	.byte	9,0			|   = NT_LIBRARY
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

||| Code-section seglist longword (stored by LibInit, read
||| PC-relative by LibExpunge in the original binary).
	.globl	_SegList
_SegList:
	.long	0

||| Shared stub: doubles as xInitCode/xExitCode (called from
||| LibInit/LibExpunge) and as the "return 0" function for the
||| reserved/unimplemented LVO slots.  In the original all of
||| these are the same routine at the same address.
	.globl	_xstub
	.globl	_xInitCode
	.globl	_xExitCode
_xInitCode:
_xExitCode:
_xstub:
	moveq	#0,d0
	rts

_libname:
	.ascii	"xpkNONE.library"
	.byte	0
_idstr:
	.ascii	"xpkNONE 1.2 (01.04.1997)"	| no $VER: prefix in this binary
	.byte	0xd,0xa,0,0

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	0			| xi_MasterVersion (0 as shipped)
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "NONE"
	.long	_s_lname		| xi_LongName   "NoPacker"
	.long	_s_desc			| xi_Description
	.long	0x4e4f4e45		| xi_ID         'NONE'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x7d00			| xi_MaxPkInChunk (32000)
	.long	20			| xi_MinPkInChunk
	.long	0x7d00			| xi_DefPkInChunk (32000)
	.long	_s_pack			| xi_PackMsg    "Writing"
	.long	_s_unpack		| xi_UnpackMsg  "Reading"
	.long	_s_packed		| xi_PackedMsg  "Wrote"
	.long	_s_unpacked		| xi_UnpackedMsg "Read"
	.word	50			| xi_DefMode
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	1918			| xm_PackSpeed
	.long	2477			| xm_UnpackSpeed
	.word	0			| xm_Ratio
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0			| xm_Description[10]

_s_name:
	.ascii	"NONE"
	.byte	0
_s_lname:
	.ascii	"NoPacker"
	.byte	0
_s_desc:
	.ascii	"A dummy library that does no compression."
	.byte	0
_s_unpack:
	.ascii	"Reading"
	.byte	0
_s_pack:
	.ascii	"Writing"
	.byte	0
_s_unpacked:
	.ascii	"Read"
	.byte	0
_s_packed:
	.ascii	"Wrote"
	.byte	0
	.even

_endcode:
	.end
