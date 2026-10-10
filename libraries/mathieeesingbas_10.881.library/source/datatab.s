|||
|||	datatab.s -- InitStruct byte stream + module strings for
|||	mathieeesingbas.library.  Linked right after the function
|||	table so _datatab lands where the original kept it.
|||
|||	InitStruct stream (as shipped):
|||	  a0 0e 06 00   INITBYTE  lib_Flags(0x0e)    = 0x06
|||	  90 16 03 71   INITWORD  lib_Revision(0x16) = 881 (0x0371)
|||	  00 00         terminator
|||

	.section .text

	.globl	_datatab
_datatab:
	.byte	0xa0,0x0e,0x06,0x00	| INITBYTE lib_Flags = 0x06
	.byte	0x90,0x16,0x03,0x71	| INITWORD lib_Revision = 881
	.byte	0x00,0x00		| end of stream

	.globl	_libname
	.globl	_idstr
_libname:
	.ascii	"mathieeesingbas.library"
	.byte	0
_idstr:
	.ascii	"MSB 10.881"
	.byte	0
	.even
