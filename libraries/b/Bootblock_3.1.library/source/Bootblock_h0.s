	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x01,0xda,0x80,0x03
	.byte 0x09,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x00,0x00,0x00,0x1e,0x00,0x00
	.byte 0x00,0x5e
	.short 0x0000,0x003a	/* orib #58,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x002e	/* orib #46,d0 */
	.short 0x23ce,0x0000,0x0008	/* movel a6,0x8 */
	.short 0x23c0,0x0000,0x0004	/* movel d0,0x4 */
	moveal d0,a0
	.byte 0x21,0x7c,0x00,0x00,0x00,0x00,0x00,0x28	/* movel #0,a0@(40) */
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	.byte 0x21,0x7c,0x00,0x00,0x00,0x00,0x00,0x0a	/* movel #0,a0@(10) */
	.short 0x117c,0x0006,0x000e	/* moveb #6,a0@(14) */
	.byte 0x31,0x79,0x00,0x00,0x00,0x36,0x00,0x14	/* movew 0x36,a0@(20) */
	.byte 0x31,0x79,0x00,0x00,0x00,0x38,0x00,0x16	/* movew 0x38,a0@(22) */
	.byte 0x21,0x7c,0x00,0x00,0x00,0x12,0x00,0x18	/* movel #18,a0@(24) */
	.short 0x7000	/* moveq #0,d0 */
	movew d0,a0@(38)
	lea a0@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-558)
	moveal sp@+,a6
	lea %pc@(L1ce),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x000c	/* movel d0,0xc */
	bnes Lb0
	moveml d7/a5-a6,sp@-
	.short 0x2e3c,0x0003,0x8007	/* movel #229383,d7 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-108)
	moveml sp@+,d7/a5-a6
Lb0:
	.short 0x4eb9,0x0000,0x0000	/* jsr 0x0 */
	rts
	lea a6@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-564)
	moveal sp@+,a6
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(38)
	.short 0x4eb9,0x0000,0x00bc	/* jsr 0xbc */
	movel d0,sp@-
	lea a6@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-570)
	moveal sp@+,a6
	movel sp@+,d0
	rts
	lea a6@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-564)
	moveal sp@+,a6
	.short 0x4eb9,0x0000,0x00cc	/* jsr 0xcc */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L11e
	btst #3,a6@(38)
	beqs L11e
	bsrw L136
L11e:
	movel d0,sp@-
	lea a6@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-570)
	moveal sp@+,a6
	movel sp@+,d0
	rts
L136:
	movel a6,sp@-
	.short 0x2279,0x0000,0x0004	/* moveal 0x4,a1 */
	lea a1@(48),a0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-576)
	moveal sp@+,a6
	tstl d0
	beqs L1c6
	.short 0x2279,0x0000,0x0004	/* moveal 0x4,a1 */
	tstw a1@(32)
	beqs L16a
	bset #3,a1@(38)
	.short 0x7000	/* moveq #0,d0 */
	bras L1c6
L16a:
	.short 0x4eb9,0x0000,0x00d8	/* jsr 0xd8 */
	tstl d0
	bnes L18c
	.short 0x2279,0x0000,0x0004	/* moveal 0x4,a1 */
	lea a1@(48),a0
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-570)
	.short 0x7000	/* moveq #0,d0 */
	beqs L1c6
L18c:
	.short 0x2279,0x0000,0x0004	/* moveal 0x4,a1 */
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-252)
	.short 0x2279,0x0000,0x000c	/* moveal 0xc,a1 */
	jsr a6@(-414)
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2279,0x0000,0x0004	/* moveal 0x4,a1 */
	moveal a1,a0
	movew a0@(16),d0
	subal d0,a1
	addw a0@(18),d0
	jsr a6@(-210)
	.short 0x203c,0xffff,0xfffc	/* movel #-4,d0 */
	lsrl #2,d0
