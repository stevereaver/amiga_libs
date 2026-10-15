	.text
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x00,0x00,0x01,0x7c,0x00,0x00,0x01,0x8a,0x00,0x00,0x01,0xa8,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x02,0x5c,0x00,0x00,0x04,0xa4,0x00,0x00,0x01,0xe0,0x00,0x00,0x07,0x66
	.byte 0x00,0x00,0x05,0x1c,0x00,0x00,0x0a,0x70,0x00,0x00,0x05,0xe8,0x00,0x00,0x0b,0x18
	.byte 0x00,0x00,0x06,0x28,0x00,0x00,0x0b,0x4c,0x00,0x00,0x0c,0x0a,0x00,0x00,0x0b,0x64
	.byte 0x00,0x00,0x04,0xbc,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x04
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x06
L5c:
	.byte 0x61,0x73,0x79,0x6e,0x63,0x69,0x6f,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20
	.byte 0x33,0x39,0x2e,0x31,0x20,0x28,0x37,0x2e,0x36,0x2e,0x39,0x37,0x29,0x0d,0x0a,0x00
L7c:
	.byte 0x61,0x73,0x79,0x6e,0x63,0x69,0x6f,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x4a,0xfc,0x00,0x00,0x00,0x8c,0x00,0x00,0x01,0xa8,0x80,0x27,0x09,0x00,0x00,0x00
	.byte 0x00,0x7c,0x00,0x00,0x00,0x5c,0x00,0x00,0x00,0x4c
La6:
	.byte 0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
Lb2:
	.byte 0x75,0x74,0x69,0x6c,0x69,0x74,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
Lc2:
	moveml d2/a5-a6,sp@-
	moveal a0,a5
	movel a4@(12),d0
	beqs Le0
	moveal d0,a1
	moveal a4@(4),a6
	jsr a6@(-414)
	moveal a4@(8),a1
	jsr a6@(-414)
Le0:
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	.short 0x7200	/* moveq #0,d1 */
	movew a5@(18),d1
	.short 0x7400	/* moveq #0,d2 */
	movew d0,d2
	moveal a5,a1
	subal d0,a1
	addl d1,d2
	movel d2,d0
	moveal a4@(4),a6
	jsr a6@(-210)
	moveml sp@+,d2/a5-a6
	rts
	moveml a2/a4-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a6,a4@(4)
	lea %pc@(La6),a1
	moveal d0,a5
	.short 0x7025	/* moveq #37,d0 */
	moveal a0,a2
	jsr a6@(-552)
	movel d0,a4@(12)
	beqs L16c
	lea %pc@(Lb2),a1
	moveal a4@(4),a6
	.short 0x7025	/* moveq #37,d0 */
	jsr a6@(-552)
	movel d0,a4@(8)
	beqs L16c
	lea a5@(8),a6
	.short 0x1cfc,0x0009	/* moveb #9,a6@+ */
	clrb a6@+
	lea %pc@(L7c),a0
	movel a0,a6@+
	.short 0x1cfc,0x0006	/* moveb #6,a6@+ */
	lea a5@(20),a6
	.short 0x3cfc,0x0027	/* movew #39,a6@+ */
	.short 0x3cfc,0x0001	/* movew #1,a6@+ */
	lea %pc@(L5c),a0
	movel a0,a6@+
	movel a2,a4@(16)
	.short 0x294d,0x0000	/* movel a5,a4@(0) */
	bras L174
L16c:
	moveal a5,a0
	bsrw Lc2
	subal a5,a5
L174:
	movel a5,d0
	moveml sp@+,a2/a4-a6
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	movel a6,d0
	bclr #3,a6@(14)
	rts
	movew a6@(32),d0
	beqs L196
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L1a4
L196:
	btst #3,a6@(14)
	beqs L1a4
	bsrw L1a8
	rts
L1a4:
	.short 0x7000	/* moveq #0,d0 */
	rts
L1a8:
	moveml a4-a6,sp@-
	moveal a6,a5
	tstw a5@(32)
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	beqs L1c4
	bset #3,a5@(14)
	.short 0x7000	/* moveq #0,d0 */
	bras L1d8
L1c4:
	moveal a5,a1
	moveal a4@(4),a6
	jsr a6@(-252)
	moveal a5,a0
	bsrw Lc2
	movel a4@(16),d0
L1d8:
	moveml sp@+,a4-a6
	rts
	nop
	moveml d2-d3/d7/a4-a6,sp@-
	moveal a0,a5
	movel a5,d0
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	beqs L246
	moveal a5,a0
	bsrw L9e8
	movel d0,d7
	blts L22a
	tstb a5@(143)
	bnes L22a
	movel a5@(16),d0
	movel a5@(20),d1
	cmpl d0,d1
	blss L22a
	subl d0,d1
	movel a5@(134),d0
	asll #2,d0
	moveal a5,a0
	addal d0,a0
	movel d1,d3
	movel a5@,d1
	movel a0@(24),d2
	moveal a4@(12),a6
	jsr a6@(-48)
	movel d0,d7
L22a:
	tstb a5@(144)
	beqs L23a
	movel a5@,d1
	moveal a4@(12),a6
	jsr a6@(-36)
L23a:
	moveal a5,a1
	moveal a4@(4),a6
	jsr a6@(-690)
	bras L254
L246:
	.short 0x722c	/* moveq #44,d1 */
	notb d1
	moveal a4@(12),a6
	jsr a6@(-462)
	.short 0x7eff	/* moveq #-1,d7 */
L254:
	movel d7,d0
	moveml sp@+,d2-d3/d7/a4-a6
	rts
	moveml d2/d5-d7/a3-a4/a6,sp@-
	movel d0,d7
	movel d7,d2
	addl d2,d2
	moveal a0,a1
	lea %pc@(L2ae),a0
	.short 0x3430,0x2800	/* movew a0@(0,d2:l),d2 */
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a4@(12),a6
	movel d1,d6
	movel a1,d1
	extl d2
	jsr a6@(-30)
	subal a3,a3
	movel d0,d5
	beqs L2a6
	.short 0x4878,0x0001	/* pea 0x1 */
	movel d5,d0
	movel d7,d1
	movel d6,sp@-
	bsrw L2b4
	.short 0x504f	/* addqw #8,sp */
	moveal d0,a3
	tstl d0
	bnes L2a6
	movel d5,d1
	jsr a6@(-36)
L2a6:
	movel a3,d0
	moveml sp@+,d2/d5-d7/a3-a4/a6
	rts
L2ae:
	.byte 0x03,0xed,0x03,0xee,0x03,0xec
L2b4:
	.byte 0x9e,0xfc
	.byte 0x00,0x34,0x48,0xe7,0x3f,0x16,0x41,0xef	/* orib #-25,a4@(0)@(41ef,d3:l:8) */
	.short 0x0030,0x2e00,0x2008	/* orib #0,a0@(8,d2:w) */
	movel sp@(92),d6
	.short 0x0240,0xfffc	/* andiw #-4,d0 */
	movel d1,sp@(40)
	moveal d0,a3
	seq d0
	negb d0
	extw d0
	.short 0x7a00	/* moveq #0,d5 */
	extl d0
	subal a5,a5
	movel d0,sp@(36)
	beqs L2f4
	tstl d7
	beqs L32c
	movel d7,d1
	moveal a4@(12),a6
	jsr a6@(-372)
	bras L32a
L2f4:
	.short 0x5581	/* subql #2,d1 */
	bnes L31c
	tstl d7
	beqs L31c
	movel d7,d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	moveal a4@(12),a6
	jsr a6@(-66)
	tstl d0
	bpls L31c
	tstw sp@(98)
	beqs L31a
	movel d7,d1
	jsr a6@(-36)
L31a:
	movel d2,d7
L31c:
	tstl d7
	beqs L32c
	movel d7,d1
	moveal a4@(12),a6
	jsr a6@(-384)
L32a:
	movel d0,d5
