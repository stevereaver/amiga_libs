/*
 * _asl.library 40.6 -- byte-exact reconstruction.
 * Single CODE hunk (0x59 longs).  AUTOINIT RomTag, word-offset
 * functab (0xffff-marked), InitStruct datatab.
 *
 * Relay library: vectors -30..-60 are six stubs that load the LVO
 * number into d1 and branch to a common tail which calls the real
 * asl.library through the pointer at lib+0x22 (NOTE: that field is
 * never initialized by the shipped binary -- latent defect),
 * invokes the LVO on the real base, then exec.CloseLibrary()s it.
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
	.byte	0x80,0x28,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"_asl.library"
	.byte	0
_idstr:	.ascii	"$VER: _asl.library 40.6"
	.byte	0,0

_inittab:
	.long	0x2e
	.long	_functab
	.long	_dtab
	.long	_initfn

_functab:
	.short	0xffff
	.short	0x50,0x60,0x76,0xb4,0xb8,0xbc,0xc0,0xc4,0xc8,0xcc
	.short	0xffff,0xffff

_dtab:
	.short	0xa00c
	.byte	9,0				/* (dead store: byte@0xc) */
	.short	0x800a
	.long	_name				/* ln_Name */
	.short	0xa00e
	.byte	6,0				/* ln_Flags */
	.short	0x9014
	.short	40				/* lib_Version */
	.short	0x9016
	.short	6				/* lib_Revision */
	.short	0x8018
	.long	_idstr				/* lib_IdString */
	.short	0x8026
	.long	_name+1				/* lib+0x26 -> "asl.library" */
	.short	0,0

_initfn:
	moveml	a5,sp@-
	moveal	d0,a5
	movel	a0,a5@(0x2a)			/* seglist */
	moveml	sp@+,a5
	rts

_open:
	addiw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	rts

_close:
	moveq	#0,d0
	subiw	#1,a6@(32)
	bnes	_cret
	btst	#3,a6@(14)
	beqs	_cret
	bsrb	_expunge
_cret:	rts

_expunge:
	moveml	d2/a5-a6,sp@-
	tstw	a6@(32)
	beqb	_unlink
	bset	#3,a6@(14)
	moveq	#0,d0
	brab	_edone
_unlink:
	moveal	a6,a5
	moveal	(4).w,a6			/* exec base */
	moveal	a5,a1
	jsr	a6@(-252)			/* Remove */
	moveal	a5,a1
	moveq	#0,d0
	movel	a5@(0x2a),d2			/* seglist */
	movew	a5@(16),d0
	subal	d0,a1
	addw	a5@(18),d0
	jsr	a6@(-210)			/* FreeMem */
	movel	d2,d0
_edone:	moveml	sp@+,d2/a5-a6
	rts

_stub:	moveq	#0,d0
	rts

/* relay stubs: LVO -30..-60 -> d1, tail forwards to real asl.library */
	moveq	#-30,d1
	brab	_relay
	moveq	#-36,d1
	brab	_relay
	moveq	#-42,d1
	brab	_relay
	moveq	#-48,d1
	brab	_relay
	moveq	#-54,d1
	brab	_relay
	moveq	#-60,d1
_relay:
	movel	a6,sp@-
	moveml	d0-d1/a0-a1,sp@-
	moveal	a6@(0x26),a1			/* "asl.library" */
	moveq	#0x24,d0			/* version 36 */
	moveal	a6@(0x22),a0			/* (uninitialized) opener fn */
	moveal	(4).w,a6
	jsr	(a0)
	tstl	d0
	beqb	_rfail
	moveal	d0,a6				/* real asl base */
	moveml	sp@+,d0-d1/a0-a1
	.short	0x4eb6,0x1000			/* jsr (a6,d1.w) -- call real LVO */
_rclose:
	moveml	d0-d1/a0-a1,sp@-
	moveal	a6,a1
	moveal	(4).w,a6
	jsr	a6@(-0x19e)			/* CloseLibrary */
	moveml	sp@+,d0-d1/a0-a1
	moveal	sp@+,a6
	rts
_rfail:
	moveml	sp@+,d0-d1/a0-a1
	moveq	#0,d0
	brab	_rclose

_endskip:
