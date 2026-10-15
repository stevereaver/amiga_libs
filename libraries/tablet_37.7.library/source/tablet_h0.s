	.text
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x21,0x09,0x00,0x00,0x00
	.byte 0x0c,0xc8,0x00,0x00,0x0c,0xd8,0x00,0x00,0x00,0x04,0x00,0x00
	.byte 0x4e,0x55
	.short 0xffe8	/* .short 0xffe8 */
	moveml d6-d7/a2/a4/a6,sp@-
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	moveal a0,a2
	movel d0,a5@(-22)
	moveal a5@(-22),a0
	movel a2,a0@(34)
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	.byte 0x21,0x7c,0x00,0x00,0x0c,0xc8,0x00,0x0a	/* movel #3272,a0@(10) */
	.short 0x117c,0x0006,0x000e	/* moveb #6,a0@(14) */
	.short 0x317c,0x0025,0x0014	/* movew #37,a0@(20) */
	.short 0x317c,0x0007,0x0016	/* movew #7,a0@(22) */
	.byte 0x21,0x7c,0x00,0x00,0x0c,0xd8,0x00,0x18	/* movel #3288,a0@(24) */
	lea a0@(46),a1
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0xff,0xf8	/* movel #0,a5@(-8) */
	.short 0x41f9,0x0000,0x0031	/* lea 0x31,a0 */
	movel a0,d0
	asll #2,d0
	movel a1,a5@(-12)
	moveal a5@(-8),a0
	bras L84
L82:
	moveb a0@+,a1@+
L84:
	.short 0x5380	/* subql #1,d0 */
	bccs L82
	.short 0x41f9,0x0000,0x0031	/* lea 0x31,a0 */
	movel a0,d0
	asll #2,d0
	addl d0,a5@(-8)
	moveal a5@(-8),a0
	movel a0@+,d7
	movel a0,a5@(-8)
La0:
	tstl d7
	bles Lc0
	movel a5@(-12),d0
	movel d0,d1
	moveal a5@(-8),a0
	addl a0@+,d1
	moveal d1,a1
	addl d0,a1@
	.short 0x5387	/* subql #1,d7 */
	movel d1,a5@(-4)
	movel a0,a5@(-8)
	bras La0
Lc0:
	moveal a5@(-22),a6
	jsr %pc@(L1a0)
	movel d0,d6
	tstw d6
	beqs Ld4
	movel a5@(-22),d0
	bras Ld6
Ld4:
	.short 0x7000	/* moveq #0,d0 */
Ld6:
	moveml sp@+,d6-d7/a2/a4/a6
	unlk a5
	rts
Lde:
	moveml a2/a4/a6,sp@-
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x526a,0x0020	/* addqw #1,a2@(32) */
	bclr #3,a2@(14)
	movel a2,d0
	moveml sp@+,a2/a4/a6
	rts
Lfa:
	moveml d7/a2/a4/a6,sp@-
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x536a,0x0020	/* subqw #1,a2@(32) */
	bnes L11c
	btst #3,a2@(14)
	beqs L11c
	moveal a2,a6
	bsrw L124
	movel d0,d7
L11c:
	movel d7,d0
	moveml sp@+,d7/a2/a4/a6
	rts
L124:
	moveml d2/d6-d7/a2/a4/a6,sp@-
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	moveal a6,a2
	.short 0x7e00	/* moveq #0,d7 */
	bset #3,a2@(14)
	tstw a2@(32)
	bnes L17e
	moveal a2,a6
	jsr %pc@(L2aa)
	movel a2@(34),d7
	movel a6,sp@-
	moveal a2,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
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
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L17e:
	movel d7,d0
	moveml sp@+,d2/d6-d7/a2/a4/a6
	rts
	.byte 0x00,0x00
L188:
	.byte 0x20,0x0c	/* orib #12,d0 */
	rts
L18c:
	moveml a3-a4,sp@-
	moveal a0@(16),a4
	moveal a0@(12),a3
	jsr a3@
	moveml sp@+,a3-a4
	rts
L1a0:
	linkw a5,#-12
	moveml d6-d7/a2/a4/a6,sp@-
	lea a6@(46),a4
	moveal a6,a2
	.short 0x7c01	/* moveq #1,d6 */
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a4@(340)
	movel a2,a4@(200)
	movel a6,sp@-
	lea a4@(20),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveal sp@+,a6
	movel d0,a4@(196)
	beqw L29e
	movel a6,sp@-
	.short 0x203c,0x0000,0x1e00	/* movel #7680,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a4@(344)
	beqw L2a0
	.short 0x700b	/* moveq #11,d0 */
	.short 0x7200	/* moveq #0,d1 */
	lea a4@(308),a0
	moveb d1,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0x1fa */
	pea a4@(308)
	jsr %pc@(Lcf8)
	.short 0x584f	/* addqw #4,sp */
	.short 0x7e78	/* moveq #120,d7 */
	movel a4@(344),a5@(-4)
L212:
	tstl d7
	beqs L234
	movel a6,sp@-
	lea a4@(308),a0
	moveal a5@(-4),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-246)
	moveal sp@+,a6
	.short 0x7040	/* moveq #64,d0 */
	addl d0,a5@(-4)
	.short 0x5387	/* subql #1,d7 */
	bras L212
L234:
	.short 0x7013	/* moveq #19,d0 */
	.short 0x7200	/* moveq #0,d1 */
	lea a4@(320),a0
	moveb d1,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0x23c */
	.short 0x700b	/* moveq #11,d0 */
	lea a4@(296),a0
	moveb d1,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0x248 */
	pea a4@(296)
	jsr %pc@(Lcf8)
	.short 0x702d	/* moveq #45,d0 */
	.short 0x7200	/* moveq #0,d1 */
	lea a4@(204),a0
	moveb d1,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0x25e */
	movel a6,sp@-
	lea a4@(204),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-558)
	moveal sp@+,a6
	.short 0x702d	/* moveq #45,d0 */
	.short 0x7200	/* moveq #0,d1 */
	lea a4@(250),a0
	moveb d1,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0x27c */
	movel a6,sp@-
	lea a4@(250),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-558)
	moveal sp@+,a6
	.short 0x4878,0x0001	/* pea 0x1 */
	jsr %pc@(L964)
	.short 0x504f	/* addqw #8,sp */
	bras L2a0
L29e:
	.short 0x7c00	/* moveq #0,d6 */
L2a0:
	movel d6,d0
	moveml sp@+,d6-d7/a2/a4/a6
	unlk a5
	rts
L2aa:
	moveml a2/a4/a6,sp@-
	lea a6@(46),a4
	moveal a6,a2
	clrl sp@-
	jsr %pc@(L964)
	.short 0x584f	/* addqw #4,sp */
	tstl a4@(344)
	beqs L2d8
	movel a6,sp@-
	moveal a4@(344),a1
	.short 0x203c,0x0000,0x1e00	/* movel #7680,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L2d8:
	movel a6,sp@-
	moveal a4@(196),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal sp@+,a6
	moveml sp@+,a2/a4/a6
	rts
	.byte 0x00,0x00
L2f0:
	.byte 0x4e,0x55	/* orib #85,d0 */
	.short 0xfff8	/* .short 0xfff8 */
	moveml a2-a3/a6,sp@-
	moveal a0,a3
	movel a1,a5@(-8)
	lea a4@(204),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	lea a4@(308),a0
	jsr a6@(-264)
	movel d0,a5@(-4)
	moveal d0,a1
	moveal a5@(-8),a0
	.short 0x7040	/* moveq #64,d0 */
	jsr a6@(-624)
	lea a4@(308),a0
	moveal a5@(-4),a1
	jsr a6@(-240)
	lea a4@(204),a0
	jsr a6@(-570)
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,a2-a3/a6
	unlk a5
	rts
L340:
	linkw a5,#-28
	moveml a2/a4/a6,sp@-
	lea a6@(46),a4
	moveal a0,a2
	subal a0,a0
	lea %pc@(L18c),a1
	movel a1,a4@(328)
	lea %pc@(L2f0),a1
	movel a1,a4@(332)
	movel a0,a5@(-12)
	movel a0,a5@(-8)
	jsr %pc@(L188)
	movel d0,a4@(336)
	movel a6,sp@-
	.short 0x7044	/* moveq #68,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a5@(-4)
	tstl d0
	beqw L528
	movel a6,sp@-
	.short 0x7050	/* moveq #80,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	moveal a5@(-4),a0
	movel d0,a0@(32)
	beqw L516
	movel d0,a0@(28)
	lea a0@(36),a1
	clrl sp@-
	clrl sp@-
	movel a1,a5@(-16)
	jsr %pc@(Ld4c)
	.short 0x504f	/* addqw #8,sp */
	moveal a5@(-16),a0
	movel d0,a0@(14)
	beqw L500
	.short 0x117c,0x0005,0x0008	/* moveb #5,a0@(8) */
	.short 0x7032	/* moveq #50,d0 */
	movel d0,a0@(20)
	lea a4@(320),a1
	movel a1,a0@(24)
	movel a2,a0@(28)
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal sp@+,a6
	movel a6,sp@-
	lea a4@(98),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-390)
	moveal sp@+,a6
	movel d0,a5@(-8)
	beqw L4e6
	movel a6,sp@-
	moveal d0,a0
	moveal a5@(-16),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-366)
	moveal sp@+,a6
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
L42a:
	moveal a5@(-12),a0
	cmpal a5@(-16),a0
	beqs L462
	movel a6,sp@-
	moveal a5@(-16),a0
	moveal a0@(14),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-384)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a5@(-16),a0
	moveal a0@(14),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-372)
	moveal sp@+,a6
	movel d0,a5@(-12)
	bras L42a
L462:
	movel a2,a5@(-20)
	moveal a5@(-4),a0
	movel a0@(32),a5@(-28)
L470:
	movel a6,sp@-
	lea a5@(-20),a0
	moveal a4@(196),a6
	jsr a6@(-48)
	moveal sp@+,a6
	movel d0,a5@(-24)
	tstl d0
	beqs L49a
	moveal d0,a0
	moveal a5@(-28),a1
	movel a0@,a1@
	clrl a1@(4)
	.short 0x50ad,0xffe4	/* addql #8,a5@(-28) */
	bras L470
L49a:
	moveal a5@(-28),a0
	clrl a0@
	movel a2,a5@(-20)
	movel a6,sp@-
	lea a4@(250),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	moveal sp@+,a6
	moveal a5@(-20),a2
	movel a6,sp@-
	lea a4@(296),a0
	moveal a5@(-4),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-246)
	moveal sp@+,a6
	movel a6,sp@-
	lea a4@(250),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-570)
	moveal sp@+,a6
	moveal a5@(-4),a0
	.short 0x5088	/* addql #8,a0 */
	movel a0,d0
	bras L52a
L4e6:
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
	moveal a5@(-16),a0
	movel a0@(14),sp@-
	jsr %pc@(Ld0c)
	.short 0x584f	/* addqw #4,sp */
L500:
	movel a6,sp@-
	moveal a5@(-4),a1
	moveal a1@(32),a1
	.short 0x7050	/* moveq #80,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L516:
	movel a6,sp@-
	moveal a5@(-4),a1
	.short 0x7044	/* moveq #68,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L528:
	.short 0x7000	/* moveq #0,d0 */
L52a:
	moveml sp@+,a2/a4/a6
	unlk a5
	rts
L532:
	linkw a5,#-24
	moveml a2/a4/a6,sp@-
	lea a6@(46),a4
	moveal a0,a2
	subal a0,a0
	movel a2,a5@(-8)
	movel a0,a5@(-24)
	movel a0,a5@(-20)
	movel a6,sp@-
	lea a4@(250),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	moveal sp@+,a6
	moveal a5@(-8),a2
	movel a4@(296),a5@(-12)
L568:
	moveal a5@(-12),a0
	tstl a0@
	beqs L592
	lea a0@(8),a1
	cmpal a1,a2
	bnes L588
	movel a6,sp@-
	moveal a0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	moveal sp@+,a6
	bras L592
L588:
	moveal a5@(-12),a0
	movel a0@,a5@(-12)
	bras L568
L592:
	movel a6,sp@-
	lea a4@(250),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-570)
	moveal sp@+,a6
	movel a5@(-12),a5@(-4)
	moveal a5@(-4),a0
	.short 0xd0fc,0x0024	/* addaw #36,a0 */
	moveal a4@(200),a1
	movew a1@(32),d0
	movel a0,a5@(-16)
	.short 0x5340	/* subqw #1,d0 */
	bnew L654
	.short 0x7033	/* moveq #51,d0 */
	movel d0,a0@(20)
	lea a4@(320),a1
	movel a1,a0@(24)
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal sp@+,a6
	movel a6,sp@-
	lea a4@(108),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-390)
	moveal sp@+,a6
	movel d0,a5@(-24)
	beqs L648
	movel a6,sp@-
	moveal d0,a0
	moveal a5@(-16),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-366)
	moveal sp@+,a6
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
L610:
	moveal a5@(-20),a0
	cmpal a5@(-16),a0
	beqs L654
	movel a6,sp@-
	moveal a5@(-16),a0
	moveal a0@(14),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-384)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a5@(-16),a0
	moveal a0@(14),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-372)
	moveal sp@+,a6
	movel d0,a5@(-20)
	bras L610
L648:
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
L654:
	moveal a5@(-16),a0
	movel a0@(14),sp@-
	jsr %pc@(Ld0c)
	movel a6,sp@-
	moveal a5@(-4),a1
	moveal a1@(32),a1
	.short 0x7050	/* moveq #80,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a5@(-4),a1
	.short 0x7044	/* moveq #68,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	moveml a5@(-36),a2/a4/a6
	unlk a5
	rts
L692:
	linkw a5,#-40
	moveml d5-d7/a2/a4/a6,sp@-
	lea a6@(46),a4
	moveal a0,a2
	movel a1,a5@(-38)
	movel a2,a5@(-4)
	movel a2,a5@(-8)
	moveal a4@(196),a0
	movew a0@(20),d0
	.short 0x7227	/* moveq #39,d1 */
	cmpw d1,d0
	bcss L6ec
	moveal a5@(-8),a0
	tstl a0@(52)
	beqs L6e4
	movel a6,sp@-
	moveal a0@(52),a0
	moveal a5@(-38),a1
	.short 0x7018	/* moveq #24,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-624)
	moveal sp@+,a6
	.short 0x3b7c,0x0001,0xffde	/* movew #1,a5@(-34) */
	braw L888
L6e4:
	clrw a5@(-34)
	braw L888
L6ec:
	movel a6,sp@-
	lea a4@(204),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	moveal sp@+,a6
	moveal a5@(-4),a2
	moveal a5@(-38),a0
	movel a0@(20),a5@(-12)
	movel a2@(36),d7
	movel a2@(40),d6
	clrw a5@(-34)
	moveal a4@(308),a0
	movel a0,a5@(-20)
	movel a0@(8),d0
	cmpl d7,d0
	bccs L72c
	movel a0,a5@(-20)
	bras L778
L72c:
	cmpl d7,d0
	bnes L73e
	movel a0@(12),d0
	cmpl d6,d0
	bccs L73e
	movel a0,a5@(-20)
	bras L778
L73e:
	movel a0,a5@(-20)
L742:
	moveal a5@(-20),a0
	tstl a0@
	beqs L76c
	movel a0@(8),d0
	cmpl d7,d0
	bnes L762
	movel a0@(12),d0
	cmpl d6,d0
	bnes L762
	.short 0x3b7c,0x0001,0xffde	/* movew #1,a5@(-34) */
	bras L76c
L762:
	moveal a5@(-20),a0
	movel a0@,a5@(-20)
	bras L742
L76c:
	tstw a5@(-34)
	bnes L778
	movel a4@(316),a5@(-20)
L778:
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-38),a0
	movew d0,a0@
	movew d0,a0@(2)
	moveal a5@(-20),a0
	moveal a5@(-38),a1
	movel a0@(16),a1@(4)
	movel a0@(20),a1@(8)
	movel a0@(24),a1@(12)
	movel a0@(28),a1@(16)
	.short 0x7a01	/* moveq #1,d5 */
	andl a0@(60),d5
	.short 0x7001	/* moveq #1,d0 */
	andl a4@(340),d0
	cmpl d5,d0
	beqs L810
	tstl d5
	beqs L7e2
	movel a1@(20),a5@(-16)
