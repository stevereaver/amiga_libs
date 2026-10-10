|||
|||	datatab.s -- InitStruct data table (exec initializers
|||	encoding).  Linked after functab.o to preserve the original
|||	layout order.
|||
|||	  INITBYTE (0x0c, 9)	quirk: byte 9 into the ln_Name
|||				pointer (should have been 0x08 = ln_Type);
|||				overwritten by the next op.  Same quirk
|||				as _asl 40.6.
|||	  INITLONG (0x0a)	ln_Name    = "fantasia.library"
|||	  INITBYTE (0x0e, 6)	lib_Flags
|||	  INITWORD (0x14, 1)	lib_Version
|||	  INITWORD (0x16, 0)	lib_Revision
|||	  INITLONG (0x18)	lib_IdString
|||

	.section .text
	.globl	_datatab
_datatab:
	.word	0xa00c,0x0900		| INITBYTE(0x0c,9) -- quirk
	.word	0x800a
	.long	_libname		| INITLONG(0x0a)
	.word	0xa00e,0x0600		| INITBYTE(0x0e,6)
	.word	0x9014,1		| INITWORD(0x14,1)
	.word	0x9016,0		| INITWORD(0x16,0)
	.word	0x8018
	.long	_idstr			| INITLONG(0x18)
	.word	0			| InitStruct terminator
