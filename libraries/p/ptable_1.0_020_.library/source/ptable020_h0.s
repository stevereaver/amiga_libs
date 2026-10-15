	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0e,0x44,0x80,0x01
	.byte 0x09,0x16,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x33,0x00,0x00,0x00,0x5c,0x70,0x74
	.byte 0x61,0x62,0x6c,0x65,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56,0x45
	.byte 0x52,0x3a,0x20,0x70,0x74,0x61,0x62,0x6c,0x65,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x20,0x31,0x2e,0x30,0x20,0x28,0x31,0x36,0x2e,0x30,0x35,0x2e,0x32,0x30,0x32
	.byte 0x36,0x29,0x20,0x5b,0x36,0x38,0x30,0x32,0x30,0x5d,0x0a,0x00,0x00,0x00,0x00,0x2a
	.byte 0x00,0x00,0x00,0x6c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7a,0xff,0xff,0x00,0x24
	.byte 0x00,0x32,0x00,0x46,0x00,0x84,0x01,0x7e,0xff,0xff
	moveal d0,a1
	movel a6,a1@(34)
	movel a0,a1@(38)
L84:
	.byte 0x23,0x7c,0x00,0x01,0x00
L89:
	.byte 0x00,0x00,0x14	/* movel #65536,a1@(20) */
	movel a1,d0
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	.short 0x022e,0x00f7,0x000e	/* andib #-9,a6@(14) */
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
La4:
	.byte 0x66
La5:
	.byte 0x0a	/* bnes 0xb0 */
	btst #3,a6@(14)
	beqs Lb0
	bras Lb2
Lb0:
	rts
Lb2:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	tstw a5@(32)
	beqs Lcc
	.short 0x002d,0x0008,0x000e	/* orib #8,a5@(14) */
	.short 0x7000	/* moveq #0,d0 */
	bras Lea
Lcc:
	movel a5@(38),d2
	moveal a5,a1
	jsr a6@(-252)
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	moveal a5,a1
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
Lea:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
Lf4:
	bcss L16e
	.short 0x7061	/* moveq #97,d0 */
	bgts L16d
	bvss L16b
	bgts L12c
	bges L169
	bhis L174
	bsrs L176
	.short 0x7900	/* .short 0x7900 */
L106:
	bccs L177
	.short 0x732e	/* .short 0x732e */
	bges L175
	bhis L180
	bsrs L182
	.short 0x7900	/* .short 0x7900 */
L112:
	notw a1@(27749)
	.short 0x5379,0x7374,0x656d	/* subqw #1,0x7374656d */
	.byte 0x2e,0x72,0x65,0x73,0x6f,0x75,0x72,0x63,0x65,0x00
L126:
	.byte 0x5b,0x52	/* moveal a2@(6f757263)@(65005b52),sp */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
L12c:
	.short 0x7363	/* .short 0x7363 */
	bsrs L19e
	.byte 0x0d,0x0a,0x00
L133:
	.byte 0x5b	/* movepw a2@(91),d6 */
	.short 0x5244	/* addqw #1,d4 */
	clrw a5@+
	moveal a6@(28448),a0
	blss L19f
	.short 0x7264	/* moveq #100,d1 */
	.byte 0x0d,0x0a,0x00
L143:
	.byte 0x5b	/* movepw a2@(91),d6 */
	.short 0x5244	/* addqw #1,d4 */
	clrw a5@+
	moveal a6@(28448),a0
	.short 0x5244	/* addqw #1,d4 */
	.short 0x420d	/* .short 0x420d */
	.byte 0x0a,0x00
L152:
	.byte 0x5b,0x52	/* eorib #82,d0 */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
	movel a6@-,a5@(29472)
	.byte 0x00
L15d:
	.byte 0x5b,0x52,0x44	/* oriw #21060,a3@+ */
	clrw a5@+
	movel a3@(25199),d0
	bles L1dc
	.byte 0x20
L169:
	.byte 0x00	/* movel d0,d0 */
L16a:
	.byte 0x5b
L16b:
	.byte 0x52	/* subqw #5,a2@ */
	.byte 0x44
L16d:
	.byte 0x42	/* negw d2 */
L16e:
	.short 0x5d20	/* subqb #6,a0@- */
	movel a4@-,a5@(28531)
L174:
	.byte 0x20
L175:
	.byte 0x20	/* movel a0@-,d0 */
L176:
	.byte 0x00
L177:
	.byte 0x5b,0x52,0x44	/* oriw #21060,a3@+ */
	clrw a5@+
	.byte 0x20,0x73,0x6b,0x69
L180:
	.byte 0x70,0x20	/* moveal a3@(7020)@(0),a0 */
L182:
	.byte 0x00
L183:
	.byte 0x5b,0x52,0x44	/* oriw #21060,a3@+ */
	clrw a5@+
	moveal a4@-,a0
	bles L1fa
	bcss L19b
	.byte 0x0a,0x00
L190:
	.byte 0x5b,0x52	/* eorib #82,d0 */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
	bcss L20a
	.short 0x723a	/* moveq #58,d1 */
	.byte 0x20
L19b:
	.byte 0x6e,0x6f,0x20	/* moveal a6@(28448),a0 */
L19e:
	.byte 0x65
L19f:
	.byte 0x78	/* bcss 0x218 */
	.short 0x702e	/* moveq #46,d0 */
	bges L20d
	bhis L1b3
	.byte 0x0a,0x00
L1a8:
	.byte 0x5b,0x52	/* eorib #82,d0 */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
	bcss L222
	.short 0x723a	/* moveq #58,d1 */
	.byte 0x20
L1b3:
	.byte 0x6e,0x6f,0x20	/* moveal a6@(28448),a0 */
	blts L21d
	blts L1c7
	.byte 0x0a,0x00
L1bc:
	.byte 0x5b,0x52	/* eorib #82,d0 */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
	bcss L236
	.short 0x723a	/* moveq #58,d1 */
	.byte 0x20
L1c7:
	.byte 0x4f	/* moveal sp,a0 */
	.short 0x7065	/* moveq #101,d0 */
	bgts L210
	bcss L244
	bvss L233
	bcss L1f2
	movel d0,d2
L1d4:
	.short 0x5b52	/* subqw #5,a2@ */
	negw d2
	.short 0x5d20	/* subqb #6,a0@- */
	bnes L24b
L1dc:
	.short 0x756e	/* .short 0x756e */
	bccs L200
	.short 0x5244	/* addqw #1,d4 */
	.short 0x534b	/* subqw #1,a3 */
	.byte 0x0d,0x0a,0x00
L1e7:
	.byte 0x0d	/* movepw a2@(13),d6 */
	.short 0x0a00,0x48e7	/* eorib #-25,d0 */
	.short 0x3f3e	/* .short 0x3f3e */
	movel a1,d6
	movel d0,d5
L1f2:
	moveal a6@(34),a5
	.byte 0x20,0x3c,0x00,0x00
L1fa:
	.byte 0x02,0x84	/* movel #644,d0 */
	.byte 0x22,0x3c,0x00,0x01
L200:
	.byte 0x00,0x01	/* movel #65537,d1 */
	moveal a5,a6
	jsr a6@(-198)
	tstl d0
L20a:
	bnes L21a
	.byte 0x41
L20d:
	.byte 0xfa,0xff,0x9a	/* lea %pc@(0x1a8),a0 */
L210:
	bsrw L702
	.short 0x7c00	/* moveq #0,d6 */
	.byte 0x60,0x00
L218:
	.byte 0x01,0x18	/* braw 0x330 */
L21a:
	moveal d0,a4
	.byte 0x28
L21d:
	.byte 0x8d	/* movel a5,a4@ */
	movel d6,a4@(124)
L222:
	movel d5,a4@(12)
	lea a4@(132),a0
	movel a0,a4@(16)
	.byte 0x19,0x7c,0x00,0xff,0x00
L233:
	.byte 0x19	/* moveb #-1,a4@(25) */
	.byte 0x20,0x6c
L236:
	.byte 0x00,0x7c	/* moveal a4@(124),a0 */
	moveal a5,a6
	bsrw L6ae
	movel d0,a4@(128)
	.short 0x7000	/* moveq #0,d0 */
L244:
	lea %pc@(Lf4),a1
	moveal a5,a6
	.byte 0x4e
L24b:
	.byte 0xae,0xfd,0xd8	/* jsr a6@(-552) */
	movel d0,a4@(4)
	bnes L260
	lea %pc@(L190),a0
	bsrw L702
	braw L314
L260:
	moveal a5,a6
	.short 0x7044	/* moveq #68,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqw L2b8
	movel d0,a4@(120)
	moveal d0,a2
	.short 0x157c,0x0014,0x0008	/* moveb #20,a2@(8) */
	movel a4@(124),a2@(10)
	.short 0x157c,0x00d4,0x0010	/* moveb #-44,a2@(16) */
	lea %pc@(Le18),a0
	movel a0,a2@(28)
	.short 0x157c,0x0001,0x0011	/* moveb #1,a2@(17) */
	.short 0x357c,0xffff,0x0014	/* movew #-1,a2@(20) */
	.byte 0x25,0x7c,0x52,0x44,0x42,0x30,0x00,0x16	/* movel #1380205104,a2@(22) */
	.byte 0x25,0x7c,0x00,0xa0,0x00,0x00,0x00,0x20	/* movel #10485760,a2@(32) */
	.byte 0x25,0x7c,0x00,0x08,0x00,0x00,0x00,0x24	/* movel #524288,a2@(36) */
L2b8:
	moveal a5,a6
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(L106),a1
	jsr a6@(-552)
	movel d0,a4@(8)
	lea %pc@(L126),a0
	bsrw L702
	bsrs L338
	tstl d0
	beqs L2da
	bsrw L4c0
L2da:
	bsrw L400
	tstb a4@(26)
	beqs L2fa
	movel a4@(120),d0
	beqs L2fa
	movel a4@(4),d0
	beqs L2fa
	moveal d0,a6
	moveal a4@(120),a0
	jsr a6@(-30)
L2fa:
	moveal a4@,a6
	movel a4@(8),d0
	beqs L308
	moveal d0,a1
	jsr a6@(-414)
L308:
	movel a4@(4),d0
	beqs L314
	moveal d0,a1
	jsr a6@(-414)
L314:
	lea %pc@(L183),a0
	bsrw L702
	.short 0x7c00	/* moveq #0,d6 */
	moveb a4@(27),d6
	moveal a4,a1
	.short 0x203c,0x0000,0x0284	/* movel #644,d0 */
	moveal a4@,a6
	jsr a6@(-210)
L330:
	movel d6,d0
	moveml sp@+,d2-d7/a2-a6
	rts
L338:
	moveal a5,a6
	subal a1,a1
	jsr a6@(-294)
	lea a4@(28),a2
	movel d0,a2@(16)
	.short 0x70ff	/* moveq #-1,d0 */
	jsr a6@(-330)
	.short 0xb03c,0x00ff	/* cmpb #-1,d0 */
	bnes L358
	braw L3fc
L358:
	moveb d0,a2@(15)
	moveb d0,a4@(25)
	.short 0x157c,0x0004,0x0008	/* moveb #4,a2@(8) */
	clrb a2@(14)
	lea a2@(20),a0
	movel a0,a0@
	.short 0x5890	/* addql #4,a0@ */
	clrl a0@(4)
	movel a0,a0@(8)
	lea a4@(62),a1
	.short 0x137c,0x0005,0x0008	/* moveb #5,a1@(8) */
	.short 0x337c,0x0038,0x0012	/* movew #56,a1@(18) */
	movel a2,a1@(14)
	moveal a4@(124),a0
	movel a4@(12),d0
	.short 0x7200	/* moveq #0,d1 */
	jsr a6@(-444)
	tstl d0
	beqs L3bc
	movel d0,sp@-
	lea %pc@(L1bc),a0
	bsrw L702
	movel sp@+,d0
	bsrw L71c
	lea %pc@(L1e7),a0
	bsrw L702
	braw L3fc
L3bc:
	.short 0x197c,0x0001,0x0018	/* moveb #1,a4@(24) */
	.short 0x7e32	/* moveq #50,d7 */
L3c4:
	lea a4@(62),a1
	.short 0x337c,0x000e,0x001c	/* movew #14,a1@(28) */
	clrl a1@(32)
	clrb a1@(31)
	jsr a6@(-456)
	tstb a4@(93)
	bnes L3e6
	movel a4@(94),d0
	beqs L3f8
L3e6:
	bsrs L42e
	.short 0x5347	/* subqw #1,d7 */
	bnes L3c4
	lea %pc@(L133),a0
	bsrw L702
	.short 0x7000	/* moveq #0,d0 */
	rts
L3f8:
	.short 0x7001	/* moveq #1,d0 */
	rts
L3fc:
	.short 0x7000	/* moveq #0,d0 */
	rts
L400:
	moveal a4@,a6
	tstb a4@(24)
	beqs L414
	lea a4@(62),a1
	jsr a6@(-450)
	clrb a4@(24)
L414:
	moveb a4@(25),d0
	.short 0xb03c,0x00ff	/* cmpb #-1,d0 */
	beqs L42c
	extw d0
	extl d0
	jsr a6@(-336)
	.short 0x197c,0x00ff,0x0019	/* moveb #-1,a4@(25) */
L42c:
	rts
L42e:
	movel a6,sp@-
	movel a4@(8),d0
	beqs L442
	moveal d0,a6
	.short 0x7205	/* moveq #5,d1 */
	jsr a6@(-198)
	moveal sp@+,a6
	rts
L442:
	.short 0x203c,0x0002,0x49f0	/* movel #150000,d0 */
L448:
	.short 0x5380	/* subql #1,d0 */
	bnes L448
	moveal sp@+,a6
	rts
L450:
	moveml d1-d2/a1,sp@-
	.short 0x7200	/* moveq #0,d1 */
	addl d0,d0
	lsll #8,d0
	exg d0,d1
	.short 0x243c,0x0000,0x0200	/* movel #512,d2 */
	moveal a4@(16),a1
	bsrs L46e
	moveml sp@+,d1-d2/a1
	rts
L46e:
	moveml d1-d2/a0-a1/a6,sp@-
	moveal a4@,a6
	lea a4@(62),a0
	.short 0x317c,0xc000,0x001c	/* movew #-16384,a0@(28) */
	clrb a0@(31)
	movel d0,a0@(32)
	movel d1,a0@(44)
	movel d2,a0@(36)
	movel a1,a0@(40)
	moveal a0,a1
	jsr a6@(-456)
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@(93),d0
	moveml sp@+,d1-d2/a0-a1/a6
	rts
L4a4:
	moveml d2/a2,sp@-
	moveal a0,a2
	.short 0x7000	/* moveq #0,d0 */
	movel d1,d2
	.short 0x5382	/* subql #1,d2 */
	bmis L4b8
	addl a2@+,d0
	.short 0x51ca,0xfffc	/* dbf d2,0x4b2 */
L4b8:
	moveml sp@+,d2/a2
	tstl d0
	rts
L4c0:
	.short 0x7c00	/* moveq #0,d6 */
L4c2:
	movel d6,d0
	bsrs L450
	tstl d0
	bnes L4e6
	moveal a4@(16),a0
	.short 0x0c90,0x5244,0x534b	/* cmpil #1380209483,a0@ */
	bnes L4e6
	movel a0@(4),d1
	.short 0xb2bc,0x0000,0x0080	/* cmpl #128,d1 */
	bhis L4e6
	bsrs L4a4
	beqs L4fc
L4e6:
	.short 0x5286	/* addql #1,d6 */
	.short 0xbcbc,0x0000,0x0010	/* cmpl #16,d6 */
	bcsw L4c2
	lea %pc@(L143),a0
	bsrw L702
	rts
L4fc:
	lea %pc@(L1d4),a0
	bsrw L702
	moveal a4@(16),a0
	movel a0@(28),d5
	movel a0@(32),d4
	movel d4,d3
	.short 0x7410	/* moveq #16,d2 */
L514:
	movel d3,d0
	.short 0x5280	/* addql #1,d0 */
	beqw L54e
	.short 0x5382	/* subql #1,d2 */
	bmiw L54e
	movel d3,d6
	movel d3,d0
	bsrw L450
	tstl d0
	bnew L54e
	moveal a4@(16),a0
	.short 0x0c90,0x4653,0x4844	/* cmpil #1179863108,a0@ */
	bnew L54e
	movel a0@(16),d3
	bsrw L86e
	cmpl d3,d6
	beqs L54e
	braw L514
L54e:
	movel d5,d3
	.short 0x747f	/* moveq #127,d2 */
L552:
	movel d3,d0
	.short 0x5280	/* addql #1,d0 */
	beqs L580
	.short 0x5382	/* subql #1,d2 */
	bmis L580
	movel d3,d6
	movel d3,d0
	bsrw L450
	tstl d0
	bnes L580
	moveal a4@(16),a0
	.short 0x0c90,0x5041,0x5254	/* cmpil #1346458196,a0@ */
	bnes L580
	movel a0@(16),d3
	bsrs L582
	cmpl d3,d6
	beqs L580
	bras L552
L580:
	rts
L582:
	moveml d2-d7/a2/a5,sp@-
	moveal a4@(16),a2
	moveal a4@,a6
	movel a2@(20),d0
	btst #1,d0
	beqs L5a6
	lea %pc@(L177),a0
	bsrw L702
	bsrw L830
	braw L6a8
L5a6:
	tstl a4@(128)
	beqw L6a8
	movel a2@(128),d2
	.short 0xb4bc,0x0000,0x0014	/* cmpl #20,d2 */
	bhiw L6a8
	.short 0x7058	/* moveq #88,d0 */
	addw d0,d0
	.short 0x223c,0x0005,0x0001	/* movel #327681,d1 */
	jsr a6@(-198)
	tstl d0
	beqw L6a8
	movel d0,d7
	moveal d7,a5
	.byte 0x2b,0x7c,0xff,0xff,0xff,0xff,0x00,0x24	/* movel #-1,a5@(36) */
	.byte 0x2b,0x7c,0x00,0x00,0x0f,0xa0,0x00,0x14	/* movel #4000,a5@(20) */
	.short 0x7005	/* moveq #5,d0 */
	movel d0,a5@(24)
	lea a2@(36),a0
	lea a5@(144),a1
	.short 0x7600	/* moveq #0,d3 */
	moveb a0@,d3
	.short 0x5283	/* addql #1,d3 */
L5f8:
	moveb a0@+,a1@+
	.short 0x5383	/* subql #1,d3 */
	bnes L5f8
	lea a5@(144),a1
	movel a1,d0
	lsrl #2,d0
	movel d0,a5@(40)
	lea a5@(44),a1
	movel a1,d0
	lsrl #2,d0
	movel d0,a5@(28)
	movel a4@(12),a1@
	movel a4@(128),a1@(4)
	lea a5@(60),a0
	movel a0,d0
	lsrl #2,d0
	movel d0,a1@(8)
	lea a2@(128),a1
	movel d2,d3
	.short 0x5283	/* addql #1,d3 */
L634:
	movel a1@+,a0@+
	.short 0x5383	/* subql #1,d3 */
	bnes L634
	moveal a4@,a6
	movel a2@(192),d0
	bsrw La4e
	tstl d0
	beqs L650
	moveal d0,a1
	moveal d7,a0
	bsrw La7e
L650:
	moveal a4@(4),a6
	movel a2@(20),d0
	btst #0,d0
	beqw L688
	lea %pc@(L15d),a0
	bsrw L702
	bsrw L830
	movel a2@(188),d0
	.short 0x7200	/* moveq #0,d1 */
	moveal d7,a0
	moveal a4@(120),a1
	jsr a6@(-36)
	.short 0x197c,0x0001,0x001a	/* moveb #1,a4@(26) */
	.short 0x522c,0x001b	/* addqb #1,a4@(27) */
	bras L6a8
L688:
	lea %pc@(L16a),a0
	bsrs L702
	bsrw L830
	movel a2@(188),d0
	.short 0x7200	/* moveq #0,d1 */
	moveal d7,a0
	jsr a6@(-150)
	.short 0x197c,0x0001,0x001a	/* moveb #1,a4@(26) */
	.short 0x522c,0x001b	/* addqb #1,a4@(27) */
L6a8:
	moveml sp@+,d2-d7/a2/a5
	rts
L6ae:
	moveml d1-d3/a0-a2,sp@-
	moveal a0,a1
	.short 0x7400	/* moveq #0,d2 */
L6b6:
	tstb a1@+
	beqs L6c4
	.short 0x5282	/* addql #1,d2 */
	.short 0xb4bc,0x0000,0x00ff	/* cmpl #255,d2 */
	bcss L6b6
