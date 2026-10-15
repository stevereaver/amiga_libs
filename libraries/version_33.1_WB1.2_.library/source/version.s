/*
 * mylib 33.1 (25 Apr 1986) -- byte-exact reconstruction.
 * Two hunks: CODE hunk (0x45 longs) + empty second CODE hunk record.
 * AUTOINIT RomTag, absolute-long functab, InitStruct datatab.
 */
	.text
	.globl	_dosstub
	.globl	_romtag
	.globl	_endskip
	.globl	_inittab

_dosstub:
	.short	0x7000,0x4e75

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x21,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"version.library"
	.byte	0x00
_idstr:	.ascii	"mylib 33.1 (25 Apr 1986)\r\n"
	.byte	0x00,0x00

_inittab:
	.long	0x2c
	.long	_functab
	.long	_dtab
	.long	_initfn

_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_stub
	.long	0xffffffff

_dtab:
	.short	0xe000,0x0008
	.byte	0x09,0x00
	.short	0xc000,0x000a
	.long	_name
	.short	0xe000,0x000e
	.byte	0x06,0x00
	.short	0xd000,0x0014,0x0021
	.short	0xd000,0x0016,0x0038
	.short	0xc000,0x0018
	.long	_idstr
	.short	0,0

_initfn:
	moveal	d0,a1
	movel	a6,a1@(34)
	movel	a0,a1@(38)
	rts

_open:
	addqw	#1,a6@(32)
	bclr	#3,a6@(42)
	movel	a6,d0
	rts

_close:
	moveq	#0,d0
	subqw	#1,a6@(32)
	bnes	_cret
	btst	#3,a6@(42)
	beqs	_cret
	bsrw	_expunge
_cret:	rts

_expunge:
	moveml	d2/a5-a6,sp@-
	moveal	a6,a5
	moveal	a5@(34),a6
	tstw	a5@(32)
	beqw	_unlink
	bset	#3,a5@(42)
	moveq	#0,d0
	bras	_edone
_unlink:
	movel	a5@(38),d2
	moveal	a5,a1
	jsr	a6@(-252)
	moveal	a5,a1
	moveq	#0,d1
	moveq	#0,d0
	movew	a5@(16),d1
	subal	d1,a1
	movew	a5@(18),d0
	addl	d1,d0
	jsr	a6@(-210)
	movel	d2,d0
_edone:	moveml	sp@+,d2/a5-a6
	rts

_stub:	moveq	#0,d0
	rts

_endskip:
	.short	0x0000
