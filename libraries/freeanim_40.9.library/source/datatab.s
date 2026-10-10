|||
|||	datatab.s -- InitStruct data table (exec/initializers.i
|||	encoding).  Linked after the generated function table to
|||	preserve the original layout order.
|||
|||	  INITBYTE (0x08, 9)	ln_Type    = NT_LIBRARY
|||	  INITLONG (0x0a)	ln_Name    = "freeanim.library"
|||	  INITBYTE (0x0e, 6)	lib_Flags  = LIBF_CHANGED|LIBF_SUMUSED
|||	  INITWORD (0x14, 40)	lib_Version
|||	  INITWORD (0x16, 9)	lib_Revision
|||	  INITLONG (0x18)	lib_IdString
|||
|||	The original follows the terminator with a stray NOP word
|||	(0x8e), reproduced here.
|||

	.section .text
	.globl	_datatab
_datatab:
	.word	0xa008,0x0900		| INITBYTE(8,9)
	.word	0x800a
	.long	_libname		| INITLONG(0x0a)
	.word	0xa00e,0x0600		| INITBYTE(0x0e,6)
	.word	0x9014,40		| INITWORD(0x14,40)
	.word	0x9016,9		| INITWORD(0x16,9)
	.word	0x8018
	.long	_idstr			| INITLONG(0x18)
	.word	0			| InitStruct terminator
	.word	0x4e71			| stray NOP (original byte image)
