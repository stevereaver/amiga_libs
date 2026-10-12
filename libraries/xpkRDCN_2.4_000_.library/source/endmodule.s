| endmodule.s -- end marker for the RomTag's RT_ENDSKIP.
| The original's code hunk tail is the stray bytes 72 00 00 08
| (linker tail garbage); reproduce verbatim.
	.section .text
	.globl	_endmodule
_endmodule:
	.byte	0x72,0x00,0x00,0x08
