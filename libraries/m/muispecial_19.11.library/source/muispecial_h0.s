	.globl	_functab
	.globl	_initfn

_v24:
	moveq	#0x0, %d0
	rts	
_name:	.ascii	"muispecial.library"
	.byte	0
_idstr:	.ascii	"$VER: muispecial.library 19.11 (12.02.97) \2511992-1997 Stefan Stuntz\r\n"
	.byte	0
_romtag:	.short	0x4afc
	.long	_romtag	/* matchtag */
	.long	_endskip
	.byte	0x00,0x13,0x09,0x00
	.long	_name
	.long	_name+0x19	/* idstr = name in $VER */
	.long	_initfn
_endskip:
_dosname:	.ascii	"dos.library"
	.byte	0
_gfxname:	.ascii	"graphics.library"
	.byte	0
	.byte	0
_utlname:	.ascii	"utility.library"
	.byte	0
_timname:	.ascii	"timer.device"
	.byte	0
	.byte	0
_audname:	.ascii	"audio.device"
	.byte	0
	.byte	0
_mtidoc:	.ascii	"mui:docs/mti.data"
	.byte	0
_mtidata:	.ascii	"s:mti.data"
	.byte	0
	.byte	0
_scol:	.ascii	"s:"
	.byte	0
	.byte	0
_procname:	.ascii	"MUI-Audio-Process"
	.byte	0

_initfn:
	moveml	%d2/%a2-%a3/%a5-%a6, %a7@-
	movel	%a0, %d2
	moveal	0x4:w, %a5
	.short	0x41f9
	.long	_functab
	subal	%a1, %a1
	subal	%a2, %a2
	moveq	#0x54, %d0
	moveq	#0x0, %d1
	moveal	%a5, %a6
	jsr	%a6@(-0x54)
	moveal	%d0, %a2
	tstl	%d0
	beqb	L17e
	moveb	#0x9, %a2@(8)
	leal	_name(%pc), %a0
	movel	%a0, %a2@(0xa)
	moveb	#0x6, %a2@(0xe)
	leal	%a2@(0x14), %a3
	movew	#0x13, %a3@+
	movew	#0xb, %a3@+
	leal	_idstr(%pc), %a0
	movel	%a0, %a3@+
	movel	%d2, %a2@(0x22)
	leal	%a2@(0x26), %a0
	jsr	%a6@(-0x22e)
	moveal	%a2, %a6
	bsrw	_initdeps
	tstw	%d0
	beqb	L15e
	moveal	%a2, %a1
	moveal	%a5, %a6
	jsr	%a6@(-0x18c)
	brab	L17e
L15e:
	moveal	%a2, %a1
	moveq	#0x0, %d0
	movew	%a2@(0x10), %d0
	subal	%d0, %a1
	moveq	#0x0, %d1
	movew	%a2@(0x12), %d1
	moveq	#0x0, %d2
	movew	%d0, %d2
	addl	%d1, %d2
	movel	%d2, %d0
	moveal	%a5, %a6
	jsr	%a6@(-0xd2)
	subal	%a2, %a2
L17e:
	movel	%a2, %d0
	moveml	%a7@+, %d2/%a2-%a3/%a5-%a6
	rts	

_expunge:
	moveml	%d2/%d7/%a3/%a5-%a6, %a7@-
	moveal	%a6, %a5
	moveal	0x4:w, %a3
	tstw	%a5@(0x20)
	beqb	L1a0
	bsetb	#0x3, %a5@(0xe)
	moveq	#0x0, %d0
	brab	L1de
L1a0:
	moveal	%a5, %a6
	bsrw	_closedeps
	tstw	%d0
	bneb	L1b4
	bsetb	#0x3, %a5@(0xe)
	moveq	#0x0, %d0
	brab	L1de
L1b4:
	moveal	%a5, %a1
	moveal	%a3, %a6
	jsr	%a6@(-0xfc)
	movel	%a5@(0x22), %d7
	moveal	%a5, %a1
	moveq	#0x0, %d0
	movew	%a5@(0x10), %d0
	subal	%d0, %a1
	moveq	#0x0, %d1
	movew	%a5@(0x12), %d1
	moveq	#0x0, %d2
	movew	%d0, %d2
	addl	%d1, %d2
	movel	%d2, %d0
	jsr	%a6@(-0xd2)
	movel	%d7, %d0
L1de:
	moveml	%a7@+, %d2/%d7/%a3/%a5-%a6
	rts	

_open:
	moveml	%a2-%a3/%a5-%a6, %a7@-
	moveal	%a6, %a5
	moveal	0x4:w, %a3
	addqw	#0x1, %a5@(0x20)
	bclrb	#0x3, %a5@(0xe)
	leal	%a5@(0x26), %a0
	moveal	%a3, %a6
	jsr	%a6@(-0x234)
	moveal	%a5, %a6
	bsrw	_opendeps
	tstw	%d0
	beqb	L210
	moveal	%a5, %a2
	brab	L216
L210:
	subal	%a2, %a2
	subqw	#0x1, %a5@(0x20)
L216:
	leal	%a5@(0x26), %a0
	moveal	%a3, %a6
	jsr	%a6@(-0x23a)
	movel	%a2, %d0
	moveml	%a7@+, %a2-%a3/%a5-%a6
	rts	

_close:
	moveml	%d7/%a2-%a3/%a5-%a6, %a7@-
	moveal	%a6, %a5
	moveal	0x4:w, %a3
	moveq	#0x0, %d7
	leal	%a5@(0x26), %a2
	moveal	%a2, %a0
	moveal	%a3, %a6
	jsr	%a6@(-0x234)
	moveal	%a5, %a6
	bsrw	_stub382
	moveal	%a2, %a0
	moveal	%a3, %a6
	jsr	%a6@(-0x23a)
	subqw	#0x1, %a5@(0x20)
	bneb	L264
	btstb	#0x3, %a5@(0xe)
	beqb	L264
	moveal	%a5, %a6
	bsrw	_expunge
	movel	%d0, %d7
L264:
	movel	%d7, %d0
	moveml	%a7@+, %d7/%a2-%a3/%a5-%a6
	rts	

_initdeps:
	subqw	#0x4, %a7
	moveml	%a4/%a6, %a7@-
	movel	%a6, %a7@(8)
	.short	0x49f9
	.long	_gd+0
	moveal	0x4:w, %a6
	.short	0x294e,0x0
	leal	%a4@(0x20), %a0
	jsr	%a6@(-0x22e)
	moveq	#0x1, %d0
	moveml	%a7@+, %a4/%a6
	addqw	#0x4, %a7
	rts	

_closedeps:
	subqw	#0x4, %a7
	moveml	%a4/%a6, %a7@-
	movel	%a6, %a7@(8)
	.short	0x49f9
	.long	_gd+0
	tstl	%a4@(0x10)
	beqb	L2b0
	moveq	#0x0, %d0
	brab	L302
L2b0:
	movel	%a4@(0x14), %d0
	beqb	L2c4
	moveal	%d0, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x2b2)
	clrl	%a4@(0x14)
L2c4:
	movel	%a4@(4), %d0
	beqb	L2d8
	moveal	%d0, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x19e)
	clrl	%a4@(4)
L2d8:
	movel	%a4@(0xc), %d0
	beqb	L2ec
	moveal	%d0, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x19e)
	clrl	%a4@(0xc)
L2ec:
	movel	%a4@(8), %d0
	beqb	L300
	moveal	%d0, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x19e)
	clrl	%a4@(8)
L300:
	moveq	#0x1, %d0
L302:
	moveml	%a7@+, %a4/%a6
	addqw	#0x4, %a7
	rts	

_opendeps:
	moveml	%a4/%a6, %a7@-
	.short	0x49f9
	.long	_gd+0
	moveq	#0x1, %d0
	cmpw	%a6@(0x20), %d0
	bneb	L37a
	tstl	%a4@(8)
	bneb	L334
	leal	_dosname(%pc), %a1
	.short	0x2c6c,0x0
	moveq	#0x25, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a4@(8)
L334:
	tstl	%a4@(0xc)
	bneb	L34c
	leal	_gfxname(%pc), %a1
	.short	0x2c6c,0x0
	moveq	#0x25, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a4@(0xc)
L34c:
	tstl	%a4@(4)
	bneb	L364
	leal	_utlname(%pc), %a1
	.short	0x2c6c,0x0
	moveq	#0x25, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a4@(4)
L364:
	tstl	%a4@(8)
	beqb	L376
	tstl	%a4@(0xc)
	beqb	L376
	tstl	%a4@(4)
	bneb	L37a
L376:
	moveq	#0x0, %d0
	.short	0xc40
L37a:
	.short	0x7001
	moveml	%a7@+, %a4/%a6
	rts	

_stub382:
	subqw	#0x4, %a7
	movel	%a4, %a7@-
	movel	%a6, %a7@(4)
	.short	0x49f9
	.long	_gd+0
	moveq	#0x1, %d0
	moveal	%a7@+, %a4
	addqw	#0x4, %a7
	rts	

_v30:
	subqw	#0x8, %a7
	movel	%a4, %a7@-
	moveml	%d0/%a0, %a7@(4)
	.short	0x49f9
	.long	_gd+0
	moveq	#0x0, %d0
	moveal	%a7@+, %a4
	addqw	#0x8, %a7
	rts	

_v36:
	subqw	#0x4, %a7
	movel	%a4, %a7@-
	movel	%a0, %a7@(4)
	.short	0x49f9
	.long	_gd+0
	moveal	%a7@+, %a4
	addqw	#0x4, %a7
	rts	

_v42:
	subaw	#0x10, %a7
	movel	%a4, %a7@-
	moveml	%d0-%d2/%a0, %a7@(4)
	.short	0x49f9
	.long	_gd+0
	moveal	%a7@+, %a4
	addaw	#0x10, %a7
	rts	

_allocreq:
	moveml	%d7/%a5-%a6, %a7@-
	movel	%d0, %d7
	.short	0x2c6c,0x0
	jsr	%a6@(-0x29a)
	moveal	%d0, %a5
	tstl	%d0
	beqb	L40a
	movel	%d7, %a7@-
	movel	%a5, %a7@-
	bsrw	_allocioreq
	addqw	#0x8, %a7
	tstl	%d0
	bneb	L40c
	moveal	%a5, %a0
	.short	0x2c6c,0x0
	jsr	%a6@(-0x2a0)
L40a:
	moveq	#0x0, %d0
L40c:
	moveml	%a7@+, %d7/%a5-%a6
	rts	

_freereq:
	moveml	%a3/%a6, %a7@-
	movel	%a0, %d0
	beqb	L434
	moveal	%a0@(0xe), %a3
	movel	%a0, %a7@-
	bsrw	_freeioreq
	addqw	#0x4, %a7
	movel	%a3, %d0
	beqb	L434
	moveal	%a3, %a0
	.short	0x2c6c,0x0
	jsr	%a6@(-0x2a0)
L434:
	moveml	%a7@+, %a3/%a6
	rts	

_opentimer:
	moveml	%d7/%a5-%a6, %a7@-
	movel	%d0, %d7
	moveq	#0x28, %d0
	bsrb	_allocreq
	moveal	%d0, %a5
	tstl	%d0
	beqb	L468
	leal	_timname(%pc), %a0
	movel	%d7, %d0
	moveal	%a5, %a1
	.short	0x2c6c,0x0
	moveq	#0x0, %d1
	jsr	%a6@(-0x1bc)
	tstb	%d0
	bneb	L464
	movel	%a5, %d0
	brab	L46a
L464:
	moveal	%a5, %a0
	bsrb	_freereq
L468:
	moveq	#0x0, %d0
L46a:
	moveml	%a7@+, %d7/%a5-%a6
	rts	

_closedev:
	moveml	%a5-%a6, %a7@-
	moveal	%a0, %a5
	movel	%a5, %d0
	beqb	L48e
	tstl	%a5@(0x14)
	beqb	L48a
	moveal	%a5, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x1c2)
L48a:
	moveal	%a5, %a0
	bsrb	_freereq
L48e:
	moveml	%a7@+, %a5-%a6
	rts	

_openaudio:
	moveml	%d6-%d7/%a3/%a5-%a6, %a7@-
	movel	%d1, %d6
	movel	%d0, %d7
	moveal	%a0, %a5
	moveq	#0x44, %d0
	bsrw	_allocreq
	moveal	%d0, %a3
	tstl	%d0
	beqb	L4e2
	movel	%a5, %a3@(0x22)
	movel	%d6, %a3@(0x26)
	movew	#0x40, %a3@(0x2c)
	moveb	#0x10, %a3@(0x1e)
	moveb	%d7, %a3@(9)
	leal	_audname(%pc), %a0
	moveal	%a3, %a1
	.short	0x2c6c,0x0
	moveq	#0x0, %d0
	movel	%d0, %d1
	jsr	%a6@(-0x1bc)
	tstb	%d0
	bneb	L4dc
	movel	%a3, %d0
	brab	L4e4
