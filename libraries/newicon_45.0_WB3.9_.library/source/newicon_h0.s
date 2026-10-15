	.text
	.byte 0x70,0xff,0x4e,0x75,0x4e,0x71,0x42,0x80,0x4e,0x75,0x4e,0x71,0x48,0xe7,0x00,0x3a
	.byte 0x49,0xf9,0x00,0x00,0x7f,0xfe,0x24,0x40,0x43,0xec,0x80,0xfa,0x22,0x8e
	movel a0,a2@(34)
	clrw a2@(22)
	moveal a1,a3
	btst #1,a6@(297)
	beqs L44
	moveal a2,a0
	bsrw Lbd4
	tstw d0
	beqs L3e
	movel a2,d0
	bras L5e
L3e:
	moveal a2,a0
	bsrw Lc12
L44:
	clrl d0
	movew a2@(16),d0
	clrl d1
	movew a2@(18),d1
	moveal a3@,a6
	moveal a2,a1
	subal d0,a1
	addl d1,d0
	jsr a6@(-210)
	clrl d0
L5e:
	moveml sp@+,a2-a4/a6
	rts
L64:
	moveb a0@+,d0
	beqs L70
	.short 0x0000,0x0020	/* orib #32,d0 */
	subb a1@+,d0
	beqs L64
L70:
	extbl d0
	rts
	nop
L76:
	bgts Ldd
	.short 0x7769	/* .short 0x7769 */
	blss Leb
	bgts Lf1
	.short 0x0000,0xdefc	/* orib #-4,d0 */
	.short 0xffac	/* .short 0xffac */
	moveml d2-d3/a2-a4/a6,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a6,a3
	.short 0x7618	/* moveq #24,d3 */
	addl sp,d3
	lea a4@(-32526),a2
	moveal a2@,a6
	movel d3,d1
	.short 0x7450	/* moveq #80,d2 */
	jsr a6@(-576)
	tstw d0
	beqs Laa
	movel d3,d1
	bras Lbc
Laa:
	moveal a4@(-32518),a6
	.short 0x43f8,0x0000	/* lea 0x0,a1 */
	jsr a6@(-294)
	moveal d0,a0
	movel a0@(10),d1
Lbc:
	moveal a2@,a6
	jsr a6@(-870)
	lea %pc@(L76),a1
	moveal d0,a0
	bsrs L64
	tstb d0
	bnes Ld2
	clrl d0
	bras Lde
Ld2:
	.short 0x022b,0x00f7,0x000e	/* andib #-9,a3@(14) */
	.short 0x526b,0x0020	/* addqw #1,a3@(32) */
	.byte 0x20
Ldd:
	.byte 0x0b	/* movel a3,d0 */
Lde:
	moveml sp@+,d2-d3/a2-a4/a6
	.short 0xdefc,0x0054	/* addaw #84,sp */
	rts
Le8:
	.byte 0x48,0xe7,0x20
Leb:
	.byte 0x3a	/* moveml d2/a2-a4/a6,sp@- */
	.byte 0x49,0xf9,0x00,0x00,0x7f
Lf1:
	.byte 0xfe	/* lea 0x7ffe,a4 */
	moveal a6,a3
	clrl d2
	tstw a3@(32)
	beqs L104
	.short 0x002b,0x0008,0x000e	/* orib #8,a3@(14) */
	bras L132
L104:
	moveal a3,a0
	bsrw Lc12
	lea a4@(-32518),a2
	moveal a2@,a6
	moveal a3,a1
	jsr a6@(-252)
	movel a3@(34),d2
	clrl d0
	movew a3@(16),d0
	clrl d1
	movew a3@(18),d1
	moveal a2@,a6
	moveal a3,a1
	subal d0,a1
	addl d1,d0
	jsr a6@(-210)
L132:
	movel d2,d0
	moveml sp@+,d2/a2-a4/a6
	rts
	movel a6,sp@-
	movel a4,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	clrl d0
	movew a6@(32),d1
	beqs L15a
	moveaw d1,a0
	.short 0x5348	/* subqw #1,a0 */
	movew a0,a6@(32)
	.short 0x0c41,0x0001	/* cmpiw #1,d1 */
	bnes L164
L15a:
	btst #3,a6@(14)
	beqs L164
	bsrs Le8
L164:
	moveal sp@+,a4
	moveal sp@+,a6
	rts
L16a:
	bvss L1cf
	bles L1dc
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L177:
	.byte 0x64,0x6f,0x73	/* oriw #28531,a4@- */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L184:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	movew a2@(0x8,d2:w:0x8),d0
	moveal d0,a2
	lea a4@(-32518),a3
	moveal a3@,a6
	jsr a6@(-198)
	movel d0,d2
	beqs L1b6
	moveal a4@(-32522),a6
	moveal d3,a0
	moveal d0,a1
	jsr a6@(-72)
	tstw d0
	bnes L1b6
	moveal a3@,a6
	moveal d2,a1
	movel a2,d0
	jsr a6@(-210)
	clrl d2
L1b6:
	movel d2,d0
	moveml sp@+,d2-d3/a2-a3/a6
	rts
L1be:
	moveml d2-d4,sp@-
	movel d2,d3
	movew d1,d4
	tstl d3
	bles L214
	movel d3,d1
	.short 0x7403	/* moveq #3,d2 */
	.byte 0x4c
L1cf:
	.byte 0x02,0x18,0x00	/* mulsl d2,d1 */
	.short 0x7402	/* moveq #2,d2 */
	.short 0xc9c0	/* mulsw d0,d4 */
	.short 0x5489	/* addql #2,a1 */
L1d8:
	moveb a1@,d0
	.byte 0x12,0xb1
L1dc:
	.byte 0x18,0x00	/* moveb a1@(0,d1:l),a1@ */
	.short 0x1380,0x1800	/* moveb d0,a1@(0,d1:l) */
	.short 0x5389	/* subql #1,a1 */
	.short 0x51ca,0xfff2	/* dbf d2,0x1d8 */
	clrw d2
	.short 0x5382	/* subql #1,d2 */
	bccs L1d8
	movew d4,d0
	.short 0x5340	/* subqw #1,d0 */
	.short 0x0c40,0xffff	/* cmpiw #-1,d0 */
	beqs L210
	clrl d2
	moveb a0@,d1
	beqs L208
	moveb d1,d2
	cmpl d2,d3
	bnes L20a
	clrb a0@
	bras L20a
L208:
	moveb d3,a0@
L20a:
	.short 0x5288	/* addql #1,a0 */
	.short 0x51c8,0xffec	/* dbf d0,0x1fa */
L210:
	.short 0x7001	/* moveq #1,d0 */
	bras L216
L214:
	clrl d0
L216:
	moveml sp@+,d2-d4
	rts
L21c:
	linkw a5,#-48
	moveml d2-d4/a2-a3/a6,sp@-
	movel a0,d2
	moveal d1,a2
	.short 0x47f8,0x0000	/* lea 0x0,a3 */
	clrl sp@-
	movew d0,sp@-
	clrw sp@-
	.short 0x203c,0x8000,0x902d	/* movel #-2147446739,d0 */
	tstl d2
	beqs L23e
	.short 0x7001	/* moveq #1,d0 */
L23e:
	movel d0,sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9032	/* movel #-2147446734,sp@- */
	movel d2,sp@-
	bsrw Lc4a
	movel d0,d3
	.short 0xdefc,0x0018	/* addaw #24,sp */
	beqw L430
	.short 0x744e	/* moveq #78,d2 */
	addl d3,d2
	.short 0x7201	/* moveq #1,d1 */
	.short 0x700c	/* moveq #12,d0 */
	moveal d2,a0
	bsrw L184
	moveal d0,a3
	tstl a3
	beqw L426
	movel d3,a3@
	clrl a3@(4)
	clrl a3@(8)
	clrl sp@-
	pea a5@(-4)
	.short 0x2f3c,0x8000,0x902a	/* movel #-2147446742,sp@- */
	movel d3,sp@-
	bsrw Lc34
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl a5@(-4)
	beqw L430
	clrl sp@-
	pea a5@(-8)
	.short 0x2f3c,0x8000,0x9001	/* movel #-2147446783,sp@- */
	pea a5@(-12)
	.short 0x2f3c,0x8000,0x901f	/* movel #-2147446753,sp@- */
	pea a5@(-16)
	.short 0x2f3c,0x8000,0x901b	/* movel #-2147446757,sp@- */
	pea a5@(-20)
	.short 0x2f3c,0x8000,0x9017	/* movel #-2147446761,sp@- */
	pea a5@(-24)
	.short 0x2f3c,0x8000,0x9013	/* movel #-2147446765,sp@- */
	pea a5@(-28)
	.short 0x2f3c,0x8000,0x9029	/* movel #-2147446743,sp@- */
	pea a5@(-32)
	.short 0x2f3c,0x8000,0x9027	/* movel #-2147446745,sp@- */
	pea a5@(-36)
	.short 0x2f3c,0x8000,0x901d	/* movel #-2147446755,sp@- */
	pea a5@(-40)
	.short 0x2f3c,0x8000,0x9019	/* movel #-2147446759,sp@- */
	pea a5@(-44)
	.short 0x2f3c,0x8000,0x9015	/* movel #-2147446763,sp@- */
	pea a5@(-48)
	.short 0x2f3c,0x8000,0x9011	/* movel #-2147446767,sp@- */
	movel d3,sp@-
	bsrw Lc34
	.short 0xdefc,0x0060	/* addaw #96,sp */
	tstl a5@(-8)
	bnew L430
	tstl a5@(-36)
	beqw L430
	tstl a5@(-44)
	beqw L430
	.short 0x7201	/* moveq #1,d1 */
	.short 0x7020	/* moveq #32,d0 */
	moveal d2,a0
	bsrw L184
	moveal d0,a6
	tstl a6
	beqw L430
	movew a5@(-30),a6@
	movew a5@(-26),a6@(2)
	movew a5@(-38),a6@(4)
	clrl d1
	movew a2,d1
	.short 0x78e0	/* moveq #-32,d4 */
	addl a5,d4
	lea a5@(-28),a2
	.short 0x70ff	/* moveq #-1,d0 */
	cmpl a5@(-48),d0
	beqs L362
	.short 0x7001	/* moveq #1,d0 */
	bras L36a
L362:
	tstl d1
	sne d0
	extw d0
	negw d0
L36a:
	movew d0,a6@(6)
	movel a5@(-44),a6@(8)
	movel a5@(-36),a6@(12)
	movel a6,a3@(4)
	movel a5@(-48),d2
	clrl d1
	movew a2@(2),d1
	moveal d4,a0
	clrl d0
	movew a0@(2),d0
	moveal a5@(-44),a1
	moveal a5@(-36),a0
	bsrw L1be
	tstw d0
	beqs L3b4
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movel d3,sp@-
	bsrw Lc34
	.short 0xdefc,0x0010	/* addaw #16,sp */
L3b4:
	tstl a5@(-12)
	beqs L430
	movel a5@(-20),d1
	beqs L430
	.short 0xdcfc,0x0010	/* addaw #16,a6 */
	moveal d4,a0
	movew a0@(2),a6@
	movew a2@(2),a6@(2)
	movew a5@(-14),a6@(4)
	movel a5@(-24),d2
	.short 0x70ff	/* moveq #-1,d0 */
	cmpl d2,d0
	sne d0
	extw d0
	negw d0
	movew d0,a6@(6)
	movel d1,a6@(8)
	movel a5@(-12),a6@(12)
	movel a6,a3@(8)
	clrl d1
	movew a2@(2),d1
	clrl d0
	movew a6@,d0
	moveal a5@(-20),a1
	moveal a5@(-12),a0
	bsrw L1be
	tstw d0
	beqs L430
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9012	/* movel #-2147446766,sp@- */
	movel d3,sp@-
	bsrw Lc34
	.short 0xdefc,0x0010	/* addaw #16,sp */
	bras L430
L426:
	moveal a4@(-32522),a6
	moveal d3,a0
	jsr a6@(-90)
L430:
	movel a3,d0
	moveml a5@(-72),d2-d4/a2-a3/a6
	unlk a5
	rts
	movel a6,sp@-
	movel a4,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a6,a1
	clrl d1
	clrl d0
	bsrw L21c
	moveal sp@+,a4
	moveal sp@+,a6
	rts
	movel a5,%usp
	.short 0x7749	/* .short 0x7749 */
	blss L4cb
	bgts L4a3
	blts L4d5
	.short 0x004e	/* .short 0x004e */
	.short 0x493d	/* .short 0x493d */
	trap #5
	.short 0x5749	/* subqw #3,a1 */
	.short 0x434f	/* .short 0x434f */
	linkw a3,#12115
	moveal sp,a6
	.short 0x5054	/* addqw #8,a4@ */
	movew sp,a6@(20564)
	.short 0x494d	/* .short 0x494d */
	.short 0x495a	/* .short 0x495a */
	chkl sp@(21292),d2
	negw a0@
	movew d4,a6@(21071)
	.short 0x5050	/* addqw #8,a0@ */
	.short 0x4c41	/* .short 0x4c41 */
	trap #1
	.short 0x522f,0x5300	/* addqb #1,sp@(21248) */
L48e:
	.short 0xdefc,0xffac	/* addaw #-84,sp */
	moveml d2-d5/a2-a3/a6,sp@-
	movel a0,d5
	lea sp@(28),a2
	lea a4@(-32526),a3
	moveal a3@,a6
	.byte 0x22
L4a3:
	.byte 0x3c,0x00,0x00,0x04,0x56	/* movel #1110,d1 */
	movel a2,d2
	.short 0x7650	/* moveq #80,d3 */
	clrl d4
	jsr a6@(-906)
	movel d0,d3
	blts L4fe
	moveal a3@,a6
	.short 0x7205	/* moveq #5,d1 */
	clrl d2
	jsr a6@(-228)
	moveal d0,a0
	tstl d0
	beqs L4fe
	.byte 0x15,0xbc,0x00,0x0a,0x38
