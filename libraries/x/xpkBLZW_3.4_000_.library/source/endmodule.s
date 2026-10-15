| endmodule.s -- code-hunk tail for xpkBLZW.library.
| The original ends with the stray long 00 00 00 18
| (linker tail garbage); reproduce verbatim.
	.section .text
	.globl	_endmodule
_endmodule:
	.byte	0x00,0x00,0x00,0x18
