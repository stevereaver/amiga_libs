	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x01,0x46,0x80,0x06
	.byte 0x09,0x00,0x00,0x00,0x02,0x4e,0x00,0x00,0x02,0x66,0x00,0x00,0x00,0x1e,0x00,0x00
	.byte 0x04,0x30,0x00,0x00,0x0c,0x2e,0x00,0x00,0x00,0x2e,0x00,0x00,0x00,0x4e,0xa0,0x08
	.byte 0x09,0x00,0x80,0x0a,0x00,0x00,0x02,0x4e,0xa0,0x0e,0x06,0x00,0x90,0x14,0x00,0x06
	.byte 0x90,0x16,0x00,0x00,0x80,0x18,0x00,0x00,0x02,0x4e,0x00,0x00,0x00,0x18,0x2f,0x0d
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
	linkw a4,#-516
	jsr a6@(-138)
	movel a3,a4@(-4)
	movel d6,a4@(-64)
	movel a6,a4@(-40)
	lea %pc@(L1ce),a1
	.short 0x7025	/* moveq #37,d0 */
	jsr a6@(-552)
	movel d0,a4@(-48)
	beqw L238
	lea %pc@(L1e0),a1
	.short 0x7021	/* moveq #33,d0 */
	jsr a6@(-552)
	movel d0,a4@(-52)
	beqw L230
	lea %pc@(L1c2),a1
	.short 0x7021	/* moveq #33,d0 */
	jsr a6@(-552)
	movel d0,a4@(-44)
	beqw L228
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
	.short 0x0000,0x0282	/* orib #-126,d0 */
L1f8:
	rts
L1fa:
	.short 0x4eb9,0x0000,0x0cbc	/* jsr 0xcbc */
	movel sp,a4@(-4)
	.byte 0x2c,0x78
L206:
	.byte 0x00,0x04	/* moveal 0x4,a6 */
	moveal a4@(-20),a2
	movel a2,d0
	beqs L220
L210:
	moveal a2,a1
	movel a2@(4),d0
	moveal a2@,a2
	jsr a6@(-210)
	movel a2,d0
	bnes L210
L220:
	moveal a4@(-44),a1
	jsr a6@(-414)
L228:
	moveal a4@(-52),a1
	jsr a6@(-414)
L230:
	.byte 0x22
L231:
	.byte 0x6c,0xff
L233:
	.byte 0xd0	/* moveal a4@(-48),a1 */
	jsr a6@(-414)
L238:
	.byte 0x20,0x3c,0x00,0x00
L23c:
	.byte 0x05,0xdc	/* movel #1500,d0 */
L23e:
	moveal a4@(-64),a1
	.byte 0x2e
L243:
	.byte 0x6c,0xff
L245:
	.byte 0xfc	/* moveal a4@(-4),sp */
	.byte 0x4e,0xae
L248:
	.byte 0xff,0x2e	/* jsr a6@(-210) */
	.short 0x7000	/* moveq #0,d0 */
	rts
L24e:
	.byte 0x61
L24f:
	.byte 0x6d	/* bsrs 0x2bd */
L250:
	bvss L2b9
	bsrs L2c1
L254:
	bcss L2ca
	bsrs L2be
	bles L2cc
	.byte 0x6d
L25b:
	.byte 0x61	/* blts 0x2bd */
	.short 0x742e	/* moveq #46,d2 */
	bges L2c9
	bhis L2d4
	bsrs L2d6
	.short 0x7900	/* .short 0x7900 */
	.short 0x416d	/* .short 0x416d */
	bvss L2d1
	bsrs L2b9
	bcss L2e2
	bsrs L2b6
	bles L2e4
	blts L2d5
	.short 0x7420	/* moveq #32,d2 */
	.short 0x414d	/* .short 0x414d */
	notb a0@(29805)
	movel a0@-,a4@-
	movew a6@(12288),d3
	bsrw Lc2a
	bsrw La86
	moveal a4@(-4),sp
	.short 0x70ff	/* moveq #-1,d0 */
	rts
L292:
	linkw a5,#-16
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-16)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-12)
	lea sp@(-8),sp
	.short 0x203c,0x0000,0x0094	/* movel #148,d0 */
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	.short 0x203c,0x0001,0x0001	/* movel #65537,d0 */
L2b6:
	.byte 0x2f,0x40,0x00
L2b9:
	.byte 0x04	/* movel d0,sp@(4) */
	.byte 0x2c,0x6c,0xff
