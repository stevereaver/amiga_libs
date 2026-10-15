	.text
	.byte 0x70,0x00,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x0d,0xb6,0x00,0x03
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x64
L1e:
	bccs L93
	.short 0x7033	/* moveq #51,d0 */
	movew a1@(0x2e,d3:w),d1
	bges L91
	bhis L9c
	bsrs L9e
	.short 0x7900	/* .short 0x7900 */
	moveal a6@,a2
	.short 0x4552	/* .short 0x4552 */
	movew a0@-,d5
L34:
	bccs La9
	.short 0x7033	/* moveq #51,d0 */
	movew a1@(0x2e,d3:w),d1
	bges La7
	bhis Lb2
	bsrs Lb4
	.short 0x7920	/* .short 0x7920 */
	movew a6@(12320),a1@-
	movel a6@(0x36,d2:l:0x8),d4
	movel a2@(0x32,d3:w),d7
	movew a1@(3338),a0@-
	.byte 0x00,0x00
L56:
	.byte 0x64,0x6f	/* orib #111,d0 */
	.short 0x732e	/* .short 0x732e */
	bges Lc5
	bhis Ld0
	bsrs Ld2
	.short 0x7900	/* .short 0x7900 */
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x7f7e	/* .short 0x7f7e */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel a0,d1
	lea %pc@(L138),a0
	subal a1,a1
	lea %pc@(L90),a2
	.short 0x702e	/* moveq #46,d0 */
	jsr a6@(-84)
	tstl d0
	beqs L8a
	moveal d0,a1
	jsr a6@(-396)
	.short 0x7001	/* moveq #1,d0 */
L8a:
	moveml sp@+,d1-d7/a1-a6
	rts
L90:
	.byte 0x48
L91:
	.byte 0xe7,0x00
L93:
	.byte 0x40	/* moveml a1,sp@- */
	moveal a0,a1
	moveal d0,a0
	movel a1,a0@(34)
L9c:
	.byte 0x11,0x7c
L9e:
	.byte 0x00,0x09,0x00,0x08	/* moveb #9,a0@(8) */
	lea %pc@(L1e),a1
	.byte 0x21
La7:
	.byte 0x49,0x00
La9:
	.byte 0x0a	/* movel a1,a0@(10) */
	.short 0x317c,0x0003,0x0014	/* movew #3,a0@(20) */
	.byte 0x42,0x68
Lb2:
	.byte 0x00,0x16	/* clrw a0@(22) */
Lb4:
	lea %pc@(L34),a1
	movel a1,a0@(24)
	clrw a0@(32)
	movel d0,d0
	.byte 0x4c,0xdf,0x02
Lc5:
	.byte 0x00	/* moveml sp@+,a1 */
	rts
	.short 0x7000	/* moveq #0,d0 */
	movel a6,d0
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
Ld0:
	.byte 0x08,0xae
Ld2:
	.byte 0x00,0x03,0x00,0x0e	/* bclr #3,a6@(14) */
	rts
	.short 0x7000	/* moveq #0,d0 */
	tstw a6@(32)
	beqs Lf0
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes Lf0
	btst #3,a6@(14)
	beqs Lf0
	bsrs Lf2
Lf0:
	rts
Lf2:
	.short 0x7000	/* moveq #0,d0 */
	moveml d2/a5-a6,sp@-
	bsrw Lb90
	moveal a6,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	tstw a5@(32)
	beqs L110
	bset #3,a5@(14)
	bras L12e
L110:
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
L12e:
	moveml sp@+,d2/a5-a6
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L138:
	.short 0x0000,0x00c8	/* orib #-56,d0 */
	.short 0x0000,0x00d8	/* orib #-40,d0 */
	.short 0x0000,0x00f2	/* orib #-14,d0 */
	.short 0x0000,0x0134	/* orib #52,d0 */
	.short 0x0000,0x0168	/* orib #104,d0 */
	.short 0x0000,0x01f6	/* orib #-10,d0 */
	.short 0x0000,0x0200	/* orib #0,d0 */
	.short 0x0000,0x0964	/* orib #100,d0 */
	.short 0x0000,0x0adc	/* orib #-36,d0 */
	.short 0x0000,0x0b34	/* orib #52,d0 */
	.short 0x0000,0x0b08	/* orib #8,d0 */
	.short 0xffff	/* .short 0xffff */
	.short 0xffff	/* .short 0xffff */
L168:
	moveml d2-d7/a2-a6,sp@-
	bsrw Lbaa
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L1cc
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movew a0@(2),d1
	beqw L1cc
	movew a0@(16),d2
	lea a0@(0x14,d2:w),a1
L18c:
	lea a1@(36),a2
	bsrw L1d4
	.short 0x0c87,0x0000,0x0020	/* cmpil #32,d7 */
	beqs L1ae
	.short 0x0c87,0x0000,0x0040	/* cmpil #64,d7 */
	beqs L1ae
	.short 0x0c87,0x0000,0x0080	/* cmpil #128,d7 */
	bnew L1d0
L1ae:
	lea a1@(16),a2
	bsrw L1d4
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addl d7,d0
	lea a1@(40),a1
	.short 0x5341	/* subqw #1,d1 */
	bnes L18c
L1c6:
	moveml sp@+,d2-d7/a2-a6
	rts
L1cc:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L1c6
L1d0:
	.short 0x70fe	/* moveq #-2,d0 */
	bras L1c6
L1d4:
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
L1e8:
	movel a2,sp@-
	.short 0x7e00	/* moveq #0,d7 */
	moveb a2@+,d7
	lslw #8,d7
	moveb a2@+,d7
	moveal sp@+,a2
	rts
L1f6:
	movel a3,sp@-
	moveal a1,a3
	bsrs L200
	moveal sp@+,a3
	rts
L200:
	.short 0x514f	/* subqw #8,sp */
	moveml d2-d7/a2-a6,sp@-
	bsrw Lbaa
	.short 0x0c50,0x0166	/* cmpiw #358,a0@ */
	bnew L926
	movel a2,sp@(48)
	moveal a0,a5
	moveal a1,a4
	movel a3,d5
	.short 0x7c00	/* moveq #0,d6 */
	movew a0@(2),d6
	beqw L926
	movel d6,d0
	lsll #3,d0
	movel d0,sp@(44)
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	tstl d0
	beqw L92e
	moveal d0,a6
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a3
	moveml d6/a3-a4/a6,sp@-
L250:
	movel a4,a6@+
	movel d5,a6@+
	moveal a4,a1
	lea a3@(20),a2
	bsrw L1d4
	moveal a5,a0
	addal d7,a0
	lea a3@(16),a2
	bsrw L1d4
	movel d7,d0
	beqs L27e
	.short 0x5687	/* addql #3,d7 */
	.short 0x0247,0xfffc	/* andiw #-4,d7 */
	addal d7,a4
	addl d7,d5
L278:
	moveb a0@+,a1@+
	.short 0x5380	/* subql #1,d0 */
	bnes L278
L27e:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnes L250
	moveml sp@+,d6/a3-a4/a6
	moveml d6/a3/a6,sp@-
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
	beqw L312
L29c:
	lea a3@(12),a2
	bsrw L1e8
	tstw d7
	beqs L2f4
	bmis L2f4
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	lea a3@(8),a2
	bsrw L1d4
	movel d7,d4
	moveml sp@+,d7
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L1d4
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
L2f4:
	tstb a3@(17)
	beqs L30a
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
L30a:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes L29c
L312:
	moveml sp@+,d6/a3/a6
	moveml d6/a4/a6,sp@-
	moveal a6,a4
L31c:
	moveal a4@,a0
	btst #2,a5@(19)
	beqs L328
	.short 0x508c	/* addql #8,a4 */
L328:
	lea a3@(30),a2
	bsrw L1d4
	movel d7,d5
	beqw L8ee
	lea a3@(24),a2
	bsrw L1d4
	tstl d7
	beqw L8ee
	moveal a5,a1
	addal d7,a1
	moveml d6/a3,sp@-
	moveal a5@(8),a3
	addal a5,a3
	.short 0x598f	/* subql #4,sp */
L354:
	moveal a1,a2
	bsrw L1d4
	movel d7,d3
	lea a1@(4),a2
	bsrw L1d4
	.short 0xcefc,0x0012	/* muluw #18,d7 */
	moveal a3,a2
	addal d7,a2
	bsrw Lbc8
	beqw L8de
	movel a2,sp@-
	lea a2@(8),a2
	bsrw L1d4
	movel d7,d4
	moveal sp@+,a2
	movel a2,sp@-
	lea a2@(12),a2
	bsrw L1e8
	moveal sp@+,a2
	tstw d7
	beqw L3ac
	.short 0x0c47,0xffff	/* cmpiw #-1,d7 */
	beqw L432
	.short 0x0c47,0xfffe	/* cmpiw #-2,d7 */
	beqw L432
	tstw d7
	bmiw L942
	bras L40c
L3ac:
	moveml d0-d2/a0-a2,sp@-
	tstb a2@
	bnes L3ce
	lea a2@(4),a2
	bsrw L1d4
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
L3ce:
	movel sp@(96),d0
	beqs L400
	moveal d0,a0
L3d6:
	movel a0@+,d0
	beqs L400
	movel a0,sp@-
	moveal d0,a0
L3de:
	movel a0@,d0
	beqs L3fc
	moveal d0,a1
	bsrw L94e
	lea a0@(8),a0
	bnes L3de
	movel a0@(-4),d4
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d0-d2/a0-a2
	.short 0x7c00	/* moveq #0,d6 */
	bras L432
L3fc:
	moveal sp@+,a0
	bras L3d6
L400:
	moveal a2,a3
	moveml sp@+,d0-d2/a0-a2
	moveal a3,a2
	braw L946
L40c:
	.short 0x5387	/* subql #1,d7 */
	moveml d7,sp@-
	movew a5@(16),d0
	lea a5@(0x14,d0:w),a2
	.short 0xcefc,0x0028	/* muluw #40,d7 */
	lea a2@(0xc,d7:w),a2
	bsrw L1d4
	movel d7,d6
	moveml sp@+,d7
	lsll #3,d7
	movel a6@(0x4,d7:w),d4
L432:
	lea a1@(8),a2
	bsrw L1e8
	.short 0x0c47,0x002c	/* cmpiw #44,d7 */
	beqw L556
	.short 0x0c47,0x002d	/* cmpiw #45,d7 */
	beqw L556
	.short 0x0c47,0x003b	/* cmpiw #59,d7 */
	beqw L556
	.short 0x0c47,0x0038	/* cmpiw #56,d7 */
	beqw L556
	.short 0x0c47,0x0031	/* cmpiw #49,d7 */
	beqw L5dc
	.short 0x0c47,0x002e	/* cmpiw #46,d7 */
	beqw L56a
	.short 0x0c47,0x0039	/* cmpiw #57,d7 */
	beqw L56a
	.short 0x0c47,0x003e	/* cmpiw #62,d7 */
	beqw L56a
	.short 0x0c47,0x0036	/* cmpiw #54,d7 */
	beqw L56a
	.short 0x0c47,0x002f	/* cmpiw #47,d7 */
	beqw L586
	.short 0x0c47,0x003a	/* cmpiw #58,d7 */
	beqw L586
	.short 0x0c47,0x003f	/* cmpiw #63,d7 */
	beqw L586
	.short 0x0c47,0x0037	/* cmpiw #55,d7 */
	beqw L586
	.short 0x0c47,0x003c	/* cmpiw #60,d7 */
	beqw L5a2
	.short 0x0c47,0x003d	/* cmpiw #61,d7 */
	beqw L5bc
	.short 0x0c47,0x0027	/* cmpiw #39,d7 */
	beqw L5f2
	.short 0x0c47,0x0026	/* cmpiw #38,d7 */
	beqw L616
	.short 0x0c47,0x0029	/* cmpiw #41,d7 */
	beqw L658
	.short 0x0c47,0x0028	/* cmpiw #40,d7 */
	beqw L68c
	.short 0x0c47,0x001c	/* cmpiw #28,d7 */
	beqw L6f2
	.short 0x0c47,0x0024	/* cmpiw #36,d7 */
	beqw L6f2
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqw L6f2
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqw L6f2
	.short 0x0c47,0x001d	/* cmpiw #29,d7 */
	beqw L71e
	.short 0x0c47,0x0025	/* cmpiw #37,d7 */
	beqw L71e
	.short 0x0c47,0x001e	/* cmpiw #30,d7 */
	beqw L756
	.short 0x0c47,0x001f	/* cmpiw #31,d7 */
	beqw L778
	.short 0x0c47,0x0022	/* cmpiw #34,d7 */
	beqw L79c
	.short 0x0c47,0x0023	/* cmpiw #35,d7 */
	beqw L83c
	.short 0x0c47,0x002a	/* cmpiw #42,d7 */
	beqw L8de
	.short 0x0c47,0x002b	/* cmpiw #43,d7 */
	beqw L8de
	.short 0x0c47,0x0020	/* cmpiw #32,d7 */
	beqw L8de
	.short 0x0c47,0x0021	/* cmpiw #33,d7 */
	beqw L8de
	.short 0x0c47,0x0032	/* cmpiw #50,d7 */
	beqw L8de
	.short 0x0c47,0x0033	/* cmpiw #51,d7 */
	beqw L8de
	braw L93e
L556:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L8de
L56a:
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
	braw L8de
L586:
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
	braw L8de
L5a2:
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
	braw L8de
L5bc:
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
	braw L8de
L5dc:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	.short 0x0080,0x0000,0x5003	/* oril #20483,d0 */
	movel d0,a0@
	moveal sp@+,a0
	braw L8de
L5f2:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L60e
	moveal sp@+,a0
	braw L94a
L60e:
	movel d0,a0@
	moveal sp@+,a0
	braw L8de
L616:
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
	braw L8de
L658:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	btst #23,d0
	beqs L66c
	.short 0x0080,0xff00,0x0000	/* oril #-16777216,d0 */
L66c:
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L684
	.short 0x0c81,0xff00,0x0000	/* cmpil #-16777216,d1 */
	beqs L684
	.short 0x7000	/* moveq #0,d0 */
L684:
	movel d0,a0@
	moveal sp@+,a0
	braw L8de
L68c:
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
	beqs L6b4
	.short 0x0081,0xff00,0x0000	/* oril #-16777216,d1 */
L6b4:
	subl d6,d1
	addl d4,d1
	movel d1,d2
	.short 0x0282,0xff00,0x0000	/* andil #-16777216,d2 */
	beqs L6d0
	.short 0x0c82,0xff00,0x0000	/* cmpil #-16777216,d2 */
	beqs L6d0
	moveal sp@+,a0
	braw L94a
L6d0:
	.short 0x0280,0xe01f,0x0000	/* andil #-534839296,d0 */
	movel d1,d2
	.short 0x0282,0x0000,0xffff	/* andil #65535,d2 */
	orl d2,d0
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	orl d1,d0
	movel d0,a0@
	moveal sp@+,a0
	braw L8de
L6f2:
	.short 0x7200	/* moveq #0,d1 */
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	.short 0x0c47,0x0034	/* cmpiw #52,d7 */
	beqs L70c
	.short 0x0c47,0x0035	/* cmpiw #53,d7 */
	beqs L70c
	subl d6,d0
	addl d4,d0
L70c:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L94a
	braw L8de
L71e:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L744
	.short 0x0c80,0xffff,0x0000	/* cmpil #-65536,d0 */
	bnes L744
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L744:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L94a
	braw L8de
L756:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L76e
	.short 0x7000	/* moveq #0,d0 */
L76e:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L8de
L778:
	movel a0,sp@-
	addal d3,a0
	.short 0x7000	/* moveq #0,d0 */
	movew a0@,d0
	extl d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	beqs L792
	.short 0x7000	/* moveq #0,d0 */
L792:
	negl d0
	movew d0,a0@
	moveal sp@+,a0
	braw L8de
L79c:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xa000,0x0000	/* andil #-1610612736,d1 */
	.short 0x0c81,0xa000,0x0000	/* cmpil #-1610612736,d1 */
	bnes L7fc
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L7d8
	moveal sp@+,a0
	braw L94a
L7d8:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L7f6:
	moveal sp@+,a0
	braw L8de
L7fc:
	movel d0,d1
	.short 0x0281,0x8000,0x0000	/* andil #-2147483648,d1 */
	.short 0x0c81,0x8000,0x0000	/* cmpil #-2147483648,d1 */
	bnes L7f6
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L82a
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L82a:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L94a
	braw L8de
L83c:
	movel a0,sp@-
	addal d3,a0
	movel a0@,d0
	movel d0,d1
	.short 0x0281,0xe000,0x0000	/* andil #-536870912,d1 */
	.short 0x0c81,0xe000,0x0000	/* cmpil #-536870912,d1 */
	bnes L89c
	movel d0,d1
	.short 0x0281,0x1fe0,0x0000	/* andil #534773760,d1 */
	lsrl #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xff00,0x0000	/* andil #-16777216,d1 */
	beqs L878
	moveal sp@+,a0
	braw L94a
L878:
	movel d0,d1
	.short 0x0281,0x00ff,0x0000	/* andil #16711680,d1 */
	lsll #5,d1
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
	orl d1,d0
	movel a0@,d1
	.short 0x0281,0xe01f,0x0000	/* andil #-534839296,d1 */
	orl d0,d1
	movel d1,a0@
L896:
	moveal sp@+,a0
	braw L8de
L89c:
	movel d0,d1
	.short 0x0281,0x1000,0x0000	/* andil #268435456,d1 */
	.short 0x0c81,0x1000,0x0000	/* cmpil #268435456,d1 */
	bnes L896
	.short 0x5488	/* addql #2,a0 */
	movew a0@,d0
	subl d6,d0
	addl d4,d0
	movel d0,d1
	.short 0x0281,0xffff,0x0000	/* andil #-65536,d1 */
	.short 0x0c81,0xffff,0x0000	/* cmpil #-65536,d1 */
	bnes L8ca
	.short 0x0280,0x0000,0xffff	/* andil #65535,d0 */
L8ca:
	movew d0,a0@
	moveal sp@+,a0
	.short 0x0280,0xffff,0x0000	/* andil #-65536,d0 */
	bnew L94a
	braw L8de
	nop
L8de:
	lea a1@(10),a1
	.short 0x5385	/* subql #1,d5 */
	bnew L354
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
L8ee:
	lea a3@(40),a3
	.short 0x5386	/* subql #1,d6 */
	bnew L31c
	moveml sp@+,d6/a4/a6
	movel sp@(48),d0
	beqs L908
	moveal d0,a4
	bsrw Lc78
L908:
	.short 0x7000	/* moveq #0,d0 */
L90a:
	movel d0,d2
	movel sp@(44),d0
	moveal a6,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	movel d2,d0
	moveal a2,a0
L91e:
	moveml sp@+,d2-d7/a2-a6
	.short 0x504f	/* addqw #8,sp */
	rts
L926:
	.short 0x70ff	/* moveq #-1,d0 */
	bras L91e
	.short 0x70fe	/* moveq #-2,d0 */
	bras L91e
L92e:
	.short 0x70fd	/* moveq #-3,d0 */
	bras L91e
L932:
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d6/a3
	moveml sp@+,d6/a4/a6
	bras L90a
L93e:
	.short 0x70f6	/* moveq #-10,d0 */
	bras L932
L942:
	.short 0x70ec	/* moveq #-20,d0 */
	bras L932
L946:
	.short 0x70eb	/* moveq #-21,d0 */
	bras L932
L94a:
	.short 0x70e2	/* moveq #-30,d0 */
	bras L932
L94e:
	moveml a1-a2,sp@-
