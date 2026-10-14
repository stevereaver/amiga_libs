/* script.library 0.4 -- hunk 2 (CODE): absolute functab + strings.
 * 12 vector entries (all -> hunk0) + -1 terminator.
 */
	.globl	_H2
	.text
_H2:
	.long	_H0+0xc4		/* -6  Open */
	.long	_H0+0xd6		/* -12 Close */
	.long	_H0+0x100		/* -18 Expunge */
	.long	_H0+0			/* -24 null stub (hunk0+0) */
	.long	_H0+0x18e		/* -30 */
	.long	_H0+0x206		/* -36 */
	.long	_H0+0x25e		/* -42 CreateContext */
	.long	_H0+0x2e6		/* -48 DestroyContext */
	.long	_H0+0x328		/* -54 SetCallback */
	.long	_H0+0x342		/* -60 GetCallback */
	.long	_H0+0x35c		/* -66 AddEntry */
	.long	_H0+0x38e		/* -72 FindEntry */
	.long	-1
	.ascii	"script.library\0"	/* +0x34 */
	.byte	0			/* +0x43 pad */
	.ascii	"script.library 0.4\0"	/* +0x44 */
	.byte	0x61			/* +0x57 tail pad */