L2bd:
	.byte 0xd8	/* moveal a4@(-40),a6 */
L2be:
	.byte 0x4c,0xdf,0x00
L2c1:
	.byte 0x03	/* moveml sp@+,d0-d1 */
	jsr a6@(-684)
	.byte 0x2b,0x40,0xff
L2c9:
	.byte 0xf0	/* movel d0,a5@(-16) */
L2ca:
	tstl d0
L2cc:
	beqw L9c4
	.byte 0x20
L2d1:
	.byte 0x2d,0x00,0x0c	/* movel a5@(12),d0 */
L2d4:
	.byte 0x20
L2d5:
	.byte 0x6d
L2d6:
	.byte 0xff,0xf0	/* moveal a5@(-16),a0 */
	movel d0,a0@
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	.byte 0x21,0x40
L2e2:
	.byte 0x00,0x24	/* movel d0,a0@(36) */
L2e4:
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(44)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(40)
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(48)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(52)
	.short 0x7032	/* moveq #50,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(100)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(104)
	.short 0x7001	/* moveq #1,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(56)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(64)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(60)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(68)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(80)
	.short 0x7001	/* moveq #1,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(96)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(32)
	.short 0x7048	/* moveq #72,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(116)
	.short 0x7048	/* moveq #72,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(120)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(92)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(124)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(108)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(128)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-16),a0
	movel d0,a0@(144)
	.short 0x7001	/* moveq #1,d0 */
	cmpl a5@(12),d0
	bnew L4fe
	.short 0x7028	/* moveq #40,d0 */
	.short 0x223c,0x0001,0x0000	/* movel #65536,d1 */
	moveal a4@(-40),a6
	jsr a6@(-684)
	movel d0,a5@(-8)
	tstl d0
	beqw L4f4
	moveal a5@(-4),a0
	movel a0@(50),d0
	moveal a5@(-8),a0
	movel d0,a0@
	moveal a5@(-4),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(54),d0
	moveal a5@(-8),a0
	movel d0,a0@(4)
	moveal a5@(-4),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(55),d0
	moveal a5@(-8),a0
	movel d0,a0@(8)
	moveal a5@(-4),a0
	movew a0@(8),d0
	extl d0
	moveal a5@(-4),a0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(56),d1
	subl d1,d0
	moveal a5@(-4),a0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(54),d1
	subl d1,d0
	.short 0x5380	/* subql #1,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(12)
	moveal a5@(-4),a0
	movew a0@(10),d0
	extl d0
	moveal a5@(-4),a0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(57),d1
	subl d1,d0
	moveal a5@(-4),a0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@(55),d1
	subl d1,d0
	.short 0x5380	/* subql #1,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(16)
	moveal a5@(8),a0
	movel a0@(4),d0
	moveal a5@(-8),a0
	movel d0,a0@(20)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(24)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(28)
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(32)
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(36)
	lea %pc@(Lc09),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L4de
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(-8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L4e4
L4de:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L4e4:
	moveal a5@(-8),a1
	moveal a4@(-40),a6
	jsr a6@(-690)
	braw L4fa
L4f4:
	.short 0x700f	/* moveq #15,d0 */
	movel d0,a5@(-12)
L4fa:
	braw L980
L4fe:
	.short 0x7002	/* moveq #2,d0 */
	cmpl a5@(12),d0
	bnew L54e
	lea %pc@(Lbe8),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L544
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L54a
L544:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L54a:
	braw L980
L54e:
	.short 0x7003	/* moveq #3,d0 */
	cmpl a5@(12),d0
	bnew L59e
	lea %pc@(Lbc8),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L594
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L59a
L594:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L59a:
	braw L980
