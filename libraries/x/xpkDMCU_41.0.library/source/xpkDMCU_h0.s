	.extern	_gd
	.globl	_initfn,_open,_close,_expunge,_extfunc,_v30,_v36,_v42,_v48,_v54,_v60
	.globl	_pkname,_pkdesc,_pkdesc2,_scomp,_sdecomp,_scomped,_sdecomped

_dead:
	movel	%a4, %a7@-
	moveq	#-1, %d0
	.short	0x49f9
	.long	_gd+0
	moveal	%a7@+, %a4
	rts	

_initfn:
	moveml	%a2/%a4, %a7@-
	moveal	%d0, %a1
	.short	0x49f9
	.long	_gd+0
	movel	%a1, %a4@(0x3c)
	movel	%a6, %a1@(0x26)
	moveal	%a0, %a2
	moveal	%a4@(0x3c), %a0
	movel	%a2, %a0@(0x22)
	bsrw	_initdeps
	tstl	%d0
	beqb	L3a
	movel	%a4@(0x3c), %d0
	brab	L40
L3a:
	bsrw	_closedeps
	moveq	#0x0, %d0
L40:
	moveml	%a7@+, %a2/%a4
	rts	

_open:
	movel	%a4, %a7@-
	.short	0x49f9
	.long	_gd+0
	addqw	#0x1, %a6@(0x20)
	movel	%a6, %d0
	bclrb	#0x3, %a6@(0xe)
	moveal	%a7@+, %a4
	rts	

_close:
	movel	%a4, %a7@-
	.short	0x49f9
	.long	_gd+0
	subqw	#0x1, %a6@(0x20)
	bneb	L7a
	btstb	#0x3, %a6@(0xe)
	beqb	L7a
	bsrw	_expunge
	.short	0xc40
L7a:
	.short	0x7000
	moveal	%a7@+, %a4
	rts	

_expunge:
	moveml	%a3-%a6, %a7@-
	moveal	%a6, %a5
	tstw	%a5@(0x20)
	.short	0x49f9
	.long	_gd+0
	bneb	Lbe
	moveal	%a5, %a1
	moveal	%a4@(0x78), %a6
	moveal	%a5@(0x22), %a3
	jsr	%a6@(-0xfc)
	bsrw	_closedeps
	moveq	#0x0, %d1
	moveq	#0x0, %d0
	movew	%a5@(0x10), %d1
	moveal	%a5, %a1
	subal	%d1, %a1
	movew	%a5@(0x12), %d0
	addl	%d1, %d0
	jsr	%a6@(-0xd2)
	movel	%a3, %d0
	brab	Lc6
Lbe:
	bsetb	#0x3, %a5@(0xe)
	moveq	#0x0, %d0
Lc6:
	moveml	%a7@+, %a3-%a6
	rts	

_extfunc:
	movel	%a4, %a7@-
	moveq	#0x0, %d0
	.short	0x49f9
	.long	_gd+0
	moveal	%a7@+, %a4
	rts	
	nop	

_initdeps:
	moveml	%a4-%a6, %a7@-
	.short	0x49f9
	.long	_gd+0
	moveal	0x4:w, %a1
	movel	%a1, %a4@(0x78)
	leal	_ppcname(%pc), %a1
	moveal	%a4@(0x78), %a6
	moveq	#0x2d, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a4@(0x7c)
	beqw	L226
	leal	_elfname(%pc), %a0
	moveal	%d0, %a6
	jsr	%a6@(-0x1e)
	movel	%d0, %a4@(0x80)
	beqw	L226
	clrl	%a7@-
	moveal	%a4@(0x7c), %a6
	moveal	%a7, %a0
	jsr	%a6@(-0x10e)
	leal	%a7@(4), %a7
	movel	%d0, %a4@(0x88)
	beqw	L226
	clrl	%a7@-
	moveal	%a4@(0x7c), %a6
	moveal	%a7, %a0
	jsr	%a6@(-0x10e)
	leal	%a7@(4), %a7
	movel	%d0, %a4@(0x8c)
	beqw	L226
	moveal	%d0, %a0
	moveq	#0x4, %d0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x126)
	movel	%d0, %a4@(0x90)
	beqw	L226
	moveal	%a4@(0x7c), %a6
	moveq	#0x4, %d0
	moveq	#0x1, %d1
	jsr	%a6@(-0x3c)
	movel	%d0, %a4@(0x94)
	beqw	L226
	moveal	%d0, %a0
	leal	%a4@(0x8c), %a5
	movel	%a5@+, %a0@
	movel	%a5@+, %d0
	movel	%a5@+, %d1
	clrl	%a7@-
	peal	0x1:w
	movel	#0x80020014, %a7@-
	movel	#0x454e4420, %a7@-
	movel	#0x80020018, %a7@-
	peal	0x4:w
	movel	#0x80020017, %a7@-
	movel	%d1, %a7@-
	movel	#0x80020016, %a7@-
	movel	%d0, %a7@-
	movel	#0x80020015, %a7@-
	moveal	%a4@(0x80), %a0
	moveal	%a4@(0x7c), %a6
	moveal	%a7, %a1
	jsr	%a6@(-0x54)
	leal	%a7@(0x2c), %a7
	moveal	%a4@(0x8c), %a0
	jsr	%a6@(-0x150)
	brab	L1f6
L1c8:
	moveal	%a5, %a0
	moveal	%a4@(0x7c), %a6
	movel	#0x80025002, %d0
	jsr	%a6@(-0x132)
	cmpil	#0x504f5254, %d0
	bneb	L1f0
	moveal	%a5, %a0
	movel	#0x80025000, %d0
	jsr	%a6@(-0x132)
	movel	%d0, %a4@(0x84)
L1f0:
	moveal	%a5, %a0
	jsr	%a6@(-0x144)
L1f6:
	moveal	%a4@(0x8c), %a0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x138)
	moveal	%d0, %a5
	tstl	%d0
	bneb	L1c8
	leal	%a4@(0x3c), %a6
	moveal	%a6@, %a0
	movel	%a4@(0x7c), %a0@(0x2a)
	moveal	%a6@, %a0
	movel	%a4@(0x84), %a0@(0x2e)
	moveal	%a6@+, %a0
	moveq	#0x1, %d0
	movel	%a4@(0x8c), %a0@(0x32)
L226:
	moveml	%a7@+, %a4-%a6
	rts	
_ppcname:	.ascii	"ppc.library"
	.byte	0
_elfname:	.ascii	"LIBS:ppc/xpkDMCU.elf"
	.byte	0
	.byte	0

_closedeps:
	moveml	%a2/%a4-%a6, %a7@-
	.short	0x49f9
	.long	_gd+0
	tstl	%a4@(0x84)
	beqw	L318
	movel	%a4@(0x88), %d0
	beqw	L318
	moveal	%d0, %a0
	moveq	#0x0, %d0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x126)
	moveal	%d0, %a5
	tstl	%d0
	beqw	L318
	subal	%a2, %a2
	moveal	%a4@(0x84), %a0
	moveal	%a5, %a1
	moveq	#0x0, %d0
	movel	#0x46494e49, %d1
	jsr	%a6@(-0x14a)
	moveal	%a4@(0x88), %a0
	jsr	%a6@(-0x150)
	moveal	%a4@(0x88), %a0
	jsr	%a6@(-0x138)
	moveal	%a5, %a0
	jsr	%a6@(-0x12c)
	movel	%a4@(0x94), %d0
	beqb	L2b6
	moveal	%d0, %a1
	jsr	%a6@(-0x42)
	clrl	%a4@(0x94)
L2b6:
	movel	%a4@(0x90), %d0
	beqb	L2c6
	moveal	%d0, %a0
	jsr	%a6@(-0x12c)
	clrl	%a4@(0x90)
L2c6:
	movel	%a4@(0x8c), %d0
	beqb	L2de
	moveal	%d0, %a0
	jsr	%a6@(-0x114)
	clrl	%a4@(0x8c)
	moveal	%a4@(0x3c), %a0
	clrl	%a0@(0x32)
L2de:
	moveal	%a4@(0x88), %a0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x114)
	clrl	%a4@(0x88)
	movel	%a4@(0x80), %d0
	beqb	L2fe
	moveal	%d0, %a0
	jsr	%a6@(-0x24)
	clrl	%a4@(0x80)
L2fe:
	movel	%a6, %d0
	beqb	L318
	moveal	%d0, %a1
	moveal	%a4@(0x78), %a6
	jsr	%a6@(-0x19e)
	clrl	%a4@(0x7c)
	moveal	%a4@(0x3c), %a0
	clrl	%a0@(0x2a)
