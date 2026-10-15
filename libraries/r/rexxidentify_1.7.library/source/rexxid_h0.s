	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0d,0xf0,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x33,0x00,0x00,0x00,0xde,0x72,0x65
	.byte 0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x00,0x72,0x65,0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x31,0x2e,0x37,0x20,0x28,0x33,0x30,0x2e
	.byte 0x31,0x30,0x2e,0x39,0x37,0x29,0x0d,0x0a,0x00,0x72,0x65,0x78,0x78,0x69,0x64,0x65
	.byte 0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x56,0x31
	.byte 0x2e,0x37,0x20,0x20,0x41,0x52,0x65,0x78,0x78,0x20,0x73,0x75,0x70,0x70,0x6f,0x72
	.byte 0x74,0x20,0x66,0x6f,0x72,0x20,0x74,0x68,0x65,0x20,0x69,0x64,0x65,0x6e,0x74,0x69
	.byte 0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x20,0x20,0x20,0x28,0x43
	.byte 0x29,0x20,0x31,0x39,0x39,0x37,0x20,0x52,0x69,0x63,0x68,0x61,0x72,0x64,0x20,0x4b
	.byte 0xf6,0x72,0x62,0x65,0x72,0x20,0x20,0x20,0x20,0x20,0x65,0x2d,0x6d,0x61,0x69,0x6c
	.byte 0x3a,0x20,0x73,0x68,0x72,0x65,0x64,0x40,0x63,0x68,0x65,0x73,0x73,0x79,0x2e,0x61
	.byte 0x77,0x6f,0x72,0x6c,0x64,0x2e,0x64,0x65,0x20,0x20,0x20,0x0d,0x0a,0x00,0x00,0x00
	.byte 0x00,0x2c,0x00,0x00,0x00,0xee,0x00,0x00,0x01,0x06,0x00,0x00,0x01,0x26,0x00,0x00
	.byte 0x02,0x36,0x00,0x00,0x02,0x44,0x00,0x00,0x02,0x58,0x00,0x00,0x02,0xd0,0x00,0x00
	.byte 0x02,0xd4,0xff,0xff,0xff,0xff,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e
	.byte 0xa0,0x0e,0x06,0x00,0x90,0x14,0x00,0x01,0x90,0x16,0x00,0x06,0x80,0x18,0x00,0x00
	.byte 0x00,0x33,0x00,0x00,0x00,0x00
	moveml d1-a6,sp@-
	moveal d0,a5
L12c:
	movel a6,a5@(36)
	.byte 0x2b,0x48
L132:
	.byte 0x00,0x28	/* movel a0,a5@(40) */
	lea %pc@(L1ec),a1
	.short 0x7021	/* moveq #33,d0 */
	.byte 0x2c,0x78,0x00
L13d:
	.byte 0x04	/* moveal 0x4,a6 */
	.byte 0x4e
L13f:
	.byte 0xae,0xfd,0xd8	/* jsr a6@(-552) */
	.short 0x23c0,0x0000,0x0de4	/* movel d0,0xde4 */
	beqw L1e6
	lea %pc@(L1ff),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0de0	/* movel d0,0xde0 */
	beqw L1da
	lea %pc@(L211),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0de8	/* movel d0,0xde8 */
	beqw L1ce
	lea %pc@(L225),a1
	.short 0x7008	/* moveq #8,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0ddc	/* movel d0,0xddc */
	beqw L1c2
	subal a0,a0
	.short 0x45f9,0x0000,0x0000	/* lea 0x0,a2 */
	.short 0x74ff	/* moveq #-1,d2 */
L19e:
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x72ff	/* moveq #-1,d1 */
	moveal %pc@(Lde0),a6
	jsr a6@(-72)
	.short 0x5242	/* addqw #1,d2 */
	moveal d0,a0
	movel d0,a2@+
	bnew L19e
	.short 0x33c2,0x0000,0x0dec	/* movew d2,0xdec */
	movel a5,d0
L1bc:
	moveml sp@+,d1-a6
	rts
L1c2:
	moveal %pc@(Lde8),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1ce:
	moveal %pc@(Lde0),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1da:
	moveal %pc@(Lde4),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1e6:
	.short 0x7000	/* moveq #0,d0 */
	braw L1bc
L1ec:
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7878	/* moveq #120,d4 */
	.short 0x7379	/* .short 0x7379 */
	.short 0x736c	/* .short 0x736c */
	bvss L258
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L1ff:
	.byte 0x65,0x78,0x70	/* oriw #30832,a5@- */
	bsrs L272
	.short 0x7369	/* .short 0x7369 */
	bles L276
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L211:
	.byte 0x63,0x6f,0x6d	/* oriw #28525,a3@- */
	blts L285
	bccs L281
	.short 0x7469	/* moveq #105,d2 */
	bcss L28f
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L225:
	.byte 0x69,0x64,0x65,0x6e,0x74	/* oriw #25701,a1@(28276) */
	bvss L292
	.short 0x792e	/* .short 0x792e */
	bges L299
	bhis L2a4
	bsrs L2a6
	.short 0x7900	/* .short 0x7900 */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #0,a6@(35)
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L256
	btst #0,a6@(35)
	beqs L256
	bsrs L258
L256:
	rts
L258:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(36),a6
	tstw a5@(32)
	beqs L274
	bset #0,a5@(35)
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x60,0x00
L272:
	.byte 0x00,0x58	/* braw 0x2ca */
L274:
	.byte 0x24,0x2d
L276:
	.byte 0x00,0x28	/* movel a5@(40),d2 */
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae,0xff
L281:
	.byte 0x04	/* jsr a6@(-252) */
	.byte 0x22,0x7a,0x0b
L285:
	.byte 0x58	/* moveal %pc@(0xddc),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.byte 0x22
L28f:
	.byte 0x7a,0x0b,0x58	/* moveal %pc@(0xde8),a1 */
L292:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae,0xfe
L299:
	.byte 0x62	/* jsr a6@(-414) */
	moveal %pc@(Lde0),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae
L2a4:
	.byte 0xfe,0x62	/* jsr a6@(-414) */
L2a6:
	moveal %pc@(Lde4),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.short 0x7000	/* moveq #0,d0 */
	moveal a5,a1
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	movel d2,d0
L2ca:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d1-d7/a1-a6,sp@-
	moveal a0,a5
	moveal a5@(40),a0
	lea %pc@(L338),a1
	bsrw Lc70
	tstl d0
	bmiw L300
	addl d0,d0
	addl d0,d0
	lea %pc@(L308),a4
	.short 0x2874,0x0800	/* moveal a4@(0,d0:l),a4 */
	jsr a4@
L2fa:
	moveml sp@+,d1-d7/a1-a6
	rts
L300:
	.short 0x7001	/* moveq #1,d0 */
	subal a0,a0
	braw L2fa
L308:
	.short 0x0000,0x03be	/* orib #-66,d0 */
	.short 0x0000,0x03ee	/* orib #-18,d0 */
	.short 0x0000,0x0410	/* orib #16,d0 */
	.short 0x0000,0x06d6	/* orib #-42,d0 */
	.short 0x0000,0x0902	/* orib #2,d0 */
	.short 0x0000,0x0976	/* orib #118,d0 */
	.short 0x0000,0x05f4	/* orib #-12,d0 */
	.short 0x0000,0x0a18	/* orib #24,d0 */
	.short 0x0000,0x0a74	/* orib #116,d0 */
	.short 0x0000,0x0adc	/* orib #-36,d0 */
	.short 0x0000,0x0c0a	/* orib #10,d0 */
	.short 0x0000,0x0c62	/* orib #98,d0 */
L338:
	.short 0x4944	/* .short 0x4944 */
	.short 0x5f52	/* subqw #7,a2@ */
	.short 0x454c	/* .short 0x454c */
	.short 0x4541	/* .short 0x4541 */
	.short 0x5345	/* subqw #1,d5 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	linkw a5,#19778
	.short 0x4f41	/* .short 0x4f41 */
	.short 0x5244	/* addqw #1,d4 */
	.short 0x5300	/* subqb #1,d0 */
	.short 0x4944	/* .short 0x4944 */
	.short 0x5f45	/* subqw #7,d5 */
	.short 0x5850	/* addqw #4,a0@ */
	.short 0x414e	/* .short 0x414e */
	.short 0x5349	/* subqw #1,a1 */
	.short 0x4f4e	/* .short 0x4f4e */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	swap d1
	.short 0x5244	/* addqw #1,d4 */
	.short 0x5741	/* subqw #3,d1 */
	.short 0x5245	/* addqw #1,d5 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	notw a5@
	trap #3
	.short 0x5449	/* addqw #2,a1 */
	.short 0x4f4e	/* .short 0x4f4e */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	.short 0x414c	/* .short 0x414c */
	.short 0x4552	/* .short 0x4552 */
	.short 0x5400	/* addqb #2,d0 */
	.short 0x4944	/* .short 0x4944 */
	.short 0x5f45	/* subqw #7,d5 */
	.short 0x5850	/* addqw #4,a0@ */
	trap #1
	.short 0x4d45	/* .short 0x4d45 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	.short 0x4c4f	/* .short 0x4c4f */
	.short 0x434b	/* .short 0x434b */
	.short 0x4358	/* .short 0x4358 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	.short 0x434f	/* .short 0x434f */
	.short 0x554e	/* subqw #2,a6 */
	.short 0x5443	/* addqw #2,d3 */
	.short 0x5800	/* addqb #4,d0 */
	.short 0x4944	/* .short 0x4944 */
	.short 0x5f47	/* subqw #7,d7 */
	.short 0x4554	/* .short 0x4554 */
	.short 0x4358	/* .short 0x4358 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	.short 0x554e	/* subqw #2,a6 */
	.short 0x4c4f	/* .short 0x4c4f */
	.short 0x434b	/* .short 0x434b */
	.short 0x4358	/* .short 0x4358 */
	.short 0x0049	/* .short 0x0049 */
	negw sp@+
	.short 0x5550	/* subqw #2,a0@ */
	negw d1
	.short 0x5445	/* addqw #2,d5 */
	.short 0x0000,0x41fa	/* orib #-6,d0 */
	.short 0x001e,0x2008	/* orib #8,a6@+ */
L3c4:
	tstb a0@+
	bnew L3c4
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
	movew a0@-,d3
	movew a6@(14120),a0@-
	movew a0@(0x31,d2:l:0x8),a1@-
	movew a6@(14647),d0
	movel d0,a4@-
	linkw a4,#-20
	.short 0x7000	/* moveq #0,d0 */
	movew %pc@(Ldec),d0
	lea a4@(-20),a0
	bsrw Lcce
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	unlk a4
	rts
	linkw a4,#-58
	movel a5@(44),d0
	beqw L5a2
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw L430
	tstb a0@
	bnew L5a2
L430:
	.short 0x7200	/* moveq #0,d1 */
	movew %pc@(Ldec),d1
	cmpl d1,d0
	bhiw L5a2
	addl d0,d0
	addl d0,d0
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	.short 0x2970,0x0800,0xffca	/* movel a0@(0,d0:l),a4@(-54) */
	movel a5@(48),d0
	beqw L5a2
	moveal d0,a0
	lea %pc@(L5bc),a1
	bsrw Lc70
	tstl d0
	bmiw L5a2
	.short 0x5780	/* subql #3,d0 */
	bcsw L554
	.short 0x5380	/* subql #1,d0 */
	bcsw L48c
	.short 0x5380	/* subql #1,d0 */
	bcsw L4a0
	.short 0x5380	/* subql #1,d0 */
	bcsw L4b8
	.short 0x5380	/* subql #1,d0 */
	bcsw L50a
	.short 0x5380	/* subql #1,d0 */
	bcsw L4d6
	braw L5a2
L48c:
	moveal a4@(-54),a0
	movel a0@(32),d0
	lea a4@(-50),a0
	bsrw Ld0e
	braw L584
L4a0:
	moveal a4@(-54),a0
	movel a0@(36),d0
	lea a4@(-50),a0
	lsrl #8,d0
	lsrl #2,d0
	bsrw Lcce
	braw L584
L4b8:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(14),d0
	btst #0,d0
	sne d0
	negb d0
	lea a4@(-50),a0
	bsrw Lcce
	braw L584
L4d6:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-58)
	.short 0x4879,0xcd45,0x000e	/* pea 0xcd45000e */
	moveal sp,a0
	moveal %pc@(Lddc),a6
	jsr a6@(-30)
	moveal d7,sp
	lea a4@(-50),a0
	movel a4@(-58),d0
	bsrw Lcce
	braw L584
L50a:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0x4879,0xcd45,0x0005	/* pea 0xcd450005 */
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x000d	/* pea 0xcd45000d */
	moveal sp,a0
	moveal %pc@(Lddc),a6
	jsr a6@(-30)
	moveal d7,sp
	lea %pc@(L5b2),a0
	.short 0x0c80,0xffff,0xfff9	/* cmpil #-7,d0 */
	beqw L584
	lea %pc@(L5aa),a0
	tstl d0
	beqw L584
	braw L5a2
L554:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0x0680,0xcd45,0x0007	/* addil #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Lddc),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnew L5a2
	lea a4@(-50),a0
L584:
	movel a0,d0
L586:
	tstb a0@+
	bnew L586
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L59e:
	unlk a4
	rts
L5a2:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw L59e
L5aa:
	.short 0x5072,0x696d,0x6172	/* addqw #8,a2@(6172)@(0) */
	.short 0x7900	/* .short 0x7900 */
L5b2:
	.short 0x5365	/* subqw #1,a5@- */
	blss L625
	bgts L61c
	bsrs L62c
	.short 0x7900	/* .short 0x7900 */
L5bc:
	.short 0x4d41	/* .short 0x4d41 */
	linkw a5,#17920
	.short 0x5052	/* addqw #8,a2@ */
	.short 0x4f44	/* .short 0x4f44 */
	.short 0x0043,0x4c41	/* oriw #19521,d3 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x0041,0x4444	/* oriw #17476,d1 */
	.short 0x5245	/* addqw #1,d5 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x0053,0x495a	/* oriw #18778,a3@ */
	chkl d0,d2
	.short 0x5348	/* subqw #1,a0 */
	.short 0x5554	/* subqw #2,a4@ */
	.short 0x5550	/* subqw #2,a0@ */
	.short 0x0053,0x4543	/* oriw #17731,a3@ */
	.short 0x4f4e	/* .short 0x4f4e */
	negw d1
	.short 0x5259	/* addqw #1,a1@+ */
	.short 0x0043,0x4c41	/* oriw #19521,d3 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x4944	/* .short 0x4944 */
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffc6	/* .short 0xffc6 */
	movel a5@(44),d0
	beqw L6bc
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw L614
	tstb a0@
	bnew L6bc
L614:
	.short 0x0c80,0x0000,0xffff	/* cmpil #65535,d0 */
	.byte 0x62,0x00
L61c:
	.byte 0x00,0xa0	/* bhiw 0x6bc */
	movel d0,a4@(-54)
	.byte 0x20,0x2d,0x00
L625:
	.byte 0x30	/* movel a5@(48),d0 */
	beqw L6bc
	moveal d0,a0
L62c:
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw L63e
	tstb a0@
	bnew L6bc
L63e:
	.short 0x0c80,0x0000,0x00ff	/* cmpil #255,d0 */
	bhiw L6bc
	movel d0,a4@(-58)
	movel a5@(52),d0
	beqw L6bc
	moveal d0,a0
	lea %pc@(L6c4),a1
	bsrw Lc70
	tstl d0
	bmiw L6bc
	movel sp,d7
	clrl sp@-
	movel a4@(-58),sp@-
	.short 0x4879,0xcd45,0x0002	/* pea 0xcd450002 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0001	/* pea 0xcd450001 */
	pea a4@(-50)
	.short 0x0680,0xcd45,0x0004	/* addil #-851116028,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Lddc),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnew L6bc
	lea a4@(-50),a0
	movel a0,d0
L6a0:
	tstb a0@+
	bnew L6a0
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L6b8:
	unlk a4
	rts
L6bc:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw L6b8
L6c4:
	.short 0x4d41	/* .short 0x4d41 */
	linkw a5,#17920
	.short 0x5052	/* addqw #8,a2@ */
	.short 0x4f44	/* .short 0x4f44 */
	.short 0x0043,0x4c41	/* oriw #19521,d3 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffcc	/* .short 0xffcc */
	sf a4@(-1)
	sf a4@(-2)
	movel a5@(28),d1
	lea a5@(48),a3
L6ea:
	.short 0x5301	/* subqb #1,d1 */
	beqw L726
	movel a3@+,d0
	beqw L6ea
	moveal d0,a0
	lea %pc@(L8ef),a1
	bsrw Lc70
	tstl d0
	bmiw L79a
	.short 0x5380	/* subql #1,d0 */
	bcsw L716
	.short 0x5380	/* subql #1,d0 */
	bcsw L71e
	braw L6ea
L716:
	st a4@(-1)
	braw L6ea
L71e:
	st a4@(-2)
	braw L6ea
L726:
	movel a5@(44),d0
	beqw L79a
	moveal d0,a0
	lea %pc@(L7a2),a1
	bsrw Lc70
	tstl d0
	bmiw L79a
	moveal sp,a3
	clrl sp@-
	tstb a4@(-1)
	beqw L754
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x0010	/* pea 0xcd450010 */
L754:
	tstb a4@(-2)
	beqw L764
	clrl sp@-
	.short 0x4879,0xcd45,0x000f	/* pea 0xcd45000f */
L764:
	moveal sp,a0
	moveal %pc@(Lddc),a6
	jsr a6@(-36)
	moveal a3,sp
	moveal d0,a0
	tstl d0
	bnew L77c
	lea %pc@(L901),a0
L77c:
	movel a0,d0
L77e:
	tstb a0@+
	bnew L77e
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L796:
	unlk a4
	rts
