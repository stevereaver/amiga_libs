	.text
	.short 0x203c,0xffff,0xffff	/* movel #-1,d0 */
	.byte 0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x08,0x00,0x00,0x0e,0x40,0x01,0x24,0x09,0x00
	.byte 0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x3a,0x00,0x00,0x00,0x76,0x6d,0x61,0x74,0x68
	.byte 0x69,0x65,0x65,0x65,0x73,0x69,0x6e,0x67,0x62,0x61,0x73,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x6d,0x61,0x74,0x68,0x69,0x65,0x65,0x65,0x73,0x69,0x6e,0x67
	.byte 0x62,0x61,0x73,0x20,0x33,0x36,0x2e,0x31,0x31,0x20,0x28,0x32,0x38,0x20,0x53,0x65
	.byte 0x70,0x20,0x31,0x39,0x38,0x38,0x29,0x0d,0x0a,0x00,0x42,0x80,0x4e,0x75,0x4d,0x61
	.byte 0x74,0x68,0x49,0x45,0x45,0x45,0x2e,0x72,0x65,0x73,0x6f,0x75,0x72,0x63,0x65,0x00
	.byte 0x23,0xc8
	.short 0x0000,0x01f2	/* orib #-14,d0 */
	moveml d2-d3/a2,sp@-
	clrl d2
	clrl d3
	.byte 0x41
L85:
	.byte 0xf9,0x00,0x00,0x02,0x1c	/* lea 0x21c,a0 */
	.byte 0x08,0x2e,0x00
L8d:
	.byte 0x04,0x01
L8f:
	.byte 0x29	/* btst #4,a6@(297) */
	.byte 0x66
L91:
	.byte 0x26	/* bnes 0xb8 */
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x43
L95:
	.byte 0xfa,0xff,0xce	/* lea %pc@(0x64),a1 */
	jsr a6@(-498)
	.byte 0x26
L9d:
	.byte 0x00	/* movel d0,d3 */
	beqs Lb2
	moveal d0,a1
	.byte 0x24,0x29,0x00
La5:
	.byte 0x10	/* movel a1@(16),d2 */
	.byte 0x4a
La7:
	.byte 0x82	/* tstl d2 */
La8:
	.byte 0x67
La9:
	.byte 0x08	/* beqs 0xb2 */
Laa:
	.byte 0x41,0xf9,0x00
Lad:
	.byte 0x00,0x0e,0x1c	/* lea 0xe1c,a0 */
	bras Lb8
Lb2:
	.short 0x41f9,0x0000,0x01f8	/* lea 0x1f8,a0 */
Lb8:
	subal a2,a2
	.short 0x43f9,0x0000,0x012a	/* lea 0x12a,a1 */
	.short 0x203c,0x0000,0x003c	/* movel #60,d0 */
	clrl d1
	jsr a6@(-84)
	moveal d0,a2
	.short 0x43fa,0xff90	/* lea %pc@(0x60),a1 */
	movel a1,a2@(52)
	movel a1,a2@(56)
	moveb a6@(297),d0
	.short 0x0200,0x0010	/* andib #16,d0 */
	beqs Lee
	.short 0x43f9,0x0000,0x0e0e	/* lea 0xe0e,a1 */
	movel a1,a2@(52)
Lee:
	moveb d0,a2@(34)
	movel d2,a2@(36)
	movel a6,a2@(40)
	movel d3,a2@(48)
	beqs L11a
	.short 0x43f9,0x0000,0x064a	/* lea 0x64a,a1 */
	movel a1,a2@(52)
	moveal d3,a1
	btst #2,a1@(15)
	beqs L11a
	moveal a1@(28),a0
	jsr a0@
L11a:
	moveal a2,a1
	jsr a6@(-396)
	moveml sp@+,d2-d3/a2
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	asrb #8,d0
	.short 0x0008	/* .short 0x0008 */
	btst d4,d0
	andb d0,d0
	.short 0x000a	/* .short 0x000a */
	.short 0x0000,0x0022	/* orib #34,d0 */
	addb d0,d0
	.short 0x0016,0x000b	/* orib #11,a6@ */
	addb d0,d0
	.short 0x0014,0x0024	/* orib #36,a4@ */
	asrb #8,d0
	.short 0x000e	/* .short 0x000e */
	.short 0x0600,0xd000	/* addib #0,d0 */
	.short 0x0020,0x0000	/* orib #0,a0@- */
	.byte 0x00,0x00
L152:
	.byte 0x2f,0x0e	/* orib #14,d0 */
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	moveal sp@+,a6
	tstw a6@(32)
	bnes L1a6
	moveal a6,a1
	moveal a1@,a0
	moveal a1@(4),a1
	movel a0,a1@
	movel a1,a0@(4)
	moveal a6,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a6@(16),d0
	subaw d0,a1
	addw a6@(18),d0
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
	.short 0x2039,0x0000,0x01f2	/* movel 0x1f2,d0 */
	rts
L1a6:
	bset #3,a6@(14)
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-138)
	moveal sp@+,a6
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveal a6@(52),a0
	jsr a0@
	tstl d0
	beqs L1cc
	clrl d0
	rts
L1cc:
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	rts
	moveal a6@(56),a0
	jsr a0@
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	btst #3,a6@(14)
	bnew L152
	clrl d0
	rts
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0xffff	/* orib #-1,d0 */
	.short 0xffc6	/* .short 0xffc6 */
	.short 0xffe2	/* .short 0xffe2 */
	.short 0xff5a	/* .short 0xff5a */
	.short 0xff2e	/* .short 0xff2e */
	.byte 0x0a,0xb0,0x0a,0x0a,0x05,0xd0,0x07,0x08	/* eoril #168429008,a0@(0,d0:w:8) */
	.short 0x04a0,0x04a8,0x071c	/* subil #78120732,a0@- */
	btst d3,a0@+
	.short 0x0682,0x04b0,0x0066	/* addil #78643302,d2 */
	.short 0x0048	/* .short 0x0048 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
	.short 0xffa2	/* .short 0xffa2 */
	.short 0xffbe	/* .short 0xffbe */
	.short 0xff36	/* .short 0xff36 */
	.short 0xff0a	/* .short 0xff0a */
	bchg d5,a0@+
	movepl a4@(3030),d5
	.short 0x06e4	/* .short 0x06e4 */
	.short 0x047c	/* .short 0x047c */
	.short 0x0484,0x0b94,0x0ba8	/* subil #194251688,d4 */
	.short 0x0bb8,0x0bc8	/* bclr d5,0xbc8 */
	bclr d5,d4
	.short 0x0024,0xffff	/* orib #-1,a4@- */
	bchg #31,d0
	jsr a6@(-90)
	bchg #31,d0
L24c:
	rts
L24e:
	tstw d1
	bges L25a
	.short 0x203c,0xbf80,0x0000	/* movel #-1082130432,d0 */
	bras L25c
L25a:
	clrl d0
L25c:
	rts
	movel d0,d1
	beqs L24c
	swap d0
	.short 0x0240,0x7f80	/* andiw #32640,d0 */
	beqs L24e
	asrw #7,d0
	.short 0x0440,0x007f	/* subiw #127,d0 */
	blts L24e
	.short 0x0c40,0x0017	/* cmpiw #23,d0 */
	bges L29a
	negw d0
	.short 0x0640,0x0017	/* addiw #23,d0 */
	moveal d1,a1
	lslw #2,d0
	.short 0xc2bb,0x0018	/* andl %pc@(0x29c,d0:w),d1 */
	movel d1,d0
	bges L29a
	cmpal d1,a1
	bnes L290
	rts
L290:
	.short 0x223c,0xbf80,0x0000	/* movel #-1082130432,d1 */
	jmp a6@(-66)
L29a:
	rts
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
	.short 0xfffe	/* .short 0xfffe */
	.short 0xffff	/* .short 0xffff */
	.short 0xfffc	/* .short 0xfffc */
	.short 0xffff	/* .short 0xffff */
	.short 0xfff8	/* .short 0xfff8 */
	.short 0xffff	/* .short 0xffff */
	.short 0xfff0	/* .short 0xfff0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffe0	/* .short 0xffe0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffc0	/* .short 0xffc0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xff80	/* .short 0xff80 */
	.short 0xffff	/* .short 0xffff */
	.short 0xff00	/* .short 0xff00 */
	.short 0xffff	/* .short 0xffff */
	.short 0xfe00	/* .short 0xfe00 */
	.short 0xffff	/* .short 0xffff */
	.short 0xfc00	/* .short 0xfc00 */
	.short 0xffff	/* .short 0xffff */
	.short 0xf800	/* .short 0xf800 */
	.short 0xffff	/* .short 0xffff */
	.short 0xf000	/* .short 0xf000 */
	.short 0xffff	/* .short 0xffff */
	asrb #8,d0
	.short 0xffff	/* .short 0xffff */
	andb d0,d0
	.short 0xffff	/* .short 0xffff */
	orb d0,d0
	.short 0xffff	/* .short 0xffff */
	.short 0x0000,0xfffe	/* orib #-2,d0 */
	.short 0x0000,0xfffc	/* orib #-4,d0 */
	.short 0x0000,0xfff8	/* orib #-8,d0 */
	.short 0x0000,0xfff0	/* orib #-16,d0 */
	.short 0x0000,0xffe0	/* orib #-32,d0 */
	.short 0x0000,0xffc0	/* orib #-64,d0 */
	.short 0x0000,0xff80	/* orib #-128,d0 */
	.byte 0x00,0x00
L2fc:
	.byte 0x31,0x7c	/* orib #124,d0 */
	.short 0x0002,0x0002	/* orib #2,d2 */
	.short 0x0247,0x00ff	/* andiw #255,d7 */
	.short 0x0c47,0x0032	/* cmpiw #50,d7 */
	bnes L310
	.short 0x8efc,0x0000	/* divuw #0,d7 */
L310:
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	bnes L31c
	.short 0x003c,0x0002	/* orib #2,%ccr */
	trapv
L31c:
	rts
L31e:
	.short 0x0c47,0x1c00	/* cmpiw #7168,d7 */
	bges L326
	rts
L326:
	.short 0x0c47,0x1e00	/* cmpiw #7680,d7 */
	bges L32e
	bras L2fc
L32e:
	.short 0x0c47,0x5c00	/* cmpiw #23552,d7 */
	bges L336
	rts
L336:
	.short 0x0c47,0x5e00	/* cmpiw #24064,d7 */
	bges L33e
	bras L2fc
L33e:
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L34a:
	.short 0x317c,0x4000,0x000a	/* movew #16384,a0@(10) */
L350:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L350
	tstw d7
	bmis L360
	bsrs L31e
	bras L34a
L360:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L350
	movel d0,a1@
L368:
	tstw a0@
	bmis L368
L36c:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L372:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L372
	tstw d7
	bmis L382
	bsrs L31e
	bras L36c
L382:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L372
	movel a1@,d0
L38a:
	tstw a0@
	bmis L38a
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L39c:
	.short 0x317c,0x4400,0x000a	/* movew #17408,a0@(10) */
L3a2:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L3a2
	tstw d7
	bmis L3b4
	bsrw L31e
	bras L39c
L3b4:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L3a2
	movel d0,a1@
L3bc:
	tstw a0@
	bmis L3bc
L3c0:
	.short 0x317c,0x4422,0x000a	/* movew #17442,a0@(10) */
L3c6:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L3c6
	tstw d7
	bmis L3d8
	bsrw L31e
	bras L3c0
L3d8:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L3c6
	movel d1,a1@
L3e0:
	tstw a0@
	bmis L3e0
L3e4:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L3ea:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L3ea
	tstw d7
	bmis L3fc
	bsrw L31e
	bras L3e4
L3fc:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L3ea
	movel a1@,d0
L404:
	tstw a0@
	bmis L404
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L416:
	.short 0x317c,0x4400,0x000a	/* movew #17408,a0@(10) */
L41c:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L41c
	tstw d7
	bmis L42e
	bsrw L31e
	bras L416
L42e:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L41c
	movel d0,a1@
L436:
	tstw a0@
	bmis L436
L43a:
	.short 0x317c,0x4428,0x000a	/* movew #17448,a0@(10) */
L440:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L440
	tstw d7
	bmis L452
	bsrw L31e
	bras L43a
L452:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L440
	movel d1,a1@
L45a:
	tstw a0@
	bmis L45a
L45e:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L464:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L464
	tstw d7
	bmis L476
	bsrw L31e
	bras L45e
L476:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L464
	movel a1@,d0
L47e:
	tstw a0@
	bmis L47e
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L490:
	.short 0x317c,0x4400,0x000a	/* movew #17408,a0@(10) */
L496:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L496
	tstw d7
	bmis L4a8
	bsrw L31e
	bras L490
L4a8:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L496
	movel d0,a1@
L4b0:
	tstw a0@
	bmis L4b0
L4b4:
	.short 0x317c,0x4427,0x000a	/* movew #17447,a0@(10) */
L4ba:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L4ba
	tstw d7
	bmis L4cc
	bsrw L31e
	bras L4b4
L4cc:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L4ba
	movel d1,a1@
L4d4:
	tstw a0@
	bmis L4d4
L4d8:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L4de:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L4de
	tstw d7
	bmis L4f0
	bsrw L31e
	bras L4d8
L4f0:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L4de
	movel a1@,d0
L4f8:
	tstw a0@
	bmis L4f8
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L50a:
	.short 0x317c,0x4400,0x000a	/* movew #17408,a0@(10) */
L510:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L510
	tstw d7
	bmis L522
	bsrw L31e
	bras L50a
L522:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L510
	movel d0,a1@
L52a:
	tstw a0@
	bmis L52a
L52e:
	.short 0x317c,0x4424,0x000a	/* movew #17444,a0@(10) */
L534:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L534
	tstw d7
	bmis L546
	bsrw L31e
	bras L52e
L546:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L534
	movel d1,a1@
L54e:
	tstw a0@
	bmis L54e
L552:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L558:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L558
	tstw d7
	bmis L56a
	bsrw L31e
	bras L552
L56a:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L558
	movel a1@,d0
L572:
	tstw a0@
	bmis L572
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
L584:
	.short 0x317c,0x4400,0x000a	/* movew #17408,a0@(10) */
L58a:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L58a
	tstw d7
	bmis L59c
	bsrw L31e
	bras L584
L59c:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L58a
	movel d0,a1@
L5a4:
	tstw a0@
	bmis L5a4
L5a8:
	.short 0x317c,0xb000,0x000a	/* movew #-20480,a0@(10) */
L5ae:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L5ae
	tstw d7
	bmis L5c0
	bsrw L31e
	bras L5a8
L5c0:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L5ae
	movel a1@,sp@-
L5c8:
	tstw a0@
	bmis L5c8
L5cc:
	.short 0x317c,0x9000,0x000a	/* movew #-28672,a0@(10) */
L5d2:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L5d2
	tstw d7
	bmis L5e4
	bsrw L31e
	bras L5cc
L5e4:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L5d2
	.short 0x22bc,0x0000,0x00a0	/* movel #160,a1@ */
L5f0:
	tstw a0@
	bmis L5f0
	.short 0x317c,0x0001,0x000a	/* movew #1,a0@(10) */
L5fa:
	tstw a0@
	bmis L5fa
L5fe:
	.short 0x317c,0x6400,0x000a	/* movew #25600,a0@(10) */
L604:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L604
	tstw d7
	bmis L616
	bsrw L31e
	bras L5fe
L616:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L604
	movel a1@,d0
L61e:
	tstw a0@
	bmis L61e
L622:
	.short 0x317c,0x9000,0x000a	/* movew #-28672,a0@(10) */
L628:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L628
	tstw d7
	bmis L63a
	bsrw L31e
	bras L622
L63a:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L628
	movel sp@+,a1@
L642:
	tstw a0@
	bmis L642
	movel sp@+,d7
	rts
	movel d7,sp@-
	moveal a6@(36),a0
	lea a0@(16),a1
	.short 0x7000	/* moveq #0,d0 */
	movew d0,a0@(6)
	movew a0@(6),d0
	.short 0x0240,0xff00	/* andiw #-256,d0 */
	beqs L666
	rts
L666:
	tstw a0@
	bmis L666
L66a:
	.short 0x317c,0x9000,0x000a	/* movew #-28672,a0@(10) */
L670:
	movew a0@,d7
	.short 0x0c47,0x8900	/* cmpiw #-30464,d7 */
	beqs L670
	tstw d7
	bmis L682
	bsrw L31e
	bras L66a
L682:
	.short 0x0c47,0xc900	/* cmpiw #-14080,d7 */
	beqs L670
	.short 0x22bc,0x0000,0x0040	/* movel #64,a1@ */
L68e:
	tstw a0@
	bmis L68e
	clrl d0
	movel sp@+,d7
	rts
	bclr #31,d0
	rts
	.short 0x0000,0x0840	/* orib #64,d0 */
	.short 0x001f,0x4e75	/* orib #117,sp@+ */
	.short 0x0000,0x2046	/* orib #70,d0 */
	moveal d7,a1
	movel d2,sp@-
	bsrw L6ba
	movel a0,d6
	movel a1,d7
	movel sp@+,d2
	rts
L6ba:
	movel d0,d6
	eorl d1,d6
	.short 0x3e3c,0x7f80	/* movew #32640,d7 */
	swap d0
	.short 0x0240,0x7fff	/* andiw #32767,d0 */
	swap d1
	.short 0x0241,0x7fff	/* andiw #32767,d1 */
	cmpw d7,d0
	blts L71a
	movew d1,d2
	.short 0x0042,0x0007	/* oriw #7,d2 */
	subw d0,d2
	.short 0x0242,0xfff8	/* andiw #-8,d2 */
	bgts L6f8
	.short 0x0c80,0x0000,0x7f80	/* cmpil #32640,d0 */
	beqs L6ec
	braw Ld3c
L6ec:
	cmpw d7,d1
	blts L702
	.short 0x0c81,0x0000,0x7f80	/* cmpil #32640,d1 */
	beqs L6fe
L6f8:
	movel d1,d0
	braw Ld3c
L6fe:
	braw Ld34
L702:
	tstl d1
	bnes L716
L706:
	movel d6,d0
	.short 0x0280,0x8000,0x0000	/* andil #-2147483648,d0 */
	.short 0x0a80,0x7f80,0x0000	/* eoril #2139095040,d0 */
	rts
L716:
	braw Ld24
L71a:
	cmpw d7,d1
	blts L730
	.short 0x0c81,0x0000,0x7f80	/* cmpil #32640,d1 */
	beqs L72c
	movel d1,d0
	braw Ld3c
L72c:
	braw Ld0c
L730:
	movew d0,d6
	andw d7,d6
	bnes L74c
	tstl d0
	bnes L746
	tstl d1
	bnes L742
	braw Ld34
L742:
	braw Ld0c
L746:
	bsrw Lae4
	bras L752
L74c:
	eorw d6,d0
	.short 0x0a40,0x0080	/* eoriw #128,d0 */
L752:
	andw d1,d7
	bnes L76a
	tstl d1
	bnes L75c
	bras L706
L75c:
	exg d0,d1
	exg d6,d7
	bsrw Lae4
	exg d0,d1
	exg d6,d7
	bras L770
L76a:
	eorw d7,d1
	.short 0x0a41,0x0080	/* eoriw #128,d1 */
L770:
	.short 0x0447,0x3f00	/* subiw #16128,d7 */
	subw d7,d6
	bvsw Ld24
	swap d0
	lsll #5,d0
	swap d1
	lsll #8,d1
	swap d1
	.short 0x80c1	/* divuw d1,d0 */
	movew d0,d2
	clrw d0
	swap d1
	movew d1,d7
	.short 0xcec2	/* muluw d2,d7 */
	subl d7,d0
	bccs L798
	.short 0x5342	/* subqw #1,d2 */
	addl d1,d0
L798:
	swap d2
	swap d1
	movel d0,d7
	.short 0x80c1	/* divuw d1,d0 */
	bvcs L7a8
	.short 0x343c,0xffff	/* movew #-1,d2 */
	bras L7b8
L7a8:
	movew d0,d2
	clrw d0
	swap d1
	movew d1,d7
	.short 0xcec2	/* muluw d2,d7 */
	subl d7,d0
	bccs L7b8
	.short 0x5382	/* subql #1,d2 */
L7b8:
	movel d2,d0
	braw Lb5a
	.byte 0x00,0x00
L7c0:
	.byte 0x70,0x01	/* orib #1,d0 */
	rts
L7c4:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	tstl d0
	bmis L7e6
	tstl d1
	bmis L7da
	cmpl d1,d0
	bgts L7c0
	blts L7c4
	clrl d0
	rts
L7da:
	tstl d0
	bnes L7c0
	addl d1,d1
	bnes L7c0
	.short 0x7000	/* moveq #0,d0 */
	rts
L7e6:
	tstl d1
	bmis L7f4
	bnes L7c4
	addl d0,d0
	bnes L7c4
	.short 0x7000	/* moveq #0,d0 */
	rts
L7f4:
	cmpl d0,d1
	bgts L7c0
	blts L7c4
	clrl d0
	rts
	.byte 0x00,0x00
L800:
	.byte 0x34,0x01	/* orib #1,d0 */
	.short 0x0042,0x0007	/* oriw #7,d2 */
	subw d0,d2
	.short 0x0242,0xfff8	/* andiw #-8,d2 */
	bgts L826
	.short 0x0c80,0x0000,0x7f80	/* cmpil #32640,d0 */
	beqs L81a
	braw Ld3c
L81a:
	cmpw d7,d1
	blts L82c
	.short 0x0c81,0x0000,0x7f80	/* cmpil #32640,d1 */
	beqs L82c
L826:
	movel d1,d0
	braw Ld3c
L82c:
	tstl d1
	bnes L834
	braw Ld34
L834:
	braw Ld24
L838:
	.short 0x0c81,0x0000,0x7f80	/* cmpil #32640,d1 */
	beqs L846
	movel d1,d0
	braw Ld3c
L846:
	tstl d0
	bnes L84e
	braw Ld34
L84e:
	braw Ld24
L852:
	tstl d0
	bnes L85a
	braw Ld0c
L85a:
	bsrw Lae4
	braw L8be
L862:
	tstl d1
	bnes L86a
	braw Ld0c
L86a:
	exg d0,d1
	exg d6,d7
	bsrw Lae4
	exg d0,d1
	exg d6,d7
	braw L8c8
	moveal d6,a0
	moveal d7,a1
	movel d2,sp@-
	bsrs L898
	movel a0,d6
	movel a1,d7
	movel sp@+,d2
	rts
L88a:
	braw L800
L88e:
	bras L838
L890:
	bras L852
L892:
	bras L862
L894:
	braw Ld24
L898:
	movel d0,d6
	eorl d1,d6
	.short 0x3e3c,0x7f80	/* movew #32640,d7 */
	swap d0
	.short 0x0240,0x7fff	/* andiw #32767,d0 */
	swap d1
	.short 0x0241,0x7fff	/* andiw #32767,d1 */
	cmpw d7,d0
	bges L88a
	cmpw d7,d1
	bges L88e
	movew d0,d6
	andw d7,d6
	beqs L890
	eorw d6,d0
	eorb d7,d0
L8be:
	andw d1,d7
	beqs L892
	eorw d7,d1
	.short 0x0041,0x0080	/* oriw #128,d1 */
L8c8:
	.short 0x0446,0x3f80	/* subiw #16256,d6 */
	addw d7,d6
	bvss L894
	swap d0
	lsll #7,d0
	swap d1
	lsll #7,d1
	movew d0,d7
	movew d1,d2
	.short 0xcec2	/* muluw d2,d7 */
	clrw d7
	swap d7
	swap d0
	.short 0xc4c0	/* muluw d0,d2 */
	addl d2,d7
	swap d1
	swap d0
	movel d0,d2
	.short 0xc4c1	/* muluw d1,d2 */
	addl d2,d7
	swap d0
	.short 0xc0c1	/* muluw d1,d0 */
	clrw d7
	swap d7
	addl d7,d0
	braw Lb5a
	addl d0,d0
	beqs L908
	bcss L90a
	.short 0x7001	/* moveq #1,d0 */
L908:
	rts
L90a:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	.short 0x0000,0x0841	/* orib #65,d0 */
	.short 0x001f,0x2046	/* orib #70,sp@+ */
	moveal d7,a1
	movew d2,sp@-
	.short 0x343c,0x0080	/* movew #128,d2 */
	movel d0,d6
	movel d1,d7
	.short 0x3e3c,0x7f80	/* movew #32640,d7 */
	swap d0
	.short 0x0240,0x7fff	/* andiw #32767,d0 */
	movew d0,d6
	andw d7,d6
	eorw d6,d0
	swap d1
	.short 0x0241,0x7fff	/* andiw #32767,d1 */
	andw d1,d7
	eorw d7,d1
	cmpw d7,d6
	bnew La2a
	.short 0x0c46,0x7f80	/* cmpiw #32640,d6 */
	bnes L970
	movew d1,d7
	.short 0x0047,0x0007	/* oriw #7,d7 */
	subw d0,d7
	.short 0x0247,0xfff8	/* andiw #-8,d7 */
	bgts L95e
	tstl d0
	bnes L960
	tstl d1
	beqs L96a
L95e:
	movel d1,d0
L960:
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld3c
L96a:
	eorl d6,d7
	bpls L9ce
	bmis L9da
L970:
	tstw d6
	bnes L9a8
	swap d0
	bnes L99e
	swap d1
	bnes L98a
	andl d7,d6
	movel d6,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld0e
L98a:
	clrw d7
	orl d7,d1
	movel d1,d0
L990:
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
L998:
	clrw d6
	orl d6,d0
	bras L990
L99e:
	swap d1
	beqs L998
	addl d0,d0
	addl d1,d1
	bras L9b0
L9a8:
	eorb d2,d0
	eorb d2,d1
	swap d0
	swap d1
L9b0:
	eorl d6,d7
	bpls L9e4
	subl d1,d0
	bmis L9c4
	bnew Lb84
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
L9c4:
	negl d0
	bchg #31,d6
	braw Lb84
L9ce:
	movel d6,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld26
L9da:
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld34
L9e4:
	addl d1,d0
	btst #24,d0
	beqw La98
	.short 0x5280	/* addql #1,d0 */
	lsrl #1,d0
	addw d2,d6
	.short 0x0c46,0x7f80	/* cmpiw #32640,d6 */
	bltw La98
	movel d6,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld16
La08:
	swap d1
	bnes La1c
	clrw d6
	swap d0
	orl d6,d0
	braw L990
La16:
	tstl d0
	bnes La20
	bras L9ce
La1c:
	addl d1,d1
	bras La3e
La20:
	braw L960
La24:
	addw d2,d6
	braw La66
La2a:
	bgts La30
	exg d0,d1
	exg d6,d7
La30:
	.short 0x0c46,0x7f80	/* cmpiw #32640,d6 */
	beqs La16
	tstw d7
	beqs La08
	eorb d2,d1
	swap d1
La3e:
	eorb d2,d0
	swap d0
	subw d2,d6
	subw d6,d7
	negw d7
	lsrw #7,d7
	.short 0x0c47,0x0018	/* cmpiw #24,d7 */
	bgts La24
	addl d0,d0
	lsrl d7,d1
	eorl d6,d7
	bmis Labc
	addl d1,d0
	.short 0x5280	/* addql #1,d0 */
	btst #25,d0
	bnes La8a
	lsrl #1,d0
	addw d2,d6
La66:
	beqs La7c
	swap d0
	eorb d2,d0
	roll #1,d6
	rorw #1,d6
	orw d6,d0
	swap d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
La7c:
	.short 0x5280	/* addql #1,d0 */
	addl d6,d6
	roxrl #1,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
La8a:
	.short 0x5280	/* addql #1,d0 */
	lsrl #2,d0
	.short 0x0646,0x0100	/* addiw #256,d6 */
	.short 0x0c46,0x7f80	/* cmpiw #32640,d6 */
	bges Lab0
La98:
	tstw d6
	beqs La7c
	swap d0
	eorb d2,d0
	roll #1,d6
	rorw #1,d6
	orw d6,d0
	swap d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
Lab0:
	movel d6,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	braw Ld16
Labc:
	subxl d7,d7
	subxl d1,d0
	btst #24,d0
	beqw Lb84
	subl d7,d0
	lsrl #1,d0
	addw d2,d6
	beqs La7c
	swap d0
	eorb d2,d0
	roll #1,d6
	rorw #1,d6
	orw d6,d0
	swap d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
Lae4:
	swap d0
	.short 0x3c3c,0x0080	/* movew #128,d6 */
	.short 0x0c80,0x0000,0x0100	/* cmpil #256,d0 */
	bges Laf8
	.short 0x0446,0x0800	/* subiw #2048,d6 */
	bras Lb04
Laf8:
	swap d0
	tstw d0
	bnes Lb04
	roll #8,d0
	.short 0x0446,0x0400	/* subiw #1024,d6 */
Lb04:
	.short 0x0c40,0x0010	/* cmpiw #16,d0 */
	bges Lb10
	roll #4,d0
	.short 0x0446,0x0200	/* subiw #512,d6 */
Lb10:
	.short 0x0c40,0x0040	/* cmpiw #64,d0 */
	bges Lb1c
	roll #2,d0
	.short 0x0446,0x0100	/* subiw #256,d6 */
Lb1c:
	tstb d0
	bmis Lb26
	roll #1,d0
	.short 0x0446,0x0080	/* subiw #128,d6 */
Lb26:
	rts
Lb28:
	negw d6
	lsrw #7,d6
	.short 0x5a46	/* addqw #5,d6 */
	.short 0x0c46,0x001e	/* cmpiw #30,d6 */
	blts Lb38
	braw Ld0c
Lb38:
	.short 0x5386	/* subql #1,d6 */
	lsrl d6,d0
	clrl d7
	addxl d7,d0
	lsrl #1,d0
	.short 0x0286,0x8000,0x0000	/* andil #-2147483648,d6 */
	eorl d6,d0
	rts
Lb4c:
	bras Lb28
Lb4e:
	lsrl #1,d0
	tstw d6
	bges Lb66
	bras Lb28
Lb56:
	braw Ld24
Lb5a:
	btst #29,d0
	bnes Lb4e
	.short 0x0446,0x0080	/* subiw #128,d6 */
	blts Lb4c
Lb66:
	.short 0x7210	/* moveq #16,d1 */
	addl d1,d0
	lsrl #5,d0
	swap d0
	addw d6,d0
	.short 0x0c40,0x7f80	/* cmpiw #32640,d0 */
	bges Lb56
	swap d6
	.short 0x0246,0x8000	/* andiw #-32768,d6 */
	eorw d6,d0
	swap d0
	rts
	.byte 0x00,0x00
Lb84:
	.byte 0x0c,0x80	/* orib #-128,d0 */
	.short 0x0000,0x0100	/* orib #0,d0 */
	bges Lb92
	.short 0x0446,0x0800	/* subiw #2048,d6 */
	bras Lb9e
Lb92:
	swap d0
	tstw d0
	bnes Lb9e
	roll #8,d0
	.short 0x0446,0x0400	/* subiw #1024,d6 */
Lb9e:
	.short 0x0c40,0x0010	/* cmpiw #16,d0 */
	bges Lbaa
	roll #4,d0
	.short 0x0446,0x0200	/* subiw #512,d6 */
Lbaa:
	.short 0x0c40,0x0040	/* cmpiw #64,d0 */
	bges Lbb6
	roll #2,d0
	.short 0x0446,0x0100	/* subiw #256,d6 */
Lbb6:
	tstb d0
	bmis Lbbe
	roll #1,d0
	subw d2,d6
Lbbe:
	tstw d6
	bgts Lbdc
	beqs Lbee
	swap d0
	negw d6
	lsrw #7,d6
	lsrl d6,d0
	addl d6,d6
	roxrl #1,d0
	.short 0x7200	/* moveq #0,d1 */
	addxl d1,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
Lbdc:
	eorw d2,d0
	roll #1,d6
	rorw #1,d6
	orw d6,d0
	swap d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
Lbee:
	swap d0
	.short 0x5280	/* addql #1,d0 */
	addl d6,d6
	roxrl #1,d0
	movel a0,d6
	movel a1,d7
	movew sp@+,d2
	rts
	.byte 0x00,0x00
Lc00:
	.byte 0x4e,0x75	/* orib #117,d0 */
	movel d0,d1
	beqs Lc00
	bpls Lc0a
	negl d0
Lc0a:
	.short 0x0c80,0x0100,0x0000	/* cmpil #16777216,d0 */
	bcss Lc58
	.short 0x323c,0x4a80	/* movew #19072,d1 */
	.short 0x0c80,0x0800,0x0000	/* cmpil #134217728,d0 */
	bcss Lc24
	.short 0x0641,0x0200	/* addiw #512,d1 */
	lsrl #4,d0
Lc24:
	.short 0x0c80,0x0200,0x0000	/* cmpil #33554432,d0 */
	bcss Lc32
	.short 0x0641,0x0100	/* addiw #256,d1 */
	lsrl #2,d0
Lc32:
	.short 0x0c80,0x0100,0x0000	/* cmpil #16777216,d0 */
	bcss Lc40
	.short 0x0641,0x0080	/* addiw #128,d1 */
	lsrl #1,d0
Lc40:
	moveal d1,a0
	.short 0x7200	/* moveq #0,d1 */
	addxl d1,d0
	movel a0,d1
	swap d0
	addw d1,d0
	swap d1
	.short 0x0241,0x8000	/* andiw #-32768,d1 */
	eorw d1,d0
	swap d0
	rts
Lc58:
	.short 0x323c,0x4b00	/* movew #19200,d1 */
	.short 0x0c80,0x0000,0x0100	/* cmpil #256,d0 */
	bges Lc6a
	.short 0x0441,0x0800	/* subiw #2048,d1 */
	bras Lc76
Lc6a:
	swap d0
	tstw d0
	bnes Lc76
	roll #8,d0
	.short 0x0441,0x0400	/* subiw #1024,d1 */
Lc76:
	.short 0x0c40,0x0010	/* cmpiw #16,d0 */
	bges Lc82
	roll #4,d0
	.short 0x0441,0x0200	/* subiw #512,d1 */
Lc82:
	.short 0x0c40,0x0040	/* cmpiw #64,d0 */
	bges Lc8e
	roll #2,d0
	.short 0x0441,0x0100	/* subiw #256,d1 */
Lc8e:
	tstb d0
	bmis Lc98
	roll #1,d0
	.short 0x0441,0x0080	/* subiw #128,d1 */
Lc98:
	.short 0x0a40,0x0080	/* eoriw #128,d0 */
	roll #1,d1
	rorw #1,d1
	orw d1,d0
	swap d0
	rts
	.short 0x0000,0x2042	/* orib #66,d0 */
	.short 0x243c,0x7fff,0xffff	/* movel #2147483647,d2 */
	movel d0,d1
	bpls Lcb8
	.short 0x5282	/* addql #1,d2 */
	eorl d2,d0
Lcb8:
	swap d0
	movew d0,d1
	.short 0x0241,0x7f80	/* andiw #32640,d1 */
	eorw d1,d0
	.short 0x0441,0x3f80	/* subiw #16256,d1 */
	blts Lce0
	.short 0x0a40,0x0080	/* eoriw #128,d0 */
	swap d0
	asrw #7,d1
	.short 0x0441,0x0017	/* subiw #23,d1 */
	bgts Lcf6
	negw d1
	lsrl d1,d0
	tstl d1
	bmis Ld06
	bras Ld08
Lce0:
	.short 0x7000	/* moveq #0,d0 */
	bras Ld08
Lce4:
	.short 0x0c41,0x0069	/* cmpiw #105,d1 */
	blts Lcf2
	tstl d0
	beqs Lcf2
	.short 0x7000	/* moveq #0,d0 */
	bras Ld08
Lcf2:
	movel d2,d0
	bras Ld08
Lcf6:
	.short 0x0c41,0x0008	/* cmpiw #8,d1 */
	bgts Lce4
	lsll d1,d0
	cmpl d2,d0
	bhis Lcf2
	tstl d1
	bpls Ld08
Ld06:
	negl d0
Ld08:
	movel a0,d2
	rts
Ld0c:
	movel d6,d0
Ld0e:
	.short 0x0280,0x8000,0x0000	/* andil #-2147483648,d0 */
	rts
Ld16:
	.short 0x0280,0x8000,0x0000	/* andil #-2147483648,d0 */
	.short 0x0a80,0x7f80,0x0000	/* eoril #2139095040,d0 */
	rts
Ld24:
	movel d6,d0
Ld26:
	.short 0x0280,0x8000,0x0000	/* andil #-2147483648,d0 */
	.short 0x0a80,0x7f80,0x0000	/* eoril #2139095040,d0 */
	rts
Ld34:
	.short 0x203c,0x7f88,0x0000	/* movel #2139619328,d0 */
	rts
Ld3c:
	btst #6,d0
	beqs Ld4a
	bclr #6,d0
	bset #4,d0
Ld4a:
	.short 0x0040,0x7f88	/* oriw #32648,d0 */
	swap d0
	rts
	.short 0x0000,0x003c	/* orib #60,d0 */
	.short 0x0002,0x4e76	/* orib #118,d2 */
	rts
	movel d0,sp@-
	.short 0x80fc,0x0000	/* divuw #0,d0 */
	movel sp@+,d0
	rts
	.short 0x0000,0xf200	/* orib #0,d0 */
	negxb d0
	fmoves %fp0,d0
	rts
	.short 0x0000,0xf200	/* orib #0,d0 */
	negb d0
	fmovel %fp0,d0
	rts
	.byte 0x00,0x00
Ld80:
	.byte 0xf2,0x00	/* orib #0,d0 */
	negb d0
	fmovel fpcr,d0
	movel d0,d1
	.short 0x103c,0x0020	/* moveb #32,d0 */
	fmovel d0,fpcr
	fintx %fp0,%fp0
	fmovel d1,fpcr
	fmoves %fp0,d0
	rts
	tstl d0
	blts Ld80
	fintrzs d0,%fp0
	fmoves %fp0,d0
	rts
	.short 0x0000,0x4a79	/* orib #121,d0 */
	.short 0x0012,0x345c	/* orib #92,a2@ */
	fmoves d0,%fp0
	fadds d1,%fp0
	fmoves %fp0,d0
	rts
	fmoves d0,%fp0
	fsubs d1,%fp0
	fmoves %fp0,d0
	rts
	.short 0x0000,0xf200	/* orib #0,d0 */
	negb d0
	fsglmuls d1,%fp0
	fmoves %fp0,d0
	rts
	.short 0x0000,0xf200	/* orib #0,d0 */
	negb d0
	fsgldivs d1,%fp0
	fmoves %fp0,d0
	rts
	fmoves d0,%fp0
	fcmps d1,%fp0
	.short 0xf281,0x000e	/* fbeq 0xe0a */
	.short 0xf292,0x0006	/* fbgt 0xe06 */
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	.short 0x7001	/* moveq #1,d0 */
	rts
	clrl d0
	rts
	.short 0x203c,0x0000,0x0040	/* movel #64,d0 */
	fmovel d0,fpcr
	clrl d0
	rts
	.short 0xffff	/* .short 0xffff */
	.short 0xf3a2	/* .short 0xf3a2 */
	.short 0xf3be	/* .short 0xf3be */
	.short 0xf336,0xf30a,0xfe8c	/* fsave a6@(0,sp:w:2)@(fffffffffffffe8c) */
	.short 0xf524	/* .short 0xf524 */
	.short 0xf9ac	/* .short 0xf9ac */
	.short 0xfae4	/* .short 0xfae4 */
	.short 0xf87c	/* .short 0xf87c */
	.short 0xf884	/* .short 0xf884 */
	.short 0xf576	/* .short 0xf576 */
	.short 0xf5f0	/* .short 0xf5f0 */
	.short 0xf66a	/* .short 0xf66a */
	.short 0xf6e4	/* .short 0xf6e4 */
	.short 0xf442	/* .short 0xf442 */
	.short 0xf424	/* .short 0xf424 */
	.short 0xffff	/* .short 0xffff */
	.data
