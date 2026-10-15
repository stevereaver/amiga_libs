	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x25
	.byte 0x09,0x00,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x00
	.short 0x0000,0x514f	/* orib #79,d0 */
	moveml d7/a2-a3/a5-a6,sp@-
	moveal d0,a5
	movel a0,a5@(34)
	.short 0x1b7c,0x0009,0x0008	/* moveb #9,a5@(8) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x20,0x00,0x0a	/* movel #32,a5@(10) */
	.short 0x1b7c,0x0006,0x000e	/* moveb #6,a5@(14) */
	.short 0x43f9,0x0000,0x0025	/* lea 0x25,a1 */
	movel a1,d0
	lea a5@(20),a3
	movew d0,a3@+
	.short 0x43f9,0x0000,0x0003	/* lea 0x3,a1 */
	movel a1,d0
	movew d0,a3@+
	.short 0x26fc,0x0000,0x0034	/* movel #52,a3@+ */
	lea a5@(46),a3
	clrl a3@+
	movel a5,a3@+
	.short 0x26fc,0x0000,0x002a	/* movel #42,a3@+ */
	lea a5@(60),a1
	.short 0x45f9,0x0000,0x0068	/* lea 0x68,a2 */
	movel a2,d0
	movel d0,d1
	asll #2,d1
	movel a6,sp@(24)
	.short 0x45f9,0x0000,0x0000	/* lea 0x0,a2 */
	.byte 0x0c,0x40
L88:
	.byte 0x12,0xda	/* cmpiw #4826,d0 */
	.short 0x5381	/* subql #1,d1 */
	bccs L88
	asll #2,d0
	.short 0x47f9,0x0000,0x0000	/* lea 0x0,a3 */
	addal d0,a3
	movel a3@,d0
	moveal sp@(24),a6
	beqs Lc6
	movel d0,d7
	asll #2,d7
	.short 0x5887	/* addql #4,d7 */
	movel d7,d0
	.short 0x7201	/* moveq #1,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	movel d0,a5@(46)
	moveal sp@(24),a6
	beqs Lc8
	moveal d0,a1
	.byte 0x0c,0x40
Lc0:
	.byte 0x12,0xdb	/* cmpiw #4827,d0 */
	.short 0x5387	/* subql #1,d7 */
	bccs Lc0
Lc6:
	movel a5,d0
Lc8:
	moveml sp@+,d7/a2-a3/a5-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x9efc,0x0014	/* subaw #20,sp */
	moveml d2/a2-a3/a5-a6,sp@-
	.short 0x2278,0x0004	/* moveal 0x4,a1 */
	moveal a6,a5
	.short 0x526d,0x0020	/* addqw #1,a5@(32) */
	bclr #3,a5@(14)
	moveal a5@(50),a0
	movel a1,sp@(24)
	.short 0x43f9,0x0000,0x01c8	/* lea 0x1c8,a1 */
	movel a1,d0
	addl a0@(54),d0
	.short 0x723c	/* moveq #60,d1 */
	addl d1,d0
	movel a6,sp@(32)
	movel a6,sp@(36)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal d0,a3
	movel d0,sp@(28)
	moveal sp@(36),a6
	beqw L1e2
	moveal a5@(50),a0
	moveal a5,a1
	movel a0@(54),d1
	subal d1,a1
	.short 0x4df9,0x0000,0x0068	/* lea 0x68,a6 */
	movel a6,d0
	asll #2,d0
	addl d1,d0
	.short 0x723c	/* moveq #60,d1 */
	addl d1,d0
	moveal a3,a0
	.byte 0x0c,0x40
L144:
	.byte 0x10,0xd9	/* cmpiw #4313,d0 */
	.short 0x5380	/* subql #1,d0 */
	bccs L144
	moveal a5@(50),a0
	moveal a3,a2
	addal a0@(54),a2
	clrl a2@(46)
	lea a2@(60),a5
	moveal a2@(50),a0
	moveal a0@(46),a1
	moveal sp@(36),a6
	movel a1,d1
	beqs L184
	lea a1@(4),a3
	movel a1@,d2
	bras L180
L174:
	movel a5,d0
	movel a3@+,d1
	addl d0,d1
	moveal d1,a0
	addl d0,a0@
	.short 0x5382	/* subql #1,d2 */
L180:
	tstl d2
	bgts L174
L184:
	moveal sp@(24),a0
	.short 0x0c68,0x0024,0x0014	/* cmpiw #36,a0@(20) */
	moveal sp@(36),a6
	bcss L19c
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-636)
L19c:
	moveal a2,a6
	bsrw L918
	moveal sp@(36),a6
	tstl d0
	bnes L1b8
	moveal a2,a6
	bsrw L2e0
	tstl d0
	moveal sp@(36),a6
	beqs L1f2
L1b8:
	moveal a2,a6
	bsrw L94c
	moveal a2@(50),a0
	.short 0x43f9,0x0000,0x01c8	/* lea 0x1c8,a1 */
	movel a1,d0
	addl a0@(54),d0
	.short 0x723c	/* moveq #60,d1 */
	addl d1,d0
	moveal sp@(28),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@(36),a6
L1e2:
	moveal sp@(32),a1
	moveal a1@(50),a0
	.short 0x5368,0x0020	/* subqw #1,a0@(32) */
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x0c,0x40
L1f2:
	.byte 0x20,0x0a	/* cmpiw #8202,d0 */
	moveml sp@+,d2/a2-a3/a5-a6
	.short 0xdefc,0x0014	/* addaw #20,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a3/a5-a6,sp@-
	moveal a6,a5
	.short 0x7e00	/* moveq #0,d7 */
	movel a6,sp@(16)
	moveal a5@(50),a0
	cmpal a5,a0
	beqs L244
	moveal a5,a6
	bsrw L414
	bsrw L94c
	moveal a5@(50),a3
	movel a3@(54),d0
	subal d0,a5
	.short 0x43f9,0x0000,0x01c8	/* lea 0x1c8,a1 */
	movel a1,d0
	addl a3@(54),d0
	.short 0x723c	/* moveq #60,d1 */
	addl d1,d0
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal a3,a5
L244:
	.short 0x536d,0x0020	/* subqw #1,a5@(32) */
	moveal sp@(16),a6
	bnes L25e
	btst #3,a5@(14)
	beqs L25e
	moveal a5,a6
	bsrw L268
	movel d0,d7
L25e:
	movel d7,d0
	moveml sp@+,d7/a3/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L268:
	.short 0x514f	/* subqw #8,sp */
	moveml d2/d7/a5-a6,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	moveal a6@(50),a5
	bset #3,a5@(14)
	movel a6,sp@(16)
	movel a6,sp@(20)
	tstw a5@(32)
	bnes L2ce
	movel a5@(46),d0
	beqs L2a2
	moveal d0,a0
	movel a0@,d1
	asll #2,d1
	.short 0x5881	/* addql #4,d1 */
	moveal d0,a1
	movel d1,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
L2a2:
	movel a5@(34),d7
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(18),d0
	.short 0x7200	/* moveq #0,d1 */
	movew a5@(16),d1
	movel d1,d2
	addl d0,d2
	moveal a5,a1
	.short 0x7000	/* moveq #0,d0 */
	movew d1,d0
	subal d0,a1
	movel d2,d0
	jsr a6@(-210)
L2ce:
	movel d7,d0
	moveml sp@+,d2/d7/a5-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x584f	/* addqw #4,sp */
	rts
L2e0:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a2/a4/a6,sp@-
	lea a6@(60),a4
	.short 0x7e01	/* moveq #1,d7 */
	movel a6,sp@(16)
	lea a4@(316),a1
	.short 0x7025	/* moveq #37,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(428)
	moveal sp@(16),a6
	tstl d0
	beqs L340
	lea a4@(334),a1
	.short 0x7025	/* moveq #37,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(432)
	moveal sp@(16),a6
	tstl d0
	beqs L340
	lea a4@(352),a1
	.short 0x7025	/* moveq #37,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(436)
	moveal sp@(16),a6
	tstl d0
	beqs L340
	.short 0x7e00	/* moveq #0,d7 */
L340:
	lea a4@(368),a1
	.short 0x7026	/* moveq #38,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(452)
	moveal sp@(16),a6
	tstl d0
	beqw L404
	clrl sp@-
	pea a4@(406)
	.short 0x2f3c,0x8009,0x0001	/* movel #-2146893823,sp@- */
	lea a4@(384),a1
	subal a0,a0
	moveal d0,a6
	moveal sp,a2
	jsr a6@(-150)
	lea sp@(12),sp
	movel d0,a4@(448)
	moveal sp@(16),a6
	tstl d0
	beqs L3fc
	moveal d0,a0
	moveal a4@(32),a1
	moveal a4@(452),a6
	.short 0x203c,0x0000,0x03ea	/* movel #1002,d0 */
	jsr a6@(-72)
	movel d0,a4@(32)
	moveal a4@(448),a0
	moveal a4@(118),a1
	.short 0x203c,0x0000,0x03eb	/* movel #1003,d0 */
	jsr a6@(-72)
	movel d0,a4@(118)
	moveal a4@(448),a0
	moveal a4@(154),a1
	.short 0x203c,0x0000,0x03ec	/* movel #1004,d0 */
	jsr a6@(-72)
	movel d0,a4@(154)
	moveal a4@(448),a0
	moveal a4@(184),a1
	.short 0x203c,0x0000,0x03ed	/* movel #1005,d0 */
	jsr a6@(-72)
	movel d0,a4@(184)
	moveal a4@(448),a0
	moveal a4@(214),a1
	.short 0x203c,0x0000,0x03ee	/* movel #1006,d0 */
	jsr a6@(-72)
	movel d0,a4@(214)
	moveal sp@(16),a6
	bras L40a
L3fc:
	movel a4@(72),a4@(4)
	bras L40a
L404:
	movel a4@(106),a4@(4)
L40a:
	movel d7,d0
	moveml sp@+,d7/a2/a4/a6
	.short 0x584f	/* addqw #4,sp */
	rts
L414:
	.short 0x594f	/* subqw #4,sp */
	moveml a4/a6,sp@-
	lea a6@(60),a4
	movel a6,sp@(8)
	movel a4@(448),d0
	beqs L432
	moveal d0,a0
	moveal a4@(452),a6
	jsr a6@(-36)
L432:
	moveal sp@(8),a6
	movel a4@(452),d0
	beqs L446
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L446:
	moveal sp@(8),a6
	movel a4@(436),d0
	beqs L45a
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L45a:
	moveal sp@(8),a6
	movel a4@(428),d0
	beqs L46e
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L46e:
	moveal sp@(8),a6
	movel a4@(432),d0
	beqs L482
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L482:
	moveml sp@+,a4/a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x9efc,0x0060	/* subaw #96,sp */
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a5
	movel a1,sp@(52)
	lea a6@(60),a4
	clrl sp@(136)
	clrl sp@(132)
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x3f7c,0x0008,0x0040	/* movew #8,sp@(64) */
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7800	/* moveq #0,d4 */
	clrl sp@(80)
	moveal a5,a0
L4ba:
	tstb a0@+
	bnes L4ba
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movew d0,sp@(68)
	movew d0,sp@(72)
	movel a6,sp@(56)
	movel a0,d0
	bnes L4de
	movel a4@(118),a4@(4)
	.short 0x7000	/* moveq #0,d0 */
	braw L8d2
L4de:
	moveal a5,a0
L4e0:
	tstb a0@+
	bnes L4e0
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movel a0,d0
	.short 0x5280	/* addql #1,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	movel d0,sp@(136)
	tstl d0
	moveal sp@(56),a6
	bnes L50e
	movel a4@(154),a4@(4)
	.short 0x7000	/* moveq #0,d0 */
	braw L8d2
L50e:
	movel d0,sp@(132)
	moveal a5,a0
	moveal d0,a1
L516:
	moveb a0@+,a1@+
	bnes L516
	movel sp@(136),sp@(0x5c,d7:l:4)
	moveal sp@(56),a6
L524:
	moveal sp@(136),a0
	moveb a0@,d0
	beqs L568
	.short 0x720a	/* moveq #10,d1 */
	cmpb d1,d0
	bnes L562
	clrb a0@+
	.short 0x5287	/* addql #1,d7 */
	movel a0,sp@(136)
	.short 0x700a	/* moveq #10,d0 */
	cmpl d0,d7
	bnes L55c
	moveal sp@(132),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
	clrl sp@(132)
	movel a4@(32),a4@(4)
	.short 0x7000	/* moveq #0,d0 */
	braw L8d2
L55c:
	movel a0,sp@(0x5c,d7:l:4)
	bras L524
L562:
	.short 0x52af,0x0088	/* addql #1,sp@(136) */
	bras L524
L568:
	cmpl d7,d6
	bgts L58a
	moveal sp@(0x5c,d6:l:4),a0
	movel a0,d0
L572:
	tstb a0@+
	bnes L572
	.short 0x5388	/* subql #1,a0 */
	subal d0,a0
	movel a0,d5
	cmpl d4,d5
	bles L586
	movel d5,d4
	movel d6,sp@(80)
L586:
	.short 0x5286	/* addql #1,d6 */
	bras L568
L58a:
	movel a3,sp@(84)
L58e:
	lea sp@(84),a0
	moveal a4@(436),a6
	jsr a6@(-48)
	moveal sp@(56),a6
	movel d0,sp@(60)
	beqs L5d2
	moveal d0,a0
	movel a0@,d0
	.short 0x0480,0x8000,0x0002	/* subil #-2147483646,d0 */
	beqs L5b6
	.short 0x5380	/* subql #1,d0 */
	beqs L5c4
	bras L58e
L5b6:
	moveal sp@(60),a0
	movel a0@(4),d0
	movew d0,sp@(72)
	bras L58e
L5c4:
	moveal sp@(60),a0
	movel a0@(4),d0
	movew d0,sp@(68)
	bras L58e
L5d2:
	movel d7,d0
	.short 0x5280	/* addql #1,d0 */
	.short 0x7200	/* moveq #0,d1 */
	moveal sp@(52),a0
	movew a0@(20),d1
	.short 0x4c00,0x1801	/* mulsl d0,d1 */
	movew sp@(64),d0
	extl d0
	addl d0,d1
	movel sp@(80),d0
	lea sp@(92),a1
	.short 0x4df1,0x0c00	/* lea a1@(0,d0:l:4),a6 */
	moveal sp@(0x5c,d0:l:4),a1
	movel a1,d2
L5fe:
	tstb a1@+
	bnes L5fe
	.short 0x5389	/* subql #1,a1 */
	subal d2,a1
	movew d1,sp@(76)
	movel a1,d0
	moveal a2@(50),a1
	moveal a6@,a0
	moveal a4@(428),a6
	jsr a6@(-54)
	movew sp@(64),d1
	extl d1
	movel d1,d2
	addl d2,d2
	moveal a2@(46),a0
	movew a0@(12),d1
	extl d1
	.short 0x4c01,0x2802	/* mulsl d1,d2 */
	.byte 0x4c,0x7c,0x28,0x02,0x00,0x00,0x02,0x80	/* divsll #640,d2,d2 */
	movew d0,sp@(88)
	extl d0
	addl d2,d0
	movew d0,sp@(88)
	.short 0x72ff	/* moveq #-1,d1 */
	cmpw sp@(72),d1
	moveal sp@(56),a6
	beqs L658
	cmpw sp@(68),d1
	bnes L684
L658:
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(142),d1
	moveb a0@(35),d2
	extbl d2
	addl d2,d1
	movew a0@(16),d2
	extl d2
	addl d1,d2
	movew d0,d1
	bpls L674
	.short 0x5241	/* addqw #1,d1 */
L674:
	asrw #1,d1
	movew a0@(18),d3
	subw d1,d3
	movew d2,sp@(68)
	movew d3,sp@(72)
L684:
	cmpw a0@(12),d0
	bles L6a6
	moveal sp@(132),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
	clrl sp@(132)
	movel a4@(184),a4@(4)
	.short 0x7000	/* moveq #0,d0 */
	braw L8d2
L6a6:
	movew sp@(72),d0
	extl d0
	movew sp@(68),d1
	extl d1
	movew sp@(88),d2
	extl d2
	movew sp@(76),d3
	extl d3
	clrl sp@-
	movel a2@(46),sp@-
	.short 0x2f3c,0x8000,0x0070	/* movel #-2147483536,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x0089	/* movel #-2147483511,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x0090	/* movel #-2147483504,sp@- */
	.short 0x4878,0x0800	/* pea 0x800 */
	.short 0x2f3c,0x8000,0x006b	/* movel #-2147483541,sp@- */
	movel d3,sp@-
	.short 0x2f3c,0x8000,0x0067	/* movel #-2147483545,sp@- */
	movel d2,sp@-
	.short 0x2f3c,0x8000,0x0066	/* movel #-2147483546,sp@- */
	movel d1,sp@-
	.short 0x2f3c,0x8000,0x0065	/* movel #-2147483547,sp@- */
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x0064	/* movel #-2147483548,sp@- */
	moveal a4@(432),a6
	subal a0,a0
	moveal sp,a1
	jsr a6@(-606)
	lea sp@(68),sp
	movel d0,a4@(440)
	moveal sp@(56),a6
	tstl d0
	beqw L8ca
	moveal d0,a1
	moveal a1@(50),a1
	moveal a4@(428),a6
	.short 0x7002	/* moveq #2,d0 */
	jsr a6@(-342)
	movew sp@(88),d0
	extl d0
	.short 0x5380	/* subql #1,d0 */
	movew sp@(76),d1
	extl d1
	.short 0x5381	/* subql #1,d1 */
	movel d0,d2
	movel d1,d3
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d1
	jsr a6@(-306)
	moveal a4@(440),a1
	moveal a1@(50),a1
	moveal sp@(52),a0
	jsr a6@(-66)
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7001	/* moveq #1,d0 */
	jsr a6@(-342)
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7002	/* moveq #2,d0 */
	jsr a6@(-348)
	.short 0x7c00	/* moveq #0,d6 */
	moveal sp@(56),a6
L78a:
	cmpl d7,d6
	bgtw L840
	lea sp@(92),a0
	.short 0x43f0,0x6c00	/* lea a0@(0,d6:l:4),a1 */
	moveal sp@(0x5c,d6:l:4),a0
	movel a0,d0
L79e:
	tstb a0@+
	bnes L79e
	.short 0x5388	/* subql #1,a0 */
	subal d0,a0
	movel a1,sp@(48)
	movel a0,d0
	moveal a2@(50),a1
	moveal sp@(48),a0
	moveal a0@,a0
	moveal a4@(428),a6
	jsr a6@(-54)
	movew sp@(88),d1
	extl d1
	extl d0
	subl d0,d1
	tstl d1
	bpls L7ce
	.short 0x5281	/* addql #1,d1 */
L7ce:
	asrl #1,d1
	moveal a4@(440),a1
	moveal a1@(50),a0
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(52),a1
	movew a1@(20),d0
	.short 0x4c06,0x0800	/* mulsl d6,d0 */
	.short 0x7400	/* moveq #0,d2 */
	movew a0@(62),d2
	addl d0,d2
	movew sp@(64),d0
	extl d0
	tstl d0
	bpls L7fa
	.short 0x5280	/* addql #1,d0 */
L7fa:
	asrl #1,d0
	addl d0,d2
	moveal a0,a1
	movel d1,d0
	movel d2,d1
	jsr a6@(-240)
	lea sp@(92),a0
	.short 0x43f0,0x6c00	/* lea a0@(0,d6:l:4),a1 */
	moveal sp@(0x5c,d6:l:4),a0
	movel a0,d0
L816:
	tstb a0@+
	bnes L816
	.short 0x5388	/* subql #1,a0 */
	subal d0,a0
	movel a1,sp@(48)
	movel a0,d0
	moveal a4@(440),a1
	moveal a1@(50),a1
	moveal sp@(48),a0
	moveal a0@,a0
	jsr a6@(-60)
	.short 0x5286	/* addql #1,d6 */
	moveal sp@(56),a6
	braw L78a
L840:
	moveal a4@(440),a1
	moveal a1@(50),a1
	moveal a4@(428),a6
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d1
	jsr a6@(-240)
	movew sp@(76),d0
	extl d0
	.short 0x5380	/* subql #1,d0 */
	movel d0,d1
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-246)
	movew sp@(88),d0
	extl d0
	.short 0x5380	/* subql #1,d0 */
	movew sp@(76),d1
	extl d1
	.short 0x5381	/* subql #1,d1 */
	moveal a4@(440),a1
	moveal a1@(50),a1
	jsr a6@(-246)
	movew sp@(88),d0
	extl d0
	.short 0x5380	/* subql #1,d0 */
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-246)
	moveal a4@(440),a1
	moveal a1@(50),a1
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d1
	jsr a6@(-246)
	moveal sp@(56),a6
	movel sp@(132),d0
	beqs L8c2
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L8c2:
	clrl sp@(132)
	.short 0x7001	/* moveq #1,d0 */
	bras L8d2
L8ca:
	movel a4@(214),a4@(4)
	.short 0x7000	/* moveq #0,d0 */
L8d2:
	moveml sp@+,d2-d7/a2-a6
	.short 0xdefc,0x0060	/* addaw #96,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a4/a6,sp@-
	lea a6@(60),a4
	movel a6,sp@(8)
	movel a4@(440),d0
	beqs L8fa
	moveal d0,a0
	moveal a4@(432),a6
	jsr a6@(-72)
L8fa:
	clrl a4@(440)
	moveml sp@+,a4/a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	movel a4,sp@-
	lea a6@(60),a4
	movel a4@(4),d0
	moveal sp@+,a4
	.short 0x584f	/* addqw #4,sp */
	rts
L918:
	.short 0x514f	/* subqw #8,sp */
	movel a4,sp@-
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	lea a6@(60),a4
	movel a0,sp@(8)
	movel a6,sp@(4)
	tstl sp@(8)
	beqs L944
	.short 0x2079,0xffff,0xfffc	/* moveal 0xfffffffc,a0 */
	jsr a0@
	tstl d0
	beqs L944
	.short 0x7001	/* moveq #1,d0 */
	.byte 0x0c,0x40
L944:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a4
	.short 0x504f	/* addqw #8,sp */
	rts
L94c:
	.short 0x514f	/* subqw #8,sp */
	movel a4,sp@-
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	lea a6@(60),a4
	movel a0,sp@(8)
	movel a6,sp@(4)
	tstl sp@(8)
	beqs L970
	.short 0x2079,0xffff,0xfffc	/* moveal 0xfffffffc,a0 */
	jsr a0@
