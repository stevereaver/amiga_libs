/*
 * mhimpegit.library 1.1 -- byte-exact reconstruction, hunk0 (2728 B).
 * MHI MPEG.it module library (Oliver Gantert / Thomas Wenzel, 2020).
 * SAS/C; globals live in the 16-byte data hunk (_gd+0 exec, _gd+4
 * intuition, _gd+8 dos, _gd+0xc prelude).
 *
 *   -6   initfn    @0x134  dep-open helper @0x04 (dos+intuition)
 *   -12  _open     @0x16c  -18 _close @0x184  -24 _expunge @0x1ac
 *   -30..-84       _v4.._v14 (module lifecycle/dispatch)
 */
	.text
	.globl	_gd
	moveq	#-1, %d0
	rts	
L4:
	moveml	%d7/%a6, %a7@-
	.short	0x2c79

	.long	_gd+0
	leal	_dosnam(%pc), %a1
	moveq	#0x25, %d0
	jsr	%a6@(-0x228)
	.short	0x23c0

	.long	_gd+8
	beqb	L64
	.short	0x2c79

	.long	_gd+0
	leal	_intuinam(%pc), %a1
	moveq	#0x25, %d0
	jsr	%a6@(-0x228)
	.short	0x23c0

	.long	_gd+4
	beqb	L3c
	moveq	#0x0, %d0
	brab	L76
L3c:
	.short	0x2c79

	.long	_gd+0
	movel	#0x35038004, %d7
	jsr	%a6@(-0x6c)
	.short	0x2279

	.long	_gd+8
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x19e)
	.short	0x42b9

	.long	_gd+8
	brab	L74
L64:
	.short	0x2c79

	.long	_gd+0
	movel	#0x35038007, %d7
	jsr	%a6@(-0x6c)
L74:
	moveq	#0x1, %d0
L76:
	moveml	%a7@+, %d7/%a6
	rts	
_intuinam:	.ascii	"intuition.library"
	.byte	0
	.short	0x4e71
_dosnam:	.ascii	"dos.library"
	.byte	0
L9c:
	movel	%a6, %a7@-
	.short	0x4ab9

	.long	_gd+12
	beqb	Lbc
	.short	0x2279

	.long	_gd+12
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x19e)
	.short	0x42b9

	.long	_gd+12
Lbc:
	.short	0x4ab9

	.long	_gd+4
	beqb	Lda
	.short	0x2279

	.long	_gd+4
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x19e)
	.short	0x42b9

	.long	_gd+4
Lda:
	.short	0x4ab9

	.long	_gd+8
	beqb	Lf8
	.short	0x2279

	.long	_gd+8
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x19e)
	.short	0x42b9

	.long	_gd+8
Lf8:
	moveal	%a7@+, %a6
	rts	
Lfc:
	moveml	%d2/%a2-%a3/%a6, %a7@-
	moveal	%a7@(0x14), %a3
	leal	%a3@(0x10), %a2
	moveq	#0x0, %d0
	movew	%a2@, %d0
	moveq	#0x0, %d1
	movew	%a3@(0x12), %d1
	movel	%d1, %d2
	addl	%d0, %d2
	beqb	L12c
	moveq	#0x0, %d0
	movew	%a2@, %d0
	moveal	%a3, %a1
	subal	%d0, %a1
	.short	0x2c79

	.long	_gd+0
	movel	%d2, %d0
	jsr	%a6@(-0xd2)
L12c:
	moveml	%a7@+, %d2/%a2-%a3/%a6
	rts	
	nop	

_initfn:
	moveml	%a2/%a6, %a7@-
	movel	%a0, %d1
	moveal	%a6, %a1
	moveal	%d0, %a2
	movel	%d1, %a2@(0x24)
	movel	%a1, %a2@(0x28)
	.short	0x23c9

	.long	_gd+0
	movel	%a2, %a7@-
	bsrw	L4
	addqw	#0x4, %a7
	tstl	%d0
	bneb	L15c
	movel	%a2, %d0
	brab	L164
L15c:
	movel	%a2, %a7@-
	bsrb	Lfc
	moveq	#0x0, %d0
	addqw	#0x4, %a7
L164:
	moveml	%a7@+, %a2/%a6
	rts	
	nop	

_open:
	movel	%a6, %a7@-
	moveal	%a6, %a1
	leal	%a1@(0x20), %a0
	addqw	#0x1, %a0@
	leal	%a1@(0xe), %a0
	andib	#0xf7, %a0@
	movel	%a1, %d0
	moveal	%a7@+, %a6
	rts	

_close:
	movel	%a6, %a7@-
	moveal	%a6, %a1
	leal	%a1@(0x20), %a0
	tstw	%a0@
	beqb	L192
	subqw	#0x1, %a0@
L192:
	tstw	%a0@
	bneb	L1a6
	moveb	%a1@(0xe), %d0
	.short	0xc03c,0x0008
	beqb	L1a6
	moveal	%a1, %a6
	bsrb	_expunge
	brab	L1a8
L1a6:
	moveq	#0x0, %d0
L1a8:
	moveal	%a7@+, %a6
	rts	

_expunge:
	moveml	%a2-%a3/%a6, %a7@-
	moveal	%a6, %a3
	tstw	%a3@(0x20)
	bneb	L1e2
	.short	0x23eb,0x28

	.long	_gd+0
	movel	%a3, %a7@-
	bsrw	L9c
	.short	0x2c79

	.long	_gd+0
	moveal	%a3, %a1
	jsr	%a6@(-0xfc)
	moveal	%a3@(0x24), %a2
	movel	%a3, %a7@-
	bsrw	Lfc
	movel	%a2, %d0
	addqw	#0x8, %a7
	brab	L1ec
L1e2:
	leal	%a3@(0xe), %a0
	orib	#0x8, %a0@
	moveq	#0x0, %d0
L1ec:
	moveml	%a7@+, %a2-%a3/%a6
	rts	
	nop	

_v4:
	moveq	#0x0, %d0
	rts	

_errf:
	leal	%a7@(-0x14), %a7
	moveml	%a2/%a6, %a7@-
	moveq	#0x14, %d0
	movel	%d0, %a7@(8)
	clrl	%a7@(0xc)
	.short	0x2f7c

	.long	_name
	.short	0x10
	clrl	%a7@(0x14)
	.short	0x2f7c

	.long	_abortmsg
	.short	0x18
	movel	%a7@(0x20), %a7@(0x14)
	leal	%a7@(8), %a1
	.short	0x2c79

	.long	_gd+4
	subal	%a0, %a0
	subal	%a2, %a2
	movel	%a3, %a7@-
	leal	%a7@(4), %a3
	jsr	%a6@(-0x24c)
	moveal	%a7@+, %a3
	moveml	%a7@+, %a2/%a6
	leal	%a7@(0x14), %a7
	rts	
_abortmsg:	.ascii	"Abort :/"
	.byte	0,0
	.short	0x4e71
	.byte	0
_verstr:	.ascii	"$VER: "
_idstr:	.ascii	"mhimpegit.library 1.1 (20.10.2020)\015\012"
	.byte	0
_copystr:	.ascii	"\251 2020 Oliver Gantert, 2017-2019 Thomas Wenzel"
	.byte	0,0
_name:	.ascii	"mhimpegit.library"
	.byte	0
	.short	0x4e71
_romtag:	.short	0x4afc

	.long	_romtag	/* matchtag */

	.long	_endskip	/* -> 0x2de */
	.byte	0x80,0x01,0x09,0x00

	.long	_name

	.long	_idstr

	.long	_inittab
_endskip:	.short	0x4e71
_functab:

	.long	_open

	.long	_close

	.long	_expunge

	.long	_v4

	.long	_v5

	.long	_v6

	.long	_v7

	.long	_v8

	.long	_v9

	.long	_v10

	.long	_v11

	.long	_v12

	.long	_v13

	.long	_v14

	.long	0xffffffff
_datatab:	.short	0xe000,0x0008,0x0900,0x800a

	.long	_name
	.short	0xe000,0x000e,0x0600,0xd000,0x0014,0x0001
	.short	0xd000,0x0016,0x0001,0x8018

	.long	_idstr

	.long	0
_inittab:
	.long	0x2c

	.long	_functab

	.long	_datatab

	.long	_initfn

_v5:
	leal	%a7@(-0x20), %a7
	moveml	%d2-%d4/%a2-%a6, %a7@-
	moveal	%a0, %a5
	movel	%d0, %d3
	movel	#0x80000032, %a7@(0x20)
	clrl	%a7@(0x24)
	movel	#0x80000033, %a7@(0x28)
	clrl	%a7@(0x2c)
	movel	#0x8000003f, %a7@(0x30)
	clrl	%a7@(0x34)
	clrl	%a7@(0x38)
	clrl	%a7@(0x3c)
	.short	0x2c79

	.long	_gd+0
	leal	_preludename(%pc), %a1
	moveq	#0x5, %d0
	jsr	%a6@(-0x228)
	.short	0x23c0

	.long	_gd+12
	beqw	L486
	.short	0x2679

	.long	_gd+12
	cmpiw	#0x5, %a3@(0x14)
	bhib	L3be
	cmpiw	#0x6, %a3@(0x16)
	bcsw	L478
L3be:
	moveal	%a3@(0x38), %a0
	moveb	%a0@(0x15), %d0
	.short	0xc03c,0x0001
	beqw	L46a
	.short	0x2c79

	.long	_gd+0
	moveq	#0x10, %d0
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	moveal	%d0, %a2
	tstl	%d0
	beqb	L45c
	movel	%a5, %a2@
	leal	%a2@(4), %a4
	movel	%d3, %a4@
	.short	0x2c79

	.long	_gd+0
	moveq	#0xc, %d0
	movel	#0x10001, %d1
	jsr	%a6@(-0x2ac)
	movel	%d0, %d2
	movel	%d2, %a2@(0xc)
	tstl	%d2
	beqb	L442
	movel	%d2, %a7@-
	.short	0x4eb9

	.long	_helpb
	movel	%a2@, %a7@(0x28)
	movel	%a4@, %a7@(0x30)
	moveq	#0x63, %d4
	movel	%d4, %a7@(0x38)
	leal	%a7@(0x24), %a0
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x5a)
	.short	0x2079

	.long	_gd+12
	moveal	%a0@(0x8e), %a0
	clrl	%a0@(0x10)
	movel	%a2, %d0
	addqw	#0x4, %a7
	brab	L494
L442:
	peal	_outofmem(%pc)
	.short	0x4eb9

	.long	_errf
	.short	0x2c79

	.long	_gd+0
	moveal	%a2, %a1
	jsr	%a6@(-0x2b2)
	addqw	#0x4, %a7
	brab	L492
L45c:
	peal	_outofmem(%pc)
	.short	0x4eb9

	.long	_errf
	addqw	#0x4, %a7
	brab	L492
L46a:
	peal	_nomodule(%pc)
	.short	0x4eb9

	.long	_errf
	addqw	#0x4, %a7
	brab	L492
L478:
	peal	_needprelude(%pc)
	.short	0x4eb9

	.long	_errf
	addqw	#0x4, %a7
	brab	L492
L486:
	peal	_needprelude(%pc)
	.short	0x4eb9

	.long	_errf
	addqw	#0x4, %a7
L492:
	moveq	#0x0, %d0
L494:
	moveml	%a7@+, %d2-%d4/%a2-%a6
	leal	%a7@(0x20), %a7
	rts	
	nop	
_preludename:	.ascii	"prelude.library"
	.byte	0

_v6:
	moveml	%a2-%a3/%a6, %a7@-
	movel	%a3, %d1
	beqb	L512
	.short	0x4ab9

	.long	_gd+12
	beqb	L4d6
	.short	0x2279

	.long	_gd+12
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x19e)
	.short	0x42b9

	.long	_gd+12
L4d6:
	leal	%a3@(0xc), %a2
	moveal	%a2@, %a0
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x102)
	tstl	%d0
	beqb	L506
L4ea:
	.short	0x2c79

	.long	_gd+0
	moveal	%d0, %a1
	jsr	%a6@(-0x2b2)
	moveal	%a2@, %a0
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x102)
	tstl	%d0
	bneb	L4ea
L506:
	.short	0x2c79

	.long	_gd+0
	moveal	%a3, %a1
	jsr	%a6@(-0x2b2)
L512:
	moveml	%a7@+, %a2-%a3/%a6
	rts	

_v7:
	moveml	%d2-%d5/%a2-%a6, %a7@-
	movel	%a0, %d3
	moveal	%a3, %a4
	movel	%d0, %d4
	.short	0x4ab9

	.long	_gd+12
	beqb	L5a4
	movel	%a4, %d5
	beqb	L5a4
	.short	0x2c79

	.long	_gd+0
	moveq	#0x12, %d0
	movel	#0x10001, %d1
	jsr	%a6@(-0x2ac)
	moveal	%d0, %a2
	tstl	%d0
	beqb	L598
	movel	%d3, %a2@(8)
	movel	%d4, %a2@(0xc)
	leal	%a2@(0x10), %a3
	clrw	%a3@
	moveal	%a4@(0xc), %a0
	.short	0x2c79

	.long	_gd+0
	moveal	%a2, %a1
	jsr	%a6@(-0xf6)
	leal	%a4@(8), %a0
	addql	#0x1, %a0@
	.short	0x2a79

	.long	_gd+12
	moveal	%a5@(0x8e), %a0
	tstl	%a0@(0x10)
	beqb	L594
	movew	#0x1, %a3@
	moveal	%a5, %a6
	moveal	%d3, %a0
	movel	%d4, %d0
	movel	#0x1008, %d1
	movel	#0x5622, %d2
	jsr	%a6@(-0x3c)
L594:
	moveq	#0x1, %d0
	brab	L5a6
L598:
	peal	_outofmem(%pc)
	.short	0x4eb9

	.long	_errf
	addqw	#0x4, %a7
L5a4:
	moveq	#0x0, %d0
L5a6:
	moveml	%a7@+, %d2-%d5/%a2-%a6
	rts	

_v8:
	moveml	%a2-%a4/%a6, %a7@-
	subal	%a4, %a4
	.short	0x4ab9

	.long	_gd+12
	beqb	L5fe
	movel	%a3, %d1
	beqb	L5fe
	.short	0x2079

	.long	_gd+12
	moveal	%a0@(0x8e), %a0
	moveal	%a0@(0x10), %a0
	leal	%a3@(8), %a2
	cmpal	%a2@, %a0
	bccb	L5fe
	moveal	%a3@(0xc), %a0
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x102)
	tstl	%d0
	beqb	L5f8
	moveal	%d0, %a0
	moveal	%a0@(8), %a4
	.short	0x2c79

	.long	_gd+0
	moveal	%d0, %a1
	jsr	%a6@(-0x2b2)
L5f8:
	tstl	%a2@
	beqb	L5fe
	subql	#0x1, %a2@
L5fe:
	movel	%a4, %d0
	moveml	%a7@+, %a2-%a4/%a6
	rts	
	nop	

_v9:
	movel	%a3, %a7@-
	movel	%a3, %d0
	.short	0x4ab9

	.long	_gd+12
	beqb	L62c
	tstl	%d0
	beqb	L62c
	.short	0x2079

	.long	_gd+12
	moveal	%a0@(0x8e), %a0
	tstl	%a0@(0x10)
	beqb	L62c
	moveq	#0x0, %d0
	brab	L62e
L62c:
	moveq	#0x1, %d0
L62e:
	moveal	%a7@+, %a3
	rts	
	nop	

_v10:
	moveml	%d2-%d3/%a2-%a3/%a6, %a7@-
	moveal	%a3, %a1
	.short	0x4ab9

	.long	_gd+12
	beqb	L680
	movel	%a1, %d3
	beqb	L680
	moveal	%a1@(0xc), %a0
	moveal	%a0@, %a2
	tstl	%a2@
	beqb	L680
L650:
	leal	%a2@(0x10), %a3
	tstw	%a3@
	bneb	L67a
	movel	%a2@(0xc), %d0
	moveal	%a2@(8), %a0
	.short	0x2c79

	.long	_gd+12
	movel	#0x1008, %d1
	movel	#0x5622, %d2
	jsr	%a6@(-0x3c)
	movew	#0x1, %a3@
L67a:
	moveal	%a2@, %a2
	tstl	%a2@
	bneb	L650
L680:
	moveml	%a7@+, %d2-%d3/%a2-%a3/%a6
	rts	
	nop	

_v11:
	moveml	%d2-%d3/%a2-%a3/%a6, %a7@-
	.short	0x4ab9

	.long	_gd+12
	beqb	L700
	movel	%a3, %d3
	beqb	L700
	.short	0x2c79

	.long	_gd+12
	movel	#0x80, %d0
	jsr	%a6@(-0x54)
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x24)
	.short	0x2c79

	.long	_gd+8
	moveq	#0x23, %d1
	jsr	%a6@(-0xc6)
	leal	%a3@(0xc), %a2
	moveal	%a2@, %a0
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x102)
	movel	%d0, %d2
	beqb	L6ee
L6d2:
	.short	0x2c79

	.long	_gd+0
	moveal	%d2, %a1
	jsr	%a6@(-0x2b2)
	moveal	%a2@, %a0
	.short	0x2c79

	.long	_gd+0
	jsr	%a6@(-0x102)
	movel	%d0, %d2
	bneb	L6d2
L6ee:
	.short	0x2079

	.long	_gd+12
	moveal	%a0@(0x8e), %a0
	clrl	%a0@(0x10)
	clrl	%a3@(8)
L700:
	moveml	%a7@+, %d2-%d3/%a2-%a3/%a6
	rts	
	nop	

_v12:
	rts	
	nop	

_v13:
	moveml	%d2-%d3, %a7@-
	moveq	#0x0, %d2
	movel	%d1, %d0
	subql	#0x1, %d0
	moveq	#0x2, %d3
	cmpl	%d0, %d3
	bccb	L792
	movel	%d1, %d0
	.short	0x90bc
	.long	0xa
	moveq	#0x2, %d3
	cmpl	%d0, %d3
	bccb	L792
	movel	%d1, %d0
	.short	0x90bc
	.long	0x14
	moveq	#0x1, %d3
	cmpl	%d0, %d3
	bccb	L792
	movel	%d1, %d0
	.short	0x90bc
	.long	0x1e
	moveq	#0x1, %d3
	cmpl	%d0, %d3
	bccb	L792
	movel	%d1, %d0
	.short	0x90bc
	.long	0x28
	moveq	#0x1, %d3
	cmpl	%d0, %d3
	bccb	L792
	.short	0xb2bc
	.long	0x3e8
	beqb	L776
	.short	0xb2bc
	.long	0x3e9
	beqb	L77e
	.short	0xb2bc
	.long	0x3ea
	beqb	L786
	.short	0xb2bc
	.long	0x3f2
	beqb	L78e
	brab	L794
L776:
	.short	0x243c

	.long	_mpegname
	brab	L794
L77e:
	.short	0x243c

	.long	_idstr
	brab	L794
L786:
	.short	0x243c

	.long	_authstr
	brab	L794
L78e:
	moveq	#0x1, %d2
	brab	L794
L792:
	moveq	#0x1, %d2
L794:
	movel	%d2, %d0
	moveml	%a7@+, %d2-%d3
	rts	
_mpegname:	.ascii	"MPEGit"
	.byte	0,0
_authstr:	.ascii	"Thomas Wenzel, Oliver Gantert"
	.byte	0
	.short	0x4e71

