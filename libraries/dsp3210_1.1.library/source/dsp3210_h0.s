	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00
	.byte 0x00,0x04,0x00,0x00,0x04,0x3a,0x00,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00
	.byte 0x00,0x34,0x00,0x00,0x00,0x56
L1e:
	.byte 0x64,0x73
	.byte 0x70,0x33,0x32,0x31,0x30,0x2e,0x6c,0x69
	.byte 0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20
L34:
	.byte 0x64,0x73,0x70,0x33
	.byte 0x32,0x31,0x30,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x20,0x31,0x2e,0x31,0x20
	.byte 0x28,0x33,0x2e,0x31,0x2e,0x32,0x30,0x32
	.byte 0x30,0x29,0x0d,0x0a,0x00,0x00
	moveml d1-d7/a1-a6,sp@-
	moveal 0x4,a6
	movel a0,d1
	lea %pc@(L128),a0
	subal a1,a1
	lea %pc@(L82),a2
	.short 0x702a	/* moveq #42,d0 */
	jsr a6@(-84)
	tstl d0
	beqs L7c
	moveal d0,a1
	jsr a6@(-396)
	.short 0x7001	/* moveq #1,d0 */
L7c:
	moveml sp@+,d1-d7/a1-a6
	rts
L82:
	moveml a1,sp@-
	moveal a0,a1
	moveal d0,a0
	movel a1,a0@(34)
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	lea %pc@(L1e),a1
	movel a1,a0@(10)
	.short 0x317c,0x0001,0x0014	/* movew #1,a0@(20) */
	.short 0x317c,0x0001,0x0016	/* movew #1,a0@(22) */
	lea %pc@(L34),a1
	movel a1,a0@(24)
	clrw a0@(32)
	movel d0,d0
	moveml sp@+,a1
	rts
	.short 0x7000	/* moveq #0,d0 */
	movel a6,d0
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	rts
	.short 0x7000	/* moveq #0,d0 */
	tstw a6@(32)
	beqs Le4
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes Le4
	btst #3,a6@(14)
	beqs Le4
	bsrs Le6
Le4:
	rts
Le6:
	.short 0x7000	/* moveq #0,d0 */
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	moveal 0x4,a6
	tstw a5@(32)
	beqs L100
	bset #3,a5@(14)
	bras L11e
L100:
	movel a5@(34),d2
	moveal a5,a1
	jsr a6@(-252)
	moveal a5,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
L11e:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L128:
	.short 0x0000,0x00bc	/* orib #-68,d0 */
	.short 0x0000,0x00cc	/* orib #-52,d0 */
	.short 0x0000,0x00e6	/* orib #-26,d0 */
	.short 0x0000,0x0124	/* orib #36,d0 */
	.short 0x0000,0x0144	/* orib #68,d0 */
	.short 0x0000,0x01e0	/* orib #-32,d0 */
	.short 0xffff
	.short 0xffff
	moveml d2-d7/a2-a6,sp@-
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L1b6
	movel a0@(12),d2
	muluw #18,d2
	addl a0@(8),d2
	cmpl d0,d2
	bhiw L3fe
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(2),d1
	beqw L1b6
	movew a0@(16),d2
	lea a0@(0x14,d2:w),a1
L176:
	lea a1@(36),a2
	bsrw L1be
	.short 0x0c87,0x0000,0x0020	/* cmpil #32,d7 */
	beqs L198
	.short 0x0c87,0x0000,0x0040	/* cmpil #64,d7 */
	beqs L198
	.short 0x0c87,0x0000,0x0080	/* cmpil #128,d7 */
	bnew L1ba
L198:
	lea a1@(16),a2
	bsrw L1be
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addl d7,d0
	lea a1@(40),a1
	.short 0x5341	/* subqw #1,d1 */
	bnes L176
L1b0:
	moveml sp@+,d2-d7/a2-a6
	rts
L1b6:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L1b0
L1ba:
	.short 0x70fe	/* moveq #-2,d0 */
	bras L1b0
L1be:
	movel a2,sp@-
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	swap d7
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	moveal sp@+,a2
	rts
L1d2:
	movel a2,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	moveal sp@+,a2
	rts
	.short 0x514f	/* subqw #8,sp */
	moveml d2-d7/a2-a6,sp@-
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L3fe
	movel a0@(12),d2
	muluw #18,d2
	addl a0@(8),d2
	cmpl d0,d2
	bhiw L3fe
	movel a2,sp@(48)
	moveal a0,a5
	moveal a1,a4
	.short 0x7c00	/* moveq #0,d6 */
	movew a0@(2),d6
	beqw L3fe
	movel d6,d0
	addl d0,d0
	addl d0,d0
	movel d0,sp@(44)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	moveal 0x4,a6
	jsr a6@(-198)
	tstl d0
	beqw L406
	moveal d0,a6
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a3
	moveml d6/a3-a4/a6,sp@-
