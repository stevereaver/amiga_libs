	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0e,0x0c,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x33,0x00,0x00,0x01,0x00,0x72,0x65
	.byte 0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x00,0x72,0x65,0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x31,0x2e,0x31,0x34,0x20,0x28,0x33,0x30
	.byte 0x2e,0x31,0x31,0x2e,0x32,0x30,0x32,0x31,0x29,0x0d,0x0a,0x00,0x41,0x52,0x65,0x78
	.byte 0x78,0x20,0x73,0x75,0x70,0x70,0x6f,0x72,0x74,0x20,0x66,0x6f,0x72,0x20,0x74,0x68
	.byte 0x65,0x20,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x20,0x0a,0x28,0x43,0x29,0x20,0x31,0x39,0x39,0x37,0x2d,0x32,0x30,0x32
	.byte 0x31,0x20,0x52,0x69,0x63,0x68,0x61,0x72,0x64,0x20,0x27,0x53,0x68,0x72,0x65,0x64
	.byte 0x27,0x20,0x4b,0xf6,0x72,0x62,0x65,0x72,0x20,0x0a,0x4c,0x69,0x63,0x65,0x6e,0x73
	.byte 0x65,0x3a,0x20,0x47,0x4e,0x55,0x20,0x4c,0x65,0x73,0x73,0x65,0x72,0x20,0x47,0x65
	.byte 0x6e,0x65,0x72,0x61,0x6c,0x20,0x50,0x75,0x62,0x6c,0x69,0x63,0x20,0x4c,0x69,0x63
	.byte 0x65,0x6e,0x73,0x65,0x20,0x76,0x33,0x20,0x0a,0x53,0x6f,0x75,0x72,0x63,0x65,0x3a
	.byte 0x20,0x68,0x74,0x74,0x70,0x73,0x3a,0x2f,0x2f,0x69,0x64,0x65,0x6e,0x74,0x69,0x66
	.byte 0x79,0x2e,0x73,0x68,0x72,0x65,0x64,0x7a,0x6f,0x6e,0x65,0x2e,0x6f,0x72,0x67,0x00
	.byte 0x00,0x00,0x00,0x2c,0x00,0x00,0x01,0x10,0x00,0x00,0x01,0x28,0x00,0x00,0x01,0x48
	.byte 0x00,0x00,0x02,0x4e,0x00,0x00,0x02,0x5c,0x00,0x00,0x02,0x70,0x00,0x00,0x02,0xe6
	.byte 0x00,0x00,0x02,0xea,0xff,0xff,0xff,0xff,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00
	.byte 0x00,0x1e,0xa0,0x0e,0x06,0x00,0x90,0x14,0x00,0x01,0x90,0x16,0x00,0x0e,0x80,0x18
	.byte 0x00,0x00,0x00,0x33,0x00,0x00,0x00,0x00
	moveml d1-a6,sp@-
	moveal d0,a5
	.byte 0x2b,0x4e,0x00
L151:
	.byte 0x24	/* movel a6,a5@(36) */
	movel a0,a5@(40)
L156:
	lea %pc@(L204),a1
	.short 0x7021	/* moveq #33,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.byte 0x4e,0xae
L162:
	.byte 0xfd,0xd8	/* jsr a6@(-552) */
	.byte 0x23,0xc0,0x00,0x00
L168:
	.byte 0x0e,0x02	/* movel d0,0xe02 */
	beqw L200
	.byte 0x43,0xfa
L170:
	.byte 0x00,0xa7	/* lea %pc@(0x217),a1 */
L172:
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0dfe	/* movel d0,0xdfe */
	beqs L1f4
	lea %pc@(L229),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0e06	/* movel d0,0xe06 */
	beqs L1e8
	lea %pc@(L23d),a1
	.short 0x7026	/* moveq #38,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0dfa	/* movel d0,0xdfa */
	beqs L1dc
	subal a0,a0
	.short 0x45f9,0x0000,0x0000	/* lea 0x0,a2 */
	.short 0x74ff	/* moveq #-1,d2 */
L1ba:
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x72ff	/* moveq #-1,d1 */
	.short 0x2c7a,0x0c3e	/* moveal %pc@(0xdfe),a6 */
	jsr a6@(-72)
	.short 0x5242	/* addqw #1,d2 */
	moveal d0,a0
	movel d0,a2@+
	bnes L1ba
	.short 0x33c2,0x0000,0x0e0a	/* movew d2,0xe0a */
	movel a5,d0
