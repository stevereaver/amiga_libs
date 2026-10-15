|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field.  Linked last so _endcode lands at the
|||	end of the code hunk (the original's EndSkip covers the
|||	whole module).
|||

	.section .text
	.globl	_endcode
_endcode:
