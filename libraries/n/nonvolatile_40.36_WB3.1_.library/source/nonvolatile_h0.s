	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0d,0x60,0x81,0x28
	.byte 0x09,0x00,0x00,0x00,0x01,0xb7,0x00,0x00,0x01,0x99,0x00,0x00,0x00,0x1e
	.short 0x0000,0x009c	/* orib #-100,d0 */
	.short 0x0000,0x002e	/* orib #46,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x0048	/* orib #72,d0 */
	.short 0xffff	/* .short 0xffff */
	.short 0x0046,0x00c6	/* oriw #198,d6 */
	.short 0x00f4	/* .short 0x00f4 */
	bchg d0,a4@-
	movepl d2,a6@(1594)
	.short 0x04ba	/* .short 0x04ba */
	.short 0x065c,0x01ca	/* addiw #458,a4@+ */
	.short 0x026e,0x045a,0xffff	/* andiw #1114,a6@(-1) */
	movel a5,sp@-
	moveal d0,a5
	movel a0,a5@(36)
	movel a6,a5@(40)
	.short 0x3b7c,0x0024,0x0016	/* movew #36,a5@(22) */
	lea a5@(110),a0
	jsr a6@(-558)
	lea a5@(64),a0
	jsr a6@(-558)
	bsrw L6f4
	movel a5,d0
	moveal sp@+,a5
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	moveal a5@(40),a6
	tstw a5@(32)
	bnes Laa
	lea %pc@(L1d7),a1
	.short 0x7025	/* moveq #37,d0 */
	jsr a6@(-552)
	movel d0,a5@(48)
	beqs Lee
	lea %pc@(L1e7),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(52)
	bnes Laa
	bsrw L180
	bras Ld4
Laa:
	movel a5@(44),d0
	bnes Ld8
	lea %pc@(L1cb),a1
	lea a6@(378),a0
	jsr a6@(-276)
	tstl d0
	beqs Le2
	lea %pc@(L1cb),a1
	.short 0x7025	/* moveq #37,d0 */
	jsr a6@(-552)
	movel d0,a5@(44)
	bnes Ld8
	bsrw L170
Ld4:
	.short 0x7000	/* moveq #0,d0 */
	bras Lee
Ld8:
	tstl a5@(60)
	bnes Le2
	bsrw L794
Le2:
	.short 0x526d,0x0020	/* addqw #1,a5@(32) */
	bclr #3,a5@(14)
	movel a5,d0
Lee:
	moveml sp@+,a5-a6
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	moveal a5@(40),a6
	.short 0x536d,0x0020	/* subqw #1,a5@(32) */
	bnes L11a
	bsrw L896
	bsrs L160
	bclr #3,a5@(14)
	beqs L11a
	tstw a5@(32)
	bnes L11a
	bsrs L132
L11a:
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,a5-a6
	rts
	tstw a6@(32)
	beqs L132
	bset #3,a6@(14)
	.short 0x7000	/* moveq #0,d0 */
	rts
L132:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(40),a6
	movel a5@(36),d2
	moveal a5,a1
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
L160:
	moveal a5@(44),a1
	jsr a6@(-414)
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0x00,0x2c	/* movel #0,a5@(44) */
L170:
	moveal a5@(52),a1
	jsr a6@(-414)
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0x00,0x34	/* movel #0,a5@(52) */
L180:
	moveal a5@(48),a1
	jsr a6@(-414)
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x00,0x00,0x30	/* movel #0,a5@(48) */
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	bsrs L1fc
	.short 0x5f6e,0x6f6e	/* subqw #7,a6@(28526) */
	.short 0x766f	/* moveq #111,d3 */
	bges L201
	.short 0x7469	/* moveq #105,d2 */
	bges L209
	movel a4@(0x2e,d3:w),d0
	movew a6@(0x28,d2:w),a1@-
	movew a4@(0x39,d2:l:0x8),a0@-
	.short 0x2e39,0x3329,0x0d0a	/* movel 0x33290d0a,d7 */
	.byte 0x00
L1b7:
	.byte 0x6e,0x6f,0x6e,0x76,0x6f	/* oriw #28526,a6@(30319) */
	bges L21f
	.short 0x7469	/* moveq #105,d2 */
	bges L227
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L1cb:
	.byte 0x64,0x6f,0x73	/* oriw #28531,a4@- */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L1d7:
	.byte 0x75,0x74,0x69,0x6c,0x69	/* oriw #29801,a5@(69,d6:l:4) */
	.short 0x7479	/* moveq #121,d2 */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L1e7:
	.byte 0x6c,0x6f,0x77,0x6c,0x65	/* oriw #28535,a4@(27749) */
	.short 0x7665	/* moveq #101,d3 */
	bges L21e
	bges L25b
	bhis L266
	bsrs L268
	.short 0x7900	/* .short 0x7900 */
	moveml a5-a6,sp@-
L1fc:
	moveal a6,a5
	.byte 0x2c,0x6d,0x00
L201:
	.byte 0x28	/* moveal a5@(40),a6 */
	extl d1
	movel d1,sp@-
	beqs L21e
	.byte 0x4a
L209:
	.byte 0xad,0x00,0x34	/* tstl a5@(52) */
	beqs L21e
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-120)
	moveml sp@+,d0-d1/a0-a1/a6
L21e:
	.byte 0x70
L21f:
	.byte 0x0c	/* moveq #12,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.byte 0x4e
L227:
	.byte 0xae,0xff,0x3a	/* jsr a6@(-198) */
	tstl d0
	beqs L27c
	movel a4,sp@-
	moveal d0,a4
	.short 0x28fc,0x0000,0x000c	/* movel #12,a4@+ */
	.short 0x5880	/* addql #4,d0 */
	moveal a5,a6
	bsrw L724
	.short 0x518f	/* subql #8,sp */
	movel sp,d0
	bsrw L6f6
	movel sp@,d0
	cmpl a4@,d0
	bmis L25c
	moveal a4,a6
	.short 0x303c,0x0001	/* movew #1,d0 */
	movel sp@+,a6@+
	.short 0x51c8,0xfffc	/* dbf d0,0x254 */
	.byte 0x60
L25b:
	.byte 0x02	/* bras 0x25e */
L25c:
	.short 0x508f	/* addql #8,sp */
L25e:
	movel a4,sp@-
	moveal a5@(48),a6
	movel a4@,d0
L266:
	.short 0x720a	/* moveq #10,d1 */
L268:
	jsr a6@(-156)
	movel d0,a4@+
	movel a4@,d0
	.short 0x720a	/* moveq #10,d1 */
	jsr a6@(-156)
	movel d0,a4@+
	movel sp@+,d0
	moveal sp@+,a4
L27c:
	movel sp@+,d1
	beqs L296
	tstl a5@(52)
	beqs L296
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-126)
	moveml sp@+,d0-d1/a0-a1/a6
L296:
	moveml sp@+,a5-a6
	rts
	moveml d1-d7/a1-a6,sp@-
	moveal a6,a5
	moveal a0,a4
	movel a0,d6
	moveal a5@(40),a6
	extl d1
	movel d1,sp@-
	beqs L2c6
	tstl a5@(52)
	beqs L2c6
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-120)
	moveml sp@+,d0-d1/a0-a1/a6
L2c6:
	bsrw L706
	bsrw L70a
	movel d0,sp@-
	bsrw Lc18
	addl sp@+,d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x5080	/* addql #8,d0 */
	movel d0,sp@-
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel sp@+,d1
	movel d0,sp@-
	beqw L416
	moveml d2-d4/a2-a3,sp@-
	moveal d0,a3
	movel d1,a3@+
	movel a3,sp@(20)
	movel a3,a3@(8)
	.short 0x588b	/* addql #4,a3 */
	clrl a3@
	movel a3,a3@-
	lea a3@(12),a3
	moveal a3,a2
	addal a3@(-16),a3
	.short 0x97fc,0x0000,0x0011	/* subal #17,a3 */
	movel a3,d3
	cmpal a2,a3
	bltw L412
	.short 0xb9fc,0x0000,0x0000	/* cmpal #0,a4 */
	bnes L36c
	movel a2,d2
	movel a3,d3
	.short 0x528a	/* addql #1,a2 */
	bsrw Lb28
	bsrw L70e
	bsrw L43c
	moveal a3,a4
	moveal d2,a2
L33a:
	movel a4,a2@(8)
	.byte 0x25,0x7c,0x00,0x00,0x00,0x00,0x00,0x0c	/* movel #0,a2@(12) */
	.byte 0x25,0x7c,0x80,0x00,0x00,0x00,0x00,0x10	/* movel #-2147483648,a2@(16) */
	moveal a2,a1
	lea a2@(20),a2
	moveal sp@(20),a0
	.short 0x5888	/* addql #4,a0 */
	movel a0@(4),d0
	movel a1,a0@(4)
	exg d0,a0
	moveml d0/a0,a1@
	movel a1,a0@
	.short 0x538b	/* subql #1,a3 */
L36c:
	movel a2,d2
	.short 0x14fc,0x0000	/* moveb #0,a2@+ */
	bsrw Lb28
	bsrw L70e
	lea a2@(-1),a0
	cmpl a0,d2
	bnes L3a4
	.short 0x95fc,0x0000,0x0015	/* subal #21,a2 */
	moveal a2,a1
	moveal sp@(20),a0
	moveal a0@(8),a1
	movel a1@(4),d0
	beqs L3a2
	movel d0,a0@(8)
	exg d0,a1
	movel a0,a1@
	.short 0x5891	/* addql #4,a1@ */
L3a2:
	bras L404
L3a4:
	movel a3,d4
	bsrw L43c
	movel a3,sp@-
L3ac:
	cmpal d4,a3
	bges L402
	moveal a2,a1
	moveal sp@(24),a0
	.short 0x5888	/* addql #4,a0 */
	movel a0@(4),d0
	movel a1,a0@(4)
	exg d0,a0
	moveml d0/a0,a1@
	movel a1,a0@
	movel a3,a2@(8)
	.byte 0x25,0x7c,0x00,0x00,0x00,0x00,0x00,0x0c	/* movel #0,a2@(12) */
	.byte 0x25,0x7c,0x00,0x00,0x00,0x00,0x00,0x10	/* movel #0,a2@(16) */
	lea a2@(12),a2
	bsrw Lba2
	bsrw L712
	movel a2@,d1
	.short 0x5081	/* addql #8,d1 */
	.short 0x5281	/* addql #1,d1 */
	.short 0x82fc,0x000a	/* divuw #10,d1 */
	.short 0x0281,0x0000,0xffff	/* andil #65535,d1 */
	movel d1,a2@
	.short 0x508a	/* addql #8,a2 */
L3fc:
	tstb a3@+
	bnes L3fc
	bras L3ac
L402:
	moveal sp@+,a3
L404:
	tstl d6
	bnes L412
	tstb a4@+
	bnes L404
	cmpl a4,d3
	bgtw L33a
L412:
	moveml sp@+,d2-d4/a2-a3
L416:
	movel sp@+,d0
	bsrw L708
	movel sp@+,d1
	beqs L436
	tstl a5@(52)
	beqs L436
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-126)
	moveml sp@+,d0-d1/a0-a1/a6
L436:
	moveml sp@+,d1-d7/a1-a6
	rts
L43c:
	moveml d2-d3/a4/a6,sp@-
	moveal a5@(48),a6
	.short 0x163c,0x0000	/* moveb #0,d3 */
	moveb d3,a3@
L44a:
	cmpal d2,a2
	beqs L480
	tstb a2@-
	beqs L44a
	moveb a2@,a3@-
L454:
	moveb a2@-,a3@-
	bnes L454
	moveal d2,a4
L45a:
	cmpal a2,a4
	beqs L44a
	tstb a4@+
	beqs L45a
	.short 0x534c	/* subqw #1,a4 */
	moveal a4,a0
	lea a3@(1),a1
	jsr a6@(-162)
	beqs L478
L470:
	tstb a4@+
	bnes L470
	.short 0x538c	/* subql #1,a4 */
	bras L45a
L478:
	moveb d3,a4@+
	tstb a4@
	bnes L478
	bras L45a
L480:
	.short 0x528b	/* addql #1,a3 */
	moveml sp@+,d2-d3/a4/a6
	rts
	movel d2,d0
	.short 0xc0bc,0xffff,0xfffe	/* andl #-2,d0 */
	beqs L496
	.short 0x7000	/* moveq #0,d0 */
	rts
L496:
	moveml d3/a3-a6,sp@-
	moveal a6,a5
	moveal a0,a3
	moveal a1,a4
	extl d1
	movel d1,sp@-
	beqs L4bc
	tstl a5@(52)
	beqs L4bc
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-120)
	moveml sp@+,d0-d1/a0-a1/a6
L4bc:
	.short 0x7600	/* moveq #0,d3 */
	bsrw Lce4
	bsrw L714
	movel d3,d0
	movel sp@+,d1
	beqs L4e2
	tstl a5@(52)
	beqs L4e2
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-126)
	moveml sp@+,d0-d1/a0-a1/a6
L4e2:
	moveml sp@+,d3/a3-a6
	rts
	moveml d2/a3-a6,sp@-
	moveal a6,a5
	moveal a0,a3
	moveal a1,a4
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	movel d0,d2
	.short 0xc4fc,0x000a	/* muluw #10,d2 */
	extl d1
	movel d1,sp@-
	beqs L51a
	tstl a5@(52)
	beqs L51a
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-120)
	moveml sp@+,d0-d1/a0-a1/a6
