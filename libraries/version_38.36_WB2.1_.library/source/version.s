/*
 * version.library 38.36 (WB2.1) -- byte-exact reconstruction.
 * Two hunks: CODE hunk (0x41 longs) + an EMPTY second CODE hunk record.
 * AUTOINIT RomTag, absolute (long) function table, InitStruct datatab.
 *
 * Vectors: -6 Open, -12 Close (deferred expunge via flag bit at lib+42),
 * -18 Expunge, -24 null stub.  initfn stores execbase/seglist @+34/+38.
 * InitStruct datatab sets ln_Type=9, ln_Name, ln_Flags=6,
 * lib_Version=38, lib_Revision=36, idstr.
 */
	.text
	.globl	_dosstub
	.globl	_romtag
	.globl	_endskip
	.globl	_inittab

_dosstub:
	moveq	#0,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x26,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"version.library"
	.byte	0
_idstr:	.ascii	"version 38.36 (4.12.92)"
	.byte	0x0d,0x0a,0x00

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

_dtab:	.short	0xa008
	.byte	9,0
	.short	0x800a
	.long	_name
	.short	0xa00e
	.byte	6,0
	.short	0x9014
	.short	38
	.short	0x9016
	.short	36
	.short	0x8018
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