L318:
	moveml	%a7@+, %a2/%a4-%a6
	rts	
	nop	

_v30:
	movel	%a4, %a7@-
	.short	0x49f9
	.long	_gd+0
	leal	%a4@(0x2f4), %a0
	movel	%a0, %d0
	moveal	%a7@+, %a4
	rts	
_pkname:	.ascii	"DMCU"
	.byte	0,0
_pkdesc:	.ascii	"Dynamic Markov Coding Ultra"
	.byte	0
_pkdesc2:	.ascii	"Arithmetic coding using Markov modelling"
	.byte	0,0
_scomp:	.ascii	"Compressing  "
	.byte	0
_sdecomp:	.ascii	"Decompressing"
	.byte	0
_scomped:	.ascii	"Compressed   "
	.byte	0
_sdecomped:	.ascii	"Decompressed "
	.byte	0

_v36:
	subaw	#0xc, %a7
	moveml	%d6-%d7/%a2-%a6, %a7@-
	moveal	%a0, %a5
	moveq	#0x9, %d0
	addl	%a5@(0x1c), %d0
	.short	0x4c7c
	orib	#0x0, %d0
	.short	0xa
	.short	0x49f9
	.long	_gd+0
	movel	%a6, %a7@(0x24)
	movel	%d0, %d7
	moveq	#0x0, %d0
	cmpl	%d0, %d7
	blsb	L3e2
	subql	#0x1, %d7
L3e2:
	cmpl	%d0, %d7
	bcsb	L3ec
	moveq	#0x9, %d1
	cmpl	%d1, %d7
	blsb	L3f2
L3ec:
	moveq	#-12, %d0
	braw	L586
L3f2:
	tstl	%a5@(0x34)
	bneb	L428
	tstl	%a5@(0x38)
	bneb	L428
	leal	%a4@(0x128), %a0
	.short	0x43f0,0x7c00
	moveal	%a1, %a2
	moveal	%a4@(0x7c), %a6
	moveq	#0x1, %d1
	movel	%a2@, %d0
	jsr	%a6@(-0x3c)
	moveq	#0x1, %d1
	movel	%d0, %a5@(0x34)
	movel	%a2@, %d0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x3c)
	movel	%d0, %a5@(0x38)
L428:
	tstl	%a5@(0x34)
	beqb	L434
	tstl	%a5@(0x38)
	bneb	L442
L434:
	moveal	%a5, %a0
	moveal	%a7@(0x24), %a6
	bsrw	_v42
	braw	L584
L442:
	moveq	#0x1c, %d0
	addl	%a5@(4), %d0
	moveq	#0x1, %d1
	addl	%a5@(0xc), %d0
	moveal	%a4@(0x7c), %a6
	movel	%d0, %d6
	jsr	%a6@(-0x3c)
	movel	%d0, %a7@(0x1c)
	beqw	L584
	moveal	%d0, %a0
	leal	%a0@, %a2
	movel	%d7, %a2@+
	leal	%a0@(0x1c), %a1
	movel	%a1, %a2@+
	leal	%a5@(4), %a3
	movel	%a3@, %d1
	moveal	%d0, %a6
	addal	%d1, %a6
	movel	%a1, %a7@(0x20)
	leal	%a6@(0x1c), %a1
	movel	%a1, %a2@+
	movel	%a3@, %d1
	movel	%d1, %a2@+
	movel	%a5@(0xc), %a2@+
	movel	%a5@(0x34), %a2@+
	movel	%a5@(0x38), %a2@+
	moveal	%a5@, %a0
	moveal	%a7@(0x20), %a1
	movel	%a3@+, %d0
	moveal	%a4@(0x78), %a6
	jsr	%a6@(-0x270)
	clrl	%a7@-
	moveal	%a4@(0x7c), %a6
	moveal	%a7, %a0
	jsr	%a6@(-0x10e)
	leal	%a7@(4), %a7
	moveal	%d0, %a3
	tstl	%d0
	beqb	L4fa
	moveal	%a3, %a0
	movel	%d6, %d0
	jsr	%a6@(-0x126)
	moveal	%d0, %a0
	tstl	%d0
	beqb	L4f4
	movel	%a0, %a7@-
	moveal	%a0, %a1
	moveal	%a7@(0x28), %a0
	moveal	%a0@(0x2e), %a0
	moveal	%a7@(0x20), %a2
	movel	%d6, %d0
	movel	#0x434f4d50, %d1
	jsr	%a6@(-0x14a)
	moveal	%a7@+, %a2
	moveal	%a3, %a0
	jsr	%a6@(-0x150)
	moveal	%a3, %a0
	jsr	%a6@(-0x138)
	moveal	%a2, %a0
	jsr	%a6@(-0x12c)
