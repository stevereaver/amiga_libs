	.text
	.byte 0x60,0x04,0x43,0x48,0x57,0x21,0x43,0xfa,0x00,0x7e,0x2c,0x78,0x00,0x04,0x4e,0xae
	.byte 0xfe,0x68,0x2c,0x40,0x4e,0xae,0xff,0xc4,0x22,0x00,0x41,0xfa,0x00,0x3e,0x24,0x08
	.byte 0x76,0x2a,0x4e,0xae,0xff,0xd0,0x22,0x4e,0x2c,0x78,0x00,0x04,0x4e,0xae,0xfe,0x62
	.byte 0x70,0x05,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x34,0x00,0x00,0x01,0xf0,0x80,0x16
	.byte 0x09,0x00,0x00,0x00,0x00,0x4e,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x92,0x69,0x66
	.byte 0x66,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x49,0x46,0x46,0x20,0x32,0x32
	.byte 0x2e,0x33,0x20,0x28,0x32,0x30,0x2e,0x30,0x36,0x2e,0x39,0x32,0x29,0x20,0x62,0x79
	.byte 0x20,0x43,0x68,0x72,0x69,0x73,0x74,0x69,0x61,0x6e,0x20,0x41,0x2e,0x20,0x57,0x65
	.byte 0x62,0x65,0x72,0x0a,0x0d,0x00
L86:
	.byte 0x64
	.byte 0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00,0x00,0x00,0x3c,0x00
	.byte 0x00,0x00,0xa2,0x00,0x00,0x00,0xd8,0x00,0x00,0x00,0xf8,0xff,0xff,0x00,0x84,0x00
	.byte 0xcc,0x01,0x04,0x01,0x4a,0x01,0xc0,0x03,0x16,0x03,0x7e,0x03,0xae,0x03,0xda,0x04
	.byte 0x22,0x05,0x12,0x05,0x2a,0x07,0x76,0x07,0x92,0x01,0xb8,0x07,0xee,0x01,0x4a,0x01
	.byte 0x4a,0x01,0x4a,0x01,0x4e,0x09,0x52,0x09,0xb6,0x0a,0x32,0x0a,0x66,0x0b,0x02,0xff
	.byte 0xff,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x4e,0xa0,0x0e,0x06,0x00,0x90
	.byte 0x14,0x00,0x16,0x90,0x16,0x00,0x03,0x80,0x18,0x00,0x00,0x00,0x5a,0x00,0x00,0x00
	.byte 0x00
	moveml d0-d1/a0-a1/a5,sp@-
	moveal d0,a5
	.byte 0x2b,0x4e
L100:
	.byte 0x00,0x22	/* movel a6,a5@(34) */
L102:
	movel a0,a5@(42)
	lea %pc@(L86),a1
	jsr a6@(-408)
	movel d0,a5@(38)
	lea a5@(46),a0
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	clrl a0@
	movel a0,a0@-
	moveml sp@+,d0-d1/a0-a1/a5
	rts
	moveml d1/a0-a2/a5-a6,sp@-
	moveal a6,a5
	bsrw L7e0
	bnes L16a
	.short 0x7016	/* moveq #22,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	beqs L16a
	moveal d0,a2
	movel a6@(276),a2@(14)
	lea a5@(46),a0
	moveal a2,a1
	jsr a6@(-246)
	.short 0x526d,0x0020	/* addqw #1,a5@(32) */
	bclr #3,a5@(14)
	movel a5,d0
L164:
	moveml sp@+,d1/a0-a2/a5-a6
	rts
L16a:
	.short 0x7000	/* moveq #0,d0 */
	bras L164
	moveml a2/a5-a6,sp@-
	moveal a6,a5
	bsrw L7e0
	beqs L18e
	moveal d0,a2
	moveal d0,a1
	moveal a5@(34),a6
	jsr a6@(-252)
	.short 0x7016	/* moveq #22,d0 */
	moveal a2,a1
	jsr a6@(-210)
L18e:
	moveml sp@+,a2/a5-a6
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L1a4
	btst #3,a6@(14)
	beqs L1a4
	bsrs L1a6
L1a4:
	rts
L1a6:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	tstw a5@(32)
	beqs L1bc
	bset #3,a5@(14)
	.short 0x7000	/* moveq #0,d0 */
	bras L1e6
