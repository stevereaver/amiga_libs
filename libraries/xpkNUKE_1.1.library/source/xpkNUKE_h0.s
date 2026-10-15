	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x0a,0xd0,0x00,0x00,0x0a,0xe0,0x00,0x00,0x00,0x04,0x00,0x00
	.byte 0x4e,0x55
	.short 0xffec
	moveml d7/a2/a4/a6,sp@-
	.byte 0x49,0xee,0x00,0x00	/* lea a6@(0),a4 */
	moveal a0,a2
	movel d0,a5@(-20)
	moveal a5@(-20),a0
	movel a2,a0@(34)
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	.byte 0x21,0x7c,0x00,0x00,0x0a,0xd0,0x00,0x0a	/* movel #2768,a0@(10) */
	.short 0x117c,0x0006,0x000e	/* moveb #6,a0@(14) */
	.short 0x317c,0x0001,0x0014	/* movew #1,a0@(20) */
	clrw a0@(22)
	.byte 0x21,0x7c,0x00,0x00,0x0a,0xe0,0x00,0x18	/* movel #2784,a0@(24) */
	lea a0@(58),a1
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0xff,0xf8	/* movel #0,a5@(-8) */
	.short 0x41f9,0x0000,0x0047	/* lea 0x47,a0 */
	movel a0,d0
	asll #2,d0
	movel a1,a5@(-12)
	moveal a5@(-8),a0
	bras L82
L80:
	moveb a0@+,a1@+
L82:
	.short 0x5380	/* subql #1,d0 */
	bccs L80
	.short 0x41f9,0x0000,0x0047	/* lea 0x47,a0 */
	movel a0,d0
	asll #2,d0
	addl d0,a5@(-8)
	moveal a5@(-8),a0
	movel a0@+,d7
	movel a0,a5@(-8)
L9e:
	tstl d7
	bles Lbe
	movel a5@(-12),d0
	movel d0,d1
	moveal a5@(-8),a0
	addl a0@+,d1
	moveal d1,a1
	addl d0,a1@
	.short 0x5387	/* subql #1,d7 */
	movel d1,a5@(-4)
	movel a0,a5@(-8)
	bras L9e
Lbe:
	moveal a5@(-20),a6
	.byte 0x4e,0xba,0x0a,0x2c	/* jsr %pc@(0xaf0) */
	movel a5@(-20),d0
	moveml sp@+,d7/a2/a4/a6
	unlk a5
	rts
	moveml a2/a4/a6,sp@-
	.byte 0x49,0xee,0x00,0x00	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x526a,0x0020	/* addqw #1,a2@(32) */
	bclr #3,a2@(14)
	movel a2,d0
	moveml sp@+,a2/a4/a6
	rts
	moveml d7/a2/a4/a6,sp@-
	.byte 0x49,0xee,0x00,0x00	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x536a,0x0020	/* subqw #1,a2@(32) */
	bnes L110
	btst #3,a2@(14)
	beqs L110
	moveal a2,a6
	bsrw L118
	movel d0,d7
L110:
	movel d7,d0
	moveml sp@+,d7/a2/a4/a6
	rts
L118:
	moveml d2/d6-d7/a2/a4/a6,sp@-
	.byte 0x49,0xee,0x00,0x00	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x7e00	/* moveq #0,d7 */
	bset #3,a2@(14)
	tstw a2@(32)
	bnes L172
	moveal a2,a6
	jsr %pc@(Laec)
	movel a2@(34),d7
	movel a6,sp@-
	moveal a2,a1
	moveal 0x4,a6
	jsr a6@(-252)
	moveal sp@+,a6
	.short 0x7000	/* moveq #0,d0 */
	movew a2@(16),d0
	.short 0x7200	/* moveq #0,d1 */
	movew a2@(18),d1
	movel d0,d2
	addl d1,d2
	movel d2,d6
	moveal a2,a0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	subal d1,a0
	movel a6,sp@-
	moveal a0,a1
	movel d6,d0
	moveal 0x4,a6
	jsr a6@(-210)
	moveal sp@+,a6
L172:
	movel d7,d0
	moveml sp@+,d2/d6-d7/a2/a4/a6
	rts
	.short 0x0000,0x2f0c	/* orib #12,d0 */
	lea a6@(58),a4
	lea a4@(196),a0
	movel a0,d0
	moveal sp@+,a4
	rts
L18c:
	linkw a5,#-4
	moveml a2/a4/a6,sp@-
	lea a6@(58),a4
	moveal a0,a2
	moveal a2@(52),a0
	movel a0,a5@(-4)
	movel a0,d0
	beqs L1ec
	movel a0@(8),d0
	beqs L1be
	movel a6,sp@-
	moveal d0,a1
	.short 0x7002	/* moveq #2,d0 */
	swap d0
	moveal 0x4,a6
	jsr a6@(-210)
	moveal sp@+,a6
L1be:
	moveal a5@(-4),a0
	movel a0@(12),d0
	beqs L1da
	movel a6,sp@-
	moveal d0,a1
	.short 0x7001	/* moveq #1,d0 */
	swap d0
	moveal 0x4,a6
	jsr a6@(-210)
	moveal sp@+,a6
L1da:
	movel a6,sp@-
	moveal a5@(-4),a1
	.short 0x7054	/* moveq #84,d0 */
	moveal 0x4,a6
	jsr a6@(-210)
	moveal sp@+,a6
L1ec:
	moveml sp@+,a2/a4/a6
	unlk a5
	rts
L1f4:
	linkw a5,#-12
	moveml d6-d7/a2,sp@-
	moveal a0,a2
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7c40	/* moveq #64,d6 */
	lsll #8,d6
	movel a2@(8),a5@(-4)
L20a:
	tstl d6
	bles L21e
	moveal a5@(-4),a0
	movel d7,a0@+
	movel d7,a0@+
	movel a0,a5@(-4)
	.short 0x5386	/* subql #1,d6 */
	bras L20a
L21e:
	.short 0x7c40	/* moveq #64,d6 */
	lsll #7,d6
	movel a2@(12),a5@(-4)
L228:
	tstl d6
	bles L23c
	moveal a5@(-4),a0
	movel d7,a0@+
	movel d7,a0@+
	movel a0,a5@(-4)
	.short 0x5386	/* subql #1,d6 */
	bras L228
L23c:
	moveml sp@+,d6-d7/a2
	unlk a5
	rts
	linkw a5,#-4
	moveml a2/a4/a6,sp@-
	lea a6@(58),a4
	moveal a0,a2
	moveal a2@(52),a0
	movel a0,a5@(-4)
	movel a0,d0
	bnes L2be
	movel a6,sp@-
	.short 0x7054	/* moveq #84,d0 */
	.short 0x7201	/* moveq #1,d1 */
	swap d1
	moveal 0x4,a6
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a2@(52)
	movel d0,a5@(-4)
	tstl d0
	beqs L2b4
	movel a6,sp@-
	.short 0x7002	/* moveq #2,d0 */
	swap d0
	.short 0x7200	/* moveq #0,d1 */
	moveal 0x4,a6
	jsr a6@(-198)
	moveal sp@+,a6
	moveal a5@(-4),a0
	movel d0,a0@(8)
	beqs L2b4
	movel a6,sp@-
	.short 0x7001	/* moveq #1,d0 */
	swap d0
	.short 0x7200	/* moveq #0,d1 */
	moveal 0x4,a6
	jsr a6@(-198)
	moveal sp@+,a6
	moveal a5@(-4),a0
	movel d0,a0@(12)
	bnes L2be
L2b4:
	moveal a2,a0
	bsrw L18c
	.short 0x70f9	/* moveq #-7,d0 */
	bras L300
L2be:
	moveal a5@(-4),a0
	bsrw L1f4
	moveal a5@(-4),a0
	movel a2@,a0@
	movel a2@(8),a0@(4)
	movel a2@(4),d0
	movew d0,a0@(32)
	movel a2@(12),d0
	.short 0x5980	/* subql #4,d0 */
	movew d0,a0@(34)
	movel a4,sp@-
	moveal a0,a4
	jsr %pc@(L52e)
	moveal sp@+,a4
	movel d0,a2@(16)
	blts L2fa
	cmpl a2@(4),d0
	bles L2fe
L2fa:
	.short 0x70ef	/* moveq #-17,d0 */
	bras L300
L2fe:
	.short 0x7000	/* moveq #0,d0 */
L300:
	moveml sp@+,a2/a4/a6
	unlk a5
	rts
	moveml a2/a4,sp@-
	lea a6@(58),a4
	moveal a0,a2
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,a2/a4
	rts
	linkw a5,#-8
	moveml a2/a4,sp@-
	lea a6@(58),a4
	moveal a0,a2
	moveal a2@,a0
	addal a2@(4),a0
	moveal a2@(8),a1
	addal a2@(16),a1
	movel a0,sp@(8)
	moveml a2/a4-a5,sp@-
	exg a2,a1
	moveal a1@(8),a0
	moveal sp@(20),a4
	moveal a1@,a5
	jsr %pc@(L992)
	moveml sp@+,a2/a4-a5
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,a2/a4
	unlk a5
	rts
	moveml a2/a4,sp@-
	lea a6@(58),a4
	moveal a0,a2
	moveml sp@+,a2/a4
	rts
L36c:
	.byte 0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x0a
L374:
	.byte 0x00,0x10,0x00,0x40,0x01,0x00,0x02,0x00,0x00,0x10,0x00,0x80,0x02,0x00,0x08,0x00
	.byte 0x20,0x00,0x40,0x00,0x00,0x20,0x00,0x80,0x02,0x00,0x08,0x00,0x20,0x00,0x40,0x00
	.byte 0x00,0x04,0x00,0x06,0x00,0x08,0x00,0x09,0x00,0x04,0x00,0x07,0x00,0x09,0x00,0x0b
	.byte 0x00,0x0d,0x00,0x0e,0x00,0x05,0x00,0x07,0x00,0x09,0x00,0x0b,0x00,0x0d,0x00,0x0e
	.byte 0x00,0x00,0x00,0x01,0x00,0x02,0x00,0x03,0x00,0x04,0x00,0x05,0x00,0x06,0x00,0x07
	.byte 0x00,0x08,0x00,0x09,0x00,0x0a,0x00,0x0b,0x00,0x0c,0x00,0x0d,0x00,0x0e,0x00,0x0f
L3d4:
	.byte 0x00,0x04,0x00,0x06,0x00,0x08,0x00,0x09,0x00,0x04,0x00,0x07,0x00,0x09,0x00,0x0b
	.byte 0x00,0x0d,0x00,0x0e,0x00,0x05,0x00,0x07,0x00,0x09,0x00,0x0b,0x00,0x0d,0x00,0x0e
	.byte 0x00,0x00,0x00,0x10,0x00,0x50,0x01,0x50,0x00,0x00,0x00,0x10,0x00,0x90,0x02,0x90
	.byte 0x0a,0x90,0x2a,0x90,0x00,0x00,0x00,0x20,0x00,0xa0,0x02,0xa0,0x0a,0xa0
L412:
	.byte 0x2a,0xa0,0x00,0x20,0x00,0x20,0x00,0x20,0x00,0x20,0x00,0x1e,0x00,0x1e,0x00,0x1e
	.byte 0x00,0x1e,0x00,0x1e,0x00,0x1e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00
L434:
	.short 0x536c,0x002c	/* subqw #1,a4@(44) */
	bccs L452
	moveal a4@(64),a0
	movew a4@(52),a0@
	movel a4@(16),a4@(64)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000f,0x002c	/* movew #15,a4@(44) */
L452:
	aslw a4@(52)
	.short 0x397c,0xffff,0x0028	/* movew #-1,a4@(40) */
	movew a4@(38),d0
	lea a5@(0xffffffffffffffff,d0:w),a0
	moveal a4@(20),a1
	movew d7,d0
L46a:
	moveb a0@+,a1@-
	dbf d0,L46a
	movel a1,a4@(20)
	tstw d7
	bnes L4a2
	.short 0x536c,0x002c	/* subqw #1,a4@(44) */
	bccs L496
	moveal a4@(64),a0
	movew a4@(52),a0@
	movel a4@(16),a4@(64)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000f,0x002c	/* movew #15,a4@(44) */
L496:
	aslw a4@(52)
	.short 0x526c,0x0034	/* addqw #1,a4@(52) */
	braw L52c
L4a2:
	movew d7,d0
	.short 0x536c,0x002c	/* subqw #1,a4@(44) */
	bccs L4c2
	moveal a4@(64),a0
	movew a4@(52),a0@
	movel a4@(16),a4@(64)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000f,0x002c	/* movew #15,a4@(44) */
L4c2:
	aslw a4@(52)
L4c6:
	.short 0x0c40,0x0003	/* cmpiw #3,d0 */
	bles L4fc
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x556c,0x002e	/* subqw #2,a4@(46) */
	bccs L4ec
	moveal a4@(68),a0
	movew a4@(54),a0@
	movel a4@(16),a4@(68)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000e,0x002e	/* movew #14,a4@(46) */
