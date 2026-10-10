||||
||||	functab_stub.s -- placeholder word-offset functab for the
||||	pass-1 link.  genfunctab.py replaces it with real offsets
||||	relative to _functab (the -1 marker address).
||||

	.section .text
	.globl	_functab
_functab:
	.word	-1
	.word	0,0,0,0,0,0,0,0,0,0
	.word	-1