L1c6:
	moveal sp@+,a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L1ce:
	bccs L23f
	.short 0x732e	/* .short 0x732e */
	bges L23d
	bhis L248
	bsrs L24a
	.short 0x7900	/* .short 0x7900 */
	nop
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a4@(4),a0
	movel a0,a4@(16)
	movel a0,d0
	moveal sp@+,a4
	rts
L1f2:
	.short 0x444f	/* .short 0x444f */
	.short 0x5300	/* subqb #1,d0 */
	andb a0@-,d0
	btst d7,a1@+
	.short 0x0000,0x0370	/* orib #112,d0 */
	lea %pc@(L218),a1
	jsr a6@(-96)
	tstl d0
	beqs L214
	moveal d0,a0
	moveal a0@(22),a0
	.short 0x7000	/* moveq #0,d0 */
L212:
	rts
L214:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L212
L218:
	bccs L289
	.short 0x732e	/* .short 0x732e */
	bges L287
	bhis L292
	bsrs L294
	.short 0x7900	/* .short 0x7900 */
	.byte 0x00,0x00
L226:
	.byte 0x44,0x4f	/* orib #79,d0 */
	.short 0x52fe	/* .short 0x52fe */
	rolb d1,d5
	.byte 0x0e,0x75,0x00,0x00,0x03,0x70,0x43,0xfa,0x00,0x3e	/* movesw a5@(43fa003e),d0 */
	.short 0x7025	/* moveq #37,d0 */
	jsr a6@(-552)
	.byte 0x4a
L23d:
	.byte 0x80	/* tstl d0 */
	.byte 0x67
L23f:
	.byte 0x0c	/* beqs 0x24c */
	moveal d0,a1
	bset #6,a1@(34)
L248:
	.byte 0x4e,0xae
L24a:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
L24c:
	lea %pc@(L266),a1
	jsr a6@(-96)
	tstl d0
	beqs L262
	moveal d0,a0
	moveal a0@(22),a0
	.short 0x7000	/* moveq #0,d0 */
	rts
L262:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
L266:
	bccs L2d7
	.short 0x732e	/* .short 0x732e */
	bges L2d5
	bhis L2e0
	bsrs L2e2
	.short 0x7900	/* .short 0x7900 */
	bcss L2ec
	.short 0x7061	/* moveq #97,d0 */
	bgts L2eb
	bvss L2e9
	bgts L2aa
	bges L2e7
	bhis L2f2
	bsrs L2f4
	.short 0x7900	/* .short 0x7900 */
	.byte 0x00,0x00
L286:
	.byte 0x74
L287:
	.byte 0x72	/* orib #114,d0 */
	.byte 0x61
L289:
	.byte 0x63	/* bsrs 0x2ed */
	bmis L2f0
	bvss L301
	bmis L2be
	bccs L2f7
L292:
	.short 0x7669	/* moveq #105,d3 */
L294:
	blss L2fb
	.short 0x0000,0x2f0c	/* orib #12,d0 */
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a4@(4),d0
	moveal sp@+,a4
	rts
	movel a4,sp@-
L2aa:
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal sp@+,a4
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.byte 0x4a,0x6c
L2be:
	.byte 0x00,0x00	/* tstw a4@(0) */
	beqs L2c6
	bsrw L560
L2c6:
	.short 0x7001	/* moveq #1,d0 */
	moveal sp@+,a4
	rts
	.short 0x9efc,0x0014	/* subaw #20,sp */
	moveml d2-d7/a2-a6,sp@-
	.byte 0x49
L2d5:
	.byte 0xf9,0x00
L2d7:
	.byte 0x00,0x00,0x00	/* lea 0x0,a4 */
	lea a4@(22),a5
	.byte 0x2f,0x48
L2e0:
	.byte 0x00,0x34	/* movel a0,sp@(52) */
L2e2:
	.short 0x4a6c,0x0000	/* tstw a4@(0) */
	.byte 0x67
