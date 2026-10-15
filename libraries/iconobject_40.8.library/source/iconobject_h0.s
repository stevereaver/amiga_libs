	.text
L0:
	moveml d2/a5-a6,sp@-
	moveal sp@(16),a5
	.short 0x41f9,0x0000,0x019c	/* lea 0x19c,a0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-558)
	lea a5@(42),a0
	jsr a6@(-558)
	pea a5@(88)
	bsrw L86c
	.short 0x584f	/* addqw #4,sp */
	.short 0x43f9,0x0000,0x0068	/* lea 0x68,a1 */
	.short 0x7027	/* moveq #39,d0 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0194	/* movel d0,0x194 */
	.short 0x43f9,0x0000,0x0074	/* lea 0x74,a1 */
	.short 0x7027	/* moveq #39,d0 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x018c	/* movel d0,0x18c */
	.short 0x43f9,0x0000,0x0086	/* lea 0x86,a1 */
	.short 0x7027	/* moveq #39,d0 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0190	/* movel d0,0x190 */
	.short 0x7001	/* moveq #1,d0 */
	.short 0x7240	/* moveq #64,d1 */
	lsll #7,d1
	movel d1,d2
	jsr a6@(-696)
	.short 0x23c0,0x0000,0x0198	/* movel d0,0x198 */
	beqs L90
	.short 0x4ab9,0x0000,0x0194	/* tstl 0x194 */
	beqs L8e
	.short 0x4ab9,0x0000,0x018c	/* tstl 0x18c */
	beqs L8e
	.short 0x4ab9,0x0000,0x0190	/* tstl 0x190 */
	beqs L8e
	.short 0x7001	/* moveq #1,d0 */
	.byte 0x0c,0x40
L8e:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
L90:
	moveml sp@+,d2/a5-a6
	rts
L96:
	moveml d2/a5-a6,sp@-
	moveal sp@(16),a5
	tstl a5@(102)
	bnes Lda
	.short 0x41f9,0x0000,0x0096	/* lea 0x96,a0 */
	movel a0,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,a5@(102)
	beqs Lf8
	movel d0,d2
	.short 0x41f9,0x0000,0x00ac	/* lea 0xac,a0 */
	movel a0,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-630)
	tstw d0
	bnes Lda
	.short 0x7000	/* moveq #0,d0 */
	bras Lf8
Lda:
	lea a5@(88),a0
	moveal a5@(96),a1
	cmpal a0,a1
	bnes Lf6
	movel a5,sp@-
	bsrw L2d4
	.short 0x584f	/* addqw #4,sp */
	tstw d0
	bnes Lf6
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x0c,0x40
Lf6:
	.byte 0x70,0x01	/* cmpiw #28673,d0 */
Lf8:
	moveml sp@+,d2/a5-a6
	rts
Lfe:
	moveml d2/a5-a6,sp@-
	moveal sp@(16),a5
	movel a5,sp@-
	bsrw L380
	.short 0x584f	/* addqw #4,sp */
	movel a5@(102),d0
	beqs L12c
	movel d0,d2
	.short 0x41f9,0x0000,0x00b2	/* lea 0xb2,a0 */
	movel a0,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-636)
	clrl a5@(102)
L12c:
	.short 0x2039,0x0000,0x0190	/* movel 0x190,d0 */
	beqs L144
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.short 0x42b9,0x0000,0x0190	/* clrl 0x190 */
L144:
	.short 0x2039,0x0000,0x018c	/* movel 0x18c,d0 */
	beqs L15c
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.short 0x42b9,0x0000,0x018c	/* clrl 0x18c */
L15c:
	.short 0x2039,0x0000,0x0194	/* movel 0x194,d0 */
	beqs L174
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	.short 0x42b9,0x0000,0x0194	/* clrl 0x194 */
L174:
	.short 0x2039,0x0000,0x0198	/* movel 0x198,d0 */
	beqs L18c
	moveal d0,a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-702)
	.short 0x42b9,0x0000,0x0198	/* clrl 0x198 */
L18c:
	moveml sp@+,d2/a5-a6
	rts
L192:
	moveml a2-a3/a5,sp@-
	moveal sp@(16),a5
	.short 0x4878,0x001c	/* pea 0x1c */
	bsrw L6b6
	.short 0x584f	/* addqw #4,sp */
	moveal d0,a3
	tstl d0
	beqs L216
	.short 0x7000	/* moveq #0,d0 */
	moveal a3,a0
	.short 0x721b	/* moveq #27,d1 */
	moveb d0,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0x1b0 */
	moveal a5,a0
L1b8:
	tstb a0@+
	bnes L1b8
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movel a0,d0
	.short 0x7221	/* moveq #33,d1 */
	addl d1,d0
	movel d0,sp@-
	bsrw L6b6
	.short 0x584f	/* addqw #4,sp */
	moveal d0,a2
	movel d0,a3@(10)
	beqs L20c
	.short 0x41f9,0x0000,0x00da	/* lea 0xda,a0 */
	moveal a2,a1
L1de:
	moveb a0@+,a1@+
	bnes L1de
	movel a5,sp@-
	movel a2,sp@-
	bsrw L964
	.short 0x4879,0x0000,0x00fa	/* pea 0xfa */
	movel a2,sp@-
	bsrw L964
	lea sp@(16),sp
	.short 0x41f9,0x0000,0x00fc	/* lea 0xfc,a0 */
	movel a0,a3@(22)
	.short 0x7005	/* moveq #5,d0 */
	movew d0,a3@(26)
	bras L216
L20c:
	movel a3,sp@-
	bsrw L704
	.short 0x584f	/* addqw #4,sp */
	subal a3,a3
L216:
	movel a3,d0
	moveml sp@+,a2-a3/a5
	rts
L21e:
	moveml a5-a6,sp@-
	moveal sp@(12),a5
	movel a5,d0
	beqs L258
	movel a5@(18),d0
	beqs L23e
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	clrl a5@(18)
L23e:
	movel a5@(10),d0
	beqs L250
	movel d0,sp@-
	bsrw L704
	.short 0x584f	/* addqw #4,sp */
	clrl a5@(10)
L250:
	movel a5,sp@-
	bsrw L704
	.short 0x584f	/* addqw #4,sp */
L258:
	moveml sp@+,a5-a6
	rts
L25e:
	moveml d7/a3/a5-a6,sp@-
	moveal sp@(24),a5
	.short 0x7e00	/* moveq #0,d7 */
	movel a5,sp@-
	movel sp@(24),sp@-
	bsrw L192
	.short 0x504f	/* addqw #8,sp */
	moveal d0,a3
	tstl d0
	beqs L2c0
	moveal a3@(10),a1
	.short 0x7000	/* moveq #0,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-552)
	moveal d0,a1
	movel d0,a3@(18)
	beqs L2c0
	.short 0x7280	/* moveq #-128,d1 */
	moveal d0,a0
	cmpb a0@(9),d1
	beqs L2c0
	moveal a1,a6
	jsr a6@(-30)
	movel d0,a3@(14)
	beqs L2c0
	moveal a3@(18),a0
	moveb a0@(9),a3@(9)
	lea a5@(88),a0
	moveal a3,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-270)
	.short 0x7e01	/* moveq #1,d7 */
L2c0:
	tstw d7
	bnes L2ce
	movel a5,sp@-
	movel a3,sp@-
	bsrw L21e
	.short 0x504f	/* addqw #8,sp */
L2ce:
	moveml sp@+,d7/a3/a5-a6
	rts
L2d4:
	moveml d2/d5-d7/a2-a3/a5-a6,sp@-
	moveal sp@(36),a5
	.short 0x7a00	/* moveq #0,d5 */
	pea a5@(88)
	bsrw L86c
	.short 0x584f	/* addqw #4,sp */
	.short 0x41f9,0x0000,0x0102	/* lea 0x102,a0 */
	movel a0,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d7
	beqs L378
	movel d7,d1
	jsr a6@(-126)
	movel d0,d6
	.short 0x7202	/* moveq #2,d1 */
	.short 0x7400	/* moveq #0,d2 */
	jsr a6@(-228)
	moveal d0,a3
	tstl d0
	beqs L366
	movel d7,d1
	movel a3,d2
	jsr a6@(-102)
	tstl d0
	beqs L358
	lea a3@(8),a2
	bras L332
L328:
	movel a5,sp@-
	movel a2,sp@-
	bsrw L25e
	.short 0x504f	/* addqw #8,sp */
L332:
	movel d7,d1
	movel a3,d2
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-108)
	tstl d0
	bnes L328
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-132)
	.short 0x7274	/* moveq #116,d1 */
	addl d1,d1
	cmpl d1,d0
	bnes L358
	.short 0x7a01	/* moveq #1,d5 */
L358:
	movel a3,d2
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x7202	/* moveq #2,d1 */
	jsr a6@(-234)
L366:
	movel d6,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-126)
	movel d7,d1
	jsr a6@(-90)
L378:
	movew d5,d0
	moveml sp@+,d2/d5-d7/a2-a3/a5-a6
	rts
L380:
	moveml a2-a3/a5-a6,sp@-
	moveal sp@(20),a5
	lea a5@(88),a3
	bras L3a8
L38e:
	movel a2@(18),d0
	beqs L39e
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
L39e:
	movel a5,sp@-
	movel a2,sp@-
	bsrw L21e
	.short 0x504f	/* addqw #8,sp */
L3a8:
	moveal a3,a0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-258)
	moveal d0,a2
	tstl d0
	bnes L38e
	moveml sp@+,a2-a3/a5-a6
	rts
	.short 0x9efc,0x0010	/* subaw #16,sp */
	moveml d2-d4/d6-d7/a2-a6,sp@-
	movel a1,sp@(44)
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a0,a5
	clrl sp@(52)
	.short 0x7e00	/* moveq #0,d7 */
	movel a0,sp@(40)
	movel a6,sp@(48)
	movel a5,d0
	beqs L430
	moveal a5,a0
L3e6:
	tstb a0@+
	bnes L3e6
	.short 0x5388	/* subql #1,a0 */
	subal a5,a0
	movel a0,d0
	.short 0x5c80	/* addql #6,d0 */
	movel d0,sp@-
	bsrw L6b6
	.short 0x584f	/* addqw #4,sp */
	moveal d0,a2
	tstl d0
	beqs L430
	moveal a5,a0
	moveal a2,a1
L404:
	moveb a0@+,a1@+
	bnes L404
	.short 0x4879,0x0000,0x0122	/* pea 0x122 */
	movel a2,sp@-
	bsrw L964
	movel a2,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	movel d0,d7
	movel a2,sp@
	bsrw L704
	.short 0x504f	/* addqw #8,sp */
L430:
	tstl d7
	beqw L4be
	movel d7,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x7601	/* moveq #1,d3 */
	.short 0x7840	/* moveq #64,d4 */
	lsll #8,d4
	jsr a6@(-366)
	moveal sp@(48),a0
	moveal a0@(88),a3
	subal a2,a2
	movel a5,d6
	lea a0@(92),a5
	bras L4a8
L45c:
	movel d7,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x76ff	/* moveq #-1,d3 */
	jsr a6@(-66)
	movel sp@(44),d0
	movel a2,sp@-
	movel d2,sp@-
	movel d0,sp@-
	.short 0x4878,0x0002	/* pea 0x2 */
	movel d7,sp@-
	.short 0x2f3c,0x8000,0x1066	/* movel #-2147479450,sp@- */
	movel d6,sp@-
	.short 0x2f3c,0x8000,0x1064	/* movel #-2147479452,sp@- */
	moveal a2,a1
	moveal a3@(14),a0
	.short 0x2c79,0x0000,0x018c	/* moveal 0x18c,a6 */
	moveal sp,a2
	jsr a6@(-636)
	lea sp@(28),sp
	moveal sp@+,a2
	moveal a3@,a3
	movel d0,sp@(52)
L4a8:
	tstl sp@(52)
	bnes L4b2
	cmpal a5,a3
	bnes L45c
L4b2:
	movel d7,d1
	.short 0x2c79,0x0000,0x0194	/* moveal 0x194,a6 */
	jsr a6@(-36)
L4be:
	movel sp@(52),d0
	moveml sp@+,d2-d4/d6-d7/a2-a6
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl d0
	rts
	moveml a4/a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x2c79,0x0000,0x018c	/* moveal 0x18c,a6 */
	jsr a6@(-642)
	moveml sp@+,a4/a6
	tstl d0
	rts
	.short 0x9efc,0x0010	/* subaw #16,sp */
	moveml d6-d7/a2-a6,sp@-
	movel d0,d7
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	subal a5,a5
	moveal a6@(88),a2
	subal a1,a1
	movel a1,sp@(32)
	.short 0x43f9,0x0000,0x0128	/* lea 0x128,a1 */
	movel a1,d6
	lea a6@(92),a1
	moveal a0,a3
	movel a0,sp@(36)
	movel a1,sp@(28)
	bras L56a
L51e:
	movel d6,d1
	moveal a3,a0
	.short 0x2c79,0x0000,0x0190	/* moveal 0x190,a6 */
	.short 0x203c,0x8000,0x1064	/* movel #-2147479452,d0 */
	jsr a6@(-36)
	movel a2,sp@-
	clrl sp@-
	movel a3,sp@-
	.short 0x4878,0x0002	/* pea 0x2 */
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x1064	/* movel #-2147479452,sp@- */
	movel d7,sp@-
	.short 0x2f3c,0x8000,0x1398	/* movel #-2147478632,sp@- */
	moveal a2@(14),a0
	moveal sp@(64),a1
	.short 0x2c79,0x0000,0x018c	/* moveal 0x18c,a6 */
	moveal sp,a2
	jsr a6@(-636)
	lea sp@(28),sp
	moveal sp@+,a0
	moveal d0,a5
	moveal a0@,a2
L56a:
	movel a5,d0
	bnes L574
	cmpal sp@(28),a2
	bnes L51e
L574:
	movel a5,d0
	moveml sp@+,d6-d7/a2-a6
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl d0
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a2,sp@-
	clrl sp@-
	movel a1,sp@-
	.short 0x2f3c,0x8000,0x13eb	/* movel #-2147478549,sp@- */
	movel a0,sp@-
	bsrw L880
	lea sp@(20),sp
	moveal sp@+,a4
	tstl d0
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml a2-a6,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	moveal a6,a2
	moveal a0,a1
L5b6:
	tstb a1@+
	bnes L5b6
	.short 0x5389	/* subql #1,a1 */
	subal a0,a1
	movel a1,d0
	moveal a0,a3
	addal d0,a3
	moveal a2@(88),a5
	.short 0xd4fc,0x005c	/* addaw #92,a2 */
	bras L5f8
L5ce:
	movew a5@(26),d0
	bnes L5d8
	.short 0x70ff	/* moveq #-1,d0 */
	bras L5fe
L5d8:
	moveal a3,a1
	subaw d0,a1
	moveal a5@(22),a0
	.short 0x2c79,0x0000,0x0190	/* moveal 0x190,a6 */
	jsr a6@(-162)
	tstl d0
	bnes L5f6
	subaw a5@(26),a3
	movel a3,d0
	bras L5fe
L5f6:
	moveal a5@,a5
L5f8:
	cmpal a2,a5
	bnes L5ce
	.short 0x7000	/* moveq #0,d0 */
L5fe:
	moveml sp@+,a2-a6
	.short 0x504f	/* addqw #8,sp */
	tstl d0
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a6,sp@-
	movel a1,sp@-
	movel a0,sp@-
	bsrw L640
	lea sp@(12),sp
	moveal sp@+,a4
	tstl d0
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	movel a6,sp@-
	clrl sp@-
	movel a0,sp@-
	bsrw L640
	lea sp@(12),sp
	moveal sp@+,a4
	tstl d0
	rts
L640:
	.short 0x594f	/* subqw #4,sp */
	moveml d7/a2-a3/a5-a6,sp@-
	subal a5,a5
	moveal sp@(36),a0
	moveal a0@(88),a3
	subal a2,a2
	.short 0x43f9,0x0000,0x012a	/* lea 0x12a,a1 */
	movel a1,d7
	lea a0@(92),a1
	movel a1,sp@(20)
	bras L6a2
L664:
	movel sp@(28),d0
	movel sp@(32),d1
	movel a2,sp@-
	clrl sp@-
	movel d1,sp@-
	.short 0x4878,0x0002	/* pea 0x2 */
	movel d7,sp@-
	.short 0x2f3c,0x8000,0x1064	/* movel #-2147479452,sp@- */
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x144d	/* movel #-2147478451,sp@- */
	moveal a2,a1
	moveal a3@(14),a0
	.short 0x2c79,0x0000,0x018c	/* moveal 0x18c,a6 */
	moveal sp,a2
	jsr a6@(-636)
	lea sp@(28),sp
	moveal sp@+,a2
	moveal d0,a5
	moveal a3@,a3
L6a2:
	movel a5,d0
	bnes L6ac
	cmpal sp@(20),a3
	bnes L664
L6ac:
	movel a5,d0
	moveml sp@+,d7/a2-a3/a5-a6
	.short 0x584f	/* addqw #4,sp */
	rts
L6b6:
	moveml d7/a5-a6,sp@-
	movel sp@(16),d7
	.short 0x4ab9,0x0000,0x0198	/* tstl 0x198 */
	beqs L6fc
	.short 0x41f9,0x0000,0x019c	/* lea 0x19c,a0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	movel d7,d0
	.short 0x5880	/* addql #4,d0 */
	.short 0x2079,0x0000,0x0198	/* moveal 0x198,a0 */
	jsr a6@(-708)
	moveal d0,a5
	.short 0x41f9,0x0000,0x019c	/* lea 0x19c,a0 */
	jsr a6@(-570)
	movel a5,d0
	beqs L6fc
	movel d7,a5@
	lea a5@(4),a0
	movel a0,d0
	.byte 0x0c,0x40
L6fc:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveml sp@+,d7/a5-a6
	rts
L704:
	moveml d7/a3/a6,sp@-
	moveal sp@(16),a0
	.short 0x4ab9,0x0000,0x0198	/* tstl 0x198 */
	beqs L748
	movel a0,d0
	beqs L748
	lea a0@(-4),a3
	movel a0@(-4),d7
	.short 0x41f9,0x0000,0x019c	/* lea 0x19c,a0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-564)
	movel d7,d0
	.short 0x5880	/* addql #4,d0 */
	.short 0x2079,0x0000,0x0198	/* moveal 0x198,a0 */
	moveal a3,a1
	jsr a6@(-714)
	.short 0x41f9,0x0000,0x019c	/* lea 0x19c,a0 */
	jsr a6@(-570)
L748:
	moveml sp@+,d7/a3/a6
	rts
	nop
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x70ff	/* moveq #-1,d0 */
	moveal sp@+,a4
	rts
	.short 0x594f	/* subqw #4,sp */
	moveml a2/a4/a6,sp@-
	moveal a0,a1
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x23ce,0x0000,0x0188	/* movel a6,0x188 */
	moveal d0,a0
	.short 0x317c,0x0008,0x0016	/* movew #8,a0@(22) */
	movel a1,a0@(34)
	movel d0,sp@-
	movel d0,sp@(16)
	bsrw L0
	.short 0x584f	/* addqw #4,sp */
	moveal sp@(12),a2
	tstw d0
	bnes L79a
	moveal a2,a6
	bsrw L800
	subal a2,a2
L79a:
	movel a2,d0
	beqs L7a2
	movel a2,d0
	.byte 0x0c,0x40