L1d6:
	moveml sp@+,d1-a6
	rts
L1dc:
	.short 0x227a,0x0c28	/* moveal %pc@(0xe06),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1e8:
	.short 0x227a,0x0c14	/* moveal %pc@(0xdfe),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1f4:
	.short 0x227a,0x0c0c	/* moveal %pc@(0xe02),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L200:
	.short 0x7000	/* moveq #0,d0 */
	bras L1d6
L204:
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7878	/* moveq #120,d4 */
	.short 0x7379	/* .short 0x7379 */
	.short 0x736c	/* .short 0x736c */
	bvss L270
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L217:
	.byte 0x65,0x78,0x70	/* oriw #30832,a5@- */
	bsrs L28a
	.short 0x7369	/* .short 0x7369 */
	bles L28e
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L229:
	.byte 0x63,0x6f,0x6d	/* oriw #28525,a3@- */
	blts L29d
	bccs L299
	.short 0x7469	/* moveq #105,d2 */
	bcss L2a7
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L23d:
	.byte 0x69,0x64,0x65,0x6e,0x74	/* oriw #25701,a1@(28276) */
	bvss L2aa
	.short 0x792e	/* .short 0x792e */
	bges L2b1
	bhis L2bc
	bsrs L2be
	.short 0x7900	/* .short 0x7900 */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #0,a6@(35)
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L26e
	btst #0,a6@(35)
	beqs L26e
	bsrs L270
L26e:
	rts
L270:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(36),a6
	tstw a5@(32)
	beqs L28a
	bset #0,a5@(35)
	.short 0x7000	/* moveq #0,d0 */
	bras L2e0
L28a:
	movel a5@(40),d2
L28e:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	.byte 0x22
L299:
	.byte 0x7a,0x0b,0x60	/* moveal %pc@(0xdfa),a1 */
	.byte 0x2c
L29d:
	.byte 0x78,0x00,0x04	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.byte 0x22,0x7a,0x0b
L2a7:
	.byte 0x60	/* moveal %pc@(0xe06),a1 */
	.byte 0x2c,0x78
L2aa:
	.byte 0x00,0x04	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.byte 0x22
L2b1:
	.byte 0x7a,0x0b,0x4c	/* moveal %pc@(0xdfe),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L2bc:
	.byte 0x22,0x7a
L2be:
	.byte 0x0b,0x44	/* moveal %pc@(0xe02),a1 */
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
L2e0:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d1-d7/a1-a6,sp@-
	moveal a0,a5
	moveal a5@(40),a0
	lea %pc@(L34a),a1
	bsrw Lcbe
	tstl d0
	bmis L314
	addl d0,d0
	addl d0,d0
	lea %pc@(L31a),a4
	.short 0x2874,0x0800	/* moveal a4@(0,d0:l),a4 */
	jsr a4@
L30e:
	moveml sp@+,d1-d7/a1-a6
	rts
L314:
	.short 0x7001	/* moveq #1,d0 */
	subal a0,a0
	bras L30e
L31a:
	.short 0x0000,0x03d0	/* orib #-48,d0 */
	.short 0x0000,0x0402	/* orib #2,d0 */
	.short 0x0000,0x0424	/* orib #36,d0 */
	.short 0x0000,0x0710	/* orib #16,d0 */
	.short 0x0000,0x09b6	/* orib #-74,d0 */
	.short 0x0000,0x0a1e	/* orib #30,d0 */
	.short 0x0000,0x063e	/* orib #62,d0 */
	.short 0x0000,0x0ab2	/* orib #-78,d0 */
	.short 0x0000,0x0b08	/* orib #8,d0 */
	.short 0x0000,0x0b62	/* orib #98,d0 */
	.short 0x0000,0x0c64	/* orib #100,d0 */
	.short 0x0000,0x0cb0	/* orib #-80,d0 */
L34a:
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
	.short 0x001c,0x2008	/* orib #8,a4@+ */
L3d6:
	tstb a0@+
	bnes L3d6
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x0a20	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
	movew a4@(0x31,d2:w),a0@-
	.byte 0x2e,0x31,0x34,0x28,0x33,0x30,0x2e,0x31,0x31,0x2e,0x32,0x30,0x32,0x31,0x29,0x00
	.byte 0x4e,0x54,0xff,0xec,0x70,0x00
	.short 0x303a,0x0a00	/* movew %pc@(0xe0a),d0 */
	lea a4@(-20),a0
	bsrw Ld0a
	.short 0x2c7a,0x09ec	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	unlk a4
	rts
	linkw a4,#-58
	movel a5@(44),d0
	beqw L5de
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L442
	tstb a0@
	bnew L5de
L442:
	.short 0x7200	/* moveq #0,d1 */
	.short 0x323a,0x09c4	/* movew %pc@(0xe0a),d1 */
	cmpl d1,d0
	bhiw L5de
	addl d0,d0
	addl d0,d0
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	.short 0x2970,0x0800,0xffca	/* movel a0@(0,d0:l),a4@(-54) */
	movel a5@(48),d0
	beqw L5de
	moveal d0,a0
	lea %pc@(L5f6),a1
	bsrw Lcbe
	tstl d0
	bmiw L5de
	.short 0x5780	/* subql #3,d0 */
	bcsw L592
	.short 0x5380	/* subql #1,d0 */
	bcss L4a2
	.short 0x5380	/* subql #1,d0 */
	bcss L4b6
	.short 0x5380	/* subql #1,d0 */
	bcss L4ce
	.short 0x5380	/* subql #1,d0 */
	bcsw L54c
	.short 0x5380	/* subql #1,d0 */
	bcss L4ec
	.short 0x5380	/* subql #1,d0 */
	bcsw L522
	.short 0x5380	/* subql #1,d0 */
	bcsw L538
	braw L5de
L4a2:
	moveal a4@(-54),a0
	movel a0@(32),d0
	lea a4@(-50),a0
	bsrw Ld44
	braw L5c2
L4b6:
	moveal a4@(-54),a0
	movel a0@(36),d0
	lea a4@(-50),a0
	lsrl #8,d0
	lsrl #2,d0
	bsrw Ld0a
	braw L5c2
L4ce:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(14),d0
	btst #0,d0
	sne d0
	negb d0
	lea a4@(-50),a0
	bsrw Ld0a
	braw L5c2
L4ec:
	movel sp,d7
	.short 0x4878,0x0000	/* pea 0x0 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-58)
	.short 0x4879,0xcd45,0x000e	/* pea 0xcd45000e */
	moveal sp,a0
	moveal %pc@(Ldfa),a6
	jsr a6@(-30)
	moveal d7,sp
	lea a4@(-50),a0
	movel a4@(-58),d0
	bsrw Ld0a
	braw L5c2
L522:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(20),d0
	lea a4@(-50),a0
	bsrw Ld0a
	braw L5c2
L538:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@(17),d0
	lea a4@(-50),a0
	bsrw Ld0a
	bras L5c2
L54c:
	movel sp,d7
	.short 0x4878,0x0000	/* pea 0x0 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0x4879,0xcd45,0x0005	/* pea 0xcd450005 */
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x000d	/* pea 0xcd45000d */
	moveal sp,a0
	moveal %pc@(Ldfa),a6
	jsr a6@(-30)
	moveal d7,sp
	lea %pc@(L5ec),a0
	.short 0xb0bc,0xffff,0xfff9	/* cmpl #-7,d0 */
	beqs L5c2
	lea %pc@(L5e4),a0
	tstl d0
	beqs L5c2
	bras L5de
L592:
	movel sp,d7
	.short 0x4878,0x0000	/* pea 0x0 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0007	/* addl #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Ldfa),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnes L5de
	lea a4@(-50),a0
L5c2:
	movel a0,d0
L5c4:
	tstb a0@+
	bnes L5c4
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x0832	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L5da:
	unlk a4
	rts
L5de:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L5da
L5e4:
	.short 0x5072,0x696d,0x6172	/* addqw #8,a2@(6172)@(0) */
	.short 0x7900	/* .short 0x7900 */
L5ec:
	.short 0x5365	/* subqw #1,a5@- */
	blss L65f
	bgts L656
	bsrs L666
	.short 0x7900	/* .short 0x7900 */
L5f6:
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
	.short 0x004d	/* .short 0x004d */
	.short 0x414e	/* .short 0x414e */
	.short 0x5546	/* subqw #2,d6 */
	.short 0x4944	/* .short 0x4944 */
	.short 0x0050,0x524f	/* oriw #21071,a0@ */
	.short 0x4449	/* .short 0x4449 */
	negb d0
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffc6	/* .short 0xffc6 */
	movel a5@(44),d0
	beqw L6f8
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L65c
L656:
	tstb a0@
	bnew L6f8
