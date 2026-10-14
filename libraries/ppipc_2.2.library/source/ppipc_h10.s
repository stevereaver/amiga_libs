/* ppipc.library 2.2 -- hunk10 CODE (0x28 bytes)
 * GetMsg/WaitPort wrappers: reload SysBase from hunk1+0x32 so they can
 * be called from contexts where a6 is not exec. No functab entries
 * point here; reached only via hunk7's jmp stubs. */

	.globl	_getmsgstub,_waitstub,_sysbase

	.text
_getmsgstub:					/* h10+0 */
	movel	%a6,%sp@-
	.short	0x2c79
	.long	_sysbase			/* moveal _sysbase:l,a6 */
	moveal	%sp@(8),%a0
	jsr	%a6@(-372)			/* GetMsg */
	moveal	%sp@+,%a6
	rts
_waitstub:					/* h10+0x14 */
	movel	%a6,%sp@-
	.short	0x2c79
	.long	_sysbase			/* moveal _sysbase:l,a6 */
	moveal	%sp@(8),%a0
	jsr	%a6@(-384)			/* WaitPort */
	moveal	%sp@+,%a6
	rts
