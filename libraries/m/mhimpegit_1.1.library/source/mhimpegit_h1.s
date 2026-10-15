/* mhimpegit.library 1.1 -- hunk1: near-data block.
 * Header allocates 16 B (4 LW) but the DATA hunk body is only 4 B;
 * _gd+0 SysBase copy, +4 IntuitionBase, +8 DOSBase, +0xc PreludeBase.
 * fixup.py truncates the stored body to 1 longword like the original. */
	.data
	.globl	_gd
_gd:	.long	0,0,0,0
