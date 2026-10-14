/* script.library 0.4 -- hunk 1 (DATA, 6 longs = 24 bytes):
 * [0x00] pad, [0x04] InitTable {dsize=0x50, ftab->h2+0, dtab=0,
 * initfn->h0+0x20}, [0x14] pad (read as fixup count at init).
 * Init copies these 20 bytes to lib+48.
 */
	.globl	_H1
	.data
_H1:
	.long	0			/* +0x00 pad */
	.long	0x50			/* +0x04 dataSize = 80 */
	.long	_H2			/* +0x08 funcTable -> h2+0 */
	.long	0			/* +0x0c dataTable = NULL */
	.long	_H0+0x20		/* +0x10 initFn -> h0+0x20 */
	.long	0			/* +0x14 pad / fixup count = 0 */