L79a:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw L796
L7a2:
	.short 0x5359	/* subqw #1,a1@+ */
	.short 0x5354	/* subqw #1,a4@ */
	.short 0x454d	/* .short 0x454d */
	.short 0x0043,0x5055	/* oriw #20565,d3 */
	.short 0x0046,0x5055	/* oriw #20565,d6 */
	.short 0x004d	/* .short 0x004d */
	.short 0x4d55	/* .short 0x4d55 */
	.short 0x004f	/* .short 0x004f */
	.short 0x5356	/* subqw #1,a6@ */
	.short 0x4552	/* .short 0x4552 */
	.short 0x0045,0x5845	/* oriw #22597,d5 */
	.short 0x4356	/* .short 0x4356 */
	.short 0x4552	/* .short 0x4552 */
	.short 0x0057,0x4256	/* oriw #16982,sp@ */
	.short 0x4552	/* .short 0x4552 */
	.short 0x0052,0x4f4d	/* oriw #20301,a2@ */
	.short 0x5349	/* subqw #1,a1 */
	.short 0x5a45	/* addqw #5,d5 */
	.short 0x0043,0x4849	/* oriw #18505,d3 */
	.short 0x5053	/* addqw #8,a3@ */
	.short 0x4554	/* .short 0x4554 */
	.short 0x0047,0x4658	/* oriw #18008,d7 */
	.short 0x5359	/* subqw #1,a1@+ */
	.short 0x5300	/* subqb #1,d0 */
	.short 0x4348	/* .short 0x4348 */
	.short 0x4950	/* .short 0x4950 */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	notw d1
	.short 0x5354	/* subqw #1,a4@ */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x5345	/* subqw #1,d5 */
	.short 0x5450	/* addqw #2,a0@ */
	.short 0x4154	/* .short 0x4154 */
	.short 0x4348	/* .short 0x4348 */
	.short 0x5645	/* addqw #3,d5 */
	.short 0x5200	/* addqb #1,d0 */
	.short 0x4155	/* .short 0x4155 */
	.short 0x4449	/* .short 0x4449 */
	.short 0x4f53	/* .short 0x4f53 */
	.short 0x5953	/* subqw #4,a3@ */
	.short 0x004f	/* .short 0x004f */
	.short 0x534e	/* subqw #1,a6 */
	.short 0x5200	/* addqb #1,d0 */
	.short 0x564d	/* addqw #3,a5 */
	.short 0x4d43	/* .short 0x4d43 */
	.short 0x4849	/* bkpt 1 */
	.short 0x5052	/* addqw #8,a2@ */
	.short 0x414d	/* .short 0x414d */
	.short 0x0056,0x4d4d	/* oriw #19789,a6@ */
	notw d1
	.short 0x5354	/* subqw #1,a4@ */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x564d	/* addqw #3,a5 */
	.short 0x4d52	/* .short 0x4d52 */
	.short 0x414d	/* .short 0x414d */
	.short 0x0050,0x4c4e	/* oriw #19534,a0@ */
	.short 0x4348	/* .short 0x4348 */
	.short 0x4950	/* .short 0x4950 */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x504c	/* addqw #8,a4 */
	trap #6
	.short 0x4153	/* .short 0x4153 */
	.short 0x5452	/* addqw #2,a2@ */
	.short 0x414d	/* .short 0x414d */
	.short 0x0050,0x4c4e	/* oriw #19534,a0@ */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x5642	/* addqw #3,d2 */
	.short 0x5200	/* addqb #1,d0 */
	.short 0x4c41	/* .short 0x4c41 */
	.short 0x5354	/* subqw #1,a4@ */
	.short 0x414c	/* .short 0x414c */
	.short 0x4552	/* .short 0x4552 */
	.short 0x5400	/* addqb #2,d0 */
	.short 0x5642	/* addqw #3,d2 */
	.short 0x4c41	/* .short 0x4c41 */
	trap #11
	notw a2@
	.short 0x4551	/* .short 0x4551 */
	.short 0x0050,0x4f57	/* oriw #20311,a0@ */
	.short 0x4552	/* .short 0x4552 */
	notw a2@
	.short 0x4551	/* .short 0x4551 */
	.short 0x0045,0x434c	/* oriw #17228,d5 */
	.short 0x4f43	/* .short 0x4f43 */
	chkl d0,d5
	.short 0x534c	/* subqw #1,a4 */
	.short 0x4f57	/* .short 0x4f57 */
	.short 0x5241	/* addqw #1,d1 */
	chkl d0,d6
	.short 0x4741	/* .short 0x4741 */
	.short 0x5259	/* addqw #1,a1@+ */
	.short 0x0052,0x414d	/* oriw #16717,a2@ */
	.short 0x5345	/* subqw #1,d5 */
	.short 0x5900	/* subqb #4,d0 */
	clrw d1
	.short 0x5454	/* addqw #2,a4@ */
	.short 0x434c	/* .short 0x434c */
	.short 0x4f43	/* .short 0x4f43 */
	chkl d0,d5
	.short 0x4348	/* .short 0x4348 */
	.short 0x554e	/* subqw #2,a6 */
	.short 0x4b59	/* .short 0x4b59 */
	.short 0x504c	/* addqw #8,a4 */
	.short 0x414e	/* .short 0x414e */
	.short 0x4152	/* .short 0x4152 */
	.short 0x0050,0x4f57	/* oriw #20311,a0@ */
	.short 0x4552	/* .short 0x4552 */
	.short 0x5043	/* addqw #8,d3 */
	.short 0x0050,0x5043	/* oriw #20547,a0@ */
	.short 0x434c	/* .short 0x434c */
	.short 0x4f43	/* .short 0x4f43 */
	chkl d0,d5
	.short 0x4350	/* .short 0x4350 */
	.short 0x5552	/* subqw #2,a2@ */
	.short 0x4556	/* .short 0x4556 */
	.short 0x0043,0x5055	/* oriw #20565,d3 */
	.short 0x434c	/* .short 0x434c */
	.short 0x4f43	/* .short 0x4f43 */
	chkl d0,d5
	notw a0@
	.short 0x5543	/* subqw #2,d3 */
	.short 0x4c4f	/* .short 0x4c4f */
	.short 0x434b	/* .short 0x434b */
	.short 0x0052,0x414d	/* oriw #16717,a2@ */
	.short 0x4143	/* .short 0x4143 */
	.short 0x4345	/* .short 0x4345 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x0052,0x414d	/* oriw #16717,a2@ */
	.short 0x5749	/* subqw #3,a1 */
	negw a4@
	nbcd d0
	.short 0x5241	/* addqw #1,d1 */
	.short 0x4d43	/* .short 0x4d43 */
	.short 0x4153	/* .short 0x4153 */
	.short 0x0052,0x414d	/* oriw #16717,a2@ */
	clrw d1
	trap #4
	.short 0x5749	/* subqw #3,a1 */
	negw a4@
	nbcd d0
	.byte 0x00
