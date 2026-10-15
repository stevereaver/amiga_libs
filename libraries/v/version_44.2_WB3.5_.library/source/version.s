/*
 * version.library 44.2 (WB3.5) -- byte-exact reconstruction.
 * Single CODE hunk, AUTOINIT RomTag, word-offset function table.
 * initfn additionally stores: lib-self pointer @+42, build-date constant
 * 0x11081999 @+46, and a hook pointer @+50.  The hook XOR-decodes a
 * 10-byte resident name with a caller key, FindResident()s it, and
 * re-encrypts it in place.
 * Quirk: Open does not clear DELEXP; Close expunges unconditionally
 * when opencnt reaches zero (no deferred-expunge test).
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
	.byte	0x80,0x2c,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"version.library"
	.byte	0
_idstr:	.ascii	"version 44.2 (11.8.99)"
	.byte	0x0d,0x0a,0x00
	.byte	0

_inittab:
	.long	0x36
	.long	_functab
	.long	0
	.long	_initfn

_functab:
	.short	0xffff
	.short	_open-_functab
	.short	_close-_functab
	.short	_stub-_functab
	.short	_stub-_functab
	.short	0xffff

_initfn:
	exg	d0,a5
	movel	a6,a5@(34)
	movel	a0,a5@(38)
	movew	#2,a5@(22)
	movel	a5,a5@(42)
	movel	#0x11081999,a5@(46)
	lea	%pc@(_hook),a0
	movel	a0,a5@(50)
	exg	d0,a5
	rts

_open:
	addqw	#1,a6@(32)
	movel	a6,d0
	rts

_close:
	subqw	#1,a6@(32)
	bnes	_cret
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
_cret:	rts

_stub:	moveq	#0,d0
	rts

_hook:
	moveml	d2/a2/a6,sp@-
	moveal	0x4,a6
	movel	d0,d2
	lea	%pc@(_xname),a2
	moveal	a2,a0
	moveq	#9,d1
_xloop:	eorb	d2,a0@+
	dbf	d1,_xloop
	moveal	a2,a1
	jsr	a6@(-594)
	moveal	a2,a0
	moveq	#9,d1
_xloop2:
	eorb	d2,a0@+
	dbf	d1,_xloop2
	moveml	sp@+,d2/a2/a6
	rts

_xname:	.short	0x42c9,0xa0b9,0x9b8c,0x8f9a,0xc952
	.byte	0
_endskip:
	.byte	0
