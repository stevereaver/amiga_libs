|||	functab_stub.s -- size-correct stand-in for the AUTOINIT
|||	function table.  12 words: marker + 10 entries + terminator.

	.section .text
	.globl	_functab
_functab:
	.word	-1
	.word	0,0,0,0,0,0,0,0,0,0
	.word	-1
