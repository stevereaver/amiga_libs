|||
|||	endmodule.s -- end-of-.text marker (_endcode) and
|||	end-of-.data marker (_enddata) for the RomTag's
|||	RT_ENDSKIP field (the original's EndSkip covers the
|||	data hunk).  Linked last.
|||

	.section .text
	.globl	_endcode
_endcode:
