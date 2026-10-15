	.text
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x70ff	/* moveq #-1,d0 */
	moveal sp@+,a4
	rts
	moveml a2/a4,sp@-
	moveal d0,a2
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a6,a2@(38)
	movel a0,a2@(34)
	bsrw Ld4
	tstl d0
	beqs L2e
	movel a2,d0
	bras L34
L2e:
	bsrw L182
	.short 0x7000	/* moveq #0,d0 */
L34:
	moveml sp@+,a2/a4
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	moveal sp@+,a4
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L6e
	btst #3,a6@(14)
	beqs L6e
	bsrw L74
	.byte 0x0c,0x40
L6e:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a4
	rts
L74:
	moveml a3-a6,sp@-
	moveal a6,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	tstw a5@(32)
	bnes Lb2
	moveal a5@(34),a3
	moveal a5,a1
	moveal a4@(64),a6
	jsr a6@(-252)
	bsrw L182
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(18),d0
	.short 0x7200	/* moveq #0,d1 */
	movew a5@(16),d1
	addl d1,d0
	moveal a5,a1
	subal d1,a1
	jsr a6@(-210)
	movel a3,d0
	bras Lba
Lb2:
	bset #3,a5@(14)
	.short 0x7000	/* moveq #0,d0 */
Lba:
	moveml sp@+,a3-a6
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@+,a4
	rts
	rts
	rts
	rts
Ld4:
	.short 0x9efc,0x0040	/* subaw #64,sp */
	moveml a4/a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x2278,0x0004	/* moveal 0x4,a1 */
	movel a1,a4@(64)
	lea a4@(324),a1
	moveal a4@(64),a6
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a4@(68)
	beqs L172
	lea a4@(336),a1
	.short 0x702c	/* moveq #44,d0 */
	jsr a6@(-552)
	movel d0,a4@(72)
	beqs L172
	lea a4@(348),a0
	moveal d0,a6
	jsr a6@(-30)
	movel d0,a4@(76)
	bnes L12c
	lea a4@(370),a0
	jsr a6@(-30)
	movel d0,a4@(76)
	beqs L172
L12c:
	lea sp@(8),a1
	.short 0x22fc,0x8002,0x0002	/* movel #-2147352574,a1@+ */
	lea a4@(396),a0
	movel a0,a1@+
	clrl a1@+
	moveal d0,a0
	lea sp@(8),a1
	jsr a6@(-84)
	movel d0,a4@(80)
	beqs L172
	lea a4@(508),a0
	moveal a4@(64),a6
	jsr a6@(-558)
	lea a4@(414),a1
	jsr a6@(-294)
	tstl d0
	beqs L16e
	moveal d0,a1
	.short 0x7015	/* moveq #21,d0 */
	jsr a6@(-300)
L16e:
	.short 0x7001	/* moveq #1,d0 */
	bras L178
L172:
	bsrw L182
	.short 0x7000	/* moveq #0,d0 */
L178:
	moveml sp@+,a4/a6
	.short 0xdefc,0x0040	/* addaw #64,sp */
	rts
L182:
	.short 0x9efc,0x0040	/* subaw #64,sp */
	moveml d7/a2-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	tstl a4@(80)
	beqw L262
	subal a5,a5
	lea sp@(24),a6
	.short 0x2cfc,0x8002,0x4000	/* movel #-2147336192,a6@+ */
	lea a4@(448),a0
	movel a0,a6@+
	clrl a6@+
	.short 0x7e32	/* moveq #50,d7 */
	bras L1cc
L1b0:
	lea sp@(24),a0
	moveal a4@(72),a6
	jsr a6@(-282)
	moveal d0,a5
	tstl d0
	bnes L1d4
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
L1cc:
	movel d7,d0
	.short 0x5387	/* subql #1,d7 */
	tstl d0
	bnes L1b0
L1d4:
	movel a5,d0
	beqw L25e
	clrl sp@(24)
	lea sp@(24),a0
	moveal a4@(72),a6
	jsr a6@(-270)
	moveal d0,a3
	tstl d0
	beqs L244
	moveal a3,a0
	.short 0x7050	/* moveq #80,d0 */
	jsr a6@(-294)
	moveal d0,a2
	tstl d0
	beqs L224
	movel a2,sp@-
	moveal a2,a1
	moveal a5,a0
	subal a2,a2
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-330)
	moveal sp@+,a2
	moveal a5,a0
	jsr a6@(-288)
	moveal a3,a0
	jsr a6@(-336)
	moveal a2,a0
	jsr a6@(-300)
	bras L236
