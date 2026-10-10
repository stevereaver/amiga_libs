|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field (the original's EndSkip covers the
|||	whole code hunk).  Linked last.
|||

	.section .text
	.globl	_endcode
_endcode:
