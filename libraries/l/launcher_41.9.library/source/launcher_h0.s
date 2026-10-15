	.text
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0c,0x4c,0x80,0x29,0x09,0x00,0x00,0x00
	.byte 0x00,0x1e,0x00,0x00,0x00,0x2f,0x00,0x00,0x00,0x38,0x6c,0x61,0x75,0x6e,0x63,0x68
	.byte 0x65,0x72,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x6c,0x61,0x75,0x6e,0x63
	.byte 0x68,0x65,0x72,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x34,0x31,0x2e,0x39
	.byte 0x20,0x28,0x35,0x2e,0x32,0x2e,0x39,0x36,0x29,0x0d,0x0a,0x00
	.byte 0x9e,0xfc
	.short 0x000c	/* .short 0x000c */
	moveml d6-d7/a2-a6,sp@-
	.short 0x307c,0x0004	/* moveaw #4,a0 */
	moveal a0@,a5
	subal a1,a1
	moveal a5,a6
	jsr a6@(-294)
	moveal d0,a3
	lea a5@(378),a0
	.short 0x43f9,0x0000,0x001e	/* lea 0x1e,a1 */
	jsr a6@(-276)
	moveal d0,a4
	movel a3,a4@(92)
	lea a3@(92),a0
	jsr a6@(-384)
	lea a3@(92),a0
	jsr a6@(-372)
	moveal d0,a2
	movel a2@(10),sp@(36)
	jsr a6@(-666)
	movel d0,a4@(96)
	tstl d0
	beqw L2d6
	moveal sp@(36),a1
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-324)
	.short 0x7c00	/* moveq #0,d6 */
Lae:
	moveal a4@(96),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(15),d0
	.short 0x7200	/* moveq #0,d1 */
	bset d0,d1
	.short 0x0041,0x1000	/* oriw #4096,d1 */
	movel d1,d0
	moveal a5,a6
	jsr a6@(-318)
	movel d0,d7
	btst #12,d7
	beqs L134
	tstl d6
	bnes L134
Ld4:
	moveal a4@(96),a0
	moveal a5,a6
	jsr a6@(-372)
	movel d0,sp@(32)
	beqw L2b2
	moveal d0,a0
	movel a0@(40),d1
	moveal a4@(88),a6
	jsr a6@(-90)
	moveal sp@(32),a0
	movel a0@(48),d1
	jsr a6@(-90)
	moveal sp@(32),a0
	movel a0@(24),d1
	jsr a6@(-156)
	moveal sp@(32),a0
	movel a0@(64),d0
	beqs L120
	moveal d0,a1
	.short 0x7010	/* moveq #16,d0 */
	moveal a5,a6
	jsr a6@(-324)
L120:
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(32),a0
	movew a0@(18),d0
	moveal a0,a1
	moveal a5,a6
	jsr a6@(-210)
	bras Ld4
L134:
	moveal a4@(96),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(15),d0
	.short 0x7200	/* moveq #0,d1 */
	bset d0,d1
	movel d7,d0
	andl d1,d0
	beqw Lae
L14a:
	moveal a4@(96),a0
	moveal a5,a6
	jsr a6@(-372)
	movel d0,sp@(32)
	beqw Lae
	.short 0x7207	/* moveq #7,d1 */
	moveal d0,a0
	cmpb a0@(8),d1
	bnes L1a8
	movel a0@(48),d1
	moveal a4@(88),a6
	jsr a6@(-90)
	moveal sp@(32),a0
	movel a0@(24),d1
	jsr a6@(-156)
	moveal sp@(32),a0
	movel a0@(64),d0
	beqs L192
	moveal d0,a1
	.short 0x7010	/* moveq #16,d0 */
	moveal a5,a6
	jsr a6@(-324)
L192:
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(32),a0
	movew a0@(18),d0
	moveal a0,a1
	moveal a5,a6
	jsr a6@(-210)
	.short 0x5386	/* subql #1,d6 */
	bras L14a
