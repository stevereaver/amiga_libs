	.text
	lea %pc@(L87),a1
	moveal 0x4,a6
	jsr a6@(-408)
	moveal d0,a6
	jsr a6@(-60)
	movel d0,d1
	lea %pc@(L54),a0
	movel a0,d2
	.short 0x7633	/* moveq #51,d3 */
	jsr a6@(-48)
	moveal a6,a1
	moveal 0x4,a6
	jsr a6@(-414)
	.short 0x700a	/* moveq #10,d0 */
	rts
	illegal
	.short 0x0000,0x002e	/* orib #46,d0 */
	.short 0x0000,0x01e0	/* orib #-32,d0 */
	orb sp@,d0
	btst d4,d0
	.short 0x0000,0x0048	/* orib #72,d0 */
	.short 0x0000,0x0054	/* orib #84,d0 */
	.short 0x0000,0x0094	/* orib #-108,d0 */
	bvss Lb0
	bnes L7a
	bges Lb7
	bhis Lc2
	bsrs Lc4
	.short 0x7900
L54:
	.short 0x4946
	notb a0@-
	.short 0x3233,0x2e32	/* "23.2" */
	movel a0@(12852),d0
	.short 0x2e35,0x2e39	/* ".59)" */
	movew a1@(8232),a1@-
	.short 0x2d3a,0x2062	/* movel %pc@(0x20cc),a6@- */
	.short 0x7920
	.short 0x4368
	.short 0x7269	/* moveq #105,d1 */
	.short 0x7374
	bvss Ld7
	bgts L98
	.byte 0x41,0x2e
L7a:
	.byte 0x20,0x57	/* chkl a6@(8279),d0 */
	bcss Le0
	bcss Lf2
	.short 0x203a,0x2d29	/* movel %pc@(0x2dab),d0 */
	.byte 0x0d,0x0a,0x00
L87:
	.byte 0x64	/* movepw a2@(100),d6 */
	bles Lfd
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.byte 0x00,0x3c
L98:
	.byte 0x00,0x00	/* orib #0,%ccr */
	.short 0x00a4,0x0000,0x00da	/* oril #218,a4@- */
	.short 0x0000,0x00fa	/* orib #-6,d0 */
	.short 0xffff
	.short 0x0084,0x00cc,0x00f8	/* oril #13369592,d4 */
	.short 0x0138,0x01ae	/* btst d0,0x1ae */
Lb0:
	btst d1,d4
	bchg d1,a4@(924)
	.byte 0x03
Lb7:
	.byte 0xc8,0x04,0x10	/* movepl d1,a0@(1040) */
	btst d2,d0
	btst d2,a0@+
	bchg d3,a4@-
	bclr d3,d0
Lc2:
	bclr d0,a6@-
Lc4:
	bset d3,a0@+
	.short 0x0138,0x0138	/* btst d0,0x138 */
	.short 0x0138,0x013c	/* btst d0,0x13c */
	.short 0x093c,0x09b0	/* btst imm (noncanonical/data) */
	.short 0x0a3c,0x0a70	/* eorib #112,%ccr */
	.byte 0x0b
Ld7:
	.byte 0x0c,0xff,0xff	/* movepw a4@(-1),d5 */
	.short 0xa008
	btst d4,d0
	.short 0x800a
Le0:
	.short 0x0000,0x0048	/* orib #72,d0 */
	.short 0xa00e
	.short 0x0600,0x9014	/* addib #20,d0 */
	.short 0x0017,0x9016	/* orib #22,sp@ */
	.short 0x0002,0x8018	/* orib #24,d2 */
Lf2:
	.short 0x0000,0x0054	/* orib #84,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.byte 0x48,0xe7,0xc0
Lfd:
	.byte 0xc4	/* moveml d0-d1/a0-a1/a5,sp@- */
	moveal d0,a5
	movel a6,a5@(34)
	movel a0,a5@(42)
	lea %pc@(L87),a1
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
	bsrw L7d0
	bnes L16c
	.short 0x7016	/* moveq #22,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	beqs L16c
	moveal d0,a2
	movel a6@(276),a2@(14)
	lea a5@(46),a0
	moveal a2,a1
	jsr a6@(-246)
	.short 0x526d,0x0020	/* addqw #1,a5@(32) */
	bclr #3,a5@(14)
	movel a5,d0
L166:
	moveml sp@+,d1/a0-a2/a5-a6
	rts
L16c:
	.short 0x7000	/* moveq #0,d0 */
	bras L166
	moveml a2/a5-a6,sp@-
	moveal a6,a5
	bsrw L7d0
	beqs L190
	moveal d0,a2
	moveal d0,a1
	moveal a5@(34),a6
	jsr a6@(-252)
	.short 0x7016	/* moveq #22,d0 */
	moveal a2,a1
	jsr a6@(-210)
L190:
	moveml sp@+,a2/a5-a6
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	rts
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	tstw a5@(32)
	beqs L1ac
	.short 0x7000	/* moveq #0,d0 */
	bras L1d6
L1ac:
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
L1d6:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d2-d6/a2/a4-a6,sp@-
	.short 0x7c00	/* moveq #0,d6 */
	tstl d0
	beqs L258
	moveal a6,a5
	movel a0,d5
	.short 0x7050	/* moveq #80,d0 */
	.short 0x7201	/* moveq #1,d1 */
	swap d1
	moveal a5@(34),a6
	jsr a6@(-198)
	tstl d0
	bnes L204
	.short 0x7012	/* moveq #18,d0 */
	bras L224
L204:
	moveal d0,a2
	.short 0x24bc,0x0049,0x6648	/* movel #4810312,a2@ */
	movel d5,d1
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	moveal a5@(38),a6
	jsr a6@(-30)
	movel d0,a2@(4)
	bnes L22a
	.short 0x7010	/* moveq #16,d0 */
L224:
	bsrw L7f8
	bras L246
L22a:
	movel d0,d1
	lea %pc@(L38c),a0
	movel a0,d2
	.short 0x7608	/* moveq #8,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	beqs L240
	.short 0x7014	/* moveq #20,d0 */
	bras L224
L240:
	bsrw L7ec
	movel a2,d0
L246:
	braw L386
	moveml d2-d6/a2/a4-a6,sp@-
	movel d0,d6
	bras L258
	moveml d2-d6/a2/a4-a6,sp@-
	.short 0x7cff	/* moveq #-1,d6 */
L258:
	moveal a6,a5
	lea sp@(-12),sp
	.short 0x7a00	/* moveq #0,d5 */
	subal a4,a4
	movel a0,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	moveal a5@(38),a6
	jsr a6@(-30)
	movel d0,d4
	bnes L27c
	.short 0x7a10	/* moveq #16,d5 */
	braw L364
L27c:
	movel d4,d1
	movel sp,d2
	.short 0x760c	/* moveq #12,d3 */
	jsr a6@(-42)
	cmpl d3,d0
	bnew L358
	movel d4,d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	.short 0x760c	/* moveq #12,d3 */
	.short 0x0c97,0x464f,0x524d	/* cmpil #1179603533,sp@ */
	beqs L2ec
	lea %pc@(L394),a1
	moveal a5@(34),a6
	jsr a6@(-408)
	tstl d0
	beqs L2e8
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
	bnes L2e8
	.short 0x7643	/* moveq #67,d3 */
	lsll #2,d3
	.short 0x0c97,0x464f,0x524d	/* cmpil #1179603533,sp@ */
	beqs L2ec
L2e8:
	.short 0x7a13	/* moveq #19,d5 */
	bras L35a
L2ec:
	movel d6,d1
	bpls L2fe
	.short 0x7201	/* moveq #1,d1 */
	.byte 0x0c,0xaf,0x38,0x53,0x56,0x58,0x00,0x08	/* cmpil #944985688,sp@(8) */
	bnes L2fe
	.short 0x7203	/* moveq #3,d1 */
L2fe:
	addl sp@(4),d3
	movel d3,d0
	moveal a5@(34),a6
	jsr a6@(-198)
	moveal d0,a2
	tstl d0
	bnes L316
	.short 0x7a12	/* moveq #18,d5 */
	bras L35a
L316:
	movel d3,a2@+
	.short 0x5983	/* subql #4,d3 */
	movel a4,d0
	beqs L348
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
	bras L356
L348:
	movel d4,d1
	movel a2,d2
	moveal a5@(38),a6
	jsr a6@(-42)
	cmpl d3,d0
L356:
	beqs L35a
L358:
	.short 0x7a11	/* moveq #17,d5 */
L35a:
	movel d4,d1
	moveal a5@(38),a6
	jsr a6@(-36)
L364:
	movel a4,d0
	beqs L372
	moveal a4,a1
	moveal a5@(34),a6
	jsr a6@(-414)
L372:
	movel d5,d0
	beqs L37c
	bsrw L7f8
	bras L382
L37c:
	bsrw L7ec
	movel a2,d0
L382:
	lea sp@(12),sp
L386:
	moveml sp@+,d2-d6/a2/a4-a6
	rts
L38c:
	.short 0x464f
	.short 0x524d	/* addqw #1,a5 */
	.short 0x0000,0x0000	/* orib #0,d0 */
L394:
	.short 0x7870	/* moveq #112,d4 */
	bmis L405
	bsrs L40d
	.short 0x7465	/* moveq #101,d2 */
	.short 0x722e	/* moveq #46,d1 */
	bges L409
	bhis L414
	bsrs L416
	.short 0x7900
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	movew a6@-,d0
	moveal a6,a5
	movel a1,d0
	beqs L406
	.short 0x0c91,0x0049,0x6648	/* cmpil #4810312,a1@ */
	beqs L3c6
	movel a1@-,d0
	moveal a5@(34),a6
	jsr a6@(-210)
	bras L406
L3c6:
	moveal a1,a2
	moveal a5@(38),a6
	movel a2@(4),d1
	beqs L3fa
	movel a2@(4),d1
	.short 0x7404	/* moveq #4,d2 */
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis L3f2
	movel a2@(4),d1
	lea a2@(8),a0
	movel a0,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
L3f2:
	movel a2@(4),d1
	jsr a6@(-36)
L3fa:
	moveal a2,a1
	.short 0x7050	/* moveq #80,d0 */
	moveal a5@(34),a6
	.byte 0x4e,0xae,0xff
L405:
	.byte 0x2e	/* jsr a6@(-210) */
L406:
	.byte 0x61,0x00,0x03
L409:
	.byte 0xe4	/* bsrw 0x7ec */
	.byte 0x4c,0xdf,0x64
L40d:
	.byte 0x0c	/* moveml sp@+,d2-d3/a2/a5-a6 */
	rts
L410:
	moveal a1@(4),a0
L414:
	.short 0x5089	/* addql #8,a1 */
L416:
	addal a1,a0
	.short 0x5889	/* addql #4,a1 */
	tstl d0
	bnes L422
	moveal a0,a1
	bras L43a
L422:
	cmpl a1@,d0
	beqs L43a
	movel a1@(4),d1
	.short 0x5281	/* addql #1,d1 */
	bclr #0,d1
	lea a1@(8,d1:l),a1
	cmpal a0,a1
	bcss L422
	subal a1,a1
L43a:
	movel a1,d0
	rts
	.byte 0x00,0x00
L440:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	movel d6,d0
	moveal a6,a5
	.short 0x203c,0x424d,0x4844	/* movel #1112361028,d0 */
	bsrw L410
	bnes L45a
	.short 0x7019	/* moveq #25,d0 */
	bsrw L7f8
	bras L464
L45a:
	.short 0x5080	/* addql #8,d0 */
	movel d0,d2
	bsrw L7ec
	movel d2,d0
L464:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	movew a0@-,d6
	moveal a0,a2
	.short 0x203c,0x434d,0x4150	/* movel #1129136464,d0 */
	bsrw L410
	beqs L4ac
	moveal d0,a0
	.short 0x5888	/* addql #4,a0 */
	movel a0@+,d4
	divsw #3,d4
	extl d4
	movel d4,d0
	.short 0x7a10	/* moveq #16,d5 */
	negb d5
	bras L4a8
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
L4a8:
	.short 0x51cc,0xffe8	/* dbf d4,0x492 */
L4ac:
	moveml sp@+,d2-d5/a2
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3f3e
	lea sp@(-496),sp
	moveal a6,a5
	moveal a0,a3
	moveal a1,a4
	.byte 0x0c,0xac,0x49,0x4c,0x42,0x4d,0x00,0x08	/* cmpil #1229734477,a4@(8) */
	beqs L4d2
	.short 0x7018	/* moveq #24,d0 */
	braw L58e
L4d2:
	bsrw L440
	bnes L4de
	.short 0x7019	/* moveq #25,d0 */
	braw L58e
L4de:
	moveal d0,a2
	moveb a2@(8),d2
	beqw L588
	.short 0x7017	/* moveq #23,d0 */
	lea a3@(8),a0
	lea sp@,a1
	movel a0@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0x4f0 */
	.short 0x203c,0x424f,0x4459	/* movel #1112491097,d0 */
	moveal a4,a1
	bsrw L410
	bnes L50a
	.short 0x701a	/* moveq #26,d0 */
	braw L58e
L50a:
	moveal d0,a0
	.short 0x5888	/* addql #4,a0 */
	moveal a0@+,a4
	addal a0,a4
	moveb a2@(10),d0
	bnes L51e
	lea %pc@(L59e),a6
	bras L52c
L51e:
	.short 0x5300	/* subqb #1,d0 */
	bnes L528
	lea %pc@(Lbca),a6
	bras L52c
L528:
	.short 0x701c	/* moveq #28,d0 */
	bras L58e
L52c:
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
	bles L556
	movew a2@(2),d6
L556:
	bras L582
	.short 0x7600	/* moveq #0,d3 */
	lea sp@,a2
L55c:
	movel d4,d0
	cmpb a3@(5),d3
	bccs L56a
	moveal a2@,a1
	addl d5,a2@+
	bras L56e
L56a:
	lea sp@(96),a1
L56e:
	jsr a6@
	.short 0x5203	/* addqb #1,d3 */
	cmpb d2,d3
	blts L55c
	tstb d7
	beqs L582
	movel d4,d0
	lea sp@(96),a1
	jsr a6@
L582:
	cmpal a4,a0
	.short 0x54ce,0xffd2	/* dbcc d6,0x558 */
L588:
	bsrw L7ec
	bras L592
L58e:
	bsrw L7f8
L592:
	lea sp@(496),sp
	moveml sp@+,d2-d7/a2-a6
	rts
	moveb a0@+,a1@+
L59e:
	.short 0x51c8,0xfffc	/* dbf d0,0x59c */
	rts
	moveml d2-d4,sp@-
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7400	/* moveq #0,d2 */
	movew a1@,d3
	movew a1@(2),d4
	bsrw L5bc
	moveml sp@+,d2-d4
	rts
L5bc:
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
	beqw L792
	moveal d0,a3
	.short 0x7814	/* moveq #20,d4 */
	moveal a2,a0
	.short 0x7001	/* moveq #1,d0 */
	moveal a5,a6
	jsr a6@(-120)
	tstl d0
	beqw L782
	moveal d0,a2
	.short 0x203c,0x494c,0x424d	/* movel #1229734477,d0 */
	.short 0x223c,0x424d,0x4844	/* movel #1112361028,d1 */
	.short 0x7414	/* moveq #20,d2 */
	moveal sp,a1
	bsrw L7aa
	beqw L77c
	moveal sp,a0
	bsrw L858
	btst #7,d6
	beqs L664
	bset #11,d0
L664:
	movel d0,sp@(20)
	.short 0x223c,0x4341,0x4d47	/* movel #1128353095,d1 */
	.short 0x7404	/* moveq #4,d2 */
	lea sp@(20),a1
	bsrw L7aa
	beqw L77c
	tstl d5
	beqw L6da
	.short 0x7000	/* moveq #0,d0 */
	moveb a4@(5),d0
	.short 0x0c00,0x0008	/* cmpib #8,d0 */
	bcss L690
	.short 0x7008	/* moveq #8,d0 */
L690:
	.short 0x7201	/* moveq #1,d1 */
	lslw d0,d1
	movel d1,d2
	moveal d5,a0
	moveal a3,a1
	bras L6c0
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
L6c0:
	.short 0x51c9,0xffda	/* dbf d1,0x69c */
	.short 0x223c,0x434d,0x4150	/* movel #1129136464,d1 */
	muluw #3,d2
	moveal a3,a1
	bsrw L7aa
	tstl d0
	beqw L77c
L6da:
	moveal a2,a0
	.short 0x223c,0x424f,0x4459	/* movel #1112491097,d1 */
	moveal a5,a6
	jsr a6@(-126)
	tstl d0
	beqw L77c
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
	.short 0x51ca,0xfff8	/* dbf d2,0x706 */
	movemw sp@,d3-d4
	lsrw #3,d3
	.short 0x7a00	/* moveq #0,d5 */
	moveb a4@(5),d5
	.short 0x5345	/* subqw #1,d5 */
	movew a4@,d6
	.short 0x7e00	/* moveq #0,d7 */
	bras L75e
	lea sp@(24),a4
	movel d5,d2
	.short 0x0c47,0x2000	/* cmpiw #8192,d7 */
	bcss L740
	moveal a2,a0
	moveal a3,a1
	movel d7,d0
	jsr a6@(-138)
	tstl d0
	beqs L77c
	.short 0x7e00	/* moveq #0,d7 */
L740:
	moveal a4@,a0
	lea a3@(0,d7:l),a1
	movel d3,d0
	.short 0x7200	/* moveq #0,d1 */
	moveb sp@(10),d1
	jsr a6@(-144)
	tstl d0
	beqs L77c
	addl d0,d7
	addl d6,a4@+
	.short 0x51ca,0xffce	/* dbf d2,0x72a */
L75e:
	.short 0x51cc,0xffc4	/* dbf d4,0x724 */
	moveal a2,a0
	moveal a3,a1
	movel d7,d0
	jsr a6@(-138)
	tstl d0
	beqs L77c
	moveal a2,a0
	jsr a6@(-132)
	tstl d0
	beqs L77c
	.short 0x7800	/* moveq #0,d4 */
L77c:
	moveal a2,a1
	jsr a6@(-36)
L782:
	.short 0x203c,0x0000,0x2800	/* movel #10240,d0 */
	moveal a3,a1
	moveal a5@(34),a6
	jsr a6@(-210)
L792:
	movel d4,d0
	beqs L79c
	bsrw L7f8
	bras L7a0
L79c:
	bsrw L7ec
L7a0:
	.short 0xdefc,0x0098	/* addaw #152,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
L7aa:
	movel a1,sp@-
	moveal a2,a0
	jsr a6@(-126)
	moveal sp@+,a1
	tstl d0
	beqs L7cc
	moveal a2,a0
	movel d2,d0
	jsr a6@(-138)
	tstl d0
	beqs L7cc
	moveal a2,a0
	jsr a6@(-132)
	tstl d0
L7cc:
	rts
	.byte 0x00,0x00
L7d0:
	.byte 0x2c,0x6d	/* orib #109,d0 */
	.short 0x0022,0x222e	/* orib #46,a2@- */
	btst d0,a4@
	movel a5@(46),d0
L7dc:
	moveal d0,a0
	movel a0@,d0
	beqs L7ea
	cmpl a0@(14),d1
	bnes L7dc
	movel a0,d0
L7ea:
	rts
L7ec:
	bsrs L7d0
	beqs L7f4
	clrl a0@(18)
L7f4:
	.short 0x7001	/* moveq #1,d0 */
	rts
L7f8:
	movel d0,sp@-
	bsrs L7d0
	beqs L802
	movel sp@,a0@(18)
L802:
	.short 0x588f	/* addql #4,sp */
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml a5-a6,sp@-
	moveal a6,a5
	bsrs L7d0
	beqs L820
	movel a0@(18),d0
	clrl a0@(18)
L81a:
	moveml sp@+,a5-a6
	rts
L820:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L81a
	movel a2,sp@-
	moveal a1,a2
	.short 0x203c,0x4341,0x4d47	/* movel #1128353095,d0 */
	bsrw L410
	beqs L848
	moveal d0,a0
	movel a0@(8),d0
	tstw a0@(8)
	bnes L846
	.short 0x0280,0xffff,0x9efd	/* andil #-24835,d0 */
L846:
	bras L854
L848:
	moveal a2,a1
	bsrw L440
	beqs L854
	moveal d0,a0
	bsrs L858
L854:
	moveal sp@+,a2
	rts
L858:
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0c28,0x0004,0x0008	/* cmpib #4,a0@(8) */
	bgts L86c
	.short 0x0c50,0x0190	/* cmpiw #400,a0@ */
	bles L86c
	bset #15,d0
L86c:
	.short 0x0c68,0x0140,0x0002	/* cmpiw #320,a0@(2) */
	blts L878
	bset #2,d0
L878:
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3f3e
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
	bras L8a6
	movew d0,a0@+
	addw d3,d0
L8a6:
	.short 0x51c9,0xfffa	/* dbf d1,0x8a2 */
	.byte 0x0c,0xac,0x49,0x4c,0x42,0x4d,0x00,0x08	/* cmpil #1229734477,a4@(8) */
	beqs L8ba
	.short 0x7018	/* moveq #24,d0 */
	braw L920
L8ba:
	.short 0x203c,0x414e,0x4844	/* movel #1095649348,d0 */
	moveal a4,a1
	bsrw L410
	bnes L8ce
	.short 0x701d	/* moveq #29,d0 */
	braw L920
