|||
|||	endmodule.s -- end-of-.text marker for the RomTag's
|||	RT_ENDSKIP field.  Linked last so _endcode lands at the
|||	end of the code hunk.
|||
|||	This build's EndSkip points two bytes before the end of
|||	the hunk: the code area is padded to a longword with a
|||	trailing zero word after the last rts.  Reproduced here.
|||

	.section .text
	.globl	_endcode
_endcode:
	.word	0
