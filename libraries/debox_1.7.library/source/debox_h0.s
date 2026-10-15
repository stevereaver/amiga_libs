	.text
	.byte 0x61,0x00,0x01,0x56,0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x08,0x00,0x00
	.byte 0x0c,0xd2,0x00,0x01,0x09,0x00,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x30,0x00,0x00
	.byte 0x01,0xe8,0x64,0x65,0x62,0x6f,0x78,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x64,0x65,0x62,0x6f,0x78,0x20,0x31,0x2e,0x37,0x20,0x28,0x30,0x31,0x20,0x4f,0x43
	.byte 0x54,0x20,0x39,0x30,0x29,0x0d,0x0a,0x00,0x00,0x00,0x57,0x72,0x69,0x74,0x74,0x65
	.byte 0x6e,0x20,0x62,0x79,0x20,0x57,0x69,0x6c,0x6c,0x69,0x61,0x6d,0x20,0x41,0x2e,0x20
	.byte 0x57,0x61,0x72,0x65,0x0d,0x0a,0x44,0x65,0x73,0x69,0x67,0x6e,0x65,0x64,0x20,0x62
	.byte 0x79,0x20,0x52,0x2e,0x20,0x4b,0x2e,0x20,0x56,0x6f,0x6e,0x20,0x57,0x6f,0x6c,0x66
	.byte 0x73,0x68,0x65,0x69,0x6c,0x64,0x2e,0x0d,0x0a,0x43,0x6f,0x70,0x79,0x72,0x69,0x67
	.byte 0x68,0x74,0x20,0xa9,0x20,0x31,0x39,0x39,0x30,0x2c,0x20,0x53,0x69,0x6c,0x65,0x6e
	.byte 0x74,0x20,0x53,0x6f,0x66,0x74,0x77,0x61,0x72,0x65,0x2c,0x20,0x49,0x6e,0x63,0x6f
	.byte 0x72,0x70,0x6f,0x72,0x61,0x74,0x65,0x64,0x2e,0x0d,0x0a,0x2a,0x2a,0x2a,0x20,0x54
	.byte 0x68,0x69,0x73,0x20,0x70,0x72,0x6f,0x67,0x72,0x61,0x6d,0x20,0x6d,0x61,0x79,0x20
	.byte 0x6e,0x6f,0x74,0x20,0x62,0x65,0x20,0x66,0x72,0x65,0x65,0x6c,0x79,0x20,0x64,0x69
	.byte 0x73,0x74,0x72,0x69,0x62,0x75,0x74,0x65,0x64,0x20,0x2a,0x2a,0x2a,0x0d,0x0a,0x00
	.byte 0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00,0x00,0x02,0x4a
	.byte 0x00,0x00,0x02,0x58,0x00,0x00,0x02,0x76,0x00,0x00,0x01,0x94,0x00,0x00,0x05,0x94
	.byte 0x00,0x00,0x04,0x7a,0x00,0x00,0x08,0xd8,0x00,0x00,0x0c,0x8c,0x00,0x00,0x0c,0xbc
	.byte 0x00,0x00,0x03,0x2a,0x00,0x00,0x04,0x4e,0x00,0x00,0x04,0x10,0x00,0x00,0x03,0x58
	.byte 0x00,0x00,0x04,0x1c,0x00,0x00,0x02,0xb8,0x00,0x00,0x07,0x48,0x00,0x00,0x0b,0xc4
	.byte 0x00,0x00,0x0c,0x40,0x00,0x00,0x0a,0x98,0x00,0x00,0x0b,0x66,0x00,0x00,0x0a,0x48
	.byte 0x00,0x00,0x09,0x40,0xff,0xff,0xff,0xff
L158:
	.byte 0x43,0xf9,0x00
L15b:
	.byte 0x00,0x00,0xf0	/* lea 0xf0,a1 */
	.byte 0x70
L15f:
	.byte 0x00	/* moveq #0,d0 */
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a6,a5
	.byte 0x4e,0xae
L16a:
	.byte 0xfd,0xd8	/* jsr a6@(-552) */
L16c:
	tstl d0
	beqs L194
	moveal d0,a6
	jsr a6@(-60)
	tstl d0
	beqs L18c
	movel d0,d1
	.short 0x243c,0x0000,0x0030	/* movel #48,d2 */
	.short 0x263c,0x0000,0x00bf	/* movel #191,d3 */
	jsr a6@(-48)
L18c:
	moveal a6,a1
	moveal a5,a6
	jsr a6@(-414)
L194:
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0xa008	/* .short 0xa008 */
	btst d4,d0
	.short 0x800a	/* .short 0x800a */
	.short 0x0000,0x0022	/* orib #34,d0 */
	.short 0xa00e	/* .short 0xa00e */
	.short 0x0600,0x8114	/* addib #20,d0 */
	.short 0x0001,0x0005	/* orib #5,d1 */
	.short 0x0000,0x0030	/* orib #48,d0 */
	.short 0x852e,0x0000	/* orb d2,a6@(0) */
	.short 0x05b2,0x0000	/* bclr d2,a2@(0,d0:w) */
	.short 0x05ea,0x0000	/* bset d2,a2@(0) */
	.byte 0x06,0x72,0x00,0x00,0x07,0x26,0x00,0x00,0x08,0x2a	/* addiw #0,a2@(0)@(82a,d0:w:8) */
	.short 0x0000,0x07b4	/* orib #-76,d0 */
	chkl d0,d4
	.short 0x0000,0x08d4	/* orib #-44,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	beqs L248
	bsrs L248
	bvcs L243
	blss L24f
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	moveml d2/a2/a4-a6,sp@-
	.short 0x7400	/* moveq #0,d2 */
	moveal a0,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x43f9,0x0000,0x01d4	/* lea 0x1d4,a1 */
	.short 0x7022	/* moveq #34,d0 */
	jsr a6@(-552)
	tstl d0
	beqs L23c
	movel d0,d2
	.short 0x41f9,0x0000,0x00fc	/* lea 0xfc,a0 */
	.short 0x43f9,0x0000,0x0198	/* lea 0x198,a1 */
	.short 0x7200	/* moveq #0,d1 */
	moveal d1,a2
	.short 0x706e	/* moveq #110,d0 */
	jsr a6@(-84)
	tstl d0
	beqs L23c
	moveal d0,a4
	movel a6,a4@(34)
	movel d2,a4@(38)
	movel a5,a4@(42)
	moveal a4,a1
	jsr a6@(-396)
	movel a4,d0
L236:
	moveml sp@+,d2/a2/a4-a6
	rts
L23c:
	tstl d2
	beqs L246
	moveal d2,a1
	.byte 0x4e
L243:
	.byte 0xae,0xfe,0x62	/* jsr a6@(-414) */
L246:
	.short 0x7000	/* moveq #0,d0 */
L248:
	bras L236
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	.byte 0x08
L24f:
	.byte 0xae,0x00,0x03,0x00,0x0e	/* bclr #3,a6@(14) */
	movel a6,d0
	rts
	movew a6@(32),d0
	beqs L268
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	beqs L268
L264:
	.short 0x7000	/* moveq #0,d0 */
	rts
L268:
	btst #3,a6@(14)
	beqs L264
	bsrw L276
	bras L264
L276:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	.short 0x7400	/* moveq #0,d2 */
	bset #3,a5@(14)
	tstw a5@(32)
	bnes L2b0
	movel a5@(42),d2
	moveal a5@(34),a6
	moveal a5,a1
	jsr a6@(-252)
	movew a5@(18),d0
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d1
	movew a5@(18),d0
	addw d1,d0
	moveal a5,a1
	subaw d1,a1
	jsr a6@(-210)
L2b0:
	movel d2,d0
	moveml sp@+,d2/a5-a6
	rts
	moveml d2-d3/a2-a3/a5-a6,sp@-
	linkw a5,#-44
	.short 0x7400	/* moveq #0,d2 */
	bsrw L45c
	.short 0x0c28,0x0010,0x0005	/* cmpib #16,a0@(5) */
	bnes L322
	moveal d2,a0
	jsr a6@(-60)
	tstl d0
	beqs L326
	movel d0,d3
	cmpal d2,a3
	beqs L302
	moveal a2,a0
	moveal sp,a1
	.short 0x7028	/* moveq #40,d0 */
	movel a6,sp@-
	moveal a6@(34),a6
	jsr a6@(-624)
	moveal sp@+,a6
	moveal sp,a2
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(5),d0
	aslw #2,d0
	movel a3,a2@(0x8,d0:w)
	.short 0x522a,0x0005	/* addqb #1,a2@(5) */
L302:
	moveal d2,a0
	moveal d3,a1
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(5),d0
	lea a2@(8),a2
	jsr a6@(-36)
	tstl d0
	blts L31a
	.short 0x7000	/* moveq #0,d0 */
L31a:
	unlk a5
	moveml sp@+,d2-d3/a2-a3/a5-a6
	rts
L322:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L31a
L326:
	.short 0x70fe	/* moveq #-2,d0 */
	bras L31a
L32a:
	bsrw L45c
	jsr a6@(-48)
	tstl d0
	bnes L354
	movel a0@(12),d1
	.short 0x7001	/* moveq #1,d0 */
	andb d1,d0
	addl d1,d0
	addal d0,a1
	movew a0@(4),d0
	.short 0x307c,0x0000	/* moveaw #0,a0 */
	btst #15,d0
	bnes L32a
	movel a1,d0
	rts
