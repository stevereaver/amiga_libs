|||
|||	endmodule.s -- end marker for the RomTag's RT_ENDSKIP field.
|||	The 44.x/45.x binaries point EndSkip at the *second byte* of
|||	the code hunk's trailing pad (an odd address), so the label is
|||	deliberately placed one byte into a literal pad.
|||
|||	Linked last so _endcode lands at the end of the code hunk.
|||

	.section .text
	.byte	0
	.globl	_endcode
_endcode:
	.byte	0