_v14:
	leal	%a7@(-0x10), %a7
	moveml	%d2-%d5/%a3/%a6, %a7@-
	moveal	%a3, %a1
	movew	%d0, %d2
	movel	#0x8000003f, %a7@(0x18)
	clrl	%a7@(0x1c)
	clrl	%a7@(0x20)
	clrl	%a7@(0x24)
	.short	0x4ab9

	.long	_gd+12
	beqw	L93c
	movel	%a1, %d3
	beqw	L93c
	tstw	%d2
	beqb	L814
	movew	%d2, %d0
	subqw	#0x1, %d0
	beqw	L93c
	subqw	#0x2, %d0
	beqw	L892
	subqw	#0x2, %d0
	beqw	L8e8
	subqw	#0x1, %d0
	beqb	L83a
	braw	L93c
L814:
	moveq	#0x64, %d3
	cmpl	%d1, %d3
	bccb	L81c
	moveq	#0x64, %d1
L81c:
	movel	#0x8000003f, %a7@(0x18)
	movel	%d1, %a7@(0x1c)
	leal	%a7@(0x18), %a0
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x5a)
	braw	L93c
L83a:
	moveq	#0x64, %d3
	cmpl	%d1, %d3
	bccb	L842
	moveq	#0x64, %d1
L842:
	moveq	#0xf, %d3
	movel	%d1, %d4
	movel	%d3, %d5
	swap	%d4
	swap	%d5
	muluw	%d3, %d4
	muluw	%d1, %d5
	muluw	%d3, %d1
	addw	%d5, %d4
	swap	%d4
	clrw	%d4
	addl	%d4, %d1
	movel	%d0, %a7@-
	movel	%a1, %a7@-
	peal	0x32:w
	movel	%d1, %a7@-
	.short	0x4eb9

	.long	_helpa
	addqw	#0x8, %a7
	moveal	%a7@+, %a1
	movel	%d0, %d1
	moveml	%a7@+, %d0
	movel	#0x8000003b, %a7@(0x18)
	movel	%d1, %a7@(0x1c)
	leal	%a7@(0x18), %a0
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x5a)
	braw	L93c
L892:
	moveq	#0x64, %d3
	cmpl	%d1, %d3
	bccb	L89a
	moveq	#0x64, %d1
L89a:
	moveq	#0xf, %d3
	movel	%d1, %d4
	movel	%d3, %d5
	swap	%d4
	swap	%d5
	muluw	%d3, %d4
	muluw	%d1, %d5
	muluw	%d3, %d1
	addw	%d5, %d4
	swap	%d4
	clrw	%d4
	addl	%d4, %d1
	movel	%d0, %a7@-
	movel	%a1, %a7@-
	peal	0x32:w
	movel	%d1, %a7@-
	.short	0x4eb9

	.long	_helpa
	addqw	#0x8, %a7
	moveal	%a7@+, %a1
	movel	%d0, %d1
	moveml	%a7@+, %d0
	movel	#0x8000003c, %a7@(0x18)
	movel	%d1, %a7@(0x1c)
	leal	%a7@(0x18), %a0
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x5a)
	brab	L93c
L8e8:
	moveq	#0x64, %d3
	cmpl	%d1, %d3
	bccb	L8f0
	moveq	#0x64, %d1
L8f0:
	moveq	#0xf, %d3
	movel	%d1, %d4
	movel	%d3, %d5
	swap	%d4
	swap	%d5
	muluw	%d3, %d4
	muluw	%d1, %d5
	muluw	%d3, %d1
	addw	%d5, %d4
	swap	%d4
	clrw	%d4
	addl	%d4, %d1
	movel	%d0, %a7@-
	movel	%a1, %a7@-
	peal	0x32:w
	movel	%d1, %a7@-
	.short	0x4eb9

	.long	_helpa
	addqw	#0x8, %a7
	moveal	%a7@+, %a1
	movel	%d0, %d1
	moveml	%a7@+, %d0
	movel	#0x8000003d, %a7@(0x18)
	movel	%d1, %a7@(0x1c)
	leal	%a7@(0x18), %a0
	.short	0x2c79

	.long	_gd+12
	jsr	%a6@(-0x5a)
