	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x1e,0x80,0x04
	.byte 0x09,0x00,0x00,0x00,0x00,0x19,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00
	.short 0x0000,0x514f	/* orib #79,d0 */
	moveml d7/a2-a3/a5-a6,sp@-
	moveal d0,a5
	movel a0,a5@(34)
	.short 0x1b7c,0x0009,0x0008	/* moveb #9,a5@(8) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x19,0x00,0x0a	/* movel #25,a5@(10) */
	.short 0x1b7c,0x0006,0x000e	/* moveb #6,a5@(14) */
	.short 0x43f9,0x0000,0x0004	/* lea 0x4,a1 */
	movel a1,d0
	lea a5@(20),a0
	movew d0,a0@+
	.short 0x43f9,0x0000,0x0001	/* lea 0x1,a1 */
	movel a1,d0
	movew d0,a0@+
	.short 0x20fc,0x0000,0x0004	/* movel #4,a0@+ */
	lea a5@(48),a3
	.short 0x43f9,0x0000,0x002b	/* lea 0x2b,a1 */
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
	bsrw L84c
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
	bsrw L912
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
	.short 0x9efc,0x0058	/* subaw #88,sp */
	moveml d4-d7/a2-a6,sp@-
	moveal a4,a5
	movel a1,sp@(40)
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a0,sp@(36)
	movel a6,sp@(44)
	lea sp@(116),a0
	movel a0,sp@(112)
	movel sp@(36),sp@(88)
	lea %pc@(L3da),a0
	lea sp@(49),a1
	moveb a0@+,a1@+
	moveb a0@+,a1@+
	moveb a0@+,a1@+
	movel a5,d0
	moveal sp@(44),a6
	bnes L19a
	lea sp@(49),a5
L19a:
	moveb a5@,d6
	moveb a5@(1),d5
	moveb a5@(2),d4
	clrl sp@(52)
	movel a3,sp@(116)
	movel a4@(188),sp@(120)
	movel a2,sp@(96)
	movel sp@(112),sp@(100)
	movel a4@(204),sp@(104)
	lea sp@(52),a0
	movel a0,sp@(108)
	moveal sp@(44),a6
L1ce:
	moveal sp@(88),a0
	moveb a0@+,d7
	movel a0,sp@(88)
	tstb d7
	beqw L39c
	cmpb d6,d7
	moveal sp@(44),a6
	bnew L378
	clrl sp@(60)
	clrl sp@(64)
	moveal sp@(44),a6
L1f4:
	moveal sp@(88),a0
	moveb a0@+,d7
	movel a0,sp@(88)
	tstb d7
	beqs L23e
	cmpb d7,d5
	moveal sp@(44),a6
	bnes L216
	.short 0x7002	/* moveq #2,d0 */
	movel d0,sp@(60)
	moveal sp@(44),a6
	bras L23e
L216:
	cmpb d7,d4
	moveal sp@(44),a6
	beqs L234
	movel sp@(64),d0
	asll #8,d0
	.short 0x7200	/* moveq #0,d1 */
	moveb d7,d1
	orl d1,d0
	moveal sp@(44),a6
	movel d0,sp@(64)
	bras L1f4
L234:
	.short 0x7001	/* moveq #1,d0 */
	movel d0,sp@(60)
	moveal sp@(44),a6
L23e:
	.short 0x7001	/* moveq #1,d0 */
	cmpl sp@(60),d0
	moveal sp@(44),a6
	bnes L296
	clrl sp@(60)
	lea sp@(72),a0
	.short 0x10fc,0x0025	/* moveb #37,a0@+ */
	movel a0,sp@(68)
	moveal sp@(44),a6
L25e:
	moveal sp@(88),a0
	moveb a0@+,d7
	movel a0,sp@(88)
	tstb d7
	beqs L28e
	cmpb d7,d5
	moveal sp@(44),a6
	beqs L284
	moveal sp@(68),a0
	moveb d7,a0@+
	moveal sp@(44),a6
	movel a0,sp@(68)
	bras L25e
L284:
	.short 0x7002	/* moveq #2,d0 */
	movel d0,sp@(60)
	moveal sp@(44),a6
L28e:
	moveal sp@(68),a0
	clrb a0@
	bras L2a8
L296:
	lea %pc@(L3de),a0
	lea sp@(72),a1
	.short 0x7010	/* moveq #16,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-624)
L2a8:
	.short 0x203c,0x8100,0x0000	/* movel #-2130706432,d0 */
	addl sp@(64),d0
	moveal sp@(40),a0
	moveal a4@(204),a6
	jsr a6@(-30)
	moveal sp@(44),a6
	movel d0,sp@(92)
	beqs L2d8
	moveal sp@(92),a0
	movel a0@(4),sp@(56)
	moveal sp@(44),a6
	bras L348
L2d8:
	.short 0x203c,0x8000,0x0000	/* movel #-2147483648,d0 */
	addl sp@(64),d0
	moveal sp@(40),a0
	moveal a4@(204),a6
	jsr a6@(-30)
	moveal sp@(44),a6
	movel d0,sp@(92)
	beqs L31a
	lea %pc@(L3e2),a0
	lea sp@(72),a1
	.short 0x7010	/* moveq #16,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-624)
	moveal sp@(92),a0
	movel a0@(4),sp@(56)
	moveal sp@(44),a6
	bras L348
L31a:
	lea sp@(72),a0
	lea %pc@(L3de),a1
	.short 0x7010	/* moveq #16,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-624)
	lea %pc@(L3e6),a0
	movel a0,d1
	moveal sp@(40),a0
	moveal a4@(204),a6
	.short 0x203c,0xef75,0x6c6c	/* movel #-277517204,d0 */
	jsr a6@(-36)
	movel d0,sp@(56)
L348:
	moveml a2-a3,sp@-
	lea sp@(80),a0
	lea sp@(64),a1
	lea %pc@(L3f8),a2
	lea sp@(104),a3
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-522)
	moveml sp@+,a2-a3
	tstl sp@(60)
	moveal sp@(44),a6
	bnes L394
	moveal sp@(44),a6
	bras L39c
L378:
	.short 0x7000	/* moveq #0,d0 */
	moveb d7,d0
	movel a2,sp@-
	moveal a2,a0
	moveal d0,a2
	moveal sp@(116),a1
	moveal a4@(204),a6
	jsr a6@(-102)
	moveal sp@+,a2
	.short 0x52af,0x0034	/* addql #1,sp@(52) */
L394:
	moveal sp@(44),a6
	braw L1ce
L39c:
	moveal sp@(40),a0
	moveal a4@(204),a6
	.short 0x203c,0x9f00,0x0001	/* movel #-1627389951,d0 */
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-36)
	tstl d0
	moveal sp@(44),a6
	bnes L3cc
	movel a2,sp@-
	moveal a2,a0
	moveal sp@(116),a1
	moveal a4@(204),a6
	subal a2,a2
	jsr a6@(-102)
	moveal sp@+,a2
L3cc:
	movel sp@(52),d0
	moveml sp@+,d4-d7/a2-a6
	.short 0xdefc,0x0058	/* addaw #88,sp */
	rts
L3da:
	.short 0x7b7d	/* .short 0x7b7d */
	movel d0,sp@-
L3de:
	.byte 0x25,0x73,0x00,0x00
L3e2:
	.byte 0x25,0x6c	/* movel a3@(0,d0:w),a2@(9580) */
	.byte 0x64,0x00
L3e6:
	.byte 0x2a,0x4e	/* bccw 0x2e34 */
	.short 0x554c	/* subqw #2,a4 */
	.short 0x4c20	/* .short 0x4c20 */
	.short 0x504f	/* addqw #8,sp */
	.short 0x494e	/* .short 0x494e */
	.short 0x5445	/* addqw #2,d5 */
	.short 0x522a,0x0000	/* addqb #1,a2@(0) */
	nop
L3f8:
	.short 0x4ef9,0x0000,0x0000	/* jmp 0x0 */
	.short 0x7061	/* moveq #97,d0 */
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a2/a4-a5,sp@-
	movel a2,d7
	moveal a1,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(16)
	moveal a5@,a0
	.short 0x5295	/* addql #1,a5@ */
	moveb d7,a0@
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d7/a2/a4-a5
	.short 0x584f	/* addqw #4,sp */
	.byte 0x4e,0x75
L422:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* rts */
	.byte 0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
L436:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #0,d0 */
	.byte 0x00,0x00,0x04,0x4a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #74,d0 */
	.short 0x594f	/* subqw #4,sp */
	moveml d2/d7/a2/a4-a6,sp@-
	movel a2,d7
	moveal a1,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(24)
	tstb d7
	moveal sp@(24),a6
	bnes L468
	.short 0x7000	/* moveq #0,d0 */
	bras L482
L468:
	moveal a5@(4),a0
	movel a0,a4@(188)
	.short 0x7000	/* moveq #0,d0 */
	moveb d7,d0
	movel d0,d2
	movel a5@,d1
	moveal a4@(188),a6
	jsr a6@(-312)
	.short 0x7000	/* moveq #0,d0 */
L482:
	moveml sp@+,d2/d7/a2/a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x9efc,0x001c	/* subaw #28,sp */
	moveml a2-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a1,sp@(20)
	movel a6,sp@(24)
	lea %pc@(L422),a0
	lea sp@(28),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	moveml a2-a4,sp@-
	moveal a2,a1
	moveal a5,a0
	moveal a4@(176),a6
	lea sp@(40),a2
	moveal sp@(32),a4
	jsr a6@(-30)
	moveml sp@+,a2-a4
	moveml sp@+,a2-a6
	.short 0xdefc,0x001c	/* addaw #28,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2-a6,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(20)
	moveal a4@(188),a6
	jsr a6@(-60)
	moveml a2-a3,sp@-
	moveal a3,a1
	moveal d0,a3
	moveal a5,a0
	moveal a4@(176),a6
	jsr a6@(-42)
	moveml sp@+,a2-a3
	moveml sp@+,a2-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x9efc,0x0018	/* subaw #24,sp */
	moveml d7/a2-a6,sp@-
	exg a1,a3
	movel a1,d7
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(24)
	lea %pc@(L436),a0
	lea sp@(28),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	moveml a2-a4,sp@-
	moveal a2,a1
	moveal a5,a0
	moveal a4@(176),a6
	movel a3,sp@-
	lea sp@(44),a2
	moveal d7,a3
	moveal sp@+,a4
	jsr a6@(-30)
	moveml sp@+,a2-a4
	moveml sp@+,d7/a2-a6
	.short 0xdefc,0x0018	/* addaw #24,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a2-a6,sp@-
	movel a3,d7
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(24)
	movel a2,sp@-
	moveal a5,a0
	moveal d7,a3
	moveal a4@(176),a6
	subal a1,a1
	jsr a6@(-42)
	moveal sp@+,a2
	moveml sp@+,d7/a2-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2/a4-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(16)
	movel a2,sp@-
	moveal a5,a0
	moveal a4@(176),a6
	subal a1,a1
	jsr a6@(-48)
	moveal sp@+,a2
	moveml sp@+,a2/a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(20)
	moveml a2-a3,sp@-
	moveal a5,a0
	moveal a4@(176),a6
	subal a1,a1
	jsr a6@(-36)
	moveml sp@+,a2-a3
	moveml sp@+,a2-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2/a4-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(16)
	movel a2,sp@-
	moveal a5,a0
	moveal a4@(176),a6
	subal a1,a1
	jsr a6@(-72)
	moveal sp@+,a2
	moveml sp@+,a2/a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2/a4-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(16)
	movel a2,sp@-
	moveal a5,a0
	moveal a4@(176),a6
	subal a1,a1
	jsr a6@(-84)
	moveal sp@+,a2
	moveml sp@+,a2/a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a2/a4-a5,sp@-
	movel a2,d7
	moveal a1,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(16)
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d7/a2/a4-a5
	.short 0x584f	/* addqw #4,sp */
	.byte 0x4e,0x75