L4cb:
	.byte 0x00	/* moveb #10,a2@(0,d3:l) */
	movel a2,a0@
	.short 0x5283	/* addql #1,d3 */
	movel d3,a0@(4)
	.byte 0x72
L4d5:
	.byte 0x04	/* moveq #4,d1 */
	movel d1,a0@(28)
	moveal a3@,a6
	.short 0x223c,0x0000,0x0461	/* movel #1121,d1 */
	movel d5,d2
	movel d0,d3
	jsr a6@(-798)
	tstl d0
	beqs L4f6
	moveal a3@,a6
	movel d0,d1
	jsr a6@(-858)
L4f6:
	moveal a3@,a6
	movel d3,d1
	jsr a6@(-858)
L4fe:
	moveml sp@+,d2-d5/a2-a3/a6
	.short 0xdefc,0x0054	/* addaw #84,sp */
	rts
	linkw a5,#-16
	moveml d2-d7/a2-a4/a6,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	movel a0,d7
	moveal a1,a3
	movel a6,d6
	moveal a3@,a2
	clrl a5@(-12)
	clrl a5@(-8)
	clrl a5@(-4)
	clrw d5
	.short 0x7601	/* moveq #1,d3 */
	lea a5@(-12),a0
	bsrw L48e
	clrl sp@-
	pea a5@(-16)
	.short 0x2f3c,0x8000,0x9050	/* movel #-2147446704,sp@- */
	movel a2,sp@-
	bsrw Lc34
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl a5@(-16)
	bnes L56c
	moveal a4@(-32522),a6
	moveal a2,a0
	.short 0x43f8,0x0000	/* lea 0x0,a1 */
	jsr a6@(-150)
	moveal d0,a2
	tstl a2
	bnes L56c
	clrl d0
	braw L740
L56c:
	moveal a3@(4),a1
	tstl a1
	beqw L688
	moveal a1,a0
	btst #1,a0@(7)
	beqs L586
	.short 0x7a01	/* moveq #1,d5 */
	braw L688
L586:
	.short 0x0c50,0x005d	/* cmpiw #93,a0@ */
	bhis L594
	.short 0x0c68,0x005d,0x0002	/* cmpiw #93,a0@(2) */
	blss L598
L594:
	clrl a5@(-12)
L598:
	tstl a5@(-12)
	bnew L688
	clrl sp@-
	bfexts a1@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movew a1@(4),d0
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bhis L5c4
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	bras L5ca
L5c4:
	.short 0x203c,0x0000,0x0100	/* movel #256,d0 */
L5ca:
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9018	/* movel #-2147446760,sp@- */
	movel a1@(8),sp@-
	.short 0x2f3c,0x8000,0x9014	/* movel #-2147446764,sp@- */
	clrl sp@-
	.short 0x2f3c,0x8000,0x901e	/* movel #-2147446754,sp@- */
	movel a1@(12),sp@-
	.short 0x2f3c,0x8000,0x901c	/* movel #-2147446756,sp@- */
	.short 0x4878,0x0011	/* pea 0x11 */
	.short 0x2f3c,0x8000,0x9024	/* movel #-2147446748,sp@- */
	clrl d0
	movew a1@(2),d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9028	/* movel #-2147446744,sp@- */
	clrl d0
	movew a1@,d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9026	/* movel #-2147446746,sp@- */
	movel a2,sp@-
	bsrw Lc34
	.short 0xdefc,0x0048	/* addaw #72,sp */
	.short 0x7208	/* moveq #8,d1 */
	cmpl d0,d1
	bnes L686
	moveal a3@(8),a0
	tstl a0
	beqs L688
	clrl sp@-
	bfexts a0@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9012	/* movel #-2147446766,sp@- */
	movew a0@(4),d0
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bhis L64e
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	bras L654
L64e:
	.short 0x203c,0x0000,0x0100	/* movel #256,d0 */
L654:
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x901a	/* movel #-2147446758,sp@- */
	movel a0@(8),sp@-
	.short 0x2f3c,0x8000,0x9016	/* movel #-2147446762,sp@- */
	movel a0@(12),sp@-
	.short 0x2f3c,0x8000,0x901e	/* movel #-2147446754,sp@- */
	movel a2,sp@-
	bsrw Lc34
	.short 0xdefc,0x0028	/* addaw #40,sp */
	.short 0x7204	/* moveq #4,d1 */
	cmpl d0,d1
	beqs L688
	clrw d3
	braw L72c
L686:
	clrw d3
L688:
	tstw d3
	beqw L72c
	movel a2@(54),d4
	clrl d2
	tstw d5
	bnes L6c2
	tstl a5@(-12)
	beqs L6c2
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x901c	/* movel #-2147446756,sp@- */
	movel a2,sp@-
	bsrw Lc34
	moveal d6,a6
	moveal a3,a0
	bsrw L9dc
	movel d0,d2
	.short 0xdefc,0x0010	/* addaw #16,sp */
	beqs L6c2
	movel d2,a2@(54)
