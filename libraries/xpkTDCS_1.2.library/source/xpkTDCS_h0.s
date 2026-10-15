/* xpkTDCS.library 1.2 -- byte-verbatim reconstruction
 * single CODE hunk; absolute operands as literals, RELOC32 tail
 * injected/ordered by fixup.py
 */
	.text
L0:
	.short 0x7000	/* moveq #0,d0 */
	rts
	illegal
	.short 0x0000,0x0004	/* orib #4,d0 */
	.short 0x0000,0x0824	/* orib #36,d0 */
	orb d1,d0
	btst d4,d0
	.short 0x0000,0x06d8	/* orib #-40,d0 */
	.short 0x0000,0x06e8	/* orib #-24,d0 */
	.short 0x0000,0x001e	/* orib #30,d0 */
	.short 0x0000,0x0026	/* orib #38,d0 */
	.short 0x0000,0x002e	/* orib #46,d0 */
	.short 0x0000,0x0046	/* orib #70,d0 */
	.short 0x0000,0x0066	/* orib #102,d0 */
	.short 0xffff
	.short 0x004e
	.short 0x005c,0x006a	/* oriw #106,a4@+ */
	.short 0xffd2
	.short 0x00a4,0x00ac,0xffd2	/* oril #11337682,a4@- */
	.short 0xffd2
	.short 0x05be
	.short 0xffd2
	.short 0xffff
	.short 0xa008
	btst d4,d0
	.short 0x800a
	.short 0x0000,0x06d8	/* orib #-40,d0 */
	.short 0xa00e
	.short 0x0600,0x9014	/* addib #20,d0 */
	.short 0x0001,0x9016	/* orib #22,d1 */
	.short 0x0002,0x8018	/* orib #24,d2 */
	.short 0x0000,0x06e8	/* orib #-24,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	moveal d0,a1
	movel a0,a1@(38)
	moveal 0x4,a0
	btst #1,a0@(297)
	beqs L0
	movel a1,d0
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	.short 0x022e,0x00f7,0x000e	/* andib #-9,a6@(14) */
	movel a6,d0
	rts
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes Lce
	btst #3,a6@(14)
	beqs Lce
	tstw a6@(32)
	bnes Lc8
	moveal a6,a1
	movel a6@(38),sp@-
	movel a6,sp@-
	moveal 0x4,a6
	jsr a6@(-252)
	moveal sp@,a0
	moveal sp@,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a0@(16),d0
	subal d0,a1
	addw a0@(18),d0
	jsr a6@(-210)
	moveal sp@+,a6
	movel sp@+,d0
	rts
Lc8:
	.short 0x002e,0x0008,0x000e	/* orib #8,a6@(14) */
Lce:
	.short 0x7000	/* moveq #0,d0 */
	rts
	lea %pc@(L680),a0
	movel a0,d0
	rts
	moveml d2-a0/a2-a6,sp@-
	moveml a0@,d4-d5/a0
	lea sp@(-156),sp
	.short 0x7000	/* moveq #0,d0 */
	movel d5,sp@(148)
	.short 0x7208	/* moveq #8,d1 */
	movel a0,sp@(140)
	rorw #4,d1
	moveal 0x4,a6
	.short 0x7401	/* moveq #1,d2 */
	rorw #4,d2
	jsr a6@(-696)
	tstl d0
	beqs L11c
	moveal d0,a0
	moveal d0,a4
	.short 0x7008	/* moveq #8,d0 */
	swap d0
	jsr a6@(-708)
	movel d0,sp@(132)
	bnes L122
L116:
	moveal a4,a0
	jsr a6@(-702)
L11c:
	.short 0x70f9	/* moveq #-7,d0 */
	braw L5d4
L122:
	moveal d0,a0
	.short 0x7002	/* moveq #2,d0 */
	swap d0
L128:
	clrl a0@+
	.short 0x5380	/* subql #1,d0 */
	bnes L128
	moveal sp@(140),a3
	movel a3,d0
	addl sp@(148),d0
	movel d0,sp@(140)
	movel a3,sp@(116)
	.short 0x584b	/* addqw #4,a3 */
	clrl sp@(120)
	.short 0x700f	/* moveq #15,d0 */
	movel d0,sp@(124)
	movel sp@(148),sp@(144)
	blew L5ac
	clrl sp@(62)
	clrl sp@(74)
L15e:
	moveal sp@(132),a2
	moveal d4,a0
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@+,d0
	.short 0x7a02	/* moveq #2,d5 */
	moveb a0@,d1
	eorl d0,d1
	lea a2@(4,d1:l:8),a2
	movel a2@,d0
	bnes L190
	moveal a4,a0
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-708)
	movel d0,a2@
	beqs L116
	.short 0x7202	/* moveq #2,d1 */
	movel d1,a2@-
	moveal d0,a2
	clrl a2@
	braw L236
L190:
	moveal d0,a2
	.short 0x7200	/* moveq #0,d1 */
	movel a2@+,d2
	bles L1ac
	moveal a2,a0
L19a:
	movel d4,d0
	subl a0@+,d0
	.short 0xb0bc,0x0000,0xffff	/* cmpl #65535,d0 */
	bles L1ac
	.short 0x5281	/* addql #1,d1 */
	cmpl d2,d1
	blts L19a
L1ac:
	tstl d1
	beqs L1c8
	subl d1,d2
	movel d2,d0
	lsll #2,d0
	beqs L1c4
	lea a2@(0,d1:l:4),a0
	moveal a2,a1
L1be:
	movel a0@+,a1@+
	.short 0x5980	/* subql #4,d0 */
	bnes L1be
L1c4:
	movel d2,a2@(-4)
L1c8:
	lea a2@(0,d2:l:4),a1
	.short 0x5382	/* subql #1,d2 */
	bmis L236
L1d0:
	moveal a1@-,a0
	moveal d4,a2
	movew a2@(0xffffffffffffffff,d5:w),d0
	cmpw a0@(0xffffffffffffffff,d5:w),d0
	bnes L22c
	movew a2@(1),d0
	cmpw a0@(1),d0
	bnes L22c
	lea a0@(3),a2
	moveal d4,a0
	.short 0x7006	/* moveq #6,d0 */
	.short 0x5648	/* addqw #3,a0 */
L1f2:
	cmpml a0@+,a2@+
	bnes L1fe
	.short 0x5840	/* addqw #4,d0 */
	.short 0xb07c,0x0104	/* cmpw #260,d0 */
	bles L1f2
L1fe:
	cmpw d0,d5
	bges L22c
	.short 0x594a	/* subqw #4,a2 */
	.short 0x5948	/* subqw #4,a0 */
	cmpmw a0@+,a2@+
	beqs L210
	.short 0x5540	/* subqw #2,d0 */
	.short 0x554a	/* subqw #2,a2 */
	.short 0x5548	/* subqw #2,a0 */
L210:
	moveb a2@,d3
	cmpb a0@,d3
	beqs L218
	.short 0x5340	/* subqw #1,d0 */
L218:
	cmpw d0,d5
	bges L22c
	movew d0,d5
	movel a2,d0
	subl a0,d0
	movel d0,sp@(108)
	.short 0xba7c,0x0101	/* cmpw #257,d5 */
	bhis L286
L22c:
	.short 0x5342	/* subqw #1,d2 */
	bccs L1d0
	clrw d2
	.short 0x5382	/* subql #1,d2 */
	bccs L1d0
L236:
	.short 0xba7c,0x0101	/* cmpw #257,d5 */
	bhiw L3fe
	movew d5,sp@(98)
	movel sp@(108),sp@(94)
	.short 0x7c01	/* moveq #1,d6 */
	clrl sp@(78)
	clrl sp@(82)
L252:
	moveal sp@(132),a2
	.short 0x5284	/* addql #1,d4 */
	moveal d4,a0
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@+,d1
	moveb a0@,d0
	eorl d0,d1
	lea a2@(4,d1:l:8),a2
	movel a2@,d0
	bnes L28e
	moveal a4,a0
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-708)
	movel d0,a2@
	beqw L116
	.short 0x7202	/* moveq #2,d1 */
	movel d1,a2@-
	moveal d0,a2
	clrl a2@
	braw L334
L286:
	.short 0x3a3c,0x0102	/* movew #258,d5 */
	braw L3fe
L28e:
	moveal d0,a2
	movel a2@+,d2
	bles L2c6
	.short 0x7200	/* moveq #0,d1 */
	moveal a2,a0
L298:
	movel d4,d0
	subl a0@+,d0
	.short 0xb0bc,0x0000,0xffff	/* cmpl #65535,d0 */
	bles L2aa
	.short 0x5281	/* addql #1,d1 */
	cmpl d2,d1
	blts L298
L2aa:
	tstl d1
	beqs L2c6
	subl d1,d2
	movel d2,d0
	lsll #2,d0
	beqs L2c2
	lea a2@(0,d1:l:4),a0
	moveal a2,a1
L2bc:
	movel a0@+,a1@+
	.short 0x5980	/* subql #4,d0 */
	bnes L2bc
L2c2:
	movel d2,a2@(-4)
L2c6:
	lea a2@(0,d2:l:4),a1
	.short 0x5382	/* subql #1,d2 */
	bmis L334
L2ce:
	moveal a1@-,a0
	moveal d4,a2
	movew a2@(0xffffffffffffffff,d5:w),d0
	cmpw a0@(0xffffffffffffffff,d5:w),d0
	bnes L32a
	movew a2@(1),d0
	cmpw a0@(1),d0
	bnes L32a
	lea a0@(3),a2
	moveal d4,a0
	.short 0x5648	/* addqw #3,a0 */
	.short 0x7006	/* moveq #6,d0 */
L2f0:
	cmpml a0@+,a2@+
	bnes L2fc
	.short 0x5840	/* addqw #4,d0 */
	.short 0xb07c,0x0104	/* cmpw #260,d0 */
	bles L2f0
L2fc:
	cmpw d0,d5
	bges L32a
	.short 0x594a	/* subqw #4,a2 */
	.short 0x5948	/* subqw #4,a0 */
	cmpmw a0@+,a2@+
	beqs L30e
	.short 0x5540	/* subqw #2,d0 */
	.short 0x554a	/* subqw #2,a2 */
	.short 0x5548	/* subqw #2,a0 */
L30e:
	moveb a2@,d3
	cmpb a0@,d3
	beqs L316
	.short 0x5340	/* subqw #1,d0 */
L316:
	cmpw d0,d5
	bges L32a
	movew d0,d5
	movel a2,d0
	subl a0,d0
	movel d0,sp@(108)
	.short 0xba7c,0x0101	/* cmpw #257,d5 */
	bhis L386
L32a:
	.short 0x5342	/* subqw #1,d2 */
	bccs L2ce
	clrw d2
	.short 0x5382	/* subql #1,d2 */
	bccs L2ce
L334:
	movew d5,sp@(84)
	movew d6,sp@(80)
	movel sp@(82),d0
	subl sp@(78),d0
	movew sp@(98),sp@(76)
	cmpl sp@(74),d0
	blew L3e4
	movew d5,sp@(98)
	movel sp@(108),sp@(94)
	.short 0x7a02	/* moveq #2,d5 */
	subl sp@(78),d4
	tstl d6
	beqs L3dc
L366:
	moveal sp@(132),a2
	moveal d4,a0
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@+,d0
	moveb a0@,d1
	eorl d0,d1
	lea a2@(0,d1:l:8),a5
	movel a5@,d0
	beqs L38c
	pea %pc@(L3a8)
	braw L49a
L386:
	.short 0x3a3c,0x0102	/* movew #258,d5 */
	bras L334
L38c:
	moveal a4,a0
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-708)
	movel d0,a5@(4)
	beqw L116
	.short 0x7202	/* moveq #2,d1 */
	moveal d0,a0
	movel d1,a5@
	.short 0x7201	/* moveq #1,d1 */
	movel d1,a0@+
	movel d4,a0@
L3a8:
	.short 0x53af,0x0094	/* subql #1,sp@(148) */
	moveal d4,a0
	moveb a0@,a3@+
	.short 0x5284	/* addql #1,d4 */
	.short 0x53af,0x007c	/* subql #1,sp@(124) */
	bpls L3d0
	moveal sp@(116),a0
	movel sp@(120),a0@
	movel a3,sp@(116)
	.short 0x584b	/* addqw #4,a3 */
	clrl sp@(120)
	.short 0x700f	/* moveq #15,d0 */
	movel d0,sp@(124)
L3d0:
	cmpal sp@(140),a3
	bhiw L5e6
	.short 0x5386	/* subql #1,d6 */
	bnes L366
L3dc:
	.short 0x0c6f,0x0101,0x0062	/* cmpiw #257,sp@(98) */
	bhis L430
L3e4:
	.short 0x5286	/* addql #1,d6 */
	.short 0xbc7c,0x0002	/* cmpw #2,d6 */
	bltw L252
	movel d6,d0
	.short 0x5380	/* subql #1,d0 */
	subl d0,d4
L3f4:
	movel sp@(94),sp@(108)
	movew sp@(98),d5
L3fe:
	cmpw sp@(150),d5
	blss L408
	movew sp@(150),d5
L408:
	.short 0x7000	/* moveq #0,d0 */
	movew d5,d0
	movel d0,d1
	.short 0x5781	/* subql #3,d1 */
	bmis L468
	.short 0x7003	/* moveq #3,d0 */
	cmpl d1,d0
	blts L434
	.byte 0x0c,0xaf,0xff,0xff,0xbf,0xff,0x00,0x6c	/* cmpil #-16385,sp@(108) */
	blss L434
	movew sp@(110),d0
	lslw #2,d0
	orw d1,d0
	movew d0,a3@+
	.short 0x7201	/* moveq #1,d1 */
	bras L45a
L430:
	.short 0x7c01	/* moveq #1,d6 */
	bras L3f4
L434:
	.short 0x700f	/* moveq #15,d0 */
	cmpl d1,d0
	blts L452
	.byte 0x0c,0xaf,0xff,0xff,0xef,0xff,0x00,0x6c	/* cmpil #-4097,sp@(108) */
	blss L452
	movew sp@(110),d0
	lslw #4,d0
	orw d1,d0
	movew d0,a3@+
	.short 0x7202	/* moveq #2,d1 */
	bras L45a
L452:
	movew sp@(110),a3@+
	moveb d1,a3@+
	.short 0x7203	/* moveq #3,d1 */
L45a:
	movel sp@(124),d0
	addl d0,d0
	lsll d0,d1
	orl d1,sp@(120)
	bras L46e
L468:
	moveal d4,a0
	moveb a0@,a3@+
	.short 0x7a01	/* moveq #1,d5 */
L46e:
	.short 0x7000	/* moveq #0,d0 */
	movew d5,d0
	subl d0,sp@(148)
	.short 0x5345	/* subqw #1,d5 */
	bmiw L580
L47c:
	moveal d4,a0
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@+,d0
	moveb a0@,d1
	eorl d1,d0
	moveal sp@(132),a0
	lea a0@(0,d0:l:8),a5
	movel a5@,d0
	beqw L55c
	pea %pc@(L578)
L49a:
	moveal d0,a2
	.short 0x7e00	/* moveq #0,d7 */
	movel a5,d3
	.short 0x5883	/* addql #4,d3 */
	moveal d3,a0
	moveal a0@,a0
	movel a0,sp@(54)
	movel a0@+,d2
	.short 0x223c,0x0000,0x0103	/* movel #259,d1 */
	movel d4,a0@(0,d2:l:4)
	.short 0x5282	/* addql #1,d2 */
	cmpl d1,d2
	blts L4da
	movel d4,d0
	lea a0@(0xfffffffffffffbf0,d2:l:4),a1
	subl a1@,d0
	cmpl d1,d0
	bnes L4da
	.short 0x5382	/* subql #1,d2 */
	.short 0x303c,0x0408	/* movew #1032,d0 */
	lea a1@(4),a0
L4d4:
	movel a0@+,a1@+
	.short 0x5940	/* subqw #4,d0 */
	bnes L4d4
L4da:
	cmpal d2,a2
	bgts L4ea
	.short 0x7e40	/* moveq #64,d7 */
	.short 0x703f	/* moveq #63,d0 */
	cmpl a2,d0
	blts L50e
	movel a2,d7
	bras L510
L4ea:
	.short 0x7001	/* moveq #1,d0 */
	cmpl d2,d0
	bges L50e
	movel a2,d1
	asrl #1,d1
	cmpl d2,d1
	blts L50e
	.short 0x7040	/* moveq #64,d0 */
	cmpl a2,d0
	bges L502
	.short 0x7ec0	/* moveq #-64,d7 */
	bras L512
L502:
	moveal d0,a2
	.short 0x7001	/* moveq #1,d0 */
	cmpl a2,d0
	blts L50e
	.short 0x7e02	/* moveq #2,d7 */
	subl a2,d7
L50e:
	tstl d7
L510:
	beqs L554
L512:
	addal d7,a2
	movel a2,d0
	lsll #2,d0
	moveal a4,a0
	.short 0x5080	/* addql #8,d0 */
	jsr a6@(-708)
	movel d0,sp@(54)
	beqw L116
	moveal d0,a1
	movel d2,d0
	moveal d3,a0
	lsll #2,d0
	moveal a0@,a0
	movel a0@+,a1@+
L534:
	movel a0@+,a1@+
	.short 0x5980	/* subql #4,d0 */
	bnes L534
	movel a5@,d0
	.short 0x5280	/* addql #1,d0 */
	moveal a4,a0
	lsll #2,d0
	moveal d3,a1
	moveal a1@,a1
	.short 0x5880	/* addql #4,d0 */
	jsr a6@(-714)
	moveal d3,a0
	movel sp@(54),a0@
	movel a2,a5@
L554:
	moveal sp@(54),a0
	movel d2,a0@
	rts
L55c:
	moveal a4,a0
	.short 0x7010	/* moveq #16,d0 */
	jsr a6@(-708)
	movel d0,a5@(4)
	beqw L116
	.short 0x7202	/* moveq #2,d1 */
	moveal d0,a0
	movel d1,a5@
	.short 0x7201	/* moveq #1,d1 */
	movel d1,a0@+
	movel d4,a0@
L578:
	.short 0x5284	/* addql #1,d4 */
	.short 0x5345	/* subqw #1,d5 */
	bccw L47c
L580:
	.short 0x53af,0x007c	/* subql #1,sp@(124) */
	bpls L59e
	moveal sp@(116),a0
	movel sp@(120),a0@
	movel a3,sp@(116)
	.short 0x584b	/* addqw #4,a3 */
	clrl sp@(120)
	.short 0x700f	/* moveq #15,d0 */
	movel d0,sp@(124)
L59e:
	cmpal sp@(140),a3
	bhis L5e6
	tstl sp@(148)
	bgtw L15e
L5ac:
	movel sp@(124),d1
	addl d1,d1
	.short 0x7003	/* moveq #3,d0 */
	lsll d1,d0
	orl sp@(120),d0
	moveal sp@(116),a0
	movel d0,a0@
	clrw a3@+
	movel sp@(140),d1
	subl sp@(144),d1
	subal d1,a3
L5cc:
	moveal a4,a0
	jsr a6@(-702)
	movel a3,d0
L5d4:
	lea sp@(156),sp
	moveml sp@+,d2-a0/a2-a6
	blts L5e4
	movel d0,a0@(16)
	.short 0x7000	/* moveq #0,d0 */
L5e4:
	rts
L5e6:
	.short 0x367c,0xffef	/* moveaw #-17,a3 */
	bras L5cc
	moveml d2-d3/a2,sp@-
	moveal a0@,a1
	.short 0x72ff	/* moveq #-1,d1 */
	moveal a0@(8),a0
	.short 0x70ff	/* moveq #-1,d0 */
L5fa:
	movel a1@+,d2
	beqs L610
	.short 0x760f	/* moveq #15,d3 */
L600:
	addl d2,d2
	bcss L636
	addl d2,d2
	bcss L61a
	moveb a1@+,a0@+
	.short 0x5343	/* subqw #1,d3 */
	bccs L600
	bras L5fa