L8ef:
	.byte 0x45,0x4d,0x50	/* oriw #19792,d5 */
	.short 0x5459	/* addqw #2,a1@+ */
	trap #1
	.short 0x004e	/* .short 0x004e */
	.short 0x4f4c	/* .short 0x4f4c */
	.short 0x4f43	/* .short 0x4f43 */
	.short 0x414c	/* .short 0x414c */
	chkl d0,d2
	.byte 0x00
L901:
	.byte 0x00,0x4e,0x54	/* orib #84,d0 */
	.short 0xffce	/* .short 0xffce */
	movel a5@(48),d0
	beqw L96e
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw L922
	tstb a0@
	bnew L96e
L922:
	movel a5@(44),d1
	beqw L96e
	moveal d1,a0
	clrl sp@-
	pea a4@(-50)
	.short 0x4879,0xcd45,0x000b	/* pea 0xcd45000b */
	moveal sp,a1
	moveal %pc@(Lddc),a6
	jsr a6@(-48)
	lea sp@(12),sp
	tstl d0
	bnew L96e
	lea a4@(-50),a0
	movel a0,d0
L952:
	tstb a0@+
	bnew L952
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L96a:
	unlk a4
	rts
L96e:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw L96a
	linkw a4,#-50
	movel a5@(44),d0
	beqw L9f6
	moveal d0,a0
	bsrw Ld92
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw L996
	tstb a0@
	bnew L9f6
L996:
	movel d0,d6
	movel a5@(48),d0
	beqw L9f6
	moveal d0,a0
	lea %pc@(L9fe),a1
	bsrw Lc70
	tstl d0
	bmiw L9f6
	movel sp,d7
	clrl sp@-
	pea a4@(-50)
	.short 0x0680,0xcd45,0x0007	/* addil #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	movel d6,d0
	moveal %pc@(Lddc),a6
	jsr a6@(-42)
	moveal d7,sp
	tstl d0
	bnew L9f6
	lea a4@(-50),a0
	movel a0,d0
L9da:
	tstb a0@+
	bnew L9da
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L9f2:
	unlk a4
	rts
L9f6:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw L9f2
L9fe:
	negw d5
	.short 0x4144	/* .short 0x4144 */
	.short 0x0053,0x5542	/* oriw #21826,a3@ */
	.short 0x5359	/* subqw #1,a1@+ */
	.short 0x5300	/* subqb #1,d0 */
	.short 0x4745	/* .short 0x4745 */
	trap #5
	.short 0x5241	/* addqw #1,d1 */
	.short 0x4c00	/* .short 0x4c00 */
	.short 0x5350	/* subqw #1,a0@ */
	.short 0x4543	/* .short 0x4543 */
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffe8	/* .short 0xffe8 */
	.short 0x7200	/* moveq #0,d1 */
	.short 0x701f	/* moveq #31,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	tstl a0@
	beqw La3a
	lea a0@(12),a0
	.short 0x5281	/* addql #1,d1 */
	.short 0x51c8,0xfff2	/* dbf d0,0xa26 */
	braw La6c
La3a:
	movel d1,a4@(-4)
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	clrl a0@
	movel a0,a0@-
	moveal %pc@(Lde8),a6
	jsr a6@(-186)
	movel a4@(-4),d0
	lea a4@(-24),a0
	bsrw Lcce
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
La68:
	unlk a4
	rts
La6c:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw La68
	linkw a4,#-20
	movel a5@(44),d0
	beqw Lad4
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw La94
	tstb a0@
	bnew Lad4
La94:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccw Lad4
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqw Lad4
	.short 0x70ff	/* moveq #-1,d0 */
Lab2:
	moveal a0@,a0
	.short 0x5280	/* addql #1,d0 */
	tstl a0@
	bnew Lab2
	lea a4@(-20),a0
	bsrw Lcce
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lad0:
	unlk a4
	rts
Lad4:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw Lad0
	linkw a4,#-24
	movel a5@(44),d0
	beqw Lbe2
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw Lafc
	tstb a0@
	bnew Lbe2
Lafc:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccw Lbe2
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqw Lbe2
	movel a0,a4@(-4)
	movel a5@(48),d0
	beqw Lbe2
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw Lb38
	tstb a0@
	bnew Lbe2
Lb38:
	moveal a4@(-4),a0
Lb3c:
	moveal a0@,a0
	tstl a0@
	beqw Lbe2
	.short 0x5380	/* subql #1,d0 */
	bccw Lb3c
	moveal a0,a3
	movel a5@(52),d0
	beqw Lbe2
	moveal d0,a0
	lea %pc@(Lbea),a1
	bsrw Lc70
	.short 0x5380	/* subql #1,d0 */
	bcsw Lb80
	.short 0x5380	/* subql #1,d0 */
	bcsw Lb88
	.short 0x5380	/* subql #1,d0 */
	bcsw Lb90
	.short 0x5380	/* subql #1,d0 */
	bcsw Lb98
	.short 0x5380	/* subql #1,d0 */
	bcsw Lba8
	braw Lbe2
Lb80:
	lea a3@(14),a0
	braw Lbc4
Lb88:
	lea a3@(38),a0
	braw Lbc4
Lb90:
	lea a3@(78),a0
	braw Lbc4
Lb98:
	movew a3@(130),d0
	.short 0xc07c,0x0004	/* andw #4,d0 */
	beqw Lbc0
	braw Lbb8
Lba8:
	movew a3@(130),d0
	.short 0xc07c,0x0002	/* andw #2,d0 */
	beqw Lbc0
	braw Lbb8
Lbb8:
	lea %pc@(Lc06),a0
	braw Lbc4
Lbc0:
	lea %pc@(Lc08),a0
Lbc4:
	movel a0,d0
Lbc6:
	tstb a0@+
	bnew Lbc6
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Lde4),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lbde:
	unlk a4
	rts
Lbe2:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw Lbde
Lbea:
	trap #1
	.short 0x4d45	/* .short 0x4d45 */
	.short 0x0054,0x4954	/* oriw #18772,a4@ */
	.short 0x4c45	/* .short 0x4c45 */
	.short 0x0044,0x4553	/* oriw #17747,d4 */
	chkl d0,d1
	.short 0x4755	/* .short 0x4755 */
	chkl d0,d4
	.short 0x4143	/* .short 0x4143 */
	.short 0x5449	/* addqw #2,a1 */
	.short 0x5645	/* addqw #3,d5 */
	.byte 0x00,0x00
Lc06:
	.byte 0x31,0x00	/* orib #0,d0 */
Lc08:
	movew d0,d0
	linkw a4,#0
	movel a5@(44),d0
	beqw Lc5a
	moveal d0,a0
	bsrw Ld42
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqw Lc2a
	tstb a0@
	bnew Lc5a
Lc2a:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccw Lc5a
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqw Lc5a
	moveal a0,a3
	moveal %pc@(Lde8),a6
	jsr a6@(-192)
	clrl a3@
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
Lc56:
	unlk a4
	rts
Lc5a:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	braw Lc56
	moveal %pc@(Lddc),a6
	jsr a6@(-60)
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
Lc70:
	moveml d1-d2/a1-a2,sp@-
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a0,a2
Lc78:
	.short 0x5280	/* addql #1,d0 */
	tstb a1@
	beqw Lcc6
	moveal a2,a0
Lc82:
	moveb a0@+,d2
	.short 0x0c02,0x0061	/* cmpib #97,d2 */
	bcss Lc94
	.short 0x0c02,0x007a	/* cmpib #122,d2 */
	bhis Lc94
	.short 0x0402,0x0020	/* subib #32,d2 */