L8ce:
	.short 0x5080	/* addql #8,d0 */
	moveal d0,a2
	moveb a2@,d0
	.short 0x0c00,0x0005	/* cmpib #5,d0 */
	bnes L8e0
	lea %pc@(L92c),a6
	bras L8e4
L8e0:
	.short 0x701c	/* moveq #28,d0 */
	bras L920
L8e4:
	moveal a4,a1
	.short 0x203c,0x444c,0x5441	/* movel #1145852993,d0 */
	bsrw L410
	bnes L8f8
	.short 0x701e	/* moveq #30,d0 */
	braw L920
L8f8:
	.short 0x5080	/* addql #8,d0 */
	moveal d0,a4
	moveal sp,a2
	.short 0x7400	/* moveq #0,d2 */
	bras L916
	movel a4@(0,d2:w),d0
	beqs L912
	moveal a4,a0
	addal d0,a0
	moveal a3@,a1
	movew d3,d0
	jsr a6@
L912:
	.short 0x5842	/* addqw #4,d2 */
	.short 0x588b	/* addql #4,a3 */
L916:
	.short 0x51cd,0xffea	/* dbf d5,0x902 */
	bsrw L7ec
	bras L924
L920:
	bsrw L7f8
L924:
	addaw d7,sp
	moveml sp@+,d2-d7/a2-a6
	rts
L92c:
	moveml d0-d5/a0-a1/a3,sp@-
	movew d0,d2
	movew d2,d4
	braw L9d6
	moveal a1,a3
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d0
	braw L9d0
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	bmiw L996
	beqw L958
	addw d1,d1
	addaw a2@(0,d1:w),a3
	braw L9d0
L958:
	moveb a0@+,d1
	moveb a0@+,d3
	movew d1,d5
	asrw #3,d5
	.short 0x0241,0x0007	/* andiw #7,d1 */
	addw d1,d1
	addw d1,d1
	negw d1
	.short 0x4efb,0x1022	/* jmp %pc@(0x98e,d1:w) */
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
	.short 0x51cd,0xffde	/* dbf d5,0x96e */
	braw L9d0
L996:
	.short 0x0241,0x007f	/* andiw #127,d1 */
	movew d1,d5
	asrw #3,d5
	.short 0x0241,0x0007	/* andiw #7,d1 */
	addw d1,d1
	addw d1,d1
	negw d1
	.short 0x4efb,0x1022	/* jmp %pc@(0x9cc,d1:w) */
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
	.short 0x51cd,0xffde	/* dbf d5,0x9ac */
L9d0:
	.short 0x51c8,0xff70	/* dbf d0,0x942 */
	.short 0x5289	/* addql #1,a1 */
L9d6:
	.short 0x51cc,0xff60	/* dbf d4,0x938 */
	moveml sp@+,d0-d5/a0-a1/a3
	rts
	moveml d0-d3/a2/a5-a6,sp@-
	moveal a6,a5
	moveal a0,a2
	moveal a5@(38),a6
	tstl a2@(8)
	bnes La06
	movel a2@(4),d1
	movel sp,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes La46
	addl d3,a2@(8)
La06:
	lea a2@(80),a1
	lea a1@(-8),a0
	.short 0x700f	/* moveq #15,d0 */
	movel a0@-,a1@-
	.short 0x51c8,0xfffc	/* dbf d0,0xa10 */
	clrl a2@(8)
	movel a2@(4),d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7600	/* moveq #0,d3 */
	jsr a6@(-66)
	movel d0,a2@(12)
	bmis La46
	movel a2@(4),d1
	lea sp@(4),a0
	movel a0,d2
	.short 0x7608	/* moveq #8,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes La46
	bsrw L7ec
	bras La4c
La46:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L7f8
La4c:
	movel d0,sp@
	moveml sp@+,d0-d3/a2/a5-a6
	rts
	moveml d2-d3/a2/a5-a6,sp@-
	moveal a6,a5
	moveal a0,a2
	moveal a5@(38),a6
	btst #0,a2@(11)
	beqs La7c
	movel a2@(4),d1
	movel a2,d2
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes Lad4
	addl d3,a2@(8)
La7c:
	.short 0x7008	/* moveq #8,d0 */
	addl a2@(8),d0
	addl d0,a2@(16)
	movel a2@(4),d1
	.short 0x7404	/* moveq #4,d2 */
	addl a2@(12),d2
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis Lad4
	movel a2@(4),d1
	lea a2@(8),a0
	movel a0,d2
	.short 0x7604	/* moveq #4,d3 */
	jsr a6@(-48)
	cmpl d3,d0
	bnes Lad4
	movel a2@(4),d1
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	jsr a6@(-66)
	tstl d0
	bmis Lad4
	lea a2@(8),a1
	lea a1@(8),a0
	.short 0x700f	/* moveq #15,d0 */
	movel a0@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0xac8 */
	bsrw L7ec
	bras Lada