L610:
	movel a1@+,a0@+
	movel a1@+,a0@+
	movel a1@+,a0@+
	movel a1@+,a0@+
	bras L5fa
L61a:
	movew a1@+,d1
	movew d1,d0
	asrl #2,d1
	lea a0@(0,d1:l),a2
	.short 0xc03c,0x0003	/* andb #3,d0 */
	.short 0x5600	/* addqb #3,d0 */
L62a:
	moveb a2@+,a0@+
	.short 0x5300	/* subqb #1,d0 */
	bnes L62a
	.short 0x5343	/* subqw #1,d3 */
	bccs L600
	bras L5fa
L636:
	addl d2,d2
	bcss L652
	movew a1@+,d1
	movew d1,d0
	asrl #4,d1
	.short 0xc07c,0x000f	/* andw #15,d0 */
	bgts L65a
	lea a0@(0,d1:l),a2
	.short 0x7003	/* moveq #3,d0 */
	bras L62a
L64e:
	.short 0x7008	/* moveq #8,d0 */
	bras L668
L652:
	movew a1@+,d1
	beqs L678
	.short 0x7000	/* moveq #0,d0 */
	moveb a1@+,d0
L65a:
	lea a0@(0,d1:l),a2
	movew d0,d1
	lsrw #3,d1
	.short 0xc03c,0x0007	/* andb #7,d0 */
	.short 0x5600	/* addqb #3,d0 */
L668:
	moveb a2@+,a0@+
	.short 0x5300	/* subqb #1,d0 */
	bnes L668
	.short 0x5341	/* subqw #1,d1 */
	bccs L64e
	.short 0x5343	/* subqw #1,d3 */
	bccs L600
	bras L5fa
L678:
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d2-d3/a2
	rts
L680:
	.short 0x0001,0x0001	/* orib #1,d1 */
	.short 0x0002,0x0000	/* orib #0,d2 */
	.short 0x0000,0x0704	/* orib #4,d0 */
	.short 0x0000,0x0724	/* orib #36,d0 */
	.short 0x0000,0x0751	/* orib #81,d0 */
	.short 0x5444	/* addqw #2,d4 */
	.short 0x4353
	.short 0x0000,0x8009	/* orib #9,d0 */
	.short 0x7fff
	.short 0xffff
	.short 0x0000,0x0004	/* orib #4,d0 */
	.short 0x0004,0xffff	/* orib #-1,d4 */
	.short 0x0000,0x0785	/* orib #-123,d0 */
	.short 0x0000,0x07ad	/* orib #-83,d0 */
	.short 0x0000,0x07d4	/* orib #-44,d0 */
	.short 0x0000,0x07e8	/* orib #-24,d0 */
	.short 0x0064,0x0000	/* oriw #0,a4@- */
	.byte 0x00,0x00,0x07,0xf8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #-8,d0 */
	.short 0x7870	/* moveq #112,d4 */
	bmis L730
	negw d3
	.short 0x532e,0x6c69	/* subqb #1,a6@(27753) */
	bhis L756
	bsrs L758
	.short 0x7900
	.short 0x7870	/* moveq #112,d4 */
	bmis L740
	negw d3
	.short 0x5320	/* subqb #1,a0@- */
	movew a6@(12832),a0@-
	.byte 0x28,0x32,0x30,0x2e	/* movel a2@(2e,d3:w),d4 */
	.byte 0x30,0x31,0x2e,0x32	/* movew a1@(32,d2:l:8),d0 */
	.byte 0x30,0x31,0x32,0x29	/* movew a1@(29,d3:w:2),d0 */
	.byte 0x0d,0x0a,0x00,0x00	/* movepw a2@(0),d6 */
	.byte 0x54,0x68,0x65,0x20	/* addqw #2,a0@(25888) */
	.byte 0x44,0x6f,0x6f,0x6d	/* negw sp@(28525) */
	.byte 0x20,0x74,0x68,0x61	/* moveal a4@(61,d6:l),a0 */
	.byte 0x74,0x20	/* moveq #32,d2 */
	.byte 0x43,0x61	/* .short 0x4361 */
	.byte 0x6d,0x65	/* blts 0x77b */
	.byte 0x20,0x6f,0x76,0x65	/* moveal sp@(30309),a0 */
	.byte 0x72,0x20	/* moveq #32,d1 */
	.byte 0x53,0x61	/* subqw #1,a1@- */
	.byte 0x72,0x6e	/* moveq #110,d1 */
	.byte 0x61,0x74	/* bsrs 0x796 */
	.byte 0x68,0x00,0x4c,0x65	/* bvcw 0x5389 */
	.byte 0x6d,0x70	/* blts 0x798 */
	.byte 0x65,0x6c	/* bcss 0x796 */
	.byte 0x2d,0x5a,0x69,0x76	/* movel a2@+,a6@(26998) */
	.byte 0x2d,0x37
L730:
	.byte 0x37,0x20,0x69,0x6d	/* movel sp@(696d,d3:w:8),a6@- */
	.byte 0x70,0x6c	/* moveq #108,d0 */
	.byte 0x65,0x6d	/* bcss 0x7a5 */
	.byte 0x65,0x6e	/* bcss 0x7a8 */
	.byte 0x74,0x61	/* moveq #97,d2 */
	.byte 0x74,0x69	/* moveq #105,d2 */
	.byte 0x6f,0x6e	/* bles 0x7ae */
L740:
	.byte 0x20,0x77,0x69,0x74,0x68,0x20,0x62,0x69	/* moveal sp@(68206269)@(0),a0 */
	.byte 0x67,0x20	/* beqs 0x76a */
	.byte 0x77,0x69	/* .short 0x7769 */
	.byte 0x6e,0x64	/* bgts 0x7b2 */
	.byte 0x6f,0x77	/* bles 0x7c7 */
	.byte 0x00,0x42,0x61,0x73	/* oriw #24947,d2 */
	.byte 0x65,0x64	/* bcss 0x7ba */
L756:
	.byte 0x20,0x75
L758:
	.byte 0x70,0x6f	/* moveal a5@(6f,d7:w),a0 */
	.byte 0x6e,0x20	/* bgts 0x77c */
	.byte 0x73,0x6f	/* .short 0x736f */
	.byte 0x6d,0x65	/* blts 0x7c5 */
	.byte 0x20,0x65	/* moveal a5@-,a0 */
	.byte 0x78,0x70	/* moveq #112,d4 */
	.byte 0x65,0x72	/* bcss 0x7d8 */
	.byte 0x69,0x6d	/* bvss 0x7d5 */
	.byte 0x65,0x6e	/* bcss 0x7d8 */
L76a:
	.byte 0x74,0x73	/* moveq #115,d2 */
	.byte 0x20,0x77,0x69,0x74,0x68,0x20,0x70,0x61	/* moveal sp@(68207061)@(0),a0 */
	.byte 0x63,0x6b	/* blss 0x7e1 */
	.byte 0x65,0x72	/* bcss 0x7ea */
	.byte 0x2c,0x20	/* movel a0@-,d6 */
	.byte 0xa9
L77b:
	.byte 0x44	/* .short 0xa944 */
L77c:
	.byte 0x59,0x4e	/* subqw #4,a6 */
	.byte 0x41,0x2d,0x54,0x65	/* chkl a5@(21605),d0 */
	.byte 0x63,0x68	/* blss 0x7ec */
	.byte 0x00,0x28,0x61,0x6e,0x6e,0x69	/* orib #110,a0@(28265) */
	.byte 0x68,0x69	/* bvcs 0x7f5 */
	.byte 0x6c,0x61	/* bges 0x7ef */
	.byte 0x74,0x65	/* moveq #101,d2 */
	.byte 0x29,0x20	/* movel a0@-,a4@- */
	.byte 0x45,0x76	/* .short 0x4576 */
	.byte 0x65,0x6e	/* bcss 0x804 */
L796:
	.byte 0x20,0x65	/* moveal a5@-,a0 */
L798:
	.byte 0x74,0x65	/* moveq #101,d2 */
	.byte 0x72,0x6e	/* moveq #110,d1 */
	.byte 0x69,0x74	/* bvss 0x812 */
	.byte 0x79,0x20	/* .short 0x7920 */
	.byte 0x77,0x69	/* .short 0x7769 */
	.byte 0x6c,0x6c	/* bges 0x810 */
	.byte 0x20
