/* write.library 4.2 -- hunk 1 (CODE, 0x10 longs):
 * absolute-long function table (8 vectors) + library name/idstr strings.
 * All 8 vector longs are RELOC32'd against hunk 0.
 */
	.globl	_functab,_libname,_idstr
	.text
_functab:
	.long	_open			/* -6   h0+0x0d0 */
	.long	_close			/* -12  h0+0x1fe */
	.long	_expunge		/* -18  h0+0x268 */
	.long	_nullvec		/* -24  h0+0x000 (the DOS stub rts) */
	.long	_vec30			/* -30  h0+0x2d8 */
	.long	_vec36			/* -36  h0+0x356 */
	.long	_vec42			/* -42  h0+0x4c4 */
	.long	_vec48			/* -48  h0+0x59c */
	.long	-1
_libname:
	.ascii	"write.library\0"	/* h1+0x24 */
	.byte	0,0
_idstr:
	.ascii	"Version 1.0\0"		/* h1+0x34 */