L952:
	tstb a2@
	beqs L95c
	cmpmb a1@+,a2@+
	beqs L952
	bras L95e
L95c:
	tstb a1@
L95e:
	moveml sp@+,a1-a2
	rts
	moveml d2-d7/a2-a6,sp@-
	.short 0x2f3c,0xffff,0xfffc	/* movel #-4,sp@- */
	moveal a6,a5
	moveal a0,a4
	moveal a1,a3
	bsrw Lb72
	beqw Lad4
	.short 0x2ebc,0xffff,0xfffd	/* movel #-3,sp@ */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,d7
	beqw Lad4
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	moveal a5@(42),a6
	movel a4,d1
	.short 0x74fe	/* moveq #-2,d2 */
	jsr a6@(-84)
	movel d0,d6
	beqw Lac4
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
	.short 0x2ebc,0xffff,0xfffd	/* movel #-3,sp@ */
	movel d7,d0
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	movel d0,d6
	beqw Lad4
	.short 0x2ebc,0xffff,0xfffb	/* movel #-5,sp@ */
	moveal a5@(42),a6
	movel a4,d1
	.short 0x243c,0x0000,0x03ed	/* movel #1005,d2 */
	jsr a6@(-30)
	movel d0,d5
	beqw Lab6
	movel d0,d1
	movel d6,d2
	movel d7,d3
	jsr a6@(-42)
	cmpl d0,d3
	bnew Lab0
	movel d5,d1
	jsr a6@(-36)
	moveal d6,a0
	movel d7,d0
	bsrw L168
	movel d0,d5
	bpls La32
	movel d0,sp@
	braw Lab6
La32:
	.short 0x2ebc,0xffff,0xfffd	/* movel #-3,sp@ */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x5080	/* addql #8,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqw Lab6
	moveal d0,a1
	.short 0x22fc,0x3210,0x2011	/* movel #839917585,a1@+ */
	movel d5,a1@+
	movel a1,d4
	moveal d6,a0
	moveal a3,a2
	bsrw L1f6
	movel d0,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal d6,a1
	movel d7,d0
	jsr a6@(-210)
	movel sp@+,d0
	beqw La7c
	movel d0,sp@
	braw La9c
La7c:
	moveal d4,a0
	movel d5,d0
	.short 0x223c,0x0000,0x0800	/* movel #2048,d1 */
	.short 0x0c6e,0x0024,0x0014	/* cmpiw #36,a6@(20) */
	blts La92
	jsr a6@(-642)
La92:
	movel d4,d0
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,d2-d7/a2-a6
	rts
La9c:
	.short 0x5184	/* subql #8,d4 */
	moveal d4,a1
	movel a1@(4),d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lad4
Lab0:
	movel d5,d1
	jsr a6@(-36)
Lab6:
	moveal d6,a1
	movel d7,d0
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	bras Lad4
Lac4:
	moveal d7,a1
	.short 0x203c,0x0000,0x0104	/* movel #260,d0 */
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
Lad4:
	movel sp@+,d0
	moveml sp@+,d2-d7/a2-a6
	rts
	movel a0,d0
	beqs Lb06
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	.short 0x0200,0x0003	/* andib #3,d0 */
	bnes Lb06
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lb06
	movel a0@(4),d0
	.short 0x5080	/* addql #8,d0 */
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
Lb06:
	rts
	movel a0,d0
	beqs Lb32
	.short 0x5188	/* subql #8,a0 */
	movel a0,d0
	.short 0x0200,0x0003	/* andib #3,d0 */
	bnes Lb32
	.short 0x0c90,0x3210,0x2011	/* cmpil #839917585,a0@ */
	bnes Lb32
	movel a0@(4),d0
	.short 0x5080	/* addql #8,d0 */
	moveal a0,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
Lb32:
	rts
	moveml a2,sp@-
	movel a0,d0
	beqs Lb6a
	movel a1,d0
	beqs Lb6a
	moveal a1,a2
Lb42:
	movel a0@+,d0
	beqs Lb6a
	movel a0,sp@-
	moveal d0,a0