L354:
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d2/d4/d7/a2/a4-a6,sp@-
	.short 0x7400	/* moveq #0,d2 */
	moveal d2,a5
	moveal a0,a4
	moveal a1,a0
	moveal a2,a1
	bsrs L3e6
	tstb d0
	bnew L3e0
	movel a0@(8),d4
	movel d4,d7
	movel a4,d0
	bnes L394
	moveml a0-a1/a6,sp@-
	.short 0x7201	/* moveq #1,d1 */
	movel d7,d0
	moveal a6@(34),a6
	jsr a6@(-198)
	moveml sp@+,a0-a1/a6
	tstl d0
	beqs L3e0
	moveal d0,a5
	moveal d0,a4
L394:
	movel d0,sp@-
	.short 0x7001	/* moveq #1,d0 */
	moveal sp,a2
	jsr a6@(-36)
	movel sp@+,d1
	cmpl d4,d0
	bnes L3e0
	.short 0x2947,0x0000	/* movel d7,a4@(0) */
	moveb a4@(17),d1
	movel a4,d0
	btst #0,d1
	beqs L3c0
	tstl a4@(4)
	beqs L3c4
	addl d0,a4@(4)
	bras L3c4
L3c0:
	movel d2,a4@(4)
L3c4:
	btst #2,d1
	beqs L3d6
	tstl a4@(8)
	beqs L3da
	addl d0,a4@(8)
	bras L3da
L3d6:
	movel d2,a4@(8)
L3da:
	moveml sp@+,d2/d4/d7/a2/a4-a6
	rts
L3e0:
	bsrs L42e
	.short 0x7000	/* moveq #0,d0 */
	bras L3da
L3e6:
	bsrw L45c
	jsr a6@(-48)
	tstb d0
	bnew L40e
	.short 0x0c28,0x0010,0x0005	/* cmpib #16,a0@(5) */
	bnew L40e
	moveal d2,a0
	bsrw L45c
	jsr a6@(-48)
	tstb d0
	bnes L40e
	.short 0x7000	/* moveq #0,d0 */
L40e:
	rts
	bsrs L3e6
	tstb d0
	bnes L41a
	movel a0@(8),d0
L41a:
	rts
	moveml d7/a5,sp@-
	.short 0x2e28,0x0000	/* movel a0@(0),d7 */
	moveal a0,a5
	bsrs L42e
	moveml sp@+,d7/a5
	rts
L42e:
	.short 0xbafc,0x0000	/* cmpaw #0,a5 */
	beqs L44c
	moveml d0-d1/a0-a1/a6,sp@-
	movel d7,d0
	moveal a5,a1
	moveal a6@(34),a6
	jsr a6@(-210)
	moveml sp@+,d0-d1/a0-a1/a6
	.short 0x7e00	/* moveq #0,d7 */
	moveal d7,a5
L44c:
	rts
	movel a2,sp@-
	moveal sp,a2
	.short 0x7001	/* moveq #1,d0 */
	jsr a6@(-36)
	moveal sp@+,a2
	rts
L45c:
	movel d0,sp@-
	movel a1,d0
	beqs L476
	movel a0,d0
	bnes L46e
	moveal a1,a0
L468:
	jsr a6@(-54)
	addaw d0,a1
L46e:
	movel a1,d0
	beqs L468
	movel sp@+,d0
	rts
L476:
	moveal a0,a1
	bras L468
	moveml d2-a5,sp@-
	movel d0,d5
	moveal a2,a4
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7400	/* moveq #0,d2 */
	moveal d2,a5
L488:
	bsrs L45c
	jsr a6@(-48)
	tstb d0
	bnes L4fc
	movew a0@(4),d4
	.short 0x0c04,0x0010	/* cmpib #16,d4 */
	bges L504
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(7),d0
	cmpw d5,d0
	bges L4fc
	aslw #2,d0
	.short 0x2474,0x0000	/* moveal a4@(0,d0:w),a2 */
	moveml a0@(8),d6-d7
	btst #12,d4
	beqs L4ba
	.short 0x5387	/* subql #1,d7 */
L4ba:
	btst #14,d4
	bnes L4d6
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(6),d0
	cmpw d5,d0
	bges L4fc
	aslw #2,d0
	.short 0x2034,0x0000	/* movel a4@(0,d0:w),d0 */
	beqs L4fc
	moveal d0,a3
	bras L508
L4d6:
	movel a1@+,d6
	.short 0x5987	/* subql #4,d7 */
	moveml a0-a1/a6,sp@-
	movel d6,d0
	.short 0x7201	/* moveq #1,d1 */
	moveal a6@(34),a6
	jsr a6@(-198)
	moveml sp@+,a0-a1/a6
	moveal d0,a3
	movel d0,d3
	tstl d0
	beqs L500
	bras L508
L4f8:
	.short 0x70fe	/* moveq #-2,d0 */
	bras L570
L4fc:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L570
L500:
	.short 0x70fc	/* moveq #-4,d0 */
	bras L570
L504:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L570
L508:
	.short 0x7000	/* moveq #0,d0 */
	moveb d4,d0
	aslb #2,d0
	moveal a6@(0x2e,d0:w),a5
	jsr a5@
	.short 0x2a7c,0x0000,0x0000	/* moveal #0,a5 */
	cmpl d0,d6
	bnes L4f8
	.short 0x7201	/* moveq #1,d1 */
	andl d7,d1
	addl d7,d1
	addal d1,a1
	btst #13,d4
	beqs L53c
	moveml d0/a0-a1,sp@-
	moveal a3,a0
	moveal a2,a1
	jsr a6@(-42)
	moveml sp@+,d0/a0-a1
L53c:
	btst #14,d4
	beqs L562
	moveml a0-a1,sp@-
	moveal a5,a0
	moveal a3,a1
	moveal a4,a2
	movel d5,d0
	jsr a6@(-36)
	moveml sp@+,a0-a1
	bsrs L578
	tstl d0
	blts L570
	cmpl a0@(8),d0
	bnes L4f8
L562:
	addl d0,d2
	moveal a5,a0
	btst #15,d4
	bnew L488
	movel d2,d0
L570:
	bsrs L578
	moveml sp@+,d2-a5
	rts
L578:
	tstl d3
	beqs L592
	moveml d0-d1/a0-a1/a6,sp@-
	movel d6,d0
	moveal d3,a1
	moveal a6@(34),a6
	jsr a6@(-210)
	.short 0x7600	/* moveq #0,d3 */
	moveml sp@+,d0-d1/a0-a1/a6
L592:
	rts
	moveml d5-d6/a5,sp@-
	moveml a0@(8),d6-d7
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(5),d0
	aslb #2,d0
	moveal a6@(0x2e,d0:w),a5
	jsr a5@
	moveml sp@+,d5-d6/a5
	rts
	moveml a0-a1/a6,sp@-
	movel d6,d0
	moveal a1,a0
	moveal a3,a1
	moveal a6@(34),a6
	jsr a6@(-624)
	movel d6,d0
	moveml sp@+,a0-a1/a6
	rts
L5cc:
	.short 0x5387	/* subql #1,d7 */
	blts L5e2
	.short 0x5285	/* addql #1,d5 */
	cmpl d6,d5
	bgts L5e6
	moveb a1@+,a3@+
	.short 0x0c04,0x0007	/* cmpib #7,d4 */
	beqs L5f0
	.short 0x5204	/* addqb #1,d4 */
	bras L5fa
L5e2:
	braw L666
L5e6:
	braw L5e6
	moveml d2-a4,sp@-
	.short 0x7a00	/* moveq #0,d5 */
L5f0:
	.short 0x5387	/* subql #1,d7 */
	bltw L666
	.short 0x7800	/* moveq #0,d4 */
	moveb a1@+,d3
L5fa:
	btst d4,d3
	bnes L5cc
	.short 0x5587	/* subql #2,d7 */
	blts L666
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7400	/* moveq #0,d2 */
	moveb a1@+,d0
	moveb a1@+,d2
	movel d2,d1
	.short 0x0201,0x000f	/* andib #15,d1 */
	.short 0x5641	/* addqw #3,d1 */
	aslw #4,d2
	clrb d2
	addw d2,d0
	cmpl d0,d5
	blts L662
	negw d0
	.short 0x49f3,0x0000	/* lea a3@(0,d0:w),a4 */
	addl d1,d5
	cmpl d6,d5
	bgts L662
	addl d1,d1
	negl d1
	.short 0x4efb,0x1026	/* jmp %pc@(0x654,d1:w) */
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	moveb a4@+,a3@+
	cmpl d6,d5
	beqs L666
	.short 0x0c04,0x0007	/* cmpib #7,d4 */
	beqs L5f0
	.short 0x5204	/* addqb #1,d4 */
	bras L5fa
L662:
	.short 0x7000	/* moveq #0,d0 */
	bras L66c
L666:
	cmpl d5,d6
	bnes L662
	movel d5,d0
L66c:
	moveml sp@+,d2-a4
	rts
	moveml d2-a5,sp@-
	.short 0x5587	/* subql #2,d7 */
	bltw L71a
	movew a1@+,d5
	movel a2,d3
	subl a3,d3
	movel a3,d4
	.short 0x5284	/* addql #1,d4 */
	moveal a3,a5
	addal d6,a5
	moveal a3,a4
	movew d5,d0
	.short 0x5240	/* addqw #1,d0 */
	addaw d0,a4
L692:
	.short 0x5387	/* subql #1,d7 */
	bltw L71a
	.short 0x7400	/* moveq #0,d2 */
	moveb a1@+,d2
	beqs L6c8
	bgts L6f8
	negb d2
	.short 0x5387	/* subql #1,d7 */
	blts L71a
	moveb a1@+,d1
	.short 0x5382	/* subql #1,d2 */
	blts L71a
	moveb d1,a3@
	addaw d5,a3
	cmpal a5,a3
	bccs L6ba
L6b4:
	.short 0x51ca,0xfff6	/* dbf d2,0x6ac */
	bras L692
L6ba:
	moveal d4,a3
	.short 0x5284	/* addql #1,d4 */
	cmpal d4,a4
	bnes L6b4
	.short 0x51ca,0x0056	/* dbf d2,0x71a */
	bras L71e
L6c8:
	.short 0x5387	/* subql #1,d7 */
	blts L71a
	moveb a1@+,d2
	moveal d3,a2
	addal a3,a2
	.short 0x5382	/* subql #1,d2 */
	blts L71a
	moveb a2@,a3@
	addaw d5,a3
	cmpal a5,a3
	bccs L6e6
	addaw d5,a2
L6e0:
	.short 0x51ca,0xfff4	/* dbf d2,0x6d6 */
	bras L692
L6e6:
	moveal d4,a3
	.short 0x5284	/* addql #1,d4 */
	moveal d3,a2
	addal a3,a2
	cmpal d4,a4
	bnes L6e0
	.short 0x51ca,0x0026	/* dbf d2,0x71a */
	bras L71e
L6f8:
	subl d2,d7
	blts L71a
	.short 0x5342	/* subqw #1,d2 */
	moveb a1@+,a3@
	addaw d5,a3
	cmpal a5,a3
	bccs L70c
L706:
	.short 0x51ca,0xfff6	/* dbf d2,0x6fe */
	bras L692
L70c:
	moveal d4,a3
	.short 0x5284	/* addql #1,d4 */
	cmpal d4,a4
	bnes L706
	.short 0x51ca,0x0004	/* dbf d2,0x71a */
	bras L71e
L71a:
	.short 0x7000	/* moveq #0,d0 */
	bras L720
L71e:
	movel d6,d0
L720:
	moveml sp@+,d2-a5
	rts
	moveml a0-a1,sp@-
	.short 0x7001	/* moveq #1,d0 */
	cmpl d0,d7
	bnew L744
	moveb a1@,d0
	movel d6,d1
	moveal a3,a0
	jsr a6@(-96)
	movel d6,d0
L73e:
	moveml sp@+,a0-a1
	rts
L744:
	.short 0x7000	/* moveq #0,d0 */
	bras L73e
	movel d2,sp@-
	movel a0,d2
	btst #0,d2
	beqs L756
	moveb d0,a0@+
	.short 0x5381	/* subql #1,d1 */
L756:
	moveb d0,d2
	aslw #8,d2
	moveb d0,d2
	movew d2,d0
	swap d0
	movew d2,d0
	.short 0x7430	/* moveq #48,d2 */
	cmpl d2,d1
	bcss L794
	moveml d3-d7/a2-a6,sp@-
	movel d0,d3
	movel d0,d4
	movel d0,d5
	movel d0,d6
	movel d0,d7
	moveal d0,a1
	moveal d0,a2
	moveal d0,a3
	moveal d0,a4
	moveal d0,a5
	moveal d0,a6
	bras L78c
L784:
	moveml d0/d3-d7/a1-a6,a0@
	addal d2,a0
	subl d2,d1
L78c:
	cmpl d2,d1
	bccs L784
	moveml sp@+,d3-d7/a2-a6
L794:
	movel d1,d2
	asrl #2,d1
	bras L79c
	movel d0,a0@+
L79c:
	.short 0x51c9,0xfffc	/* dbf d1,0x79a */
	btst #1,d2
	beqs L7a8
	movew d0,a0@+
L7a8:
	btst #0,d2
	beqs L7b0
	moveb d0,a0@+
L7b0:
	movel sp@+,d2
	rts
	moveml d3-a5,sp@-
	.short 0x5787	/* subql #3,d7 */
	blts L81a
	movew a1@+,d5
	moveb a1@+,d3
	movel a3,d4
	.short 0x5284	/* addql #1,d4 */
	moveal a3,a5
	addal d6,a5
	moveal a3,a4
	movew d5,d0
	.short 0x5240	/* addqw #1,d0 */
	addaw d0,a4
L7d0:
	.short 0x5387	/* subql #1,d7 */
	bltw L81a
	moveb a1@+,d0
	cmpb d0,d3
	beqs L7ee
	moveb d0,a3@
	addaw d5,a3
	cmpal a5,a3
	bcss L7d0
	moveal d4,a3
	.short 0x5284	/* addql #1,d4 */
	cmpal d4,a4
	bnes L7d0
	bras L81e
L7ee:
	.short 0x5587	/* subql #2,d7 */
	bltw L81a
	.short 0x7200	/* moveq #0,d1 */
	moveb a1@+,d1
	beqs L81a
	.short 0x5341	/* subqw #1,d1 */
	moveb a1@+,d0
	moveb d0,a3@
	addaw d5,a3
	cmpal a5,a3
	bccs L80c
L806:
	.short 0x51c9,0xfff6	/* dbf d1,0x7fe */
	bras L7d0