L65c:
	.byte 0xb0,0xbc,0x00
L65f:
	.byte 0x00,0xff,0xff	/* cmpl #65535,d0 */
	bhiw L6f8
L666:
	movel d0,a4@(-54)
	movel a5@(48),d0
	beqw L6f8
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L682
	tstb a0@
	bnes L6f8
L682:
	.short 0xb0bc,0x0000,0x00ff	/* cmpl #255,d0 */
	bhis L6f8
	movel d0,a4@(-58)
	movel a5@(52),d0
	beqs L6f8
	moveal d0,a0
	lea %pc@(L6fe),a1
	bsrw Lcbe
	tstl d0
	bmis L6f8
	movel sp,d7
	.short 0x4878,0x0000	/* pea 0x0 */
	movel a4@(-58),sp@-
	.short 0x4879,0xcd45,0x0002	/* pea 0xcd450002 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0001	/* pea 0xcd450001 */
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0004	/* addl #-851116028,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Ldfa),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnes L6f8
	lea a4@(-50),a0
	movel a0,d0
L6de:
	tstb a0@+
	bnes L6de
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x0718	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L6f4:
	unlk a4
	rts
L6f8:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L6f4
L6fe:
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
L724:
	.short 0x5301	/* subqb #1,d1 */
	beqs L752
	movel a3@+,d0
	beqs L724
	moveal d0,a0
	lea %pc@(L9a3),a1
	bsrw Lcbe
	tstl d0
	bmiw L7be
	.short 0x5380	/* subql #1,d0 */
	bcss L746
	.short 0x5380	/* subql #1,d0 */
	bcss L74c
	bras L724
L746:
	st a4@(-1)
	bras L724
L74c:
	st a4@(-2)
	bras L724
L752:
	movel a5@(44),d0
	beqs L7be
	moveal d0,a0
	lea %pc@(L7c4),a1
	bsrw Lcbe
	tstl d0
	bmis L7be
	moveal sp,a3
	.short 0x4878,0x0000	/* pea 0x0 */
	tstb a4@(-1)
	beqs L77c
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x0010	/* pea 0xcd450010 */
L77c:
	tstb a4@(-2)
	beqs L78c
	.short 0x4878,0x0000	/* pea 0x0 */
	.short 0x4879,0xcd45,0x000f	/* pea 0xcd45000f */
L78c:
	moveal sp,a0
	moveal %pc@(Ldfa),a6
	jsr a6@(-36)
	moveal a3,sp
	moveal d0,a0
	tstl d0
	bnes L7a2
	lea %pc@(L9b5),a0
L7a2:
	movel a0,d0
L7a4:
	tstb a0@+
	bnes L7a4
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x0652	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L7ba:
	unlk a4
	rts