L32c:
	tstl d7
	beqw L498
	.short 0x7840	/* moveq #64,d4 */
	.byte 0x2f,0x7c,0x00,0x00,0x02,0x00,0x00,0x54	/* movel #512,sp@(84) */
	lsll #4,d4
	tstl d5
	beqs L37c
	movel d5,d1
	movel a3,d2
	moveal a4@(12),a6
	jsr a6@(-114)
	tstl d0
	beqs L376
	movel a3@(20),d0
	movel d0,d4
	addl d4,d4
	addl d4,d6
	.short 0x5386	/* subql #1,d6 */
	movel d0,sp@(84)
	moveal a4@(8),a0
	movel d4,d1
	movel d6,d0
	jsr a0@(-150)
	movel d4,d1
	jsr a0@(-138)
	movel d0,d6
L376:
	movel d5,d1
	jsr a6@(-90)
L37c:
	.short 0x7256	/* moveq #86,d1 */
	movel d6,d0
	notb d1
	addl d1,d0
	.short 0x7201	/* moveq #1,d1 */
	moveal a4@(4),a6
	jsr a6@(-684)
	moveal d0,a5
	tstl d0
	bnes L39c
	cmpl d4,d6
	bles L39c
	subl d4,d6
	bras L37c
L39c:
	movel a5,d0
	beqw L488
	lea a5@,a1
	movel d7,a1@+
	movel sp@(36),d0
	lea a5@(143),a6
	moveb d0,a6@+
	movel sp@(84),a1@+
	asll #2,d7
	lsrl #1,d6
	movel a5,d1
	movew sp@(98),d0
	moveb d0,a6@+
	.short 0x7056	/* moveq #86,d0 */
	moveal d7,a3
	notb d0
	movel a3@(8),a1@+
	addl d0,d1
	.short 0x0241,0xfff0	/* andiw #-16,d1 */
	lea a5@(20),a1
	movel d6,a1@+
	moveal d1,a0
	addal d6,a0
	movel d1,a1@+
	movel a0,a1@+
	lea a5@(134),a1
	clrl a1@+
	clrl a1@+
	clrb a1@+
	clrb a6@+
	lea a5@(124),a0
	lea a5@(120),a1
	.short 0x7004	/* moveq #4,d0 */
	movel a0,a1@+
	clrl a1@+
	lea a5@(120),a0
	movel a0,a1@+
	moveb d0,a5@(108)
	lea a5@(110),a0
	clrl a0@+
	.short 0x10fc,0x0002	/* moveb #2,a0@+ */
	moveb d0,a0@+
	subal a1,a1
	moveal a4@(4),a6
	jsr a6@(-294)
	movel d0,a5@(116)
	lea a5@(32),a0
	movel a0,a5@(52)
	movel a3@(36),a5@(72)
	movel a5@(20),a5@(80)
	clrl a5@(64)
	clrl a5@(68)
	lea a5@(52),a0
	movel a0,a5@(42)
	.short 0x1b7c,0x0005,0x0028	/* moveb #5,a5@(40) */
	.short 0x3b7c,0x0044,0x0032	/* movew #68,a5@(50) */
	tstl sp@(40)
	bnes L474
	.short 0x7052	/* moveq #82,d0 */
	movel d0,a5@(60)
	clrl a5@(16)
	movel a5@(28),a5@(12)
	tstl a5@(8)
	beqs L498
	moveal a5,a0
	moveal a0@(24),a1
	bsrw L9b8
	bras L498
L474:
	.short 0x7057	/* moveq #87,d0 */
	movel d0,a5@(60)
	movel a5@(20),a5@(16)
	movel a5@(24),a5@(12)
	bras L498
L488:
	tstw sp@(98)
	beqs L498
	movel d7,d1
	moveal a4@(12),a6
	jsr a6@(-36)
L498:
	movel a5,d0
	moveml sp@+,d2-d7/a3/a5-a6
	.short 0xdefc,0x0034	/* addaw #52,sp */
	rts
	movel d5,sp@-
	movel d1,d5
	clrl sp@-
	movel d0,d1
	movel a0,d0
	movel d5,sp@-
	bsrw L2b4
	.short 0x504f	/* addqw #8,sp */
	movel sp@+,d5
	rts
	nop
	.short 0x514f	/* subqw #8,sp */
	moveml d7/a3-a6,sp@-
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel d0,sp@(20)
	movel d0,d7
	tstl a5@(16)
	moveal a1,a3
	bnes L4f2
	moveal a5,a0
	lea sp@(24),a1
	.short 0x7001	/* moveq #1,d0 */
	bsrw L51c
	movel d0,sp@(24)
	bles L514
	.short 0x53ad,0x000c	/* subql #1,a5@(12) */
	.short 0x52ad,0x0010	/* addql #1,a5@(16) */
L4f2:
	movel a5@(16),d0
	cmpl d0,d7
	bges L4fe
	movel d7,d1
	.byte 0x0c,0x40
L4fe:
	.byte 0x22,0x00	/* cmpiw #8704,d0 */
	movel d1,d0
	moveal a5@(12),a0
	moveal a3,a1
	moveal a4@(4),a6
	movel d1,d7
	jsr a6@(-624)
	movel d7,d0
L514:
	moveml sp@+,d7/a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L51c:
	.short 0x594f	/* subqw #4,sp */
	moveml d5-d7/a3-a6,sp@-
	movel d0,d7
	.short 0x7c00	/* moveq #0,d6 */
	moveal a1,a3
	moveal a0,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	braw L5bc
L534:
	moveal a5@(12),a0
	moveal a3,a1
	movel a5@(16),d0
	moveal a4@(4),a6
	jsr a6@(-624)
	movel a5@(16),d0
	clrl a5@(16)
	moveal a5,a0
	subl d0,d7
	addl d0,d6
	addal d0,a3
	bsrw L9e8
	movel d0,d5
	bgts L56a
	tstl d5
	bnes L566
	movel d6,d0
	bras L5e0
L566:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L5e0
L56a:
	movel a5@(134),d1
	asll #2,d1
	moveal a5,a0
	subal d1,a0
	movel a0,sp@(28)
	moveal sp@(28),a1
	moveal a1@(28),a1
	moveal a5,a0
	bsrw L9b8
	movel a5@(138),d0
	cmpl d5,d0
	blss L592
	movel d5,a5@(138)
L592:
	lea a5@(134),a6
	movel a6@+,d1
	asll #2,d1
	moveal a5,a0
	addal d1,a0
	moveal a0@(24),a1
	movel a6@,d1
	addal d1,a1
	.short 0x7001	/* moveq #1,d0 */
	movel a1,a5@(12)
	subl a5@(134),d0
	movel d0,a5@(134)
	subl a6@,d5
	movel d5,a5@(16)
	clrl a6@+
L5bc:
	cmpl a5@(16),d7
	bgtw L534
	moveal a5@(12),a0
	moveal a3,a1
	movel d7,d0
	moveal a4@(4),a6
	jsr a6@(-624)
	movel d6,d0
	subl d7,a5@(16)
	addl d7,d0
	addl d7,a5@(12)
L5e0:
	moveml sp@+,d5-d7/a3-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveal a0,a1
	movel a1@(16),d0
	beqs L60a
	moveal a1@(12),a0
	moveb a0@,d1
	moveb d1,sp@(3)
	.short 0x53a9,0x0010	/* subql #1,a1@(16) */
	.short 0x7000	/* moveq #0,d0 */
	moveb d1,d0
	.short 0x52a9,0x000c	/* addql #1,a1@(12) */
	bras L624
L60a:
	moveal a1,a0
	lea sp@(3),a1
	.short 0x7001	/* moveq #1,d0 */
	bsrw L51c
	tstl d0
	bles L622
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(3),d0
	.byte 0x0c,0x40
L622:
	.byte 0x70,0xff	/* cmpiw #28927,d0 */
L624:
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x9efc,0x0010	/* subaw #16,sp */
	moveml d6/a2-a5,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel d0,sp@(20)
	movel a1,sp@(24)
	movel a2,sp@-
	lea sp@(36),a2
	moveal a0,a5
	moveal a1,a3
	bsrw Lb64
	moveal sp@+,a0
	tstl d0
	beqs L6c0
	addal sp@(32),a3
	lea a3@(-1),a3
	.short 0x700a	/* moveq #10,d0 */
	cmpb a3@,d0
	beqs L6c0
	clrb sp@(31)
L664:
	moveal a5@(12),a0
	movel a5@(16),d1
	beqs L698
	.short 0x7c00	/* moveq #0,d6 */
	bras L676
L672:
	.short 0x5286	/* addql #1,d6 */
	.short 0x5288	/* addql #1,a0 */
L676:
	cmpl d1,d6
	bges L680
	.short 0x700a	/* moveq #10,d0 */
	cmpb a0@,d0
	bnes L672
L680:
	cmpl d1,d6
	bges L68c
	.short 0x1f7c,0x000a,0x001f	/* moveb #10,sp@(31) */
	.short 0x5286	/* addql #1,d6 */
L68c:
	subl d6,a5@(16)
	addl d6,a5@(12)
	cmpl d1,d6
	blts L6b2
L698:
	moveal a5,a0
	lea sp@(31),a1
	.short 0x7001	/* moveq #1,d0 */
	bsrw L51c
	.short 0x7201	/* moveq #1,d1 */
	cmpl d1,d0
	blts L6b2
	.short 0x700a	/* moveq #10,d0 */
	cmpb sp@(31),d0
	bnes L664
L6b2:
	.short 0x700a	/* moveq #10,d0 */
	cmpb sp@(31),d0
	bnes L6c0
	moveb d0,a3@
	clrb a3@(1)
L6c0:
	movel sp@(32),d0
	moveml sp@+,d6/a2-a5
	.short 0xdefc,0x0010	/* addaw #16,sp */
	rts
	nop
L6d0:
	moveml a5-a6,sp@-
	moveal a0,a5
	movel a5@(64),a5@(146)
	.short 0x70ff	/* moveq #-1,d0 */
	movel a5@(16),a5@(150)
	movel d0,a5@(64)
	moveal a4@(12),a6
	jsr a6@(-132)
	movel d0,a5@(68)
	clrl a5@(16)
	moveml sp@+,a5-a6
	rts
	nop
L700:
	moveml a5-a6,sp@-
	moveal a0,a5
	lea a5@(120),a0
	lea a5@(32),a1
	moveal a4@(4),a6
	jsr a6@(-240)
	.short 0x1b7c,0x0001,0x008e	/* moveb #1,a5@(142) */
	moveml sp@+,a5-a6
	rts
	nop
L724:
	.short 0x9efc,0x0108	/* subaw #264,sp */
	moveml d2/a2-a3/a5-a6,sp@-
	moveal a0,a5
	lea sp@(24),a0
	movel a0,d0
	.short 0x0240,0xfffc	/* andiw #-4,d0 */
	movel a5@,d1
	moveal d0,a2
	movel a2,d2
	moveal a4@(12),a6
	moveal a1,a3
	jsr a6@(-390)
	tstw d0
	bnes L756
	moveal a5,a0
	bsrw L6d0
	.short 0x7000	/* moveq #0,d0 */
	bras L75c
L756:
	movel a2@(124),a3@
	.short 0x7001	/* moveq #1,d0 */
L75c:
	moveml sp@+,d2/a2-a3/a5-a6
	.short 0xdefc,0x0108	/* addaw #264,sp */
	rts
	.short 0x9efc,0x0014	/* subaw #20,sp */
	moveml d2-d5/d7/a3-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel d0,sp@(40)
	movel d1,d5
	movel d0,d4
	moveal a0,a5
	bsrw L9e8
	movel d0,d7
	bges L79e
	tstb a5@(145)
	beqs L798
	movel a5@(146),d7
	movel a5@(150),a5@(16)
	bras L79e
L798:
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L79e:
	tstb a5@(143)
	beqw L932
	.short 0x7400	/* moveq #0,d2 */
	movel a5@,d1
	movel d2,d3
	moveal a4@(12),a6
	jsr a6@(-66)
	movel d0,sp@(36)
	bpls L7c6
	moveal a5,a0
	bsrw L6d0
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L7c6:
	movel d0,d2
	subl a5@(16),d2
	subl d7,d2
	addl a5@(138),d2
	movel d2,sp@(52)
	tstl d5
	bnes L7de
	movel d2,d5
	bras L7fe
L7de:
	.short 0x5285	/* addql #1,d5 */
	bnes L7e6
	movel d4,d5
	bras L800
L7e6:
	moveal a5,a0
	lea sp@(48),a1
	bsrw L724
	tstl d0
	bnes L7fa
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L7fa:
	movel sp@(48),d5
L7fe:
	addl d4,d5
L800:
	movel a5@(134),d1
	asll #2,d1
	moveal a5,a0
	subal d1,a0
	movel a5@(12),d0
	lea a0@(4),a3
	movel d5,d3
	movel d2,d1
	subl a3@(24),d0
	subl d1,d3
	subl d0,d2
	movel a5@(16),d0
	addl d1,d0
	addl d7,d0
	cmpl d2,d5
	blts L830
	cmpl d0,d5
	bltw L8cc
L830:
	cmpl d0,d5
	blts L86c
	moveal a5,a0
	lea sp@(48),a1
	bsrw L724
	tstl d0
	bnes L848
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L848:
	cmpl sp@(48),d5
	bles L86c
	.short 0x1b7c,0x0001,0x0091	/* moveb #1,a5@(145) */
	.short 0x7224	/* moveq #36,d1 */
	notb d1
	moveal a4@(12),a6
	jsr a6@(-462)
	moveal a5,a0
	bsrw L6d0
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L86c:
	movel d5,d0
	movel a5@(4),d1
	moveal a4@(8),a0
	jsr a0@(-156)
	movel a5@(4),d1
	jsr a0@(-144)
	.short 0x7600	/* moveq #0,d3 */
	movel d0,d4
	movel sp@(36),d0
	movel d4,d2
	subl d0,d2
	movel a5@,d1
	moveal a4@(12),a6
	jsr a6@(-66)
	tstl d0
	bpls L8a8
	moveal a5,a0
	bsrw L6d0
	.short 0x70ff	/* moveq #-1,d0 */
	braw L9ae
L8a8:
	moveal a5,a0
	moveal a0@(24),a1
	subl d4,d5
	bsrw L9b8
	.short 0x7000	/* moveq #0,d0 */
	movel d5,a5@(138)
	movel d0,a5@(16)
	clrl a5@(134)
	movel a5@(28),a5@(12)
	braw L996
L8cc:
	cmpl sp@(52),d5
	blts L8d8
	cmpl a5@(16),d3
	bgts L8f8
L8d8:
	moveal a5,a0
	bsrw L700
	subl d3,a5@(16)
	addl d3,a5@(12)
	tstb a5@(145)
	beqw L996
	movel a5@(146),a5@(64)
	braw L996
L8f8:
	moveal a5,a0
	moveal a3@(24),a1
	bsrw L9b8
	lea a5@(134),a6
	movel a6@+,d1
	subl a5@(16),d3
	asll #2,d1
	moveal a5,a0
	addal d1,a0
	addl a6@,d3
	subl d3,d7
	moveal a0@(24),a1
	addal d3,a1
	.short 0x7001	/* moveq #1,d0 */
	movel a1,a5@(12)
	movel d7,a5@(16)
	clrl a6@+
	subl a5@(134),d0
	movel d0,a5@(134)
	bras L996
L932:
	movel a5@(16),d0
	movel a5@(20),d1
	cmpl d0,d1
	blss L968
	subl d0,d1
	movel a5@(134),d0
	asll #2,d0
	moveal a5,a0
	addal d0,a0
	movel d1,d3
	movel a5@,d1
	movel a0@(24),d2
	moveal a4@(12),a6
	jsr a6@(-48)
	tstl d0
	bpls L968
	moveal a5,a0
	bsrw L6d0
	.short 0x70ff	/* moveq #-1,d0 */
	bras L9ae
L968:
	movel a5@,d1
	movel d4,d2
	movel d5,d3
	moveal a4@(12),a6
	jsr a6@(-66)
	movel d0,sp@(52)
	bpls L986
	moveal a5,a0
	bsrw L6d0
	.short 0x70ff	/* moveq #-1,d0 */
	bras L9ae
L986:
	movel a5@(20),a5@(16)
	clrl a5@(134)
	movel a5@(24),a5@(12)
L996:
	tstb a5@(145)
	beqs L9a0
	clrb a5@(145)
L9a0:
	moveal a4@(12),a6
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-462)
	movel sp@(52),d0
L9ae:
	moveml sp@+,d2-d5/d7/a3-a6
	.short 0xdefc,0x0014	/* addaw #20,sp */
	rts
L9b8:
	moveml a5-a6,sp@-
	moveal a0,a5
	lea a5@(100),a0
	movel a0,a5@(56)
	movel a1,a5@(76)
	lea a5@(32),a0
	moveal a0,a1
	moveal a5@(8),a0
	moveal a4@(4),a6
	jsr a6@(-366)
	.short 0x1b7c,0x0001,0x008e	/* moveb #1,a5@(142) */
	moveml sp@+,a5-a6
	rts
L9e8:
	moveml d2-d4/a2-a3/a5-a6,sp@-
	moveal a0,a5
	tstb a5@(142)
	beqs La58
	subal a2,a2
	lea a5@(100),a3
L9fa:
	clrb a5@(114)
	moveal a4@(4),a6
	moveal a3,a0
	jsr a6@(-384)
	moveal d0,a1
	jsr a6@(-252)
	.short 0x1b7c,0x0002,0x0072	/* moveb #2,a5@(114) */
	clrb a5@(142)
	movel a5@(64),d0
	bges La68
	movel a5@(68),d1
	movel a5@,d3
	movel a2,d4
	.short 0x7400	/* moveq #0,d2 */
	moveal a4@(12),a6
	jsr a6@(-480)
	tstl d0
	beqs La38
	.short 0x70ff	/* moveq #-1,d0 */
	bras La68
La38:
	tstb a5@(143)
	beqs La44
	movel a5@(134),d0
	bras La4a
La44:
	.short 0x7001	/* moveq #1,d0 */
	subl a5@(134),d0
La4a:
	asll #2,d0
	moveal a5,a0
	moveal a0@(0x18,d0:l),a1
	bsrw L9b8
	bras L9fa
La58:
	movel a5@(68),d1
	moveal a4@(12),a6
	jsr a6@(-462)
	movel a5@(64),d0
La68:
	moveml sp@+,d2-d4/a2-a3/a5-a6
	rts
	nop
La70:
	moveml d6-d7/a3-a6,sp@-
	moveal a0,a5
	movel d0,d7
	.short 0x7c00	/* moveq #0,d6 */
	tstl a5@(8)
	moveal a1,a3
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	bnes Laf0
	movel a5@(24),a5@(12)
	movel d7,d0
	movel a5@(20),a5@(16)
	bras Lb12
La98:
	movel a5@(16),d0
	beqs Lab6
	moveal a3,a0
	moveal a5@(12),a1
	moveal a4@(4),a6
	jsr a6@(-624)
	movel a5@(16),d0
	subl d0,d7
	addl d0,d6
	addal d0,a3
Lab6:
	moveal a5,a0
	bsrw L9e8
	tstl d0
	bpls Lac4
	.short 0x70ff	/* moveq #-1,d0 */
	bras Lb12
Lac4:
	movel a5@(134),d1
	asll #2,d1
	moveal a5,a0
	moveal a0@(0x18,d1:l),a1
	bsrw L9b8
	.short 0x7001	/* moveq #1,d0 */
	subl a5@(134),d0
	moveal a5,a0
	movel d0,a5@(134)
	asll #2,d0
	addal d0,a0
	movel a0@(24),a5@(12)
	movel a5@(20),a5@(16)