L6c4:
	movel d2,d0
	.short 0x5280	/* addql #1,d0 */
	.short 0x5680	/* addql #3,d0 */
	.short 0xc0bc,0xffff,0xfffc	/* andl #-4,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqs L6fa
	moveal d0,a1
	moveb d2,a1@+
	moveal sp@(12),a0
	movel d2,d3
	tstl d3
	beqs L6f2
L6ec:
	moveb a0@+,a1@+
	.short 0x5383	/* subql #1,d3 */
	bnes L6ec
L6f2:
	lsrl #2,d0
	moveml sp@+,d1-d3/a0-a2
	rts
L6fa:
	moveml sp@+,d1-d3/a0-a2
	.short 0x7000	/* moveq #0,d0 */
	rts
L702:
	moveml d0-d1/a0-a1/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
L70a:
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	beqs L716
	jsr a6@(-516)
	bras L70a
L716:
	moveml sp@+,d0-d1/a0-a1/a6
	rts
L71c:
	moveml d0-d3/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d0,d2
	.short 0x7607	/* moveq #7,d3 */
	roll #4,d2
	movel d2,d0
	.short 0xc0bc,0x0000,0x000f	/* andl #15,d0 */
	.short 0xb03c,0x000a	/* cmpb #10,d0 */
	blts L73e
	.short 0xd03c,0x0037	/* addb #55,d0 */
	bras L742
L73e:
	.short 0xd03c,0x0030	/* addb #48,d0 */
L742:
	jsr a6@(-516)
	.short 0x51cb,0xffe0	/* dbf d3,0x728 */
	moveml sp@+,d0-d3/a6
	rts
L750:
	moveml d0-d3/a0/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d0,d2
	.short 0x7603	/* moveq #3,d3 */
	roll #8,d2
	movel d2,d0
	.short 0xc0bc,0x0000,0x00ff	/* andl #255,d0 */
	tstl d0
	bnes L76c
	.short 0x702e	/* moveq #46,d0 */
L76c:
	jsr a6@(-516)
	.short 0x51cb,0xffea	/* dbf d3,0x75c */
	moveml sp@+,d0-d3/a0/a6
	rts
L77a:
	moveml d0-d5/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0xc0bc,0x0000,0xffff	/* andl #65535,d0 */
	.short 0x518f	/* subql #8,sp */
	moveal sp,a0
	.short 0x7604	/* moveq #4,d3 */
	movel d0,d2
	.short 0x84fc,0x000a	/* divuw #10,d2 */
	movel d2,d1
	swap d1
	.short 0xc2bc,0x0000,0x00ff	/* andl #255,d1 */
	.short 0xd23c,0x0030	/* addb #48,d1 */
	.short 0x1181,0x3800	/* moveb d1,a0@(0,d3:l) */
	movew d2,d0
	.short 0x51cb,0xffe4	/* dbf d3,0x78e */
	.short 0x7600	/* moveq #0,d3 */
L7ae:
	.short 0xb63c,0x0004	/* cmpb #4,d3 */
	bges L7c2
	.short 0x1030,0x3800	/* moveb a0@(0,d3:l),d0 */
	.short 0xb03c,0x0030	/* cmpb #48,d0 */
	bnes L7c2
	.short 0x5283	/* addql #1,d3 */
	bras L7ae
L7c2:
	.short 0x1030,0x3800	/* moveb a0@(0,d3:l),d0 */
	.short 0xc0bc,0x0000,0x00ff	/* andl #255,d0 */
	jsr a6@(-516)
	.short 0x5283	/* addql #1,d3 */
	.short 0xb63c,0x0005	/* cmpb #5,d3 */
	blts L7c2
	.short 0x508f	/* addql #8,sp */
	moveml sp@+,d0-d5/a6
	rts
L7e0:
	moveml d0-d2/a0/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d0,d2
	.short 0x7020	/* moveq #32,d0 */
	jsr a6@(-516)
	.short 0x7076	/* moveq #118,d0 */
	jsr a6@(-516)
	movel d2,d0
	swap d0
	.short 0xc0bc,0x0000,0xffff	/* andl #65535,d0 */
	bsrw L77a
	.short 0x702e	/* moveq #46,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-516)
	movel d2,d0
	.short 0xc0bc,0x0000,0xffff	/* andl #65535,d0 */
	bsrw L77a
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x700d	/* moveq #13,d0 */
	jsr a6@(-516)
	.short 0x700a	/* moveq #10,d0 */
	jsr a6@(-516)
	moveml sp@+,d0-d2/a0/a6
	rts
L830:
	moveml d0-d3/a0-a1/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4@(16),a0
	lea a0@(36),a0
	.short 0x7600	/* moveq #0,d3 */
	moveb a0@+,d3
	.short 0xb67c,0x001f	/* cmpw #31,d3 */
	blss L84c
	.short 0x761f	/* moveq #31,d3 */
L84c:
	.short 0x5383	/* subql #1,d3 */
	bmis L85c
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	jsr a6@(-516)
	.short 0x51cb,0xfff6	/* dbf d3,0x850 */
L85c:
	.short 0x700d	/* moveq #13,d0 */
	jsr a6@(-516)
	.short 0x700a	/* moveq #10,d0 */
	jsr a6@(-516)
	moveml sp@+,d0-d3/a0-a1/a6
	rts