L1bc:
	moveal a5,a1
	moveal a5@(34),a6
	jsr a6@(-252)
	moveal a5@(38),a1
	jsr a6@(-414)
	movel a5@(42),d2
	.short 0x7000	/* moveq #0,d0 */
	moveal a5,a1
	movew a5@(16),d0
	subaw d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
L1e6:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d2-d6/a2/a4-a6,sp@-
	.short 0x7c00	/* moveq #0,d6 */
	tstl d0
	beqs L268
	moveal a6,a5
	movel a0,d5
	.short 0x7014	/* moveq #20,d0 */
	.short 0x7201	/* moveq #1,d1 */
	swap d1
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	bnes L214
	.short 0x7012	/* moveq #18,d0 */
	bras L234
L214:
	moveal d0,a2
	.short 0x24bc,0x0049,0x6648	/* movel #4810312,a2@ */
	movel d5,d1
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	moveal a5@(38),a6
	jsr a6@(-30)
	movel d0,a2@(4)
	bnes L23a
	.short 0x7010	/* moveq #16,d0 */
L234:
	bsrw L808
	bras L256
L23a:
	movel d0,d1
	lea %pc@(L39c),a0
	movel a0,d2
	.short 0x7608	/* moveq #8,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	beqs L250
	.short 0x7014	/* moveq #20,d0 */
	bras L234
L250:
	bsrw L7fc
	movel a2,d0
L256:
	braw L396
	moveml d2-d6/a2/a4-a6,sp@-
	movel d0,d6
	bras L268
	moveml d2-d6/a2/a4-a6,sp@-
	.short 0x7cff	/* moveq #-1,d6 */
L268:
	moveal a6,a5
	lea sp@(-12),sp
	.short 0x7a00	/* moveq #0,d5 */
	subal a4,a4
	movel a0,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	moveal a5@(38),a6
	jsr a6@(-30)
	movel d0,d4
	bnes L28c
	.short 0x7a10	/* moveq #16,d5 */
	braw L374
L28c:
	movel d4,d1
	movel sp,d2
	.short 0x760c	/* moveq #12,d3 */
	jsr a6@(-42)
	cmpl d3,d0
	bnew L368
	movel d4,d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	.short 0x760c	/* moveq #12,d3 */
	.short 0x0c97,0x464f,0x524d	/* cmpil #1179603533,sp@ */
	beqs L2fc
	lea %pc@(L3a4),a1
	moveal a5@(34),a6
	jsr a6@(-408)
	tstl d0
	beqs L2f8
	moveal d0,a4
	lea sp@(-94),sp
	moveal sp,a0
	clrl sp@-
	movel d4,sp@-
	.short 0x4879,0x8000,0x5852	/* pea 0x80005852 */
	moveal sp,a1
	moveal a4,a6
	jsr a6@(-36)
	moveml sp@(54),d1-d3
	lea sp@(106),sp
	moveml d1-d3,sp@
	tstl d0
	bnes L2f8
	.short 0x7643	/* moveq #67,d3 */
	lsll #2,d3
	.short 0x0c97,0x464f,0x524d	/* cmpil #1179603533,sp@ */
	beqs L2fc
L2f8:
	.short 0x7a13	/* moveq #19,d5 */
	bras L36a
L2fc:
	movel d6,d1
	bpls L30e
	.short 0x7201	/* moveq #1,d1 */
	.byte 0x0c,0xaf,0x38,0x53,0x56,0x58,0x00,0x08	/* cmpil #944985688,sp@(8) */
	bnes L30e
	.short 0x7203	/* moveq #3,d1 */
L30e:
	addl sp@(4),d3
	movel d3,d0
	moveal a5@(34),a6
	jsr a6@(-198)
	moveal d0,a2
	tstl d0
	bnes L326
	.short 0x7a12	/* moveq #18,d5 */
	bras L36a
L326:
	movel d3,a2@+
	.short 0x5983	/* subql #4,d3 */
	movel a4,d0
	beqs L358
	clrl sp@-
	movel d3,sp@-
	.short 0x4879,0x8000,0x5871	/* pea 0x80005871 */
	movel a2,sp@-
	.short 0x4879,0x8000,0x5862	/* pea 0x80005862 */
	movel d4,sp@-
	.short 0x4879,0x8000,0x5852	/* pea 0x80005852 */
	moveal sp,a0
	moveal a4,a6
	jsr a6@(-48)
	lea sp@(28),sp
	tstl d0
	bras L366
