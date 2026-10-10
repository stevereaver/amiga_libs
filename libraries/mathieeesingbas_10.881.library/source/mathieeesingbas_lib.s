|||
|||	mathieeesingbas_lib.s -- resident module header + AUTOINIT
|||	tables for mathieeesingbas.library "MSB 10.881"
|||	(Kickstart 1.x disk library for the MC68881/68882).
|||
|||	Code-hunk layout (as shipped):
|||	  0x00  rts                     (bare RTS entry, no moveq)
|||	  0x02  RomTag  (RTF_AUTOINIT, rt_Version 45, NT_LIBRARY)
|||	  0x1c  InitTable (dataSize 0x3c)
|||	  0x2c  longword cell -- initfunc stores the seglist here
|||	  0x30  word-offset function table (linked from functab.o)
|||
|||	The word-offset table is the "-1 flag word + word offsets
|||	relative to the table start + -1 terminator" form consumed
|||	by MakeLibrary (see genfunctab.py).
|||

	.section .text

	rts				| executable entry: bare RTS

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	45			| RT_VERSION (0x2d)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x3c			| dataSize
	.long	_functab		| generated offset table
	.long	_datatab		| InitStruct byte stream
	.long	_LibInit		| init routine

	.globl	_segcell
_segcell:
	.long	0			| seglist cell at text+0x2c

	.end