L6c2:
	clrl sp@-
	.short 0x70ff	/* moveq #-1,d0 */
	cmpl a5@(-8),d0
	seq d0
	extbl d0
	negl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x903b	/* movel #-2147446725,sp@- */
	.short 0x72ff	/* moveq #-1,d1 */
	cmpl a5@(-4),d1
	seq d0
	extbl d0
	negl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9038	/* movel #-2147446728,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x9035	/* movel #-2147446731,sp@- */
	.short 0x4878,0x0001	/* pea 0x1 */
	.short 0x2f3c,0x8000,0x903a	/* movel #-2147446726,sp@- */
	.short 0x7001	/* moveq #1,d0 */
	andl d5,d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9039	/* movel #-2147446727,sp@- */
	movel a2,sp@-
	movel d7,sp@-
	bsrw Lc60
	movew d0,d3
	.short 0xdefc,0x0034	/* addaw #52,sp */
	tstl d2
	beqs L72c
	movel d4,a2@(54)
	moveal a4@(-32518),a6
	moveal d2,a1
	jsr a6@(-690)
L72c:
	tstl a5@(-16)
	bnes L73c
	moveal a4@(-32522),a6
	moveal a2,a0
	jsr a6@(-90)
L73c:
	movew d3,d0
	extl d0
L740:
	moveml a5@(-56),d2-d7/a2-a4/a6
	unlk a5
	rts
	movel a6,sp@-
	movel a4,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	tstl a0
	beqs L762
	moveal a4@(-32522),a6
	moveal a0@,a0
	jsr a6@(-90)
L762:
	moveal sp@+,a4
	moveal sp@+,a6
	rts
	clrl d0
	rts
	nop
L76e:
	moveml d2-d7/a2-a3/a5-a6,sp@-
	moveal a0,a5
	moveal a1,a3
	movew d0,d6
	movew a5@(4),d0
	.short 0x2a3c,0x0000,0x0100	/* movel #256,d5 */
	.short 0x0c40,0x0100	/* cmpiw #256,d0 */
	bhis L78c
	clrl d5
	movew d0,d5
L78c:
	tstl a5
	beqw L8dc
	movel d5,d3
	.short 0x7003	/* moveq #3,d0 */
	.short 0x4c00,0x3800	/* mulsl d0,d3 */
	movel a5@(8),d4
	lea a4@(-32539),a6
	moveal a6,a1
	tstw d6
	beqs L7ac
	lea a4@(-32534),a1
L7ac:
	moveal a2@,a0
	bsrw Lbca
	moveal a2@,a0
	.short 0x7043	/* moveq #67,d0 */
	btst #0,a5@(7)
	beqs L7c0
	.short 0x7042	/* moveq #66,d0 */
L7c0:
	moveb d0,a0@(4)
	moveal a2@,a0
	moveb a5@(1),d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(5)
	moveal a2@,a0
	moveb a5@(3),d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(6)
	moveal a2@,a0
	movel d5,d1
	bges L7ea
	.short 0x723f	/* moveq #63,d1 */
	addl d5,d1
L7ea:
	asrl #6,d1
	moveb d1,d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(7)
	moveal a2@,a0
	lsll #6,d1
	movel d5,d0
	subl d1,d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(8)
	.short 0x7408	/* moveq #8,d2 */
	.short 0x7277	/* moveq #119,d1 */
	movel d3,d0
	moveal a2@,a0
	lea a0@(9),a1
	moveal d4,a0
	bsrw L8e2
	movel d0,d2
	moveal a3@,a0
	movel a2@,a0@
	.short 0x5893	/* addql #4,a3@ */
	moveal a2@,a0
	bsrw Lbbc
	moveal a2@,a0
	lea a0@(0x1,d0:l),a0
	movel a0,a2@
	addl d2,d4
	subl d2,d3
	movew d5,d7
	.short 0x5347	/* subqw #1,d7 */
	tstl d3
	bles L878
L83a:
	moveal a6,a1
	tstw d6
	beqs L844
	lea a4@(-32534),a1
L844:
	moveal a2@,a0
	bsrw Lbca
	.short 0x7408	/* moveq #8,d2 */
	.short 0x727c	/* moveq #124,d1 */
	movel d3,d0
	moveal a2@,a1
	.short 0x5889	/* addql #4,a1 */
	moveal d4,a0
	bsrw L8e2
	movel d0,d2
	moveal a3@,a0
	movel a2@,a0@
	.short 0x5893	/* addql #4,a3@ */
	moveal a2@,a0
	bsrw Lbbc
	moveal a2@,a0
	lea a0@(0x1,d0:l),a0
	movel a0,a2@
	addl d2,d4
	subl d2,d3
	tstl d3
	bgts L83a
L878:
	.short 0x7a01	/* moveq #1,d5 */
	movew d7,d0
	asrw #1,d0
	movew a5@,d3
	movew a5@(2),d2
	movel a5@(12),d1
	tstw d0
	beqs L892
L88c:
	.short 0x5245	/* addqw #1,d5 */
	asrw #1,d0
	bnes L88c
L892:
	.short 0xc6c2	/* muluw d2,d3 */
	movel d1,d4
	tstl d3
	bles L8d8
L89a:
	moveal a6,a1
	tstw d6
	beqs L8a4
	lea a4@(-32534),a1
L8a4:
	moveal a2@,a0
	bsrw Lbca
	movew d5,d2
	extl d2
	.short 0x727c	/* moveq #124,d1 */
	movel d3,d0
	moveal a2@,a1
	.short 0x5889	/* addql #4,a1 */
	moveal d4,a0
	bsrs L8e2
	movel d0,d2
	moveal a3@,a0
	movel a2@,a0@
	.short 0x5893	/* addql #4,a3@ */
	moveal a2@,a0
	bsrw Lbbc
	moveal a2@,a0
	lea a0@(0x1,d0:l),a0
	movel a0,a2@
	addl d2,d4
	subl d2,d3
	tstl d3
	bgts L89a
L8d8:
	moveal a3@,a0
	clrl a0@
L8dc:
	moveml sp@+,d2-d7/a2-a3/a5-a6
	rts
L8e2:
	.short 0x514f	/* subqw #8,sp */
	moveml d2-d7/a2-a3/a5-a6,sp@-
	moveal a0,a5
	movel d0,d4
	moveal d1,a3
	moveaw d2,a2
	clrw d3
	clrl d6
	clrl d5
	movel d5,sp@(40)
	clrw d2
	lea a3@(-1),a6
	bras L96a
L902:
	.short 0x0c43,0x0006	/* cmpiw #6,d3 */
	bgts L924
	movew a2,d1
	extl d1
	clrl d0
L90e:
	lsll d1,d6
	.short 0x5384	/* subql #1,d4 */
	bmis L91c
	moveb a5@+,d0
	orl d0,d6
	.short 0x52af,0x0028	/* addql #1,sp@(40) */
L91c:
	addw a2,d3
	.short 0x0c43,0x0006	/* cmpiw #6,d3 */
	bles L90e
L924:
	moveaw d3,a0
	movel a0,d0
	.short 0x5f80	/* subql #7,d0 */
	movel d6,d1
	asrl d0,d1
	.short 0x707f	/* moveq #127,d0 */
	andl d0,d1
	.short 0x7020	/* moveq #32,d0 */
	addl d1,d0
	.short 0x7e6f	/* moveq #111,d7 */
	cmpl d0,d7
	bges L940
	.short 0x7051	/* moveq #81,d0 */
	addl d1,d0
L940:
	.short 0x7220	/* moveq #32,d1 */
	cmpl d0,d1
	bnes L956
	.short 0x5242	/* addqw #1,d2 */
	.short 0x0c42,0x002f	/* cmpiw #47,d2 */
	bnes L968
	st a1@+
	.short 0x5285	/* addql #1,d5 */
	clrw d2
	bras L968
L956:
	tstw d2
	beqs L964
	.short 0x0602,0xffd0	/* addib #-48,d2 */
	moveb d2,a1@+
	.short 0x5285	/* addql #1,d5 */
	clrw d2
L964:
	moveb d0,a1@+
	.short 0x5285	/* addql #1,d5 */
L968:
	.short 0x5f43	/* subqw #7,d3 */
L96a:
	tstl d4
	bgts L976
	movel a3,d0
	.short 0x5380	/* subql #1,d0 */
	tstw d3
	beqs L97e
L976:
	movel a3,d0
	.short 0x5380	/* subql #1,d0 */
	cmpal d5,a6
	bgts L902
L97e:
	tstw d2
	beqs L988
	.short 0x0602,0xffd0	/* addib #-48,d2 */
	moveb d2,a1@+
L988:
	cmpl d5,d0
	bgts L998
	tstw d3
	beqs L998
	tstl d4
	blts L998
	.short 0x53af,0x0028	/* subql #1,sp@(40) */
L998:
	clrb a1@
	movel sp@(40),d0
	moveml sp@+,d2-d7/a2-a3/a5-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L9a6:
	clrl d0
	tstl a0
	beqs L9b8
	tstl a0@
	beqs L9b8
L9b0:
	.short 0x5888	/* addql #4,a0 */
	.short 0x5280	/* addql #1,d0 */
	tstl a0@
	bnes L9b0
L9b8:
	rts
	nop
L9bc:
	movel a2,sp@-
	moveal a1,a2
	tstl a0
	beqs L9d2
	tstl a0@
	beqs L9d2
	moveal a2@,a1
L9ca:
	movel a0@+,a1@+
	tstl a0@
	bnes L9ca
	movel a1,a2@
L9d2:
	moveal a2@,a0
	clrl a0@
	moveal sp@+,a2
	rts
	movel d0,d0
L9dc:
	.short 0xdefc,0xfff4	/* addaw #-12,sp */
	moveml d2-d4/a2-a4/a6,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a0,a3
	moveal a3@,a0
	moveal a0@(54),a2
	moveal a2,a0
	bsrs L9a6
	movel d0,d2
	.short 0x0682,0x0000,0x00f9	/* addil #249,d2 */
	lsll #2,d2
	moveal a4@(-32518),a6
	movel d2,d0
	.short 0x0680,0x0000,0x7b00	/* addil #31488,d0 */
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-684)
	movel d0,d4
	beqs La72
	movel d0,sp@(32)
	addl d4,d2
	movel d2,sp@(28)
	.short 0x7620	/* moveq #32,d3 */
	addl sp,d3
	moveal d3,a1
	moveal a2,a0
	bsrs L9bc
	moveal a3@(4),a6
	tstl a6
	beqs La72
	btst #1,a6@(7)
	bnes La72
	moveal sp@(32),a0
	.short 0x20bc,0x0000,0x09da	/* movel #2522,a0@ */
	.short 0x58af,0x0020	/* addql #4,sp@(32) */
	moveal sp@(32),a0
	lea a4@(-32580),a1
	movel a1,a0@
	.short 0x58af,0x0020	/* addql #4,sp@(32) */
	.short 0x741c	/* moveq #28,d2 */
	addl sp,d2
	moveal d2,a2
	moveal d3,a1
	clrl d0
	moveal a6,a0
	bsrw L76e
	moveal d3,a1
	.short 0x7001	/* moveq #1,d0 */
	moveal a3@(8),a0
	bsrw L76e
La72:
	movel d4,d0
	moveml sp@+,d2-d4/a2-a4/a6
	.short 0xdefc,0x000c	/* addaw #12,sp */
	rts
	rts
	nop
	linkw a5,#-4
	moveml d2-d5/a2-a4/a6,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a0,a3
	movel a1,d4
	lea a4@(-32522),a2
	moveal a2@,a6
	.short 0x7003	/* moveq #3,d0 */
	jsr a6@(-174)
	movel d0,d5
	movel a2,d3
	tstl d5
	beqw Lb72
	.short 0x7201	/* moveq #1,d1 */
	.short 0x7018	/* moveq #24,d0 */
	moveal d5,a1
	lea a1@(78),a0
	bsrw L184
	movel d0,d2
	beqw Lb68
	clrl sp@-
	pea a5@(-4)
	.short 0x2f3c,0x8000,0x9001	/* movel #-2147446783,sp@- */
	bfexts a3@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movel a3@(8),sp@-
	.short 0x2f3c,0x8000,0x9014	/* movel #-2147446764,sp@- */
	clrl d0
	movew a3@(4),d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9018	/* movel #-2147446760,sp@- */
	movel a3@(12),sp@-
	.short 0x2f3c,0x8000,0x901c	/* movel #-2147446756,sp@- */
	.short 0x4878,0x0011	/* pea 0x11 */
	.short 0x2f3c,0x8000,0x9024	/* movel #-2147446748,sp@- */
	clrl d0
	movew a3@(2),d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9028	/* movel #-2147446744,sp@- */
	clrl d0
	movew a3@,d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9026	/* movel #-2147446746,sp@- */
	movel d5,sp@-
	bsrw Lc34
	.short 0xdefc,0x0048	/* addaw #72,sp */
	tstl a5@(-4)
	bnes Lb68
	moveal d5,a0
	movew a3@,a0@(12)
	movew a3@(2),a0@(14)
	moveal a2@,a6
	moveal d4,a1
	.short 0x45f8,0x0000	/* lea 0x0,a2 */
	jsr a6@(-192)
	tstw d0
	beqs Lb68
	moveal d5,a1
	moveal a1@(22),a0
	moveal d2,a1
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@+,a1@+
	movel a0@,a1@
	moveal d2,a0
	movel d5,a0@(20)
	movel d2,d0
	bras Lb74
Lb68:
	moveal d3,a1
	moveal a1@,a6
	moveal d5,a0
	jsr a6@(-90)
Lb72:
	clrl d0
Lb74:
	moveml a5@(-36),d2-d5/a2-a4/a6
	unlk a5
	rts
	movel a6,sp@-
	movel a4,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a4@(-32522),a6
	moveal a0@(20),a0
	jsr a6@(-90)
	moveal sp@+,a4
	moveal sp@+,a6
	rts
	movel a6,sp@-
	movel a4,sp@-
	.short 0x49f9,0x0000,0x7ffe	/* lea 0x7ffe,a4 */
	moveal a6,a1
	clrl d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	.short 0x41f8,0x0000	/* lea 0x0,a0 */
	bsrw L21c
	moveal sp@+,a4
	moveal sp@+,a6
	rts
Lbbc:
	movel a0,d0
Lbbe:
	tstb a0@+
	bnes Lbbe
	subl a0,d0
	notl d0
	rts
	nop
Lbca:
	moveb a1@,a0@+
	tstb a1@+
	bnes Lbca
	rts
	nop
Lbd4:
	moveml a2-a3/a6,sp@-
	lea a4@(-32522),a2
	lea a4@(-32518),a3
	moveal a3@,a6
	lea %pc@(L16a),a1
	.short 0x702c	/* moveq #44,d0 */
	jsr a6@(-552)
	movel d0,a2@
	beqs Lc0a
	lea a4@(-32526),a2
	moveal a3@,a6
	lea %pc@(L177),a1
	.short 0x7028	/* moveq #40,d0 */
	jsr a6@(-552)
	movel d0,d1
	movel d1,a2@
	.short 0x7001	/* moveq #1,d0 */
	tstl d1
	bnes Lc0c
Lc0a:
	clrl d0
Lc0c:
	moveml sp@+,a2-a3/a6
	rts
Lc12:
	movel a6,sp@-
	movel a2,sp@-
	lea a4@(-32518),a2
	moveal a2@,a6
	moveal a4@(-32522),a1
	jsr a6@(-414)
	moveal a2@,a6
	moveal a4@(-32526),a1
	jsr a6@(-414)
	moveal sp@+,a2
	moveal sp@+,a6
	rts
Lc34:
	movel a6,sp@-
	moveal a4@(-32522),a6
	moveal sp@(8),a0
	lea sp@(12),a1
	jsr a6@(-156)
	moveal sp@+,a6
	rts
Lc4a:
	movel a6,sp@-
	moveal a4@(-32522),a6
	moveal sp@(8),a0
	lea sp@(12),a1
	jsr a6@(-180)
	moveal sp@+,a6
	rts
Lc60:
	movel a6,sp@-
	movel a2,sp@-
	moveal a4@(-32522),a6
	moveal sp@(12),a0
	moveal sp@(16),a1
	lea sp@(20),a2
	jsr a6@(-186)
	extl d0
	moveal sp@+,a2
	moveal sp@+,a6
	rts
	.data
	.byte 0x00,0x00,0x00,0x80,0x00,0x00,0x01,0x3a,0x00,0x00,0x00,0xe8,0x00,0x00,0x00,0x06
	.byte 0x00,0x00,0x04,0x3c,0x00,0x00,0x05,0x08,0x00,0x00,0x07,0x4a,0x00,0x00,0x07,0x68
	.byte 0x00,0x00,0x09,0xdc,0x00,0x00,0x0a,0x7e,0x00,0x00,0x0a,0x82,0x00,0x00,0x0b,0x7e
	.byte 0x00,0x00,0x0b,0x9a,0xff,0xff,0xff,0xff,0x6e,0x65,0x77,0x69,0x63,0x6f,0x6e,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x6e,0x65,0x77,0x69,0x63,0x6f,0x6e,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x34,0x35,0x2e,0x30,0x20,0x28,0x32,0x37
	.byte 0x2e,0x31,0x30,0x2e,0x30,0x30,0x29,0x20,0x65,0x6d,0x75,0x6c,0x61,0x74,0x69,0x6f
	.byte 0x6e,0x20,0x28,0x43,0x29,0x20,0x32,0x30,0x30,0x30,0x20,0x62,0x79,0x20,0x53,0x74
	.byte 0x65,0x70,0x68,0x61,0x6e,0x20,0x52,0x75,0x70,0x70,0x72,0x65,0x63,0x68,0x74,0x00
	.byte 0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0c
	.byte 0x4a,0xfc,0x00,0x00,0x00,0xa0,0x00,0x00,0x00,0xba,0x80,0x2d,0x09,0x00,0x00,0x00
	.byte 0x00,0x38,0x00,0x00,0x00,0x48,0x00,0x00,0x00,0x90,0x2a,0x2a,0x2a,0x20,0x44,0x4f
	.byte 0x4e,0x27,0x54,0x20,0x45,0x44,0x49,0x54,0x20,0x54,0x48,0x45,0x20,0x46,0x4f,0x4c
	.byte 0x4c,0x4f,0x57,0x49,0x4e,0x47,0x20,0x4c,0x49,0x4e,0x45,0x53,0x21,0x21,0x20,0x2a
	.byte 0x2a,0x2a,0x00,0x49,0x4d,0x31,0x3d,0x00,0x49,0x4d,0x32,0x3d
