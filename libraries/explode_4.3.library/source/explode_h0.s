	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00
	.byte 0x00,0x04,0x00,0x00,0x05,0x5c,0x80,0x04
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00
	.byte 0x00,0x2e,0x00,0x00,0x00,0x6e,0x65,0x78
	.byte 0x70,0x6c,0x6f,0x64,0x65,0x2e,0x6c,0x69
	.byte 0x62,0x72,0x61,0x72,0x79,0x00,0x45,0x78
	.byte 0x65,0x63,0x75,0x74,0x61,0x62,0x6c,0x65
	.byte 0x20,0x66,0x69,0x6c,0x65,0x20,0x65,0x78
	.byte 0x70,0x6c,0x6f,0x64,0x65,0x72,0x20,0x56
	.byte 0x34,0x2e,0x33,0x20,0x28,0x32,0x39,0x20
	.byte 0x4d,0x61,0x79,0x20,0x31,0x39,0x38,0x39
	.byte 0x29,0x20,0xa9,0x20,0x44,0x53,0x49,0x0d
	.byte 0x0a,0x00
L62:
	.byte 0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x00,0x00,0x00,0x36
	.byte 0x00,0x00,0x00,0x7e,0x00,0x00,0x00,0x96
	.byte 0x00,0x00,0x00,0xc2,0x00,0x00,0x01,0x68
	.byte 0x00,0x00,0x01,0x70,0x00,0x00,0x01,0x70
	.byte 0x00,0x00,0x01,0x70,0x00,0x00,0x01,0xca
	.byte 0xff,0xff,0xff,0xff,0xe0,0x00,0x00,0x0c
	.byte 0x09,0x00,0xc0,0x00,0x00,0x0a,0x00,0x00
	.byte 0x00,0x1e,0xe0,0x00,0x00,0x0e,0x06,0x00
	.byte 0xd0,0x00,0x00,0x14,0x00,0x04,0xd0,0x00
	.byte 0x00,0x16,0x00,0x03,0xc0,0x00,0x00,0x18
	.byte 0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x00
	movel a5,sp@-
	moveal d0,a5
	.short 0x3b7c,0x0001,0x0020	/* movew #1,a5@(32) */
	movel a0,a5@(38)
	lea %pc@(L62),a1
	.short 0x7021	/* moveq #33,d0 */
	moveal 0x4,a6
	jsr a6@(-552)
	movel d0,a5@(34)
	bnes Lfa
Le4:
	moveml d7/a5-a6,sp@-
	.short 0x2e3c,0x0003,0x8007	/* movel #229383,d7 */
	moveal 0x4,a6
	jsr a6@(-108)
	moveml sp@+,d7/a5-a6
Lfa:
	moveal a5@(34),a0
	.short 0xd0fc,0xff6a	/* addaw #-150,a0 */
	lea %pc@(L174),a1
	.short 0x0c50,0x4ef9	/* cmpiw #20217,a0@ */
	bnes L116
	movel a0@(2),a1@(4)
	.short 0x7202	/* moveq #2,d1 */
	bras L12e
L116:
	.short 0x0c18,0x0070	/* cmpib #112,a0@+ */
	bnes Le4
	moveb a0@+,a1@(1)
	.short 0x0c58,0x6000	/* cmpiw #24576,a0@+ */
	bnes Le4
	addaw a0@,a0
	movel a0,a1@(4)
	.short 0x7200	/* moveq #0,d1 */
L12e:
	lea a5@(46),a0
	clrl a0@
	lea %pc@(L1a2),a1
	movel a0,a1@(2)
	lea a5@(50),a0
	clrl a0@
	lea %pc@(L4c4),a1
	movel a0,a1@(2)
	clrl a5@(42)
	moveal a5@(34),a1
	.short 0x307c,0xff6a	/* moveaw #-150,a0 */
	.short 0x203c,0x0000,0x0174	/* movel #372,d0 */
	addl d1,d0
	jsr a6@(-420)
	movel a5,d0
	moveal sp@+,a5
	rts
	.short 0x52ae,0x002a	/* addql #1,a6@(42) */
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L174:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x4eb9,0x0000,0x0000	/* jsr 0x0 */
	moveml d0/a0,sp@-
	lsll #2,d0
	moveal d0,a0
	.byte 0x0c,0xa8,0x48,0xe7,0xff,0xff,0x00,0x04	/* cmpil #1223163903,a0@(4) */
	bnes L1c2
	.byte 0x0c,0xa8,0x65,0x78,0x70,0x6c,0x00,0x28	/* cmpil #1702391916,a0@(40) */
	bnes L1c2
	.byte 0x0c,0xa8,0x61,0x72,0x79,0x00,0x00,0x34	/* cmpil #1634892032,a0@(52) */
	bnes L1c2
L1a2:
	.short 0x52b9,0x00c2,0x3456	/* addql #1,0xc23456 */
	moveml d1-d7/a1-a6,sp@-
	lea a0@(32),a5
	.short 0x9efc,0x0044	/* subaw #68,sp */
	moveal sp,a4
	bsrw L212
	.short 0xdefc,0x0044	/* addaw #68,sp */
	moveml sp@+,d1-d7/a1-a6
L1c2:
	moveml sp@+,d0/a0
	tstl d0
	rts
	moveal sp@+,a5
	.short 0x9efc,0x0044	/* subaw #68,sp */
	moveal sp,a4
	subal a1,a1
	moveal 0x4,a6
	jsr a6@(-294)
	movel d0,a4@(60)
	moveal d0,a1
	.short 0x700f	/* moveq #15,d0 */
	jsr a6@(-300)
	movew d0,a4@(58)
	bsrs L212
	moveal a4@(60),a1
	movew a4@(58),d0
	moveal 0x4,a6
	jsr a6@(-300)
	.short 0x7c00	/* moveq #0,d6 */
	bsrw L4cc
	.short 0xdefc,0x0044	/* addaw #68,sp */
	movel a1,sp@(60)
	moveml sp@+,d0-a6
	rts
L212:
	movel a5,sp@-
	clrl a4@(64)
	lea %pc@(L4e4),a0
	movel a0@+,a4@(8)
	lea a4@(12),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	moveb a5@,d0
	lsrb #4,d0
	moveb d0,a1@-
	moveb a5@+,d0
	.short 0x0240,0x000f	/* andiw #15,d0 */
	muluw #12,d0
	moveb a5@+,a4@(2)
	movew a5@+,a4@
	movel a5@,a4@(4)
	clrb a4@(3)
	lea %pc@(L4f0),a0
	addaw d0,a0
	lea a4@(36),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@
	lea a4@(36),a0
	lea a4@(20),a1
	.short 0x7207	/* moveq #7,d1 */
	moveb a0@+,d0
	bpls L26a
	bclr #7,d0
	.short 0x5000	/* addqb #8,d0 */
L26a:
	.short 0x7400	/* moveq #0,d2 */
	bset d0,d2
	tstl a4@(4)
	bpls L276
	.short 0x5342	/* subqw #1,d2 */
L276:
	movew d2,a1@+
	.short 0x51c9,0xffe6	/* dbf d1,0x19e */
	lea a4@(20),a0
	lea a4@(28),a1
	.short 0x7203	/* moveq #3,d1 */
	movew a0@+,d0
	addw d0,a1@+
	.short 0x51c9,0xfffa	/* dbf d1,0x1c4 */
	bclr #31,a4@(4)
	moveal sp@+,a0
	lea a0@(-32),a2
	movel a2,a4@(52)
	.short 0x70ff	/* moveq #-1,d0 */
L2a0:
	.short 0x5240	/* addqw #1,d0 */
	movel a2@,d1
	lsll #2,d1
	moveal d1,a2
	bnes L2a0
	movew d0,a4@(56)
	.short 0x536c,0x0038	/* subqw #1,a4@(56) */
	movew d0,d6
	bsrw L4cc
	moveal a1,a6
	moveal a6,a2
	movel a1@(-8),d0
	.short 0x5180	/* subql #8,d0 */
	movel d0,d4
	.short 0x5346	/* subqw #1,d6 */
	bsrw L4cc
	movel a1@(-8),d0
	.short 0x5180	/* subql #8,d0 */
	tstb a0@(-23)
	beqs L2dc
	.short 0x5980	/* subql #4,d0 */
	orb a0@(-23),d0
L2dc:
	moveal a1,a0
	addal d0,a0
	.short 0x7a00	/* moveq #0,d5 */
L2e2:
	movew d5,d6
	bsrw L4cc
	moveal a1,a3
L2ea:
	bsrs L326
	bpls L2fa
	.short 0x5245	/* addqw #1,d5 */
	cmpw a4@(56),d5
	bnes L2e2
	braw L4a0
L2fa:
	addl d0,d0
	bpls L31e
L2fe:
	bsrs L326
	movel d0,d1
	beqs L2ea
	bsrs L326
	movew d0,d6
	bsrw L4cc
	movel a1,d3
	.short 0x7400	/* moveq #0,d2 */
L310:
	bsrs L326
	addl d0,d2
	addl d3,a3@(0x0,d2:l)
	.short 0x5381	/* subql #1,d1 */
	bnes L310
	bras L2fe
L31e:
	beqs L2ea
	moveal a3,a1
	bsrs L32c
	bras L2ea
L326:
	lea a4@(48),a1
	.short 0x7002	/* moveq #2,d0 */
L32c:
	cmpal a6,a2
	beqs L344
L330:
	moveb a2@-,a1@+
	moveb a2@-,a1@+
	moveb a2@-,a1@+
	moveb a2@-,a1@+
	.short 0x58ac,0x0040	/* addql #4,a4@(64) */
	.short 0x5580	/* subql #2,d0 */
	bnes L32c
	movel a1@-,d0
	rts
L344:
	addal d4,a2
	moveml d0-d3/d5-d6/a3,sp@-
	moveal a2,a3
	movew d4,d5
	movew a4@,d2
	moveb a4@(2),d1
	moveb a4@(3),d0
	bnew L480
L35c:
	tstw d2
	beqs L36c
L360:
	.short 0x5345	/* subqw #1,d5 */
	bmiw L48e
	moveb a0@-,a3@-
	.short 0x5342	/* subqw #1,d2 */
	bnes L360
L36c:
	.short 0x53ac,0x0004	/* subql #1,a4@(4) */
	beqw L48e
	addb d1,d1
	bnes L37c
	moveb a0@-,d1
	addxb d1,d1
L37c:
	bccs L3e2
	addb d1,d1
	bnes L386
	moveb a0@-,d1
	addxb d1,d1
L386:
	bccs L3dc
	addb d1,d1
	bnes L390
	moveb a0@-,d1
	addxb d1,d1
L390:
	bccs L3d6
	addb d1,d1
	bnes L39a
	moveb a0@-,d1
	addxb d1,d1
L39a:
	bccs L3d0
	addb d1,d1
	bnes L3a4
	moveb a0@-,d1
	addxb d1,d1
L3a4:
	bccs L3ac
	moveb a0@-,d0
	.short 0x7e03	/* moveq #3,d7 */
	bras L3e6
L3ac:
	addb d1,d1
	bnes L3b4
	moveb a0@-,d1
	addxb d1,d1
L3b4:
	addxb d0,d0
	addb d1,d1
	bnes L3be
	moveb a0@-,d1
	addxb d1,d1
L3be:
	addxb d0,d0
	addb d1,d1
	bnes L3c8
	moveb a0@-,d1
	addxb d1,d1
L3c8:
	addxb d0,d0
	.short 0x5c00	/* addqb #6,d0 */
	.short 0x7e03	/* moveq #3,d7 */
	bras L3e6
L3d0:
	.short 0x7005	/* moveq #5,d0 */
	.short 0x7e03	/* moveq #3,d7 */
	bras L3e6
L3d6:
	.short 0x7004	/* moveq #4,d0 */
	.short 0x7e02	/* moveq #2,d7 */
	bras L3e6
L3dc:
	.short 0x7003	/* moveq #3,d0 */
	.short 0x7e01	/* moveq #1,d7 */
	bras L3e6
L3e2:
	.short 0x7002	/* moveq #2,d0 */
	.short 0x7e00	/* moveq #0,d7 */
L3e6:
	movew d7,d3
	addb d1,d1
	bnes L3f0
	moveb a0@-,d1
	addxb d1,d1
L3f0:
	bccs L406
	addb d1,d1
	bnes L3fa
	moveb a0@-,d1
	addxb d1,d1
L3fa:
	bccs L412
	.short 0x7c00	/* moveq #0,d6 */
	moveb a4@(0x8,d7:w),d6
	.short 0x5807	/* addqb #4,d7 */
	bras L414
L406:
	addb d1,d1
	bnes L40e
	moveb a0@-,d1
	addxb d1,d1
L40e:
	addxw d2,d2
	bras L428
L412:
	.short 0x7c02	/* moveq #2,d6 */
L414:
	moveb a4@(0xc,d7:w),d7
L418:
	addb d1,d1
	bnes L420
	moveb a0@-,d1
	addxb d1,d1
L420:
	addxw d2,d2
	.short 0x5307	/* subqb #1,d7 */
	bnes L418
	addw d6,d2
L428:
	.short 0x7c00	/* moveq #0,d6 */
	moveaw d6,a5
	movew d3,d7
	addb d1,d1
	bnes L436
	moveb a0@-,d1
	addxb d1,d1
L436:
	bccs L452
	addw d3,d3
	addb d1,d1
	bnes L442
	moveb a0@-,d1
	addxb d1,d1
L442:
	bccs L44c
	moveaw a4@(0x1c,d3:w),a5
	.short 0x5007	/* addqb #8,d7 */
	bras L452
L44c:
	moveaw a4@(0x14,d3:w),a5
	.short 0x5807	/* addqb #4,d7 */
L452:
	moveb a4@(0x24,d7:w),d7
	bpls L460
	moveb a0@-,d6
	.short 0x0207,0x007f	/* andib #127,d7 */
	beqs L46e
L460:
	addb d1,d1
	bnes L468
	moveb a0@-,d1
	addxb d1,d1
L468:
	addxw d6,d6
	.short 0x5307	/* subqb #1,d7 */
	bnes L460
L46e:
	.short 0x5246	/* addqw #1,d6 */
	addaw d6,a5
	addal a3,a5
	cmpal a2,a5
	blss L47a
	subaw d4,a5
L47a:
	cmpal a5,a6
	bnes L480
	moveal a2,a5
L480:
	.short 0x5345	/* subqw #1,d5 */
	bmis L48e
	moveb a5@-,a3@-
	.short 0x5300	/* subqb #1,d0 */
	bnes L47a
	braw L35c
L48e:
	moveb d0,a4@(3)
	moveb d1,a4@(2)
	movew d2,a4@
	moveml sp@+,d0-d3/d5-d6/a3
	braw L330
L4a0:
	movew a4@(56),d6
	.short 0x5246	/* addqw #1,d6 */
	moveal 0x4,a6
L4aa:
	bsrs L4cc
	.short 0x5189	/* subql #8,a1 */
	movel a1@,d0
	jsr a6@(-210)
	.short 0x5346	/* subqw #1,d6 */
	cmpw a4@(56),d6
	bccs L4aa
	bsrs L4cc
	clrl a1@-
	movel a4@(64),d0
L4c4:
	.short 0xd1b9,0x00c2,0x3456	/* addl d0,0xc23456 */
	rts
L4cc:
	movew d6,d7
	moveal a4@(52),a1
	.short 0x5347	/* subqw #1,d7 */
	bmis L4e0
	moveal a1@,a1
	addal a1,a1
	addal a1,a1
	.short 0x51cf,0xfff8	/* dbf d7,0x414 */
L4e0:
	.short 0x5889	/* addql #4,a1 */
	rts
L4e4:
	.short 0x060a
	.short 0x0a12,0x0203	/* eorib #3,a2@ */
	btst d1,d4
	.short 0x0405,0x0700	/* subib #0,d5 */
L4f0:
	btst d2,d5
	btst d2,d5
	btst d2,d5
	btst d2,d5
	.short 0x0606,0x0606	/* addib #6,d6 */
	btst d2,d6
	btst d3,d7
	.short 0x0606,0x0606	/* addib #6,d6 */
	btst d3,d7
	.short 0x0606,0x0506	/* addib #6,d6 */
	btst d3,d7
	btst d3,d7
	btst d3,d7
	orl d0,d0
	orl d0,d0
	btst d2,d6
	bclr d3,d0
	btst d3,d7
	orl d0,d0
	orl d1,d0
	.short 0x8181
	.short 0x0607,0x0780	/* addib #-128,d7 */
	bclr d3,d0
	.short 0x8181
	orl d1,d0
	orl d2,d1
	.short 0x0607,0x0780	/* addib #-128,d7 */
	bclr d3,d1
	.short 0x8182
	orl d2,d0
	.short 0x8383
	.short 0x0607,0x0780	/* addib #-128,d7 */
	bclr d3,d1
	.short 0x8182
	orl d2,d0
	orl d4,d2
	.short 0x0607,0x0780	/* addib #-128,d7 */
	bclr d3,d1
	orl d2,d1
	orl d3,d0
	orl d5,d2
	.short 0x0607,0x0780	/* addib #-128,d7 */
	bclr d3,d1
	orl d3,d1
	orl d3,d0
	.short 0x8586
