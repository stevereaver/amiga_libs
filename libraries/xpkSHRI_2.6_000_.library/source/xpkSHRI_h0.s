	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x80,0x02
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x64,0x78,0x70
	.byte 0x6b,0x53,0x48,0x52,0x49,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20,0x78,0x70,0x6b,0x53,0x48,0x52,0x49,0x20,0x56,0x32,0x2e,0x36
	.byte 0x20,0x28,0x31,0x20,0x4f,0x63,0x74,0x20,0x32,0x30,0x31,0x33,0x29,0x20,0x62,0x79
	.byte 0x20,0x4d,0x61,0x74,0x74,0x68,0x69,0x61,0x73,0x20,0x4d,0x65,0x69,0x78,0x6e,0x65
	.byte 0x72,0x0d,0x0a,0x00,0x00,0x00,0x00,0x26,0x00,0x00,0x00,0x94,0x00,0x00,0x00,0x74
	.byte 0x00,0x00,0x00,0xac,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e,0xa0,0x0e
	.byte 0x06,0x00,0x90,0x14,0x00,0x02,0x90,0x16,0x00,0x06,0x80,0x18,0x00,0x00,0x00,0x2e
	.byte 0x00,0x00,0x00,0x00,0xff,0xff,0x00,0x20,0x00,0x2e,0x00,0x40,0xff,0x6c,0x00,0x7e
	.byte 0x00,0xfa,0x00,0x86,0x00,0x9e,0x06,0xc0,0x00,0x86
	.byte 0xff,0xff,0x22,0x40
	movel a0,a1@(34)
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	.byte 0x08
Lb9:
	.byte 0xae,0x00,0x03,0x00,0x0e	/* bclr #3,a6@(14) */
	movel a6,d0
	rts
	.byte 0x53,0x6e,0x00
Lc5:
	.byte 0x20	/* subqw #1,a6@(32) */
	.short 0x6600,0xff38	/* bnew 0x0 */
	btst #3,a6@(14)
	.short 0x6700,0xff2e	/* beqw 0x0 */
	.byte 0x4a,0x6e
Ld6:
	.byte 0x00,0x20	/* tstw a6@(32) */
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
	.short 0x41fa,0x0d48	/* lea %pc@(0xe5c),a0 */
	movel a0,d0
	rts
	movel a0@(52),d0
	beqs L130
	movel a6,sp@-
	moveal d0,a1
	movel a1@-,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L130:
	rts
L132:
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
	.short 0x51c8,0xffee	/* dbf d0,0x148 */
	.short 0x703f	/* moveq #63,d0 */
	moveal a3@(2028),a0
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	movel d1,a0@+
	.short 0x51c8,0xfff6	/* dbf d0,0x162 */
	bsrw Lb96
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrw Lc8e
	.short 0x42ab,0x0000	/* clrl a3@(0) */
	clrl a3@(4)
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@(8)
	moveml sp@+,d2/a3
	rts
	moveml d2-a0/a2-a6,sp@-
	moveal a0,a5
	tstl a5@(52)
	bnew L220
	.short 0x700d	/* moveq #13,d0 */
	addl a5@(28),d0
	.short 0x80fc,0x000e	/* divuw #14,d0 */
	addw d0,d0
	addw d0,d0
	.short 0x41fa,0x0c8c	/* lea %pc@(0xe38),a0 */
	.short 0x2630,0x0000	/* movel a0@(0,d0:w),d3 */
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
	beqw L34a
	moveal d0,a3
	movel d2,a3@+
	.short 0x41f8,0x0400	/* lea 0x400,a0 */
	.short 0x7244	/* moveq #68,d1 */
	.short 0x0680,0x0000,0x07fc	/* addil #2044,d0 */
	movel d0,a3@(2020)
	.short 0x0680,0x0000,0x8000	/* addil #32768,d0 */
	movel d0,a3@(2028)
	addl a0,d0
	movel d0,a3@(2024)
	addl a0,d0
	movel d0,a3@(2012)
	addl d3,d0
	addl d1,d0
	movel d0,a3@(2016)
	.short 0x5383	/* subql #1,d3 */
	movel d3,a3@(2036)
	.short 0x70fc	/* moveq #-4,d0 */
	cmpw d0,d3
	blss L212
	movew d0,d3
L212:
	movel d3,a3@(2032)
	movel a3,a5@(52)
	moveal a5,a0
	bsrw L132
L220:
	moveal a5@(52),a3
	movel a5@(4),d5
	movel a5@(28),d1
	.short 0x286d,0x0000	/* moveal a5@(0),a4 */
	moveal a5@(8),a5
	.short 0x4df5,0x5800	/* lea a5@(0,d5:l),a6 */
	movel a3@(12),d6
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7801	/* moveq #1,d4 */
	.short 0x534c	/* subqw #1,a4 */
	tstl a3@(4)
	sne d0
	negb d0
	.short 0x5200	/* addqb #1,d0 */
	moveb d0,a5@+
	moveb d1,a5@+
	.short 0x0c85,0x0000,0x7fff	/* cmpil #32767,d5 */
	bhis L25c
	movew d5,a5@+
	bras L262
L25c:
	movel d5,d0
	negl d0
	movel d0,a5@+
L262:
	cmpal a6,a5
	bccw L33e
	bsrw L352
	movel a3@(8),d4
	bmis L282
L272:
	cmpl a3@(4),d4
	bhis L282
	bsrw Lbe0
	movel d4,a3@(8)
	bras L272
L282:
	bsrw L57c
	tstw d1
	beqs L294
	.short 0x7800	/* moveq #0,d4 */
	movew d0,d4
	bsrw L3fe
	bras L2f4
L294:
	bsrw L6ac
	.short 0x5540	/* subqw #2,d0 */
	beqs L2a8
	bmis L2ea
	swap d0
	bsrw L4a2
	.short 0x7803	/* moveq #3,d4 */
	bras L2f4
L2a8:
	.short 0x323c,0x01f3	/* movew #499,d1 */
	swap d0
	movew d0,d4
	.short 0x0640,0x02f2	/* addiw #754,d0 */
	addw d0,d0
	movew a3@(0x10,d0:w),d2
	.short 0xc4eb,0x0012	/* muluw a3@(18),d2 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@(1),d0
	addw d1,d0
	addw d0,d0
	movew a3@(0x10,d0:w),d3
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@,d0
	addw d1,d0
	addw d0,d0
	.short 0xc6f3,0x0010	/* muluw a3@(10,d0:w),d3 */
	cmpl d2,d3
	bccs L2ea
	movew d4,d0
	.short 0x0640,0x00ff	/* addiw #255,d0 */
	bsrw L500
	.short 0x7802	/* moveq #2,d4 */
	bras L2f4
L2ea:
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@,d0
	bsrw L500
	.short 0x7801	/* moveq #1,d4 */
L2f4:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L262
	.short 0x5344	/* subqw #1,d4 */
	beqs L314
	moveal sp@(24),a0
	.short 0x2828,0x0000	/* movel a0@(0),d4 */
	addl a0@(4),d4
	subl a4,d4
	.short 0x5344	/* subqw #1,d4 */
	bsrs L352
L314:
	swap d7
	movew d7,sp@-
	moveb sp@+,a5@+
	moveb d7,a5@+
	swap d7
	movew d7,sp@-
	moveb sp@+,a5@+
	moveb d7,a5@+
	cmpal a6,a5
	bccs L33e
	movel d6,a3@(12)
	movel a5,d0
	moveml sp@+,d2-a0/a2-a6
	subl a0@(8),d0
	movel d0,a0@(16)
	.short 0x7000	/* moveq #0,d0 */
	rts
L33e:
	moveml sp@+,d2-a0/a2-a6
	bsrw L132
	.short 0x70ef	/* moveq #-17,d0 */
	rts
L34a:
	moveml sp@+,d2-a0/a2-a6
	.short 0x70f9	/* moveq #-7,d0 */
	rts
L352:
	.short 0x5344	/* subqw #1,d4 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x524c	/* addqw #1,a4 */
	moveal a4,a0
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	moveb a0@+,d2
	moveb a0@+,d0
	addw d0,d0
	addw d0,d0
	eorw d0,d2
	moveb a0@+,d1
	moveb a0@,d0
	aslw #6,d0
	aslw #4,d1
	eorw d2,d0
	eorw d1,d0
	.short 0x0240,0x1fff	/* andiw #8191,d0 */
	.short 0x0242,0x00ff	/* andiw #255,d2 */
	moveal a3@(2020),a0
	addw d0,d0
	addaw d0,a0
	movel d3,d1
	.short 0x92b0,0x0000	/* subl a0@(0,d0:w),d1 */
	.short 0x2183,0x0000	/* movel d3,a0@(0,d0:w) */
	cmpl a3@(2032),d1
	blss L39a
	.short 0x7200	/* moveq #0,d1 */
L39a:
	movel a3@(2036),d0
	andl d3,d0
	addl d0,d0
	moveal a3@(2016),a0
	.short 0x3181,0x0800	/* movew d1,a0@(0,d0:l) */
	moveal a3@(2028),a0
	addw d2,d2
	addaw d2,a0
	movel d3,d1
	.short 0x92b0,0x2000	/* subl a0@(0,d2:w),d1 */
	.short 0x2183,0x2000	/* movel d3,a0@(0,d2:w) */
	.short 0x0c81,0x0000,0x01fc	/* cmpil #508,d1 */
	blss L3c6
	.short 0x7200	/* moveq #0,d1 */
L3c6:
	movel d3,d0
	.short 0x0240,0x01ff	/* andiw #511,d0 */
	addw d0,d0
	moveal a3@(2024),a0
	.short 0x3181,0x0000	/* movew d1,a0@(0,d0:w) */
	moveal a3@(2012),a0
	movel a3@(2036),d0
	andl d3,d0
	.short 0x1194,0x0800	/* moveb a4@,a0@(0,d0:l) */
	.short 0x7243	/* moveq #67,d1 */
	cmpl d1,d0
	bges L3f2
	addl a3@(2036),d0
	moveb a4@,a0@(0x1,d0:l)
L3f2:
	.short 0x5283	/* addql #1,d3 */
	.short 0x51cc,0xff62	/* dbf d4,0x358 */
	.short 0x2743,0x0000	/* movel d3,a3@(0) */
	rts
L3fe:
	movel d4,sp@-
	movew d1,d3
	movew d0,d4
	.short 0x0c44,0x0043	/* cmpiw #67,d4 */
	bhiw L48e
	.short 0x5343	/* subqw #1,d3 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7004	/* moveq #4,d0 */
	bras L41a
L414:
	subw d0,d3
	addw d0,d0
	.short 0x5242	/* addqw #1,d2 */
L41a:
	cmpw d0,d3
	bccs L414
	.short 0x0c44,0x0007	/* cmpiw #7,d4 */
	bhis L454
	.short 0x7001	/* moveq #1,d0 */
	andw d3,d0
	addw d2,d2
	addw d0,d2
	movew d4,d0
	addw d0,d0
	.short 0x303b,0x0812	/* movew %pc@(0x444,d0:l),d0 */
	addw d2,d0
	bsrw L500
	lsrw #1,d3
	movew d3,d0
	lsrw #1,d2
	movew d2,d1
	.byte 0x60,0x5a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* bras 0x49e */
	movepl a4@(358),d0
	bclr d0,d2
	bclr d0,a6@+
L454:
	.short 0x5144	/* subqw #8,d4 */
	swap d3
	movew d2,d3
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7004	/* moveq #4,d0 */
	bras L466
L460:
	subw d0,d4
	addw d0,d0
	.short 0x5242	/* addqw #1,d2 */
L466:
	cmpw d0,d4
	bccs L460
	movew d2,d0
	aslw #3,d0
	subw d2,d0
	addw d0,d0
	addw d3,d0
	.short 0x0640,0x01ba	/* addiw #442,d0 */
	bsrw L500
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	movew d4,d0
	bsrs L4d4
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	swap d3
	movew d3,d0
	bras L49e
L48e:
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrs L500
	movew d4,d0
	.short 0x720f	/* moveq #15,d1 */
	bsrs L4d4
	movew d3,d0
	.short 0x720f	/* moveq #15,d1 */
L49e:
	movel sp@+,d4
	bras L4d4
L4a2:
	.short 0x5340	/* subqw #1,d0 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7204	/* moveq #4,d1 */
	bras L4b0
L4aa:
	subw d1,d0
	addw d1,d1
	.short 0x5242	/* addqw #1,d2 */
L4b0:
	cmpw d1,d0
	bccs L4aa
	movew d0,d3
	.short 0x7003	/* moveq #3,d0 */
	andw d3,d0
	addw d2,d2
	addw d2,d2
	addw d0,d2
	lsrw #2,d3
	movew d2,d0
	.short 0x0640,0x0130	/* addiw #304,d0 */
	bsrs L500
	lsrw #2,d2
	beqs L4fe
	movew d3,d0
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
L4d4:
	.short 0x740f	/* moveq #15,d2 */
	subw d1,d2
	lslw d2,d0
	lsrl #1,d6
	addw d0,d0
	bccs L4ea
	addl d6,d7
	bccs L4ea
	moveal a5,a0
L4e6:
	.short 0x5220	/* addqb #1,a0@- */
	beqs L4e6
L4ea:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs L4fa
	roll #8,d7
	moveb d7,a5@+
	clrb d7
	lsll #8,d6
L4fa:
	.short 0x51c9,0xffde	/* dbf d1,0x4da */
L4fe:
	rts
L500:
	moveml d2-d4,sp@-
	movew d0,d2
	.short 0x0642,0x01f3	/* addiw #499,d2 */
	addw d2,d2
	.short 0x7600	/* moveq #0,d3 */
	movew a3@(0x10,d2:w),d3
	movew a3@(18),d4
	movew d4,d1
	.short 0x700a	/* moveq #10,d0 */
	lsrw d0,d1
	.short 0x5641	/* addqw #3,d1 */
	.short 0x7000	/* moveq #0,d0 */
L520:
	btst #1,d2
	beqs L52a
	addw a3@(0xe,d2:w),d0
L52a:
	addw d1,a3@(0x10,d2:w)
	lsrw #1,d2
	.short 0x0242,0xfffe	/* andiw #-2,d2 */
	.short 0x0c42,0x0002	/* cmpiw #2,d2 */
	bnes L520
	addw d1,a3@(18)
	movew d4,d1
	bsrw Ldf8
	addl d0,d7
	bccs L54e
	moveal a5,a0
L54a:
	.short 0x5220	/* addqb #1,a0@- */
	beqs L54a
L54e:
	movew d4,d1
	movel d3,d0
	bsrw Ldf8
	movel d0,d6
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss L564
	bsrw Lca8
L564:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs L576
	roll #8,d7
	moveb d7,a5@+
	clrb d7
	lsll #8,d6
	bras L564
L576:
	moveml sp@+,d2-d4
	rts
L57c:
	moveml d5-d7/a6,sp@-
	moveal a3@(2016),a2
	moveal a3@(2012),a6
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7e03	/* moveq #3,d7 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x5383	/* subql #1,d3 */
	andl a3@(2036),d3
	movel d3,d0
	addl d0,d0
	.short 0x7800	/* moveq #0,d4 */
	.short 0x3832,0x0800	/* movew a2@(0,d0:l),d4 */
	beqw L62c
	.short 0x7043	/* moveq #67,d0 */
	cmpl d0,d5
	blss L5ac
	movew d0,d5
L5ac:
	cmpl a3@(2032),d4
	bhis L62c
	movel d3,d2
	subl d4,d2
	andl a3@(2036),d2
	cmpw d4,d7
	bhis L5cc
	movel d2,d0
	addl d7,d0
	.short 0x1036,0x0800	/* moveb a6@(0,d0:l),d0 */
	.short 0xb034,0x7000	/* cmpb a4@(0,d7:w),d0 */
	beqs L5da
L5cc:
	movel d7,d0
	subl d4,d0
	.short 0x1034,0x0800	/* moveb a4@(0,d0:l),d0 */
	.short 0xb034,0x7000	/* cmpb a4@(0,d7:w),d0 */
	bnes L61e
L5da:
	.short 0x41f6,0x2800	/* lea a6@(0,d2:l),a0 */
	moveal a4,a1
	movew d5,d1
	.short 0x70ff	/* moveq #-1,d0 */
	cmpw d4,d1
	bhis L5f2
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x5e8 */
	bras L612
L5f2:
	movew d4,d1
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x5f4 */
	cmpw d0,d4
	bnes L612
	movew d5,d1
	subw d4,d1
	moveal a4,a0
	.short 0x5349	/* subqw #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x60a */
L612:
	cmpw d0,d7
	bccs L61e
	movew d4,d6
	movew d0,d7
	cmpw d0,d5
	blss L62c
L61e:
	addl d2,d2
	.short 0x7000	/* moveq #0,d0 */
	.short 0x3032,0x2800	/* movew a2@(0,d2:l),d0 */
	beqs L62c
	addl d0,d4
	bras L5ac
L62c:
	movew d7,d0
	.short 0x0c47,0x0043	/* cmpiw #67,d7 */
	bnes L638
	movel sp@,d5
	bsrs L64e
L638:
	movew d6,d1
	.short 0x7404	/* moveq #4,d2 */
	cmpw d2,d0
	bnes L648
	.short 0x0c41,0x7ffc	/* cmpiw #32764,d1 */
	blss L648
	.short 0x7200	/* moveq #0,d1 */
L648:
	moveml sp@+,d5-d7/a6
	rts
L64e:
	.short 0x0c85,0x0000,0xfffc	/* cmpil #65532,d5 */
	bcss L658
	.short 0x7afc	/* moveq #-4,d5 */
L658:
	movel a3@(2036),d3
	.short 0x282b,0x0000	/* movel a3@(0),d4 */
	.short 0x5384	/* subql #1,d4 */
	subl d6,d4
	andl d3,d4
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a4,a1
	cmpw d6,d5
	bhis L682
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d1
	andl d3,d1
	.short 0x5244	/* addqw #1,d4 */
	.short 0x1236,0x1800	/* moveb a6@(0,d1:l),d1 */
	cmpb a1@+,d1
	.short 0x56cd,0xfff0	/* dbne d5,0x66e */
	rts
L682:
	movew d6,d2
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d1
	andl d3,d1
	.short 0x5244	/* addqw #1,d4 */
	.short 0x1236,0x1800	/* moveb a6@(0,d1:l),d1 */
	cmpb a1@+,d1
	.short 0x56ca,0xfff0	/* dbne d2,0x684 */
	cmpw d6,d0
	bnes L6aa
	subw d6,d5
	moveal a4,a0
	.short 0x5349	/* subqw #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a1@+,a0@+
	.short 0x56cd,0xfffa	/* dbne d5,0x6a2 */
L6aa:
	rts
L6ac:
	moveml d5-d6/a6,sp@-
	moveal a3@(2024),a2
	moveal a3@(2012),a6
	.short 0x7c01	/* moveq #1,d6 */
	.short 0x262b,0x0000	/* movel a3@(0),d3 */
	.short 0x5383	/* subql #1,d3 */
	andl a3@(2036),d3
	movew d3,d0
	.short 0x0240,0x01ff	/* andiw #511,d0 */
	addw d0,d0
	.short 0x3832,0x0000	/* movew a2@(0,d0:w),d4 */
	beqs L73e
	.short 0x7003	/* moveq #3,d0 */
	cmpl d0,d5
	blss L6da
	movew d0,d5
L6da:
	.short 0x0c44,0x01fc	/* cmpiw #508,d4 */
	bhis L73e
	movel d3,d2
	subl d4,d2
	andl a3@(2036),d2
	.short 0x41f6,0x2800	/* lea a6@(0,d2:l),a0 */
	moveal a4,a1
	movew d5,d1
	.short 0x70ff	/* moveq #-1,d0 */
	cmpw d4,d1
	bhis L700
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x6f6 */
	bras L720
L700:
	movew d4,d1
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x702 */
	cmpw d0,d4
	bnes L720
	movew d5,d1
	subw d4,d1
	moveal a4,a0
	.short 0x5349	/* subqw #1,a1 */
	.short 0x5340	/* subqw #1,d0 */
	.short 0x5240	/* addqw #1,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c9,0xfffa	/* dbne d1,0x718 */
L720:
	cmpw d0,d6
	bccs L72e
	movew d4,d6
	swap d6
	movew d0,d6
	cmpw d0,d5
	blss L73e
L72e:
	.short 0x0242,0x01ff	/* andiw #511,d2 */
	addw d2,d2
	.short 0x3032,0x2000	/* movew a2@(0,d2:w),d0 */
	beqs L73e
	addw d0,d4
	bras L6da
L73e:
	movel d6,d0
	.short 0x5546	/* subqw #2,d6 */
	bnes L74e
	swap d6
	.short 0x0c46,0x0030	/* cmpiw #48,d6 */
	blss L74e
	.short 0x7000	/* moveq #0,d0 */
L74e:
	moveml sp@+,d5-d6/a6
	rts
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a5
	.short 0x286d,0x0000	/* moveal a5@(0),a4 */
	moveb a4@+,d3
	.short 0x524c	/* addqw #1,a4 */
	.short 0x0c03,0x0002	/* cmpib #2,d3 */
	blss L770
	moveml sp@+,d2-d7/a2-a6
	.short 0x70e6	/* moveq #-26,d0 */
	rts
L770:
	movel a5@(20),d4
	.short 0x0284,0x0000,0x0002	/* andil #2,d4 */
	seq d4
	negb d4
	tstl a5@(52)
	bnes L7ae
	movel d4,d2
	swap d2
	.short 0x0682,0x0000,0x07e0	/* addil #2016,d2 */
	movel d2,d0
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	bnes L7a6
	moveml sp@+,d2-d7/a2-a6
	.short 0x70f9	/* moveq #-7,d0 */
	rts
L7a6:
	moveal d0,a3
	movel d2,a3@+
	movel a3,a5@(52)
