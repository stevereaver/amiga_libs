	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x10,0xe2,0x00,0x06
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x9c,0x64,0x73
	.byte 0x70,0x33,0x32,0x31,0x30,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x24,0x56
	.byte 0x45,0x52,0x3a,0x20,0x64,0x73,0x70,0x33,0x32,0x31,0x30,0x2e,0x6c,0x69,0x62,0x72
	.byte 0x61,0x72,0x79,0x20,0x36,0x2e,0x30,0x20,0x28,0x32,0x30,0x2e,0x38,0x2e,0x32,0x30
	.byte 0x32,0x31,0x29,0x0d,0x0a,0x00,0x64,0x6f,0x73,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72
	.byte 0x79,0x00,0x00,0x00,0x44,0x53,0x50,0x43,0x4f,0x4d,0x50,0x41,0x54,0x00,0x00,0x00
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
	.byte 0xc8	/* lea %pc@(0x170),a0 */
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
	.byte 0x4c,0xdf,0x7e
Lc5:
	.byte 0xfe	/* moveml sp@+,d1-d7/a1-a6 */
	rts
Lc8:
	moveml a1,sp@-
	moveal a0,a1
	moveal d0,a0
Ld0:
	.byte 0x21,0x49
Ld2:
	.byte 0x00,0x22	/* movel a1,a0@(34) */
	.short 0x117c,0x0009,0x0008	/* moveb #9,a0@(8) */
	.short 0x43fa,0xff42	/* lea %pc@(0x1e),a1 */
	.byte 0x21,0x49,0x00
Le1:
	.byte 0x0a	/* movel a1,a0@(10) */
	.short 0x317c,0x0006,0x0014	/* movew #6,a0@(20) */
Le8:
	clrw a0@(22)
	.byte 0x43
Led:
	.byte 0xfa,0xff,0x46	/* lea %pc@(0x34),a1 */
	.byte 0x21,0x49
Lf2:
	.byte 0x00
Lf3:
	.byte 0x18	/* movel a1,a0@(24) */
	clrw a0@(32)
	movel d0,d0
	moveml sp@+,a1
	rts
L100:
	.short 0x7000	/* moveq #0,d0 */
	movel a6,d0
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(14)
	rts
	.short 0x7000	/* moveq #0,d0 */
	tstw a6@(32)
	beqs L128
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L128
	btst #3,a6@(14)
	beqs L128
	bsrs L12a
L128:
	rts
L12a:
	.short 0x7000	/* moveq #0,d0 */
	moveml d2/a5-a6,sp@-
	bsrw Le5a
	moveal a6,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	tstw a5@(32)
	beqs L148
	bset #3,a5@(14)
	bras L166
L148:
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
L166:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0xff,0xff,0xff,0x90,0xff,0xa0,0xff,0xba,0xff,0xfc,0x00,0x22,0x00,0xb0,0x00,0xba
	.byte 0x08,0x1e,0x09,0xf2,0x0a,0x86,0x0a,0x32,0x0a,0xc4,0x08,0x2a,0x0c,0xb8,0x0a,0x64
	.short 0xffff	/* .short 0xffff */
L192:
	moveml d2-d7/a2-a6,sp@-
	bsrw Leac
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L1f6
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(2),d1
	beqw L1f6
	movew a0@(16),d2
	lea a0@(0x14,d2:w),a1
L1b6:
	lea a1@(36),a2
	bsrw L1fe
	.short 0x0c87,0x0000,0x0020	/* cmpil #32,d7 */
	beqs L1d8
	.short 0x0c87,0x0000,0x0040	/* cmpil #64,d7 */
	beqs L1d8
	.short 0x0c87,0x0000,0x0080	/* cmpil #128,d7 */
	bnew L1fa
L1d8:
	lea a1@(16),a2
	bsrw L1fe
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addl d7,d0
	lea a1@(40),a1
	.short 0x5341	/* subqw #1,d1 */
	bnes L1b6
L1f0:
	moveml sp@+,d2-d7/a2-a6
	rts
L1f6:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L1f0
L1fa:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L1f0
L1fe:
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
L212:
	movel a2,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	moveal sp@+,a2
	rts
	movel a3,sp@-
	moveal a1,a3
	bsrs L22a
	moveal sp@+,a3
	rts
L22a:
	.short 0x514f	/* subqw #8,sp */
	moveml d2-d7/a2-a6,sp@-
	bsrw Leac
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L950
	movel a2,sp@(48)
	moveal a0,a5
	moveal a1,a4
	movel a3,d5
	.short 0x7c00	/* moveq #0,d6 */
	movew a0@(2),d6
	beqw L950
	movel d6,d0
	lsll #3,d0
	movel d0,sp@(44)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	beqw L958
	moveal d0,a6
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a3
	moveml d6/a3-a4/a6,sp@-
L27a:
	movel a4,a6@+
	movel d5,a6@+
	moveal a4,a1
	lea a3@(20),a2
	bsrw L1fe
	moveal a5,a0
	addal d7,a0
	lea a3@(16),a2
	bsrw L1fe
	movel d7,d0
	beqs L2a8
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addal d7,a4
	addl d7,d5
L2a2:
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	bnes L2a2
L2a8:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnes L27a
	moveml sp@+,d6/a3-a4/a6
	moveml d6/a3/a6,sp@-
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
	beqw L33c
L2c6:
	lea a3@(12),a2
	bsrw L212
	tstw d7
	beqs L31e
	bmis L31e
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	lea a3@(8),a2
	bsrw L1fe
	movel d7,d4
	moveml sp@+,d7
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L1fe
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
L31e:
	tstb a3@(17)
	beqs L334
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L334:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L2c6
L33c:
	moveml sp@+,d6/a3/a6
	moveml d6/a4/a6,sp@-
	moveal a6,a4
L346:
	moveal a4@,a0
	btst #2,a5@(19)
	beqs L352
	.short 0x508c	/* addql #8,a4 */
L352:
	lea a3@(32),a2
	bsrw L212
	movel d7,d5
	beqw L918
	lea a3@(24),a2
	bsrw L1fe
	tstl d7
	beqw L918
	moveal a5,a1
	addal d7,a1
	moveml d6/a3,sp@-
	moveal a5@(8),a3
	addal a5,a3
	.short 0x598f	/* subql #4,sp */
L37e:
	moveal a1,a2
	bsrw L1fe
	movel d7,d3
	lea a1@(4),a2
	bsrw L1fe
	.short 0xcefc,0x0012	/* muluw #18,d7 */
	moveal a3,a2
	addal d7,a2
	bsrw Lf0c
	beqw L908
	movel a2,sp@-
	lea a2@(8),a2
	bsrw L1fe
	movel d7,d4
	moveal sp@+,a2
	movel a2,sp@-
	lea a2@(12),a2
	bsrw L212
	moveal sp@+,a2
	tstw d7
	beqw L3d6
	.short 0x0c47,0xffff	/* cmpiw #-1,d7 */
	beqw L45c
	.short 0x0c47,0xfffe	/* cmpiw #-2,d7 */
	beqw L45c
	tstw d7
	bmiw L96c
	bras L436
L3d6:
	moveml d0-d2/a0-a2,sp@-
	tstb a2@
	bnes L3f8
	lea a2@(4),a2
	bsrw L1fe
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L3f8:
	movel sp@(96),d0
	beqs L42a
	moveal d0,a0
L400:
	movel a0@+,d0
	beqs L42a
	movel a0,sp@-
	moveal d0,a0
L408:
	movel a0@,d0
	beqs L426
	moveal d0,a1
	bsrw L978
	lea a0@(8),a0
	bnes L408
	movel a0@(-4),d4
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d0-d2/a0-a2
	.short 0x7c00	/* moveq #0,d6 */
	bras L45c
L426:
	moveal sp@+,a0
	bras L400
L42a:
	moveal a2,a3
	moveml sp@+,d0-d2/a0-a2
	moveal a3,a2
	braw L970
L436:
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L1fe
	movel d7,d6
	moveml sp@+,d7
	lsll #3,d7
	movel a6@(0x4,d7:w),d4
L45c:
	lea a1@(8),a2
	bsrw L212
	.short 0x0c47,0x002c	/* cmpiw #44,d7 */
	beqw L580
	.short 0x0c47,0x002d	/* cmpiw #45,d7 */
	beqw L580
	.short 0x0c47,0x003b	/* cmpiw #59,d7 */
	beqw L580
	.short 0x0c47,0x0038	/* cmpiw #56,d7 */
	beqw L580
	.short 0x0c47,0x0031	/* cmpiw #49,d7 */
	beqw L606
	.short 0x0c47,0x002e	/* cmpiw #46,d7 */
	beqw L594
	.short 0x0c47,0x0039	/* cmpiw #57,d7 */
	beqw L594
	.short 0x0c47,0x003e	/* cmpiw #62,d7 */
	beqw L594
	.short 0x0c47,0x0036	/* cmpiw #54,d7 */
	beqw L594
	.short 0x0c47,0x002f	/* cmpiw #47,d7 */
	beqw L5b0
	.short 0x0c47,0x003a	/* cmpiw #58,d7 */
	beqw L5b0
	.short 0x0c47,0x003f	/* cmpiw #63,d7 */
	beqw L5b0
	.short 0x0c47,0x0037	/* cmpiw #55,d7 */
	beqw L5b0
	.short 0x0c47,0x003c	/* cmpiw #60,d7 */
	beqw L5cc
	.short 0x0c47,0x003d	/* cmpiw #61,d7 */
	beqw L5e6
	.short 0x0c47,0x0027	/* cmpiw #39,d7 */
	beqw L61c
	.short 0x0c47,0x0026	/* cmpiw #38,d7 */
	beqw L640
	.short 0x0c47,0x0029	/* cmpiw #41,d7 */
	beqw L682
	.short 0x0c47,0x0028	/* cmpiw #40,d7 */
	beqw L6b6
	.short 0x0c47,0x001c	/* cmpiw #28,d7 */
	beqw L71c
	.short 0x0c47,0x0024	/* cmpiw #36,d7 */
	beqw L71c
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqw L71c
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqw L71c
	.short 0x0c47,0x001d	/* cmpiw #29,d7 */
	beqw L748
	.short 0x0c47,0x0025	/* cmpiw #37,d7 */
	beqw L748
	.short 0x0c47,0x001e	/* cmpiw #30,d7 */
	beqw L780
	.short 0x0c47,0x001f	/* cmpiw #31,d7 */
	beqw L7a2
	.short 0x0c47,0x0022	/* cmpiw #34,d7 */
	beqw L7c6
	.short 0x0c47,0x0023	/* cmpiw #35,d7 */
	beqw L866
	.short 0x0c47,0x002a	/* cmpiw #42,d7 */
	beqw L908
	.short 0x0c47,0x002b	/* cmpiw #43,d7 */
	beqw L908
	.short 0x0c47,0x0020	/* cmpiw #32,d7 */
	beqw L908
	.short 0x0c47,0x0021	/* cmpiw #33,d7 */
	beqw L908
	.short 0x0c47,0x0032	/* cmpiw #50,d7 */
	beqw L908
	.short 0x0c47,0x0033	/* cmpiw #51,d7 */
	beqw L908
	braw L968
L580:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L908
L594:
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
	braw L908
L5b0:
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
	braw L908
L5cc:
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
	braw L908
L5e6:
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
	braw L908
L606:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	.short 0x0080,0x0000,0x5003	/* oril #20483,d0 */
	movel d0,a0@
	moveal sp@+,a0
	braw L908
L61c:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L638
	moveal sp@+,a0
	braw L974
L638:
	movel d0,a0@
	moveal sp@+,a0
	braw L908
L640:
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
	braw L908
L682:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	btst #23,d0
	beqs L696
	.short 0x0080,0xff00,0x0000	/* oril #-16777216,d0 */
L696:
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L6ae
	.short 0x0c81,0xff00,0x0000	/* cmpil #-16777216,d1 */
	beqs L6ae
	.short 0x7000	/* moveq #0,d0 */
