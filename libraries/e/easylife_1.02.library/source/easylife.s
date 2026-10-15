/* easylife.library 1.02 reconstruction - byte-identical transcription */
/* Compiled-C dynamic-array library (Paul Hickman 21.09.94) */
/* Single CODE hunk; AUTOINIT; reg-args d0-d4/a0-a1 */
	.text
	.globl _start
_start:
	moveq	#-1,d0			/* dos LoadSeg stub: fail */
	rts

	/* RomTag @ h0+4 */
_rt:
	.short	0x4afc
	.long	_rt			/* MatchTag -> +4 */
	.long	_inittab		/* EndSkip -> InitTable */
	.byte	0x80,1,9,0		/* AUTOINIT, ver 1, NT_LIBRARY, pri 0 */
	.long	_name			/* Name */
	.long	_idstr			/* IdString */
	.long	_inittab		/* Init -> InitTable */
_name:
	.ascii	"easylife.library"
	.byte	0
_idstr:
	.ascii	"Easylife.Library V 1.02 (21.09.94) \251 Paul Hickman\r\n"
	.byte	0
	.even

	/* InitTable @ 0x64 */
_inittab:
	.long	0xfc			/* dsize */
	.long	_functab		/* function table */
	.long	_datatab		/* InitStruct table */
	.long	_initfn			/* init routine */

_functab:
	.long	_open			/* -6 */
	.long	_close			/* -12 */
	.long	_expunge		/* -18 */
	.long	_ret0			/* -24 */
	.long	_f1d8			/* -30 */
	.long	_f236			/* -36 */
	.long	_f166			/* -42 */
	.long	_f25a			/* -48 */
	.long	_f3be			/* -54 */
	.long	_f46a			/* -60 */
	.long	_f548			/* -66 */
	.long	_f59c			/* -72 */
	.long	_f5f8			/* -78 */
	.long	_f6d0			/* -84 */
	.long	_f7b4			/* -90 */
	.long	_f6e8			/* -96 */
	.long	_f8e4			/* -102 */
	.long	_f97a			/* -108 */
	.long	-1

	/* InitStruct data table @ 0xc0 */
_datatab:
	.byte	0xa0,0x0c,0x09,0x00	/* INITBYTE @+0x0c = 9 (dead: covered by next) */
	.byte	0x80,0x0a		/* INITLONG @+0x0a = ln_Name */
	.long	_name
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE @+0x0e = 6 (lib_Flags) */
	.byte	0x90,0x14		/* INITWORD @+0x14 = version 1 */
	.short	1
	.byte	0x90,0x16		/* INITWORD @+0x16 = revision 2 */
	.short	2
	.byte	0x80,0x18		/* INITLONG @+0x18 = lib_IdString */
	.long	_idstr
	.long	0

/* initfn @ 0xe0 : d0 = libbase */
_initfn:
	movel	a5,sp@-
	moveal	d0,a5
	movel	a6,a5@(34)		/* lib+34 = SysBase */
	movel	a0,a5@(38)		/* lib+38 = seglist */
	moveal	sp@+,a5
	rts

/* -6 Open */
_open:
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

/* -12 Close */
_close:
	moveq	#0,d0
	subqw	#1,a6@(32)
	bnew	1f
	btst	#3,a6@(14)
	beqw	1f
	bsrw	_expunge
1:	rts

/* -18 Expunge */
_expunge:
	moveml	d1-d2/a5-a6,sp@-
	moveal	a6,a5
	moveal	a5@(34),a6		/* SysBase */
	tstw	a5@(32)
	beqw	1f
	bset	#3,a5@(14)
	moveq	#0,d0
	braw	2f
1:	movel	a5@(38),d2		/* seglist */
	moveal	a5,a1
	moveal	0x4,a6
	jsr	a6@(-252)		/* Remove */
	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(16),d0
	subal	d0,a1
	addw	a5@(18),d0
	moveal	0x4,a6
	jsr	a6@(-210)		/* FreeMem */
	movel	d2,d0
2:	moveml	sp@+,d1-d2/a5-a6
	rts

/* -24 */
_ret0:
	moveq	#0,d0
	rts

