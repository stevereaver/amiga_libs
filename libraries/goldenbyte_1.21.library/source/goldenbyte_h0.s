	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0c,0x38,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x31,0x00,0x00,0x00,0x50,0x67,0x6f
	.byte 0x6c,0x64,0x65,0x6e,0x62,0x79,0x74,0x65,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79
	.byte 0x00,0x47,0x4f,0x4c,0x44,0x45,0x4e,0x20,0x42,0x59,0x54,0x45,0x20,0x31,0x2e,0x32
	.byte 0x31,0x20,0x28,0x32,0x34,0x2e,0x30,0x32,0x2e,0x39,0x37,0x29,0x0d,0x0a,0x00,0x00
	.byte 0x00,0x00,0x00,0x62,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc8
	.byte 0x00,0x00,0x00,0xe2,0x00,0x00,0x00,0xea,0x00,0x00,0x00,0xf2,0x00,0x00,0x01,0x8a
	.byte 0x00,0x00,0x02,0x42,0x00,0x00,0x03,0x4c,0x00,0x00,0x03,0xc0,0x00,0x00,0x03,0xf4
	.byte 0x00,0x00,0x04,0x10,0x00,0x00,0x04,0xac,0x00,0x00,0x04,0xf4,0x00,0x00,0x05,0x3c
	.byte 0x00,0x00,0x05,0xa8,0x00,0x00,0x06,0x12,0x00,0x00,0x06,0x2e,0x00,0x00,0x06,0x94
	.byte 0x00,0x00,0x06,0xee,0x00,0x00,0x07,0x02,0x00,0x00,0x07,0x26,0x00,0x00,0x07,0x5e
	.byte 0x00,0x00,0x07,0xe2,0x00,0x00,0x09,0xc8,0x00,0x00,0x0b,0x06,0x00,0x00,0x0b,0x36
	.short 0x0000,0x0b98	/* orib #-104,d0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
	exg d0,a5
	movel a6,a5@(34)
	movel a0,a5@(38)
	.short 0x3b7c,0x0015,0x0016	/* movew #21,a5@(22) */
	.short 0x4eb9,0x0000,0x018e	/* jsr 0x18e */
	exg d0,a5
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	rts
	.short 0x7000	/* moveq #0,d0 */
	movew a6@(32),d2
	tstw d2
	bnew L188
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(50),a6
	moveal a5@(86),a1
	jsr a6@(-78)
	moveal a5@(42),a6
	moveal a5@(78),a1
	jsr a6@(-414)
	moveal a5@(74),a1
	jsr a6@(-414)
	moveal a5@(70),a1
	jsr a6@(-414)
	moveal a5@(66),a1
	jsr a6@(-414)
	moveal a5@(62),a1
	jsr a6@(-414)
	moveal a5@(58),a1
	jsr a6@(-414)
	moveal a5@(54),a1
	jsr a6@(-414)
	moveal a5@(50),a1
	jsr a6@(-414)
	moveal a5@(46),a1
	jsr a6@(-414)
	movel a5@(38),d2
	moveal a5,a1
	moveal a1@+,a0
	moveal a1@,a1
	movel a0,a1@
	movel a1,a0@(4)
	moveal a5@(34),a6
	moveal a5,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
	moveml sp@+,d2/a5-a6
L188:
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d0-a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	movel a6,a5@(42)
	lea %pc@(L290),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(46)
	lea %pc@(L2a2),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(50)
	lea %pc@(L2b4),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(54)
	lea %pc@(L2c0),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(58)
	lea %pc@(L2d0),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(62)
	lea %pc@(L2e2),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(66)
	lea %pc@(L2f2),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(70)
	lea %pc@(L304),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(74)
	lea %pc@(L318),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(78)
	lea %pc@(L32a),a1
	.short 0x203c,0x0000,0x0000	/* movel #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(82)
	lea %pc@(L338),a0
	moveal a5@(50),a6
	jsr a6@(-72)
	movel d0,a5@(86)
	moveml sp@+,d0-a6
	rts
	moveal a6,a5
	movel a5@(42),d0
	movel a5@(62),d1
	tstl d1
	bnew L266
	moveal d0,a6
	lea %pc@(L2d0),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(62)
	movel a5@(62),d1
L266:
	movel a5@(42),d0
	movel a5@(50),d2
	movel a5@(66),d3
	movel a5@(74),d4
	movel a5@(78),d5
	movel a5@(58),d6
	movel a5@(70),d7
	moveal a5@(86),a0
	moveal a5@(54),a1
	moveal a5@(82),a2
	rts
L290:
	bvss L300
	.short 0x7475	/* moveq #117,d2 */
	bvss L30a
	bvss L307
	bgts L2c8
	bges L305
	bhis L310
	bsrs L312
	.short 0x7900	/* .short 0x7900 */
L2a2:
	beqs L316
	bsrs L316
	bvcs L311
	blss L31d
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L2b4:
	.byte 0x64,0x6f	/* orib #111,d0 */
	.short 0x732e	/* .short 0x732e */
	bges L323
	bhis L32e
	bsrs L330
	.short 0x7900	/* .short 0x7900 */
L2c0:
	.short 0x7574	/* .short 0x7574 */
	bvss L330
	bvss L33a
	.short 0x792e	/* .short 0x792e */
L2c8:
	bges L333
	bhis L33e
	bsrs L340
	.short 0x7900	/* .short 0x7900 */
L2d0:
	.short 0x776f	/* .short 0x776f */
	.short 0x726b	/* moveq #107,d1 */
	bhis L33b
	bgts L33b
	bvcs L308
	bges L345
	bhis L350
	bsrs L352
	.short 0x7900	/* .short 0x7900 */
L2e2:
	bges L345
	.short 0x7965	/* .short 0x7965 */
	.short 0x7273	/* moveq #115,d1 */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L2f2:
	.byte 0x72,0x65	/* orib #101,d0 */
	.short 0x7174	/* .short 0x7174 */
	bles L367
	bges L36d
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
L300:
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L304:
	.byte 0x63
L305:
	.byte 0x6f	/* orib #111,d0 */
	.byte 0x6d
L307:
	.byte 0x6d	/* blts 0x375 */
L308:
	bles L36e
L30a:
	bvss L380
	bvss L373
	.short 0x732e	/* .short 0x732e */
L310:
	.byte 0x6c
L311:
	.byte 0x69	/* bges 0x37b */
L312:
	bhis L386
	bsrs L388
L316:
	.short 0x7900	/* .short 0x7900 */
L318:
	bccs L383
	.short 0x736b	/* .short 0x736b */
	.byte 0x66
L31d:
	.byte 0x6f	/* bnes 0x38d */
	bgts L394
	.byte 0x2e,0x6c,0x69
L323:
	.byte 0x62	/* moveal a4@(26978),sp */
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L32a:
	.byte 0x69,0x63	/* orib #99,d0 */
	bles L39c
L32e:
	.byte 0x2e,0x6c
L330:
	.byte 0x69,0x62	/* moveal a4@(26978),sp */
	.byte 0x72
L333:
	.byte 0x61	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L338:
	.byte 0x00,0x00	/* orib #0,d0 */
L33a:
	.byte 0x03
L33b:
	.byte 0x40	/* bchg d1,d0 */
	.short 0x0008	/* .short 0x0008 */
L33e:
	.byte 0x00,0x01
L340:
	.byte 0x74,0x6f	/* orib #111,d1 */
	.short 0x7061	/* moveq #97,d0 */
	.byte 0x7a
L345:
	.byte 0x2e	/* moveq #46,d5 */
	bnes L3b7
	bgts L3be
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.byte 0x00,0x2e
L350:
	.byte 0x2a,0x4e
L352:
	.byte 0x28,0x48	/* orib #78,a6@(10312) */
	moveal a5@(42),a6
	.short 0x7074	/* moveq #116,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-684)
	moveal d0,a2
	.byte 0x67
L367:
	.byte 0x00,0x00,0x38	/* beqw 0x3a0 */
	movel a4,a2@+
	.byte 0x20
L36d:
	.byte 0x4a	/* moveal a2,a0 */
L36e:
	moveal a5@(46),a6
	.byte 0x4e
L373:
	.byte 0xae,0xff
L375:
	.byte 0x76	/* jsr a6@(-138) */
	moveal a2,a0
	moveal a4,a1
	.byte 0x4e
L37b:
	.byte 0xae,0xff,0x10	/* jsr a6@(-240) */
	tstl d0
L380:
	.byte 0x67,0x00,0x00
L383:
	.byte 0x14	/* beqw 0x396 */
	moveal a4,a0
L386:
	.byte 0x43,0xfa
