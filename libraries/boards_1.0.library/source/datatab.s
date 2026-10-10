|||
|||	datatab.s -- InitStruct data table (exec initializers
|||	encoding).  Linked after functab.o to preserve the original
|||	layout order (inittab -> functab -> datatable -> code).
|||
|||	  INITBYTE (0x08, 9)	ln_Type    = NT_LIBRARY
|||	  INITLONG (0x0a)	ln_Name    = "boards.library"
|||	  INITBYTE (0x0e, 6)	lib_Flags  = LIBF_CHANGED|LIBF_SUMUSED
|||	  INITWORD (0x14, 1)	lib_Version
|||	  INITWORD (0x16, 0)	lib_Revision
|||	  INITLONG (0x18)	lib_IdString
|||

	.section .text
	.globl	_datatab
_datatab:
	.word	0xa008,0x0900		| INITBYTE(8,9)
	.word	0x800a
	.long	_libname		| INITLONG(0x0a)
	.word	0xa00e,0x0600		| INITBYTE(0x0e,6)
	.word	0x9014,1		| INITWORD(0x14,1)
	.word	0x9016,0		| INITWORD(0x16,0)
	.word	0x8018
	.long	_idstr			| INITLONG(0x18)
	.word	0			| InitStruct terminator