/* -42 @0x166 */
_f166:
	linkw	a4,#-28
	moveml	d1-d4/a0-a1,a4@(-28)
	moveal	d0,a0
	bsrw	_f236
	beqw	_e36
	moveal	d0,a1
	movel	a1@(12),d2
	moveq	#0,d0
	movew	a0@,d0
	moveq	#0,d1
	bsrw	_f1d8
	beqw	_e00
	moveal	d0,a1
	movel	a1@,d0
	movel	a6@(248),d3
4:	movel	d3,d1
	beqw	_e23
	cmpl	a0,d1
	bccs	3f
	addl	d2,d1
	cmpl	a0,d1
	bcss	3f
	moveal	a0,a1
	moveal	d3,a0
	lea	a0@(-14),a0
	moveml	d2-d7/a1-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-192)		/* Deallocate */
	moveml	sp@+,d2-d7/a1-a6
	subql	#1,a6@(244)
	moveml	a4@(-28),d1-d4/a0-a2
	unlk	a4
	movew	#0,%ccr
	rts
3:	moveal	d3,a1
	movel	a1@(18),d3
	bras	4b

/* -30 @0x1d8 */
_f1d8:
	linkw	a4,#-16
	moveml	d2/a0-a1,a4@(-16)
	movel	d0,d2
	beqs	1f
	bsrw	_f236
	beqw	_e36
	moveal	d0,a0
	moveal	d0,a1
	addal	d2,a0
	moveq	#0,d0
	movew	a0@+,d0
	bras	3f
2:	movel	a0@+,d2
	cmpw	d1,d2
	beqs	5f
3:	dbf	d0,2b
1:	moveml	a4@(-16),d2/a0-a1
	unlk	a4
	movew	#4,%ccr
	rts
5:	movew	#0,d2
	swap	d2
	cmpl	a1@(16),d2
	blts	1b
	cmpl	a1@(-20),d2
	bges	1b
	addal	d2,a1
	movel	a1,d0
	moveml	a4@(-16),d2/a0-a1
	unlk	a4
	movew	#0,%ccr
	rts

/* -36 @0x236 : lazy pool-head init */
_f236:
	movel	a6@(240),d0
	bnes	1f
	movel	a6@(236),d0
	moveml	d1/a0-a1,sp@-
	movel	a2,sp@-
	moveal	a6@(42),a2
	jsr	a2@
	moveal	sp@+,a2
	movel	a0,d0
	moveml	sp@+,d1/a0-a1
	movel	d0,a6@(240)
1:	rts

/* -48 @0x25a */
_f25a:
	linkw	a4,#-16
	moveml	d2-d3/a0,a4@(-16)
	movel	d0,d2
	movel	d1,d3
	moveq	#0,d1
	bsrw	_f1d8
	beqw	_e00
	moveal	d0,a0
	movel	a0@,d0
	movel	d0,d1
	bsrs	_f2b0
	beqw	_e24a
	moveal	d0,a0
	movew	d2,a0@+
	movew	#0,a0@+
	.short	0xb6bc			/* cmpl #65536,d3 */
	.long	65536
	bnes	2f
	movel	d1,d2
	lsrl	#2,d2
	subqw	#2,d2
1:	movel	#0,a0@+
	dbf	d2,1b
2:	addql	#1,a6@(244)
	moveml	a4@(-16),d2-d3/a0
	unlk	a4
	movew	#0,%ccr
	rts

/* helper @0x2b0 : Allocate into pool a6+248 */
_f2b0:
	linkw	a4,#-16
	moveml	d1/a0-a1,a4@(-16)
	lea	a6@(248),a1
	movel	d0,d1
1:	movel	a1@,d0
	bnes	2f
	bsrs	_f2f6
	beqs	3f
	movel	d0,a1@
2:	moveal	d0,a0
	moveml	d1-a6,sp@-
	movel	d1,d0
	lea	a0@(-14),a0
	moveal	0x4,a6
	jsr	a6@(-186)		/* Allocate */
	moveml	sp@+,d1-a6
	tstl	d0
	bnes	3f
	lea	a0@(18),a1
	bras	1b
3:	moveml	a4@(-16),d1/a0-a1
	unlk	a4
	rts

/* helper @0x2f6 : AllocMem pool block */
_f2f6:
	linkw	a4,#-20
	moveml	d1-d2/a0-a1,a4@(-20)
	moveal	a6@(240),a0
	movel	a0@(12),d0
	movel	#65536,d1
	movel	d0,d2
	moveml	d2-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-198)		/* AllocMem */
	moveml	sp@+,d2-a6
	tstl	d0
	beqs	1f
	moveal	d0,a0
	movel	d0,a0@(2)
	addil	#24,a0@(2)
	movel	a0@(2),a0@(6)
	movel	d0,d1
	addl	d2,d1
	movel	d1,a0@(10)
	movel	d2,d1
	subil	#32,d1
	movel	d1,a0@(14)
	movel	#0,a0@(24)
	movel	d1,a0@(28)
1:	moveml	a4@(-20),d1-d2/a0-a1
	unlk	a4
	tstl	d0
	rts

/* helper @0x364 : decode size-spec a0 -> d1 */
_f364:
	linkw	a4,#-16
	moveml	d1/d3-d4,a4@(-16)
	moveal	d1,a0
	movew	a0@,d1
	bsrw	_f1d8
	beqw	_e00
	moveal	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveal	d2,a1
	cmpl	d3,d1
	bnew	_e23
	moveq	#0,d4
	bras	2f
1:	moveq	#0,d2
	movew	a0@+,d2
	movel	a1@+,d3
	bmiw	_e31
	cmpl	d3,d2
	bcsw	_e31
	muluw	d2,d4
	addl	d3,d4
2:	dbf	d1,1b
	movel	d4,d1
	moveml	a4@(-12),d3-d4
	moveml	a4@(-16),a1
	unlk	a4
	movew	#0,%ccr
	rts

/* -54 @0x3be : element GET via jump table @0x3f4 */
_f3be:
	linkw	a4,#-40
	moveml	d2-a2,a4@(-40)
	bsrs	_f364
	beqw	_e00
	movel	d0,d7
	movel	a0@+,d2
	addal	d2,a1
	moveq	#0,d2
	lea	%pc@(_jt3f4),a2
	asll	#1,d0
	movew	a2@(0,d0:l),d0
	addal	d0,a2
	jsr	a2@
	movel	d7,d1
	moveml	a4@(-40),d2-a2
	unlk	a4
	movew	#0,%ccr
	rts

/* jump table @0x3f4 : word offsets rel to table start */
_jt3f4:
	.short	0x1a,0x18,0x26,0x24,0x32,0x30,0x3a,0x1a,0x1a
	.short	0x42,0x56,0x64
/* entries: 40e,40c,41a,418,426,424,42e,40e,40e,436,44a,458 */

/* GET helpers */
_g40c:				/* 0x40c : entry 0x18, d2 = *a0 base variant */
	movel	a0@,d2
_g40e:				/* 0x40e */
	asll	#2,d1
	movel	a1@(0,d1:l),d0
	addl	d2,d0
	rts
_g418:				/* 0x418 */
	movel	a0@,d2
	asll	#1,d1
	movew	a1@(0,d1:l),d0
	addl	d2,d0
	rts
_g424:				/* 0x424 */
	movel	a0@,d2
	moveb	a1@(0,d1:l),d0
	addl	d2,d0
	rts
_g42e:				/* 0x42e */
	asll	#2,d1
	movel	a1@(0,d1:l),d0
	rts
_g436:				/* 0x436 */
	moveb	a0@,d2
	addl	d1,d2
	movel	d2,d1
	asrl	#3,d1
	moveq	#0,d0
	btst	d2,a1@(0,d1:l)
	beqs	1f
	moveq	#-1,d0
1:	rts
_g44a:				/* 0x44a */
	movew	a0@,d2
	addqw	#2,d2
	muluw	d2,d1
	addal	d1,a1
	movel	a1,d0
	addqw	#2,d0
	rts
