|||
|||	lowmem_lib.s -- resident module header for
|||	asdg-low-mem.library (0.0, 10-Jun-87)
|||
|||	Matches the shipped binary's layout: a code hunk whose first
|||	words are "clr.l d0/rts", the RomTag, the InitStruct data
|||	table (24-bit-offset command form), an absolute longword
|||	function table, the AUTOINIT InitTable (dataSize 0x3c) and
|||	the name/id/copyright strings.
|||
|||	The function table uses the absolute-pointer interpretation
|||	(first word is not -1): Open, Close, Expunge, the module
|||	entry point as reserved vector, then the three user
|||	functions.
|||

	.section .text

||| executable-entry return value for non-resident loaders
	clr.l	d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	0			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitStruct data (exec/initializers.i), 24-bit-offset command
||| bytes (0xc0 long / 0xd0 word / 0xe0 byte), as in the original.
_datatab:
	.byte	0xe0,0x00,0x00,0x08	| INITBYTE  ln_Type @ 8
	.byte	0x09,0x00		|   = NT_LIBRARY (9)
	.byte	0xc0,0x00,0x00,0x0a	| INITLONG  ln_Name @ 10
	.long	_libname
	.byte	0xe0,0x00,0x00,0x0e	| INITBYTE  lib_Flags @ 14
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0xd0,0x00,0x00,0x14	| INITWORD  lib_Version @ 20
	.word	0
	.byte	0xd0,0x00,0x00,0x16	| INITWORD  lib_Revision @ 22
	.word	0
	.byte	0xc0,0x00,0x00,0x18	| INITLONG  lib_IdString @ 24
	.long	_idstr
	.word	0			| end of InitStruct data

||| Function table: absolute longword vectors, -1L terminated.
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_romtag-4		| LVO -24 (reserved -> module entry)
	.long	_RegLowMemReq		| LVO -30
	.long	_DeRegLowMemReq		| LVO -36
	.long	_LMSQuery		| LVO -42
	.long	-1

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x3c			| sizeof(struct LowMemBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

_libname:
	.ascii	"asdg-low-mem.library"
	.byte	0
	.byte	0			| pad: original idstring starts even
_idstr:
	.ascii	"asdg low memory alert server (10-Jun-87)"
	.byte	0xd,0xa,0
||| copyright strings embedded in the code hunk (unreferenced)
	.ascii	"Copyright 1987 By ASDG Incorporated"
	.byte	0xd,0xa,0
	.ascii	"Perry S. Kivolowitz"
	.byte	0xd,0xa,0
	.even
