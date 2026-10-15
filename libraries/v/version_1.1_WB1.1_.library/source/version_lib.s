|||
|||	version_lib.s -- resident module header + AUTOINIT tables
|||	for version.library 1.1 (Workbench 1.1)
|||
|||	Matches the shipped binary: a code hunk starting with
|||	"moveq #0,d0 / rts", the RomTag, name/id strings, the
|||	InitTable (dataSize 0x2c), an absolute longword function
|||	table (no leading -1 word: exec treats the entries as
|||	pointers), and the InitStruct data for the library base.
|||
|||	Quirk: the InitStruct data uses the 24-bit offset command
|||	form (0xc0/0xd0/0xe0) even though all offsets fit in one
|||	byte, and its first entry writes byte 9 at offset 0x0c --
|||	inside ln_Name, immediately overwritten by the INITLONG
|||	ln_Name that follows.  Reproduced verbatim.
|||

	.section .text

||| executable entry for non-resident loaders: returns failure
	moveq	#0,d0
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

_libname:
	.ascii	"version.library"
	.byte	0
_idstr:
	.ascii	"mylib 1.1 (04 Nov 1985)"
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

||| InitStruct data (see exec/initializers.i).  This early build
||| emits the 24-bit offset form for every entry.
_datatab:
	.byte	0xe0,0x00		| INITBYTE  24-bit offset 0x000c
	.word	0x000c			|   (lands inside ln_Name -- dead write)
	.byte	0x09,0x00		|   = 9
	.byte	0xc0,0x00		| INITLONG  24-bit offset 0x000a (ln_Name)
	.word	0x000a
	.long	_libname
	.byte	0xe0,0x00		| INITBYTE  24-bit offset 0x000e
	.word	0x000e			|   lib_Flags
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0xd0,0x00		| INITWORD  24-bit offset 0x0014
	.word	0x0014			|   lib_Version
	.word	1
	.byte	0xd0,0x00		| INITWORD  24-bit offset 0x0016
	.word	0x0016			|   lib_Revision
	.word	1
	.byte	0xc0,0x00		| INITLONG  24-bit offset 0x0018
	.word	0x0018			|   lib_IdString
	.long	_idstr
	.word	0			| end of InitStruct data
	.word	0			| pad word (function code is long-aligned)
