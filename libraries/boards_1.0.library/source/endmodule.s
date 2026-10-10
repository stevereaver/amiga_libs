|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field.  Linked last so _endcode lands at the end
|||	of the code hunk (original EndSkip = 0x200 = hunk end).
|||

	.section .text
	.globl	_endcode
_endcode:
