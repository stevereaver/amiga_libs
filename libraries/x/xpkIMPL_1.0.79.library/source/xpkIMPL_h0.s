	.text
	.byte 0x70,0xff,0x4e,0x75,0x4a,0xfc,0x00,0x00,0x00,0x04,0x00,0x00,0x04,0x98,0x80,0x01
	.byte 0x09,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x35,0x00,0x00,0x00,0x5c,0x78,0x70
	.byte 0x6b,0x49,0x4d,0x50,0x4c,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79,0x00,0x00,0x24
	.byte 0x56,0x45,0x52,0x3a,0x20,0x78,0x70,0x6b,0x49,0x4d,0x50,0x4c,0x20,0x31,0x2e,0x30
	.byte 0x2e,0x37,0x39,0x20,0x28,0x30,0x32,0x2d,0x4e,0x6f,0x76,0x2d,0x39,0x32,0x20,0x30
	.byte 0x31,0x3a,0x32,0x34,0x3a,0x31,0x38,0x29,0x0d,0x0a,0x00,0x00,0x00,0x00,0x00,0x28
	.byte 0x00,0x00,0x00,0x6c,0x00,0x00,0x00,0xbc,0x00,0x00,0x00,0xe8,0x00,0x00,0x00,0xf6
	.byte 0x00,0x00,0x01,0x04,0x00,0x00,0x01,0x1a,0x00,0x00,0x02,0x48,0x00,0x00,0x01,0x56
	.byte 0x00,0x00,0x01,0x5e,0x00,0x00,0x02,0x4a,0x00,0x00,0x02,0x48,0x00,0x00,0x02,0x24
	.byte 0x00,0x00,0x02,0x4a,0x00,0x00,0x02,0x4a,0x00,0x00,0x02,0x4a,0x00,0x00,0x02,0x4a
	.byte 0x00,0x00,0x02,0x4a,0x00,0x00,0x02,0x4a,0x00,0x00,0x04,0x98,0x00,0x00,0x0d,0x9c
	.byte 0x00,0x00,0x04,0xa2,0x00,0x00,0x0d,0x5c,0xff,0xff,0xff,0xff,0xe0,0x00,0x00,0x08
	.byte 0x09,0x00,0xc0,0x00,0x00,0x0a,0x00,0x00,0x00,0x1e,0xe0,0x00,0x00,0x0e,0x06,0x00
	.byte 0xd0,0x00,0x00,0x14,0x00,0x01,0xd0,0x00,0x00,0x16,0x00,0x00,0xc0,0x00,0x00,0x18
	.byte 0x00,0x00,0x00,0x35,0x00,0x00,0x00,0x00
	movel a5,sp@-
	moveal d0,a5
	movel a0,a5@(36)
	movel a5,d0
	moveal sp@+,a5
	rts
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(34)
	movel a6,d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L116
	btst #3,a6@(34)
	beqs L116
	bsrs L11a
L116:
	tstl d0
	rts
L11a:
	moveml d2/a5-a6,sp@-
	moveal a6,a5
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	.short 0x7000	/* moveq #0,d0 */
	bset #3,a5@(34)
	tstw a5@(32)
	bnes L14e
	movel a5@(36),d2
	moveal a5,a1
	jsr a6@(-252)
	moveal a5,a1
	movew a5@(16),d0
	subaw d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
L14e:
	moveml sp@+,d2/a5-a6
	tstl d0
	rts
	lea %pc@(L270),a0
	movel a0,d0
	rts
	moveml a4/a6,sp@-
	moveal a0,a4
	bsrw L1ee
	movel a4@(28),d0
	.short 0xb07c,0x0064	/* cmpw #100,d0 */
	beqs L1a4
	movel a4@(4),d0
	lea %pc@(L468),a0
	.short 0x720b	/* moveq #11,d1 */
L17c:
	cmpl a0@+,d0
	bhis L184
	.short 0x5381	/* subql #1,d1 */
	bnes L17c
L184:
	movel d2,sp@-
	movel a4@(28),d0
	.short 0x5280	/* addql #1,d0 */
	.short 0x7400	/* moveq #0,d2 */
	.short 0x82fc,0x0064	/* divuw #100,d1 */
	movel d1,d2
	swap d2
	.short 0xc2c0	/* muluw d0,d1 */
	.short 0xc4c0	/* muluw d0,d2 */
	.short 0x84fc,0x0064	/* divuw #100,d2 */
	addw d2,d1
	movel sp@+,d2
	bras L1b6
L1a4:
	movel a4@(4),d0
	lea %pc@(L438),a0
	.short 0x720b	/* moveq #11,d1 */
L1ae:
	cmpl a0@+,d0
	bccs L1b6
	.short 0x5381	/* subql #1,d1 */
	bnes L1ae
L1b6:
	movel a4@(4),d0
	.short 0xb0bc,0x0000,0x0800	/* cmpl #2048,d0 */
	blss L1c8
	.short 0x0081,0x8000,0x0000	/* oril #-2147483648,d1 */
L1c8:
	moveal a4@(8),a0
	lea %pc@(L24c),a1
	bsrw L4a2
	beqs L1e0
	bmis L1e4
	movel d0,a4@(16)
	.short 0x7000	/* moveq #0,d0 */
	bras L1e6
L1e0:
	.short 0x70ef	/* moveq #-17,d0 */
	bras L1e6
L1e4:
	.short 0x70ed	/* moveq #-19,d0 */
L1e6:
	moveml sp@+,a4/a6
	tstl d0
	rts
L1ee:
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	moveal a4@,a0
	moveal a4@(8),a1
	movel a4@(4),d0
	.short 0x0240,0xfffc	/* andiw #-4,d0 */
	jsr a6@(-630)
	moveal a4@,a0
	moveal a4@(8),a1
	movel a4@(4),d0
	movel d0,d1
	addal d0,a0
	addal d0,a1
	.short 0x0241,0xfffc	/* andiw #-4,d1 */
	subl d1,d0
	beqs L222
L21c:
	moveb a0@-,a1@-
	.short 0x5340	/* subqw #1,d0 */
	bnes L21c
L222:
	rts
	moveml a4/a6,sp@-
	moveal a0,a4
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	bsrs L1ee
	moveal a4@(8),a0
	bsrw Ld5c
	beqs L23e
	.short 0x7000	/* moveq #0,d0 */
	bras L240
L23e:
	.short 0x70f2	/* moveq #-14,d0 */
L240:
	moveml sp@+,a4/a6
	tstl d0
	rts
	.short 0x7000	/* moveq #0,d0 */
	rts
L24c:
	.short 0x0240,0x0007	/* andiw #7,d0 */
	bnes L268
	.short 0x7200	/* moveq #0,d1 */
	.short 0x7000	/* moveq #0,d0 */
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-306)
	moveal sp@+,a6
	.short 0x720c	/* moveq #12,d1 */
	btst d1,d0
	bnes L26c
L268:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
L26c:
	.short 0x7000	/* moveq #0,d0 */
	rts
L270:
	.short 0x0001,0x0001	/* orib #1,d1 */
	.short 0x0001,0x0000	/* orib #0,d1 */
	.short 0x0000,0x02c8	/* orib #-56,d0 */
	.short 0x0000,0x02cd	/* orib #-51,d0 */
	.short 0x0000,0x02df	/* orib #-33,d0 */
	.short 0x494d	/* .short 0x494d */
	.short 0x504c	/* addqw #8,a4 */
	.short 0x0000,0x8009	/* orib #9,d0 */
	.short 0x0008	/* .short 0x0008 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0040,0x0001	/* oriw #1,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	btst d1,a6@
	.short 0x0000,0x0329	/* orib #41,d0 */
	.short 0x0000,0x0320	/* orib #32,d0 */
	.short 0x0000,0x0333	/* orib #51,d0 */
	.short 0x0064,0x0000	/* oriw #0,a4@- */
	.byte 0x00,0x00,0x03,0x3c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	/* orib #60,d0 */
	.short 0x494d	/* .short 0x494d */
	.short 0x504c	/* addqw #8,a4 */
	.short 0x0054,0x7572	/* oriw #30066,a4@ */
	bhis L341
	moveal a1,a0
	blts L346
	bges L347
	bccs L33f
	movel a1@(0x30,d2:l:0x8),d0
	.short 0x0041,0x2077	/* oriw #8311,d1 */
	bcss L350
	bges L313
	bmis L356
	bles L361
	bgts L30c
	blss L35d
	blts L360
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7373	/* .short 0x7373 */
	bles L368
	.byte 0x20,0x77,0x69,0x74,0x68,0x20,0x64,0x79	/* moveal sp@(68206479)@(0),a0 */
	bgts L361
	blts L36b
	blss L324
	blss L375
	blts L378
	.short 0x7265	/* moveq #101,d1 */
	.short 0x7373	/* .short 0x7373 */
L30c:
	bvss L37d
	bgts L330
	blts L381
	.byte 0x64
L313:
	.byte 0x65	/* bccs 0x379 */
	.short 0x7300	/* .short 0x7300 */
	.short 0x496d	/* .short 0x496d */
	.short 0x706c	/* moveq #108,d0 */
	bles L380
	bvss L38c
	.short 0x6700,0x496d	/* beqw 0x4c8d */
	.short 0x706c	/* moveq #108,d0 */
L324:
	bles L38a
	bcss L38c
	.short 0x0045,0x7870	/* oriw #30832,d5 */
	bges L39d
	bccs L399
L330:
	bgts L399
	.short 0x0045,0x7870	/* oriw #30832,d5 */
	bges L3a7
	bccs L39f
	.byte 0x64,0x00
L33c:
	.byte 0x00,0x00	/* bccw 0x33c */
	.byte 0x03
L33f:
	.byte 0x66	/* bchg d1,a6@- */
	.byte 0x00
L341:
	.byte 0x00,0x00,0x0a	/* orib #10,d0 */
	.byte 0x00,0x00
L346:
	.byte 0x00
L347:
	.byte 0x01	/* orib #1,d0 */
	.short 0x0004,0x93e0	/* orib #-32,d4 */
	.short 0x0000,0x0000	/* orib #0,d0 */
L350:
	.short 0x0000,0x0019	/* orib #25,d0 */
	.byte 0x00,0x00
L356:
	.byte 0x01,0x54	/* orib #84,d0 */
	bchg d0,a4@+
	.byte 0x00,0x00,0x30
L35d:
	.byte 0x2e	/* orib #46,d0 */
	.byte 0x31,0x2a
L360:
	.byte 0x6d
L361:
	.byte 0x61	/* movew a2@(28001),a0@- */
	.short 0x7820	/* moveq #32,d4 */
	movel d0,d0
	.byte 0x00,0x00
L368:
	.byte 0x03,0x90	/* orib #-112,d0 */
	.byte 0x00
L36b:
	.byte 0x00,0x00,0x1e	/* orib #30,d0 */
	.short 0x0000,0x0001	/* orib #1,d0 */
	.byte 0x00,0x05,0x57
L375:
	.byte 0x30	/* orib #48,d5 */
	.byte 0x00,0x00
L378:
	.byte 0x00
L379:
	.byte 0x00	/* orib #0,d0 */
	.byte 0x00,0x00,0x00
L37d:
	.byte 0x15	/* orib #21,d0 */
	.byte 0x00,0x00
L380:
	.byte 0x01
L381:
	.byte 0x2c	/* orib #44,d0 */
	.short 0x018e,0x0000	/* movepw d0,a6@(0) */
	movew a6@(13098),d0
L38a:
	blts L3ed
L38c:
	.short 0x7820	/* moveq #32,d4 */
	movel d0,d0
	.short 0x0000,0x03ba	/* orib #-70,d0 */
	.short 0x0000,0x0032	/* orib #50,d0 */
	.byte 0x00
L399:
	.byte 0x00,0x00,0x01	/* orib #1,d0 */
	.byte 0x00
L39d:
	.byte 0x06,0x1a
L39f:
	.byte 0x80	/* orib #-128,d6 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.byte 0x00,0x00,0x00
L3a7:
	.byte 0x0d	/* orib #13,d0 */
	.short 0x0000,0x0118	/* orib #24,d0 */
	.short 0x01b1,0x0000	/* bclr d0,a1@(0,d0:w) */
	movew a6@(13610),d0
	blts L417
	.short 0x7820	/* moveq #32,d4 */
	movel d0,d0
	.short 0x0000,0x03e4	/* orib #-28,d0 */
	.short 0x0000,0x004b	/* orib #75,d0 */
	.short 0x0000,0x0001	/* orib #1,d0 */
	.short 0x0006,0x7c28	/* orib #40,d6 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x0008	/* orib #8,d0 */
	.short 0x0000,0x0113	/* orib #19,d0 */
	.short 0x01b8,0x0000	/* bclr d0,0x0 */
	movew a6@(14133),d0
	moveal a5@(24952),a5
	movel d0,d0
	.short 0x0000,0x040e	/* orib #14,d0 */
	.short 0x0000,0x0062	/* orib #98,d0 */
	.byte 0x00
L3ed:
	.byte 0x00,0x00,0x01	/* orib #1,d0 */
	.short 0x0006,0xddd0	/* orib #-48,d6 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x0006	/* orib #6,d0 */
	.short 0x0000,0x010e	/* orib #14,d0 */
	.short 0x01ba	/* .short 0x01ba */
	.short 0x0000,0x312e	/* orib #46,d0 */
	movew a2@(28001),d0
	.short 0x7820	/* moveq #32,d4 */
	movel d0,d0
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x0064	/* orib #100,d0 */
	.byte 0x00
L417:
	.byte 0x00,0x00,0x01	/* orib #1,d0 */
	.short 0x0006,0xddd0	/* orib #-48,d6 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x0006	/* orib #6,d0 */
	.short 0x0000,0x0118	/* orib #24,d0 */
	.short 0x01bb	/* .short 0x01bb */
	.short 0x0000,0x6164	/* orib #100,d0 */
	bsrs L4a2
	.short 0x7469	/* moveq #105,d2 */
	.short 0x7665	/* moveq #101,d3 */
	movel d0,d0
L438:
	.short 0x0007,0xa120	/* orib #32,d7 */
	.short 0x0002,0xf9b8	/* orib #-72,d2 */
	.short 0x0001,0x5f90	/* orib #-112,d1 */
	.short 0x0000,0xa410	/* orib #16,d0 */
	.short 0x0000,0x4a38	/* orib #56,d0 */
	.short 0x0000,0x2904	/* orib #4,d0 */
	.short 0x0000,0x1770	/* orib #112,d0 */
	.short 0x0000,0x0d48	/* orib #72,d0 */
	.short 0x0000,0x0708	/* orib #8,d0 */
	.short 0x0000,0x0320	/* orib #32,d0 */
	.short 0x0000,0x017c	/* orib #124,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
L468:
	.short 0x0001,0x4900	/* orib #0,d1 */
	.short 0x0000,0xb200	/* orib #0,d0 */
	.short 0x0000,0x6100	/* orib #0,d0 */
	.short 0x0000,0x2d00	/* orib #0,d0 */
	.short 0x0000,0x1900	/* orib #0,d0 */
	.short 0x0000,0x0f00	/* orib #0,d0 */
	.short 0x0000,0x0800	/* orib #0,d0 */
	.short 0x0000,0x0480	/* orib #-128,d0 */
	.short 0x0000,0x0240	/* orib #64,d0 */
	.short 0x0000,0x0120	/* orib #32,d0 */
	.short 0x0000,0x0090	/* orib #-112,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	swap d1
	bset #7,d1
	braw La2c
L4a2:
	swap d1
	bclr #7,d1
	braw La2c
L4ac:
	.short 0x0002,0x0002	/* orib #2,d2 */
	.short 0x0002,0x0002	/* orib #2,d2 */
	.short 0x0006,0x000a	/* orib #10,d6 */
	.short 0x000a	/* .short 0x000a */
	.short 0x0012,0x0016	/* orib #22,a2@ */
	.short 0x002a,0x008a,0x4012	/* orib #-118,a2@(16402) */
L4c4:
	btst d0,d1
	btst d0,d1
	.short 0x0203,0x0304	/* andib #4,d3 */
	.short 0x0405,0x070e	/* subib #14,d5 */
L4d0:
	.short 0x0002,0x060e	/* orib #14,d2 */
	btst d0,d2
	btst d1,d4
L4d8:
	.short 0x0000,0x0080	/* orib #-128,d0 */
	.short 0x0000,0x0100	/* orib #0,d0 */
	.short 0x0000,0x0200	/* orib #0,d0 */
	.short 0x0000,0x0400	/* orib #0,d0 */
	.short 0x0000,0x0700	/* orib #0,d0 */
	.short 0x0000,0x0d00	/* orib #0,d0 */
	.short 0x0000,0x1500	/* orib #0,d0 */
	.short 0x0000,0x2500	/* orib #0,d0 */
	.short 0x0000,0x5100	/* orib #0,d0 */
	.short 0x0000,0x9200	/* orib #0,d0 */
	.short 0x0001,0x0900	/* orib #0,d1 */
	.short 0x0002,0x1200	/* orib #0,d2 */
L508:
	btst d2,d5
	btst d2,d5
	btst d2,d5
	btst d2,d5
	.short 0x0606,0x0606	/* addib #6,d6 */
	btst d2,d6
	btst d3,d7
	.short 0x0606,0x0606	/* addib #6,d6 */
	btst d3,d7
	.short 0x0606,0x0506	/* addib #6,d6 */
	btst d3,d7
	btst d3,d7
	btst d3,d7
	.short 0x0808	/* .short 0x0808 */
	.short 0x0808	/* .short 0x0808 */
	btst d2,d6
	movepw a0@(1799),d3
	.short 0x0808	/* .short 0x0808 */
	.short 0x0808	/* .short 0x0808 */
	movepw a1@(1543),d4
	movepw a0@(1800),d3
	movepw a1@(2057),d4
	.short 0x0a0a	/* .short 0x0a0a */
	.short 0x0607,0x0708	/* addib #8,d7 */
	movepw a1@(2314),d3
	.short 0x080a	/* .short 0x080a */
	movepw a3@(1543),d5
	.short 0x0808	/* .short 0x0808 */
	movepw a1@(2314),d3
	.short 0x080a	/* .short 0x080a */
	movepw a4@(1543),d5
	.short 0x0808	/* .short 0x0808 */
	movepw a1@(2314),d3
	movepw a2@(3085),d4
	.short 0x0607,0x0708	/* addib #8,d7 */
	movepw a1@(2316),d3
	movepw a2@(3086),d4
	.short 0x0607,0x0809	/* addib #9,d7 */
	movepw a1@(2572),d3
	movepw a3@(3343),d4
	.short 0x0607,0x0808	/* addib #8,d7 */
	movepw a2@(2827),d3
	movepw a4@(3344),d4
	.short 0x0608	/* .short 0x0608 */
	.short 0x0809	/* .short 0x0809 */
	movepw a3@(3084),d3
	movepw a5@(3601),d4
L598:
	movel a6@(8),d0
	beqs L5ca
	moveal d0,a0
	movel a6@(16),d0
	subl a6@(44),d0
	movel a6@(44),d1
	subl a6@(48),d1
	.short 0x7400	/* moveq #0,d2 */
	moveb a6@(1),d2
	extw d2
	swap d2
	moveb a6@(2),d2
	moveal a6@(4),a5
	movel a6,sp@-
	jsr a0@
	moveal sp@+,a6
	notl d0
L5ca:
	tstl d0
	rts
L5ce:
	moveml d2/a2-a4,sp@-
	movel a6@(28),d2
	lsll #3,d2
	.short 0x7004	/* moveq #4,d0 */
	swap d0
	.short 0x7201	/* moveq #1,d1 */
	swap d1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel d0,a6@(32)
	beqw L680
	subal a2,a2
L5f6:
	.short 0x203c,0x0000,0x0800	/* movel #2048,d0 */
	subl d0,d2
	bpls L604
	addl d2,d0
	.short 0x7400	/* moveq #0,d2 */
L604:
	.short 0x5080	/* addql #8,d0 */
	.short 0x7200	/* moveq #0,d1 */
	movel d0,sp@-
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-198)
	moveal sp@+,a6
	movel sp@+,d1
	tstl d0
	beqs L680
	movel d0,a6@(36)
	moveal d0,a0
	movel d1,a0@
	movel a2,a0@(4)
	moveal a0,a2
	tstl d2
	bnes L5f6
	moveal a6@(32),a0
	moveal a6@(12),a1
	addal a6@(28),a1
	moveal a6@(36),a2
L63e:
	moveal a2,a3
	addal a3@,a3
	.short 0x504a	/* addqw #8,a2 */
L644:
	.short 0x7000	/* moveq #0,d0 */
	moveb a1@(-1),d0
	lslw #8,d0
	moveb a1@,d0
	lsll #2,d0
	.short 0x2230,0x0800	/* movel a0@(0,d0:l),d1 */
	beqs L660
	moveal d1,a4
	movel a1,a3@-
	movel a4@,a3@-
	movel a3,a4@
	bras L66a
L660:
	movel a1,a3@-
	.short 0x598b	/* subql #4,a3 */
	movel a3,a3@
	.short 0x218b,0x0800	/* movel a3,a0@(0,d0:l) */
L66a:
	.short 0x5389	/* subql #1,a1 */
	cmpal a2,a3
	bhis L644
	moveal a2@-,a2
	movel a2,d0
	bnes L63e
	.short 0x70ff	/* moveq #-1,d0 */
L678:
	moveml sp@+,d2/a2-a4
	tstl d0
	rts
L680:
	.short 0x7000	/* moveq #0,d0 */
	bras L678
L684:
	moveml a2,sp@-
	movel a6@(32),d0
	beqs L6a2
	moveal d0,a1
	.short 0x203c,0x0004,0x0000	/* movel #262144,d0 */
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
L6a2:
	moveal a6@(36),a2
L6a6:
	movel a2,d0
	beqs L6c0
	movel a2@,d0
	moveal a2@(4),a1
	exg a2,a1
	movel a6,sp@-
	.short 0x2c78,0x0004	/* moveal 0x4,a6 */
	jsr a6@(-210)
	moveal sp@+,a6
	bras L6a6
L6c0:
	clrl a6@(36)
	clrl a6@(32)
	moveml sp@+,a2
	rts
L6ce:
	movel a6@(16),d5
	moveal a6@(44),a5
	.short 0x7e01	/* moveq #1,d7 */
	moveal a6@(32),a3
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@+,d0
	lslw #8,d0
	moveb a5@+,d0
	lsll #2,d0
	moveb a5@,d3
	addal d0,a3
	moveal a3@,a0
	moveal a0@,a4
	movel a4,a6@(40)
	cmpal a0,a4
	bnes L6fc
	clrl a3@
	braw L766
L6fc:
	moveal a4@,a4
	movel a4,a0@
	movel a4,d4
	lea a6@(70),a3
	clrl a3@-
	clrl a3@-
	bras L712
L70c:
	moveal a4@,a4
	cmpl a4,d4
	beqs L766
L712:
	moveal a4@(4),a2
	lea a2@(1),a1
	cmpb a1@+,d3
	bnes L732
	lea a5@(1),a0
	.short 0x303c,0x00fc	/* movew #252,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c8,0xfffc	/* dbne d0,0x726 */
	cmpal d5,a1
	blss L732
	moveal d5,a1
L732:
	movel a1,d6
	subl a2,d6
	cmpw d6,d7
	bccs L70c
	movew d6,d7
	.short 0xbc7c,0x0008	/* cmpw #8,d6 */
	bhis L754
	moveb d6,a3@(0xfffffffffffffffe,d6:w)
	movel a2,d0
	subl a5,d0
	movew d6,d1
	lslw #2,d1
	.short 0x2780,0x1000	/* movel d0,a3@(0,d1:w) */
	bras L70c
L754:
	moveb d6,a3@(7)
	movel a2,d0
	subl a5,d0
	movel d0,a3@(36)
	.short 0xbc3c,0x00ff	/* cmpb #-1,d6 */
	bnes L70c
L766:
	addal a6@(28),a5
	cmpal d5,a5
	bccs L79c
	.short 0x558d	/* subql #2,a5 */
	moveal a6@(32),a0
	moveal a6@(40),a1
	.short 0x7000	/* moveq #0,d0 */
	moveb a5@+,d0
	lslw #8,d0
	moveb a5@,d0
	lsll #2,d0
	movel a5,a1@(4)
	addal d0,a0
	movel a0@,d1
	beqs L798
	movel a1,a0@
	moveal d1,a0
	movel a0@,a1@
	movel a1,a0@
	.short 0x5307	/* subqb #1,d7 */
	rts
L798:
	movel a1,a0@
	movel a1,a1@
L79c:
	.short 0x5307	/* subqb #1,d7 */
	rts
L7a0:
	moveal a6@(44),a5
	movel a6@(16),d5
	movel a5,d0
	addl a6@(28),d0
	cmpl d5,d0
	blss L7b4
	movel d5,d0
L7b4:
	movel d0,d4
	moveal a5,a2
	.short 0x528a	/* addql #1,a2 */
	moveal a2,a4
	.short 0x7e01	/* moveq #1,d7 */
	moveb a5@,d3
	lea a6@(70),a3
	clrl a3@-
	clrl a3@-
L7c8:
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpb a2@+,d3
	beqs L80e
	cmpl a2,d4
	bhis L7c8
L80c:
	rts
L80e:
	cmpl a2,d4
	blss L80c
	moveal a4,a0
	moveal a2,a1
	cmpmb a0@+,a1@+
	bnes L7c8
	cmpmb a0@+,a1@+
	bnes L832
	cmpmb a0@+,a1@+
	bnes L82c
	.short 0x303c,0x00fb	/* movew #251,d0 */
	cmpmb a0@+,a1@+
	.short 0x56c8,0xfffc	/* dbne d0,0x826 */
L82c:
	cmpal d5,a1
	blss L832
	moveal d5,a1
L832:
	movel a1,d6
	subl a2,d6
	cmpw d6,d7
	bccs L7c8
	movew d6,d7
	.short 0xbc7c,0x0008	/* cmpw #8,d6 */
	bhis L85e
	tstb a3@(0xfffffffffffffffe,d6:w)
	bnes L7c8
	moveb d6,a3@(0xfffffffffffffffe,d6:w)
	movel a2,d0
	subl a5,d0
	.short 0x5580	/* subql #2,d0 */
	movew d6,d1
	lslw #2,d1
	.short 0x2780,0x1000	/* movel d0,a3@(0,d1:w) */
	braw L7c8
L85e:
	moveb d6,a3@(7)
	movel a2,d0
	subl a5,d0
	.short 0x5580	/* subql #2,d0 */
	movel d0,a3@(36)
	.short 0xbc3c,0x00ff	/* cmpb #-1,d6 */
	bnew L7c8
	rts
L876:
	moveb a6@(54),d2
	moveb a6@(55),d3
	moveal a6@(48),a0
L882:
	lsrl #1,d1
	roxrb #1,d2
	.short 0x5303	/* subqb #1,d3 */
	bpls L890
	.short 0x7607	/* moveq #7,d3 */
	moveb d2,a0@+
	.short 0x7400	/* moveq #0,d2 */
L890:
	.short 0x5300	/* subqb #1,d0 */
	bnes L882
	movel a0,a6@(48)
	moveb d3,a6@(55)
	moveb d2,a6@(54)
	rts
L8a2:
	.short 0x0240,0x00ff	/* andiw #255,d0 */
	.short 0xb03c,0x000d	/* cmpb #13,d0 */
	bhis L8d8
	.short 0xb03c,0x0005	/* cmpb #5,d0 */
	bhis L8c6
	lea %pc@(L4d0),a0
	addaw d0,a0
	moveb a0@(-2),a6@(123)
	moveb a0@(2),a6@(115)
	bras L8ea
L8c6:
	.short 0x5d00	/* subqb #6,d0 */
	.short 0x0000,0x00f0	/* orib #-16,d0 */
	moveb d0,a6@(123)
	.short 0x1d7c,0x0008,0x0073	/* moveb #8,a6@(115) */
	bras L8e8
L8d8:
	.short 0x1d7c,0x001f,0x007a	/* moveb #31,a6@(122) */
	moveb d0,a6@(123)
	.short 0x1d7c,0x000d,0x0073	/* moveb #13,a6@(115) */
L8e8:
	.short 0x7005	/* moveq #5,d0 */
L8ea:
	.short 0x5500	/* subqb #2,d0 */
	movel a6@(58),d2
	lea %pc@(L4c4),a1
	lea %pc@(L4ac),a0
	addaw d0,a0
	addaw d0,a0
	cmpw a0@,d2
	bccs L912
	.short 0x1c31,0x0000	/* moveb a1@(0,d0:w),d6 */
	moveb d6,d3
	.short 0x5203	/* addqb #1,d3 */
	.short 0x1d7c,0x0000,0x007d	/* moveb #0,a6@(125) */
	.short 0x7800	/* moveq #0,d4 */
	bras L946
L912:
	cmpw a0@(8),d2
	bccs L92a
	moveb a1@(0x4,d0:w),d6
	moveb d6,d3
	.short 0x5403	/* addqb #2,d3 */
	.short 0x1d7c,0x0002,0x007d	/* moveb #2,a6@(125) */
	movew a0@,d4
	bras L946
L92a:
	cmpw a0@(16),d2
	bcss L934
	.short 0x7000	/* moveq #0,d0 */
	rts
L934:
	moveb a1@(0x8,d0:w),d6
	moveb d6,d3
	.short 0x5403	/* addqb #2,d3 */
	.short 0x1d7c,0x0003,0x007d	/* moveb #3,a6@(125) */
	movew a0@(8),d4
L946:
	moveb d3,a6@(116)
	subw d4,d2
	.short 0x7a10	/* moveq #16,d5 */
	subb d6,d5
	lslw d5,d2
L952:
	addw d2,d2
	roxlw a6@(124)
	.short 0x5306	/* subqb #1,d6 */
	bnes L952
	lea a6@(174),a1
	lea a6@(126),a0
	addaw d0,a0
	addaw d0,a0
	addaw d0,a0
	addaw d0,a0
	cmpl a0@,d1
	bccs L97e
	.short 0x1c31,0x0000	/* moveb a1@(0,d0:w),d6 */
	moveb d6,d3
	.short 0x5203	/* addqb #1,d3 */
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x7800	/* moveq #0,d4 */
	bras L9aa
L97e:
	cmpl a0@(16),d1
	bccs L992
	moveb a1@(0x4,d0:w),d6
	moveb d6,d3
	.short 0x5403	/* addqb #2,d3 */
	.short 0x7e02	/* moveq #2,d7 */
	movel a0@,d4
	bras L9aa
L992:
	cmpl a0@(32),d1
	bcss L99c
	.short 0x7000	/* moveq #0,d0 */
	rts
L99c:
	moveb a1@(0x8,d0:w),d6
	moveb d6,d3
	.short 0x5403	/* addqb #2,d3 */
	.short 0x7e03	/* moveq #3,d7 */
	movel a0@(16),d4
L9aa:
	moveb d3,a6@(114)
	subl d4,d1
	.short 0x7a20	/* moveq #32,d5 */
	subb d6,d5
	lsll d5,d1
L9b6:
	addl d1,d1
	addxl d7,d7
	.short 0x5306	/* subqb #1,d6 */
	bnes L9b6
	movel d7,a6@(118)
	.short 0x70ff	/* moveq #-1,d0 */
	rts
L9c6:
	clrw a6@(52)
	clrw a6@(56)
	lea a6@(62),a2
	lea a6@(70),a3
L9d6:
	movel a3@+,d1
	moveb a2@+,d0
	beqs La1c
	bsrw L8a2
	beqs La1c
	.short 0x7000	/* moveq #0,d0 */
	.short 0x7200	/* moveq #0,d1 */
	moveb a2@(-1),d0
	lslw #3,d0
	addb a6@(115),d1
	addb a6@(114),d1
	addb a6@(116),d1
	subw d1,d0
	bmis La1c
	cmpw a6@(52),d0
	bcss La1c
	movew d0,a6@(52)
	moveb a2@(-1),a6@(57)
	lea a6@(102),a0
	lea a6@(114),a1
	.short 0x720b	/* moveq #11,d1 */
	moveb a1@+,a0@+
	.short 0x51c9,0xfffc	/* dbf d1,0xa16 */
La1c:
	movel a2,d0
	subl a6,d0
	.short 0xb07c,0x0046	/* cmpw #70,d0 */
	bnes L9d6
	tstw a6@(56)
	rts
La2c:
	moveml d2-d7/a2-a6,sp@-
	.short 0x343c,0x005c	/* movew #92,d2 */
	clrw sp@-
	.short 0x51ca,0xfffc	/* dbf d2,0xa34 */
	moveal sp,a6
	movel a5,a6@(4)
	.short 0xb0bc,0x0000,0x0040	/* cmpl #64,d0 */
	bcsw Ld38
	lsrl #8,d1
	scs a6@
	lsrl #8,d1
	scs a6@(1)
	.short 0xb23c,0x000c	/* cmpb #12,d1 */
	bcss La5c
	.short 0x7200	/* moveq #0,d1 */
La5c:
	movel a1,a6@(8)
	movel a0,a6@(12)
	movel a0,a6@(44)
	movel a0,a6@(48)
	movel d0,a6@(20)
	addal d0,a0
	movel a0,a6@(16)
	lea %pc@(L4d8),a0
	lslw #2,d1
	.short 0x2230,0x1000	/* movel a0@(0,d1:w),d1 */
	.short 0x5281	/* addql #1,d1 */
	cmpl d0,d1
	blss La8a
	movel d0,d1
	.short 0x5381	/* subql #1,d1 */
La8a:
	movel d1,a6@(28)
	.short 0x5381	/* subql #1,d1 */
	.short 0x7000	/* moveq #0,d0 */
La92:
	cmpl a0@+,d1
	blss La9a
	.short 0x5200	/* addqb #1,d0 */
	bras La92
La9a:
	moveb d0,a6@(2)
	lea a6@(174),a1
	.short 0x720c	/* moveq #12,d1 */
	.short 0xc0c1	/* muluw d1,d0 */
	lea %pc@(L508),a0
	addal d0,a0
	.short 0x5341	/* subqw #1,d1 */
	moveb a0@+,a1@+
	.short 0x51c9,0xfffc	/* dbf d1,0xaae */
	lea a6@(126),a1
	lea a6@(174),a0
	.short 0x720b	/* moveq #11,d1 */
	moveb a0@+,d0
	.short 0x7400	/* moveq #0,d2 */
	bset d0,d2
	movel d2,a1@+
	.short 0x51c9,0xfff6	/* dbf d1,0xabe */
	lea a6@(126),a0
	lea a6@(142),a1
	.short 0x7207	/* moveq #7,d1 */
	movel a0@+,d0
	addl d0,a1@+
	.short 0x51c9,0xfffa	/* dbf d1,0xad4 */
	tstb a6@
	beqs Lafa
	lea a6@(126),a1
	.short 0x7007	/* moveq #7,d0 */
	movel a1@+,d1
	movew d1,a2@+
	.short 0x51c8,0xfffa	/* dbf d0,0xae6 */
	lea a6@(174),a1
	.short 0x700b	/* moveq #11,d0 */
	moveb a1@+,a2@+
	.short 0x51c8,0xfffc	/* dbf d0,0xaf4 */
Lafa:
	.short 0x1d7c,0x0007,0x0037	/* moveb #7,a6@(55) */
	tstb a6@(1)
	beqs Lb14
	bsrw L5ce
	bnes Lb14
	sf a6@(1)
	bsrw L684
Lb14:
	movel a6@(16),d0
	.short 0x5580	/* subql #2,d0 */
	cmpl a6@(44),d0
	blsw Lc1c
	bsrw L598
	bnew Ld34
	tstb a6@(1)
	bnes Lb36
	bsrw L7a0
	bras Lb3c
Lb36:
	bsrw L6ce
	beqs Lb42
Lb3c:
	bsrw L9c6
	bnes Lb66
Lb42:
	moveal a6@(44),a0
	moveal a6@(48),a1
	moveb a0@,a1@
	.short 0x52ae,0x002c	/* addql #1,a6@(44) */
	.short 0x52ae,0x0030	/* addql #1,a6@(48) */
	.short 0x52ae,0x003a	/* addql #1,a6@(58) */
	.byte 0x0c,0xae,0x00,0x00,0x40,0x12,0x00,0x3a	/* cmpil #16402,a6@(58) */
	bcss Lb14
	braw Lc1c
