	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x80,0x03
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x64,0x78,0x70
	.byte 0x6b,0x53,0x48,0x52,0x33,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20,0x78,0x70,0x6b,0x53,0x48,0x52,0x33,0x20,0x56,0x33,0x2e,0x30
	.byte 0x20,0x28,0x31,0x20,0x4f,0x63,0x74,0x20,0x32,0x30,0x31,0x33,0x29,0x20,0x62,0x79
	.byte 0x20,0x4d,0x61,0x74,0x74,0x68,0x69,0x61,0x73,0x20,0x4d,0x65,0x69,0x78,0x6e,0x65
	.byte 0x72,0x0d,0x0a,0x00,0x00,0x00,0x00,0x26,0x00,0x00,0x00,0x94,0x00,0x00,0x00,0x74
	.byte 0x00,0x00,0x00,0xac,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e,0xa0,0x0e
	.byte 0x06,0x00,0x90,0x14,0x00,0x03,0x90,0x16,0x00,0x00,0x80,0x18,0x00,0x00,0x00,0x2e
	.byte 0x00,0x00,0x00,0x00,0xff,0xff,0x00,0x2e,0x00,0x3c,0x00,0x4e,0xff,0x6c,0x00,0x8c
	.byte 0x01,0x08,0x00,0x94,0x00,0xac,0x06,0x9e,0x00,0x94,0xff,0xff
	moveal d0,a1
	movel a0,a1@(34)
	.short 0x2078,0x0004	/* moveal 0x4,a0 */
	.byte 0x08,0x28,0x00
Lb9:
	.byte 0x01,0x01,0x29	/* btst #1,a0@(297) */
	.short 0x6700,0xff42	/* beqw 0x0 */
	rts
	.byte 0x52,0x6e,0x00
Lc5:
	.byte 0x20	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	rts
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	.byte 0x66,0x00
Ld6:
	.byte 0xff,0x2a	/* bnew 0x0 */
	btst #3,a6@(14)
	.short 0x6700,0xff20	/* beqw 0x0 */
	tstw a6@(32)
	beqs Lf2
	bset #3,a6@(14)
	.short 0x6000,0xff10	/* braw 0x0 */
Lf2:
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
	.short 0x41fa,0x0ce0	/* lea %pc@(0xe02),a0 */
	movel a0,d0
	rts
	movel a0@(52),d0
	beqs L13e
	movel a6,sp@-
	moveal d0,a1
	movel a1@-,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L13e:
	rts
L140:
	moveml d2/a3,sp@-
	moveal a0@(52),a3
	.short 0x303c,0x03ff	/* movew #1023,d0 */
	moveal a3@(2020),a0
	.short 0x223c,0xffff,0x0000	/* movel #-65536,d1 */
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	.short 0x51c8,0xffee	/* dbf d0,0x156 */
	.short 0x703f	/* moveq #63,d0 */
	moveal a3@(2028),a0
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	.short 0x51c8,0xfff6	/* dbf d0,0x170 */
	bsrw Lb56
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrw Lc4c
	.short 0x42ab,0x0000	/* clrl a3@(0) */
	clrl a3@(4)
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@(8)
	moveml sp@+,d2/a3
	rts
	moveml d2-a0/a2-a6,sp@-
	moveal a0,a5
	tstl a5@(52)
	bnew L22c
	.short 0x700d	/* moveq #13,d0 */
	addl a5@(28),d0
	.short 0x80fc,0x000e	/* divuw #14,d0 */
	.short 0x41fa,0x0c28	/* lea %pc@(0xdde),a0 */
	.short 0x2630,0x0400	/* movel a0@(0,d0:w:4),d3 */
	.short 0x7444	/* moveq #68,d2 */
	addl d3,d2
	addl d3,d2
	addl d3,d2
	.short 0x0682,0x0000,0x8ffc	/* addil #36860,d2 */
	movel d2,d0
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	beqw L32e
	moveal d0,a3
	movel d2,a3@+
	.short 0x41f8,0x0400	/* lea 0x400,a0 */
	.short 0x0680,0x0000,0x07fc	/* addil #2044,d0 */
	movel d0,a3@(2020)
	.short 0x0680,0x0000,0x8000	/* addil #32768,d0 */
	movel d0,a3@(2028)
	addl a0,d0
	movel d0,a3@(2024)
	addl a0,d0
	movel d0,a3@(2012)
	addl d3,d0
	.short 0x0680,0x0000,0x0044	/* addil #68,d0 */
	movel d0,a3@(2016)
	.short 0x5383	/* subql #1,d3 */
	movel d3,a3@(2036)
	.short 0x70fc	/* moveq #-4,d0 */
	cmpw d0,d3
	blss L21e
	movew d0,d3
L21e:
	movel d3,a3@(2032)
	movel a3,a5@(52)
	moveal a5,a0
	bsrw L140
L22c:
	moveal a5@(52),a3
	movel a5@(4),d5
	movel a5@(28),d1
	.short 0x286d,0x0000	/* moveal a5@(0),a4 */
	moveal a5@(8),a5
	.short 0x4df5,0x5800	/* lea a5@(0,d5:l),a6 */
	movel a3@(12),d6
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7801	/* moveq #1,d4 */
	.short 0x538c	/* subql #1,a4 */
	tstl a3@(4)
	sne d0
	negb d0
	.short 0x5200	/* addqb #1,d0 */
	moveb d0,a5@+
L25a:
	cmpal a6,a5
	bccw L322
	bsrw L336
	movel a3@(8),d4
	bmis L27a
L26a:
	cmpl a3@(4),d4
	bhis L27a
	bsrw Lb9e
	movel d4,a3@(8)
	bras L26a
L27a:
	bsrw L564
	tstw d1
	beqs L28c
	.short 0x7800	/* moveq #0,d4 */
	movew d0,d4
	bsrw L3d6
	bras L2e6
L28c:
	bsrw L68e
	.short 0x5540	/* subqw #2,d0 */
	beqs L2a0
	bmis L2dc
	swap d0
	bsrw L474
	.short 0x7803	/* moveq #3,d4 */
	bras L2e6
L2a0:
	swap d0
	movew d0,d4
	.short 0x0640,0x02f2	/* addiw #754,d0 */
	movew a3@(0x10,d0:w:0x2),d2
	.short 0xc4eb,0x0012	/* muluw a3@(18),d2 */
	.short 0x323c,0x01f3	/* movew #499,d1 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@(1),d0
	addw d1,d0
	movew a3@(0x10,d0:w:0x2),d3
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@,d0
	addw d1,d0
	.short 0xc6f3,0x0210	/* muluw a3@(10,d0:w:2),d3 */
	cmpl d2,d3
	bccs L2dc
	movew d4,d0
	.short 0x0640,0x00ff	/* addiw #255,d0 */
	bsrw L4d0
	.short 0x7802	/* moveq #2,d4 */
	bras L2e6
L2dc:
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@,d0
	bsrw L4d0
	.short 0x7801	/* moveq #1,d4 */
L2e6:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L25a
	.short 0x5344	/* subqw #1,d4 */
	beqs L306
	moveal sp@(24),a0
	.short 0x2828,0x0000	/* movel a0@(0),d4 */
	addl a0@(4),d4
	subl a4,d4
	.short 0x5344	/* subqw #1,d4 */
	bsrs L336
L306:
	movel d7,a5@+
	cmpal a6,a5
	bccs L322
	movel d6,a3@(12)
	movel a5,d0
	moveml sp@+,d2-a0/a2-a6
	subl a0@(8),d0
	movel d0,a0@(16)
	.short 0x7000	/* moveq #0,d0 */
	rts
L322:
	moveml sp@+,d2-a0/a2-a6
	bsrw L140
	.short 0x70ef	/* moveq #-17,d0 */
	rts
L32e:
	moveml sp@+,d2-a0/a2-a6
	.short 0x70f9	/* moveq #-7,d0 */
	rts
L336:
	.short 0x5344	/* subqw #1,d4 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x528c	/* addql #1,a4 */
	moveal a4,a0
	.short 0x7400	/* moveq #0,d2 */
	moveb a0@+,d2
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	lslw #2,d0
	eorw d0,d2
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	aslw #4,d1
	moveb a0@,d0
	aslw #6,d0
	eorw d2,d0
	eorw d1,d0
	.short 0x0240,0x1fff	/* andiw #8191,d0 */
	.short 0x0242,0x00ff	/* andiw #255,d2 */
	moveal a3@(2020),a0
	movel d3,d1
	.short 0x92b0,0x0400	/* subl a0@(0,d0:w:4),d1 */
	.short 0x2183,0x0400	/* movel d3,a0@(0,d0:w:4) */
	cmpl a3@(2032),d1
	blss L378
	.short 0x7200	/* moveq #0,d1 */
L378:
	movel a3@(2036),d0
	andl d3,d0
	moveal a3@(2016),a0
	.short 0x3181,0x0a00	/* movew d1,a0@(0,d0:l:2) */
	moveal a3@(2028),a0
	movel d3,d1
	.short 0x92b0,0x2400	/* subl a0@(0,d2:w:4),d1 */
	.short 0x2183,0x2400	/* movel d3,a0@(0,d2:w:4) */
	.short 0x0c81,0x0000,0x01fc	/* cmpil #508,d1 */
	blss L39e
	.short 0x7200	/* moveq #0,d1 */
L39e:
	movel d3,d0
	.short 0x0240,0x01ff	/* andiw #511,d0 */
	moveal a3@(2024),a0
	.short 0x3181,0x0200	/* movew d1,a0@(0,d0:w:2) */
	moveal a3@(2012),a0
	movel a3@(2036),d0
	andl d3,d0
	.short 0x1194,0x0800	/* moveb a4@,a0@(0,d0:l) */
	.short 0x0c80,0x0000,0x0043	/* cmpil #67,d0 */
	bges L3ca
	addl a3@(2036),d0
	moveb a4@,a0@(0x1,d0:l)
L3ca:
	.short 0x5283	/* addql #1,d3 */
	.short 0x51cc,0xff6e	/* dbf d4,0x33c */
	.short 0x2743,0x0000	/* movel d3,a3@(0) */
	rts
L3d6:
	movel d4,sp@-
	movew d1,d3
	movew d0,d4
	.short 0x0c44,0x0043	/* cmpiw #67,d4 */
	bhis L460
	.short 0x5343	/* subqw #1,d3 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7004	/* moveq #4,d0 */
	bras L3f0
L3ea:
	subw d0,d3
	addw d0,d0
	.short 0x5242	/* addqw #1,d2 */
L3f0:
	cmpw d0,d3
	bccs L3ea
	.short 0x0c44,0x0007	/* cmpiw #7,d4 */
	bhis L426
	.short 0x7001	/* moveq #1,d0 */
	andw d3,d0
	addw d2,d2
	addw d0,d2
	.short 0x303b,0x4212	/* movew %pc@(0x416,d4:w:2),d0 */
	addw d2,d0
	bsrw L4d0
	lsrw #1,d3
	movew d3,d0
	lsrw #1,d2
	movew d2,d1
	.byte 0x60,0x5a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* bras 0x470 */
	movepl a4@(358),d0
	bclr d0,d2
	bclr d0,a6@+
L426:
	.short 0x5144	/* subqw #8,d4 */
	swap d3
	movew d2,d3
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7004	/* moveq #4,d0 */
	bras L438
L432:
	subw d0,d4
	addw d0,d0
	.short 0x5242	/* addqw #1,d2 */
L438:
	cmpw d0,d4
	bccs L432
	movew d2,d0
	lslw #3,d0
	subw d2,d0
	addw d0,d0
	addw d3,d0
	.short 0x0640,0x01ba	/* addiw #442,d0 */
	bsrw L4d0
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	movew d4,d0
	bsrs L4a4
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	swap d3
	movew d3,d0
	bras L470
L460:
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrs L4d0
	movew d4,d0
	.short 0x720f	/* moveq #15,d1 */
	bsrs L4a4
	movew d3,d0
	.short 0x720f	/* moveq #15,d1 */
L470:
	movel sp@+,d4
	bras L4a4
L474:
	.short 0x5340	/* subqw #1,d0 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7204	/* moveq #4,d1 */
	bras L482
L47c:
	subw d1,d0
	addw d1,d1
	.short 0x5242	/* addqw #1,d2 */
L482:
	cmpw d1,d0
	bccs L47c
	movew d0,d3
	.short 0x7003	/* moveq #3,d0 */
	andw d3,d0
	lslw #2,d2
	addw d0,d2
	lsrw #2,d3
	movew d2,d0
	.short 0x0640,0x0130	/* addiw #304,d0 */
	bsrs L4d0
	lsrw #2,d2
	beqs L4ce
	movew d3,d0
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
L4a4:
	.short 0x740f	/* moveq #15,d2 */
	subw d1,d2
	lslw d2,d0
	lsrl #1,d6
	addw d0,d0
	bccs L4ba
	addl d6,d7
	bccs L4ba
	moveal a5,a0
L4b6:
	.short 0x5220	/* addqb #1,a0@- */
	beqs L4b6
L4ba:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs L4ca
	roll #8,d7
	moveb d7,a5@+
	clrb d7
	lsll #8,d6
L4ca:
	.short 0x51c9,0xffde	/* dbf d1,0x4aa */
L4ce:
	rts
L4d0:
	moveml d2-d4,sp@-
	movew d0,d2
	.short 0x0642,0x01f3	/* addiw #499,d2 */
	moveaw a3@(0x10,d2:w:0x2),a2
	movew a3@(18),d3
	movew d3,d1
	.short 0x700a	/* moveq #10,d0 */
	lsrw d0,d1
	.short 0x5641	/* addqw #3,d1 */
	.short 0x7800	/* moveq #0,d4 */
L4ec:
	btst #0,d2
	beqs L4f6
	addw a3@(0xe,d2:w:0x2),d4
L4f6:
	addw d1,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	.short 0x0c42,0x0001	/* cmpiw #1,d2 */
	bnes L4ec
	addw d1,a3@(18)
	.short 0x7001	/* moveq #1,d0 */
	swap d0
	.short 0x80c3	/* divuw d3,d0 */
	movew d0,d2
	clrw d0
	.short 0x80c3	/* divuw d3,d0 */
	swap d6
	.short 0xc0c6	/* muluw d6,d0 */
	clrw d0
	swap d0
	movew d6,d1
	.short 0xc2c2	/* muluw d2,d1 */
	addl d1,d0
	swap d6
	.short 0xc4c6	/* muluw d6,d2 */
	clrw d2
	swap d2
	addl d0,d2
	movel d4,d0
	.short 0x4c02,0x0000	/* mulul d2,d0 */
	addl d0,d7
	bccs L53a
	moveal a5,a0
L536:
	.short 0x5220	/* addqb #1,a0@- */
	beqs L536
L53a:
	movel a2,d6
	.short 0x4c02,0x6006	/* mulul d2,d6 */
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss L54c
	bsrw Lc60
L54c:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs L55e
	roll #8,d7
	moveb d7,a5@+
	clrb d7
	lsll #8,d6
	bras L54c
L55e:
	moveml sp@+,d2-d4
	rts
L564:
	moveml d5-d7/a6,sp@-
	moveal a3@(2016),a2
	moveal a3@(2012),a6
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7e03	/* moveq #3,d7 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x5383	/* subql #1,d3 */
	andl a3@(2036),d3
	.short 0x7800	/* moveq #0,d4 */
	.short 0x3832,0x3a00	/* movew a2@(0,d3:l:2),d4 */
	beqw L60e
	.short 0x7043	/* moveq #67,d0 */
	cmpl d0,d5
	blss L590
	movew d0,d5
L590:
	cmpl a3@(2032),d4
	bhis L60e
	movel d3,d2
	subl d4,d2
	andl a3@(2036),d2
	cmpw d4,d7
	bhis L5b0
	movel d2,d0
	addl d7,d0
	.short 0x1036,0x0800	/* moveb a6@(0,d0:l),d0 */
	.short 0xb034,0x7000	/* cmpb a4@(0,d7:w),d0 */
	beqs L5be
L5b0:
	movel d7,d0
	subl d4,d0
	.short 0x1034,0x0800	/* moveb a4@(0,d0:l),d0 */
	.short 0xb034,0x7000	/* cmpb a4@(0,d7:w),d0 */
	bnes L602
L5be:
	.short 0x41f6,0x2800	/* lea a6@(0,d2:l),a0 */
	moveal a4,a1
	movew d5,d1
	.short 0x70ff	/* moveq #-1,d0 */
	cmpw d4,d1
	bhis L5d6
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x5cc */
	bras L5f6
L5d6:
	movew d4,d1
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x5d8 */
	cmpw d0,d4
	bnes L5f6
	movew d5,d1
	subw d4,d1
	moveal a4,a0
	.short 0x5389	/* subql #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x5ee */
L5f6:
	cmpw d0,d7
	bccs L602
	movew d4,d6
	movew d0,d7
	cmpw d0,d5
	blss L60e
L602:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x3032,0x2a00	/* movew a2@(0,d2:l:2),d0 */
	beqs L60e
	addl d0,d4
	bras L590
L60e:
	movew d7,d0
	.short 0x0c47,0x0043	/* cmpiw #67,d7 */
	bnes L61a
	movel sp@,d5
	bsrs L630
L61a:
	movew d6,d1
	.short 0x7404	/* moveq #4,d2 */
	cmpw d2,d0
	bnes L62a
	.short 0x0c41,0x7ffc	/* cmpiw #32764,d1 */
	blss L62a
	.short 0x7200	/* moveq #0,d1 */
L62a:
	moveml sp@+,d5-d7/a6
	rts
L630:
	.short 0x0c85,0x0000,0xfffc	/* cmpil #65532,d5 */
	bcss L63a
	.short 0x7afc	/* moveq #-4,d5 */
L63a:
	movel a3@(2036),d3
	.short 0x282b,0x0000	/* movel a3@(0),d4 */
	.short 0x5384	/* subql #1,d4 */
	subl d6,d4
	andl d3,d4
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a4,a1
	cmpw d6,d5
	bhis L664
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d1
	andl d3,d1
	.short 0x5244	/* addqw #1,d4 */
	.short 0x1236,0x1800	/* moveb a6@(0,d1:l),d1 */
	cmpb a1@+,d1
	.short 0x56cd,0xfff0	/* dbne d5,0x650 */
	rts
L664:
	movew d6,d2
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d1
	andl d3,d1
	.short 0x5244	/* addqw #1,d4 */
	.short 0x1236,0x1800	/* moveb a6@(0,d1:l),d1 */
	cmpb a1@+,d1
	.short 0x56ca,0xfff0	/* dbne d2,0x666 */
	cmpw d6,d0
	bnes L68c
	subw d6,d5
	moveal a4,a0
	.short 0x5389	/* subql #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a1@+,a0@+
	.short 0x56cd,0xfffa	/* dbne d5,0x684 */
L68c:
	rts
L68e:
	moveml d5-d6/a6,sp@-
	moveal a3@(2024),a2
	moveal a3@(2012),a6
	.short 0x7c01	/* moveq #1,d6 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x5383	/* subql #1,d3 */
	andl a3@(2036),d3
	movew d3,d0
	.short 0x0240,0x01ff	/* andiw #511,d0 */
	.short 0x3832,0x0200	/* movew a2@(0,d0:w:2),d4 */
	beqs L71c
	.short 0x7003	/* moveq #3,d0 */
	cmpl d0,d5
	blss L6ba
	movew d0,d5
L6ba:
	.short 0x0c44,0x01fc	/* cmpiw #508,d4 */
	bhis L71c
	movel d3,d2
	subl d4,d2
	andl a3@(2036),d2
	.short 0x41f6,0x2800	/* lea a6@(0,d2:l),a0 */
	moveal a4,a1
	movew d5,d1
	.short 0x70ff	/* moveq #-1,d0 */
	cmpw d4,d1
	bhis L6e0
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x6d6 */
	bras L700
L6e0:
	movew d4,d1
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x6e2 */
	cmpw d0,d4
	bnes L700
	movew d5,d1
	subw d4,d1
	moveal a4,a0
	.short 0x5389	/* subql #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x6f8 */
L700:
	cmpw d0,d6
	bccs L70e
	movew d4,d6
	swap d6
	movew d0,d6
	cmpw d0,d5
	blss L71c
L70e:
	.short 0x0242,0x01ff	/* andiw #511,d2 */
	.short 0x3032,0x2200	/* movew a2@(0,d2:w:2),d0 */
	beqs L71c
	addw d0,d4
	bras L6ba
L71c:
	movel d6,d0
	.short 0x5546	/* subqw #2,d6 */
	bnes L72c
	swap d6
	.short 0x0c46,0x0030	/* cmpiw #48,d6 */
	blss L72c
	.short 0x7000	/* moveq #0,d0 */
L72c:
	moveml sp@+,d5-d6/a6
	rts
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a5
	.short 0x286d,0x0000	/* moveal a5@(0),a4 */
	moveb a4@+,d3
	.short 0x0c03,0x0002	/* cmpib #2,d3 */
	blss L74c
	moveml sp@+,d2-d7/a2-a6
	.short 0x70e6	/* moveq #-26,d0 */
	rts
L74c:
	movel a5@(20),d4
	.short 0x0284,0x0000,0x0002	/* andil #2,d4 */
	seq d4
	negb d4
	tstl a5@(52)
	bnes L78a
	movel d4,d2
	swap d2
	.short 0x0682,0x0000,0x07e0	/* addil #2016,d2 */
	movel d2,d0
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	bnes L782
	moveml sp@+,d2-d7/a2-a6
	.short 0x70f9	/* moveq #-7,d0 */
	rts
L782:
	moveal d0,a3
	movel d2,a3@+
	movel a3,a5@(52)
L78a:
	moveal a5@(52),a3
	.short 0x45fa,0x0632	/* lea %pc@(0xdc2),a2 */
	.short 0x5303	/* subqb #1,d3 */
	bnes L7b0
	.short 0x42ab,0x0000	/* clrl a3@(0) */
	clrl a3@(4)
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@(8)
	bsrw Lb56
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrw Lc4c
L7b0:
	movel a5@(16),d5
	lea a3@(2012),a6
	movel a3@(12),d6
	moveal a5@(8),a5
	movel a4@+,d7
	tstb d4
	bnes L7ca
	bsrs L7da
	bras L7ce
L7ca:
	bsrw L994
L7ce:
	movel d6,a3@(12)
	moveml sp@+,d2-d7/a2-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
L7da:
	movel a3@(8),d4
	bmis L7f0
L7e0:
	cmpl a3@(4),d4
	bhis L7f0
	bsrw Lb9e
	movel d4,a3@(8)
	bras L7e0
L7f0:
	bsrw Lc8e
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bccs L802
	moveb d0,a5@+
	.short 0x7801	/* moveq #1,d4 */
	braw L96c
L802:
	moveal a5,a0
	.short 0x0c40,0x0130	/* cmpiw #304,d0 */
	bccs L81a
	.short 0x0440,0x00ff	/* subiw #255,d0 */
	subal d0,a0
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7802	/* moveq #2,d4 */
	braw L96c
L81a:
	.short 0x0c40,0x014c	/* cmpiw #332,d0 */
	bccs L850
	.short 0x0440,0x0130	/* subiw #304,d0 */
	.short 0x7803	/* moveq #3,d4 */
	movew d0,d3
	andw d4,d3
	movew d0,d2
	.short 0x7000	/* moveq #0,d0 */
	lsrw #2,d2
	beqs L83c
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
	bsrw Ld9e
	lslw #2,d0
L83c:
	addw d3,d0
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	.short 0x5240	/* addqw #1,d0 */
	subal d0,a0
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	braw L96c
L850:
	.short 0x0c40,0x0166	/* cmpiw #358,d0 */
	bccs L86c
	.short 0x0440,0x014c	/* subiw #332,d0 */
	bsrw L978
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7804	/* moveq #4,d4 */
	braw L96c
L86c:
	.short 0x0c40,0x0182	/* cmpiw #386,d0 */
	bccs L88a
	.short 0x0440,0x0166	/* subiw #358,d0 */
	bsrw L978
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7805	/* moveq #5,d4 */
	braw L96c
L88a:
	.short 0x0c40,0x019e	/* cmpiw #414,d0 */
	bccs L8aa
	.short 0x0440,0x0182	/* subiw #386,d0 */
	bsrw L978
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7806	/* moveq #6,d4 */
	braw L96c
L8aa:
	.short 0x0c40,0x01ba	/* cmpiw #442,d0 */
	bccs L8cc
	.short 0x0440,0x019e	/* subiw #414,d0 */
	bsrw L978
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7807	/* moveq #7,d4 */
	braw L96c
L8cc:
	.short 0x0c40,0x01f2	/* cmpiw #498,d0 */
	bccs L93c
	.short 0x0440,0x01ba	/* subiw #442,d0 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x163b,0x002a	/* moveb %pc@(0x904,d0:w),d3 */
	.short 0x7403	/* moveq #3,d2 */
	andw d3,d2
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ld9e
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	movel d0,d4
	.short 0x5084	/* addql #8,d4 */
	lsrw #2,d3
	movew d3,d2
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ld9e
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	.short 0x5240	/* addqw #1,d0 */
	bras L946
	.short 0x0004,0x080c	/* orib #12,d4 */
	moveb a4@,d0
	moveb a4@+,d4
	movel a4@-,d0
	movel a4@(12340),d4
	btst d0,d5
	movepw a5@(4373),d4
	moveb a5@+,a4@-
	movel a5@-,a0@-
	movel a5@(12597),a4@-
	.short 0x0206,0x0a0e	/* andib #14,d6 */
	moveb a6@,d1
	moveb a6@+,d5
	movel a6@-,d1
	movel a6@(12854),d5
	btst d1,d7
	movepw sp@(4887),d5
	moveb sp@+,a5@-
	movel sp@-,a1@-
	movel sp@(13111),a5@-
L93c:
	bsrw Ld9c
	movel d0,d4
	bsrw Ld9c
L946:
	subal d0,a0
	movew d4,d0
	movew d4,d1
	lsrw #3,d0
	.short 0x0241,0x0007	/* andiw #7,d1 */
	negw d1
	.short 0x4efb,0x1212	/* jmp %pc@(0x968,d1:w:2) */
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x51c8,0xffee	/* dbf d0,0x958 */
L96c:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L7da
	rts
L978:
	.short 0x7601	/* moveq #1,d3 */
	andw d0,d3
	movew d0,d1
	lsrw #1,d1
	movew d1,d2
	bsrw Ld9e
	addw d0,d0
	addw d3,d0
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	.short 0x5240	/* addqw #1,d0 */
	subal d0,a0
	rts
L994:
	movel a3@(8),d4
	bmis L9aa
L99a:
	cmpl a3@(4),d4
	bhis L9aa
	bsrw Lb9e
	movel d4,a3@(8)
	bras L99a
L9aa:
	bsrw Lc8e
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bccs L9ca
	.short 0x222b,0x0000	/* movel a3@(0),d1 */
	moveb d0,a5@+
	.short 0x1d80,0x1800	/* moveb d0,a6@(0,d1:l) */
	.short 0x5241	/* addqw #1,d1 */
	.short 0x2741,0x0000	/* movel d1,a3@(0) */
	.short 0x7801	/* moveq #1,d4 */
	braw Lb32
L9ca:
	.short 0x0c40,0x0130	/* cmpiw #304,d0 */
	bccs La00
	.short 0x0440,0x00ff	/* subiw #255,d0 */
	.short 0x7802	/* moveq #2,d4 */
	.short 0x242b,0x0000	/* movel a3@(0),d2 */
	movel d2,d1
	subw d0,d1
	.short 0x1036,0x1800	/* moveb a6@(0,d1:l),d0 */
	moveb d0,a5@+
	.short 0x1d80,0x2800	/* moveb d0,a6@(0,d2:l) */
	.short 0x5242	/* addqw #1,d2 */
	.short 0x5241	/* addqw #1,d1 */
	.short 0x1036,0x1800	/* moveb a6@(0,d1:l),d0 */
	moveb d0,a5@+
	.short 0x1d80,0x2800	/* moveb d0,a6@(0,d2:l) */
	.short 0x5242	/* addqw #1,d2 */
	.short 0x2742,0x0000	/* movel d2,a3@(0) */
	braw Lb32
La00:
	.short 0x0c40,0x014c	/* cmpiw #332,d0 */
	bccs La3a
	.short 0x0440,0x0130	/* subiw #304,d0 */
	.short 0x7803	/* moveq #3,d4 */
	movew d0,d3
	andw d4,d3
	movew d0,d2
	.short 0x7000	/* moveq #0,d0 */
	lsrw #2,d2
	beqs La22
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
	bsrw Ld9e
	lslw #2,d0
La22:
	addw d3,d0
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d3
	.short 0x5343	/* subqw #1,d3 */
	.short 0x242b,0x0000	/* movel a3@(0),d2 */
	movel d2,d1
	subw d0,d1
	braw Lb3e
La3a:
	.short 0x0c40,0x0166	/* cmpiw #358,d0 */
	bccs La4a
	.short 0x7804	/* moveq #4,d4 */
	.short 0x0440,0x014c	/* subiw #332,d0 */
	braw Laee
La4a:
	.short 0x0c40,0x0182	/* cmpiw #386,d0 */
	bccs La5a
	.short 0x7805	/* moveq #5,d4 */
	.short 0x0440,0x0166	/* subiw #358,d0 */
	braw Laee
La5a:
	.short 0x0c40,0x019e	/* cmpiw #414,d0 */
	bccs La6a
	.short 0x7806	/* moveq #6,d4 */
	.short 0x0440,0x0182	/* subiw #386,d0 */
	braw Laee
La6a:
	.short 0x0c40,0x01ba	/* cmpiw #442,d0 */
	bccs La78
	.short 0x7807	/* moveq #7,d4 */
	.short 0x0440,0x019e	/* subiw #414,d0 */
	bras Laee
La78:
	.short 0x0c40,0x01f2	/* cmpiw #498,d0 */
	bccs Lae2
	.short 0x0440,0x01ba	/* subiw #442,d0 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x163b,0x0024	/* moveb %pc@(0xaaa,d0:w),d3 */
	.short 0x7403	/* moveq #3,d2 */
	andw d3,d2
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ld9e
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	movel d0,d4
	.short 0x5084	/* addql #8,d4 */
	lsrw #2,d3
	movew d3,d2
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ld9e
	bras Lb00
	.short 0x0004,0x080c	/* orib #12,d4 */
	moveb a4@,d0
	moveb a4@+,d4
	movel a4@-,d0
	movel a4@(12340),d4
	btst d0,d5
	movepw a5@(4373),d4
	moveb a5@+,a4@-
	movel a5@-,a0@-
	movel a5@(12597),a4@-
	.short 0x0206,0x0a0e	/* andib #14,d6 */
	moveb a6@,d1
	moveb a6@+,d5
	movel a6@-,d1
	movel a6@(12854),d5
	btst d1,d7
	movepw sp@(4887),d5
	moveb sp@+,a5@-
	movel sp@-,a1@-
	movel sp@(13111),a5@-
Lae2:
	bsrw Ld9c
	movel d0,d4
	bsrw Ld9c
	bras Lb06
Laee:
	.short 0x7601	/* moveq #1,d3 */
	andw d0,d3
	movew d0,d1
	lsrw #1,d1
	movew d1,d2
	bsrw Ld9e
	addw d0,d0
	addw d3,d0
Lb00:
	.short 0xd072,0x2200	/* addw a2@(0,d2:w:2),d0 */
	.short 0x5240	/* addqw #1,d0 */
Lb06:
	movew d4,d3
	.short 0x5343	/* subqw #1,d3 */
	.short 0x242b,0x0000	/* movel a3@(0),d2 */
	movel d2,d1
	subw d0,d1
	movew d1,d0
	addw d4,d0
	bcss Lb3e
	movew d2,d0
	addw d4,d0
	bcss Lb3e
	.short 0x41f6,0x1800	/* lea a6@(0,d1:l),a0 */
	.short 0x43f6,0x2800	/* lea a6@(0,d2:l),a1 */
	.short 0x2740,0x0000	/* movel d0,a3@(0) */
	moveb a0@,a1@+
	moveb a0@+,a5@+
	.short 0x51cb,0xfffa	/* dbf d3,0xb2a */
Lb32:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L994
	rts
Lb3e:
	.short 0x1036,0x1800	/* moveb a6@(0,d1:l),d0 */
	moveb d0,a5@+
	.short 0x1d80,0x2800	/* moveb d0,a6@(0,d2:l) */
	.short 0x5242	/* addqw #1,d2 */
	.short 0x5241	/* addqw #1,d1 */
	.short 0x51cb,0xfff0	/* dbf d3,0xb3e */
	.short 0x2742,0x0000	/* movel d2,a3@(0) */
	bras Lb32
Lb56:
	.short 0x303c,0x03e6	/* movew #998,d0 */
	lea a3@(0x10,d0:w),a0
	moveal a0,a1
	.short 0x203c,0x0001,0x0001	/* movel #65537,d0 */
	.short 0x243c,0x0003,0x0003	/* movel #196611,d2 */
	.short 0x720f	/* moveq #15,d1 */
	movel d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xb6e */
	.short 0x722e	/* moveq #46,d1 */
	movew d2,a0@+
	movel d2,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xb78 */
	.short 0x723f	/* moveq #63,d1 */
	movew d0,a0@+
	movel d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xb82 */
	.short 0x7278	/* moveq #120,d1 */
	clrw a0@+
	clrl a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xb8c */
	.byte 0x27,0x7c,0x80,0x00,0x00,0x00,0x00,0x0c	/* movel #-2147483648,a3@(12) */
	braw Lc7e
Lb9e:
	movel d4,d2
	.short 0x5342	/* subqw #1,d2 */
	bpls Lba8
Lba4:
	.short 0x78ff	/* moveq #-1,d4 */
Lba6:
	rts
Lba8:
	.short 0x0c42,0x0030	/* cmpiw #48,d2 */
	bcss Lbbc
	beqs Lbb8
	movew d2,d4
	addw d4,d4
	.short 0x5a44	/* addqw #5,d4 */
	bras Lbc8
Lbb8:
	.short 0x783d	/* moveq #61,d4 */
	bras Lbc8
Lbbc:
	.short 0x5284	/* addql #1,d4 */
	movew d2,d0
	.short 0x0640,0x0100	/* addiw #256,d0 */
	bsrw Lc4c
Lbc8:
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7204	/* moveq #4,d1 */
	bras Lbd4
Lbce:
	subw d1,d2
	addw d1,d1
	.short 0x5243	/* addqw #1,d3 */
Lbd4:
	cmpw d1,d2
	bccs Lbce
	.short 0x0c43,0x000e	/* cmpiw #14,d3 */
	bccs Lba4
	tstw d2
	bnes Lba6
	movew d3,d2
	addw d2,d2
	.short 0x0c43,0x0007	/* cmpiw #7,d3 */
	bccs Lc04
	addw d2,d2
	.short 0x0642,0x0130	/* addiw #304,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	movew d3,d2
	addw d2,d2
Lc04:
	.short 0x0c43,0x000d	/* cmpiw #13,d3 */
	bccs Lc18
	.short 0x0642,0x014c	/* addiw #332,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	.short 0x0442,0x014d	/* subiw #333,d2 */
Lc18:
	.short 0x0642,0x0166	/* addiw #358,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	.short 0x0642,0x001b	/* addiw #27,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	.short 0x0642,0x001b	/* addiw #27,d2 */
	bsrs Lc4a
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc4a
	movew d3,d2
	.short 0x760e	/* moveq #14,d3 */
	.short 0x0642,0x01ba	/* addiw #442,d2 */
	bsrs Lc4a
	addw d3,d2
	bsrs Lc4a
	addw d3,d2
	bsrs Lc4a
	addw d3,d2
Lc4a:
	movew d2,d0
Lc4c:
	.short 0x0640,0x01f3	/* addiw #499,d0 */
Lc50:
	.short 0x5273,0x0210	/* addqw #1,a3@(10,d0:w:2) */
	lsrw #1,d0
	bnes Lc50
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss Lc8c
Lc60:
	.short 0x303c,0x03e6	/* movew #998,d0 */
	lea a3@(0x10,d0:w),a0
	moveal a0,a1
	.short 0x323c,0x01f2	/* movew #498,d1 */
	movew a0@+,d0
	beqs Lc7a
	lsrw #1,d0
	.short 0x5240	/* addqw #1,d0 */
	movew d0,a0@(-2)
Lc7a:
	.short 0x51c9,0xfff2	/* dbf d1,0xc6e */
Lc7e:
	.short 0x323c,0x01f1	/* movew #497,d1 */
	movew a0@-,d0
	addw a0@-,d0
	movew d0,a1@-
	.short 0x51c9,0xfff8	/* dbf d1,0xc82 */
Lc8c:
	rts
Lc8e:
	.short 0x307c,0x01f3	/* moveaw #499,a0 */
	movel d7,d0
	movel d6,d1
	swap d1
	.short 0x80c1	/* divuw d1,d0 */
	.short 0xc0eb,0x0012	/* muluw a3@(18),d0 */
	swap d0
	.short 0x7601	/* moveq #1,d3 */
	.short 0x7800	/* moveq #0,d4 */
Lca4:
	addw d3,d3
	movew a3@(0x10,d3:w:0x2),d1
	addw d4,d1
	cmpw d1,d0
	bcss Lcb4
	movew d1,d4
	.short 0x5243	/* addqw #1,d3 */
Lcb4:
	cmpw a0,d3
	bcss Lca4
	movew a3@(18),d1
	.short 0x7001	/* moveq #1,d0 */
	swap d0
	.short 0x80c1	/* divuw d1,d0 */
	movew d0,d2
	clrw d0
	.short 0x80c1	/* divuw d1,d0 */
	swap d6
	.short 0xc0c6	/* muluw d6,d0 */
	clrw d0
	swap d0
	movew d6,d1
	.short 0xc2c2	/* muluw d2,d1 */
	addl d1,d0
	swap d6
	.short 0xc4c6	/* muluw d6,d2 */
	clrw d2
	swap d2
	addl d0,d2
	movel d4,d0
	.short 0x4c02,0x0000	/* mulul d2,d0 */
	cmpl d7,d0
	bhis Ld0e
	moveal d0,a1
Lcec:
	addw a3@(0x10,d3:w:0x2),d4
	cmpw a3@(18),d4
	bccs Ld26
	movel d4,d0
	.short 0x4c02,0x0000	/* mulul d2,d0 */
	cmpl d0,d7
	bcss Ld26
	moveal d0,a1
	.short 0x5243	/* addqw #1,d3 */
	.short 0x0c43,0x03e6	/* cmpiw #998,d3 */
	bcss Lcec
	subw a0,d3
	bras Lcec
Ld0e:
	.short 0x5343	/* subqw #1,d3 */
	cmpw a0,d3
	bccs Ld16
	addw a0,d3
Ld16:
	subw a3@(0x10,d3:w:0x2),d4
	movel d4,d0
	.short 0x4c02,0x0000	/* mulul d2,d0 */
	cmpl d0,d7
	bcss Ld0e
	moveal d0,a1