_g458:				/* 0x458 */
	movel	a1,d0
	muluw	a0@+,d1
	addl	d1,d0
	movew	a0@,a1@(0,d1:l)
	movew	#1,a1@(2,d1:l)
	rts

/* -60 @0x46a : element SET via jump table @0x49a */
_f46a:
	linkw	a4,#-44
	moveml	d0-d6/a0-a2,a4@(-44)
	movel	d4,d6
	bsrw	_f364
	movel	a0@+,d2
	addal	d2,a1
	lea	%pc@(_jt49a),a2
	asll	#1,d0
	movew	a2@(0,d0:l),d0
	addal	d0,a2
	jsr	a2@
	moveml	a4@(-44),d0-d6/a0-a2
	unlk	a4
	movew	#0,%ccr
	rts

/* jump table @0x49a */
_jt49a:
	.short	0x26,0x18,0x3c,0x2e,0x52,0x44,0x26,0x26,0x58,0x6e
	.short	0x88,0xaa
/* entries: 4c0,4b2,4d6,4c8,4ec,4de,4c0,4c0,4f2,508,522,544 */

_s4b4:				/* 0x4b4 (d6 base? pre-entry shared tail) */
	subl	a0@+,d6
	bmiw	_e32
	cmpl	a0@,d6
	beqs	1f
	bccw	_e33
1:	asll	#2,d1
	movel	d6,a1@(0,d1:l)
	rts
_s4c8:				/* 0x4c8 */
	subl	a0@+,d6
	bmiw	_e32
	cmpl	a0@,d6
	beqs	1f
	bccw	_e33
1:	asll	#1,d1
	movew	d6,a1@(0,d1:l)
	rts
_s4de:				/* 0x4de */
	subl	a0@+,d6
	bmiw	_e32
	cmpl	a0@,d6
	beqs	1f
	bccw	_e33
1:	moveb	d6,a1@(0,d1:l)
	rts
_s4f2:				/* 0x4f2 */
	tstl	d6
	beqs	1f
	moveal	d6,a2
	movew	a2@,d0
	cmpw	a0@,d0
	bnew	_e34
1:	asll	#2,d1
	movel	d6,a1@(0,d1:l)
	rts
_s508:				/* 0x508 */
	moveq	#0,d2
	moveb	a0@,d2
	addl	d2,d1
	movel	d1,d2
	asrl	#3,d1
	tstl	d6
	beqs	1f
	bset	d2,a1@(0,d1:l)
	rts
1:	bclr	d2,a1@(0,d1:l)
	rts
_s522:				/* 0x522 */
	moveal	d6,a2
	movew	a2@,d0
	movew	a0@,d2
	cmpw	d0,d2
	bcsw	_e35
	addqw	#2,d0
	addqw	#2,d2
	muluw	d2,d1
	addal	d1,a1
	bras	1f
2:	moveb	a2@+,a1@+
1:	dbf	d0,2b
	moveb	#0,a1@+
	rts
_s544:				/* 0x544 */
	braw	_e36b

/* -66 @0x548 : compare elements */
_f548:
	linkw	a4,#-24
	moveml	d1-d3/a0-a1,a4@(-24)
	bsrw	_f3be
	.short	0xb2bc			/* cmpl #10,d1 */
	.long	10
	bnew	_e23
	moveal	d0,a0
	moveal	d4,a1
	moveq	#0,d0
	moveq	#0,d1
	movew	a0@(-2),d0
	movew	a1@+,d1
	moveq	#-1,d2
1:	addql	#1,d2
	cmpw	d2,d0
	beqs	3f
	cmpw	d2,d1
	beqs	4f
	cmpmb	a0@+,a1@+
	beqs	1b
	blts	4f
2:	moveq	#-1,d0
	bras	5f
3:	cmpw	d2,d1
	bnes	2b
	moveq	#0,d0
	bras	5f
4:	moveq	#1,d0
5:	moveml	a4@(-24),d1-d3/a0-a1
	unlk	a4
	movew	#0,%ccr
	rts

/* -72 @0x59c : free all arrays */
_f59c:
	linkw	a4,#-20
	moveml	d0-d1/a0-a1,a4@(-20)
	movel	a6@(248),d1
	tstl	d1
	beqs	2f
	moveal	a6@(240),a0
	movel	a0@(12),d0
