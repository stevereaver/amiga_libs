|||
|||	asl_lib.s -- resident module header for _asl.library 40.6
|||	(binary: _asl._40.6.library)
|||
|||	Single-code-hunk AUTOINIT library.  A shim: its six public
|||	vectors (-30..-60) relay to the corresponding LVOs of the
|||	real asl.library, which it opens by name on every call.
|||
|||	Layout (code hunk offsets):
|||	  0x00  moveq #-1,d0 / rts
|||	  0x04  RomTag (RTF_AUTOINIT, ver 40)
|||	  0x1e  "_asl.library"	(name+1 == "asl.library")
|||	  0x2b  "$VER: _asl.library 40.6"
|||	  0x44  InitTable -> functab 0x54, datatable 0x6e, init 0x94
|||	  0x54  word-offset function table (10 entries + 2 x -1)
|||	  0x6e  InitStruct data (see datatab.s)
|||	  0x94  code
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
	.long	_endcode		| RT_ENDSKIP (original: 0x164, hunk end)
	.byte	0x80			| RTF_AUTOINIT
	.byte	40			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"_asl.library"
	.byte	0
_idstr:
	.ascii	"$VER: _asl.library 40.6"
	.byte	0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2e			| sizeof(libbase): Library + 3 longs
	.long	_functab		| word-offset vector table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| init routine
