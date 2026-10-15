	.section .text
SECSTRT_0:
	moveq #0,d0                       	/* 000000 */
	rts                               	/* 000002 */
ROMTAG:
	.byte 0x4a,0xfc
	.long ROMTAG	/* =00000004 */
	.long ENDSKIP	/* =0000001e */
	.byte 0x80,0x01,0x09,0x00
	.long BITMAPLIBNAME	/* =000009d0 */
	.long IDSTRING	/* =000009e0 */
	.long INIT	/* =00000004 */
ENDSKIP:
	.byte 0x00,0x00
INITFUNCTION:
	subqw #8,sp                       	/* 000020 */
	moveml d7/a2-a3/a5-a6,sp@-        	/* 000022 */
	moveal d0,a5                      	/* 000026 */
	movel a0,a5@(34)                  	/* 000028 */
	moveb #0x09,a5@(8)                	/* 00002c */
	movel #BITMAPLIBNAME,a5@(10)      	/* 000032 */
	moveb #0x06,a5@(14)               	/* 00003a */
	lea 0x1:l:l,a1                    	/* 000040 */
	movel a1,d0                       	/* 000046 */
	lea a5@(20),a0                    	/* 000048 */
	movew d0,a0@+                     	/* 00004c */
	lea 0x4:l:l,a1                    	/* 00004e */
	movel a1,d0                       	/* 000054 */
	movew d0,a0@+                     	/* 000056 */
	movel #IDSTRING,a0@+              	/* 000058 */
	lea a5@(48),a3                    	/* 00005e */
	lea 0xa:l:l,a1                    	/* 000062 */
	movel a1,d0                       	/* 000068 */
	movel d0,d1                       	/* 00006a */
	asll #2,d1                        	/* 00006c */
	movel a6,sp@(24)                  	/* 00006e */
	lea SECSTRT_1:l,a1                	/* 000072 */
	moveal a3,a6                      	/* 000078 */
LAB_0004:
	cmpiw #0x1cd9,d0                  	/* 00007a */
	subql #1,d1                       	/* 00007e */
	bccs LAB_0004+2                   	/* 000080 */
	asll #2,d0                        	/* 000082 */
	lea SECSTRT_1:l,a0                	/* 000084 */
	addal d0,a0                       	/* 00008a */
	movel a0@,d7                      	/* 00008c */
	lea a0@(4),a2                     	/* 00008e */
	moveal sp@(24),a6                 	/* 000092 */
	bras LAB_0006                     	/* 000096 */
LAB_0005:
	movel a3,d0                       	/* 000098 */
	addl a2@+,d0                      	/* 00009a */
	movel a3,d1                       	/* 00009c */
	moveal d0,a0                      	/* 00009e */
	addl d1,a0@                       	/* 0000a0 */
	subql #1,d7                       	/* 0000a2 */
LAB_0006:
	tstl d7                           	/* 0000a4 */
	bgts LAB_0005                     	/* 0000a6 */
	moveal a5,a6                      	/* 0000a8 */
	bsrw LAB_000D                     	/* 0000aa */
	tstl d0                           	/* 0000ae */
	moveal sp@(24),a6                 	/* 0000b0 */
	beqs LAB_0007+2                   	/* 0000b4 */
	moveq #0,d0                       	/* 0000b6 */
LAB_0007:
	cmpiw #0x200d,d0                  	/* 0000b8 */
	moveml sp@+,d7/a2-a3/a5-a6        	/* 0000bc */
	addqw #8,sp                       	/* 0000c0 */
	rts                               	/* 0000c2 */
OPEN:
	subqw #4,sp                       	/* 0000c4 */
	addqw #1,a6@(32)                  	/* 0000c6 */
	bclr #3,a6@(14)                   	/* 0000ca */
	movel a6,d0                       	/* 0000d0 */
	addqw #4,sp                       	/* 0000d2 */
	rts                               	/* 0000d4 */
CLOSE:
	subqw #4,sp                       	/* 0000d6 */
	movel d7,sp@-                     	/* 0000d8 */
	moveq #0,d7                       	/* 0000da */
	subqw #1,a6@(32)                  	/* 0000dc */
	movel a6,sp@(4)                   	/* 0000e0 */
	tstw a6@(32)                      	/* 0000e4 */
	bnes LAB_000A                     	/* 0000e8 */
	btst #3,a6@(14)                   	/* 0000ea */
	beqs LAB_000A                     	/* 0000f0 */
	bsrw EXPUNGE                      	/* 0000f2 */
	movel d0,d7                       	/* 0000f6 */
LAB_000A:
	movel d7,d0                       	/* 0000f8 */
	movel sp@+,d7                     	/* 0000fa */
	addqw #4,sp                       	/* 0000fc */
	rts                               	/* 0000fe */
EXPUNGE:
	subqw #4,sp                       	/* 000100 */
	moveml d2/d7/a5-a6,sp@-           	/* 000102 */
	moveal a6,a5                      	/* 000106 */
	moveq #0,d7                       	/* 000108 */
	bset #3,a5@(14)                   	/* 00010a */
	movel a6,sp@(16)                  	/* 000110 */
	tstw a5@(32)                      	/* 000114 */
	bnes LAB_000C                     	/* 000118 */
	moveal a5,a6                      	/* 00011a */
	bsrw LAB_000F                     	/* 00011c */
	movel a5@(34),d7                  	/* 000120 */
	moveal a5,a1                      	/* 000124 */
	moveal 0x4:w,a6                   	/* 000126 */
	jsr a6@(-252)                     	/* 00012a */
	moveq #0,d0                       	/* 00012e */
	movew a5@(18),d0                  	/* 000130 */
	moveq #0,d1                       	/* 000134 */
	movew a5@(16),d1                  	/* 000136 */
	movel d1,d2                       	/* 00013a */
	addl d0,d2                        	/* 00013c */
	moveal a5,a1                      	/* 00013e */
	moveq #0,d0                       	/* 000140 */
	movew d1,d0                       	/* 000142 */
	subal d0,a1                       	/* 000144 */
	movel d2,d0                       	/* 000146 */
	jsr a6@(-210)                     	/* 000148 */
LAB_000C:
	movel d7,d0                       	/* 00014c */
	moveml sp@+,d2/d7/a5-a6           	/* 00014e */
	addqw #4,sp                       	/* 000152 */
	rts                               	/* 000154 */
	.byte 0x4e,0x71
LAB_000D:
	subqw #8,sp                       	/* 000158 */
	moveml a4/a6,sp@-                 	/* 00015a */
	movel a6,sp@(8)                   	/* 00015e */
	lea a6@(48),a4                    	/* 000162 */
	movel a6,sp@(12)                  	/* 000166 */
	lea a4@(20),a1                    	/* 00016a */
	moveq #0,d0                       	/* 00016e */
	moveal 0x4:w,a6                   	/* 000170 */
	jsr a6@(-552)                     	/* 000174 */
	movel d0,a4@(44)                  	/* 000178 */
	moveal sp@(12),a6                 	/* 00017c */
	beqs LAB_000E+2                   	/* 000180 */
	moveq #0,d0                       	/* 000182 */
LAB_000E:
	cmpiw #0x7001,d0                  	/* 000184 */
	moveml sp@+,a4/a6                 	/* 000188 */
	addqw #8,sp                       	/* 00018c */
	rts                               	/* 00018e */
LAB_000F:
	subqw #8,sp                       	/* 000190 */
	moveml a4/a6,sp@-                 	/* 000192 */
	movel a6,sp@(8)                   	/* 000196 */
	lea a6@(48),a4                    	/* 00019a */
	movel a6,sp@(12)                  	/* 00019e */
	moveal a4@(44),a1                 	/* 0001a2 */
	moveal 0x4:w,a6                   	/* 0001a6 */
	jsr a6@(-414)                     	/* 0001aa */
	moveml sp@+,a4/a6                 	/* 0001ae */
	addqw #8,sp                       	/* 0001b2 */
	rts                               	/* 0001b4 */
LIBFUNC_0:
	subqw #4,sp                       	/* 0001b6 */
	moveml D6-D7/A3-A6,sp@-           	/* 0001b8 */
	moveal a1,a5                      	/* 0001bc */
	lea a6@(48),a4                    	/* 0001be */
	movel a6,sp@(24)                  	/* 0001c2 */
	movel a5,d0                       	/* 0001c6 */
	beqs LAB_0015                     	/* 0001c8 */
	moveal a4@(44),a0                 	/* 0001ca */
	cmpiw #0x0027,a0@(20)             	/* 0001ce */
	bcss LAB_0011                     	/* 0001d4 */
	moveal a5,a0                      	/* 0001d6 */
	moveal a4@(44),a6                 	/* 0001d8 */
	jsr a6@(-924)                     	/* 0001dc */
	moveal sp@(24),a6                 	/* 0001e0 */
	bras LAB_0015                     	/* 0001e4 */
LAB_0011:
	movew a5@,d0                      	/* 0001e6 */
	mulu a5@(2),d0                    	/* 0001e8 */
	movel d0,d7                       	/* 0001ec */
	moveq #0,d6                       	/* 0001ee */
	moveal a5,a3                      	/* 0001f0 */
	bras LAB_0014                     	/* 0001f2 */
LAB_0012:
	tstl a3@(8)                       	/* 0001f4 */
	beqs LAB_0013                     	/* 0001f8 */
	movel d6,d0                       	/* 0001fa */
	asll #2,d0                        	/* 0001fc */
	moveal a5@(8,d0:l),a1             	/* 0001fe */
	movel d7,d0                       	/* 000202 */
	moveal 0x4:w,a6                   	/* 000204 */
	jsr a6@(-210)                     	/* 000208 */
LAB_0013:
	addql #1,d6                       	/* 00020c */
	addql #4,a3                       	/* 00020e */
	moveal sp@(24),a6                 	/* 000210 */
LAB_0014:
	moveq #0,d0                       	/* 000214 */
	moveb a5@(5),d0                   	/* 000216 */
	cmpl d0,d6                        	/* 00021a */
	bcss LAB_0012                     	/* 00021c */
	moveal a5,a1                      	/* 00021e */
	moveq #40,d0                      	/* 000220 */
	moveal 0x4:w,a6                   	/* 000222 */
	jsr a6@(-210)                     	/* 000226 */
LAB_0015:
	moveml sp@+,D6-D7/A3-A6           	/* 00022a */
	addqw #4,sp                       	/* 00022e */
	rts                               	/* 000230 */
LIBFUNC_1:
	subqw #8,sp                       	/* 000232 */
	moveml D2-D3/D5/D7/A2-A6,sp@-     	/* 000234 */
	movel d1,d3                       	/* 000238 */
	movel d0,d7                       	/* 00023a */
	lea a6@(48),a4                    	/* 00023c */
	moveq #0,d0                       	/* 000240 */
	movew d7,d0                       	/* 000242 */
	moveq #15,d1                      	/* 000244 */
	addl d1,d0                        	/* 000246 */
	lsrl #3,d0                        	/* 000248 */
	andil #0x0000fffe,d0              	/* 00024a */
	moveq #0,d1                       	/* 000250 */
	movew d3,d1                       	/* 000252 */
	bsrw LAB_0066                     	/* 000254 */
	movel d0,d5                       	/* 000258 */
	moveb d2,sp@(39)                  	/* 00025a */
	movel a6,sp@(40)                  	/* 00025e */
	moveal a4@(44),a0                 	/* 000262 */
	cmpiw #0x0027,a0@(20)             	/* 000266 */
	bcss LAB_0017                     	/* 00026c */
	moveq #0,d0                       	/* 00026e */
	movew d7,d0                       	/* 000270 */
	moveq #0,d1                       	/* 000272 */
	movew d3,d1                       	/* 000274 */
	moveq #0,d3                       	/* 000276 */
	moveb d2,d3                       	/* 000278 */
	movel d3,d2                       	/* 00027a */
	moveq #11,d3                      	/* 00027c */
	subal a0,a0                       	/* 00027e */
	moveal a4@(44),a6                 	/* 000280 */
	jsr a6@(-918)                     	/* 000284 */
	bras LAB_001C                     	/* 000288 */
LAB_0017:
	moveq #40,d0                      	/* 00028a */
	moveq #1,d1                       	/* 00028c */
	swap d1                           	/* 00028e */
	moveal 0x4:w,a6                   	/* 000290 */
	jsr a6@(-198)                     	/* 000294 */
	moveal d0,a5                      	/* 000298 */
	moveal sp@(40),a6                 	/* 00029a */
	tstl d0                           	/* 00029e */
	beqs LAB_001A                     	/* 0002a0 */
	moveq #0,d0                       	/* 0002a2 */
	moveb d2,d0                       	/* 0002a4 */
	moveq #0,d1                       	/* 0002a6 */
	movew d7,d1                       	/* 0002a8 */
	moveq #0,d2                       	/* 0002aa */
	movew d3,d2                       	/* 0002ac */
	moveal a5,a0                      	/* 0002ae */
	moveal a4@(44),a6                 	/* 0002b0 */
	jsr a6@(-390)                     	/* 0002b4 */
	moveq #0,d2                       	/* 0002b8 */
	moveal a5,a3                      	/* 0002ba */
	moveal sp@(40),a6                 	/* 0002bc */
	bras LAB_0019                     	/* 0002c0 */
LAB_0018:
	movel d5,d0                       	/* 0002c2 */
	movel #0x00010002,d1              	/* 0002c4 */
	moveal 0x4:w,a6                   	/* 0002ca */
	jsr a6@(-198)                     	/* 0002ce */
	moveal d0,a2                      	/* 0002d2 */
	tstl d0                           	/* 0002d4 */
	moveal sp@(40),a6                 	/* 0002d6 */
	beqs LAB_001B                     	/* 0002da */
	movel a2,a3@(8)                   	/* 0002dc */
	addql #1,d2                       	/* 0002e0 */
	addql #4,a3                       	/* 0002e2 */
LAB_0019:
	moveq #0,d0                       	/* 0002e4 */
	moveb sp@(39),d0                  	/* 0002e6 */
	cmpl d0,d2                        	/* 0002ea */
	bcss LAB_0018                     	/* 0002ec */
	movel a5,d0                       	/* 0002ee */
	bras LAB_001C                     	/* 0002f0 */
LAB_001A:
	moveal sp@(40),a6                 	/* 0002f2 */
LAB_001B:
	moveal a5,a1                      	/* 0002f6 */
	bsrw LIBFUNC_0                    	/* 0002f8 */
	moveq #0,d0                       	/* 0002fc */
LAB_001C:
	moveml sp@+,D2-D3/D5/D7/A2-A6     	/* 0002fe */
	addqw #8,sp                       	/* 000302 */
	rts                               	/* 000304 */
LIBFUNC_2:
	subaw #0x0014,sp                  	/* 000306 */
	moveml D2-D7/A2-A6,sp@-           	/* 00030a */
	moveal a1,a5                      	/* 00030e */
	lea a6@(48),a4                    	/* 000310 */
	movel a6,sp@(60)                  	/* 000314 */
	movew a5@(14),d0                  	/* 000318 */
	beqs LAB_001E                     	/* 00031c */
	tstw a5@(18)                      	/* 00031e */
	beqs LAB_001E                     	/* 000322 */
	movew a5@(12),d1                  	/* 000324 */
	beqs LAB_001E                     	/* 000328 */
	tstw a5@(16)                      	/* 00032a */
	bnes LAB_001F                     	/* 00032e */
LAB_001E:
	moveq #0,d0                       	/* 000330 */
	braw LAB_0031                     	/* 000332 */
LAB_001F:
	tstl a5@(8)                       	/* 000336 */
	moveal sp@(60),a6                 	/* 00033a */
	bnes LAB_0020                     	/* 00033e */
	moveq #0,d1                       	/* 000340 */
	movew d0,d1                       	/* 000342 */
	moveq #0,d2                       	/* 000344 */
	movew a5@(12),d2                  	/* 000346 */
	moveq #0,d3                       	/* 00034a */
	movew d0,d3                       	/* 00034c */
	moveq #0,d0                       	/* 00034e */
	movew a5@(28),d0                  	/* 000350 */
	addl d3,d0                        	/* 000354 */
	subql #1,d0                       	/* 000356 */
	movel d1,sp@(44)                  	/* 000358 */
	movel d2,d1                       	/* 00035c */
	bsrw LAB_0065                     	/* 00035e */
	movel sp@(44),d1                  	/* 000362 */
	bsrw LAB_005A                     	/* 000366 */
	moveq #0,d1                       	/* 00036a */
	movew d0,d1                       	/* 00036c */
	moveq #0,d0                       	/* 00036e */
	movew a5@(30),d0                  	/* 000370 */
	moveal a5@,a0                     	/* 000374 */
	moveq #0,d2                       	/* 000376 */
	moveb a0@(5),d2                   	/* 000378 */
	exg d0,d1                         	/* 00037c */
	bsrw LIBFUNC_1                    	/* 00037e */
	moveal d0,a3                      	/* 000382 */
	tstl d0                           	/* 000384 */
	beqw LAB_0031                     	/* 000386 */
	moveal sp@(60),a6                 	/* 00038a */
	bras LAB_0021                     	/* 00038e */
LAB_0020:
	moveal a5@(8),a3                  	/* 000390 */
LAB_0021:
	moveq #0,d0                       	/* 000394 */
	movew a5@(14),d0                  	/* 000396 */
	movew a5@(28),d1                  	/* 00039a */
	mulu a5@(12),d1                   	/* 00039e */
	movel d0,sp@(44)                  	/* 0003a2 */
	movel d1,d0                       	/* 0003a6 */
	movel sp@(44),d1                  	/* 0003a8 */
	bsrw LAB_005A                     	/* 0003ac */
	movel d0,d7                       	/* 0003b0 */
	moveq #0,d0                       	/* 0003b2 */
	movew a5@(18),d0                  	/* 0003b4 */
	movew a5@(30),d1                  	/* 0003b8 */
	mulu a5@(16),d1                   	/* 0003bc */
	movel d0,sp@(44)                  	/* 0003c0 */
	movel d1,d0                       	/* 0003c4 */
	movel sp@(44),d1                  	/* 0003c6 */
	bsrw LAB_005A                     	/* 0003ca */
	movel d0,d6                       	/* 0003ce */
	moveq #0,d5                       	/* 0003d0 */
	btst #0,a5@(33)                   	/* 0003d2 */
	beqw LAB_0024                     	/* 0003d8 */
	moveq #0,d4                       	/* 0003dc */
	subal a2,a2                       	/* 0003de */
	bras LAB_0023                     	/* 0003e0 */
LAB_0022:
	moveq #0,d0                       	/* 0003e2 */
	movew a5@(12),d0                  	/* 0003e4 */
	moveq #0,d1                       	/* 0003e8 */
	movew a5@(14),d1                  	/* 0003ea */
	moveq #0,d2                       	/* 0003ee */
	movew d4,d2                       	/* 0003f0 */
	moveq #0,d3                       	/* 0003f2 */
	movew d7,d3                       	/* 0003f4 */
	subl d2,d3                        	/* 0003f6 */
	subql #1,d3                       	/* 0003f8 */
	movel d0,sp@(44)                  	/* 0003fa */
	movel d3,d0                       	/* 0003fe */
	bsrw LAB_0065                     	/* 000400 */
	movel sp@(44),d1                  	/* 000404 */
	bsrw LAB_005A                     	/* 000408 */
	moveq #0,d1                       	/* 00040c */
	movew a5@(20),d1                  	/* 00040e */
	addl d0,d1                        	/* 000412 */
	moveq #0,d0                       	/* 000414 */
	movew a5@(22),d0                  	/* 000416 */
	moveq #0,d2                       	/* 00041a */
	movew d5,d2                       	/* 00041c */
	addqw #1,d5                       	/* 00041e */
	moveq #0,d3                       	/* 000420 */
	movew a5@(30),d3                  	/* 000422 */
	movel d0,sp@(48)                  	/* 000426 */
	moveml D4-D7/A2,sp@-              	/* 00042a */
	movel d1,d0                       	/* 00042e */
	movel d3,d5                       	/* 000430 */
	moveal a5@,a0                     	/* 000432 */
	movel sp@(68),d1                  	/* 000434 */
	moveal a3,a1                      	/* 000438 */
	moveal a4@(44),a6                 	/* 00043a */
	moveq #0,d3                       	/* 00043e */
	moveq #1,d4                       	/* 000440 */
	moveq #96,d6                      	/* 000442 */
	addl d6,d6                        	/* 000444 */
	moveq #0,d7                       	/* 000446 */
	notb d7                           	/* 000448 */
	jsr a6@(-30)                      	/* 00044a */
	moveml sp@+,D4-D7/A2              	/* 00044e */
	addqw #1,d4                       	/* 000452 */
	moveal sp@(60),a6                 	/* 000454 */
LAB_0023:
	cmpw d7,d4                        	/* 000458 */
	bcss LAB_0022                     	/* 00045a */
	braw LAB_0028                     	/* 00045c */
LAB_0024:
	moveq #1,d0                       	/* 000460 */
	cmpw a5@(12),d0                   	/* 000462 */
	bnes LAB_0025                     	/* 000466 */
	cmpw a5@(14),d0                   	/* 000468 */
	bnes LAB_0025                     	/* 00046c */
	moveq #0,d0                       	/* 00046e */
	movew a5@(20),d0                  	/* 000470 */
	moveq #0,d1                       	/* 000474 */
	movew a5@(22),d1                  	/* 000476 */
	moveq #0,d2                       	/* 00047a */
	movew a5@(28),d2                  	/* 00047c */
	moveq #0,d3                       	/* 000480 */
	movew a5@(30),d3                  	/* 000482 */
	moveml D5-D7,sp@-                 	/* 000486 */
	movel d2,d4                       	/* 00048a */
	movel d3,d5                       	/* 00048c */
	moveal a5@,a0                     	/* 00048e */
	moveal a3,a1                      	/* 000490 */
	moveal a4@(44),a6                 	/* 000492 */
	moveq #0,d2                       	/* 000496 */
	movel d2,d3                       	/* 000498 */
	moveq #96,d6                      	/* 00049a */
	addl d6,d6                        	/* 00049c */
	moveq #0,d7                       	/* 00049e */
	notb d7                           	/* 0004a0 */
	subal a2,a2                       	/* 0004a2 */
	jsr a6@(-30)                      	/* 0004a4 */
	moveml sp@+,D5-D7                 	/* 0004a8 */
	moveal sp@(60),a6                 	/* 0004ac */
	bras LAB_0028                     	/* 0004b0 */
LAB_0025:
	moveq #0,d4                       	/* 0004b2 */
	subal a2,a2                       	/* 0004b4 */
	bras LAB_0027                     	/* 0004b6 */
LAB_0026:
	moveq #0,d0                       	/* 0004b8 */
	movew a5@(12),d0                  	/* 0004ba */
	movew d4,d1                       	/* 0004be */
	mulu a5@(14),d1                   	/* 0004c0 */
	movel d0,sp@(44)                  	/* 0004c4 */
	movel d1,d0                       	/* 0004c8 */
	movel sp@(44),d1                  	/* 0004ca */
	bsrw LAB_005A                     	/* 0004ce */
	moveq #0,d1                       	/* 0004d2 */
	movew a5@(20),d1                  	/* 0004d4 */
	addl d0,d1                        	/* 0004d8 */
	moveq #0,d0                       	/* 0004da */
	movew a5@(22),d0                  	/* 0004dc */
	moveq #0,d2                       	/* 0004e0 */
	movew d5,d2                       	/* 0004e2 */
	addqw #1,d5                       	/* 0004e4 */
	moveq #0,d3                       	/* 0004e6 */
	movew a5@(30),d3                  	/* 0004e8 */
	movel d0,sp@(48)                  	/* 0004ec */
	moveml D4-D7/A2,sp@-              	/* 0004f0 */
	movel d1,d0                       	/* 0004f4 */
	movel d3,d5                       	/* 0004f6 */
	moveal a5@,a0                     	/* 0004f8 */
	movel sp@(68),d1                  	/* 0004fa */
	moveal a3,a1                      	/* 0004fe */
	moveal a4@(44),a6                 	/* 000500 */
	moveq #0,d3                       	/* 000504 */
	moveq #1,d4                       	/* 000506 */
	moveq #96,d6                      	/* 000508 */
	addl d6,d6                        	/* 00050a */
	moveq #0,d7                       	/* 00050c */
	notb d7                           	/* 00050e */
	jsr a6@(-30)                      	/* 000510 */
	moveml sp@+,D4-D7/A2              	/* 000514 */
	addqw #1,d4                       	/* 000518 */
	moveal sp@(60),a6                 	/* 00051a */
