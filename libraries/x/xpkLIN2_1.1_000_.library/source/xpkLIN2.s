	.file	"xpkLIN2_000.s"
	.text
	.globl	_start
_start:
	moveq	#0,%d0
	rts
_romtag:
	.word	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	0			/* rt_EndSkip = 0 (sic) */
	.byte	0x80,1,9,0		/* AUTOINIT, v1, NT_LIBRARY, pri 0 */
	.long	_libname
	.long	_idstr
	.long	_inittab
_libname:
	.ascii	"xpkLIN2.library"
	.byte	0
_idstr:
	.ascii	"$VER: xpkLIN2 V1.1 (1 Oct 2013) by Gerhard Tuenkler"
	.byte	13,10,0
_inittab:
	.long	0x26			/* dataSize */
	.long	_functab
	.long	_datatab
	.long	_LibInit
_datatab:
	.word	0xa008			/* byte @0x08 = ln_Type */
	.byte	9,0
	.word	0x800a			/* long @0x0a = ln_Name */
	.long	_libname
	.word	0xa00e			/* byte @0x0e = lib_Flags */
	.byte	6,0
	.word	0x9014			/* word @0x14 = version */
	.short	1
	.word	0x9016			/* word @0x16 = revision */
	.short	1
	.word	0x8018			/* long @0x18 = idstring */
	.long	_idstr
	.short	0,0
_functab:
	.short	-1			/* word-offset functab marker */
	.short	_LibOpen-_functab	/* -6   -> 0xb4 */
	.short	_LibClose-_functab	/* -12  -> 0xc2 */
	.short	_LibExpunge-_functab	/* -18  -> 0xd4 */
	.short	_start-_functab		/* -24  -> 0x00 (null: ExtFunc) */
	.short	_XpksPackerInfo-_functab	/* -30 -> 0x132 */
	.short	_XpksPackChunk-_functab	/* -36 -> 0x13a */
	.short	_XpkSubFree-_functab	/* -42  -> 0x112 (XpksPackFree) */
	.short	_start-_functab		/* -48  -> 0x00 (null: XpksPackReset) */
	.short	_XpksUnpackChunk-_functab	/* -54 -> 0x75c */
	.short	_XpkSubFree-_functab	/* -60  -> 0x112 (XpksUnpackFree) */
	.short	-1
_LibInit:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)
	rts	
_LibOpen:
	addqw	#1,%a6@(32)
	bclrb	#3,%a6@(14)
	movel	%a6,%d0
	rts	
_LibClose:
	subqw	#1,%a6@(32)
	bne	_start
	btstb	#3,%a6@(14)
	beq	_start
_LibExpunge:
	tstw	%a6@(32)
	beqs	_DoExpunge
	bsetb	#3,%a6@(14)
	braw	_start
_DoExpunge:
	moveml	%d2/%a5-%a6,%sp@-
	movel	%a6@(34),%d2
	moveal	%a6,%a5
	moveal	%a5,%a1
	moveal	4:w,%a6
	jsr	%a6@(-252)
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0
	subal	%d0,%a1
	addw	%a5@(18),%d0
	jsr	%a6@(-210)
	movel	%d2,%d0
	moveml	%sp@+,%d2/%a5-%a6
	rts	
_XpkSubFree:
	tstl	%a0@(52)
	beqs	L_130
	movel	%a0@(56),%d0
	moveal	%a0@(52),%a1
	clrl	%a0@(52)
	movel	%a6,%sp@-
	moveal	4:w,%a6
	jsr	%a6@(-210)
	moveal	%sp@+,%a6
L_130:
	rts	
_XpksPackerInfo:
	.short	0x41fa	/* lea.l $aa0(pc), a0 */
	.short	0x096c	/*  */
	movel	%a0,%d0
	rts	
_XpksPackChunk:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	subaw	#12,%a7
	movel	%a0,%a7@(8)
	tstl	%a0@(52)
	bne	L_1b6
	clrl	%a0@(64)
	moveal	%a0@(32),%a1
	tstb	%a1@
	beqs	L_162
	.short	0x6100	/* bsr.w $a74 */
	.short	0x0918	/*  */
	movel	%d0,%a0@(64)
L_162:
	movel	%a0@(28),%d2
	cmpib	#34,%d2
	bges	L_176
	movel	#18688,%d0
	moveq	#5,%d1
	bras	L_18e
L_176:
	cmpib	#67,%d2
	bges	L_186
	movel	#35072,%d0
	moveq	#6,%d1
	bras	L_18e
L_186:
	movel	#67840,%d0
	moveq	#7,%d1
L_18e:
	movel	%d0,%a0@(56)
	moveb	%d1,%a0@(63)
	moveq	#0,%d1
	movel	%a0,%sp@-
	moveal	4:w,%a6
	jsr	%a6@(-198)
	moveal	%sp@+,%a0
	movel	%d0,%a0@(52)
	bnes	L_1b6
	moveq	#-7,%d0
L_1ac:
	addaw	#12,%a7
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts	
L_1b6:
	moveal	%a7@(8),%a0
	movel	%a0@(56),%d0
	moveal	%a0@(52),%a0
	movel	%d3,%sp@-
	addal	%d0,%a0
	lsrl	#8,%d0
	subql	#1,%d0
	moveq	#0,%d1
	moveq	#0,%d2
	moveq	#0,%d3
	moveq	#0,%d4
	moveq	#0,%d5
	moveq	#0,%d6
	moveq	#0,%d7
	moveal	%d1,%a1
	moveal	%d1,%a2
	moveal	%d1,%a3
	moveal	%d1,%a4
	moveal	%d1,%a5
	moveal	%d1,%a6
L_1e4:
	moveml	%d1-%d7/%a1-%a6,%a0@-
	moveml	%d1-%d7/%a1-%a6,%a0@-
	moveml	%d1-%d7/%a1-%a6,%a0@-
	moveml	%d1-%d7/%a1-%a6,%a0@-
	moveml	%d1-%d7/%a1-%a5,%a0@-
	dbf	%d0,L_1e4
	movel	%sp@+,%d3
	moveal	%a7@(8),%a0
	moveal	%a0@(8),%a3
	addaw	#10,%a3
	moveal	%a0@(52),%a5
	movel	%a5,%d7
	addil	#1056,%d7
	.short	0x2468	/* movea.l $0(a0), a2 */
	.short	0x0000	/*  */
	movel	%a2,%d0
	addl	%a0@(4),%d0
	movel	%d0,%sp@
	moveal	%a0@(8),%a4
	addal	%a0@(4),%a4
	movel	%a4,%a7@(4)
	moveb	%a0@(63),%d1
	swap	%d1
	moveal	%a5,%a0
	lea	%a0@(18),%a1
	clrw	%a0@
	clrb	%a1@+
	moveq	#1,%d5
L_240:
	movew	%a0@+,%d0
	addw	%d0,%d0
	addqw	#2,%d0
	movew	%d0,%a0@
	moveb	%d5,%a1@+
	addqb	#1,%d5
	cmpib	#8,%d5
	blss	L_240
	movew	#32,%d1
	clrl	%a3@
	lea	%a5@(16),%a5
	moveq	#0,%d3
	bras	L_28e
L_260:
	movew	%a2,%a6@
L_262:
	swap	%d1
	moveq	#0,%d0
	subqw	#1,%d1
	bgts	L_272
	addiw	#32,%d1
	addql	#4,%a3
	movel	%d0,%a3@
L_272:
	moveb	%a2@+,%d0
	moveb	%d0,%a4@-
	addw	%d0,%d0
	addw	%d0,%d0
	addql	#1,%a5@(16,%d0:w)
	cmpal	%a4,%a3
	blts	L_288
	moveq	#-17,%d0
	braw	L_1ac
L_288:
	cmpal	%sp@,%a2
	bcc	L_51e
L_28e:
	swap	%d1
	moveal	%a2,%a0
	moveb	%a0@+,%d3
	moveb	%a0@+,%d4
	moveb	%a0@+,%d5
	movel	%d3,%d0
	asl.b	#3,%d0
	addb	%d4,%d0
	addb	%d5,%d0
	addqb	#1,%d0
	aslw	%d1,%d0
	eorb	%d3,%d0
	eorb	%d4,%d0
	addl	%d0,%d0
	moveal	%d7,%a6
	addal	%d0,%a6
	movew	%a6@,%d6
	beqs	L_260
	movel	%a2,%d0
	movew	%d6,%d0
	cmpw	%a2,%d0
	bcss	L_2c0
	swap	%d0
	subqw	#1,%d0
	swap	%d0
L_2c0:
	movew	%a2,%a6@
	movel	%a2,%d2
	subl	%d0,%d2
	cmpil	#32636,%d2
	bges	L_262
	moveal	%d0,%a1
	cmpb	%a1@+,%d3
	bnes	L_316
	cmpb	%a1@+,%d4
	bnes	L_316
	cmpb	%a1@+,%d5
	bnes	L_316
	moveq	#0,%d6
	cmpmb	%a1@+,%a0@+
	bnes	L_346
	cmpmb	%a1@+,%a0@+
	bnes	L_344
	moveq	#2,%d6
L_2e8:
	cmpmb	%a1@+,%a0@+
	bne	L_3ca
	cmpmb	%a1@+,%a0@+
	bnes	L_33e
	cmpmb	%a1@+,%a0@+
	bnes	L_338
	cmpmb	%a1@+,%a0@+
	bnes	L_332
	cmpmb	%a1@+,%a0@+
	bnes	L_32c
	cmpmb	%a1@+,%a0@+
	bnes	L_326
	cmpmb	%a1@+,%a0@+
	bnes	L_320
	cmpmb	%a1@+,%a0@+
	bnes	L_31a
	addqw	#8,%d6
	cmpib	#240,%d6
	bcss	L_2e8
	braw	L_3ca
L_316:
	moveq	#0,%d2
	bras	L_346
L_31a:
	addqw	#7,%d6
	braw	L_3ca
L_320:
	addqw	#6,%d6
	braw	L_3ca
L_326:
	addqw	#5,%d6
	braw	L_3ca
L_32c:
	addqw	#4,%d6
	braw	L_3ca
L_332:
	addqw	#3,%d6
	braw	L_3ca
L_338:
	addqw	#2,%d6
	braw	L_3ca
L_33e:
	addqw	#1,%d6
	braw	L_3ca
L_344:
	moveq	#1,%d6
L_346:
	moveq	#1,%d0
	addb	%a2@(3),%d0
	addb	%a2@(4),%d0
	addw	%d0,%d0
	addaw	%d0,%a6
	tstw	%a6@
	beqs	L_3c2
	movel	%a2,%d0
	movew	%a6@,%d0
	cmpw	%a2,%d0
	bcss	L_366
	swap	%d0
	subqw	#1,%d0
	swap	%d0
L_366:
	moveal	%d0,%a1
	moveal	%d0,%a0
	lea	%a0@(32636),%a0
	cmpal	%a2,%a0
	blss	L_3c2
	cmpb	%a1@+,%d3
	bnes	L_3c2
	cmpb	%a1@+,%d4
	bnes	L_3c2
	cmpb	%a1@+,%d5
	bnes	L_3c2
	lea	%a2@(3),%a0
	cmpmb	%a1@+,%a0@+
	bnes	L_3c2
	cmpmb	%a1@+,%a0@+
	bnes	L_3c2
	movew	%a2,%a6@
	movel	%a0,%d2
	subl	%a1,%d2
	moveq	#2,%d6
L_392:
	cmpmb	%a1@+,%a0@+
	bnes	L_3ca
	cmpmb	%a1@+,%a0@+
	bnes	L_33e
	cmpmb	%a1@+,%a0@+
	bnes	L_338
	cmpmb	%a1@+,%a0@+
	bnes	L_332
	cmpmb	%a1@+,%a0@+
	bnes	L_32c
	cmpmb	%a1@+,%a0@+
	bne	L_326
	cmpmb	%a1@+,%a0@+
	bne	L_320
	cmpmb	%a1@+,%a0@+
	bne	L_31a
	addqw	#8,%d6
	cmpib	#240,%d6
	bcss	L_392
	bras	L_3ca
L_3c2:
	movew	%a2,%a6@
	tstw	%d2
	beq	L_262
L_3ca:
	swap	%d1
	lea	%a2@(3,%d6:w),%a2
	moveq	#0,%d4
	tstb	%d6
	bnes	L_3de
	moveq	#2,%d6
	subqw	#2,%d1
	bgts	L_42a
	bras	L_41c
L_3de:
	cmpib	#4,%d6
	bccs	L_3ee
	addiw	#11,%d6
	subqw	#4,%d1
	bgts	L_42a
	bras	L_41c
L_3ee:
	cmpib	#11,%d6
	bccs	L_3fe
	addiw	#116,%d6
	subqw	#7,%d1
	bgts	L_42a
	bras	L_41c
L_3fe:
	cmpib	#26,%d6
	bccs	L_410
	addiw	#2021,%d6
	subiw	#11,%d1
	bgts	L_42a
	bras	L_41c
L_410:
	addil	#524032,%d6
	subiw	#19,%d1
	bgts	L_42a
L_41c:
	moveq	#32,%d0
	addw	%d0,%d1
	subw	%d1,%d0
	movel	%d6,%d5
	lsrl	%d0,%d5
	addl	%d5,%a3@+
	movel	%d4,%a3@
L_42a:
	movew	%d1,%d4
	asll	%d4,%d6
	addl	%d6,%a3@
L_430:
	cmpw	%a5@,%d2
	blts	L_486
	moveq	#0,%d0
	moveb	%a5@(10),%d0
	subw	%d0,%d1
	subqw	#3,%d1
	moveq	#7,%d6
	asll	%d0,%d6
	moveq	#0,%d0
	movew	%a5@,%d0
	addl	%d0,%d6
	movew	%a5@(-2),%d0
	subl	%d0,%d6
	subql	#1,%d6
	moveq	#0,%d4
	tstw	%d1
	bgts	L_464
	moveq	#32,%d0
	addw	%d0,%d1
	subw	%d1,%d0
	movel	%d6,%d5
	lsrl	%d0,%d5
	addl	%d5,%a3@+
	movel	%d4,%a3@
L_464:
	movew	%d1,%d4
	asll	%d4,%d6
	addl	%d6,%a3@
	moveq	#7,%d5
	lea	%a5@(2),%a5
	lea	%a5@(9),%a0
L_474:
	movew	%a5@-,%d0
	addw	%d0,%d0
	movew	%d0,%a5@
	addqb	#1,%a0@-
	dbf	%d5,L_474
	lea	%a5@(14),%a5
	bras	L_430
L_486:
	subqw	#1,%d2
	cmpw	%a5@(-8),%d2
	bcss	L_4c0
	cmpw	%a5@(-4),%d2
	bcss	L_4aa
	cmpw	%a5@(-2),%d2
	bcss	L_4a2
	moveq	#7,%d6
	subw	%a5@(-2),%d2
	bras	L_4f0
L_4a2:
	moveq	#6,%d6
	subw	%a5@(-4),%d2
	bras	L_4f0
L_4aa:
	cmpw	%a5@(-6),%d2
	bcss	L_4b8
	moveq	#5,%d6
	subw	%a5@(-6),%d2
	bras	L_4f0
L_4b8:
	moveq	#4,%d6
	subw	%a5@(-8),%d2
	bras	L_4f0
L_4c0:
	cmpw	%a5@(-12),%d2
	bcss	L_4dc
	cmpw	%a5@(-10),%d2
	bcss	L_4d4
	moveq	#3,%d6
	subw	%a5@(-10),%d2
	bras	L_4f0
L_4d4:
	moveq	#2,%d6
	subw	%a5@(-12),%d2
	bras	L_4f0
L_4dc:
	cmpw	%a5@(-14),%d2
	bcss	L_4ea
	moveq	#1,%d6
	subw	%a5@(-14),%d2
	bras	L_4f0
L_4ea:
	moveq	#0,%d6
	subw	%a5@(-16),%d2
L_4f0:
	moveq	#0,%d0
	moveb	%a5@(3,%d6:w),%d0
	asll	%d0,%d6
	addl	%d2,%d6
	subw	%d0,%d1
	subqw	#3,%d1
	moveq	#0,%d4
	tstw	%d1
	bgts	L_512
	moveq	#32,%d0
	addw	%d0,%d1
	subw	%d1,%d0
	movel	%d6,%d5
	lsrl	%d0,%d5
	addl	%d5,%a3@+
	movel	%d4,%a3@
L_512:
	movew	%d1,%d4
	asll	%d4,%d6
	addl	%d6,%a3@
	cmpal	%sp@,%a2
	bcs	L_28e
L_51e:
	movel	#524287,%d6
	subiw	#19,%d1
	bgts	L_53a
	moveq	#32,%d0
	addw	%d0,%d1
	subw	%d1,%d0
	movel	%d6,%d5
	lsrl	%d0,%d5
	addl	%d5,%a3@+
	moveq	#0,%d0
	movel	%d0,%a3@
L_53a:
	moveq	#0,%d0
	movew	%d1,%d0
	asll	%d0,%d6
	addl	%d6,%a3@
	addql	#4,%a3
	movel	%a2,%sp@-
	lea	%a5@(16),%a5
	moveal	%d7,%a6
	movew	#255,%d6
L_550:
	moveb	%d6,%a6@(0,%d6:w)
	dbf	%d6,L_550
	moveq	#0,%d0
	moveq	#0,%d3
	movew	#255,%d4
	lea	L_566:l,%a1
L_566:
	cmpw	%d3,%d4
	ble	L_608
	movew	%d4,%d0
	addw	%d0,%d0
	addw	%d0,%d0
	movel	%a5@(0,%d0:w),%d2
	movew	%d3,%d6
	subqw	#1,%d6
	movew	%d4,%d7
L_57c:
	moveal	%a5,%a0
	movew	%d6,%d0
	addqw	#1,%d0
	addw	%d0,%d0
	addw	%d0,%d0
	addaw	%d0,%a0
L_588:
	addqw	#1,%d6
	cmpl	%a0@+,%d2
	bgts	L_588
	moveal	%a5,%a0
	movew	%d7,%d0
	addw	%d0,%d0
	addw	%d0,%d0
	addaw	%d0,%a0
L_598:
	subqw	#1,%d7
	cmpl	%a0@-,%d2
	blts	L_598
	movew	%d6,%d1
	addw	%d1,%d1
	addw	%d1,%d1
	moveal	%a5@(0,%d1:w),%a2
	movew	%d7,%d0
	addw	%d0,%d0
	addw	%d0,%d0
	movel	%a5@(0,%d0:w),%a5@(0,%d1:w)
	movel	%a2,%a5@(0,%d0:w)
	moveb	%a6@(0,%d6:w),%d5
	moveb	%a6@(0,%d7:w),%a6@(0,%d6:w)
	moveb	%d5,%a6@(0,%d7:w)
	cmpw	%d6,%d7
	bgts	L_57c
	movel	%a5@(0,%d1:w),%a5@(0,%d0:w)
	movew	%d4,%d0
	addw	%d0,%d0
	addw	%d0,%d0
	movel	%a5@(0,%d0:w),%a5@(0,%d1:w)
	movel	%a2,%a5@(0,%d0:w)
	moveb	%a6@(0,%d6:w),%a6@(0,%d7:w)
	moveb	%a6@(0,%d4:w),%a6@(0,%d6:w)
	moveb	%d5,%a6@(0,%d4:w)
	cmpiw	#239,%d6
	blts	L_5fa
	movew	%d6,%d4
	subqw	#1,%d4
L_5fa:
	cmpiw	#239,%d6
	bgt	L_566
	movew	%d6,%d3
	addqw	#1,%d3
	jmp	%a1@
L_608:
	movew	#255,%d0
	movew	%d0,%d6
L_60e:
	moveb	%d0,%a5@(0,%d6:w)
	dbf	%d6,L_60e
	moveq	#0,%d0
	movew	#255,%d6
	moveq	#0,%d1
	lea	%a5@(256),%a0
L_622:
	moveb	%a6@(0,%d6:w),%d0
	moveb	%d0,%a0@+
	moveb	%d1,%a5@(0,%d0:w)
	addqw	#1,%d1
	subqw	#1,%d6
	cmpiw	#240,%d6
	bges	L_622
	moveq	#1,%d7
	movew	#256,%d3
	moveq	#0,%d4
	moveb	%d4,%a6@
L_640:
	moveq	#0,%d6
	lsrw	#1,%d3
	addw	%d3,%d4
L_646:
	movew	%d4,%d0
	movew	%d7,%d1
	subw	%d6,%d1
	subb	%a6@(-1,%d1:w),%d0
	movew	%d7,%d1
	addw	%d6,%d1
	moveb	%d0,%a6@(0,%d1:w)
	addqw	#1,%d6
	cmpw	%d7,%d6
	blts	L_646
	addb	%d7,%d7
	bccs	L_640
	moveal	%a7@(8),%a1
	movel	%a1,%d0
	subl	%a4,%d0
	lsrl	#3,%d0
	addql	#4,%d0
	addal	%d0,%a3
	cmpal	%a4,%a3
	blts	L_67c
	addql	#4,%a7
	moveq	#-17,%d0
	braw	L_1ac
L_67c:
	moveal	%a3,%a2
	movew	#240,%d1
	movew	#255,%d2
	moveq	#0,%d3
	moveq	#7,%d4
	moveq	#0,%d5
	moveq	#0,%d6
	moveq	#0,%d7
	lea	L_6ca:l,%a0
L_696:
	moveb	%a4@+,%d3
	moveb	%a5@(0,%d3:w),%d6
	addw	%d5,%d5
	cmpb	%d2,%d6
	bnes	L_6ba
	addqw	#1,%d5
	tstb	%d7
	beqs	L_6b6
	movew	%d1,%d0
	andb	%d3,%d0
	addb	%d0,%a3@+
	moveq	#15,%d0
	andb	%d3,%d0
	moveb	%d0,%a3@
	jmp	%a0@
L_6b6:
	moveb	%d3,%a3@+
	jmp	%a0@
L_6ba:
	tstb	%d7
	beqs	L_6c6
	aslw	#4,%d6
	addb	%d6,%a3@+
	moveq	#0,%d7
	jmp	%a0@
L_6c6:
	moveb	%d6,%a3@
	moveq	#1,%d7
L_6ca:
	dbf	%d4,L_6d6
	.short	0x1536	/* move.b (a6, d5.w), -(a2) */
	.short	0x5000	/*  */
	moveq	#7,%d4
	moveq	#0,%d5
L_6d6:
	cmpal	%a1,%a4
	bcss	L_696
	cmpib	#7,%d4
	bges	L_6ea
	.short	0x1536	/* move.b (a6, d5.w), -(a2) */
	.short	0x5000	/*  */
	addqb	#1,%d4
	moveb	%d4,%a2@-
	bras	L_6ee
L_6ea:
	moveb	#0,%a2@-
L_6ee:
	tstb	%d7
	beqs	L_6f4
	addql	#1,%a3
L_6f4:
	moveq	#15,%d6
	lea	%a5@(256),%a0
L_6fa:
	.short	0x16d8	/* move.b (a0)+, (a3)+ */
	dbf	%d6,L_6fa
	moveq	#0,%d0
	moveb	%d0,%a3@+
	moveb	%d2,%a3@+
	moveb	%d0,%a3@+
	moveb	%d0,%a3@+
	moveb	%d0,%a3@+
	moveb	%d0,%a3@+
	moveal	%a7@(12),%a0
	movel	%a3,%d0
	moveal	%a0@(8),%a1
	subl	%a1,%d0
	andil	#-4,%d0
	movel	%d0,%a0@(16)
	movel	%a3,%d0
	moveal	%a1,%a3
	movel	%a0@(64),%a3@+
	subl	%a2,%d0
	movel	%d0,%a3@+
	moveal	%sp@+,%a2
	movel	%a2,%d0
	movel	%sp@,%d1
	cmpl	%d1,%d0
	blss	L_740
	subl	%d1,%d0
	moveb	%d0,%a3@+
	bras	L_744
L_740:
	moveb	#0,%a3@+
L_744:
	moveb	%d7,%a3@
	movel	%a0@(16),%d0
	cmpl	%a0@(4),%d0
	blts	L_756
	moveq	#-17,%d0
	braw	L_1ac
L_756:
	moveq	#0,%d0
	braw	L_1ac
_XpksUnpackChunk:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	movel	%a0,%sp@-
	moveq	#0,%d5
	moveq	#0,%d7
	.short	0x2468	/* movea.l $0(a0), a2 */
	.short	0x0000	/*  */
	moveal	%a2,%a1
	addaw	#9,%a1
	moveb	%a1@,%d7
	moveal	%a2,%a5
	addal	%a0@(4),%a5
L_778:
	cmpib	#255,%a5@-
	bnes	L_778
	subqw	#1,%a5
	subqw	#5,%a1
	movel	%a1@,%d0
	moveal	%a5,%a4
	subal	%d0,%a4
	addqw	#6,%a4
	tstl	%a0@(52)
	bnes	L_7c6
	clrl	%a0@(64)
	tstl	%a2@
	beqs	L_7aa
	.short	0x6100	/* bsr.w $a74 */
	.short	0x02da	/*  */
	cmpl	%a2@,%d0
	beqs	L_7aa
	moveq	#-32,%d0
L_7a2:
	addqw	#4,%a7
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts	
L_7aa:
	moveq	#32,%d0
	movel	%d0,%a0@(56)
	moveq	#0,%d1
	moveal	4:w,%a6
	jsr	%a6@(-198)
	moveal	%sp@,%a0
	movel	%d0,%a0@(52)
	bnes	L_7c6
	moveq	#-7,%d0
	bras	L_7a2
L_7c6:
	addaw	#10,%a2
	moveal	%a0@(8),%a3
	moveal	%a0@(52),%a0
	lea	%a0@(16),%a6
	lea	%a6@(2),%a1
	clrw	%a0@
	clrb	%a1@+
	moveq	#1,%d1
L_7e0:
	movew	%a0@+,%d0
	addw	%d0,%d0
	addqw	#2,%d0
	movew	%d0,%a0@
	moveb	%d1,%a1@+
	addqb	#1,%d1
	cmpib	#8,%d1
	blss	L_7e0
	subaw	#16,%a5
	moveal	%a5,%a1
	tstb	%d7
	beqs	L_7fe
	subql	#1,%a5
L_7fe:
	moveq	#7,%d4
	subb	%a4@+,%d4
	moveb	%a4@+,%d5
	moveq	#0,%d3
	moveq	#0,%d2
	moveq	#0,%d6
	bras	L_81c
L_80c:
	moveal	%a3,%a0
	subaw	%d2,%a0
	movew	%sp@+,%d0
L_812:
	.short	0x16d8	/* move.b (a0)+, (a3)+ */
	dbf	%d0,L_812
	.short	0x16d8	/* move.b (a0)+, (a3)+ */
	.short	0x16d8	/* move.b (a0)+, (a3)+ */
L_81c:
	dbf	%d3,L_826
	addiw	#16,%d3
	movew	%a2@+,%d6
L_826:
	addw	%d6,%d6
	bcc	L_a0e
	dbf	%d3,L_836
	addiw	#16,%d3
	movew	%a2@+,%d6
L_836:
	addw	%d6,%d6
	bcss	L_842
	movew	#0,%sp@-
	braw	L_97a
L_842:
	moveq	#0,%d2
	dbf	%d3,L_84e
	addiw	#16,%d3
	movew	%a2@+,%d6
L_84e:
	addw	%d6,%d6
	bcss	L_86a
	moveq	#1,%d2
	dbf	%d3,L_85e
	addiw	#16,%d3
	movew	%a2@+,%d6
L_85e:
	addw	%d6,%d6
	bcc	L_978
	moveq	#2,%d2
	braw	L_978
L_86a:
	dbf	%d3,L_874
	addiw	#16,%d3
	movew	%a2@+,%d6
L_874:
	moveq	#3,%d2
	addw	%d6,%d6
	bcc	L_978
	moveq	#10,%d2
	dbf	%d3,L_888
	addiw	#16,%d3
	movew	%a2@+,%d6
L_888:
	addw	%d6,%d6
	bcss	L_8b4
	subqw	#4,%d2
	dbf	%d3,L_898
	addiw	#16,%d3
	movew	%a2@+,%d6
L_898:
	addw	%d6,%d6
	bcss	L_89e
	subqw	#2,%d2
L_89e:
	dbf	%d3,L_8a8
	addiw	#16,%d3
	movew	%a2@+,%d6
L_8a8:
	addw	%d6,%d6
	bcc	L_978
	addqw	#1,%d2
	braw	L_978
L_8b4:
	dbf	%d3,L_8be
	addiw	#16,%d3
	movew	%a2@+,%d6
L_8be:
	addw	%d6,%d6
	bcss	L_8da
	subqw	#2,%d2
	dbf	%d3,L_8ce
	addiw	#16,%d3
	movew	%a2@+,%d6
L_8ce:
	addw	%d6,%d6
	bcc	L_978
	addqw	#1,%d2
	braw	L_978
L_8da:
	dbf	%d3,L_8e4
	addiw	#16,%d3
	movew	%a2@+,%d6
L_8e4:
	addw	%d6,%d6
	bcc	L_978
	tstw	%d3
	bgts	L_8f4
	addiw	#16,%d3
	movew	%a2@+,%d6
L_8f4:
	cmpiw	#4,%d3
	blts	L_90a
	moveq	#0,%d0
	movew	%d6,%d0
	asll	#4,%d0
	movew	%d0,%d6
	swap	%d0
	movew	%d0,%d2
	subqw	#4,%d3
	bras	L_928
L_90a:
	moveq	#0,%d0
	movew	%d6,%d0
	asll	#4,%d0
	swap	%d0
	movew	%d0,%d2
	moveq	#0,%d6
	movew	%a2@+,%d6
	moveq	#4,%d0
	subw	%d3,%d0
	asll	%d0,%d6
	swap	%d6
	addw	%d6,%d2
	swap	%d6
	addiw	#12,%d3
L_928:
	cmpiw	#15,%d2
	bccs	L_934
	addiw	#11,%d2
	bras	L_978
L_934:
	tstw	%d3
	bgts	L_93e
	addiw	#16,%d3
	movew	%a2@+,%d6
L_93e:
	cmpiw	#8,%d3
	blts	L_954
	moveq	#0,%d0
	movew	%d6,%d0
	asll	#8,%d0
	movew	%d0,%d6
	swap	%d0
	movew	%d0,%d2
	subqw	#8,%d3
	bras	L_970
L_954:
	moveq	#0,%d0
	movew	%d6,%d0
	asll	#8,%d0
	swap	%d0
	movew	%d0,%d2
	moveq	#0,%d6
	movew	%a2@+,%d6
	moveq	#8,%d0
	subw	%d3,%d0
	asll	%d0,%d6
	swap	%d6
	addw	%d6,%d2
	swap	%d6
	addqw	#8,%d3
L_970:
	cmpiw	#255,%d2
	beq	L_a4e
L_978:
	movew	%d2,%sp@-
L_97a:
	moveq	#0,%d2
	dbf	%d3,L_986
	addiw	#16,%d3
	movew	%a2@+,%d6
L_986:
	addw	%d6,%d6
	addxw	%d2,%d2
	dbf	%d3,L_994
	addiw	#16,%d3
	movew	%a2@+,%d6
L_994:
	addw	%d6,%d6
	addxw	%d2,%d2
	dbf	%d3,L_9a2
	addiw	#16,%d3
	movew	%a2@+,%d6
L_9a2:
	addw	%d6,%d6
	addxw	%d2,%d2
	movew	%d2,%sp@-
	moveq	#0,%d1
	moveb	%a6@(3,%d2:w),%d1
	tstw	%d3
	bgts	L_9b8
	addiw	#16,%d3
	movew	%a2@+,%d6
L_9b8:
	movew	%d6,%d2
	moveq	#16,%d0
	subb	%d1,%d0
	asrl	%d0,%d2
	cmpw	%d3,%d1
	bgts	L_9ce
	movew	%d6,%d0
	aslw	%d1,%d0
	movew	%d0,%d6
	subw	%d1,%d3
	bras	L_9de
L_9ce:
	moveq	#0,%d6
	movew	%a2@+,%d6
	subw	%d3,%d1
	asll	%d1,%d6
	swap	%d6
	addw	%d6,%d2
	swap	%d6
	addw	%d0,%d3
L_9de:
	movew	%sp@+,%d1
	addw	%d1,%d1
	movew	%a6@(-16,%d1:w),%d0
	addqw	#1,%d0
	addw	%d0,%d2
	cmpw	%a6@,%d2
	bne	L_80c
	moveq	#7,%d1
	lea	%a6@(2),%a6
	lea	%a6@(9),%a0
L_9fa:
	movew	%a6@-,%d0
	addw	%d0,%d0
	movew	%d0,%a6@
	addqb	#1,%a0@-
	dbf	%d1,L_9fa
	lea	%a6@(14),%a6
	braw	L_97a
L_a0e:
	addb	%d5,%d5
	bccs	L_a2a
	tstb	%d7
	beqs	L_a26
	moveq	#15,%d0
	andb	%a5@,%d0
	moveb	%a5@-,%d1
	andi.b	#240,%d1
	addb	%d1,%d0
	moveb	%d0,%a3@+
	bras	L_a42
L_a26:
	.short	0x16e5	/* move.b -(a5), (a3)+ */
	bras	L_a42
L_a2a:
	tstb	%d7
	beqs	L_a36
	moveq	#15,%d0
	andb	%a5@,%d0
	moveq	#0,%d7
	bras	L_a3e
L_a36:
	moveq	#0,%d0
	moveb	%a5@-,%d0
	asrw	#4,%d0
	moveq	#1,%d7
L_a3e:
	.short	0x16f1	/* move.b (a1, d0.w), (a3)+ */
	.short	0x0000	/*  */
L_a42:
	dbf	%d4,L_81c
	moveb	%a4@+,%d5
	moveq	#7,%d4
	braw	L_81c
L_a4e:
	moveal	%sp@,%a0
	movel	%a3,%d0
	subl	%a0@(8),%d0
	.short	0x2668	/* movea.l $0(a0), a3 */
	.short	0x0000	/*  */
	addqw	#8,%a3
	moveq	#0,%d1
	moveb	%a3@,%d1
	subl	%d1,%d0
	cmpl	%a0@(16),%d0
	beqs	L_a6e
	moveq	#-14,%d0
	braw	L_7a2
L_a6e:
	moveq	#0,%d0
	braw	L_7a2
_strhash:
	moveml	%d1-%d2/%a1,%sp@-
	moveal	%a0@(32),%a1
	moveq	#0,%d0
	moveq	#0,%d2
L_a80:
	tstb	%a1@
	beqs	L_a90
	asll	#4,%d0
	moveq	#0,%d1
	moveb	%a1@+,%d1
	orb	%d1,%d0
	addl	%d1,%d2
	bras	L_a80
L_a90:
	addl	%d2,%d0
	bnes	L_a9a
	movel	#16843009,%d0
L_a9a:
	moveml	%sp@+,%d1-%d2/%a1
	rts	
_xpkinfo:
	.short	1,1,2,0		/* xpkver,libver,masterver,modesver */
	.long	_sname
	.long	_slong
	.long	_sdesc
	.long	0x4c494e32		/* 'LIN2' */
	.long	0xa009			/* flags */
	.long	0x7fffffff		/* max packed chunk */
	.long	0			/* min packed chunk */
	.long	0x8000			/* def packed chunk */
	.long	_sPack
	.long	_sUnpack
	.long	_sPacked
	.long	_sUnpacked
	.short	100,0			/* def mode */
	.long	_modes
	.long	0,0,0,0,0,0		/* reserved */
_modes:
	.long	_mode2			/* xm_Next */
	.long	33			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0x4900			/* xm_PackMemory */
	.long	0x20			/* xm_UnpackMemory */
	.long	80			/* xm_PackSpeed */
	.long	179			/* xm_UnpackSpeed */
	.short	0x199			/* xm_Ratio = 409 */
	.short	0			/* xm_MaxPacked */
	.byte	109,105,110,105,109,97,108,0,0,0	/* "minimal" */
_mode2:
	.long	_mode3
	.long	66
	.long	1
	.long	0x8900
	.long	0x20
	.long	88
	.long	179
	.short	0x19d			/* xm_Ratio = 413 */
	.short	0
	.byte	110,111,114,109,97,108,0,0,0,0	/* "normal" */
_mode3:
	.long	0
	.long	100
	.long	1
	.long	0x10900
	.long	0x20
	.long	94
	.long	179
	.short	0x19f			/* xm_Ratio = 415 */
	.short	0
	.byte	109,97,120,105,109,97,108,0,0,0	/* "maximal" */
_sname:
	.ascii	"LINO2"
	.byte	0
_slong:
	.ascii	"Lino2 V1.1"
	.byte	0
_sdesc:
	.ascii	"Better version of Lino1"
	.byte	0
_sPack:
	.ascii	"Comressing"
	.byte	0
_sUnpack:
	.ascii	"Expanding"
	.byte	0
_sPacked:
	.ascii	"Compressed"
	.byte	0
_sUnpacked:
	.ascii	"Expanded"
	.byte	0
