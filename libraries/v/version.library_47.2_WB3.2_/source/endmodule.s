|||
|||	endmodule.s -- end marker for the RomTag's RT_ENDSKIP field.
|||	The original's EndSkip covers the code hunk and lands on the
|||	trailing zero word; linked last so _endcode is that word.
|||

	.section .text
	.globl	_endcode
_endcode:
	.word	0