L7a2:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveml sp@+,a2/a4/a6
	.short 0x584f	/* addqw #4,sp */
	tstl d0
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	movel a6,sp@-
	bsrw L96
	.short 0x584f	/* addqw #4,sp */
	tstw d0
	bnes L7d4
	bsrw L7dc
	.short 0x7000	/* moveq #0,d0 */
	.byte 0x0c,0x40
L7d4:
	.byte 0x20,0x0e	/* cmpiw #8206,d0 */
	moveal sp@+,a4
	tstl d0
	rts
L7dc:
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L7f8
	btst #3,a6@(14)
	beqs L7f8
	bsrw L800
	.byte 0x0c,0x40
L7f8:
	.byte 0x70,0x00	/* cmpiw #28672,d0 */
	moveal sp@+,a4
	tstl d0
	rts
L800:
	moveml d2/a2-a6,sp@-
	moveal a6,a5
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	tstw a5@(32)
	bnes L84c
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(18),d0
	.short 0x7200	/* moveq #0,d1 */
	movew a5@(16),d1
	movel d1,d2
	addl d0,d2
	moveal a5,a3
	.short 0x7000	/* moveq #0,d0 */
	movew d1,d0
	subal d0,a3
	moveal a5@(34),a2
	moveal a5,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-252)
	movel a5,sp@-
	bsrw Lfe
	.short 0x584f	/* addqw #4,sp */
	moveal a3,a1
	movel d2,d0
	jsr a6@(-210)
	movel a2,d0
	bras L854
L84c:
	bset #3,a5@(14)
	.short 0x7000	/* moveq #0,d0 */
L854:
	moveml sp@+,d2/a2-a6
	tstl d0
	rts
	movel a4,sp@-
	.short 0x49f9,0x0000,0x0000	/* lea 0x0,a4 */
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@+,a4
	tstl d0
	rts
L86c:
	moveal sp@(4),a0
	clrl a0@(4)
	movel a0,a0@(8)
	.short 0x5888	/* addql #4,a0 */
	movel a0,a0@-
	rts
	.byte 0x00,0x00
L880:
	.byte 0x2f,0x0a	/* orib #10,d0 */
	moveal sp@(8),a2
	movel a2,d0
	beqs L8ec
	lea sp@(12),a1
	moveal a2@(-4),a0
	bras L8e0
	movel a2,sp@-
	moveml sp@(8),a0/a2
	movel a2,d0
	beqs L8ec
	movel a0,d0
	beqs L8ec
	lea sp@(16),a1
	moveal a0@(24),a0
	bras L8e0
	movel a2,sp@-
	moveml sp@(8),a0/a2
	movel a2,d0
	beqs L8ec
	movel a0,d0
	beqs L8ec
	lea sp@(16),a1
	bras L8e0
	moveml sp@(4),a0-a1
	movel sp@(12),sp@(4)
	movel a2,sp@-
	moveal a1,a2
	movel a2,d0
	beqs L8ec
	movel a0,d0
	beqs L8ec
	moveal sp@(8),a1
L8e0:
	.short 0x4879,0x0000,0x08ee	/* pea 0x8ee */
	movel a0@(8),sp@-
	rts
L8ec:
	.short 0x7000	/* moveq #0,d0 */
	moveal sp@+,a2
	rts
	moveal sp@(4),a0
	moveal sp@(8),a1
	movel a2,sp@-
	moveal a0,a2
	movel a2,d0
	beqs L8ec
	moveal a2@(-4),a0
	bras L8e0
	moveml sp@(4),a0-a1
	movel sp@(12),sp@(4)
	movel a2,sp@-
	moveal a1,a2
	movel a2,d0
	beqs L8ec
	movel a0,d0
	beqs L8ec
	moveal sp@(8),a1
	moveal a0@(24),a0
	bras L8e0
	movel a2,sp@-
	moveml sp@(8),a0/a2
	movel a2,d0
	beqs L8ec
	movel a0,d0
	beqs L8ec
	moveal a0@(24),a0
	.short 0x2f3c,0x0000,0x0000	/* movel #0,sp@- */
	pea sp@(20)
	.short 0x2f3c,0x0000,0x0103	/* movel #259,sp@- */
	lea sp@,a1
	pea %pc@(L95a)
	movel a0@(8),sp@-
	rts