L358:
	movel d4,d1
	movel a2,d2
	moveal a5@(38),a6
	jsr a6@(-42)
	cmpl d3,d0
L366:
	beqs L36a
L368:
	.short 0x7a11	/* moveq #17,d5 */
L36a:
	movel d4,d1
	moveal a5@(38),a6
	jsr a6@(-36)
L374:
	movel a4,d0
	beqs L382
	moveal a4,a1
	moveal a5@(34),a6
	jsr a6@(-414)
L382:
	movel d5,d0
	beqs L38c
	bsrw L808
	bras L392
L38c:
	bsrw L7fc
	movel a2,d0
L392:
	lea sp@(12),sp
L396:
	moveml sp@+,d2-d6/a2/a4-a6
	rts
L39c:
	.short 0x464f
	.short 0x524d	/* addqw #1,a5 */
	.short 0x0000,0x0000	/* orib #0,d0 */
L3a4:
	.short 0x7870	/* moveq #112,d4 */
	bmis L415
	bsrs L41d
	.short 0x7465	/* moveq #101,d2 */
	.short 0x722e	/* moveq #46,d1 */
	bges L419
	bhis L424
	bsrs L426
	.short 0x7900
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	movew a6@-,d0
	moveal a6,a5
	movel a1,d0
	beqs L416
	.short 0x0c91,0x0049,0x6648	/* cmpil #4810312,a1@ */
	beqs L3d6
	movel a1@-,d0
	moveal a5@(34),a6
	jsr a6@(-210)
	bras L416
L3d6:
	moveal a1,a2
	moveal a5@(38),a6
	movel a2@(4),d1
	beqs L40a
	movel a2@(4),d1
	.short 0x7404	/* moveq #4,d2 */
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis L402
	movel a2@(4),d1
	lea a2@(8),a0
	movel a0,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
L402:
	movel a2@(4),d1
	jsr a6@(-36)
L40a:
	moveal a2,a1
	.short 0x7014	/* moveq #20,d0 */
	moveal a5@(34),a6
	.byte 0x4e,0xae,0xff
L415:
	.byte 0x2e	/* jsr a6@(-210) */
L416:
	.byte 0x61,0x00,0x03
L419:
	.byte 0xe4	/* bsrw 0x7fc */
	.byte 0x4c,0xdf,0x64
L41d:
	.byte 0x0c	/* moveml sp@+,d2-d3/a2/a5-a6 */
	rts
L420:
	moveal a1@(4),a0
L424:
	.short 0x5089	/* addql #8,a1 */
L426:
	addal a1,a0
	.short 0x5889	/* addql #4,a1 */
	tstl d0
	bnes L432
	moveal a0,a1
	bras L44a
L432:
	cmpl a1@,d0
	beqs L44a
	movel a1@(4),d1
	.short 0x5281	/* addql #1,d1 */
	bclr #0,d1
	lea a1@(8,d1:l),a1
	cmpal a0,a1
	bcss L432
	subal a1,a1
L44a:
	movel a1,d0
	rts
	.byte 0x00,0x00
L450:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	movel d6,d0
	moveal a6,a5
	.short 0x203c,0x424d,0x4844	/* movel #1112361028,d0 */
	bsrw L420
	bnes L46a
	.short 0x7019	/* moveq #25,d0 */
	bsrw L808
	bras L474
L46a:
	.short 0x5080	/* addql #8,d0 */
	movel d0,d2
	bsrw L7fc
	movel d2,d0
L474:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	movew a0@-,d6
	moveal a0,a2
	.short 0x203c,0x434d,0x4150	/* movel #1129136464,d0 */
	bsrw L420
	beqs L4bc
	moveal d0,a0
	.short 0x5888	/* addql #4,a0 */
	movel a0@+,d4
	divsw #3,d4
	extl d4
	movel d4,d0
	.short 0x7a10	/* moveq #16,d5 */
	negb d5
	bras L4b8
	moveb a0@+,d1
	andw d5,d1
	moveb a0@+,d2
	andw d5,d2
	moveb a0@+,d3
	andw d5,d3
	lslw #4,d1
	lsrw #4,d3
	orw d2,d1
	orw d3,d1
	movew d1,a2@+