L4f4:
	moveal	%a3, %a0
	jsr	%a6@(-0x114)
L4fa:
	moveal	%a7@(0x24), %a2
	moveal	%a2@(0x32), %a0
	jsr	%a6@(-0x150)
	brab	L53a
L508:
	moveal	%a3, %a0
	moveal	%a4@(0x7c), %a6
	movel	#0x80025002, %d0
	jsr	%a6@(-0x132)
	cmpil	#0x4c454e47, %d0
	bneb	L530
	moveal	%a3, %a0
	movel	#0x80025000, %d0
	jsr	%a6@(-0x132)
	movel	%d0, %a5@(0x10)
L530:
	moveal	%a3, %a0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x144)
L53a:
	moveal	%a2@(0x32), %a0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x138)
	moveal	%d0, %a3
	tstl	%d0
	bneb	L508
	movel	%a5@(0x10), %d0
	moveq	#0x0, %d1
	cmpl	%d1, %d0
	moveal	%a7@(0x1c), %a2
	blsb	L56a
	moveal	%a2@(8), %a0
	moveal	%a5@(8), %a1
	moveal	%a4@(0x78), %a6
	jsr	%a6@(-0x270)
L56a:
	moveal	%a2, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	moveq	#-1, %d0
	cmpl	%a5@(0x10), %d0
	bneb	L580
	moveq	#-17, %d0
	brab	L586
L580:
	moveq	#0x0, %d0
	.short	0xc40
L584:
	.short	0x70f9
L586:
	moveml	%a7@+, %d6-%d7/%a2-%a6
	addaw	#0xc, %a7
	rts	

_v42:
	moveml	%a4-%a6, %a7@-
	moveal	%a0, %a5
	movel	%a5@(0x38), %d0
	.short	0x49f9
	.long	_gd+0
	beqb	L5b0
	moveal	%d0, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	clrl	%a5@(0x38)
L5b0:
	movel	%a5@(0x34), %d0
	beqb	L5c4
	moveal	%d0, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	clrl	%a5@(0x34)
L5c4:
	moveml	%a7@+, %a4-%a6
	rts	

_v48:
	movel	%a4, %a7@-
	moveq	#0x0, %d0
	.short	0x49f9
	.long	_gd+0
	moveal	%a7@+, %a4
	rts	

_v54:
	subqw	#0x8, %a7
	moveml	%d5-%d7/%a2-%a6, %a7@-
	moveal	%a0, %a5
	moveal	%a5@, %a0
	moveq	#0x0, %d6
	moveq	#0x0, %d7
	moveq	#0x0, %d0
	moveb	%a0@, %d6
	.short	0x49f9
	.long	_gd+0
	movel	%a6, %a7@(0x24)
	cmpl	%d0, %d6
	bcsb	L5fe
	moveq	#0x9, %d1
	cmpl	%d1, %d6
	blsb	L604
L5fe:
	moveq	#-12, %d0
	braw	L794
L604:
	tstl	%a5@(0x34)
	bneb	L63a
	tstl	%a5@(0x38)
	bneb	L63a
	leal	%a4@(0x128), %a0
	.short	0x43f0,0x6c00
	moveal	%a1, %a2
	moveal	%a4@(0x7c), %a6
	moveq	#0x1, %d1
	movel	%a2@, %d0
	jsr	%a6@(-0x3c)
	moveq	#0x1, %d1
	movel	%d0, %a5@(0x34)
	movel	%a2@, %d0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x3c)
	movel	%d0, %a5@(0x38)
L63a:
	tstl	%a5@(0x34)
	beqb	L646
	tstl	%a5@(0x38)
	bneb	L654
L646:
	moveal	%a5, %a0
	moveal	%a7@(0x24), %a6
	bsrw	_v60
	braw	L792