L4dc:
	moveal	%a3, %a0
	bsrw	_freereq
L4e2:
	moveq	#0x0, %d0
L4e4:
	moveml	%a7@+, %d6-%d7/%a3/%a5-%a6
	rts	

_closeaudio:
	moveml	%a5-%a6, %a7@-
	moveal	%a0, %a5
	movel	%a5, %d0
	beqb	L50a
	tstl	%a5@(0x14)
	beqb	L504
	moveal	%a5, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x1c2)
L504:
	moveal	%a5, %a0
	bsrw	_freereq
L50a:
	moveml	%a7@+, %a5-%a6
	rts	

_dotone:
	moveml	%d7/%a5-%a6, %a7@-
	movel	%d0, %d7
	moveal	%a0, %a5
	movew	#0x9, %a5@(0x1c)
	tstl	%d7
	beqb	L582
	moveq	#0x1, %d0
	cmpl	%d0, %d7
	bneb	L530
	clrl	%a5@(0x20)
	moveq	#0x32, %d0
	brab	L56c
L530:
	cmpil	#0x3e8, %d7
	bltb	L55c
	movel	%d7, %d0
	moveq	#0x7d, %d1
	lsll	#0x3, %d1
	bsrw	_divs
	movel	%d0, %a5@(0x20)
	movel	%d7, %d0
	moveq	#0x7d, %d1
	lsll	#0x3, %d1
	bsrw	_divs
	movel	%d1, %d0
	asll	#0x6, %d0
	subl	%d1, %d0
	addl	%d0, %d0
	subl	%d1, %d0
	brab	L56a
L55c:
	clrl	%a5@(0x20)
	movel	%d7, %d0
	asll	#0x6, %d0
	subl	%d7, %d0
	addl	%d0, %d0
	subl	%d7, %d0
L56a:
	asll	#0x3, %d0
L56c:
	movel	%d0, %a5@(0x24)
	movel	%a5, %a7@-
	bsrw	_beginio
	addqw	#0x4, %a7
	moveal	%a5, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x1da)
L582:
	moveml	%a7@+, %d7/%a5-%a6
	rts	

_audioproc:
	subaw	#0x10, %a7
	moveml	%d6-%d7/%a2-%a6, %a7@-
	.short	0x49f9
	.long	_gd+0
	leal	%a4@(0x18), %a0
	moveq	#0x32, %d0
	moveq	#0x3, %d1
	bsrw	_openaudio
	moveal	%d0, %a5
	movel	%d0, %a7@(0x28)
	beqw	L786
	leal	%a4@(0x1b), %a0
	moveq	#0x32, %d0
	moveq	#0x3, %d1
	bsrw	_openaudio
	moveal	%d0, %a3
	movel	%d0, %a7@(0x24)
	beqw	L780
	moveq	#0x0, %d0
	bsrw	_opentimer
	moveal	%d0, %a2
	movel	%d0, %a7@(0x20)
	beqw	L77a
	moveq	#0x3, %d1
	movew	%d1, %a5@(0x1c)
	movew	%d1, %a3@(0x1c)
	moveq	#0x10, %d1
	moveb	%d1, %a5@(0x1e)
	moveb	%d1, %a3@(0x1e)
	moveal	%a4@(0x14), %a0
	movel	%a0, %a5@(0x22)
	movel	%a0, %a3@(0x22)
	movel	#0x1b6c, %d1
	movel	%d1, %a5@(0x26)
	movel	%d1, %a3@(0x26)
	moveq	#0x40, %d1
	movew	%d1, %a5@(0x2c)
	movew	%d1, %a3@(0x2c)
	moveq	#0x1, %d1
	movew	%d1, %a5@(0x2e)
	movew	%d1, %a3@(0x2e)
	moveal	%a4@(0xc), %a0
	btstb	#0x2, %a0@(0xcf)
	beqb	L628
	movel	#0x361f0f, %d1
	brab	L62e
L628:
	movel	#0x369e99, %d1
L62e:
	movel	%d1, %d0
	movel	%a4@(0x52), %d1
	bsrw	_divs
	movew	%d0, %a5@(0x2a)
	movew	%d0, %a3@(0x2a)
	movel	%a5, %a7@-
	bsrw	_beginio
	movel	%a3, %a7@
	bsrw	_beginio
	moveal	%a2, %a0
	moveq	#0x64, %d0
	addl	%d0, %d0
	bsrw	_dotone
	moveal	%a4@(0x14), %a0
	addaw	#0x1b6e, %a0
	movel	%a0, %a5@(0x22)
	leal	%a3@(0x22), %a2
	movel	%a0, %a2@+
	movel	#0xffffe494, %d0
	addl	%a4@(0x4e), %d0
	movel	%d0, %a5@(0x26)
	movel	%d0, %a2@+
	subqw	#0x1, %a2@+
	moveal	%a5, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x1da)
	movel	%a5, %a7@
	bsrw	_beginio
	moveal	%a3, %a1
	jsr	%a6@(-0x1da)
	movel	%a3, %a7@
	bsrw	_beginio
	moveal	%a3, %a1
	jsr	%a6@(-0x1da)
	moveal	%a4@(0x14), %a0
	addal	#0x9144, %a0
	movel	%a0, %a3@(0x22)
	movel	#0xffff6ebc, %d0
	addl	%a4@(0x4e), %d0
	movel	%d0, %a3@(0x26)
	movew	#0x5, %a3@(0x2e)
	movel	%a3, %a7@
	bsrw	_beginio
	moveal	%a5, %a1
	jsr	%a6@(-0x1da)
	moveal	%a4@(0x14), %a0
	addal	#0x9144, %a0
	movel	%a0, %a5@(0x22)
	movel	#0xffff6ebc, %d0
	addl	%a4@(0x4e), %d0
	movel	%d0, %a5@(0x26)
	movew	#0x5, %a5@(0x2e)
	movel	%a5, %a7@
	bsrw	_beginio
	addqw	#0x4, %a7
	moveq	#0x5c, %d7
	moveal	#0xdff0a8, %a2
	moveal	#0xdff0b8, %a3
	moveal	#0xdff0c8, %a5
	moveal	#0xdff0d8, %a0
	movel	%a0, %a7@(0x1c)
L712:
	movel	%d7, %d6
	moveq	#0x40, %d0
	cmpl	%d0, %d7
	bleb	L71c
	movel	%d0, %d6
L71c:
	movew	%d6, %a2@
	movew	%d6, %a3@
	movew	%d6, %a5@
	moveal	%a7@(0x1c), %a0
	movew	%d6, %a0@
	.short	0x2c6c,0x0
	moveq	#0x0, %d0
	movel	%d0, %d1
	jsr	%a6@(-0x132)
	btstb	#0xc, %d0
	beqb	L74c
	moveal	%a7@(0x24), %a1
	jsr	%a6@(-0x1e0)
	moveal	%a7@(0x28), %a1
	jsr	%a6@(-0x1e0)
	brab	L75a
L74c:
	moveal	%a7@(0x20), %a0
	moveq	#0x78, %d0
	bsrw	_dotone
	subql	#0x1, %d7
	bplb	L712
L75a:
	moveal	%a7@(0x24), %a3
	moveal	%a3, %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x1da)
	moveal	%a7@(0x28), %a5
	moveal	%a5, %a1
	jsr	%a6@(-0x1da)
	moveal	%a7@(0x20), %a0
	bsrw	_closedev
L77a:
	moveal	%a3, %a0
	bsrw	_closeaudio
L780:
	moveal	%a5, %a0
	bsrw	_closeaudio
L786:
	.short	0x2c6c,0x0
	jsr	%a6@(-0x84)
	clrl	%a4@(0x10)
	moveml	%a7@+, %d6-%d7/%a2-%a6
	addaw	#0x10, %a7
	tstl	%d0
	rts	

