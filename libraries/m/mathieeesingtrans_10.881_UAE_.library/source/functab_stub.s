|||
|||	functab_stub.s -- size-correct stand-in for the AUTOINIT
|||	function table.  Linked in pass 1 so that every function's
|||	final .text address is known; genfunctab.py then emits
|||	functab.s with the real word offsets.
|||
|||	23 words: marker(-1) + 21 entries + terminator(-1).
|||

	.section .text
	.globl	_functab
_functab:
	.word	-1
	.rept	21
	.word	0
	.endr
	.word	-1
