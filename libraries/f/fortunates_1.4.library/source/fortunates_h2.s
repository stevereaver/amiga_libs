/* fortunates.library 1.4 -- hunk 2: BSS, 0x26 longs (152 bytes).
 * fixup.py converts the emitted DATA hunk back to HUNK_BSS.
 *
 *  +0x00 execbase (copy of $4)    +0x04 dos        +0x08 intuition
 *  +0x0c graphics               +0x10 gadtools   +0x14 icon
 *  +0x18 diskfont               +0x1c asl        +0x20 reqtools
 *  +0x24 workbench              +0x28 reqtools drawertext buffer
 *  +0x2c..+0x97 scratch/unused
 */
	.globl	_bss
	.section .bss
_bss:	.space	152