L1a8:
	movel a4@(96),a0@(14)
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x03ef	/* movel #-2147482641,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03ee	/* movel #-2147482642,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03ed	/* movel #-2147482643,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03ec	/* movel #-2147482644,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03f2	/* movel #-2147482638,sp@- */
	movel a0@(40),sp@-
	.short 0x2f3c,0x8000,0x03f8	/* movel #-2147482632,sp@- */
	movel a0@(44),sp@-
	.short 0x2f3c,0x8000,0x03f4	/* movel #-2147482636,sp@- */
	movel a0@(60),sp@-
	.short 0x2f3c,0x8000,0x03f5	/* movel #-2147482635,sp@- */
	movel a0@(56),sp@-
	.short 0x2f3c,0x8000,0x03f3	/* movel #-2147482637,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03ea	/* movel #-2147482646,sp@- */
	movel a0@(24),sp@-
	.short 0x2f3c,0x8000,0x03e9	/* movel #-2147482647,sp@- */
	moveal a4@(88),a6
	movel sp,d1
	jsr a6@(-498)
	lea sp@(92),sp
	movel d0,sp@(28)
	tstl d0
	beqs L264
	moveal d0,a0
	.short 0xd0fc,0x005c	/* addaw #92,a0 */
	moveal sp@(32),a1
	movel a0,a1@(20)
	moveal a5,a6
	jsr a6@(-366)
	moveal sp@(32),a0
	movel a0@(64),d0
	beqs L25e
	.short 0x7201	/* moveq #1,d1 */
	cmpl a0@(68),d1
	bnes L25e
	moveal d0,a1
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-324)
	moveal sp@(32),a0
	clrl a0@(64)
L25e:
	.short 0x5286	/* addql #1,d6 */
	braw L14a
L264:
	moveal sp@(32),a0
	movel a0@(40),d1
	jsr a6@(-90)
	moveal sp@(32),a0
	movel a0@(48),d1
	jsr a6@(-90)
	moveal sp@(32),a0
	movel a0@(24),d1
	jsr a6@(-156)
	moveal sp@(32),a0
	movel a0@(64),d0
	beqs L29c
	moveal d0,a1
	.short 0x7010	/* moveq #16,d0 */
	moveal a5,a6
	jsr a6@(-324)
L29c:
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@(32),a0
	movew a0@(18),d0
	moveal a0,a1
	moveal a5,a6
	jsr a6@(-210)
	braw L14a
L2b2:
	moveal a5,a6
	jsr a6@(-132)
	lea a4@(34),a0
	jsr a6@(-564)
	moveal a4@(96),a0
	jsr a6@(-672)
	clrl a4@(92)
	lea a4@(34),a0
	jsr a6@(-570)
	bras L2e6
L2d6:
	moveal a5,a6
	jsr a6@(-132)
	moveal sp@(36),a1
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-324)
L2e6:
	moveml sp@+,d6-d7/a2-a6
	.short 0xdefc,0x000c	/* addaw #12,sp */
	rts
	.byte 0x43,0x3a,0x00,0x00,0x69,0x63,0x6f,0x6e,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79
	.byte 0x00,0x00,0x43,0x4c,0x49,0x00,0x22,0x00,0x00,0x00,0x54,0x4f,0x4f,0x4c,0x50,0x52
	.byte 0x49,0x00,0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00
L31e:
	.short 0x9efc,0x0120	/* subaw #288,sp */
	moveml d2/d6-d7/a2-a6,sp@-
	moveal a1,a4
	moveal a0,a5
	moveal a4@(88),a6
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-126)
	movel d0,d6
	moveal a4@(84),a6
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a0
	movel a0@(184),sp@(308)
	.short 0x72ff	/* moveq #-1,d1 */
	movel d1,a0@(184)
	movel a0@(172),d1
	asll #2,d1
	moveal d1,a3
	movel d0,sp@(312)
	movel a3,d0
	beqw L3e4
	movel a3@(8),d0
	asll #2,d0
	movel d0,sp@(304)
L36a:
	tstl sp@(304)
	beqs L3e4
	moveal sp@(304),a0
	movel a0@(4),d1
	moveal a4@(88),a6
	jsr a6@(-126)
	movel a5,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d7
	tstl d7
	beqs L3d6
	lea sp@(44),a0
	movel a0,d0
	.short 0x0240,0xfffc	/* andiw #-4,d0 */
	movel d0,sp@(36)
	movel d0,d2
	movel d7,d1
	jsr a6@(-102)
	tstl d0
	beqs L3cc
	moveal d2,a0
	movel a0@(4),d0
	tstl d0
	bpls L3cc
	moveal sp@(312),a0
	movel sp@(308),a0@(184)
	movel d6,d1
	moveal a4@(88),a6
	jsr a6@(-126)
	movel d7,d0
	braw L4ac
L3cc:
	movel d7,d1
	moveal a4@(88),a6
	jsr a6@(-90)
L3d6:
	moveal sp@(304),a0
	movel a0@,d0
	asll #2,d0
	movel d0,sp@(304)
	bras L36a
L3e4:
	subal a2,a2
	moveal a4@(88),a6
	jsr a6@(-522)
	movel d0,sp@(316)
L3f2:
	.short 0x41fa,0xfefc	/* lea %pc@(0x2f0),a0 */
	movel a0,d1
	movel a2,d2
	moveal a4@(88),a6
	jsr a6@(-642)
	moveal d0,a2
	movel a2,d0
	beqs L47c
	movel a2@,d1
	jsr a6@(-528)
	movel a2@(4),d1
	jsr a6@(-126)
	movel a5,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d7
	tstl d7
	beqs L3f2
	lea sp@(48),a0
	movel a0,d0
	.short 0x0240,0xfffc	/* andiw #-4,d0 */
	movel d0,sp@(32)
	movel d0,d2
	movel d7,d1
	jsr a6@(-102)
	tstl d0
	beqs L46e
	moveal d2,a0
	movel a0@(4),d0
	tstl d0
	bpls L46e
	moveal sp@(312),a0
	movel sp@(308),a0@(184)
	movel d6,d1
	moveal a4@(88),a6
	jsr a6@(-126)
	movel sp@(316),d1
	jsr a6@(-528)
	movel a2,d1
	jsr a6@(-648)
	movel d7,d0
	bras L4ac
L46e:
	movel d7,d1
	moveal a4@(88),a6
	jsr a6@(-90)
	braw L3f2
L47c:
	movel sp@(316),d1
	moveal a4@(88),a6
	jsr a6@(-528)
	movel a2,d1
	jsr a6@(-648)
	movel d6,d1
	jsr a6@(-126)
	moveal sp@(312),a0
	movel sp@(308),a0@(184)
	moveal a4@(88),a6
	.short 0x7232	/* moveq #50,d1 */
	notb d1
	jsr a6@(-462)
	.short 0x7000	/* moveq #0,d0 */
L4ac:
	moveml sp@+,d2/d6-d7/a2-a6
	.short 0xdefc,0x0120	/* addaw #288,sp */
	rts
	.short 0x9efc,0x0110	/* subaw #272,sp */
	moveml d2/d5-d7/a2-a6,sp@-
	movel d0,d7
	moveal a6,a4
	moveal a0,a5
	moveal a4@(84),a6
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a3
	.short 0x700d	/* moveq #13,d0 */
	cmpb a3@(8),d0
	beqs L4de
	.short 0x7000	/* moveq #0,d0 */
	braw L9e8
L4de:
	movel a5,d0
	bnes L4f2
	moveal a4@(88),a6
	.short 0x7274	/* moveq #116,d1 */
	jsr a6@(-462)
	.short 0x7000	/* moveq #0,d0 */
	braw L9e8
L4f2:
	tstl d7
	bmis L4fc
	.short 0x7002	/* moveq #2,d0 */
	cmpl d0,d7
	bles L50e
L4fc:
	moveal a4@(88),a6
	.short 0x722e	/* moveq #46,d1 */
	notb d1
	jsr a6@(-462)
	.short 0x7000	/* moveq #0,d0 */
	braw L9e8
L50e:
	.short 0x43fa,0xfde4	/* lea %pc@(0x2f4),a1 */
	moveal a4@(84),a6
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	moveal d0,a2
	movel a2,d0
	beqw L9d0
	moveal a5,a0
	moveal a2,a6
	jsr a6@(-78)
	movel d0,sp@(304)
	beqw L9ba
	moveal d0,a0
	moveb a0@(48),d1
	.short 0x7403	/* moveq #3,d2 */
	cmpb d2,d1
	beqs L546
	.short 0x5901	/* subqb #4,d1 */
	bnew L9aa
L546:
	moveal a0@(54),a0
	.short 0x43fa,0xfdb6	/* lea %pc@(0x302),a1 */
	jsr a6@(-96)
	tstl d0
	beqw L6ce
	movel a5,d1
	moveal a4@(88),a6
	jsr a6@(-870)
	moveal d0,a0
L564:
	tstb a0@+
	bnes L564
	.short 0x5388	/* subql #1,a0 */
	subal d0,a0
	movel a0,d5
	movel d5,d1
	.short 0x741d	/* moveq #29,d2 */
	addl d2,d1
	movel d0,sp@(44)
	.short 0x707f	/* moveq #127,d0 */
	addl d0,d0
	cmpl d0,d1
	blss L584
	.short 0x7a1e	/* moveq #30,d5 */
	notb d5
L584:
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	lea sp@(48),a1
L58e:
	moveb a0@+,a1@+
	bnes L58e
	moveal sp@(44),a0
	lea sp@(65),a1
	movel d5,d0
	moveal a4@(84),a6
	jsr a6@(-624)
	movel d5,d0
	.short 0x7211	/* moveq #17,d1 */
	addl d1,d0
	clrb sp@(0x30,d0:l)
	lea sp@(48),a0
	.short 0x43f9,0x0000,0x0012	/* lea 0x12,a1 */
	bsrw Lc3c
	clrw sp@(40)
	movel a5,sp@(44)
L5c4:
	moveal sp@(44),a0
	moveb a0@,d0
	beqs L5e0
	.short 0x7220	/* moveq #32,d1 */
	cmpb d1,d0
	bnes L5da
	.short 0x3f7c,0x0001,0x0028	/* movew #1,sp@(40) */
	bras L5e0
L5da:
	.short 0x52af,0x002c	/* addql #1,sp@(44) */
	bras L5c4
L5e0:
	tstw sp@(40)
	beqs L628
	moveal a5,a0
L5e8:
	tstb a0@+
	bnes L5e8
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movel a0,d0
	.short 0x5680	/* addql #3,d0 */
	moveal a4@(84),a6
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-684)
	movel d0,sp@(44)
	tstl d0
	bnes L60a
	.short 0x7c67	/* moveq #103,d6 */
	bras L62e
L60a:
	moveal d0,a0
	.short 0x10bc,0x0022	/* moveb #34,a0@ */
	lea a0@(1),a1
	moveal a5,a0
L616:
	moveb a0@+,a1@+
	bnes L616
	moveal sp@(44),a0
	.short 0x43fa,0xfce6	/* lea %pc@(0x306),a1 */
	bsrw Lc3c
	bras L62e
L628:
	moveal a5,a0
	movel a0,sp@(44)
