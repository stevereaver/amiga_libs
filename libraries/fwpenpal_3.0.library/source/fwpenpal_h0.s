	.text
	.byte 0x70,0x00,0x4e,0x75,0x66,0x77,0x70,0x65,0x6e,0x70,0x61,0x6c,0x2e,0x6c,0x69,0x62
	.byte 0x72,0x61,0x72,0x79,0x00,0x00,0x66,0x77,0x70,0x65,0x6e,0x70,0x61,0x6c
	movel a3@(0x30,d2:l:0x8),d0
	movel a0@(13869),d0
	.short 0x4175	/* .short 0x4175 */
	beqs L57
	.short 0x3933,0x290d	/* movew a3@(0)@(0,d2:l),a4@- */
	.byte 0x0a,0x00
L30:
	.byte 0x09,0x00	/* eorib #0,d0 */
	moveml a3/a6,sp@-
	moveal a6,a3
	.short 0x526b,0x0020	/* addqw #1,a3@(32) */
	bclr #3,a3@(14)
	movel a3,d0
	moveml sp@+,a3/a6
	rts
L4a:
	moveml a3/a6,sp@-
	moveal a6,a3
	tstw a3@(32)
	bnes L8c
	.byte 0x20
L57:
	.byte 0x4b	/* moveal a3,a0 */
	bsrw Lc22
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	moveal a3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(16),d0
	subal d0,a0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x30,0x2b
L78:
	.byte 0x00,0x12	/* movew a3@(18),d0 */
L7a:
	addl d0,d1
	.byte 0x22
L7d:
	.byte 0x48	/* moveal a0,a1 */
	movel d1,d0
	jsr a6@(-210)
	.short 0x2039,0x0000,0x0c7c	/* movel 0xc7c,d0 */
L8a:
	bras L94
L8c:
	bset #3,a3@(14)
	.short 0x7000	/* moveq #0,d0 */
L94:
	moveml sp@+,a3/a6
	rts
	moveml a3/a6,sp@-
	moveal a6,a3
	.short 0x536b,0x0020	/* subqw #1,a3@(32) */
	bnes Lb4
	btst #3,a3@(14)
	beqs Lb4
	moveal a3,a6
	bsrs L4a
	bras Lb6
Lb4:
	.short 0x7000	/* moveq #0,d0 */
Lb6:
	moveml sp@+,a3/a6
	rts
	moveml d7/a3,sp@-
	moveal d0,a3
	movel a0,d7
	.short 0x23c7,0x0000,0x0c7c	/* movel d7,0xc7c */
	.short 0x177c,0x0009,0x0008	/* moveb #9,a3@(8) */
	.short 0x41fa,0xff32	/* lea %pc@(0x4),a0 */
	movel a0,a3@(10)
	.short 0x177c,0x0006,0x000e	/* moveb #6,a3@(14) */
	.short 0x377c,0x0003,0x0014	/* movew #3,a3@(20) */
	clrw a3@(22)
	.short 0x41fa,0xff2c	/* lea %pc@(0x16),a0 */
	movel a0,a3@(24)
	moveal a3,a0
	bsrw Lc18
	moveml sp@+,d7/a3
	rts
	linkw a5,#-72
	moveml d2/d5-d7/a2-a3/a6,sp@-
	moveal a1,a3
	movel a0,a5@(-68)
	moveal a5@(-68),a0
	moveal a0@(16),a2
	moveal a2@(48),a1
	lea a5@(-30),a6
	movel a1,a5@(-48)
	moveal a3@(4),a1
	movel a1,sp@(28)
	moveal a5@(-48),a1
	.short 0xd2fc,0x009a	/* addaw #154,a1 */
	movel a6,a5@(-34)
	moveal a5@(-48),a0
	moveal sp@(28),a6
	jsr a6@
	lea a2@(5010),a0
	movel a0,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	moveal a3@(8),a6
	jsr a6@(-348)
	movel d0,d5
	tstl d5
	beqw L272
	moveal a5@(-34),a0
	clrw a0@
	.short 0x317c,0x0050,0x0002	/* movew #80,a0@(2) */
	.short 0x317c,0x0048,0x0004	/* movew #72,a0@(4) */
	.short 0x317c,0x0001,0x0006	/* movew #1,a0@(6) */
	moveal a5@(-68),a1
	.short 0xd2fc,0x0058	/* addaw #88,a1 */
	lea a0@(8),a6
	moveal a1,a0
	moveal a6,a1
	moveal a3@(8),a6
	jsr a6@(-1050)
	.short 0x7cff	/* moveq #-1,d6 */
	.short 0x7e01	/* moveq #1,d7 */
	moveal a5@(-34),a0
	.short 0x5088	/* addql #8,a0 */
	.short 0x7000	/* moveq #0,d0 */
	movew d0,a5@(-44)
	moveal a5@(-34),a1
	movew d0,a1@(24)
	movel a0,a5@(-56)
L1a4:
	movew a5@(-44),d0
	.short 0x5340	/* subqw #1,d0 */
	beqw L268
	.short 0x5246	/* addqw #1,d6 */
	movel d5,d0
	lea a5@(-44),a0
	moveal a3,a1
	bsrw L466
	tstw d0
	beqw L262
	movew a5@(-44),d0
	beqs L1ec
	.short 0x5740	/* subqw #3,d0 */
	beqs L1ec
	movew a5@(-44),d0
	.short 0x5340	/* subqw #1,d0 */
	beqs L1ec
	movel a3,sp@-
	pea a5@(-44)
	movel d5,d0
	moveal a5@(-68),a0
	moveal a5@(-56),a1
	bsrw L3fe
	.short 0x504f	/* addqw #8,sp */
	movel d0,d7
L1ec:
	tstw d7
	beqs L262
	movew a5@(-44),d0
	tstw d0
	beqs L20a
	.short 0x5740	/* subqw #3,d0 */
	beqs L234
	.short 0x5d40	/* subqw #6,d0 */
	beqs L21a
	.short 0x5b40	/* subqw #5,d0 */
	beqs L21a
	.short 0x5b40	/* subqw #5,d0 */
	beqs L24e
	bras L262
L20a:
	tstw d6
	beqs L210
	.short 0x7e00	/* moveq #0,d7 */
L210:
	clrl a5@(-38)
	clrl a5@(-42)
	bras L262
L21a:
	movel a3,sp@-
	pea a5@(-44)
	movel d5,d0
	moveal a5@(-68),a0
	moveal a5@(-56),a1
	bsrw L4a8
	.short 0x504f	/* addqw #8,sp */
	movel d0,d7
	bras L262
L234:
	movel a3,sp@-
	movel a5@(-34),sp@-
	movel d5,d0
	moveal a5@(-68),a0
	lea a5@(-44),a1
	bsrw L532
	.short 0x504f	/* addqw #8,sp */
	movel d0,d7
	bras L262
L24e:
	moveal a5@(-38),a0
	moveal a5@(-34),a1
	movel a5@(-42),d0
	moveal a3@(8),a6
	jsr a6@(-42)
L262:
	tstw d7
	bnew L1a4
L268:
	movel d5,d1
	moveal a3@(8),a6
	jsr a6@(-354)
L272:
	tstw d7
	bnes L282
	moveal a5@(-68),a0
	moveal a3,a1
	bsrw L4f0
	bras L2c8
L282:
	moveal a5@(-48),a0
	movel a0@(162),a5@(-52)
	lea a0@(154),a1
	moveal a1,a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-264)
	moveal a3@,a0
	moveal a5@(-68),a1
	.short 0xd2fc,0x0058	/* addaw #88,a1 */
	movel a0,sp@(28)
	moveal a1,a0
	moveal a5@(-52),a1
	movel sp@(28),d0
	subl a0,d0
	.short 0x4eb0,0x0800	/* jsr a0@(0,d0:l) */
	moveal a5@(-34),a0
	movew a0@(2),d0
	extl d0
	moveal a2,a0
	bsrw L2e0
L2c8:
	moveal a5@(-34),a0
	.short 0x5088	/* addql #8,a0 */
	moveal a3@(8),a6
	jsr a6@(-1056)
	movel d7,d0
	moveml sp@+,d2/d5-d7/a2-a3/a6
	unlk a5
	rts
L2e0:
	linkw a5,#-24
	moveml d5-d7/a2-a3/a6,sp@-
	moveal a0,a3
	movel d0,d7
	moveal a3@(48),a0
	lea a0@(154),a1
	moveal a3@(5554),a0
	lea a0@(16),a6
	moveal a1@,a2
	movel a1,a5@(-12)
	movel a6,a5@(-16)
L306:
	tstl a2@
	beqw L3f6
	movel a2,a5@(-8)
	moveal a5@(-8),a0
	movel a0@(8),d0
	extl d0
	movel d7,d1
	extl d1
	bsrw Lbf8
	moveal a5@(-8),a0
	movel d0,a0@(8)
	movel a0@(12),d0
	extl d0
	movel d7,d1
	extl d1
	bsrw Lbf8
	moveal a5@(-8),a0
	movel d0,a0@(12)
	movel a0@(16),d0
	extl d0
	movel d7,d1
	extl d1
	bsrw Lbf8
	moveal a5@(-8),a0
	movel d0,a0@(16)
	moveal a5@(-16),a1
	movew a1@(4),d0
	extl d0
	subl d0,a0@(8)
	bges L36c
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a0@(8)
L36c:
	movew a1@(4),d0
	extl d0
	subl d0,a0@(16)
	bges L37e
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a0@(16)
L37e:
	moveal a3@(48),a1
	movew a1@(502),d0
	extl d0
	subl a0@(12),d0
	moveal a5@(-16),a1
	movew a1@(6),d1
	extl d1
	subl d1,d0
	movel d0,a0@(12)
	bges L3a2
	clrl a0@(12)
L3a2:
	movel a0@(66),a5@(-20)
	movel a0@(58),d0
	.short 0x7208	/* moveq #8,d1 */
	jsr %pc@(Lc30)
	movel d0,d6
	.short 0x7a00	/* moveq #0,d5 */
L3b6:
	cmpw d6,d5
	bges L3f0
	moveal a5@(-20),a0
	movel a0@(4),d0
	extl d0
	movel d7,d1
	extl d1
	bsrw Lbf8
	moveal a5@(-20),a0
	movel d0,a0@(4)
	moveal a5@(-16),a1
	movew a1@(4),d0
	extl d0
	subl d0,a0@(4)
	bges L3e8
	clrl a0@(4)
L3e8:
	.short 0x50ad,0xffec	/* addql #8,a5@(-20) */
	.short 0x5245	/* addqw #1,d5 */
	bras L3b6
L3f0:
	moveal a2@,a2
	braw L306
L3f6:
	moveml sp@+,d5-d7/a2-a3/a6
	unlk a5
	rts
L3fe:
	linkw a5,#-12
	moveml d2-d3/d6-d7/a2-a3/a6,sp@-
	movel d0,d7
	moveal a5@(8),a3
	moveal a5@(12),a2
	moveml a0-a1,a5@(-10)
	.short 0x7c00	/* moveq #0,d6 */
	moveal a5@(-10),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	movel a3@(2),d0
	moveal a2@(8),a6
	jsr a6@(-1008)
	movel d0,a3@(6)
	tstl d0
	beqs L45c
	movel d0,d2
	movel d7,d1
	movel a3@(2),d3
	moveal a2@(8),a6
	jsr a6@(-360)
	cmpl a3@(2),d0
	bnes L44c
	.short 0x7c01	/* moveq #1,d6 */
L44c:
	moveal a5@(-10),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	moveal a3@(6),a1
	jsr a6@(-1002)
L45c:
	movel d6,d0
	moveml sp@+,d2-d3/d6-d7/a2-a3/a6
	unlk a5
	rts
L466:
	linkw a5,#-4
	moveml d2-d3/d7/a3/a6,sp@-
	movel d0,d7
	moveal a1,a3
	movel a0,a5@(-4)
	movel a0,d2
	movel d7,d1
	.short 0x7602	/* moveq #2,d3 */
	moveal a3@(8),a6
	jsr a6@(-360)
	.short 0x5580	/* subql #2,d0 */
	bnes L49e
	moveal d2,a0
	.short 0x5488	/* addql #2,a0 */
	movel a0,d2
	movel d7,d1
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-360)
	.short 0x5980	/* subql #4,d0 */
	bnes L49e
	.short 0x7001	/* moveq #1,d0 */
	bras L4a0
L49e:
	.short 0x7000	/* moveq #0,d0 */
L4a0:
	moveml sp@+,d2-d3/d7/a3/a6
	unlk a5
	rts
L4a8:
	linkw a5,#-4
	moveml d6-d7/a2-a3,sp@-
	moveal a0,a3
	movel d0,d7
	moveal a1,a2
	.short 0x7c00	/* moveq #0,d6 */
	movel d7,d0
	moveal a5@(8),a0
	moveal a5@(12),a1
	bsrs L466
	tstw d0
	beqs L4e6
	.short 0x700a	/* moveq #10,d0 */
	moveal a5@(8),a0
	cmpw a0@,d0
	bnes L4e6
	movel a5@(12),sp@-
	movel a0,sp@-
	movel d7,d0
	moveal a3,a0
	moveal a2,a1
	bsrw L3fe
	.short 0x504f	/* addqw #8,sp */
	movel d0,d6
L4e6:
	movel d6,d0
	moveml sp@+,d6-d7/a2-a3
	unlk a5
	rts
L4f0:
	linkw a5,#-8
	moveml a2-a3/a6,sp@-
	moveal a0,a3
	moveal a1,a2
	moveal a3@(16),a0
	moveal a0@(48),a1
	moveal a2@(4),a0
	lea a1@(154),a6
	movel a0,sp@(12)
	movel a1,a5@(-4)
	moveal a1,a0
	moveal a6,a1
	movel sp@(12),d0
	subl a0,d0
	.short 0x4eb0,0x0800	/* jsr a0@(0,d0:l) */
	moveal a3@(16),a0
	clrw a0@(346)
	moveml sp@+,a2-a3/a6
	unlk a5
	rts
L532:
	linkw a5,#-20
	moveml d2-d3/d6-d7/a2-a3/a6,sp@-
	movel d0,d7
	moveal a1,a3
	moveal a5@(8),a2
	movel a0,a5@(-14)
	.short 0x7c00	/* moveq #0,d6 */
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	.short 0x704a	/* moveq #74,d0 */
	moveal a5@(12),a6
	moveal a6@(8),a6
	jsr a6@(-1008)
	movel d0,a5@(-4)
	tstl d0
	beqw L636
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	moveal d0,a1
	.short 0xd2fc,0x001a	/* addaw #26,a1 */
	jsr a6@(-1050)
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	moveal a5@(-4),a1
	.short 0xd2fc,0x002a	/* addaw #42,a1 */
	jsr a6@(-1050)
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	moveal a5@(-4),a1
	.short 0xd2fc,0x003a	/* addaw #58,a1 */
	jsr a6@(-1050)
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	movel a3@(2),d0
	jsr a6@(-1008)
	movel d0,a5@(-8)
	tstl d0
	beqs L636
	movel d0,d2
	movel d7,d1
	movel a3@(2),d3
	jsr a6@(-360)
	cmpl a3@(2),d0
	bnes L61e
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	movel a5@(12),sp@-
	moveal a5@(-14),a1
	movel a1@(16),sp@-
	movel a2,sp@-
	movel a5@(-4),sp@-
	movel a3,sp@-
	movel a0,sp@(48)
	moveal d2,a0
	moveal sp@(48),a1
	bsrw L640
	lea sp@(20),sp
	movel d0,d6
	tstw d6
	bnes L61e
	moveal a5@(12),a1
	moveal a1@,a0
	moveal a5@(-14),a1
	.short 0xd2fc,0x0058	/* addaw #88,a1 */
	movel a0,sp@(28)
	moveal a1,a0
	moveal a5@(-4),a1
	moveal sp@(28),a6
	jsr a6@
L61e:
	moveal a5@(-14),a0
	.short 0xd0fc,0x0058	/* addaw #88,a0 */
	moveal a5@(-8),a1
	moveal a5@(12),a6
	moveal a6@(8),a6
	jsr a6@(-1002)
L636:
	movel d6,d0
	moveml sp@+,d2-d3/d6-d7/a2-a3/a6
	unlk a5
	rts
