	.text
	/* ---- hunk0 CODE body 0x9f8 bytes ---- */
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x04,0x00,0x00
	.byte 0x51,0x4f
	moveml d7/a2-a3/a5-a6,sp@-
	moveal d0,a5
	movel a0,a5@(34)
	.short 0x1b7c,0x0009,0x0008	/* moveb #9,a5@(8) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x20,0x00,0x0a	/* movel #32,a5@(10) */
	.short 0x1b7c,0x0006,0x000e	/* moveb #6,a5@(14) */
	.short 0x43f9,0x0000,0x0001	/* lea 0x1,a1 */
	movel a1,d0
	lea a5@(20),a0
	movew d0,a0@+
	.short 0x43f9,0x0000,0x0000	/* lea 0x0,a1 */
	movel a1,d0
	movew d0,a0@+
	.short 0x20fc,0x0000,0x0030	/* movel #48,a0@+ */
	lea a5@(48),a3
	.short 0x43f9,0x0000,0x0007	/* lea 0x7,a1 */
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
	.short 0x43f9,0x0000,0x0000	/* lea 0x0,a1 */
	addal d0,a1
	movel a1@,d7
	lea a1@(4),a2
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
	bsrw L956
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
	bsrw L98a
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
L158:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a5-a6,sp@-
	moveal sp@(20),a5
	movel a6,sp@(12)
	movel a5,d0
	beqs L194
	moveal a4@(20),a0
	movew a0@(20),d0
	.short 0x7227	/* moveq #39,d1 */
	cmpw d1,d0
	bccs L180
	.short 0x7e00	/* moveq #0,d7 */
	moveb a5@(5),d7
	bras L18e
L180:
	moveal a5,a0
	moveal a4@(20),a6
	.short 0x7204	/* moveq #4,d1 */
	jsr a6@(-960)
	movel d0,d7
L18e:
	moveal sp@(12),a6
	bras L196
L194:
	.short 0x7e00	/* moveq #0,d7 */
L196:
	movel d7,d0
	moveml sp@+,d7/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L1a0:
	.byte 0xff,0xff
L1a2:
	.byte 0x7f,0xff,0x3f,0xff,0x1f,0xff,0x0f,0xff,0x07,0xff,0x03,0xff,0x01,0xff,0x00,0xff
	.byte 0x00,0x7f,0x00,0x3f,0x00,0x1f,0x00,0x0f,0x00,0x07,0x00,0x03,0x00,0x01,0x00,0x00
L1c2:
	.byte 0x67,0x72,0x61,0x70,0x68,0x69,0x63,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79
	.byte 0x00,0x00
L1d4:
	.byte 0x59,0x4f
	moveml d7/a5-a6,sp@-
	moveal sp@(20),a5
	movel a6,sp@(12)
	movel a5,d0
	beqs L210
	moveal a4@(20),a0
	movew a0@(20),d0
	.short 0x7227	/* moveq #39,d1 */
	cmpw d1,d0
	bccs L1fc
	.short 0x7e00	/* moveq #0,d7 */
	movew a5@(2),d7
	bras L20a
L1fc:
	moveal a5,a0
	moveal a4@(20),a6
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-960)
	movel d0,d7
L20a:
	moveal sp@(12),a6
	bras L212
L210:
	.short 0x7e00	/* moveq #0,d7 */
L212:
	movel d7,d0
	moveml sp@+,d7/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L21c:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a5-a6,sp@-
	moveal sp@(20),a5
	movel a6,sp@(12)
	movel a5,d0
	beqs L25a
	.byte 0x20,0x6c,0x00
L231:
	.byte 0x14	/* moveal a4@(20),a0 */
	movew a0@(20),d0
L236:
	.short 0x7227	/* moveq #39,d1 */
	cmpw d1,d0
	bccs L246
	.byte 0x70
L23d:
	.byte 0x00	/* moveq #0,d0 */
	movew a5@,d0
	asll #3,d0
	movel d0,d7
	bras L254
L246:
	moveal a5,a0
	moveal a4@(20),a6
	.short 0x7208	/* moveq #8,d1 */
	jsr a6@(-960)
	movel d0,d7
L254:
	moveal sp@(12),a6
	bras L25c
L25a:
	.short 0x7e00	/* moveq #0,d7 */
L25c:
	movel d7,d0
	moveml sp@+,d7/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L266:
	.short 0x9efc,0x00a8	/* subaw #168,sp */
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a5
	lea a6@(48),a4
	clrw sp@(116)
	movel a6,sp@(44)
	movel a5@(48),d0
	beqw L732
	moveal d0,a0
	movel a0@,sp@(144)
	tstl sp@(144)
	beqw L732
	moveal a5@,a3
	moveal a5@(12),a2
	moveal a5@(24),a0
	movel a0,sp@-
	movel a0,sp@(152)
	bsrw L158
	movel a3,sp@
	movel d0,sp@(196)
	bsrw L158
	.short 0x584f	/* addqw #4,sp */
	movel a5@(4),d1
	movel d1,d2
	lsrl #3,d2
	movel d2,d7
	.short 0x0247,0xfffe	/* andiw #-2,d7 */
	movel a5@(36),d2
	movel d1,d3
	addl d2,d3
	.short 0x5383	/* subql #1,d3 */
	lsrl #3,d3
	movel d3,d6
	.short 0x0246,0xfffe	/* andiw #-2,d6 */
	movel a5@(16),d3
	movel d3,d4
	lsrl #3,d4
	movel d4,d5
	.short 0x0245,0xfffe	/* andiw #-2,d5 */
	movel d3,d4
	addl d2,d4
	.short 0x5384	/* subql #1,d4 */
	movel d4,sp@(112)
	asrl #3,d4
	.short 0x0244,0xfffe	/* andiw #-2,d4 */
	movel d0,sp@(196)
	movel a5@(28),d0
	lsrl #3,d0
	.short 0x0240,0xfffe	/* andiw #-2,d0 */
	movel d4,sp@(208)
	movel a5@(28),d4
	movel d2,d3
	addl d4,d3
	.short 0x5383	/* subql #1,d3 */
	lsrl #3,d3
	.short 0x0243,0xfffe	/* andiw #-2,d3 */
	movel d3,d2
	subl d0,d2
	.short 0x5482	/* addql #2,d2 */
	movel d2,sp@(176)
	.short 0x740f	/* moveq #15,d2 */
	andl d2,d4
	andl d2,d1
	movel d4,d2
	subl d1,d2
	.short 0x720f	/* moveq #15,d1 */
	andl a5@(16),d1
	subl d1,d4
	moveml d0,sp@(204)
	moveml d2,sp@(164)
	moveml d3,sp@(200)
	moveml d4,sp@(160)
	tstl d2
	bpls L36a
	.short 0x7210	/* moveq #16,d1 */
	addl d1,sp@(164)
	.short 0x55af,0x00cc	/* subql #2,sp@(204) */
	tstl d4
	bpls L360
	.short 0x7010	/* moveq #16,d0 */
	addl d0,sp@(160)
	bras L37a
L360:
	.short 0x5585	/* subql #2,d5 */
	.short 0x3f7c,0x0001,0x0074	/* movew #1,sp@(116) */
	bras L37a
L36a:
	tstl d4
	bpls L37a
	.short 0x7010	/* moveq #16,d0 */
	addl d0,sp@(160)
	.short 0x55af,0x00cc	/* subql #2,sp@(204) */
	.short 0x5587	/* subql #2,d7 */
L37a:
	subl sp@(204),d3
	.short 0x5483	/* addql #2,d3 */
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(148),a0
	movew a0@,d0
	movel d3,sp@(172)
	cmpl d0,d3
	bles L396
	.short 0x7004	/* moveq #4,d0 */
	cmpl d0,d3
	bgts L3aa
L396:
	movel d3,d0
	movel a5@(40),d1
	bsrw L9c8
	moveal a5@(48),a0
	cmpl a0@(4),d0
	blss L3f0
L3aa:
	moveal a5,a0
	lea sp@(48),a1
	.short 0x700f	/* moveq #15,d0 */
L3b2:
	movel a0@+,a1@+
	dbf d0,L3b2
	movel a5@(36),d0
	lsrl #1,d0
	movel d0,a5@(36)
	movel d0,sp@(124)
	moveal a5,a0
	moveal sp@(44),a6
	bsrw L266
	movel sp@(124),d0
	addl d0,sp@(52)
	addl d0,sp@(64)
	addl d0,sp@(76)
	subl d0,sp@(84)
	lea sp@(48),a0
	bsrw L266
	braw L732
L3f0:
	moveal sp@(44),a6
	movel a3,d0
	beqs L408
	.short 0x7000	/* moveq #0,d0 */
	movew a3@,d0
	movel a5@(8),d1
	bsrw L9c8
	addl d7,d0
	bras L40a
L408:
	.short 0x7000	/* moveq #0,d0 */
L40a:
	.short 0x7200	/* moveq #0,d1 */
	movew a2@,d1
	movel d0,sp@(188)
	movel a5@(20),d0
	bsrw L9c8
	addl d5,d0
	.short 0x7200	/* moveq #0,d1 */
	moveal sp@(148),a0
	movew a0@,d1
	movel d0,sp@(184)
	movel a5@(32),d0
	bsrw L9c8
	addl sp@(204),d0
	movel a5@(60),sp@(132)
	movel a5@(52),sp@(140)
	movel a5@(56),sp@(136)
	movel d0,sp@(180)
	moveal a4@(20),a6
	jsr a6@(-456)
	.short 0x4878,0x00ff	/* pea 0xff */
	movel sp@(176),sp@-
	.short 0x4879,0x0000,0x0000	/* pea 0x0 */
	moveal sp@(56),a6
	bsrw L9b0
	lea sp@(12),sp
	.short 0x4279,0x0000,0x0000	/* clrw 0x0 */
	movel sp@(200),d0
	subl sp@(204),d0
	tstl d0
	bpls L480
	.short 0x5280	/* addql #1,d0 */
L480:
	asrl #1,d0
	movel d0,d1
	addl d1,d1
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	moveal a0,a1
	addal d1,a1
	clrw a1@
	movew sp@(116),d0
	extl d0
	movel d0,d1
	addl d1,d1
	moveal a0,a1
	addal d1,a1
	.short 0x32bc,0xffff	/* movew #-1,a1@ */
	movel sp@(208),d0
	subl d5,d0
	tstl d0
	bpls L4b0
	.short 0x5280	/* addql #1,d0 */
L4b0:
	asrl #1,d0
	movel d0,d2
	addl d2,d2
	moveal a0,a1
	addal d2,a1
	.short 0x700f	/* moveq #15,d0 */
	andl sp@(112),d0
	movel d0,d2
	addl d2,d2
	lea %pc@(L1a2),a6
	addal d2,a6
	movew a6@,d0
	notw d0
	movew d0,a1@
	addal d1,a0
	.short 0x700f	/* moveq #15,d0 */
	andl a5@(16),d0
	movel d0,d1
	addl d1,d1
	lea %pc@(L1a0),a1
	addal d1,a1
	movew a0@,d0
	andw a1@,d0
	movew d0,a0@
	moveal a4@(20),a6
	jsr a6@(-228)
	.short 0x303c,0xffff	/* movew #-1,d0 */
	moveal a4@(24),a0
	movew d0,a0@(68)
	movew d0,a0@(70)
	.short 0x317c,0x0dc0,0x0040	/* movew #3520,a0@(64) */
	clrw a0@(66)
	.byte 0x21,0x7c,0x00,0x00,0x00,0x00,0x00,0x50	/* movel #0,a0@(80) */
	movel sp@(172),d0
	movel d0,d1
	negl d1
	movew d1,a0@(100)
	moveal a2@(8),a0
	addal sp@(184),a0
	moveal a4@(24),a1
	movel a0,a1@(76)
	.short 0x7200	/* moveq #0,d1 */
	movew a2@,d1
	subl d0,d1
	movew d1,a1@(98)
	movel sp@(144),a1@(84)
	clrw a1@(102)
	moveal a4@(20),a0
	moveb a0@(236),d1
	btst #0,d1
	moveal sp@(44),a6
	beqs L566
	movel a5@(40),d1
	movew d1,a1@(92)
	movel d0,d1
	asrl #1,d1
	movew d1,a1@(94)
	bras L574