Lad4:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L7f8
Lada:
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
	bnes Lb06
	addl d3,a2@(8)
	bsrw L7ec
	bras Lb0c
Lb06:
	.short 0x7014	/* moveq #20,d0 */
	bsrw L7f8
Lb0c:
	moveml sp@+,d2-d3/a2/a5-a6
	rts
	.short 0x0000,0x5381	/* orib #-127,d0 */
	beqs Lb3e
	bmis Lb2c
	moveml a5-a6,sp@-
	moveal a6,a5
	.short 0x701c	/* moveq #28,d0 */
	bsrw L7f8
	moveml sp@+,a5-a6
	rts
Lb2c:
	moveml d0/a6,sp@-
	moveal a6@(34),a6
	jsr a6@(-624)
	moveml sp@+,d0/a6
	rts
Lb3e:
	moveml d2-d3/a2-a3,sp@-
	lea a0@(0,d0:l),a2
	.short 0x7600	/* moveq #0,d3 */
Lb48:
	bsrs Lb96
	.short 0xb07c,0x0003	/* cmpw #3,d0 */
	blts Lb60
	.short 0x5483	/* addql #2,d3 */
	moveb a0@,d1
	addaw d0,a0
	.short 0x5340	/* subqw #1,d0 */
	negb d0
	moveb d0,a1@+
	moveb d1,a1@+
	bras Lb8a
Lb60:
	moveal a0,a3
	.short 0x7400	/* moveq #0,d2 */
Lb64:
	.short 0x5202	/* addqb #1,d2 */
	bmis Lb78
	.short 0x5288	/* addql #1,a0 */
	cmpal a2,a0
	bccs Lb7a
	bsrs Lb96
	.short 0xb07c,0x0003	/* cmpw #3,d0 */
	blts Lb64
	bras Lb7a
Lb78:
	.short 0x747f	/* moveq #127,d2 */
Lb7a:
	moveal a3,a0
	addl d2,d3
	.short 0x5283	/* addql #1,d3 */
	.short 0x5342	/* subqw #1,d2 */
	moveb d2,a1@+
	moveb a0@+,a1@+
	.short 0x51ca,0xfffc	/* dbf d2,0xb84 */
Lb8a:
	cmpal a2,a0
	bcss Lb48
	movel d3,d0
	moveml sp@+,d2-d3/a2-a3
	rts
Lb96:
	movel a0,sp@-
	.short 0x7001	/* moveq #1,d0 */
	moveb a0@+,d1
Lb9c:
	cmpb a0@+,d1
	bnes Lbac
	.short 0xb07c,0x0080	/* cmpw #128,d0 */
	bges Lbac
	.short 0x5240	/* addqw #1,d0 */
	cmpal a2,a0
	bcss Lb9c
Lbac:
	moveal sp@+,a0
	rts
	.short 0x5381	/* subql #1,d1 */
	beqs Lbca
	bmiw Lb2c
	moveml a5-a6,sp@-
	moveal a6,a5
	.short 0x701c	/* moveq #28,d0 */
	bsrw L7f8
	moveml sp@+,a5-a6
	rts
Lbca:
	moveml d0/d2,sp@-
Lbce:
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	bmis Lbde
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	.short 0x5fc9,0xfffa	/* dble d1,0xbd4 */
	bras Lbec
Lbde:
	negb d1
	bmis Lbec
	moveb a0@+,d2
	moveb d2,a1@+
	.short 0x5380	/* subql #1,d0 */
	.short 0x5fc9,0xfffa	/* dble d1,0xbe4 */
Lbec:
	tstl d0
	bgts Lbce
	moveml sp@+,d0/d2
	rts
	.short 0x0000,0x4348	/* orib #72,d0 */
	.short 0x5721	/* subqb #3,a1@- */
