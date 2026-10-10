|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field (the original binary pointed EndSkip at
|||	the end of the code hunk).
|||
|||	Linked last so _endcode lands at the end of the code hunk.
|||

	.section .text
	.globl	_endcode
_endcode:
