	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x64,0x78,0x70
	.byte 0x6b,0x4c,0x49,0x4e,0x34,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20,0x78,0x70,0x6b,0x4c,0x49,0x4e,0x34,0x20,0x56,0x31,0x2e,0x31
	.byte 0x20,0x28,0x31,0x20,0x4f,0x63,0x74,0x20,0x32,0x30,0x31,0x33,0x29,0x20,0x62,0x79
	.byte 0x20,0x47,0x65,0x72,0x68,0x61,0x72,0x64,0x20,0x54,0x75,0x65,0x6e,0x6b,0x6c,0x65
	.byte 0x72,0x0d,0x0a,0x00,0x00,0x00,0x00,0x26,0x00,0x00,0x00,0x94,0x00,0x00,0x00,0x74
	.byte 0x00,0x00,0x00,0xac,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e,0xa0,0x0e
	.byte 0x06,0x00,0x90,0x14,0x00,0x01,0x90,0x16,0x00,0x01,0x80,0x18,0x00,0x00,0x00,0x2e
	.byte 0x00,0x00,0x00,0x00,0xff,0xff,0x00,0x20,0x00,0x2e,0x00,0x40,0xff,0x6c,0x00,0xbe
	.byte 0x00,0xc6,0x00,0x7e,0xff,0x6c,0x08,0x9e,0x00,0xa0,0xff,0xff
	moveal d0,a1
	movel a0,a1@(34)
	rts
	.byte 0x52,0x6e,0x00
Lb7:
	.byte 0x20	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	rts
	.byte 0x53,0x6e,0x00
Lc5:
	.byte 0x20	/* subqw #1,a6@(32) */
	.byte 0x66,0x00,0xff
Lc9:
	.byte 0x38	/* bnew 0x0 */
	btst #3,a6@(14)
	.short 0x6700,0xff2e	/* beqw 0x0 */
	tstw a6@(32)
	beqs Le4
	bset #3,a6@(14)
	.short 0x6000,0xff1e	/* braw 0x0 */
Le4:
	moveml d2/a5-a6,sp@-
	movel a6@(34),d2
	moveal a6,a5
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	moveal a5,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
	moveml sp@+,d2/a5-a6
	rts
	tstl a0@(52)
	beqs L132
	.short 0x203c,0x0001,0x873c	/* movel #100156,d0 */
	moveal a0@(52),a1
	clrl a0@(52)
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L132:
	rts
	tstl a0@(52)
	beqs L150
	.short 0x7020	/* moveq #32,d0 */
	moveal a0@(52),a1
	clrl a0@(52)
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L150:
	rts
	lea %pc@(Lcd4),a0
	movel a0,d0
	rts
	moveml d1-d7/a1-a6,sp@-
	.short 0x9efc,0x0034	/* subaw #52,sp */
	movel a0,sp@(4)
	tstl a0@(52)
	bnes L1de
	clrl a0@(64)
	moveal a0@(32),a1
	tstb a1@
	beqs L180
	bsrw Lc80
	movel d0,a0@(64)
L180:
	movel a0@(28),d2
	.short 0x0c02,0x0022	/* cmpib #34,d2 */
	bges L18e
	.short 0x7005	/* moveq #5,d0 */
	bras L19a
L18e:
	.short 0x0c02,0x0043	/* cmpib #67,d2 */
	bges L198
	.short 0x7014	/* moveq #20,d0 */
	bras L19a
L198:
	.short 0x7046	/* moveq #70,d0 */
L19a:
	movew d0,a0@(60)
	.short 0x317c,0x000c,0x003e	/* movew #12,a0@(62) */
	clrl a0@(56)
	clrl a0@(52)
	.short 0x203c,0x0001,0x873c	/* movel #100156,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a0
	movel d0,a0@(52)
	beqs L1d2
	.short 0x0680,0x0001,0x0738	/* addil #67384,d0 */
	movel d0,a0@(56)
	bras L1de
L1d2:
	.short 0x70f9	/* moveq #-7,d0 */
L1d4:
	.short 0xdefc,0x0034	/* addaw #52,sp */
	moveml sp@+,d1-d7/a1-a6
	rts
L1de:
	.short 0x203c,0x0000,0x0420	/* movel #1056,d0 */
	moveal sp@(4),a0
	moveal a0@(52),a0
	bsrw Lcac
	.short 0x203c,0x0000,0x8004	/* movel #32772,d0 */
	moveal sp@(4),a0
	moveal a0@(56),a0
	bsrw Lcac
	moveal sp@(4),a0
	moveal a0@(8),a3
	.short 0xd6fc,0x000a	/* addaw #10,a3 */
	movew a0@(60),sp@(48)
	movew a0@(62),sp@(50)
	moveal a0@(52),a5
	lea a5@(1088),a1
	movel a1,sp@(24)
	moveal a1,a6
	movel a1,d0
	.short 0x0680,0x0001,0x0108	/* addil #65800,d0 */
	movel d0,sp@(32)
	movel d0,sp@(28)
	.byte 0x2f,0x7c,0x00,0x01,0x01,0x08,0x00,0x14	/* movel #65800,sp@(20) */
	.short 0x203c,0x0000,0x7f78	/* movel #32632,d0 */
	cmpl a0@(4),d0
	bles L250
	movel a0@(4),d0
L250:
	movel d0,sp@(44)
	.short 0x2468,0x0000	/* moveal a0@(0),a2 */
	movel a2,d0
	addl a0@(4),d0
	movel d0,sp@
	movel a2,sp@(40)
	moveal a0@(8),a4
	addal a0@(4),a4
	movel a4,sp@(8)
	movel a4,sp@(12)
	movel a0@(56),d0
	movel d0,d5
	.short 0x0680,0x0000,0x8004	/* addil #32772,d0 */
	movel d0,sp@(36)
	moveal a5,a0
	lea a0@(18),a1
	clrw a0@
	clrb a1@+
	.short 0x7201	/* moveq #1,d1 */
L290:
	movew a0@+,d0
	addw d0,d0
	.short 0x5440	/* addqw #2,d0 */
	movew d0,a0@
	moveb d1,a1@+
	.short 0x5201	/* addqb #1,d1 */
	.short 0x0c01,0x0008	/* cmpib #8,d1 */
	blss L290
	lea a5@(16),a5
	movel a5,sp@(16)
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x3e3c,0x0020	/* movew #32,d7 */
	clrl a3@
	bras L316
L2b4:
	movel a5,d0
	beqs L2be
	clrw a4@
	movew a2,a5@
	bras L2c0
L2be:
	movew a2,a4@
L2c0:
	swap d7
	moveal sp@+,a3
	.short 0x7000	/* moveq #0,d0 */
	.short 0x5347	/* subqw #1,d7 */
	bgts L2d2
	.short 0x0647,0x0020	/* addiw #32,d7 */
	.short 0x588b	/* addql #4,a3 */
	movel d0,a3@
L2d2:
	moveb a2@+,d0
	moveal sp@(8),a0
	moveb d0,a0@-
	movel a0,sp@(8)
	addw d0,d0
	addw d0,d0
	moveal sp@(16),a0
	.short 0x52b0,0x0010	/* addql #1,a0@(10,d0:w) */
	clrw a6@+
	cmpal sp@(32),a6
	bcss L304
	clrw a6@
	movel a6,d0
	movel d0,sp@(28)
	moveal sp@(24),a6
	subl a6,d0
	movel d0,sp@(20)
L304:
	cmpal sp@(8),a3
	blts L310
	.short 0x70ef	/* moveq #-17,d0 */
	braw L1d4
L310:
	cmpal sp@,a2
	bccw L6b8
L316:
	movel a3,sp@-
	swap d7
L31a:
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	movel a2,d1
	subl sp@(48),d1
	moveal a2,a3
	moveb a3@+,d2
	moveb a3@+,d3
	moveb a3@+,d4
	.short 0x7c01	/* moveq #1,d6 */
	addb d4,d6
	addw d3,d6
	addw d2,d6
	addw d6,d6
	movel d2,d0
	aslb #3,d0
	addb d3,d0
	addb d4,d0
	.short 0x5200	/* addqb #1,d0 */
	aslw #6,d0
	eorb d2,d0
	eorb d3,d0
	moveal d5,a4
	addw d0,d0
	addaw d0,a4
	movew sp@(54),d7
	subal a5,a5
	clrw a6@
	moveal sp@(40),a0
L358:
	tstw a4@
	beqw L2b4
	movel a2,d0
	movew a4@,d0
	cmpl a2,d0
	bcss L36c
	swap d0
	.short 0x5340	/* subqw #1,d0 */
	swap d0
L36c:
	moveal d0,a1
	cmpb a1@+,d2
	bnes L390
	cmpb a1@+,d3
	bnes L390
	cmpb a1@+,d4
	bnes L390
	cmpl d1,d0
	bltw L2b4
	movel a3,d2
	subl a1,d2
	movew d2,a6@
	movel a5,d0
	beqs L3b8
	movew a2,a5@
	clrw a4@
	bras L3ba
L390:
	cmpl d1,d0
	bges L39c
	clrw a4@
	movel a5,d0
	bnes L39c
	moveal a4,a5
L39c:
	addaw d6,a4
	cmpal a0,a4
	bcss L3a8
	.short 0x99fc,0x0000,0x8004	/* subal #32772,a4 */
L3a8:
	.short 0x5347	/* subqw #1,d7 */
	bgts L358
	movel a5,d0
	beqw L2c0
	movew a2,a5@
	braw L2c0
L3b8:
	movew a2,a4@
L3ba:
	movel a2,sp@-
	.short 0x7600	/* moveq #0,d3 */
	moveal a6,a3
	.short 0x5681	/* addql #3,d1 */
	cmpl sp@(48),d1
	bccs L3cc
	movel sp@(48),d1
L3cc:
	.short 0x568a	/* addql #3,a2 */
	moveal a2,a5
	moveal a5,a0
	subaw a3@,a0
	movew sp@(56),d4
	movel sp@(32),d0
	movew a3@,d7
	blss L430
	subaw d7,a5
	cmpal d1,a5
	bcss L430
	subaw d7,a3
	subaw d7,a3
	cmpal d0,a3
	bccs L3f2
	addal sp@(28),a3
L3f2:
	moveal a2,a1
	moveal a5,a4
	cmpmb a1@+,a4@+
	bnes L42c
	.short 0x7401	/* moveq #1,d2 */
L3fc:
	cmpmb a1@+,a4@+
	bnes L424
	cmpmb a1@+,a4@+
	bnes L440
	cmpmb a1@+,a4@+
	bnes L448
	cmpmb a1@+,a4@+
	bnes L450
	cmpmb a1@+,a4@+
	bnes L458
	cmpmb a1@+,a4@+
	bnes L460
	cmpmb a1@+,a4@+
	bnes L468
	cmpmb a1@+,a4@+
	bnes L470
	.short 0x5042	/* addqw #8,d2 */
	.short 0x0c42,0x00f0	/* cmpiw #240,d2 */
	bcss L3fc
L424:
	cmpw d3,d2
	blss L42c
L428:
	movew d2,d3
	moveal a5,a0
L42c:
	.short 0x51cc,0xffae	/* dbf d4,0x3dc */
L430:
	movel d3,d1
	moveal sp@+,a2
	swap d7
	moveal sp@+,a3
	movel a2,d2
	subl a0,d2
	.short 0x5442	/* addqw #2,d2 */
	bras L478
L440:
	.short 0x5242	/* addqw #1,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L448:
	.short 0x5442	/* addqw #2,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L450:
	.short 0x5642	/* addqw #3,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L458:
	.short 0x5842	/* addqw #4,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L460:
	.short 0x5a42	/* addqw #5,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L468:
	.short 0x5c42	/* addqw #6,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L470:
	.short 0x5e42	/* addqw #7,d2 */
	cmpw d3,d2
	blss L42c
	bras L428
L478:
	.short 0x7800	/* moveq #0,d4 */
	.short 0x0c43,0x0003	/* cmpiw #3,d3 */
	bccs L488
	.short 0x5883	/* addql #4,d3 */
	.short 0x5747	/* subqw #3,d7 */
	bgts L4d4
	bras L4c6
L488:
	.short 0x0c43,0x0006	/* cmpiw #6,d3 */
	bccs L498
	.short 0x0643,0x0019	/* addiw #25,d3 */
	.short 0x5b47	/* subqw #5,d7 */
	bgts L4d4
	bras L4c6
L498:
	.short 0x0c43,0x000d	/* cmpiw #13,d3 */
	bccs L4a8
	.short 0x0643,0x00f2	/* addiw #242,d3 */
	.short 0x5147	/* subqw #8,d7 */
	bgts L4d4
	bras L4c6
L4a8:
	.short 0x0c43,0x001c	/* cmpiw #28,d3 */
	bccs L4ba
	.short 0x0643,0x0fe3	/* addiw #4067,d3 */
	.short 0x0447,0x000c	/* subiw #12,d7 */
	bgts L4d4
	bras L4c6
L4ba:
	.short 0x0683,0x000f,0xff00	/* addil #1048320,d3 */
	.short 0x0447,0x0014	/* subiw #20,d7 */
	bgts L4d4
L4c6:
	.short 0x7020	/* moveq #32,d0 */
	addw d0,d7
	subw d7,d0
	movel d3,d6
	lsrl d0,d6
	addl d6,a3@+
	movel d4,a3@
L4d4:
	movew d7,d4
	asll d4,d3
	addl d3,a3@
L4da:
	moveal sp@(16),a5
	movew d2,d0
	.short 0x5240	/* addqw #1,d0 */
	cmpw a5@,d0
	blts L538
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@(10),d0
	subw d0,d7
	.short 0x5747	/* subqw #3,d7 */
	.short 0x7607	/* moveq #7,d3 */
	asll d0,d3
	.short 0x7000	/* moveq #0,d0 */
	movew a5@,d0
	addl d0,d3
	movew a5@(-2),d0
	subl d0,d3
	.short 0x5383	/* subql #1,d3 */
	.short 0x7800	/* moveq #0,d4 */
	tstw d7
	bgts L516
	.short 0x7020	/* moveq #32,d0 */
	addw d0,d7
	subw d7,d0
	movel d3,d6
	lsrl d0,d6
	addl d6,a3@+
	movel d4,a3@
L516:
	movew d7,d4
	asll d4,d3
	addl d3,a3@
	.short 0x7c07	/* moveq #7,d6 */
	lea a5@(2),a5
	lea a5@(9),a0
	movew a5@-,d0
	addw d0,d0
	movew d0,a5@
	.short 0x5220	/* addqb #1,a0@- */
	.short 0x51ce,0xfff6	/* dbf d6,0x526 */
	lea a5@(14),a5
	bras L4da
L538:
	cmpw a5@(-8),d2
	bcss L570
	cmpw a5@(-4),d2
	bcss L55a
	cmpw a5@(-2),d2
	bcss L552
	.short 0x7607	/* moveq #7,d3 */
	subw a5@(-2),d2
	bras L5a0
L552:
	.short 0x7606	/* moveq #6,d3 */
	subw a5@(-4),d2
	bras L5a0
L55a:
	cmpw a5@(-6),d2
	bcss L568
	.short 0x7605	/* moveq #5,d3 */
	subw a5@(-6),d2
	bras L5a0
L568:
	.short 0x7604	/* moveq #4,d3 */
	subw a5@(-8),d2
	bras L5a0
L570:
	cmpw a5@(-12),d2
	bcss L58c
	cmpw a5@(-10),d2
	bcss L584
	.short 0x7603	/* moveq #3,d3 */
	subw a5@(-10),d2
	bras L5a0
L584:
	.short 0x7602	/* moveq #2,d3 */
	subw a5@(-12),d2
	bras L5a0
L58c:
	cmpw a5@(-14),d2
	bcss L59a
	.short 0x7601	/* moveq #1,d3 */
	subw a5@(-14),d2
	bras L5a0
L59a:
	.short 0x7600	/* moveq #0,d3 */
	subw a5@(-16),d2
L5a0:
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@(0x3,d3:w),d0
	subw d0,d7
	.short 0x5747	/* subqw #3,d7 */
	asll d0,d3
	extl d2
	addl d2,d3
	.short 0x7800	/* moveq #0,d4 */
	tstw d7
	bgts L5c4
	.short 0x7020	/* moveq #32,d0 */
	addw d0,d7
	subw d7,d0
	movel d3,d6
	lsrl d0,d6
	addl d6,a3@+
	movel d4,a3@
L5c4:
	movew d7,d4
	asll d4,d3
	addl d3,a3@
	.short 0x5241	/* addqw #1,d1 */
	movel a3,sp@-
	swap d7
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7800	/* moveq #0,d4 */
	.short 0x528a	/* addql #1,a2 */
	.short 0x548e	/* addql #2,a6 */
	moveal a2,a3
	moveb a3@+,d2
	moveb a3@+,d3
	moveb a3@+,d4
	.short 0x7c01	/* moveq #1,d6 */
	addw d2,d6
	addw d3,d6
	addw d4,d6
	addw d6,d6
	movel d2,d0
	aslb #3,d0
	addb d3,d0
	addb d4,d0
	.short 0x5200	/* addqb #1,d0 */
	aslw #6,d0
	eorb d2,d0
	eorb d3,d0
	moveal d5,a4
	addw d0,d0
	addaw d0,a4
	movew sp@(54),d7
	subal a5,a5
	clrw a6@
	moveal sp@(40),a0
L60e:
	tstw a4@
	bnes L626
	movel a5,d0
	beqs L61e
	movew a2,a5@
	.short 0x51c9,0xffbc	/* dbf d1,0x5d6 */
	bras L690
L61e:
	movew a2,a4@
	.short 0x51c9,0xffb4	/* dbf d1,0x5d6 */
	bras L690
L626:
	movel a2,d0
	movew a4@,d0
	cmpl a2,d0
	bcss L634
	swap d0
	.short 0x5340	/* subqw #1,d0 */
	swap d0
L634:
	moveal d0,a1
	cmpb a1@+,d2
	bnes L666
	cmpb a1@+,d3
	bnes L666
	cmpb a1@+,d4
	bnes L666
	addl sp@(48),d0
	cmpl a2,d0
	blts L650
	movel a3,d0
	subl a1,d0
	movew d0,a6@
L650:
	movel a5,d0
	beqs L65e
	movew a2,a5@
	clrw a4@
	.short 0x51c9,0xff7c	/* dbf d1,0x5d6 */
	bras L690
L65e:
	movew a2,a4@
	.short 0x51c9,0xff74	/* dbf d1,0x5d6 */
	bras L690
L666:
	addl sp@(48),d0
	cmpl a2,d0
	bges L676
	clrw a4@
	movel a5,d0
	bnes L676
	moveal a4,a5
L676:
	addaw d6,a4
	cmpal a0,a4
	bcss L682
	.short 0x99fc,0x0000,0x8004	/* subal #32772,a4 */
L682:
	.short 0x5347	/* subqw #1,d7 */
	bgts L60e
	movel a5,d0
	beqs L68c
	movew a2,a5@
L68c:
	.short 0x51c9,0xff48	/* dbf d1,0x5d6 */
L690:
	.short 0x528a	/* addql #1,a2 */
	.short 0x548e	/* addql #2,a6 */
	cmpal sp@(36),a6
	bcss L6ac
	clrw a6@
	movel a6,d0
	movel d0,sp@(32)
	moveal sp@(28),a6
	subl a6,d0
	movel d0,sp@(24)
L6ac:
	cmpal sp@(4),a2
	bcsw L31a
	swap d7
	moveal sp@+,a3
L6b8:
	.short 0x2c3c,0x000f,0xffff	/* movel #1048575,d6 */
	.short 0x0447,0x0014	/* subiw #20,d7 */
	bgts L6d4
	.short 0x7020	/* moveq #32,d0 */
	addw d0,d7
	subw d7,d0
	movel d6,d1
	lsrl d0,d1
	addl d1,a3@+
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a3@
L6d4:
	.short 0x7000	/* moveq #0,d0 */
	movew d7,d0
	asll d0,d6
	addl d6,a3@
	.short 0x588b	/* addql #4,a3 */
	moveal sp@(8),a4
	moveal sp@(16),a5
	lea a5@(16),a5
	lea a5@(1056),a6
	movel a2,sp@-
	.short 0x3c3c,0x00ff	/* movew #255,d6 */
	.short 0x1d86,0x6000	/* moveb d6,a6@(0,d6:w) */
	.short 0x51ce,0xfffa	/* dbf d6,0x6f4 */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x383c,0x00ff	/* movew #255,d4 */
	.short 0x43f9,0x0000,0x070a	/* lea 0x70a,a1 */
L70a:
	cmpw d3,d4
	blew L7ac
	movew d4,d0
	addw d0,d0
	addw d0,d0
	.short 0x2435,0x0000	/* movel a5@(0,d0:w),d2 */
	movew d3,d6
	.short 0x5346	/* subqw #1,d6 */
	movew d4,d7
L720:
	moveal a5,a0
	movew d6,d0
	.short 0x5240	/* addqw #1,d0 */
	addw d0,d0
	addw d0,d0
	addaw d0,a0
L72c:
	.short 0x5246	/* addqw #1,d6 */
	cmpl a0@+,d2
	bgts L72c
	moveal a5,a0
	movew d7,d0
	addw d0,d0
	addw d0,d0
	addaw d0,a0
L73c:
	.short 0x5347	/* subqw #1,d7 */
	cmpl a0@-,d2
	blts L73c
	movew d6,d1
	addw d1,d1
	addw d1,d1
	.short 0x2475,0x1000	/* moveal a5@(0,d1:w),a2 */
	movew d7,d0
	addw d0,d0
	addw d0,d0
	.short 0x2bb5,0x0000,0x1000	/* movel a5@(0,d0:w),a5@(0,d1:w) */
	.short 0x2b8a,0x0000	/* movel a2,a5@(0,d0:w) */
	.short 0x1a36,0x6000	/* moveb a6@(0,d6:w),d5 */
	.short 0x1db6,0x7000,0x6000	/* moveb a6@(0,d7:w),a6@(0,d6:w) */
	.short 0x1d85,0x7000	/* moveb d5,a6@(0,d7:w) */
	cmpw d6,d7
	bgts L720
	.short 0x2bb5,0x1000,0x0000	/* movel a5@(0,d1:w),a5@(0,d0:w) */
	movew d4,d0
	addw d0,d0
	addw d0,d0
	.short 0x2bb5,0x0000,0x1000	/* movel a5@(0,d0:w),a5@(0,d1:w) */
	.short 0x2b8a,0x0000	/* movel a2,a5@(0,d0:w) */
	.short 0x1db6,0x6000,0x7000	/* moveb a6@(0,d6:w),a6@(0,d7:w) */
	.short 0x1db6,0x4000,0x6000	/* moveb a6@(0,d4:w),a6@(0,d6:w) */
	.short 0x1d85,0x4000	/* moveb d5,a6@(0,d4:w) */
	.short 0x0c46,0x00df	/* cmpiw #223,d6 */
	blts L79e
	movew d6,d4
	.short 0x5344	/* subqw #1,d4 */
L79e:
	.short 0x0c46,0x00df	/* cmpiw #223,d6 */
	bgtw L70a
	movew d6,d3
	.short 0x5243	/* addqw #1,d3 */
	jmp a1@
L7ac:
	.short 0x303c,0x00ff	/* movew #255,d0 */
	movew d0,d6
	.short 0x1b80,0x6000	/* moveb d0,a5@(0,d6:w) */
	.short 0x51ce,0xfffa	/* dbf d6,0x7b2 */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x3c3c,0x00ff	/* movew #255,d6 */
	.short 0x7200	/* moveq #0,d1 */
	lea a5@(256),a0
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7e00	/* moveq #0,d7 */
L7ca:
	.short 0x1036,0x6000	/* moveb a6@(0,d6:w),d0 */
	moveb d0,a0@+
	.short 0x1b81,0x0000	/* moveb d1,a5@(0,d0:w) */
	.short 0x5241	/* addqw #1,d1 */
	movew d6,d7
	addw d7,d7
	addw d7,d7
	.short 0xd4b5,0x7000	/* addl a5@(0,d7:w),d2 */
	.short 0x5346	/* subqw #1,d6 */
	.short 0x0c46,0x00e0	/* cmpiw #224,d6 */
	bges L7ca
	.short 0x7e01	/* moveq #1,d7 */
	.short 0x363c,0x0100	/* movew #256,d3 */
	.short 0x7800	/* moveq #0,d4 */
	moveb d4,a6@
L7f2:
	.short 0x7c00	/* moveq #0,d6 */
	lsrw #1,d3
	addw d3,d4
L7f8:
	movew d4,d0
	movew d7,d1
	subw d6,d1
	subb a6@(0xffffffffffffffff,d1:w),d0
	movew d7,d1
	addw d6,d1
	.short 0x1d80,0x1000	/* moveb d0,a6@(0,d1:w) */
	.short 0x5246	/* addqw #1,d6 */
	cmpw d7,d6
	blts L7f8
	addb d7,d7
	bccs L7f2
	moveal sp@(16),a1
	movel a1,d0
	subl a4,d0
	lsrl #3,d0
	lsrl #3,d2
	addl d2,d0
	.short 0x5880	/* addql #4,d0 */
	addal d0,a3
	cmpal a4,a3
	blts L832
	.short 0x588f	/* addql #4,sp */
	.short 0x70ef	/* moveq #-17,d0 */
	braw L1d4
L832:
	moveal a3,a2
	.short 0x223c,0x0000,0x00f0	/* movel #240,d1 */
	.short 0x243c,0x0000,0x00ff	/* movel #255,d2 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7807	/* moveq #7,d4 */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x41f9,0x0000,0x08a0	/* lea 0x8a0,a0 */
L850:
	addw d5,d5
	moveb a4@+,d3
	.short 0x1c35,0x3000	/* moveb a5@(0,d3:w),d6 */
	cmpb d2,d6
	bnes L874
	.short 0x5245	/* addqw #1,d5 */
	tstb d7
	beqs L870
	movew d1,d0
	andb d3,d0
	addb d0,a3@+
	.short 0x700f	/* moveq #15,d0 */
	andb d3,d0
	moveb d0,a3@
	jmp a0@
L870:
	moveb d3,a3@+
	jmp a0@
L874:
	movew d6,d0
	.short 0x0240,0x0001	/* andiw #1,d0 */
	addw d0,d5
	.short 0x51cc,0x000a	/* dbf d4,0x888 */
	.short 0x1536,0x5000	/* moveb a6@(0,d5:w),a2@- */
	.short 0x7807	/* moveq #7,d4 */
	.short 0x7a00	/* moveq #0,d5 */
	addw d5,d5
	tstb d7
	beqs L89a
	movew d6,d0
	aslw #3,d0
	andb d1,d0
	addb d0,a3@+
	.short 0x7e00	/* moveq #0,d7 */
	jmp a0@
L89a:
	lsrb #1,d6
	moveb d6,a3@
	.short 0x7e01	/* moveq #1,d7 */
	.short 0x51cc,0x000a	/* dbf d4,0x8ac */
	.short 0x1536,0x5000	/* moveb a6@(0,d5:w),a2@- */
	.short 0x7807	/* moveq #7,d4 */
	.short 0x7a00	/* moveq #0,d5 */
	cmpal a1,a4
	bcss L850
	.short 0x0c04,0x0007	/* cmpib #7,d4 */
	bges L8c0
	.short 0x1536,0x5000	/* moveb a6@(0,d5:w),a2@- */
	.short 0x5204	/* addqb #1,d4 */
	moveb d4,a2@-
	bras L8c4
L8c0:
	.short 0x153c,0x0000	/* moveb #0,a2@- */
L8c4:
	tstb d7
	beqs L8ca
	.short 0x528b	/* addql #1,a3 */
L8ca:
	.short 0x7c1f	/* moveq #31,d6 */
	lea a5@(256),a0
	moveb a0@+,a3@+
	.short 0x51ce,0xfffc	/* dbf d6,0x8d0 */
	.short 0x7000	/* moveq #0,d0 */
	moveb d0,a3@+
	moveb d2,a3@+
	moveb d0,a3@+
	moveb d0,a3@+
	moveb d0,a3@+
	moveb d0,a3@+
	moveal sp@(8),a0
	movel a3,d0
	moveal a0@(8),a1
	subl a1,d0
	.short 0x0280,0xffff,0xfffc	/* andil #-4,d0 */
	movel d0,a0@(16)
	movel a3,d0
	moveal a1,a3
	movel a0@(64),a3@+
	subl a2,d0
	movel d0,a3@+
	moveal sp@+,a2
	movel a2,d0
	movel sp@,d1
	cmpl d1,d0
	blss L916
	subl d1,d0
	moveb d0,a3@+
	bras L91a
L916:
	.short 0x16fc,0x0000	/* moveb #0,a3@+ */
L91a:
	moveb d7,a3@
	movel a0@(16),d0
	cmpl a0@(4),d0
	blts L92c
	.short 0x70ef	/* moveq #-17,d0 */
	braw L1d4
L92c:
	.short 0x7000	/* moveq #0,d0 */
	braw L1d4
	moveml d2-d7/a2-a6,sp@-
	movel a0,sp@-
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x2468,0x0000	/* moveal a0@(0),a2 */
	moveal a2,a1
	.short 0xd2fc,0x0009	/* addaw #9,a1 */
	moveb a1@,d7
	moveal a2,a5
	addal a0@(4),a5
L94e:
	.short 0x0c25,0x00ff	/* cmpib #-1,a5@- */
	bnes L94e
	.short 0x534d	/* subqw #1,a5 */
	.short 0x5b49	/* subqw #5,a1 */
	movel a1@,d0
	moveal a5,a4
	subal d0,a4
	.short 0x5c4c	/* addqw #6,a4 */
	tstl a0@(52)
	bnes L994
	tstl a2@
	beqs L97c
	bsrw Lc80
	cmpl a2@,d0
	beqs L97c
	.short 0x70e0	/* moveq #-32,d0 */
L974:
	.short 0x584f	/* addqw #4,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
L97c:
	.short 0x7020	/* moveq #32,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@,a0
	movel d0,a0@(52)
	bnes L994
	.short 0x70f9	/* moveq #-7,d0 */
	bras L974
L994:
	.short 0xd4fc,0x000a	/* addaw #10,a2 */
	moveal a0@(8),a3
	moveal a0@(52),a0
	lea a0@(16),a6
	lea a6@(2),a1
	clrw a0@
	clrb a1@+
	.short 0x7201	/* moveq #1,d1 */
L9ae:
	movew a0@+,d0
	addw d0,d0
	.short 0x5440	/* addqw #2,d0 */
	movew d0,a0@
	moveb d1,a1@+
	.short 0x5201	/* addqb #1,d1 */
	.short 0x0c01,0x0008	/* cmpib #8,d1 */
	blss L9ae
	.short 0x9afc,0x0020	/* subaw #32,a5 */
	moveal a5,a1
	tstb d7
	beqs L9cc
	.short 0x538d	/* subql #1,a5 */
L9cc:
	.short 0x7807	/* moveq #7,d4 */
	subb a4@+,d4
	moveb a4@+,d5
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7c00	/* moveq #0,d6 */
	bras L9ea
L9da:
	moveal a3,a0
	subaw d2,a0
	movew sp@+,d0
	moveb a0@+,a3@+
	.short 0x51c8,0xfffc	/* dbf d0,0x9e0 */
	moveb a0@+,a3@+
	moveb a0@+,a3@+
L9ea:
	.short 0x51cb,0x0008	/* dbf d3,0x9f4 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lc00
	.short 0x7400	/* moveq #0,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa06 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bcss La22
	.short 0x7400	/* moveq #0,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa16 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lb6a
	.short 0x7401	/* moveq #1,d2 */
	braw Lb6a
La22:
	.short 0x51cb,0x0008	/* dbf d3,0xa2c */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	.short 0x7402	/* moveq #2,d2 */
	addw d6,d6
	bccw Lb6a
	.short 0x7402	/* moveq #2,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa40 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bcss La5c
	.short 0x7403	/* moveq #3,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa50 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lb6a
	.short 0x7404	/* moveq #4,d2 */
	braw Lb6a
La5c:
	.short 0x51cb,0x0008	/* dbf d3,0xa66 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	.short 0x7405	/* moveq #5,d2 */
	addw d6,d6
	bccw Lb6a
	.short 0x740c	/* moveq #12,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa7a */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bcss Laa6
	.short 0x5942	/* subqw #4,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xa8a */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bcss La90
	.short 0x5542	/* subqw #2,d2 */
La90:
	.short 0x51cb,0x0008	/* dbf d3,0xa9a */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lb6a
	.short 0x5242	/* addqw #1,d2 */
	braw Lb6a
Laa6:
	.short 0x51cb,0x0008	/* dbf d3,0xab0 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bcss Lacc
	.short 0x5542	/* subqw #2,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xac0 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lb6a
	.short 0x5242	/* addqw #1,d2 */
	braw Lb6a
Lacc:
	.short 0x51cb,0x0008	/* dbf d3,0xad6 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	bccw Lb6a
	tstw d3
	bgts Lae6
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
Lae6:
	.short 0x0c43,0x0004	/* cmpiw #4,d3 */
	blts Lafc
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	asll #4,d0
	movew d0,d6
	swap d0
	movew d0,d2
	.short 0x5943	/* subqw #4,d3 */
	bras Lb1a
Lafc:
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	asll #4,d0
	swap d0
	movew d0,d2
	.short 0x7c00	/* moveq #0,d6 */
	movew a2@+,d6
	.short 0x7004	/* moveq #4,d0 */
	subw d3,d0
	asll d0,d6
	swap d6
	addw d6,d2
	swap d6
	.short 0x0643,0x000c	/* addiw #12,d3 */
Lb1a:
	.short 0x0c42,0x000f	/* cmpiw #15,d2 */
	bccs Lb26
	.short 0x0642,0x000d	/* addiw #13,d2 */
	bras Lb6a
Lb26:
	tstw d3
	bgts Lb30
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
Lb30:
	.short 0x0c43,0x0008	/* cmpiw #8,d3 */
	blts Lb46
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	asll #8,d0
	movew d0,d6
	swap d0
	movew d0,d2
	.short 0x5143	/* subqw #8,d3 */
	bras Lb62
Lb46:
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	asll #8,d0
	swap d0
	movew d0,d2
	.short 0x7c00	/* moveq #0,d6 */
	movew a2@+,d6
	.short 0x7008	/* moveq #8,d0 */
	subw d3,d0
	asll d0,d6
	swap d6
	addw d6,d2
	swap d6
	.short 0x5043	/* addqw #8,d3 */
Lb62:
	.short 0x0c42,0x00ff	/* cmpiw #255,d2 */
	beqw Lc5a
Lb6a:
	movew d2,sp@-
Lb6c:
	.short 0x7400	/* moveq #0,d2 */
	.short 0x51cb,0x0008	/* dbf d3,0xb78 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	addxw d2,d2
	.short 0x51cb,0x0008	/* dbf d3,0xb86 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	addxw d2,d2
	.short 0x51cb,0x0008	/* dbf d3,0xb94 */
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
	addw d6,d6
	addxw d2,d2
	movew d2,sp@-
	.short 0x7200	/* moveq #0,d1 */
	moveb a6@(0x3,d2:w),d1
	tstw d3
	bgts Lbaa
	.short 0x0643,0x0010	/* addiw #16,d3 */
	movew a2@+,d6
Lbaa:
	movew d6,d2
	.short 0x7010	/* moveq #16,d0 */
	subb d1,d0
	asrl d0,d2
	cmpw d3,d1
	bgts Lbc0
	movew d6,d0
	aslw d1,d0
	movew d0,d6
	subw d1,d3
	bras Lbd0
Lbc0:
	.short 0x7c00	/* moveq #0,d6 */
	movew a2@+,d6
	subw d3,d1
	asll d1,d6
	swap d6
	addw d6,d2
	swap d6
	addw d0,d3
Lbd0:
	movew sp@+,d1
	addw d1,d1
	movew a6@(0xfffffffffffffff0,d1:w),d0
	.short 0x5240	/* addqw #1,d0 */
	addw d0,d2
	cmpw a6@,d2
	bnew L9da
	.short 0x7207	/* moveq #7,d1 */
	lea a6@(2),a6
	lea a6@(9),a0
	movew a6@-,d0
	addw d0,d0
	movew d0,a6@
	.short 0x5220	/* addqb #1,a0@- */
	.short 0x51c9,0xfff6	/* dbf d1,0xbec */
	lea a6@(14),a6
	braw Lb6c
Lc00:
	addb d5,d5
	bccs Lc1e
	tstb d7
	beqs Lc1a
	moveb a5@,d0
	.short 0x700f	/* moveq #15,d0 */
	andb a5@,d0
	moveb a5@-,d1
	.short 0x0201,0x00f0	/* andib #-16,d1 */
	addb d1,d0
	moveb d0,a3@+
	bras Lc4e
Lc1a:
	moveb a5@-,a3@+
	bras Lc4e
Lc1e:
	.short 0x51cc,0x0006	/* dbf d4,0xc26 */
	moveb a4@+,d5
	.short 0x7807	/* moveq #7,d4 */
	.short 0x7200	/* moveq #0,d1 */
	addb d5,d5
	addxb d1,d1
	tstb d7
	beqs Lc3c
	.short 0x700f	/* moveq #15,d0 */
	andb a5@,d0
	addb d0,d0
	addb d1,d0
	.short 0x7e00	/* moveq #0,d7 */
	bras Lc4a
Lc3c:
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@-,d0
	.short 0x0200,0x00f0	/* andib #-16,d0 */
	asrw #3,d0
	addb d1,d0
	.short 0x7e01	/* moveq #1,d7 */
Lc4a:
	.short 0x16f1,0x0000	/* moveb a1@(0,d0:w),a3@+ */
Lc4e:
	.short 0x51cc,0xfd9a	/* dbf d4,0x9ea */
	moveb a4@+,d5
	.short 0x7807	/* moveq #7,d4 */
	braw L9ea
Lc5a:
	moveal sp@,a0
	movel a3,d0
	subl a0@(8),d0
	.short 0x2668,0x0000	/* moveal a0@(0),a3 */
	.short 0x504b	/* addqw #8,a3 */
	.short 0x7200	/* moveq #0,d1 */
	moveb a3@,d1
	subl d1,d0
	cmpl a0@(16),d0
	beqs Lc7a
	.short 0x70f2	/* moveq #-14,d0 */
	braw L974
Lc7a:
	.short 0x7000	/* moveq #0,d0 */
	braw L974
Lc80:
	moveml d1-d2/a1,sp@-
	moveal a0@(32),a1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7400	/* moveq #0,d2 */
Lc8c:
	tstb a1@
	beqs Lc9c
	asll #4,d0
	.short 0x7200	/* moveq #0,d1 */
	moveb a1@+,d1
	orb d1,d0
	addl d1,d2
	bras Lc8c
Lc9c:
	addl d2,d0
	bnes Lca6
	.short 0x203c,0x0101,0x0101	/* movel #16843009,d0 */
Lca6:
	moveml sp@+,d1-d2/a1
	rts
Lcac:
	moveml d1-d7,sp@-
	addal d0,a0
	lsrl #5,d0
	.short 0x5380	/* subql #1,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7800	/* moveq #0,d4 */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7e00	/* moveq #0,d7 */
	moveal d1,a1
	moveml d1-d7/a1,a0@-
	.short 0x51c8,0xfffa	/* dbf d0,0xcc6 */
	moveml sp@+,d1-d7
	rts
Lcd4:
	.short 0x0001,0x0001	/* orib #1,d1 */
	.short 0x0002,0x0000	/* orib #0,d2 */
	.short 0x0000,0x0daa	/* orib #-86,d0 */
	.short 0x0000,0x0db0	/* orib #-80,d0 */
	.short 0x0000,0x0dbb	/* orib #-69,d0 */
	.short 0x4c49	/* .short 0x4c49 */
	.short 0x4e34	/* .short 0x4e34 */
	.short 0x0000,0xa009	/* orib #9,d0 */
	.short 0x7fff	/* .short 0x7fff */
	.short 0xffff	/* .short 0xffff */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x8000	/* orib #0,d0 */
	.short 0x0000,0x0de3	/* orib #-29,d0 */
	.short 0x0000,0x0dee	/* orib #-18,d0 */
	.short 0x0000,0x0df8	/* orib #-8,d0 */
	.short 0x0000,0x0e03	/* orib #3,d0 */
	.short 0x0064,0x0000	/* oriw #0,a4@- */
	.byte 0x00,0x00,0x0d,0x2c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #44,d0 */
	.short 0x0000,0x0d56	/* orib #86,d0 */
	.short 0x0000,0x0021	/* orib #33,d0 */
	.short 0x0000,0x0001	/* orib #1,d0 */
	.short 0x0001,0x873c	/* orib #60,d1 */
	.short 0x0000,0x0020	/* orib #32,d0 */
	.short 0x0000,0x001f	/* orib #31,d0 */
	.short 0x0000,0x00b0	/* orib #-80,d0 */
	bset d0,d2
	.short 0x0000,0x6d69	/* orib #105,d0 */
	bgts Ldb9
	blts Ldb3
	.byte 0x6c,0x00
Ld54:
	.byte 0x00,0x00	/* bgew 0xd54 */
	.short 0x0000,0x0d80	/* orib #-128,d0 */
	.short 0x0000,0x0042	/* orib #66,d0 */
	.short 0x0000,0x0001	/* orib #1,d0 */
	.short 0x0001,0x873c	/* orib #60,d1 */
	.short 0x0000,0x0020	/* orib #32,d0 */
	.short 0x0000,0x001d	/* orib #29,d0 */
	.short 0x0000,0x00b2	/* orib #-78,d0 */
	.short 0x01c8,0x0000	/* movepl d0,a0@(0) */
	bgts Lde7
	.short 0x726d	/* moveq #109,d1 */
	.byte 0x61,0x6c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* bsrs 0xde8 */
	.short 0x0000,0x0064	/* orib #100,d0 */
	.short 0x0000,0x0001	/* orib #1,d0 */
	.short 0x0001,0x873c	/* orib #60,d1 */
	.short 0x0000,0x0020	/* orib #32,d0 */
	.short 0x0000,0x001a	/* orib #26,d0 */
	.short 0x0000,0x00b3	/* orib #-77,d0 */
	.short 0x01ca,0x0000	/* movepl d0,a2@(0) */
	blts Le03
	.short 0x7869	/* moveq #105,d4 */
	blts Le07
	.byte 0x6c,0x00
Lda8:
	.byte 0x00,0x00	/* bgew 0xda8 */
	.short 0x4c49	/* .short 0x4c49 */
	trap #15
	movew d0,d2
	.short 0x4c69	/* .short 0x4c69 */
	.byte 0x6e
Ldb3:
	.byte 0x6f	/* bgts 0xe23 */
	movew a0@-,d2
	.byte 0x56,0x31,0x2e
Ldb9:
	.byte 0x31	/* addqb #3,a1@(31,d2:l:8) */
	.short 0x0049	/* .short 0x0049 */
	.short 0x6d70	/* blts 0xe2e */
	.short 0x726f	/* moveq #111,d1 */
	.short 0x7665	/* moveq #101,d3 */
	bccs Lde4
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7273	/* moveq #115,d1 */
	.short 0x696f	/* bvss 0xe39 */
	bgts Ldec
	.short 0x6f66	/* bles 0xe34 */
	moveal a4,a0
	.short 0x696e	/* bvss 0xe40 */
	bles Le06
	movel a0@-,d6
	.short 0x6265	/* bhis 0xe3d */
	.short 0x7374	/* .short 0x7374 */
	.byte 0x20,0x70,0x61,0x63,0x6b,0x69,0x6e,0x67,0x00,0x43	/* moveal a0@(6b69)@(6e670043),a0 */
Lde4:
	.short 0x6f6d	/* bles 0xe53 */
	.byte 0x72
Lde7:
	.byte 0x65	/* moveq #101,d1 */
Lde8:
	.short 0x7373	/* .short 0x7373 */
	.short 0x696e	/* bvss 0xe5a */
Ldec:
	.short 0x6700,0x4578	/* beqw 0x5366 */
	.short 0x7061	/* moveq #97,d0 */
	.short 0x6e64	/* bgts 0xe58 */
	.short 0x696e	/* bvss 0xe64 */
	.short 0x6700,0x436f	/* beqw 0x5167 */
	.short 0x6d70	/* blts 0xe6c */
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7373	/* .short 0x7373 */
	.short 0x6564	/* bcss 0xe66 */
	.byte 0x00
Le03:
	.byte 0x45,0x78,0x70	/* oriw #30832,d5 */
Le06:
	.byte 0x61
Le07:
	.byte 0x6e	/* bsrs 0xe76 */
	.byte 0x64,0x65,0x64,0x00	/* bccs 0xe6f */
	.data