L95a:
	lea sp@(12),sp
	moveal sp@+,a2
	rts
	.byte 0x00,0x00
L964:
	.byte 0x22,0x6f	/* orib #111,d0 */
	.short 0x0008	/* .short 0x0008 */
	moveal sp@(4),a0
	movel a0,d0
L96e:
	tstb a0@+
	bnes L96e
	.short 0x5388	/* subql #1,a0 */
L974:
	moveb a1@+,a0@+
	bnes L974
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	.data
	.byte 0x69,0x63,0x6f,0x6e,0x6f,0x62,0x6a,0x65,0x63,0x74,0x2e,0x6c,0x69,0x62,0x72,0x61
	.byte 0x72,0x79,0x00,0x00,0x24,0x56,0x45,0x52,0x3a,0x20,0x69,0x63,0x6f,0x6e,0x6f,0x62
	.byte 0x6a,0x65,0x63,0x74,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x34,0x30,0x2e
	.byte 0x38,0x20,0x41,0x75,0x67,0x20,0x31,0x32,0x20,0x32,0x30,0x31,0x32,0x20,0x20,0x28
	.byte 0x53,0x41,0x53,0x2f,0x43,0x20,0x36,0x2e,0x35,0x38,0x29,0x20,0xa9,0x31,0x39,0x39
	.byte 0x39,0x2d,0x32,0x30,0x31,0x32,0x20,0x54,0x68,0x65,0x20,0x53,0x63,0x61,0x6c,0x6f
	.byte 0x73,0x20,0x54,0x65,0x61,0x6d,0x00,0x00,0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x69,0x6e,0x74,0x75,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x6c,0x69
	.byte 0x62,0x72,0x61,0x72,0x79,0x00,0x75,0x74,0x69,0x6c,0x69,0x74,0x79,0x2e,0x6c,0x69
	.byte 0x62,0x72,0x61,0x72,0x79,0x00,0x53,0x63,0x61,0x6c,0x6f,0x73,0x3a,0x49,0x63,0x6f
	.byte 0x6e,0x44,0x61,0x74,0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x00,0x4c,0x49,0x42,0x53
	.byte 0x00,0x00,0x4c,0x49,0x42,0x53,0x00,0x00,0x53,0x63,0x61,0x6c,0x6f,0x73,0x3a,0x49
	.byte 0x63,0x6f,0x6e,0x44,0x61,0x74,0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x64,0x61,0x74
	.byte 0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x00,0x00,0x00,0x53,0x63,0x61,0x6c,0x6f,0x73
	.byte 0x3a,0x49,0x63,0x6f,0x6e,0x44,0x61,0x74,0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x64
	.byte 0x61,0x74,0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x00,0x00,0x00,0x2e,0x69,0x6e,0x66
	.byte 0x6f,0x00,0x53,0x63,0x61,0x6c,0x6f,0x73,0x3a,0x49,0x63,0x6f,0x6e,0x44,0x61,0x74
	.byte 0x61,0x74,0x79,0x70,0x65,0x73,0x2f,0x64,0x61,0x74,0x61,0x74,0x79,0x70,0x65,0x73
	.byte 0x00,0x00,0x2e,0x69,0x6e,0x66,0x6f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0xae
	.byte 0x00,0x00,0x07,0xdc,0x00,0x00,0x08,0x00,0x00,0x00,0x08,0x5c,0x00,0x00,0x03,0xbe
	.byte 0x00,0x00,0x04,0xce,0x00,0x00,0x04,0xea,0x00,0x00,0x05,0x82,0x00,0x00,0x05,0xa6
	.byte 0x00,0x00,0x06,0x24,0x00,0x00,0x06,0x08,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x6c
	.byte 0x00,0x00,0x01,0x2c,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x5e,0x4a,0xfc,0x00,0x00
	.byte 0x01,0x6c,0x00,0x00,0x01,0x86,0x80,0x28,0x09,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x14,0x00,0x00,0x01,0x5c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