L4b8:
	.short 0x51cc,0xffe8	/* dbf d4,0x4a2 */
L4bc:
	moveml sp@+,d2-d5/a2
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3f3e
	lea sp@(-496),sp
	moveal a6,a5
	moveal a0,a3
	moveal a1,a4
	.byte 0x0c,0xac,0x49,0x4c,0x42,0x4d,0x00,0x08	/* cmpil #1229734477,a4@(8) */
	beqs L4e2
	.short 0x7018	/* moveq #24,d0 */
	braw L59e
L4e2:
	bsrw L450
	bnes L4ee
	.short 0x7019	/* moveq #25,d0 */
	braw L59e
L4ee:
	moveal d0,a2
	moveb a2@(8),d2
	beqw L598
	.short 0x7017	/* moveq #23,d0 */
	lea a3@(8),a0
	lea sp@,a1
	movel a0@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0x500 */
	.short 0x203c,0x424f,0x4459	/* movel #1112491097,d0 */
	moveal a4,a1
	bsrw L420
	bnes L51a
	.short 0x701a	/* moveq #26,d0 */
	braw L59e
L51a:
	moveal d0,a0
	.short 0x5888	/* addql #4,a0 */
	moveal a0@+,a4
	addal a0,a4
	moveb a2@(10),d0
	bnes L52e
	lea %pc@(L5ae),a6
	bras L53c
L52e:
	.short 0x5300	/* subqb #1,d0 */
	bnes L538
	lea %pc@(Lbbe),a6
	bras L53c
L538:
	.short 0x701c	/* moveq #28,d0 */
	bras L59e
L53c:
	.short 0x0c2a,0x0001,0x0009	/* cmpib #1,a2@(9) */
	seq d7
	.short 0x7800	/* moveq #0,d4 */
	movew a2@,d4
	.short 0x0644,0x000f	/* addiw #15,d4 */
	lsrl #3,d4
	bclr #0,d4
	.short 0x7a00	/* moveq #0,d5 */
	movew a3@,d5
	.short 0x7c00	/* moveq #0,d6 */
	movew a3@(2),d6
	cmpw a2@(2),d6
	bles L566
	movew a2@(2),d6
L566:
	bras L592
	.short 0x7600	/* moveq #0,d3 */
	lea sp@,a2
L56c:
	movel d4,d0
	cmpb a3@(5),d3
	bccs L57a
	moveal a2@,a1
	addl d5,a2@+
	bras L57e
L57a:
	lea sp@(96),a1
L57e:
	jsr a6@
	.short 0x5203	/* addqb #1,d3 */
	cmpb d2,d3
	blts L56c
	tstb d7
	beqs L592
	movel d4,d0
	lea sp@(96),a1
	jsr a6@
L592:
	cmpal a4,a0
	.short 0x54ce,0xffd2	/* dbcc d6,0x568 */
L598:
	bsrw L7fc
	bras L5a2
L59e:
	bsrw L808
L5a2:
	lea sp@(496),sp
	moveml sp@+,d2-d7/a2-a6
	rts
	moveb a0@+,a1@+
L5ae:
	.short 0x51c8,0xfffc	/* dbf d0,0x5ac */
	rts
	moveml d2-d4,sp@-
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	movew a1@,d3
	movew a1@(2),d4
	bsrw L5cc
	moveml sp@+,d2-d4
	rts