L640:
	linkw a5,#-68
	moveml d2-d7/a2-a3/a6,sp@-
	moveal a0,a3
	moveal a5@(8),a2
	movel a1,a5@(-68)
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(12),d0
	moveal a5@(12),a0
	movel d0,a0@(8)
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(14),d0
	movel d0,a0@(12)
	movew a3@(10),d0
	extl d0
	movel d0,a0@(16)
	moveal a5@(20),a0
	moveal a5@(12),a1
	movew a0@(1500),a1@(20)
	moveal a0@(48),a0
	movew a0@(576),d0
	moveb d0,a1@(24)
	clrb a1@(25)
	movew a3@(6),d0
	tstw d0
	beqs L6a8
	.short 0x5340	/* subqw #1,d0 */
	beqs L6b4
	.short 0x5340	/* subqw #1,d0 */
	beqs L6c0
	.short 0x5340	/* subqw #1,d0 */
	beqs L6cc
	bras L6d6
L6a8:
	moveal a5@(12),a0
	.short 0x317c,0x0001,0x0016	/* movew #1,a0@(22) */
	bras L6d6
L6b4:
	moveal a5@(12),a0
	.short 0x317c,0x0002,0x0016	/* movew #2,a0@(22) */
	bras L6d6
L6c0:
	moveal a5@(12),a0
	.short 0x317c,0x0004,0x0016	/* movew #4,a0@(22) */
	bras L6d6
L6cc:
	moveal a5@(12),a0
	.short 0x317c,0x0008,0x0016	/* movew #8,a0@(22) */
L6d6:
	moveal a5@(16),a0
	tstw a0@(24)
	beqs L6f2
	moveal a5@(12),a0
	bset #5,a0@(23)
	moveal a5@(16),a0
	clrw a0@(24)
L6f2:
	movew a3@(26),d0
	extl d0
	.short 0x0280,0x0000,0xc000	/* andil #49152,d0 */
	movew d0,a5@(-64)
	.short 0x0440,0x8000	/* subiw #-32768,d0 */
	beqs L72e
	.short 0x0440,0x8000	/* subiw #-32768,d0 */
	beqs L716
	.short 0x0440,0x4000	/* subiw #16384,d0 */
	beqs L722
	bras L738
L716:
	moveal a5@(12),a0
	bset #1,a0@(22)
	bras L738
L722:
	moveal a5@(12),a0
	bset #7,a0@(23)
	bras L738
L72e:
	moveal a5@(12),a0
	bset #0,a0@(22)
L738:
	movel a3,d0
	.short 0x7220	/* moveq #32,d1 */
	addl d1,d0
	.short 0x72e0	/* moveq #-32,d1 */
	addl a2@(2),d1
	movel d0,a5@(-4)
	moveml d1,a5@(-52)
	tstw a3@(30)
	beqw L81c
	.short 0x7a00	/* moveq #0,d5 */
	movel d0,a5@(-8)
L75c:
	cmpw a3@(30),d5
	bgew L808
	movel d5,d0
	extl d0
	addl d0,d0
	moveal a5@(-8),a0
	.short 0x3230,0x0800	/* movew a0@(0,d0:l),d1 */
	extl d1
	.short 0x0281,0x0000,0xc000	/* andil #49152,d1 */
	movel d1,d6
	movel d6,d0
	.short 0x0440,0x8000	/* subiw #-32768,d0 */
	beqs L7a8
	.short 0x0440,0x4000	/* subiw #16384,d0 */
	beqs L7b0
	.short 0x0440,0x4000	/* subiw #16384,d0 */
	beqs L798
	.short 0x0440,0x4000	/* subiw #16384,d0 */
	beqs L7a0
	bras L7b6
L798:
	.short 0x3b7c,0x0001,0xfff0	/* movew #1,a5@(-16) */
	bras L7b6
L7a0:
	.short 0x3b7c,0x0002,0xfff0	/* movew #2,a5@(-16) */
	bras L7b6
L7a8:
	.short 0x3b7c,0x0004,0xfff0	/* movew #4,a5@(-16) */
	bras L7b6
L7b0:
	.short 0x3b7c,0x0008,0xfff0	/* movew #8,a5@(-16) */
L7b6:
	movel d5,d0
	extl d0
	addl d0,d0
	.short 0x3e3c,0x3fff	/* movew #16383,d7 */
	moveal a5@(-8),a0
	.short 0xce70,0x0800	/* andw a0@(0,d0:l),d7 */
	movel d7,d0
	extl d0
	movel d0,a5@(-12)
	.short 0x3b7c,0x0001,0xfff2	/* movew #1,a5@(-14) */
	moveal a5@(12),a0
	.short 0xd0fc,0x003a	/* addaw #58,a0 */
	lea a5@(-16),a1
	.short 0x7008	/* moveq #8,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes L7fa
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
L7fa:
	.short 0x54ad,0xfffc	/* addql #2,a5@(-4) */
	.short 0x55ad,0xffcc	/* subql #2,a5@(-52) */
	.short 0x5245	/* addqw #1,d5 */
	braw L75c
L808:
	moveal a5@(12),a0
	.short 0xd0fc,0x003a	/* addaw #58,a0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1062)
L81c:
	.short 0x303c,0x03ff	/* movew #1023,d0 */
	andw a3@(22),d0
	.short 0x323c,0x03ff	/* movew #1023,d1 */
	andw a3@(28),d1
	.short 0x7400	/* moveq #0,d2 */
	movel d2,a5@(-44)
	.short 0x7600	/* moveq #0,d3 */
	moveb d3,a5@(-33)
	.short 0x7800	/* moveq #0,d4 */
	movew d4,a5@(-40)
	.short 0x3b7c,0x000c,0xffda	/* movew #12,a5@(-38) */
	moveb d3,a5@(-36)
	.short 0x3b7c,0x000e,0xffe8	/* movew #14,a5@(-24) */
	.short 0x3b7c,0x0064,0xffe6	/* movew #100,a5@(-26) */
	movel d2,a5@(-32)
	moveb d3,a5@(-27)
	moveb d3,a5@(-35)
	moveb d3,a5@(-28)
	movew d0,a5@(-46)
	movemw d1,a5@(-48)
	beqs L886
	btst #0,d0
	beqs L882
	movel d3,d0
	.short 0x0000,0x0001	/* orib #1,d0 */
	moveb d0,a5@(-35)
	bras L886
L882:
	movew d4,a5@(-46)
L886:
	moveb d3,a5@(-34)
	.short 0x7001	/* moveq #1,d0 */
	cmpw d0,d1
	bnes L896
	.short 0x1b7c,0x0002,0xffde	/* moveb #2,a5@(-34) */
L896:
	.short 0x5541	/* subqw #2,d1 */
	bnes L8a0
	.short 0x1b7c,0x0001,0xffde	/* moveb #1,a5@(-34) */
L8a0:
	tstl a5@(-52)
	beqw Lbee
	moveal a5@(-4),a0
	movew a0@,d0
	movemw d0,a5@(-54)
	bgew Lb1c
	.short 0x0240,0xfc00	/* andiw #-1024,d0 */
	.short 0x323c,0x03ff	/* movew #1023,d1 */
	andw a5@(-54),d1
	movew d0,a5@(-58)
	movew d0,a5@(-56)
	movew d1,a5@(-62)
	.short 0x0440,0x9000	/* subiw #-28672,d0 */
	beqw Lbe2
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqs L91a
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqw Lbe2
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqw L992
	.short 0x0440,0x0800	/* subiw #2048,d0 */
	beqw La98
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqw L9e6
	.short 0x0440,0x0800	/* subiw #2048,d0 */
	beqw Lbe2
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqw La24
	.short 0x0440,0x0400	/* subiw #1024,d0 */
	beqw La5e
	braw Lbe2
L91a:
	btst #1,a5@(-61)
	bnes L92a
	btst #2,a5@(-61)
	beqs L930
L92a:
	.short 0x7000	/* moveq #0,d0 */
	movew d0,a5@(-62)
L930:
	movew a5@(-62),d0
	cmpw a5@(-46),d0
	beqw Lbe2
	movel a5@(-44),d0
	tstl d0
	bles L96c
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes L968
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
L968:
	clrl a5@(-44)
L96c:
	.short 0x7000	/* moveq #0,d0 */
	moveb d0,a5@(-35)
	clrw a5@(-46)
	btst #0,a5@(-61)
	beqw Lbe2
	.short 0x0000,0x0001	/* orib #1,d0 */
	moveb d0,a5@(-35)
	movew a5@(-62),a5@(-46)
	braw Lbe2