L2e7:
	.byte 0x06	/* beqs 0x2ee */
	.byte 0x70
L2e9:
	.byte 0xfd	/* moveq #-3,d0 */
	.byte 0x60
L2eb:
	.byte 0x00
L2ec:
	.byte 0x02
L2ed:
	.byte 0x6a	/* braw 0x556 */
L2ee:
	movel a0,d1
L2f0:
	.byte 0x2c,0x6c
L2f2:
	.byte 0x00,0x0c	/* moveal a4@(12),a6 */
L2f4:
	.byte 0x24,0x3c,0x00
L2f7:
	.byte 0x00,0x03,0xed	/* movel #1005,d2 */
	.byte 0x4e
L2fb:
	.byte 0xae,0xff,0xe2	/* jsr a6@(-30) */
	movel d0,d6
	.byte 0x66
L301:
	.byte 0x08	/* bnes 0x30a */
	jsr a6@(-132)
	braw L556
L30a:
	movel d6,d1
	lea sp@(60),a0
	movel a0,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-42)
	.short 0x5980	/* subql #4,d0 */
	beqs L32a
	movel d6,d1
	jsr a6@(-36)
	jsr a6@(-132)
	braw L556
L32a:
	.byte 0x0c,0xaf,0x42,0x42,0x42,0x46,0x00,0x3c	/* cmpil #1111638598,sp@(60) */
	beqs L340
	movel d6,d1
	jsr a6@(-36)
	.short 0x70ff	/* moveq #-1,d0 */
	braw L556
L340:
	movel d6,d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-66)
	movel d6,d1
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	movel d0,d5
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal d0,a3
	tstl d0
	bnes L378
	movel d6,d1
	moveal a4@(12),a6
	jsr a6@(-36)
	.short 0x70fc	/* moveq #-4,d0 */
	braw L556
L378:
	movel d6,d1
	movel a3,d2
	movel d5,d3
	moveal a4@(12),a6
	jsr a6@(-42)
	cmpl d3,d0
	beqs L398
	movel d6,d1
	jsr a6@(-36)
	jsr a6@(-132)
	braw L556
L398:
	movel d6,d1
	jsr a6@(-36)
	movel d3,d0
	.short 0x720a	/* moveq #10,d1 */
	jsr %pc@(L89e)
	movel d0,d6
	.short 0x3f7c,0x0008,0x0038	/* movew #8,sp@(56) */
	.short 0x7800	/* moveq #0,d4 */
	bras L3da
L3b2:
	.short 0x7000	/* moveq #0,d0 */
	movew sp@(56),d1
	.short 0x1033,0x1000	/* moveb a3@(0,d1:w),d0 */
	extl d1
	movel d0,sp@(44)
	movel d1,d0
	movel d6,d1
	jsr %pc@(L89e)
	.short 0x5480	/* addql #2,d0 */
	movel sp@(44),d1
	jsr %pc@(L930)
	addl d0,d4
	.short 0x526f,0x0038	/* addqw #1,sp@(56) */
L3da:
	movew sp@(56),d0
	extl d0
	cmpl d5,d0
	bcss L3b2
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(7),d0
	.short 0x7200	/* moveq #0,d1 */
	moveb a3@(6),d1
	asll #8,d1
	.short 0x7400	/* moveq #0,d2 */
	moveb a3@(5),d2
	swap d2
	clrw d2
	.short 0x7600	/* moveq #0,d3 */
	moveb a3@(4),d3
	swap d3
	clrw d3
	asll #8,d3
	addl d2,d3
	addl d1,d3
	addl d0,d3
	cmpl d4,d3
	beqs L418
	.short 0x70fe	/* moveq #-2,d0 */
	braw L556
L418:
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(9),d0
	.short 0x7200	/* moveq #0,d1 */
	moveb a3@(8),d1
	asll #8,d1
	addl d0,d1
	movew d1,a4@(20)
	.short 0x7e0a	/* moveq #10,d7 */
	clrw sp@(56)
	braw L4fc
L436:
	.short 0x702a	/* moveq #42,d0 */
	.short 0x7201	/* moveq #1,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	movel d0,a5@
	bnes L460
	moveal a3,a1
	movel d5,d0
	jsr a6@(-210)
	movew sp@(56),d0
	movew d0,a4@(20)
	bsrw L560
	.short 0x70fc	/* moveq #-4,d0 */
	braw L556
L460:
	moveal a3,a0
	addaw d7,a0
	moveb a0@,a5@(34)
	lea a0@(1),a1
	moveb a1@,a5@(35)
	lea a0@(2),a1
	moveb a1@,a5@(36)
	lea a0@(3),a1
	moveb a1@,a5@(37)
	lea a0@(4),a1
	lea a0@(5),a2
	.short 0x5047	/* addqw #8,d7 */
	movel a1,sp@(48)
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(7),d0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(6),d1
	asll #8,d1
	.short 0x7400	/* moveq #0,d2 */
	moveb a2@,d2
	swap d2
	clrw d2
	.short 0x7600	/* moveq #0,d3 */
	moveal sp@(48),a0
	moveb a0@,d3
	swap d3
	clrw d3
	asll #8,d3
	addl d2,d3
	addl d1,d3
	addl d0,d3
	movel d3,a5@(38)
	clrw sp@(58)
	bras L4d6
L4c2:
	.short 0x1033,0x7000	/* moveb a3@(0,d7:w),d0 */
	movew sp@(58),d1
	moveb d0,a5@(0x4,d1:w)
	.short 0x526f,0x003a	/* addqw #1,sp@(58) */
	movew sp@(44),d7
L4d6:
	movew d7,d0
	.short 0x5240	/* addqw #1,d0 */
	movew d0,sp@(44)
	.short 0x4a33,0x7000	/* tstb a3@(0,d7:w) */
	bnes L4c2
	movel d7,d0
	movew sp@(44),d7
	.short 0x1233,0x0000	/* moveb a3@(0,d0:w),d1 */
	movew sp@(58),d2
	moveb d1,a5@(0x4,d2:w)
	moveal a5@,a5
	.short 0x526f,0x0038	/* addqw #1,sp@(56) */
L4fc:
	.short 0x7000	/* moveq #0,d0 */
	movew a4@(20),d0
	movew sp@(56),d1
	extl d1
	cmpl d0,d1
	bltw L436
	clrw sp@(58)
	.short 0x5c47	/* addqw #6,d7 */
	bras L52c
L516:
	.short 0x1033,0x7000	/* moveb a3@(0,d7:w),d0 */
	lea a4@(64),a0
	movew sp@(58),d1
	.short 0x1180,0x1000	/* moveb d0,a0@(0,d1:w) */
	.short 0x526f,0x003a	/* addqw #1,sp@(58) */
	.short 0x5247	/* addqw #1,d7 */
L52c:
	.short 0x4a33,0x7000	/* tstb a3@(0,d7:w) */
	bnes L516
	.short 0x1033,0x7000	/* moveb a3@(0,d7:w),d0 */
	lea a4@(64),a0
	movew sp@(58),d1
	.short 0x1180,0x1000	/* moveb d0,a0@(0,d1:w) */
	moveal a3,a1
	movel d5,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	.short 0x397c,0x0001,0x0000	/* movew #1,a4@(0) */
	.short 0x7000	/* moveq #0,d0 */
L556:
	moveml sp@+,d2-d7/a2-a6
	.short 0xdefc,0x0014	/* addaw #20,sp */
	rts
L560:
	moveml d7/a4-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x4a6c,0x0000	/* tstw a4@(0) */
	beqs L5a2
	moveal a4@(22),a5
	.short 0x7e00	/* moveq #0,d7 */
	bras L588
L578:
	moveal a5,a1
	moveal a1@,a5
	.short 0x702a	/* moveq #42,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	.short 0x5247	/* addqw #1,d7 */
L588:
	.short 0x7000	/* moveq #0,d0 */
	movew a4@(20),d0
	movew d7,d1
	extl d1
	cmpl d0,d1
	blts L578
	clrw a4@(20)
	clrb a4@(64)
	.short 0x426c,0x0000	/* clrw a4@(0) */
L5a2:
	moveml sp@+,d7/a4-a6
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d2-d3/d7/a2-a5,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	lea a4@(22),a2
	.short 0x4a6c,0x0000	/* tstw a4@(0) */
	bnes L5ca
	.short 0x70ff	/* moveq #-1,d0 */
	movel d0,a3@
	braw L648
L5ca:
	movel a5@,d0
	lsrl #8,d0
	.short 0x0c80,0x0044,0x4f53	/* cmpil #4476755,d0 */
	beqs L5dc
	.short 0x7002	/* moveq #2,d0 */
	movel d0,a3@
	bras L648
L5dc:
	.short 0x7e00	/* moveq #0,d7 */
	movew a4@(20),d0
	movew d0,sp@(28)
	bras L638
L5e8:
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(37),d0
	extl d0
	movel d0,d1
	asll #2,d1
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(36),d0
	extl d0
	movel d0,d2
	asll #2,d2
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(35),d0
	extl d0
	movel d0,d3
	asll #2,d3
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@(34),d0
	extl d0
	asll #2,d0
	.short 0x2035,0x0800	/* movel a5@(0,d0:l),d0 */
	.short 0xd0b5,0x3800	/* addl a5@(0,d3:l),d0 */
	.short 0xd0b5,0x2800	/* addl a5@(0,d2:l),d0 */
	.short 0xd0b5,0x1800	/* addl a5@(0,d1:l),d0 */
	cmpl a2@(38),d0
	bnes L634
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@
	movel a2,d0
	bras L64a
L634:
	moveal a2@,a2
	.short 0x5247	/* addqw #1,d7 */
L638:
	.short 0x7000	/* moveq #0,d0 */
	movew sp@(28),d0
	movew d7,d1
	extl d1
	cmpl d0,d1
	blts L5e8
	clrl a3@
L648:
	.short 0x7000	/* moveq #0,d0 */
L64a:
	moveml sp@+,d2-d3/d7/a2-a5
	.short 0x584f	/* addqw #4,sp */
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x4a6c,0x0000	/* tstw a4@(0) */
	bnes L664
	.short 0x70ff	/* moveq #-1,d0 */
	bras L672
L664:
	movew a4@(20),a0@
	lea a4@(64),a0
L66c:
	moveb a0@+,a1@+
	bnes L66c
	.short 0x7000	/* moveq #0,d0 */
L672:
	moveal sp@+,a4
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x4a6c,0x0000	/* tstw a4@(0) */
	bnes L688
	.short 0x7000	/* moveq #0,d0 */
	bras L68e
L688:
	lea a4@(22),a0
	movel a0,d0
L68e:
	moveal sp@+,a4
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x7202	/* moveq #2,d1 */
	bsrw L6c2
	moveal sp@+,a4
	rts
L6a4:
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x7203	/* moveq #3,d1 */
	bsrw L6c2
	moveal sp@+,a4
	rts
	movel sp@(4),d0
	moveal sp@(8),a0
	movel sp@(12),d1
L6c2:
	.short 0x594f	/* subqw #4,sp */
	moveml d5-d7/a3-a6,sp@-
	movel d1,d6
	movel d0,d7
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a0,sp@(28)
	.short 0x7000	/* moveq #0,d0 */
	subal a0,a0
	jsr %pc@(La14)
	moveal d0,a5
	tstl d0
	beqw L786
	moveal a5,a0
	jsr %pc@(L9d0)
	moveal d0,a3
	tstl d0
	beqw L77c
	lea %pc@(L286),a0
	movel d7,d0
	moveal a3,a1
	.short 0x7200	/* moveq #0,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-444)
	moveb d0,d5
	extw d5
	extl d5
	bnes L774
	.short 0x7001	/* moveq #1,d0 */
	movel d0,a3@(36)
	.short 0x377c,0x0009,0x001c	/* movew #9,a3@(28) */
	moveal a3,a1
	jsr a6@(-456)
	.byte 0x27,0x7c,0x00,0x00,0x04,0x00,0x00,0x24	/* movel #1024,a3@(36) */
	movel sp@(28),a3@(40)
	movel d6,d0
	movew d0,a3@(28)
	clrl a3@(44)
	moveal a3,a1
	jsr a6@(-456)
	tstb d0
	bnes L756
	.short 0x5786	/* subql #3,d6 */
	bnes L75e
	.short 0x377c,0x0004,0x001c	/* movew #4,a3@(28) */
	moveal a3,a1
	jsr a6@(-456)
	tstb d0
	beqs L75e
L756:
	moveb a3@(31),d5
	extw d5
	extl d5
L75e:
	clrl a3@(36)
	.short 0x377c,0x0009,0x001c	/* movew #9,a3@(28) */
	moveal a3,a1
	jsr a6@(-456)
	moveal a3,a1
	jsr a6@(-450)
L774:
	moveal a3,a0
	jsr %pc@(L964)
	bras L77e
L77c:
	.short 0x7a67	/* moveq #103,d5 */
L77e:
	moveal a5,a0
	jsr %pc@(L98c)
	bras L788
L786:
	.short 0x7a67	/* moveq #103,d5 */
L788:
	movel d5,d0
	moveml sp@+,d5-d7/a3-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x9efc,0x0098	/* subaw #152,sp */
	moveml d5-d7/a4-a6,sp@-
	movel d1,d6
	movel d0,d7
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	clrb sp@(27)
	lea %pc@(L1f2),a0
	lea sp@(124),a1
	.short 0x700c	/* moveq #12,d0 */
	movel a0@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0x7b2 */
	lea %pc@(L226),a0
	lea sp@(28),a1
	.short 0x7017	/* moveq #23,d0 */
	movel a0@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0x7c2 */
	.short 0x7000	/* moveq #0,d0 */
	cmpw d0,d6
	bcss L7d4
	.short 0x7007	/* moveq #7,d0 */
	cmpw d0,d6
	blss L7da
L7d4:
	.short 0x709d	/* moveq #-99,d0 */
	braw L862
L7da:
	.short 0x7040	/* moveq #64,d0 */
	lsll #4,d0
	.short 0x223c,0x0001,0x0002	/* movel #65538,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal d0,a5
	tstl d0
	bnes L7f6
	.short 0x7067	/* moveq #103,d0 */
	bras L862
L7f6:
	.short 0x7002	/* moveq #2,d0 */
	cmpw d0,d6
	bccs L81e
L7fc:
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(27),d0
	extl d0
	asll #2,d0
	lea sp@(124),a0
	.short 0x2bb0,0x0800,0x0800	/* movel a0@(0,d0:l),a5@(0,d0:l) */
	.short 0x522f,0x001b	/* addqb #1,sp@(27) */
	.short 0x0c2f,0x000d,0x001b	/* cmpib #13,sp@(27) */
	bcss L7fc
	bras L83a
L81e:
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(27),d0
	extl d0
	asll #2,d0
	.short 0x2bb7,0x081c,0x0800	/* movel sp@(1c,d0:l),a5@(0,d0:l) */
	.short 0x522f,0x001b	/* addqb #1,sp@(27) */
	.short 0x0c2f,0x0018,0x001b	/* cmpib #24,sp@(27) */
	bcss L81e
L83a:
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	addl d0,a5@
	.short 0x7000	/* moveq #0,d0 */
	movew d6,d0
	subl d0,a5@(4)
	movel d7,d0
	moveal a5,a0
	bsrw L6a4
	movel d0,d5
	moveal a5,a1
	.short 0x7040	/* moveq #64,d0 */
	lsll #4,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	movel d5,d0
L862:
	moveml sp@+,d5-d7/a4-a6
	.short 0xdefc,0x0098	/* addaw #152,sp */
	rts
	tstl d0
	bplw L88e
	negl d0
	tstl d1
	bplw L884
	negl d1
	bsrw L89e
	negl d1
	rts
L884:
	bsrw L89e
	negl d0
	negl d1
	rts
L88e:
	tstl d1
	bplw L89e
	negl d1
	bsrw L89e
	negl d0
	rts
L89e:
	movel d2,sp@-
	swap d1
	movew d1,d2
	bnew L8c8
	swap d0
	swap d1
	swap d2
	movew d0,d2
	beqw L8b8
	.short 0x84c1	/* divuw d1,d2 */
	movew d2,d0
L8b8:
	swap d0
	movew d0,d2
	.short 0x84c1	/* divuw d1,d2 */
	movew d2,d0
	swap d2
	movew d2,d1
	movel sp@+,d2
	rts
L8c8:
	movel d3,sp@-
	.short 0x7610	/* moveq #16,d3 */
	.short 0x0c41,0x0080	/* cmpiw #128,d1 */
	bccw L8d8
	roll #8,d1
	.short 0x5143	/* subqw #8,d3 */
L8d8:
	.short 0x0c41,0x0800	/* cmpiw #2048,d1 */
	bccw L8e4
	roll #4,d1
	.short 0x5943	/* subqw #4,d3 */
L8e4:
	.short 0x0c41,0x2000	/* cmpiw #8192,d1 */
	bccw L8f0
	roll #2,d1
	.short 0x5543	/* subqw #2,d3 */
L8f0:
	tstw d1
	bmiw L8fa
	roll #1,d1
	.short 0x5343	/* subqw #1,d3 */
L8fa:
	movew d0,d2
	lsrl d3,d0
	swap d2
	clrw d2
	lsrl d3,d2
	swap d3
	.short 0x80c1	/* divuw d1,d0 */
	movew d0,d3
	movew d2,d0
	movew d3,d2
	swap d1
	.short 0xc4c1	/* muluw d1,d2 */
	subl d2,d0
	bccw L91c
	.short 0x5343	/* subqw #1,d3 */
	addl d1,d0
L91c:
	.short 0x7200	/* moveq #0,d1 */
	movew d3,d1
	swap d3
	roll d3,d0
	swap d0
	exg d0,d1
	movel sp@+,d3
	movel sp@+,d2
	rts
	.byte 0x00,0x00
L930:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d2
	beqs L958
	tstl d1
	bnes L940
	clrl d0
	bras L958
L940:
	movel d0,d3
	.short 0xc6c1	/* muluw d1,d3 */
	swap d2
	.short 0xc4c1	/* muluw d1,d2 */
	swap d2
	clrw d2
	addl d2,d3
	swap d1
	.short 0xc0c1	/* muluw d1,d0 */
	swap d0
	clrw d0
	addl d3,d0
L958:
	moveml sp@+,d1-d3
	rts
	.short 0x0000,0x206f	/* orib #111,d0 */
	.byte 0x00,0x04
