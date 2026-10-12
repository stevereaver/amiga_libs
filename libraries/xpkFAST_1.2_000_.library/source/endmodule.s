| endmodule.s -- end marker for the RomTag's RT_ENDSKIP.
| The original's code hunk tail is the stray bytes 00 21 e2 34
| (linker tail garbage); reproduce verbatim.
	.section .text
	.globl	_endmodule
_endmodule:
	.byte	0,0x21,0xe2,0x34
