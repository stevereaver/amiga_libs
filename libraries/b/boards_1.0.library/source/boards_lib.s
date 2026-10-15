|||
|||	boards_lib.s -- resident module header for
|||	boards.library 1.0 (binary: boards_1.0.library)
|||
|||	Single-code-hunk AUTOINIT library by Richard Koerber,
|||	replacing Torsten Bach's boards.library.  The InitTable uses
|||	an ABSOLUTE LONG function table (not word offsets).
|||
|||	Layout (code hunk offsets):
|||	  0x00  moveq #-1,d0 / rts
|||	  0x04  RomTag (RTF_AUTOINIT, ver 1)
|||	  0x1e  "boards.library"
|||	  0x2d  "boards.library 1.0 (14.4.96)\r\n"
|||	  0x4e  copyright/author string
|||	  0xd0  InitTable -> functab 0xe0, datatable 0xf8, init 0x118
|||	  0xe0  function table (absolute .long entries, see functab.s)
|||	  0xf8  InitStruct data (see datatab.s)
|||	  0x118 code
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
	.long	_endcode		| RT_ENDSKIP (original: 0x200, hunk end)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"boards.library"
	.byte	0
_idstr:
	.ascii	"boards.library 1.0 (14.4.96)"
	.byte	0xd,0xa,0
	.even
||| Copyright string embedded by the original author
||| (0xf6 = 'oe' umlaut in ISO-8859-1, "Koerber").
_copyright:
	.ascii	"boards.library V1.0  Replaces boards.library by Torsten "
	.ascii	"Bach    (C) 1995-96 Richard K\xf6rber     e-mail: "
	.ascii	"shred@tfh.dssd.sub.org   "
	.byte	0xd,0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2c			| sizeof(libbase): Library + 0x0a
	.long	_functab		| ABSOLUTE LONG vector table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| init routine
