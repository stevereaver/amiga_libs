	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x11,0xe0,0x00,0x07
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x9c,0x64,0x73
	.byte 0x70,0x33,0x32,0x31,0x30,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20,0x64,0x73,0x70,0x33,0x32,0x31,0x30,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x20,0x37,0x2e,0x31,0x20,0x28,0x31,0x32,0x2e,0x31,0x32,0x2e,0x32
	.byte 0x30,0x32,0x31,0x29,0x0d,0x0a,0x00,0x00,0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x00,0x44,0x53,0x50,0x43,0x4f,0x4d,0x50,0x41,0x54,0x00,0x00,0x00
	.byte 0x57,0x72,0x69,0x74,0x74,0x65,0x6e,0x20,0x62,0x79,0x20,0x54,0x68,0x6f,0x6d,0x61
	.byte 0x73,0x20,0x57,0x69,0x6e,0x69,0x73,0x63,0x68,0x68,0x6f,0x66,0x65,0x72,0x20,0x28
	.byte 0x41,0x31,0x30,0x30,0x30,0x31,0x39,0x38,0x36,0x29,0x00,0x00
	.byte 0x48,0xe7
L9e:
	.short 0x7f7e	/* .short 0x7f7e */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a0,d1
	.byte 0x41
La7:
	.byte 0xfa,0x00
La9:
	.byte 0xca	/* lea %pc@(0x172),a0 */
	subal a1,a1
	lea %pc@(Lc8),a2
	.short 0x702c	/* moveq #44,d0 */
Lb2:
	.byte 0x4e,0xae
Lb4:
	.byte 0xff,0xac	/* jsr a6@(-84) */
	tstl d0
	beqs Lc2
	moveal d0,a1
	jsr a6@(-396)
	.short 0x7001	/* moveq #1,d0 */
Lc2:
	moveml sp@+,d1-d7/a1-a6
	.byte 0x4e
Lc7:
	.byte 0x75	/* rts */
Lc8:
	moveml a1,sp@-
	moveal a0,a1
	moveal d0,a0
	.byte 0x21,0x49
Ld2:
	.byte 0x00,0x22	/* movel a1,a0@(34) */
Ld4:
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	.short 0x43fa,0xff42	/* lea %pc@(0x1e),a1 */
	.byte 0x21,0x49,0x00
Le1:
	.byte 0x0a	/* movel a1,a0@(10) */
	.short 0x317c,0x0007,0x0014	/* movew #7,a0@(20) */
Le8:
	.byte 0x31,0x7c,0x00,0x01,0x00
Led:
	.byte 0x16	/* movew #1,a0@(22) */
	.short 0x43fa,0xff44	/* lea %pc@(0x34),a1 */
Lf2:
	.byte 0x21
Lf3:
	.byte 0x49,0x00,0x18	/* movel a1,a0@(24) */
	clrw a0@(32)
	movel d0,d0
	moveml sp@+,a1
L100:
	rts
	.short 0x7000	/* moveq #0,d0 */
	movel a6,d0
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	rts
	.short 0x7000	/* moveq #0,d0 */
	tstw a6@(32)
	beqs L12a
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L12a
	btst #3,a6@(14)
	beqs L12a
	bsrs L12c
L12a:
	rts
L12c:
	.short 0x7000	/* moveq #0,d0 */
	moveml d2/a5-a6,sp@-
	bsrw Lf18
	moveal a6,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	tstw a5@(32)
	beqs L14a
	bset #3,a5@(14)
	bras L168
L14a:
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
L168:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0xff,0xff,0xff,0x90,0xff,0xa0,0xff,0xba,0xff,0xfc,0x00,0x22,0x00,0xb0,0x00,0xba
	.byte 0x08,0x0e,0x09,0xe0,0x0a,0xf2,0x0a,0x28,0x0b,0x80,0x08,0x1a,0x0d,0x74,0x0a,0xa0
	.short 0xffff	/* .short 0xffff */
L194:
	moveml d2-d7/a2-a6,sp@-
	bsrw Lf66
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L1f8
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(2),d1
	beqw L1f8
	movew a0@(16),d2
	lea a0@(0x14,d2:w),a1
L1b8:
	lea a1@(36),a2
	bsrw L200
	.short 0x0c87,0x0000,0x0020	/* cmpil #32,d7 */
	beqs L1da
	.short 0x0c87,0x0000,0x0040	/* cmpil #64,d7 */
	beqs L1da
	.short 0x0c87,0x0000,0x0080	/* cmpil #128,d7 */
	bnew L1fc
L1da:
	lea a1@(16),a2
	bsrw L200
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addl d7,d0
	lea a1@(40),a1
	.short 0x5341	/* subqw #1,d1 */
	bnes L1b8
L1f2:
	moveml sp@+,d2-d7/a2-a6
	rts
L1f8:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L1f2
L1fc:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L1f2
L200:
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
L214:
	movel a2,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	moveal sp@+,a2
	rts
	movel a3,sp@-
	moveal a1,a3
	bsrs L22c
	moveal sp@+,a3
	rts
L22c:
	.short 0x514f	/* subqw #8,sp */
	moveml d2-d7/a2-a6,sp@-
	bsrw Lf66
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L942
	movel a2,sp@(48)
	moveal a0,a5
	moveal a1,a4
	movel a3,d5
	.short 0x7c00	/* moveq #0,d6 */
	movew a0@(2),d6
	beqw L942
	movel d6,d0
	lsll #3,d0
	movel d0,sp@(44)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	beqw L94a
	moveal d0,a6
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a3
	moveml d6/a3-a4/a6,sp@-
L27c:
	movel a4,a6@+
	movel d5,a6@+
	moveal a4,a1
	lea a3@(20),a2
	bsrw L200
	moveal a5,a0
	addal d7,a0
	lea a3@(16),a2
	bsrw L200
	movel d7,d0
	beqs L2aa
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addal d7,a4
	addl d7,d5
L2a4:
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	bnes L2a4
L2aa:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnes L27c
	moveml sp@+,d6/a3-a4/a6
	moveml d6/a3/a6,sp@-
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
	beqw L33e
L2c8:
	lea a3@(12),a2
	bsrw L214
	tstw d7
	beqs L320
	bmis L320
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	lea a3@(8),a2
	bsrw L200
	movel d7,d4
	moveml sp@+,d7
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L200
	subl d7,d4
	moveml sp@+,d7
	lsll #3,d7
	addl a6@(0x4,d7:w),d4
	lea a3@(12),a2
	moveb d4,a2@-
	lsrw #8,d4
	moveb d4,a2@-
	swap d4
	moveb d4,a2@-
	lsrw #8,d4
	moveb d4,a2@-
L320:
	tstb a3@(17)
	beqs L336
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L336:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L2c8
L33e:
	moveml sp@+,d6/a3/a6
	moveml d6/a4/a6,sp@-
	moveal a6,a4
L348:
	moveal a4@,a0
	btst #2,a5@(19)
	beqs L354
	.short 0x508c	/* addql #8,a4 */
L354:
	lea a3@(32),a2
	bsrw L214
	movel d7,d5
	beqw L90a
	lea a3@(24),a2
	bsrw L200
	tstl d7
	beqw L90a
	moveal a5,a1
	addal d7,a1
	moveml d6/a3,sp@-
	moveal a5@(8),a3
	addal a5,a3
	.short 0x598f	/* subql #4,sp */
L380:
	moveal a1,a2
	bsrw L200
	movel d7,d3
	lea a1@(4),a2
	bsrw L200
	.short 0xcefc,0x0012	/* muluw #18,d7 */
	moveal a3,a2
	addal d7,a2
	bsrw Lfc6
	beqw L8fa
	movel a2,sp@-
	lea a2@(8),a2
	bsrw L200
	movel d7,d4
	moveal sp@+,a2
	movel a2,sp@-
	lea a2@(12),a2
	bsrw L214
	moveal sp@+,a2
	tstw d7
	beqw L3d8
	.short 0x0c47,0xffff	/* cmpiw #-1,d7 */
	beqw L44e
	.short 0x0c47,0xfffe	/* cmpiw #-2,d7 */
	beqw L44e
	tstw d7
	bmiw L95e
	bras L428
L3d8:
	moveml d0-d2/a0-a2,sp@-
	tstb a2@
	bnes L3fa
	lea a2@(4),a2
	bsrw L200
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L3fa:
	movel sp@(96),d0
	beqs L41c
	moveal d0,a0
	moveml d1/a0-a1,sp@-
	moveal a2,a1
	bsrw Lc64
	moveml sp@+,d1/a0-a1
	beqs L41c
	movel d0,d4
	moveml sp@+,d0-d2/a0-a2
	.short 0x7c00	/* moveq #0,d6 */
	bras L44e
L41c:
	moveal a2,a3
	moveml sp@+,d0-d2/a0-a2
	moveal a3,a2
	braw L962
L428:
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L200
	movel d7,d6
	moveml sp@+,d7
	lsll #3,d7
	movel a6@(0x4,d7:w),d4