L7be:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L7ba
L7c4:
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
	.short 0x5443	/* addqw #2,d3 */
	.short 0x5049	/* addqw #8,a1 */
	.short 0x5000	/* addqb #8,d0 */
	.short 0x5050	/* addqw #8,a0@ */
	.short 0x434f	/* .short 0x434f */
	.short 0x5300	/* subqb #1,d0 */
	.short 0x4147	/* .short 0x4147 */
	linkw a5,#21248
	.short 0x4147	/* .short 0x4147 */
	linkw a5,#21325
	.short 0x4f44	/* .short 0x4f44 */
	chkl d0,d2
	negw d5
	trap #9
	.short 0x5345	/* subqw #1,d5 */
	.short 0x0044,0x454e	/* oriw #17742,d4 */
	.short 0x4953	/* .short 0x4953 */
	.short 0x4552	/* .short 0x4552 */
	.short 0x4556	/* .short 0x4556 */
	.short 0x0042,0x4f49	/* oriw #20297,d2 */
	trap #7
	clrw d1
	chkl d0,d3
	.short 0x454d	/* .short 0x454d */
	.short 0x554c	/* subqw #2,a4 */
	.short 0x4154	/* .short 0x4154 */
	.short 0x4544	/* .short 0x4544 */
	.short 0x0058,0x4c56	/* oriw #19542,a0@+ */
	.short 0x4552	/* .short 0x4552 */
	.short 0x5349	/* subqw #1,a1 */
	.short 0x4f4e	/* .short 0x4f4e */
	.short 0x0048	/* .short 0x0048 */
	.short 0x4f53	/* .short 0x4f53 */
	.short 0x544f	/* addqw #2,sp */
	.short 0x5300	/* subqb #1,d0 */
	.short 0x484f	/* bkpt 7 */
	.short 0x5354	/* subqw #1,a4@ */
	.short 0x5645	/* addqw #3,d5 */
	.short 0x5253	/* addqw #1,a3@ */
	.short 0x0048	/* .short 0x0048 */
	.short 0x4f53	/* .short 0x4f53 */
	.short 0x544d	/* addqw #2,a5 */
	.short 0x4143	/* .short 0x4143 */
	.short 0x4849	/* bkpt 1 */
	trap #5
	.short 0x0048	/* .short 0x0048 */
	.short 0x4f53	/* .short 0x4f53 */
	.short 0x5443	/* addqw #2,d3 */
	.short 0x5055	/* addqw #8,a5@ */
	.short 0x0048	/* .short 0x0048 */
	.short 0x4f53	/* .short 0x4f53 */
	.short 0x5453	/* addqw #2,a3@ */
	.short 0x5045	/* addqw #8,d5 */
	.short 0x4544	/* .short 0x4544 */
	.short 0x004c	/* .short 0x004c */
	.short 0x4153	/* .short 0x4153 */
	.short 0x5441	/* addqw #2,d1 */
	.short 0x4c45	/* .short 0x4c45 */
	.short 0x5254	/* addqw #1,a4@ */
	.short 0x5441	/* addqw #2,d1 */
	.short 0x534b	/* subqw #1,a3 */
	.short 0x0050,0x4155	/* oriw #16725,a0@ */
	.short 0x4c41	/* .short 0x4c41 */
	.short 0x0052,0x4f4d	/* oriw #20301,a2@ */
	.short 0x5645	/* addqw #3,d5 */
	.short 0x5200	/* addqb #1,d0 */
	.byte 0x00
L9a3:
	.byte 0x45,0x4d,0x50	/* oriw #19792,d5 */
	.short 0x5459	/* addqw #2,a1@+ */
	trap #1
	.short 0x004e	/* .short 0x004e */
	.short 0x4f4c	/* .short 0x4f4c */
	.short 0x4f43	/* .short 0x4f43 */
	.short 0x414c	/* .short 0x414c */
	chkl d0,d2
	.byte 0x00
L9b5:
	.byte 0x00,0x4e,0x54	/* orib #84,d0 */
	.short 0xffce	/* .short 0xffce */
	movel a5@(48),d0
	beqs La18
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L9d0
	tstb a0@
	bnes La18
L9d0:
	movel a5@(44),d1
	beqs La18
	moveal d1,a0
	.short 0x4878,0x0000	/* pea 0x0 */
	pea a4@(-50)
	.short 0x4879,0xcd45,0x000b	/* pea 0xcd45000b */
	moveal sp,a1
	moveal %pc@(Ldfa),a6
	jsr a6@(-48)
	lea sp@(12),sp
	tstl d0
	bnes La18
	lea a4@(-50),a0
	movel a0,d0
L9fe:
	tstb a0@+
	bnes L9fe
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x03f8	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
La14:
	unlk a4
	rts
La18:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras La14
	linkw a4,#-50
	movel a5@(44),d0
	beqs La92
	moveal d0,a0
	bsrw Ldbc
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs La38
	tstb a0@
	bnes La92
La38:
	movel d0,d6
	movel a5@(48),d0
	beqs La92
	moveal d0,a0
	lea %pc@(La98),a1
	bsrw Lcbe
	tstl d0
	bmis La92
	movel sp,d7
	.short 0x4878,0x0000	/* pea 0x0 */
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0007	/* addl #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	movel d6,d0
	moveal %pc@(Ldfa),a6
	jsr a6@(-42)
	moveal d7,sp
	tstl d0
	bnes La92
	lea a4@(-50),a0
	movel a0,d0
La78:
	tstb a0@+
	bnes La78
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x037e	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
La8e:
	unlk a4
	rts
La92:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras La8e
La98:
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
	beqs Lad0
	lea a0@(12),a0
	.short 0x5281	/* addql #1,d1 */
	.short 0x51c8,0xfff4	/* dbf d0,0xac0 */
	bras Lb02