Laf0:
	cmpl a5@(16),d7
	bgts La98
	moveal a3,a0
	moveal a5@(12),a1
	movel d7,d0
	moveal a4@(4),a6
	jsr a6@(-624)
	movel d6,d0
	subl d7,a5@(16)
	addl d7,d0
	addl d7,a5@(12)
Lb12:
	moveml sp@+,d6-d7/a3-a6
	rts
	.short 0x594f	/* subqw #4,sp */
	moveal a0,a1
	movel d0,d1
	movel a1@(16),d0
	beqs Lb36
	moveal a1@(12),a0
	moveb d1,a0@
	.short 0x53a9,0x0010	/* subql #1,a1@(16) */
	.short 0x7001	/* moveq #1,d0 */
	.short 0x52a9,0x000c	/* addql #1,a1@(12) */
	bras Lb46
Lb36:
	moveb d1,sp@(3)
	.short 0x7001	/* moveq #1,d0 */
	moveal a1,a0
	lea sp@(3),a1
	bsrw La70
Lb46:
	.short 0x584f	/* addqw #4,sp */
	rts
	nop
	movel a5,sp@-
	moveal a0,a5
	moveal a1,a0
Lb52:
	tstb a0@+
	bnes Lb52
	.short 0x5388	/* subql #1,a0 */
	subal a1,a0
	movel a0,d0
	moveal a5,a0
	moveal sp@+,a5
	braw La70
Lb64:
	.short 0x514f	/* subqw #8,sp */
	moveml d4/d6-d7/a2/a4-a5,sp@-
	movel d0,d7
	movel a2,sp@(28)
	.short 0x5387	/* subql #1,d7 */
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a1,sp@(24)
	tstl d7
	moveal a1,a2
	moveal a0,a5
	bgts Lb8a
	.short 0x7000	/* moveq #0,d0 */
	bras Lc02
Lb8a:
	moveal a5@(12),a0
	movel a5@(16),d0
	beqs Lbd2
	cmpl d7,d0
	blts Lb9a
	movel d7,d0
Lb9a:
	movel d0,d1
	.short 0x7800	/* moveq #0,d4 */
	bras Lba4
Lba0:
	moveb a0@+,a2@+
	.short 0x5284	/* addql #1,d4 */
Lba4:
	cmpl d1,d4
	bges Lbae
	.short 0x700a	/* moveq #10,d0 */
	cmpb a0@,d0
	bnes Lba0
Lbae:
	addl d4,d6
	cmpl d1,d4
	bges Lbbc
	.short 0x700a	/* moveq #10,d0 */
	.short 0x5284	/* addql #1,d4 */
	.short 0x5286	/* addql #1,d6 */
	moveb d0,a2@+
Lbbc:
	subl d4,a5@(16)
	addl d4,a5@(12)
	cmpl d7,d4
	bges Lbec
	.short 0x700a	/* moveq #10,d0 */
	cmpb a2@(-1),d0
	beqs Lbec
	subl d4,d7
Lbd2:
	moveal a5,a0
	moveal a2,a1
	.short 0x7001	/* moveq #1,d0 */
	bsrw L51c
	.short 0x7201	/* moveq #1,d1 */
	cmpl d1,d0
	blts Lbec
	.short 0x5387	/* subql #1,d7 */
	.short 0x5286	/* addql #1,d6 */
	.short 0x700a	/* moveq #10,d0 */
	cmpb a2@+,d0
	bnes Lb8a
Lbec:
	clrb a2@
	moveal sp@(28),a0
	movel d6,a0@
	moveal sp@(24),a0
	cmpal a0,a2
	bnes Lc00
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x0c,0x40
Lc00:
	.byte 0x20,0x08	/* cmpiw #8200,d0 */
Lc02:
	moveml sp@+,d4/d6-d7/a2/a4-a5
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	movel a2,sp@-
	lea sp@(4),a2
	bsrw Lb64
	moveal sp@+,a2
	.short 0x584f	/* addqw #4,sp */
	rts