_finddata:
	subaw	#0x104, %a7
	moveml	%d2/%d5-%d7/%a3/%a5-%a6, %a7@-
	.short	0x2c6c,0x0
	subal	%a1, %a1
	jsr	%a6@(-0x126)
	moveal	%d0, %a5
	moveal	%d0, %a0
	moveal	%a0@(0xb8), %a3
	moveq	#-1, %d1
	movel	%d1, %a0@(0xb8)
	leal	_mtidoc(%pc), %a0
	movel	%a0, %d1
	moveal	%a4@(8), %a6
	movel	#0x3ed, %d2
	jsr	%a6@(-0x1e)
	movel	%d0, %d7
	bnew	L862
	leal	_mtidata(%pc), %a0
	movel	%a0, %d1
	jsr	%a6@(-0x1e)
	movel	%d0, %d7
	bneb	L862
	leal	_scol(%pc), %a0
	movel	%a0, %d1
	moveq	#-2, %d2
	jsr	%a6@(-0x54)
	movel	%d0, %d6
	beqb	L862
	movel	%d6, %d1
	leal	%a7@(0x1c), %a0
	movel	%a0, %d2
	jsr	%a6@(-0x66)
	tstl	%d0
	beqb	L858
	movel	%a7@(0x20), %d0
	bmib	L858
	brab	L844
L80e:
	movel	%a7@(0x20), %d0
	bplb	L844
	cmpil	#0x15a09, %a7@(0x98)
	bneb	L844
	movel	%d6, %d1
	moveal	%a4@(8), %a6
	jsr	%a6@(-0x7e)
	movel	%d0, %d5
	leal	%a7@(0x24), %a0
	movel	%a0, %d1
	movel	#0x3ed, %d2
	jsr	%a6@(-0x1e)
	movel	%d0, %d7
	movel	%d5, %d1
	jsr	%a6@(-0x7e)
	brab	L858
L844:
	movel	%d6, %d1
	leal	%a7@(0x1c), %a0
	movel	%a0, %d2
	moveal	%a4@(8), %a6
	jsr	%a6@(-0x6c)
	tstl	%d0
	bneb	L80e
L858:
	movel	%d6, %d1
	moveal	%a4@(8), %a6
	jsr	%a6@(-0x5a)
L862:
	movel	%a3, %a5@(0xb8)
	movel	%d7, %d0
	moveml	%a7@+, %d2/%d5-%d7/%a3/%a5-%a6
	addaw	#0x104, %a7
	rts	

_v48:
	moveml	%d2-%d3/%d6-%d7/%a4/%a6, %a7@-
	.short	0x49f9
	.long	_gd+0
	moveq	#0x0, %d6
	leal	%a4@(0x20), %a0
	.short	0x2c6c,0x0
	jsr	%a6@(-0x234)
	tstw	%a4@(0x1e)
	bnew	L972
	tstl	%a4@(0x10)
	bnew	L972
	tstl	%a4@(0x14)
	bnew	L92c
	moveq	#0x2, %d1
	jsr	%a6@(-0xd8)
	cmpil	#0x493e0, %d0
	blsb	L92c
	bsrw	_finddata
	movel	%d0, %d7
	beqb	L92c
	movel	%d7, %d1
	leal	%a4@(0x4e), %a0
	movel	%a0, %d2
	moveal	%a4@(8), %a6
	moveq	#0x4, %d3
	jsr	%a6@(-0x2a)
	movel	%d7, %d1
	leal	%a4@(0x52), %a0
	movel	%a0, %d2
	jsr	%a6@(-0x2a)
	movel	%a4@(0x4e), %d0
	cmpil	#0x10f3a, %d0
	bneb	L922
	cmpil	#0x2596, %a4@(0x52)
	bneb	L922
	.short	0x2c6c,0x0
	moveq	#0x2, %d1
	jsr	%a6@(-0x2ac)
	movel	%d0, %a4@(0x14)
	beqb	L922
	movel	%d0, %d2
	movel	%d7, %d1
	movel	%a4@(0x4e), %d3
	moveal	%a4@(8), %a6
	jsr	%a6@(-0x2a)
	cmpl	%a4@(0x4e), %d0
	beqb	L922
	moveal	%a4@(0x14), %a1
	.short	0x2c6c,0x0
	jsr	%a6@(-0x2b2)
	clrl	%a4@(0x14)
L922:
	movel	%d7, %d1
	moveal	%a4@(8), %a6
	jsr	%a6@(-0x24)