L964:
	.byte 0x2f,0x0e	/* orib #14,d4 */
	moveal a0,a1
	.short 0x137c,0x00ff,0x0008	/* moveb #-1,a1@(8) */
	.short 0x307c,0xffff	/* moveaw #-1,a0 */
	movel a0,a1@(20)
	movel a0,a1@(24)
	.short 0x7030	/* moveq #48,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	rts
	moveal sp@(4),a0
L98c:
	moveml a5-a6,sp@-
	moveal a0,a5
	tstl a5@(10)
	beqs L9a2
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-360)
L9a2:
	.short 0x1b7c,0x00ff,0x0008	/* moveb #-1,a5@(8) */
	.short 0x70ff	/* moveq #-1,d0 */
	movel d0,a5@(20)
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@(15),d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-336)
	moveal a5,a1
	.short 0x7022	/* moveq #34,d0 */
	jsr a6@(-210)
	moveml sp@+,a5-a6
	rts
	.short 0x0000,0x206f	/* orib #111,d0 */
	.byte 0x00,0x04
L9d0:
	.byte 0x48,0xe7	/* orib #-25,d4 */
	.short 0x0016,0x2a48	/* orib #72,a6@ */
	movel a5,d0
	bnes L9de
	.short 0x7000	/* moveq #0,d0 */
	bras La04
L9de:
	.short 0x7030	/* moveq #48,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal d0,a3
	tstl d0
	beqs La02
	.short 0x177c,0x0005,0x0008	/* moveb #5,a3@(8) */
	clrb a3@(9)
	movel a5,a3@(14)
La02:
	movel a3,d0
La04:
	moveml sp@+,a3/a5-a6
	rts
	.short 0x0000,0x206f	/* orib #111,d0 */
	.short 0x0004,0x202f	/* orib #47,d4 */
	.short 0x0008	/* .short 0x0008 */
La14:
	moveml d6-d7/a3/a5-a6,sp@-
	movel d0,d7
	moveal a0,a5
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-330)
	moveb d0,d6
	extw d6
	extl d6
	movel d6,d0
	.short 0x5280	/* addql #1,d0 */
	bnes La36
	.short 0x7000	/* moveq #0,d0 */
	bras La96
La36:
	.short 0x7022	/* moveq #34,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	moveal d0,a3
	tstl d0
	bnes La50
	movel d6,d0
	jsr a6@(-336)
	bras La94
La50:
	lea a3@(10),a0
	movel a5,a0@+
	moveb d7,a3@(9)
	.short 0x177c,0x0004,0x0008	/* moveb #4,a3@(8) */
	clrb a0@+
	moveb d6,a0@+
	subal a1,a1
	jsr a6@(-294)
	movel d0,a3@(16)
	movel a5,d0
	beqs La7a
	moveal a3,a1
	jsr a6@(-354)
	bras La94
La7a:
	lea a3@(24),a0
	movel a0,a3@(20)
	lea a3@(20),a0
	movel a0,a3@(28)
	clrl a3@(24)
	.short 0x177c,0x0002,0x0020	/* moveb #2,a3@(32) */
La94:
	movel a3,d0
La96:
	moveml sp@+,d6-d7/a3/a5-a6
	rts
	.data
	.byte 0x42,0x6f,0x6f,0x74,0x62,0x6c,0x6f,0x63,0x6b,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x42,0x6f,0x6f,0x74,0x62,0x6c,0x6f,0x63,0x6b,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x20,0x33,0x2e,0x31,0x20,0x28,0x32,0x34,0x2e,0x30,0x36,0x2e,0x39
	.byte 0x33,0x29,0x0d,0x0a,0x00,0x00,0x00,0x03,0x00,0x01,0x00,0x00,0x00,0xb8,0x00,0x00
	.byte 0x00,0xf2,0x00,0x00,0x01,0x36,0x00,0x00,0x01,0xca,0x00,0x00,0x00,0xf0,0x00,0x00
	.byte 0x03,0x84,0x00,0x00,0x03,0xcc,0x00,0x00,0x04,0x76,0x00,0x00,0x04,0x9a,0x00,0x00
	.byte 0x04,0xb6,0x00,0x00,0x04,0xc8,0x00,0x00,0x05,0xb6,0xff,0xff,0xff,0xff,0x03,0x86
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