L44e:
	lea a1@(8),a2
	bsrw L214
	.short 0x0c47,0x002c	/* cmpiw #44,d7 */
	beqw L572
	.short 0x0c47,0x002d	/* cmpiw #45,d7 */
	beqw L572
	.short 0x0c47,0x003b	/* cmpiw #59,d7 */
	beqw L572
	.short 0x0c47,0x0038	/* cmpiw #56,d7 */
	beqw L572
	.short 0x0c47,0x0031	/* cmpiw #49,d7 */
	beqw L5f8
	.short 0x0c47,0x002e	/* cmpiw #46,d7 */
	beqw L586
	.short 0x0c47,0x0039	/* cmpiw #57,d7 */
	beqw L586
	.short 0x0c47,0x003e	/* cmpiw #62,d7 */
	beqw L586
	.short 0x0c47,0x0036	/* cmpiw #54,d7 */
	beqw L586
	.short 0x0c47,0x002f	/* cmpiw #47,d7 */
	beqw L5a2
	.short 0x0c47,0x003a	/* cmpiw #58,d7 */
	beqw L5a2
	.short 0x0c47,0x003f	/* cmpiw #63,d7 */
	beqw L5a2
	.short 0x0c47,0x0037	/* cmpiw #55,d7 */
	beqw L5a2
	.short 0x0c47,0x003c	/* cmpiw #60,d7 */
	beqw L5be
	.short 0x0c47,0x003d	/* cmpiw #61,d7 */
	beqw L5d8
	.short 0x0c47,0x0027	/* cmpiw #39,d7 */
	beqw L60e
	.short 0x0c47,0x0026	/* cmpiw #38,d7 */
	beqw L632
	.short 0x0c47,0x0029	/* cmpiw #41,d7 */
	beqw L674
	.short 0x0c47,0x0028	/* cmpiw #40,d7 */
	beqw L6a8
	.short 0x0c47,0x001c	/* cmpiw #28,d7 */
	beqw L70e
	.short 0x0c47,0x0024	/* cmpiw #36,d7 */
	beqw L70e
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqw L70e
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqw L70e
	.short 0x0c47,0x001d	/* cmpiw #29,d7 */
	beqw L73a
	.short 0x0c47,0x0025	/* cmpiw #37,d7 */
	beqw L73a
	.short 0x0c47,0x001e	/* cmpiw #30,d7 */
	beqw L772
	.short 0x0c47,0x001f	/* cmpiw #31,d7 */
	beqw L794
	.short 0x0c47,0x0022	/* cmpiw #34,d7 */
	beqw L7b8
	.short 0x0c47,0x0023	/* cmpiw #35,d7 */
	beqw L858
	.short 0x0c47,0x002a	/* cmpiw #42,d7 */
	beqw L8fa
	.short 0x0c47,0x002b	/* cmpiw #43,d7 */
	beqw L8fa
	.short 0x0c47,0x0020	/* cmpiw #32,d7 */
	beqw L8fa
	.short 0x0c47,0x0021	/* cmpiw #33,d7 */
	beqw L8fa
	.short 0x0c47,0x0032	/* cmpiw #50,d7 */
	beqw L8fa
	.short 0x0c47,0x0033	/* cmpiw #51,d7 */
	beqw L8fa
	braw L95a
L572:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L586:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,sp@(4)
	movew d0,a0@
	moveal sp@+,a0
	braw L8fa
L5a2:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	swap d0
	addl sp@(4),d0
	swap d0
	movew d0,a0@
	moveal sp@+,a0
	braw L8fa
L5be:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,sp@(4)
	moveal sp@+,a0
	braw L8fa
L5d8:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	.short 0x5483	/* addql #2,d3 */
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	swap d0
	addl sp@(4),d0
	swap d0
	.short 0x0240,0xff00	/* andiw #-256,d0 */
	movew d0,a0@
	moveal sp@+,a0
	braw L8fa
L5f8:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	.short 0x0080,0x0000,0x5003	/* oril #20483,d0 */
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L60e:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L62a
	moveal sp@+,a0
	braw L966
L62a:
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L632:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	movel d0,d2
	.short 0x0281,0x0000,0xffff	/* andil #65535,d1 */
	lsrl #5,d2
	.short 0x0282,0x00ff,0x0000	/* andil #16711680,d2 */
	orl d2,d1
	subl d6,d1
	addl d4,d1
	.short 0x0280,0xe01f,0x0000	/* andil #-534839296,d0 */
	movel d1,d2
	.short 0x0282,0x0000,0xffff	/* andil #65535,d2 */
	orl d2,d0
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	orl d1,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L674:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	btst #23,d0
	beqs L688
	.short 0x0080,0xff00,0x0000	/* oril #-16777216,d0 */
L688:
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L6a0
	.short 0x0c81,0xff00,0x0000	/* cmpil #-16777216,d1 */
	beqs L6a0
	.short 0x7000	/* moveq #0,d0 */
L6a0:
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L6a8:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	movel d0,d2
	.short 0x0281,0x0000,0xffff	/* andil #65535,d1 */
	lsrl #5,d2
	.short 0x0282,0x00ff,0x0000	/* andil #16711680,d2 */
	orl d2,d1
	btst #23,d1
	beqs L6d0
	.short 0x0081,0xff00,0x0000	/* oril #-16777216,d1 */
L6d0:
	subl d6,d1
	addl d4,d1
	movel d1,d2
	.short 0x0282,0xff00,0x0000	/* andil #-16777216,d2 */
	beqs L6ec
	.short 0x0c82,0xff00,0x0000	/* cmpil #-16777216,d2 */
	beqs L6ec
	moveal sp@+,a0
	braw L966
L6ec:
	.short 0x0280,0xe01f,0x0000	/* andil #-534839296,d0 */
	movel d1,d2
	.short 0x0282,0x0000,0xffff	/* andil #65535,d2 */
	orl d2,d0
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	orl d1,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L8fa
L70e:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqs L728
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqs L728
	subl d6,d0
	addl d4,d0
L728:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L966
	braw L8fa
L73a:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L760
	.short 0x0c80,0xffff,0x0000	/* cmpil #-65536,d0 */
	bnes L760
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L760:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L966
	braw L8fa
L772:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L78a
	.short 0x7000	/* moveq #0,d0 */
L78a:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L8fa
L794:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L7ae
	.short 0x7000	/* moveq #0,d0 */
L7ae:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L8fa
L7b8:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xa000,0x0000	/* andil #-1610612736,d1 */
	.short 0x0c81,0xa000,0x0000	/* cmpil #-1610612736,d1 */
	bnes L818
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L7f4
	moveal sp@+,a0
	braw L966
L7f4:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L812:
	moveal sp@+,a0
	braw L8fa
L818:
	movel d0,d1
	.short 0x0281,0x8000,0x0000	/* andil #-2147483648,d1 */
	.short 0x0c81,0x8000,0x0000	/* cmpil #-2147483648,d1 */
	bnes L812
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L846
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L846:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L966
	braw L8fa
L858:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xe000,0x0000	/* andil #-536870912,d1 */
	.short 0x0c81,0xe000,0x0000	/* cmpil #-536870912,d1 */
	bnes L8b8
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L894
	moveal sp@+,a0
	braw L966
L894:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L8b2:
	moveal sp@+,a0
	braw L8fa
L8b8:
	movel d0,d1
	.short 0x0281,0x1000,0x0000	/* andil #268435456,d1 */
	.short 0x0c81,0x1000,0x0000	/* cmpil #268435456,d1 */
	bnes L8b2
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L8e6
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L8e6:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L966
	braw L8fa
	nop
L8fa:
	lea a1@(10),a1
	.short 0x5385	/* subql #1,d5 */
	bnew L380
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
L90a:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnew L348
	moveml sp@+,d6/a4/a6
	movel sp@(48),d0
	beqs L924
	moveal d0,a4
	bsrw L105c
L924:
	.short 0x7000	/* moveq #0,d0 */
L926:
	movel d0,d2
	movel sp@(44),d0
	moveal a6,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	movel d2,d0
	moveal a2,a0
L93a:
	moveml sp@+,d2-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L942:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L93a
	.short 0x70fd	/* moveq #-3,d0 */
	bras L93a
L94a:
	.short 0x70fb	/* moveq #-5,d0 */
	bras L93a
L94e:
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
	moveml sp@+,d6/a4/a6
	bras L926
L95a:
	.short 0x70f5	/* moveq #-11,d0 */
	bras L94e
L95e:
	.short 0x70eb	/* moveq #-21,d0 */
	bras L94e
L962:
	.short 0x70e9	/* moveq #-23,d0 */
	bras L94e
L966:
	.short 0x70e1	/* moveq #-31,d0 */
	bras L94e
L96a:
	moveml a1-a2,sp@-
L96e:
	tstb a2@
	beqs L978
	cmpmb a1@+,a2@+
	beqs L96e
	bras L97a
L978:
	tstb a1@
L97a:
	moveml sp@+,a1-a2
	rts
	moveml d2-d7/a2-a6,sp@-
	.short 0x283c,0x0001,0x0001	/* movel #65537,d4 */
	bras L996
	moveml d2-d7/a2-a6,sp@-
	.short 0x283c,0x0001,0x0003	/* movel #65539,d4 */
L996:
	.short 0x2f3c,0xffff,0xfff9	/* movel #-7,sp@- */
	moveal a6,a5
	moveal a0,a4
	moveal a1,a3
	bsrw Lefa
	beqw Lb4a
	btst #1,d4
	bnes L9be
	bsrw Lf32
	tstb a6@(43)
	beqs L9be
	.short 0x0004,0x0002	/* orib #2,d4 */
L9be:
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,d7
	beqw Lb4a
	.short 0x2ebc,0xffff,0xfff7	/* movel #-9,sp@ */
	moveal a5@(38),a6
	movel a4,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d6
	beqw Lb3a
	movel d0,d1
	movel d7,d2
	jsr a6@(-102)
	movel d6,d1
	jsr a6@(-90)
	moveal d7,a1
	movel a1@(124),d7
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	movel d7,d0
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,d6
	beqw Lb4a
	.short 0x2ebc,0xffff,0xfff7	/* movel #-9,sp@ */
	moveal a5@(38),a6
	movel a4,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	movel d0,d5
	beqw Lb2c
	movel d0,d1
	movel d6,d2
	movel d7,d3
	jsr a6@(-42)
	cmpl d0,d3
	bnew Lb26
	movel d5,d1
	jsr a6@(-36)
	moveal d6,a0
	bsrw L194
	movel d0,d5
	bpls La72
	movel d0,sp@
	braw Lb2c