L92c:
	tstl	%a4@(0x14)
	beqb	L968
	clrl	%a7@-
	peal	0x5:w
	movel	#0x800003f5, %a7@-
	peal	_procname(%pc)
	movel	#0x800003f4, %a7@-
	peal	_audioproc(%pc)
	movel	#0x800003eb, %a7@-
	moveal	%a4@(8), %a6
	movel	%a7, %d1
	jsr	%a6@(-0x1f2)
	leal	%a7@(0x1c), %a7
	movel	%d0, %a4@(0x10)
	beqb	L968
	moveq	#0x1, %d6
L968:
	tstw	%d6
	bneb	L972
	movew	#0x1, %a4@(0x1e)
L972:
	leal	%a4@(0x20), %a0
	.short	0x2c6c,0x0
	jsr	%a6@(-0x23a)
	movew	%d6, %d0
	moveml	%a7@+, %d2-%d3/%d6-%d7/%a4/%a6
	rts	
	nop	
_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_v24
	.long	_v30
	.long	_v36
	.long	_v42
	.long	_v48
	.long	0xffffffff

_allocioreq:
	moveal	%a7@(4), %a0
	movel	%a7@(8), %d0
	moveml	%d7/%a5-%a6, %a7@-
	moveal	%a0, %a5
	movel	%d0, %d7
	movel	%a5, %d0
	beqb	L9e6
	movel	%d7, %d0
	movel	#0x10001, %d1
	moveal	0x4:w, %a6
	jsr	%a6@(-0xc6)
	tstl	%d0
	beqb	L9e6
	moveal	%d0, %a0
	moveb	#0x7, %a0@(8)
	movew	%d7, %a0@(0x12)
	movel	%a5, %a0@(0xe)
	.short	0xc40
L9e6:
	.short	0x7000
	moveml	%a7@+, %d7/%a5-%a6
	rts	

_freeioreq:
	moveal	%a7@(4), %a0
	movel	%a6, %a7@-
	moveal	%a0, %a1
	movel	%a1, %d0
	beqb	La12
	moveaw	#0xffff, %a0
	movel	%a0, %a1@
	movel	%a0, %a1@(0x14)
	moveq	#0x0, %d0
	movew	%a1@(0x12), %d0
	moveal	0x4:w, %a6
	jsr	%a6@(-0xd2)
La12:
	moveal	%a7@+, %a6
	rts	
	nop	

_beginio:
	moveal	%a7@(4), %a0
	moveal	%a0, %a1
	movel	%a6, %a7@-
	moveal	%a1@(0x14), %a6
	jsr	%a6@(-0x1e)
	moveal	%a7@+, %a6
	rts	

_divs:
	tstl	%d0
	bplw	La4e
	negl	%d0
	tstl	%d1
	bplw	La44
	negl	%d1
	bsrw	_divu32
	negl	%d1
	rts	
La44:
	bsrw	_divu32
	negl	%d0
	negl	%d1
	rts	
La4e:
	tstl	%d1
	bplw	_divu32
	negl	%d1
	bsrw	_divu32
	negl	%d0
	rts	

_divu32:
	movel	%d2, %a7@-
	swap	%d1
	movew	%d1, %d2
	bnew	La88
	swap	%d0
	swap	%d1
	swap	%d2
	movew	%d0, %d2
	beqw	La78
	divuw	%d1, %d2
	movew	%d2, %d0
La78:
	swap	%d0
	movew	%d0, %d2
	divuw	%d1, %d2
	movew	%d2, %d0
	swap	%d2
	movew	%d2, %d1
	movel	%a7@+, %d2
	rts	
La88:
	movel	%d3, %a7@-
	moveq	#0x10, %d3
	cmpiw	#0x100, %d1
	bccw	La98
	roll	#0x8, %d1
	subqw	#0x8, %d3
La98:
	cmpiw	#0x1000, %d1
	bccw	Laa4
	roll	#0x4, %d1
	subqw	#0x4, %d3
Laa4:
	cmpiw	#0x4000, %d1
	bccw	Lab0
	roll	#0x2, %d1
	subqw	#0x2, %d3
Lab0:
	tstw	%d1
	bmiw	Laba
	roll	#0x1, %d1
	subqw	#0x1, %d3
Laba:
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
	bccw	Ladc
	subqw	#0x1, %d3
	addl	%d1, %d0
Ladc:
	moveq	#0x0, %d1
	movew	%d3, %d1
	swap	%d3
	roll	%d3, %d0
	swap	%d0
	exg	%d0, %d1
	movel	%a7@+, %d3
	movel	%a7@+, %d2
	rts	