L6ae:
	movel d0,a0@
	moveal sp@+,a0
	braw L908
L6b6:
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
	beqs L6de
	.short 0x0081,0xff00,0x0000	/* oril #-16777216,d1 */
L6de:
	subl d6,d1
	addl d4,d1
	movel d1,d2
	.short 0x0282,0xff00,0x0000	/* andil #-16777216,d2 */
	beqs L6fa
	.short 0x0c82,0xff00,0x0000	/* cmpil #-16777216,d2 */
	beqs L6fa
	moveal sp@+,a0
	braw L974
L6fa:
	.short 0x0280,0xe01f,0x0000	/* andil #-534839296,d0 */
	movel d1,d2
	.short 0x0282,0x0000,0xffff	/* andil #65535,d2 */
	orl d2,d0
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	orl d1,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L908
L71c:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqs L736
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqs L736
	subl d6,d0
	addl d4,d0
L736:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L974
	braw L908
L748:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L76e
	.short 0x0c80,0xffff,0x0000	/* cmpil #-65536,d0 */
	bnes L76e
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L76e:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L974
	braw L908
L780:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L798
	.short 0x7000	/* moveq #0,d0 */
L798:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L908
L7a2:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L7bc
	.short 0x7000	/* moveq #0,d0 */
L7bc:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L908
L7c6:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xa000,0x0000	/* andil #-1610612736,d1 */
	.short 0x0c81,0xa000,0x0000	/* cmpil #-1610612736,d1 */
	bnes L826
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L802
	moveal sp@+,a0
	braw L974
L802:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L820:
	moveal sp@+,a0
	braw L908
L826:
	movel d0,d1
	.short 0x0281,0x8000,0x0000	/* andil #-2147483648,d1 */
	.short 0x0c81,0x8000,0x0000	/* cmpil #-2147483648,d1 */
	bnes L820
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L854
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L854:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L974
	braw L908
L866:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xe000,0x0000	/* andil #-536870912,d1 */
	.short 0x0c81,0xe000,0x0000	/* cmpil #-536870912,d1 */
	bnes L8c6
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L8a2
	moveal sp@+,a0
	braw L974
L8a2:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L8c0:
	moveal sp@+,a0
	braw L908
L8c6:
	movel d0,d1
	.short 0x0281,0x1000,0x0000	/* andil #268435456,d1 */
	.short 0x0c81,0x1000,0x0000	/* cmpil #268435456,d1 */
	bnes L8c0
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L8f4
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L8f4:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L974
	braw L908
	nop
L908:
	lea a1@(10),a1
	.short 0x5385	/* subql #1,d5 */
	bnew L37e
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
L918:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnew L346
	moveml sp@+,d6/a4/a6
	movel sp@(48),d0
	beqs L932
	moveal d0,a4
	bsrw Lfa4
L932:
	.short 0x7000	/* moveq #0,d0 */
L934:
	movel d0,d2
	movel sp@(44),d0
	moveal a6,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	movel d2,d0
	moveal a2,a0
L948:
	moveml sp@+,d2-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L950:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L948
	.short 0x70fd	/* moveq #-3,d0 */
	bras L948
L958:
	.short 0x70fb	/* moveq #-5,d0 */
	bras L948
L95c:
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
	moveml sp@+,d6/a4/a6
	bras L934
L968:
	.short 0x70f5	/* moveq #-11,d0 */
	bras L95c
L96c:
	.short 0x70eb	/* moveq #-21,d0 */
	bras L95c
L970:
	.short 0x70e9	/* moveq #-23,d0 */
	bras L95c
L974:
	.short 0x70e1	/* moveq #-31,d0 */
	bras L95c
L978:
	moveml a1-a2,sp@-
L97c:
	tstb a2@
	beqs L986
	cmpmb a1@+,a2@+
	beqs L97c
	bras L988
L986:
	tstb a1@
L988:
	moveml sp@+,a1-a2
	rts
	moveml d2-d7/a2-a6,sp@-
	.short 0x283c,0x0001,0x0001	/* movel #65537,d4 */
	bras L9a4
	moveml d2-d7/a2-a6,sp@-
	.short 0x283c,0x0001,0x0003	/* movel #65539,d4 */