1:	tstl	d1
	beqs	2f
	moveal	d1,a1
	movel	a1@(18),d1
	moveml	d0-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-210)		/* FreeMem */
	moveml	sp@+,d0-a6
	bras	1b
2:	movel	#0,a6@(248)
	movel	#0,a6@(244)
	movel	#0,a6@(240)
	moveml	a4@(-20),d0-d1/a0-a1
	unlk	a4
	movew	#0,%ccr
	rts

/* -78 @0x5f8 : build sorted array buffer */
_f5f8:
	linkw	a4,#-16
	moveml	d1-d3,a4@(-16)
	movel	d0,d3
	movel	a6@(244),d0
	asll	#2,d0
	addil	#12,d0
	movel	#65536,d1
	movel	d0,d2
	moveml	d2-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-198)		/* AllocMem */
	moveml	sp@+,d2-a6
	beqw	_e24a
	moveal	d0,a1
	movel	d2,a1@+
	addql	#4,a1
	movel	a1,d1
	movel	d3,a1@
	lea	a1@(4),a2
1:	moveal	a1@+,a0
	moveq	#0,d0
	movew	a0@,d0
	bsrw	_f670
	cmpal	a1,a2
	bnes	1b
	moveq	#0,d2
2:	cmpl	a1,d1
	beqs	3f
	moveal	a1@-,a0
	bclr	#1,a0@(2)
	addql	#1,d2
	bras	2b
3:	movel	d1,d0
	moveal	d1,a1
	movel	d2,a1@(-4)
	moveml	a4@(-16),d1-d3
	unlk	a4
	movew	#0,%ccr
	rts

/* helper @0x670 : collect marked elts */
_f670:
	moveml	d1-d5/a1/a3,sp@-
	moveq	#0,d1
	bsrw	_f1d8
	beqw	_e00
	moveal	d0,a1
	movel	a1@+,d3
	moveq	#0,d2
	movew	a1@+,d2
	movel	d2,d4
	asll	#2,d4
	bras	2f
1:	subqw	#4,d4
	movel	a0@(4,d4:l),d0
	beqs	2f
	moveal	d0,a3
	tstw	a3@(2)
	bnes	2f
	bset	#1,a3@(2)
	movel	a3,a2@+
2:	dbf	d2,1b
	moveq	#0,d2
	moveq	#0,d4
	movew	a1@+,d4
	moveal	a0,a3
	braw	_loopout
_loopo:	moveal	a3,a0
	addal	a1@+,a0
	movel	a1@+,d5
	movew	a1@+,d0
_loopi:	bsrs	_f670
	dbf	d5,_loopi
_loopout:dbf	d4,_loopo
	moveal	a3,a0
	addal	d3,a1
	moveml	sp@+,d1-d5/a1/a3
	rts

/* -84 @0x6d0 : free buffer d0 */
_f6d0:
	moveml	d1-a6,sp@-
	subql	#8,d0
	moveal	d0,a1
	movel	a1@,d0
	moveal	0x4,a6
	jsr	a6@(-210)		/* FreeMem */
	moveml	sp@+,d1-a6
	rts

/* -96 @0x6e8 : write array file (a5 = ctx, a5+696 = DosBase) */
_f6e8:
	linkw	a4,#-48
	moveml	d2-d5/a0-a2/a5,a4@(-36)
	bsrw	_f5f8
	beqw	_e00
	moveal	d0,a2
	movel	d0,d5
	movel	#1006,d2		/* MODE_NEWFILE */
	moveal	a5@(696),a5
	jsr	a5@(-30)		/* dos Open */
	movel	d0,d4
	beqw	_e94
	lea	a4@(-48),a0
	movel	a2@(-4),a0@(4)
	movel	#0x456c5374,a0@		/* 'ElSt' */
	movel	#0,a0@(8)
	movel	d4,d1
	movel	a0,d2
	moveq	#12,d3
	moveml	a0-a2,sp@-
	jsr	a5@(-48)		/* dos Write */
	moveml	sp@+,a0-a2
		.short	0xb0bc			/* cmpl #12,d0 */
	.long	12
	bnes	5f
