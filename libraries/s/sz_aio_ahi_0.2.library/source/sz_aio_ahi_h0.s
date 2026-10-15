	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x01,0x46,0x80,0x00
	.byte 0x09,0x00,0x00,0x00,0x02,0x54,0x00,0x00,0x02,0x67,0x00,0x00,0x00,0x1e,0x00,0x00
	.byte 0x04,0x30,0x00,0x00,0x0b,0x3e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x4e,0xa0,0x08
	.byte 0x09,0x00,0x80,0x0a,0x00,0x00,0x02,0x54,0xa0,0x0e,0x06,0x00,0x90,0x14,0x00,0x00
	.byte 0x90,0x16,0x00,0x02,0x80,0x18,0x00,0x00,0x02,0x54,0x00,0x00,0x00,0x13,0x2f,0x0d
	.byte 0x2a,0x40,0x2b,0x4e,0x00,0x24,0x2b,0x48,0x00,0x2c,0x41,0xed,0x00,0x30,0x70,0x7f
	clrl a0@+
	clrl a0@+
	.short 0x51c8,0xfffa	/* dbf d0,0x60 */
	movel a5,d0
	moveal sp@+,a5
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(34)
	bsrw L130
	movel a6,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	tstl a0@+
	beqs L9a
	.short 0x5888	/* addql #4,a0 */
	.short 0x51c9,0xfff8	/* dbf d1,0x86 */
	jsr a6@(-138)
	moveal d0,a6
L96:
	.short 0x7000	/* moveq #0,d0 */
	rts
L9a:
	jsr a6@(-138)
	moveal d0,a6
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a5
	movel a1,a0@-
	bsrw L146
	moveml sp@+,d2-d7/a2-a6
	tstl d0
	beqs L96
	movel a6,d0
	rts
	bsrs L130
	cmpal a0@+,a1
	beqs Lc6
	.short 0x5888	/* addql #4,a0 */
	.short 0x51c9,0xfff8	/* dbf d1,0xba */
	rts
Lc6:
	moveml d2-d7/a2-a6,sp@-
	moveal a0@,a4
	clrl a0@-
	bsrw L1fa
	moveml sp@+,d2-d7/a2-a6
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes Lea
	btst #3,a6@(34)
	beqs Lea
	bsrw Lec
Lea:
	rts
Lec:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(36),a6
	tstw a5@(32)
	beqw L108
	bset #3,a5@(34)
	.short 0x7000	/* moveq #0,d0 */
	bras L126
L108:
	movel a5@(44),d2
	moveal a5,a1
	jsr a6@(-252)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5,a1
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
L126:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L130:
	.short 0x2278,0x0004	/* moveal 0x4,a1 */
	moveal a1@(276),a1
	movel a1,d1
	.short 0x0241,0x0380	/* andiw #896,d1 */
	lea a6@(0x30,d1:w),a0
	.short 0x720f	/* moveq #15,d1 */
	rts
L146:
	moveal sp,a3
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x05dc	/* movel #1500,d0 */
	.short 0x223c,0x0001,0x0000	/* movel #65536,d1 */
	movel d0,d2
	jsr a6@(-198)
	tstl d0
	beqw L1f8
	movel d0,d6
	addl d2,d0
	jsr a6@(-132)
	moveal d0,sp
	.short 0xdffc,0x0000,0x0000	/* addal #0,sp */
	linkw a4,#-520
	jsr a6@(-138)
	movel a3,a4@(-4)
	movel d6,a4@(-64)
	movel a6,a4@(-40)
	lea %pc@(L1ce),a1
	.short 0x7021	/* moveq #33,d0 */
	jsr a6@(-552)
	movel d0,a4@(-48)
	beqw L23e
	lea %pc@(L1e0),a1
	.short 0x7021	/* moveq #33,d0 */
	jsr a6@(-552)
	movel d0,a4@(-52)
	beqw L236
	lea %pc@(L1c2),a1
	.short 0x7021	/* moveq #33,d0 */
	jsr a6@(-552)
	movel d0,a4@(-44)
	beqw L22e
	movel a4,a5@
	bras L1f2
L1c2:
	bccs L233
	.short 0x732e	/* .short 0x732e */
	bges L231
	bhis L23c
	bsrs L23e
	.short 0x7900	/* .short 0x7900 */
L1ce:
	bvss L23e
	.short 0x7475	/* moveq #117,d2 */
	bvss L248
	bvss L245
	bgts L206
	bges L243
	bhis L24e
	bsrs L250
	.short 0x7900	/* .short 0x7900 */
L1e0:
	beqs L254
	bsrs L254
	bvcs L24f
	blss L25b
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L1f2:
	.byte 0x4e,0xf9	/* orib #-7,d0 */
	.short 0x0000,0x0296	/* orib #-106,d0 */
L1f8:
	rts
L1fa:
	.short 0x4eb9,0x0000,0x0bcc	/* jsr 0xbcc */
	.short 0x4eb9,0x0000,0x01f8	/* jsr 0x1f8 */
L206:
	movel sp,a4@(-4)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4@(-20),a2
	movel a2,d0
	beqs L226
L216:
	moveal a2,a1
	movel a2@(4),d0
	moveal a2@,a2
	jsr a6@(-210)
	movel a2,d0
	bnes L216
L226:
	moveal a4@(-44),a1
	jsr a6@(-414)
L22e:
	.byte 0x22,0x6c,0xff
L231:
	.byte 0xcc	/* moveal a4@(-52),a1 */
	.byte 0x4e
L233:
	.byte 0xae,0xfe,0x62	/* jsr a6@(-414) */
L236:
	moveal a4@(-48),a1
	.byte 0x4e,0xae
L23c:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
L23e:
	.byte 0x20,0x3c,0x00,0x00,0x05
L243:
	.byte 0xdc	/* movel #1500,d0 */
	.byte 0x22
L245:
	.byte 0x6c,0xff,0xc0	/* moveal a4@(-64),a1 */
L248:
	moveal a4@(-4),sp
	.byte 0x4e,0xae
L24e:
	.byte 0xff
L24f:
	.byte 0x2e	/* jsr a6@(-210) */
L250:
	.short 0x7000	/* moveq #0,d0 */
	rts
L254:
	.short 0x737a	/* .short 0x737a */
	.short 0x5f61	/* subqw #7,a1@- */
	bvss L2c9
	.byte 0x5f
L25b:
	.byte 0x61	/* subqw #7,a1@- */
	bvcs L2c7
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x73,0x7a,0x5f,0x61,0x69,0x6f,0x5f	/* oriw #31327,a3@(6f5f)@(0) */
	bsrs L2d8
	bvss L292
	.short 0x5630,0x2e32	/* addqb #3,a0@(32,d2:l:8) */
	movel a0@-,d0
	.short 0x3039,0x2e30,0x332e	/* movew 0x2e30332e,d0 */
	movew a0@(0x30,d3:w),d1
	movel a0@-,d0
	bhis L2ff
	moveal a2@,a0
	bsrs L2f3
	bgts L2f1
	.short 0x7220	/* moveq #32,d1 */
	.short 0x4dfc	/* .short 0x4dfc */
	bges L2fe
L292:
	bcss L306
	.short 0x0000,0x4eb9	/* orib #-71,d0 */
	.short 0x0000,0x0b3a	/* orib #58,d0 */
	.short 0x4eb9,0x0000,0x02aa	/* jsr 0x2aa */
	moveal a4@(-4),sp
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	linkw a5,#0
	.short 0x7000	/* moveq #0,d0 */
	unlk a5
	rts
	linkw a5,#0
	lea sp@(-8),sp
	.short 0x41f9,0x0000,0x0b29	/* lea 0xb29,a0 */
	movel a0,d0
	.byte 0x2f,0x40,0x00
L2c7:
	.byte 0x04	/* movel d0,sp@(4) */
	.byte 0x70
L2c9:
	.byte 0x27	/* moveq #39,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-40),a6
	moveml sp@+,d0/a1
	.byte 0x4e,0xae
L2d8:
	.byte 0xfd,0xd8	/* jsr a6@(-552) */
	movel d0,a4@(-516)
	tstl d0
	bnew L2ea
	.short 0x7013	/* moveq #19,d0 */
	braw L2f2
L2ea:
	movel a5@(8),a4@(-520)
	.byte 0x70
L2f1:
	.byte 0x00	/* moveq #0,d0 */
L2f2:
	.byte 0x4e
L2f3:
	.byte 0x5d	/* unlk a5 */
	rts
	linkw a5,#0
	movel a4@(-516),d0
L2fe:
	.byte 0x67
L2ff:
	.byte 0x00,0x00,0x0e	/* beqw 0x30e */
	moveal a4@(-516),a1
L306:
	moveal a4@(-40),a6
	jsr a6@(-414)
L30e:
	.short 0x7000	/* moveq #0,d0 */
	unlk a5
	rts
	linkw a5,#-52
	moveml d3-d7,sp@-
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-32)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-28)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-4)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-12)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-36)
	.short 0x70ff	/* moveq #-1,d0 */
	movel d0,a5@(-48)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-24)
	movel a4@(-80),sp@-
	movel a4@(-76),sp@-
	movel a4@(-88),sp@-
	movel sp,a4@(-80)
	lea %pc@(L968),a0
	movel a0,a4@(-76)
	movel a5,a4@(-88)
	lea sp@(-16),sp
	movel a5@(16),d0
	movel d0,sp@(12)
	movel a5@(20),d0
	movel d0,sp@(8)
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,sp@(4)
	lea a5@(-52),a0
	movel a0,d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-520),a6
	moveml sp@+,d0-d1/a0-a1
	jsr a6@(-120)
	movel d0,a5@(-24)
	tstl d0
	bnew L3b0
	.short 0x4878,0x0007	/* pea 0x7 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L3b0:
	moveal a4@(-40),a6
	jsr a6@(-666)
	movel d0,a5@(-36)
	tstl d0
	bnew L3d0
	.short 0x4878,0x0017	/* pea 0x17 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L3d0:
	lea sp@(-8),sp
	movel a5@(-36),d0
	movel d0,sp@(4)
	.short 0x7050	/* moveq #80,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-40),a6
	moveml sp@+,d0/a0
	jsr a6@(-654)
	movel d0,a5@(-28)
	movel d0,a5@(-32)
	tstl d0
	bnew L40a
	.short 0x4878,0x001e	/* pea 0x1e */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L40a:
	.short 0x7004	/* moveq #4,d0 */
	moveal a5@(-32),a0
	movew d0,a0@(48)
	lea sp@(-16),sp
	.short 0x41f9,0x0000,0x0b1e	/* lea 0xb1e,a0 */
	movel a0,d0
	movel d0,sp@(8)
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	movel a5@(-32),d0
	movel d0,sp@(12)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,sp@(4)
	moveal a4@(-40),a6
	moveml sp@+,d0-d1/a0-a1
	jsr a6@(-444)
	movel d0,a5@(-48)
	tstl d0
	beqw L45c
	.short 0x4878,0x0008	/* pea 0x8 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L45c:
	lea sp@(-8),sp
	.short 0x7050	/* moveq #80,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	.short 0x7000	/* moveq #0,d0 */
	movel d0,sp@(4)
	moveal a4@(-40),a6
	moveml sp@+,d0-d1
	jsr a6@(-684)
	movel d0,a5@(-4)
	tstl d0
	bnew L490
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L490:
	.short 0x707f	/* moveq #127,d0 */
	moveal a5@(-32),a0
	lea a0@,a0
	lea a0@,a0
	lea a0@,a0
	moveb d0,a0@(9)
	.short 0x7003	/* moveq #3,d0 */
	moveal a5@(-32),a0
	lea a0@,a0
	movew d0,a0@(28)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-32),a0
	lea a0@,a0
	movel d0,a0@(44)
	moveal a5@(24),a0
	movel a0@(16),d0
	.short 0x0c80,0x0000,0x0001	/* cmpil #1,d0 */
	bnew L4d0
	.short 0x7001	/* moveq #1,d0 */
	braw L4d2
L4d0:
	.short 0x7003	/* moveq #3,d0 */
