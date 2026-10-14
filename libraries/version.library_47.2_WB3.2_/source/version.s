/*
 * version.library 47.2 (WB3.2) -- byte-exact reconstruction.
 * Single CODE hunk, AUTOINIT RomTag, word-offset function table.
 * Real lifecycle: Open clears DELEXP bit (lib+14 bit3), Close expunges
 * inline when opencnt hits 0 and DELEXP is set, Expunge defers while open.
 */
	.text
	.globl	_dosstub
	.globl	_romtag
	.globl	_endskip
	.globl	_inittab

_dosstub:
	moveq	#-1,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x2f,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"version.library"
	.byte	0
_idstr:	.ascii	"version 47.2 (10.4.2021)"
	.byte	0x0d,0x0a,0x00
	.byte	0

_inittab:
	.long	0x2a
	.long	_functab
	.long	0
	.long	_initfn

_functab:
	.short	0xffff
	.short	_open-_functab
	.short	_close-_functab
	.short	_expunge-_functab
	.short	_stub-_functab
	.short	0xffff

_initfn:
	exg	d0,a5
	movel	a6,a5@(34)
	movel	a0,a5@(38)
	movew	#2,a5@(22)
	exg	d0,a5
	rts

_open:
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	rts

_close:
	subqw	#1,a6@(32)
	bnes	_cret
	btst	#3,a6@(14)
	bnes	_expbody
_cret:	moveq	#0,d0
	rts

_expunge:
	tstw	a6@(32)
	bnes	_defer
_expbody:
	moveml	d2/a5-a6,sp@-
	moveal	a6,a5
	movel	a5@(38),d2
	moveal	a5,a1
	moveal	a1@+,a0
	moveal	a1@,a1
	movel	a0,a1@
	movel	a1,a0@(4)
	moveal	a5@(34),a6
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(16),d0
	subal	d0,a1
	addw	a5@(18),d0
	jsr	a6@(-210)
	movel	d2,d0
	moveml	sp@+,d2/a5-a6
	rts
_defer:
	bset	#3,a6@(14)
	moveq	#0,d0
	rts

_stub:	moveq	#0,d0
	rts

_endskip:
	.byte	0,0