L59e:
	.short 0x7004	/* moveq #4,d0 */
	cmpl a5@(12),d0
	bnew L6aa
	.short 0x7028	/* moveq #40,d0 */
	.short 0x223c,0x0001,0x0000	/* movel #65536,d1 */
	moveal a4@(-40),a6
	jsr a6@(-684)
	movel d0,a5@(-8)
	tstl d0
	beqw L6a0
	moveal a5@(8),a0
	movel a0@,d0
	moveal a5@(-8),a0
	movel d0,a0@
	moveal a5@(8),a0
	movel a0@(4),d0
	moveal a5@(-8),a0
	movel d0,a0@(4)
	moveal a5@(8),a0
	movel a0@(8),d0
	moveal a5@(-8),a0
	movel d0,a0@(8)
	moveal a5@(8),a0
	movel a0@(12),d0
	moveal a5@(-8),a0
	movel d0,a0@(12)
	moveal a5@(8),a0
	movel a0@(16),d0
	moveal a5@(-8),a0
	movel d0,a0@(16)
	moveal a5@(8),a0
	movel a0@(20),d0
	moveal a5@(-8),a0
	movel d0,a0@(20)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(24)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(28)
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(32)
	.short 0x203c,0x0000,0x7fff	/* movel #32767,d0 */
	moveal a5@(-8),a0
	movel d0,a0@(36)
	lea %pc@(Lba7),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L68a
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(-8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L690
L68a:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L690:
	moveal a5@(-8),a1
	moveal a4@(-40),a6
	jsr a6@(-690)
	braw L6a6
L6a0:
	.short 0x700f	/* moveq #15,d0 */
	movel d0,a5@(-12)
L6a6:
	braw L980
L6aa:
	.short 0x7005	/* moveq #5,d0 */
	cmpl a5@(12),d0
	bnew L6fa
	lea %pc@(Lb88),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L6f0
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L6f6
L6f0:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L6f6:
	braw L980
L6fa:
	.short 0x7006	/* moveq #6,d0 */
	cmpl a5@(12),d0
	bnew L74a
	lea %pc@(Lb69),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L740
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L746
L740:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L746:
	braw L980
L74a:
	.short 0x7007	/* moveq #7,d0 */
	cmpl a5@(12),d0
	bnew L79a
	lea %pc@(Lb4a),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L790
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L796
L790:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L796:
	braw L980
L79a:
	.short 0x7008	/* moveq #8,d0 */
	cmpl a5@(12),d0
	bnew L7ea
	lea %pc@(Lb2c),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L7e0
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L7e6
L7e0:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L7e6:
	braw L980
L7ea:
	.short 0x7009	/* moveq #9,d0 */
	cmpl a5@(12),d0
	bnew L83a
	lea %pc@(Lb0c),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L830
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L836
L830:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L836:
	braw L980
L83a:
	.short 0x700a	/* moveq #10,d0 */
	cmpl a5@(12),d0
	bnew L88a
	lea %pc@(Laec),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L880
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L886
L880:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L886:
	braw L980
L88a:
	.short 0x700b	/* moveq #11,d0 */
	cmpl a5@(12),d0
	bnew L8da
	lea %pc@(Lace),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L8d0
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L8d6
L8d0:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L8d6:
	braw L980
L8da:
	.short 0x700c	/* moveq #12,d0 */
	cmpl a5@(12),d0
	bnew L92a
	lea %pc@(Laaf),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L920
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L926
L920:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L926:
	braw L980
L92a:
	.short 0x700d	/* moveq #13,d0 */
	cmpl a5@(12),d0
	bnew L97a
	lea %pc@(La90),a1
	.short 0x7000	/* moveq #0,d0 */
	moveal a4@(-40),a6
	jsr a6@(-552)
	movel d0,a4@(-516)
	tstl d0
	beqw L970
	movel a4@(-516),d0
	moveal a5@(-16),a0
	movel d0,a0@(144)
	moveal a5@(-16),a0
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-30)
	movel d0,a5@(-12)
	braw L976
L970:
	.short 0x700a	/* moveq #10,d0 */
	movel d0,a5@(-12)
L976:
	braw L980
L97a:
	.short 0x7005	/* moveq #5,d0 */
	movel d0,a5@(-12)
L980:
	movel a5@(-12),d0
	beqw L9c4
	moveal a5@(-16),a0
	movel a0@(144),d0
	tstl d0
	beqw L9b2
	lea sp@(-4),sp
	moveal a5@(-16),a0
	movel a0@(144),d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-40),a6
	moveml sp@+,a1
	jsr a6@(-414)
L9b2:
	moveal a5@(-16),a1
	moveal a4@(-40),a6
	jsr a6@(-690)
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-16)
L9c4:
	movel a5@(-16),d0
	unlk a5
	rts
