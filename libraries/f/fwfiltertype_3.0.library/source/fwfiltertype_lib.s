|||
|||	fwfiltertype_lib.s -- resident module header + AUTOINIT tables
|||	for fwfiltertype.library 3.0 (SoftWood, 1993)
|||
|||	Matches the shipped binary: a code hunk starting with
|||	"moveq #0,d0 / rts", the RomTag, name/id strings, the
|||	InitTable (dataSize 0x28), an absolute longword function
|||	table (first word 0x0000: exec uses the pointer
|||	interpretation), and compact InitStruct data.
|||
|||	Six vectors: the four standard system vectors plus one
|||	user function (FwFilterType, LVO -30) and a second
|||	reserved null slot (LVO -36).
|||

	.section .text

||| executable entry for non-resident loaders: returns 0
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	3			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"fwfiltertype.library"
	.byte	0
||| lib_IdString points into the "$VER:" string, after the cookie.
_verprefix:
	.ascii	"$VER: "
_idstr:
	.ascii	"fwfiltertype.library 3.0 (6.8.93)"
	.byte	0xa,0
_copyright:
	.ascii	"Copyright "
	.byte	0xa9
	.ascii	" 1993 SoftWood, Inc."
	.byte	0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x28			| dataSize = sizeof(struct FWFilterBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| Function table: absolute longword vectors, -1L terminated.
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved)
	.long	_FwFilterType		| LVO -30
	.long	_LibNull		| LVO -36 (reserved)
	.long	-1

||| InitStruct data for the library base.
||| compact byte-offset form (0x80=INITLONG/0x90=INITWORD/0xa0=INITBYTE).
_datatab:
	.byte	0xa0,0x08		| INITBYTE  ln_Type @ 8
	.byte	0x09,0x00		|   = NT_LIBRARY (9)
	.byte	0x80,0x0a		| INITLONG  ln_Name @ 10
	.long	_libname
	.byte	0xa0,0x0e		| INITBYTE  lib_Flags @ 14
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,0x14		| INITWORD  lib_Version @ 20
	.word	3
	.byte	0x90,0x16		| INITWORD  lib_Revision @ 22
	.word	0
	.byte	0x80,0x18		| INITLONG  lib_IdString @ 24
	.long	_idstr
	.word	0			| end of InitStruct data
	.word	0			| pad word