L224:
	moveal a5,a0
	jsr a6@(-288)
	bras L236
L22c:
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
L236:
	moveal a3,a0
	moveal a4@(72),a6
	jsr a6@(-276)
	tstw d0
	beqs L22c
L244:
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
	moveal a4@(80),a0
	moveal a4@(72),a6
	jsr a6@(-144)
	tstl d0
	bnes L244
L25e:
	clrl a4@(80)
L262:
	movel a4@(76),d0
	beqs L276
	moveal d0,a0
	moveal a4@(72),a6
	jsr a6@(-36)
	clrl a4@(76)
L276:
	movel a4@(72),d0
	beqs L28a
	moveal d0,a1
	moveal a4@(64),a6
	jsr a6@(-414)
	clrl a4@(72)
L28a:
	movel a4@(68),d0
	beqs L29e
	moveal d0,a1
	moveal a4@(64),a6
	jsr a6@(-414)
	clrl a4@(68)
L29e:
	moveml sp@+,d7/a2-a6
	.short 0xdefc,0x0040	/* addaw #64,sp */
	rts
L2a8:
	moveml a5-a6,sp@-
	moveal a0,a5
	movel a5,d0
	beqw L340
	movel a5@(16),d0
	beqs L2c8
	moveal d0,a0
	moveal a4@(72),a6
	jsr a6@(-288)
	clrl a5@(16)
L2c8:
	movel a5@(12),d0
	beqs L2dc
	moveal d0,a0
	moveal a4@(72),a6
	jsr a6@(-300)
	clrl a5@(12)
L2dc:
	tstl a5@(8)
	beqs L302
	bras L2ee
L2e4:
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
L2ee:
	moveal a5@(8),a0
	moveal a4@(72),a6
	jsr a6@(-276)
	tstw d0
	beqs L2e4
	clrl a5@(8)
L302:
	movel a5@(4),d0
	beqs L316
	moveal d0,a1
	moveal a4@(72),a6
	jsr a6@(-66)
	clrl a5@(4)
L316:
	tstl a5@
	beqs L336
	bras L326
L31c:
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
L326:
	moveal a5@,a0
	moveal a4@(72),a6
	jsr a6@(-276)
	tstw d0
	beqs L31c
	clrl a5@
L336:
	moveal a5,a1
	moveal a4@(64),a6
	jsr a6@(-690)
L340:
	moveml sp@+,a5-a6
	rts
L346:
	.short 0x9efc,0x0050	/* subaw #80,sp */
	moveml a5-a6,sp@-
	moveal a4@(64),a6
	.short 0x7020	/* moveq #32,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-684)
	moveal d0,a5
	tstl d0
	beqw L3f2
	clrl sp@(8)
	lea sp@(8),a0
	moveal a4@(72),a6
	jsr a6@(-270)
	movel d0,a5@
	beqs L3ec
	moveal a4@(72),a6
	.short 0x7050	/* moveq #80,d0 */
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-60)
	movel d0,a5@(4)
	beqs L3ec
	moveal d0,a0
	movel a5@,a0@
	clrl sp@(8)
	lea sp@(8),a0
	moveal a4@(72),a6
	jsr a6@(-270)
	movel d0,a5@(8)
	beqs L3ec
	moveal d0,a0
	moveal a4@(72),a6
	.short 0x7050	/* moveq #80,d0 */
	jsr a6@(-294)
	movel d0,a5@(12)
	beqs L3ec
	lea sp@(8),a6
	.short 0x2cfc,0x8002,0x4000	/* movel #-2147336192,a6@+ */
	lea a4@(468),a0
	movel a0,a6@+
	clrl a6@+
	bras L3d6
L3cc:
	moveal a4@(68),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-198)
L3d6:
	lea sp@(8),a0
	moveal a4@(72),a6
	jsr a6@(-282)
	movel d0,a5@(16)
	beqs L3cc
	movel a5,d0
	bras L3f4
L3ec:
	moveal a5,a0
	bsrw L2a8
L3f2:
	.short 0x7000	/* moveq #0,d0 */
L3f4:
	moveml sp@+,a5-a6
	.short 0xdefc,0x0050	/* addaw #80,sp */
	rts
L3fe:
	moveml d2-d4/d6/a3/a6,sp@-
	movel d0,d3
	moveal a1,a3
	clrl a3@
	movel a0,d1
	moveal a4@(68),a6
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	movel d0,d6
	beqs L42c
	tstl d3
	bles L42c
	movel d6,d1
	movel d3,d4
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-366)
L42c:
	clrl a3@
	tstl d6
	beqs L45a
	movel d6,d1
	moveal a4@(68),a6
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-66)
	.short 0x5280	/* addql #1,d0 */
	beqs L45a
	movel d6,d1
	movel d2,d3
	jsr a6@(-66)
	movel d0,a3@
	movel d6,d1
	moveal a4@(68),a6
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
L45a:
	movel d6,d0
	moveml sp@+,d2-d4/d6/a3/a6
	rts
L462:
	movel a6,sp@-
	tstl d0
	beqs L472
	movel d0,d1
	moveal a4@(68),a6
	jsr a6@(-36)
L472:
	moveal sp@+,a6
	rts
L476:
	moveml d2-d3/d5/a6,sp@-
	movel d1,d3
	.short 0x7aff	/* moveq #-1,d5 */
	tstl d0
	beqs L490
	movel d0,d1
	movel a0,d2
	moveal a4@(68),a6
	jsr a6@(-42)
	movel d0,d5
L490:
	movel d5,d0
	moveml sp@+,d2-d3/d5/a6
	rts
L498:
	moveml d2-d3/d5/a6,sp@-
	movel d1,d2
	.short 0x7a00	/* moveq #0,d5 */
	tstl d0
	beqs L4b6
	movel d0,d1
	moveal a4@(68),a6
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	.short 0x5280	/* addql #1,d0 */
	bnes L4b6
	movel d3,d5
L4b6:
	movel d5,d0
	moveml sp@+,d2-d3/d5/a6
	rts
	moveml a4-a5,sp@-
	moveal a1,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a5@,d0
	beqs L4dc
	.short 0x5380	/* subql #1,d0 */
	beqs L4f0
	.short 0x5380	/* subql #1,d0 */
	beqs L4f8
	.short 0x5380	/* subql #1,d0 */
	beqs L508
	bras L512
L4dc:
	lea a5@(12),a0
	moveal a0,a1
	movel a5@(8),d0
	moveal a5@(4),a0
	bsrw L3fe
	bras L514
L4f0:
	movel a2,d0
	bsrw L462
	bras L512
L4f8:
	movel a2,d0
	movel a5@(8),d1
	moveal a5@(4),a0
	bsrw L476
	bras L514
L508:
	movel a2,d0
	movel a5@(4),d1
	bsrs L498
	.byte 0x0c,0x40
L512:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
L514:
	moveml sp@+,a4-a5
	rts
L51a:
	moveml d7/a2/a5-a6,sp@-
	movel d0,d7
	moveal a0,a5
	lea a4@(508),a0
	moveal a4@(64),a6
	jsr a6@(-564)
	.short 0x2b95,0x0161,0x0004	/* movel a5@,a5@(4)@(0) */
	moveal a5@(16),a0
	moveal a5@(12),a1
	moveal a5@(4),a2
	movel d7,d1
	moveal a4@(72),a6
	.short 0x7050	/* moveq #80,d0 */
	jsr a6@(-330)
	tstw d0
	beqs L57e
	moveal a5@(8),a0
	jsr a6@(-336)
	moveal a5@,a0
	jsr a6@(-336)
	moveal a5@,a0
	jsr a6@(-312)
	movel d0,a5@(20)
	beqs L57e
	moveal d0,a0
	moveal a4@(72),a6
	.short 0x203c,0x8002,0x5000	/* movel #-2147332096,d0 */
	jsr a6@(-306)
	movel d0,a5@(24)
L57e:
	moveml sp@+,d7/a2/a5-a6
	rts
L584:
	moveml a5-a6,sp@-
	moveal a0,a5
	movel a5@(20),d0
	beqs L5aa
	moveal d0,a0
	moveal a4@(72),a6
	jsr a6@(-324)
	clrl a5@(20)
	lea a4@(508),a0
	moveal a4@(64),a6
	jsr a6@(-570)
L5aa:
	moveml sp@+,a5-a6
	rts
L5b0:
	moveml a3/a5,sp@-
	lea a0@,a5
	lea a1@,a3
	movew a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movel a5@+,a3@+
	movew a5@+,a3@+
	lea a0@(16),a5
	movel a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movew a5@+,a3@+
	movel a0@(32),a3@+
	moveml sp@+,a3/a5
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml a2-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a0,a2
	movel a0,sp@(20)
	movel a1,sp@(24)
	bsrw L346
	moveal d0,a5
	tstl d0
	bnes L604
	.short 0x7000	/* moveq #0,d0 */
	braw L6de
L604:
	moveal a4@(64),a6
	.short 0x7024	/* moveq #36,d0 */
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-684)
	moveal d0,a3
	tstl d0
	bnes L622
	moveal a5,a0
	bsrw L2a8
	.short 0x7000	/* moveq #0,d0 */
	braw L6de
L622:
	.byte 0x2b,0x8a,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a2,a5@(4)@(8) */
	moveal a5@(4),a2
	.short 0xd4fc,0x000c	/* addaw #12,a2 */
	moveal sp@(24),a1
	moveal a1@,a0
	movel a0,a2@
	bnes L642
	lea a4@(486),a0
	movel a0,a2@
L642:
	lea a1@(4),a6
	movew a6@+,d0
	extl d0
	lea a2@(4),a1
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movel a6@+,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movel a6@+,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movel a6@+,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movel a6@+,a1@+
	movew a6@+,d0
	extl d0
	movel d0,a1@+
	movel a6@+,a1@+
	moveal a5,a0
	.short 0x7002	/* moveq #2,d0 */
	bsrw L51a
	moveal a5@(24),a0
	tstl a0@
	bnes L6c0
	moveal a5,a0
	bsrw L584
	moveal a3,a1
	moveal a4@(64),a6
	jsr a6@(-690)
	moveal a5,a0
	bsrw L2a8
	.short 0x7000	/* moveq #0,d0 */
	bras L6de
L6c0:
	movel a5,a3@(32)
	moveal a5@(24),a0
	moveal a0@,a1
	movel a1,a5@(28)
	moveal a0@,a0
	moveal a3,a1
	bsrw L5b0
	moveal a5,a0
	bsrw L584
	movel a3,d0
L6de:
	moveml sp@+,a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	moveml a3-a6,sp@-
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a5@(32),a3
	.byte 0x27,0xab,0x00,0x1c,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a3@(28),a3@(4)@(8) */
	moveal a3,a0
	.short 0x7003	/* moveq #3,d0 */
	bsrw L51a
	moveal a3,a0
	bsrw L584
	moveal a5,a1
	moveal a4@(64),a6
	jsr a6@(-690)
	moveal a3,a0
	bsrw L2a8
	moveml sp@+,a3-a6
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d2/d4-d7/a2-a6,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a5@(32),a2
	.byte 0x25,0xaa,0x00,0x1c,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a2@(28),a2@(4)@(8) */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7c00	/* moveq #0,d6 */
	bras L76a
L748:
	moveal a2@(24),a0
	addal d6,a0
	moveal a0@(12),a0
	moveal a4@(64),a6
	.short 0x203c,0x0000,0x0900	/* movel #2304,d0 */
	.short 0x223c,0x0000,0x0800	/* movel #2048,d1 */
	jsr a6@(-642)
	.short 0x5282	/* addql #1,d2 */
	.short 0x5886	/* addql #4,d6 */
L76a:
	movew a5@(24),d0
	extl d0
	cmpl d0,d2
	blts L748
	moveal a2,a0
	.short 0x7004	/* moveq #4,d0 */
	bsrw L51a
	.byte 0x2e,0x32,0x01,0x62,0x00,0x18,0x00,0x04	/* movel a2@(18)@(4),d7 */
	bles L7e6
	movel d7,d0
	addl d0,d0
	movel d0,d6
	.short 0x7a00	/* moveq #0,d5 */
	.short 0x7800	/* moveq #0,d4 */
	bras L7dc
L792:
	.short 0x2033,0x4800	/* movel a3@(0,d4:l),d0 */
	movel d0,d1
	.short 0x7403	/* moveq #3,d2 */
	andl d2,d1
	bnes L7be
	moveal a2@(24),a1
	addal d4,a1
	movel a1,sp@(44)
	moveal d0,a1
	moveal sp@(44),a0
	moveal a0@(12),a0
	movel d6,d0
	moveal a4@(64),a6
	jsr a6@(-630)
	bras L7d8
L7be:
	moveal a2@(24),a0
	addal d4,a0
	moveal a3,a1
	addal d4,a1
	moveal a0@(12),a0
	moveal a1@,a1
	movel d6,d0
	moveal a4@(64),a6
	jsr a6@(-624)
L7d8:
	.short 0x5285	/* addql #1,d5 */
	.short 0x5884	/* addql #4,d4 */
L7dc:
	movew a5@(24),d0
	extl d0
	cmpl d0,d5
	blts L792
L7e6:
	moveal a2,a0
	bsrw L584
	movel d7,d0
	moveml sp@+,d2/d4-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a3-a5,sp@-
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a5@(32),a3
	.byte 0x27,0xab,0x00,0x1c,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a3@(28),a3@(4)@(8) */
	.byte 0x27,0x80,0x01,0x62,0x00,0x04,0x00,0x0c	/* movel d0,a3@(4)@(c) */
	movel d0,sp@(16)
	moveal a3,a0
	.short 0x7005	/* moveq #5,d0 */
	bsrw L51a
	moveal a3@(24),a0
	moveal a0@,a0
	moveal a5,a1
	bsrw L5b0
	.byte 0x2e,0x33,0x01,0x62,0x00,0x18,0x00,0x04	/* movel a3@(18)@(4),d7 */
	moveal a3,a0
	bsrw L584
	movel d7,d0
	moveml sp@+,d7/a3-a5
	.short 0x584f	/* addqw #4,sp */
	rts
	moveml d7/a2-a5,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a5@(32),a2
	.byte 0x25,0xaa,0x00,0x1c,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a2@(28),a2@(4)@(8) */
	moveal a2,a0
	.short 0x7006	/* moveq #6,d0 */
	bsrw L51a
	moveal a2@(24),a0
	moveal a0@,a0
	moveal a5,a1
	bsrw L5b0
	moveal a2@(24),a0
	movel a0@(8),a3@
	movel a0@(4),d7
	moveal a2,a0
	bsrw L584
	movel d7,d0
	moveml sp@+,d7/a2-a5
	rts
L894:
	moveml d5-d7,sp@-
	movel d0,d7
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7a00	/* moveq #0,d5 */
	bras L8f4
L8a0:
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	asll #8,d5
	orl d0,d5
	.short 0x7003	/* moveq #3,d0 */
	cmpl d0,d6
	blts L8f2
	movel d5,d1
	.short 0xc2bc,0xffe0,0x0000	/* andl #-2097152,d1 */
	.short 0x0c81,0xffe0,0x0000	/* cmpil #-2097152,d1 */
	bnes L8f2
	movel d5,d1
	.short 0x0281,0x0006,0x0000	/* andil #393216,d1 */
	beqs L8f2
	movel d5,d0
	.short 0xc0bc,0x0000,0xf000	/* andl #61440,d0 */
	.short 0x0c80,0x0000,0xf000	/* cmpil #61440,d0 */
	beqs L8f2
	tstl d0
	beqs L8f2
	movel d5,d1
	.short 0x0281,0x0000,0x0c00	/* andil #3072,d1 */
	.short 0x0c81,0x0000,0xc000	/* cmpil #49152,d1 */
	beqs L8f2
	movel d6,d0
	.short 0x5780	/* subql #3,d0 */
	bras L8fa
L8f2:
	.short 0x5286	/* addql #1,d6 */
L8f4:
	cmpl d7,d6
	blts L8a0
	.short 0x70fc	/* moveq #-4,d0 */
L8fa:
	moveml sp@+,d5-d7
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	bsrs L894
	moveal sp@+,a4
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a3-a5,sp@-
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a5@(32),a3
	.byte 0x27,0xab,0x00,0x1c,0x01,0x62,0x00,0x04,0x00,0x08	/* movel a3@(28),a3@(4)@(8) */
	.byte 0x27,0x80,0x01,0x62,0x00,0x04,0x00,0x0c	/* movel d0,a3@(4)@(c) */
	movel d0,sp@(16)
	moveal a3,a0
	.short 0x7009	/* moveq #9,d0 */
	bsrw L51a
	moveal a3@(24),a0
	moveal a0@,a0
	moveal a5,a1
	bsrw L5b0
	.byte 0x2e,0x33,0x01,0x62,0x00,0x18,0x00,0x04	/* movel a3@(18)@(4),d7 */
	moveal a3,a0
	bsrw L584
	movel d7,d0
	moveml sp@+,d7/a3-a5
	.short 0x584f	/* addqw #4,sp */
	rts
	nop
	.data
	.byte 0x00,0x00,0x00,0x2a,0x00,0x00,0x00,0x10,0x00,0x00,0x01,0x1c,0x00,0x00,0x00,0x0e
	.byte 0x00,0x00,0x00,0x3a,0x00,0x00,0x00,0x52,0x00,0x00,0x00,0x74,0x00,0x00,0x00,0xc0
	.byte 0x00,0x00,0x05,0xde,0x00,0x00,0x06,0xe6,0x00,0x00,0x07,0x24,0x00,0x00,0x07,0xf6
	.byte 0x00,0x00,0x08,0x4a,0x00,0x00,0x09,0x00,0x00,0x00,0x09,0x0e,0xff,0xff,0xff,0xff
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x6d,0x70,0x65,0x67,0x61,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x00,0x00,0x6d,0x70,0x65,0x67,0x61,0x20,0x32,0x2e,0x34,0x20,0x28,0x31
	.byte 0x33,0x2e,0x39,0x2e,0x39,0x39,0x29,0x20,0x5b,0x50,0x50,0x43,0x5d,0x20,0x4d,0x50
	.byte 0x45,0x47,0x20,0x41,0x75,0x64,0x69,0x6f,0x20,0x64,0x65,0x63,0x6f,0x64,0x69,0x6e
	.byte 0x67,0x20,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x28,0x43,0x29,0x31,0x39,0x39
	.byte 0x37,0x2d,0x31,0x39,0x39,0x39,0x20,0x53,0x74,0x65,0x70,0x68,0x61,0x6e,0x65,0x20
	.byte 0x54,0x41,0x56,0x45,0x4e,0x41,0x52,0x44,0x00,0x00,0x00,0x00,0x28,0x43,0x29,0x6f
	.byte 0x70,0x79,0x72,0x69,0x67,0x68,0x74,0x20,0x31,0x39,0x39,0x37,0x2d,0x31,0x39,0x39
	.byte 0x39,0x20,0x62,0x79,0x20,0x53,0x74,0xe9,0x70,0x68,0x61,0x6e,0x65,0x20,0x54,0x41
	.byte 0x56,0x45,0x4e,0x41,0x52,0x44,0x2e,0x20,0x41,0x6c,0x6c,0x20,0x72,0x69,0x67,0x68
	.byte 0x74,0x73,0x20,0x72,0x65,0x73,0x65,0x72,0x76,0x65,0x64,0x2e,0x00,0x00,0x00,0x00
	.byte 0x4a,0xfc,0x00,0x00,0x01,0x00,0x00,0x00,0x02,0x2a,0x80,0x02,0x09,0x00,0x00,0x00
	.byte 0x00,0x54,0x00,0x00,0x00,0x64,0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0x00,0x00,0x08
	.byte 0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x54,0xe0,0x00,0x00,0x0e,0x06,0x00,0xd0,0x00
	.byte 0x00,0x14,0x00,0x02,0xd0,0x00,0x00,0x16,0x00,0x04,0x80,0x18,0x00,0x00,0x00,0x64
	.byte 0x00,0x00,0x00,0x00,0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x70,0x70,0x63,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x6d,0x70,0x65,0x67
	.byte 0x61,0x70,0x70,0x63,0x5f,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x2e,0x65,0x6c,0x66
	.byte 0x00,0x00,0x4c,0x49,0x42,0x53,0x3a,0x6d,0x70,0x65,0x67,0x61,0x70,0x70,0x63,0x5f
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x2e,0x65,0x6c,0x66,0x00,0x4d,0x50,0x45,0x47
	.byte 0x41,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x50,0x50,0x43,0x00,0x50,0x50
	.byte 0x43,0x3a,0x4d,0x73,0x67,0x48,0x61,0x6e,0x64,0x6c,0x65,0x72,0x20,0x4d,0x50,0x45
	.byte 0x47,0x41,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x50,0x50,0x43,0x00,0x00
	.byte 0x4d,0x50,0x45,0x47,0x41,0x4c,0x49,0x42,0x5f,0x50,0x50,0x43,0x20,0x70,0x6f,0x72
	.byte 0x74,0x00,0x00,0x00,0x4d,0x50,0x45,0x47,0x41,0x4c,0x49,0x42,0x5f,0x50,0x50,0x43
	.byte 0x20,0x70,0x6f,0x72,0x74,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x04,0xbe,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
