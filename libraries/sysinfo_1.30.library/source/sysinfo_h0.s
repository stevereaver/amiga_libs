	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x44,0x00,0x00,0x00,0x54,0x00,0x00,0x00,0x04
	.short 0x0000,0x514f	/* orib #79,d0 */
	moveml d7/a2-a3/a5-a6,sp@-
	moveal d0,a5
	movel a0,a5@(34)
	.short 0x1b7c,0x0009,0x0008	/* moveb #9,a5@(8) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x44,0x00,0x0a	/* movel #68,a5@(10) */
	.short 0x1b7c,0x0006,0x000e	/* moveb #6,a5@(14) */
	.short 0x43f9,0x0000,0x0001	/* lea 0x1,a1 */
	movel a1,d0
	lea a5@(20),a0
	movew d0,a0@+
	.short 0x43f9,0x0000,0x001e	/* lea 0x1e,a1 */
	movel a1,d0
	movew d0,a0@+
	.short 0x20fc,0x0000,0x0054	/* movel #84,a0@+ */
	lea a5@(48),a3
	.short 0x43f9,0x0000,0x0006	/* lea 0x6,a1 */
	movel a1,d0
	movel d0,d1
	asll #2,d1
	movel a6,sp@(24)
	.short 0x43f9,0x0000,0x0000	/* lea 0x0,a1 */
	moveal a3,a6
	.byte 0x0c,0x40
L7c:
	.byte 0x1c,0xd9	/* cmpiw #7385,d0 */
	.short 0x5381	/* subql #1,d1 */
	bccs L7c
	asll #2,d0
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	addal d0,a0
	movel a0@,d7
	lea a0@(4),a2
	moveal sp@(24),a6
	bras La4
L98:
	movel a3,d0
	addl a2@+,d0
	movel a3,d1
	moveal d0,a0
	addl d1,a0@
	.short 0x5387	/* subql #1,d7 */
La4:
	tstl d7
	bgts L98
	moveal a5,a6
	bsrw Lb84
	tstl d0
	moveal sp@(24),a6
	beqs Lba
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x0c,0x40
Lba:
	.byte 0x20,0x0d	/* cmpiw #8205,d0 */
	moveml sp@+,d7/a2-a3/a5-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	movel d7,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	movel a6,sp@(4)
	tstw a6@(32)
	bnes Lf8
	btst #3,a6@(14)
	beqs Lf8
	bsrw L100
	movel d0,d7
Lf8:
	movel d7,d0
	movel sp@+,d7
	.short 0x584f	/* addqw #4,sp */
	rts
L100:
	.short 0x594f	/* subqw #4,sp */
	moveml d2/d7/a5-a6,sp@-
	moveal a6,a5
	.short 0x7e00	/* moveq #0,d7 */
	bset #3,a5@(14)
	movel a6,sp@(16)
	tstw a5@(32)
	bnes L14c
	moveal a5,a6
	bsrw Lb80
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
L14c:
	movel d7,d0
	moveml sp@+,d2/d7/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	nop
	.short 0x594f	/* subqw #4,sp */
	moveml a4-a6,sp@-
	lea a6@(48),a4
	movel a6,sp@(12)
	.short 0x7044	/* moveq #68,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveal d0,a5
	moveal sp@(12),a6
	tstl d0
	beqs L1fc
	.short 0x707c	/* moveq #124,d0 */
	addl d0,d0
	bsrw L908
	moveal d0,a1
	tstl d0
	beqs L194
	.short 0x7001	/* moveq #1,d0 */
	movew d0,a1@(38)
L194:
	movel a1,a5@(64)
	beqs L1f2
	.short 0x337c,0x0001,0x0018	/* movew #1,a1@(24) */
	moveal a1,a0
	bsrw L990
	tstw d0
	bnes L1e6
	lea a5@(4),a6
	.short 0x3cfc,0x0001	/* movew #1,a6@+ */
	.short 0x3cfc,0x003c	/* movew #60,a6@+ */
	.short 0x3cfc,0x012c	/* movew #300,a6@+ */
	.short 0x3cfc,0x0384	/* movew #900,a6@+ */
	moveal a5@(64),a0
	movew a0@(122),a6@+
	.short 0x7001	/* moveq #1,d0 */
	movew d0,a6@+
	movew d0,a6@+
	.short 0x3cfc,0x000b	/* movew #11,a6@+ */
	.short 0x3cfc,0xffec	/* movew #-20,a6@+ */
	.short 0x3cfc,0x0014	/* movew #20,a6@+ */
	movew d0,a6@+
	movew d0,a6@+
	.short 0x707f	/* moveq #127,d0 */
	movew d0,a6@+
	movew d0,a6@+
	movel a5,d0
	bras L1fe
L1e6:
	moveal a5@(64),a0
	moveal sp@(12),a6
	bsrw L8fe
L1f2:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L1fc:
	.short 0x7000	/* moveq #0,d0 */
L1fe:
	moveml sp@+,a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	moveal a6@,a2
	.short 0x4552	/* .short 0x4552 */
	movew a0@-,d5
	.short 0x5379,0x7349,0x6e66	/* subqw #1,0x73496e66 */
	bles L242
	bges L27f
	bhis L28a
	bsrs L28c
	.short 0x7920	/* .short 0x7920 */
	movew a6@(13104),a0@-
	movel a0@(12850),d0
	.byte 0x2e,0x31,0x31,0x2e,0x39,0x35,0x29,0x00	/* movel a1@(3935)@(2900,d3:w),d7 */
L22c:
	.short 0x4578	/* .short 0x4578 */
	bcss L293
	.short 0x7574	/* .short 0x7574 */
	bvss L2aa
	bcss L295
	.short 0x7365	/* .short 0x7365 */
	.short 0x7276	/* moveq #118,d1 */
	bcss L2ae
	.short 0x0000,0x594f	/* orib #79,d0 */
	.byte 0x48,0xe7
L242:
	.byte 0x00,0x0e	/* moveml a4-a6,sp@- */
	moveal a0,a5
	moveal a5@(64),a0
	lea a6@(48),a4
	movel a6,sp@(12)
	movel a0,d0
	beqs L260
	.short 0x317c,0x0002,0x0018	/* movew #2,a0@(24) */
	bsrw L990
L260:
	moveal a5@(64),a0
	bsrw L8fe
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
	moveml sp@+,a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	.byte 0x48,0xe7,0x00
L27f:
	.byte 0x1c	/* moveml a3-a5,sp@- */
	moveal a0@(64),a0
	lea a0@(110),a5
	moveal a1,a3
L28a:
	moveal a5@+,a1
L28c:
	lea a6@(48),a4
	movel a1@,a3@
	.byte 0x22
L293:
	.byte 0x5d	/* moveal a5@+,a1 */
	.byte 0x27
L295:
	.byte 0x51,0x00,0x04	/* movel a1@,a3@(4) */
	moveal a5@+,a1
	movel a1@,a3@(8)
	moveml sp@+,a3-a5
	.short 0x584f	/* addqw #4,sp */
	rts
L2a6:
	.short 0x514f	/* subqw #8,sp */
	.byte 0x48,0xe7
L2aa:
	.byte 0x01,0x1e	/* moveml d7/a3-a6,sp@- */
	.byte 0x49,0xee
L2ae:
	.byte 0x00,0x30	/* lea a6@(48),a4 */
	movel a6,sp@(24)
	movel a0,sp@(20)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a5
	jsr a6@(-132)
	subal a1,a1
	moveal a5@(64),a0
	moveal a0@(184),a5
	jsr a6@(-294)
	moveal d0,a0
	moveal sp@(24),a6
	moveal d0,a3
	jsr a5@
	tstl d0
	beqs L2e8
	moveal d0,a0
	.short 0x7e00	/* moveq #0,d7 */
	movew a0@(70),d7
	.byte 0x0c,0x40
L2e8:
	.byte 0x2e,0x0b	/* cmpiw #11787,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d7,d0
	moveml sp@+,d7/a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d7/a4-a6,sp@-
	lea a6@(48),a4
	movel a6,sp@(20)
	movel a0,sp@(16)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a5
	jsr a6@(-132)
	subal a1,a1
	moveal a5@(64),a0
	moveal a0@(184),a5
	jsr a6@(-294)
	moveal d0,a0
	moveal sp@(20),a6
	jsr a5@
	tstl d0
	beqs L344
	moveal d0,a0
	moveal a0@(86),a0
	movel a0,d0
	beqs L344
	.short 0x7e00	/* moveq #0,d7 */
	movew a0@(70),d7
	.byte 0x0c,0x40
L344:
	.byte 0x7e,0xff	/* cmpiw #32511,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d7,d0
	moveml sp@+,d7/a4-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L358:
	.short 0x594f	/* subqw #4,sp */
	movel a4,sp@-
	lea a6@(48),a4
	movel a6,sp@(4)
	bsrw L2a6
	moveal sp@+,a4
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d6-d7/a3-a6,sp@-
	moveal a0,a5
	movel d1,d7
	lea a6@(48),a4
	clrl a5@
	movel d0,sp@(24)
	movel a6,sp@(28)
	tstl d0
	beqs L398
	.short 0x5380	/* subql #1,d0 */
	beqs L3ee
	.short 0x5580	/* subql #2,d0 */
	beqw L44c
	braw L496
L398:
	tstl d7
	bnes L3a4
	moveal a5,a0
	bsrw L2a6
	movel d0,d7
L3a4:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(48),a1
	moveal a1@,a3
	moveal sp@(28),a6
	bras L3c8
L3bc:
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(70),d0
	cmpl d7,d0
	beqs L3cc
	moveal a3@,a3
L3c8:
	movel a3,d0
	bnes L3bc
L3cc:
	movel a3,d0
	beqs L3da
	moveb a3@(72),d6
	extw d6
	extl d6
	bras L3e0
L3da:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7cff	/* moveq #-1,d6 */
L3e0:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d6,d0
	braw L49c
L3ee:
	tstl d7
	bnes L3fa
	moveal a5,a0
	bsrw L358
	movel d0,d7
L3fa:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(48),a1
	moveal a1@,a3
	moveal sp@(28),a6
	bras L41e
L412:
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(70),d0
	cmpl d7,d0
	beqs L422
	moveal a3@,a3
L41e:
	movel a3,d0
	bnes L412
L422:
	movel a3,d0
	beqs L43a
	moveb a3@(72),d0
	extw d0
	moveal a3@(90),a0
	extl d0
	bsrw La00
	movel d0,d6
	bras L440
L43a:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7cff	/* moveq #-1,d6 */
L440:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d6,d0
	bras L49c
L44c:
	tstl d7
	bnes L45c
	subal a1,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-294)
	movel d0,d7
L45c:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(184),a1
	moveal d7,a0
	moveal sp@(28),a6
	jsr a1@
	tstl d0
	beqs L484
	moveal d0,a0
	moveb a0@(72),d6
	extw d6
	extl d6
	bras L48a
L484:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7cff	/* moveq #-1,d6 */
L48a:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d6,d0
	bras L49c
L496:
	.short 0x7016	/* moveq #22,d0 */
	movel d0,a5@
	.short 0x70ff	/* moveq #-1,d0 */
L49c:
	moveml sp@+,d6-d7/a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d5-d6/a3-a6,sp@-
	moveal a0,a5
	movel d1,d6
	movel d0,d1
	movel d2,d5
	lea a6@(48),a4
	clrl a5@
	movel d2,sp@(24)
	movel a6,sp@(28)
	.short 0x7014	/* moveq #20,d0 */
	cmpl d0,d5
	bles L4c8
	movel d0,d5
L4c8:
	.short 0x70ec	/* moveq #-20,d0 */
	cmpl d0,d5
	bges L4d0
	movel d0,d5
L4d0:
	movel d1,d0
	beqs L4e2
	.short 0x5380	/* subql #1,d0 */
	beqs L538
	.short 0x5580	/* subql #2,d0 */
	beqw L594
	braw L5dc
L4e2:
	tstl d6
	bnes L4ee
	moveal a5,a0
	bsrw L2a6
	movel d0,d6
L4ee:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(48),a1
	moveal a1@,a3
	moveal sp@(28),a6
	bras L512
L506:
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(70),d0
	cmpl d6,d0
	beqs L516
	moveal a3@,a3
L512:
	movel a3,d0
	bnes L506
L516:
	movel a3,d0
	beqs L524
	movel d5,d0
	moveb d0,a3@(72)
	.short 0x7a00	/* moveq #0,d5 */
	bras L52a
L524:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7aff	/* moveq #-1,d5 */
L52a:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d5,d0
	braw L5e2
L538:
	tstl d6
	bnes L544
	moveal a5,a0
	bsrw L358
	movel d0,d6
L544:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(48),a1
	moveal a1@,a3
	moveal sp@(28),a6
	bras L568
L55c:
	.short 0x7000	/* moveq #0,d0 */
	movew a3@(70),d0
	cmpl d6,d0
	beqs L56c
	moveal a3@,a3
L568:
	movel a3,d0
	bnes L55c
L56c:
	movel a3,d0
	beqs L582
	movel d5,d0
	moveb d0,a3@(72)
	moveal a3@(90),a0
	bsrw La40
	.short 0x7a00	/* moveq #0,d5 */
	bras L588
L582:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7aff	/* moveq #-1,d5 */
L588:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d5,d0
	bras L5e2
L594:
	tstl d6
	bnes L5a4
	subal a1,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-294)
	movel d0,d6
L5a4:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a5@(64),a0
	moveal a0@(184),a1
	moveal d6,a0
	moveal sp@(28),a6
	jsr a1@
	tstl d0
	beqs L5ca
	moveal d0,a0
	moveb d5,a0@(72)
	.short 0x7a00	/* moveq #0,d5 */
	bras L5d0
L5ca:
	.short 0x7003	/* moveq #3,d0 */
	movel d0,a5@
	.short 0x7aff	/* moveq #-1,d5 */
L5d0:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	movel d5,d0
	bras L5e2
L5dc:
	.short 0x7016	/* moveq #22,d0 */
	movel d0,a5@
	.short 0x70ff	/* moveq #-1,d0 */
L5e2:
	moveml sp@+,d5-d6/a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d6-d7/a2-a6,sp@-
	movel d1,d6
	movel d0,d7
	movel a0,sp@(28)
	lea a6@(48),a4
	movel a6,sp@(32)
	.short 0x7012	/* moveq #18,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveal d0,a5
	moveal sp@(32),a6
	tstl d0
	beqw L702
	.short 0x703c	/* moveq #60,d0 */
	bsrw L908
	moveal d0,a3
	tstl d0
	beqs L644
	.short 0x377c,0x0001,0x0026	/* movew #1,a3@(38) */
	subal a1,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-294)
	moveal a3,a2
	movel d0,a3@(40)
	moveal sp@(32),a6
	bras L64c
L644:
	moveal a3,a0
	bsrw La6c
	subal a2,a2
L64c:
	moveal a2,a0
	movel a0,a5@(14)
	beqw L6f8
	movel d6,a2@(50)
	btst #0,d7
	beqs L6a4
	.short 0x3b7c,0xffff,0x0004	/* movew #-1,a5@(4) */
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(14),a2
	bsrw Lac8
	movel d0,a2@(46)
	beqs L6ec
	moveal a5@(14),a0
	movel a0@(46),a5@
	moveal a5@(14),a0
	.short 0x7000	/* moveq #0,d0 */
	bsrw La7c
	tstw d0
	bnes L692
	movel a5,d0
	bras L704
L692:
	moveal a5@(14),a0
	moveal a0@(46),a0
	moveal sp@(32),a6
	bsrw Lb42
	bras L6ec
L6a4:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a5@(14),a2
	jsr a6@(-330)
	moveb d0,d1
	extw d1
	movew d1,a2@(44)
	.short 0x5241	/* addqw #1,d1 */
	moveal sp@(32),a6
	beqs L6ec
	moveal a5@(14),a0
	movew a0@(44),a5@(4)
	.short 0x7000	/* moveq #0,d0 */
	bsrw La7c
	tstw d0
	bnes L6da
	movel a5,d0
	bras L704
L6da:
	moveal a5@(14),a0
	movew a0@(44),d0
	extl d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-336)
L6ec:
	moveal a5@(14),a0
	moveal sp@(32),a6
	bsrw La6c
L6f8:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L702:
	.short 0x7000	/* moveq #0,d0 */
L704:
	moveml sp@+,d6-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml a3-a6,sp@-
	movel a0,sp@(16)
	lea a6@(48),a4
	movel a6,sp@(20)
	moveal a1,a5
	moveal a5@(14),a0
	.short 0x7000	/* moveq #0,d0 */
	bsrw La90
	subal a3,a3
	bras L740
L72e:
	movel a3,a0@(20)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a1
	jsr a6@(-378)
	moveal sp@(20),a6
L740:
	moveal a5@,a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-372)
	moveal d0,a0
	moveal sp@(20),a6
	tstl d0
	bnes L72e
	moveal a5@(14),a0
	bsrw La6c
	movew a5@(4),d0
	.short 0x72ff	/* moveq #-1,d1 */
	cmpw d1,d0
	beqs L780
	extl d0
	.short 0x7200	/* moveq #0,d1 */
	bset d0,d1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-306)
	movew a5@(4),d0
	extl d0
	jsr a6@(-336)
L780:
	moveal sp@(20),a6
	movel a5@,d0
	beqs L78e
	moveal d0,a0
	bsrw Lb42
L78e:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
	moveml sp@+,a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x9efc,0x0010	/* subaw #16,sp */
	moveml d2/a3-a5,sp@-
	moveal a0@(64),a0
	movew a0@(76),d0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	moveal a1,a3
	moveal a0@(86),a1
	lea a6@(48),a4
	movew d0,sp@(24)
	movel a1@,d0
	bsrw Lbba
	movel d0,a3@
	moveal a0@(78),a1
	movew sp@(24),d0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	movel a1@,d0
	bsrw Lbba
	lea a3@(4),a5
	movel d0,a5@+
	moveal a0@(82),a1
	.short 0x7000	/* moveq #0,d0 */
	movew a1@,d0
	movel d0,a5@+
	.short 0x7000	/* moveq #0,d0 */
	movew sp@(24),d0
	movel d0,a5@+
	lea a0@(94),a4
	moveal a4@+,a1
	movel a1@,d1
	movel d1,a3@(26)
	moveal a4@+,a1
	movel a1@,d2
	movel d2,a3@(30)
	addl d2,d1
	movel d1,a3@(34)
	moveal a4@+,a1
	movel a1@,d1
	lea a3@(38),a4
	movel d1,a4@+
	moveal a0@(106),a1
	movel a1@,d2
	movel d2,a4@+
	addl d2,d1
	movel d1,a4@+
	moveal a0@(90),a1
	movel a1@,a5@+
	.short 0xc0e8,0x007a	/* muluw a0@(122),d0 */
	movel d0,a5@+
	.short 0x3afc,0x003c	/* movew #60,a5@+ */
	moveml sp@+,d2/a3-a5
	.short 0xdefc,0x0010	/* addaw #16,sp */
	rts
	.short 0x9efc,0x000c	/* subaw #12,sp */
	moveml a2-a6,sp@-
	moveal a1,a5
	lea sp@(24),a1
	movel a2,a1@
	moveal a1@+,a2
	lea a6@(48),a4
	moveal a0@(64),a3
	movel a0,sp@(20)
	movel a6,a1@+
	movel a2,d0
	bnes L86e
	subal a1,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-294)
	moveal d0,a2
L86e:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal a3@(184),a1
	moveal a2,a0
	moveal sp@(28),a6
	jsr a1@
	moveal d0,a0
	tstl d0
	bnes L894
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	.short 0x70ff	/* moveq #-1,d0 */
	bras L8f4
L894:
	movel a0@(36),a5@
	movel a0@(48),a5@(8)
	.short 0x7000	/* moveq #0,d0 */
	movew a0@(34),d0
	lea a5@(12),a2
	movel d0,a2@+
	movew a3@(76),d0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	movel d1,a5@(4)
	movel d1,a2@+
	movel a0@(40),a2@+
	.short 0xc0eb,0x007a	/* muluw a3@(122),d0 */
	movel d0,a2@+
	.short 0x34fc,0x003c	/* movew #60,a2@+ */
	movel a0@(60),d0
	movel d0,a2@+
	movel a0@(64),d1
	movel d1,a2@+
	addl d1,d0
	movel d0,a2@+
	.short 0x7000	/* moveq #0,d0 */
	movew a0@(56),d0
	movel d0,a2@+
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(58),d1
	movel d1,a2@+
	addl d1,d0
	movel d0,a2@+
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	.short 0x7000	/* moveq #0,d0 */
L8f4:
	moveml sp@+,a2-a6
	.short 0xdefc,0x000c	/* addaw #12,sp */
	rts
L8fe:
	.short 0x594f	/* subqw #4,sp */
	movel a6,sp@
	.short 0x588f	/* addql #4,sp */
	braw L962
L908:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a5-a6,sp@-
	movel d0,d7
	movel a6,sp@(12)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveal d0,a5
	moveal sp@(12),a6
	tstl d0
	beqs L958
	.short 0x1b7c,0x0005,0x0008	/* moveb #5,a5@(8) */
	movew d7,a5@(18)
	.short 0x3b7c,0x0001,0x0014	/* movew #1,a5@(20) */
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
	bsrw Lac8
	movel d0,a5@(14)
	beqs L94e
	movel a5,d0
	bras L95a
L94e:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L958:
	.short 0x7000	/* moveq #0,d0 */
L95a:
	moveml sp@+,d7/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L962:
	.short 0x594f	/* subqw #4,sp */
	moveml a5-a6,sp@-
	moveal a0,a5
	movel a6,sp@(8)
	movel a5,d0
	beqs L988
	movel a5@(14),d0
	beqs L97e
	moveal d0,a0
	bsrw Lb42
L97e:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L988:
	moveml sp@+,a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L990:
	.short 0x594f	/* subqw #4,sp */
	moveml a5-a6,sp@-
	movel a6,sp@(8)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a5
	jsr a6@(-132)
	lea %pc@(L22c),a1
	jsr a6@(-390)
	tstl d0
	moveal sp@(8),a6
	beqs L9e6
	moveal d0,a0
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-366)
	jsr a6@(-138)
	moveal a5@(14),a0
	jsr a6@(-384)
	moveal sp@(8),a6
L9d0:
	moveal a5@(14),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-372)
	tstl d0
	moveal sp@(8),a6
	bnes L9d0
	bras L9f4
L9e6:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	.short 0x7009	/* moveq #9,d0 */
	movew d0,a5@(22)
L9f4:
	movew a5@(22),d0
	moveml sp@+,a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
La00:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a5,sp@-
	movel d0,d7
	movel a6,sp@(8)
	moveal a0,a5
	bras La32
La10:
	moveb a5@(72),d0
	extw d0
	extl d0
	cmpl d7,d0
	bges La24
	moveb a5@(72),d7
	extw d7
	extl d7
La24:
	movel d7,d0
	moveal a5@(90),a0
	bsrs La00
	movel d0,d7
	moveal a5@(94),a5
La32:
	movel a5,d0
	bnes La10
	movel d7,d0
	moveml sp@+,d7/a5
	.short 0x584f	/* addqw #4,sp */
	rts
La40:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a5,sp@-
	movel d0,d7
	movel a6,sp@(8)
	moveal a0,a5
	bras La60
La50:
	movel d7,d0
	moveb d0,a5@(72)
	moveal a5@(90),a0
	bsrs La40
	moveal a5@(94),a5
La60:
	movel a5,d0
	bnes La50
	moveml sp@+,d7/a5
	.short 0x584f	/* addqw #4,sp */
	rts
La6c:
	.short 0x594f	/* subqw #4,sp */
	movel a6,sp@
	movel a0,d0
	beqs La78
	bsrw L962
La78:
	.short 0x584f	/* addqw #4,sp */
	rts
La7c:
	.short 0x594f	/* subqw #4,sp */
	.short 0x317c,0x0003,0x0018	/* movew #3,a0@(24) */
	movew d0,a0@(54)
	movel a6,sp@
	.short 0x588f	/* addql #4,sp */
	braw L990
La90:
	.short 0x594f	/* subqw #4,sp */
	movel d0,d1
	movel a6,sp@
	movel a0,d0
	beqs Laa8
	.short 0x317c,0x0004,0x0018	/* movew #4,a0@(24) */
	movew d1,a0@(54)
	bsrw L990
Laa8:
	.short 0x584f	/* addqw #4,sp */
	rts
	moveal sp@(4),a0
Lab0:
	clrl a0@(4)
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	movel a0,a0@-
	rts
	.short 0x0000,0x206f	/* orib #111,d0 */
	.short 0x0004,0x202f	/* orib #47,d4 */
	.short 0x0008	/* .short 0x0008 */
