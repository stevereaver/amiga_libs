|||
|||	freeanim_lib.s -- resident module header for
|||	freeanim.library 40.29 (binary: freeanim_40.29.library)
|||
|||	The shipped binary is a minimal AUTOINIT stub: a single code
|||	hunk holding the resident header, name/id strings, an
|||	InitTable (dataSize 0x2a, no InitStruct data) and a
|||	word-offset function table whose four entries all point at
|||	the same "moveq #0,d0 / rts" routine -- which is also the
|||	init function.
|||
|||	Layout (code hunk offsets):
|||	  0x00  moveq #-1,d0 / rts		(run entry)
|||	  0x04  RomTag (RTF_AUTOINIT, ver 40, NT_LIBRARY, pri 0)
|||	  0x1e  "freeanim.library"
|||	  0x2f  "freeanim 40.29 (1.4.94)\r\n"
|||	  0x4a  InitTable
|||	  0x5a  function table (4 word offsets -> +0x66)
|||	  0x66  moveq #0,d0 / rts		(shared stub)
|||	  0x6a  pad word (RT_ENDSKIP target)
|||

	.section .text

||| executable-entry return value for non-resident loaders
	moveq	#-1,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP (original: last pad word)
	.byte	0x80			| RTF_AUTOINIT
	.byte	40			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"freeanim.library"
	.byte	0
_idstr:
	.ascii	"freeanim 40.29 (1.4.94)"
	.byte	0xd,0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2a			| sizeof(libbase): Library + 2 pad longs
	.long	_functab		| word-offset vector table
	.long	0			| no InitStruct data
	.long	_LibNull		| init routine == the shared null stub