L4ec:
	aslw a4@(54)
	aslw a4@(54)
	orw d7,a4@(54)
	.short 0x5740	/* subqw #3,d0 */
	bras L4c6
L4fc:
	negw d0
	.short 0x7e03	/* moveq #3,d7 */
	andw d0,d7
	.short 0x556c,0x002e	/* subqw #2,a4@(46) */
	bccs L520
	moveal a4@(68),a0
	movew a4@(54),a0@
	movel a4@(16),a4@(68)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000e,0x002e	/* movew #14,a4@(46) */
L520:
	aslw a4@(54)
	aslw a4@(54)
	orw d7,a4@(54)
L52c:
	rts
L52e:
	moveml d2-d7/a2-a6,sp@-
	bsrw L862
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7e00	/* moveq #0,d7 */
L53c:
	.short 0x7200	/* moveq #0,d1 */
	moveb a5@(0xffffffffffffffff,d5:w),d1
	aslw #8,d1
	orb a5@(0x0,d5:w),d1
	addl d1,d1
	movew a3@(0x0,d1:l),d6
	bnes L57a
L550:
	.short 0x526c,0x0028	/* addqw #1,a4@(40) */
	bnes L55a
	movew d5,a4@(38)
L55a:
	movew d5,a3@(0x0,d1:l)
	.short 0x5245	/* addqw #1,d5 */
	cmpw a4@(42),d5
	blts L570
	moveal a4@(28),a0
	clrw a0@+
	movel a0,a4@(28)
L570:
	cmpw a4@(36),d5
	blts L53c
	braw L854
L57a:
	moveb a5@(0xffffffffffffffff,d5:w),d0
	cmpb a5@(0x0,d5:w),d0
	bnes L5d0
	lea a5@(0x1,d5:w),a0
	moveal a0,a1
	movew a4@(36),d4
	subw d5,d4
L590:
	cmpb a0@+,d0
	dbne d4,L590
	movel a0,d2
	cmpl a4@(24),d2
	bles L5a2
	movel a4@(24),d2
L5a2:
	subl a1,d2
	.short 0x0c42,0x0002	/* cmpiw #2,d2 */
	bles L5d0
	.short 0x7601	/* moveq #1,d3 */
	.short 0x5342	/* subqw #1,d2 */
	.short 0x526c,0x0028	/* addqw #1,a4@(40) */
	bnes L5b8
	movew d5,a4@(38)
L5b8:
	.short 0x5245	/* addqw #1,d5 */
	.short 0x7000	/* moveq #0,d0 */
	cmpw a4@(42),d5
	blts L5cc
	moveal a4@(28),a0
	movew d0,a0@+
	movel a0,a4@(28)
L5cc:
	braw L658
L5d0:
	movew d5,d4
	subw a4@(42),d4
	bges L5da
	.short 0x7800	/* moveq #0,d4 */
L5da:
	lea a5@(0x1,d5:w),a0
	movel a0,d2
	.short 0x5282	/* addql #1,d2 */
	movel a0,d0
	moveb a0@,d7
	movel a5,d3
	addl d6,d3
	.short 0x5483	/* addql #2,d3 */
	moveal a5,a2
	movew d5,a6@
	bras L614
L5f2:
	lea a5@(0x1,d6:w),a0
	moveal d0,a1
L5f8:
	cmpmb a0@+,a1@+
	beqs L5f8
	cmpl a1,d2
	bccs L60e
	cmpw d4,d6
	bles L62a
	subal d2,a2
	addal a1,a2
	movel a1,d2
	movel a0,d3
	moveb a1@-,d7
L60e:
	addw d6,d6
	movew a6@(0x0,d6:l),d6
L614:
	cmpb a2@(0x1,d6:w),d7
	beqs L626
	addw d6,d6
	movew a6@(0x0,d6:l),d6
	cmpb a2@(0x1,d6:w),d7
	bnes L60e
L626:
	cmpw d5,d6
	bnes L5f2
L62a:
	subl d2,d3
	negl d3
	cmpl a4@(24),d2
	bles L638
	movel a4@(24),d2
L638:
	subl d0,d2
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0c42,0x0001	/* cmpiw #1,d2 */
	bgts L658
	.short 0x0c43,0x0140	/* cmpiw #320,d3 */
	blts L658
	.short 0x7e00	/* moveq #0,d7 */
	movew d5,d7
	addl d7,d7
	movew a3@(0x0,d1:l),a6@(0x0,d7:l)
	braw L550
L658:
	movew a4@(40),d7
	blts L664
	jsr %pc@(L434)
	bras L68a
L664:
	.short 0x536c,0x002c	/* subqw #1,a4@(44) */
	bccs L682
	moveal a4@(64),a0
	movew a4@(52),a0@
	movel a4@(16),a4@(64)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000f,0x002c	/* movew #15,a4@(44) */
L682:
	aslw a4@(52)
	.short 0x526c,0x0034	/* addqw #1,a4@(52) */
L68a:
	movel d2,d0
	.short 0x0c40,0x0003	/* cmpiw #3,d0 */
	bles L694
	.short 0x7003	/* moveq #3,d0 */
L694:
	lea %pc@(L36c),a2
	addw d0,d0
	movew a2@(0x0,d0:w),d0
	lea %pc@(L374),a2
	addw d0,d0
	addaw d0,a2
	cmpw a2@,d3
	blts L6b0
L6aa:
	subw a2@+,d3
	cmpw a2@,d3
	bges L6aa
L6b0:
	movew a2@(64),d7
	.short 0x596c,0x0030	/* subqw #4,a4@(48) */
	bccs L6d6
	moveal a4@(72),a0
	movel a4@(56),a0@
	movel a4@(16),a4@(72)
	.short 0x58ac,0x0010	/* addql #4,a4@(16) */
	.short 0x397c,0x001c,0x0030	/* movew #28,a4@(48) */
	clrl a4@(56)
L6d6:
	movel a4@(56),d0
	orw d7,d0
	rorl #4,d0
	movel d0,a4@(56)
	movew a2@(32),d7
	.short 0x7000	/* moveq #0,d0 */
	movel a4@(60),d0
	asll d7,d0
	orl d3,d0
	subw d7,a4@(50)
	bccs L71a
	movew a4@(50),d7
	negw d7
	rorl d7,d0
	moveal a4@(76),a0
	movew d0,a0@
	movel a4@(16),a4@(76)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	roll d7,d0
	negw d7
	.short 0xde7c,0x0010	/* addw #16,d7 */
	movew d7,a4@(50)
L71a:
	movel d0,a4@(60)
	.short 0x0c42,0x0002	/* cmpiw #2,d2 */
	blew L81e
	movel d2,d0
	.short 0x0c40,0x0005	/* cmpiw #5,d0 */
	bgts L764
	.short 0x5740	/* subqw #3,d0 */
	notw d0
	.short 0x7e03	/* moveq #3,d7 */
	andw d0,d7
	.short 0x556c,0x002e	/* subqw #2,a4@(46) */
	bccs L754
	moveal a4@(68),a0
	movew a4@(54),a0@
	movel a4@(16),a4@(68)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000e,0x002e	/* movew #14,a4@(46) */
L754:
	aslw a4@(54)
	aslw a4@(54)
	orw d7,a4@(54)
	braw L81e
L764:
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x556c,0x002e	/* subqw #2,a4@(46) */
	bccs L784
	moveal a4@(68),a0
	movew a4@(54),a0@
	movel a4@(16),a4@(68)
	.short 0x54ac,0x0010	/* addql #2,a4@(16) */
	.short 0x397c,0x000e,0x002e	/* movew #14,a4@(46) */
L784:
	aslw a4@(54)
	aslw a4@(54)
	orw d7,a4@(54)
	.short 0x5d40	/* subqw #6,d0 */
L792:
	.short 0x0c40,0x000e	/* cmpiw #14,d0 */
	bles L7d2
	.short 0x7e00	/* moveq #0,d7 */
	movel d0,sp@-
	.short 0x596c,0x0030	/* subqw #4,a4@(48) */
	bccs L7be
	moveal a4@(72),a0
	movel a4@(56),a0@
	movel a4@(16),a4@(72)
	.short 0x58ac,0x0010	/* addql #4,a4@(16) */
	.short 0x397c,0x001c,0x0030	/* movew #28,a4@(48) */
	clrl a4@(56)
L7be:
	movel a4@(56),d0
	orw d7,d0
	rorl #4,d0
	movel d0,a4@(56)
	movel sp@+,d0
	.short 0x907c,0x000f	/* subw #15,d0 */
	bras L792