L566:
	movel a5@(40),d1
	asll #6,d1
	asrl #1,d0
	orl d0,d1
	movew d1,a1@(88)
L574:
	movel sp@(160),d0
	asll #8,d0
	asll #4,d0
	movel sp@(164),d1
	asll #8,d1
	asll #4,d1
	.short 0x7400	/* moveq #0,d2 */
	movew d0,d2
	.short 0x0042,0x0f00	/* oriw #3840,d2 */
	.short 0x7600	/* moveq #0,d3 */
	notb d3
	andl a5@(44),d3
	orl d3,d2
	.short 0x7800	/* moveq #0,d4 */
	movew d0,d4
	.short 0x0044,0x0b00	/* oriw #2816,d4 */
	orl d3,d4
	movew d0,sp@(122)
	movew d1,sp@(128)
	moveal a4@(20),a6
	jsr a6@(-228)
	.short 0x303c,0xffff	/* movew #-1,d0 */
	moveal a4@(24),a0
	movew d0,a0@(68)
	movew d0,a0@(70)
	clrw a0@(100)
	moveal sp@(44),a6
	movew d2,sp@(120)
	movew d4,sp@(118)
	movel a3,d0
	beqs L5da
	.short 0x7000	/* moveq #0,d0 */
	movew a3@,d0
	bras L5dc
L5da:
	.short 0x7000	/* moveq #0,d0 */
L5dc:
	movel sp@(172),d1
	subl d1,d0
	movew d0,a0@(98)
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(148),a0
	movew a0@,d0
	movel d0,d2
	subl d1,d2
	moveal a4@(24),a0
	movew d2,a0@(96)
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(148),a0
	movew a0@,d0
	subl d1,d0
	moveal a4@(24),a0
	movew d0,a0@(102)
	.short 0x1f7c,0x0001,0x00a8	/* moveb #1,sp@(168) */
	.short 0x7000	/* moveq #0,d0 */
	movel d0,sp@(156)
	movel d0,sp@(152)
L61c:
	movel sp@(152),d0
	cmpl sp@(192),d0
	bgew L726
	moveal a4@(20),a6
	jsr a6@(-228)
	moveal a4@(24),a0
	movel sp@(144),a0@(80)
	movel sp@(152),d0
	movel d0,d1
	asll #2,d1
	movel sp@(180),d2
	moveal sp@(148),a0
	moveal a0@(0x8,d1:l),a0
	addal d2,a0
	moveal a4@(24),a1
	movel a0,a1@(84)
	moveal sp@(148),a0
	moveal a0@(0x8,d1:l),a0
	addal d2,a0
	movel a0,a1@(72)
	.short 0x7200	/* moveq #0,d1 */
	moveb sp@(168),d1
	movel d1,d2
	andl sp@(140),d2
	moveal sp@(44),a6
	beqs L6a4
	movel sp@(156),d2
	cmpl sp@(196),d2
	bges L6a4
	movew sp@(128),a1@(66)
	movew sp@(120),a1@(64)
	movel d2,d3
	asll #2,d3
	.short 0x52af,0x009c	/* addql #1,sp@(156) */
	moveal a3@(0x8,d3:l),a0
	addal sp@(188),a0
	movel a0,a1@(76)
	bras L6de
L6a4:
	clrw a1@(66)
	movew sp@(118),a1@(64)
	movel sp@(132),d2
	beqs L6c6
	addl d0,d0
	movel d0,d3
	addl d3,d3
	moveal d2,a0
	.short 0x3030,0x3800	/* movew a0@(0,d3:l),d0 */
	movew d0,a1@(114)
	bras L6de
L6c6:
	.short 0x7000	/* moveq #0,d0 */
	moveb d1,d0
	andl sp@(136),d0
	beqs L6d8
	.short 0x203c,0x0000,0xffff	/* movel #65535,d0 */
	bras L6da
L6d8:
	.short 0x7000	/* moveq #0,d0 */
L6da:
	movew d0,a1@(114)
L6de:
	moveal a4@(20),a0
	moveb a0@(236),d0
	btst #0,d0
	beqs L702
	movel a5@(40),d0
	movew d0,a1@(92)
	movel sp@(172),d0
	movel d0,d2
	asrl #1,d2
	movew d2,a1@(94)
	bras L714