L64c:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* rts */
	.byte 0x00,0x00,0x06,0x30,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #48,d0 */
	.short 0x9efc,0x0018	/* subaw #24,sp */
	moveml a2-a6,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(20)
	lea %pc@(L64c),a0
	lea sp@(24),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	moveml a2-a4,sp@-
	moveal a2,a1
	moveal a5,a0
	moveal a4@(176),a6
	movel a3,sp@-
	lea sp@(40),a2
	subal a3,a3
	moveal sp@+,a4
	jsr a6@(-30)
	moveml sp@+,a2-a4
	moveml sp@+,a2-a6
	.short 0xdefc,0x0018	/* addaw #24,sp */
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d7/a2-a6,sp@-
	moveal a1,a3
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(24)
	movel a2,sp@-
	moveal a5,a0
	moveal a3,a1
	moveal a4@(176),a6
	jsr a6@(-72)
	moveal sp@+,a2
	movel d0,d7
	.short 0x5287	/* addql #1,d7 */
	movel d7,d0
	.short 0x7201	/* moveq #1,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveal sp@(24),a6
	movel d0,sp@(28)
	tstl d0
	beqs L704
	moveml a2-a3,sp@-
	moveal a3,a1
	moveal a5,a0
	moveal a4@(176),a6
	moveal sp@(36),a3
	jsr a6@(-36)
	moveml sp@+,a2-a3
L704:
	movel sp@(28),d0
	moveml sp@+,d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a4-a6,sp@-
	moveal a0,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(12)
	movel a5,d0
	moveal sp@(12),a6
	beqs L732
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L732:
	moveml sp@+,a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
	nop
	.short 0x9efc,0x0030	/* subaw #48,sp */
	moveml d7/a2-a6,sp@-
	moveal a4,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel d1,sp@(24)
	movel a0,sp@(28)
	movel a1,sp@(32)
	movel a6,sp@(36)
	.short 0x7efe	/* moveq #-2,d7 */
	lea %pc@(L832),a0
	lea sp@(40),a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	lea %pc@(L846),a0
	movel a0,sp@(52)
	movel a0,sp@(56)
	movel a2,sp@-
	moveal sp@(36),a0
	moveal a4@(176),a6
	moveal sp@(32),a2
	jsr a6@(-96)
	moveal sp@+,a2
	moveal sp@(36),a6
	movel d0,sp@(68)
	beqw L826
	movel sp@(68),sp@(48)
	movel a2,sp@-
	moveal a2,a0
	moveal a4@(176),a6
	moveal sp@(32),a2
	jsr a6@(-96)
	moveal sp@+,a2
	moveal sp@(36),a6
	movel d0,sp@(64)
	beqs L81a
	movel a2,sp@-
	moveal a3,a0
	moveal a4@(176),a6
	moveal sp@(32),a2
	jsr a6@(-96)
	moveal sp@+,a2
	moveal sp@(36),a6
	movel d0,sp@(60)
	beqs L80e
	moveml a2-a3,sp@-
	movel sp@(68),sp@-
	movel sp@(76),sp@-
	moveal a5,a0
	lea sp@(56),a1
	moveal a4@(196),a6
	moveal sp@(40),a2
	moveal sp,a3
	jsr a6@(-588)
	lea sp@(8),sp
	moveml sp@+,a2-a3
	movel d0,d7
	moveal sp@(60),a0
	moveal a4@(176),a6
	jsr a6@(-90)
L80e:
	moveal sp@(64),a0
	moveal a4@(176),a6
	jsr a6@(-90)
L81a:
	moveal sp@(68),a0
	moveal a4@(176),a6
	jsr a6@(-90)
L826:
	movel d7,d0
	moveml sp@+,d7/a2-a6
	.short 0xdefc,0x0030	/* addaw #48,sp */
	rts
L832:
	.byte 0x00,0x00,0x00,0x14,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #20,d0 */
L846:
	.short 0x2573,0x0000,0x4e71	/* movel a3@(0,d0:w),a2@(20081) */
L84c:
	.short 0x594f	/* subqw #4,sp */
	moveml a4-a6,sp@-
	moveal a6,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(12)
	movel a5,a4@(176)
	lea %pc@(L8e4),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(204)
	tstl d0
	moveal sp@(12),a6
	bnes L87e
	.short 0x7001	/* moveq #1,d0 */
	bras L8dc
L87e:
	lea %pc@(L8f4),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(188)
	tstl d0
	moveal sp@(12),a6
	bnes L8a8
	moveal a4@(204),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.short 0x7001	/* moveq #1,d0 */
	bras L8dc
L8a8:
	lea %pc@(L900),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(196)
	tstl d0
	moveal sp@(12),a6
	bnes L8da
	moveal a4@(204),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal a4@(204),a1
	jsr a6@(-414)
	.short 0x7001	/* moveq #1,d0 */
	bras L8dc
L8da:
	.short 0x7000	/* moveq #0,d0 */
L8dc:
	moveml sp@+,a4-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L8e4:
	.short 0x7574	/* .short 0x7574 */
	bvss L954
	bvss L95e
	.short 0x792e	/* .short 0x792e */
	bges L957
	bhis L962
	bsrs L964
	.short 0x7900	/* .short 0x7900 */
L8f4:
	bccs L965
	.short 0x732e	/* .short 0x732e */
	bges L963
	bhis L96e
	bsrs L970
	.short 0x7900	/* .short 0x7900 */
L900:
	bvss L970
	.short 0x7475	/* moveq #117,d2 */
	bvss L97a
	bvss L977
	bgts L938
	bges L975
	bhis L980
	bsrs L982
	.short 0x7900	/* .short 0x7900 */
L912:
	.short 0x594f	/* subqw #4,sp */
	moveml a4-a6,sp@-
	moveal a6,a5
	.short 0x49ee,0x0000	/* lea a6@(0),a4 */
	movel a6,sp@(12)
	movel a4@(196),d0
	beqs L934
	moveal a4@(196),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L934:
	moveal sp@(12),a6
L938:
	movel a4@(188),d0
	beqs L94a
	moveal a4@(188),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L94a:
	moveal sp@(12),a6
	movel a4@(204),d0
	beqs L960
L954:
	.byte 0x22,0x6c,0x00
L957:
	.byte 0xcc	/* moveal a4@(204),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae
L95e:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
L960:
	.byte 0x4c,0xdf
L962:
	.byte 0x70
L963:
	.byte 0x00	/* moveml sp@+,a4-a6 */
L964:
	.byte 0x58
L965:
	.byte 0x4f	/* addqw #4,sp */
	rts
	movel d7,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	.byte 0x58,0xac
L96e:
	.byte 0x00,0x94	/* addql #4,a4@(148) */
L970:
	bras L98a
L972:
	.byte 0x4a,0x2c,0x00
L975:
	.byte 0xb4	/* tstb a4@(180) */
	.byte 0x66
L977:
	.byte 0x04	/* bnes 0x97c */
	tstl d7
L97a:
	bnes L986
L97c:
	moveal a4@(148),a1
L980:
	moveal a1@,a0
L982:
	jsr a0@
	movel d0,d7
L986:
	.short 0x58ac,0x0094	/* addql #4,a4@(148) */
L98a:
	moveal a4@(148),a0
	tstl a0@
	bnes L972
	.short 0x197c,0x0001,0x00b4	/* moveb #1,a4@(180) */
	movel d7,d0
	movel sp@+,d7
	rts
	nop
L9a0:
	.short 0x9efc,0x0034	/* subaw #52,sp */
	moveml d2-d3/d7/a2-a3/a5-a6,sp@-
	lea %pc@(La72),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x7000	/* moveq #0,d0 */
	moveal a0,a5
	jsr a6@(-552)
	moveal d0,a3
	tstl a4@(172)
	bnes L9ca
	moveal a3,a6
	jsr a6@(-60)
	movel d0,d7
	bras L9de
L9ca:
	lea a4@(152),a0
	movel a0,d1
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	moveal a3,a6
	jsr a6@(-30)
	movel d0,d7
L9de:
	tstl d7
	beqs La50
	lea %pc@(La9a),a0
	movel a3,sp@-
	lea a4@(184),a1
	lea sp@(34),a3
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a0,a2
	lea %pc@(La7e),a0
	jsr a6@(-522)
	moveal sp@+,a3
	lea sp@(30),a0
	moveal a0,a1
La06:
	tstb a1@+
	bnes La06
	.short 0x5389	/* subql #1,a1 */
	movel a0,d2
	subal a0,a1
	moveal a3,a6
	movel a1,d3
	movel d7,d1
	jsr a6@(-48)
	moveal a5,a0
La1c:
	tstb a0@+
	bnes La1c
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movel a0,d3
	movel d7,d1
	movel a5,d2
	jsr a6@(-48)
	lea %pc@(Laa0),a0
	movel d7,d1
	movel a0,d2
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-48)
	tstl a4@(172)
	beqs La50
	.short 0x7264	/* moveq #100,d1 */
	addl d1,d1
	jsr a6@(-198)
	movel d7,d1
	jsr a6@(-36)
La50:
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	subal a1,a1
	jsr a6@(-294)
	.short 0x727a	/* moveq #122,d1 */
	moveal d0,a0
	movel d1,a0@(148)
	moveml sp@+,d2-d3/d7/a2-a3/a5-a6
	.short 0xdefc,0x0034	/* addaw #52,sp */
	rts
La72:
	bccs Lae3
	.short 0x732e	/* .short 0x732e */
	bges Lae1
	bhis Laec
	bsrs Laee
	.short 0x7900	/* .short 0x7900 */
La7e:
	.short 0x4361	/* .short 0x4361 */
	bgts Laa9
	.short 0x7420	/* moveq #32,d2 */
	bles Laf6
	bcss Laf6
	.byte 0x20,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x25	/* moveal a6@(73696f6e)@(2025),a0 */
	bges Laf8
	moveal sp@(26144),a0
	.byte 0x00,0x00
La9a:
	.byte 0x16,0xc0	/* orib #-64,d0 */
	rts
	.byte 0x00,0x00
Laa0:
	.byte 0x0a,0x00	/* orib #0,d0 */
	nop
	movel a6,sp@-
	.byte 0x43,0xfa,0x00
Laa9:
	.byte 0x2a	/* lea %pc@(0xad2),a1 */
	movel a4@(184),d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(188)
	movel d0,a4@(192)
	bnes Lacc
	lea %pc@(Lad2),a0
	bsrw L9a0
	.short 0x7001	/* moveq #1,d0 */
	.byte 0x0c,0x40
Lacc:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a6
	rts
Lad2:
	bccs Lb43
	.short 0x732e	/* .short 0x732e */
	bges Lb41
	bhis Lb4c
	bsrs Lb4e
	.short 0x7900	/* .short 0x7900 */
	movel a6,sp@-
	.byte 0x20
Lae1:
	.byte 0x2c,0x00
Lae3:
	.byte 0xc0	/* movel a4@(192),d0 */
	beqs Lafa
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
Laec:
	.byte 0x4e,0xae
Laee:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
	subal a0,a0
	movel a0,a4@(188)
Laf6:
	.byte 0x29,0x48
Laf8:
	.byte 0x00,0xc0	/* movel a0,a4@(192) */
Lafa:
	moveal sp@+,a6
	rts
	nop
	movel a6,sp@-
	lea %pc@(Lb2e),a1
	movel a4@(184),d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(196)
	movel d0,a4@(200)
	bnes Lb28
	lea %pc@(Lb2e),a0
	bsrw L9a0
	.short 0x7001	/* moveq #1,d0 */
	.byte 0x0c,0x40
Lb28:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a6
	rts
Lb2e:
	bvss Lb9e
	.short 0x7475	/* moveq #117,d2 */
	bvss Lba8
	bvss Lba5
	bgts Lb66
	bges Lba3
	bhis Lbae
	bsrs Lbb0
	.short 0x7900	/* .short 0x7900 */
	.byte 0x2f
Lb41:
	.byte 0x0e	/* movel a6,sp@- */
	.byte 0x20
Lb43:
	.byte 0x2c,0x00,0xc8	/* movel a4@(200),d0 */
	beqs Lb5c
	moveal d0,a1
	.byte 0x2c,0x78
Lb4c:
	.byte 0x00,0x04	/* moveal 0x4,a6 */
