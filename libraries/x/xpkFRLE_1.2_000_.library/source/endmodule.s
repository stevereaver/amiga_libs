|||
|||	endmodule.s -- trailing word at the end of the code hunk.
|||	(The original ends with the unterminated "EVE" tag; our
|||	link keeps a pad word here.)
|||

	.section .text
	.even
	.globl	_endmodule
_endmodule:
	.word	0