Lac8:
	moveml d6-d7/a3/a5-a6,sp@-
	movel d0,d7
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a5
	jsr a6@(-330)
	.short 0x7c00	/* moveq #0,d6 */
	moveb d0,d6
	tstl d6
	bles Lb36
	.short 0x7022	/* moveq #34,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	moveal d0,a3
	tstl d0
	beqs Lb2c
	lea a3@(10),a0
	movel a5,a0@+
	movel d7,d0
	moveb d0,a3@(9)
	.short 0x177c,0x0004,0x0008	/* moveb #4,a3@(8) */
	clrb a0@+
	subal a1,a1
	moveb d6,a0@+
	jsr a6@(-294)
	movel d0,a3@(16)
	movel a5,d0
	beqs Lb20
	moveal a3,a1
	jsr a6@(-354)
	bras Lb28
Lb20:
	lea a3@(20),a0
	bsrw Lab0
Lb28:
	movel a3,d0
	bras Lb38
Lb2c:
	movel d6,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-336)
Lb36:
	.short 0x7000	/* moveq #0,d0 */
Lb38:
	moveml sp@+,d6-d7/a3/a5-a6
	rts
	moveal sp@(4),a0
Lb42:
	moveml a5-a6,sp@-
	moveal a0,a5
	tstl a5@(10)
	beqs Lb58
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-360)
Lb58:
	st a5@(8)
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
	nop
Lb80:
	rts
	.byte 0x00,0x00
Lb84:
	.byte 0x70,0x00	/* orib #0,d0 */
	rts
	tstl d0
	bplw Lbaa
	negl d0
	tstl d1
	bplw Lba0
	negl d1
	bsrw Lbba
	negl d1
	rts
Lba0:
	bsrw Lbba
	negl d0
	negl d1
	rts
Lbaa:
	tstl d1
	bplw Lbba
	negl d1
	bsrw Lbba
	negl d0
	rts
Lbba:
	movel d2,sp@-
	swap d1
	movew d1,d2
	bnew Lbe4
	swap d0
	swap d1
	swap d2
	movew d0,d2
	beqw Lbd4
	.short 0x84c1	/* divuw d1,d2 */
	movew d2,d0
Lbd4:
	swap d0
	movew d0,d2
	.short 0x84c1	/* divuw d1,d2 */
	movew d2,d0
	swap d2
	movew d2,d1
	movel sp@+,d2
	rts
Lbe4:
	movel d3,sp@-
	.short 0x7610	/* moveq #16,d3 */
	.short 0x0c41,0x0100	/* cmpiw #256,d1 */
	bccw Lbf4
	roll #8,d1
	.short 0x5143	/* subqw #8,d3 */
Lbf4:
	.short 0x0c41,0x1000	/* cmpiw #4096,d1 */
	bccw Lc00
	roll #4,d1
	.short 0x5943	/* subqw #4,d3 */
Lc00:
	.short 0x0c41,0x4000	/* cmpiw #16384,d1 */
	bccw Lc0c
	roll #2,d1
	.short 0x5543	/* subqw #2,d3 */
Lc0c:
	tstw d1
	bmiw Lc16
	roll #1,d1
	.short 0x5343	/* subqw #1,d3 */
Lc16:
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
	bccw Lc38
	.short 0x5343	/* subqw #1,d3 */
	addl d1,d0
Lc38:
	.short 0x7200	/* moveq #0,d1 */
	movew d3,d1
	swap d3
	roll d3,d0
	swap d0
	exg d0,d1
	movel sp@+,d3
	movel sp@+,d2
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	.data
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x4c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x20,0x00,0x00,0x02,0x06,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0xc4,0x00,0x00,0x00,0xd6,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x01,0x58,0x00,0x00,0x02,0x3e,0x00,0x00,0x02,0x7a,0x00,0x00,0x02,0xa6
	.byte 0x00,0x00,0x02,0xfc,0x00,0x00,0x03,0x58,0x00,0x00,0x03,0x6e,0x00,0x00,0x04,0xa4
	.byte 0x00,0x00,0x05,0xea,0x00,0x00,0x07,0x0c,0x00,0x00,0x07,0xa0,0x00,0x00,0x08,0x3e
	.byte 0xff,0xff,0xff,0xff,0x53,0x79,0x73,0x49,0x6e,0x66,0x6f,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x56,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x31,0x2e,0x30,0x00