La72:
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	.short 0x5080	/* addql #8,d0 */
	movel a2,d1
	beqs La8e
	moveal a2@(38),a6
	moveal a2,a0
	movel d0,d1
	movel d4,d2
	jsr a6@(-54)
	bras La98
La8e:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d4,d1
	jsr a6@(-198)
La98:
	tstl d0
	beqw Lb2c
	moveal d0,a1
	.short 0x22fc,0x3210,0x2011	/* movel #839917585,a1@+ */
	movel d5,a1@+
	movel a1,d4
	movel a3,sp@-
	moveal a1,a3
	movel a2,d0
	beqs Lad0
	moveml a1-a2,sp@-
	moveal a2@(38),a6
	moveal a2,a0
	.short 0x598f	/* subql #4,sp */
	moveal sp,a2
	jsr a6@(-42)
	moveal sp@+,a3
	moveml sp@+,a1-a2
	tstl d0
	beqs Lad0
	moveal a1,a3
Lad0:
	moveal d6,a0
	moveal sp@+,a2
	bsrw L22c
	movel d0,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal d6,a1
	movel d7,d0
	jsr a6@(-210)
	movel sp@+,d0
	beqw Laf2
	movel d0,sp@
	braw Lb12
Laf2:
	moveal d4,a0
	movel d5,d0
	.short 0x0c6e,0x0024,0x0014	/* cmpiw #36,a6@(20) */
	blts Lb08
	.short 0x223c,0x0000,0x0800	/* movel #2048,d1 */
	jsr a6@(-642)
Lb08:
	movel d4,d0
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
Lb12:
	.short 0x5184	/* subql #8,d4 */
	moveal d4,a1
	movel a1@(4),d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lb4a
Lb26:
	movel d5,d1
	jsr a6@(-36)
Lb2c:
	moveal d6,a1
	movel d7,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lb4a
Lb3a:
	moveal d7,a1
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
Lb4a:
	movel sp@+,d0
	moveml sp@+,d2-d7/a2-a6
	rts
	movel a6,sp@-
	movel a0,d0
	beqs Lb96
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	btst #0,d0
	bnes Lb96
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lb96
	movel a1,d1
	beqs Lb80
	movel a6,sp@-
	moveal a1@(38),a6
	exg a0,a1
	jsr a6@(-60)
	moveal sp@+,a6
	movel d0,sp@
	bras Lb96
Lb80:
	clrl sp@
	movel a0@(4),d0
	.short 0x5080	/* addql #8,d0 */
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
Lb96:
	movel sp@+,d0
	rts
	movel a0,d1
	beqs Lbae
	btst #0,d1
	bnes Lbae
	.short 0x0c90,0x00fc,0x2011	/* cmpil #16523281,a0@ */
	beqs Lbb0
	bsrs Lbe2
Lbae:
	rts
Lbb0:
	moveml d7/a2-a3/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a1,d7
	moveal a0@(8),a1
	movel a1,d0
	beqs Lbdc
Lbc2:
	tstl a1@
	beqs Lbdc
	cmpl a1@(8),d7
	bnes Lbd8
	movel a1,sp@-
	jsr a6@(-252)
	moveal sp@+,a0
	bsrs Lbe2
	bras Lbdc
Lbd8:
	moveal a1@,a1
	bras Lbc2
Lbdc:
	moveml sp@+,d7/a2-a3/a6
	rts
Lbe2:
	clrl sp@-
	movel a0,d0
	beqs Lc0e
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	btst #0,d0
	bnes Lc0e
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lc0e
	movel a0@(4),d0
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	notl sp@
Lc0e:
	movel sp@+,d0
	rts
	movel a0,d0
	beqs Lc3a
	btst #0,d0
	bnes Lc3a
	.short 0x0c90,0x00fc,0x2011	/* cmpil #16523281,a0@ */
	beqs Lc3c
Lc24:
	tstl a0@
	beqs Lc3a
	movel a0,sp@-
	moveal a0@,a0
	bsrs Lbe2
	moveal sp@+,a0
	tstl d0
	beqs Lc36
	clrl a0@
Lc36:
	.short 0x5888	/* addql #4,a0 */
	bras Lc24
Lc3a:
	rts
Lc3c:
	moveml a2-a3/a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	lea a0@(8),a3
	tstl a3@
	beqs Lc5e
	bras Lc52
Lc4e:
	moveal a2,a0
	bsrs Lbe2
Lc52:
	moveal a3,a0
	jsr a6@(-258)
	moveal d0,a2
	tstl d0
	bnes Lc4e
Lc5e:
	moveml sp@+,a2-a3/a6
	rts
Lc64:
	moveml a2-a3,sp@-
	movel a0,d0
	beqs Lca0
	movel a1,d0
	beqs Lca0
	.short 0x0c90,0x00fc,0x2011	/* cmpil #16523281,a0@ */
	beqs Lca8
	moveal a1,a2
Lc7a:
	movel a0@+,d0
	beqs Lca0
	movel a0,sp@-
	moveal d0,a0
Lc82:
	movel a0@,d0
	beqs Lc9c
	moveal d0,a1
	bsrw L96a
	.short 0x5088	/* addql #8,a0 */
	bnes Lc82
	movel a0@(-4),d0
	tstl sp@+
	moveml sp@+,a2-a3
	rts
Lc9c:
	moveal sp@+,a0
	bras Lc7a
Lca0:
	moveml sp@+,a2-a3
	.short 0x7000	/* moveq #0,d0 */
	rts
Lca8:
	moveal a0,a3
	moveal a1,a2
	movel a3@(4),d0
	beqs Lcb8
	moveal d0,a0
	bsrs Lcdc
	bnes Lcd6
Lcb8:
	moveal a3@(8),a1
	movel a1,d0
	beqs Lcd6
Lcc0:
	tstl a1@
	beqs Lcd4
	lea a1@(12),a0
	movel a1,sp@-
	bsrs Lcdc
	moveal sp@+,a1
	bnes Lcd6
	moveal a1@,a1
	bras Lcc0
Lcd4:
	.short 0x7000	/* moveq #0,d0 */
Lcd6:
	moveml sp@+,a2-a3
	rts
Lcdc:
	movel a0@,d0
	beqs Lcf0
	moveal d0,a1
	bsrw L96a
	.short 0x5088	/* addql #8,a0 */
	bnes Lcdc
	movel a0@(-4),d0
	tstl sp@
Lcf0:
	rts
	moveml d2-d7/a2-a6,sp@-
	bsrw Lf66
	bsrw Lf84
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	beqs Ld10
	.short 0x7c01	/* moveq #1,d6 */
	.short 0x0c50,0x6601	/* cmpiw #26113,a0@ */
	bnew Lebe
Ld10:
	moveal a0,a2
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	bsrw L214
	movew d7,d0
	bsrw Lec6
	tstl d6
	beqs Ld2c
	movew a2@,d0
Ld2c:
	.short 0x548a	/* addql #2,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	moveal d7,a4
	bsrw Led2
	tstl d6
	beqs Ld48
	moveal a2@,a4
Ld48:
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	movel d7,d4
	bsrw Led2
	tstl d6
	beqs Ld5a
	movel a2@,d4
Ld5a:
	.short 0x588a	/* addql #4,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(16),d1
	tstl d6
	bnes Ld7c
	rorw #8,d1
Ld7c:
	addal d1,a2
	tstw d0
	beqw Le48
	.short 0x7203	/* moveq #3,d1 */
	tstl d6
	bnes Ld8c
	.short 0x7200	/* moveq #0,d1 */
Ld8c:
	.short 0x4a32,0x1000	/* tstb a2@(0,d1:w) */
	beqs Ld96
	.short 0x508a	/* addql #8,a2 */
	bras Lda2
Ld96:
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
Lda2:
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	moveal d7,a5
	bsrw Led2
	tstl d6
	beqs Ldde
	bsrw L200
	moveal d7,a5
Ldde:
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L214
	movew d7,d5
	bsrw Lec6
	tstl d6
	beqs Ldfa
	rorw #8,d5
Ldfa:
	.short 0x548a	/* addql #2,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	.short 0xdb78,0x0180	/* addw d5,0x180 */
	tstw d5
	beqs Le42
	movel a2,sp@-
	moveal a0,a2
	addal a5,a2
Le1e:
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	.short 0x5345	/* subqw #1,d5 */
	bnes Le1e
	moveal sp@+,a2
Le42:
	.short 0x5340	/* subqw #1,d0 */
	bnew Ld8c
Le48:
	.short 0x7203	/* moveq #3,d1 */
	tstl d6
	bnes Le50
	.short 0x7200	/* moveq #0,d1 */
Le50:
	movel d4,sp@-
	tstl d4
	beqs Lea2
	moveal a0,a2
	addal a4,a2
Le5a:
	.short 0x4a32,0x1000	/* tstb a2@(0,d1:w) */
	beqs Le64
	.short 0x508a	/* addql #8,a2 */
	bras Le70
Le64:
	.short 0x588a	/* addql #4,a2 */
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
Le70:
	bsrw L200
	bsrw Led2
	.short 0x588a	/* addql #4,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	bsrw L214
	bsrw Lec6
	.short 0x548a	/* addql #2,a2 */
	.short 0x528a	/* addql #1,a2 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@+,d0
	beqs Le9e
	subl d0,d4
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addal d0,a2
Le9e:
	.short 0x5384	/* subql #1,d4 */
	bnes Le5a
Lea2:
	movel sp@+,d4
	.short 0xc8fc,0x0012	/* muluw #18,d4 */
	moveal a4,a2
	addal d4,a2
	addal a0,a2
	bsrw L200
	bsrw Led2
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Lebe:
	.short 0x70ff	/* moveq #-1,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Lec6:
	movel a2,sp@-
	moveb d7,a2@+
	lsrw #8,d7
	moveb d7,a2@+
	moveal sp@+,a2
	rts
Led2:
	movel a2,sp@-
	moveb d7,a2@+
	lsrw #8,d7
	moveb d7,a2@+
	swap d7
	moveb d7,a2@+
	lsrw #8,d7
	moveb d7,a2@+
	moveal sp@+,a2
	rts
	moveml d1-a6,sp@-
	bsrs Lf32
	.short 0x7000	/* moveq #0,d0 */
	tstb a6@(43)
	sne d0
	moveml sp@+,d1-a6
	rts
Lefa:
	tstl a6@(38)
	bnes Lf16
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x7024	/* moveq #36,d0 */
	.short 0x43fa,0xf14e	/* lea %pc@(0x58),a1 */
	jsr a6@(-552)
	moveal sp@+,a6
	movel d0,a6@(38)
Lf16:
	rts
Lf18:
	movel a6@(38),d0
	beqs Lf30
	movel a6,sp@-
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal sp@+,a6
	clrl a6@(38)
Lf30:
	rts
Lf32:
	tstb a6@(42)
	bnes Lf64
	bsrs Lefa
	movel a6,sp@-
	moveal a6@(38),a6
	.short 0x41fa,0xf122	/* lea %pc@(0x64),a0 */
	movel a0,d1
	.short 0x9efc,0x0010	/* subaw #16,sp */
	movel sp,d2
	.short 0x7610	/* moveq #16,d3 */
	.short 0x7800	/* moveq #0,d4 */
	jsr a6@(-906)
	.short 0xdefc,0x0010	/* addaw #16,sp */
	moveal sp@+,a6
	st a6@(42)
	tstl d0
	spl a6@(43)
Lf64:
	rts
Lf66:
	.short 0x0c68,0x382b,0x000a	/* cmpiw #14379,a0@(10) */
	bnes Lf82
	movew a0@,a0@(10)
	notl a0@(12)
	.short 0x243c,0x0000,0x0166	/* movel #358,d2 */
	addl d2,a0@(12)
	movew d2,a0@
Lf82:
	rts
Lf84:
	.short 0x0c68,0x2b38,0x0008	/* cmpiw #11064,a0@(8) */
	bnes Lfc4
	moveml a0/a2,sp@-
	movew a0@,a0@(8)
	notl a0@(12)
	.short 0x243c,0x0000,0x0166	/* movel #358,d2 */
	lea a0@(16),a2
	moveb a2@-,d7
	lslw #8,d7
	moveb a2@-,d7
	swap d7
	moveb a2@-,d7
	lslw #8,d7
	moveb a2@-,d7
	addl d2,d7
	lea a0@(12),a2
	bsrw Led2
	moveb d2,a0@+
	lsrw #8,d2
	moveb d2,a0@
	moveml sp@+,a0/a2
Lfc4:
	rts
Lfc6:
	moveml a1/a3-a4,sp@-
	lea %pc@(Lfe8),a4
	moveal a4,a3
Lfd0:
	movew a3@+,d0
	beqs Lfe0
	lea a4@(0x2,d0:w),a1
	bsrw L96a
	beqs Lfe2
	bras Lfd0
Lfe0:
	.short 0x70ff	/* moveq #-1,d0 */
Lfe2:
	moveml sp@+,a1/a3-a4
	rts
Lfe8:
	.short 0x001a,0x0022	/* orib #34,a2@+ */
	.short 0x002a,0x0030,0x0038	/* orib #48,a2@(56) */
	.short 0x0040,0x0048	/* oriw #72,d0 */
	.short 0x004e	/* .short 0x004e */
	.short 0x0054,0x005a	/* oriw #90,a4@ */
	.short 0x0062,0x006a	/* oriw #106,a2@- */
	.short 0x0000,0x0404	/* orib #4,d0 */
	bvss L1068
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x0408	/* orib #8,d0 */
	bles L1070
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x040c	/* orib #12,d0 */
	bvss L1085
	.short 0x6300,0x0413	/* blsw 0x142b */
	.short 0x7463	/* moveq #99,d2 */
	bles L108c
	.short 0x0000,0x0414	/* orib #20,d0 */
	.short 0x7469	/* moveq #105,d2 */
	blts L108b
	.short 0x7200	/* moveq #0,d1 */
	.short 0x041b,0x6269	/* subib #105,a3@+ */
	bles L1091
	.short 0x0000,0x041e	/* orib #30,d0 */
	bhis L109d
	.short 0x6f00,0x0420	/* blew 0x1456 */
	bvss L109e
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0424,0x6f64	/* subib #100,a4@- */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x042a,0x6963,0x6e74	/* subib #99,a2@(28276) */
	.short 0x0000,0x042e	/* orib #46,d0 */
	bles L10b1
	bgts L10c4
	.short 0x0000,0x0433	/* orib #51,d0 */
	bccs L10c3
	bsrs L10bb
	.short 0x0000,0x0000	/* orib #0,d0 */