L9cc:
	linkw a5,#-4
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-4)
	movel a5@(8),d0
	tstl d0
	beqw La3a
	moveal a5@(8),a0
	movel a0@(144),d0
	movel d0,a4@(-516)
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-36)
	moveal a4@(-516),a1
	moveal a4@(-40),a6
	jsr a6@(-414)
	moveal a5@(8),a0
	movel a0@(52),d0
	tstl d0
	beqw La2e
	lea sp@(-4),sp
	moveal a5@(8),a0
	movel a0@(52),d0
	.short 0x2f40,0x0000	/* movel d0,sp@(0) */
	moveal a4@(-52),a6
	moveml sp@+,a1
	jsr a6@(-78)
La2e:
	moveal a5@(8),a1
	moveal a4@(-40),a6
	jsr a6@(-690)
La3a:
	movel a5@(-4),d0
	unlk a5
	rts
La42:
	linkw a5,#-4
	.short 0x7000	/* moveq #0,d0 */
	movel d0,a5@(-4)
	movel a5@(20),d0
	tstl d0
	beqw La7e
	moveal a5@(20),a0
	movel a0@(144),d0
	movel d0,a4@(-516)
	moveal a5@(20),a1
	moveal a5@(16),a0
	movel a5@(12),d1
	movel a5@(8),d0
	moveal a4@(-516),a6
	jsr a6@(-42)
	movel d0,a5@(-4)
La7e:
	movel a5@(-4),d0
	unlk a5
	rts
La86:
	linkw a5,#0
	.short 0x7000	/* moveq #0,d0 */
	unlk a5
	rts
La90:
	.short 0x414d	/* .short 0x414d */
	notb sp@(24941)
	bvss Laff
	bsrs Lb07
	bcss Lb10
	bsrs Lb04
	bles Lb12
	blts Lb03
	.short 0x742d	/* moveq #45,d2 */
	bpls Lb13
	bnes Lad6
	bccs Lb1c
	bvss Lb22
	bcss Lb20
	.byte 0x00
Laaf:
	.byte 0x41,0x4d,0x46	/* oriw #19782,d1 */
	movel a1@-,sp@(28009)
	beqs Lb19
	blts Lb1f
	.short 0x7461	/* moveq #97,d2 */
	bnes Lb2d
	.short 0x726d	/* moveq #109,d1 */
	bsrs Lb36
	.byte 0x2d,0x77,0x6d,0x66,0x2e,0x64,0x72,0x69,0x76,0x65	/* movel sp@(2e64)@(7269),a6@(30309) */
	.short 0x7200	/* moveq #0,d1 */
Lace:
	.short 0x414d	/* .short 0x414d */
	notb sp@(24941)
	bvss Lb3d
Lad6:
	bsrs Lb45
	bcss Lb4e
	bsrs Lb42
	bles Lb50
	blts Lb41
	.short 0x742d	/* moveq #45,d2 */
	bsrs Lb4d
	moveal a4@-,sp
	.short 0x7269	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Laec:
	.short 0x414d	/* .short 0x414d */
	notb sp@(24941)
	bvss Lb5b
	bsrs Lb63
	bcss Lb6c
	bsrs Lb60
	bles Lb6e
	blts Lb5f
	.byte 0x74
Laff:
	.byte 0x2d	/* moveq #45,d2 */
	bccs Lb74
	.byte 0x32
Lb03:
	.byte 0x64	/* moveaw a4@-,a1 */
Lb04:
	moveal a4@-,sp
	.byte 0x72
Lb07:
	.byte 0x69	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Lb0c:
	.short 0x414d	/* .short 0x414d */
	.byte 0x46,0x2f
Lb10:
	.byte 0x61,0x6d	/* notb sp@(24941) */
Lb12:
	.byte 0x69
Lb13:
	.byte 0x67	/* bvss 0xb7b */
	bsrs Lb83
	bcss Lb8c
	.byte 0x61
Lb19:
	.byte 0x66	/* bsrs 0xb80 */
	bles Lb8e
Lb1c:
	blts Lb7f
	.byte 0x74
Lb1f:
	.byte 0x2d	/* moveq #45,d2 */
Lb20:
	bvcs Lb92
Lb22:
	beqs Lb90
	moveal a4@-,sp
	.short 0x7269	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Lb2c:
	.byte 0x41
Lb2d:
	.byte 0x4d	/* .short 0x414d */
	notb sp@(24941)
	bvss Lb9b
	bsrs Lba3
Lb36:
	bcss Lbac
	bsrs Lba0
	bles Lbae
	.byte 0x6d
Lb3d:
	.byte 0x61	/* blts 0xb9f */
	.short 0x742d	/* moveq #45,d2 */
	.byte 0x77
Lb41:
	.byte 0x77	/* .short 0x7777 */
Lb42:
	moveal a4@-,sp
	.byte 0x72
Lb45:
	.byte 0x69	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Lb4a:
	.short 0x414d	/* .short 0x414d */
	.byte 0x46
Lb4d:
	.byte 0x2f
Lb4e:
	.byte 0x61,0x6d	/* notb sp@(24941) */
Lb50:
	bvss Lbb9
	bsrs Lbc1
	bcss Lbca
	bsrs Lbbe
	bles Lbcc
	.byte 0x6d
Lb5b:
	.byte 0x61	/* blts 0xbbd */
	.short 0x742d	/* moveq #45,d2 */
	.byte 0x63
Lb5f:
	.byte 0x67	/* blss 0xbc7 */
Lb60:
	blts Lb90
	.byte 0x64
Lb63:
	.byte 0x72	/* bccs 0xbd6 */
	bvss Lbdc
	bcss Lbda
	.byte 0x00
Lb69:
	.byte 0x41,0x4d,0x46	/* oriw #19782,d1 */
Lb6c:
	.byte 0x2f,0x61
Lb6e:
	.byte 0x6d,0x69	/* movel a1@-,sp@(28009) */
	beqs Lbd3
	blts Lbd9
Lb74:
	.short 0x7461	/* moveq #97,d2 */
	bnes Lbe7
	.short 0x726d	/* moveq #109,d1 */
	.byte 0x61
Lb7b:
	.byte 0x74	/* bsrs 0xbf0 */
	.byte 0x2d,0x67,0x65
Lb7f:
	.byte 0x6d	/* movel sp@-,a6@(25965) */
Lb80:
	moveal a4@-,sp
	.byte 0x72
Lb83:
	.byte 0x69	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Lb88:
	.short 0x414d	/* .short 0x414d */
	.byte 0x46,0x2f
Lb8c:
	.byte 0x61,0x6d	/* notb sp@(24941) */
Lb8e:
	bvss Lbf7
Lb90:
	bsrs Lbff
Lb92:
	bcss Lc08
	bsrs Lbfc
	bles Lc0a
	blts Lbfb
	.byte 0x74
Lb9b:
	.byte 0x2d	/* moveq #45,d2 */
	bcss Lc0e
	.byte 0x73
Lb9f:
	.byte 0x2e	/* .short 0x732e */
Lba0:
	bccs Lc14
	.byte 0x69
Lba3:
	.byte 0x76	/* bvss 0xc1a */
	bcss Lc18
	.byte 0x00
Lba7:
	.byte 0x41,0x4d,0x46	/* oriw #19782,d1 */
	.byte 0x2f,0x61
Lbac:
	.byte 0x6d,0x69	/* movel a1@-,sp@(28009) */
Lbae:
	beqs Lc11
	blts Lc17
	.short 0x7461	/* moveq #97,d2 */
	bnes Lc25
	.short 0x726d	/* moveq #109,d1 */
	.byte 0x61
Lbb9:
	.byte 0x74	/* bsrs 0xc2e */
	.byte 0x2d,0x73,0x74
Lbbd:
	.byte 0x72
Lbbe:
	.byte 0x69,0x70	/* movel a3@(72,d7:w:4),a6@(26992) */
	.byte 0x2e
Lbc1:
	.byte 0x64	/* moveal a4@-,sp */
	.short 0x7269	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.byte 0x72
Lbc7:
	.byte 0x00	/* moveq #0,d1 */
Lbc8:
	.short 0x414d	/* .short 0x414d */
Lbca:
	.byte 0x46,0x2f
Lbcc:
	.byte 0x61,0x6d	/* notb sp@(24941) */
	bvss Lc37
	bsrs Lc3f
	.byte 0x65
Lbd3:
	.byte 0x74	/* bcss 0xc48 */
	bsrs Lc3c
Lbd6:
	bles Lc4a
	.byte 0x6d
Lbd9:
	.byte 0x61	/* blts 0xc3b */
Lbda:
	.short 0x742d	/* moveq #45,d2 */
Lbdc:
	bnes Lc47
	bges Lc45
	moveal a4@-,sp
	.short 0x7269	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.byte 0x72
Lbe7:
	.byte 0x00	/* moveq #0,d1 */
Lbe8:
	.short 0x414d	/* .short 0x414d */
	notb sp@(24941)
	bvss Lc57
Lbf0:
	bsrs Lc5f
	bcss Lc68
	bsrs Lc5c
	.byte 0x6f