L7ae:
	moveal a5@(52),a3
	.short 0x45fa,0x0668	/* lea %pc@(0xe1c),a2 */
	.short 0x5303	/* subqb #1,d3 */
	bnes L7d4
	.short 0x42ab,0x0000	/* clrl a3@(0) */
	clrl a3@(4)
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@(8)
	bsrw Lb96
	.short 0x303c,0x01f2	/* movew #498,d0 */
	bsrw Lc8e
L7d4:
	.short 0x7a00	/* moveq #0,d5 */
	movew a4@+,d5
	bpls L7e0
	swap d5
	movew a4@+,d5
	negl d5
L7e0:
	movel a4@+,d7
	lea a3@(2012),a6
	movel a3@(12),d6
	moveal a5@(8),a5
	tstb d4
	bnes L7f6
	bsrs L806
	bras L7fa
L7f6:
	bsrw L9cc
L7fa:
	movel d6,a3@(12)
	moveml sp@+,d2-d7/a2-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
L806:
	movel a3@(8),d4
	bmis L81c
L80c:
	cmpl a3@(4),d4
	bhis L81c
	bsrw Lbe0
	movel d4,a3@(8)
	bras L80c
L81c:
	bsrw Lcd6
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bccs L82e
	moveb d0,a5@+
	.short 0x7801	/* moveq #1,d4 */
	braw L9a2
L82e:
	moveal a5,a0
	.short 0x0c40,0x0130	/* cmpiw #304,d0 */
	bccs L846
	.short 0x0440,0x00ff	/* subiw #255,d0 */
	subal d0,a0
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7802	/* moveq #2,d4 */
	braw L9a2
L846:
	.short 0x0c40,0x014c	/* cmpiw #332,d0 */
	bccs L880
	.short 0x0440,0x0130	/* subiw #304,d0 */
	.short 0x7803	/* moveq #3,d4 */
	movew d0,d3
	andw d4,d3
	movew d0,d2
	.short 0x7000	/* moveq #0,d0 */
	lsrw #2,d2
	beqs L86a
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
	bsrw Ldce
	addw d0,d0
	addw d0,d0
L86a:
	addw d3,d0
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	.short 0x5240	/* addqw #1,d0 */
	subal d0,a0
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	braw L9a2
L880:
	.short 0x0c40,0x0166	/* cmpiw #358,d0 */
	bccs L89c
	.short 0x0440,0x014c	/* subiw #332,d0 */
	bsrw L9ae
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7804	/* moveq #4,d4 */
	braw L9a2
L89c:
	.short 0x0c40,0x0182	/* cmpiw #386,d0 */
	bccs L8ba
	.short 0x0440,0x0166	/* subiw #358,d0 */
	bsrw L9ae
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7805	/* moveq #5,d4 */
	braw L9a2
L8ba:
	.short 0x0c40,0x019e	/* cmpiw #414,d0 */
	bccs L8da
	.short 0x0440,0x0182	/* subiw #386,d0 */
	bsrw L9ae
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7806	/* moveq #6,d4 */
	braw L9a2
L8da:
	.short 0x0c40,0x01ba	/* cmpiw #442,d0 */
	bccs L8fc
	.short 0x0440,0x019e	/* subiw #414,d0 */
	bsrw L9ae
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x7807	/* moveq #7,d4 */
	braw L9a2
L8fc:
	.short 0x0c40,0x01f2	/* cmpiw #498,d0 */
	bccs L970
	.short 0x0440,0x01ba	/* subiw #442,d0 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x163b,0x002e	/* moveb %pc@(0x938,d0:w),d3 */
	.short 0x7403	/* moveq #3,d2 */
	andw d3,d2
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ldce
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	movel d0,d4
	.short 0x5084	/* addql #8,d4 */
	lsrw #2,d3
	movew d3,d2
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ldce
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	.short 0x5240	/* addqw #1,d0 */
	bras L97a
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
L970:
	bsrw Ldcc
	movel d0,d4
	bsrw Ldcc
L97a:
	subal d0,a0
	movew d4,d0
	movew d4,d1
	lsrw #3,d0
	.short 0x0241,0x0007	/* andiw #7,d1 */
	addw d1,d1
	negw d1
	.short 0x4efb,0x1012	/* jmp %pc@(0x99e,d1:w) */
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	moveb a0@+,a5@+
	.short 0x51c8,0xffee	/* dbf d0,0x98e */
L9a2:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L806
	rts
L9ae:
	.short 0x7601	/* moveq #1,d3 */
	andw d0,d3
	movew d0,d1
	lsrw #1,d1
	movew d1,d2
	bsrw Ldce
	addw d0,d0
	addw d3,d0
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	.short 0x5240	/* addqw #1,d0 */
	subal d0,a0
	rts
L9cc:
	movel a3@(8),d4
	bmis L9e2
L9d2:
	cmpl a3@(4),d4
	bhis L9e2
	bsrw Lbe0
	movel d4,a3@(8)
	bras L9d2
L9e2:
	bsrw Lcd6
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bccs La02
	.short 0x222b,0x0000	/* movel a3@(0),d1 */
	moveb d0,a5@+
	.short 0x1d80,0x1800	/* moveb d0,a6@(0,d1:l) */
	.short 0x5241	/* addqw #1,d1 */
	.short 0x2741,0x0000	/* movel d1,a3@(0) */
	.short 0x7801	/* moveq #1,d4 */
	braw Lb72
La02:
	.short 0x0c40,0x0130	/* cmpiw #304,d0 */
	bccs La38
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
	braw Lb72
La38:
	.short 0x0c40,0x014c	/* cmpiw #332,d0 */
	bccs La76
	.short 0x0440,0x0130	/* subiw #304,d0 */
	.short 0x7803	/* moveq #3,d4 */
	movew d0,d3
	andw d4,d3
	movew d0,d2
	.short 0x7000	/* moveq #0,d0 */
	lsrw #2,d2
	beqs La5c
	movew d2,d1
	.short 0x5341	/* subqw #1,d1 */
	bsrw Ldce
	addw d0,d0
	addw d0,d0
La5c:
	addw d3,d0
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	.short 0x5240	/* addqw #1,d0 */
	movew d4,d3
	.short 0x5343	/* subqw #1,d3 */
	.short 0x242b,0x0000	/* movel a3@(0),d2 */
	movel d2,d1
	subw d0,d1
	braw Lb7e
La76:
	.short 0x0c40,0x0166	/* cmpiw #358,d0 */
	bccs La86
	.short 0x7804	/* moveq #4,d4 */
	.short 0x0440,0x014c	/* subiw #332,d0 */
	braw Lb2c
La86:
	.short 0x0c40,0x0182	/* cmpiw #386,d0 */
	bccs La96
	.short 0x7805	/* moveq #5,d4 */
	.short 0x0440,0x0166	/* subiw #358,d0 */
	braw Lb2c
La96:
	.short 0x0c40,0x019e	/* cmpiw #414,d0 */
	bccs Laa6
	.short 0x7806	/* moveq #6,d4 */
	.short 0x0440,0x0182	/* subiw #386,d0 */
	braw Lb2c
Laa6:
	.short 0x0c40,0x01ba	/* cmpiw #442,d0 */
	bccs Lab4
	.short 0x7807	/* moveq #7,d4 */
	.short 0x0440,0x019e	/* subiw #414,d0 */
	bras Lb2c
Lab4:
	.short 0x0c40,0x01f2	/* cmpiw #498,d0 */
	bccs Lb20
	.short 0x0440,0x01ba	/* subiw #442,d0 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x163b,0x0026	/* moveb %pc@(0xae8,d0:w),d3 */
	.short 0x7403	/* moveq #3,d2 */
	andw d3,d2
	movew d2,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ldce
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	movel d0,d4
	.short 0x5084	/* addql #8,d4 */
	lsrw #2,d3
	movew d3,d2
	movew d3,d1
	.short 0x5241	/* addqw #1,d1 */
	bsrw Ldce
	bras Lb3e
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
Lb20:
	bsrw Ldcc
	movel d0,d4
	bsrw Ldcc
	bras Lb46
Lb2c:
	.short 0x7601	/* moveq #1,d3 */
	andw d0,d3
	movew d0,d1
	lsrw #1,d1
	movew d1,d2
	bsrw Ldce
	addw d0,d0
	addw d3,d0
Lb3e:
	addw d2,d2
	.short 0xd072,0x2000	/* addw a2@(0,d2:w),d0 */
	.short 0x5240	/* addqw #1,d0 */
Lb46:
	movew d4,d3
	.short 0x5343	/* subqw #1,d3 */
	.short 0x242b,0x0000	/* movel a3@(0),d2 */
	movel d2,d1
	subw d0,d1
	movew d1,d0
	addw d4,d0
	bcss Lb7e
	movew d2,d0
	addw d4,d0
	bcss Lb7e
	.short 0x41f6,0x1800	/* lea a6@(0,d1:l),a0 */
	.short 0x43f6,0x2800	/* lea a6@(0,d2:l),a1 */
	.short 0x2740,0x0000	/* movel d0,a3@(0) */
	moveb a0@,a1@+
	moveb a0@+,a5@+
	.short 0x51cb,0xfffa	/* dbf d3,0xb6a */
Lb72:
	addl d4,a3@(4)
	subl d4,d5
	bgtw L9cc
	rts
Lb7e:
	.short 0x1036,0x1800	/* moveb a6@(0,d1:l),d0 */
	moveb d0,a5@+
	.short 0x1d80,0x2800	/* moveb d0,a6@(0,d2:l) */
	.short 0x5242	/* addqw #1,d2 */
	.short 0x5241	/* addqw #1,d1 */
	.short 0x51cb,0xfff0	/* dbf d3,0xb7e */
	.short 0x2742,0x0000	/* movel d2,a3@(0) */
	bras Lb72
Lb96:
	.short 0x303c,0x03e6	/* movew #998,d0 */
	lea a3@(0x10,d0:w),a0
	moveal a0,a1
	.short 0x203c,0x0001,0x0001	/* movel #65537,d0 */
	.short 0x243c,0x0003,0x0003	/* movel #196611,d2 */
	.short 0x720f	/* moveq #15,d1 */
	movel d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xbae */
	.short 0x722e	/* moveq #46,d1 */
	movew d2,a0@+
	movel d2,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xbb8 */
	.short 0x723f	/* moveq #63,d1 */
	movew d0,a0@+
	movel d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xbc2 */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7278	/* moveq #120,d1 */
	movew d0,a0@+
	movel d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xbce */
	.byte 0x27,0x7c,0x80,0x00,0x00,0x00,0x00,0x0c	/* movel #-2147483648,a3@(12) */
	braw Lcc6
Lbe0:
	movel d4,d2
	.short 0x5342	/* subqw #1,d2 */
	bpls Lbea
Lbe6:
	.short 0x78ff	/* moveq #-1,d4 */
Lbe8:
	rts
Lbea:
	.short 0x0c42,0x0030	/* cmpiw #48,d2 */
	bcss Lbfe
	beqs Lbfa
	movew d2,d4
	addw d4,d4
	.short 0x5a44	/* addqw #5,d4 */
	bras Lc0a
Lbfa:
	.short 0x783d	/* moveq #61,d4 */
	bras Lc0a
Lbfe:
	.short 0x5284	/* addql #1,d4 */
	movew d2,d0
	.short 0x0640,0x0100	/* addiw #256,d0 */
	bsrw Lc8e
Lc0a:
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7204	/* moveq #4,d1 */
	bras Lc16
Lc10:
	subw d1,d2
	addw d1,d1
	.short 0x5243	/* addqw #1,d3 */
Lc16:
	cmpw d1,d2
	bccs Lc10
	.short 0x0c43,0x000e	/* cmpiw #14,d3 */
	bccs Lbe6
	tstw d2
	bnes Lbe8
	movew d3,d2
	addw d2,d2
	.short 0x0c43,0x0007	/* cmpiw #7,d3 */
	bccs Lc46
	addw d2,d2
	.short 0x0642,0x0130	/* addiw #304,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	movew d3,d2
	addw d2,d2
Lc46:
	.short 0x0c43,0x000d	/* cmpiw #13,d3 */
	bccs Lc5a
	.short 0x0642,0x014c	/* addiw #332,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	.short 0x0442,0x014d	/* subiw #333,d2 */
Lc5a:
	.short 0x0642,0x0166	/* addiw #358,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	.short 0x0642,0x001b	/* addiw #27,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	.short 0x0642,0x001b	/* addiw #27,d2 */
	bsrs Lc8c
	.short 0x5242	/* addqw #1,d2 */
	bsrs Lc8c
	movew d3,d2
	.short 0x760e	/* moveq #14,d3 */
	.short 0x0642,0x01ba	/* addiw #442,d2 */
	bsrs Lc8c
	addw d3,d2
	bsrs Lc8c
	addw d3,d2
	bsrs Lc8c
	addw d3,d2
Lc8c:
	movew d2,d0
Lc8e:
	.short 0x0640,0x01f3	/* addiw #499,d0 */
	addw d0,d0
	.short 0x72fe	/* moveq #-2,d1 */
Lc96:
	.short 0x5273,0x0010	/* addqw #1,a3@(10,d0:w) */
	lsrw #1,d0
	andw d1,d0
	bnes Lc96
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss Lcd4
Lca8:
	.short 0x303c,0x03e6	/* movew #998,d0 */
	lea a3@(0x10,d0:w),a0
	moveal a0,a1
	.short 0x323c,0x01f2	/* movew #498,d1 */
	movew a0@+,d0
	beqs Lcc2
	lsrw #1,d0
	.short 0x5240	/* addqw #1,d0 */
	movew d0,a0@(-2)
Lcc2:
	.short 0x51c9,0xfff2	/* dbf d1,0xcb6 */
Lcc6:
	.short 0x323c,0x01f1	/* movew #497,d1 */
	movew a0@-,d0
	addw a0@-,d0
	movew d0,a1@-
	.short 0x51c9,0xfff8	/* dbf d1,0xcca */
Lcd4:
	rts
Lcd6:
	.short 0x307c,0x03e6	/* moveaw #998,a0 */
	movel d7,d0
	movel d6,d1
	swap d1
	.short 0x80c1	/* divuw d1,d0 */
	.short 0xc0eb,0x0012	/* muluw a3@(18),d0 */
	swap d0
	.short 0x7602	/* moveq #2,d3 */
	.short 0x7800	/* moveq #0,d4 */
Lcec:
	addw d3,d3
	movew a3@(0x10,d3:w),d1
	addw d4,d1
	cmpw d1,d0
	bcss Lcfc
	movew d1,d4
	.short 0x5443	/* addqw #2,d3 */
Lcfc:
	cmpw a0,d3
	bcss Lcec
	bsrw Ldf2
	cmpl d7,d0
	bhis Ld2a
	moveal d0,a1
Ld0a:
	addw a3@(0x10,d3:w),d4
	cmpw a3@(18),d4
	bccs Ld40
	bsrw Ldf2
	cmpl d0,d7
	bcss Ld40
	moveal d0,a1
	.short 0x5443	/* addqw #2,d3 */
	.short 0x0c43,0x07cc	/* cmpiw #1996,d3 */
	bcss Ld0a
	subw a0,d3
	bras Ld0a
Ld2a:
	.short 0x5543	/* subqw #2,d3 */
	cmpw a0,d3
	bccs Ld32
	addw a0,d3
Ld32:
	subw a3@(0x10,d3:w),d4
	bsrw Ldf2
	cmpl d0,d7
	bcss Ld2a
	moveal d0,a1
Ld40:
	subl a1,d7
	movew a3@(0x10,d3:w),d4
	bsrw Ldf2
	movel d0,d6
	subw a0,d3
	movew a3@(18),d0
	.short 0x720a	/* moveq #10,d1 */
	lsrw d1,d0
	.short 0x5640	/* addqw #3,d0 */
	movew a0,d2
	addw d3,d2
	.short 0x72fe	/* moveq #-2,d1 */
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	lsrw #1,d2
	andw d1,d2
	addw d0,a3@(0x10,d2:w)
	.short 0x0c6b,0x2000,0x0012	/* cmpiw #8192,a3@(18) */
	bcss Ldb6
	bsrw Lca8
Ldb6:
	.short 0x0c86,0x0100,0x0000	/* cmpil #16777216,d6 */
	bccs Ldc6
	lsll #8,d7
	lsll #8,d6
	moveb a4@+,d7
	bras Ldb6
