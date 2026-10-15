	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0d,0xfe,0x80,0x06
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x78,0x6d,0x63
	.byte 0x70,0x73,0x75,0x70,0x70,0x6f,0x72,0x74,0x32,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x24,0x56,0x45,0x52,0x3a,0x20,0x4d,0x43,0x50,0x53,0x75,0x70,0x70,0x6f
	.byte 0x72,0x74,0x32,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x36,0x2e,0x31,0x73
	.byte 0x20,0x28,0x31,0x35,0x2e,0x31,0x32,0x2e,0x30,0x36,0x29,0x20,0x0a,0x28,0x63,0x29
	.byte 0x32,0x30,0x30,0x32,0x2d,0x32,0x30,0x30,0x36,0x20,0x62,0x79,0x20,0x44,0x2e,0x47
	.byte 0x72,0x6f,0x70,0x70,0xe9,0x00,0x02,0x62,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x88
	.byte 0x00,0x00,0x00,0xc0,0x00,0x00,0x00,0xe0,0x00,0x00,0x01,0x3c,0x00,0x00,0x01,0x4a
	.byte 0x00,0x00,0x01,0x58,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0xa6,0x00,0x00,0x02,0x58
	.byte 0x00,0x00,0x03,0x7e,0x00,0x00,0x02,0xf4,0x00,0x00,0x04,0xec,0x00,0x00,0x05,0x8a
	.byte 0x00,0x00,0x06,0xa6,0x00,0x00,0x07,0xd0,0x00,0x00,0x09,0x42,0xff,0xff,0xff,0xff
	.byte 0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e,0xa0,0x0e,0x06,0x00,0x90,0x14
	.byte 0x00,0x06,0x90,0x16,0x00,0x01,0x80,0x18,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x00
	moveml d0-a6,sp@-
	.byte 0x24
Le5:
	.byte 0x48	/* moveal a0,a2 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x0018	/* movel #24,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	.short 0x23c0,0x0000,0x0d9a	/* movel d0,0xd9a */
	beqw L134
	moveal d0,a5
	.short 0x2b4a,0x0000	/* movel a2,a5@(0) */
	.short 0x7025	/* moveq #37,d0 */
	lea %pc@(Ld9e),a1
	jsr a6@(-552)
	movel d0,a5@(4)
	beqw L134
	.short 0x7024	/* moveq #36,d0 */
	lea %pc@(Ldaa),a1
	jsr a6@(-552)
	movel d0,a5@(8)
	beqw L134
	moveml sp@+,d0-a6
	rts
L134:
	moveml sp@+,d0-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	rts
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L164
	btst #3,a6@(14)
	beqs L164
	tstw a6@(32)
	beqs L168
	bset #3,a6@(14)
L164:
	.short 0x7000	/* moveq #0,d0 */
	rts
L168:
	moveml d2/a4-a6,sp@-
	moveal %pc@(Ld9a),a5
	.short 0x242d,0x0000	/* movel a5@(0),d2 */
	moveal a6,a4
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4,a1
	jsr a6@(-252)
	.short 0x7000	/* moveq #0,d0 */
	moveal a4,a1
	movew a4@(16),d0
	subaw d0,a1
	addw a4@(18),d0
	jsr a6@(-210)
	moveal a5,a1
	.short 0x203c,0x0000,0x0018	/* movel #24,d0 */
	jsr a6@(-210)
	movel d2,d0
	moveml sp@+,d2/a4-a6
	rts
	moveml d2-d7/a1/a5-a6,sp@-
	moveal %pc@(Ld9a),a5
	movel d0,d4
	movel d1,d5
	moveal a5@(4),a6
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d7
	beqs L23c
	.short 0x7202	/* moveq #2,d1 */
	.short 0x7400	/* moveq #0,d2 */
	jsr a6@(-228)
	movel d0,d2
	beqw L24c
	movel d7,d1
	jsr a6@(-102)
	moveal d2,a0
	movel a0@(124),d6
	tstl d0
	bnes L1e0
	.short 0x7c00	/* moveq #0,d6 */
L1e0:
	.short 0x7202	/* moveq #2,d1 */
	jsr a6@(-234)
	movel d6,d0
	beqw L24c
	.short 0x5240	/* addqw #1,d0 */
	movel d4,d1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	movel d0,d1
	beqw L24c
	exg d5,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	moveal a5@(4),a6
	jsr a6@(-30)
	movel d0,d4
	beqw L242
	movel d4,d1
	movel d5,d2
	movel d6,d3
	jsr a6@(-42)
	movel d0,d3
	moveal d5,a0
	addal d6,a0
	sf a0@
	movel d4,d1
	jsr a6@(-36)
	cmpl d3,d6
	bnew L242
	movel d7,d1
	jsr a6@(-90)
	movel d6,d1
	movel d5,d0
L23c:
	moveml sp@+,d2-d7/a1/a5-a6
	rts
L242:
	moveal d5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L24c:
	movel d7,d1
	jsr a6@(-90)
	.short 0x7000	/* moveq #0,d0 */
	braw L23c
L258:
	moveml d1-d3/a0-a2/a6,sp@-
	movel d0,d2
	movel d1,d3
	moveal a1,a2
	sf a2@
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a0,sp@-
	jsr a6@(-132)
	moveal sp@+,a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	bnes L280
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a0
L280:
	movel a0@(10),d0
	.short 0x0c28,0x000d,0x0008	/* cmpib #13,a0@(8) */
	bnes L2b6
	movel a0@(172),d1
	beqs L2b6
	lsll #2,d1
	moveal d1,a1
	movel a1@(16),d1
	beqs L2b6
	lsll #2,d1
	moveal d1,a1
	tstb a1@
	beqs L2b6
	.short 0x72ff	/* moveq #-1,d1 */
	moveal a1,a0
	tstb a0@+
L2aa:
	.short 0x5201	/* addqb #1,d1 */
	tstb a0@+
	bnes L2aa
	cmpb a1@+,d1
	bnes L2b6
	movel a1,d0
L2b6:
	tstl d0
	beqs L2e4
	btst #0,d2
	beqs L2d6
	moveal d0,a0
L2c2:
	.short 0x0c18,0x002f	/* cmpib #47,a0@+ */
	beqs L2f0
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L2f0
	tstb a0@(-1)
	bnes L2c2
L2d6:
	moveal a2,a1
	moveal d0,a0
	.short 0x5383	/* subql #1,d3 */
	moveb a0@+,a1@+
	beqs L2e4
	.short 0x51cb,0xfffa	/* dbf d3,0x2dc */
L2e4:
	jsr a6@(-138)
	movel a2,d0
	moveml sp@+,d1-d3/a0-a2/a6
	rts
L2f0:
	movel a0,d0
	bras L2c2
	moveml d1-d2/a0-a1/a6,sp@-
	movel d0,d2
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a0,sp@-
	jsr a6@(-132)
	moveal sp@+,a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	bnes L316
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a0
L316:
	movel a0@(10),d0
	.short 0x0c28,0x000d,0x0008	/* cmpib #13,a0@(8) */
	bnes L34c
	movel a0@(172),d1
	beqs L34c
	lsll #2,d1
	moveal d1,a1
	movel a1@(16),d1
	beqs L34c
	lsll #2,d1
	moveal d1,a1
	tstb a1@
	beqs L34c
	.short 0x72ff	/* moveq #-1,d1 */
	moveal a1,a0
	tstb a0@+
L340:
	.short 0x5201	/* addqb #1,d1 */
	tstb a0@+
	bnes L340
	cmpb a1@+,d1
	bnes L34c
	movel a1,d0
L34c:
	tstl d0
	beqs L36c
	btst #0,d2
	beqs L36c
	moveal d0,a0
L358:
	.short 0x0c18,0x002f	/* cmpib #47,a0@+ */
	beqs L37a
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L37a
	tstb a0@(-1)
	bnes L358
L36c:
	movel d0,sp@-
	jsr a6@(-138)
	movel sp@+,d0
	moveml sp@+,d1-d2/a0-a1/a6
	rts
L37a:
	movel a0,d0
	bras L358
L37e:
	moveml a2-a3/a5-a6,sp@-
	moveal d0,a2
	moveal d1,a3
	moveal %pc@(Ld9a),a5
	moveal a5@(8),a6
	bsrs L396
	moveml sp@+,a2-a3/a5-a6
	rts
L396:
	moveml d2-d3/a2-a3,sp@-
	moveb a2@,d1
	beqw L470
	.short 0x0c01,0x007e	/* cmpib #126,d1 */
	bnes L3b8
	.short 0x524a	/* addqw #1,a2 */
	bsrs L396
	tstl d0
	beqw L4e4
	bplw L470
	bmiw L4ce
L3b8:
	.short 0x0c01,0x0028	/* cmpib #40,d1 */
	bnes L42a
	.short 0x7600	/* moveq #0,d3 */
	.short 0x70fb	/* moveq #-5,d0 */
L3c2:
	tstb d1
	beqw L470
	.short 0x0c01,0x0028	/* cmpib #40,d1 */
	beqs L3e0
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L3f6
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L416
	.short 0x524a	/* addqw #1,a2 */
	moveb a2@,d1
	bras L3c2
L3e0:
	tstb d3
	bnew L4ce
	.short 0x0c80,0xffff,0xfffb	/* cmpil #-5,d0 */
	bnew L4ce
	.short 0x524a	/* addqw #1,a2 */
	.short 0x7601	/* moveq #1,d3 */
	bras L404
L3f6:
	tstb d3
	beqw L4ce
	tstb a2@(1)
	beqs L470
	.short 0x524a	/* addqw #1,a2 */
L404:
	bsrs L426
	tstl d0
	bgtw L4e4
	bmiw L4ce
	lea a2@(1),a2
	bras L3c2
L416:
	tstb d3
	beqw L4ce
	tstb a2@(1)
	bnew L4ce
	bras L470
L426:
	moveml d2-d3/a2-a3,sp@-
L42a:
	moveb a3@,d0
	jsr a6@(-174)
	moveb d0,d2
	moveb a2@,d0
	jsr a6@(-174)
	moveb d0,d1
	cmpb d1,d2
	bnes L44a
	tstb d2
	beqw L4e4
	.short 0x528a	/* addql #1,a2 */
	.short 0x528b	/* addql #1,a3 */
	bras L42a
L44a:
	tstb d2
	bnes L47a
	.short 0x0c12,0x0023	/* cmpib #35,a2@ */
	bnes L45e
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	bnes L45e
	.short 0x544a	/* addqw #2,a2 */
L45e:
	moveb a2@,d1
	beqw L4e4
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L4e4
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L4e4
L470:
	moveal a2,a0
	moveml sp@+,d2-d3/a2-a3
	.short 0x7000	/* moveq #0,d0 */
	rts
L47a:
	moveb a2@,d1
	beqs L470
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L470
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L470
	.short 0x0c01,0x003f	/* cmpib #63,d1 */
	bnes L4a0
L490:
	.short 0x524a	/* addqw #1,a2 */
	.short 0x524b	/* addqw #1,a3 */
	.short 0x0c12,0x003f	/* cmpib #63,a2@ */
	bnes L42a
	tstb a3@
	beqs L42a
	bras L490
L4a0:
	.short 0x0c12,0x0023	/* cmpib #35,a2@ */
	bnes L470
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	bnes L4ce
L4ae:
	.short 0x544a	/* addqw #2,a2 */
	moveb a2@,d1
	beqs L4e4
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L4e4
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L4e4
	.short 0x0c01,0x0023	/* cmpib #35,d1 */
	bnes L4d2
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	beqs L4ae
L4ce:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L4e6
L4d2:
	bsrw L426
	tstl d0
	bnes L4e6
	.short 0x528b	/* addql #1,a3 */
	tstb a3@
	bnes L4d2
	braw L42a
L4e4:
	.short 0x7001	/* moveq #1,d0 */
L4e6:
	moveml sp@+,d2-d3/a2-a3
	rts
	moveml d1-a2/a5-a6,sp@-
	moveal %pc@(Ld9a),a5
	movel a1,d5
	movel a0,d4
	movel a5@(16),d0
	bnes L514
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Ldba),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a5@(16)
	beqw L584
L514:
	moveal d0,a6
	.short 0x7000	/* moveq #0,d0 */
	moveal d5,a0
	jsr a6@(-48)
	movel d0,d6
	beqw L584
	moveal d6,a0
	moveal d5,a1
	jsr a6@(-60)
	tstl d0
	beqw L57e
	.short 0x7000	/* moveq #0,d0 */
	moveal d6,a2
	moveal d4,a0
	movel a2@(8),d1
	beqw L564
	moveal d1,a1
L542:
	moveb a1@+,a0@+
	bnes L542
	.short 0x5388	/* subql #1,a0 */
	cmpal d4,a0
	beqs L564
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L564
	.short 0x0c28,0x002f,0xffff	/* cmpib #47,a0@(-1) */
	beqs L564
	.short 0x10fc,0x002f	/* moveb #47,a0@+ */
	.short 0x10bc,0x0000	/* moveb #0,a0@ */
L564:
	movel a2@(4),d1
	beqw L572
	moveal d1,a1
L56e:
	moveb a1@+,a0@+
	bnes L56e
L572:
	moveal d6,a0
	jsr a6@(-54)
L578:
	moveml sp@+,d1-a2/a5-a6
	rts
L57e:
	moveal d6,a0
	jsr a6@(-54)
L584:
	.short 0x70ff	/* moveq #-1,d0 */
	braw L578
	moveml d0-d7/a1-a6,sp@-
	moveal %pc@(Ld9a),a5
	movel a0,d4
	bnes L59c
	.short 0x283c,0x0000,0x0df8	/* movel #3576,d4 */
L59c:
	tstl a5@(20)
	bnes L5b6
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	lea %pc@(Ldd8),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(20)
	beqs L5be
L5b6:
	moveal a5@(20),a6
	movel d0,d6
	moveal d0,a0
L5be:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	lea %pc@(Lde8),a1
	jsr a6@(-498)
	movel d0,d5
	beqs L5fa
	moveal d0,a0
	moveal a0@(14),a0
	moveal a0,a3
L5d6:
	moveal d4,a4
	tstl a0
	beqs L5fa
	moveal a0@(10),a1
	tstb a1@
	beqs L5f0
L5e4:
	tstb a4@
	bnes L5ec
	tstb a1@
	beqs L5f4
L5ec:
	cmpmb a4@+,a1@+
	beqs L5e4
L5f0:
	moveal a0@,a0
	bras L5d6
L5f4:
	lea a0@(14),a0
	bras L66a
L5fa:
	moveal d4,a4
	.short 0x41f9,0x0000,0x0699	/* lea 0x699,a0 */
L602:
	moveb a4@+,a0@+
	bnes L602
	subal d4,a4
	movel a4,d4
	.short 0x0684,0x0000,0x0011	/* addil #17,d4 */
	.short 0x223c,0x0000,0x0688	/* movel #1672,d1 */
	moveal a5@(4),a6
	jsr a6@(-150)
	tstl d0
	beqs L630
	addl d0,d0
	addl d0,d0
	.short 0x5880	/* addql #4,d0 */
	moveal d0,a3
	lea a3@(14),a0
	bras L66a
L630:
	moveal a5@(4),a6
	.short 0x223c,0x0000,0x0674	/* movel #1652,d1 */
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	jsr a6@(-30)
	movel d0,d7
	beqs L664
	movel d7,d1
	.short 0x243c,0x0000,0x0688	/* movel #1672,d2 */
	movel d4,d3
	moveal a5@(4),a6
	jsr a6@(-48)
	movel d7,d1
	moveal a5@(4),a6
	jsr a6@(-36)
L664:
	lea a3@(14),a0
	bras L66e
L66a:
	moveal a5@(20),a6
L66e:
	moveml sp@+,d0-d7/a1-a6
	rts
	.short 0x7379	/* .short 0x7379 */
	.short 0x733a	/* .short 0x733a */
	.short 0x732f	/* .short 0x732f */
	blts L6df
	.short 0x706c	/* moveq #108,d0 */
	bvss L6e2
	bcss L6f4
	.short 0x722e	/* moveq #46,d1 */
	bges L6f5
	.short 0x6700,0x7379	/* beqw 0x7a01 */
	.short 0x733a	/* .short 0x733a */
	bccs L6f3
	.short 0x7673	/* moveq #115,d3 */
	movel a3@(25977),sp@(28001)
	.short 0x7073	/* moveq #115,d0 */
	.byte 0x2f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* movel d0,sp@- */
	moveml d1-a6,sp@-
	moveal %pc@(Ld9a),a5
	tstb d0
	beqw L7c4
	.short 0x0281,0x0000,0x00ff	/* andil #255,d1 */
	moveaw d1,a1
	movew a0@(18),d1
	movew a0@(16),d2
	movew a0@(8),d3
	movew a0@(10),d4
	movew d3,d5
	addw a0@(12),d5
	.short 0x5345	/* subqw #1,d5 */
	movew d4,d6
	addw a0@(14),d6
	.short 0x5346	/* subqw #1,d6 */
	moveaw d3,a2
	.byte 0xd4
L6df:
	.byte 0xc9	/* addaw a1,a2 */
	cmpaw d1,a2
L6e2:
	blts L6f4
	.short 0x0c00,0x0005	/* cmpib #5,d0 */
	beqw L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	.byte 0x67,0x00,0x00
L6f3:
	.byte 0xd6	/* beqw 0x7c8 */
L6f4:
	.byte 0x34
L6f5:
	.byte 0x44	/* moveaw d4,a2 */
	addaw a1,a2
	cmpaw d2,a2
	blts L70c
	.short 0x0c00,0x0007	/* cmpib #7,d0 */
	beqw L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7c8
L70c:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L724
	.short 0x0c00,0x0006	/* cmpib #6,d0 */
	beqw L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7c8
L724:
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L73c
	.short 0x0c00,0x0008	/* cmpib #8,d0 */
	beqw L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7c8
L73c:
	moveaw d3,a2
	addaw a1,a2
	cmpaw d1,a2
	blts L75e
	moveaw d4,a2
	addaw a1,a2
	cmpaw d2,a2
	blts L75e
	.short 0x0c00,0x0001	/* cmpib #1,d0 */
	beqs L7c8
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7c8
L75e:
	moveaw d3,a2
	addaw a1,a2
	cmpaw d1,a2
	blts L780
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L780
	.short 0x0c00,0x0002	/* cmpib #2,d0 */
	beqs L7c8
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7c8
L780:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L7a2
	moveaw d4,a2
	addaw a1,a2
	cmpaw d2,a2
	blts L7a2
	.short 0x0c00,0x0003	/* cmpib #3,d0 */
	beqs L7c8
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7c8
L7a2:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L7c4
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L7c4
	.short 0x0c00,0x0004	/* cmpib #4,d0 */
	beqs L7c8
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7c8
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7c8
L7c4:
	.short 0x7000	/* moveq #0,d0 */
	bras L7ca
L7c8:
	.short 0x7001	/* moveq #1,d0 */
L7ca:
	moveml sp@+,d1-a6
	rts
	moveml d1-a6,sp@-
	moveal %pc@(Ld9a),a5
	.short 0x76ff	/* moveq #-1,d3 */
	movel d0,d2
	movel a5@(12),d0
	bnes L800
	moveml d2/a0-a1/a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Ldc6),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveml sp@+,d2/a0-a1/a6
	movel d0,a5@(12)
	beqw L93a
L800:
	subal a2,a2
	subal a3,a3
	.short 0xb3fc,0x0000,0x0000	/* cmpal #0,a1 */
	beqw L918
	.short 0x0c11,0x007e	/* cmpib #126,a1@ */
	bnes L816
	.short 0x76ff	/* moveq #-1,d3 */
L816:
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L918
	tstl d2
	beqs L83a
	.short 0x0c82,0x0000,0x0001	/* cmpil #1,d2 */
	beqw L89a
	.short 0x0c82,0x0000,0x0002	/* cmpil #2,d2 */
	beqs L856
	braw L918
L83a:
	moveal a0@(86),a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L918
	moveal a0@(16),a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L918
L856:
	moveml a0-a1,sp@-
	.short 0x203c,0x0000,0x00c8	/* movel #200,d0 */
	.short 0x7201	/* moveq #1,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveml sp@+,a0-a1
	tstl d0
	beqw L918
	moveal d0,a3
	movel a1,sp@-
	.short 0x7001	/* moveq #1,d0 */
	.short 0x223c,0x0000,0x00c8	/* movel #200,d1 */
	moveal a3,a1
	bsrw L258
	moveal sp@+,a1
	tstl d0
	beqw L918
	moveal d0,a0
	tstb a0@
	beqw L918
	braw L904
L89a:
	movew a0@(20),d0
	.short 0x0240,0x000f	/* andiw #15,d0 */
	.short 0x0c40,0x000f	/* cmpiw #15,d0 */
	beqs L8ec
	.short 0x0c40,0x0001	/* cmpiw #1,d0 */
	beqs L8b4
	.short 0x0c40,0x0002	/* cmpiw #2,d0 */
	bnes L8ec
L8b4:
	bras L8ec
	moveml a0-a1,sp@-
	moveal a5@(12),a6
	jsr a6@(-522)
	moveml sp@+,a0-a1
	tstl d0
	beqs L8ec
	moveal d0,a2
	moveal a2@,a4
L8ce:
	.short 0xb9fc,0x0000,0x0000	/* cmpal #0,a4 */
	beqs L8ec
	cmpal a4@(14),a0
	beqs L8e6
	cmpal a2@(8),a4
	beqs L8ec
	moveal a4@,a4
	bras L8ce
L8e6:
	moveal a4@(10),a0
	bras L8f0
L8ec:
	moveal a0@(22),a0
L8f0:
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L918
	.short 0xb1fc,0xffff,0xffff	/* cmpal #-1,a0 */
	beqw L918
L904:
	movel a0,d1
	movel a1,d0
	bsrw L37e
	tstl d0
	bmis L918
	beqs L916
	.short 0x7600	/* moveq #0,d3 */
	bras L918
L916:
	.short 0x76ff	/* moveq #-1,d3 */
L918:
	.short 0xb5fc,0x0000,0x0000	/* cmpal #0,a2 */
	beqs L928
	moveal a5@(12),a6
	jsr a6@(-528)
L928:
	.short 0xb7fc,0x0000,0x0000	/* cmpal #0,a3 */
	beqs L93a
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L93a:
	movel d3,d0
	moveml sp@+,d1-a6
	rts
	moveml d1-a6,sp@-
	moveal %pc@(Ld9a),a5
	movel a0,d5
	beqw Lbd8
	tstl a1
	beqw Lbd8
	movel a5@(12),d0
	bnes L97a
	moveml d2/a0-a1/a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Ldc6),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveml sp@+,d2/a0-a1/a6
	movel d0,a5@(12)
	beqw Lbd8
L97a:
	movel a1,d4
	movew a1@(10),d3
	addw %pc@(Ld98),d3
	moveal a1@(18),a1
	movel a1,d7
	beqw Lbd8
	.short 0x7c01	/* moveq #1,d6 */
L990:
	tstl a1
	beqs L99a
	moveal a1@,a1
	.short 0x5206	/* addqb #1,d6 */
	bras L990
L99a:
	movel d6,d0
	.short 0xc0fc,0x002e	/* muluw #46,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	tstl d0
	beqw Lbd8
	moveal d0,a4
	moveal d7,a1
	moveal d0,a2
	.short 0x7201	/* moveq #1,d1 */
L9bc:
	.short 0x357c,0x0005,0x0004	/* movew #5,a2@(4) */
	movew d1,d0
	.short 0x0440,0x0001	/* subiw #1,d0 */
	addw d0,d0
	addw a1@(6),d0
	addw d3,d0
	movew d0,a2@(6)
	movel a1@(8),a2@(8)
	.short 0x357c,0x0000,0x000c	/* movew #0,a2@(12) */
	.short 0x357c,0x0002,0x000e	/* movew #2,a2@(14) */
	.short 0x357c,0x0001,0x0010	/* movew #1,a2@(16) */
	movel a1@(18),a2@(26)
	moveal a1@(18),a0
	.short 0x10bc,0x0002	/* moveb #2,a0@ */
	.short 0x117c,0x0003,0x0001	/* moveb #3,a0@(1) */
	.short 0x117c,0x0000,0x0002	/* moveb #0,a0@(2) */
	.short 0x5301	/* subqb #1,d1 */
	movew d1,a2@(38)
	.short 0x5401	/* addqb #2,d1 */
	cmpb d1,d6
	beqs La22
	moveal a1@,a1
	movel a2,d2
	.short 0x0682,0x0000,0x002e	/* addil #46,d2 */
	movel d2,a2@
	moveal a2@,a2
	bras L9bc
La22:
	movew a2@(8),d0
	.short 0x33c0,0x0000,0x0d8c	/* movew d0,0xd8c */
	.short 0x33c0,0x0000,0x0d90	/* movew d0,0xd90 */
	.short 0x303c,0x0000	/* movew #0,d0 */
	.short 0x33c0,0x0000,0x0d84	/* movew d0,0xd84 */
	.short 0x33c0,0x0000,0x0d88	/* movew d0,0xd88 */
	.short 0x33c0,0x0000,0x0d94	/* movew d0,0xd94 */
	movew a2@(10),d0
	.short 0x33c0,0x0000,0x0d8a	/* movew d0,0xd8a */
	.short 0x33c0,0x0000,0x0d8e	/* movew d0,0xd8e */
	subw a2@(10),d0
	movew a2@(6),d0
	subw a2@(10),d0
	subw %pc@(Ld98),d0
	negw d0
	.short 0x33c0,0x0000,0x0d86	/* movew d0,0xd86 */
	.short 0x33c0,0x0000,0x0d92	/* movew d0,0xd92 */
	.short 0x33c0,0x0000,0x0d96	/* movew d0,0xd96 */
	.byte 0x25,0x7c,0x00,0x00,0x0d,0x64,0x00,0x12	/* movel #3428,a2@(18) */
	moveal a5@(12),a6
	lea %pc@(Lbe0),a1
	moveal d5,a2
	moveal d4,a0
	movel a0@(14),a1@(36)
	movew a2@(4),a1@(6)
	movew a2@(6),a1@(14)
	.short 0x3039,0x0000,0x0d8c	/* movew 0xd8c,d0 */
	.short 0xd079,0x0000,0x0d98	/* addw 0xd98,d0 */
	.short 0xd079,0x0000,0x0d98	/* addw 0xd98,d0 */
	movew d0,a1@(22)
	movew a4@(10),d0
	.short 0xc0c6	/* muluw d6,d0 */
	.short 0x0640,0x0010	/* addiw #16,d0 */
	movew d0,a1@(30)
	.short 0x207c,0x0000,0x0000	/* moveal #0,a0 */
	jsr a6@(-606)
	.short 0x23c0,0x0000,0x0c1c	/* movel d0,0xc1c */
	beqs Lae0
	.short 0x23c5,0x0000,0x0c20	/* movel d5,0xc20 */
	movel d0,d5
Lae0:
	moveal d5,a0
	moveal a4,a1
	.short 0x7000	/* moveq #0,d0 */
	movel d6,d1
	.short 0x247c,0x0000,0x0000	/* moveal #0,a2 */
	moveal a5@(12),a6
	jsr a6@(-438)
	moveal d0,a0
	moveal d5,a1
	moveal a4,a0
	movel d6,d0
	.short 0x247c,0x0000,0x0000	/* moveal #0,a2 */
	jsr a6@(-432)
Lb08:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x2079,0x0000,0x0c1c	/* moveal 0xc1c,a0 */
	moveal a0@(86),a0
	jsr a6@(-384)
	jsr a6@(-372)
	moveal d0,a0
	lea %pc@(Lc24),a1
	movel a0@,a1@+
	movel a0@(4),a1@+
	movel a0@(8),a1@+
	movel a0@(12),a1@+
	movel a0@(16),a1@+
	movel a0@(20),a1@+
	movel a0@(24),a1@+
	movel a0@(28),a1@+
	movel a0@(32),a1@+
	movel a0@(36),a1@+
	movel a0@(40),a1@+
	movel a0@(44),a1@+
	movel a0@(48),a1@+
	movel a0@(20),d4
	.short 0x2079,0x0000,0x0c1c	/* moveal 0xc1c,a0 */
	moveal a0@(86),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-378)
	.short 0x0c44,0x0020	/* cmpiw #32,d4 */
	bnes Lb08
	lea %pc@(Lc24),a1
	.byte 0x23,0x7c,0x00,0x00,0x01,0x00,0x00,0x14	/* movel #256,a1@(20) */
	moveal a1@(28),a0
	movew a0@(38),d0
	lslb #5,d0
	movew d0,a1@(24)
	.short 0x237a,0x0092,0x002c	/* movel %pc@(0xc20),a1@(44) */
	.short 0x2079,0x0000,0x0c1c	/* moveal 0xc1c,a0 */
	moveal a0@(86),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal %pc@(Lc20),a0
	moveal a0@(86),a0
	lea %pc@(Lc24),a1
	jsr a6@(-366)
	.short 0x2079,0x0000,0x0c1c	/* moveal 0xc1c,a0 */
	moveal a0@(86),a0
	jsr a6@(-384)
	jsr a6@(-372)
	moveal a5@(12),a6
	moveal %pc@(Lc1c),a0
	jsr a6@(-72)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4,a1
	jsr a6@(-690)
Lbd8:
	.short 0x70ff	/* moveq #-1,d0 */
	moveml sp@+,d1-a6
	rts
Lbe0:
	orb d0,d0
	.short 0x0064,0x0000	/* oriw #0,a4@- */
	.short 0x0000,0x8000	/* orib #0,d0 */
	.short 0x0065,0x0000	/* oriw #0,a5@- */
	.short 0x0000,0x8000	/* orib #0,d0 */
	.short 0x0066,0x0000	/* oriw #0,a6@- */
	.short 0x0064,0x8000	/* oriw #-32768,a4@- */
	.short 0x0067,0x0000	/* oriw #0,sp@- */
	.short 0x0064,0x8000	/* oriw #-32768,a4@- */
	.short 0x006e,0x0000,0x0000	/* oriw #0,a6@(0) */
	orb d0,d0
	.short 0x006a,0x0008,0x0060	/* oriw #8,a2@(96) */
	orb d0,d0
	.byte 0x00,0x6b,0x00,0xa3,0x10,0x42,0x00,0x00,0x00,0x00
Lc1c:
	.byte 0x00,0x00,0x00,0x00
Lc20:
	.byte 0x00,0x00,0x00,0x00
Lc24:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* oriw #163,a3@(4162) */
	.byte 0x00,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #0,a0@ */
	btst d0,d0
	btst d0,d5
	.short 0x0000,0x0d84	/* orib #-124,d0 */
	.short 0x0000,0x0d74	/* orib #116,d0 */
	.short 0x0001,0x0001	/* orib #1,d1 */
	.short 0x0200,0x0105	/* andib #5,d0 */
	.byte 0x00,0x00,0x0d,0x84,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #-124,d0 */
	.short 0x0000,0x0014	/* orib #20,d0 */
	.short 0x000a	/* .short 0x000a */
	.short 0x0014,0x000a	/* orib #10,a4@ */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.byte 0x00,0x00
Ld98:
	.byte 0x00,0x04	/* orib #4,d0 */
Ld9a:
	.short 0x0000,0x0000	/* orib #0,d0 */
Ld9e:
	.short 0x646f	/* bccs 0xe0f */
	.short 0x732e	/* .short 0x732e */
	.short 0x6c69	/* bges 0xe0d */
	.short 0x6272	/* bhis 0xe18 */
	.short 0x6172	/* bsrs 0xe1a */
	.short 0x7900	/* .short 0x7900 */
Ldaa:
	.short 0x7574	/* .short 0x7574 */
	.short 0x696c	/* bvss 0xe1a */
	.short 0x6974	/* bvss 0xe24 */
	.short 0x792e	/* .short 0x792e */
	.short 0x6c69	/* bges 0xe1d */
	.short 0x6272	/* bhis 0xe28 */
	.short 0x6172	/* bsrs 0xe2a */
	.short 0x7900	/* .short 0x7900 */
Ldba:
	.short 0x6173	/* bsrs 0xe2f */
	bges Ldec
	.short 0x6c69	/* bges 0xe29 */
	.short 0x6272	/* bhis 0xe34 */
	.short 0x6172	/* bsrs 0xe36 */
	.short 0x7900	/* .short 0x7900 */
Ldc6:
	.short 0x696e	/* bvss 0xe36 */
	.short 0x7475	/* moveq #117,d2 */
	.short 0x6974	/* bvss 0xe40 */
	.short 0x696f	/* bvss 0xe3d */
	bgts Ldfe
	.short 0x6c69	/* bges 0xe3b */
	.short 0x6272	/* bhis 0xe46 */
	.short 0x6172	/* bsrs 0xe48 */
	.short 0x7900	/* .short 0x7900 */
Ldd8:
	.short 0x6b65	/* bmis 0xe3f */
	.short 0x796d	/* .short 0x796d */
	.short 0x6170	/* bsrs 0xe4e */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
Lde8:
	.byte 0x6b,0x65	/* orib #101,d0 */
	.short 0x796d	/* .short 0x796d */
Ldec:
	.short 0x6170	/* bsrs 0xe5e */
	.byte 0x2e,0x72,0x65,0x73,0x6f,0x75,0x72,0x63,0x65,0x00,0x75,0x73	/* moveal a2@(6f757263)@(65007573),sp */
	.short 0x6131	/* bsrs 0xe2d */
	.byte 0x00,0x00
Ldfe:
	.byte 0x02,0x62	/* orib #98,d0 */
	.data
