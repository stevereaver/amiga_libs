	.text
	.byte 0x70,0xff,0x4e,0x75,0x4e,0x71,0x42,0x80,0x4e,0x75,0x4e,0x71,0x2f,0x0e,0x2f,0x0a
	.byte 0x24,0x40,0x23,0xce,0x00,0x00,0x00,0x08,0x25,0x48,0x00,0x22
	.short 0x357c,0x0003,0x0016	/* movew #3,a2@(22) */
	btst #1,a6@(297)
	beqs L3e
	moveal a2,a0
	bsrw L176
	tstw d0
	beqs L38
	movel a2,d0
	bras L5c
L38:
	moveal a2,a0
	bsrw L1b4
L3e:
	clrl d0
	movew a2@(16),d0
	clrl d1
	movew a2@(18),d1
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal a2,a1
	subal d0,a1
	addl d1,d0
	jsr a6@(-210)
	clrl d0
L5c:
	moveal sp@+,a2
	moveal sp@+,a6
	rts
L62:
	moveb a0@+,d0
	beqs L6e
	.short 0x0000,0x0020	/* orib #32,d0 */
	subb a1@+,d0
	beqs L62
L6e:
	extbl d0
	rts
	nop
L74:
	bgts Ldb
	.short 0x7769	/* .short 0x7769 */
	blss Le9
	bgts Lef
	.short 0x0000,0xdefc	/* orib #-4,d0 */
	.short 0xffac	/* .short 0xffac */
	moveml d2-d3/a2/a6,sp@-
	moveal a6,a2
	.short 0x7610	/* moveq #16,d3 */
	addl sp,d3
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	movel d3,d1
	.short 0x7450	/* moveq #80,d2 */
	jsr a6@(-576)
	tstw d0
	beqs La2
	movel d3,d1
	bras Lb6
La2:
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	.short 0x43f8,0x0000	/* lea 0x0,a1 */
	jsr a6@(-294)
	moveal d0,a0
	movel a0@(10),d1
Lb6:
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	jsr a6@(-870)
	lea %pc@(L74),a1
	moveal d0,a0
	bsrs L62
	tstb d0
	bnes Ld0
	clrl d0
	bras Ldc
Ld0:
	.short 0x022a,0x00f7,0x000e	/* andib #-9,a2@(14) */
	.short 0x526a,0x0020	/* addqw #1,a2@(32) */
	.byte 0x20
Ldb:
	.byte 0x0a	/* movel a2,d0 */
Ldc:
	moveml sp@+,d2-d3/a2/a6
	.short 0xdefc,0x0054	/* addaw #84,sp */
	rts
Le6:
	.byte 0x48,0xe7,0x20
Le9:
	.byte 0x22	/* moveml d2/a2/a6,sp@- */
	moveal a6,a2
	clrl d2
	.byte 0x4a
Lef:
	.byte 0x6a,0x00,0x20	/* tstw a2@(32) */
	beqs Lfc
	.short 0x002a,0x0008,0x000e	/* orib #8,a2@(14) */
	bras L12e
Lfc:
	moveal a2,a0
	bsrw L1b4
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal a2,a1
	jsr a6@(-252)
	movel a2@(34),d2
	clrl d0
	movew a2@(16),d0
	clrl d1
	movew a2@(18),d1
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal a2,a1
	subal d0,a1
	addl d1,d0
	jsr a6@(-210)
L12e:
	movel d2,d0
	moveml sp@+,d2/a2/a6
	rts
	movel a6,sp@-
	clrl d0
	movew a6@(32),d1
	beqs L14e
	moveaw d1,a0
	.short 0x5348	/* subqw #1,a0 */
	movew a0,a6@(32)
	.short 0x0c41,0x0001	/* cmpiw #1,d1 */
	bnes L158
L14e:
	btst #3,a6@(14)
	beqs L158
	bsrs Le6
L158:
	moveal sp@+,a6
	rts
L15c:
	bvss L1c1
	bles L1ce
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00
L169:
	.byte 0x64,0x6f,0x73	/* oriw #28531,a4@- */
	moveal a4@(26978),sp
	.short 0x7261	/* moveq #97,d1 */
	.short 0x7279	/* moveq #121,d1 */
	.byte 0x00,0x00
L176:
	.byte 0x2f,0x0e	/* orib #14,d0 */
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	lea %pc@(L15c),a1
	.short 0x702c	/* moveq #44,d0 */
	jsr a6@(-552)
	.short 0x23c0,0x0000,0x0004	/* movel d0,0x4 */
	beqs L1ae
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	lea %pc@(L169),a1
	.short 0x7028	/* moveq #40,d0 */
	jsr a6@(-552)
	movel d0,d1
	.short 0x23c1,0x0000,0x0000	/* movel d1,0x0 */
	.short 0x7001	/* moveq #1,d0 */
	tstl d1
	bnes L1b0
L1ae:
	clrl d0
L1b0:
	moveal sp@+,a6
	rts
L1b4:
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	.byte 0x22,0x79,0x00,0x00,0x00
L1c1:
	.byte 0x04	/* moveal 0x4,a1 */
	jsr a6@(-414)
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	.byte 0x22,0x79
L1ce:
	.byte 0x00,0x00,0x00,0x00	/* moveal 0x0,a1 */
	jsr a6@(-414)
	moveal sp@+,a6
	rts
L1da:
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal sp@(8),a0
	lea sp@(12),a1
	jsr a6@(-156)
	moveal sp@+,a6
	rts
L1f2:
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal sp@(8),a0
	lea sp@(12),a1
	jsr a6@(-180)
	moveal sp@+,a6
	rts
L20a:
	movel a6,sp@-
	movel a2,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal sp@(12),a0
	moveal sp@(16),a1
	lea sp@(20),a2
	jsr a6@(-186)
	extl d0
	moveal sp@+,a2
	moveal sp@+,a6
	rts
L22c:
	moveml d2-d3/a2/a6,sp@-
	movel a0,d3
	moveal d0,a2
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	jsr a6@(-198)
	movel d0,d2
	beqs L264
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal d3,a0
	moveal d0,a1
	jsr a6@(-72)
	tstw d0
	bnes L264
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal d2,a1
	movel a2,d0
	jsr a6@(-210)
	clrl d2
L264:
	movel d2,d0
	moveml sp@+,d2-d3/a2/a6
	rts
L26c:
	moveml d2-d4,sp@-
	movel d2,d3
	movew d1,d4
	tstl d3
	bles L2c2
	movel d3,d1
	.short 0x7403	/* moveq #3,d2 */
	.short 0x4c02,0x1800	/* mulsl d2,d1 */
	.short 0x7402	/* moveq #2,d2 */
	.short 0xc9c0	/* mulsw d0,d4 */
	.short 0x5489	/* addql #2,a1 */
L286:
	moveb a1@,d0
	.short 0x12b1,0x1800	/* moveb a1@(0,d1:l),a1@ */
	.short 0x1380,0x1800	/* moveb d0,a1@(0,d1:l) */
	.short 0x5389	/* subql #1,a1 */
	.short 0x51ca,0xfff2	/* dbf d2,0x286 */
	clrw d2
	.short 0x5382	/* subql #1,d2 */
	bccs L286
	movew d4,d0
	.short 0x5340	/* subqw #1,d0 */
	.short 0x0c40,0xffff	/* cmpiw #-1,d0 */
	beqs L2be
	clrl d2
	moveb a0@,d1
	beqs L2b6
	moveb d1,d2
	cmpl d2,d3
	bnes L2b8
	clrb a0@
	bras L2b8
L2b6:
	moveb d3,a0@
L2b8:
	.short 0x5288	/* addql #1,a0 */
	.short 0x51c8,0xffec	/* dbf d0,0x2a8 */
L2be:
	.short 0x7001	/* moveq #1,d0 */
	bras L2c4
L2c2:
	clrl d0
L2c4:
	moveml sp@+,d2-d4
	rts
L2ca:
	linkw a5,#-48
	moveml d2-d3/a2-a4/a6,sp@-
	movel a0,d2
	moveal a1,a6
	moveaw d1,a3
	.short 0x49f8,0x0000	/* lea 0x0,a4 */
	clrl sp@-
	movew d0,sp@-
	clrw sp@-
	.short 0x203c,0x8000,0x902d	/* movel #-2147446739,d0 */
	tstl d2
	beqs L2ee
	.short 0x7001	/* moveq #1,d0 */
L2ee:
	movel d0,sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9032	/* movel #-2147446734,sp@- */
	movel d2,sp@-
	bsrw L1f2
	moveal d0,a2
	.short 0xdefc,0x0018	/* addaw #24,sp */
	tstl a2
	beqw L542
	.short 0x744e	/* moveq #78,d2 */
	addl a2,d2
	.short 0x7201	/* moveq #1,d1 */
	.short 0x700c	/* moveq #12,d0 */
	moveal d2,a0
	bsrw L22c
	moveal d0,a4
	tstl a4
	beqw L536
	movel a2,a4@
	clrl a4@(4)
	clrl a4@(8)
	clrl sp@-
	pea a5@(-4)
	.short 0x2f3c,0x8000,0x902a	/* movel #-2147446742,sp@- */
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl a2@(22)
	bnes L39e
	.short 0x7202	/* moveq #2,d1 */
	.short 0x7016	/* moveq #22,d0 */
	moveal d2,a0
	bsrw L22c
	moveal d0,a1
	tstl a1
	bnes L362
	moveal a4,a0
	bsrw L84e
	clrl d0
	braw L544
L362:
	lea a1@(20),a0
	.short 0x30bc,0xffff	/* movew #-1,a0@ */
	clrw a1@(2)
	clrw a1@
	.short 0x337c,0x0001,0x0006	/* movew #1,a1@(6) */
	.short 0x337c,0x0001,0x0004	/* movew #1,a1@(4) */
	movel a0,a1@(10)
	.short 0x337c,0x0001,0x0008	/* movew #1,a1@(8) */
	clrb a1@(15)
	.short 0x137c,0x0001,0x000e	/* moveb #1,a1@(14) */
	clrl a1@(16)
	movel a1,a2@(22)
	.short 0x026a,0xfffc,0x0010	/* andiw #-4,a2@(16) */
L39e:
	tstl a5@(-4)
	beqw L542
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
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0060	/* addaw #96,sp */
	tstl a5@(-8)
	bnew L542
	tstl a5@(-36)
	beqw L542
	tstl a5@(-44)
	beqw L542
	.short 0x7201	/* moveq #1,d1 */
	.short 0x7020	/* moveq #32,d0 */
	moveal d2,a0
	bsrw L22c
	moveal d0,a6
	tstl a6
	beqw L542
	movew a5@(-30),a6@
	movew a5@(-26),a6@(2)
	movew a5@(-38),a6@(4)
	clrl d1
	movew a3,d1
	.short 0x76e0	/* moveq #-32,d3 */
	addl a5,d3
	lea a5@(-28),a3
	.short 0x70ff	/* moveq #-1,d0 */
	cmpl a5@(-48),d0
	beqs L472
	.short 0x7001	/* moveq #1,d0 */
	bras L47a
L472:
	tstl d1
	sne d0
	extw d0
	negw d0
L47a:
	movew d0,a6@(6)
	movel a5@(-44),a6@(8)
	movel a5@(-36),a6@(12)
	movel a6,a4@(4)
	movel a5@(-48),d2
	clrl d1
	movew a3@(2),d1
	moveal d3,a0
	clrl d0
	movew a0@(2),d0
	moveal a5@(-44),a1
	moveal a5@(-36),a0
	bsrw L26c
	tstw d0
	beqs L4c4
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0010	/* addaw #16,sp */
L4c4:
	tstl a5@(-12)
	beqs L542
	movel a5@(-20),d1
	beqs L542
	.short 0xdcfc,0x0010	/* addaw #16,a6 */
	moveal d3,a0
	movew a0@(2),a6@
	movew a3@(2),a6@(2)
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
	movel a6,a4@(8)
	clrl d1
	movew a3@(2),d1
	clrl d0
	movew a6@,d0
	moveal a5@(-20),a1
	moveal a5@(-12),a0
	bsrw L26c
	tstw d0
	beqs L542
	clrl sp@-
	clrl sp@-
	.short 0x2f3c,0x8000,0x9012	/* movel #-2147446766,sp@- */
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0010	/* addaw #16,sp */
	bras L542
L536:
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a2,a0
	jsr a6@(-90)
L542:
	movel a4,d0
L544:
	moveml a5@(-72),d2-d3/a2-a4/a6
	unlk a5
	rts
	movel a6,sp@-
	moveal a6,a1
	clrl d1
	clrl d0
	bsrw L2ca
	moveal sp@+,a6
	rts
	movel a5,%usp
	.short 0x7749	/* .short 0x7749 */
	blss L5d3
	bgts L5ab
	blts L5dd
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
L596:
	.short 0xdefc,0xffac	/* addaw #-84,sp */
	moveml d2-d5/a2/a6,sp@-
	movel a0,d5
	lea sp@(24),a2
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	.byte 0x22
L5ab:
	.byte 0x3c,0x00,0x00,0x05,0x5e	/* movel #1374,d1 */
	movel a2,d2
	.short 0x7650	/* moveq #80,d3 */
	clrl d4
	jsr a6@(-906)
	movel d0,d3
	blts L616
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	.short 0x7205	/* moveq #5,d1 */
	clrl d2
	jsr a6@(-228)
	moveal d0,a0
	tstl d0
	beqs L616
	.byte 0x15
L5d3:
	.byte 0xbc,0x00,0x0a,0x38,0x00	/* moveb #10,a2@(0,d3:l) */
	movel a2,a0@
	.short 0x5283	/* addql #1,d3 */
	.byte 0x21
L5dd:
	.byte 0x43,0x00,0x04	/* movel d3,a0@(4) */
	.short 0x7204	/* moveq #4,d1 */
	movel d1,a0@(28)
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	.short 0x223c,0x0000,0x0569	/* movel #1385,d1 */
	movel d5,d2
	movel d0,d3
	jsr a6@(-798)
	tstl d0
	beqs L60a
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	movel d0,d1
	jsr a6@(-858)
L60a:
	.short 0x2c79,0x0000,0x0000	/* moveal 0x0,a6 */
	movel d3,d1
	jsr a6@(-858)
L616:
	moveml sp@+,d2-d5/a2/a6
	.short 0xdefc,0x0054	/* addaw #84,sp */
	rts
	linkw a5,#-16
	moveml d2-d7/a2-a3/a6,sp@-
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
	bsrw L596
	clrl sp@-
	pea a5@(-16)
	.short 0x2f3c,0x8000,0x9050	/* movel #-2147446704,sp@- */
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0010	/* addaw #16,sp */
	tstl a5@(-16)
	bnes L680
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a2,a0
	.short 0x43f8,0x0000	/* lea 0x0,a1 */
	jsr a6@(-150)
	moveal d0,a2
	tstl a2
	bnes L680
	clrl d0
	braw L844
L680:
	moveal a3@(4),a1
	tstl a1
	beqw L79c
	moveal a1,a0
	btst #1,a0@(7)
	beqs L69a
	.short 0x7a01	/* moveq #1,d5 */
	braw L79c
L69a:
	clrl d1
	movew a0@(4),d1
	.short 0x0c50,0x005d	/* cmpiw #93,a0@ */
	bhis L6ae
	.short 0x0c68,0x005d,0x0002	/* cmpiw #93,a0@(2) */
	blss L6b2
L6ae:
	clrl a5@(-12)
L6b2:
	moveal a3@(8),a0
	tstl a0
	beqs L6ce
	clrl d2
	movew a0@(4),d2
	.short 0x0c82,0x0000,0x0100	/* cmpil #256,d2 */
	bles L6ce
	.short 0x243c,0x0000,0x0100	/* movel #256,d2 */
L6ce:
	.short 0x0c81,0x0000,0x0100	/* cmpil #256,d1 */
	bles L6dc
	.short 0x223c,0x0000,0x0100	/* movel #256,d1 */
L6dc:
	tstl a5@(-12)
	bnew L79c
	clrl sp@-
	bfexts a1@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movel d1,sp@-
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
	bsrw L1da
	.short 0xdefc,0x0048	/* addaw #72,sp */
	.short 0x7208	/* moveq #8,d1 */
	cmpl d0,d1
	bnes L79a
	moveal a3@(8),a0
	tstl a0
	beqs L79c
	clrl sp@-
	bfexts a0@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9012	/* movel #-2147446766,sp@- */
	movel d2,sp@-
	.short 0x2f3c,0x8000,0x901a	/* movel #-2147446758,sp@- */
	movel a0@(8),sp@-
	.short 0x2f3c,0x8000,0x9016	/* movel #-2147446762,sp@- */
	movel a0@(12),sp@-
	.short 0x2f3c,0x8000,0x901e	/* movel #-2147446754,sp@- */
	movel a2,sp@-
	bsrw L1da
	.short 0xdefc,0x0028	/* addaw #40,sp */
	.short 0x7204	/* moveq #4,d1 */
	cmpl d0,d1
	beqs L79c
	clrw d3
	braw L82e
L79a:
	clrw d3
L79c:
	tstw d3
	beqw L82e
	movel a2@(54),d4
	clrl d2
	tstw d5
	bnes L7c2
	tstl a5@(-12)
	beqs L7c2
	moveal d6,a6
	moveal a3,a0
	bsrw Laa2
	movel d0,d2
	beqs L7c2
	movel d2,a2@(54)
L7c2:
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
	bsrw L20a
	movew d0,d3
	.short 0xdefc,0x0034	/* addaw #52,sp */
	tstl d2
	beqs L82e
	movel d4,a2@(54)
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal d2,a1
	jsr a6@(-690)
L82e:
	tstl a5@(-16)
	bnes L840
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a2,a0
	jsr a6@(-90)
L840:
	movew d3,d0
	extl d0
L844:
	moveml a5@(-52),d2-d7/a2-a3/a6
	unlk a5
	rts
L84e:
	movel a6,sp@-
	tstl a0
	beqs L860
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a0@,a0
	jsr a6@(-90)
L860:
	moveal sp@+,a6
	rts
	clrl d0
	rts
	nop
L86a:
	moveml d2-d7/a2-a4,sp@-
	moveal a0,a4
	moveal a1,a3
	movew d0,d6
	tstl a4
	beqw L9ac
	movew a4@(4),d3
	.short 0xc6fc,0x0003	/* muluw #3,d3 */
	movel a4@(8),d4
	.short 0x2e3c,0x0000,0x00e3	/* movel #227,d7 */
	movel d7,d1
	tstw d0
	beqs L898
	.short 0x223c,0x0000,0x00e8	/* movel #232,d1 */
L898:
	moveal d1,a1
	moveal a2@,a0
	bsrw Lc76
	moveal a2@,a0
	.short 0x7043	/* moveq #67,d0 */
	btst #0,a4@(7)
	beqs L8ae
	.short 0x7042	/* moveq #66,d0 */
L8ae:
	moveb d0,a0@(4)
	moveal a2@,a0
	moveb a4@(1),d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(5)
	moveal a2@,a0
	moveb a4@(3),d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(6)
	moveal a2@,a0
	movew a4@(4),d0
	lsrw #6,d0
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(7)
	moveal a2@,a0
	movew a4@(4),d0
	.short 0x0240,0x003f	/* andiw #63,d0 */
	.short 0x0600,0x0021	/* addib #33,d0 */
	moveb d0,a0@(8)
	.short 0x7408	/* moveq #8,d2 */
	.short 0x7277	/* moveq #119,d1 */
	movel d3,d0
	moveal a2@,a0
	lea a0@(9),a1
	bras L91c
L8fe:
	movel d7,d0
	tstw d6
	beqs L90a
	.short 0x203c,0x0000,0x00e8	/* movel #232,d0 */
L90a:
	moveal d0,a1
	moveal a2@,a0
	bsrw Lc76
	.short 0x7408	/* moveq #8,d2 */
	.short 0x727c	/* moveq #124,d1 */
	movel d3,d0
	moveal a2@,a1
	.short 0x5889	/* addql #4,a1 */
L91c:
	moveal d4,a0
	bsrw L9b2
	movel d0,d2
	moveal a3@,a0
	movel a2@,a0@
	.short 0x5893	/* addql #4,a3@ */
	moveal a2@,a0
	bsrw Lc68
	moveal a2@,a0
	lea a0@(0x1,d0:l),a0
	movel a0,a2@
	addl d2,d4
	subl d2,d3
	tstl d3
	bgts L8fe
	.short 0x7a01	/* moveq #1,d5 */
	movew a4@(4),d1
	.short 0x5341	/* subqw #1,d1 */
	asrw #1,d1
	movew a4@,d3
	movew a4@(2),d0
	movel a4@(12),d2
	tstw d1
	beqs L95e
L958:
	.short 0x5245	/* addqw #1,d5 */
	asrw #1,d1
	bnes L958
L95e:
	.short 0xc6c0	/* muluw d0,d3 */
	movel d2,d4
	tstl d3
	bles L9a8
L966:
	movel d7,d0
	tstw d6
	beqs L972
	.short 0x203c,0x0000,0x00e8	/* movel #232,d0 */
L972:
	moveal d0,a1
	moveal a2@,a0
	bsrw Lc76
	movew d5,d2
	extl d2
	.short 0x727c	/* moveq #124,d1 */
	movel d3,d0
	moveal a2@,a1
	.short 0x5889	/* addql #4,a1 */
	moveal d4,a0
	bsrs L9b2
	movel d0,d2
	moveal a3@,a0
	movel a2@,a0@
	.short 0x5893	/* addql #4,a3@ */
	moveal a2@,a0
	bsrw Lc68
	moveal a2@,a0
	lea a0@(0x1,d0:l),a0
	movel a0,a2@
	addl d2,d4
	subl d2,d3
	tstl d3
	bgts L966
L9a8:
	moveal a3@,a0
	clrl a0@
L9ac:
	moveml sp@+,d2-d7/a2-a4
	rts
L9b2:
	moveml d2-d7/a2-a6,sp@-
	moveal a0,a4
	movel d0,d4
	moveal d1,a3
	moveaw d2,a2
	clrw d3
	clrl d6
	clrl d5
	.short 0x4df8,0x0000	/* lea 0x0,a6 */
	clrw d2
	lea a3@(-1),a5
	bras La36
L9d0:
	.short 0x0c43,0x0006	/* cmpiw #6,d3 */
	bgts L9f0
	movew a2,d1
	extl d1
	clrl d0
L9dc:
	lsll d1,d6
	.short 0x5384	/* subql #1,d4 */
	bmis L9e8
	moveb a4@+,d0
	orl d0,d6
	.short 0x528e	/* addql #1,a6 */
L9e8:
	addw a2,d3
	.short 0x0c43,0x0006	/* cmpiw #6,d3 */
	bles L9dc
L9f0:
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
	bges La0c
	.short 0x7051	/* moveq #81,d0 */
	addl d1,d0
La0c:
	.short 0x7220	/* moveq #32,d1 */
	cmpl d0,d1
	bnes La22
	.short 0x5242	/* addqw #1,d2 */
	.short 0x0c42,0x002f	/* cmpiw #47,d2 */
	bnes La34
	st a1@+
	.short 0x5285	/* addql #1,d5 */
	clrw d2
	bras La34
La22:
	tstw d2
	beqs La30
	.short 0x0602,0xffd0	/* addib #-48,d2 */
	moveb d2,a1@+
	.short 0x5285	/* addql #1,d5 */
	clrw d2
La30:
	moveb d0,a1@+
	.short 0x5285	/* addql #1,d5 */
La34:
	.short 0x5f43	/* subqw #7,d3 */
La36:
	tstl d4
	bgts La42
	movel a3,d0
	.short 0x5380	/* subql #1,d0 */
	tstw d3
	beqs La4a
La42:
	movel a3,d0
	.short 0x5380	/* subql #1,d0 */
	cmpal d5,a5
	bgts L9d0
La4a:
	tstw d2
	beqs La54
	.short 0x0602,0xffd0	/* addib #-48,d2 */
	moveb d2,a1@+
La54:
	cmpl d5,d0
	bgts La62
	tstw d3
	beqs La62
	tstl d4
	blts La62
	.short 0x538e	/* subql #1,a6 */
La62:
	clrb a1@
	movel a6,d0
	moveml sp@+,d2-d7/a2-a6
	rts
La6c:
	clrl d0
	tstl a0
	beqs La7e
	tstl a0@
	beqs La7e
La76:
	.short 0x5888	/* addql #4,a0 */
	.short 0x5280	/* addql #1,d0 */
	tstl a0@
	bnes La76
La7e:
	rts
	nop
La82:
	movel a2,sp@-
	moveal a1,a2
	tstl a0
	beqs La98
	tstl a0@
	beqs La98
	moveal a2@,a1
La90:
	movel a0@+,a1@+
	tstl a0@
	bnes La90
	movel a1,a2@
La98:
	moveal a2@,a0
	clrl a0@
	moveal sp@+,a2
	rts
	movel d0,d0
Laa2:
	.short 0xdefc,0xfff4	/* addaw #-12,sp */
	moveml d2-d4/a2-a3/a6,sp@-
	moveal a0,a3
	moveal a3@,a0
	moveal a0@(54),a2
	moveal a2,a0
	bsrs La6c
	movel d0,d2
	.short 0x0682,0x0000,0x00f9	/* addil #249,d2 */
	lsll #2,d2
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	movel d2,d0
	.short 0x0680,0x0000,0x7b00	/* addil #31488,d0 */
	.short 0x7201	/* moveq #1,d1 */
	jsr a6@(-684)
	movel d0,d4
	beqs Lb34
	movel d0,sp@(28)
	addl d4,d2
	movel d2,sp@(24)
	.short 0x761c	/* moveq #28,d3 */
	addl sp,d3
	moveal d3,a1
	moveal a2,a0
	bsrs La82
	moveal a3@(4),a6
	tstl a6
	beqs Lb34
	btst #1,a6@(7)
	bnes Lb34
	moveal sp@(28),a0
	.short 0x20bc,0x0000,0x0aa0	/* movel #2720,a0@ */
	.short 0x58af,0x001c	/* addql #4,sp@(28) */
	moveal sp@(28),a0
	.short 0x20bc,0x0000,0x00ba	/* movel #186,a0@ */
	.short 0x58af,0x001c	/* addql #4,sp@(28) */
	.short 0x7418	/* moveq #24,d2 */
	addl sp,d2
	moveal d2,a2
	moveal d3,a1
	clrl d0
	moveal a6,a0
	bsrw L86a
	moveal d3,a1
	.short 0x7001	/* moveq #1,d0 */
	moveal a3@(8),a0
	bsrw L86a
Lb34:
	movel d4,d0
	moveml sp@+,d2-d4/a2-a3/a6
	.short 0xdefc,0x000c	/* addaw #12,sp */
	rts
	rts
	nop
	linkw a5,#-4
	moveml d2/a2-a4/a6,sp@-
	moveal a0,a2
	movel a1,d2
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	.short 0x7003	/* moveq #3,d0 */
	jsr a6@(-174)
	moveal d0,a3
	tstl a3
	beqw Lc30
	.short 0x7201	/* moveq #1,d1 */
	.short 0x7018	/* moveq #24,d0 */
	lea a3@(78),a0
	bsrw L22c
	moveal d0,a4
	tstl a4
	beqw Lc24
	clrl sp@-
	pea a5@(-4)
	.short 0x2f3c,0x8000,0x9001	/* movel #-2147446783,sp@- */
	bfexts a2@(7),7,1,d0
	notl d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9010	/* movel #-2147446768,sp@- */
	movel a2@(8),sp@-
	.short 0x2f3c,0x8000,0x9014	/* movel #-2147446764,sp@- */
	clrl d0
	movew a2@(4),d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9018	/* movel #-2147446760,sp@- */
	movel a2@(12),sp@-
	.short 0x2f3c,0x8000,0x901c	/* movel #-2147446756,sp@- */
	.short 0x4878,0x0011	/* pea 0x11 */
	.short 0x2f3c,0x8000,0x9024	/* movel #-2147446748,sp@- */
	clrl d0
	movew a2@(2),d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9028	/* movel #-2147446744,sp@- */
	clrl d0
	movew a2@,d0
	movel d0,sp@-
	.short 0x2f3c,0x8000,0x9026	/* movel #-2147446746,sp@- */
	movel a3,sp@-
	bsrw L1da
	.short 0xdefc,0x0048	/* addaw #72,sp */
	tstl a5@(-4)
	bnes Lc24
	movew a2@,a3@(12)
	movew a2@(2),a3@(14)
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a3,a0
	moveal d2,a1
	.short 0x45f8,0x0000	/* lea 0x0,a2 */
	jsr a6@(-192)
	tstw d0
	beqs Lc24
	.short 0x2c79,0x0000,0x0008	/* moveal 0x8,a6 */
	moveal a3@(22),a0
	moveal a4,a1
	.short 0x7014	/* moveq #20,d0 */
	jsr a6@(-624)
	movel a3,a4@(20)
	movel a4,d0
	bras Lc32
Lc24:
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a3,a0
	jsr a6@(-90)
Lc30:
	clrl d0
Lc32:
	moveml a5@(-24),d2/a2-a4/a6
	unlk a5
	rts
	movel a6,sp@-
	.short 0x2c79,0x0000,0x0004	/* moveal 0x4,a6 */
	moveal a0@(20),a0
	jsr a6@(-90)
	moveal sp@+,a6
	rts
	movel a6,sp@-
	moveal a6,a1
	clrl d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	.short 0x41f8,0x0000	/* lea 0x0,a0 */
	bsrw L2ca
	moveal sp@+,a6
	rts
Lc68:
	movel a0,d0
Lc6a:
	tstb a0@+
	bnes Lc6a
	subl a0,d0
	notl d0
	rts
	nop
Lc76:
	moveb a1@,a0@+
	tstb a1@+
	bnes Lc76
	rts
	nop
	.data
	.byte 0x00,0x00,0x00,0x7e,0x00,0x00,0x01,0x36,0x00,0x00,0x00,0xe6,0x00,0x00,0x00,0x06
	.byte 0x00,0x00,0x05,0x4e,0x00,0x00,0x06,0x20,0x00,0x00,0x08,0x4e,0x00,0x00,0x08,0x64
	.byte 0x00,0x00,0x0a,0xa2,0x00,0x00,0x0b,0x40,0x00,0x00,0x0b,0x44,0x00,0x00,0x0c,0x3c
	.byte 0x00,0x00,0x0c,0x50,0xff,0xff,0xff,0xff,0x6e,0x65,0x77,0x69,0x63,0x6f,0x6e,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x6e,0x65,0x77,0x69,0x63,0x6f,0x6e,0x2e
	.byte 0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x20,0x34,0x34,0x2e,0x33,0x20,0x28,0x32,0x31
	.byte 0x2e,0x30,0x35,0x2e,0x30,0x30,0x29,0x20,0x65,0x6d,0x75,0x6c,0x61,0x74,0x69,0x6f
	.byte 0x6e,0x20,0x28,0x43,0x29,0x20,0x32,0x30,0x30,0x30,0x20,0x62,0x79,0x20,0x53,0x74
	.byte 0x65,0x70,0x68,0x61,0x6e,0x20,0x52,0x75,0x70,0x70,0x72,0x65,0x63,0x68,0x74,0x00
	.byte 0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0c
	.byte 0x4a,0xfc,0x00,0x00,0x00,0xa0,0x00,0x00,0x00,0xba,0x80,0x2c,0x09,0x00,0x00,0x00
	.byte 0x00,0x38,0x00,0x00,0x00,0x48,0x00,0x00,0x00,0x90,0x2a,0x2a,0x2a,0x20,0x44,0x4f
	.byte 0x4e,0x27,0x54,0x20,0x45,0x44,0x49,0x54,0x20,0x54,0x48,0x45,0x20,0x46,0x4f,0x4c
	.byte 0x4c,0x4f,0x57,0x49,0x4e,0x47,0x20,0x4c,0x49,0x4e,0x45,0x53,0x21,0x21,0x20,0x2a
	.byte 0x2a,0x2a,0x00,0x49,0x4d,0x31,0x3d,0x00,0x49,0x4d,0x32,0x3d,0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