L7be:
	moveal a5@(-16),a0
	movel a0@,d0
	beqs L810
	.short 0x5380	/* subql #1,d0 */
	bnes L7dc
	.byte 0x0c,0xa8,0x80,0x03,0xa0,0x06,0x00,0x04	/* cmpil #-2147246074,a0@(4) */
	bnes L7dc
	.short 0x20bc,0x8003,0xa006	/* movel #-2147246074,a0@ */
	bras L810
L7dc:
	.short 0x50ad,0xfff0	/* addql #8,a5@(-16) */
	bras L7be
L7e2:
	movel a6,sp@-
	.short 0x203c,0x8003,0xa006	/* movel #-2147246074,d0 */
	moveal a5@(-38),a0
	moveal a0@(20),a0
	moveal a4@(196),a6
	jsr a6@(-30)
	moveal sp@+,a6
	movel d0,a5@(-16)
	beqs L810
	moveal d0,a0
	.byte 0x21,0x7c,0x80,0x03,0xa0,0x06,0x00,0x04	/* movel #-2147246074,a0@(4) */
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a0@
L810:
	moveal a5@(-20),a0
	movel a0@(60),a4@(340)
	moveal a5@(-38),a0
	movel a0@(20),a5@(-12)
L824:
	movel a6,sp@-
	lea a5@(-12),a0
	moveal a4@(196),a6
	jsr a6@(-48)
	moveal sp@+,a6
	movel d0,a5@(-16)
	tstl d0
	beqs L878
	moveal d0,a0
	movel a0@,d0
	.short 0x0480,0x8003,0xa006	/* subil #-2147246074,d0 */
	beqs L84e
	.short 0x5580	/* subql #2,d0 */
	beqs L85e
	bras L86e
L84e:
	moveal a5@(-20),a0
	moveal a5@(-16),a1
	movel a0@(32),a1@(4)
	bras L824
L85e:
	moveal a5@(-20),a0
	moveal a5@(-16),a1
	movel a0@(36),a1@(4)
	bras L824
L86e:
	.short 0x7001	/* moveq #1,d0 */
	moveal a5@(-16),a0
	movel d0,a0@
	bras L824
L878:
	movel a6,sp@-
	lea a4@(204),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-570)
	moveal sp@+,a6
L888:
	movew a5@(-34),d0
	moveml sp@+,d5-d7/a2/a4/a6
	unlk a5
	rts
L894:
	linkw a5,#-52
	moveml d7/a2/a4/a6,sp@-
	lea a6@(46),a4
	movel d0,d7
	subal a2,a2
	subal a0,a0
	clrl sp@-
	movel a0,sp@-
	movel a0,a5@(-8)
	jsr %pc@(Ld4c)
	.short 0x504f	/* addqw #8,sp */
	movel d0,a5@(-38)
	beqw L958
	.short 0x1b7c,0x0005,0xffd4	/* moveb #5,a5@(-44) */
	.short 0x7034	/* moveq #52,d0 */
	movel d0,a5@(-32)
	movel d7,d0
	extl d0
	movel d0,a5@(-28)
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal sp@+,a6
	movel a6,sp@-
	lea a4@(118),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-390)
	moveal sp@+,a6
	moveal d0,a2
	movel a2,d0
	beqs L942
	movel a6,sp@-
	moveal a2,a0
	lea a5@(-52),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-366)
	moveal sp@+,a6
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
L910:
	lea a5@(-52),a0
	moveal a5@(-8),a1
	cmpal a0,a1
	beqs L94e
	movel a6,sp@-
	moveal a5@(-38),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-384)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a5@(-38),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-372)
	moveal sp@+,a6
	movel d0,a5@(-8)
	bras L910
L942:
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
L94e:
	movel a5@(-38),sp@-
	jsr %pc@(Ld0c)
	.short 0x584f	/* addqw #4,sp */
L958:
	movel d7,d0
	moveml sp@+,d7/a2/a4/a6
	unlk a5
	rts
	.byte 0x00,0x00
L964:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	movel a2@(18926),sp@-
	.short 0x002e,0x2e2f,0x0024	/* orib #47,a6@(36) */
	.short 0x7c14	/* moveq #20,d6 */
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7800	/* moveq #0,d4 */
	movel a6,sp@-
	lea a4@(146),a1
	.short 0x7025	/* moveq #37,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveal sp@+,a6
	movel d0,a4@(348)
	tstl d0
	beqw Lbde
	moveal d0,a0
	movew a0@(20),d1
	.short 0x7427	/* moveq #39,d2 */
	cmpw d2,d1
	bhis L9ac
	cmpw d2,d1
	bnes L9b2
	movew a0@(22),d1
	.short 0x0c41,0x0890	/* cmpiw #2192,d1 */
	blss L9b2
L9ac:
	.short 0x7c00	/* moveq #0,d6 */
	braw Lbce
L9b2:
	.short 0x5386	/* subql #1,d6 */
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a4@(142),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-390)
	moveal sp@+,a6
	tstl d0
	bnes L9ea
	.short 0x4878,0xff80	/* pea 0xffffff80 */
	movel a4@(142),sp@-
	jsr %pc@(Ld4c)
	.short 0x504f	/* addqw #8,sp */
	movel d0,a4@(368)
	beqs L9ea
	.short 0x7801	/* moveq #1,d4 */
L9ea:
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
	tstl d4
	bnes La00
	tstl d7
	bnew Lbce
La00:
	tstl d7
	beqs La36
	moveal a4@(348),a0
	movew a0@(20),d0
	.short 0x7227	/* moveq #39,d1 */
	cmpw d1,d0
	bnes La20
	lea a0@(1796),a1
	movel a1,a4@(364)
	lea %pc@(Lc8c),a2
	bras La36
La20:
	.short 0x7225	/* moveq #37,d1 */
	cmpw d1,d0
	bnes La34
	lea a0@(1902),a1
	movel a1,a4@(364)
	lea %pc@(Lc54),a2
	bras La36
La34:
	.short 0x7a01	/* moveq #1,d5 */
La36:
	tstl d5
	bnew Lbba
	tstw a4@(128)
	bnes La48
	tstl d7
	beqw Lbba
La48:
	.short 0x5386	/* subql #1,d6 */
	clrl sp@-
	clrl sp@-
	jsr %pc@(Ld4c)
	.short 0x504f	/* addqw #8,sp */
	movel d0,a4@(352)
	beqw Lbba
	.short 0x5386	/* subql #1,d6 */
	.short 0x4878,0x0030	/* pea 0x30 */
	movel d0,sp@-
	bsrw Lbe6
	.short 0x504f	/* addqw #8,sp */
	movel d0,a4@(356)
	tstl d0
	beqw Lbb0
	.short 0x5386	/* subql #1,d6 */
	movel a6,sp@-
	moveal d0,a1
	lea a4@(164),a0
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-444)
	moveal sp@+,a6
	tstb d0
	bnew Lba6
	.short 0x5386	/* subql #1,d6 */
	tstl d7
	beqw Lb2c
	movel a6,sp@-
	.short 0x7016	/* moveq #22,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a4@(360)
	tstl d0
	beqw Lb96
	.short 0x7c00	/* moveq #0,d6 */
	moveal d0,a0
	.short 0x117c,0x0032,0x0009	/* moveb #50,a0@(9) */
	lea a4@(178),a0
	moveal a4@(360),a1
	movel a0,a1@(10)
	movel a4@(348),a1@(14)
	moveal a4@(360),a0
	movel a2,a0@(18)
	moveal a4@(356),a0
	.short 0x317c,0x000a,0x001c	/* movew #10,a0@(28) */
	moveal a4@(356),a0
	movel a4@(364),a0@(40)
	movel a6,sp@-
	moveal a4@(356),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-456)
	moveal sp@+,a6
	moveal a4@(356),a0
	.short 0x317c,0x0009,0x001c	/* movew #9,a0@(28) */
	moveal a4@(356),a0
	movel a4@(360),a0@(40)
	movel a6,sp@-
	moveal a4@(356),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-456)
	moveal sp@+,a6
	.short 0x397c,0x0001,0x0080	/* movew #1,a4@(128) */
	bras Lb96
Lb2c:
	.short 0x7c00	/* moveq #0,d6 */
	moveal a4@(356),a0
	.short 0x317c,0x000a,0x001c	/* movew #10,a0@(28) */
	moveal a4@(356),a0
	movel a4@(360),a0@(40)
	movel a6,sp@-
	moveal a4@(356),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-456)
	moveal sp@+,a6
	moveal a4@(356),a0
	.short 0x317c,0x0009,0x001c	/* movew #9,a0@(28) */
	moveal a4@(356),a0
	movel a4@(364),a0@(40)
	movel a6,sp@-
	moveal a4@(356),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-456)
	moveal sp@+,a6
	movel a6,sp@-
	moveal a4@(360),a1
	.short 0x7016	/* moveq #22,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	movel a4@(368),sp@-
	jsr %pc@(Ld0c)
	.short 0x584f	/* addqw #4,sp */
	clrw a4@(128)
Lb96:
	movel a6,sp@-
	moveal a4@(356),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-450)
	moveal sp@+,a6
Lba6:
	movel a4@(356),sp@-
	bsrw Lc32
	.short 0x584f	/* addqw #4,sp */
Lbb0:
	movel a4@(352),sp@-
	jsr %pc@(Ld0c)
	.short 0x584f	/* addqw #4,sp */
Lbba:
	tstl d6
	beqs Lbce
	tstl a4@(368)
	beqs Lbce
	movel a4@(368),sp@-
	jsr %pc@(Ld0c)
	.short 0x584f	/* addqw #4,sp */
Lbce:
	movel a6,sp@-
	moveal a4@(348),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal sp@+,a6
Lbde:
	movel d6,d0
	moveml sp@+,d2/d4-d7/a2/a4/a6
	rts
Lbe6:
	linkw a5,#-4
	moveml d7/a2/a6,sp@-
	moveal a5@(8),a2
	movel a5@(12),d7
	movel a2,d0
	beqs Lc28
	movel a6,sp@-
	movel d7,d0
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a5@(-4)
	beqs Lc28
	moveal d0,a0
	.short 0x117c,0x0007,0x0008	/* moveb #7,a0@(8) */
	movel d7,d1
	movew d1,a0@(18)
	movel a2,a0@(14)
	bras Lc2a
Lc28:
	.short 0x7000	/* moveq #0,d0 */
Lc2a:
	moveml sp@+,d7/a2/a6
	unlk a5
	rts
Lc32:
	moveml a2/a6,sp@-
	moveal sp@(12),a2
	.short 0x7000	/* moveq #0,d0 */
	movew a2@(18),d0
	movel a6,sp@-
	moveal a2,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	moveml sp@+,a2/a6
	rts
Lc54:
	movel a0@(14),d0
	movel d0,a1@(72)
	movel a0@(18),d0
	movel d0,a1@(76)
	moveb a0@(4),d0
	.short 0x0c00,0x0004	/* cmpib #4,d0 */
	bnes Lc86
	movel a1@(52),d0
	tstl d0
	beqs Lc86
	movel a0,sp@-
	moveal a1@(52),a0
	.byte 0x21,0x7c,0x80,0x00,0x80,0x00,0x00,0x88	/* movel #-2147450880,a0@(136) */
	moveal sp@+,a0
Lc86:
	movel a1@(1920),sp@-
	rts
Lc8c:
	movel a0@(14),d0
	movel d0,a1@(72)
	movel a0@(18),d0
	movel d0,a1@(76)
	movel a1@(1814),sp@-
	rts
	.byte 0x00,0x00,0x00,0x00,0x00,0xde,0x00,0x00,0x00,0xfa,0x00,0x00,0x01,0x24,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x03,0x40,0x00,0x00,0x05,0x32,0x00,0x00,0x06,0x92,0x00,0x00
	.byte 0x08,0x94,0xff,0xff,0xff,0xff,0x74,0x61,0x62,0x6c,0x65,0x74,0x2e,0x6c,0x69,0x62
	.byte 0x72,0x61,0x72,0x79,0x00,0x00,0x74,0x61,0x62,0x6c,0x65,0x74,0x2e,0x6c,0x69,0x62
	.byte 0x72,0x61,0x72,0x79,0x20,0x33,0x37,0x2e,0x37,0x20,0x28,0x32,0x38,0x2e,0x30,0x34
	.byte 0x2e,0x39,0x33,0x29,0x00,0x4f
Lcf8:
	moveal sp@(4),a0
	movel a0,a0@
	.short 0x5890	/* addql #4,a0@ */
	clrl a0@(4)
	movel a0,a0@(8)
	rts
	.byte 0x00,0x00
Ld0c:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	.short 0x0012,0x266f	/* orib #111,a2@ */
	.short 0x000c	/* .short 0x000c */
	tstl a3@(10)
	beqs Ld24
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-360)
Ld24:
	.short 0x177c,0x00ff,0x0008	/* moveb #-1,a3@(8) */
	.short 0x70ff	/* moveq #-1,d0 */
	movel d0,a3@(20)
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(15),d0
	.byte 0x2c,0x78
Ld38:
	.byte 0x00,0x04	/* moveal 0x4,a6 */
	jsr a6@(-336)
	moveal a3,a1
	.short 0x7022	/* moveq #34,d0 */
Ld42:
	jsr a6@(-210)
	.byte 0x4c,0xdf
Ld48:
	.byte 0x48,0x00	/* moveml sp@+,a3/a6 */
	rts
Ld4c:
	moveml d6-d7/a2-a3/a6,sp@-
	.byte 0x26,0x6f
Ld52:
	.byte 0x00,0x18	/* moveal sp@(24),a3 */
	movel sp@(28),d7
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-330)
	.short 0x7c00	/* moveq #0,d6 */
	moveb d0,d6
	.short 0x70ff	/* moveq #-1,d0 */
	cmpl d0,d6
	bnes Ld70
	.short 0x7000	/* moveq #0,d0 */
	bras Ldd6
Ld70:
	.short 0x7022	/* moveq #34,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	moveal d0,a2
	movel a2,d0
	bnes Ld8a
	movel d6,d0
	jsr a6@(-336)
	bras Ldd4
Ld8a:
	movel a3,a2@(10)
	movel d7,d0
	moveb d0,a2@(9)
	.short 0x157c,0x0004,0x0008	/* moveb #4,a2@(8) */
	clrb a2@(14)
	movel d6,d0
	moveb d0,a2@(15)
	subal a1,a1
	jsr a6@(-294)
	movel d0,a2@(16)
	movel a3,d0
	beqs Ldba
	moveal a2,a1
	jsr a6@(-354)
	bras Ldd4
Ldba:
	lea a2@(24),a0
	movel a0,a2@(20)
	lea a2@(20),a0
	movel a0,a2@(28)
	clrl a2@(24)
	.short 0x157c,0x0002,0x0020	/* moveb #2,a2@(32) */
Ldd4:
	movel a2,d0
Ldd6:
	moveml sp@+,d6-d7/a2-a3/a6
	rts
	.data
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x01,0xa2,0x00,0x00,0x0c,0xa4,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x20,0x75,0x74,0x69,0x6c,0x69,0x74,0x79,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x24,0x56,0x45,0x52,0x3a,0x20,0x74,0x61,0x62,0x6c,0x65,0x74
	.byte 0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x33,0x37,0x2e,0x37,0x20,0x28,0x32
	.byte 0x38,0x2e,0x30,0x34,0x2e,0x39,0x33,0x29,0x00,0x28,0x63,0x29,0x31,0x39,0x39,0x32
	.byte 0x2c,0x20,0x54,0x72,0x69,0x4d,0x65,0x64,0x69,0x61,0x2c,0x20,0x49,0x6e,0x63,0x2e
	.byte 0x00,0x00,0x41,0x50,0x43,0x6f,0x6d,0x6d,0x61,0x6e,0x64,0x00,0x41,0x50,0x43,0x6f
	.byte 0x6d,0x6d,0x61,0x6e,0x64,0x00,0x41,0x50,0x43,0x6f,0x6d,0x6d,0x61,0x6e,0x64,0x00
	.byte 0x00,0x00,0x54,0x61,0x62,0x6c,0x65,0x74,0x50,0x61,0x74,0x63,0x68,0x00,0x00,0x00
	.byte 0x00,0x82,0x69,0x6e,0x74,0x75,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x69,0x6e,0x70,0x75,0x74,0x2e,0x64,0x65,0x76,0x69,0x63,0x65
	.byte 0x00,0x00,0x69,0x6e,0x74,0x75,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x8e
