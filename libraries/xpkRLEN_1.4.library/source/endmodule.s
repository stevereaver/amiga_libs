||||
||||	endmodule.s -- end marker object (linked last so that
||||	_endcode lands at the end of the hunk, matching the
||||	original's RT_ENDSKIP = module end)
||||

	.section .text
	.globl	_endcode
_endcode:
