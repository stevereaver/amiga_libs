|||
|||	cachemap_lib.s -- resident module header for
|||	cachemap.library 34.5 (10.3.92)
|||
|||	Single code hunk: "moveq #0,d0/rts" entry, RomTag
|||	(version 34), InitTable (dataSize 0x3c, no InitStruct
|||	data -- init routine writes the public Library fields
|||	itself) and a word-offset AUTOINIT function table
|||	(-1W marker, offsets relative to the table start,
|||	-1W terminated).  The table is emitted by
|||	genfunctab.py on the second link pass; functab_stub.s
|||	is the size-correct stand-in for pass 1.
|||
|||	LVO -24 is a negative offset back to the module entry
|||	(moveq #0,d0/rts) as in the original.

	.section .text

||| executable-entry return value for non-resident loaders
_libentry:
	moveq	#0,d0
	rts

	.globl	_libentry
	.globl	_functab

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

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x3c			| sizeof(struct CacheMapBase)
	.long	_functab
	.long	0			| no InitStruct data
	.long	_LibInit

	.globl	_gfxname
	.globl	_libname
	.globl	_idstr
_gfxname:
	.ascii	"graphics.library"
	.byte	0
_libname:
	.ascii	"cachemap.library"
	.byte	0
_idstr:
	.ascii	"CacheMap 34.5 (10.3.92)"
	.byte	0xd,0xa,0
	.even
