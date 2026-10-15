	.section .text
ENDSKIP:
	moveq #0,d0                       	/* 000000 */
	rts                               	/* 000002 */
ROMTAG:
	.byte 0x4a,0xfc
	.long ROMTAG	/* =00000004 */
	.long ENDSKIP	/* =00000000 */
	.byte 0x80,0x01,0x09,0x00
	.long XPKPWPKLIBNAME	/* =0000001e */
	.long IDSTRING	/* =0000002e */
	.long INIT	/* =00000064 */
XPKPWPKLIBNAME:
	.byte 0x78,0x70,0x6b,0x50,0x57,0x50,0x4b,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79	/* "xpkPWPK.library" */
	.byte 0x00
IDSTRING:
	.byte 0x24,0x56,0x45,0x52,0x3a,0x20,0x78,0x70,0x6b,0x50,0x57,0x50,0x4b,0x20,0x56,0x31,0x2e,0x32,0x20,0x28,0x31,0x20,0x4f,0x63,0x74,0x20,0x32,0x30,0x31,0x33,0x29,0x20,0x62,0x79,0x20,0x4d,0x69,0x63,0x68,0x61,0x65,0x6c,0x20,0x42,0x61,0x72,0x73,0x6f,0x6f,0x6d	/* "$VER: xpkPWPK V1.2 (1 Oct 2013) by Michael Barsoom" */
	.byte 0x0d
	.byte 0x0a
	.byte 0x00
	.byte 0x00
INIT:
	.byte 0x00,0x00,0x00,0x26
	.long FUNCTABLE	/* =00000094 */
	.long DATATABLE	/* =00000074 */
	.long INITFUNCTION	/* =000000ac */
DATATABLE:
	.byte 0xa0,0x08,0x09,0x00
	.byte 0x80,0x0a
	.long XPKPWPKLIBNAME	/* =0000001e */
	.byte 0xa0,0x0e,0x06,0x00
	.byte 0x90,0x14,0x00,0x01
	.byte 0x90,0x16,0x00,0x02
	.byte 0x80,0x18
	.long IDSTRING	/* =0000002e */
	.byte 0x00,0x00,0x00,0x00
FUNCTABLE:
	.byte 0xff,0xff,0x00,0x20
	.byte 0x00,0x2e,0x00,0x40
	.byte 0xff,0x6c,0x00,0x7e
	.byte 0x01,0x2c,0x00,0x86
	.byte 0xff,0x6c,0x05,0xa4
	.byte 0xff,0x6c,0xff,0xff
INITFUNCTION:
	moveal d0,a1                      	/* 0000ac */
	movel a0,a1@(34)                  	/* 0000ae */
	rts                               	/* 0000b2 */
OPEN:
	addqw #1,a6@(32)                  	/* 0000b4 */
	bclr #3,a6@(14)                   	/* 0000b8 */
	movel a6,d0                       	/* 0000be */
	rts                               	/* 0000c0 */
CLOSE:
	subqw #1,a6@(32)                  	/* 0000c2 */
	bnew ENDSKIP                      	/* 0000c6 */
	btst #3,a6@(14)                   	/* 0000ca */
	beqw ENDSKIP                      	/* 0000d0 */
EXPUNGE:
	tstw a6@(32)                      	/* 0000d4 */
	beqs LAB_000B                     	/* 0000d8 */
	bset #3,a6@(14)                   	/* 0000da */
	braw ENDSKIP                      	/* 0000e0 */
LAB_000B:
	moveml d2/a5-a6,sp@-              	/* 0000e4 */
	movel a6@(34),d2                  	/* 0000e8 */
	moveal a6,a5                      	/* 0000ec */
	moveal a5,a1                      	/* 0000ee */
	moveal 0x4:w,a6                   	/* 0000f0 */
	jsr a6@(-252)                     	/* 0000f4 */
	moveal a5,a1                      	/* 0000f8 */
	moveq #0,d0                       	/* 0000fa */
	movew a5@(16),d0                  	/* 0000fc */
	subal d0,a1                       	/* 000100 */
	addw a5@(18),d0                   	/* 000102 */
	jsr a6@(-210)                     	/* 000106 */
	movel d2,d0                       	/* 00010a */
	moveml sp@+,d2/a5-a6              	/* 00010c */
	rts                               	/* 000110 */
LIBFUNC_1:
	lea %pc@(LAB_006E),a0             	/* 000112 */
	movel a0,d0                       	/* 000116 */
	rts                               	/* 000118 */
LIBFUNC_3:
	movel a0@(52),d0                  	/* 00011a */
	beqs LAB_000E                     	/* 00011e */
	movel a6,sp@-                     	/* 000120 */
	moveal d0,a1                      	/* 000122 */
	movel a1@-,d0                     	/* 000124 */
	moveal 0x4:w,a6                   	/* 000126 */
	jsr a6@(-210)                     	/* 00012a */
	moveal sp@+,a6                    	/* 00012e */
LAB_000E:
	rts                               	/* 000130 */
LAB_000F:
	moveml D2-D7/A2/A6,sp@-           	/* 000132 */
	lea %pc@(LAB_004F),a0             	/* 000136 */
	addw d0,d0                        	/* 00013a */
	addw d0,d0                        	/* 00013c */
	addqw #1,d0                       	/* 00013e */
	addaw d0,a0                       	/* 000140 */
	moveq #0,d2                       	/* 000142 */
	moveq #0,d3                       	/* 000144 */
	moveq #0,d4                       	/* 000146 */
	moveb a0@+,d2                     	/* 000148 */
	moveb a0@+,d3                     	/* 00014a */
	moveb a0@,d4                      	/* 00014c */
	moveq #1,d5                       	/* 00014e */
	moveq #1,d6                       	/* 000150 */
	moveq #1,d7                       	/* 000152 */
	aslw d2,d5                        	/* 000154 */
	aslw d3,d6                        	/* 000156 */
	aslw d4,d7                        	/* 000158 */
	moveq #66,d0                      	/* 00015a */
	addil #0x00030000,d0              	/* 00015c */
	movel d7,d1                       	/* 000162 */
	asll #3,d1                        	/* 000164 */
	addl d1,d0                        	/* 000166 */
	addql #4,d0                       	/* 000168 */
	moveal d0,a2                      	/* 00016a */
	moveq #0,d1                       	/* 00016c */
	moveal 0x4:w,a6                   	/* 00016e */
	jsr a6@(-198)                     	/* 000172 */
	tstl d0                           	/* 000176 */
	beqs LAB_0010                     	/* 000178 */
	moveal d0,a0                      	/* 00017a */
	movel a2,a0@+                     	/* 00017c */
	movel a0,d0                       	/* 00017e */
	movew #0x0009,a0@+                	/* 000180 */
	movew d2,a0@+                     	/* 000184 */
	movew d3,a0@+                     	/* 000186 */
	movew d4,a0@+                     	/* 000188 */
	movew #0x0200,a0@+                	/* 00018a */
	movew d5,a0@+                     	/* 00018e */
	movew d6,a0@+                     	/* 000190 */
	movew d7,a0@+                     	/* 000192 */
	movel #0x00000001,a0@+            	/* 000194 */
	movel #0x00020003,a0@             	/* 00019a */
	moveal d0,a2                      	/* 0001a0 */
	addl d7,d7                        	/* 0001a2 */
	movel d7,a2@(62)                  	/* 0001a4 */
	lea a2@(66),a1                    	/* 0001a8 */
	movel a1,a2@(58)                  	/* 0001ac */
	addal #0x00030000,a1              	/* 0001b0 */
	movel a1,a2@(54)                  	/* 0001b6 */
LAB_0010:
	moveml sp@+,D2-D7/A2/A6           	/* 0001ba */
	rts                               	/* 0001be */
LIBFUNC_2:
	moveml D2-D7/A2-A6,sp@-           	/* 0001c0 */
	moveal a0,a5                      	/* 0001c4 */
	.byte 0x26,0x6d,0x00,0x00	/* MOVEA.L	0(A5),A3 */
	moveal a5@(8),a4                  	/* 0001ca */
	movel a5@(4),d7                   	/* 0001ce */
	movel a5@(32),d5                  	/* 0001d2 */
	tstl a5@(52)                      	/* 0001d6 */
	beqs LAB_0012                     	/* 0001da */
	moveal a5@(52),a0                 	/* 0001dc */
	moveal a3,a1                      	/* 0001e0 */
	moveal a4,a2                      	/* 0001e2 */
	movel d7,d0                       	/* 0001e4 */
	bsrw LAB_0018                     	/* 0001e6 */
	movel d0,d4                       	/* 0001ea */
	bmiw LAB_0016                     	/* 0001ec */
	tstl d5                           	/* 0001f0 */
	beqs LAB_0014                     	/* 0001f2 */
	movel d4,d0                       	/* 0001f4 */
	subql #4,d0                       	/* 0001f6 */
	moveal a4,a0                      	/* 0001f8 */
	movel a5@(60),d1                  	/* 0001fa */
	bsrw LAB_006C                     	/* 0001fe */
	bras LAB_0014                     	/* 000202 */
LAB_0012:
	movel a5@(28),d0                  	/* 000204 */
	beqs LAB_0013                     	/* 000208 */
	subqb #1,d0                       	/* 00020a */
	divu #0x0014,d0                   	/* 00020c */
	andil #0x0000000f,d0              	/* 000210 */
LAB_0013:
	movel d0,a5@(56)                  	/* 000216 */
	bsrw LAB_000F                     	/* 00021a */
	movel d0,a5@(52)                  	/* 00021e */
	beqs LAB_0017                     	/* 000222 */
	moveal d0,a0                      	/* 000224 */
	moveal a3,a1                      	/* 000226 */
	moveal a4,a2                      	/* 000228 */
	movel d7,d0                       	/* 00022a */
	bsrs LAB_0018                     	/* 00022c */
	movel d0,d4                       	/* 00022e */
	bmis LAB_0016                     	/* 000230 */
	movel a5@(56),a4@(0,d4:l)         	/* 000232 */
	addql #4,d4                       	/* 000238 */
	tstl d5                           	/* 00023a */
	beqs LAB_0014                     	/* 00023c */
	moveal d5,a0                      	/* 00023e */
	bsrw LAB_0068                     	/* 000240 */
	movel d0,a5@(60)                  	/* 000244 */
	moveal d5,a0                      	/* 000248 */
	bsrw LAB_006A                     	/* 00024a */
	movel d0,a5@(64)                  	/* 00024e */
	movel d4,d0                       	/* 000252 */
	subql #8,d0                       	/* 000254 */
	moveal a4,a0                      	/* 000256 */
	movel a5@(60),d1                  	/* 000258 */
	bsrw LAB_006C                     	/* 00025c */
	movel a5@(64),a4@(0,d4:l)         	/* 000260 */
	addql #4,d4                       	/* 000266 */
LAB_0014:
	movel d4,a5@(16)                  	/* 000268 */
	moveq #0,d0                       	/* 00026c */
LAB_0015:
	moveml sp@+,D2-D7/A2-A6           	/* 00026e */
	rts                               	/* 000272 */
LAB_0016:
	moveq #-17,d0                     	/* 000274 */
	bras LAB_0015                     	/* 000276 */
LAB_0017:
	moveq #-7,d0                      	/* 000278 */
	bras LAB_0015                     	/* 00027a */
LAB_0018:
	moveml D1-D7/A1-A6,sp@-           	/* 00027c */
	moveal a0,a4                      	/* 000280 */
	movel a1,a4@(34)                  	/* 000282 */
	movel d0,a4@(38)                  	/* 000286 */
	addl a1,d0                        	/* 00028a */
	movel d0,a4@(42)                  	/* 00028c */
	movel a2,a4@(46)                  	/* 000290 */
	moveal a4@(54),a0                 	/* 000294 */
	movel a4@(62),d0                  	/* 000298 */
	subql #1,d0                       	/* 00029c */
LAB_0019:
	clrl a0@+                         	/* 00029e */
	dbf d0,LAB_0019                   	/* 0002a0 */
	moveal a4@(58),a0                 	/* 0002a4 */
	movel #0x0000bfff,d0              	/* 0002a8 */
LAB_001A:
	clrl a0@+                         	/* 0002ae */
	dbf d0,LAB_001A                   	/* 0002b0 */
	moveal a4@(34),a0                 	/* 0002b4 */
	moveal a4@(46),a6                 	/* 0002b8 */
	moveal a6,a5                      	/* 0002bc */
	addal a4@(38),a5                  	/* 0002be */
	subqw #8,a5                       	/* 0002c2 */
	movel a4@(38),d5                  	/* 0002c4 */
	moveal a4@(54),a3                 	/* 0002c8 */
	moveq #0,d0                       	/* 0002cc */
	movew a4@(14),d0                  	/* 0002ce */
	addw d0,d0                        	/* 0002d2 */
	movel d0,d6                       	/* 0002d4 */
	movew d0,a4@(24)                  	/* 0002d6 */
	addl d0,d0                        	/* 0002da */
	movel d0,a4@(26)                  	/* 0002dc */
	moveml a0/a6,sp@-                 	/* 0002e0 */
	moveal a0,a1                      	/* 0002e4 */
	subal d6,a0                       	/* 0002e6 */
	movel d6,d7                       	/* 0002e8 */
	cmpl d5,d7                        	/* 0002ea */
	bcss LAB_001B                     	/* 0002ec */
	movel d5,d7                       	/* 0002ee */
LAB_001B:
	moveal a4@(26),a6                 	/* 0002f0 */
	addal a3,a6                       	/* 0002f4 */
	bsrw LAB_0038                     	/* 0002f6 */
	moveml sp@+,a0/a6                 	/* 0002fa */
	movel sp,a4@(50)                  	/* 0002fe */
	moveq #1,d5                       	/* 000302 */
	moveq #0,d7                       	/* 000304 */
LAB_001C:
	moveml d5/d7/a3/a5-a6,sp@-        	/* 000306 */
	lea a0@(32767),a5                 	/* 00030a */
	cmpal a4@(42),a5                  	/* 00030e */
	bcss LAB_001D                     	/* 000312 */
	moveal a4@(42),a5                 	/* 000314 */
LAB_001D:
	moveq #1,d4                       	/* 000318 */
	lea a0@(1),a1                     	/* 00031a */
	subal a2,a2                       	/* 00031e */
LAB_001E:
	moveq #0,d3                       	/* 000320 */
	movew a4@(24),d3                  	/* 000322 */
	moveb a0@(1),d1                   	/* 000326 */
	moveb a0@(0,d4:l),d2              	/* 00032a */
	moveq #0,d0                       	/* 00032e */
	lea a1@(-1,d4:l),a1               	/* 000330 */
	lea a2@(-1,d4:l),a2               	/* 000334 */
LAB_001F:
	movew a3@,d0                      	/* 000338 */
	beqs LAB_0023                     	/* 00033a */
	addal d0,a1                       	/* 00033c */
	addw d0,d0                        	/* 00033e */
	addal d0,a3                       	/* 000340 */
	cmpb a1@,d2                       	/* 000342 */
	bnes LAB_001F                     	/* 000344 */
	cmpal a2,a1                       	/* 000346 */
	bcss LAB_001F                     	/* 000348 */
	subal d4,a1                       	/* 00034a */
	addqw #1,a1                       	/* 00034c */
	cmpal a5,a1                       	/* 00034e */
	bccs LAB_0023                     	/* 000350 */
	lea a0@(2),a2                     	/* 000352 */
	lea a1@(1),a6                     	/* 000356 */
LAB_0020:
	cmpmb a2@+,a6@+                   	/* 00035a */
	beqs LAB_0020                     	/* 00035c */
	subqw #1,a6                       	/* 00035e */
	cmpal a6,a5                       	/* 000360 */
	bccs LAB_0021                     	/* 000362 */
	movel a6,d0                       	/* 000364 */
	subl a5,d0                        	/* 000366 */
	subal d0,a2                       	/* 000368 */
	moveal a5,a6                      	/* 00036a */
LAB_0021:
	movel a2,d2                       	/* 00036c */
	subl a0,d2                        	/* 00036e */
	subql #1,d2                       	/* 000370 */
	cmpl d2,d4                        	/* 000372 */
	bccs LAB_001E                     	/* 000374 */
	movel a6,d3                       	/* 000376 */
	subl a0,d3                        	/* 000378 */
	subl d2,d3                        	/* 00037a */
	moveq #6,d1                       	/* 00037c */
	moveq #5,d0                       	/* 00037e */
	cmpl d0,d2                        	/* 000380 */
	bccs LAB_0022                     	/* 000382 */
	movew d2,d1                       	/* 000384 */
	subqw #2,d1                       	/* 000386 */
	addw d1,d1                        	/* 000388 */
LAB_0022:
	movew a4@(8,d1:w),d0              	/* 00038a */
	cmpw d3,d0                        	/* 00038e */
	bcss LAB_001E                     	/* 000390 */
	movel d2,d4                       	/* 000392 */
	movew d3,d5                       	/* 000394 */
	movew d1,d7                       	/* 000396 */
	bras LAB_001E                     	/* 000398 */
LAB_0023:
	movew d5,a4@(30)                  	/* 00039a */
	movew d7,a4@(32)                  	/* 00039e */
	moveml sp@+,d5/d7/a3/a5-a6        	/* 0003a2 */
	moveq #1,d0                       	/* 0003a6 */
	cmpl d0,d4                        	/* 0003a8 */
	bnes LAB_0025                     	/* 0003aa */
	moveq #8,d0                       	/* 0003ac */
	moveb a0@,d1                      	/* 0003ae */
	bsrw LAB_0045                     	/* 0003b0 */
	addql #1,d7                       	/* 0003b4 */
	moveml d7/a6,sp@-                 	/* 0003b6 */
	moveal a4@(26),a6                 	/* 0003ba */
	addal a3,a6                       	/* 0003be */
	clrw a3@+                         	/* 0003c0 */
	clrw a6@+                         	/* 0003c2 */
	subqw #1,d6                       	/* 0003c4 */
	bnes LAB_0024                     	/* 0003c6 */
	movew a4@(24),d6                  	/* 0003c8 */
	moveal a4@(54),a3                 	/* 0003cc */
	moveal a4@(26),a6                 	/* 0003d0 */
	addal a3,a6                       	/* 0003d4 */
LAB_0024:
	lea a0@(1),a1                     	/* 0003d6 */
	moveq #1,d7                       	/* 0003da */
	bsrw LAB_0038                     	/* 0003dc */
	moveml sp@+,d7/a6                 	/* 0003e0 */
	braw LAB_0033                     	/* 0003e4 */
LAB_0025:
	moveml d4/d7/a6,sp@-              	/* 0003e8 */
	moveq #0,d0                       	/* 0003ec */
	movew a4@(24),d0                  	/* 0003ee */
	cmpl d0,d4                        	/* 0003f2 */
	bcss LAB_0027                     	/* 0003f4 */
	addal d4,a0                       	/* 0003f6 */
	moveal a4@(54),a3                 	/* 0003f8 */
	moveal a4@(26),a6                 	/* 0003fc */
	addal a3,a6                       	/* 000400 */
	movew a4@(24),d6                  	/* 000402 */
	movew d6,d4                       	/* 000406 */
	subqw #1,d4                       	/* 000408 */
