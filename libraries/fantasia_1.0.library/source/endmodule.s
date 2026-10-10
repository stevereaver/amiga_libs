|||
|||	endmodule.s -- end-of-.text marker.  Linked last.
|||	(The original's RT_ENDSKIP pointed at the InitTable, not
|||	here; this label is only used as the general hunk-end
|||	anchor for completeness.)
|||

	.section .text
	.globl	_endcode
_endcode:
