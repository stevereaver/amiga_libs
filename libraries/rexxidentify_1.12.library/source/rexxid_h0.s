	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0d,0xc0,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x33,0x00,0x00,0x00,0xe0,0x72,0x65
	.byte 0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x00,0x72,0x65,0x78,0x78,0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x31,0x2e,0x31,0x32,0x20,0x28,0x30,0x38
	.byte 0x2e,0x30,0x39,0x2e,0x32,0x30,0x30,0x31,0x29,0x0d,0x0a,0x00,0x72,0x65,0x78,0x78
	.byte 0x69,0x64,0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79
	.byte 0x20,0x56,0x31,0x2e,0x31,0x32,0x20,0x20,0x41,0x52,0x65,0x78,0x78,0x20,0x73,0x75
	.byte 0x70,0x70,0x6f,0x72,0x74,0x20,0x66,0x6f,0x72,0x20,0x74,0x68,0x65,0x20,0x69,0x64
	.byte 0x65,0x6e,0x74,0x69,0x66,0x79,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x20
	.byte 0x20,0x20,0x28,0x43,0x29,0x20,0x31,0x39,0x39,0x37,0x2d,0x32,0x30,0x30,0x31,0x20
	.byte 0x52,0x69,0x63,0x68,0x61,0x72,0x64,0x20,0x4b,0xf6,0x72,0x62,0x65,0x72,0x20,0x20
	.byte 0x20,0x20,0x20,0x65,0x2d,0x6d,0x61,0x69,0x6c,0x3a,0x20,0x72,0x6b,0x6f,0x65,0x72
	.byte 0x62,0x65,0x72,0x40,0x67,0x6d,0x78,0x2e,0x64,0x65,0x20,0x20,0x20,0x0d,0x0a,0x00
	.byte 0x00,0x00,0x00,0x2c,0x00,0x00,0x00,0xf0,0x00,0x00,0x01,0x08,0x00,0x00,0x01,0x28
	.byte 0x00,0x00,0x02,0x2e,0x00,0x00,0x02,0x3c,0x00,0x00,0x02,0x50,0x00,0x00,0x02,0xc6
	.byte 0x00,0x00,0x02,0xca,0xff,0xff,0xff,0xff,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00
	.byte 0x00,0x1e,0xa0,0x0e,0x06,0x00,0x90,0x14,0x00,0x01,0x90,0x16,0x00,0x0c,0x80,0x18
	.byte 0x00,0x00,0x00,0x33,0x00,0x00,0x00,0x00
L128:
	moveml d1-a6,sp@-
	moveal d0,a5
	.byte 0x2b,0x4e
L130:
	.byte 0x00,0x24	/* movel a6,a5@(36) */
	movel a0,a5@(40)
	lea %pc@(L1e4),a1
	.short 0x7021	/* moveq #33,d0 */
	.byte 0x2c,0x78,0x00
L13f:
	.byte 0x04	/* moveal 0x4,a6 */
	.byte 0x4e,0xae,0xfd
L143:
	.byte 0xd8	/* jsr a6@(-552) */
	.short 0x23c0,0x0000,0x0db6	/* movel d0,0xdb6 */
	beqw L1e0
	lea %pc@(L1f7),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0db2	/* movel d0,0xdb2 */
	beqs L1d4
	lea %pc@(L209),a1
	.short 0x7024	/* moveq #36,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0dba	/* movel d0,0xdba */
	beqs L1c8
	lea %pc@(L21d),a1
	.short 0x700d	/* moveq #13,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0dae	/* movel d0,0xdae */
	beqs L1bc
	subal a0,a0
	.short 0x45f9,0x0000,0x0000	/* lea 0x0,a2 */
	.short 0x74ff	/* moveq #-1,d2 */
L19a:
	.short 0x70ff	/* moveq #-1,d0 */
	.short 0x72ff	/* moveq #-1,d1 */
	moveal %pc@(Ldb2),a6
	jsr a6@(-72)
	.short 0x5242	/* addqw #1,d2 */
	moveal d0,a0
	movel d0,a2@+
	bnes L19a
	.short 0x33c2,0x0000,0x0dbe	/* movew d2,0xdbe */
	movel a5,d0
L1b6:
	moveml sp@+,d1-a6
	rts
L1bc:
	moveal %pc@(Ldba),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1c8:
	moveal %pc@(Ldb2),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1d4:
	moveal %pc@(Ldb6),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L1e0:
	.short 0x7000	/* moveq #0,d0 */
	bras L1b6
L1e4:
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7878	/* moveq #120,d4 */
	.short 0x7379	/* .short 0x7379 */
	.short 0x736c	/* .short 0x736c */
	bvss L250
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L1f7:
	.byte 0x65,0x78,0x70	/* oriw #30832,a5@- */
	bsrs L26a
	.short 0x7369	/* .short 0x7369 */
	bles L26e
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L209:
	.byte 0x63,0x6f,0x6d	/* oriw #28525,a3@- */
	blts L27d
	bccs L279
	.short 0x7469	/* moveq #105,d2 */
	bcss L287
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L21d:
	.byte 0x69,0x64,0x65,0x6e,0x74	/* oriw #25701,a1@(28276) */
	bvss L28a
	.short 0x792e	/* .short 0x792e */
	bges L291
	bhis L29c
	bsrs L29e
	.short 0x7900	/* .short 0x7900 */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #0,a6@(35)
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L24e
	btst #0,a6@(35)
	beqs L24e
	bsrs L250
L24e:
	rts
L250:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(36),a6
	tstw a5@(32)
	beqs L26a
	bset #0,a5@(35)
	.short 0x7000	/* moveq #0,d0 */
	bras L2c0
L26a:
	movel a5@(40),d2
L26e:
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	.byte 0x22
L279:
	.byte 0x7a,0x0b,0x34	/* moveal %pc@(0xdae),a1 */
	.byte 0x2c
L27d:
	.byte 0x78,0x00,0x04	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.byte 0x22,0x7a,0x0b
L287:
	.byte 0x34	/* moveal %pc@(0xdba),a1 */
	.byte 0x2c,0x78
L28a:
	.byte 0x00,0x04	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.byte 0x22
L291:
	.byte 0x7a,0x0b,0x20	/* moveal %pc@(0xdb2),a1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L29c:
	.byte 0x22,0x7a
L29e:
	.byte 0x0b,0x18	/* moveal %pc@(0xdb6),a1 */
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
L2c0:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d1-d7/a1-a6,sp@-
	moveal a0,a5
	moveal a5@(40),a0
	lea %pc@(L32a),a1
	bsrw Lc72
	tstl d0
	bmis L2f4
	addl d0,d0
	addl d0,d0
	lea %pc@(L2fa),a4
	.short 0x2874,0x0800	/* moveal a4@(0,d0:l),a4 */
	jsr a4@
L2ee:
	moveml sp@+,d1-d7/a1-a6
	rts
L2f4:
	.short 0x7001	/* moveq #1,d0 */
	subal a0,a0
	bras L2ee
L2fa:
	.short 0x0000,0x03b0	/* orib #-80,d0 */
	.short 0x0000,0x03e2	/* orib #-30,d0 */
	.short 0x0000,0x0404	/* orib #4,d0 */
	.short 0x0000,0x06e8	/* orib #-24,d0 */
	.short 0x0000,0x096e	/* orib #110,d0 */
	.short 0x0000,0x09d4	/* orib #-44,d0 */
	.short 0x0000,0x0618	/* orib #24,d0 */
	.short 0x0000,0x0a66	/* orib #102,d0 */
	.short 0x0000,0x0abc	/* orib #-68,d0 */
	.short 0x0000,0x0b16	/* orib #22,d0 */
	.short 0x0000,0x0c18	/* orib #24,d0 */
	.short 0x0000,0x0c64	/* orib #100,d0 */
L32a:
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
L3b6:
	tstb a0@+
	bnes L3b6
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
	movew a1@(0x31,d2:w),a0@-
	.byte 0x2e,0x31,0x32,0x28,0x30,0x38,0x2e,0x30,0x39,0x2e,0x32,0x30,0x30,0x31,0x29,0x00
	.byte 0x4e,0x54,0xff,0xec,0x70,0x00
	movew %pc@(Ldbe),d0
	lea a4@(-20),a0
	bsrw Lcbe
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
	unlk a4
	rts
	linkw a4,#-58
	movel a5@(44),d0
	beqw L5b8
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L422
	tstb a0@
	bnew L5b8
L422:
	.short 0x7200	/* moveq #0,d1 */
	movew %pc@(Ldbe),d1
	cmpl d1,d0
	bhiw L5b8
	addl d0,d0
	addl d0,d0
	.short 0x41f9,0x0000,0x0000	/* lea 0x0,a0 */
	.short 0x2970,0x0800,0xffca	/* movel a0@(0,d0:l),a4@(-54) */
	movel a5@(48),d0
	beqw L5b8
	moveal d0,a0
	lea %pc@(L5d0),a1
	bsrw Lc72
	tstl d0
	bmiw L5b8
	.short 0x5780	/* subql #3,d0 */
	bcsw L56e
	.short 0x5380	/* subql #1,d0 */
	bcss L482
	.short 0x5380	/* subql #1,d0 */
	bcss L496
	.short 0x5380	/* subql #1,d0 */
	bcss L4ae
	.short 0x5380	/* subql #1,d0 */
	bcsw L52a
	.short 0x5380	/* subql #1,d0 */
	bcss L4cc
	.short 0x5380	/* subql #1,d0 */
	bcsw L500
	.short 0x5380	/* subql #1,d0 */
	bcsw L516
	braw L5b8
L482:
	moveal a4@(-54),a0
	movel a0@(32),d0
	lea a4@(-50),a0
	bsrw Lcf8
	braw L59c
L496:
	moveal a4@(-54),a0
	movel a0@(36),d0
	lea a4@(-50),a0
	lsrl #8,d0
	lsrl #2,d0
	bsrw Lcbe
	braw L59c
L4ae:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@(14),d0
	btst #0,d0
	sne d0
	negb d0
	lea a4@(-50),a0
	bsrw Lcbe
	braw L59c
L4cc:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-58)
	.short 0x4879,0xcd45,0x000e	/* pea 0xcd45000e */
	moveal sp,a0
	moveal %pc@(Ldae),a6
	jsr a6@(-30)
	moveal d7,sp
	lea a4@(-50),a0
	movel a4@(-58),d0
	bsrw Lcbe
	braw L59c
L500:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(20),d0
	lea a4@(-50),a0
	bsrw Lcbe
	braw L59c
L516:
	moveal a4@(-54),a0
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@(17),d0
	lea a4@(-50),a0
	bsrw Lcbe
	bras L59c
L52a:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0x4879,0xcd45,0x0005	/* pea 0xcd450005 */
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x000d	/* pea 0xcd45000d */
	moveal sp,a0
	moveal %pc@(Ldae),a6
	jsr a6@(-30)
	moveal d7,sp
	lea %pc@(L5c6),a0
	.short 0x0c80,0xffff,0xfff9	/* cmpil #-7,d0 */
	beqs L59c
	lea %pc@(L5be),a0
	tstl d0
	beqs L59c
	bras L5b8
L56e:
	movel sp,d7
	clrl sp@-
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0000	/* pea 0xcd450000 */
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0007	/* addl #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Ldae),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnes L5b8
	lea a4@(-50),a0
L59c:
	movel a0,d0
L59e:
	tstb a0@+
	bnes L59e
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L5b4:
	unlk a4
	rts
L5b8:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L5b4
L5be:
	.short 0x5072,0x696d,0x6172	/* addqw #8,a2@(6172)@(0) */
	.short 0x7900	/* .short 0x7900 */
L5c6:
	.short 0x5365	/* subqw #1,a5@- */
	blss L639
	bgts L630
	bsrs L640
	.short 0x7900	/* .short 0x7900 */
L5d0:
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
	beqw L6d0
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L636
L630:
	tstb a0@
	bnew L6d0
L636:
	.byte 0x0c,0x80,0x00
L639:
	.byte 0x00,0xff,0xff	/* cmpil #65535,d0 */
	bhiw L6d0
L640:
	movel d0,a4@(-54)
	movel a5@(48),d0
	beqw L6d0
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L65c
	tstb a0@
	bnes L6d0
L65c:
	.short 0x0c80,0x0000,0x00ff	/* cmpil #255,d0 */
	bhis L6d0
	movel d0,a4@(-58)
	movel a5@(52),d0
	beqs L6d0
	moveal d0,a0
	lea %pc@(L6d6),a1
	bsrw Lc72
	tstl d0
	bmis L6d0
	movel sp,d7
	clrl sp@-
	movel a4@(-58),sp@-
	.short 0x4879,0xcd45,0x0002	/* pea 0xcd450002 */
	movel a4@(-54),sp@-
	.short 0x4879,0xcd45,0x0001	/* pea 0xcd450001 */
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0004	/* addl #-851116028,d0 */
	movel d0,sp@-
	moveal sp,a0
	moveal %pc@(Ldae),a6
	jsr a6@(-30)
	moveal d7,sp
	tstl d0
	bnes L6d0
	lea a4@(-50),a0
	movel a0,d0
L6b6:
	tstb a0@+
	bnes L6b6
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L6cc:
	unlk a4
	rts
L6d0:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L6cc
L6d6:
	.short 0x4d41	/* .short 0x4d41 */
	linkw a5,#17920
	.short 0x5052	/* addqw #8,a2@ */
	.short 0x4f44	/* .short 0x4f44 */
	.short 0x0043,0x4c41	/* oriw #19521,d3 */
	.short 0x5353	/* subqw #1,a3@ */
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffcc	/* .short 0xffcc */
	clrb a4@(-1)
	clrb a4@(-2)
	movel a5@(28),d1
	lea a5@(48),a3
L6fc:
	.short 0x5301	/* subqb #1,d1 */
	beqs L728
	movel a3@+,d0
	beqs L6fc
	moveal d0,a0
	lea %pc@(L95a),a1
	bsrw Lc72
	tstl d0
	bmis L790
	.short 0x5380	/* subql #1,d0 */
	bcss L71c
	.short 0x5380	/* subql #1,d0 */
	bcss L722
	bras L6fc
L71c:
	st a4@(-1)
	bras L6fc
L722:
	st a4@(-2)
	bras L6fc
L728:
	movel a5@(44),d0
	beqs L790
	moveal d0,a0
	lea %pc@(L796),a1
	bsrw Lc72
	tstl d0
	bmis L790
	moveal sp,a3
	clrl sp@-
	tstb a4@(-1)
	beqs L750
	.short 0x4878,0xffff	/* pea 0xffffffff */
	.short 0x4879,0xcd45,0x0010	/* pea 0xcd450010 */
L750:
	tstb a4@(-2)
	beqs L75e
	clrl sp@-
	.short 0x4879,0xcd45,0x000f	/* pea 0xcd45000f */
L75e:
	moveal sp,a0
	moveal %pc@(Ldae),a6
	jsr a6@(-36)
	moveal a3,sp
	moveal d0,a0
	tstl d0
	bnes L774
	lea %pc@(L96c),a0
L774:
	movel a0,d0
L776:
	tstb a0@+
	bnes L776
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L78c:
	unlk a4
	rts
L790:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L78c
L796:
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
	.byte 0x00,0x00
L95a:
	.byte 0x45,0x4d	/* orib #77,d0 */
	.short 0x5054	/* addqw #8,a4@ */
	.short 0x594e	/* subqw #4,a6 */
	chkl d0,d0
	trap #15
	.short 0x4c4f	/* .short 0x4c4f */
	.short 0x4341	/* .short 0x4341 */
	.short 0x4c45,0x0000	/* divull d5,d0,d0 */
L96c:
	.short 0x0000,0x4e54	/* orib #84,d0 */
	.short 0xffce	/* .short 0xffce */
	movel a5@(48),d0
	beqs L9ce
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L988
	tstb a0@
	bnes L9ce
L988:
	movel a5@(44),d1
	beqs L9ce
	moveal d1,a0
	clrl sp@-
	pea a4@(-50)
	.short 0x4879,0xcd45,0x000b	/* pea 0xcd45000b */
	moveal sp,a1
	moveal %pc@(Ldae),a6
	jsr a6@(-48)
	lea sp@(12),sp
	tstl d0
	bnes L9ce
	lea a4@(-50),a0
	movel a0,d0
L9b4:
	tstb a0@+
	bnes L9b4
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
L9ca:
	unlk a4
	rts
L9ce:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras L9ca
	linkw a4,#-50
	movel a5@(44),d0
	beqs La46
	moveal d0,a0
	bsrw Ld70
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs L9ee
	tstb a0@
	bnes La46
L9ee:
	movel d0,d6
	movel a5@(48),d0
	beqs La46
	moveal d0,a0
	lea %pc@(La4c),a1
	bsrw Lc72
	tstl d0
	bmis La46
	movel sp,d7
	clrl sp@-
	pea a4@(-50)
	.short 0xd0bc,0xcd45,0x0007	/* addl #-851116025,d0 */
	movel d0,sp@-
	moveal sp,a0
	movel d6,d0
	moveal %pc@(Ldae),a6
	jsr a6@(-42)
	moveal d7,sp
	tstl d0
	bnes La46
	lea a4@(-50),a0
	movel a0,d0
La2c:
	tstb a0@+
	bnes La2c
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
La42:
	unlk a4
	rts
La46:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras La42
La4c:
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
	beqs La84
	lea a0@(12),a0
	.short 0x5281	/* addql #1,d1 */
	.short 0x51c8,0xfff4	/* dbf d0,0xa74 */
	bras Lab6
La84:
	movel d1,a4@(-4)
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	clrl a0@
	movel a0,a0@-
	moveal %pc@(Ldba),a6
	jsr a6@(-186)
	movel a4@(-4),d0
	lea a4@(-24),a0
	bsrw Lcbe
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lab2:
	unlk a4
	rts
Lab6:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lab2
	linkw a4,#-20
	movel a5@(44),d0
	beqs Lb10
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lad6
	tstb a0@
	bnes Lb10
Lad6:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccs Lb10
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqs Lb10
	.short 0x70ff	/* moveq #-1,d0 */
Laf0:
	moveal a0@,a0
	.short 0x5280	/* addql #1,d0 */
	tstl a0@
	bnes Laf0
	lea a4@(-20),a0
	bsrw Lcbe
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lb0c:
	unlk a4
	rts
Lb10:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lb0c
	linkw a4,#-24
	movel a5@(44),d0
	beqw Lbf2
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lb34
	tstb a0@
	bnew Lbf2
Lb34:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccw Lbf2
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqw Lbf2
	movel a0,a4@(-4)
	movel a5@(48),d0
	beqw Lbf2
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lb6e
	tstb a0@
	bnew Lbf2
Lb6e:
	moveal a4@(-4),a0
Lb72:
	moveal a0@,a0
	tstl a0@
	beqs Lbf2
	.short 0x5380	/* subql #1,d0 */
	bccs Lb72
	moveal a0,a3
	movel a5@(52),d0
	beqs Lbf2
	moveal d0,a0
	lea %pc@(Lbf8),a1
	bsrw Lc72
	.short 0x5380	/* subql #1,d0 */
	bcss Lba4
	.short 0x5380	/* subql #1,d0 */
	bcss Lbaa
	.short 0x5380	/* subql #1,d0 */
	bcss Lbb0
	.short 0x5380	/* subql #1,d0 */
	bcss Lbb6
	.short 0x5380	/* subql #1,d0 */
	bcss Lbc2
	bras Lbf2
Lba4:
	lea a3@(14),a0
	bras Lbd6
Lbaa:
	lea a3@(38),a0
	bras Lbd6
Lbb0:
	lea a3@(78),a0
	bras Lbd6
Lbb6:
	movew a3@(130),d0
	.short 0xc07c,0x0004	/* andw #4,d0 */
	beqs Lbd2
	bras Lbcc
Lbc2:
	movew a3@(130),d0
	.short 0xc07c,0x0002	/* andw #2,d0 */
	beqs Lbd2
Lbcc:
	lea %pc@(Lc14),a0
	bras Lbd6
Lbd2:
	lea %pc@(Lc16),a0
Lbd6:
	movel a0,d0
Lbd8:
	tstb a0@+
	bnes Lbd8
	subal d0,a0
	exg d0,a0
	.short 0x5380	/* subql #1,d0 */
	moveal %pc@(Ldb6),a6
	jsr a6@(-126)
	moveal d0,a0
	.short 0x7000	/* moveq #0,d0 */
Lbee:
	unlk a4
	rts
Lbf2:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lbee
Lbf8:
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
Lc14:
	.byte 0x31,0x00	/* orib #0,d0 */
Lc16:
	movew d0,d0
	linkw a4,#0
	movel a5@(44),d0
	beqs Lc5e
	moveal d0,a0
	bsrw Ld2c
	.short 0x0c10,0x0020	/* cmpib #32,a0@ */
	beqs Lc32
	tstb a0@
	bnes Lc5e
Lc32:
	.short 0x0c80,0x0000,0x0020	/* cmpil #32,d0 */
	bccs Lc5e
	.short 0xc0fc,0x000c	/* muluw #12,d0 */
	.short 0x41f9,0x0000,0x0080	/* lea 0x80,a0 */
	addal d0,a0
	tstl a0@
	beqs Lc5e
	moveal a0,a3
	moveal %pc@(Ldba),a6
	jsr a6@(-192)
	clrl a3@
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
Lc5a:
	unlk a4
	rts
Lc5e:
	.short 0x700c	/* moveq #12,d0 */
	subal a0,a0
	bras Lc5a
	moveal %pc@(Ldae),a6
	jsr a6@(-60)
	subal a0,a0
	.short 0x7000	/* moveq #0,d0 */
	rts
Lc72:
	moveml d1-d2/a1-a2,sp@-
	.short 0x70ff	/* moveq #-1,d0 */
	moveal a0,a2
Lc7a:
	.short 0x5280	/* addql #1,d0 */
	tstb a1@
	beqs Lcb6
	moveal a2,a0
Lc82:
	moveb a0@+,d2
	.short 0x0c02,0x0061	/* cmpib #97,d2 */
	bcss Lc94
	.short 0x0c02,0x007a	/* cmpib #122,d2 */
	bhis Lc94
	.short 0x943c,0x0020	/* subb #32,d2 */
Lc94:
	moveb a1@+,d1
	beqs Lca2
	cmpb d2,d1
	beqs Lc82
Lc9c:
	tstb a1@+
	bnes Lc9c
	bras Lc7a
Lca2:
	.short 0x5388	/* subql #1,a0 */
	tstb d2
	beqs Lcb8
	.short 0x0c02,0x0020	/* cmpib #32,d2 */
	beqs Lcb8
	.short 0x0c02,0x003d	/* cmpib #61,d2 */
	beqs Lcb8
	bras Lc7a
Lcb6:
	.short 0x70ff	/* moveq #-1,d0 */
Lcb8:
	moveml sp@+,d1-d2/a1-a2
	rts
Lcbe:
	moveml d1-d2,sp@-
	tstl d0
	smi d2
	bpls Lcca
	negl d0
Lcca:
	lea a0@(20),a0
	clrb a0@-
	.short 0x7200	/* moveq #0,d1 */
Lcd2:
	.short 0x80fc,0x000a	/* divuw #10,d0 */
	swap d0
	.short 0xd03c,0x0030	/* addb #48,d0 */
	moveb d0,a0@-
	.short 0x5281	/* addql #1,d1 */
	clrw d0
	swap d0
	bnes Lcd2
	tstb d2
	beqs Lcf0
	.short 0x113c,0x002d	/* moveb #45,a0@- */
	.short 0x5281	/* addql #1,d1 */
Lcf0:
	movel d1,d0
	moveml sp@+,d1-d2
	rts
Lcf8:
	moveml d1-d2/a0,sp@-
	lea %pc@(Ld1c),a1
	.short 0x7207	/* moveq #7,d1 */
	roll #4,d0
	movew d0,d2
	.short 0xc47c,0x000f	/* andw #15,d2 */
	.short 0x10f1,0x2000	/* moveb a1@(0,d2:w),a0@+ */
	.short 0x51c9,0xfff2	/* dbf d1,0xd02 */
	clrb a0@
	.short 0x7008	/* moveq #8,d0 */
	moveml sp@+,d1-d2/a0
	rts
Ld1c:
	movew a1@(0x33,d3:w:0x2),d0
	movew a5@(0x37,d3:w:0x8),d2
	.short 0x3839,0x4142,0x4344	/* movew 0x41424344,d4 */
	.short 0x4546	/* .short 0x4546 */
Ld2c:
	moveml d1-d3,sp@-
	.short 0x7000	/* moveq #0,d0 */
Ld32:
	.short 0x0c18,0x0020	/* cmpib #32,a0@+ */
	beqs Ld32
	.short 0x5388	/* subql #1,a0 */
	.short 0x0c10,0x002d	/* cmpib #45,a0@ */
	seq d2
	bnes Ld44
	.short 0x5288	/* addql #1,a0 */
Ld44:
	.short 0x7200	/* moveq #0,d1 */
	moveb a0@+,d1
	.short 0x923c,0x0030	/* subb #48,d1 */
	bcss Ld62
	.short 0x0c01,0x0009	/* cmpib #9,d1 */
	bhis Ld62
	addl d0,d0
	movel d0,d3
	addl d0,d0
	addl d0,d0
	addl d3,d0
	addl d1,d0
	bras Ld44
Ld62:
	tstb d2
	beqs Ld68
	negl d0
Ld68:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d3
	rts
Ld70:
	moveml d1-d2,sp@-
	.short 0x7207	/* moveq #7,d1 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a0@+,d2
	.short 0x943c,0x0030	/* subb #48,d2 */
	bcss Lda6
	.short 0x0c02,0x0009	/* cmpib #9,d2 */
	blss Ld9c
	.short 0x5f02	/* subqb #7,d2 */
	bcss Lda6
	.short 0x0c02,0x000f	/* cmpib #15,d2 */
	blss Ld9c
	.short 0x943c,0x0020	/* subb #32,d2 */
	bcss Lda6
	.short 0x0c02,0x000f	/* cmpib #15,d2 */
	bhis Lda6
Ld9c:
	lsll #4,d0
	orb d2,d0
	.short 0x51c9,0xffd6	/* dbf d1,0xd78 */
	.short 0x5288	/* addql #1,a0 */
Lda6:
	.short 0x5388	/* subql #1,a0 */
	moveml sp@+,d1-d2
	.byte 0x4e,0x75
Ldae:
	.byte 0x00,0x00,0x00,0x00
Ldb2:
	.byte 0x00,0x00,0x00,0x00
Ldb6:
	.byte 0x00,0x00,0x00,0x00
Ldba:
	.byte 0x00,0x00,0x00,0x00
Ldbe:
	.byte 0x00,0x00	/* rts */
	.data