1:	movel	a2@+,d2
	beqs	4f
	moveal	d2,a1
	movel	d2,a0@
	movel	a0,d2
	moveq	#4,d3
	movel	d4,d1
	moveml	a0-a2,sp@-
	jsr	a5@(-48)		/* Write */
	moveml	sp@+,a0-a2
		.short	0xb0bc			/* cmpl #4,d0 */
	.long	4
	bnes	5f
	moveq	#0,d0
	movew	a1@,d0
	moveq	#0,d1
	bsrw	_f1d8
	movel	a1,d2
	moveal	d0,a1
	movel	a1@,d3
	movel	d4,d1
	moveml	a0-a2,sp@-
	jsr	a5@(-48)		/* Write */
	moveml	sp@+,a0-a2
	cmpl	a1@,d0
	bnes	5f
	bras	1b
4:	movel	d4,d1
	jsr	a5@(-36)		/* Close */
	movel	d5,d0
	bsrw	_f6d0
	moveml	a4@(-36),d2-d5/a0-a2/a5
	unlk	a4
	movew	#0,%ccr
	rts
5:	movel	d4,d1
	jsr	a5@(-36)		/* Close */
	unlk	a4
	moveq	#94,d0
	movew	#4,%ccr
	rts

/* -90 @0x7b4 : read array file */
_f7b4:
	linkw	a4,#-60
	moveml	d1-a3,a4@(-48)
	movel	d0,d1
	movel	#1005,d2		/* MODE_OLDFILE */
	moveal	a5@(696),a3
	jsr	a3@(-30)		/* dos Open */
	beqw	_e94
	movel	d0,d5
	lea	a4@(-60),a0
	movel	a0,d2
	movel	d5,d1
	moveq	#12,d3
	moveml	a0-a2,sp@-
	jsr	a3@(-42)		/* dos Read */
	moveml	sp@+,a0-a2
		.short	0xb0bc			/* cmpl #12,d0 */
	.long	12
	bnew	_eshort
	movel	a0@+,d0
		.short	0xb0bc			/* cmpl #0x456c5374,d0 */
	.long	0x456c5374		/* 'ElSt' */
	bnew	_e98
	movel	a0@,d0
	movel	d0,d4
	addqw	#1,d0
	asll	#2,d0
	movel	d0,d2
	asll	#1,d0
	movel	#65536,d1
	moveml	d2-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-198)		/* AllocMem */
	moveml	sp@+,d2-a6
	tstl	d0
	beqw	_ealloc
	moveal	d0,a1
	moveal	d0,a2
	addal	d2,a2
	movel	a1,d6
	movel	a2,d7
	subqw	#1,d4
1:	movel	d5,d1
	lea	a4@(-60),a0
	movel	a0,d2
	moveq	#8,d3
	moveml	a0-a2,sp@-
	jsr	a3@(-42)		/* Read */
	moveml	sp@+,a0-a2
		.short	0xb0bc			/* cmpl #8,d0 */
	.long	8
	bnew	_eshort
	movel	a0@+,a2@+
	moveq	#0,d0
	movew	a0@,d0
	moveq	#0,d1
	bsrw	_f25a
	beqw	_ealloc
	movel	d0,a1@+
	movel	d1,d3
	subqw	#4,d3
	movel	d0,d2
	addqw	#4,d2
	movel	d5,d1
	moveml	a0-a2,sp@-
	jsr	a3@(-42)		/* Read */
	moveml	sp@+,a0-a2
	cmpl	d3,d0
	bnew	_eshort
	dbf	d4,1b
	movel	d5,d1
	moveml	a0-a2,sp@-
	jsr	a3@(-36)		/* Close */
	moveml	sp@+,a0-a2
	movel	d6,d0
	movel	d7,d1
	bsrw	_f8e4
	beqw	_e00
	moveal	d6,a1
	movel	a1@,d1
	subl	d6,d7
	asll	#1,d7
	movel	d7,d0
	moveml	d1-a6,sp@-
	moveal	0x4,a6
	jsr	a6@(-210)		/* FreeMem */
	moveml	sp@+,d1-a6
	movel	d1,d0
	moveml	a4@(-48),d1-a3
	unlk	a4
	movew	#0,%ccr
	rts
