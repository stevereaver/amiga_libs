|||
|||	datatab.s -- InitStruct data table for _asl.library.
|||	Linked after the generated function table to preserve the
|||	original layout order.  The leading .word -1 reproduces the
|||	extra pad word (code+0x6c) between the table terminator and
|||	the InitStruct data.
|||
|||	  INITBYTE (0x0c, 9)	quirk: writes byte 9 at libbase+0x0c,
|||				inside the ln_Name pointer -- overwritten
|||				immediately by the INITLONG below
|||	  INITLONG (0x0a)	ln_Name    = "_asl.library"
|||	  INITBYTE (0x0e, 6)	lib_Flags  = LIBF_CHANGED|LIBF_SUMUSED
|||	  INITWORD (0x14, 40)	lib_Version
|||	  INITWORD (0x16, 6)	lib_Revision
|||	  INITLONG (0x18)	lib_IdString
|||	  INITLONG (0x26)	sh_RealName = "_asl.library"+1
|||				  i.e. "asl.library" -- the target name
|||

	.section .text
	.word	-1			| second -1 pad word (original image)
	.globl	_datatab
_datatab:
	.word	0xa00c,0x0900		| INITBYTE(0x0c,9) -- quirk
	.word	0x800a
	.long	_libname		| INITLONG(0x0a)
	.word	0xa00e,0x0600		| INITBYTE(0x0e,6)
	.word	0x9014,40		| INITWORD(0x14,40)
	.word	0x9016,6		| INITWORD(0x16,6)
	.word	0x8018
	.long	_idstr			| INITLONG(0x18)
	.word	0x8026
	.long	_libname+1		| INITLONG(0x26) = "asl.library"
	.word	0			| InitStruct terminator