L23e:
	movel a4,a6@+
	moveal a4,a1
	lea a3@(20),a2
	bsrw L1be
	moveal a5,a0
	addal d7,a0
	lea a3@(16),a2
	bsrw L1be
	movel d7,d0
	beqs L268
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addal d7,a4
L262:
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	bnes L262
L268:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnes L23e
	moveml sp@+,d6/a3-a4/a6
	moveml d6/a4/a6,sp@-
	moveal a6,a4
L27a:
	moveal a4@+,a0
	lea a3@(30),a2
	bsrw L1be
	movel d7,d5
	beqw L3d2
	lea a3@(24),a2
	bsrw L1be
	tstl d7
	beqw L3d2
	moveal a5,a1
	addal d7,a1
	moveml a3,sp@-
	moveal a5@(8),a3
	addal a5,a3
L2a6:
	moveal a1,a2
	bsrw L1be
	movel d7,d3
	lea a1@(4),a2
	bsrw L1be
	muluw #18,d7
	moveal a3,a2
	addal d7,a2
	movel a2,sp@-
	lea a2@(8),a2
	bsrw L1be
	movel d7,d4
	moveal sp@+,a2
	movel a2,sp@-
	lea a2@(12),a2
	bsrw L1d2
	moveal sp@+,a2
	tstw d7
	beqw L2e4
	bmiw L418
	bras L334
L2e4:
	moveml d0-d2/a0-a2,sp@-
	tstb a2@
	bnes L306
	lea a2@(6),a2
	bsrw L1d2
	moveal a5,a2
	movel a5@(12),d0
	muluw #18,d0
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L306:
	movel sp@(88),d0
	beqs L328
	moveal d0,a0
L30e:
	movel a0@,d0
	beqs L328
	moveal d0,a1
	bsrw L424
	lea a0@(8),a0
	bnes L30e
	movel a0@(-4),d4
	moveml sp@+,d0-d2/a0-a2
	bras L35c
L328:
	moveal a2,a3
	moveml sp@+,d0-d2/a0-a2
	moveal a3,a2
	braw L41c
L334:
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	muluw #40,d7
	lea a2@(0xc,d7:w),a2
	bsrw L1be
	subl d7,d4
	moveml sp@+,d7
	addl d7,d7
	addl d7,d7
	addl a6@(0x0,d7:w),d4
L35c:
	lea a1@(8),a2
	bsrw L1d2
	.short 0x0c47,0x002c	/* cmpiw #44,d7 */
	beqs L380
	.short 0x0c47,0x002e	/* cmpiw #46,d7 */
	beqs L38c
	.short 0x0c47,0x002f	/* cmpiw #47,d7 */
	beqs L39a
	.short 0x0c47,0x001c	/* cmpiw #28,d7 */
	beqs L3aa
	braw L414
L380:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel d4,a0@
	moveal sp@+,a0
	bras L3c4
L38c:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	movew d4,a0@
	moveal sp@+,a0
	bras L3c4
L39a:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	swap d4
	movew d4,a0@
	moveal sp@+,a0
	bras L3c4
L3aa:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	movew d4,a0@
	moveal sp@+,a0
	.short 0x0284,0xffff,0x0000	/* andil #-65536,d4 */
	bnew L420
	bras L3c4
	nop
L3c4:
	lea a1@(10),a1
	.short 0x5385	/* subql #1,d5 */
	bnew L2a6
	moveml sp@+,a3
L3d2:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnew L27a
	moveml sp@+,d6/a4/a6
	.short 0x7000	/* moveq #0,d0 */
L3e2:
	movel d0,d2
	movel sp@(44),d0
	moveal a6,a1
	moveal 0x4,a6
	jsr a6@(-210)
	movel d2,d0
	moveal a2,a0
L3f6:
	moveml sp@+,d2-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L3fe:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L3f6
	.short 0x70fe	/* moveq #-2,d0 */
	bras L3f6
L406:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L3f6
L40a:
	moveml sp@+,a3
	moveml sp@+,d6/a4/a6
	bras L3e2
L414:
	.short 0x70f6	/* moveq #-10,d0 */
	bras L40a
L418:
	.short 0x70ec	/* moveq #-20,d0 */
	bras L40a
L41c:
	.short 0x70eb	/* moveq #-21,d0 */
	bras L40a
L420:
	.short 0x70e2	/* moveq #-30,d0 */
	bras L40a
L424:
	moveml a1-a2,sp@-
L428:
	tstb a2@
	beqs L432
	cmpmb a1@+,a2@+
	beqs L428
	bras L434
L432:
	tstb a1@
L434:
	moveml sp@+,a1-a2
	.byte 0x4e,0x75,0x00,0x00	/* rts */

