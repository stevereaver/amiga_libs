|||
|||	fantasia_lib.s -- resident module header for
|||	fantasia.library 1.0 (binary: fantasia_1.0.library)
|||
|||	Single-code-hunk AUTOINIT library.  Quirks of the original:
|||	  - the executable entry returns 0, not -1
|||	  - RT_ENDSKIP points at the InitTable itself (0x52),
|||	    mid-module, identical to RT_INIT
|||	  - the InitStruct starts with INITBYTE(0x0c,9), writing
|||	    inside the ln_Name pointer (same quirk as _asl)
|||
|||	Layout (code hunk offsets):
|||	  0x00  moveq #0,d0 / rts
|||	  0x04  RomTag (RTF_AUTOINIT, ver 1)
|||	  0x1e  "fantasia.library"
|||	  0x2f  "fantasia.library 1.0\n"	(\n only, no \r)
|||	  0x46  "dos.library"
|||	  0x52  InitTable -> functab 0x62, datatable 0x7c, init 0x9a
|||	  0x62  function table (absolute .long, see functab.s)
|||	  0x7c  InitStruct data (see datatab.s)
|||	  0x9a  code
|||

	.section .text
	.globl	_libname
	.globl	_idstr
	.globl	_dosname

	moveq	#0,d0			| original entry returns 0, not -1
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_inittab		| RT_ENDSKIP == RT_INIT (quirk)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"fantasia.library"
	.byte	0
_idstr:
	.ascii	"fantasia.library 1.0"
	.byte	0xa,0
	.even
_dosname:
	.ascii	"dos.library"
	.byte	0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x30			| sizeof(libbase): Library + 0x0e
	.long	_functab		| ABSOLUTE LONG vector table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| init routine