L5cc:
	moveml d2-d7/a2-a6,sp@-
	.short 0x9efc,0x0098	/* subaw #152,sp */
	movel d0,d6
	movel a2,d5
	moveal a0,a2
	moveal a6,a5
	moveal a1,a4
	.short 0x0240,0x000f	/* andiw #15,d0 */
	moveb d0,sp@(10)
	lslw #3,d1
	movemw d1-d2,sp@(4)
	bclr #0,d3
	lslw #3,d3
	movemw d3-d4,sp@
	movemw d3-d4,sp@(14)
	movew a4@,d0
	lslw #3,d0
	movew d0,sp@(16)
	movew a4@(2),sp@(18)
	moveb a4@(5),sp@(8)
	clrb sp@(9)
	clrb sp@(11)
	clrw sp@(12)
	.short 0x7812	/* moveq #18,d4 */
	.short 0x203c,0x0000,0x2800	/* movel #10240,d0 */
	.short 0x7201	/* moveq #1,d1 */
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	beqw L7a2
	moveal d0,a3
	.short 0x7814	/* moveq #20,d4 */
	moveal a2,a0
	.short 0x7001	/* moveq #1,d0 */
	moveal a5,a6
	jsr a6@(-120)
	tstl d0
	beqw L792
	moveal d0,a2
	.short 0x203c,0x494c,0x424d	/* movel #1229734477,d0 */
	.short 0x223c,0x424d,0x4844	/* movel #1112361028,d1 */
	.short 0x7414	/* moveq #20,d2 */
	moveal sp,a1
	bsrw L7ba
	beqw L78c
	moveal sp,a0
	bsrw L86e
	btst #7,d6
	beqs L674
	bset #11,d0
L674:
	movel d0,sp@(20)
	.short 0x223c,0x4341,0x4d47	/* movel #1128353095,d1 */
	.short 0x7404	/* moveq #4,d2 */
	lea sp@(20),a1
	bsrw L7ba
	beqw L78c
	tstl d5
	beqw L6ea
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@(5),d0
	.short 0x0c00,0x0008	/* cmpib #8,d0 */
	bcss L6a0
	.short 0x7008	/* moveq #8,d0 */
L6a0:
	.short 0x7201	/* moveq #1,d1 */
	lslw d0,d1
	movel d1,d2
	moveal d5,a0
	moveal a3,a1
	bras L6d0
	movew a0@,d0
	lsrw #8,d0
	muluw #17,d0
	moveb d0,a1@+
	movew a0@,d0
	lsrw #4,d0
	.short 0x0240,0x000f	/* andiw #15,d0 */
	muluw #17,d0
	moveb d0,a1@+
	movew a0@+,d0
	.short 0x0240,0x000f	/* andiw #15,d0 */
	muluw #17,d0
	moveb d0,a1@+
L6d0:
	.short 0x51c9,0xffda	/* dbf d1,0x6ac */
	.short 0x223c,0x434d,0x4150	/* movel #1129136464,d1 */
	muluw #3,d2
	moveal a3,a1
	bsrw L7ba
	tstl d0
	beqw L78c
L6ea:
	moveal a2,a0
	.short 0x223c,0x424f,0x4459	/* movel #1112491097,d1 */
	moveal a5,a6
	jsr a6@(-126)
	tstl d0
	beqw L78c
	.short 0x7000	/* moveq #0,d0 */
	movemw sp@(4),d0-d1
	lsrw #3,d0
	muluw a4@,d1
	addl d0,d1
	lea a4@(8),a0
	lea sp@(24),a1
	.short 0x741f	/* moveq #31,d2 */
	movel a0@+,d0
	addl d1,d0
	movel d0,a1@+
	.short 0x51ca,0xfff8	/* dbf d2,0x716 */
	movemw sp@,d3-d4
	lsrw #3,d3
	.short 0x7a00	/* moveq #0,d5 */
	moveb a4@(5),d5
	.short 0x5345	/* subqw #1,d5 */
	movew a4@,d6
	.short 0x7e00	/* moveq #0,d7 */
	bras L76e
	lea sp@(24),a4
	movel d5,d2
	.short 0x0c47,0x2000	/* cmpiw #8192,d7 */
	bcss L750
	moveal a2,a0
	moveal a3,a1
	movel d7,d0
	jsr a6@(-138)
	tstl d0
	beqs L78c
	.short 0x7e00	/* moveq #0,d7 */
L750:
	moveal a4@,a0
	lea a3@(0,d7:l),a1
	movel d3,d0
	.short 0x7200	/* moveq #0,d1 */
	moveb sp@(10),d1
	jsr a6@(-144)
	tstl d0
	beqs L78c
	addl d0,d7
	addl d6,a4@+
	.short 0x51ca,0xffce	/* dbf d2,0x73a */