L7d2:
	notw d0
	.short 0x7e0f	/* moveq #15,d7 */
	andw d0,d7
	.short 0x596c,0x0030	/* subqw #4,a4@(48) */
	bccs L7fa
	moveal a4@(72),a0
	movel a4@(56),a0@
	movel a4@(16),a4@(72)
	.short 0x58ac,0x0010	/* addql #4,a4@(16) */
	.short 0x397c,0x001c,0x0030	/* movew #28,a4@(48) */
	clrl a4@(56)
L7fa:
	movel a4@(56),d0
	orw d7,d0
	rorl #4,d0
	movel d0,a4@(56)
	cmpw a4@(42),d5
	blts L81e
	movew d2,d7
	moveal a4@(28),a0
	.short 0x7000	/* moveq #0,d0 */
L814:
	movew d0,a0@+
	dbf d7,L814
	movel a0,a4@(28)
L81e:
	lea a5@(0x1,d5:w),a0
	movew d5,d7
	addw d7,d7
	.short 0x0c43,0x0001	/* cmpiw #1,d3 */
	bnes L83a
	addw d2,d5
	.short 0x5245	/* addqw #1,d5 */
	bras L84c
L832:
	lsrl #1,d1
	lslw #8,d1
	moveb a0@+,d1
	addl d1,d1
L83a:
	movew a3@(0x0,d1:l),a6@(0x0,d7:l)
	movew d5,a3@(0x0,d1:l)
	.short 0x5447	/* addqw #2,d7 */
	.short 0x5245	/* addqw #1,d5 */
	dbf d2,L832
L84c:
	cmpw a4@(36),d5
	bltw L53c
L854:
	bsrw L8ec
	bsrw L950
	moveml sp@+,d2-d7/a2-a6
	rts
L862:
	.short 0x7000	/* moveq #0,d0 */
	movew d0,a4@(44)
	movew d0,a4@(46)
	movew d0,a4@(48)
	movew d0,a4@(50)
	movew d0,a4@(52)
	movew d0,a4@(54)
	movel d0,a4@(56)
	movel d0,a4@(60)
	lea a4@(80),a0
	movel a0,a4@(64)
	movel a0,a4@(68)
	movel a0,a4@(72)
	movel a0,a4@(76)
	moveal a4@(8),a3
	moveal a4@,a5
	moveal a4@(12),a6
	movel a6,a4@(28)
	.short 0x397a,0xfb6a,0x002a	/* movew %pc@(0x412),a4@(42) */
	.short 0x536c,0x002a	/* subqw #1,a4@(42) */
	movel a4@(4),a4@(16)
	moveal a4@(4),a0
	addaw a4@(34),a0
	movel a0,a4@(20)
	moveal a4@,a0
	addaw a4@(32),a0
	movel a0,a4@(24)
	movew a4@(32),a4@(36)
	.short 0x536c,0x0024	/* subqw #1,a4@(36) */
	.short 0x7a01	/* moveq #1,d5 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x397c,0xffff,0x0028	/* movew #-1,a4@(40) */
	.short 0x397c,0x0000,0x0026	/* movew #0,a4@(38) */
	rts
L8ec:
	cmpw a4@(32),d5
	beqs L8fc
	.short 0x526c,0x0028	/* addqw #1,a4@(40) */
	bnes L8fc
	movew d5,a4@(38)
L8fc:
	.short 0x526c,0x0028	/* addqw #1,a4@(40) */
	bnes L906
	movew d5,a4@(38)
L906:
	movew a4@(40),d7
	bsrw L434
	moveal a4@(64),a0
	movew a4@(52),d0
	movew a4@(44),d1
	lslw d1,d0
	movew d0,a0@
	moveal a4@(68),a0
	movew a4@(54),d0
	movew a4@(46),d1
	lslw d1,d0
	movew d0,a0@
	moveal a4@(72),a0
	movel a4@(56),d0
	movew a4@(48),d1
	lsrl d1,d0
	movel d0,a0@
	moveal a4@(76),a0
	movew a4@(62),d0
	movew a4@(50),d1
	lslw d1,d0
	movew d0,a0@
	rts
L950:
	movel a4@(20),d0
	subl a4@(16),d0
	bges L95e
	.short 0x70ff	/* moveq #-1,d0 */
	bras L990
L95e:
	moveal a4@(20),a2
	moveal a4@(4),a0
	addaw a4@(34),a0
	subal a4@(20),a0
	movel a0,d2
	moveal a4@(16),a1
L974:
	movel a1,d0
	addl d2,d0
	.short 0x7203	/* moveq #3,d1 */
	andl d0,d1
	beqs L986
	.short 0x12fc,0x00fb	/* moveb #-5,a1@+ */
	bras L974
L984:
	moveb a2@+,a1@+
L986:
	dbf d2,L984
	movel a1,d0
	subl a4@(4),d0
L990:
	rts
L992:
	moveml d2-d7/a3-a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x343c,0x8000	/* movew #-32768,d2 */
	.short 0x363c,0x8000	/* movew #-32768,d3 */
	.short 0x7800	/* moveq #0,d4 */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x367c,0x0010	/* moveaw #16,a3 */
	lea %pc@(L3d4),a6
	bsrw La20
	movel a0,d0
	moveml sp@+,d2-d7/a3-a6
	rts
L9be:
	dbf d5,L9c8
	.short 0x7a07	/* moveq #7,d5 */
	movel a5@+,d4
	addl d4,d4
L9c8:
	.short 0x701e	/* moveq #30,d0 */
	andw d4,d0
	roxrl #4,d4
	movew a6@(0x0,d0:w),d1
	asll d1,d6
	subw d1,d7
	bccs L9e6
	.short 0x7200	/* moveq #0,d1 */
	movew a5@+,d1
	negw d7
	asll d7,d1
	orl d1,d6
	negw d7
	addw a3,d7
L9e6:
	swap d6
	moveal a0,a1
	addw a6@(0x20,d0:w),d6
	subaw d6,a1
	clrw d6
	swap d6
	movew a6@(0x40,d0:w),d0
	.short 0x4efb,0x0002	/* jmp %pc@(0x9fc,d0:w) */
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	.short 0x7000	/* moveq #0,d0 */
	addw d3,d3
	bnes La0c
	movew a5@+,d3
	addxw d3,d3
La0c:
	addxw d0,d0
	addw d3,d3
	addxw d0,d0
	addw d0,d0
	.short 0x4efb,0x0002	/* jmp %pc@(0xa18,d0:w) */
	bras La84
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
La20:
	addw d2,d2
	bnes La28
	movew a5@+,d2
	addxw d2,d2
La28:
	bcss L9be
	addw d2,d2
	bnes La32
	movew a5@+,d2
	addxw d2,d2
La32:
	bccs La42
	moveb a4@-,a0@+
	cmpal a2,a0
	blts L9be
	rts
La3c:
	moveb a4@-,a0@+
	moveb a4@-,a0@+
	moveb a4@-,a0@+
La42:
	.short 0x7000	/* moveq #0,d0 */
	addw d3,d3
	bnes La4c
	movew a5@+,d3
	addxw d3,d3
La4c:
	addxw d0,d0
	addw d3,d3
	addxw d0,d0
	addw d0,d0
	.short 0x4efb,0x0002	/* jmp %pc@(0xa58,d0:w) */
	bras La3c
	moveb a4@-,a0@+
	moveb a4@-,a0@+
	moveb a4@-,a0@+
	moveb a4@-,a0@+
	cmpal a2,a0
	bltw L9be
	rts
	.short 0x7000	/* moveq #0,d0 */
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
La84:
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	moveb a1@+,a0@+
	tstb d0
	bnes La20
	dbf d5,La98
	.short 0x7a07	/* moveq #7,d5 */
	movel a5@+,d4
	addl d4,d4
La98:
	.short 0x701e	/* moveq #30,d0 */
	andw d4,d0
	roxrl #4,d4
	.short 0x4efb,0x00ca	/* jmp %pc@(0xa6a,d0:w) */
	.byte 0x00,0x00,0x00,0x00,0x00,0xd2,0x00,0x00,0x00,0xee,0x00,0x00,0x01,0x18,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x01,0x7c,0x00,0x00,0x02,0x44,0x00,0x00,0x01,0x8c,0x00,0x00
	.byte 0x03,0x08,0x00,0x00,0x03,0x1a,0x00,0x00,0x03,0x5c,0xff,0xff,0xff,0xff,0x78,0x70
	.byte 0x6b,0x4e,0x55,0x4b,0x45,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x56,0x65
	.byte 0x72,0x73,0x69,0x6f,0x6e,0x20,0x31,0x2e,0x30,0x00
Laec:
	.byte 0x4e,0x75,0x00,0x00
Laf0:
	.byte 0x4e,0x75,0x00,0x00
