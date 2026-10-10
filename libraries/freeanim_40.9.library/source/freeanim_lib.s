|||
|||	freeanim_lib.s -- resident module header for
|||	freeanim.library 40.9 (binary: freeanim_40.9.library)
|||
|||	Single-code-hunk AUTOINIT library.  InitTable dataSize 0x26
|||	(Library + seglist slot), word-offset function table with
|||	the four system vectors only (-6/-12/-18/-24), InitStruct
|||	data table, and a real Open/Close/Expunge/init routine set.
|||
|||	Layout (code hunk offsets):
|||	  0x00  moveq #-1,d0 / rts
|||	  0x04  RomTag (RTF_AUTOINIT|RTF_COLDSTART, ver 40)
|||	  0x1e  "freeanim.library"
|||	  0x2f  "freeanim.library 40.9 (11.8.95)\r\n"
|||	  0x51  stray bytes: 4e 71 (a NOP at odd address) + 00
|||	  0x54  InitTable -> functab 0x64, datatable 0x70, init 0x128
|||	  0x64  function table (word offsets)
|||	  0x70  InitStruct data (see datatab.s)
|||	  0x90  code
|||

	.section .text
	.globl	_libname
	.globl	_idstr

	moveq	#-1,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP (original: 0x130, hunk end)
	.byte	0x81			| RTF_AUTOINIT | RTF_COLDSTART
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
	.ascii	"freeanim.library 40.9 (11.8.95)"
	.byte	0xd,0xa,0
||| stray filler in the original image: a NOP opcode at an odd
||| address (0x51) followed by a pad byte -- reproduced verbatim.
	.byte	0x4e,0x71,0

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x26			| sizeof(libbase): Library + seglist
	.long	_functab		| word-offset vector table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| init routine
