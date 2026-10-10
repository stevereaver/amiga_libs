|||
|||	version_lib.s -- resident module header + AUTOINIT tables
|||	for version.library 34.34 (Workbench 1.3.3)
|||
|||	Matches the shipped binary: a code hunk starting with
|||	"moveq #-1,d0 / rts" (all other version.library builds
|||	use "moveq #0,d0"), the RomTag, name/id strings, the
|||	InitTable (dataSize 0x2c), an absolute longword function
|||	table (no leading -1 word: exec treats the entries as
|||	pointers), and the InitStruct data for the library base.
|||
|||	First build using the compact byte-offset InitStruct
|||	command form (0x80/0x90/0xa0).
|||

	.section .text

||| executable entry for non-resident loaders: returns failure
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	34			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"version.library"
	.byte	0
_idstr:
	.ascii	"versionlib 34.34 (05 OCT 1990)"
	.byte	0xd,0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2c			| dataSize = sizeof(struct VersionBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| Function table: absolute longword vectors, -1L terminated.
||| First word is 0x0000 (not -1), so MakeLibrary uses the
||| absolute-pointer interpretation.
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved)
	.long	-1

||| InitStruct data (see exec/initializers.i).
||| compact byte-offset form (0x80/0x90/0xa0 command bytes).
_datatab:
	.byte	0xa0,0x08		| INITBYTE  ln_Type @ 8
	.byte	0x09,0x00		|   = NT_LIBRARY (9)
	.byte	0x80,0x0a		| INITLONG  ln_Name @ 10
	.long	_libname
	.byte	0xa0,0x0e		| INITBYTE  lib_Flags @ 14
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,0x14		| INITWORD  lib_Version @ 20
	.word	34
	.byte	0x90,0x16		| INITWORD  lib_Revision @ 22
	.word	34
	.byte	0x80,0x18		| INITLONG  lib_IdString @ 24
	.long	_idstr
	.word	0			| end of InitStruct data
	.word	0			| pad word (function code is long-aligned)