Lb66:
	clrl a6@(58)
	tstb a6@(1)
	beqs Lbd6
	moveal a6@(44),a2
	.short 0x528a	/* addql #1,a2 */
	moveal a2,a3
	addal a6@(28),a3
	movew a6@(56),d3
	.short 0x5343	/* subqw #1,d3 */
	movel a6@(16),d2
	subl a3,d2
	.short 0x5382	/* subql #1,d2 */
	bpls Lb8e
	.short 0x7400	/* moveq #0,d2 */
Lb8e:
	moveal a6@(32),a4
	.short 0x7000	/* moveq #0,d0 */
	moveb a2@+,d0
	lslw #8,d0
	moveb a2@,d0
	lsll #2,d0
	addal d0,a4
	moveal a4@,a0
	moveal a0@,a5
	cmpal a0,a5
	bnes Lbaa
	clrl a4@
	bras Lbac
Lbaa:
	movel a5@,a0@
Lbac:
	.short 0x5382	/* subql #1,d2 */
	bmis Lbd2
	subal d0,a4
	.short 0x7000	/* moveq #0,d0 */
	moveb a3@+,d0
	lslw #8,d0
	moveb a3@,d0
	lsll #2,d0
	addal d0,a4
	movel a3,a5@(4)
	movel a4@,d1
	beqs Lbce
	moveal d1,a0
	movel a0@,a5@
	movel a5,a0@
	bras Lbd0
Lbce:
	movel a5,a5@
Lbd0:
	movel a5,a4@
Lbd2:
	.short 0x5343	/* subqw #1,d3 */
	bnes Lb8e
Lbd6:
	movew a6@(56),d0
	extl d0
	addl d0,a6@(44)
	moveb a6@(102),d0
	movel a6@(106),d1
	bsrw L876
	moveb a6@(104),d0
	movew a6@(112),d1
	bsrw L876
	moveb a6@(103),d0
	movew a6@(110),d1
	.short 0xb03c,0x000d	/* cmpb #13,d0 */
	bnes Lc14
	moveal a6@(48),a0
	moveb d1,a0@
	.short 0x52ae,0x0030	/* addql #1,a6@(48) */
	.short 0x7005	/* moveq #5,d0 */
	.short 0x721f	/* moveq #31,d1 */
Lc14:
	bsrw L876
	braw Lb14
Lc1c:
	bsrw L598
	bnew Ld34
	moveal a6@(44),a0
	moveal a6@(48),a1
	moveb a0@,a1@
	.short 0x52ae,0x002c	/* addql #1,a6@(44) */
	.short 0x52ae,0x0030	/* addql #1,a6@(48) */
	.short 0x52ae,0x003a	/* addql #1,a6@(58) */
	movel a6@(44),d0
	cmpl a6@(16),d0
	bnes Lc1c
	bsrw L598
	bnew Ld34
	tstb a6@
	bnew Lcf0
	movel a6@(48),d0
	subl a6@(12),d0
	.short 0xb0bc,0x0000,0x000c	/* cmpl #12,d0 */
	bcsw Ld38
	movel a6@(20),d1
	subl d0,d1
	.short 0xb2bc,0x0000,0x0036	/* cmpl #54,d1 */
	blsw Ld38
	moveal a6@(12),a1
	moveal a6@(48),a0
	.short 0x2e3c,0x0000,0xff00	/* movel #65280,d7 */
	btst #0,d0
	beqs Lc8e
	.short 0x7e00	/* moveq #0,d7 */
	.short 0x5280	/* addql #1,d0 */
	clrb a0@+
Lc8e:
	movel a1@,a0@(8)
	.short 0x22bc,0x494d,0x5021	/* movel #1229803553,a1@ */
	movel a1@(4),a0@(4)
	movel a6@(20),a1@(4)
	movel a1@(8),a0@
	movel d0,a1@(8)
	.short 0x0680,0x0000,0x002e	/* addil #46,d0 */
	movel d0,a6@(24)
	movel a6@(58),a0@(12)
	moveb a6@(54),d1
	.short 0x0241,0x00fe	/* andiw #254,d1 */
	moveb a6@(55),d0
	bset d0,d1
	orw d7,d1
	movew d1,a0@(16)
	lea a6@(126),a1
	.short 0xd0fc,0x0012	/* addaw #18,a0 */
	.short 0x7007	/* moveq #7,d0 */
	movel a1@+,d1
	movew d1,a0@+
	.short 0x51c8,0xfffa	/* dbf d0,0xcda */
	lea a6@(174),a1
	.short 0x700b	/* moveq #11,d0 */
	moveb a1@+,a0@+
	.short 0x51c8,0xfffc	/* dbf d0,0xce8 */
	bras Ld38
Lcf0:
	movel a6@(48),d0
	subl a6@(12),d0
	movel a6@(20),d1
	subl d0,d1
	.short 0xb2bc,0x0000,0x0006	/* cmpl #6,d1 */
	blss Ld38
	moveb a6@(54),d1
	.short 0x0201,0x00fe	/* andib #-2,d1 */
	moveb a6@(55),d2
	bset d2,d1
	moveal a6@(48),a0
	btst #0,d0
	beqs Ld26
	moveb d1,a0@+
	movel a6@(58),a0@
	bras Ld2c
Ld26:
	movel a6@(58),a0@+
	moveb d1,a0@
Ld2c:
	.short 0x5a80	/* addql #5,d0 */
	movel d0,a6@(24)
	bras Ld38
Ld34:
	.short 0x70ff	/* moveq #-1,d0 */
	bras Ld3c
Ld38:
	movel a6@(24),d0
Ld3c:
	moveml d0,sp@-
	bsrw L684
	moveml sp@+,d0
	.short 0x343c,0x005c	/* movew #92,d2 */
	clrw sp@+
	.short 0x51ca,0xfffc	/* dbf d2,0xd4c */
	moveml sp@+,d2-d7/a2-a6
	tstl d0
	rts
	.byte 0x00,0x00
