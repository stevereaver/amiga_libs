||
||	iffparse_lib.s -- resident module header for
||	iffparse.library 39.2 (WB3.0)
||
||	Matches the shipped binary's layout: a code hunk whose first
||	words are "moveq #-1,d0/rts", the RomTag, name/id strings and
||	the AUTOINIT InitTable (dataSize 0x44).  The word-offset
||	function table itself is emitted by iffparse.c (the offsets
||	can only be resolved inside the object that defines the
||	functions); it lands at text+0x58 because this object is
||	linked first.
||

	.section .text

|| executable-entry return value for non-resident loaders
	moveq	#-1,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	39			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"iffparse.library"
	.byte	0
_idstr:
	.ascii	"iffparse 39.2 (28.8.92)"
	.byte	0xd,0xa,0
	.even

|| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x44			| sizeof(struct IFFBase)
	.long	_functab
	.long	0			| no InitStruct data
	.long	_LibInit