Lb4a:
	movel a0@,d0
	beqs Lb66
	moveal d0,a1
	bsrw L94e
	lea a0@(8),a0
	bnes Lb4a
	movel a0@(-4),d0
	.short 0x588f	/* addql #4,sp */
	moveml sp@+,a2
	rts
Lb66:
	moveal sp@+,a0
	bras Lb42
Lb6a:
	moveml sp@+,a2
	.short 0x70ff	/* moveq #-1,d0 */
	rts
Lb72:
	tstl a6@(42)
	bnes Lb8e
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x7024	/* moveq #36,d0 */
	lea %pc@(L56),a1
	jsr a6@(-552)
	moveal sp@+,a6
	movel d0,a6@(42)
Lb8e:
	rts
Lb90:
	movel a6@(42),d0
	beqs Lba8
	movel a6,sp@-
	moveal d0,a1
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-414)
	moveal sp@+,a6
	clrl a6@(42)
Lba8:
	rts
Lbaa:
	.short 0x0c68,0x382b,0x000a	/* cmpiw #14379,a0@(10) */
	bnes Lbc6
	movew a0@,a0@(10)
	notl a0@(12)
	.short 0x243c,0x0000,0x0166	/* movel #358,d2 */
	addl d2,a0@(12)
	movew d2,a0@
Lbc6:
	rts
Lbc8:
	moveml a1/a3,sp@-
	lea %pc@(Lbec),a3
Lbd0:
	movel a3@+,d0
	beqs Lbe0
	.short 0x5480	/* addql #2,d0 */
	moveal d0,a1
	bsrw L94e
	beqs Lbe4
	bras Lbd0
Lbe0:
	.short 0x70ff	/* moveq #-1,d0 */
	bras Lbe6
Lbe4:
	.short 0x7000	/* moveq #0,d0 */
Lbe6:
	moveml sp@+,a1/a3
	rts
Lbec:
	.short 0x0000,0x0c20	/* orib #32,d0 */
	.short 0x0000,0x0c28	/* orib #40,d0 */
	.short 0x0000,0x0c30	/* orib #48,d0 */
	.short 0x0000,0x0c36	/* orib #54,d0 */
	.short 0x0000,0x0c3e	/* orib #62,d0 */
	.short 0x0000,0x0c46	/* orib #70,d0 */
	.short 0x0000,0x0c4e	/* orib #78,d0 */
	.short 0x0000,0x0c54	/* orib #84,d0 */
	.short 0x0000,0x0c5a	/* orib #90,d0 */
	.short 0x0000,0x0c60	/* orib #96,d0 */
	.short 0x0000,0x0c68	/* orib #104,d0 */
	.short 0x0000,0x0c70	/* orib #112,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0404,0x6962	/* subib #98,d4 */
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x0408	/* orib #8,d0 */
	bles Lc8e
	.short 0x7566	/* .short 0x7566 */
	.short 0x0000,0x040c	/* orib #12,d0 */
	bvss Lca3
	.short 0x6300,0x0413	/* blsw 0x1049 */
	.short 0x7463	/* moveq #99,d2 */
	bles Lcaa
	.short 0x0000,0x0414	/* orib #20,d0 */
	.short 0x7469	/* moveq #105,d2 */
	blts Lca9
	.short 0x7200	/* moveq #0,d1 */
	.short 0x041b,0x6269	/* subib #105,a3@+ */
	bles Lcaf
	.short 0x0000,0x041e	/* orib #30,d0 */
	bhis Lcbb
	.short 0x6f00,0x0420	/* blew 0x1074 */
	bvss Lcbc
	.short 0x7000	/* moveq #0,d0 */
	.short 0x0424,0x6f64	/* subib #100,a4@- */
	.short 0x7000	/* moveq #0,d0 */
	.short 0x042a,0x6963,0x6e74	/* subib #99,a2@(28276) */
	.short 0x0000,0x042e	/* orib #46,d0 */
	bles Lccf
	bgts Lce2
	.short 0x0000,0x0433	/* orib #51,d0 */
	bccs Lce1
	bsrs Lcd9
	.byte 0x00,0x00
Lc78:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	.short 0x3f3e	/* .short 0x3f3e */
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
	beqw Ldb0
	.short 0x7c00	/* moveq #0,d6 */
	.short 0x7800	/* moveq #0,d4 */
Lc8e:
	lea a3@(12),a2
	bsrw L1e8
	tstw d7
	beqs Lcde
	bmis Lcde
	lea a3@(14),a2
	.byte 0x61,0x00,0xf5
Lca3:
	.byte 0x46	/* bsrw 0x1e8 */
	.short 0x0247,0x0004	/* andiw #4,d7 */
	.byte 0x67
Lca9:
	.byte 0x34	/* beqs 0xcde */
Lcaa:
	.short 0x5286	/* addql #1,d6 */
	.short 0x5084	/* addql #8,d4 */
	.byte 0x24
Lcaf:
	.byte 0x4b	/* moveal a3,a2 */
	bsrw L1d4
	tstl d7
	beqs Lcbe
	.short 0x5084	/* addql #8,d4 */
	.byte 0x52
Lcbb:
	.byte 0x84	/* addql #1,d4 */
Lcbc:
	bras Lcde
Lcbe:
	lea a2@(4),a2
	bsrw L1d4
	moveal a5,a2
	movel a5@(12),d0
	.byte 0xc0,0xfc,0x00
Lccf:
	.byte 0x12	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
Lcd8:
	.byte 0x52
Lcd9:
	.byte 0x84	/* addql #1,d4 */
	tstb a2@+
	bnes Lcd8
Lcde:
	.byte 0x4a,0x2b,0x00
Lce1:
	.byte 0x11	/* tstb a3@(17) */
Lce2:
	beqs Lcf4
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
Lcf4:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes Lc8e
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	movel d4,d0
	.short 0x5080	/* addql #8,d0 */
	.short 0x5080	/* addql #8,d0 */
	.short 0x223c,0x0001,0x0001	/* movel #65537,d1 */
	jsr a6@(-198)
	tstl d0
	beqw Ldb0
	moveal d0,a6
	.short 0x2cfc,0x3210,0x2011	/* movel #839917585,a6@+ */
	movel d4,a6@+
Ld20:
	tstl a4@+
	bnes Ld20
	movel a6,a4@-
	lsll #3,d6
	lea a6@(0x8,d6:w),a4
	moveal a5@(8),a3
	addal a5,a3
	movel a5@(12),d5
Ld36:
	lea a3@(12),a2
	bsrw L1e8
	tstw d7
	beqs Ld92
	bmis Ld92
	lea a3@(14),a2
	bsrw L1e8
	.short 0x0247,0x0004	/* andiw #4,d7 */
	beqs Ld92
	movel a4,a6@+
	lea a3@(8),a2
	bsrw L1d4
	movel d7,a6@+
	moveal a3,a2
	bsrw L1d4
	tstl d7
	beqs Ld74
	.short 0x7007	/* moveq #7,d0 */
	moveb a2@+,a4@+
	.short 0x51c8,0xfffc	/* dbf d0,0xd6a */
	clrb a4@+
	bras Ld92
Ld74:
	lea a2@(4),a2
	bsrw L1d4
	moveal a5,a2
	movel a5@(12),d0
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	addl a5@(8),d0
	addal d0,a2
	addal d7,a2
Ld8e:
	moveb a2@+,a4@+
	bnes Ld8e
Ld92:
	tstb a3@(17)
	beqs Lda8
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@(17),d0
	subl d0,d5
	.short 0xc0fc,0x0012	/* muluw #18,d0 */
	.short 0x47f3,0x0000	/* lea a3@(0,d0:w),a3 */
Lda8:
	lea a3@(18),a3
	.short 0x5385	/* subql #1,d5 */
	bnes Ld36
Ldb0:
	moveml sp@+,d2-d7/a2-a6
	.byte 0x4e,0x75,0x00,0x00	/* rts */
	.data