L970:
	moveal sp@+,a4
	.short 0x504f	/* addqw #8,sp */
	rts
	nop
	.data
	.byte 0x00,0x00,0x02,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x54,0x6f,0x6f,0x20,0x6d,0x61,0x6e,0x79
	.byte 0x20,0x6e,0x65,0x77,0x20,0x6c,0x69,0x6e,0x65,0x20,0x63,0x68,0x61,0x72,0x73,0x00
	.byte 0x00,0x00,0x00,0x08,0x43,0x6f,0x75,0x6c,0x64,0x6e,0x27,0x74,0x20,0x6f,0x70,0x65
	.byte 0x6e,0x20,0x51,0x75,0x69,0x63,0x6b,0x48,0x65,0x6c,0x70,0x5f,0x6c,0x69,0x62,0x2e
	.byte 0x63,0x61,0x74,0x61,0x6c,0x6f,0x67,0x00,0x00,0x00,0x00,0x24,0x43,0x6f,0x75,0x6c
	.byte 0x64,0x6e,0x27,0x74,0x20,0x6f,0x70,0x65,0x6e,0x20,0x6c,0x6f,0x63,0x61,0x6c,0x65
	.byte 0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00,0x00,0x00,0x00,0x4c,0x4e,0x6f
	.byte 0x20,0x74,0x65,0x78,0x74,0x00,0x00,0x00,0x00,0x6e,0x43,0x6f,0x75,0x6c,0x64,0x6e
	.byte 0x27,0x74,0x20,0x61,0x6c,0x6c,0x6f,0x63,0x20,0x6d,0x65,0x6d,0x6f,0x72,0x79,0x20
	.byte 0x66,0x6f,0x72,0x20,0x74,0x65,0x78,0x74,0x00,0x00,0x00,0x00,0x00,0x7a,0x4c,0x6f
	.byte 0x6e,0x67,0x65,0x73,0x74,0x20,0x74,0x65,0x78,0x74,0x20,0x69,0x73,0x20,0x74,0x6f
	.byte 0x6f,0x20,0x6c,0x6f,0x6e,0x67,0x00,0x00,0x00,0x00,0x00,0x9e,0x43,0x6f,0x75,0x6c
	.byte 0x64,0x6e,0x27,0x74,0x20,0x6f,0x70,0x65,0x6e,0x20,0x68,0x65,0x6c,0x70,0x20,0x77
	.byte 0x69,0x6e,0x64,0x6f,0x77,0x00,0x00,0x00,0x00,0xbc,0x00,0x24,0x56,0x45,0x52,0x3a
	.byte 0x20,0x71,0x75,0x69,0x63,0x6b,0x68,0x65,0x6c,0x70,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x20,0x33,0x39,0x2e,0x30,0x33,0x20,0x28,0x28,0x31,0x32,0x2e,0x32,0x2e
	.byte 0x39,0x39,0x29,0x20,0x31,0x39,0x3a,0x30,0x35,0x3a,0x34,0x31,0x29,0x00,0x00,0x00
	.byte 0x00,0xda,0x51,0x75,0x69,0x63,0x6b,0x48,0x65,0x6c,0x70,0x20,0xa9,0x20,0x50,0x61
	.byte 0x77,0x65,0xee,0x20,0x4d,0x61,0x72,0x63,0x69,0x6e,0x69,0x61,0x6b,0x20,0x31,0x39
	.byte 0x39,0x36,0x2d,0x31,0x39,0x39,0x37,0x00,0x00,0x00,0x01,0x12,0x67,0x72,0x61,0x70
	.byte 0x68,0x69,0x63,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00,0x69,0x6e
	.byte 0x74,0x75,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x75,0x74,0x69,0x6c,0x69,0x74,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x6c,0x6f,0x63,0x61,0x6c,0x65,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00
	.byte 0x71,0x75,0x69,0x63,0x6b,0x68,0x65,0x6c,0x70,0x5f,0x6c,0x69,0x62,0x2e,0x63,0x61
	.byte 0x74,0x61,0x6c,0x6f,0x67,0x00,0x65,0x6e,0x67,0x6c,0x69,0x73,0x68,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x09,0x00,0x00,0x01,0x38,0x00,0x00,0x01,0x0e,0x00,0x00,0x00,0xd6
	.byte 0x00,0x00,0x00,0xb8,0x00,0x00,0x00,0x9a,0x00,0x00,0x00,0x76,0x00,0x00,0x00,0x6a
	.byte 0x00,0x00,0x00,0x48,0x00,0x00,0x00,0x20
	.byte 0x00,0x00,0x00,0xd0,0x00,0x00,0x01,0xfe,0x00,0x00,0x02,0x68,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x04,0x8a,0x00,0x00,0x08,0xdc,0x00,0x00,0x09,0x06,0xff,0xff,0xff,0xff
	.byte 0x71,0x75,0x69,0x63,0x6b,0x68,0x65,0x6c,0x70,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x00,0x00,0x71,0x75,0x69,0x63,0x6b,0x68,0x65,0x6c,0x70,0x2e,0x6c,0x69
	.byte 0x62,0x72,0x61,0x72,0x79,0x20,0x33,0x37,0x2e,0x33,0x00,0x00
