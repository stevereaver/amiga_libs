/* write.library 4.2 -- hunk 2 (DATA, 0x15 longs = 84 bytes):
 * [0x00] unused pad
 * [0x04] InitTable: dsize=0xb0, ftab->h1+0, dtab=0, initfn->h0+0x20
 * [0x14] runtime template copied per-open: callback ptrs, con: spec
 */
	.globl	_template
	.data
_template:
	.long	0			/* +0x00 pad */
	.long	0xb0			/* +0x04 dataSize = 176 */
	.long	_functab		/* +0x08 -> hunk1+0 (RELOC32 h1) */
	.long	0			/* +0x0c dataTable = NULL */
	.long	_initfn			/* +0x10 -> h0+0x20 */
	.long	_verstr			/* +0x14 -> h0+0x2e6 $VER str */
	.long	_listwalk		/* +0x18 -> h0+0x5e0 */
	.long	_openrexx		/* +0x1c -> h0+0x7a8 */
	.long	_opendos		/* +0x20 -> h0+0x80c */
	.long	0			/* +0x24 */
	.long	_closedos		/* +0x28 -> h0+0x846 */
	.long	_closerexx		/* +0x2c -> h0+0x7ea */
	.long	0			/* +0x30 */
	.long	0x18			/* +0x34 */
	.ascii	"con:10/10/320/80/\0"	/* +0x38..+0x4a */
	.byte	0,0
	.long	1			/* +0x4c */
	.long	0x34			/* +0x50 */