L76e:
	.short 0x51cc,0xffc4	/* dbf d4,0x734 */
	moveal a2,a0
	moveal a3,a1
	movel d7,d0
	jsr a6@(-138)
	tstl d0
	beqs L78c
	moveal a2,a0
	jsr a6@(-132)
	tstl d0
	beqs L78c
	.short 0x7800	/* moveq #0,d4 */
L78c:
	moveal a2,a1
	jsr a6@(-36)
L792:
	.short 0x203c,0x0000,0x2800	/* movel #10240,d0 */
	moveal a3,a1
	moveal a5@(34),a6
	jsr a6@(-210)
L7a2:
	movel d4,d0
	beqs L7ac
	bsrw L808
	bras L7b0
L7ac:
	bsrw L7fc
L7b0:
	.short 0xdefc,0x0098	/* addaw #152,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
L7ba:
	movel a1,sp@-
	moveal a2,a0
	jsr a6@(-126)
	moveal sp@+,a1
	tstl d0
	beqs L7dc
	moveal a2,a0
	movel d2,d0
	jsr a6@(-138)
	tstl d0
	beqs L7dc
	moveal a2,a0
	jsr a6@(-132)
	tstl d0
L7dc:
	rts
	.byte 0x00,0x00
L7e0:
	.byte 0x2c,0x6d	/* orib #109,d0 */
	.short 0x0022,0x222e	/* orib #46,a2@- */
	btst d0,a4@
	movel a5@(46),d0
L7ec:
	moveal d0,a0
	movel a0@,d0
	beqs L7fa
	cmpl a0@(14),d1
	bnes L7ec
	movel a0,d0
L7fa:
	rts
L7fc:
	bsrs L7e0
	beqs L804
	clrl a0@(18)
L804:
	.short 0x7001	/* moveq #1,d0 */
	rts
L808:
	movel d0,sp@-
	bsrs L7e0
	beqs L812
	movel sp@,a0@(18)
L812:
	.short 0x588f	/* addql #4,sp */
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	bsrs L7e0
	beqs L830
	movel a0@(18),d0
	clrl a0@(18)
L82a:
	moveml sp@+,a5-a6
	rts
L830:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L82a
	movel a2,sp@-
	moveal a1,a2
	.short 0x203c,0x4341,0x4d47	/* movel #1128353095,d0 */
	bsrw L420
	beqs L852
	moveal d0,a0
	movel a0@(8),d0
	.short 0x0280,0xffff,0x9efd	/* andil #-24835,d0 */
	bras L86a
L852:
	moveal a2,a1
	bsrw L450
	beqs L86a
	moveal d0,a0
	bsrs L86e
	.short 0x0c28,0x0006,0x0008	/* cmpib #6,a0@(8) */
	blts L86a
	bset #11,d0
L86a:
	moveal sp@+,a2
	rts
L86e:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0c28,0x0004,0x0008	/* cmpib #4,a0@(8) */
	bgts L882
	.short 0x0c50,0x0190	/* cmpiw #400,a0@ */
	bles L882
	bset #15,d0
L882:
	.short 0x0c68,0x0140,0x0002	/* cmpiw #320,a0@(2) */
	blts L88e
	bset #2,d0
L88e:
	rts
	moveml d2-d7/a2-a6,sp@-
	moveal a6,a5
	moveal a1,a4
	movew a0@,d3
	movew a0@(2),d4
	.short 0x7a00	/* moveq #0,d5 */
	moveb a0@(5),d5
	lea a0@(8),a3
	movew d4,d7
	addw d7,d7
	subaw d7,sp
	moveal sp,a0
	.short 0x7000	/* moveq #0,d0 */
	movew d4,d1
	bras L8ba
	movew d0,a0@+
	addw d3,d0
L8ba:
	.short 0x51c9,0xfffa	/* dbf d1,0x8b6 */
	.byte 0x0c,0xac,0x49,0x4c,0x42,0x4d,0x00,0x08	/* cmpil #1229734477,a4@(8) */
	beqs L8ce
	.short 0x7018	/* moveq #24,d0 */
	braw L934
L8ce:
	.short 0x203c,0x414e,0x4844	/* movel #1095649348,d0 */
	moveal a4,a1
	bsrw L420
	bnes L8e2
	.short 0x701d	/* moveq #29,d0 */
	braw L934
L8e2:
	.short 0x5080	/* addql #8,d0 */
	moveal d0,a2
	moveb a2@,d0
	.short 0x0c00,0x0005	/* cmpib #5,d0 */
	bnes L8f4
	lea %pc@(L940),a6
	bras L8f8
L8f4:
	.short 0x701c	/* moveq #28,d0 */
	bras L934
L8f8:
	moveal a4,a1
	.short 0x203c,0x444c,0x5441	/* movel #1145852993,d0 */
	bsrw L420
	bnes L90c
	.short 0x701e	/* moveq #30,d0 */
	braw L934
L90c:
	.short 0x5080	/* addql #8,d0 */
	moveal d0,a4
	moveal sp,a2
	.short 0x7400	/* moveq #0,d2 */
	bras L92a
	movel a4@(0,d2:w),d0
	beqs L926
	moveal a4,a0
	addal d0,a0
	moveal a3@,a1
	movew d3,d0
	jsr a6@
L926:
	.short 0x5842	/* addqw #4,d2 */
	.short 0x588b	/* addql #4,a3 */
L92a:
	.short 0x51cd,0xffea	/* dbf d5,0x916 */
	bsrw L7fc
	bras L938
L934:
	bsrw L808
L938:
	addaw d7,sp
	moveml sp@+,d2-d7/a2-a6
	rts
L940:
	moveml d0-d5/a0-a1/a3,sp@-
	movew d0,d2
	movew d2,d4
	braw L9ea
	moveal a1,a3
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	braw L9e4
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	bmiw L9aa
	beqw L96c
	addw d1,d1
	addaw a2@(0,d1:w),a3
	braw L9e4
L96c:
	moveb a0@+,d1
	moveb a0@+,d3
	movew d1,d5
	asrw #3,d5
	.short 0x0241,0x0007	/* andiw #7,d1 */
	addw d1,d1
	addw d1,d1
	negw d1
	.short 0x4efb,0x1022	/* jmp %pc@(0x9a2,d1:w) */
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	moveb d3,a3@
	addaw d2,a3
	.short 0x51cd,0xffde	/* dbf d5,0x982 */
	braw L9e4
L9aa:
	.short 0x0241,0x007f	/* andiw #127,d1 */
	movew d1,d5
	asrw #3,d5
	.short 0x0241,0x0007	/* andiw #7,d1 */
	addw d1,d1
	addw d1,d1
	negw d1
	.short 0x4efb,0x1022	/* jmp %pc@(0x9e0,d1:w) */
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	moveb a0@+,a3@
	addaw d2,a3
	.short 0x51cd,0xffde	/* dbf d5,0x9c0 */
L9e4:
	.short 0x51c8,0xff70	/* dbf d0,0x956 */
	.short 0x5289	/* addql #1,a1 */
L9ea:
	.short 0x51cc,0xff60	/* dbf d4,0x94c */
	moveml sp@+,d0-d5/a0-a1/a3
	rts
	moveml d0-d3/a2/a5-a6,sp@-
	moveal a6,a5
	moveal a0,a2
	moveal a5@(38),a6
	tstl a2@(8)
	bnes La1a
	movel a2@(4),d1
	movel sp,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes La4a
	addl d3,a2@(8)
La1a:
	clrl a2@(12)
	movel a2@(4),d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	jsr a6@(-66)
	movel d0,a2@(16)
	bmis La4a
	movel a2@(4),d1
	lea sp@(4),a0
	movel a0,d2
	.short 0x7608	/* moveq #8,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes La4a
	bsrw L7fc
	bras La50
La4a:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L808
La50:
	movel d0,sp@
	moveml sp@+,d0-d3/a2/a5-a6
	rts
	moveml d2-d3/a2/a5-a6,sp@-
	moveal a6,a5
	moveal a0,a2
	moveal a5@(38),a6
	btst #0,a2@(15)
	beqs La80
	movel a2@(4),d1
	movel a2,d2
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes Lac8
	addl d3,a2@(12)
La80:
	.short 0x7008	/* moveq #8,d0 */
	addl a2@(12),d0
	addl d0,a2@(8)
	movel a2@(4),d1
	.short 0x7404	/* moveq #4,d2 */
	addl a2@(16),d2
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis Lac8
	movel a2@(4),d1
	lea a2@(12),a0
	movel a0,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes Lac8
	movel a2@(4),d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis Lac8
	bsrw L7fc
	bras Lace