L86e:
	moveml d2-d7/a2-a3,sp@-
	moveal a4@(16),a0
	movel a0@(32),d2
	movel a0@(72),d3
	movel d3,d0
	.short 0x5280	/* addql #1,d0 */
	beqw La48
	.short 0x7000	/* moveq #0,d0 */
	.short 0x303c,0x0100	/* movew #256,d0 */
	.short 0x7201	/* moveq #1,d1 */
	moveal a4@,a6
	jsr a6@(-198)
	tstl d0
	beqw La48
	moveal d0,a3
	moveal a4@(16),a0
	moveal a3,a1
	.short 0x7040	/* moveq #64,d0 */
L8a4:
	movel a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	bnes L8a4
	movel d2,d0
	bsrw La4e
	tstl d0
	beqs L8b8
	braw La3a
L8b8:
	.short 0x7800	/* moveq #0,d4 */
	movel d3,d5
L8bc:
	movel d5,d0
	bsrw L450
	tstl d0
	bnew La3a
	moveal a4@(16),a0
	.short 0x0c90,0x4c53,0x4547	/* cmpil #1280525639,a0@ */
	bnew La3a
	.short 0xd8bc,0x0000,0x01ec	/* addl #492,d4 */
	movel a0@(16),d0
	movel d0,d5
	.short 0x5280	/* addql #1,d0 */
	bnes L8bc
	tstl d4
	beqw La3a
	.short 0xb8bc,0x0010,0x0000	/* cmpl #1048576,d4 */
	bhiw La3a
	movel d4,d0
	.short 0xd0bc,0x0000,0x000c	/* addl #12,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a4@,a6
	jsr a6@(-198)
	tstl d0
	beqw La3a
	moveal d0,a2
	movel d4,d0
	.short 0x5080	/* addql #8,d0 */
	movel d0,a2@
	lea a2@(8),a0
	movel d3,d5
L91e:
	movel d5,d0
	bsrw L450
	tstl d0
	bnew La26
	moveal a4@(16),a1
	.short 0x0c91,0x4c53,0x4547	/* cmpil #1280525639,a1@ */
	bnew La26
	movel a1@(16),d5
	lea a1@(20),a1
	.short 0x707b	/* moveq #123,d0 */
L942:
	movel a1@+,a0@+
	.short 0x5380	/* subql #1,d0 */
	bnes L942
	movel d5,d0
	.short 0x5280	/* addql #1,d0 */
	bnes L91e
	.byte 0x0c,0xaa,0x00,0x00,0x03,0xf3,0x00,0x08	/* cmpil #1011,a2@(8) */
	bnew L982
	movel a2,sp@-
	.short 0x508a	/* addql #8,a2 */
	bsrw Lb64
	moveal sp@+,a2
	tstl d0
	beqw La26
	movel d0,d7
	moveal a4@,a6
	moveal a2,a1
	movel d4,d0
	.short 0xd0bc,0x0000,0x000c	/* addl #12,d0 */
	jsr a6@(-210)
	subal a2,a2
	braw L98a
L982:
	movel a2,d0
	.short 0x5880	/* addql #4,d0 */
	lsrl #2,d0
	movel d0,d7
L98a:
	moveal a4@,a6
	jsr a6@(-636)
	.short 0x703e	/* moveq #62,d0 */
	.short 0x223c,0x0005,0x0001	/* movel #327681,d1 */
	moveal a4@,a6
	jsr a6@(-198)
	tstl d0
	beqw La26
	moveal d0,a0
	clrb a0@(8)
	.short 0x43fa,0xf672	/* lea %pc@(0x1e),a1 */
	movel a1,a0@(10)
	movel d2,a0@(14)
	movel a3@(36),a0@(18)
	movel a3@(40),d5
	movel d5,a0@(22)
	movel a3@(44),a0@(26)
	movel a3@(48),a0@(30)
	movel a3@(52),a0@(34)
	movel a3@(56),a0@(38)
	movel a3@(60),a0@(42)
	movel a3@(64),a0@(46)
	movel a3@(68),a0@(50)
	movel d7,a0@(54)
	movel a3@(76),a0@(58)
	.byte 0x00,0xa8,0x00,0x00,0x00,0x80,0x00,0x16	/* oril #128,a0@(22) */
	moveal a0,a2
	bsrw Lae4
	moveml d0-d1/a0-a1/a6,sp@-
	lea %pc@(L152),a0
	bsrw L702
	movel d2,d0
	bsrw L750
	movel a2@(18),d0
	bsrw L7e0
	moveml sp@+,d0-d1/a0-a1/a6
	bras La3a
La26:
	movel a2,d0
	beqs La3a
	moveal a4@,a6
	moveal a2,a1
	movel d4,d0
	.short 0xd0bc,0x0000,0x000c	/* addl #12,d0 */
	jsr a6@(-210)
La3a:
	moveal a4@,a6
	moveal a3,a1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x303c,0x0100	/* movew #256,d0 */
	jsr a6@(-210)
La48:
	moveml sp@+,d2-d7/a2-a3
	rts
La4e:
	moveml d2/a2,sp@-
	movel d0,d2
	bsrw Lb08
	tstl d0
	beqs La76
	moveal d0,a0
	lea a0@(18),a0
	moveal a0@,a2
La64:
	movel a2@,d0
	beqs La76
	cmpl a2@(14),d2
	beqs La72
	moveal d0,a2
	bras La64
La72:
	movel a2,d0
	bras La78
La76:
	.short 0x7000	/* moveq #0,d0 */
La78:
	moveml sp@+,d2/a2
	rts