L9a4:
	.short 0x2f3c,0xffff,0xfff9	/* movel #-7,sp@- */
	moveal a6,a5
	moveal a0,a4
	moveal a1,a3
	bsrw Le3c
	beqw Lb5a
	btst #1,d4
	bnes L9cc
	bsrw Le74
	tstb a6@(43)
	beqs L9cc
	.short 0x0004,0x0002	/* orib #2,d4 */
L9cc:
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,d7
	beqw Lb5a
	.short 0x2ebc,0xffff,0xfff7	/* movel #-9,sp@ */
	moveal a5@(38),a6
	movel a4,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d6
	beqw Lb4a
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
	beqw Lb5a
	.short 0x2ebc,0xffff,0xfff7	/* movel #-9,sp@ */
	moveal a5@(38),a6
	movel a4,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	movel d0,d5
	beqw Lb3c
	movel d0,d1
	movel d6,d2
	movel d7,d3
	jsr a6@(-42)
	cmpl d0,d3
	bnew Lb36
	movel d5,d1
	jsr a6@(-36)
	moveal d6,a0
	movel d7,d0
	bsrw L192
	movel d0,d5
	bpls La82
	movel d0,sp@
	braw Lb3c
La82:
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	.short 0x5080	/* addql #8,d0 */
	movel a2,d1
	beqs La9e
	moveal a2@(38),a6
	moveal a2,a0
	movel d0,d1
	movel d4,d2
	jsr a6@(-54)
	bras Laa8
La9e:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d4,d1
	jsr a6@(-198)
Laa8:
	tstl d0
	beqw Lb3c
	moveal d0,a1
	.short 0x22fc,0x3210,0x2011	/* movel #839917585,a1@+ */
	movel d5,a1@+
	movel a1,d4
	movel a3,sp@-
	moveal a1,a3
	movel a2,d0
	beqs Lae0
	moveml a1-a2,sp@-
	moveal a2@(38),a6
	moveal a2,a0
	.short 0x598f	/* subql #4,sp */
	moveal sp,a2
	jsr a6@(-42)
	moveal sp@+,a3
	moveml sp@+,a1-a2
	tstl d0
	beqs Lae0
	moveal a1,a3
Lae0:
	moveal d6,a0
	moveal sp@+,a2
	bsrw L22a
	movel d0,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal d6,a1
	movel d7,d0
	jsr a6@(-210)
	movel sp@+,d0
	beqw Lb02
	movel d0,sp@
	braw Lb22
Lb02:
	moveal d4,a0
	movel d5,d0
	.short 0x223c,0x0000,0x0800	/* movel #2048,d1 */
	.short 0x0c6e,0x0024,0x0014	/* cmpiw #36,a6@(20) */
	blts Lb18
	jsr a6@(-642)
Lb18:
	movel d4,d0
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
Lb22:
	.short 0x5184	/* subql #8,d4 */
	moveal d4,a1
	movel a1@(4),d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lb5a
Lb36:
	movel d5,d1
	jsr a6@(-36)
Lb3c:
	moveal d6,a1
	movel d7,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lb5a
Lb4a:
	moveal d7,a1
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
Lb5a:
	movel sp@+,d0
	moveml sp@+,d2-d7/a2-a6
	rts
	movel a0,d0
	beqs Lba0
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	.short 0x0200,0x0003	/* andib #3,d0 */
	bnes Lba0
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lba0
	movel a1,d1
	beqs Lb8c
	movel a6,sp@-
	moveal a1@(38),a6
	exg a0,a1
	jsr a6@(-60)
	moveal sp@+,a6
	bras Lba0
Lb8c:
	movel a0@(4),d0
	.short 0x5080	/* addql #8,d0 */
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
Lba0:
	rts
Lba2:
	clrl sp@-
	movel a0,d0
	beqs Lbd0
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	btst #0,d0
	bnes Lbd0
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lbd0
	movel a0@(4),d0
	.short 0x5080	/* addql #8,d0 */
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	notl sp@
Lbd0:
	movel sp@+,d0
	rts
	movel a0,d0
	beqs Lbf4
	btst #0,d0
	bnes Lbf4
Lbde:
	tstl a0@
	beqs Lbf4
	movel a0,sp@-
	moveal a0@,a0
	bsrs Lba2
	moveal sp@+,a0
	tstl d0
	beqs Lbf0
	clrl a0@
Lbf0:
	.short 0x5888	/* addql #4,a0 */
	bras Lbde
Lbf4:
	rts
	moveml a2,sp@-
	movel a0,d0
	beqs Lc2c
	movel a1,d0
	beqs Lc2c
	moveal a1,a2
Lc04:
	movel a0@+,d0
	beqs Lc2c
	movel a0,sp@-
	moveal d0,a0
Lc0c:
	movel a0@,d0
	beqs Lc28
	moveal d0,a1
	bsrw L978
	lea a0@(8),a0
	bnes Lc0c
	movel a0@(-4),d0
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,a2
	rts
Lc28:
	moveal sp@+,a0
	bras Lc04
Lc2c:
	moveml sp@+,a2
	.short 0x7000	/* moveq #0,d0 */
	rts
	moveml d2-d7/a2-a6,sp@-
	bsrw Leac
	bsrw Leca
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	beqs Lc52
	.short 0x7c01	/* moveq #1,d6 */
	.short 0x0c50,0x6601	/* cmpiw #26113,a0@ */
	bnew Le00
Lc52:
	moveal a0,a2
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	bsrw L212
	movew d7,d0
	bsrw Le08
	tstl d6
	beqs Lc6e
	movew a2@,d0
Lc6e:
	.short 0x548a	/* addql #2,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	moveal d7,a4
	bsrw Le14
	tstl d6
	beqs Lc8a
	moveal a2@,a4
Lc8a:
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	movel d7,d4
	bsrw Le14
	tstl d6
	beqs Lc9c
	movel a2@,d4
Lc9c:
	.short 0x588a	/* addql #4,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(16),d1
	tstl d6
	bnes Lcbe
	rorw #8,d1
Lcbe:
	addal d1,a2
	tstw d0
	beqw Ld8a
	.short 0x7203	/* moveq #3,d1 */
	tstl d6
	bnes Lcce
	.short 0x7200	/* moveq #0,d1 */
Lcce:
	.short 0x4a32,0x1000	/* tstb a2@(0,d1:w) */
	beqs Lcd8
	.short 0x508a	/* addql #8,a2 */
	bras Lce4
Lcd8:
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
Lce4:
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	moveal d7,a5
	bsrw Le14
	tstl d6
	beqs Ld20
	bsrw L1fe
	moveal d7,a5
Ld20:
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L212
	movew d7,d5
	bsrw Le08
	tstl d6
	beqs Ld3c
	rorw #8,d5
Ld3c:
	.short 0x548a	/* addql #2,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	.short 0xdb78,0x0180	/* addw d5,0x180 */
	tstw d5
	beqs Ld84
	movel a2,sp@-
	moveal a0,a2
	addal a5,a2
Ld60:
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	.short 0x5345	/* subqw #1,d5 */
	bnes Ld60
	moveal sp@+,a2
Ld84:
	.short 0x5340	/* subqw #1,d0 */
	bnew Lcce
Ld8a:
	.short 0x7203	/* moveq #3,d1 */
	tstl d6
	bnes Ld92
	.short 0x7200	/* moveq #0,d1 */
Ld92:
	movel d4,sp@-
	tstl d4
	beqs Lde4
	moveal a0,a2
	addal a4,a2
Ld9c:
	.short 0x4a32,0x1000	/* tstb a2@(0,d1:w) */
	beqs Lda6
	.short 0x508a	/* addql #8,a2 */
	bras Ldb2