LAB_0027:
	cmpw d7,d4                        	/* 00051e */
	bcss LAB_0026                     	/* 000520 */
LAB_0028:
	movew a5@(26),d5                  	/* 000522 */
	btst #1,a5@(33)                   	/* 000526 */
	moveal sp@(60),a6                 	/* 00052c */
	beqw LAB_002B                     	/* 000530 */
	moveq #0,d4                       	/* 000534 */
	subal a2,a2                       	/* 000536 */
	bras LAB_002A                     	/* 000538 */
LAB_0029:
	moveq #0,d0                       	/* 00053a */
	movew a5@(16),d0                  	/* 00053c */
	moveq #0,d1                       	/* 000540 */
	movew a5@(18),d1                  	/* 000542 */
	moveq #0,d2                       	/* 000546 */
	movew d4,d2                       	/* 000548 */
	moveq #0,d3                       	/* 00054a */
	movew d6,d3                       	/* 00054c */
	subl d2,d3                        	/* 00054e */
	subql #1,d3                       	/* 000550 */
	movel d0,sp@(44)                  	/* 000552 */
	movel d3,d0                       	/* 000556 */
	bsrw LAB_0065                     	/* 000558 */
	movel sp@(44),d1                  	/* 00055c */
	bsrw LAB_005A                     	/* 000560 */
	moveq #0,d1                       	/* 000564 */
	movew a5@(22),d1                  	/* 000566 */
	addl d0,d1                        	/* 00056a */
	moveq #0,d0                       	/* 00056c */
	movew a5@(24),d0                  	/* 00056e */
	moveq #0,d2                       	/* 000572 */
	movew d5,d2                       	/* 000574 */
	addqw #1,d5                       	/* 000576 */
	moveq #0,d3                       	/* 000578 */
	movew d7,d3                       	/* 00057a */
	moveml D4-D7/A2,sp@-              	/* 00057c */
	movel d2,sp@(72)                  	/* 000580 */
	movel d0,d2                       	/* 000584 */
	movel d3,d4                       	/* 000586 */
	moveal a3,a0                      	/* 000588 */
	moveal a5@(4),a1                  	/* 00058a */
	movel sp@(72),d3                  	/* 00058e */
	moveal a4@(44),a6                 	/* 000592 */
	moveq #0,d0                       	/* 000596 */
	moveq #1,d5                       	/* 000598 */
	moveq #96,d6                      	/* 00059a */
	addl d6,d6                        	/* 00059c */
	moveq #0,d7                       	/* 00059e */
	notb d7                           	/* 0005a0 */
	jsr a6@(-30)                      	/* 0005a2 */
	moveml sp@+,D4-D7/A2              	/* 0005a6 */
	addqw #1,d4                       	/* 0005aa */
	moveal sp@(60),a6                 	/* 0005ac */
LAB_002A:
	cmpw d6,d4                        	/* 0005b0 */
	bcss LAB_0029                     	/* 0005b2 */
	braw LAB_002F                     	/* 0005b4 */
LAB_002B:
	moveq #1,d0                       	/* 0005b8 */
	cmpw a5@(16),d0                   	/* 0005ba */
	bnes LAB_002C                     	/* 0005be */
	cmpw a5@(18),d0                   	/* 0005c0 */
	bnes LAB_002C                     	/* 0005c4 */
	moveq #0,d0                       	/* 0005c6 */
	movew a5@(24),d0                  	/* 0005c8 */
	moveq #0,d1                       	/* 0005cc */
	movew a5@(26),d1                  	/* 0005ce */
	moveq #0,d2                       	/* 0005d2 */
	movew d7,d2                       	/* 0005d4 */
	moveq #0,d3                       	/* 0005d6 */
	movew a5@(30),d3                  	/* 0005d8 */
	lea sp@(52),a2                    	/* 0005dc */
	movel d2,a2@+                     	/* 0005e0 */
	movel d0,d2                       	/* 0005e2 */
	movel d3,a2@                      	/* 0005e4 */
	movel d1,d3                       	/* 0005e6 */
	moveal a3,a0                      	/* 0005e8 */
	moveal a5@(4),a1                  	/* 0005ea */
	moveal a4@(44),a6                 	/* 0005ee */
	moveq #0,d0                       	/* 0005f2 */
	movel d0,d1                       	/* 0005f4 */
	movel sp@(52),d4                  	/* 0005f6 */
	movel a2@+,d5                     	/* 0005fa */
	moveq #96,d6                      	/* 0005fc */
	addl d6,d6                        	/* 0005fe */
	moveq #0,d7                       	/* 000600 */
	notb d7                           	/* 000602 */
	subal a2,a2                       	/* 000604 */
	jsr a6@(-30)                      	/* 000606 */
	moveal sp@(60),a6                 	/* 00060a */
	bras LAB_002F                     	/* 00060e */
LAB_002C:
	moveq #0,d4                       	/* 000610 */
	subal a2,a2                       	/* 000612 */
	bras LAB_002E                     	/* 000614 */
LAB_002D:
	moveq #0,d0                       	/* 000616 */
	movew a5@(16),d0                  	/* 000618 */
	movew d4,d1                       	/* 00061c */
	mulu a5@(18),d1                   	/* 00061e */
	movel d0,sp@(44)                  	/* 000622 */
	movel d1,d0                       	/* 000626 */
	movel sp@(44),d1                  	/* 000628 */
	bsrw LAB_005A                     	/* 00062c */
	moveq #0,d1                       	/* 000630 */
	movew a5@(24),d1                  	/* 000632 */
	moveq #0,d2                       	/* 000636 */
	movew d5,d2                       	/* 000638 */
	addqw #1,d5                       	/* 00063a */
	moveq #0,d3                       	/* 00063c */
	movew d7,d3                       	/* 00063e */
	movel d1,sp@(48)                  	/* 000640 */
	moveml D4-D7/A2,sp@-              	/* 000644 */
	movel d0,d1                       	/* 000648 */
	movel d3,sp@(76)                  	/* 00064a */
	movel d2,d3                       	/* 00064e */
	moveal a3,a0                      	/* 000650 */
	moveal a5@(4),a1                  	/* 000652 */
	movel sp@(68),d2                  	/* 000656 */
	moveal a4@(44),a6                 	/* 00065a */
	moveq #0,d0                       	/* 00065e */
	movel sp@(76),d4                  	/* 000660 */
	moveq #1,d5                       	/* 000664 */
	moveq #96,d6                      	/* 000666 */
	addl d6,d6                        	/* 000668 */
	moveq #0,d7                       	/* 00066a */
	notb d7                           	/* 00066c */
	jsr a6@(-30)                      	/* 00066e */
	moveml sp@+,D4-D7/A2              	/* 000672 */
	addqw #1,d4                       	/* 000676 */
	moveal sp@(60),a6                 	/* 000678 */