La7e:
	movel a1@(22),d1
	btst #0,d1
	beqs La8e
	movel a1@(26),a0@(4)
La8e:
	btst #1,d1
	beqs La9a
	movel a1@(30),a0@(8)
La9a:
	btst #2,d1
	beqs Laa6
	movel a1@(34),a0@(12)
Laa6:
	btst #3,d1
	beqs Lab2
	movel a1@(38),a0@(16)
Lab2:
	btst #4,d1
	beqs Labe
	movel a1@(42),a0@(20)
Labe:
	btst #5,d1
	beqs Laca
	movel a1@(46),a0@(24)
Laca:
	btst #7,d1
	beqs Lad6
	movel a1@(54),a0@(32)
Lad6:
	btst #8,d1
	beqs Lae2
	movel a1@(58),a0@(36)
Lae2:
	rts
Lae4:
	movel a6,sp@-
	bsrs Lb08
	tstl d0
	beqw Lb04
	moveal d0,a0
	lea a0@(18),a0
	moveal a4@,a6
	jsr a6@(-132)
	moveal a2,a1
	jsr a6@(-240)
	jsr a6@(-138)
Lb04:
	moveal sp@+,a6
	rts
Lb08:
	movel a4@(20),d0
	bnes Lb62
	moveal a4@,a6
	lea %pc@(L112),a1
	jsr a6@(-498)
	tstl d0
	bnes Lb5e
	.short 0x7020	/* moveq #32,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqs Lb62
	moveal d0,a0
	.short 0x117c,0x0008,0x0008	/* moveb #8,a0@(8) */
	lea %pc@(L112),a1
	movel a1,a0@(10)
	.short 0x43fa,0xf4e0	/* lea %pc@(0x1e),a1 */
	movel a1,a0@(14)
	lea a0@(18),a1
	movel a1,a1@
	.short 0x5891	/* addql #4,a1@ */
	clrl a1@(4)
	movel a1,a1@(8)
	movel a0,sp@-
	moveal a0,a1
	jsr a6@(-486)
	movel sp@+,d0
Lb5e:
	movel d0,a4@(20)
Lb62:
	rts
Lb64:
	moveml d2-d7/a2-a6,sp@-
	moveal a2,a3
	addal d4,a3
	cmpal a3,a2
	bccw Le10
	.short 0x0c92,0x0000,0x03f3	/* cmpil #1011,a2@ */
	bnew Le10
	.short 0x588a	/* addql #4,a2 */
Lb7e:
	cmpal a3,a2
	bccw Le10
	movel a2@+,d0
	tstl d0
	beqs Lb96
	lsll #2,d0
	addal d0,a2
	cmpal a3,a2
	bhiw Le10
	bras Lb7e
Lb96:
	lea a2@(12),a0
	cmpal a3,a0
	bhiw Le10
	.short 0x588a	/* addql #4,a2 */
	movel a2@+,d2
	movel a2@+,d3
	movel d3,d4
	subl d2,d4
	.short 0x5284	/* addql #1,d4 */
	tstl d4
	blew Le10
	.short 0xb8bc,0x0000,0x0040	/* cmpl #64,d4 */
	bhiw Le10
	movel d4,d0
	lsll #2,d0
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a4@,a6
	jsr a6@(-198)
	tstl d0
	beqw Le10
	moveal d0,a5
	.short 0x7a00	/* moveq #0,d5 */
Lbd6:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	.short 0xccbc,0x3fff,0xffff	/* andl #1073741823,d6 */
	movel d6,d0
	lsll #2,d0
	.short 0x5080	/* addql #8,d0 */
	.short 0xb0bc,0x0010,0x0000	/* cmpl #1048576,d0 */
	bhiw Ldde
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a4@,a6
	jsr a6@(-198)
	tstl d0
	beqw Ldde
	moveal d0,a0
	movel d6,d1
	lsll #2,d1
	.short 0x5081	/* addql #8,d1 */
	movel d1,a0@
	clrl a0@(4)
	movel d5,d0
	lsll #2,d0
	.short 0x2b88,0x0800	/* movel a0,a5@(0,d0:l) */
	.short 0x5285	/* addql #1,d5 */
	cmpl d4,d5
	bcsw Lbd6
	movel d4,d7
	.short 0x5387	/* subql #1,d7 */
	bles Lc4e
	.short 0x7a00	/* moveq #0,d5 */
Lc2c:
	movel d5,d0
	lsll #2,d0
	.short 0x2075,0x0800	/* moveal a5@(0,d0:l),a0 */
	movel d5,d0
	.short 0x5280	/* addql #1,d0 */
	lsll #2,d0
	.short 0x2275,0x0800	/* moveal a5@(0,d0:l),a1 */
	movel a1,d0
	.short 0x5880	/* addql #4,d0 */
	lsrl #2,d0
	movel d0,a0@(4)
	.short 0x5285	/* addql #1,d5 */
	cmpl d7,d5
	bcss Lc2c
Lc4e:
	.short 0x7a00	/* moveq #0,d5 */
Lc50:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d0
	.short 0x0c80,0x0000,0x03e9	/* cmpil #1001,d0 */
	beqw Lcb6
	.short 0x0c80,0x0000,0x03ea	/* cmpil #1002,d0 */
	beqw Lcb6
	.short 0x0c80,0x0000,0x03eb	/* cmpil #1003,d0 */
	beqw Lcf4
	.short 0x0c80,0x0000,0x03ec	/* cmpil #1004,d0 */
	beqw Ld1c
	.short 0x0c80,0x0000,0x03f0	/* cmpil #1008,d0 */
	beqw Ld78
	.short 0x0c80,0x0000,0x03f1	/* cmpil #1009,d0 */
	beqw Ld9c
	.short 0x0c80,0x0000,0x03e8	/* cmpil #1000,d0 */
	beqw Ld9c
	.short 0x0c80,0x0000,0x03e7	/* cmpil #999,d0 */
	beqw Ld9c
	.short 0x0c80,0x0000,0x03f2	/* cmpil #1010,d0 */
	beqw Ldb4
	braw Ldde
Lcb6:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	.short 0xccbc,0x3fff,0xffff	/* andl #1073741823,d6 */
	movel a2,d0
	movel d6,d1
	lsll #2,d1
	addl d1,d0
	cmpl a3,d0
	bhiw Ldde
	movel d5,d0
	lsll #2,d0
	.short 0x2275,0x0800	/* moveal a5@(0,d0:l),a1 */
	movel a1@,d0
	.short 0x5180	/* subql #8,d0 */
	cmpl d1,d0
	bcsw Ldde
	.short 0x5089	/* addql #8,a1 */
	tstl d6
	beqs Lcf0
Lcea:
	movel a2@+,a1@+
	.short 0x5386	/* subql #1,d6 */
	bnes Lcea
Lcf0:
	braw Lc50
Lcf4:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	.short 0xccbc,0x3fff,0xffff	/* andl #1073741823,d6 */
	movel d5,d0
	lsll #2,d0
	.short 0x2275,0x0800	/* moveal a5@(0,d0:l),a1 */
	movel a1@,d0
	.short 0x5180	/* subql #8,d0 */
	movel d6,d1
	lsll #2,d1
	cmpl d1,d0
	bcsw Ldde
	braw Lc50
Ld1c:
	movel d5,d0
	lsll #2,d0
	.short 0x2075,0x0800	/* moveal a5@(0,d0:l),a0 */
	.short 0x5088	/* addql #8,a0 */
Ld26:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	tstl d6
	beqw Lc50
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d7
	subl d2,d7
	bmiw Ldde
	cmpl d4,d7
	bccw Ldde
	movel d7,d0
	lsll #2,d0
	.short 0x2275,0x0800	/* moveal a5@(0,d0:l),a1 */
	.short 0x5089	/* addql #8,a1 */
Ld52:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d0
	movel a0@(-8),d3
	.short 0x96bc,0x0000,0x000c	/* subl #12,d3 */
	cmpl d3,d0
	bhiw Ldde
	movel a1,d1
	.short 0xd3b0,0x0800	/* addl d1,a0@(0,d0:l) */
	.short 0x5386	/* subql #1,d6 */
	bnes Ld52
	braw Ld26
Ld78:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	tstl d6
	beqw Lc50
	.short 0xccbc,0x00ff,0xffff	/* andl #16777215,d6 */
	.short 0x5286	/* addql #1,d6 */
	movel d6,d0
	lsll #2,d0
	addal d0,a2
	cmpal a3,a2
	bhiw Ldde
	bras Ld78
Ld9c:
	cmpal a3,a2
	bccw Ldde
	movel a2@+,d6
	movel d6,d0
	lsll #2,d0
	addal d0,a2
	cmpal a3,a2
	bhiw Ldde
	braw Lc50
Ldb4:
	.short 0x5285	/* addql #1,d5 */
	cmpl d4,d5
	bcsw Lc50
	moveal a5@,a0
	movel a0,d7
	.short 0x5887	/* addql #4,d7 */
	lsrl #2,d7
	movel d4,d0
	lsll #2,d0
	moveal a5,a1
	moveal a4@,a6
	jsr a6@(-210)
	moveal a4@,a6
	jsr a6@(-636)
	movel d7,d0
	moveml sp@+,d2-d7/a2-a6
	rts
Ldde:
	.short 0x7a00	/* moveq #0,d5 */
Lde0:
	cmpl d4,d5
	bccs Ldfc
	movel d5,d0
	lsll #2,d0
	.short 0x2275,0x0800	/* moveal a5@(0,d0:l),a1 */
	movel a1,d0
	beqs Ldf8
	movel a1@,d0
	moveal a4@,a6
	jsr a6@(-210)
Ldf8:
	.short 0x5285	/* addql #1,d5 */
	bras Lde0
Ldfc:
	movel d4,d0
	lsll #2,d0
	moveal a5,a1
	moveal a4@,a6
	jsr a6@(-210)
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Le10:
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Le18:
	moveb d0,d0
	.short 0x002a,0x0000,0x0008	/* orib #0,a2@(8) */
	lea %pc@(Le36),a1
	jsr a6@(-96)
	tstl d0
	beqs Le34
	moveal d0,a0
	moveal a0@(22),a0
	jsr a0@
Le34:
	rts
Le36:
	.short 0x646f	/* bccs 0xea7 */
	.short 0x732e	/* .short 0x732e */
	.short 0x6c69	/* bges 0xea5 */
	.short 0x6272	/* bhis 0xeb0 */
	.short 0x6172	/* bsrs 0xeb2 */
	.short 0x7900	/* .short 0x7900 */
	nop
	.data