Lda6:
	.short 0x588a	/* addql #4,a2 */
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
Ldb2:
	bsrw L1fe
	bsrw Le14
	.short 0x588a	/* addql #4,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	bsrw L212
	bsrw Le08
	.short 0x548a	/* addql #2,a2 */
	.short 0x528a	/* addql #1,a2 */
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@+,d0
	beqs Lde0
	subl d0,d4
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addal d0,a2
Lde0:
	.short 0x5384	/* subql #1,d4 */
	bnes Ld9c
Lde4:
	movel sp@+,d4
	.short 0xc8fc,0x0012	/* muluw #18,d4 */
	moveal a4,a2
	addal d4,a2
	addal a0,a2
	bsrw L1fe
	bsrw Le14
	.short 0x7000	/* moveq #0,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Le00:
	.short 0x70ff	/* moveq #-1,d0 */
	moveml sp@+,d2-d7/a2-a6
	rts
Le08:
	movel a2,sp@-
	moveb d7,a2@+
	lsrw #8,d7
	moveb d7,a2@+
	moveal sp@+,a2
	rts
Le14:
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
	bsrs Le74
	.short 0x7000	/* moveq #0,d0 */
	tstb a6@(43)
	sne d0
	moveml sp@+,d1-a6
	rts
Le3c:
	tstl a6@(38)
	bnes Le58
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x7024	/* moveq #36,d0 */
	.short 0x43fa,0xf20a	/* lea %pc@(0x56),a1 */
	jsr a6@(-552)
	moveal sp@+,a6
	movel d0,a6@(38)
Le58:
	rts
Le5a:
	movel a6@(38),d0
	beqs Le72
	movel a6,sp@-
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal sp@+,a6
	clrl a6@(38)
Le72:
	rts
Le74:
	tstb a6@(42)
	bnes Leaa
	bsrs Le3c
	movel a6,sp@-
	moveal a6@(38),a6
	.short 0x41fa,0xf1e0	/* lea %pc@(0x64),a0 */
	movel a0,d1
	.short 0x9efc,0x0010	/* subaw #16,sp */
	movel sp,d2
	.short 0x7610	/* moveq #16,d3 */
	.short 0x283c,0x0000,0x0100	/* movel #256,d4 */
	jsr a6@(-906)
	.short 0xdefc,0x0010	/* addaw #16,sp */
	moveal sp@+,a6
	st a6@(42)
	tstl d0
	spl a6@(43)
Leaa:
	rts
Leac:
	.short 0x0c68,0x382b,0x000a	/* cmpiw #14379,a0@(10) */
	bnes Lec8
	movew a0@,a0@(10)
	notl a0@(12)
	.short 0x243c,0x0000,0x0166	/* movel #358,d2 */
	addl d2,a0@(12)
	movew d2,a0@
Lec8:
	rts
Leca:
	.short 0x0c68,0x2b38,0x0008	/* cmpiw #11064,a0@(8) */
	bnes Lf0a
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
	bsrw Le14
	moveb d2,a0@+
	lsrw #8,d2
	moveb d2,a0@
	moveml sp@+,a0/a2
Lf0a:
	rts
Lf0c:
	moveml a1/a3-a4,sp@-
	lea %pc@(Lf32),a4
	moveal a4,a3
Lf16:
	movew a3@+,d0
	beqs Lf26
	lea a4@(0x2,d0:w),a1
	bsrw L978
	beqs Lf2a
	bras Lf16
Lf26:
	.short 0x70ff	/* moveq #-1,d0 */
	bras Lf2c
Lf2a:
	.short 0x7000	/* moveq #0,d0 */
Lf2c:
	moveml sp@+,a1/a3-a4
	rts
Lf32:
	.short 0x001a,0x0022	/* orib #34,a2@+ */
	.short 0x002a,0x0030,0x0038	/* orib #48,a2@(56) */
	.short 0x0040,0x0048	/* oriw #72,d0 */
	.short 0x004e	/* .short 0x004e */
	.short 0x0054,0x005a	/* oriw #90,a4@ */
	.short 0x0062,0x006a	/* oriw #106,a2@- */
	.short 0x0000,0x0404	/* orib #4,d0 */
	bvss Lfb2
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x0408	/* orib #8,d0 */
	bles Lfba
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x040c	/* orib #12,d0 */
	bvss Lfcf
	.short 0x6300,0x0413	/* blsw 0x1375 */
	.short 0x7463	/* moveq #99,d2 */
	bles Lfd6
	.short 0x0000,0x0414	/* orib #20,d0 */
	.short 0x7469	/* moveq #105,d2 */
	blts Lfd5
	.short 0x7200	/* moveq #0,d1 */
	.short 0x041b,0x6269	/* subib #105,a3@+ */
	bles Lfdb
	.short 0x0000,0x041e	/* orib #30,d0 */
	bhis Lfe7
	.short 0x6f00,0x0420	/* blew 0x13a0 */
	bvss Lfe8
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0424,0x6f64	/* subib #100,a4@- */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x042a,0x6963,0x6e74	/* subib #99,a2@(28276) */
	.short 0x0000,0x042e	/* orib #46,d0 */
	bles Lffb
	bgts L100e
	.short 0x0000,0x0433	/* orib #51,d0 */
	bccs L100d
	bsrs L1005
	.byte 0x00,0x00
Lfa4:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	.short 0x3f3e	/* .short 0x3f3e */
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
Lfb2:
	beqw L10dc
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7800	/* moveq #0,d4 */
Lfba:
	lea a3@(12),a2
	bsrw L212
	tstw d7
	beqs L100a
	bmis L100a
	lea a3@(14),a2
	.byte 0x61,0x00,0xf2
Lfcf:
	.byte 0x44	/* bsrw 0x212 */
	.short 0x0247,0x0004	/* andiw #4,d7 */
	.byte 0x67
Lfd5:
	.byte 0x34	/* beqs 0x100a */
Lfd6:
	.short 0x5286	/* addql #1,d6 */
	.short 0x5084	/* addql #8,d4 */
	.byte 0x24
Lfdb:
	.byte 0x4b	/* moveal a3,a2 */
	bsrw L1fe
	tstl d7
	beqs Lfea
	.short 0x5084	/* addql #8,d4 */
	.byte 0x52
Lfe7:
	.byte 0x84	/* addql #1,d4 */
Lfe8:
	bras L100a
Lfea:
	lea a2@(4),a2
	bsrw L1fe
	moveal a5,a2
	movel a5@(12),d0
	.byte 0xc0,0xfc,0x00
Lffb:
	.byte 0x12	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L1004:
	.byte 0x52
L1005:
	.byte 0x84	/* addql #1,d4 */
	tstb a2@+
	bnes L1004
L100a:
	.byte 0x4a,0x2b,0x00
L100d:
	.byte 0x11	/* tstb a3@(17) */
L100e:
	beqs L1020
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L1020:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes Lfba
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d4,d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x5080	/* addql #8,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqw L10dc
	moveal d0,a6
	.short 0x2cfc,0x3210,0x2011	/* movel #839917585,a6@+ */
	movel d4,a6@+
L104c:
	tstl a4@+
	bnes L104c
	movel a6,a4@-
	lsll #3,d6
	lea a6@(0x8,d6:w),a4
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
L1062:
	lea a3@(12),a2
	bsrw L212
	tstw d7
	beqs L10be
	bmis L10be
	lea a3@(14),a2
	bsrw L212
	.short 0x0247,0x0004	/* andiw #4,d7 */
	beqs L10be
	movel a4,a6@+
	lea a3@(8),a2
	bsrw L1fe
	movel d7,a6@+
	moveal a3,a2
	bsrw L1fe
	tstl d7
	beqs L10a0
	.short 0x7007	/* moveq #7,d0 */
	moveb a2@+,a4@+
	.short 0x51c8,0xfffc	/* dbf d0,0x1096 */
	clrb a4@+
	bras L10be
L10a0:
	lea a2@(4),a2
	bsrw L1fe
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L10ba:
	moveb a2@+,a4@+
	bnes L10ba
L10be:
	tstb a3@(17)
	beqs L10d4
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L10d4:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L1062
L10dc:
	moveml sp@+,d2-d7/a2-a6
	.byte 0x4e,0x75,0x00,0x00	/* rts */