L702:
	movel a5@(40),d0
	asll #6,d0
	movel sp@(172),d2
	asrl #1,d2
	orl d2,d0
	movew d0,a1@(88)
L714:
	.short 0x7000	/* moveq #0,d0 */
	moveb d1,d0
	addl d0,d0
	moveb d0,sp@(168)
	.short 0x52af,0x0098	/* addql #1,sp@(152) */
	braw L61c
L726:
	moveal a4@(20),a6
	jsr a6@(-228)
	jsr a6@(-462)
L732:
	moveml sp@+,d2-d7/a2-a6
	.short 0xdefc,0x00a8	/* addaw #168,sp */
	rts
	.short 0x9efc,0x000c	/* subaw #12,sp */
	moveml d2/d4-d7/a2-a6,sp@-
	movel d2,d5
	movel d1,d6
	movel d0,d7
	moveal a0,a5
	lea a6@(48),a4
	.short 0x7000	/* moveq #0,d0 */
	moveb d5,d0
	.short 0x7200	/* moveq #0,d1 */
	notb d1
	andl d1,d0
	movew d0,sp@(50)
	moveml a1,sp@(40)
	moveml a6,sp@(44)
	movel a5,d1
	beqs L776
	bset #11,d0
	movew d0,sp@(50)
L776:
	movel a1,d0
	beqs L780
	bset #2,sp@(50)
L780:
	movel a2,d0
	beqs L78a
	bset #1,sp@(50)
L78a:
	movel a3,d0
	beqs L794
	bset #0,sp@(50)
L794:
	moveal a4@(20),a6
	jsr a6@(-456)
	jsr a6@(-228)
	.short 0x303c,0xffff	/* movew #-1,d0 */
	moveal a4@(24),a0
	movew d0,a0@(68)
	movew d0,a0@(70)
	movew sp@(50),d0
	movew d0,a0@(64)
	clrw a0@(66)
	clrw a0@(100)
	clrw a0@(98)
	clrw a0@(96)
	clrw a0@(102)
	movel a5,a0@(80)
	movel sp@(40),a0@(76)
	movel a2,a0@(72)
	movel a3,a0@(84)
	moveal a4@(20),a0
	moveb a0@(236),d0
	btst #0,d0
	moveal sp@(44),a6
	beqs L804
	movel d6,d0
	moveal a4@(24),a0
	movew d0,a0@(92)
	movel d7,d1
	lsrl #1,d1
	movew d1,a0@(94)
	bras L816
L804:
	movel d6,d0
	asll #6,d0
	movel d7,d1
	lsrl #1,d1
	orl d1,d0
	moveal a4@(24),a0
	movew d0,a0@(88)
L816:
	moveal a4@(20),a6
	jsr a6@(-228)
	moveal a4@(24),a0
	btst #5,a0@(2)
	sne d0
	negb d0
	extw d0
	extl d0
	movel d0,d4
	jsr a6@(-462)
	movel d4,d0
	moveml sp@+,d2/d4-d7/a2-a6
	.short 0xdefc,0x000c	/* addaw #12,sp */
	rts
	.short 0x9efc,0x003c	/* subaw #60,sp */
	moveml d2-d7/a2-a6,sp@-
	movel d1,d6
	movel d0,d7
	moveal a1,a3
	moveal a0,a5
	lea a6@(48),a4
	movel a5,sp@-
	movel a6,sp@(48)
	bsrw L158
	movel d0,d5
	movel a5,sp@
	bsrw L21c
	movel a5,sp@
	movel d0,sp@(104)
	bsrw L1d4
	.short 0x584f	/* addqw #4,sp */
	movel d0,sp@(96)
	tstw d6
	beqs L890
	.short 0x1f7c,0x00cc,0x005a	/* moveb #-52,sp@(90) */
	.short 0x1f7c,0x0088,0x005c	/* moveb #-120,sp@(92) */
	.short 0x1f7c,0x0022,0x005b	/* moveb #34,sp@(91) */
	bras L8a2
L890:
	.short 0x7033	/* moveq #51,d0 */
	.short 0x1f7c,0x00bb,0x005c	/* moveb #-69,sp@(92) */
	.short 0x1f7c,0x00ee,0x005b	/* moveb #-18,sp@(91) */
	moveb d0,sp@(90)