L7a5:
	.byte 0x64	/* moveal a4@-,a0 */
	.byte 0x69,0x65	/* bvss 0x80d */
L7a8:
	.byte 0x20,0x2e,0x2e,0x2e	/* movel a6@(11822),d0 */
	.byte 0x00,0x28
L7ae:
	.byte 0x72,0x65,0x61,0x6e	/* orib #101,a0@(24942) */
L7b2:
	.byte 0x69,0x6d	/* bvss 0x821 */
	.byte 0x61,0x74	/* bsrs 0x82a */
	.byte 0x65,0x2e	/* bcss 0x7e6 */
	.byte 0x29,0x20	/* movel a0@-,a4@- */
L7ba:
	.byte 0x49,0x20	/* chkl a0@-,d4 */
	.byte 0x67,0x6f	/* beqs 0x82d */
	.byte 0x74,0x20	/* moveq #32,d2 */
	.byte 0x69,0x74	/* bvss 0x836 */
	.byte 0x2c,0x20	/* movel a0@-,d6 */
	.byte 0x79
L7c5:
	.byte 0x65	/* .short 0x7965 */
	.byte 0x61
L7c7:
	.byte 0x68	/* bsrs 0x830 */
	.byte 0x2c,0x20	/* movel a0@-,d6 */
	.byte 0x2e,0x2e,0x2e,0x20	/* movel a6@(11808),d7 */
	.byte 0x72,0x65	/* moveq #101,d1 */
	.byte 0x61,0x64	/* bsrs 0x836 */
	.byte 0x79,0x00	/* .short 0x7900 */
	.byte 0x4f
L7d5:
	.byte 0x68	/* .short 0x4f68 */
	.byte 0x20,0x67	/* moveal sp@-,a0 */
L7d8:
	.byte 0x6f,0x64	/* bles 0x83e */
	.byte 0x2c,0x20	/* movel a0@-,d6 */
	.byte 0x49,0x74	/* .short 0x4974 */
	.byte 0x20,0x69,0x73
L7e1:
	.byte 0x20	/* moveal a1@(29472),a0 */
	.byte 0x64,0x6f	/* bccs 0x853 */
	.byte 0x6e,0x65	/* bgts 0x84b */
L7e6:
	.byte 0x21,0x00	/* movel d0,a0@- */
	.byte 0x48,0x65	/* .short 0x4865 */
L7ea:
	.byte 0x68,0x65	/* bvcs 0x851 */
L7ec:
	.byte 0x2c,0x20	/* movel a0@-,d6 */
	.byte 0x66
L7ef:
	.byte 0x61	/* bnes 0x851 */
	.byte 0x73,0x74	/* .short 0x7374 */
	.byte 0x20,0x68,0x65
L7f5:
	.byte 0x77	/* moveal a0@(25975),a0 */
	.byte 0x2e,0x00	/* movel d0,d7 */
	.byte 0x00,0x00,0x00,0x00	/* orib #0,d0 */
	.byte 0x00,0x00,0x00,0x31	/* orib #49,d0 */
	.byte 0x00,0x00,0x00,0x01	/* orib #1,d0 */
L804:
	.byte 0x00,0x08	/* .short 0x0008 */
	.byte 0x00,0xa0,0x00,0x00,0x00,0x00	/* oril #0,a0@- */
	.byte 0x00
L80d:
	.byte 0x00,0x00,0x14	/* orib #20,d0 */
L810:
	.byte 0x00,0x00
L812:
	.byte 0x05,0xdc	/* orib #-36,d0 */
	.byte 0x01,0xf4,0x00,0x00	/* bset d0,a4@(0,d0:w) */
	.byte 0x64,0x69	/* bccs 0x883 */
	.byte 0x72,0x65	/* moveq #101,d1 */
	.byte 0x63,0x74	/* blss 0x892 */
	.byte 0x20,0x6d,0x61
L821:
	.byte 0x74	/* moveal a5@(24948),a0 */
	.byte 0x63,0x68	/* blss 0x88c */