L388:
	.byte 0x00,0x20	/* lea %pc@(0x3a8),a1 */
	.byte 0x4e,0xae,0xfc
L38d:
	.byte 0xd0	/* jsr a6@(-816) */
	movel a2,d0
	moveml sp@+,a2/a4-a6
L394:
	rts
L396:
	moveal a2,a1
	moveal a5@(42),a6
L39c:
	jsr a6@(-690)
L3a0:
	moveml sp@+,a2/a4-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
L3a8:
	orb d0,d0
	.short 0x0098,0xffff,0xffff	/* oril #-1,a0@+ */
	orb d0,d0
	.byte 0x00,0x99,0xff,0xff,0xff
L3b7:
	.byte 0xff,0x00,0x00,0x00,0x00,0x00,0x00
L3be:
	.byte 0x00,0x00	/* oril #-1,a1@+ */
	moveml a2/a4-a6,sp@-
	moveal a6,a5
	moveal a0@(-4),a4
	moveal a0,a2
	moveal a4,a1
	moveal a5@(46),a6
	jsr a6@(-120)
	moveal a4,a0
	jsr a6@(-60)
	moveal a2,a1
	.short 0x93fc,0x0000,0x0004	/* subal #4,a1 */
	.short 0x7074	/* moveq #116,d0 */
	moveal a5@(42),a6
	jsr a6@(-210)
	moveml sp@+,a2/a4-a6
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	tstl d1
	beqs L402
	bset #31,d0
L402:
	moveal a5@(42),a6
	jsr a6@(-318)
	moveml sp@+,a5-a6
	rts
	moveml d1-d6/a0-a5,sp@-
	moveal a6,a5
	movel a0,d0
	tstl d0
	beqw L452
	movel a1,d0
	tstl d0
	beqw L452
	moveal a0,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L452
	movel d0,d2
	moveal a1,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L452
	movel d0,d3
	.short 0x4eb9,0x0000,0x0456	/* jsr 0x456 */
	moveml sp@+,d1-d6/a0-a5
	rts
L452:
	.short 0x7000	/* moveq #0,d0 */
	rts
	movel d2,d1
	.short 0x2c3c,0x0000,0x0000	/* movel #0,d6 */
L45e:
	moveal a0,a4
	.short 0x92bc,0x0000,0x0001	/* subl #1,d1 */
	movel d3,d4
	moveal a1,a3
	.short 0x2a3c,0xffff,0xffff	/* movel #-1,d5 */
	.short 0xdcbc,0x0000,0x0001	/* addl #1,d6 */
L476:
	.short 0x98bc,0x0000,0x0001	/* subl #1,d4 */
	cmpmb a4@+,a3@+
	beqw L488
	.short 0x2a3c,0x0000,0x0000	/* movel #0,d5 */
L488:
	tstl d4
	bnew L476
	tstl d5
	bnew L49c
	tstl d1
	moveb a0@+,d5
	bnew L45e
L49c:
	.short 0x203c,0x0000,0x0000	/* movel #0,d0 */
	tstl d5
	beqw L4aa
	movel d6,d0
L4aa:
	rts
	moveml d0-d2/a0-a3,sp@-
	movel a0,d0
	tstl d0
	beqw L4ee
	moveal a0,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L4ee
	.short 0xd0bc,0x0000,0x0001	/* addl #1,d0 */
L4cc:
	.short 0x90bc,0x0000,0x0001	/* subl #1,d0 */
	tstl d0
	beqw L4ee
	moveb a0@+,d2
	.short 0xb43c,0x0020	/* cmpb #32,d2 */
	beqs L4cc
	bclr #5,d2
	.short 0x91fc,0x0000,0x0001	/* subal #1,a0 */
	moveb d2,a0@+
	bras L4cc
L4ee:
	moveml sp@+,d0-d2/a0-a3
	rts
	moveml d0-d2/a0-a3,sp@-
	movel a0,d0
	tstl d0
	beqw L536
	moveal a0,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L536
	.short 0xd0bc,0x0000,0x0001	/* addl #1,d0 */
L514:
	.short 0x90bc,0x0000,0x0001	/* subl #1,d0 */
	tstl d0
	beqw L536
	moveb a0@+,d2
	.short 0xb43c,0x0020	/* cmpb #32,d2 */
	beqs L514
	bset #5,d2
	.short 0x91fc,0x0000,0x0001	/* subal #1,a0 */
	moveb d2,a0@+
	bras L514