Lc94:
	moveb a1@+,d1
	beqw Lcaa
	cmpb d2,d1
	beqw Lc82
Lca0:
	tstb a1@+
	bnew Lca0
	braw Lc78
Lcaa:
	.short 0x5388	/* subql #1,a0 */
	tstb d2
	beqw Lcc8
	.short 0x0c02,0x0020	/* cmpib #32,d2 */
	beqw Lcc8
	.short 0x0c02,0x003d	/* cmpib #61,d2 */
	beqw Lcc8
	braw Lc78
Lcc6:
	.short 0x70ff	/* moveq #-1,d0 */
Lcc8:
	moveml sp@+,d1-d2/a1-a2
	rts
Lcce:
	moveml d1-d2,sp@-
	tstl d0
	smi d2
	bplw Lcdc
	negl d0
Lcdc:
	lea a0@(20),a0
	clrb a0@-
	.short 0x7200	/* moveq #0,d1 */
Lce4:
	.short 0x80fc,0x000a	/* divuw #10,d0 */
	swap d0
	.short 0x0600,0x0030	/* addib #48,d0 */
	moveb d0,a0@-
	.short 0x5281	/* addql #1,d1 */
	clrw d0
	swap d0
	bnew Lce4
	tstb d2
	beqw Ld06
	.short 0x113c,0x002d	/* moveb #45,a0@- */
	.short 0x5281	/* addql #1,d1 */
Ld06:
	movel d1,d0
	moveml sp@+,d1-d2
	rts
Ld0e:
	moveml d1-d2/a0,sp@-
	lea %pc@(Ld32),a1
	.short 0x7207	/* moveq #7,d1 */
	roll #4,d0
	movew d0,d2
	.short 0xc47c,0x000f	/* andw #15,d2 */
	.short 0x10f1,0x2000	/* moveb a1@(0,d2:w),a0@+ */
	.short 0x51c9,0xfff2	/* dbf d1,0xd18 */
	clrb a0@
	.short 0x7008	/* moveq #8,d0 */
	moveml sp@+,d1-d2/a0
	rts
Ld32:
	movew a1@(0x33,d3:w:0x2),d0
	movew a5@(0x37,d3:w:0x8),d2
	.short 0x3839,0x4142,0x4344	/* movew 0x41424344,d4 */
	.short 0x4546	/* .short 0x4546 */
Ld42:
	moveml d1-d3,sp@-
	.short 0x7000	/* moveq #0,d0 */
Ld48:
	.short 0x0c18,0x0020	/* cmpib #32,a0@+ */
	beqw Ld48
	.short 0x5388	/* subql #1,a0 */
	.short 0x0c10,0x002d	/* cmpib #45,a0@ */
	seq d2
	bnew Ld5e
	.short 0x5288	/* addql #1,a0 */
Ld5e:
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	.short 0x0401,0x0030	/* subib #48,d1 */
	bcsw Ld82
	.short 0x0c01,0x0009	/* cmpib #9,d1 */
	bhiw Ld82
	addl d0,d0
	movel d0,d3
	addl d0,d0
	addl d0,d0
	addl d3,d0
	addl d1,d0
	braw Ld5e
Ld82:
	tstb d2
	beqw Ld8a
	negl d0
Ld8a:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d3
	rts
Ld92:
	moveml d1-d2,sp@-
	.short 0x7207	/* moveq #7,d1 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d2
	.short 0x0402,0x0030	/* subib #48,d2 */
	bcsw Ldd4
	.short 0x0c02,0x0009	/* cmpib #9,d2 */
	blsw Ldca
	.short 0x5f02	/* subqb #7,d2 */
	bcsw Ldd4
	.short 0x0c02,0x000f	/* cmpib #15,d2 */
	blsw Ldca
	.short 0x0402,0x0020	/* subib #32,d2 */
	bcsw Ldd4
	.short 0x0c02,0x000f	/* cmpib #15,d2 */
	bhiw Ldd4
Ldca:
	lsll #4,d0
	orb d2,d0
	.short 0x51c9,0xffca	/* dbf d1,0xd9a */
	.short 0x5288	/* addql #1,a0 */
Ldd4:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d2
	.byte 0x4e,0x75
Lddc:
	.byte 0x00,0x00,0x00,0x00
Lde0:
	.byte 0x00,0x00,0x00,0x00
Lde4:
	.byte 0x00,0x00,0x00,0x00
Lde8:
	.byte 0x00,0x00,0x00,0x00	/* rts */
Ldec:
	.short 0x0000,0x4e71	/* orib #113,d0 */
	.data
