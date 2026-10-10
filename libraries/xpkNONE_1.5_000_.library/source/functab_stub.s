|||
|||	functab_stub.s -- size-correct stand-in for the AUTOINIT
|||	function table.  Linked in pass 1 so that every function's
|||	final .text address is known; genfunctab.py then emits
|||	functab.s with the real word offsets.
|||
|||	12 words: marker(-1) + 10 entries + terminator(-1) = 0x18.
|||

	.section .text
	.globl	_functab
_functab:
	.word	-1
	.rept	10
	.word	0
	.endr
	.word	-1