L62e:
	tstl sp@(44)
	beqw L9ae
	lea sp@(48),a0
	movel a0,d1
	moveal a4@(88),a6
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	jsr a6@(-30)
	movel d0,sp@(36)
	beqs L6b0
	tstl d7
	seq d1
	negb d1
	extw d1
	extl d1
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x03f7	/* movel #-2147482633,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x03ee	/* movel #-2147482642,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x0024	/* movel #-2147483612,sp@- */
	movel d1,sp@-
	.short 0x2f3c,0x8000,0x0023	/* movel #-2147483613,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x0022	/* movel #-2147483614,sp@- */
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x0021	/* movel #-2147483615,sp@- */
	movel sp@(96),d1
	movel sp,d2
	jsr a6@(-606)
	lea sp@(52),sp
	tstl d0
	beqs L6ac
	movel sp@(36),d1
	jsr a6@(-36)
	bras L6b6
L6ac:
	.short 0x7c00	/* moveq #0,d6 */
	bras L6b6
L6b0:
	jsr a6@(-132)
	movel d0,d6
L6b6:
	tstw sp@(40)
	beqw L9ae
	moveal sp@(44),a1
	moveal a4@(84),a6
	jsr a6@(-690)
	braw L9ae
L6ce:
	clrl sp@(296)
	.short 0x41fa,0xfc34	/* lea %pc@(0x308),a0 */
	movel a0,sp@(288)
	.short 0x7004	/* moveq #4,d0 */
	moveal sp@(304),a0
	cmpb a0@(48),d0
	bnes L752
	movel a5,d1
	moveal a4@(88),a6
	jsr a6@(-876)
	moveal d0,a0
	moveb a0@,sp@(283)
	clrb a0@
	movel d0,sp@(284)
	movel a5,d1
	moveal a4@(88),a6
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	moveal sp@(284),a0
	moveb sp@(283),a0@
	movel d0,sp@(296)
	bnes L73c
	moveal sp@(304),a0
	moveal a2,a6
	jsr a6@(-90)
	moveal a2,a1
	moveal a4@(84),a6
	jsr a6@(-414)
	moveal a4@(88),a6
	.short 0x7232	/* moveq #50,d1 */
	notb d1
	jsr a6@(-462)
	.short 0x7000	/* moveq #0,d0 */
	braw L9e8
L73c:
	movel a5,d1
	moveal a4@(88),a6
	jsr a6@(-870)
	moveal sp@(304),a0
	moveal a0@(50),a5
	movel d0,sp@(288)
L752:
	movel sp@(296),d0
	beqs L766
	movel d0,d1
	moveal a4@(88),a6
	jsr a6@(-126)
	movel d0,sp@(292)
L766:
	movel a5,d0
	beqs L79a
	tstb a5@
	beqs L79a
	movel a5,d1
	moveal a4@(88),a6
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,sp@(300)
	tstl d0
	bnes L7a2
	moveal a5,a0
	moveal a4,a1
	bsrw L31e
	movel d0,sp@(300)
	tstl d0
	bnes L7a2
	jsr a6@(-132)
	movel d0,d6
	bras L7a2
L79a:
	clrl sp@(300)
	.short 0x7c32	/* moveq #50,d6 */
	notb d6
L7a2:
	tstl sp@(296)
	beqs L7b4
	movel sp@(292),d1
	moveal a4@(88),a6
	jsr a6@(-126)
L7b4:
	movel sp@(300),d0
	beqw L9ae
	movel d0,d1
	moveal a4@(88),a6
	jsr a6@(-210)
	movel d0,sp@(284)
	tstl d0
	bnes L7d4
	jsr a6@(-132)
	movel d0,d6
L7d4:
	movel sp@(300),d1
	jsr a6@(-90)
	tstl sp@(284)
	beqw L9ae
	clrl sp@(276)
	.byte 0x2f,0x7c,0x00,0x00,0x10,0x00,0x01,0x18	/* movel #4096,sp@(280) */
	moveal sp@(304),a0
	moveal a0@(54),a0
	.short 0x43fa,0xfb10	/* lea %pc@(0x30a),a1 */
	moveal a2,a6
	jsr a6@(-96)
	movel d0,sp@(268)
	beqs L83a
	movel d0,d1
	lea sp@(276),a0
	movel a0,d2
	moveal a4@(88),a6
	jsr a6@(-816)
	.byte 0x0c,0xaf,0xff,0xff,0xff,0x80,0x01,0x14	/* cmpil #-128,sp@(276) */
	bges L82a
	.short 0x7080	/* moveq #-128,d0 */
	movel d0,sp@(276)
	bras L83a
L82a:
	.byte 0x0c,0xaf,0x00,0x00,0x00,0x7f,0x01,0x14	/* cmpil #127,sp@(276) */
	bles L83a
	.short 0x707f	/* moveq #127,d0 */
	movel d0,sp@(276)
L83a:
	moveal sp@(304),a0
	movel a0@(74),d0
	.short 0x0c80,0x0000,0x1000	/* cmpil #4096,d0 */
	bles L84e
	movel d0,sp@(280)
L84e:
	movel sp@(284),d1
	moveal a4@(88),a6
	jsr a6@(-126)
	movel d0,sp@(264)
	movel a5,d1
	jsr a6@(-150)
	movel d0,sp@(272)
	tstl d0
	bnes L872
	jsr a6@(-132)
	movel d0,d6
L872:
	movel sp@(264),d1
	jsr a6@(-126)
	tstl sp@(272)
	bnes L88c
	movel sp@(284),d1
	jsr a6@(-90)
	braw L9ae
L88c:
	movel a5,d1
	jsr a6@(-870)
	moveal d0,a5
	moveal a5,a0
L896:
	tstb a0@+
	bnes L896
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	moveal sp@(288),a1
	movel a1,d0
L8a4:
	tstb a1@+
	bnes L8a4
	.short 0x5389	/* subql #1,a1 */
	subal d0,a1
	movel a0,d0
	movel a1,d1
	addl d1,d0
	.short 0x724a	/* moveq #74,d1 */
	addl d1,d0
	movel d0,sp@(256)
	moveal a4@(84),a6
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,sp@(260)
	tstl d0
	beqw L992
	movel sp@(256),d1
	moveal d0,a0
	movew d1,a0@(18)
	.short 0x7201	/* moveq #1,d1 */
	movel d1,a0@(28)
	lea a0@(40),a1
	movel a1,a0@(36)
	movel sp@(272),a0@(24)
	movel sp@(280),a0@(56)
	movel sp@(276),a0@(60)
	lea a0@(72),a1
	movel a1,a0@(44)
	moveal a5,a0
L906:
	moveb a0@+,a1@+
	bnes L906
	moveal sp@(260),a0
	movel sp@(284),a0@(40)
	tstl sp@(296)
	beqs L952
	.short 0x7002	/* moveq #2,d0 */
	movel d0,a0@(28)
	moveal sp@(260),a1
	moveal a1@(44),a0
	movel a0,d0
L92a:
	tstb a0@+
	bnes L92a
	.short 0x5388	/* subql #1,a0 */
	subal d0,a0
	movel a0,d0
	.short 0x5280	/* addql #1,d0 */
	moveal a1@(44),a0
	addal d0,a0
	movel a0,a1@(52)
	moveal sp@(288),a1
L944:
	moveb a1@+,a0@+
	bnes L944
	moveal sp@(260),a0
	movel sp@(296),a0@(48)
L952:
	tstl d7
	beqs L96c
	moveal a4@(84),a6
	subal a1,a1
	jsr a6@(-294)
	moveal sp@(260),a0
	movel d0,a0@(64)
	movel d7,a0@(68)
L96c:
	moveal a4@(84),a6
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7210	/* moveq #16,d1 */
	jsr a6@(-306)
	moveal a4@(96),a0
	moveal sp@(260),a1
	jsr a6@(-366)
	tstl d7
	beqs L98e
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-318)
L98e:
	.short 0x7c00	/* moveq #0,d6 */
	bras L9ae
L992:
	.short 0x7c67	/* moveq #103,d6 */
	movel sp@(272),d1
	moveal a4@(88),a6
	jsr a6@(-156)
	movel sp@(284),d1
	jsr a6@(-90)
	bras L9ae
