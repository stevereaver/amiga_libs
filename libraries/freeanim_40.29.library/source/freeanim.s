/* freeanim.library 40.29 (1.4.94) - single CODE hunk reconstruction
 * Placeholder/stub library: 4 word-offset vectors all -> moveq#0;rts.
 * initfn = same stub. dsize 0x2a, no datatab.
 */
	.text

/* ---- DOS stub @0x00 (returns -1) ---- */
	moveq	#-1,%d0
	rts

/* ---- RomTag @0x04 ---- */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x28,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"freeanim.library\0"	/* @0x1e */
_idstr:	.ascii	"freeanim 40.29 (1.4.94)\r\n\0"	/* @0x2f */
	.byte	0			/* pad @0x49 */

/* ---- InitTable @0x4a ---- */
_inittab:
	.long	0x2a			/* dsize */
	.long	_functab
	.long	0			/* datatab */
	.long	_stub			/* initfn -> return-0 stub */

/* ---- functab @0x5a: word-offset mode, 4 vectors -> _stub ---- */
_functab:
	.short	0xffff			/* word mode */
	.short	0x000c,0x000c,0x000c,0x000c
	.short	0xffff

/* ---- _stub @0x66 = vector target + initfn ---- */
_stub:	moveq	#0,%d0
	rts
_endskip:				/* RomTag EndSkip -> stub end */
	.short	0			/* pad to 0x6c */

	.globl	_romtag
	.end
