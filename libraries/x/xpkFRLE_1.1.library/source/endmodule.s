|||
|||	endmodule.s -- trailing word at the end of the code hunk;
|||	RT_ENDSKIP points here (original endskip = hunk end).
|||

	.section .text
	.even
	.globl	_endmodule
_endmodule:
	.word	0
