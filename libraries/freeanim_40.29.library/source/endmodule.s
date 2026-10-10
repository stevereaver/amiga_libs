|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field.  The original pointed EndSkip at the
|||	trailing pad word (code+0x6a), two bytes before the end of
|||	the hunk, so the label is defined before a final .word 0.
|||
|||	Linked last so _endcode lands at the end of the code hunk.
|||

	.section .text
	.globl	_endcode
_endcode:
	.word	0