Ld26:
	subl a1,d7
	movew a3@(0x10,d3:w:0x2),d4
	movel d4,d6
	.short 0x4c02,0x6006	/* mulul d2,d6 */
	subw a0,d3
	movew a3@(18),d0
	.short 0x720a	/* moveq #10,d1 */
	lsrw d1,d0
	.short 0x5640	/* addqw #3,d0 */
	movew a0,d2
	addw d3,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	lsrw #1,d2
	addw d0,a3@(0x10,d2:w:0x2)
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss Ld88
	bsrw Lc60
Ld88:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs Ld98
	lsll #8,d7
	lsll #8,d6
	moveb a4@+,d7
	bras Ld88
Ld98:
	movel d3,d0
	rts
Ld9c:
	.short 0x720f	/* moveq #15,d1 */
Ld9e:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x227c,0x0100,0x0000	/* moveal #16777216,a1 */
	addl d0,d0
	lsrl #1,d6
	cmpl d6,d7
	bcss Ldb2
	.short 0x5200	/* addqb #1,d0 */
	subl d6,d7
Ldb2:
	cmpl a1,d6
	bccs Ldbc
	lsll #8,d6
	lsll #8,d7
	moveb a4@+,d7
Ldbc:
	.short 0x51c9,0xffe8	/* dbf d1,0xda6 */
	rts
	.byte 0x00,0x00,0x00,0x04,0x00,0x0c,0x00,0x1c,0x00,0x3c,0x00,0x7c,0x00,0xfc,0x01,0xfc
	.byte 0x03,0xfc,0x07,0xfc,0x0f,0xfc,0x1f,0xfc,0x3f,0xfc,0x7f,0xfc,0x00,0x00,0x04,0x00
	.byte 0x00,0x00,0x04,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x20,0x00
	.byte 0x00,0x00,0x40,0x00,0x00,0x00,0x80,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00
	.byte 0x00,0x01,0x00,0x03,0x00,0x02,0x00,0x00,0x00,0x00,0x0f,0x7e,0x00,0x00,0x0f,0x85
	.byte 0x00,0x00,0x0f,0x96,0x53,0x48,0x52,0x33,0x00,0x02,0x80,0x09,0x7f,0xff,0xff,0xff
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x7f,0xfe,0x00,0x00,0x0f,0xcd,0x00,0x00,0x0f,0xd7
	.byte 0x00,0x00,0x0f,0xe3,0x00,0x00,0x0f,0xec,0x00,0x64,0x00,0x00,0x00,0x00,0x0e,0x5a
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0x84,0x00,0x00,0x00,0x0e
	.byte 0x00,0x00,0x00,0x01,0x00,0x00,0x9c,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x0a
	.byte 0x00,0x00,0x00,0x14,0x01,0xe2,0x00,0x00,0x77,0x6f,0x72,0x73,0x74,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x0e,0xae,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x01,0x00,0x00
	.byte 0xa8,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0x14,0x01,0xee
	.byte 0x00,0x00,0x62,0x61,0x64,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0xd8
	.byte 0x00,0x00,0x00,0x2a,0x00,0x00,0x00,0x01,0x00,0x00,0xc0,0x40,0x00,0x01,0x07,0xe0
	.byte 0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0x15,0x01,0xf8,0x00,0x00,0x61,0x76,0x65,0x72
	.byte 0x61,0x67,0x65,0x00,0x00,0x00,0x00,0x00,0x0f,0x02,0x00,0x00,0x00,0x38,0x00,0x00
	.byte 0x00,0x01,0x00,0x00,0xf0,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x09,0x00,0x00
	.byte 0x00,0x16,0x01,0xff,0x00,0x00,0x6e,0x6f,0x72,0x6d,0x61,0x6c,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x0f,0x2a,0x00,0x00,0x00,0x46,0x00,0x00,0x00,0x01,0x00,0x01,0x50,0x40
	.byte 0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x09,0x00,0x00,0x00,0x17,0x02,0x04,0x00,0x00
	.byte 0x67,0x6f,0x6f,0x64,0x00,0x00,0x00,0x00,0x00,0x00,0x0f,0x54,0x00,0x00,0x00,0x54
	.byte 0x00,0x00,0x00,0x01,0x00,0x02,0x10,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x08
	.byte 0x00,0x00,0x00,0x18,0x02,0x07,0x00,0x00,0x62,0x65,0x74,0x74,0x65,0x72,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x64,0x00,0x00,0x00,0x01,0x00,0x03
	.byte 0x90,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x18,0x02,0x0c
	.byte 0x00,0x00,0x62,0x65,0x73,0x74,0x00,0x00,0x00,0x00,0x00,0x00,0x53,0x68,0x72,0x69
	.byte 0x6e,0x6b,0x00,0x53,0x68,0x72,0x69,0x6e,0x6b,0x20,0x30,0x32,0x30,0x2b,0x20,0x56
	.byte 0x33,0x2e,0x30,0x00,0x53,0x68,0x72,0x69,0x6e,0x6b,0x20,0x73,0x6c,0x6f,0x77,0x20
	.byte 0x63,0x6f,0x6d,0x70,0x72,0x65,0x73,0x73,0x6f,0x72,0x20,0x77,0x69,0x74,0x68,0x20
	.byte 0x65,0x78,0x63,0x65,0x6c,0x6c,0x65,0x6e,0x74,0x20,0x63,0x6f,0x6d,0x70,0x72,0x65
	.byte 0x73,0x73,0x69,0x6f,0x6e,0x20,0x72,0x61,0x74,0x65,0x00,0x53,0x68,0x72,0x69,0x6e
	.byte 0x6b,0x69,0x6e,0x67,0x00,0x55,0x6e,0x73,0x68,0x72,0x69,0x6e,0x6b,0x69,0x6e,0x67
	.byte 0x00,0x53,0x68,0x72,0x69,0x6e,0x6b,0x65,0x64,0x00,0x55,0x6e,0x73,0x68,0x72,0x69
	.byte 0x6e,0x6b,0x65,0x64,0x00,0x01
