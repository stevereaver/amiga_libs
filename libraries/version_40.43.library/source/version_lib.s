|||
|||	version_lib.s -- resident module header for
|||	version.library 40.43
|||
|||	Matches the shipped binary's layout: a code hunk whose first
|||	words are "moveq #-1,d0/rts", the RomTag, name/id strings and
|||	the AUTOINIT InitTable (dataSize 0x2a).  The word-offset
|||	function table is emitted by genfunctab.py in pass 2 and lands
|||	right after the InitTable because this object is linked first.
|||

	.section .text

||| executable-entry return value for non-resident loaders
	moveq	#-1,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	40			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"version.library"
	.byte	0
_idstr:
	.ascii	"version 40.43 (07.2.11)"
	.byte	0xd,0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2a			| sizeof(struct VersionBase)
	.long	_functab
	.long	0			| no InitStruct data
	.long	_LibInit
