||||
||||	lsdetect_lib.s -- lsdetect.library 1.0
||||	"LightShock EnvDetector V1.0"
||||
||||	Single CODE hunk: "moveq #-1,d0/rts" entry, RomTag
||||	(ver 1), name/id string (the id string carries a
||||	leading NUL byte and is referenced as IDSTRING+1),
||||	library-name literals, InitTable (dataSize 0x44,
||||	InitStruct data) and an absolute-longword function
||||	table (7 vectors + -1L).

	.section	.text

| loader entry -- returns -1

	.globl	_libentry
_libentry:
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
	.long	_idstr+1		| RT_IDSTRING (skips a lead NUL)
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"lsdetect.library"
	.byte	0
_idstr:
	.byte	0			| odd leading byte, verbatim
	.ascii	"LightShock EnvDetector V1.0"
	.byte	0
	.even

| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x44			| sizeof(struct LSDBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

| Function table: 7 absolute vectors + -1L
_functab:
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	_reserved		| -24
	.long	_LSDetectLanguage	| -30
	.long	_LSReleaseScreen	| -36
	.long	_LSBorrowScreen		| -42
	.long	-1

| InitStruct data (exec/initializers.i 16-bit-offset form)
_datatab:
	.byte	0xa0,0x08,0x09,0x00	| INITBYTE @8 = NT_LIBRARY
	.byte	0x80,0x0a		| INITLONG @0xa
	.long	_libname		|   ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| INITBYTE @0xe = flags 6
	.byte	0x90,0x14		| INITWORD @0x14
	.word	1			|   lib_Version = 1
	.byte	0x90,0x16		| INITWORD @0x16
	.word	0			|   lib_Revision = 0
	.byte	0x80,0x18		| INITLONG @0x18
	.long	_idstr+1		|   lib_IdString
	.word	0			| end

| reserved LVO -24
_reserved:
	moveq	#0,d0
	rts