L51a:
	.short 0x7001	/* moveq #1,d0 */
	movel a3,d1
	beqw L5d6
	movel a4,d1
	beqw L5d6
	tstb a3@
	bnes L534
	tstb a4@
	beqs L57a
	braw L5d6
L534:
	tstb a4@
	beqw L5d6
	moveal a3,a0
	.short 0x7200	/* moveq #0,d1 */
L53e:
	.short 0x0c10,0x002f	/* cmpib #47,a0@ */
	beqw L5d6
	.short 0x0c18,0x003a	/* cmpib #58,a0@+ */
	beqw L5d6
	.short 0x5281	/* addql #1,d1 */
	tstb a0@
	bnes L53e
	.short 0xb2bc,0x0000,0x001f	/* cmpl #31,d1 */
	bgts L5d6
	moveal a4,a0
	.short 0x7200	/* moveq #0,d1 */
L560:
	.short 0x0c10,0x002f	/* cmpib #47,a0@ */
	beqs L5d6
	.short 0x0c18,0x003a	/* cmpib #58,a0@+ */
	beqs L5d6
	.short 0x5281	/* addql #1,d1 */
	tstb a0@
	bnes L560
	.short 0xb2bc,0x0000,0x001f	/* cmpl #31,d1 */
	bgts L5d6
L57a:
	moveal a5,a6
	moveal a4,a1
	moveal a3,a0
	.short 0x223c,0x0000,0x03ed	/* movel #1005,d1 */
	movel d2,d0
	bsrw L9d2
	tstl d0
	bles L5d6
	.short 0xb0bc,0x0000,0x0001	/* cmpl #1,d0 */
	beqs L5d6
	moveal a4,a1
	moveal a3,a0
	.short 0x223c,0x0000,0x03ed	/* movel #1005,d1 */
	movel d2,d0
	bsrw L71a
	tstl d0
	beqs L5d6
	moveal a4,a1
	moveal a3,a0
	.short 0x223c,0x0000,0x03ee	/* movel #1006,d1 */
	movel d2,d0
	bsrw L9d2
	tstl d0
	bles L5d6
	moveal a4,a1
	moveal a3,a0
	.short 0x223c,0x0000,0x03ee	/* movel #1006,d1 */
	exg d2,d0
	bsrw L71a
	tstl d0
	beqs L5d6
	exg d2,d0
L5d6:
	bclr #31,d0
	movel sp@+,d1
	beqs L5f4
	tstl a5@(52)
	beqs L5f4
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-126)
	moveml sp@+,d0-d1/a0-a1/a6
L5f4:
	moveml sp@+,d2/a3-a6
	rts
	.short 0x0000,0x594f	/* orib #79,d0 */
	moveml d7/a2-a6,sp@-
	movel d1,d7
	moveal a6,a3
	moveal a1,a4
	moveal a0,a5
	movel a6,sp@(24)
	movel a5,d0
	beqs L65c
	movel a4,d0
	beqs L65c
	tstw d7
	beqs L622
	moveal a3@(52),a6
	jsr a6@(-120)
L622:
	moveal a5,a0
	moveal a4,a1
	moveal a3,a6
	.short 0x4eb9,0x0000,0x08ec	/* jsr 0x8ec */
	moveal d0,a2
	tstl d0
	moveal sp@(24),a6
	bnes L646
	moveal a5,a0
	moveal a4,a1
	moveal a3,a6
	.short 0x4eb9,0x0000,0x0716	/* jsr 0x716 */
	moveal d0,a2
L646:
	moveal sp@(24),a6
	tstw d7
	beqs L656
	moveal a3@(52),a6
	jsr a6@(-126)
L656:
	moveal sp@(24),a6
	bras L65e
L65c:
	subal a2,a2
L65e:
	movel a2,d0
	moveml sp@+,d7/a2-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	movel a6,sp@-
	movel a6,sp@(4)
	movel a0,d0
	beqs L684
	moveal a0,a1
	.short 0x5989	/* subql #4,a1 */
	movel a0@(-4),d0
	moveal a6@(40),a6
	jsr a6@(-210)
L684:
	moveal sp@+,a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d6-d7/a3-a6,sp@-
	movel d1,d7
	moveal a6,a3
	moveal a1,a4
	moveal a0,a5
	movel a6,sp@(28)
	movel a5,d0
	beqs L6e8
	movel a4,d0
	beqs L6e8
	tstw d7
	beqs L6b0
	moveal a3@(52),a6
	jsr a6@(-120)
L6b0:
	moveal a5,a0
	moveal a4,a1
	moveal a3,a6
	.short 0x4eb9,0x0000,0x071e	/* jsr 0x71e */
	movew d0,sp@(24)
	moveal a5,a0
	moveal a4,a1
	.short 0x4eb9,0x0000,0x0ac4	/* jsr 0xac4 */
	movew sp@(24),d1
	orw d0,d1
	movel d1,d6
	moveal sp@(28),a6
	tstw d7
	beqs L6e2
	moveal a3@(52),a6
	jsr a6@(-126)
L6e2:
	moveal sp@(28),a6
	bras L6ea
L6e8:
	.short 0x7c00	/* moveq #0,d6 */
L6ea:
	movew d6,d0
	moveml sp@+,d6-d7/a3-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L6f4:
	rts
L6f6:
	movel a0,sp@-
	moveal d0,a0
	clrl a0@
	clrl a0@(4)
	moveal sp@+,a0
	rts
	rts
L706:
	rts
L708:
	rts
L70a:
	.short 0x7000	/* moveq #0,d0 */
	rts
L70e:
	clrb a2@+
	rts
L712:
	rts
L714:
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L71a:
	.short 0x7004	/* moveq #4,d0 */
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x00,0x00
L724:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	cmpb d6,d4
	moveal a6,a5
	bsrw L896
	bsrs L794
	moveal a5@(44),a6
	movel a5@(60),d1
	beqs L784
	.short 0x9ffc,0x0000,0x0028	/* subal #40,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	jsr a6@(-114)
	moveal d2,a0
	movel a0@(20),d2
	movel a0@(12),d3
	movel d3,d4
	subl a0@(16),d4
	lea sp@(40),sp
	tstw d0
	beqs L784
	moveal a5@(48),a6
	movel d2,d0
	movel d3,d1
	jsr a6@(-144)
	movel d0,d3
	.short 0x5784	/* subql #3,d4 */
	bcss L780
	movel d2,d0
	movel d4,d1
	jsr a6@(-144)
	bras L788
L780:
	.short 0x7000	/* moveq #0,d0 */
	bras L788
L784:
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d3
L788:
	moveal sp@+,a0
	movel d3,a0@+
	movel d0,a0@+
	moveml sp@+,d2-d4/a5-a6
	rts
L794:
	moveml d2-d4/a4-a6,sp@-
	moveal a5@(40),a6
	lea a5@(110),a0
	jsr a6@(-564)
	.short 0x7201	/* moveq #1,d1 */
	extl d1
	movel d1,sp@-
	beqs L7c2
	tstl a5@(52)
	beqs L7c2
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-120)
	moveml sp@+,d0-d1/a0-a1/a6
L7c2:
	.short 0x7601	/* moveq #1,d3 */
	roll #8,d3
	lea %pc@(L8d7),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,d4
	beqw L86e
	movel d4,sp@-
	tstl a5@(44)
	beqw L864
	moveal a5@(44),a6
	.short 0xd8bc,0x0000,0x004a	/* addl #74,d4 */
	moveal d4,a0
	movel a0@,d4
	lea %pc@(L8b0),a0
L7f2:
	moveal sp,a4
	subal d3,sp
	.short 0x303c,0x0022	/* movew #34,d0 */
	lea %pc@(L8b4),a1
	.short 0x1931,0x0000	/* moveb a1@(0,d0:w),a4@- */
	.short 0x51c8,0xfffa	/* dbf d0,0x7fe */
	moveb a0@+,d0
	extw d0
	bras L810
	.short 0x1930,0x0000	/* moveb a0@(0,d0:w),a4@- */
L810:
	.short 0x51c8,0xfffa	/* dbf d0,0x80c */
	movel a4,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	addal d3,sp
	movel d0,d1
	beqs L850
	subal d3,sp
	movel sp,d2
	movel d1,sp@-
	jsr a6@(-42)
	movel sp@+,d1
	jsr a6@(-36)
	movel d2,d1
	moveal d2,a1
L83a:
	.short 0x0c19,0x0020	/* cmpib #32,a1@+ */
	bges L83a
	moveb d3,a1@-
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	addal d3,sp
	movel d0,a5@(60)
	bnes L864
L850:
	moveal d4,a0
	movel a0@,d4
	beqs L864
	moveal a0@(16),a0
	movel a0@(40),d0
	lsll #2,d0
	moveal d0,a0
	bras L7f2
L864:
	moveal sp@+,a1
	moveal a5@(40),a6
	jsr a6@(-414)