L536:
	moveml sp@+,d0-d2/a0-a3
	rts
	moveml d0-d3/a0-a3,sp@-
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	movel a0,d1
	tstl d1
	beqw L5a2
	tstl d0
	beqw L5a2
L554:
	.short 0x90bc,0x0000,0x0001	/* subl #1,d0 */
	moveb a0@+,d2
	.short 0x91fc,0x0000,0x0001	/* subal #1,a0 */
	.short 0xb47c,0x0001	/* cmpw #1,d2 */
	bcsw L582
	btst #0,d2
	bnew L58e
	.short 0x84fc,0x0002	/* divuw #2,d2 */
	moveb d2,a0@+
	tstl d0
	beqw L5a2
	braw L554
L582:
	moveb d2,a0@+
	tstl d0
	bnew L554
	braw L5a2
L58e:
	.short 0xd43c,0x0001	/* addb #1,d2 */
	.short 0x84fc,0x0002	/* divuw #2,d2 */
	bset #7,d2
	moveb d2,a0@+
	tstl d0
	bnew L554
L5a2:
	moveml sp@+,d0-d3/a0-a3
	rts
	moveml d0-d3/a0-a3,sp@-
	.short 0x7400	/* moveq #0,d2 */
	movel a0,d1
	tstl d1
	beqw L60c
	moveal a0,a3
	tstl d0
	beqw L60c
L5be:
	.short 0x90bc,0x0000,0x0001	/* subl #1,d0 */
	moveb a0@+,d2
	.short 0x91fc,0x0000,0x0001	/* subal #1,a0 */
	btst #7,d2
	bnew L5f8
	.short 0xb47c,0x0000	/* cmpw #0,d2 */
	blew L5ec
	.short 0xc4fc,0x0002	/* muluw #2,d2 */
	moveb d2,a0@+
	tstl d0
	beqw L60c
	braw L5be
L5ec:
	moveb d2,a0@+
	tstl d0
	bnew L5be
	braw L60c
L5f8:
	bclr #7,d2
	.short 0xc4fc,0x0002	/* muluw #2,d2 */
	.short 0x943c,0x0001	/* subb #1,d2 */
	moveb d2,a0@+
	tstl d0
	bnew L5be
L60c:
	moveml sp@+,d0-d3/a0-a3
	rts
	moveml d0-d6/a0-a6,sp@-
	moveal a6,a5
	moveal a5@(42),a6
	.short 0x203c,0x3b9a,0xca00	/* movel #1000000000,d0 */
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-198)
	moveml sp@+,d0-d6/a0-a6
	rts
	moveml d1-d6/a0-a6,sp@-
	moveal a6,a5
	moveal a5@(42),a6
	movel a0,d2
	movel d0,d3
	jsr a6@(-666)
	tstl d0
	beqw L68e
	movel d0,d6
	tstl d2
	beqw L686
	moveal d2,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L686
	.short 0xd0bc,0x0000,0x0001	/* addl #1,d0 */
	movel d0,d5
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqw L686
	movel d0,d4
	moveal d2,a0
	moveal d4,a1
	movel d5,d0
	jsr a6@(-624)
	moveal d6,a1
	movel d4,a1@(10)
L686:
	moveal d6,a1
	moveb d3,a1@(9)
	movel d6,d0
L68e:
	moveml sp@+,d1-d6/a0-a6
	rts
	moveml d0-d6/a0-a6,sp@-
	moveal a6,a5
	moveal a0,a4
	moveal a5@(42),a6
	movel a0,d0
	tstl d0
	bnew L6bc
	movel a1,d0
	tstl d0
	beqw L6e8
	jsr a6@(-390)
	tstl d0
	beqw L6e8
	moveal d0,a4
L6bc:
	movel a4@(10),d0
	tstl d0
	beqw L6e0
	movel d0,d2
	moveal d0,a3
	.short 0x4eb9,0x0000,0x0bfa	/* jsr 0xbfa */
	tstl d0
	beqw L6e0
	.short 0xd07c,0x0001	/* addw #1,d0 */
	moveal d2,a1
	jsr a6@(-210)
L6e0:
	moveal a4,a1
	moveal a4,a0
	jsr a6@(-672)
L6e8:
	moveml sp@+,d0-d6/a0-a6
	rts
	moveal a6,a5
	moveal a5@(54),a6
	jsr a6@(-42)
	moveal d2,a0
	.short 0x4eb9,0x0000,0x05a8	/* jsr 0x5a8 */
	rts
	moveal a6,a5
	moveal d2,a0
	movel d3,d0
	.short 0x4eb9,0x0000,0x053c	/* jsr 0x53c */
	moveal a5@(54),a6
	jsr a6@(-48)
	movel d0,d4
	moveal d2,a0
	movel d3,d0
	.short 0x4eb9,0x0000,0x05a8	/* jsr 0x5a8 */
	movel d4,d0
	rts
	moveml d1-d2/a5-a6,sp@-
	tstl d0
	beqw L752
	moveal a6,a5
	moveal a5@(54),a6
	movel d0,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	tstl d0
	beqw L758
	movel d0,d1
	jsr a6@(-90)
	.short 0x203c,0xffff,0xffff	/* movel #-1,d0 */
	bras L758
L752:
	.short 0x203c,0x0000,0x0000	/* movel #0,d0 */
L758:
	moveml sp@+,d1-d2/a5-a6
	rts
	moveml d1-d5/a4-a6,sp@-
	tstl d0
	beqw L7c0
	moveal a6,a5
	moveal a5@(54),a6
	movel d0,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	tstl d0
	beqw L7dc
	movel d0,d3
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x223c,0x0001,0x0000	/* movel #65536,d1 */
	moveal a5@(42),a6
	jsr a6@(-198)
	tstl d0
	beqw L7d0
	movel d0,d4
	moveal a5@(54),a6
	movel d3,d1
	movel d4,d2
	jsr a6@(-102)
	moveal d4,a4
	movel a4@(124),d5
	moveal a4,a1
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	moveal a5@(42),a6
	jsr a6@(-210)
	braw L7d0
L7c0:
	.short 0x203c,0x0000,0x0000	/* movel #0,d0 */
	.short 0x2a3c,0x0000,0x0000	/* movel #0,d5 */
	braw L7dc
L7d0:
	movel d3,d1
	moveal a5@(54),a6
	jsr a6@(-90)
	movel d5,d0
L7dc:
	moveml sp@+,d1-d5/a4-a6
	rts
	moveml d1-a5,sp@-
	moveal a6,a5
	moveal a5@(42),a6
	.short 0x203c,0x0000,0x0030	/* movel #48,d0 */
	.short 0x223c,0x0001,0x0002	/* movel #65538,d1 */
	moveml a1,sp@-
	jsr a6@(-198)
	moveml sp@+,a1
	tstl d0
	beqw L9c2
	moveal d0,a0
	movew d2,a0@
	movew d3,a0@(2)
	movew d4,a0@(4)
	movew d5,a0@(6)
	.short 0x117c,0x0001,0x0008	/* moveb #1,a0@(8) */
	.short 0x117c,0x0002,0x0009	/* moveb #2,a0@(9) */
	movel d6,a0@(10)
	movel d7,a0@(14)
	movel a1,a0@(18)
	movel a2,a0@(26)
	movel a3,a0@(30)
	movel a4,a0@(34)
	.short 0x317c,0x000f,0x002e	/* movew #15,a0@(46) */
	moveal a0,a4
	movel a0@(30),d0
	.short 0xb0bc,0xffff,0xffff	/* cmpl #-1,d0 */
	bnew L85e
	moveal a5@(46),a0
	movel a0@(60),a4@(30)
L85e:
	movel a4@(30),d0
	tstl d0
	bnew L874
	moveal a5@(46),a6
	jsr a6@(-210)
	movel d0,a4@(30)
L874:
	movel a4@(30),d1
	tstl d1
	bnew L888
	moveal a5@(46),a0
	movel a0@(60),a4@(30)
L888:
	movew a4@(4),d1
	.short 0xb27c,0xffff	/* cmpw #-1,d1 */
	bnew L8a2
	moveal a4@(30),a0
	movew a0@(12),a4@(4)
	.short 0x38bc,0x0000	/* movew #0,a4@ */
L8a2:
	.short 0x223c,0x0000,0x0000	/* movel #0,d1 */
	movel a4@(26),d2
	tstl d2
	beqw L8ca
	.short 0x243c,0x0000,0x0000	/* movel #0,d2 */
	moveal a4@(30),a0
	movew a4@(6),d1
	moveb a0@(30),d2
	addw d2,d1
	movew d1,a4@(6)
L8ca:
	movew a4@(6),d1
	.short 0xb27c,0xffff	/* cmpw #-1,d1 */
	bnew L8e6
	moveal a4@(30),a0
	movew a0@(14),a4@(6)
	.short 0x397c,0x0000,0x0002	/* movew #0,a4@(2) */
L8e6:
	.short 0x223c,0x0000,0x0000	/* movel #0,d1 */
	.short 0x243c,0x0000,0x0000	/* movel #0,d2 */
	movew a4@,d1
	.short 0xb27c,0xffff	/* cmpw #-1,d1 */
	bnew L920
	movew a4@(4),d1
	moveal a4@(30),a0
	movew a0@(12),d2
	subw d1,d2
	.short 0xb47c,0x0000	/* cmpw #0,d2 */
	beqw L91c
	.short 0x84fc,0x0002	/* divuw #2,d2 */
	movew d2,a4@
	braw L920
L91c:
	.short 0x38bc,0x0000	/* movew #0,a4@ */
L920:
	.short 0x223c,0x0000,0x0000	/* movel #0,d1 */
	.short 0x243c,0x0000,0x0000	/* movel #0,d2 */
	movew a4@(2),d1
	.short 0xb27c,0xffff	/* cmpw #-1,d1 */
	bnew L95e
	movew a4@(6),d1
	moveal a4@(30),a0
	movew a0@(14),d2
	subw d1,d2
	tstw d2
	beqw L958
	.short 0x84fc,0x0002	/* divuw #2,d2 */
	movew d2,a4@(2)
	braw L95e
L958:
	.short 0x397c,0x0000,0x0002	/* movew #0,a4@(2) */
L95e:
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	movew a4@(2),d1
	moveal a4@(30),a1
	moveb a1@(30),d2
	cmpw d2,d1
	bhiw L988
	.short 0x7200	/* moveq #0,d1 */
	.short 0xd43c,0x0001	/* addb #1,d2 */
	movew a1@(14),d1
	subw d2,d1
	movew d1,a4@(6)
	movew d2,a4@(2)
L988:
	movew a4@(4),a4@(38)
	movew a4@(6),a4@(40)
	moveal a4@(30),a1
	movew a1@(12),a4@(42)
	movew a1@(14),a4@(44)
	moveal a5@(46),a6
	moveal a4,a0
	jsr a6@(-204)
	moveal d0,a3
	moveal a5@(42),a6
	moveal a4,a1
	.short 0x203c,0x0000,0x0030	/* movel #48,d0 */
	jsr a6@(-210)
	movel a3,d0
L9c2:
	moveml sp@+,d1-a5
	rts
	moveal a6,a5
	tstl d0
	beqw La16
	movel a5@(90),d0
	tstl d0
	bnew La14
	moveal a5@(42),a6
	.short 0x207c,0xffff,0xff34	/* moveal #-204,a0 */
	moveal a5@(46),a1
	.short 0x203c,0x0000,0x0a5a	/* movel #2650,d0 */
	jsr a6@(-420)
	movel d0,a5@(90)
	.short 0x207c,0xffff,0xfda2	/* moveal #-606,a0 */
	moveal a5@(46),a1
	.short 0x203c,0x0000,0x0a6c	/* movel #2668,d0 */
	jsr a6@(-420)
	movel d0,a5@(94)
	lea %pc@(Laf4),a6
	movel a5,a6@
La14:
	rts
La16:
	movel a5@(90),d1
	tstl d1
	beqw La58
	moveal a5@(42),a6
	moveal a5@(46),a1
	.short 0x207c,0xffff,0xff34	/* moveal #-204,a0 */
	movel a5@(90),d0
	jsr a6@(-420)
	moveal a5@(46),a1
	.short 0x207c,0xffff,0xfda2	/* moveal #-606,a0 */
	movel a5@(94),d0
	jsr a6@(-420)
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0x00,0x5a	/* movel #0,a5@(90) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0x00,0x5e	/* movel #0,a5@(94) */
La58:
	rts
	moveml d1-d7/a1-a6,sp@-
	.short 0x227c,0x0000,0x0af8	/* moveal #2808,a1 */
	jsr %pc@(La6c)
	moveml sp@+,d1-d7/a1-a6
La6c:
	moveml d1-a6,sp@-
	moveal %pc@(Laf4),a5
	moveml d0-a6,sp@-
	movel a0,d0
	tstl d0
	beqw Lae2
	.short 0x203c,0x0000,0x0000	/* movel #0,d0 */
	.short 0x223c,0x0000,0x0000	/* movel #0,d1 */
	.short 0x243c,0x0000,0x0000	/* movel #0,d2 */
	.short 0x263c,0x0000,0x0000	/* movel #0,d3 */
	movew a0@,d0
	movew a0@(2),d1
	movew a0@(4),d2
	.short 0x947c,0x0001	/* subw #1,d2 */
	movew a0@(6),d3
	.short 0x967c,0x0001	/* subw #1,d3 */
	.short 0x283c,0x0000,0x0003	/* movel #3,d4 */
	movel a0@(30),d5
	tstl d5
	bnew Lac6
	moveal a5@(46),a0
	moveal a0@(56),a0
Lac6:
	moveal d5,a0
	.short 0xd1fc,0x0000,0x0054	/* addal #84,a0 */
	moveal a5,a6
	jsr %pc@(Lb06)
	moveal a5@(54),a6
	.short 0x223c,0x0000,0x0032	/* movel #50,d1 */
	jsr a6@(-198)
Lae2:
	moveml sp@+,d0-a6
	lea a5@(94),a2
	moveal a2@,a2
	jsr a2@
	braw Lb00
	.byte 0x4e,0x71
Laf4:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* nop */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
Lb00:
	moveml sp@+,d1-a6
	rts
Lb06:
	moveml d0-d4/a0-a6,sp@-
	moveal a6,a5
	movel a0,d5
	tstl d5
	beqw Lb30
	moveal a0,a1
	moveal a5@(50),a6
	addl d0,d2
	addl d1,d3
	moveml d0-d1/a0-a1,sp@-
	movel d4,d0
	jsr a6@(-342)
	moveml sp@+,d0-d1/a0-a1
	jsr a6@(-306)
Lb30:
	moveml sp@+,d0-d4/a0-a6
	rts
	moveml d1-d6/a0-a2,sp@-
	moveal a6,a5
	movel d1,d4
	movel a0,d1
	tstl d1
	beqw Lb92
	movel a1,d5
	tstl d5
	beqw Lb92
	movel d0,d6
	moveal a5@(54),a6
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	tstl d0
	beqw Lb8c
	moveal d0,a2
	movel d0,d1
	movel d6,d2
	.short 0x263c,0x0000,0x0000	/* movel #0,d3 */
	jsr a6@(-66)
	movel a2,d1
	movel d5,d2
	movel d4,d3
	jsr a6@(-42)
	movel d0,d5
	movel a2,d1
	jsr a6@(-36)
	movel d5,d0
	braw Lb92
Lb8c:
	.short 0x203c,0xffff,0xffff	/* movel #-1,d0 */
Lb92:
	moveml sp@+,d1-d6/a0-a2
	rts
	moveml d1-d6/a0-a2,sp@-
	moveal a6,a5
	movel d1,d4
	movel a0,d1
	tstl d1
	beqw Lbf4
	movel a1,d5
	tstl d5
	beqw Lbf4
	movel d0,d6
	moveal a5@(54),a6
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	tstl d0
	beqw Lbee
	moveal d0,a2
	movel d0,d1
	movel d6,d2
	.short 0x263c,0x0000,0x0000	/* movel #0,d3 */
	jsr a6@(-66)
	movel a2,d1
	movel d5,d2
	movel d4,d3
	jsr a6@(-48)
	movel d0,d5
	movel a2,d1
	jsr a6@(-36)
	movel d5,d0
	braw Lbf4
Lbee:
	.short 0x203c,0xffff,0xffff	/* movel #-1,d0 */
Lbf4:
	moveml sp@+,d1-d6/a0-a2
	rts
	.short 0x203c,0xffff,0xffff	/* movel #-1,d0 */
Lc00:
	.short 0xd0bc,0x0000,0x0001	/* addl #1,d0 */
	moveb a3@+,d1
	.short 0xb23c,0x0000	/* cmpb #0,d1 */
	bnew Lc00
	rts
	moveml d0-d6/a0-a6,sp@-
	.short 0x207c,0x0000,0x0000	/* moveal #0,a0 */
	moveal a5@(46),a6
	jsr a6@(-96)
	moveal a5@(54),a6
	.short 0x223c,0x0000,0x0032	/* movel #50,d1 */
	jsr a6@(-198)
	moveml sp@+,d0-d6/a0-a6
	rts
	.short 0x0000,0x4e71	/* orib #113,d0 */
