/* cddb.library 44.999 - hunk1 DATA reconstruction
 * Runtime template: copied (96 bytes) into lib+48 at init.
 * [0]=pad [4]=dsize [8]=functab->h0 [0xc]=datatab(0) [0x10]=initfn->h0
 * [0x14,0x18]=freedb/utility base slots [0x1c..0x50]=14 ptrs
 * (12 err strings + runlist + stub0) [0x54,0x58]=fnlist terminator
 * [0x5c]=fixup delta (0x4c -> &ctx[0x4c]) [0x60]=fix count(1)
 * [0x64]=0x5c
 */
	.data
	.globl	_dt0
	.globl	_inittab
_dt0:	.long	0
_inittab:
	.long	0x9c			/* lib data size */
	.long	_functab
	.long	0			/* datatab */
	.long	_init
	.long	0			/* ctx+20: freedb base */
	.long	0			/* ctx+24: utility base */
	.long	_err0			/* ctx+0x1c: err table */
	.long	_err1
	.long	_err2
	.long	_err3
	.long	_err4
	.long	_err5
	.long	_err6
	.long	_err7
	.long	_err8
	.long	_err9
	.long	_err10
	.long	_err11
	.long	_runlist		/* ctx+0x4c: fn list head */
	.long	_stub0			/* ctx+0x50: fn list[1] */
	.long	0			/* ctx+0x54: terminator */
	.long	0			/* ctx+0x58 */
	.long	0x4c			/* ctx+0x5c: fixup delta -> &ctx[0x4c] */
	.long	1			/* +0x60: fix count (not copied) */
	.long	0x5c			/* +0x64: fix delta */
	.end