L105c:
	moveml d2-d7/a2-a6,sp@-
	moveal a5@(8),a3
	addal a5,a3
	.byte 0x2a,0x2d
L1068:
	.byte 0x00,0x0c	/* movel a5@(12),d5 */
	beqw L11da
	movel a0,sp@-
L1070:
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7800	/* moveq #0,d4 */
L1074:
	lea a3@(12),a2
	bsrw L214
	tstw d7
	beqs L10c4
	bmis L10c4
	.byte 0x45,0xeb,0x00
L1085:
	.byte 0x0e	/* lea a3@(14),a2 */
	bsrw L214
	.byte 0x02
L108b:
	.byte 0x47
L108c:
	.byte 0x00,0x04	/* andiw #4,d7 */
	beqs L10c4
	.byte 0x52
L1091:
	.byte 0x86	/* addql #1,d6 */
	.short 0x5084	/* addql #8,d4 */
	moveal a3,a2
	bsrw L200
	tstl d7
	.byte 0x67
L109d:
	.byte 0x06	/* beqs 0x10a4 */
L109e:
	.short 0x5084	/* addql #8,d4 */
	.short 0x5284	/* addql #1,d4 */
	bras L10c4
L10a4:
	lea a2@(4),a2
	bsrw L200
	moveal a5,a2
	.byte 0x20,0x2d,0x00
L10b1:
	.byte 0x0c	/* movel a5@(12),d0 */
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	.byte 0xd5
L10bb:
	.byte 0xc0	/* addal d0,a2 */
	addal d7,a2
L10be:
	.short 0x5284	/* addql #1,d4 */
	tstb a2@+
	.byte 0x66
L10c3:
	.byte 0xfa	/* bnes 0x10be */
L10c4:
	tstb a3@(17)
	beqs L10da
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L10da:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L1074
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x5084	/* addql #8,d4 */
	.short 0x0c94,0x00fc,0x2011	/* cmpil #16523281,a4@ */
	bnes L10f4
	.short 0x5084	/* addql #8,d4 */
	.short 0x5884	/* addql #4,d4 */
L10f4:
	.short 0x5084	/* addql #8,d4 */
	movel d4,d0
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	moveal sp@+,a0
	tstl d0
	beqw L11da
	movel a0,sp@-
	moveal d0,a6
	.short 0x2cfc,0x3210,0x2011	/* movel #839917585,a6@+ */
	movel d4,a6@+
	.short 0x0c94,0x00fc,0x2011	/* cmpil #16523281,a4@ */
	bnes L1148
	lea a4@(8),a0
	tstl a0@
	bnes L1132
	movel a0,a0@
	.short 0x5890	/* addql #4,a0@ */
	clrl a0@(4)
	movel a0,a0@(8)
L1132:
	moveal a6,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-246)
	moveal sp@+,a6
	lea a6@(8),a6
	movel sp@+,a6@+
	bras L1150
L1148:
	tstl a4@+
	bnes L1148
	movel a6,a4@-
	.short 0x588f	/* addql #4,sp */
L1150:
	lsll #3,d6
	lea a6@(0x8,d6:w),a4
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
L1160:
	lea a3@(12),a2
	bsrw L214
	tstw d7
	beqs L11bc
	bmis L11bc
	lea a3@(14),a2
	bsrw L214
	.short 0x0247,0x0004	/* andiw #4,d7 */
	beqs L11bc
	movel a4,a6@+
	lea a3@(8),a2
	bsrw L200
	movel d7,a6@+
	moveal a3,a2
	bsrw L200
	tstl d7
	beqs L119e
	.short 0x7007	/* moveq #7,d0 */
	moveb a2@+,a4@+
	.short 0x51c8,0xfffc	/* dbf d0,0x1194 */
	clrb a4@+
	bras L11bc
L119e:
	lea a2@(4),a2
	bsrw L200
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L11b8:
	moveb a2@+,a4@+
	bnes L11b8
L11bc:
	tstb a3@(17)
	beqs L11d2
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L11d2:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L1160
L11da:
	moveml sp@+,d2-d7/a2-a6
	rts