L654:
	moveq	#0x1c, %d0
	addl	%a5@(4), %d0
	moveq	#0x1, %d1
	addl	%a5@(0xc), %d0
	moveal	%a4@(0x7c), %a6
	movel	%d0, %d5
	jsr	%a6@(-0x3c)
	moveal	%d0, %a2
	movel	%d0, %a7@(0x20)
	beqw	L792
	leal	%a2@, %a3
	movel	%d6, %a3@+
	leal	%a2@(0x1c), %a0
	movel	%a0, %a3@+
	movel	%a5@(4), %d1
	moveal	%a2, %a1
	addal	%d1, %a1
	leal	%a1@(0x1c), %a6
	subql	#0x1, %d1
	movel	%a6, %a3@+
	movel	%d1, %a3@+
	movel	%a5@(0xc), %a3@+
	moveal	%a0, %a1
	movel	%a5@(0x34), %a3@+
	movel	%a5@(0x38), %a3@+
	moveal	%a5@, %a0
	movel	%a5@(4), %d0
	moveal	%a4@(0x78), %a6
	jsr	%a6@(-0x270)
	addql	#0x1, %a2@(4)
	clrl	%a7@-
	moveal	%a4@(0x7c), %a6
	moveal	%a7, %a0
	jsr	%a6@(-0x10e)
	leal	%a7@(4), %a7
	moveal	%d0, %a3
	tstl	%d0
	beqb	L70a
	moveal	%a3, %a0
	movel	%d5, %d0
	jsr	%a6@(-0x126)
	moveal	%d0, %a0
	tstl	%d0
	beqb	L704
	movel	%a0, %a7@-
	moveal	%a0, %a1
	moveal	%a7@(0x28), %a0
	moveal	%a0@(0x2e), %a0
	moveal	%a7@(0x24), %a2
	movel	%d5, %d0
	movel	#0x4445434f, %d1
	jsr	%a6@(-0x14a)
	moveal	%a7@+, %a2
	moveal	%a3, %a0
	jsr	%a6@(-0x150)
	moveal	%a3, %a0
	jsr	%a6@(-0x138)
	moveal	%a2, %a0
	jsr	%a6@(-0x12c)
L704:
	moveal	%a3, %a0
	jsr	%a6@(-0x114)
L70a:
	moveal	%a7@(0x24), %a2
	moveal	%a2@(0x32), %a0
	jsr	%a6@(-0x150)
	brab	L744
L718:
	moveal	%a3, %a0
	moveal	%a4@(0x7c), %a6
	movel	#0x80025002, %d0
	jsr	%a6@(-0x132)
	cmpil	#0x4c454e47, %d0
	bneb	L73e
	moveal	%a3, %a0
	movel	#0x80025000, %d0
	jsr	%a6@(-0x132)
	movel	%d0, %d7
L73e:
	moveal	%a3, %a0
	jsr	%a6@(-0x144)
L744:
	moveal	%a2@(0x32), %a0
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x138)
	moveal	%d0, %a3
	tstl	%d0
	bneb	L718
	moveal	%a7@(0x20), %a2
	tstl	%d7
	bleb	L770
	moveal	%a2@(8), %a0
	moveal	%a5@(8), %a1
	movel	%d7, %d0
	moveal	%a4@(0x78), %a6
	jsr	%a6@(-0x270)
L770:
	moveal	%a2, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	moveq	#-1, %d0
	cmpl	%d0, %d7
	bneb	L784
	moveq	#-17, %d0
	brab	L794
L784:
	cmpl	%a5@(0xc), %d7
	beqb	L78e
	moveq	#-4, %d0
	brab	L794
L78e:
	moveq	#0x0, %d0
	.short	0xc40
L792:
	.short	0x70f9
L794:
	moveml	%a7@+, %d5-%d7/%a2-%a6
	addqw	#0x8, %a7
	rts	

_v60:
	moveml	%a4-%a6, %a7@-
	moveal	%a0, %a5
	movel	%a5@(0x38), %d0
	.short	0x49f9
	.long	_gd+0
	beqb	L7bc
	moveal	%d0, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	clrl	%a5@(0x38)
L7bc:
	movel	%a5@(0x34), %d0
	beqb	L7d0
	moveal	%d0, %a1
	moveal	%a4@(0x7c), %a6
	jsr	%a6@(-0x42)
	clrl	%a5@(0x34)
L7d0:
	moveq	#0x0, %d0
	moveml	%a7@+, %a4-%a6
	rts	
