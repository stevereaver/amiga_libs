/* asyncio.library 37.2 -- hunk 1: BSS globals (20 bytes, 5 longs).
 * fixup.py rewrites the emitted DATA hunk (0x3ea) to HUNK_BSS
 * (0x3eb) and strips the zero body to match the original.
 *
 *  +0  libbase   +4  execbase   +8  UtilityBase
 *  +12 DOSBase   +16 seglist
 */

	.globl	_bsx

	.section .bss
_bsx:
	.space	20