Lad0:
	movel d1,a4@(-4)
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	clrl a0@
	movel a0,a0@-
	.short 0x2c7a,0x0326	/* moveal %pc@(0xe06),a6 */
	jsr a6@(-186)
	movel a4@(-4),d0
	lea a4@(-24),a0
	bsrw Ld0a
	.short 0x2c7a,0x030e	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lafe:
	unlk a4
	rts
Lb02:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lafe
	linkw a4,#-20
	movel a5@(44),d0
	beqs Lb5c
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lb22
	tstb a0@
	bnes Lb5c
Lb22:
	.short 0xb0bc,0x0000,0x0020	/* cmpl #32,d0 */
	bccs Lb5c
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqs Lb5c
	.short 0x70ff	/* moveq #-1,d0 */
Lb3c:
	moveal a0@,a0
	.short 0x5280	/* addql #1,d0 */
	tstl a0@
	bnes Lb3c
	lea a4@(-20),a0
	bsrw Ld0a
	.short 0x2c7a,0x02b4	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lb58:
	unlk a4
	rts
Lb5c:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lb58
	linkw a4,#-24
	movel a5@(44),d0
	beqw Lc3e
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lb80
	tstb a0@
	bnew Lc3e
Lb80:
	.short 0xb0bc,0x0000,0x0020	/* cmpl #32,d0 */
	bccw Lc3e
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqw Lc3e
	movel a0,a4@(-4)
	movel a5@(48),d0
	beqw Lc3e
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lbba
	tstb a0@
	bnew Lc3e
Lbba:
	moveal a4@(-4),a0
Lbbe:
	moveal a0@,a0
	tstl a0@
	beqs Lc3e
	.short 0x5380	/* subql #1,d0 */
	bccs Lbbe
	moveal a0,a3
	movel a5@(52),d0
	beqs Lc3e
	moveal d0,a0
	lea %pc@(Lc44),a1
	bsrw Lcbe
	.short 0x5380	/* subql #1,d0 */
	bcss Lbf0
	.short 0x5380	/* subql #1,d0 */
	bcss Lbf6
	.short 0x5380	/* subql #1,d0 */
	bcss Lbfc
	.short 0x5380	/* subql #1,d0 */
	bcss Lc02
	.short 0x5380	/* subql #1,d0 */
	bcss Lc0e
	bras Lc3e
Lbf0:
	lea a3@(14),a0
	bras Lc22
Lbf6:
	lea a3@(38),a0
	bras Lc22
Lbfc:
	lea a3@(78),a0
	bras Lc22
Lc02:
	movew a3@(130),d0
	.short 0xc07c,0x0004	/* andw #4,d0 */
	beqs Lc1e
	bras Lc18
Lc0e:
	movew a3@(130),d0
	.short 0xc07c,0x0002	/* andw #2,d0 */
	beqs Lc1e
Lc18:
	lea %pc@(Lc60),a0
	bras Lc22
Lc1e:
	lea %pc@(Lc62),a0
Lc22:
	movel a0,d0
Lc24:
	tstb a0@+
	bnes Lc24
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	.short 0x2c7a,0x01d2	/* moveal %pc@(0xe02),a6 */
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lc3a:
	unlk a4
	rts
Lc3e:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lc3a
Lc44:
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
Lc60:
	.byte 0x31,0x00	/* orib #0,d0 */
Lc62:
	movew d0,d0
	linkw a4,#0
	movel a5@(44),d0
	beqs Lcaa
	moveal d0,a0
	bsrw Ld78
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lc7e
	tstb a0@
	bnes Lcaa
Lc7e:
	.short 0xb0bc,0x0000,0x0020	/* cmpl #32,d0 */
	bccs Lcaa
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqs Lcaa
	moveal a0,a3
	.short 0x2c7a,0x016c	/* moveal %pc@(0xe06),a6 */
	jsr a6@(-192)
	clrl a3@
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
Lca6:
	unlk a4
	rts
Lcaa:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lca6
	moveal %pc@(Ldfa),a6
	jsr a6@(-60)
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
Lcbe:
	moveml d1-d2/a1-a2,sp@-
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a0,a2
Lcc6:
	.short 0x5280	/* addql #1,d0 */
	tstb a1@
	beqs Ld02
	moveal a2,a0
Lcce:
	moveb a0@+,d2
	.short 0xb43c,0x0061	/* cmpb #97,d2 */
	bcss Lce0
	.short 0xb43c,0x007a	/* cmpb #122,d2 */
	bhis Lce0
	.short 0x943c,0x0020	/* subb #32,d2 */
