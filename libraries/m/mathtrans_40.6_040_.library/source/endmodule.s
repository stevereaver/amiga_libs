||||
||||	endmodule.s -- end marker for the RomTag's RT_ENDSKIP field.
||||	Linked last so _endcode lands at the end of the code hunk.
||||

	.section .text
	.globl	_endcode
_endcode:
	.word	0
