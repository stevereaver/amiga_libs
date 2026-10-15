	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0f,0x5c,0x80,0x07
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x78,0x6d,0x63
	.byte 0x70,0x73,0x75,0x70,0x70,0x6f,0x72,0x74,0x32,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x24,0x56,0x45,0x52,0x3a,0x20,0x4d,0x43,0x50,0x53,0x75,0x70,0x70,0x6f
	.byte 0x72,0x74,0x32,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x37,0x2e,0x31,0x20
	.byte 0x28,0x33,0x30,0x2e,0x30,0x39,0x2e,0x30,0x39,0x29,0x20,0x0a,0x28,0x63,0x29,0x32
	.byte 0x30,0x30,0x32,0x2d,0x32,0x30,0x31,0x30,0x20,0x62,0x79,0x20,0x44,0x2e,0x47,0x72
	.byte 0x6f,0x70,0x70,0xe9,0x00,0x08,0x60,0x23,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x88
	.byte 0x00,0x00,0x00,0xd4,0x00,0x00,0x00,0xf4,0x00,0x00,0x01,0x4a,0x00,0x00,0x01,0x58
	.byte 0x00,0x00,0x01,0x66,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0xb4,0x00,0x00,0x02,0x5a
	.byte 0x00,0x00,0x03,0x80,0x00,0x00,0x02,0xf6,0x00,0x00,0x04,0xf6,0x00,0x00,0x05,0x88
	.byte 0x00,0x00,0x06,0xaa,0x00,0x00,0x07,0xd4,0x00,0x00,0x09,0x5c,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x0d,0xb4,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0xff,0xff,0xff,0xff,0xa0,0x08,0x09,0x00,0x80,0x0a,0x00,0x00,0x00,0x1e,0xa0,0x0e
	.byte 0x06,0x00,0x90,0x14,0x00,0x07,0x90,0x16,0x00,0x01,0x80,0x18,0x00,0x00,0x00,0x32
	.byte 0x00,0x00,0x00,0x00
	moveml d0-a6,sp@-
	moveal a0,a2
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x001c	/* movel #28,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	.short 0x23c0,0x0000,0x0ebc	/* movel d0,0xebc */
	beqs L142
	moveal d0,a5
	.short 0x2b4a,0x0000	/* movel a2,a5@(0) */
	.short 0x7025	/* moveq #37,d0 */
	lea %pc@(Lec0),a1
	jsr a6@(-552)
	movel d0,a5@(4)
	beqs L142
	.short 0x7024	/* moveq #36,d0 */
	lea %pc@(Lecc),a1
	jsr a6@(-552)
	movel d0,a5@(8)
	beqs L142
	moveml sp@+,d0-a6
	rts
L142:
	moveml sp@+,d0-a6
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,d0
	rts
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L172
	btst #3,a6@(14)
	beqs L172
	tstw a6@(32)
	beqs L176
	bset #3,a6@(14)
L172:
	.short 0x7000	/* moveq #0,d0 */
	rts
L176:
	moveml d2/a4-a6,sp@-
	moveal %pc@(Lebc),a5
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
	.short 0x203c,0x0000,0x001c	/* movel #28,d0 */
	jsr a6@(-210)
	movel d2,d0
	moveml sp@+,d2/a4-a6
	rts
	moveml d2-d7/a1/a5-a6,sp@-
	moveal %pc@(Lebc),a5
	movel d0,d4
	movel d1,d5
	moveal a5@(4),a6
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d7
	beqs L240
	.short 0x7202	/* moveq #2,d1 */
	.short 0x7400	/* moveq #0,d2 */
	jsr a6@(-228)
	movel d0,d2
	beqs L250
	movel d7,d1
	jsr a6@(-102)
	moveal d2,a0
	movel a0@(124),d6
	tstl d0
	bnes L1ec
	.short 0x7c00	/* moveq #0,d6 */
L1ec:
	.short 0x7202	/* moveq #2,d1 */
	jsr a6@(-234)
	movel d6,d0
	beqs L250
	.short 0x5240	/* addqw #1,d0 */
	movel d4,d1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	movel d0,d1
	beqs L250
	exg d5,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	moveal a5@(4),a6
	jsr a6@(-30)
	movel d0,d4
	beqs L246
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
	bnes L246
	movel d7,d1
	jsr a6@(-90)
	movel d6,d1
	movel d5,d0
L240:
	moveml sp@+,d2-d7/a1/a5-a6
	rts
L246:
	moveal d5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L250:
	movel d7,d1
	jsr a6@(-90)
	.short 0x7000	/* moveq #0,d0 */
	bras L240
L25a:
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
	bnes L282
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a0
L282:
	movel a0@(10),d0
	.short 0x0c28,0x000d,0x0008	/* cmpib #13,a0@(8) */
	bnes L2b8
	movel a0@(172),d1
	beqs L2b8
	lsll #2,d1
	moveal d1,a1
	movel a1@(16),d1
	beqs L2b8
	lsll #2,d1
	moveal d1,a1
	tstb a1@
	beqs L2b8
	.short 0x72ff	/* moveq #-1,d1 */
	moveal a1,a0
	tstb a0@+
L2ac:
	.short 0x5201	/* addqb #1,d1 */
	tstb a0@+
	bnes L2ac
	cmpb a1@+,d1
	bnes L2b8
	movel a1,d0
L2b8:
	tstl d0
	beqs L2e6
	btst #0,d2
	beqs L2d8
	moveal d0,a0
L2c4:
	.short 0x0c18,0x002f	/* cmpib #47,a0@+ */
	beqs L2f2
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L2f2
	tstb a0@(-1)
	bnes L2c4
L2d8:
	moveal a2,a1
	moveal d0,a0
	.short 0x5383	/* subql #1,d3 */
	moveb a0@+,a1@+
	beqs L2e6
	.short 0x51cb,0xfffa	/* dbf d3,0x2de */
L2e6:
	jsr a6@(-138)
	movel a2,d0
	moveml sp@+,d1-d3/a0-a2/a6
	rts
L2f2:
	movel a0,d0
	bras L2c4
	moveml d1-d2/a0-a1/a6,sp@-
	movel d0,d2
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a0,sp@-
	jsr a6@(-132)
	moveal sp@+,a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	bnes L318
	subal a1,a1
	jsr a6@(-294)
	moveal d0,a0
L318:
	movel a0@(10),d0
	.short 0x0c28,0x000d,0x0008	/* cmpib #13,a0@(8) */
	bnes L34e
	movel a0@(172),d1
	beqs L34e
	lsll #2,d1
	moveal d1,a1
	movel a1@(16),d1
	beqs L34e
	lsll #2,d1
	moveal d1,a1
	tstb a1@
	beqs L34e
	.short 0x72ff	/* moveq #-1,d1 */
	moveal a1,a0
	tstb a0@+
L342:
	.short 0x5201	/* addqb #1,d1 */
	tstb a0@+
	bnes L342
	cmpb a1@+,d1
	bnes L34e
	movel a1,d0
L34e:
	tstl d0
	beqs L36e
	btst #0,d2
	beqs L36e
	moveal d0,a0
L35a:
	.short 0x0c18,0x002f	/* cmpib #47,a0@+ */
	beqs L37c
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L37c
	tstb a0@(-1)
	bnes L35a
L36e:
	movel d0,sp@-
	jsr a6@(-138)
	movel sp@+,d0
	moveml sp@+,d1-d2/a0-a1/a6
	rts
L37c:
	movel a0,d0
	bras L35a
L380:
	moveml a2-a3/a5-a6,sp@-
	tstl d1
	beqs L396
	moveal d0,a2
	moveal d1,a3
	moveal %pc@(Lebc),a5
	moveal a5@(8),a6
	bsrs L3a0
L396:
	moveml sp@+,a2-a3/a5-a6
	rts
	.short 0x7001	/* moveq #1,d0 */
	bras L396
L3a0:
	moveml d2-d3/a2-a3,sp@-
	moveb a2@,d1
	beqw L47a
	.short 0x0c01,0x007e	/* cmpib #126,d1 */
	bnes L3c2
	.short 0x524a	/* addqw #1,a2 */
	bsrs L3a0
	tstl d0
	beqw L4ee
	bplw L47a
	bmiw L4d8
L3c2:
	.short 0x0c01,0x0028	/* cmpib #40,d1 */
	bnes L434
	.short 0x7600	/* moveq #0,d3 */
	.short 0x70fb	/* moveq #-5,d0 */
L3cc:
	tstb d1
	beqw L47a
	.short 0x0c01,0x0028	/* cmpib #40,d1 */
	beqs L3ea
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L400
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L420
	.short 0x524a	/* addqw #1,a2 */
	moveb a2@,d1
	bras L3cc