Ld5c:
	.byte 0x0c,0x90	/* orib #-112,d0 */
	.short 0x494d	/* .short 0x494d */
	.short 0x5021	/* addqb #8,a1@- */
	bnes Ld96
	moveml d2-d5/a2-a4,sp@-
	moveal a0,a3
	moveal a0,a4
	tstl a0@+
	addal a0@+,a4
	addal a0@+,a3
	moveal a3,a2
	movel a2@+,a0@-
	movel a2@+,a0@-
	movel a2@+,a0@-
	movel a2@+,d2
	movew a2@+,d3
	bmis Ld82
	.short 0x538b	/* subql #1,a3 */
Ld82:
	lea sp@(-28),sp
	moveal sp,a1
	.short 0x7006	/* moveq #6,d0 */
	movel a2@+,a1@+
	.short 0x51c8,0xfffc	/* dbf d0,0xd8a */
	moveal sp,a1
	braw Ldc0
Ld96:
	.short 0x7000	/* moveq #0,d0 */
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0x3c38,0x2648	/* movew 0x2648,d6 */
	moveal a0,a4
	addal d0,a4
	addal d1,a3
	lsrw #1,d1
	bccs Ldb2
	moveb a3@-,d3
	movel a3@-,d2
	bras Ldb6
Ldb2:
	movel a3@-,d2
	moveb a3@-,d3
Ldb6:
	lea sp@(-28),sp
	braw Ldc0
	.byte 0x00,0x00
Ldc0:
	.byte 0x4a,0x82	/* orib #-126,d0 */
	beqs Ldca
Ldc4:
	moveb a3@-,a4@-
	.short 0x5382	/* subql #1,d2 */
	bnes Ldc4
Ldca:
	cmpal a4,a0
	bcss Lde2
	lea sp@(28),sp
	.short 0x70ff	/* moveq #-1,d0 */
	cmpal a3,a0
	beqs Ldda
	.short 0x7000	/* moveq #0,d0 */
Ldda:
	moveml sp@+,d2-d5/a2-a4
	tstl d0
	rts
Lde2:
	addb d3,d3
	bnes Ldea
	moveb a3@-,d3
	addxb d3,d3
Ldea:
	bccs Le54
	addb d3,d3
	bnes Ldf4
	moveb a3@-,d3
	addxb d3,d3
Ldf4:
	bccs Le4e
	addb d3,d3
	bnes Ldfe
	moveb a3@-,d3
	addxb d3,d3
Ldfe:
	bccs Le48
	addb d3,d3
	bnes Le08
	moveb a3@-,d3
	addxb d3,d3
Le08:
	bccs Le42
	.short 0x7800	/* moveq #0,d4 */
	addb d3,d3
	bnes Le14
	moveb a3@-,d3
	addxb d3,d3
Le14:
	bccs Le1e
	moveb a3@-,d4
	.short 0x7003	/* moveq #3,d0 */
	.short 0x5304	/* subqb #1,d4 */
	bras Le58
Le1e:
	addb d3,d3
	bnes Le26
	moveb a3@-,d3
	addxb d3,d3
Le26:
	addxb d4,d4
	addb d3,d3
	bnes Le30
	moveb a3@-,d3
	addxb d3,d3
Le30:
	addxb d4,d4
	addb d3,d3
	bnes Le3a
	moveb a3@-,d3
	addxb d3,d3
Le3a:
	addxb d4,d4
	.short 0x5a04	/* addqb #5,d4 */
	.short 0x7003	/* moveq #3,d0 */
	bras Le58
Le42:
	.short 0x7804	/* moveq #4,d4 */
	.short 0x7003	/* moveq #3,d0 */
	bras Le58
Le48:
	.short 0x7803	/* moveq #3,d4 */
	.short 0x7002	/* moveq #2,d0 */
	bras Le58
Le4e:
	.short 0x7802	/* moveq #2,d4 */
	.short 0x7001	/* moveq #1,d0 */
	bras Le58
Le54:
	.short 0x7801	/* moveq #1,d4 */
	.short 0x7000	/* moveq #0,d0 */
Le58:
	.short 0x7a00	/* moveq #0,d5 */
	movew d0,d1
	addb d3,d3
	bnes Le64
	moveb a3@-,d3
	addxb d3,d3
Le64:
	bccs Le7c
	addb d3,d3
	bnes Le6e
	moveb a3@-,d3
	addxb d3,d3
Le6e:
	bccs Le78
	.short 0x1a3b,0x006a	/* moveb %pc@(0xedc,d0:w),d5 */
	.short 0x5000	/* addqb #8,d0 */
	bras Le7c
Le78:
	.short 0x7a02	/* moveq #2,d5 */
	.short 0x5800	/* addqb #4,d0 */
Le7c:
	.short 0x103b,0x0062	/* moveb %pc@(0xee0,d0:w),d0 */
Le80:
	addb d3,d3
	bnes Le88
	moveb a3@-,d3
	addxb d3,d3
Le88:
	addxw d2,d2
	.short 0x5300	/* subqb #1,d0 */
	bnes Le80
	addw d5,d2
	.short 0x7a00	/* moveq #0,d5 */
	moveal d5,a2
	movew d1,d0
	addb d3,d3
	bnes Le9e
	moveb a3@-,d3
	addxb d3,d3
Le9e:
	bccs Leba
	addw d1,d1
	addb d3,d3
	bnes Leaa
	moveb a3@-,d3
	addxb d3,d3
Leaa:
	bccs Leb4
	moveaw a1@(0x8,d1:w),a2
	.short 0x5000	/* addqb #8,d0 */
	bras Leba
Leb4:
	.short 0x3471,0x1000	/* moveaw a1@(0,d1:w),a2 */
	.short 0x5800	/* addqb #4,d0 */
Leba:
	moveb a1@(0x10,d0:w),d0
Lebe:
	addb d3,d3
	bnes Lec6
	moveb a3@-,d3
	addxb d3,d3
Lec6:
	addxl d5,d5
	.short 0x5300	/* subqb #1,d0 */
	bnes Lebe
	.short 0x524a	/* addqw #1,a2 */
	addal d5,a2
	addal a4,a2
	moveb a2@-,a4@-
	.short 0x51cc,0xfffc	/* dbf d4,0xed2 */
	braw Ldc0
	.short 0x060a	/* .short 0x060a */
	.short 0x0a12,0x0101	/* eorib #1,a2@ */
	btst d0,d1
	.short 0x0203,0x0304	/* andib #4,d3 */
	.short 0x0405,0x070e	/* subib #14,d5 */