Lac8:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L808
Lace:
	moveml sp@+,d2-d3/a2/a5-a6
	rts
	moveml d2-d3/a2/a5-a6,sp@-
	moveal a6,a5
	moveal a0,a2
	moveal a5@(38),a6
	movel a2@(4),d1
	movel a1,d2
	movel d0,d3
	jsr a6@(-48)
	cmpl d3,d0
	bnes Lafa
	addl d3,a2@(12)
	bsrw L7fc
	bras Lb00
Lafa:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L808
Lb00:
	moveml sp@+,d2-d3/a2/a5-a6
	rts
	.short 0x0000,0x5381	/* orib #-127,d0 */
	beqs Lb32
	bmis Lb20
	moveml a5-a6,sp@-
	moveal a6,a5
	.short 0x701c	/* moveq #28,d0 */
	bsrw L808
	moveml sp@+,a5-a6
	rts
Lb20:
	moveml d0/a6,sp@-
	moveal a6@(34),a6
	jsr a6@(-624)
	moveml sp@+,d0/a6
	rts
Lb32:
	moveml d2-d3/a2-a3,sp@-
	lea a0@(0,d0:l),a2
	.short 0x7600	/* moveq #0,d3 */
Lb3c:
	bsrs Lb8a
	.short 0xb07c,0x0003	/* cmpw #3,d0 */
	blts Lb54
	.short 0x5483	/* addql #2,d3 */
	moveb a0@,d1
	addaw d0,a0
	.short 0x5340	/* subqw #1,d0 */
	negb d0
	moveb d0,a1@+
	moveb d1,a1@+
	bras Lb7e
Lb54:
	moveal a0,a3
	.short 0x7400	/* moveq #0,d2 */
Lb58:
	.short 0x5202	/* addqb #1,d2 */
	bmis Lb6c
	.short 0x5288	/* addql #1,a0 */
	cmpal a2,a0
	bccs Lb6e
	bsrs Lb8a
	.short 0xb07c,0x0003	/* cmpw #3,d0 */
	blts Lb58
	bras Lb6e
Lb6c:
	.short 0x747f	/* moveq #127,d2 */
Lb6e:
	moveal a3,a0
	addl d2,d3
	.short 0x5283	/* addql #1,d3 */
	.short 0x5342	/* subqw #1,d2 */
	moveb d2,a1@+
	moveb a0@+,a1@+
	.short 0x51ca,0xfffc	/* dbf d2,0xb78 */
Lb7e:
	cmpal a2,a0
	bcss Lb3c
	movel d3,d0
	moveml sp@+,d2-d3/a2-a3
	rts
Lb8a:
	movel a0,sp@-
	.short 0x7001	/* moveq #1,d0 */
	moveb a0@+,d1
Lb90:
	cmpb a0@+,d1
	bnes Lba0
	.short 0xb07c,0x0080	/* cmpw #128,d0 */
	bges Lba0
	.short 0x5240	/* addqw #1,d0 */
	cmpal a2,a0
	bcss Lb90
Lba0:
	moveal sp@+,a0
	rts
	.short 0x5381	/* subql #1,d1 */
	beqs Lbbe
	bmiw Lb20
	moveml a5-a6,sp@-
	moveal a6,a5
	.short 0x701c	/* moveq #28,d0 */
	bsrw L808
	moveml sp@+,a5-a6
	rts
Lbbe:
	moveml d0/d2,sp@-
Lbc2:
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	bmis Lbd2
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	.short 0x5fc9,0xfffa	/* dble d1,0xbc8 */
	bras Lbe0
Lbd2:
	negb d1
	bmis Lbe0
	moveb a0@+,d2
	moveb d2,a1@+
	.short 0x5380	/* subql #1,d0 */
	.short 0x5fc9,0xfffa	/* dble d1,0xbd8 */
Lbe0:
	tstl d0
	bgts Lbc2
	moveml sp@+,d0/d2
	.byte 0x4e,0x75,0x00,0x00	/* rts */

	.data
	.long 0