_ealloc:
	movel	d5,d1
	jsr	a3@(-36)
	braw	_e24a
_eshort:
	movel	d5,d1
	jsr	a3@(-36)
	unlk	a4
	moveq	#94,d0
	movew	#4,%ccr
	rts

/* -102 @0x8e4 : resolve reloc'd ptrs (d0=base, d1=count) */
_f8e4:
	linkw	a4,#-16
	moveml	d5-d6/a0,a4@(-16)
	movel	d0,d6
	movel	d1,d5
	moveal	d0,a3
1:	movel	a3@+,d0
	beqs	2f
	moveal	d0,a0
	bsrw	_f90e
	bras	1b
2:	moveml	a4@(-16),d5-d6/a0
	unlk	a4
	movew	#0,%ccr
	rts

/* helper @0x90e */
_f90e:
	moveml	d0-d4/d7/a1-a2,sp@-
	moveq	#0,d0
	movew	a0@,d0
	moveq	#0,d1
	bsrw	_f1d8
	beqw	_e00
	moveal	d0,a2
	moveq	#0,d2
	movel	a2@+,d3
	movew	a2@+,d2
	movel	d2,d4
	asll	#2,d4
	bras	3f
1:	subqw	#4,d4
	movel	a0@(4,d4:l),d0
	beqs	3f
	moveal	d5,a1
2:	movel	a1@+,d1
	beqw	3f
	cmpl	d1,d0
	bnes	2b
	subal	d5,a1
	addal	d6,a1
	movel	a1@-,d1
	movel	d1,a0@(4,d4:l)
3:	dbf	d2,1b
	moveq	#0,d0
	moveq	#0,d4
	movew	a2@+,d4
	moveal	a0,a1
	braw	5f
4:	moveal	a1,a0
	addal	a2@+,a0
	movel	a2@+,d7
	movew	a2@+,d2
_loopj:	movew	d2,a0@
	bsrs	_f90e
	dbf	d7,_loopj
5:	dbf	d4,4b
	moveal	a1,a0
	addal	d3,a0
	moveml	sp@+,d0-d4/d7/a1-a2
	rts

/* -108 @0x97a : free array table */
_f97a:
	linkw	a4,#-12
	moveml	d2/a2,a4@(-12)
	bsrw	_f5f8
	beqw	_e00
	moveal	d0,a2
	movel	d0,d2
1:	movel	a2@+,d0
	beqs	2f
	bsrw	_f166
	bras	1b
2:	movel	d2,d0
	bsrw	_f6d0
	moveml	a4@(-12),d2/a2
	unlk	a4
	movew	#0,%ccr
	rts

/* error exits (unlk a4; movew #4,%ccr; rts) */
_e36:	moveq	#36,d0
_e00:	unlk	a4
	movew	#4,%ccr
	rts
_e24a:	unlk	a4
	moveq	#24,d0
	movew	#4,%ccr
	rts
_e23:	unlk	a4
	moveq	#23,d0
	movew	#4,%ccr
	rts
_e94:	unlk	a4
	moveq	#94,d0
	movew	#4,%ccr
	rts
_e30:	unlk	a4
	moveq	#-30,d0
	movew	#4,%ccr
	rts
_e31:	unlk	a4
	moveq	#-31,d0
	movew	#4,%ccr
	rts
_e32:	unlk	a4
	moveq	#-32,d0
	movew	#4,%ccr
	rts
_e33:	unlk	a4
	moveq	#-33,d0
	movew	#4,%ccr
	rts
_e34:	unlk	a4
	moveq	#-34,d0
	movew	#4,%ccr
	rts
_e36b:	unlk	a4
	moveq	#-36,d0
	movew	#4,%ccr
	rts
_e35:	unlk	a4
	moveq	#-35,d0
	movew	#4,%ccr
	rts
_e98:	unlk	a4
	moveq	#98,d0
	movew	#4,%ccr
	rts
