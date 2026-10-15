|||
|||	endmodule.s -- end marker for the RomTag's RT_ENDSKIP field.
|||	The original binary pointed EndSkip at the code hunk's trailing
|||	alignment word rather than at a label boundary, so the label is
|||	placed before a literal pad word.
|||
|||	Linked last so _endcode lands at the end of the code hunk.
|||

	.section .text
	.globl	_endcode
_endcode:
	.word	0