Ldc6:
	movel d3,d0
	lsrw #1,d0
	rts
Ldcc:
	.short 0x720f	/* moveq #15,d1 */
Ldce:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x227c,0x0100,0x0000	/* moveal #16777216,a1 */
	addl d0,d0
	lsrl #1,d6
	cmpl d6,d7
	bcss Lde2
	.short 0x5200	/* addqb #1,d0 */
	subl d6,d7
Lde2:
	cmpl a1,d6
	bccs Ldec
	lsll #8,d6
	lsll #8,d7
	moveb a4@+,d7
Ldec:
	.short 0x51c9,0xffe8	/* dbf d1,0xdd6 */
	rts
Ldf2:
	movel d4,d0
	movew a3@(18),d1
Ldf8:
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
	addl d2,d0
	rts
	.byte 0x00,0x00,0x00,0x04,0x00,0x0c,0x00,0x1c,0x00,0x3c,0x00,0x7c,0x00,0xfc,0x01,0xfc
	.byte 0x03,0xfc,0x07,0xfc,0x0f,0xfc,0x1f,0xfc,0x3f,0xfc,0x7f,0xfc,0x00,0x00,0x04,0x00
	.byte 0x00,0x00,0x04,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x20,0x00
	.byte 0x00,0x00,0x40,0x00,0x00,0x00,0x80,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x00
	.byte 0x00,0x01,0x00,0x02,0x00,0x02,0x00,0x00,0x00,0x00,0x0f,0xd8,0x00,0x00,0x0f,0xdf
	.byte 0x00,0x00,0x0f,0xeb,0x53,0x48,0x52,0x49,0x00,0x02,0x80,0x09,0x7f,0xff,0xff,0xff
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x7f,0xfe,0x00,0x00,0x10,0x22,0x00,0x00,0x10,0x2c
	.byte 0x00,0x00,0x10,0x38,0x00,0x00,0x10,0x41,0x00,0x64,0x00,0x00,0x00,0x00,0x0e,0xb4
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0xde,0x00,0x00,0x00,0x0e
	.byte 0x00,0x00,0x00,0x01,0x00,0x00,0x9c,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x09
	.byte 0x00,0x00,0x00,0x0e,0x01,0xe1,0x00,0x00,0x77,0x6f,0x72,0x73,0x74,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x0f,0x08,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x01,0x00,0x00
	.byte 0xa8,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x09,0x00,0x00,0x00,0x0f,0x01,0xee
	.byte 0x00,0x00,0x62,0x61,0x64,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f,0x32
	.byte 0x00,0x00,0x00,0x2a,0x00,0x00,0x00,0x01,0x00,0x00,0xc0,0x40,0x00,0x01,0x07,0xe0
	.byte 0x00,0x00,0x00,0x09,0x00,0x00,0x00,0x0f,0x01,0xf8,0x00,0x00,0x61,0x76,0x65,0x72
	.byte 0x61,0x67,0x65,0x00,0x00,0x00,0x00,0x00,0x0f,0x5c,0x00,0x00,0x00,0x38,0x00,0x00
	.byte 0x00,0x01,0x00,0x00,0xf0,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x09,0x00,0x00
	.byte 0x00,0x10,0x01,0xff,0x00,0x00,0x6e,0x6f,0x72,0x6d,0x61,0x6c,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x0f,0x84,0x00,0x00,0x00,0x46,0x00,0x00,0x00,0x01,0x00,0x01,0x50,0x40
	.byte 0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x11,0x02,0x04,0x00,0x00
	.byte 0x67,0x6f,0x6f,0x64,0x00,0x00,0x00,0x00,0x00,0x00,0x0f,0xae,0x00,0x00,0x00,0x54
	.byte 0x00,0x00,0x00,0x01,0x00,0x02,0x10,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x07
	.byte 0x00,0x00,0x00,0x11,0x02,0x07,0x00,0x00,0x62,0x65,0x74,0x74,0x65,0x72,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x64,0x00,0x00,0x00,0x01,0x00,0x03
	.byte 0x90,0x40,0x00,0x01,0x07,0xe0,0x00,0x00,0x00,0x06,0x00,0x00,0x00,0x12,0x02,0x0c
	.byte 0x00,0x00,0x62,0x65,0x73,0x74,0x00,0x00,0x00,0x00,0x00,0x00,0x53,0x68,0x72,0x69
	.byte 0x6e,0x6b,0x00,0x53,0x68,0x72,0x69,0x6e,0x6b,0x20,0x56,0x32,0x2e,0x36,0x00,0x53
	.byte 0x68,0x72,0x69,0x6e,0x6b,0x20,0x73,0x6c,0x6f,0x77,0x20,0x63,0x6f,0x6d,0x70,0x72
	.byte 0x65,0x73,0x73,0x6f,0x72,0x20,0x77,0x69,0x74,0x68,0x20,0x65,0x78,0x63,0x65,0x6c
	.byte 0x6c,0x65,0x6e,0x74,0x20,0x63,0x6f,0x6d,0x70,0x72,0x65,0x73,0x73,0x69,0x6f,0x6e
	.byte 0x20,0x72,0x61,0x74,0x65,0x00,0x53,0x68,0x72,0x69,0x6e,0x6b,0x69,0x6e,0x67,0x00
	.byte 0x55,0x6e,0x73,0x68,0x72,0x69,0x6e,0x6b,0x69,0x6e,0x67,0x00,0x53,0x68,0x72,0x69
	.byte 0x6e,0x6b,0x65,0x64,0x00,0x55,0x6e,0x73,0x68,0x72,0x69,0x6e,0x6b,0x65,0x64,0x00
