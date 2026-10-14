/* ppipc.library 2.2 -- hunk1 DATA (0x38 bytes)
 * InitStruct datatab for MakeLibrary + SysBase global cell at +0x32.
 * datatab entries are word-aligned; 0xe0=w8/0xd0=w16/0xc0=w32 with
 * 24-bit offset (off byte + offset word). */

	.globl	_datatab,_sysbase,_libname,_idstr

	.data
_datatab:					/* h1+0 */
	.byte	0xe0,0,0,8,9,0			/* lib+8  ln_Type = 9 */
	.byte	0xe0,0,0,9,0,0			/* lib+9  ln_Pri  = 0 */
	.byte	0xc0,0,0,0x0a			/* lib+0xa ln_Name  = */
	.long	_libname			/*   -> hunk2+0 */
	.byte	0xe0,0,0,0x0e,6,0			/* lib+0xe ln_Flags = 6 */
	.byte	0xd0,0,0,0x14,0,1			/* lib+0x14 lib_Version = 1 */
	.byte	0xd0,0,0,0x16,0,0			/* lib+0x16 lib_Revision = 0 */
	.byte	0xc0,0,0,0x18			/* lib+0x18 lib_IdString = */
	.long	_idstr				/*   -> hunk2+0xe */
	.byte	0,0				/* end + pad */
	.short	0				/* +0x30 */
_sysbase:					/* h1+0x32 */
	.long	0				/* SysBase stored by init */
	.short	0				/* +0x36 pad */