Lb4e:
	jsr a6@(-414)
	subal a0,a0
	movel a0,a4@(196)
	movel a0,a4@(200)
Lb5c:
	moveal sp@+,a6
	rts
	movel a6,sp@-
	lea %pc@(Lb8e),a1
Lb66:
	movel a4@(184),d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a4@(204)
	movel d0,a4@(208)
	bnes Lb88
	lea %pc@(Lb8e),a0
	bsrw L9a0
	.short 0x7001	/* moveq #1,d0 */
	.byte 0x0c,0x40
Lb88:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a6
	rts
Lb8e:
	.short 0x7574	/* .short 0x7574 */
	.short 0x696c	/* bvss 0xbfe */
	.short 0x6974	/* bvss 0xc08 */
	.short 0x792e	/* .short 0x792e */
	.short 0x6c69	/* bges 0xc01 */
	.short 0x6272	/* bhis 0xc0c */
	.short 0x6172	/* bsrs 0xc0e */
	.short 0x7900	/* .short 0x7900 */
Lb9e:
	movel a6,sp@-
	.byte 0x20,0x2c,0x00
Lba3:
	.byte 0xd0	/* movel a4@(208),d0 */
	.byte 0x67
Lba5:
	.byte 0x14	/* beqs 0xbba */
	moveal d0,a1
Lba8:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae
Lbae:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
Lbb0:
	subal a0,a0
	movel a0,a4@(204)
	movel a0,a4@(208)
Lbba:
	moveal sp@+,a6
	rts
	nop
	.data
	.byte 0x00,0x00,0x01,0x04,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20
	.byte 0x4a,0x00,0x66,0x02,0x4e,0x75,0x48,0xe7,0x7f,0xfe,0x20,0x6b,0x00,0x0c,0x52,0x90
	.byte 0x02,0x80,0x00,0x00,0x00,0xff,0x2c,0x6b,0x00,0x08,0x20,0x53,0x22,0x6b,0x00,0x04
	.byte 0x24,0x40,0x4e,0xae,0xff,0x9a,0x4c,0xdf,0x7f,0xfe,0x4e,0x75,0x48,0xe7,0x00,0x80
	.byte 0x10,0x18,0x4a,0x00,0x67,0x0e,0xb2,0x00,0x66,0xf6,0x20,0x08,0x53,0x80,0x4c,0xdf
	.byte 0x01,0x00,0x4e,0x75,0x42,0x80,0x60,0xf6,0x00,0x00,0x00,0x00,0x6e,0x65,0x77,0x66
	.byte 0x6d,0x74,0x20,0x34,0x2e,0x32,0x20,0x28,0x31,0x30,0x2e,0x31,0x2e,0x39,0x38,0x29
	.byte 0x00,0x6e,0x65,0x77,0x66,0x6d,0x74,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
	.byte 0x00,0x00,0x00,0xc4,0x00,0x00,0x00,0xd6,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x20
	.byte 0x00,0x00,0x01,0x58,0x00,0x00,0x04,0x8a,0x00,0x00,0x05,0x10,0x00,0x00,0x04,0xd8
	.byte 0x00,0x00,0x05,0xb4,0x00,0x00,0x05,0x60,0x00,0x00,0x05,0x8c,0x00,0x00,0x06,0x60
	.byte 0x00,0x00,0x05,0xe0,0x00,0x00,0x06,0xae,0x00,0x00,0x07,0x10,0x00,0x00,0x06,0x08
	.byte 0x00,0x00,0x07,0x3c,0xff,0xff,0xff,0xff,0x00,0x00,0x09,0x68,0x00,0x00,0x0b,0x60
	.byte 0x00,0x00,0x0b,0x00,0x00,0x00,0x0a,0xa4,0x00,0x00,0x00,0x00,0x00,0x00,0x0a,0xde
	.byte 0x00,0x00,0x0b,0x40,0x00,0x00,0x0b,0x9e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70
	.byte 0x63,0x6f,0x6e,0x3a,0x31,0x30,0x2f,0x31,0x30,0x2f,0x33,0x32,0x30,0x2f,0x38,0x30
	.byte 0x2f,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x94