L9aa:
	.short 0x7c6a	/* moveq #106,d6 */
	addl d6,d6
L9ae:
	moveal sp@(304),a0
	moveal a2,a6
	jsr a6@(-90)
	bras L9c4
L9ba:
	moveal a4@(88),a6
	jsr a6@(-132)
	movel d0,d6
L9c4:
	moveal a2,a1
	moveal a4@(84),a6
	jsr a6@(-414)
	bras L9d4
L9d0:
	.short 0x7c32	/* moveq #50,d6 */
	notb d6
L9d4:
	tstl d6
	beqs L9e6
	movel d6,d1
	moveal a4@(88),a6
	jsr a6@(-462)
	.short 0x7000	/* moveq #0,d0 */
	bras L9e8
L9e6:
	.short 0x7001	/* moveq #1,d0 */
L9e8:
	moveml sp@+,d2/d5-d7/a2-a6
	.short 0xdefc,0x0110	/* addaw #272,sp */
	rts
	moveml d7/a4-a6,sp@-
	movel a0,d7
	moveal a6,a4
	moveal d0,a5
	moveal a4,a0
	movel a0,a5@(84)
	.short 0x43fa,0xf90e	/* lea %pc@(0x312),a1 */
	.short 0x7025	/* moveq #37,d0 */
	moveal a0,a6
	jsr a6@(-552)
	movel d0,a5@(88)
	tstl d0
	beqs La56
	.short 0x1b7c,0x0009,0x0008	/* moveb #9,a5@(8) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x1e,0x00,0x0a	/* movel #30,a5@(10) */
	.short 0x1b7c,0x0006,0x000e	/* moveb #6,a5@(14) */
	.short 0x3b7c,0x0029,0x0014	/* movew #41,a5@(20) */
	.short 0x3b7c,0x0009,0x0016	/* movew #9,a5@(22) */
	.byte 0x2b,0x7c,0x00,0x00,0x00,0x2f,0x00,0x18	/* movel #47,a5@(24) */
	movel d7,a5@(80)
	lea a5@(34),a0
	moveal a5@(84),a6
	jsr a6@(-558)
	clrl a5@(92)
	movel a5,d0
	bras La58
La56:
	.short 0x7000	/* moveq #0,d0 */
La58:
	moveml sp@+,d7/a4-a6
	rts
	.short 0x9efc,0x0014	/* subaw #20,sp */
	moveml a3-a6,sp@-
	moveal a6,a5
	.short 0x526d,0x0020	/* addqw #1,a5@(32) */
	bclr #3,a5@(14)
	lea a5@(34),a0
	moveal a5@(84),a6
	jsr a6@(-564)
	.short 0x7001	/* moveq #1,d0 */
	cmpw a5@(32),d0
	bnew Lb56
	tstl a5@(92)
	bnew Lb3c
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a4
	.short 0x700d	/* moveq #13,d0 */
	cmpb a4@(8),d0
	bnew Lb3c
	tstl a4@(172)
	beqw Lb3c
	clrl sp@-
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x03fa	/* movel #-2147482630,sp@- */
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x2f3c,0x8000,0x03f7	/* movel #-2147482633,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x03f6	/* movel #-2147482634,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x03f5	/* movel #-2147482635,sp@- */
	.short 0x4879,0x0000,0x001e	/* pea 0x1e */
	.short 0x2f3c,0x8000,0x03fc	/* movel #-2147482628,sp@- */
	.short 0x4879,0x0000,0x001e	/* pea 0x1e */
	.short 0x2f3c,0x8000,0x03f4	/* movel #-2147482636,sp@- */
	.short 0x487a,0xf564	/* pea %pc@(0x50) */
	.short 0x2f3c,0x8000,0x03eb	/* movel #-2147482645,sp@- */
	moveal a5@(88),a6
	movel sp,d1
	jsr a6@(-498)
	lea sp@(60),sp
	moveal d0,a3
	movel a3,d0
	beqs Lb3c
	.short 0x7000	/* moveq #0,d0 */
	lea sp@(16),a0
	.short 0x7213	/* moveq #19,d1 */
	moveb d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xb10 */
	movel a4,sp@(26)
	.short 0x3f7c,0x0014,0x0022	/* movew #20,sp@(34) */
	moveal a5@(84),a6
	.short 0x7210	/* moveq #16,d1 */
	jsr a6@(-306)
	lea a3@(92),a0
	lea sp@(16),a1
	jsr a6@(-366)
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-318)
Lb3c:
	tstl a5@(92)
	bnes Lb56
	.short 0x536d,0x0020	/* subqw #1,a5@(32) */
	lea a5@(34),a0
	moveal a5@(84),a6
	jsr a6@(-570)
	.short 0x7000	/* moveq #0,d0 */
	bras Lb64