L8a2:
	btst #0,d7
	bnes L8b6
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(90),d0
	.short 0x0a40,0x00ff	/* eoriw #255,d0 */
	moveb d0,sp@(90)
L8b6:
	moveal a5,a0
	lea sp@(48),a1
	.short 0x7009	/* moveq #9,d0 */
L8be:
	movel a0@+,a1@+
	dbf d0,L8be
	.short 0x1f7c,0x0001,0x0035	/* moveb #1,sp@(53) */
	clrw sp@(88)
	moveal sp@(44),a6
L8d2:
	movew sp@(88),d0
	extl d0
	cmpl d5,d0
	bccs L944
	movew sp@(88),d0
	extl d0
	movel d0,d1
	asll #2,d1
	movel a5@(0x8,d1:l),sp@(56)
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(90),d0
	moveml d5-d7,sp@-
	movel d0,d6
	lea sp@(60),a0
	moveal a3,a1
	movel sp@(112),d4
	moveal a4@(20),a6
	.short 0x7000	/* moveq #0,d0 */
	movel d0,d1
	movel d0,d2
	movel d0,d3
	movel sp@(108),d5
	.short 0x7e00	/* moveq #0,d7 */
	notb d7
	subal a2,a2
	jsr a6@(-30)
	moveml sp@+,d5-d7
	lsrl #1,d7
	btst #0,d7
	moveal sp@(44),a6
	beqs L934
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(92),d0
	bras L93a
L934:
	.short 0x7000	/* moveq #0,d0 */
	moveb sp@(91),d0
L93a:
	moveb d0,sp@(90)
	.short 0x526f,0x0058	/* addqw #1,sp@(88) */
	bras L8d2
L944:
	moveal a4@(20),a6
	jsr a6@(-228)
	moveml sp@+,d2-d7/a2-a6
	.short 0xdefc,0x003c	/* addaw #60,sp */
	rts
L956:
	.short 0x594f	/* subqw #4,sp */
	moveml a4/a6,sp@-
	lea a6@(48),a4
	movel a6,sp@(8)
	lea %pc@(L1c2),a1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(20)
	moveal sp@(8),a6
	bnes L980
	.short 0x7001	/* moveq #1,d0 */
	bras L982
L980:
	.short 0x7000	/* moveq #0,d0 */
L982:
	moveml sp@+,a4/a6
	.short 0x584f	/* addqw #4,sp */
	rts
L98a:
	.short 0x594f	/* subqw #4,sp */
	moveml a4/a6,sp@-
	lea a6@(48),a4
	movel a6,sp@(8)
	movel a4@(20),d0
	beqs L9a8
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L9a8:
	moveml sp@+,a4/a6
	.short 0x584f	/* addqw #4,sp */
	rts
L9b0:
	moveal sp@(4),a0
	movel sp@(8),d0
	movel sp@(12),d1
	tstl d0
	bles L9c6
L9c0:
	moveb d1,a0@+
	.short 0x5380	/* subql #1,d0 */
	bnes L9c0
L9c6:
	rts
L9c8:
	moveml d1-d3,sp@-
	movel d0,d2
	beqs L9f0
	tstl d1
	bnes L9d8
	clrl d0
	bras L9f0
L9d8:
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
L9f0:
	moveml sp@+,d1-d3
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	/* hunk1 DATA body 32B: pad + InitTable + {0,0xdff000,0} */
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x00,0x00,0xdf,0xf0,0x00,0x00,0x00,0x00,0x00
	/* hunk2 DATA|CHIP body 512B zeros (blit pattern buffer) */
	.zero 512
	/* hunk3 CODE body 60B: functab + strings */
	.byte 0x00,0x00,0x00,0xc4,0x00,0x00,0x00,0xd6,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x02,0x66,0x00,0x00,0x07,0x3c,0x00,0x00,0x08,0x42,0xff,0xff,0xff,0xff
	.byte 0x64,0x70,0x62,0x6c,0x69,0x74,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00
	.byte 0x44,0x50,0x42,0x6c,0x69,0x74,0x42,0x61,0x73,0x65,0x00,0x6c