Lbf7:
	.byte 0x72	/* bles 0xc6a */
	blts Lc5b
	.byte 0x74
Lbfb:
	.byte 0x2d	/* moveq #45,d2 */
Lbfc:
	.short 0x7374	/* .short 0x7374 */
	.byte 0x72
Lbff:
	.byte 0x69	/* moveq #105,d1 */
	.short 0x702e	/* moveq #46,d0 */
	bccs Lc76
	bvss Lc7c
	bcss Lc7a
Lc08:
	.byte 0x00
Lc09:
	.byte 0x41
Lc0a:
	.byte 0x4d,0x46	/* oriw #19782,d1 */
	.byte 0x2f,0x61
Lc0e:
	.byte 0x6d,0x69	/* movel a1@-,sp@(28009) */
	.byte 0x67
Lc11:
	.byte 0x61	/* beqs 0xc73 */
	blts Lc79
Lc14:
	.short 0x7461	/* moveq #97,d2 */
	.byte 0x66
Lc17:
	.byte 0x6f	/* bnes 0xc87 */
Lc18:
	.short 0x726d	/* moveq #109,d1 */
Lc1a:
	bsrs Lc90
	movel a3@(0x72,d7:w:0x4),a6@(26992)
	moveal a4@-,sp
	.byte 0x72
Lc25:
	.byte 0x69	/* moveq #105,d1 */
	.short 0x7665	/* moveq #101,d3 */
	.short 0x7200	/* moveq #0,d1 */
Lc2a:
	.short 0x74ff	/* moveq #-1,d2 */
	rts
Lc2e:
	.short 0x0000,0x006e	/* orib #110,d0 */
	.short 0x0000,0x00b8	/* orib #-72,d0 */
	.byte 0x00
Lc37:
	.byte 0x00,0x00,0xec	/* orib #-20,d0 */
	.byte 0x00
Lc3b:
	.byte 0x00
Lc3c:
	.byte 0x01,0x2c	/* orib #44,d0 */
	.byte 0x00
Lc3f:
	.byte 0x00,0x0c,0x74	/* orib #116,d0 */
	.byte 0x00,0x00,0x0c
Lc45:
	.byte 0x8c	/* orib #-116,d0 */
	.byte 0x00
Lc47:
	.byte 0x00
Lc48:
	.byte 0x0c,0xa2	/* orib #-94,d0 */
Lc4a:
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
Lc4e:
	.short 0x2278,0x0004	/* moveal 0x4,a1 */
	moveal a1@(276),a1
	.byte 0x22
Lc57:
	.byte 0x09	/* movel a1,d1 */
	.byte 0x02,0x41,0x03
Lc5b:
	.byte 0x80	/* andiw #896,d1 */
Lc5c:
	.byte 0x41,0xf6,0x10
Lc5f:
	.byte 0x30	/* lea a6@(30,d1:w),a0 */
	.short 0x720f	/* moveq #15,d1 */
	cmpal a0@+,a1
	beqs Lc70
	.short 0x5888	/* addql #4,a0 */
Lc68:
	.byte 0x51,0xc9
Lc6a:
	.byte 0xff,0xf8	/* dbf d1,0xc62 */
	subal a4,a4
	rts
Lc70:
	moveal a0@+,a4
	.byte 0x4e
Lc73:
	.byte 0x75	/* rts */
	.byte 0x48,0xe7
Lc76:
	.byte 0x20,0x3e	/* moveml d2/a2-a6,sp@- */
	.byte 0x48
Lc79:
	.byte 0xe7
Lc7a:
	.byte 0x80,0x80	/* moveml d0/a0,sp@- */
Lc7c:
	bsrw Lc4e
	bsrw L292
	.short 0x508f	/* addql #8,sp */
	.byte 0x4c
Lc87:
	.byte 0xdf,0x7c,0x04	/* moveml sp@+,d2/a2-a6 */
	rts
	moveml d2/a2-a6,sp@-
Lc90:
	movel d0,sp@-
	bsrw Lc4e
	bsrw L9cc
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d2/a2-a6
	rts
	moveml d2/a2-a6,sp@-
	moveml d0-d1/a0-a1,sp@-
	bsrw Lc4e
	bsrw La42
	lea sp@(16),sp
	moveml sp@+,d2/a2-a6
	rts
	.byte 0x4e,0x75,0x00,0x00	/* rts */