L86e:
	movel sp@+,d1
	beqs L888
	tstl a5@(52)
	beqs L888
	moveml d0-d1/a0-a1/a6,sp@-
	moveal a5@(52),a6
	jsr a6@(-126)
	moveml sp@+,d0-d1/a0-a1/a6
L888:
	lea a5@(110),a0
	jsr a6@(-570)
	moveml sp@+,d2-d4/a4-a6
	rts
L896:
	movel a5@(60),d1
	beqs L8ae
	movel a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(60)
	moveal a5@(44),a6
	jsr a6@(-90)
	moveal sp@+,a6
L8ae:
	rts
L8b0:
	bchg d1,a3@
	.short 0x5953	/* subqw #4,a3@ */
L8b4:
	moveaw a0@(0x65,d7:w:0x2),a5
	bnes L92d
	movel a5@-,sp@(28278)
	movel a1@-,a6@(29283)
	bvcs L92d
	.short 0x7665	/* moveq #101,d3 */
	.byte 0x2f,0x73,0x79,0x73,0x2f,0x6e,0x76,0x5f,0x6c,0x6f,0x63,0x61,0x74,0x69	/* movel a3@(2f6e765f)@(6c6f6361),sp@(29801) */
	bles L944
	.byte 0x00
L8d7:
	.byte 0x65,0x78,0x70	/* oriw #30832,a5@- */
	bsrs L94a
	.short 0x7369	/* .short 0x7369 */
	bles L94e
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	movel d7,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	movel a6@(60),d1
	beqw L9cc
	tstb a0@
	bnes L904
	tstb a1@
	bnes L904
	braw L9cc
L904:
	moveml d2-d6/a0-a6,sp@-
	moveal a6,a5
	moveal a5@(44),a6
	jsr a6@(-126)
	moveal d0,a3
	movel sp@(20),d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d6
	beqw L9c2
	movel d0,d1
	jsr a6@(-126)
	.byte 0x22,0x2f,0x00
L92d:
	.byte 0x18	/* movel sp@(24),d1 */
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d5
	beqw L9bc
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
L944:
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a2
L94a:
	movel d5,d1
	.byte 0x4e,0xae
L94e:
	.byte 0xff,0x9a	/* jsr a6@(-102) */
	movel a2@(124),d4
	lea sp@(264),sp
	tstw d0
	beqs L9b6
	.short 0x5884	/* addql #4,d4 */
	movel d4,d0
	.short 0x7201	/* moveq #1,d1 */
	moveal a5@(40),a6
	jsr a6@(-198)
	moveal a5@(44),a6
	tstl d0
	beqs L9b6
	moveal d0,a0
	movel d4,a0@+
	.short 0x5984	/* subql #4,d4 */
	movel a0,d7
	movel d5,d1
	jsr a6@(-378)
	movel d0,d1
	beqs L99c
	movel d1,d5
	movel d7,d2
	movel d4,d3
	jsr a6@(-42)
	subl d0,d4
	movel d5,d1
	jsr a6@(-36)
	tstl d4
	bnes L9a2
	bras L9bc
L99c:
	movel d5,d1
	jsr a6@(-90)
L9a2:
	moveal d7,a1
	movel a1@-,d0
	moveal a5@(40),a6
	jsr a6@(-210)
	moveal a5@(44),a6
	.short 0x7e00	/* moveq #0,d7 */
	bras L9bc
L9b6:
	movel d5,d1
	jsr a6@(-90)
L9bc:
	movel d6,d1
	jsr a6@(-90)
L9c2:
	movel a3,d1
	jsr a6@(-126)
	moveml sp@+,d2-d6/a0-a6
L9cc:
	movel d7,d0
	movel sp@+,d7
	rts
L9d2:
	movel d7,sp@-
	.short 0x7e03	/* moveq #3,d7 */
	moveml d1-d6/a0-a1/a4-a6,sp@-
	moveal a6,a5
	movel d0,d3
	.short 0x781f	/* moveq #31,d4 */
	moveal a5@(44),a6
	movel a5@(60),d1
	beqw Laba
	tstb a0@
	bnes L9f8
	tstb a1@
	bnes L9f8
	braw Laba
L9f8:
	subal a4,a4
	jsr a6@(-126)
	movel d0,d6
La00:
	movel sp@(24),d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d5
	bnes La26
	movel sp@(24),d1
	jsr a6@(-120)
	movel d0,d1
	beqs La62
	.short 0x287c,0x0000,0x0001	/* moveal #1,a4 */
	jsr a6@(-90)
	bras La00
La26:
	movel d0,d1
	jsr a6@(-126)
	movel sp@(28),d1
	movel sp@,d2
	jsr a6@(-30)
	movel d0,d4
	beqs La62
	.short 0x0c82,0x0000,0x03ee	/* cmpil #1006,d2 */
	bnes La48
	.short 0x287c,0x0000,0x0001	/* moveal #1,a4 */
La48:
	movel d4,d1
	movel a2,d2
	jsr a6@(-48)
	subl d0,d3
	movel d4,d1
	jsr a6@(-36)
	.short 0x7e04	/* moveq #4,d7 */
	tstl d3
	bnes La62
	movel d3,d7
	bras Laac
La62:
	jsr a6@(-132)
	.short 0xb0bc,0x0000,0x00ce	/* cmpl #206,d0 */
	beqs La8e
	.short 0xb0bc,0x0000,0x00d2	/* cmpl #210,d0 */
	beqs La8e
	.short 0xb0bc,0x0000,0x00d6	/* cmpl #214,d0 */
	beqs La86
	.short 0xb0bc,0x0000,0x00df	/* cmpl #223,d0 */
	bnes La90
La86:
	.short 0x2e3c,0x8000,0x0002	/* movel #-2147483646,d7 */
	bras Laac
La8e:
	.short 0x7e01	/* moveq #1,d7 */
La90:
	movel a4,d1
	beqs Laac
	movel d5,d1
	beqs La9c
	jsr a6@(-90)
La9c:
	moveal sp@(24),a0
	moveal sp@(28),a1
	exg a5,a6
	bsrs Lac4
	exg a5,a6
	bras Lab4
Laac:
	movel d5,d1
	beqs Lab4
	jsr a6@(-90)
Lab4:
	movel d6,d1
	jsr a6@(-126)
Laba:
	moveml sp@+,d1-d6/a0-a1/a4-a6
	movel d7,d0
	movel sp@+,d7
	rts
Lac4:
	moveml d3-a1/a5-a6,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	movel a6@(60),d1
	beqs Lb1e
	tstb a0@
	bnes Lada
	tstb a1@
	bnes Lada
	bras Lb1e
Lada:
	movel a0,d3
	movel a1,d4
	moveal a6,a5
	moveal a5@(44),a6
	jsr a6@(-126)
	movel d0,d6
	movel d3,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d5
	beqs Lb0a
	movel d0,d1
	jsr a6@(-126)
	movel d4,d1
	jsr a6@(-72)
	movel d0,d7
	movel d5,d1
	jsr a6@(-90)
Lb0a:
	movel a5@(60),d1
	jsr a6@(-126)
	movel d3,d1
	jsr a6@(-72)
	movel d6,d1
	jsr a6@(-126)
Lb1e:
	movel d7,d0
	moveml sp@+,d3-a1/a5-a6
	rts
	.byte 0x00,0x00
Lb28:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	movew a2@,d4
	movel a5@(60),d4
	beqs Lb9c
	moveal a5@(44),a6
	.short 0x7600	/* moveq #0,d3 */
	cmpl a4,d3
	beqs Lb5e
	movel d4,d1
	jsr a6@(-126)
	movel d0,sp@-
	.short 0x74fe	/* moveq #-2,d2 */
	movel a4,d1
	jsr a6@(-84)
	movel d0,d4
	movel sp@+,d1
	jsr a6@(-126)
	tstl d4
	beqs Lb9c
	.short 0x263c,0x7fff,0xffff	/* movel #2147483647,d3 */
Lb5e:
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a3
	movel d4,d1
	jsr a6@(-102)
Lb74:
	movel d4,d1
	jsr a6@(-108)
	tstw d0
	beqs Lb8e
	cmpl a3@(4),d3
	bpls Lb74
Lb84:
	.short 0x5240	/* addqw #1,d0 */
	moveb a3@(0x8,d0:w),a2@+
	bnes Lb84
	bras Lb74
Lb8e:
	lea sp@(264),sp
	tstl d3
	beqs Lb9c
	movel d4,d1
	jsr a6@(-90)
Lb9c:
	moveml sp@+,d2-d4/a3/a6
	rts
Lba2:
	moveml d2-d4/a3/a6,sp@-
	moveal a5@(44),a6
	movel a5@(60),d1
	beqs Lc10
	jsr a6@(-126)
	movel d0,sp@-
	.short 0x74fe	/* moveq #-2,d2 */
	movel a4,d1
	jsr a6@(-84)
	movel d0,d4
	jsr a6@(-126)
	movel a3,d1
	jsr a6@(-84)
	movel d0,d3
	movel sp@+,d1
	jsr a6@(-126)
	movel d3,d1
	beqs Lc08
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a3
	jsr a6@(-102)
	movel a3@(116),d0
	orl d0,a2@(4)
	movel a2@,d0
	cmpl a3@(124),d0
	bgts Lbfe
	movel a3@(124),a2@
Lbfe:
	lea sp@(264),sp
	movel d3,d1
	jsr a6@(-90)
Lc08:
	movel d4,d1
	beqs Lc10
	jsr a6@(-90)
Lc10:
	moveml sp@+,d2-d4/a3/a6
	rts
	.byte 0x00,0x00
Lc18:
	.byte 0x70,0x00	/* orib #0,d0 */
	movel a5@(60),d1
	beqs Lc98
	moveml d2/d7/a2/a6,sp@-
	moveal a5@(44),a6
	.short 0x7e00	/* moveq #0,d7 */
	movel a0,sp@-
	jsr a6@(-126)
	movel d0,sp@-
	movel sp@(4),d1
	beqs Lc3c
	bsrs Lc9a
	bras Lc8c
Lc3c:
	movel a5@(60),d1
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a2
	jsr a6@(-102)
Lc54:
	movel a5@(60),d1
	jsr a6@(-108)
	tstw d0
	beqs Lc88
	tstb a2@(4)
	bmis Lc54
Lc66:
	.short 0x5240	/* addqw #1,d0 */
	tstb a2@(0x8,d0:w)
	bnes Lc66
	.short 0xd07c,0x0015	/* addw #21,d0 */
	extl d0
	addl d0,d7
	moveml d2/a2,sp@-
	lea a2@(8),a0
	movel a0,d1
	bsrs Lc9a
	moveml sp@+,d2/a2
	bras Lc54
Lc88:
	lea sp@(264),sp
Lc8c:
	movel sp@+,d1
	jsr a6@(-126)
	movel d7,d0
	moveml sp@+,d1-d2/d7/a2/a6
Lc98:
	rts
Lc9a:
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d1
	beqs Lce0
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a2
	movel d1,sp@-
	jsr a6@(-102)
Lcba:
	movel sp@,d1
	jsr a6@(-108)
	tstw d0
	beqs Lcd6
Lcc4:
	.short 0x5240	/* addqw #1,d0 */
	tstb a2@(0x8,d0:w)
	bnes Lcc4
	.short 0xd07c,0x0015	/* addw #21,d0 */
	extl d0
	addl d0,d7
	bras Lcba
Lcd6:
	movel sp@+,d1
	jsr a6@(-90)
	lea sp@(264),sp
Lce0:
	rts
	.byte 0x00,0x00
Lce4:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	.short 0x0c12,0x2c6d	/* cmpib #109,a2@ */
	.short 0x002c,0x222d,0x003c	/* orib #45,a4@(60) */
	beqs Ld5a
	jsr a6@(-126)
	movel d0,sp@-
	movel d2,sp@-
	.short 0x74fe	/* moveq #-2,d2 */
	movel a3,d1
	jsr a6@(-84)
	movel d0,d5
	jsr a6@(-126)
	movel a4,d1
	jsr a6@(-84)
	movel d0,d4
	movel d4,d1
	beqs Ld4a
	.short 0x9ffc,0x0000,0x0108	/* subal #264,sp */
	movel sp,d2
	.short 0x5682	/* addql #3,d2 */
	.short 0xc43c,0x00fc	/* andb #-4,d2 */
	moveal d2,a3
	jsr a6@(-102)
	tstl d0
	beqs Ld4a
	movel a3@(116),d2
	lea sp@(264),sp
	movel d4,d1
	jsr a6@(-90)
	movel sp@,d0
	lsrb #1,d2
	lsrb #1,d0
	addxb d2,d2
	movel a4,d1
	jsr a6@(-186)
	orw d0,d3
Ld4a:
	movel sp@+,d2
	movel sp@+,d1
	jsr a6@(-126)
	movel d5,d1
	beqs Ld5a
	jsr a6@(-90)
Ld5a:
	moveml sp@+,d4-d5/a3/a6
	rts
	illegal
	.short 0x0000,0x0d60	/* orib #96,d0 */
	.short 0x0000,0x0d8e	/* orib #-114,d0 */
	.short 0x0400,0x0000	/* subib #0,d0 */
	.short 0x0000,0x0196	/* orib #-106,d0 */
	.short 0x0000,0x0196	/* orib #-106,d0 */
	.short 0x0000,0x0d7a	/* orib #122,d0 */
	lea %pc@(L1b7),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	moveal d0,a1
	jsr a6@(-414)
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	.data
