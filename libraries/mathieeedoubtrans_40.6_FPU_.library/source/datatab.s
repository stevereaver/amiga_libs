|||
|||	datatab.s -- InitStruct byte stream for
|||	mathieeedoubtrans.library 40.6.
|||
|||	  a0 08 09 00          INITBYTE  ln_Type(0x08)      = 9
|||	  80 0a <name>         INITLONG  ln_Name(0x0a)      = libname
|||	  a0 0e 06 00          INITBYTE  lib_Flags(0x0e)    = 0x06
|||	  90 14 0028           INITWORD  lib_Version(0x14)  = 40
|||	  90 16 0006           INITWORD  lib_Revision(0x16) = 6
|||	  80 18 <idstr>        INITLONG  lib_IdString(0x18) = idstr
|||	  00 00                terminator
|||

	.section .text

	.globl	_datatab
_datatab:
	.byte	0xa0,0x08,0x09,0x00	| INITBYTE  ln_Type = 9
	.byte	0x80,0x0a
	.long	_libname		| INITLONG  ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| INITBYTE  lib_Flags = 6
	.byte	0x90,0x14
	.word	40			| INITWORD  lib_Version
	.byte	0x90,0x16
	.word	6			| INITWORD  lib_Revision
	.byte	0x80,0x18
	.long	_idstr			| INITLONG  lib_IdString
	.byte	0x00,0x00		| end of stream