LAB_002E:
	cmpw d6,d4                        	/* 00067c */
	bcss LAB_002D                     	/* 00067e */
LAB_002F:
	tstl a5@(8)                       	/* 000680 */
	moveal sp@(60),a6                 	/* 000684 */
	bnes LAB_0030                     	/* 000688 */
	moveal a3,a1                      	/* 00068a */
	bsrw LIBFUNC_0                    	/* 00068c */
LAB_0030:
	moveq #1,d0                       	/* 000690 */
LAB_0031:
	moveml sp@+,D2-D7/A2-A6           	/* 000692 */
	addaw #0x0014,sp                  	/* 000696 */
	rts                               	/* 00069a */
LIBFUNC_5:
	moveml D0-D5,sp@-                 	/* 00069c */
	andil #0x0000ffff,d2              	/* 0006a0 */
	aslw #2,d2                        	/* 0006a6 */
	movel a3@(0,d2:w),d2              	/* 0006a8 */
	andil #0x0000ffff,d1              	/* 0006ac */
	moveb d1,d3                       	/* 0006b2 */
	asrw #3,d1                        	/* 0006b4 */
	addw d1,d2                        	/* 0006b6 */
	moveq #7,d1                       	/* 0006b8 */
	andib #0x07,d3                    	/* 0006ba */
	subb d3,d1                        	/* 0006be */
	moveb #0x08,d4                    	/* 0006c0 */
	subb a2@(5),d4                    	/* 0006c4 */
	rolb d4,d0                        	/* 0006c8 */
	moveb #0xff,d3                    	/* 0006ca */
	bclr d1,d3                        	/* 0006ce */
	lea a2@(8),a0                     	/* 0006d0 */
	lea LAB_0033:l,a1                 	/* 0006d4 */
	moveq #0,d5                       	/* 0006da */
	moveb a2@(5),d5                   	/* 0006dc */
	lslw #2,d5                        	/* 0006e0 */
	moveal a1@(0,d5:w),a1             	/* 0006e2 */
	jmp a1@                           	/* 0006e6 */
LAB_0033:
	.long LAB_003C	/* =000007aa */
	.long LAB_003B	/* =00000798 */
	.long LAB_003A	/* =00000784 */
	.long LAB_0039	/* =00000770 */
	.long LAB_0038	/* =0000075c */
	.long LAB_0037	/* =00000748 */
	.long LAB_0036	/* =00000734 */
	.long LAB_0035	/* =00000720 */
	.long LAB_0034	/* =0000070c */
LAB_0034:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x1c,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_0035:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x18,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_0036:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x14,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_0037:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x10,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_0038:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x0c,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_0039:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x08,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_003A:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x68
	.byte 0x00,0x04,0xd3,0xc2
	.byte 0xc7,0x11,0x89,0x11
LAB_003B:
	.byte 0xe3,0x18,0x18,0x00
	.byte 0x02,0x44,0x00,0x01
	.byte 0xe3,0x64,0x22,0x50
	.byte 0xd3,0xc2,0xc7,0x11
	.byte 0x89,0x11
LAB_003C:
	.byte 0x4c,0xdf,0x00,0x3f
	.byte 0x4e,0x75
LIBFUNC_6:
	moveml D0-D5,sp@-                 	/* 0007b0 */
	.byte 0x24,0x33
	movel d0,d2                       	/* 0007b6 */
	moveb d1,d3                       	/* 0007b8 */
	asrw #3,d1                        	/* 0007ba */
	addl d1,d2                        	/* 0007bc */
	moveb d3,d1                       	/* 0007be */
	andib #0x07,d1                    	/* 0007c0 */
	moveb #0x08,d4                    	/* 0007c4 */
	subb a2@(5),d4                    	/* 0007c8 */
	rolb d4,d0                        	/* 0007cc */
	moveb #0xff,d3                    	/* 0007ce */
	bclr d1,d3                        	/* 0007d2 */
	lea a2@(8),a0                     	/* 0007d4 */
	lea LAB_003E:l,a1                 	/* 0007d8 */
	moveq #0,d5                       	/* 0007de */
	moveb a2@(5),d5                   	/* 0007e0 */
	.byte 0x22,0x71
	addqb #2,d0                       	/* 0007e6 */
	jmp a1@                           	/* 0007e8 */
LAB_003E:
	.long LAB_0047	/* =0000085c */
	.long LAB_0046	/* =00000854 */
	.long LAB_0045	/* =0000084a */
	.long LAB_0044	/* =00000840 */
	.long LAB_0043	/* =00000836 */
	.long LAB_0042	/* =0000082c */
	.long LAB_0041	/* =00000822 */
	.long LAB_0040	/* =00000818 */
	.long LAB_003F	/* =0000080e */
LAB_003F:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x1c
LAB_0040:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x18
LAB_0041:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x14
LAB_0042:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x10
LAB_0043:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x0c
LAB_0044:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x08
LAB_0045:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x04
LAB_0046:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x15
LAB_0047:
	.byte 0x4c,0xdf,0x00,0x3f
	.byte 0x4e,0x75
LIBFUNC_3:
	moveml D2-D3/A6,sp@-              	/* 000862 */
	moveq #0,d0                       	/* 000866 */
	movew a2@(2),d0                   	/* 000868 */
	aslw #2,d0                        	/* 00086c */
	moveq #0,d1                       	/* 00086e */
	moveal 0x4:l,a6                   	/* 000870 */
	jsr a6@(-198)                     	/* 000876 */
	tstw d0                           	/* 00087a */
	beqw LAB_004A                     	/* 00087c */
	movel d0,d3                       	/* 000880 */
	moveal d0,a0                      	/* 000882 */
	moveq #0,d0                       	/* 000884 */
	movew a2@(2),d0                   	/* 000886 */
	subqw #1,d0                       	/* 00088a */
	moveq #0,d1                       	/* 00088c */
	moveq #0,d2                       	/* 00088e */
	.byte 0x34,0x2a,0x00,0x00	/* MOVE.W	0(A2),D2 */
