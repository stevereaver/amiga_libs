||
||	endmodule.s -- end-of-.text marker for the RomTag's
||	RT_ENDSKIP field (the original binary pointed EndSkip at the
||	tail of the module rather than just past the RomTag).
||
||	Linked last so _endcode lands at the end of the code hunk.
||

	.section .text
	.globl	_endcode
_endcode:
