/* ppipc.library 2.2 -- hunk2 DATA (0xa0 bytes)
 * name + idstr, ver/rev words (copied to lib by initfn), the
 * 22-entry absolute-long functab, and the InitTable at +0x8a. */

	.globl	_libname,_idstr,_verword,_revword,_functab,_inittab,_datatab
	.globl	_init,_open,_close,_expunge,_nullret
	.globl	_findport,_getport,_sigport,_relport,_portsig,_setsig,_freesig
	.globl	_portflags,_putmsg,_allocmsg,_freemsg,_broker,_str2id,_findid

	.data
_libname:					/* h2+0x00 */
	.ascii	"ppipc.library\0"
_idstr:						/* h2+0x0e */
	.ascii	"PPIPC version 2.2 89:04:17\n\0"
_verword:					/* h2+0x2a */
	.short	2
_revword:					/* h2+0x2c */
	.short	2
_functab:					/* h2+0x2e */
	.long	_open				/* -6   h3+0x46 */
	.long	_close				/* -12  h3+0xbc */
	.long	_expunge			/* -18  h3+0x5a */
	.long	_nullret			/* -24  h3+0xda */
	.long	_findport			/* -30  h5+0xc6 */
	.long	_getport			/* -36  h5+0x114 */
	.long	_sigport			/* -42  h5+0x96 */
	.long	_relport			/* -48  h5+0x172 */
	.long	_portsig			/* -54  h5+0x1ce */
	.long	_setsig				/* -60  h5+0x248 */
	.long	_freesig			/* -66  h5+0x27a */
	.long	_portflags			/* -72  h5+0x2ac */
	.long	_putmsg				/* -78  h5+0x2f6 */
	.long	_allocmsg			/* -84  h5+0x32c */
	.long	_freemsg			/* -90  h5+0x38c */
	.long	_broker				/* -96  h7+0 */
	.long	_str2id				/* -102 h9+0 */
	.long	_findid				/* -108 h9+0x30 */
	.long	_nullret			/* -114 */
	.long	_nullret			/* -120 */
	.long	_nullret			/* -126 */
	.long	_nullret			/* -132 */
	.long	-1
_inittab:					/* h2+0x8a */
	.long	0x22				/* dsize = sizeof(struct Library) */
	.long	_functab			/* functab -> hunk2+0x2e */
	.long	_datatab			/* datatab -> hunk1+0 */
	.long	_init				/* initfn  -> hunk3+0 */
	.long	0x22				/* h2+0x9a tail data */
	.short	0				/* h2+0x9e */