LAB_0049:
	movel d1,a0@+                     	/* 000894 */
	addl d2,d1                        	/* 000896 */
	dbf d0,LAB_0049                   	/* 000898 */
	movel d3,d0                       	/* 00089c */
LAB_004A:
	moveml sp@+,D2-D3/A6              	/* 00089e */
	rts                               	/* 0008a2 */
LIBFUNC_4:
	movel a6,sp@-                     	/* 0008a4 */
	moveq #0,d0                       	/* 0008a6 */
	movew a2@(2),d0                   	/* 0008a8 */
	aslw #2,d0                        	/* 0008ac */
	moveal 0x4:l,a6                   	/* 0008ae */
	jsr a6@(-210)                     	/* 0008b4 */
	moveal sp@+,a6                    	/* 0008b8 */
	rts                               	/* 0008ba */
LIBFUNC_7:
	moveml D0-D7/A4-A6,sp@-           	/* 0008bc */
	moveq #0,d0                       	/* 0008c0 */
	.byte 0x24,0x33
	movel d0,d2                       	/* 0008c4 */
	moveb d1,d6                       	/* 0008c6 */
	asrw #3,d1                        	/* 0008c8 */
	addl d1,d2                        	/* 0008ca */
	moveb d6,d1                       	/* 0008cc */
	andib #0x07,d1                    	/* 0008ce */
	lea a2@(8),a0                     	/* 0008d2 */
	andil #0x0000ffff,d5              	/* 0008d6 */
	subw d3,d5                        	/* 0008dc */
	subqw #1,d3                       	/* 0008de */
	subqw #1,d4                       	/* 0008e0 */
	movew d3,d7                       	/* 0008e2 */
	lea LAB_0056:l,a1                 	/* 0008e4 */
	moveq #0,d6                       	/* 0008ea */
	moveb a2@(5),d6                   	/* 0008ec */
	.byte 0x22,0x71
	.byte 0x64,0x00
	moveb #0x08,d6                    	/* 0008f4 */
	subb a2@(5),d6                    	/* 0008f8 */
	moveal d2,a5                      	/* 0008fc */
	moveal d1,a6                      	/* 0008fe */
	moveb a4@+,d0                     	/* 000900 */
	rolb d6,d0                        	/* 000902 */
	jmp a1@                           	/* 000904 */
LAB_004D:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x1c
LAB_004E:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x18
LAB_004F:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x14
LAB_0050:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x10
LAB_0051:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x0c
LAB_0052:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x08
LAB_0053:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x25
	.byte 0x00,0x04
LAB_0054:
	.byte 0xe3,0x18,0xef,0xf0
	.byte 0x08,0x41,0x29,0x15
LAB_0055:
	.byte 0x52,0x41,0x02,0x01
	.byte 0x00,0x07,0x66,0x02
	.byte 0x52,0x42,0x51,0xcb
	.byte 0xff,0xa0,0x36,0x07
	.byte 0xd9,0xc5,0x24,0x0d
	.byte 0x22,0x0e,0xd4,0x6a
	.byte 0x00,0x00,0x51,0xcc
	.byte 0xff,0x8c,0x4c,0xdf
	.byte 0x70,0xff,0x4e,0x75
LAB_0056:
	.long LAB_0055	/* =00000954 */
	.long LAB_0054	/* =0000094c */
	.long LAB_0053	/* =00000942 */
	.long LAB_0052	/* =00000938 */
	.long LAB_0051	/* =0000092e */
	.long LAB_0050	/* =00000924 */
	.long LAB_004F	/* =0000091a */
	.long LAB_004E	/* =00000910 */
	.long LAB_004D	/* =00000906 */
FUNCTABLE:
	.long OPEN	/* =000000c4 */
	.long CLOSE	/* =000000d6 */
	.long EXPUNGE	/* =00000100 */
	.long SECSTRT_0	/* =00000000 */
	.long LIBFUNC_0	/* =000001b6 */
	.long LIBFUNC_1	/* =00000232 */
	.long LIBFUNC_2	/* =00000306 */
	.long LIBFUNC_3	/* =00000862 */
	.long LIBFUNC_4	/* =000008a4 */
	.long LIBFUNC_5	/* =0000069c */
	.long LIBFUNC_6	/* =000007b0 */
	.long LIBFUNC_7	/* =000008bc */
	.byte 0xff,0xff,0xff,0xff
BITMAPLIBNAME:
	.byte 0x62,0x69,0x74,0x6d,0x61,0x70,0x2e,0x6c,0x69,0x62,0x72,0x61,0x72,0x79	/* "bitmap.library" */
	.byte 0x00
	.byte 0x00
IDSTRING:
	.byte 0x62,0x69,0x74,0x6d
	.byte 0x61,0x70,0x20,0x31
	.byte 0x2e,0x34,0x20,0x28
	.byte 0x31,0x30,0x2e,0x35
	.byte 0x2e,0x39,0x35,0x29
	.byte 0x20,0x43,0x6f,0x70
	.byte 0x79,0x72,0x69,0x67
	.byte 0x68,0x74,0x20,0xa9
	.byte 0x20,0x31,0x39,0x39
	.byte 0x34,0x2d,0x31,0x39
	.byte 0x39,0x35,0x20,0x62
	.byte 0x79,0x20,0x53,0x74
	.byte 0x65,0x66,0x61,0x6e
	.byte 0x6f,0x20,0x52,0x65
	.byte 0x6b,0x73,0x74,0x65
	.byte 0x6e,0x00,0x6c,0x69
LAB_005A:
	tstl d0                           	/* 000a20 */
	bplw LAB_005C                     	/* 000a22 */
	negl d0                           	/* 000a26 */
	tstl d1                           	/* 000a28 */
	bplw LAB_005B                     	/* 000a2a */
	negl d1                           	/* 000a2e */
	bsrw LAB_005D                     	/* 000a30 */
	negl d1                           	/* 000a34 */
	rts                               	/* 000a36 */