Lce0:
	moveb a1@+,d1
	beqs Lcee
	cmpb d2,d1
	beqs Lcce
Lce8:
	tstb a1@+
	bnes Lce8
	bras Lcc6
Lcee:
	.short 0x5388	/* subql #1,a0 */
	tstb d2
	beqs Ld04
	.short 0xb43c,0x0020	/* cmpb #32,d2 */
	beqs Ld04
	.short 0xb43c,0x003d	/* cmpb #61,d2 */
	beqs Ld04
	bras Lcc6
Ld02:
	.short 0x70ff	/* moveq #-1,d0 */
Ld04:
	moveml sp@+,d1-d2/a1-a2
	rts
Ld0a:
	moveml d1-d2,sp@-
	tstl d0
	smi d2
	bpls Ld16
	negl d0
Ld16:
	lea a0@(20),a0
	clrb a0@-
	.short 0x7200	/* moveq #0,d1 */
Ld1e:
	.short 0x80fc,0x000a	/* divuw #10,d0 */
	swap d0
	.short 0xd03c,0x0030	/* addb #48,d0 */
	moveb d0,a0@-
	.short 0x5281	/* addql #1,d1 */
	clrw d0
	swap d0
	bnes Ld1e
	tstb d2
	beqs Ld3c
	.short 0x113c,0x002d	/* moveb #45,a0@- */
	.short 0x5281	/* addql #1,d1 */
Ld3c:
	movel d1,d0
	moveml sp@+,d1-d2
	rts
Ld44:
	moveml d1-d2/a0,sp@-
	lea %pc@(Ld68),a1
	.short 0x7207	/* moveq #7,d1 */
	roll #4,d0
	movew d0,d2
	.short 0xc47c,0x000f	/* andw #15,d2 */
	.short 0x10f1,0x2000	/* moveb a1@(0,d2:w),a0@+ */
	.short 0x51c9,0xfff2	/* dbf d1,0xd4e */
	clrb a0@
	.short 0x7008	/* moveq #8,d0 */
	moveml sp@+,d1-d2/a0
	rts
Ld68:
	movew a1@(0x33,d3:w:0x2),d0
	movew a5@(0x37,d3:w:0x8),d2
	.short 0x3839,0x4142,0x4344	/* movew 0x41424344,d4 */
	.short 0x4546	/* .short 0x4546 */
Ld78:
	moveml d1-d3,sp@-
	.short 0x7000	/* moveq #0,d0 */
Ld7e:
	.short 0x0c18,0x0020	/* cmpib #32,a0@+ */
	beqs Ld7e
	.short 0x5388	/* subql #1,a0 */
	.short 0x0c10,0x002d	/* cmpib #45,a0@ */
	seq d2
	bnes Ld90
	.short 0x5288	/* addql #1,a0 */
Ld90:
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	.short 0x923c,0x0030	/* subb #48,d1 */
	bcss Ldae
	.short 0xb23c,0x0009	/* cmpb #9,d1 */
	bhis Ldae
	addl d0,d0
	movel d0,d3
	addl d0,d0
	addl d0,d0
	addl d3,d0
	addl d1,d0
	bras Ld90
Ldae:
	tstb d2
	beqs Ldb4
	negl d0
Ldb4:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d3
	rts
Ldbc:
	moveml d1-d2,sp@-
	.short 0x7207	/* moveq #7,d1 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d2
	.short 0x943c,0x0030	/* subb #48,d2 */
	bcss Ldf2
	.short 0xb43c,0x0009	/* cmpb #9,d2 */
	blss Lde8
	.short 0x5f02	/* subqb #7,d2 */
	bcss Ldf2
	.short 0xb43c,0x000f	/* cmpb #15,d2 */
	blss Lde8
	.short 0x943c,0x0020	/* subb #32,d2 */
	bcss Ldf2
	.short 0xb43c,0x000f	/* cmpb #15,d2 */
	bhis Ldf2
Lde8:
	lsll #4,d0
	orb d2,d0
	.short 0x51c9,0xffd6	/* dbf d1,0xdc4 */
	.short 0x5288	/* addql #1,a0 */
Ldf2:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d2
	.byte 0x4e,0x75
Ldfa:
	.byte 0x00,0x00	/* rts */
	.data
