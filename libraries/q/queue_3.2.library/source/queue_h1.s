/*
 * queue.library 3.2 -- hunk1 (DATA): InitTable embedded at h1+4 plus
 * the runtime template that initfn copies into lib+48.
 * relocs: h1+0x8 -> h2 functab, h1+0x10 -> h0 initfn.
 */
	.data
	.globl	_qdata
_qdata:
	.long	0
	.long	0x8c		/* InitTable data size */
	.long	_functab
	.long	0		/* datatab */
	.long	_initfn
	.long	0
	.long	0
	.long	0