L992:
	movel a5@(-44),d0
	tstl d0
	bles L9c2
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes L9be
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
L9be:
	clrl a5@(-44)
L9c2:
	clrb a5@(-34)
	movew a5@(-62),d0
	.short 0x7201	/* moveq #1,d1 */
	cmpw d1,d0
	bnes L9d6
	.short 0x1b7c,0x0002,0xffde	/* moveb #2,a5@(-34) */
L9d6:
	.short 0x5540	/* subqw #2,d0 */
	bnew Lbe2
	.short 0x1b7c,0x0001,0xffde	/* moveb #1,a5@(-34) */
	braw Lbe2
L9e6:
	movel a5@(-44),d0
	tstl d0
	bles La16
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes La12
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
La12:
	clrl a5@(-44)
La16:
	moveal a5@(16),a0
	.short 0x317c,0x0001,0x0018	/* movew #1,a0@(24) */
	braw Lbe2
La24:
	movel a5@(-44),d0
	tstl d0
	bles La54
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes La50
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
La50:
	clrl a5@(-44)
La54:
	.short 0x1b7c,0x0002,0xffdf	/* moveb #2,a5@(-33) */
	braw Lbe2
La5e:
	moveb a5@(-33),d0
	.short 0x5500	/* subqb #2,d0 */
	bnew Lbe2
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes La8c
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
La8c:
	clrb a5@(-33)
	clrl a5@(-44)
	braw Lbe2
La98:
	movel a5@(-44),d0
	tstl d0
	bles Lac4
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes Lac4
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
Lac4:
	.short 0x1b7c,0x0001,0xffdf	/* moveb #1,a5@(-33) */
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a5@(-44)
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes Laf4
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
Laf4:
	moveal a5@(12),a0
	.short 0xd0fc,0x001a	/* addaw #26,a0 */
	lea %pc@(L30),a1
	.short 0x7001	/* moveq #1,d0 */
	jsr a6@(-1020)
	tstw d0
	bnes Lb10
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
Lb10:
	clrb a5@(-33)
	clrl a5@(-44)
	braw Lbe2
Lb1c:
	movew a5@(-54),d0
	extl d0
	.short 0x7200	/* moveq #0,d1 */
	notb d1
	andl d1,d0
	moveb d0,a5@(-59)
	.short 0x721f	/* moveq #31,d1 */
	cmpb d1,d0
	blss Lb5e
	moveal a5@(12),a0
	.short 0xd0fc,0x001a	/* addaw #26,a0 */
	lea a5@(-59),a1
	.short 0x7001	/* moveq #1,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes Lb56
	.short 0x7000	/* moveq #0,d0 */
	braw Lbf0
Lb56:
	.short 0x52ad,0xffd4	/* addql #1,a5@(-44) */
	braw Lbe2
Lb5e:
	.short 0x7200	/* moveq #0,d1 */
	moveb d0,d1
	.short 0x0441,0x000d	/* subiw #13,d1 */
	bnes Lbe2
	movel a5@(-44),d0
	tstl d0
	bgts Lb7a
	moveal a5@(12),a0
	tstl a0@(42)
	bnes Lb9c
Lb7a:
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	lea a5@(-44),a1
	.short 0x7016	/* moveq #22,d0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1020)
	tstw d0
	bnes Lb9c
	.short 0x7000	/* moveq #0,d0 */
	bras Lbf0
Lb9c:
	moveal a5@(12),a0
	.short 0xd0fc,0x002a	/* addaw #42,a0 */
	moveal a5@(24),a6
	moveal a6@(8),a6
	jsr a6@(-1062)
	moveal a5@(12),a0
	.short 0xd0fc,0x001a	/* addaw #26,a0 */
	jsr a6@(-1062)
	moveal a5@(12),a0
	.short 0xd0fc,0x003a	/* addaw #58,a0 */
	jsr a6@(-1062)
	moveal a5@(20),a1
	moveal a1@(48),a0
	lea a0@(154),a1
	moveal a1,a0
	moveal a5@(12),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-246)
Lbe2:
	.short 0x54ad,0xfffc	/* addql #2,a5@(-4) */
	.short 0x55ad,0xffcc	/* subql #2,a5@(-52) */
	braw L8a0
Lbee:
	.short 0x7001	/* moveq #1,d0 */
Lbf0:
	moveml sp@+,d2-d7/a2-a3/a6
	unlk a5
	rts
Lbf8:
	moveml d5-d7,sp@-
	movel d0,d7
	movel d1,d6
	movel d7,d0
	.short 0xc1fc,0x02d0	/* mulsw #720,d0 */
	movel d6,d1
	extl d1
	jsr %pc@(Lc30)
	movel d0,d5
	movel d5,d0
	moveml sp@+,d5-d7
	rts
Lc18:
	movel a3,sp@-
	moveal a0,a3
	movel a3,d0
	moveal sp@+,a3
	rts
Lc22:
	linkw a5,#-4
	movel a0,a5@(-4)
	.short 0x7001	/* moveq #1,d0 */
	unlk a5
	rts
Lc30:
	.short 0x4ef9,0x0000,0x0000	/* jmp 0x0 */
	.short 0x7061	/* moveq #97,d0 */
	.short 0x0000,0x0032	/* orib #50,d0 */
	.short 0x0000,0x009a	/* orib #-102,d0 */
	.short 0x0000,0x004a	/* orib #74,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x00fc	/* orib #-4,d0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
	.short 0x0000,0x0022	/* orib #34,d0 */
	.short 0x0000,0x0c38	/* orib #56,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x00bc	/* orib #-68,d0 */
	illegal
	.short 0x0000,0x0c60	/* orib #96,d0 */
	.short 0x0000,0x0c7a	/* orib #122,d0 */
	orb d3,d0
	btst d4,d0
	.short 0x0000,0x0004	/* orib #4,d0 */
	.short 0x0000,0x0016	/* orib #22,d0 */
	.short 0x0000,0x0c50	/* orib #80,d0 */
	.byte 0x00,0x00,0x00,0x00,0x00,0x00	/* orib #0,d0 */
	.data
	.byte 0x4a,0x80,0x6a,0x00,0x00,0x1e,0x44,0x80,0x4a,0x81,0x6a,0x00,0x00,0x0c,0x44,0x81
	.byte 0x61,0x00,0x00,0x20,0x44,0x81,0x4e,0x75,0x61,0x00,0x00,0x18,0x44,0x80,0x44,0x81
	.byte 0x4e,0x75,0x4a,0x81,0x6a,0x00,0x00,0x0c,0x44,0x81,0x61,0x00,0x00,0x06,0x44,0x80
	.byte 0x4e,0x75,0x2f,0x02,0x48,0x41,0x34,0x01,0x66,0x00,0x00,0x22,0x48,0x40,0x48,0x41
	.byte 0x48,0x42,0x34,0x00,0x67,0x00,0x00,0x06,0x84,0xc1,0x30,0x02,0x48,0x40,0x34,0x00
	.byte 0x84,0xc1,0x30,0x02,0x48,0x42,0x32,0x02,0x24,0x1f,0x4e,0x75,0x2f,0x03,0x76,0x10
	.byte 0x0c,0x41,0x00,0x80,0x64,0x00,0x00,0x06,0xe1,0x99,0x51,0x43,0x0c,0x41,0x08,0x00
	.byte 0x64,0x00,0x00,0x06,0xe9,0x99,0x59,0x43,0x0c,0x41,0x20,0x00,0x64,0x00,0x00,0x06
	.byte 0xe5,0x99,0x55,0x43,0x4a,0x41,0x6b,0x00,0x00,0x06,0xe3,0x99,0x53,0x43,0x34,0x00
	.byte 0xe6,0xa8,0x48,0x42,0x42,0x42,0xe6,0xaa,0x48,0x43,0x80,0xc1,0x36,0x00,0x30,0x02
	.byte 0x34,0x03,0x48,0x41,0xc4,0xc1,0x90,0x82,0x64,0x00,0x00,0x08,0x53,0x43,0xd0,0x81
	.byte 0x64,0xfe,0x72,0x00,0x32,0x03,0x48,0x43,0xe7,0xb8,0x48,0x40,0xc1,0x41,0x26,0x1f
	.byte 0x24,0x1f,0x4e,0x75