Lb56:
	lea a5@(34),a0
	moveal a5@(84),a6
	jsr a6@(-570)
	movel a5,d0
Lb64:
	moveml sp@+,a3-a6
	.short 0xdefc,0x0014	/* addaw #20,sp */
	rts
Lb6e:
	moveml d7/a5-a6,sp@-
	moveal a6,a5
	tstw a5@(32)
	bnes Lbb8
	tstl a5@(92)
	bnes Lbb8
	movel a5@(80),d7
	moveal a5@(88),a1
	moveal a5@(84),a6
	jsr a6@(-414)
	moveal a5,a1
	jsr a6@(-252)
	moveal a5,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	subal d0,a0
	.short 0x7200	/* moveq #0,d1 */
	movew d0,d1
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(18),d0
	addl d0,d1
	moveal a0,a1
	movel d1,d0
	jsr a6@(-210)
	movel d7,d0
	bras Lbd4
Lbb8:
	movel a5@(92),d0
	beqs Lbcc
	moveal d0,a1
	moveal a5@(84),a6
	.short 0x7040	/* moveq #64,d0 */
	lsll #6,d0
	jsr a6@(-324)
Lbcc:
	bset #3,a5@(14)
	.short 0x7000	/* moveq #0,d0 */
Lbd4:
	moveml sp@+,d7/a5-a6
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	movew a5@(32),d0
	beqs Lbea
	.short 0x536d,0x0020	/* subqw #1,a5@(32) */
Lbea:
	lea a5@(34),a0
	moveal a5@(84),a6
	jsr a6@(-564)
	tstw a5@(32)
	beqs Lc06
	lea a5@(34),a0
	jsr a6@(-570)
	bras Lc1e
Lc06:
	lea a5@(34),a0
	jsr a6@(-570)
	btst #3,a5@(14)
	beqs Lc1e
	moveal a5,a6
	bsrw Lb6e
	bras Lc20
Lc1e:
	.short 0x7000	/* moveq #0,d0 */
Lc20:
	moveml sp@+,a5-a6
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,a5-a6
	rts
	moveal sp@(8),a1
	moveal sp@(4),a0
Lc3c:
	movel a0,d0
Lc3e:
	tstb a0@+
	bnes Lc3e
	.short 0x5388	/* subql #1,a0 */
Lc44:
	moveb a1@+,a0@+
	bnes Lc44
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	.data
	.byte 0x43,0x4f,0x4e,0x3a,0x30,0x2f,0x32,0x35,0x2f,0x36,0x34,0x30,0x2f,0x31,0x35,0x30
	.byte 0x2f,0x00,0x2f,0x41,0x55,0x54,0x4f,0x2f,0x57,0x41,0x49,0x54,0x00,0x00,0x00,0x00
	.byte 0x0a,0x5e,0x00,0x00,0x0b,0xda,0x00,0x00,0x0b,0x6e,0x00,0x00,0x0c,0x26,0x00,0x00
	.byte 0x04,0xb6,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x64,0x00,0x00,0x00,0x1e
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x09,0xf2
