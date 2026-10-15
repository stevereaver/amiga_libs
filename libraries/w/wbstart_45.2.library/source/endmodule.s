||||
||||	endmodule.s -- end-of-.text marker (_endcode).  The
||||	RomTag's RT_ENDSKIP points at _enddata in the data
||||	hunk (defined in wbstart_lib.s); the original's
||||	EndSkip covers the data hunk.  Linked last.
||||

	.section .text
	.globl	_endcode
_endcode:
