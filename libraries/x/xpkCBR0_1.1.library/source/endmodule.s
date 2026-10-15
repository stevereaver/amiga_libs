||||
||||	endmodule.s -- end marker for the RomTag's RT_ENDSKIP.
||||	Linked last so _endcode/_endmodule lands at hunk end.
||||

	.section .text
	.globl	_endmodule
_endmodule:
	.word	0