LAB_0026:
	clrw a3@+                         	/* 00040a */
	clrw a6@+                         	/* 00040c */
	dbf d4,LAB_0026                   	/* 00040e */
	moveal a4@(54),a3                 	/* 000412 */
	moveal a4@(26),a6                 	/* 000416 */
	addal a3,a6                       	/* 00041a */
	moveal a0,a1                      	/* 00041c */
	subal d6,a0                       	/* 00041e */
	movel d6,d7                       	/* 000420 */
	bsrw LAB_0038                     	/* 000422 */
	bras LAB_002A                     	/* 000426 */
LAB_0027:
	moveal a4@(26),a6                 	/* 000428 */
	addal a3,a6                       	/* 00042c */
	movew d4,d0                       	/* 00042e */
	subqw #1,d0                       	/* 000430 */
LAB_0028:
	clrw a3@+                         	/* 000432 */
	clrw a6@+                         	/* 000434 */
	subqw #1,d6                       	/* 000436 */
	bnes LAB_0029                     	/* 000438 */
	movew a4@(24),d6                  	/* 00043a */
	moveal a4@(54),a3                 	/* 00043e */
	moveal a4@(26),a6                 	/* 000442 */
	addal a3,a6                       	/* 000446 */
LAB_0029:
	dbf d0,LAB_0028                   	/* 000448 */
	movel d4,d7                       	/* 00044c */
	moveal a0,a1                      	/* 00044e */
	addal d7,a1                       	/* 000450 */
	bsrw LAB_0038                     	/* 000452 */
LAB_002A:
	moveml sp@+,d4/d7/a6              	/* 000456 */
	tstl d7                           	/* 00045a */
	beqs LAB_002B                     	/* 00045c */
	bsrw LAB_003D                     	/* 00045e */
	bras LAB_002C                     	/* 000462 */
LAB_002B:
	moveq #1,d1                       	/* 000464 */
	bsrw LAB_0043                     	/* 000466 */
LAB_002C:
	moveq #5,d0                       	/* 00046a */
	cmpl d0,d4                        	/* 00046c */
	bcss LAB_0031                     	/* 00046e */
	movel d4,d2                       	/* 000470 */
	moveq #12,d0                      	/* 000472 */
	cmpl d0,d2                        	/* 000474 */
	bccs LAB_002D                     	/* 000476 */
	subqw #5,d2                       	/* 000478 */
	movew d2,d1                       	/* 00047a */
	bsrw LAB_0041                     	/* 00047c */
	bras LAB_002F                     	/* 000480 */
LAB_002D:
	subl d0,d2                        	/* 000482 */
	divu #0x0007,d2                   	/* 000484 */
	swap d2                           	/* 000488 */
	movew d2,d1                       	/* 00048a */
	bsrw LAB_0041                     	/* 00048c */
	swap d2                           	/* 000490 */
LAB_002E:
	moveq #7,d1                       	/* 000492 */
	bsrw LAB_0041                     	/* 000494 */
	dbf d2,LAB_002E                   	/* 000498 */
LAB_002F:
	movew a4@(32),d2                  	/* 00049c */
	movew a4@(30),d1                  	/* 0004a0 */
	subqw #1,d1                       	/* 0004a4 */
	cmpiw #0x0080,d1                  	/* 0004a6 */
	bccs LAB_0030                     	/* 0004aa */
	moveq #7,d0                       	/* 0004ac */
	bsrw LAB_0045                     	/* 0004ae */
	moveq #0,d1                       	/* 0004b2 */
	moveq #1,d0                       	/* 0004b4 */
	bras LAB_0032                     	/* 0004b6 */
LAB_0030:
	movew a4@(0,d2:w),d0              	/* 0004b8 */
	bsrw LAB_0045                     	/* 0004bc */
	moveq #1,d1                       	/* 0004c0 */
	moveq #1,d0                       	/* 0004c2 */
	bras LAB_0032                     	/* 0004c4 */
LAB_0031:
	movew a4@(32),d2                  	/* 0004c6 */
	movew a4@(0,d2:w),d0              	/* 0004ca */
	movew a4@(30),d1                  	/* 0004ce */
	subqw #1,d1                       	/* 0004d2 */
LAB_0032:
	bsrw LAB_0045                     	/* 0004d4 */
	movew a4@(16,d2:w),d1             	/* 0004d8 */
	bsrw LAB_0042                     	/* 0004dc */
LAB_0033:
	cmpal a4@(42),a0                  	/* 0004e0 */
	bcsw LAB_001C                     	/* 0004e4 */
	bsrw LAB_003D                     	/* 0004e8 */
	cmpil #0x00000001,d5              	/* 0004ec */
	beqs LAB_0036                     	/* 0004f2 */
	moveq #0,d0                       	/* 0004f4 */
LAB_0034:
	addqb #1,d0                       	/* 0004f6 */
	lsll #1,d5                        	/* 0004f8 */
	bccs LAB_0034                     	/* 0004fa */
	movel d0,d7                       	/* 0004fc */
	moveq #0,d2                       	/* 0004fe */
	movel a4@(42),d3                  	/* 000500 */
	subqw #1,d0                       	/* 000504 */
LAB_0035:
	lsrl #1,d3                        	/* 000506 */
	roxll #1,d2                       	/* 000508 */
	dbf d0,LAB_0035                   	/* 00050a */
	orl d2,d5                         	/* 00050e */
	movel d5,a6@+                     	/* 000510 */
LAB_0036:
	cmpal a5,a6                       	/* 000512 */
	bccw LAB_0048                     	/* 000514 */
	movel a4@(38),d1                  	/* 000518 */
	lsll #8,d1                        	/* 00051c */
	orl d7,d1                         	/* 00051e */
	movel d1,a6@+                     	/* 000520 */
	movel a6,d0                       	/* 000522 */
	subl a4@(46),d0                   	/* 000524 */
LAB_0037:
	moveml sp@+,D1-D7/A1-A6           	/* 000528 */
	rts                               	/* 00052c */
LAB_0038:
	moveml d5/a5,sp@-                 	/* 00052e */
	moveal a4@(42),a5                 	/* 000532 */
	movel #0x00020000,d5              	/* 000536 */
	moveal a4@(58),a2                 	/* 00053c */
	moveq #0,d2                       	/* 000540 */
	movew a4@(14),d2                  	/* 000542 */
	addaw d2,a0                       	/* 000546 */
	addaw d2,a0                       	/* 000548 */
	subqw #1,d7                       	/* 00054a */
	moveq #0,d3                       	/* 00054c */
	subqw #1,a5                       	/* 00054e */
LAB_0039:
	cmpal a5,a0                       	/* 000550 */
	bccs LAB_003C                     	/* 000552 */
	moveq #0,d0                       	/* 000554 */
	moveb a0@,d0                      	/* 000556 */
	lslw #8,d0                        	/* 000558 */
	moveb a0@(1),d0                   	/* 00055a */
	movel d0,d4                       	/* 00055e */
	addl d5,d4                        	/* 000560 */
	addl d0,d0                        	/* 000562 */
	moveq #0,d1                       	/* 000564 */
	moveb a2@(0,d4:l),d1              	/* 000566 */
	swap d1                           	/* 00056a */
	movew a2@(0,d0:l),d1              	/* 00056c */
	tstl d1                           	/* 000570 */
	beqs LAB_003B                     	/* 000572 */
	movel a0,d3                       	/* 000574 */
	andil #0x00ffffff,d3              	/* 000576 */
	subl d1,d3                        	/* 00057c */
	movel a0,d1                       	/* 00057e */
	subl a1,d1                        	/* 000580 */
	subl d3,d1                        	/* 000582 */
	blts LAB_003B                     	/* 000584 */
	cmpw d2,d3                        	/* 000586 */
	bccs LAB_003B                     	/* 000588 */
	cmpw d6,d1                        	/* 00058a */
	bcss LAB_003A                     	/* 00058c */
	subw d2,d1                        	/* 00058e */
	subw d2,d1                        	/* 000590 */
LAB_003A:
	addw d1,d1                        	/* 000592 */
	movew d3,a3@(0,d1:w)              	/* 000594 */
	movew d3,a6@(0,d1:w)              	/* 000598 */
LAB_003B:
	movel a0,d1                       	/* 00059c */
	movew d1,a2@(0,d0:l)              	/* 00059e */
	swap d1                           	/* 0005a2 */
	moveb d1,a2@(0,d4:l)              	/* 0005a4 */
LAB_003C:
	addqw #1,a0                       	/* 0005a8 */
	dbf d7,LAB_0039                   	/* 0005aa */
	subaw d2,a0                       	/* 0005ae */
	subaw d2,a0                       	/* 0005b0 */
	moveml sp@+,d5/a5                 	/* 0005b2 */
	rts                               	/* 0005b6 */
LAB_003D:
	movel d7,d1                       	/* 0005b8 */
	movel d7,d2                       	/* 0005ba */
	moveq #4,d0                       	/* 0005bc */
	cmpl d0,d7                        	/* 0005be */
	bcss LAB_003F                     	/* 0005c0 */
	subql #4,d2                       	/* 0005c2 */
	divu #0x0003,d2                   	/* 0005c4 */
	swap d2                           	/* 0005c8 */
	movew d2,d1                       	/* 0005ca */
	bsrs LAB_0042                     	/* 0005cc */
	swap d2                           	/* 0005ce */
LAB_003E:
	moveq #3,d1                       	/* 0005d0 */
	bsrs LAB_0042                     	/* 0005d2 */
	dbf d2,LAB_003E                   	/* 0005d4 */
	bras LAB_0040                     	/* 0005d8 */
LAB_003F:
	subqb #1,d1                       	/* 0005da */
	bsrs LAB_0042                     	/* 0005dc */
LAB_0040:
	moveq #0,d1                       	/* 0005de */
	bsrs LAB_0043                     	/* 0005e0 */
	moveq #0,d7                       	/* 0005e2 */
	rts                               	/* 0005e4 */
LAB_0041:
	lsrl #1,d1                        	/* 0005e6 */
	addxl d5,d5                       	/* 0005e8 */
	bccs LAB_0042                     	/* 0005ea */
	movel d5,a6@+                     	/* 0005ec */
	moveq #1,d5                       	/* 0005ee */
	cmpal a5,a6                       	/* 0005f0 */
	bccs LAB_0048                     	/* 0005f2 */
LAB_0042:
	lsrl #1,d1                        	/* 0005f4 */
	addxl d5,d5                       	/* 0005f6 */
	bccs LAB_0043                     	/* 0005f8 */
	movel d5,a6@+                     	/* 0005fa */
	moveq #1,d5                       	/* 0005fc */
	cmpal a5,a6                       	/* 0005fe */
	bccs LAB_0048                     	/* 000600 */
LAB_0043:
	lsrl #1,d1                        	/* 000602 */
	addxl d5,d5                       	/* 000604 */
	bccs LAB_0044                     	/* 000606 */
	movel d5,a6@+                     	/* 000608 */
	moveq #1,d5                       	/* 00060a */
	cmpal a5,a6                       	/* 00060c */
	bccs LAB_0048                     	/* 00060e */
LAB_0044:
	rts                               	/* 000610 */
LAB_0045:
	subqw #1,d0                       	/* 000612 */
LAB_0046:
	lsrl #1,d1                        	/* 000614 */
	addxl d5,d5                       	/* 000616 */
	dbcs d0,LAB_0046                  	/* 000618 */
	bcss LAB_0047                     	/* 00061c */
	rts                               	/* 00061e */
LAB_0047:
	movel d5,a6@+                     	/* 000620 */
	moveq #1,d5                       	/* 000622 */
	cmpal a5,a6                       	/* 000624 */
	bccs LAB_0048                     	/* 000626 */
	dbf d0,LAB_0046                   	/* 000628 */
	rts                               	/* 00062c */
LAB_0048:
	moveal a4@(50),sp                 	/* 00062e */
	moveq #-1,d0                      	/* 000632 */
	braw LAB_0037                     	/* 000634 */
LIBFUNC_5:
	moveml D2-D7/A2-A6,sp@-           	/* 000638 */
	moveal a0,a5                      	/* 00063c */
	.byte 0x26,0x6d,0x00,0x00	/* MOVEA.L	0(A5),A3 */
	moveal a5@(8),a4                  	/* 000642 */
	movel a5@(4),d7                   	/* 000646 */
	movel a5@(32),d5                  	/* 00064a */
	moveq #0,d6                       	/* 00064e */
	tstl a5@(52)                      	/* 000650 */
	bnes LAB_004B                     	/* 000654 */
	movel a0,a5@(52)                  	/* 000656 */
	tstl d5                           	/* 00065a */
	beqs LAB_004A                     	/* 00065c */
	moveal d5,a0                      	/* 00065e */
	bsrw LAB_006A                     	/* 000660 */
	cmpl a3@(-4,d7:l),d0              	/* 000664 */
	bnes LAB_004E                     	/* 000668 */
	moveal d5,a0                      	/* 00066a */
	bsrw LAB_0068                     	/* 00066c */
	movel d0,a5@(60)                  	/* 000670 */
	moveq #4,d6                       	/* 000674 */
LAB_004A:
	movel d7,d0                       	/* 000676 */
	subl d6,d0                        	/* 000678 */
	movel a3@(-4,d0:l),a5@(56)        	/* 00067a */
	addql #4,d6                       	/* 000680 */
LAB_004B:
	tstl d5                           	/* 000682 */
	beqs LAB_004C                     	/* 000684 */
	movel d7,d0                       	/* 000686 */
	subl d6,d0                        	/* 000688 */
	subql #4,d0                       	/* 00068a */
	moveal a3,a0                      	/* 00068c */
	movel a5@(60),d1                  	/* 00068e */
	bsrw LAB_006C                     	/* 000692 */
LAB_004C:
	subl d6,d7                        	/* 000696 */
	lea a3@(0,d7:l),a0                	/* 000698 */
	movel a5@(56),d0                  	/* 00069c */
	asll #2,d0                        	/* 0006a0 */
	.byte 0x45,0xfb,0x00,0x14	/* LEA	LAB_004F(PC,D0.W),A2 */
	moveal a4,a1                      	/* 0006a6 */
	movel d7,d0                       	/* 0006a8 */
	bsrs LAB_0050                     	/* 0006aa */
	moveq #0,d0                       	/* 0006ac */
LAB_004D:
	moveml sp@+,D2-D7/A2-A6           	/* 0006ae */
	rts                               	/* 0006b2 */
LAB_004E:
	moveq #-32,d0                     	/* 0006b4 */
	bras LAB_004D                     	/* 0006b6 */
LAB_004F:
	.byte 0x09
	.byte 0x09
	.byte 0x09
	.byte 0x09
	.byte 0x09
	.byte 0x0a
	.byte 0x0a
	.byte 0x0a
	.byte 0x09
	.byte 0x0a
	.byte 0x0b
	.byte 0x0b
	.byte 0x09
	.byte 0x0a
	.byte 0x0c
	.byte 0x0c
	.byte 0x09
	.byte 0x0a
	.byte 0x0c
	.byte 0x0d
LAB_0050:
	moveml D2-D7/A2-A6,sp@-           	/* 0006cc */
	lea %pc@(LAB_0067),a5             	/* 0006d0 */
	moveq #24,d6                      	/* 0006d4 */
	moveq #0,d4                       	/* 0006d6 */
	movew #0x00ff,d7                  	/* 0006d8 */
	moveq #1,d5                       	/* 0006dc */
	moveal a1,a4                      	/* 0006de */
	movel a0@-,d1                     	/* 0006e0 */
	tstb d1                           	/* 0006e2 */
	beqs LAB_0051                     	/* 0006e4 */
	lsrl #1,d5                        	/* 0006e6 */
	movel a0@-,d5                     	/* 0006e8 */
	roxrl #1,d5                       	/* 0006ea */
	subqb #1,d1                       	/* 0006ec */
	lsrl d1,d5                        	/* 0006ee */
LAB_0051:
	lsrl #8,d1                        	/* 0006f0 */
	addal d1,a1                       	/* 0006f2 */
LAB_0052:
	lsrl #1,d5                        	/* 0006f4 */
	bnes LAB_0053                     	/* 0006f6 */
	movel a0@-,d5                     	/* 0006f8 */
	roxrl #1,d5                       	/* 0006fa */
LAB_0053:
	bcss LAB_0059                     	/* 0006fc */
	moveq #0,d2                       	/* 0006fe */
LAB_0054:
	moveq #0,d1                       	/* 000700 */
	lsrl #1,d5                        	/* 000702 */
	bnes LAB_0055                     	/* 000704 */
	movel a0@-,d5                     	/* 000706 */
	roxrl #1,d5                       	/* 000708 */
LAB_0055:
	addxw d1,d1                       	/* 00070a */
	lsrl #1,d5                        	/* 00070c */
	bnes LAB_0056                     	/* 00070e */
	movel a0@-,d5                     	/* 000710 */
	roxrl #1,d5                       	/* 000712 */
LAB_0056:
	addxw d1,d1                       	/* 000714 */
	addw d1,d2                        	/* 000716 */
	subqw #3,d1                       	/* 000718 */
	beqs LAB_0054                     	/* 00071a */
	moveq #0,d0                       	/* 00071c */
LAB_0057:
	moveb d5,d4                       	/* 00071e */
	lsrl #8,d5                        	/* 000720 */
	bnes LAB_0058                     	/* 000722 */
	moveb a5@(127,d4:w),d0            	/* 000724 */
	movel a0@-,d5                     	/* 000728 */
	movew d5,d3                       	/* 00072a */
	lslw d0,d3                        	/* 00072c */
	bchg d0,d3                        	/* 00072e */
	eorw d3,d4                        	/* 000730 */
	andw d7,d4                        	/* 000732 */
	moveq #8,d1                       	/* 000734 */
	subw d0,d1                        	/* 000736 */
	lsrl d1,d5                        	/* 000738 */
	addw d6,d0                        	/* 00073a */
	bset d0,d5                        	/* 00073c */
LAB_0058:
	moveb a5@(-128,d4:w),d0           	/* 00073e */
	moveb d0,a1@-                     	/* 000742 */
	dbf d2,LAB_0057                   	/* 000744 */
	cmpal a1,a4                       	/* 000748 */
	bccw LAB_0066                     	/* 00074a */
LAB_0059:
	moveq #0,d2                       	/* 00074e */
	lsrl #1,d5                        	/* 000750 */
	bnes LAB_005A                     	/* 000752 */
	movel a0@-,d5                     	/* 000754 */
	roxrl #1,d5                       	/* 000756 */
LAB_005A:
	addxw d2,d2                       	/* 000758 */
	lsrl #1,d5                        	/* 00075a */
	bnes LAB_005B                     	/* 00075c */
	movel a0@-,d5                     	/* 00075e */
	roxrl #1,d5                       	/* 000760 */
LAB_005B:
	addxw d2,d2                       	/* 000762 */
	moveb d5,d4                       	/* 000764 */
	lsrl #8,d5                        	/* 000766 */
	bnes LAB_005C                     	/* 000768 */
	moveb a5@(127,d4:w),d0            	/* 00076a */
	movel a0@-,d5                     	/* 00076e */
	movew d5,d3                       	/* 000770 */
	lslw d0,d3                        	/* 000772 */
	bchg d0,d3                        	/* 000774 */
	eorw d3,d4                        	/* 000776 */
	andw d7,d4                        	/* 000778 */
	moveq #8,d1                       	/* 00077a */
	subw d0,d1                        	/* 00077c */
	lsrl d1,d5                        	/* 00077e */
	addw d6,d0                        	/* 000780 */
	bset d0,d5                        	/* 000782 */
LAB_005C:
	moveq #0,d3                       	/* 000784 */
	moveb a5@(-128,d4:w),d3           	/* 000786 */
	cmpiw #0x0003,d2                  	/* 00078a */
	bnes LAB_0062                     	/* 00078e */
	bclr #7,d3                        	/* 000790 */
	beqs LAB_005E                     	/* 000794 */
	moveq #13,d0                      	/* 000796 */
	subb a2@(0,d2:w),d0               	/* 000798 */
	movew d0,d1                       	/* 00079c */
	lslw #3,d0                        	/* 00079e */
	addw d1,d0                        	/* 0007a0 */
	addw d1,d0                        	/* 0007a2 */
	.byte 0x4e,0xfb,0x00,0x02	/* JMP	LAB_005D(PC,D0.W) */
LAB_005D:
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43,0xe2,0x8d
	.byte 0x66,0x04,0x2a,0x20
	.byte 0xe2,0x95,0xd7,0x43
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43,0xe2,0x8d
	.byte 0x66,0x04,0x2a,0x20
	.byte 0xe2,0x95,0xd7,0x43
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43,0xe2,0x8d
	.byte 0x66,0x04,0x2a,0x20
	.byte 0xe2,0x95,0xd7,0x43
LAB_005E:
	moveq #0,d1                       	/* 0007e4 */
	lsrl #1,d5                        	/* 0007e6 */
	bnes LAB_005F                     	/* 0007e8 */
	movel a0@-,d5                     	/* 0007ea */
	roxrl #1,d5                       	/* 0007ec */
LAB_005F:
	addxw d1,d1                       	/* 0007ee */
	lsrl #1,d5                        	/* 0007f0 */
	bnes LAB_0060                     	/* 0007f2 */
	movel a0@-,d5                     	/* 0007f4 */
	roxrl #1,d5                       	/* 0007f6 */
LAB_0060:
	addxw d1,d1                       	/* 0007f8 */
	lsrl #1,d5                        	/* 0007fa */
	bnes LAB_0061                     	/* 0007fc */
	movel a0@-,d5                     	/* 0007fe */
	roxrl #1,d5                       	/* 000800 */
LAB_0061:
	addxw d1,d1                       	/* 000802 */
	addw d1,d2                        	/* 000804 */
	subqw #7,d1                       	/* 000806 */
	beqs LAB_005E                     	/* 000808 */
	bras LAB_0064                     	/* 00080a */
LAB_0062:
	moveq #13,d0                      	/* 00080c */
	subb a2@(0,d2:w),d0               	/* 00080e */
	movew d0,d1                       	/* 000812 */
	lslw #3,d0                        	/* 000814 */
	addw d1,d0                        	/* 000816 */
	addw d1,d0                        	/* 000818 */
	.byte 0x4e,0xfb,0x00,0x02	/* JMP	LAB_0063(PC,D0.W) */
LAB_0063:
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43,0xe2,0x8d
	.byte 0x66,0x04,0x2a,0x20
	.byte 0xe2,0x95,0xd7,0x43
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43,0xe2,0x8d
	.byte 0x66,0x04,0x2a,0x20
	.byte 0xe2,0x95,0xd7,0x43
	.byte 0xe2,0x8d,0x66,0x04
	.byte 0x2a,0x20,0xe2,0x95
	.byte 0xd7,0x43
LAB_0064:
	moveb a1@(0,d3:w),a1@-            	/* 000850 */
LAB_0065:
	moveb a1@(0,d3:w),a1@-            	/* 000854 */
	dbf d2,LAB_0065                   	/* 000858 */
	cmpal a1,a4                       	/* 00085c */
	bcsw LAB_0052                     	/* 00085e */
LAB_0066:
	moveml sp@+,D2-D7/A2-A6           	/* 000862 */
	rts                               	/* 000866 */
	.byte 0x00,0x80,0x40,0xc0
	.byte 0x20,0xa0,0x60,0xe0
	.byte 0x10,0x90,0x50,0xd0
	.byte 0x30,0xb0,0x70,0xf0
	.byte 0x08,0x88,0x48,0xc8
	.byte 0x28,0xa8,0x68,0xe8
	.byte 0x18,0x98,0x58,0xd8
	.byte 0x38,0xb8,0x78,0xf8
	.byte 0x04,0x84,0x44,0xc4
	.byte 0x24,0xa4,0x64,0xe4
	.byte 0x14,0x94,0x54,0xd4
	.byte 0x34,0xb4,0x74,0xf4
	.byte 0x0c,0x8c,0x4c,0xcc
	.byte 0x2c,0xac,0x6c,0xec
	.byte 0x1c,0x9c,0x5c,0xdc
	.byte 0x3c,0xbc,0x7c,0xfc
	.byte 0x02,0x82,0x42,0xc2
	.byte 0x22,0xa2,0x62,0xe2
	.byte 0x12,0x92,0x52,0xd2
	.byte 0x32,0xb2,0x72,0xf2
	.byte 0x0a,0x8a,0x4a,0xca
	.byte 0x2a,0xaa,0x6a,0xea
	.byte 0x1a,0x9a,0x5a,0xda
	.byte 0x3a,0xba,0x7a,0xfa
	.byte 0x06,0x86,0x46,0xc6
	.byte 0x26,0xa6,0x66,0xe6
	.byte 0x16,0x96,0x56,0xd6
	.byte 0x36,0xb6,0x76,0xf6
	.byte 0x0e,0x8e,0x4e,0xce
	.byte 0x2e,0xae,0x6e,0xee
	.byte 0x1e,0x9e,0x5e,0xde
	.byte 0x3e,0xbe,0x7e,0xfe
LAB_0067:
	.byte 0x01,0x81,0x41,0xc1
	.byte 0x21,0xa1,0x61,0xe1
	.byte 0x11,0x91,0x51,0xd1
	.byte 0x31,0xb1,0x71,0xf1
	.byte 0x09,0x89,0x49,0xc9
	.byte 0x29,0xa9,0x69,0xe9
	.byte 0x19,0x99,0x59,0xd9
	.byte 0x39,0xb9,0x79,0xf9
	.byte 0x05,0x85,0x45,0xc5
	.byte 0x25,0xa5,0x65,0xe5
	.byte 0x15,0x95,0x55,0xd5
	.byte 0x35,0xb5,0x75,0xf5
	.byte 0x0d,0x8d,0x4d,0xcd
	.byte 0x2d,0xad,0x6d,0xed
	.byte 0x1d,0x9d,0x5d,0xdd
	.byte 0x3d,0xbd,0x7d,0xfd
	.byte 0x03,0x83,0x43,0xc3
	.byte 0x23,0xa3,0x63,0xe3
	.byte 0x13,0x93,0x53,0xd3
	.byte 0x33,0xb3,0x73,0xf3
	.byte 0x0b,0x8b,0x4b,0xcb
	.byte 0x2b,0xab,0x6b,0xeb
	.byte 0x1b,0x9b,0x5b,0xdb
	.byte 0x3b,0xbb,0x7b,0xfb
	.byte 0x07,0x87,0x47,0xc7
	.byte 0x27,0xa7,0x67,0xe7
	.byte 0x17,0x97,0x57,0xd7
	.byte 0x37,0xb7,0x77,0xf7
	.byte 0x0f,0x8f,0x4f,0xcf
	.byte 0x2f,0xaf,0x6f,0xef
	.byte 0x1f,0x9f,0x5f,0xdf
	.byte 0x3f,0xbf,0x7f,0xff
	.byte 0x00,0x01,0x01,0x02
	.byte 0x02,0x02,0x02,0x03
	.byte 0x03,0x03,0x03,0x03
	.byte 0x03,0x03,0x03,0x04
	.byte 0x04,0x04,0x04,0x04
	.byte 0x04,0x04,0x04,0x04
	.byte 0x04,0x04,0x04,0x04
	.byte 0x04,0x04,0x04,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x05
	.byte 0x05,0x05,0x05,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x06
	.byte 0x06,0x06,0x06,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x07
	.byte 0x07,0x07,0x07,0x00
LAB_0068:
	moveq #0,d0                       	/* 000a68 */
	moveq #0,d1                       	/* 000a6a */
LAB_0069:
	roll #1,d0                        	/* 000a6c */
	addl d1,d0                        	/* 000a6e */
	swap d0                           	/* 000a70 */
	moveb a0@+,d1                     	/* 000a72 */
	bnes LAB_0069                     	/* 000a74 */
	rts                               	/* 000a76 */
LAB_006A:
	moveq #0,d0                       	/* 000a78 */
	moveq #0,d1                       	/* 000a7a */
LAB_006B:
	rorw d1,d0                        	/* 000a7c */
	addw d1,d0                        	/* 000a7e */
	moveb a0@+,d1                     	/* 000a80 */
	bnes LAB_006B                     	/* 000a82 */
	rts                               	/* 000a84 */
LAB_006C:
	movel d2,sp@-                     	/* 000a86 */
	addql #3,d0                       	/* 000a88 */
	lsrl #2,d0                        	/* 000a8a */
LAB_006D:
	movel a0@,d2                      	/* 000a8c */
	eorl d1,d2                        	/* 000a8e */
	movel d2,a0@+                     	/* 000a90 */
	subql #1,d0                       	/* 000a92 */
	bnes LAB_006D                     	/* 000a94 */
	movel sp@+,d2                     	/* 000a96 */
	rts                               	/* 000a98 */
LAB_006E:
	.byte 0x00,0x01,0x00,0x01
	.byte 0x00,0x02,0x00,0x00
	.long LAB_0074	/* =00000bc4 */
	.long LAB_0075	/* =00000bca */
	.long LAB_0076	/* =00000bda */
	.byte 0x50,0x57,0x50,0x4b
	.byte 0x00,0x02,0xa0,0x09
	.byte 0x00,0x7f,0xff,0xff
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x01,0x00,0x00
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 0x00,0x64,0x00,0x00
	.long LAB_006F	/* =00000af2 */
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
LAB_006F:
	.long LAB_0070	/* =00000b1c */
	.byte 0x00,0x00,0x00,0x14
	.byte 0x00,0x00,0x00,0x01
	.byte 0x00,0x03,0x10,0x46
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x12
	.byte 0x00,0x00,0x00,0xd2
	.byte 0x01,0x8d,0x00,0x00
	.byte 0x46,0x61,0x73,0x74
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00
LAB_0070:
	.long LAB_0071	/* =00000b46 */
	.byte 0x00,0x00,0x00,0x28
	.byte 0x00,0x00,0x00,0x01
	.byte 0x00,0x03,0x20,0x46
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x11
	.byte 0x00,0x00,0x00,0xd0
	.byte 0x01,0x9f,0x00,0x00
	.byte 0x4d,0x65,0x64,0x69
	.byte 0x6f,0x63,0x72,0x65
	.byte 0x00,0x00
LAB_0071:
	.long LAB_0072	/* =00000b70 */
	.byte 0x00,0x00,0x00,0x3c
	.byte 0x00,0x00,0x00,0x01
	.byte 0x00,0x03,0x40,0x46
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x0e
	.byte 0x00,0x00,0x00,0xd2
	.byte 0x01,0xac,0x00,0x00
	.byte 0x47,0x6f,0x6f,0x64
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00
LAB_0072:
	.long LAB_0073	/* =00000b9a */
	.byte 0x00,0x00,0x00,0x50
	.byte 0x00,0x00,0x00,0x01
	.byte 0x00,0x03,0x80,0x46
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x0b
	.byte 0x00,0x00,0x00,0xd2
	.byte 0x01,0xb6,0x00,0x00
	.byte 0x56,0x65,0x72,0x79
	.byte 0x20,0x47,0x6f,0x6f
	.byte 0x64,0x00
LAB_0073:
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x64
	.byte 0x00,0x00,0x00,0x01
	.byte 0x00,0x04,0x00,0x46
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00,0x00,0x09
	.byte 0x00,0x00,0x00,0xd3
	.byte 0x01,0xba,0x00,0x00
	.byte 0x42,0x65,0x73,0x74
	.byte 0x00,0x00,0x00,0x00
	.byte 0x00,0x00
LAB_0074:
	.byte 0x78,0x70,0x6b,0x50,0x50	/* "xpkPP" */
	.byte 0x00
LAB_0075:
	.byte 0x50,0x6f,0x77,0x65,0x72,0x50,0x61,0x63,0x6b,0x65,0x72,0x20,0x31,0x2e,0x32	/* "PowerPacker 1.2" */
	.byte 0x00
LAB_0076:
	.byte 0x42,0x61,0x73,0x65,0x64,0x20,0x6f,0x6e,0x20,0x70,0x6f,0x77,0x65,0x72,0x70,0x61,0x63,0x6b,0x65,0x72,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79	/* "Based on powerpacker.library" */
	.byte 0x00
	.byte 0x00
	.byte 	/* END */