L4d2:
	moveal a5@(-32),a0
	movel d0,a0@(60)
	moveal a5@(24),a0
	movel a0@(8),d0
	moveal a5@(-32),a0
	movel d0,a0@(64)
	.short 0x2f3c,0x0001,0x0000	/* movel #65536,sp@- */
	moveal a5@(24),a0
	movel a0@(12),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	movel d0,sp@-
	.short 0x4878,0x0064	/* pea 0x64 */
	.short 0x4eb9,0x0000,0x0bf6	/* jsr 0xbf6 */
	lea sp@(8),sp
	moveal a5@(-32),a0
	movel d0,a0@(68)
	.short 0x203c,0x0000,0x8000	/* movel #32768,d0 */
	moveal a5@(-32),a0
	movel d0,a0@(72)
	lea sp@(-12),sp
	movel a5@(-32),d0
	movel d0,sp@(4)
	movel a5@(-4),d0
	movel d0,sp@(8)
	.short 0x7050	/* moveq #80,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-40),a6
	moveml sp@+,d0/a0-a1
	jsr a6@(-624)
	movel a5@(28),d0
	.short 0x0c80,0x0000,0x0001	/* cmpil #1,d0 */
	bnew L66c
	.short 0x7000	/* moveq #0,d0 */
	cmpl a5@(32),d0
	bnew L588
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,sp@-
	.short 0x4878,0x0008	/* pea 0x8 */
	.short 0x4eb9,0x0000,0x0bf6	/* jsr 0xbf6 */
	lea sp@(8),sp
	movel d0,a5@(-40)
	braw L5f2
L588:
	.short 0x7001	/* moveq #1,d0 */
	cmpl a5@(32),d0
	bnew L5b2
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,sp@-
	.short 0x4878,0x0004	/* pea 0x4 */
	.short 0x4eb9,0x0000,0x0bf6	/* jsr 0xbf6 */
	lea sp@(8),sp
	movel d0,a5@(-40)
	braw L5f2
L5b2:
	.short 0x7002	/* moveq #2,d0 */
	cmpl a5@(32),d0
	bnew L5dc
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,sp@-
	.short 0x4878,0x0002	/* pea 0x2 */
	.short 0x4eb9,0x0000,0x0bf6	/* jsr 0xbf6 */
	lea sp@(8),sp
	movel d0,a5@(-40)
	braw L5f2
L5dc:
	.short 0x7003	/* moveq #3,d0 */
	cmpl a5@(32),d0
	bnew L5f2
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,a5@(-40)
L5f2:
	movel a5@(-40),sp@-
	.short 0x4eb9,0x0000,0x0c64	/* jsr 0xc64 */
	lea sp@(4),sp
	tstl d0
	beqw L60a
	.short 0x53ad,0xffd8	/* subql #1,a5@(-40) */
L60a:
	moveml d3,sp@-
	lea sp@(-12),sp
	movel a5@(36),d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a5@(24),a0
	movel a0@,d0
	movel d0,sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	movel d0,sp@(4)
	.short 0x70ff	/* moveq #-1,d0 */
	movel d0,sp@(8)
	moveal a4@(-44),a6
	moveml sp@+,d1-d3
	jsr a6@(-66)
	moveml sp@+,d3
	.short 0x0c80,0xffff,0xffff	/* cmpil #-1,d0 */
	bnew L668
	.short 0x4878,0x0023	/* pea 0x23 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L668:
	braw L69e
L66c:
	moveal a5@(24),a0
	movel a0@(8),d0
	movel d0,sp@-
	.short 0x4878,0x0008	/* pea 0x8 */
	.short 0x4eb9,0x0000,0x0bf6	/* jsr 0xbf6 */
	lea sp@(8),sp
	movel d0,a5@(-40)
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0c64	/* jsr 0xc64 */
	lea sp@(4),sp
	tstl d0
	beqw L69e
	.short 0x53ad,0xffd8	/* subql #1,a5@(-40) */
L69e:
	moveal a5@(24),a0
	movel a0@,d0
	subl a5@(-40),d0
	movel d0,a5@(-52)
	moveal a5@(24),a0
	movel a0@(4),d0
	movel d0,a5@(-20)
	movel a5@(-40),a5@(-44)
L6be:
	movel a5@(-20),d0
	cmpl a5@(-40),d0
	blew L6da
	movel a5@(-20),d0
	subl a5@(-40),d0
	movel d0,a5@(-20)
	braw L6e6
L6da:
	movel a5@(-20),a5@(-44)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-20)
L6e6:
	movel a5@(-52),d0
	addl a5@(-40),d0
	movel d0,a5@(-52)
	movel a5@(-24),d0
	moveal a4@(-520),a6
	jsr a6@(-126)
	movel a5@(28),d0
	.short 0x0c80,0x0000,0x0001	/* cmpil #1,d0 */
	bnew L7c8
	moveml d3,sp@-
	lea sp@(-12),sp
	movel a5@(36),d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	movel a5@(12),d0
	movel d0,sp@(4)
	movel a5@(-44),sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	movel d0,sp@(8)
	moveal a4@(-44),a6
	moveml sp@+,d1-d3
	jsr a6@(-42)
	moveml sp@+,d3
	movel d0,sp@-
	movel a5@(-44),sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	movel d0,d1
	movel sp@+,d0
	cmpl d1,d0
	beqw L782
	.short 0x4878,0x0002	/* pea 0x2 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L782:
	movel a5@(12),d0
	moveal a5@(-32),a0
	lea a0@,a0
	movel d0,a0@(40)
	movel a5@(-44),sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	moveal a5@(-32),a0
	lea a0@,a0
	movel d0,a0@(36)
	movel a5@(12),a5@(-8)
	movel a5@(8),a5@(12)
	movel a5@(-8),a5@(8)
	braw L818
L7c8:
	movel a5@(40),d0
	movel d0,sp@-
	movel a5@(-52),sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	movel d0,d1
	movel sp@+,d0
	addl d1,d0
	moveal a5@(-32),a0
	lea a0@,a0
	movel d0,a0@(40)
	movel a5@(-44),sp@-
	moveal a5@(24),a0
	movel a0@(20),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0bce	/* jsr 0xbce */
	lea sp@(8),sp
	moveal a5@(-32),a0
	lea a0@,a0
	movel d0,a0@(36)
L818:
	movel a5@(-12),d0
	moveal a5@(-32),a0
	movel d0,a0@(76)
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-462)
	movel a5@(-12),d0
	beqw L8f6
	lea sp@(-4),sp
	.short 0x4878,0x0001	/* pea 0x1 */
	moveal a5@(-24),a0
	moveal a0@(20),a0
	moveal a0@(86),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(15),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0c74	/* jsr 0xc74 */
	lea sp@(8),sp
	movel d0,sp@-
	.short 0x4878,0x0001	/* pea 0x1 */
	moveal a5@(-36),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(15),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0c74	/* jsr 0xc74 */
	lea sp@(8),sp
	movel d0,d1
	movel sp@+,d0
	orl d1,d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-40),a6
	moveml sp@+,d0
	jsr a6@(-318)
	movel d0,a5@(-16)
	movel a5@(-16),d0
	movel d0,sp@-
	.short 0x4878,0x0001	/* pea 0x1 */
	moveal a5@(-24),a0
	moveal a0@(20),a0
	moveal a0@(86),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(15),d0
	movel d0,sp@-
	.short 0x4eb9,0x0000,0x0c74	/* jsr 0xc74 */
	lea sp@(8),sp
	movel d0,d1
	movel sp@+,d0
	andl d1,d0
	tstl d0
	beqw L8d6
	.short 0x4878,0x0034	/* pea 0x34 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L8d6:
	moveal a5@(-12),a1
	moveal a4@(-40),a6
	jsr a6@(-474)
	tstl d0
	beqw L8f6
	.short 0x4878,0x0034	/* pea 0x34 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L8f6:
	movel a5@(-44),d0
	cmpl a5@(-40),d0
	sne d0
	extw d0
	extl d0
	movel d0,sp@-
	movel a5@(-20),d0
	.short 0x0c80,0x0000,0x0000	/* cmpil #0,d0 */
	seq d0
	extw d0
	extl d0
	movel d0,d1
	movel sp@+,d0
	orl d1,d0
	tstl d0
	beqw L93c
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-474)
	.short 0x4878,0x0034	/* pea 0x34 */
	.short 0x4eb9,0x0000,0x0c80	/* jsr 0xc80 */
	lea sp@(4),sp
L93c:
	movel a5@(-32),a5@(-12)
	movel a5@(-32),a5@(-8)
	movel a5@(-4),a5@(-32)
	movel a5@(-8),a5@(-4)
	braw L6be
	movel sp@+,a4@(-88)
	movel sp@+,a4@(-76)
	movel sp@+,a4@(-80)
	clrl a4@(-84)
L968:
	movel a4@(-84),d0
	.short 0x0c80,0x0000,0x0034	/* cmpil #52,d0 */
	bnew L9ae
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-480)
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-474)
	movel a5@(-12),d0
	beqw L9ae
	moveal a5@(-4),a1
	moveal a4@(-40),a6
	jsr a6@(-480)
	moveal a5@(-4),a1
	moveal a4@(-40),a6
	jsr a6@(-474)
L9ae:
	movel a4@(-84),d0
	.short 0x0c80,0x0000,0x0002	/* cmpil #2,d0 */
	bnew L9d4
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-480)
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-474)
L9d4:
	movel a5@(-28),d0
	cmpl a5@(-32),d0
	beqw L9f2
	movel a5@(-32),a5@(-8)
	movel a5@(-4),a5@(-32)
	movel a5@(-8),a5@(-4)
L9f2:
	moveal a5@(-36),a0
	moveal a4@(-40),a6
	jsr a6@(-372)
	tstl d0
	bnew L9f2
	movel a5@(-24),d0
	moveal a4@(-520),a6
	jsr a6@(-132)
	movel a5@(-48),d0
	bnew La24
	moveal a5@(-32),a1
	moveal a4@(-40),a6
	jsr a6@(-450)
La24:
	movel a5@(-4),d0
	beqw La38
	moveal a5@(-4),a1
	moveal a4@(-40),a6
	jsr a6@(-690)
La38:
	movel a5@(-32),d0
	beqw La4c
	moveal a5@(-32),a0
	moveal a4@(-40),a6
	jsr a6@(-660)
La4c:
	movel a5@(-36),d0
	beqw La60
	moveal a5@(-36),a0
	moveal a4@(-40),a6
	jsr a6@(-672)
La60:
	.short 0x7017	/* moveq #23,d0 */
	cmpl a4@(-84),d0
	bnew La78
	.short 0x7017	/* moveq #23,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
La78:
	.short 0x701e	/* moveq #30,d0 */
	cmpl a4@(-84),d0
	bnew La90
	.short 0x701e	/* moveq #30,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
La90:
	.short 0x7008	/* moveq #8,d0 */
	cmpl a4@(-84),d0
	bnew Laa8
	.short 0x7008	/* moveq #8,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
Laa8:
	.short 0x7023	/* moveq #35,d0 */
	cmpl a4@(-84),d0
	bnew Lac0
	.short 0x7023	/* moveq #35,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
Lac0:
	.short 0x7001	/* moveq #1,d0 */
	cmpl a4@(-84),d0
	bnew Lad8
	.short 0x7001	/* moveq #1,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
Lad8:
	.short 0x7002	/* moveq #2,d0 */
	cmpl a4@(-84),d0
	bnew Laf0
	.short 0x7002	/* moveq #2,d0 */
	moveal a4@(-520),a6
	jsr a6@(-102)
	braw Lb14
Laf0:
	.short 0x7034	/* moveq #52,d0 */
	cmpl a4@(-84),d0
	bnew Lb04
	.short 0x7000	/* moveq #0,d0 */
	braw Lb16
	braw Lb14
Lb04:
	.short 0x7000	/* moveq #0,d0 */
	cmpl a4@(-84),d0
	bnew Lb14
	.short 0x7000	/* moveq #0,d0 */
	braw Lb16
Lb14:
	.short 0x7007	/* moveq #7,d0 */
Lb16:
	moveml sp@+,d3-d7
	unlk a5
	rts
	bsrs Lb88
	bvss Lb50
	bccs Lb89
	.short 0x7669	/* moveq #105,d3 */
	blss Lb8d
	.short 0x0067,0x6164	/* oriw #24932,sp@- */
	.short 0x746f	/* moveq #111,d2 */
	bles Lb9c
	.short 0x732e	/* .short 0x732e */
	bges Lb9d
	bhis Lba8
	bsrs Lbaa
	.short 0x7900	/* .short 0x7900 */
	.short 0x74ff	/* moveq #-1,d2 */
	rts
	.short 0x0000,0x006e	/* orib #110,d0 */
	.short 0x0000,0x00b8	/* orib #-72,d0 */
	.short 0x0000,0x00ec	/* orib #-20,d0 */
	.short 0x0000,0x012c	/* orib #44,d0 */
	.byte 0x00,0x00
Lb50:
	.byte 0x0b,0x84	/* orib #-124,d0 */
	.short 0x0000,0x0b9c	/* orib #-100,d0 */
	.short 0x0000,0x0bb0	/* orib #-80,d0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
Lb5e:
	.short 0x2278,0x0004	/* moveal 0x4,a1 */
	moveal a1@(276),a1
	movel a1,d1
	.short 0x0241,0x0380	/* andiw #896,d1 */
	lea a6@(0x30,d1:w),a0
	.short 0x720f	/* moveq #15,d1 */
	cmpal a0@+,a1
	beqs Lb80
	.short 0x5888	/* addql #4,a0 */
	.short 0x51c9,0xfff8	/* dbf d1,0xb72 */
	subal a4,a4
	rts
Lb80:
	moveal a0@+,a4
	rts
	moveml d2/a2-a6,sp@-
Lb88:
	.byte 0x2f
Lb89:
	.byte 0x00	/* movel d0,sp@- */
	.byte 0x61,0x00,0xff
Lb8d:
	.byte 0xd2	/* bsrw 0xb5e */
	.short 0x4eb9,0x0000,0x02b4	/* jsr 0x2b4 */
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d2/a2-a6
	rts
Lb9c:
	.byte 0x48
Lb9d:
	.byte 0xe7,0x20,0x3e	/* moveml d2/a2-a6,sp@- */
	bsrw Lb5e
	.byte 0x4e,0xb9,0x00,0x00
Lba8:
	.byte 0x02,0xf6	/* jsr 0x2f6 */
Lbaa:
	moveml sp@+,d2/a2-a6
	rts
	moveml d2/a2-a6,sp@-
	moveml d0-d4/a0-a3,sp@-
	bsrw Lb5e
	.short 0x4eb9,0x0000,0x0314	/* jsr 0x314 */
	lea sp@(36),sp
	moveml sp@+,d2/a2-a6
	rts
	rts
	moveal d3,a3
	movel sp@(4),d1
	movel sp@(8),d0
	movel d0,d2
	movel d0,d3
	.short 0xc0c1	/* muluw d1,d0 */
	swap d3
	.short 0xc6c1	/* muluw d1,d3 */
	swap d3
	clrw d3
	addl d3,d0
	swap d1
	.short 0xc4c1	/* muluw d1,d2 */
	swap d2
	clrw d2
	addl d2,d0
	movel a3,d3
	rts
	movel sp@(8),d0
	movel sp@(4),d1
	tstl d0
	bmis Lc0e
	tstl d1
	bpls Lc16
	negl d1
Lc08:
	bsrs Lc16
	negl d0
	rts
Lc0e:
	negl d0
	tstl d1
	bpls Lc08
	negl d1
Lc16:
	swap d1
	tstw d1
	bnes Lc3c
	movel d3,sp@-
	swap d1
	movew d1,d3
	movew d0,d2
	clrw d0
	swap d0
	.short 0x80c3	/* divuw d3,d0 */
	movel d0,d1
	swap d0
	movew d2,d1
	.short 0x82c3	/* divuw d3,d1 */
	movew d1,d0
	clrw d1
	swap d1
	movel sp@+,d3
	rts
Lc3c:
	swap d1
	moveml d3-d4,sp@-
	.short 0x741f	/* moveq #31,d2 */
	.short 0x7600	/* moveq #0,d3 */
	.short 0x7800	/* moveq #0,d4 */
	asll #1,d3
	asll #1,d0
	roxll #1,d4
	cmpl d1,d4
	bcss Lc56
	subl d1,d4
	.short 0x5283	/* addql #1,d3 */
Lc56:
	.short 0x51ca,0xfff0	/* dbf d2,0xc48 */
	movel d4,d1
	movel d3,d0
	moveml sp@+,d3-d4
	rts
	btst #0,sp@(7)
	bnes Lc70
	.short 0x7000	/* moveq #0,d0 */
	rts
Lc70:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	movel sp@(8),d0
	movel sp@(4),d1
	asll d1,d0
	rts
	movel sp@(4),a4@(-84)
	movel a4@(-76),d0
	beqs Lca4
	moveal d0,a0
	moveal a4@(-80),sp
	moveal a4@(-88),a5
	movel sp@+,a4@(-88)
	movel sp@+,a4@(-76)
	movel sp@+,a4@(-80)
	jmp a0@
Lca4:
	moveal a4@(-24),a0
	.byte 0x4e,0xd0,0x00,0x00	/* jmp a0@ */