L3ea:
	tstb d3
	bnew L4d8
	.short 0x0c80,0xffff,0xfffb	/* cmpil #-5,d0 */
	bnew L4d8
	.short 0x524a	/* addqw #1,a2 */
	.short 0x7601	/* moveq #1,d3 */
	bras L40e
L400:
	tstb d3
	beqw L4d8
	tstb a2@(1)
	beqs L47a
	.short 0x524a	/* addqw #1,a2 */
L40e:
	bsrs L430
	tstl d0
	bgtw L4ee
	bmiw L4d8
	lea a2@(1),a2
	bras L3cc
L420:
	tstb d3
	beqw L4d8
	tstb a2@(1)
	bnew L4d8
	bras L47a
L430:
	moveml d2-d3/a2-a3,sp@-
L434:
	moveb a3@,d0
	jsr a6@(-174)
	moveb d0,d2
	moveb a2@,d0
	jsr a6@(-174)
	moveb d0,d1
	cmpb d1,d2
	bnes L454
	tstb d2
	beqw L4ee
	.short 0x528a	/* addql #1,a2 */
	.short 0x528b	/* addql #1,a3 */
	bras L434
L454:
	tstb d2
	bnes L484
	.short 0x0c12,0x0023	/* cmpib #35,a2@ */
	bnes L468
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	bnes L468
	.short 0x544a	/* addqw #2,a2 */
L468:
	moveb a2@,d1
	beqw L4ee
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L4ee
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L4ee
L47a:
	moveal a2,a0
	moveml sp@+,d2-d3/a2-a3
	.short 0x7000	/* moveq #0,d0 */
	rts
L484:
	moveb a2@,d1
	beqs L47a
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L47a
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L47a
	.short 0x0c01,0x003f	/* cmpib #63,d1 */
	bnes L4aa
L49a:
	.short 0x524a	/* addqw #1,a2 */
	.short 0x524b	/* addqw #1,a3 */
	.short 0x0c12,0x003f	/* cmpib #63,a2@ */
	bnes L434
	tstb a3@
	beqs L434
	bras L49a
L4aa:
	.short 0x0c12,0x0023	/* cmpib #35,a2@ */
	bnes L47a
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	bnes L4d8
L4b8:
	.short 0x544a	/* addqw #2,a2 */
	moveb a2@,d1
	beqs L4ee
	.short 0x0c01,0x007c	/* cmpib #124,d1 */
	beqs L4ee
	.short 0x0c01,0x0029	/* cmpib #41,d1 */
	beqs L4ee
	.short 0x0c01,0x0023	/* cmpib #35,d1 */
	bnes L4dc
	.short 0x0c2a,0x003f,0x0001	/* cmpib #63,a2@(1) */
	beqs L4b8
L4d8:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L4f0
L4dc:
	bsrw L430
	tstl d0
	bnes L4f0
	.short 0x528b	/* addql #1,a3 */
	tstb a3@
	bnes L4dc
	braw L434
L4ee:
	.short 0x7001	/* moveq #1,d0 */
L4f0:
	moveml sp@+,d2-d3/a2-a3
	rts
	moveml d1-a2/a5-a6,sp@-
	moveal %pc@(Lebc),a5
	movel a1,d5
	movel a0,d4
	movel a5@(20),d0
	bnes L51c
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Leed),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a5@(20)
	beqs L584
L51c:
	moveal d0,a6
	.short 0x7000	/* moveq #0,d0 */
	moveal d5,a0
	jsr a6@(-48)
	movel d0,d6
	beqs L584
	moveal d6,a0
	moveal d5,a1
	jsr a6@(-60)
	tstl d0
	beqs L57e
	.short 0x7000	/* moveq #0,d0 */
	moveal d6,a2
	moveal d4,a0
	movel a2@(8),d1
	beqs L566
	moveal d1,a1
L544:
	moveb a1@+,a0@+
	bnes L544
	.short 0x5388	/* subql #1,a0 */
	cmpal d4,a0
	beqs L566
	.short 0x0c28,0x003a,0xffff	/* cmpib #58,a0@(-1) */
	beqs L566
	.short 0x0c28,0x002f,0xffff	/* cmpib #47,a0@(-1) */
	beqs L566
	.short 0x10fc,0x002f	/* moveb #47,a0@+ */
	.short 0x10bc,0x0000	/* moveb #0,a0@ */
L566:
	movel a2@(4),d1
	beqs L572
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
	bras L578
	moveml d0-d7/a1-a6,sp@-
	moveal %pc@(Lebc),a5
	movel a0,d4
	tstl d4
	beqs L59a
	tstb a0@
	bnes L5a0
L59a:
	.short 0x283c,0x0000,0x0f56	/* movel #3926,d4 */
L5a0:
	tstl a5@(24)
	bnes L5ba
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	lea %pc@(Lf36),a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
	movel d0,a5@(24)
	beqs L5c2
L5ba:
	moveal a5@(24),a6
	movel d0,d6
	moveal d0,a0
L5c2:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	lea %pc@(Lf46),a1
	jsr a6@(-498)
	movel d0,d5
	beqs L5fe
	moveal d0,a0
	moveal a0@(14),a0
	moveal a0,a3
L5da:
	moveal d4,a4
	tstl a0
	beqs L5fe
	moveal a0@(10),a1
	tstb a1@
	beqs L5f4
L5e8:
	tstb a4@
	bnes L5f0
	tstb a1@
	beqs L5f8
L5f0:
	cmpmb a4@+,a1@+
	beqs L5e8
L5f4:
	moveal a0@,a0
	bras L5da
L5f8:
	lea a0@(14),a0
	bras L66e
L5fe:
	moveal d4,a4
	.short 0x41f9,0x0000,0x069d	/* lea 0x69d,a0 */
L606:
	moveb a4@+,a0@+
	bnes L606
	subal d4,a4
	movel a4,d4
	.short 0x0684,0x0000,0x0011	/* addil #17,d4 */
	.short 0x223c,0x0000,0x068c	/* movel #1676,d1 */
	moveal a5@(4),a6
	jsr a6@(-150)
	tstl d0
	beqs L634
	addl d0,d0
	addl d0,d0
	.short 0x5880	/* addql #4,d0 */
	moveal d0,a3
	lea a3@(14),a0
	bras L66e
L634:
	moveal a5@(4),a6
	.short 0x223c,0x0000,0x0678	/* movel #1656,d1 */
	.short 0x243c,0x0000,0x03ee	/* movel #1006,d2 */
	jsr a6@(-30)
	movel d0,d7
	beqs L668
	movel d7,d1
	.short 0x243c,0x0000,0x068c	/* movel #1676,d2 */
	movel d4,d3
	moveal a5@(4),a6
	jsr a6@(-48)
	movel d7,d1
	moveal a5@(4),a6
	jsr a6@(-36)
L668:
	lea a3@(14),a0
	bras L672
L66e:
	moveal a5@(24),a6
L672:
	moveml sp@+,d0-d7/a1-a6
	rts
	.short 0x7379	/* .short 0x7379 */
	.short 0x733a	/* .short 0x733a */
	.short 0x732f	/* .short 0x732f */
	blts L6e3
	.short 0x706c	/* moveq #108,d0 */
	bvss L6e6
	bcss L6f8
	.short 0x722e	/* moveq #46,d1 */
	bges L6f9
	.short 0x6700,0x7379	/* beqw 0x7a05 */
	.short 0x733a	/* .short 0x733a */
	bccs L6f7
	.short 0x7673	/* moveq #115,d3 */
	movel a3@(25977),sp@(28001)
	.short 0x7073	/* moveq #115,d0 */
	.byte 0x2f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* movel d0,sp@- */
	moveml d1-a6,sp@-
	moveal %pc@(Lebc),a5
	tstb d0
	beqw L7c8
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
L6e3:
	.byte 0xc9	/* addaw a1,a2 */
	cmpaw d1,a2
L6e6:
	blts L6f8
	.short 0x0c00,0x0005	/* cmpib #5,d0 */
	beqw L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	.byte 0x67,0x00,0x00
L6f7:
	.byte 0xd6	/* beqw 0x7cc */
L6f8:
	.byte 0x34
L6f9:
	.byte 0x44	/* moveaw d4,a2 */
	addaw a1,a2
	cmpaw d2,a2
	blts L710
	.short 0x0c00,0x0007	/* cmpib #7,d0 */
	beqw L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7cc
L710:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L728
	.short 0x0c00,0x0006	/* cmpib #6,d0 */
	beqw L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7cc
L728:
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L740
	.short 0x0c00,0x0008	/* cmpib #8,d0 */
	beqw L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqw L7cc
L740:
	moveaw d3,a2
	addaw a1,a2
	cmpaw d1,a2
	blts L762
	moveaw d4,a2
	addaw a1,a2
	cmpaw d2,a2
	blts L762
	.short 0x0c00,0x0001	/* cmpib #1,d0 */
	beqs L7cc
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7cc
L762:
	moveaw d3,a2
	addaw a1,a2
	cmpaw d1,a2
	blts L784
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L784
	.short 0x0c00,0x0002	/* cmpib #2,d0 */
	beqs L7cc
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7cc
L784:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L7a6
	moveaw d4,a2
	addaw a1,a2
	cmpaw d2,a2
	blts L7a6
	.short 0x0c00,0x0003	/* cmpib #3,d0 */
	beqs L7cc
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7cc
L7a6:
	moveaw d5,a2
	subaw a1,a2
	cmpaw d1,a2
	bgts L7c8
	moveaw d6,a2
	subaw a1,a2
	cmpaw d2,a2
	bgts L7c8
	.short 0x0c00,0x0004	/* cmpib #4,d0 */
	beqs L7cc
	.short 0x0c00,0x0009	/* cmpib #9,d0 */
	beqs L7cc
	.short 0x0c00,0x000a	/* cmpib #10,d0 */
	beqs L7cc
L7c8:
	.short 0x7000	/* moveq #0,d0 */
	bras L7ce
L7cc:
	.short 0x7001	/* moveq #1,d0 */
L7ce:
	moveml sp@+,d1-a6
	rts
	moveml d1-a6,sp@-
	moveal %pc@(Lebc),a5
	.short 0x76ff	/* moveq #-1,d3 */
	movel d0,d2
	movel a5@(12),d0
	bnes L804
	moveml d2/a0-a1/a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Lef9),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveml sp@+,d2/a0-a1/a6
	movel d0,a5@(12)
	beqw L954
L804:
	subal a2,a2
	subal a3,a3
	.short 0x7600	/* moveq #0,d3 */
	.short 0xb3fc,0x0000,0x0000	/* cmpal #0,a1 */
	beqw L932
	.short 0x76ff	/* moveq #-1,d3 */
	.short 0x0c11,0x007e	/* cmpib #126,a1@ */
	bnew L81e
L81e:
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L932
	tstl d2
	beqs L848
	.short 0x0c82,0x0000,0x0001	/* cmpil #1,d2 */
	beqs L8a6
	.short 0x0c82,0x0000,0x0003	/* cmpil #3,d2 */
	beqs L8a6
	.short 0x0c82,0x0000,0x0002	/* cmpil #2,d2 */
	beqs L864
	braw L932
L848:
	moveal a0@(86),a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L932
	moveal a0@(16),a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqw L932
L864:
	moveml a0-a1,sp@-
	.short 0x203c,0x0000,0x00c8	/* movel #200,d0 */
	.short 0x7201	/* moveq #1,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	moveml sp@+,a0-a1
	tstl d0
	beqw L932
	moveal d0,a3
	movel a1,sp@-
	.short 0x7001	/* moveq #1,d0 */
	.short 0x223c,0x0000,0x00c8	/* movel #200,d1 */
	moveal a3,a1
	bsrw L25a
	moveal sp@+,a1
	tstl d0
	beqw L932
	moveal d0,a0
	tstb a0@
	beqw L932
	bras L91e
L8a6:
	movew a0@(20),d0
	.short 0x0240,0x000f	/* andiw #15,d0 */
	.short 0x0c40,0x000f	/* cmpiw #15,d0 */
	beqs L8f8
	.short 0x0c40,0x0001	/* cmpiw #1,d0 */
	beqs L8c0
	.short 0x0c40,0x0002	/* cmpiw #2,d0 */
	bnes L8f8
L8c0:
	bras L8f8
	moveml a0-a1,sp@-
	moveal a5@(12),a6
	jsr a6@(-522)
	moveml sp@+,a0-a1
	tstl d0
	beqs L8f8
	moveal d0,a2
	moveal a2@,a4
L8da:
	.short 0xb9fc,0x0000,0x0000	/* cmpal #0,a4 */
	beqs L8f8
	cmpal a4@(14),a0
	beqs L8f2
	cmpal a2@(8),a4
	beqs L8f8
	moveal a4@,a4
	bras L8da
L8f2:
	moveal a4@(10),a0
	bras L90e
L8f8:
	.short 0x0c82,0x0000,0x0003	/* cmpil #3,d2 */
	bnes L90a
	movel a0@(26),d2
	beqs L90a
	moveal d2,a0
	bras L90e
L90a:
	moveal a0@(22),a0
L90e:
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqs L932
	.short 0xb1fc,0xffff,0xffff	/* cmpal #-1,a0 */
	beqs L932
L91e:
	movel a0,d1
	movel a1,d0
	bsrw L380
	tstl d0
	bmis L932
	beqs L930
	.short 0x7600	/* moveq #0,d3 */
	bras L932
L930:
	.short 0x76ff	/* moveq #-1,d3 */
L932:
	.short 0xb5fc,0x0000,0x0000	/* cmpal #0,a2 */
	beqs L942
	moveal a5@(12),a6
	jsr a6@(-528)
L942:
	.short 0xb7fc,0x0000,0x0000	/* cmpal #0,a3 */
	beqs L954
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-690)
L954:
	movel d3,d0
	moveml sp@+,d1-a6
	rts
	moveml d1-a6,sp@-
	moveal %pc@(Lebc),a5
	movel a0,d5
	beqw Lbf2
	tstl a1
	beqw Lbf2
	movel a5@(12),d0
	bnes L994
	moveml d2/a0-a1/a6,sp@-
	.short 0x7000	/* moveq #0,d0 */
	lea %pc@(Lef9),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveml sp@+,d2/a0-a1/a6
	movel d0,a5@(12)
	beqw Lbf2
L994:
	movel a1,d4
	movew a1@(10),d3
	addw %pc@(Ldb2),d3
	moveal a1@(18),a1
	movel a1,d7
	beqw Lbf2
	.short 0x7c01	/* moveq #1,d6 */
L9aa:
	tstl a1
	beqs L9b4
	moveal a1@,a1
	.short 0x5206	/* addqb #1,d6 */
	bras L9aa
L9b4:
	movel d6,d0
	.short 0xc0fc,0x002e	/* muluw #46,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-684)
	tstl d0
	beqw Lbf2
	moveal d0,a4
	moveal d7,a1
	moveal d0,a2
	.short 0x7201	/* moveq #1,d1 */
L9d6:
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
	beqs La3c
	moveal a1@,a1
	movel a2,d2
	.short 0x0682,0x0000,0x002e	/* addil #46,d2 */
	movel d2,a2@
	moveal a2@,a2
	bras L9d6
La3c:
	movew a2@(8),d0
	.short 0x33c0,0x0000,0x0da6	/* movew d0,0xda6 */
	.short 0x33c0,0x0000,0x0daa	/* movew d0,0xdaa */
	.short 0x303c,0x0000	/* movew #0,d0 */
	.short 0x33c0,0x0000,0x0d9e	/* movew d0,0xd9e */
	.short 0x33c0,0x0000,0x0da2	/* movew d0,0xda2 */
	.short 0x33c0,0x0000,0x0dae	/* movew d0,0xdae */
	movew a2@(10),d0
	.short 0x33c0,0x0000,0x0da4	/* movew d0,0xda4 */
	.short 0x33c0,0x0000,0x0da8	/* movew d0,0xda8 */
	subw a2@(10),d0
	movew a2@(6),d0
	subw a2@(10),d0
	subw %pc@(Ldb2),d0
	negw d0
	.short 0x33c0,0x0000,0x0da0	/* movew d0,0xda0 */
	.short 0x33c0,0x0000,0x0dac	/* movew d0,0xdac */
	.short 0x33c0,0x0000,0x0db0	/* movew d0,0xdb0 */
	.byte 0x25,0x7c,0x00,0x00,0x0d,0x7e,0x00,0x12	/* movel #3454,a2@(18) */
	moveal a5@(12),a6
	lea %pc@(Lbfa),a1
	moveal d5,a2
	moveal d4,a0
	movel a0@(14),a1@(36)
	movew a2@(4),a1@(6)
	movew a2@(6),a1@(14)
	.short 0x3039,0x0000,0x0da6	/* movew 0xda6,d0 */
	.short 0xd079,0x0000,0x0db2	/* addw 0xdb2,d0 */
	.short 0xd079,0x0000,0x0db2	/* addw 0xdb2,d0 */
	movew d0,a1@(22)
	movew a4@(10),d0
	.short 0xc0c6	/* muluw d6,d0 */
	.short 0x0640,0x0010	/* addiw #16,d0 */
	movew d0,a1@(30)
	.short 0x207c,0x0000,0x0000	/* moveal #0,a0 */
	jsr a6@(-606)
	.short 0x23c0,0x0000,0x0c36	/* movel d0,0xc36 */
	beqs Lafa
	.short 0x23c5,0x0000,0x0c3a	/* movel d5,0xc3a */
	movel d0,d5
Lafa:
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
Lb22:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x2079,0x0000,0x0c36	/* moveal 0xc36,a0 */
	moveal a0@(86),a0
	jsr a6@(-384)
	jsr a6@(-372)
	moveal d0,a0
	lea %pc@(Lc3e),a1
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
	.short 0x2079,0x0000,0x0c36	/* moveal 0xc36,a0 */
	moveal a0@(86),a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-378)
	.short 0x0c44,0x0020	/* cmpiw #32,d4 */
	bnes Lb22
	lea %pc@(Lc3e),a1
	.byte 0x23,0x7c,0x00,0x00,0x01,0x00,0x00,0x14	/* movel #256,a1@(20) */
	moveal a1@(28),a0
	movew a0@(38),d0
	lslb #5,d0
	movew d0,a1@(24)
	.short 0x237a,0x0092,0x002c	/* movel %pc@(0xc3a),a1@(44) */
	.short 0x2079,0x0000,0x0c36	/* moveal 0xc36,a0 */
	moveal a0@(86),a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal %pc@(Lc3a),a0
	moveal a0@(86),a0
	lea %pc@(Lc3e),a1
	jsr a6@(-366)
	.short 0x2079,0x0000,0x0c36	/* moveal 0xc36,a0 */
	moveal a0@(86),a0
	jsr a6@(-384)
	jsr a6@(-372)
	moveal a5@(12),a6
	moveal %pc@(Lc36),a0
	jsr a6@(-72)
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4,a1
	jsr a6@(-690)
Lbf2:
	.short 0x70ff	/* moveq #-1,d0 */
	moveml sp@+,d1-a6
	rts
Lbfa:
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
Lc36:
	.byte 0x00,0x00,0x00,0x00
Lc3a:
	.byte 0x00,0x00,0x00,0x00
Lc3e:
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* oriw #163,a3@(4162) */
	.byte 0x00,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #0,a0@ */
	btst d0,d0
	btst d0,d5
	.short 0x0000,0x0d9e	/* orib #-98,d0 */
	.short 0x0000,0x0d8e	/* orib #-114,d0 */
	.short 0x0001,0x0001	/* orib #1,d1 */
	.short 0x0200,0x0105	/* andib #5,d0 */
	.byte 0x00,0x00,0x0d,0x9e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #-98,d0 */
	.short 0x0000,0x0014	/* orib #20,d0 */
	.short 0x000a	/* .short 0x000a */
	.short 0x0014,0x000a	/* orib #10,a4@ */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.byte 0x00,0x00
Ldb2:
	.byte 0x00,0x04	/* orib #4,d0 */
	moveml d1-d7/a1-a6,sp@-
	moveal %pc@(Lebc),a5
	movel a0,d5
	beqw Le80
	.short 0x7600	/* moveq #0,d3 */
	movel a5@(16),d0
	bnes Lde0
	lea %pc@(Ledc),a1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	movel d0,a5@(16)
	beqw Le80
Lde0:
	moveal d0,a6
	btst #2,a6@(236)
	bnes Ldf2
	btst #1,a6@(236)
	beqs Ldf4
Ldf2:
	.short 0x7601	/* moveq #1,d3 */
Ldf4:
	moveal d5,a4
	lea a4@(44),a0
	.short 0xb1fc,0x0000,0x0000	/* cmpal #0,a0 */
	beqs Le7e
	moveal a5@(16),a6
	jsr a6@(-792)
	.short 0x0c80,0xffff,0xffff	/* cmpil #-1,d0 */
	beqs Le7e
	movel d0,d2
	lea %pc@(Lf0b),a1
	bsrs Le8a
	tstl d0
	beqs Le2e
	moveal d0,a3
	movel d2,d0
	moveal a3,a6
	jsr a6@(-54)
	tstl d0
	bnes Le2e
	.short 0x7602	/* moveq #2,d3 */
Le2e:
	tstl a3
	beqs Le3c
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
Le3c:
	.short 0x0c83,0x0000,0x0002	/* cmpil #2,d3 */
	beqs Le82
	lea %pc@(Lf21),a1
	bsrs Le8a
	tstl d0
	beqs Le76
	moveal d0,a3
	moveal a3,a6
	moveal d5,a4
	lea a4@(84),a0
	moveal a0@(4),a0
	.short 0x7008	/* moveq #8,d0 */
	jsr a6@(-42)
	.short 0x0c80,0x0000,0x0001	/* cmpil #1,d0 */
	bnes Le6c
	.short 0x7603	/* moveq #3,d3 */
Le6c:
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
Le76:
	.short 0x0c83,0x0000,0x0003	/* cmpil #3,d3 */
	beqs Le82
Le7e:
	bras Le82
Le80:
	.short 0x76ff	/* moveq #-1,d3 */
Le82:
	movel d3,d0
	moveml sp@+,d1-d7/a1-a6
	rts
Le8a:
	moveml d1-d3/a2-a3,sp@-
	moveal a1,a3
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-132)
	lea a6@(378),a0
	moveal a3,a1
	jsr a6@(-276)
	tstl d0
	beqs Leae
	moveal a3,a1
	.short 0x7000	/* moveq #0,d0 */
	jsr a6@(-552)
Leae:
	movel d0,d3
	jsr a6@(-138)
	movel d3,d0
	moveml sp@+,d1-d3/a2-a3
	rts
Lebc:
	.short 0x0000,0x0000	/* orib #0,d0 */
Lec0:
	bccs Lf31
	.short 0x732e	/* .short 0x732e */
	bges Lf2f
	bhis Lf3a
	bsrs Lf3c
	.short 0x7900	/* .short 0x7900 */
Lecc:
	.short 0x7574	/* .short 0x7574 */
	bvss Lf3c
	bvss Lf46
	.short 0x792e	/* .short 0x792e */
	bges Lf3f
	bhis Lf4a
	bsrs Lf4c
	.short 0x7900	/* .short 0x7900 */
Ledc:
	beqs Lf50
	bsrs Lf50
	bvcs Lf4b
	blss Lf57
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
Leed:
	.byte 0x61,0x73,0x6c	/* oriw #29548,a1@- */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
Lef9:
	.byte 0x69,0x6e,0x74,0x75,0x69	/* oriw #28276,a1@(30057) */
	.short 0x7469	/* moveq #105,d2 */
	.short 0x6f6e	/* bles 0xf70 */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
Lf0b:
	.byte 0x63,0x79,0x62	/* oriw #31074,a3@- */
	.short 0x6572	/* bcss 0xf82 */
	.short 0x6772	/* beqs 0xf84 */
	.short 0x6170	/* bsrs 0xf84 */
	.short 0x6869	/* bvcs 0xf7f */
	.short 0x6373	/* blss 0xf8b */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
Lf21:
	.byte 0x50,0x69,0x63	/* oriw #26979,a0@ */
	.short 0x6173	/* bsrs 0xf99 */
	.short 0x736f	/* .short 0x736f */
	.short 0x3936,0x4150	/* movew a6@(0),a4@- */
	.byte 0x49,0x2e,0x6c
Lf2f:
	.byte 0x69	/* chkl a6@(27753),d4 */
	.byte 0x62
Lf31:
	.byte 0x72	/* bhis 0xfa4 */
	.short 0x6172	/* bsrs 0xfa6 */
	.short 0x7900	/* .short 0x7900 */
Lf36:
	.short 0x6b65	/* bmis 0xf9d */
	.short 0x796d	/* .short 0x796d */
Lf3a:
	.short 0x6170	/* bsrs 0xfac */
Lf3c:
	.byte 0x2e,0x6c,0x69
Lf3f:
	.byte 0x62	/* moveal a4@(26978),sp */
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
Lf46:
	.byte 0x6b,0x65	/* orib #101,d0 */
	.short 0x796d	/* .short 0x796d */
Lf4a:
	.byte 0x61
Lf4b:
	.byte 0x70	/* bsrs 0xfbc */
Lf4c:
	.byte 0x2e,0x72,0x65,0x73
Lf50:
	.byte 0x6f,0x75,0x72,0x63,0x65,0x00,0x75
Lf57:
	.byte 0x73	/* moveal a2@(6f757263)@(65007573),sp */
	.byte 0x61,0x31,0x00,0x00	/* bsrs 0xf8b */
	.data