L93c:
	moveml	%a7@+, %d2-%d5/%a3/%a6
	leal	%a7@(0x10), %a7
	rts	
	nop	
_needprelude:	.ascii	"I need at least version 5.6 of prelude.library"
	.byte	0,0
_nomodule:	.ascii	"No MPEGit module found"
	.byte	0,0
_outofmem:	.ascii	"Out of memory"
	.byte	0
	.short	0x4e71
	moveml	%a7@(4), %d0-%d1
	tstl	%d1
	bmib	L9b4
	tstl	%d0
	bmib	L9c0
	bsrb	La12
	movel	%d1, %d0
	rts	
L9b4:
	negl	%d1
	tstl	%d0
	bmib	L9ca
	bsrb	La12
	movel	%d1, %d0
	rts	
L9c0:
	negl	%d0
	bsrb	La12
	negl	%d1
	movel	%d1, %d0
	rts	
L9ca:
	negl	%d0
	bsrb	La12
	negl	%d1
	movel	%d1, %d0
	rts	
	moveml	%a7@(4), %d0-%d1
	bsrb	La12
	movel	%d1, %d0
	rts	
	moveml	%a7@(4), %d0-%d1
	tstl	%d0
	bplb	La00
	negl	%d0
	tstl	%d1
	bplb	L9f8
	negl	%d1
	bsrb	La12
	negl	%d1
	rts	
L9f8:
	bsrb	La12
	negl	%d0
	negl	%d1
	rts	
La00:
	tstl	%d1
	bplb	La12
	negl	%d1
	bsrb	La12
	negl	%d0
	rts	

_helpa:
	moveml	%a7@(4), %d0-%d1
La12:
	movel	%d2, %a7@-
	swap	%d1
	movew	%d1, %d2
	bneb	La38
	swap	%d0
	swap	%d1
	swap	%d2
	movew	%d0, %d2
	beqb	La28
	divuw	%d1, %d2
	movew	%d2, %d0
La28:
	swap	%d0
	movew	%d0, %d2
	divuw	%d1, %d2
	movew	%d2, %d0
	swap	%d2
	movew	%d2, %d1
	movel	%a7@+, %d2
	rts	
La38:
	movel	%d3, %a7@-
	moveq	#0x10, %d3
	.short	0xb27c,0x0080
	bccb	La46
	roll	#0x8, %d1
	subqw	#0x8, %d3
La46:
	.short	0xb27c,0x0800
	bccb	La50
	roll	#0x4, %d1
	subqw	#0x4, %d3
La50:
	.short	0xb27c,0x2000
	bccb	La5a
	roll	#0x2, %d1
	subqw	#0x2, %d3
La5a:
	tstw	%d1
	bmib	La62
	roll	#0x1, %d1
	subqw	#0x1, %d3
La62:
	movew	%d0, %d2
	lsrl	%d3, %d0
	swap	%d2
	clrw	%d2
	lsrl	%d3, %d2
	swap	%d3
	divuw	%d1, %d0
	movew	%d0, %d3
	movew	%d2, %d0
	movew	%d3, %d2
	swap	%d1
	muluw	%d1, %d2
	subl	%d2, %d0
	bccb	La84
	subqw	#0x1, %d3
	addl	%d1, %d0
La82:
	bccb	La82
La84:
	moveq	#0x0, %d1
	movew	%d3, %d1
	swap	%d3
	roll	%d3, %d0
	swap	%d0
	exg	%d0, %d1
	movel	%a7@+, %d3
	movel	%a7@+, %d2
	rts	
	nop	

_helpb:
	moveal	%a7@(4), %a0
	movel	%a0, %a0@(8)
	addql	#0x4, %a0
	clrl	%a0@
	movel	%a0, %a0@-
	rts	