L80c:
	moveal d4,a3
	.short 0x5284	/* addql #1,d4 */
	cmpal d4,a4
	bnes L806
	.short 0x51c9,0x0004	/* dbf d1,0x81a */
	bras L81e
L81a:
	.short 0x7000	/* moveq #0,d0 */
	bras L824
L81e:
	tstl d7
	bnes L81a
	movel d6,d0
L824:
	moveml sp@+,d3-a5
	rts
	moveml d2-a5,sp@-
	moveal d6,a4
	.short 0x7a00	/* moveq #0,d5 */
L832:
	.short 0x5387	/* subql #1,d7 */
	bltw L8c8
	.short 0x7800	/* moveq #0,d4 */
	moveb a1@+,d3
L83c:
	btst d4,d3
	bnes L8aa
	.short 0x5587	/* subql #2,d7 */
	bltw L8c8
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7400	/* moveq #0,d2 */
	moveb a1@+,d0
	moveb a1@+,d2
	movel d2,d1
	.short 0x0201,0x000f	/* andib #15,d1 */
	.short 0x5641	/* addqw #3,d1 */
	aslw #4,d2
	clrb d2
	addw d2,d0
	subl d1,d7
	blts L8c4
	cmpl d0,d5
	blts L8c4
	negw d0
	.short 0x4bf3,0x0000	/* lea a3@(0,d0:w),a5 */
	addl d1,d5
	addl d1,d5
	cmpl a4,d5
	bgts L8c4
	.short 0x5341	/* subqw #1,d1 */
	moveb a1@+,d0
	moveb d0,d2
	asrb #4,d2
	moveb a5@+,d6
	subb d2,d6
	moveb d6,a3@+
	btst #3,d0
	bnes L88c
	.short 0x0200,0x000f	/* andib #15,d0 */
	bras L890
L88c:
	.short 0x0000,0x00f0	/* orib #-16,d0 */
L890:
	moveb a5@+,d6
	subb d0,d6
	moveb d6,a3@+
	.short 0x51c9,0xffdc	/* dbf d1,0x874 */
	cmpl a4,d5
	beqs L8c8
	.short 0x0c04,0x0007	/* cmpib #7,d4 */
	beqs L832
	.short 0x5204	/* addqb #1,d4 */
	braw L83c
L8aa:
	.short 0x5387	/* subql #1,d7 */
	blts L8c8
	.short 0x5285	/* addql #1,d5 */
	cmpl a4,d5
	bgts L8c4
	moveb a1@+,a3@+
	.short 0x0c04,0x0007	/* cmpib #7,d4 */
	beqw L832
	.short 0x5204	/* addqb #1,d4 */
	braw L83c
L8c4:
	.short 0x7000	/* moveq #0,d0 */
	bras L8ce
L8c8:
	cmpl a4,d5
	bnes L8c4
	movel d5,d0
L8ce:
	moveml sp@+,d2-a5
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0x720c	/* moveq #12,d1 */
	cmpl d1,d0
	bcss L930
	movel a0,d1
	btst #0,d1
	beqs L8ec
	moveb a1@+,d1
	eorb d1,a0@+
	.short 0x5380	/* subql #1,d0 */
L8ec:
	movel a1,d1
	btst #0,d1
	bnes L930
	movel d0,d1
	.short 0x0241,0x0003	/* andiw #3,d1 */
	movew d1,sp@-
	moveml d2-d7,sp@-
	.short 0x7218	/* moveq #24,d1 */
	bras L916
L904:
	moveml a1@+,d2-d7
	eorl d2,a0@+
	eorl d3,a0@+
	eorl d4,a0@+
	eorl d5,a0@+
	eorl d6,a0@+
	eorl d7,a0@+
	subl d1,d0
L916:
	cmpl d1,d0
	bccs L904
	moveml sp@+,d2-d7
	lsrl #2,d0
	beqs L92a
L922:
	movel a1@+,d1
	eorl d1,a0@+
	.short 0x5380	/* subql #1,d0 */
	bnes L922
L92a:
	movew sp@+,d0
	beqs L93c
	bras L934
L930:
	tstl d0
	beqs L93c
L934:
	moveb a1@+,d1
	eorb d1,a0@+
	.short 0x5380	/* subql #1,d0 */
	bnes L934
L93c:
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3f3e	/* .short 0x3f3e */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7400	/* moveq #0,d2 */
	moveb a0@(21),d2
	beqw La3a
	moveal a0@(8),a1
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(20),d1
	beqw La3e
	addw d1,d1
	subaw d1,sp
	moveal sp,a4
	movew d1,sp@-
	moveal a0@(4),a3
	.short 0x263c,0x000f,0x4240	/* movel #1000000,d3 */
	.short 0x5342	/* subqw #1,d2 */
	moveb a1@(4),d4
	beqw La32
	subl d0,a1@(14)
	bgtw La32
	.short 0x5369,0x000c	/* subqw #1,a1@(12) */
	blts L990
	addl d3,a1@(14)
	braw La32
L990:
	tstb d5
	bnes L9ae
	moveml a3-a4,sp@-
	moveb a0@(20),d5
	asrw #1,d5
	bccs L9a6
	movew a3@+,a4@+
	bras L9a6
	movel a3@+,a4@+
L9a6:
	.short 0x51cd,0xfffc	/* dbf d5,0x9a4 */
	moveml sp@+,a3-a4
L9ae:
	movew a1@(6),a1@(12)
	movel a1@(8),d1
	addl d1,a1@(14)
	tstb d4
	bgts L9f8
	moveb a1@(2),d1
	extw d1
	moveb a1@(3),d4
	extw d4
	subw d1,d4
	beqs La30
	.short 0x5344	/* subqw #1,d4 */
	lea a1@(0x16,d1:w),a5
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7200	/* moveq #0,d1 */
	moveb a5@+,d7
	addw d7,d7
	.short 0x3c34,0x7000	/* movew a4@(0,d7:w),d6 */
	moveb a5@+,d1
	addb d1,d1
	.short 0x37b4,0x1000,0x7000	/* movew a4@(0,d1:w),a3@(0,d7:w) */
	moveb d1,d7
	.short 0x51cc,0xfff2	/* dbf d4,0x9e2 */
	.short 0x3786,0x7000	/* movew d6,a3@(0,d7:w) */
	bras La30
L9f8:
	moveb a1@(2),d1
	extw d1
	moveb a1@(3),d4
	extw d4
	movew d4,d7
	subw d1,d4
	beqs La30
	.short 0x5344	/* subqw #1,d4 */
	lea a1@(0x16,d7:w),a5
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7200	/* moveq #0,d1 */
	moveb a5@,d7
	addb d7,d7
	.short 0x3c34,0x7000	/* movew a4@(0,d7:w),d6 */
	moveb a5@-,d1
	addb d1,d1
	.short 0x37b4,0x1000,0x7000	/* movew a4@(0,d1:w),a3@(0,d7:w) */
	moveb d1,d7
	.short 0x51cc,0xfff2	/* dbf d4,0xa1c */
	.short 0x3786,0x7000	/* movew d6,a3@(0,d7:w) */
La30:
	.short 0x7aff	/* moveq #-1,d5 */
La32:
	.short 0xd2e9,0x0000	/* addaw a1@(0),a1 */
	.short 0x51ca,0xff3a	/* dbf d2,0x972 */
La3a:
	movew sp@+,d1
	addaw d1,sp
La3e:
	movel d5,d0
	moveml sp@+,d2-d7/a2-a6
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	movel a0@-,d0
	moveal a6@(38),a2
	movew a1@(32),d0
	movew a2@(218),d1
	btst #15,d0
	bnes La60
	asrw #1,d1
La60:
	subw a1@(24),d1
	asrw #1,d1
	movew d1,a1@(28)
	movew a2@(216),d1
	movew a0@(12),d2
	negw d2
	.short 0x0642,0x000d	/* addiw #13,d2 */
	btst #2,d0
	beqs La82
	addw d1,d1
	addw d2,d2
La82:
	subw a1@(26),d1
	asrw #1,d1
	cmpw d2,d1
	bges La8e
	movew d2,d1
La8e:
	movew d1,a1@(30)
	moveml sp@+,d2/a2
	rts
	moveml d2-d4/a2-a6,sp@-
	moveal a6,a5
	movel d0,d3
	movel d1,d4
	.short 0x0c44,0x0010	/* cmpiw #16,d4 */
	blew Lb62
	moveal a1,a3
	moveal a0,a2
	movel a2,d0
	bnes Lad0
	.short 0x704a	/* moveq #74,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	beqw Lb54
	moveal d0,a2
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a2@(70)
Lad0:
	lea a2@(18),a0
	moveal a0,a4
	moveal a5@(38),a6
	jsr a6@(-204)
	movew d3,a4@(24)
	movew d4,a4@(26)
	movew d2,a4@(32)
	lea a2@(58),a0
	movel a0,a4@(36)
	.short 0x7001	/* moveq #1,d0 */
	moveb a3@(5),d1
	aslw d1,d0
	jsr a6@(-570)
	tstl d0
	beqs Lb5a
	movel d0,a4@(4)
	movel a3,a2@(62)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a2@(66)
	movel d0,a2@(58)
	moveal a2,a1
	jsr a6@(-360)
	movel a6@(34),d0
	beqs Lb28
	moveal d0,a0
	movel a0@(12),a2@(12)
Lb28:
	.short 0x254c,0x0000	/* movel a4,a2@(0) */
	movew d2,d0
	.short 0x0240,0x0006	/* andiw #6,d0 */
	orw d0,a2@(16)
	moveal a2,a0
	moveal a4,a1
	moveal a5,a6
	jsr a6@(-126)
	moveal a5@(38),a6
	moveal a2,a0
	moveal a4,a1
	jsr a6@(-216)
	moveal a2,a1
	jsr a6@(-210)
	movel a2,d0
Lb54:
	moveml sp@+,d2-d4/a2-a6
	rts
Lb5a:
	moveal a2,a0
	moveal a5,a6
	jsr a6@(-120)
Lb62:
	.short 0x7000	/* moveq #0,d0 */
	bras Lb54
	moveml a2-a3/a5-a6,sp@-
	moveal a6,a5
	moveal a6@(38),a6
	moveal a0,a2
	movel a0,d0
	beqs Lbba
	movel a2@(4),d0
	beqs Lb7e
	moveal d0,a0
Lb7e:
	jsr a6@(-564)
	movel a2@(8),d0
	beqs Lb8e
	moveal d0,a0
	jsr a6@(-564)
Lb8e:
	lea a2@(18),a3
	moveal a3,a0
	jsr a6@(-540)
	movel a3@(4),d0
	beqs Lba4
	moveal d0,a0
	jsr a6@(-576)
Lba4:
	movel a2@(70),d0
	btst #0,d0
	beqs Lbba
	.short 0x704a	/* moveq #74,d0 */
	moveal a2,a1
	moveal a5@(34),a6
	jsr a6@(-210)
Lbba:
	moveml sp@+,a2-a3/a5-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3e3a,0x2c00	/* movew %pc@(0x37c8),d7 */
	moveal a6,a4
	moveal a6@(34),a6
	.short 0x2a3c,0x0001,0x0002	/* movel #65538,d5 */
	movel d1,d3
	movel d2,d4
	.short 0x7028	/* moveq #40,d0 */
	movew d6,d1
	.short 0x5141	/* subqw #8,d1 */
	bles Lbe6
	aslw #2,d1
	addw d1,d0
Lbe6:
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqs Lc32
	moveal d0,a2
	lea a2@(8),a3
	moveal a2,a0
	movel d6,d0
	movel d3,d1
	movel d4,d2
	moveal a4@(38),a6
	jsr a6@(-390)
	.short 0x362a,0x0000	/* movew a2@(0),d3 */
	.short 0xc6ea,0x0002	/* muluw a2@(2),d3 */
	moveal a4@(34),a6
	bras Lc26
	movel d3,d0
	movel d5,d1
	jsr a6@(-198)
	tstl d0
	beqs Lc36
	movel d0,a3@+
Lc26:
	.short 0x51ce,0xfff0	/* dbf d6,0xc18 */
	movel a2,d0
Lc2c:
	moveml sp@+,d2-d6/a2-a4/a6
	rts
Lc32:
	.short 0x7000	/* moveq #0,d0 */
	bras Lc2c
Lc36:
	moveal a4,a6
	moveal a2,a0
	jsr a6@(-108)
	bras Lc2c
	moveml d2-d5/a2-a3/a6,sp@-
	moveal a0,a2
	.short 0x7400	/* moveq #0,d2 */
	cmpl a2,d2
	beqs Lc86
	lea a2@(8),a3
	.short 0x362a,0x0000	/* movew a2@(0),d3 */
	.short 0xc6ea,0x0002	/* muluw a2@(2),d3 */
	.short 0x7800	/* moveq #0,d4 */
	moveb a2@(5),d4
	movew d4,d5
	moveal a6@(34),a6
	bras Lc72
	moveal a3@+,a1
	cmpal d2,a1
	beqs Lc72
	movel d3,d0
	jsr a6@(-210)
Lc72:
	.short 0x51cc,0xfff2	/* dbf d4,0xc66 */
	moveal a2,a1
	.short 0x7028	/* moveq #40,d0 */
	.short 0x5145	/* subqw #8,d5 */
	bles Lc82
	aslw #2,d5
	addw d5,d0
Lc82:
	jsr a6@(-210)
Lc86:
	moveml sp@+,d2-d5/a2-a3/a6
	rts
	bsrs Lc92
	subb d1,d0
	rts
Lc92:
	moveml d2/a0,sp@-
	jsr a6@(-54)
	tstl d0
	beqs Lcb6
	.short 0x5540	/* subqw #2,d0 */
	movew d0,d2
	.short 0x7001	/* moveq #1,d0 */
	moveb a0@+,d1
	addb a0@+,d0
	rorb #1,d0
	.short 0x51ca,0xfffa	/* dbf d2,0xca6 */
	movel a1,d2
Lcb0:
	moveml sp@+,d2/a0
	rts
Lcb6:
	moveb d1,d0
	.short 0x5200	/* addqb #1,d0 */
	bras Lcb0
	movel a0,d0
	beqs Lcce
	moveb a0@(1),d0
	.short 0x0c00,0x0001	/* cmpib #1,d0 */
	beqs Lcce
	.short 0x7000	/* moveq #0,d0 */
	rts
Lcce:
	.short 0x7010	/* moveq #16,d0 */
	.byte 0x4e,0x75,0x00,0x00	/* rts */