LAB_005B:
	bsrw LAB_005D                     	/* 000a38 */
	negl d0                           	/* 000a3c */
	negl d1                           	/* 000a3e */
	rts                               	/* 000a40 */
LAB_005C:
	tstl d1                           	/* 000a42 */
	bplw LAB_005D                     	/* 000a44 */
	negl d1                           	/* 000a48 */
	bsrw LAB_005D                     	/* 000a4a */
	negl d0                           	/* 000a4e */
	rts                               	/* 000a50 */
LAB_005D:
	movel d2,sp@-                     	/* 000a52 */
	swap d1                           	/* 000a54 */
	movew d1,d2                       	/* 000a56 */
	bnew LAB_005F                     	/* 000a58 */
	swap d0                           	/* 000a5c */
	swap d1                           	/* 000a5e */
	swap d2                           	/* 000a60 */
	movew d0,d2                       	/* 000a62 */
	beqw LAB_005E                     	/* 000a64 */
	divu d1,d2                        	/* 000a68 */
	movew d2,d0                       	/* 000a6a */
LAB_005E:
	swap d0                           	/* 000a6c */
	movew d0,d2                       	/* 000a6e */
	divu d1,d2                        	/* 000a70 */
	movew d2,d0                       	/* 000a72 */
	swap d2                           	/* 000a74 */
	movew d2,d1                       	/* 000a76 */
	movel sp@+,d2                     	/* 000a78 */
	rts                               	/* 000a7a */
LAB_005F:
	movel d3,sp@-                     	/* 000a7c */
	moveq #16,d3                      	/* 000a7e */
	cmpiw #0x0100,d1                  	/* 000a80 */
	bccw LAB_0060                     	/* 000a84 */
	roll #8,d1                        	/* 000a88 */
	subqw #8,d3                       	/* 000a8a */
LAB_0060:
	cmpiw #0x1000,d1                  	/* 000a8c */
	bccw LAB_0061                     	/* 000a90 */
	roll #4,d1                        	/* 000a94 */
	subqw #4,d3                       	/* 000a96 */
LAB_0061:
	cmpiw #0x4000,d1                  	/* 000a98 */
	bccw LAB_0062                     	/* 000a9c */
	roll #2,d1                        	/* 000aa0 */
	subqw #2,d3                       	/* 000aa2 */
LAB_0062:
	tstw d1                           	/* 000aa4 */
	bmiw LAB_0063                     	/* 000aa6 */
	roll #1,d1                        	/* 000aaa */
	subqw #1,d3                       	/* 000aac */
LAB_0063:
	movew d0,d2                       	/* 000aae */
	lsrl d3,d0                        	/* 000ab0 */
	swap d2                           	/* 000ab2 */
	clrw d2                           	/* 000ab4 */
	lsrl d3,d2                        	/* 000ab6 */
	swap d3                           	/* 000ab8 */
	divu d1,d0                        	/* 000aba */
	movew d0,d3                       	/* 000abc */
	movew d2,d0                       	/* 000abe */
	movew d3,d2                       	/* 000ac0 */
	swap d1                           	/* 000ac2 */
	mulu d1,d2                        	/* 000ac4 */
	subl d2,d0                        	/* 000ac6 */
	bccw LAB_0064                     	/* 000ac8 */
	subqw #1,d3                       	/* 000acc */
	addl d1,d0                        	/* 000ace */
LAB_0064:
	moveq #0,d1                       	/* 000ad0 */
	movew d3,d1                       	/* 000ad2 */
	swap d3                           	/* 000ad4 */
	roll d3,d0                        	/* 000ad6 */
	swap d0                           	/* 000ad8 */
	exg d0,d1                         	/* 000ada */
	movel sp@+,d3                     	/* 000adc */
	movel sp@+,d2                     	/* 000ade */
	rts                               	/* 000ae0 */
	.byte 0x00,0x00
LAB_0065:
	moveml D2-D3,sp@-                 	/* 000ae4 */
	movel d0,d2                       	/* 000ae8 */
	movel d1,d3                       	/* 000aea */
	swap d2                           	/* 000aec */
	swap d3                           	/* 000aee */
	mulu d1,d2                        	/* 000af0 */
	mulu d0,d3                        	/* 000af2 */
	mulu d1,d0                        	/* 000af4 */
	addw d3,d2                        	/* 000af6 */
	swap d2                           	/* 000af8 */
	clrw d2                           	/* 000afa */
	addl d2,d0                        	/* 000afc */
	moveml sp@+,D2-D3                 	/* 000afe */
	rts                               	/* 000b02 */
LAB_0066:
	moveml D1-D3,sp@-                 	/* 000b04 */
	movel d0,d2                       	/* 000b08 */
	beqs LAB_0068                     	/* 000b0a */
	tstl d1                           	/* 000b0c */
	bnes LAB_0067                     	/* 000b0e */
	clrl d0                           	/* 000b10 */
	bras LAB_0068                     	/* 000b12 */
LAB_0067:
	movel d0,d3                       	/* 000b14 */
	mulu d1,d3                        	/* 000b16 */
	swap d2                           	/* 000b18 */
	mulu d1,d2                        	/* 000b1a */
	swap d2                           	/* 000b1c */
	clrw d2                           	/* 000b1e */
	addl d2,d3                        	/* 000b20 */
	swap d1                           	/* 000b22 */
	mulu d1,d0                        	/* 000b24 */
	swap d0                           	/* 000b26 */
	clrw d0                           	/* 000b28 */
	addl d3,d0                        	/* 000b2a */
LAB_0068:
	moveml sp@+,D1-D3                 	/* 000b2c */
	rts                               	/* 000b30 */
	.byte 0x00,0x00
	.section .data
SECSTRT_1:
	.byte 0x00,0x00,0x00,0x00
INIT:
	.byte 0x00,0x00,0x00,0x60
	.long FUNCTABLE	/* =0000099c */
	.byte 0x00,0x00,0x00,0x00
	.long INITFUNCTION	/* =00000020 */
	.byte 0x67,0x72,0x61,0x70
	.byte 0x68,0x69,0x63,0x73
	.byte 0x2e,0x6c,0x69,0x62
	.byte 0x72,0x61,0x72,0x79
	.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
	.byte 	/* END */
