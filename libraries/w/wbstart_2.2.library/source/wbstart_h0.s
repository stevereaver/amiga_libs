||
||	wbstart_h0.s -- verbatim reconstruction of
||	wbstart.library 2.2 (18.9.96) "WBStart Handler",
||	4032-byte two-hunk module (SAS/C small-data model,
||	a4 = DATA+0x7ffe as small-data base).
||
||	Hunk 0 CODE (0x3c7 longs):
||	  0x000 moveq #0/rts         loader entry (returns 0)
||	  0x004 "wbstart.library"  lib name
||	  0x014 "$VER: ...\r\n"     id string
||	  0x03a "WBStart Handler"  process name x2
||	  0x04a "dos.library"
||	  0x056 packed RomTag      rt_Flags=0 (non-AUTOINIT)
||	  0x070 functab            6 absolute longs + -1L
||	  0x08c CreateNewProc tags handler process (NP_*)
||	  0x0de initfn             exec v39 check, MakeLibrary,
||	                           AddLibrary, DATA+0=lib, +4=sysb
||	  0x198 LibOpen            LVO -6
||	  0x1b0 LibClose           LVO -12 (deferred expunge)
||	  0x1e6 LibExpunge         LVO -18 (Signal 0x1000 path)
||	  0x26a reserved stub      LVO -24/-30, returns 0
||	  0x26e pktrt helper       PutMsg/WaitPort/GetMsg
||	  0x2b8 WBStart            LVO -36
||	  0x3d0 handlerentry       "WBStart Handler" proc main
||	  0x5ea "utility.library"
||	  0x5fa "icon.library"
||	  0x608.. helpers: pool, AllocPooled, FreePooled,
||	    dospath.library glue, strlen/strcpy, NewList,
||	    CreateNewProc wrapper
||	  0x79c NP_ taglist        client proc template
||	  0x78a "dospath.library"
||	  0xf00.. tail stubs/pads
||
||	Hunk 1 DATA: hunk table allocs 0xa longs (40 bytes),
||	body defines only 1 long (0).  Used as globals:
||	  +0 libbase +4 SysBase +8 DOSBase +12 IconBase
||	  +16 UtilityBase +20 pool +24 dospathbase +28/+32
||	  dospath list ptrs +36 saved cli_CommandDir
||
||	Quirks preserved verbatim:
||	  - CODE reloc tail is plain HUNK_RELOC32 with an
||	    intentionally non-sorted first group.
||	  - exg dn,an (0xc58e/0xc98e) register juggling around
||	    library calls -- SAS/C a6-swap idiom.
||	  - DATA hunk alloc (40B) exceeds body (4B): the
||	    trailing 36 bytes are uninitialized globals.
||
	.text
	.globl	_start
_start:
	.short	0x7000		| 0000: moveq #0,d0
	.short	0x4e75		| 0002: rts
libname:
	.short	0x7762		| 0004: mvsw a2@-,d3
	.short	0x7374		| 0006: mvsw a4@(742e6c69)@(6272),d1
	.short	0x6172		| 0008:
	.short	0x742e		| 000a:
	.short	0x6c69		| 000c: 6c69 6272
	.short	0x6272		| 000e:
	.short	0x6172		| 0010: bsrs 0x84
	.short	0x7900		| 0012: mvsb d0,d4
verstr:
	.short	0x2456		| 0014: moveal a6@,a2
	.short	0x4552		| 0016: .short 0x4552
	.short	0x3a20		| 0018: movew a0@-,d5
	.short	0x7762		| 001a: mvsw a2@-,d3
	.short	0x7374		| 001c: mvsw a4@(742e6c69)@(6272),d1
	.short	0x6172		| 001e:
	.short	0x742e		| 0020:
	.short	0x6c69		| 0022: 6c69 6272
	.short	0x6272		| 0024:
	.short	0x6172		| 0026: bsrs 0x9a
	.short	0x7920		| 0028: mvsb a0@-,d4
	.short	0x322e		| 002a: movew a6@(12832),d1
	.short	0x3220		| 002c:
	.short	0x2831		| 002e: movel a1@(2e,d3:l),d4
	.short	0x382e		| 0030:
	.short	0x392e		| 0032: movew a6@(14646),a4@-
	.short	0x3936		| 0034:
	.short	0x290d		| 0036: movel a5,a4@-
	.short	0x0a00		| 0038: eorib #66,d0
handlername:
	.short	0x5742		| 003a:
	.short	0x5374		| 003c: subqw #1,a4@(74204861)@(6e64)
	.short	0x6172		| 003e:
	.short	0x7420		| 0040:
	.short	0x4861		| 0042: 4861 6e64
	.short	0x6e64		| 0044:
	.short	0x6c65		| 0046: bges 0xad
	.short	0x7200		| 0048: moveq #0,d1
doslibname:
	.short	0x646f		| 004a: bccs 0xbb
	.short	0x732e		| 004c: mvsb a6@(27753),d1
	.short	0x6c69		| 004e:
	.short	0x6272		| 0050: bhis 0xc4
	.short	0x6172		| 0052: bsrs 0xc6
	.short	0x7900		| 0054: mvsb d0,d4
romtag:
	.short	0x4afc		| 0056: illegal
	.long	romtag		| 0x058 -> hunk0
	.long	functab		| 0x05c -> hunk0
	.short	0x0002		| 0060: orib #0,d2
	.short	0x0900		| 0062:
	.long	libname		| 0x064 -> hunk0
	.long	verstr		| 0x068 -> hunk0
	.long	initfn		| 0x06c -> hunk0
functab:
	.long	libopen		| 0x070 -> hunk0
	.long	libclose		| 0x074 -> hunk0
	.long	libexpunge		| 0x078 -> hunk0
	.long	reserved0		| 0x07c -> hunk0
	.long	reserved0		| 0x080 -> hunk0
	.long	wbstart		| 0x084 -> hunk0
	.short	0xffff		| 0088: .short 0xffff
	.short	0xffff		| 008a: .short 0xffff
	.short	0x8000		| 008c: orb d0,d0
	.short	0x03eb		| 008e: bset d1,a3@(0)
	.long	handlerentry		| 0x090 -> hunk0
	.short	0x8000		| 0094: orb d0,d0
	.short	0x03f2		| 0096: bset d1,a2@(0,d0:w)
	.short	0x0000		| 0098:
	.short	0x0000		| 009a: orib #0,d0
	.short	0x8000		| 009c:
	.short	0x03f4		| 009e: bset d1,a4@(0,d0:w)
	.long	handlername		| 0x0a0 -> hunk0
	.short	0x8000		| 00a4: orb d0,d0
	.short	0x03f5		| 00a6: bset d1,a5@(0,d0:w)
	.short	0x0000		| 00a8:
	.short	0x0000		| 00aa: orib #0,d0
	.short	0x8000		| 00ac:
	.short	0x03f6		| 00ae: bset d1,a6@(0,d0:w)
	.short	0x0000		| 00b0:
	.short	0x0000		| 00b2: orib #0,d0
	.short	0x8000		| 00b4:
	.short	0x03f7		| 00b6: bset d1,sp@(0,d0:w)
	.short	0x0000		| 00b8:
	.short	0x0000		| 00ba: orib #0,d0
	.short	0x8000		| 00bc:
	.short	0x03f8		| 00be: bset d1,0x0
	.short	0x0000		| 00c0:
	.short	0x0000		| 00c2: orib #0,d0
	.short	0x8000		| 00c4:
	.short	0x03fa		| 00c6: .short 0x03fa
	.short	0x0000		| 00c8: orib #1,d0
	.short	0x0001		| 00ca:
	.short	0x8000		| 00cc: orb d0,d0
	.short	0x03fc		| 00ce: .short 0x03fc
	.long	handlername		| 0x0d0 -> hunk0
	.short	0x0000		| 00d4:
	.short	0x0000		| 00d6:
	.short	0x0000		| 00d8:
	.short	0x0000		| 00da:
	.short	0x0000		| 00dc: orib #-25,d0
initfn:
	.short	0x48e7		| 00de:
	.short	0x2138		| 00e0: movel 0x2e08,a0@-
	.short	0x2e08		| 00e2:
	.short	0x49f9		| 00e4: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x0e6 -> hunk1
	.short	0x97cb		| 00ea: subal a3,a3
	.short	0x0c6e		| 00ec: cmpiw #39,a6@(20)
	.short	0x0027		| 00ee:
	.short	0x0014		| 00f0:
	.short	0x6500		| 00f2: bcsw 0x190
	.short	0x009c		| 00f4:
	.short	0x294e		| 00f6: movel a6,a4@(-32762)
	.short	0x8006		| 00f8:
	.short	0x41fa		| 00fa: lea %pc@(0x70),a0
	.short	0xff74		| 00fc:
	.short	0x93c9		| 00fe: subal a1,a1
	.short	0x95ca		| 0100: subal a2,a2
	.short	0x203c		| 0102: movel #152,d0
	.short	0x0000		| 0104:
	.short	0x0098		| 0106:
	.short	0x7200		| 0108: moveq #0,d1
	.short	0x242c		| 010a: movel a4@(-32762),d2
	.short	0x8006		| 010c:
	.short	0xc58e		| 010e: exg d2,a6
	.short	0x4eae		| 0110: jsr a6@(-84)
	.short	0xffac		| 0112:
	.short	0x2640		| 0114: moveal d0,a3
	.short	0xc58e		| 0116: exg d2,a6
	.short	0x240b		| 0118: movel a3,d2
	.short	0x6774		| 011a: beqs 0x190
	.short	0x177c		| 011c: moveb #9,a3@(8)
	.short	0x0009		| 011e:
	.short	0x0008		| 0120:
	.short	0x45fa		| 0122: lea %pc@(0x4),a2
	.short	0xfee0		| 0124:
	.short	0x274a		| 0126: movel a2,a3@(10)
	.short	0x000a		| 0128:
	.short	0x177c		| 012a: moveb #6,a3@(14)
	.short	0x0006		| 012c:
	.short	0x000e		| 012e:
	.short	0x377c		| 0130: movew #2,a3@(20)
	.short	0x0002		| 0132:
	.short	0x0014		| 0134:
	.short	0x377c		| 0136: movew #2,a3@(22)
	.short	0x0002		| 0138:
	.short	0x0016		| 013a:
	.short	0x45fa		| 013c: lea %pc@(0x14),a2
	.short	0xfed6		| 013e:
	.short	0x274a		| 0140: movel a2,a3@(24)
	.short	0x0018		| 0142:
	.short	0x377c		| 0144: movew #0,a3@(34)
	.short	0x0000		| 0146:
	.short	0x0022		| 0148:
	.short	0x2747		| 014a: movel d7,a3@(36)
	.short	0x0024		| 014c:
	.short	0x7400		| 014e: moveq #0,d2
	.short	0x2742		| 0150: movel d2,a3@(40)
	.short	0x0028		| 0152:
	.short	0x7400		| 0154: moveq #0,d2
	.short	0x2742		| 0156: movel d2,a3@(44)
	.short	0x002c		| 0158:
	.short	0x177c		| 015a: moveb #0,a3@(110)
	.short	0x0000		| 015c:
	.short	0x006e		| 015e:
	.short	0x377c		| 0160: movew #20,a3@(150)
	.short	0x0014		| 0162:
	.short	0x0096		| 0164:
	.short	0x41eb		| 0166: lea a3@(116),a0
	.short	0x0074		| 0168:
	.short	0x6100		| 016a: bsrw 0xee0
	.short	0x0d74		| 016c:
	.short	0x41eb		| 016e: lea a3@(48),a0
	.short	0x0030		| 0170:
	.short	0x242c		| 0172: movel a4@(-32762),d2
	.short	0x8006		| 0174:
	.short	0xc58e		| 0176: exg d2,a6
	.short	0x4eae		| 0178: jsr a6@(-558)
	.short	0xfdd2		| 017a:
	.short	0xc58e		| 017c: exg d2,a6
	.short	0x224b		| 017e: moveal a3,a1
	.short	0x242c		| 0180: movel a4@(-32762),d2
	.short	0x8006		| 0182:
	.short	0xc58e		| 0184: exg d2,a6
	.short	0x4eae		| 0186: jsr a6@(-396)
	.short	0xfe74		| 0188:
	.short	0xc58e		| 018a: exg d2,a6
	.short	0x294b		| 018c: movel a3,a4@(-32766)
	.short	0x8002		| 018e:
	.short	0x200b		| 0190: movel a3,d0
	.short	0x4cdf		| 0192: moveml sp@+,d2/d7/a2-a4
	.short	0x1c84		| 0194:
	.short	0x4e75		| 0196: rts
libopen:
	.short	0x2f0c		| 0198: movel a4,sp@-
	.short	0x49f9		| 019a: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x19c -> hunk1
	.short	0x526e		| 01a0: addqw #1,a6@(32)
	.short	0x0020		| 01a2:
	.short	0x08ae		| 01a4: bclr #3,a6@(14)
	.short	0x0003		| 01a6:
	.short	0x000e		| 01a8:
	.short	0x200e		| 01aa: movel a6,d0
	.short	0x285f		| 01ac: moveal sp@+,a4
	.short	0x4e75		| 01ae: rts
libclose:
	.short	0x48e7		| 01b0: moveml d7/a4,sp@-
	.short	0x0108		| 01b2:
	.short	0x49f9		| 01b4: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x1b6 -> hunk1
	.short	0x7e00		| 01ba: moveq #0,d7
	.short	0x0c6e		| 01bc: cmpiw #0,a6@(32)
	.short	0x0000		| 01be:
	.short	0x0020		| 01c0:
	.short	0x631a		| 01c2: blss 0x1de
	.short	0x536e		| 01c4: subqw #1,a6@(32)
	.short	0x0020		| 01c6:
	.short	0x4a6e		| 01c8: tstw a6@(32)
	.short	0x0020		| 01ca:
	.short	0x6610		| 01cc: bnes 0x1de
	.short	0x7000		| 01ce: moveq #0,d0
	.short	0x102e		| 01d0: moveb a6@(14),d0
	.short	0x000e		| 01d2:
	.short	0x0800		| 01d4: btst #3,d0
	.short	0x0003		| 01d6:
	.short	0x6704		| 01d8: beqs 0x1de
	.short	0x610a		| 01da: bsrs 0x1e6
	.short	0x2e00		| 01dc: movel d0,d7
	.short	0x2007		| 01de: movel d7,d0
	.short	0x4cdf		| 01e0: moveml sp@+,d7/a4
	.short	0x1080		| 01e2:
	.short	0x4e75		| 01e4: rts
libexpunge:
	.short	0x48e7		| 01e6: moveml d2/d7/a4,sp@-
	.short	0x2108		| 01e8:
	.short	0x49f9		| 01ea: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x1ec -> hunk1
	.short	0x7e00		| 01f0: moveq #0,d7
	.short	0x0c6e		| 01f2: cmpiw #0,a6@(32)
	.short	0x0000		| 01f4:
	.short	0x0020		| 01f6:
	.short	0x6308		| 01f8: blss 0x202
	.short	0x08ee		| 01fa: bset #3,a6@(14)
	.short	0x0003		| 01fc:
	.short	0x000e		| 01fe:
	.short	0x6060		| 0200: bras 0x262
	.short	0x4a6e		| 0202: tstw a6@(34)
	.short	0x0022		| 0204:
	.short	0x663c		| 0206: bnes 0x244
	.short	0x43d6		| 0208: lea a6@,a1
	.short	0x202c		| 020a: movel a4@(-32762),d0
	.short	0x8006		| 020c:
	.short	0x2f0e		| 020e: movel a6,sp@-
	.short	0x2c40		| 0210: moveal d0,a6
	.short	0x4eae		| 0212: jsr a6@(-252)
	.short	0xff04		| 0214:
	.short	0x2c5f		| 0216: moveal sp@+,a6
	.short	0x2e2e		| 0218: movel a6@(36),d7
	.short	0x0024		| 021a:
	.short	0x7000		| 021c: moveq #0,d0
	.short	0x302e		| 021e: movew a6@(16),d0
	.short	0x0010		| 0220:
	.short	0x224e		| 0222: moveal a6,a1
	.short	0x93c0		| 0224: subal d0,a1
	.short	0x7200		| 0226: moveq #0,d1
	.short	0x322e		| 0228: movew a6@(16),d1
	.short	0x0010		| 022a:
	.short	0x7400		| 022c: moveq #0,d2
	.short	0x342e		| 022e: movew a6@(18),d2
	.short	0x0012		| 0230:
	.short	0x2001		| 0232: movel d1,d0
	.short	0xd082		| 0234: addl d2,d0
	.short	0x242c		| 0236: movel a4@(-32762),d2
	.short	0x8006		| 0238:
	.short	0xc58e		| 023a: exg d2,a6
	.short	0x4eae		| 023c: jsr a6@(-210)
	.short	0xff2e		| 023e:
	.short	0xc58e		| 0240: exg d2,a6
	.short	0x601e		| 0242: bras 0x262
	.short	0x226e		| 0244: moveal a6@(40),a1
	.short	0x0028		| 0246:
	.short	0x43d1		| 0248: lea a1@,a1
	.short	0x203c		| 024a: movel #4096,d0
	.short	0x0000		| 024c:
	.short	0x1000		| 024e:
	.short	0x242c		| 0250: movel a4@(-32762),d2
	.short	0x8006		| 0252:
	.short	0xc58e		| 0254: exg d2,a6
	.short	0x4eae		| 0256: jsr a6@(-324)
	.short	0xfebc		| 0258:
	.short	0xc58e		| 025a: exg d2,a6
	.short	0x08ee		| 025c: bset #3,a6@(14)
	.short	0x0003		| 025e:
	.short	0x000e		| 0260:
	.short	0x2007		| 0262: movel d7,d0
	.short	0x4cdf		| 0264: moveml sp@+,d2/d7/a4
	.short	0x1084		| 0266:
	.short	0x4e75		| 0268: rts
reserved0:
	.short	0x7000		| 026a: moveq #0,d0
	.short	0x4e75		| 026c: rts
	.short	0x48e7		| 026e: moveml a2-a3/a6,sp@-
	.short	0x0032		| 0270:
	.short	0x2648		| 0272: moveal a0,a3
	.short	0x2449		| 0274: moveal a1,a2
	.short	0x2c40		| 0276: moveal d0,a6
	.short	0x254e		| 0278: movel a6,a2@(14)
	.short	0x000e		| 027a:
	.short	0x204b		| 027c: moveal a3,a0
	.short	0x224a		| 027e: moveal a2,a1
	.short	0x202c		| 0280: movel a4@(-32762),d0
	.short	0x8006		| 0282:
	.short	0x2f0e		| 0284: movel a6,sp@-
	.short	0x2c40		| 0286: moveal d0,a6
	.short	0x4eae		| 0288: jsr a6@(-366)
	.short	0xfe92		| 028a:
	.short	0x2c5f		| 028c: moveal sp@+,a6
	.short	0x204e		| 028e: moveal a6,a0
	.short	0x202c		| 0290: movel a4@(-32762),d0
	.short	0x8006		| 0292:
	.short	0x2f0e		| 0294: movel a6,sp@-
	.short	0x2c40		| 0296: moveal d0,a6
	.short	0x4eae		| 0298: jsr a6@(-384)
	.short	0xfe80		| 029a:
	.short	0x2c5f		| 029c: moveal sp@+,a6
	.short	0x204e		| 029e: moveal a6,a0
	.short	0x202c		| 02a0: movel a4@(-32762),d0
	.short	0x8006		| 02a2:
	.short	0x2f0e		| 02a4: movel a6,sp@-
	.short	0x2c40		| 02a6: moveal d0,a6
	.short	0x4eae		| 02a8: jsr a6@(-372)
	.short	0xfe8c		| 02aa:
	.short	0x2c5f		| 02ac: moveal sp@+,a6
	.short	0x202a		| 02ae: movel a2@(10),d0
	.short	0x000a		| 02b0:
	.short	0x4cdf		| 02b2: moveml sp@+,a2-a3/a6
	.short	0x4c00		| 02b4:
	.short	0x4e75		| 02b6: rts
wbstart:
	.short	0x48e7		| 02b8: moveml d6-d7/a2-a4,sp@-
	.short	0x0338		| 02ba:
	.short	0x49f9		| 02bc: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x2be -> hunk1
	.short	0x4e55		| 02c2: linkw a5,#-4
	.short	0xfffc		| 02c4:
	.short	0x2b48		| 02c6: movel a0,a5@(-4)
	.short	0xfffc		| 02c8:
	.short	0x7e14		| 02ca: moveq #20,d7
	.short	0x70ff		| 02cc: moveq #-1,d0
	.short	0x222c		| 02ce: movel a4@(-32762),d1
	.short	0x8006		| 02d0:
	.short	0x2f0e		| 02d2: movel a6,sp@-
	.short	0x2c41		| 02d4: moveal d1,a6
	.short	0x4eae		| 02d6: jsr a6@(-330)
	.short	0xfeb6		| 02d8:
	.short	0x1c00		| 02da: moveb d0,d6
	.short	0x2c5f		| 02dc: moveal sp@+,a6
	.short	0x4a06		| 02de: tstb d6
	.short	0x6d00		| 02e0: bltw 0x3c4
	.short	0x00e2		| 02e2:
	.short	0x41ee		| 02e4: lea a6@(48),a0
	.short	0x0030		| 02e6:
	.short	0x222c		| 02e8: movel a4@(-32762),d1
	.short	0x8006		| 02ea:
	.short	0x2f0e		| 02ec: movel a6,sp@-
	.short	0x2c41		| 02ee: moveal d1,a6
	.short	0x4eae		| 02f0: jsr a6@(-564)
	.short	0xfdcc		| 02f2:
	.short	0x2c5f		| 02f4: moveal sp@+,a6
	.short	0x1d46		| 02f6: moveb d6,a6@(111)
	.short	0x006f		| 02f8:
	.short	0x93c9		| 02fa: subal a1,a1
	.short	0x222c		| 02fc: movel a4@(-32762),d1
	.short	0x8006		| 02fe:
	.short	0x2f0e		| 0300: movel a6,sp@-
	.short	0x2c41		| 0302: moveal d1,a6
	.short	0x4eae		| 0304: jsr a6@(-294)
	.short	0xfeda		| 0306:
	.short	0x2040		| 0308: moveal d0,a0
	.short	0x2c5f		| 030a: moveal sp@+,a6
	.short	0x2d48		| 030c: movel a0,a6@(112)
	.short	0x0070		| 030e:
	.short	0x4a6e		| 0310: tstw a6@(34)
	.short	0x0022		| 0312:
	.short	0x6668		| 0314: bnes 0x37e
	.short	0x43fa		| 0316: lea %pc@(0x4a),a1
	.short	0xfd32		| 0318:
	.short	0x7027		| 031a: moveq #39,d0
	.short	0x222c		| 031c: movel a4@(-32762),d1
	.short	0x8006		| 031e:
	.short	0x2f0e		| 0320: movel a6,sp@-
	.short	0x2c41		| 0322: moveal d1,a6
	.short	0x4eae		| 0324: jsr a6@(-552)
	.short	0xfdd8		| 0326:
	.short	0x2640		| 0328: moveal d0,a3
	.short	0x2c5f		| 032a: moveal sp@+,a6
	.short	0x220b		| 032c: movel a3,d1
	.short	0x674e		| 032e: beqs 0x37e
	.short	0x43fa		| 0330: lea %pc@(0x8c),a1
	.short	0xfd5a		| 0332:
	.short	0x2209		| 0334: movel a1,d1
	.short	0x200b		| 0336: movel a3,d0
	.short	0x2f0e		| 0338: movel a6,sp@-
	.short	0x2c40		| 033a: moveal d0,a6
	.short	0x4eae		| 033c: jsr a6@(-498)
	.short	0xfe0e		| 033e:
	.short	0x2240		| 0340: moveal d0,a1
	.short	0x2c5f		| 0342: moveal sp@+,a6
	.short	0x2d49		| 0344: movel a1,a6@(40)
	.short	0x0028		| 0346:
	.short	0x4aae		| 0348: tstl a6@(40)
	.short	0x0028		| 034a:
	.short	0x6720		| 034c: beqs 0x36e
	.short	0x226e		| 034e: moveal a6@(40),a1
	.short	0x0028		| 0350:
	.short	0x41e9		| 0352: lea a1@(92),a0
	.short	0x005c		| 0354:
	.short	0x43ee		| 0356: lea a6@(132),a1
	.short	0x0084		| 0358:
	.short	0x45ee		| 035a: lea a6@(96),a2
	.short	0x0060		| 035c:
	.short	0x200a		| 035e: movel a2,d0
	.short	0x6100		| 0360: bsrw 0x26e
	.short	0xff0c		| 0362:
	.short	0x4a80		| 0364: tstl d0
	.short	0x6606		| 0366: bnes 0x36e
	.short	0x3d7c		| 0368: movew #1,a6@(34)
	.short	0x0001		| 036a:
	.short	0x0022		| 036c:
	.short	0x224b		| 036e: moveal a3,a1
	.short	0x202c		| 0370: movel a4@(-32762),d0
	.short	0x8006		| 0372:
	.short	0x2f0e		| 0374: movel a6,sp@-
	.short	0x2c40		| 0376: moveal d0,a6
	.short	0x4eae		| 0378: jsr a6@(-414)
	.short	0xfe62		| 037a:
	.short	0x2c5f		| 037c: moveal sp@+,a6
	.short	0x4aae		| 037e: tstl a6@(44)
	.short	0x002c		| 0380:
	.short	0x671a		| 0382: beqs 0x39e
	.short	0x2d6d		| 0384: movel a5@(-4),a6@(142)
	.short	0xfffc		| 0386:
	.short	0x008e		| 0388:
	.short	0x206e		| 038a: moveal a6@(44),a0
	.short	0x002c		| 038c:
	.short	0x43ee		| 038e: lea a6@(132),a1
	.short	0x0084		| 0390:
	.short	0x47ee		| 0392: lea a6@(96),a3
	.short	0x0060		| 0394:
	.short	0x200b		| 0396: movel a3,d0
	.short	0x6100		| 0398: bsrw 0x26e
	.short	0xfed4		| 039a:
	.short	0x2e00		| 039c: movel d0,d7
	.short	0x41ee		| 039e: lea a6@(48),a0
	.short	0x0030		| 03a0:
	.short	0x202c		| 03a2: movel a4@(-32762),d0
	.short	0x8006		| 03a4:
	.short	0x2f0e		| 03a6: movel a6,sp@-
	.short	0x2c40		| 03a8: moveal d0,a6
	.short	0x4eae		| 03aa: jsr a6@(-570)
	.short	0xfdc6		| 03ac:
	.short	0x2c5f		| 03ae: moveal sp@+,a6
	.short	0x1006		| 03b0: moveb d6,d0
	.short	0x4880		| 03b2: extw d0
	.short	0x48c0		| 03b4: extl d0
	.short	0x222c		| 03b6: movel a4@(-32762),d1
	.short	0x8006		| 03b8:
	.short	0x2f0e		| 03ba: movel a6,sp@-
	.short	0x2c41		| 03bc: moveal d1,a6
	.short	0x4eae		| 03be: jsr a6@(-336)
	.short	0xfeb0		| 03c0:
	.short	0x2c5f		| 03c2: moveal sp@+,a6
	.short	0x2007		| 03c4: movel d7,d0
	.short	0x4e5d		| 03c6: unlk a5
	.short	0x4cdf		| 03c8: moveml sp@+,d6-d7/a2-a4
	.short	0x1cc0		| 03ca:
	.short	0x4e75		| 03cc: rts
	.short	0x4e71		| 03ce: nop
handlerentry:
	.short	0x48e7		| 03d0: moveml d3-d7/a2-a4/a6,sp@-
	.short	0x1f3a		| 03d2:
	.short	0x49f9		| 03d4: lea 0x7ffe,a4
	.long	wbsdata+0x7ffe	| 0x3d6 -> hunk1
	.short	0x93c9		| 03da: subal a1,a1
	.short	0x2c6c		| 03dc: moveal a4@(-32762),a6
	.short	0x8006		| 03de:
	.short	0x4eae		| 03e0: jsr a6@(-294)
	.short	0xfeda		| 03e2:
	.short	0x2040		| 03e4: moveal d0,a0
	.short	0x45e8		| 03e6: lea a0@(92),a2
	.short	0x005c		| 03e8:
	.short	0x204a		| 03ea: moveal a2,a0
	.short	0x2c6c		| 03ec: moveal a4@(-32762),a6
	.short	0x8006		| 03ee:
	.short	0x4eae		| 03f0: jsr a6@(-384)
	.short	0xfe80		| 03f2:
	.short	0x204a		| 03f4: moveal a2,a0
	.short	0x2c6c		| 03f6: moveal a4@(-32762),a6
	.short	0x8006		| 03f8:
	.short	0x4eae		| 03fa: jsr a6@(-372)
	.short	0xfe8c		| 03fc:
	.short	0x2640		| 03fe: moveal d0,a3
	.short	0x7014		| 0400: moveq #20,d0
	.short	0x2740		| 0402: movel d0,a3@(10)
	.short	0x000a		| 0404:
	.short	0x43f9		| 0406: lea 0x4a,a1
	.long	doslibname		| 0x408 -> hunk0
	.short	0x7027		| 040c: moveq #39,d0
	.short	0x2c6c		| 040e: moveal a4@(-32762),a6
	.short	0x8006		| 0410:
	.short	0x4eae		| 0412: jsr a6@(-552)
	.short	0xfdd8		| 0414:
	.short	0x2940		| 0416: movel d0,a4@(-32758)
	.short	0x800a		| 0418:
	.short	0x4aac		| 041a: tstl a4@(-32758)
	.short	0x800a		| 041c:
	.short	0x6700		| 041e: beqw 0x5c2
	.short	0x01a2		| 0420:
	.short	0x43fa		| 0422: lea %pc@(0x5fa),a1
	.short	0x01d6		| 0424:
	.short	0x7027		| 0426: moveq #39,d0
	.short	0x2c6c		| 0428: moveal a4@(-32762),a6
	.short	0x8006		| 042a:
	.short	0x4eae		| 042c: jsr a6@(-552)
	.short	0xfdd8		| 042e:
	.short	0x2940		| 0430: movel d0,a4@(-32754)
	.short	0x800e		| 0432:
	.short	0x4aac		| 0434: tstl a4@(-32754)
	.short	0x800e		| 0436:
	.short	0x6700		| 0438: beqw 0x5b6
	.short	0x017c		| 043a:
	.short	0x43fa		| 043c: lea %pc@(0x5ea),a1
	.short	0x01ac		| 043e:
	.short	0x7027		| 0440: moveq #39,d0
	.short	0x2c6c		| 0442: moveal a4@(-32762),a6
	.short	0x8006		| 0444:
	.short	0x4eae		| 0446: jsr a6@(-552)
	.short	0xfdd8		| 0448:
	.short	0x2940		| 044a: movel d0,a4@(-32750)
	.short	0x8012		| 044c:
	.short	0x4aac		| 044e: tstl a4@(-32750)
	.short	0x8012		| 0450:
	.short	0x6700		| 0452: beqw 0x5aa
	.short	0x0156		| 0454:
	.short	0x6100		| 0456: bsrw 0x608
	.short	0x01b0		| 0458:
	.short	0x4a40		| 045a: tstw d0
	.short	0x6700		| 045c: beqw 0x59e
	.short	0x0140		| 045e:
	.short	0x70ff		| 0460: moveq #-1,d0
	.short	0x2c6c		| 0462: moveal a4@(-32762),a6
	.short	0x8006		| 0464:
	.short	0x4eae		| 0466: jsr a6@(-330)
	.short	0xfeb6		| 0468:
	.short	0x1e00		| 046a: moveb d0,d7
	.short	0x4a07		| 046c: tstb d7
	.short	0x6d00		| 046e: bltw 0x59a
	.short	0x012a		| 0470:
	.short	0x7022		| 0472: moveq #34,d0
	.short	0x6100		| 0474: bsrw 0x64c
	.short	0x01d6		| 0476:
	.short	0x2440		| 0478: moveal d0,a2
	.short	0x200a		| 047a: movel a2,d0
	.short	0x6700		| 047c: beqw 0x58c
	.short	0x010e		| 047e:
	.short	0x157c		| 0480: moveb #0,a2@(14)
	.short	0x0000		| 0482:
	.short	0x000e		| 0484:
	.short	0x1547		| 0486: moveb d7,a2@(15)
	.short	0x000f		| 0488:
	.short	0x93c9		| 048a: subal a1,a1
	.short	0x2c6c		| 048c: moveal a4@(-32762),a6
	.short	0x8006		| 048e:
	.short	0x4eae		| 0490: jsr a6@(-294)
	.short	0xfeda		| 0492:
	.short	0x2540		| 0494: movel d0,a2@(16)
	.short	0x0010		| 0496:
	.short	0x41ea		| 0498: lea a2@(20),a0
	.short	0x0014		| 049a:
	.short	0x6100		| 049c: bsrw 0xee0
	.short	0x0a42		| 049e:
	.short	0x206c		| 04a0: moveal a4@(-32766),a0
	.short	0x8002		| 04a2:
	.short	0x214a		| 04a4: movel a2,a0@(44)
	.short	0x002c		| 04a6:
	.short	0x7000		| 04a8: moveq #0,d0
	.short	0x2740		| 04aa: movel d0,a3@(10)
	.short	0x000a		| 04ac:
	.short	0x224b		| 04ae: moveal a3,a1
	.short	0x2c6c		| 04b0: moveal a4@(-32762),a6
	.short	0x8006		| 04b2:
	.short	0x4eae		| 04b4: jsr a6@(-378)
	.short	0xfe86		| 04b6:
	.short	0x6100		| 04b8: bsrw 0x6e4
	.short	0x022a		| 04ba:
	.short	0x7001		| 04bc: moveq #1,d0
	.short	0xefa0		| 04be: asll d7,d0
	.short	0x2c00		| 04c0: movel d0,d6
	.short	0x2a3c		| 04c2: movel #4096,d5
	.short	0x0000		| 04c4:
	.short	0x1000		| 04c6:
	.short	0x8a86		| 04c8: orl d6,d5
	.short	0x7800		| 04ca: moveq #0,d4
	.short	0x2005		| 04cc: movel d5,d0
	.short	0x2c6c		| 04ce: moveal a4@(-32762),a6
	.short	0x8006		| 04d0:
	.short	0x4eae		| 04d2: jsr a6@(-318)
	.short	0xfec2		| 04d4:
	.short	0x2600		| 04d6: movel d0,d3
	.short	0x2006		| 04d8: movel d6,d0
	.short	0xc083		| 04da: andl d3,d0
	.short	0x6744		| 04dc: beqs 0x522
	.short	0x6032		| 04de: bras 0x512
	.short	0x0c2b		| 04e0: cmpib #7,a3@(8)
	.short	0x0007		| 04e2:
	.short	0x0008		| 04e4:
	.short	0x660c		| 04e6: bnes 0x4f4
	.short	0x5384		| 04e8: subql #1,d4
	.short	0x204b		| 04ea: moveal a3,a0
	.short	0x7001		| 04ec: moveq #1,d0
	.short	0x6100		| 04ee: bsrw 0xe32
	.short	0x0942		| 04f0:
	.short	0x601e		| 04f2: bras 0x512
	.short	0x206b		| 04f4: moveal a3@(10),a0
	.short	0x000a		| 04f6:
	.short	0x6100		| 04f8: bsrw 0xbe4
	.short	0x06ea		| 04fa:
	.short	0x2740		| 04fc: movel d0,a3@(10)
	.short	0x000a		| 04fe:
	.short	0x4aab		| 0500: tstl a3@(10)
	.short	0x000a		| 0502:
	.short	0x6602		| 0504: bnes 0x508
	.short	0x5284		| 0506: addql #1,d4
	.short	0x224b		| 0508: moveal a3,a1
	.short	0x2c6c		| 050a: moveal a4@(-32762),a6
	.short	0x8006		| 050c:
	.short	0x4eae		| 050e: jsr a6@(-378)
	.short	0xfe86		| 0510:
	.short	0x204a		| 0512: moveal a2,a0
	.short	0x2c6c		| 0514: moveal a4@(-32762),a6
	.short	0x8006		| 0516:
	.short	0x4eae		| 0518: jsr a6@(-372)
	.short	0xfe8c		| 051a:
	.short	0x2640		| 051c: moveal d0,a3
	.short	0x200b		| 051e: movel a3,d0
	.short	0x66be		| 0520: bnes 0x4e0
	.short	0x0803		| 0522: btst #12,d3
	.short	0x000c		| 0524:
	.short	0x67a4		| 0526: beqs 0x4cc
	.short	0x4a84		| 0528: tstl d4
	.short	0x66a0		| 052a: bnes 0x4cc
	.short	0x2c6c		| 052c: moveal a4@(-32766),a6
	.short	0x8002		| 052e:
	.short	0x41ee		| 0530: lea a6@(48),a0
	.short	0x0030		| 0532:
	.short	0x2c6c		| 0534: moveal a4@(-32762),a6
	.short	0x8006		| 0536:
	.short	0x4eae		| 0538: jsr a6@(-576)
	.short	0xfdc0		| 053a:
	.short	0x4a80		| 053c: tstl d0
	.short	0x678c		| 053e: beqs 0x4cc
	.short	0x2c6c		| 0540: moveal a4@(-32766),a6
	.short	0x8002		| 0542:
	.short	0x7000		| 0544: moveq #0,d0
	.short	0x2d40		| 0546: movel d0,a6@(44)
	.short	0x002c		| 0548:
	.short	0x2c6c		| 054a: moveal a4@(-32766),a6
	.short	0x8002		| 054c:
	.short	0x41ee		| 054e: lea a6@(48),a0
	.short	0x0030		| 0550:
	.short	0x2c6c		| 0552: moveal a4@(-32762),a6
	.short	0x8006		| 0554:
	.short	0x4eae		| 0556: jsr a6@(-570)
	.short	0xfdc6		| 0558:
	.short	0x6004		| 055a: bras 0x560
	.short	0x6000		| 055c: braw 0x4cc
	.short	0xff6e		| 055e:
	.short	0x204a		| 0560: moveal a2,a0
	.short	0x2c6c		| 0562: moveal a4@(-32762),a6
	.short	0x8006		| 0564:
	.short	0x4eae		| 0566: jsr a6@(-372)
	.short	0xfe8c		| 0568:
	.short	0x2640		| 056a: moveal d0,a3
	.short	0x260b		| 056c: movel a3,d3
	.short	0x6710		| 056e: beqs 0x580
	.short	0x7614		| 0570: moveq #20,d3
	.short	0x2743		| 0572: movel d3,a3@(10)
	.short	0x000a		| 0574:
	.short	0x224b		| 0576: moveal a3,a1
	.short	0x2c6c		| 0578: moveal a4@(-32762),a6
	.short	0x8006		| 057a:
	.short	0x4eae		| 057c: jsr a6@(-378)
	.short	0xfe86		| 057e:
	.short	0x97cb		| 0580: subal a3,a3
	.short	0x6100		| 0582: bsrw 0x74c
	.short	0x01c8		| 0584:
	.short	0x204a		| 0586: moveal a2,a0
	.short	0x6100		| 0588: bsrw 0x676
	.short	0x00ec		| 058a:
	.short	0x1007		| 058c: moveb d7,d0
	.short	0x4880		| 058e: extw d0
	.short	0x48c0		| 0590: extl d0
	.short	0x2c6c		| 0592: moveal a4@(-32762),a6
	.short	0x8006		| 0594:
	.short	0x4eae		| 0596: jsr a6@(-336)
	.short	0xfeb0		| 0598:
	.short	0x6100		| 059a: bsrw 0x63a
	.short	0x009e		| 059c:
	.short	0x226c		| 059e: moveal a4@(-32750),a1
	.short	0x8012		| 05a0:
	.short	0x2c6c		| 05a2: moveal a4@(-32762),a6
	.short	0x8006		| 05a4:
	.short	0x4eae		| 05a6: jsr a6@(-414)
	.short	0xfe62		| 05a8:
	.short	0x226c		| 05aa: moveal a4@(-32754),a1
	.short	0x800e		| 05ac:
	.short	0x2c6c		| 05ae: moveal a4@(-32762),a6
	.short	0x8006		| 05b0:
	.short	0x4eae		| 05b2: jsr a6@(-414)
	.short	0xfe62		| 05b4:
	.short	0x226c		| 05b6: moveal a4@(-32758),a1
	.short	0x800a		| 05b8:
	.short	0x2c6c		| 05ba: moveal a4@(-32762),a6
	.short	0x8006		| 05bc:
	.short	0x4eae		| 05be: jsr a6@(-414)
	.short	0xfe62		| 05c0:
	.short	0x2e0b		| 05c2: movel a3,d7
	.short	0x670c		| 05c4: beqs 0x5d2
	.short	0x224b		| 05c6: moveal a3,a1
	.short	0x2c6c		| 05c8: moveal a4@(-32762),a6
	.short	0x8006		| 05ca:
	.short	0x4eae		| 05cc: jsr a6@(-378)
	.short	0xfe86		| 05ce:
	.short	0x6012		| 05d0: bras 0x5e4
	.short	0x2c6c		| 05d2: moveal a4@(-32762),a6
	.short	0x8006		| 05d4:
	.short	0x4eae		| 05d6: jsr a6@(-132)
	.short	0xff7c		| 05d8:
	.short	0x2c6c		| 05da: moveal a4@(-32766),a6
	.short	0x8002		| 05dc:
	.short	0x3d7c		| 05de: movew #0,a6@(34)
	.short	0x0000		| 05e0:
	.short	0x0022		| 05e2:
	.short	0x4cdf		| 05e4: moveml sp@+,d3-d7/a2-a4/a6
	.short	0x5cf8		| 05e6:
	.short	0x4e75		| 05e8: rts
	.short	0x7574		| 05ea: mvsw a4@(6974)@(0),d2
	.short	0x696c		| 05ec:
	.short	0x6974		| 05ee:
	.short	0x792e		| 05f0: mvsb a6@(27753),d4
	.short	0x6c69		| 05f2:
	.short	0x6272		| 05f4: bhis 0x668
	.short	0x6172		| 05f6: bsrs 0x66a
	.short	0x7900		| 05f8: mvsb d0,d4
	.short	0x6963		| 05fa: bvss 0x65f
	.short	0x6f6e		| 05fc: bles 0x66c
	.short	0x2e6c		| 05fe: moveal a4@(26978),sp
	.short	0x6962		| 0600:
	.short	0x7261		| 0602: moveq #97,d1
	.short	0x7279		| 0604: moveq #121,d1
	.short	0x0000		| 0606: orib #-25,d0
	.short	0x48e7		| 0608:
	.short	0x2002		| 060a: movel d2,d0
	.short	0x7001		| 060c: moveq #1,d0
	.short	0x223c		| 060e: movel #4096,d1
	.short	0x0000		| 0610:
	.short	0x1000		| 0612:
	.short	0x243c		| 0614: movel #4096,d2
	.short	0x0000		| 0616:
	.short	0x1000		| 0618:
	.short	0x2c6c		| 061a: moveal a4@(-32762),a6
	.short	0x8006		| 061c:
	.short	0x4eae		| 061e: jsr a6@(-696)
	.short	0xfd48		| 0620:
	.short	0x2940		| 0622: movel d0,a4@(-32746)
	.short	0x8016		| 0624:
	.short	0x7400		| 0626: moveq #0,d2
	.short	0x4aac		| 0628: tstl a4@(-32746)
	.short	0x8016		| 062a:
	.short	0x56c2		| 062c: sne d2
	.short	0x4402		| 062e: negb d2
	.short	0x48c2		| 0630: extl d2
	.short	0x2002		| 0632: movel d2,d0
	.short	0x4cdf		| 0634: moveml sp@+,d2/a6
	.short	0x4004		| 0636:
	.short	0x4e75		| 0638: rts
	.short	0x2f0e		| 063a: movel a6,sp@-
	.short	0x206c		| 063c: moveal a4@(-32746),a0
	.short	0x8016		| 063e:
	.short	0x2c6c		| 0640: moveal a4@(-32762),a6
	.short	0x8006		| 0642:
	.short	0x4eae		| 0644: jsr a6@(-702)
	.short	0xfd42		| 0646:
	.short	0x2c5f		| 0648: moveal sp@+,a6
	.short	0x4e75		| 064a: rts
	.short	0x48e7		| 064c: moveml d7/a3/a6,sp@-
	.short	0x0112		| 064e:
	.short	0x2e00		| 0650: movel d0,d7
	.short	0x5887		| 0652: addql #4,d7
	.short	0x206c		| 0654: moveal a4@(-32746),a0
	.short	0x8016		| 0656:
	.short	0x2007		| 0658: movel d7,d0
	.short	0x2c6c		| 065a: moveal a4@(-32762),a6
	.short	0x8006		| 065c:
	.short	0x4eae		| 065e: jsr a6@(-708)
	.short	0xfd3c		| 0660:
	.short	0x2640		| 0662: moveal d0,a3
	.short	0x200b		| 0664: movel a3,d0
	.short	0x6706		| 0666: beqs 0x66e
	.short	0x204b		| 0668: moveal a3,a0
	.short	0x588b		| 066a: addql #4,a3
	.short	0x2087		| 066c: movel d7,a0@
	.short	0x200b		| 066e: movel a3,d0
	.short	0x4cdf		| 0670: moveml sp@+,d7/a3/a6
	.short	0x4880		| 0672:
	.short	0x4e75		| 0674: rts
	.short	0x48e7		| 0676: moveml d7/a3/a6,sp@-
	.short	0x0112		| 0678:
	.short	0x2648		| 067a: moveal a0,a3
	.short	0x598b		| 067c: subql #4,a3
	.short	0x2e13		| 067e: movel a3@,d7
	.short	0x206c		| 0680: moveal a4@(-32746),a0
	.short	0x8016		| 0682:
	.short	0x224b		| 0684: moveal a3,a1
	.short	0x2007		| 0686: movel d7,d0
	.short	0x2c6c		| 0688: moveal a4@(-32762),a6
	.short	0x8006		| 068a:
	.short	0x4eae		| 068c: jsr a6@(-714)
	.short	0xfd36		| 068e:
	.short	0x4cdf		| 0690: moveml sp@+,d7/a3/a6
	.short	0x4880		| 0692:
	.short	0x4e75		| 0694: rts
	.short	0x4e71		| 0696: nop
	.short	0x48e7		| 0698: moveml d2/d6-d7/a3/a6,sp@-
	.short	0x2312		| 069a:
	.short	0x2648		| 069c: moveal a0,a3
	.short	0x2e00		| 069e: movel d0,d7
	.short	0x4e55		| 06a0: linkw a5,#-4
	.short	0xfffc		| 06a2:
	.short	0x220b		| 06a4: movel a3,d1
	.short	0x74fe		| 06a6: moveq #-2,d2
	.short	0x2c6c		| 06a8: moveal a4@(-32758),a6
	.short	0x800a		| 06aa:
	.short	0x4eae		| 06ac: jsr a6@(-84)
	.short	0xffac		| 06ae:
	.short	0x2c00		| 06b0: movel d0,d6
	.short	0x4a86		| 06b2: tstl d6
	.short	0x670e		| 06b4: beqs 0x6c4
	.short	0x2206		| 06b6: movel d6,d1
	.short	0x2c6c		| 06b8: moveal a4@(-32758),a6
	.short	0x800a		| 06ba:
	.short	0x4eae		| 06bc: jsr a6@(-90)
	.short	0xffa6		| 06be:
	.short	0x2c07		| 06c0: movel d7,d6
	.short	0x6016		| 06c2: bras 0x6da
	.short	0x2b6c		| 06c4: movel a4@(-32738),a5@(-4)
	.short	0x801e		| 06c6:
	.short	0xfffc		| 06c8:
	.short	0x41ed		| 06ca: lea a5@(-4),a0
	.short	0xfffc		| 06cc:
	.short	0x224b		| 06ce: moveal a3,a1
	.short	0x2c6c		| 06d0: moveal a4@(-32742),a6
	.short	0x801a		| 06d2:
	.short	0x4eae		| 06d4: jsr a6@(-54)
	.short	0xffca		| 06d6:
	.short	0x2c00		| 06d8: movel d0,d6
	.short	0x2006		| 06da: movel d6,d0
	.short	0x4e5d		| 06dc: unlk a5
	.short	0x4cdf		| 06de: moveml sp@+,d2/d6-d7/a3/a6
	.short	0x48c4		| 06e0:
	.short	0x4e75		| 06e2: rts
	.short	0x48e7		| 06e4: moveml a3/a6,sp@-
	.short	0x0012		| 06e6:
	.short	0x2c6c		| 06e8: moveal a4@(-32758),a6
	.short	0x800a		| 06ea:
	.short	0x4eae		| 06ec: jsr a6@(-492)
	.short	0xfe14		| 06ee:
	.short	0x2640		| 06f0: moveal d0,a3
	.short	0x202b		| 06f2: movel a3@(8),d0
	.short	0x0008		| 06f4:
	.short	0xe580		| 06f6: asll #2,d0
	.short	0x2940		| 06f8: movel d0,a4@(-32730)
	.short	0x8026		| 06fa:
	.short	0x296c		| 06fc: movel a4@(-32730),a4@(-32738)
	.short	0x8026		| 06fe:
	.short	0x801e		| 0700:
	.short	0x7000		| 0702: moveq #0,d0
	.short	0x2940		| 0704: movel d0,a4@(-32734)
	.short	0x8022		| 0706:
	.short	0x43fa		| 0708: lea %pc@(0x78a),a1
	.short	0x0080		| 070a:
	.short	0x7001		| 070c: moveq #1,d0
	.short	0x2c6c		| 070e: moveal a4@(-32762),a6
	.short	0x8006		| 0710:
	.short	0x4eae		| 0712: jsr a6@(-552)
	.short	0xfdd8		| 0714:
	.short	0x2940		| 0716: movel d0,a4@(-32742)
	.short	0x801a		| 0718:
	.short	0x4aac		| 071a: tstl a4@(-32742)
	.short	0x801a		| 071c:
	.short	0x6726		| 071e: beqs 0x746
	.short	0x91c8		| 0720: subal a0,a0
	.short	0x93c9		| 0722: subal a1,a1
	.short	0x2c6c		| 0724: moveal a4@(-32742),a6
	.short	0x801a		| 0726:
	.short	0x4eae		| 0728: jsr a6@(-78)
	.short	0xffb2		| 072a:
	.short	0x2940		| 072c: movel d0,a4@(-32734)
	.short	0x8022		| 072e:
	.short	0x4aac		| 0730: tstl a4@(-32734)
	.short	0x8022		| 0732:
	.short	0x6710		| 0734: beqs 0x746
	.short	0x202c		| 0736: movel a4@(-32734),d0
	.short	0x8022		| 0738:
	.short	0xe480		| 073a: asrl #2,d0
	.short	0x2740		| 073c: movel d0,a3@(8)
	.short	0x0008		| 073e:
	.short	0x296c		| 0740: movel a4@(-32734),a4@(-32738)
	.short	0x8022		| 0742:
	.short	0x801e		| 0744:
	.short	0x4cdf		| 0746: moveml sp@+,a3/a6
	.short	0x4800		| 0748:
	.short	0x4e75		| 074a: rts
	.short	0x2f0e		| 074c: movel a6,sp@-
	.short	0x4aac		| 074e: tstl a4@(-32734)
	.short	0x8022		| 0750:
	.short	0x6720		| 0752: beqs 0x774
	.short	0x2c6c		| 0754: moveal a4@(-32758),a6
	.short	0x800a		| 0756:
	.short	0x4eae		| 0758: jsr a6@(-492)
	.short	0xfe14		| 075a:
	.short	0x2040		| 075c: moveal d0,a0
	.short	0x202c		| 075e: movel a4@(-32730),d0
	.short	0x8026		| 0760:
	.short	0xe480		| 0762: asrl #2,d0
	.short	0x2140		| 0764: movel d0,a0@(8)
	.short	0x0008		| 0766:
	.short	0x206c		| 0768: moveal a4@(-32734),a0
	.short	0x8022		| 076a:
	.short	0x2c6c		| 076c: moveal a4@(-32742),a6
	.short	0x801a		| 076e:
	.short	0x4eae		| 0770: jsr a6@(-36)
	.short	0xffdc		| 0772:
	.short	0x4aac		| 0774: tstl a4@(-32742)
	.short	0x801a		| 0776:
	.short	0x670c		| 0778: beqs 0x786
	.short	0x226c		| 077a: moveal a4@(-32742),a1
	.short	0x801a		| 077c:
	.short	0x2c6c		| 077e: moveal a4@(-32762),a6
	.short	0x8006		| 0780:
	.short	0x4eae		| 0782: jsr a6@(-414)
	.short	0xfe62		| 0784:
	.short	0x2c5f		| 0786: moveal sp@+,a6
	.short	0x4e75		| 0788: rts
	.short	0x646f		| 078a: bccs 0x7fb
	.short	0x7370		| 078c: mvsw a0@(682e6c69)@(0),d1
	.short	0x6174		| 078e:
	.short	0x682e		| 0790:
	.short	0x6c69		| 0792: 6c69
	.short	0x6272		| 0794: bhis 0x808
	.short	0x6172		| 0796: bsrs 0x80a
	.short	0x7900		| 0798: mvsb d0,d4
	.short	0x4e71		| 079a: nop
	.short	0x8000		| 079c: orb d0,d0
	.short	0x03ea		| 079e: bset d1,a2@(0)
	.short	0x0000		| 07a0:
	.short	0x0000		| 07a2: orib #0,d0
	.short	0x8000		| 07a4:
	.short	0x03ec		| 07a6: bset d1,a4@(0)
	.short	0x0000		| 07a8:
	.short	0x0000		| 07aa: orib #0,d0
	.short	0x8000		| 07ac:
	.short	0x03ee		| 07ae: bset d1,a6@(0)
	.short	0x0000		| 07b0:
	.short	0x0000		| 07b2: orib #0,d0
	.short	0x8000		| 07b4:
	.short	0x03ed		| 07b6: bset d1,a5@(0)
	.short	0x0000		| 07b8:
	.short	0x0000		| 07ba: orib #0,d0
	.short	0x8000		| 07bc:
	.short	0x03ef		| 07be: bset d1,sp@(0)
	.short	0x0000		| 07c0:
	.short	0x0000		| 07c2: orib #0,d0
	.short	0x8000		| 07c4:
	.short	0x03f0		| 07c6: bset d1,a0@(0,d0:w)
	.short	0x0000		| 07c8:
	.short	0x0000		| 07ca: orib #0,d0
	.short	0x8000		| 07cc:
	.short	0x03f1		| 07ce: bset d1,a1@(0,d0:w)
	.short	0x0000		| 07d0:
	.short	0x0000		| 07d2: orib #0,d0
	.short	0x8000		| 07d4:
	.short	0x03f2		| 07d6: bset d1,a2@(0,d0:w)
	.short	0x0000		| 07d8:
	.short	0x0000		| 07da: orib #0,d0
	.short	0x8000		| 07dc:
	.short	0x03f6		| 07de: bset d1,a6@(0,d0:w)
	.short	0x0000		| 07e0:
	.short	0x0000		| 07e2: orib #0,d0
	.short	0x8000		| 07e4:
	.short	0x03f7		| 07e6: bset d1,sp@(0,d0:w)
	.short	0x0000		| 07e8:
	.short	0x0000		| 07ea:
	.short	0x0000		| 07ec:
	.short	0x0000		| 07ee:
	.short	0x0000		| 07f0:
	.short	0x0000		| 07f2: orib #-25,d0
	.short	0x48e7		| 07f4:
	.short	0x0030		| 07f6: orib #72,a0@(4b,d2:w)
	.short	0x2648		| 07f8:
	.short	0x204b		| 07fa:
	.short	0x6100		| 07fc: bsrw 0xeb4
	.short	0x06b6		| 07fe:
	.short	0x5280		| 0800: addql #1,d0
	.short	0x6100		| 0802: bsrw 0x64c
	.short	0xfe48		| 0804:
	.short	0x2440		| 0806: moveal d0,a2
	.short	0x200a		| 0808: movel a2,d0
	.short	0x6708		| 080a: beqs 0x814
	.short	0x204a		| 080c: moveal a2,a0
	.short	0x224b		| 080e: moveal a3,a1
	.short	0x6100		| 0810: bsrw 0xec4
	.short	0x06b2		| 0812:
	.short	0x200a		| 0814: movel a2,d0
	.short	0x4cdf		| 0816: moveml sp@+,a2-a3
	.short	0x0c00		| 0818:
	.short	0x4e75		| 081a: rts
	.short	0x48e7		| 081c: moveml d2/d6-d7/a2-a3/a6,sp@-
	.short	0x2332		| 081e:
	.short	0x2648		| 0820: moveal a0,a3
	.short	0x2449		| 0822: moveal a1,a2
	.short	0x2e00		| 0824: movel d0,d7
	.short	0x2c6b		| 0826: moveal a3@(48),a6
	.short	0x0030		| 0828:
	.short	0x7c01		| 082a: moveq #1,d6
	.short	0x6046		| 082c: bras 0x874
	.short	0x206a		| 082e: moveal a2@(4),a0
	.short	0x0004		| 0830:
	.short	0x61c0		| 0832: bsrs 0x7f4
	.short	0x2d40		| 0834: movel d0,a6@(4)
	.short	0x0004		| 0836:
	.short	0x4aae		| 0838: tstl a6@(4)
	.short	0x0004		| 083a:
	.short	0x672e		| 083c: beqs 0x86c
	.short	0x52ab		| 083e: addql #1,a3@(28)
	.short	0x001c		| 0840:
	.short	0x2212		| 0842: movel a2@,d1
	.short	0x242c		| 0844: movel a4@(-32758),d2
	.short	0x800a		| 0846:
	.short	0xc58e		| 0848: exg d2,a6
	.short	0x4eae		| 084a: jsr a6@(-96)
	.short	0xffa0		| 084c:
	.short	0xc58e		| 084e: exg d2,a6
	.short	0x2c80		| 0850: movel d0,a6@
	.short	0x4a96		| 0852: tstl a6@
	.short	0x661a		| 0854: bnes 0x870
	.short	0x206e		| 0856: moveal a6@(4),a0
	.short	0x0004		| 0858:
	.short	0x6100		| 085a: bsrw 0xeb4
	.short	0x0658		| 085c:
	.short	0x5380		| 085e: subql #1,d0
	.short	0x206e		| 0860: moveal a6@(4),a0
	.short	0x0004		| 0862:
	.short	0xd1c0		| 0864: addal d0,a0
	.short	0x0c10		| 0866: cmpib #58,a0@
	.short	0x003a		| 0868:
	.short	0x6704		| 086a: beqs 0x870
	.short	0x7c00		| 086c: moveq #0,d6
	.short	0x600c		| 086e: bras 0x87c
	.short	0x508a		| 0870: addql #8,a2
	.short	0x508e		| 0872: addql #8,a6
	.short	0x2007		| 0874: movel d7,d0
	.short	0x5387		| 0876: subql #1,d7
	.short	0x4a80		| 0878: tstl d0
	.short	0x66b2		| 087a: bnes 0x82e
	.short	0x3006		| 087c: movew d6,d0
	.short	0x48c0		| 087e: extl d0
	.short	0x4cdf		| 0880: moveml sp@+,d2/d6-d7/a2-a3/a6
	.short	0x4cc4		| 0882:
	.short	0x4e75		| 0884: rts
	.short	0x48e7		| 0886: moveml d2/d4-d7/a2-a3/a6,sp@-
	.short	0x2f32		| 0888:
	.short	0x2e00		| 088a: movel d0,d7
	.short	0x2649		| 088c: moveal a1,a3
	.short	0x4e55		| 088e: linkw a5,#-4
	.short	0xfffc		| 0890:
	.short	0x2b48		| 0892: movel a0,a5@(-4)
	.short	0xfffc		| 0894:
	.short	0x206d		| 0896: moveal a5@(-4),a0
	.short	0xfffc		| 0898:
	.short	0x2468		| 089a: moveal a0@(48),a2
	.short	0x0030		| 089c:
	.short	0x50a8		| 089e: addql #8,a0@(48)
	.short	0x0030		| 08a0:
	.short	0x7c00		| 08a2: moveq #0,d6
	.short	0x204b		| 08a4: moveal a3,a0
	.short	0x6100		| 08a6: bsrw 0x7f4
	.short	0xff4c		| 08a8:
	.short	0x2540		| 08aa: movel d0,a2@(4)
	.short	0x0004		| 08ac:
	.short	0x4aaa		| 08ae: tstl a2@(4)
	.short	0x0004		| 08b0:
	.short	0x6700		| 08b2: beqw 0x9aa
	.short	0x00f6		| 08b4:
	.short	0x206d		| 08b6: moveal a5@(-4),a0
	.short	0xfffc		| 08b8:
	.short	0x52a8		| 08ba: addql #1,a0@(28)
	.short	0x001c		| 08bc:
	.short	0x7000		| 08be: moveq #0,d0
	.short	0x2480		| 08c0: movel d0,a2@
	.short	0x222a		| 08c2: movel a2@(4),d1
	.short	0x0004		| 08c4:
	.short	0x2c6c		| 08c6: moveal a4@(-32758),a6
	.short	0x800a		| 08c8:
	.short	0x4eae		| 08ca: jsr a6@(-870)
	.short	0xfc9a		| 08cc:
	.short	0x2c40		| 08ce: moveal d0,a6
	.short	0xbdea		| 08d0: cmpal a2@(4),a6
	.short	0x0004		| 08d2:
	.short	0x6700		| 08d4: beqw 0x990
	.short	0x00ba		| 08d6:
	.short	0x1a16		| 08d8: moveb a6@,d5
	.short	0x1cbc		| 08da: moveb #0,a6@
	.short	0x0000		| 08dc:
	.short	0x222a		| 08de: movel a2@(4),d1
	.short	0x0004		| 08e0:
	.short	0x74fe		| 08e2: moveq #-2,d2
	.short	0x202c		| 08e4: movel a4@(-32758),d0
	.short	0x800a		| 08e6:
	.short	0x2f0e		| 08e8: movel a6,sp@-
	.short	0x2c40		| 08ea: moveal d0,a6
	.short	0x4eae		| 08ec: jsr a6@(-84)
	.short	0xffac		| 08ee:
	.short	0x2480		| 08f0: movel d0,a2@
	.short	0x2c5f		| 08f2: moveal sp@+,a6
	.short	0x7000		| 08f4: moveq #0,d0
	.short	0x4a92		| 08f6: tstl a2@
	.short	0x56c0		| 08f8: sne d0
	.short	0x4400		| 08fa: negb d0
	.short	0x3c00		| 08fc: movew d0,d6
	.short	0x1c85		| 08fe: moveb d5,a6@
	.short	0x4a46		| 0900: tstw d6
	.short	0x6700		| 0902: beqw 0x9aa
	.short	0x00a6		| 0904:
	.short	0x7a00		| 0906: moveq #0,d5
	.short	0x222a		| 0908: movel a2@(4),d1
	.short	0x0004		| 090a:
	.short	0x74fe		| 090c: moveq #-2,d2
	.short	0x202c		| 090e: movel a4@(-32758),d0
	.short	0x800a		| 0910:
	.short	0x2f0e		| 0912: movel a6,sp@-
	.short	0x2c40		| 0914: moveal d0,a6
	.short	0x4eae		| 0916: jsr a6@(-84)
	.short	0xffac		| 0918:
	.short	0x2800		| 091a: movel d0,d4
	.short	0x2c5f		| 091c: moveal sp@+,a6
	.short	0x4a84		| 091e: tstl d4
	.short	0x672c		| 0920: beqs 0x94e
	.short	0x2204		| 0922: movel d4,d1
	.short	0x202c		| 0924: movel a4@(-32758),d0
	.short	0x800a		| 0926:
	.short	0x2f0e		| 0928: movel a6,sp@-
	.short	0x2c40		| 092a: moveal d0,a6
	.short	0x4eae		| 092c: jsr a6@(-210)
	.short	0xff2e		| 092e:
	.short	0x2a00		| 0930: movel d0,d5
	.short	0x2c5f		| 0932: moveal sp@+,a6
	.short	0x7000		| 0934: moveq #0,d0
	.short	0x4a85		| 0936: tstl d5
	.short	0x56c0		| 0938: sne d0
	.short	0x4400		| 093a: negb d0
	.short	0x3c00		| 093c: movew d0,d6
	.short	0x2204		| 093e: movel d4,d1
	.short	0x202c		| 0940: movel a4@(-32758),d0
	.short	0x800a		| 0942:
	.short	0x2f0e		| 0944: movel a6,sp@-
	.short	0x2c40		| 0946: moveal d0,a6
	.short	0x4eae		| 0948: jsr a6@(-90)
	.short	0xffa6		| 094a:
	.short	0x2c5f		| 094c: moveal sp@+,a6
	.short	0x4a46		| 094e: tstw d6
	.short	0x672e		| 0950: beqs 0x980
	.short	0x0c2e		| 0952: cmpib #47,a6@(-1)
	.short	0x002f		| 0954:
	.short	0xffff		| 0956:
	.short	0x671c		| 0958: beqs 0x976
	.short	0x4a85		| 095a: tstl d5
	.short	0x6722		| 095c: beqs 0x980
	.short	0x2205		| 095e: movel d5,d1
	.short	0x2412		| 0960: movel a2@,d2
	.short	0x202c		| 0962: movel a4@(-32758),d0
	.short	0x800a		| 0964:
	.short	0x2f0e		| 0966: movel a6,sp@-
	.short	0x2c40		| 0968: moveal d0,a6
	.short	0x4eae		| 096a: jsr a6@(-420)
	.short	0xfe5c		| 096c:
	.short	0x2800		| 096e: movel d0,d4
	.short	0x2c5f		| 0970: moveal sp@+,a6
	.short	0x4a84		| 0972: tstl d4
	.short	0x660a		| 0974: bnes 0x980
	.short	0x206a		| 0976: moveal a2@(4),a0
	.short	0x0004		| 0978:
	.short	0x224e		| 097a: moveal a6,a1
	.short	0x6100		| 097c: bsrw 0xec4
	.short	0x0546		| 097e:
	.short	0x2205		| 0980: movel d5,d1
	.short	0x282c		| 0982: movel a4@(-32758),d4
	.short	0x800a		| 0984:
	.short	0xc98e		| 0986: exg d4,a6
	.short	0x4eae		| 0988: jsr a6@(-90)
	.short	0xffa6		| 098a:
	.short	0xc98e		| 098c: exg d4,a6
	.short	0x601a		| 098e: bras 0x9aa
	.short	0x2207		| 0990: movel d7,d1
	.short	0x2a2c		| 0992: movel a4@(-32758),d5
	.short	0x800a		| 0994:
	.short	0xcb8e		| 0996: exg d5,a6
	.short	0x4eae		| 0998: jsr a6@(-96)
	.short	0xffa0		| 099a:
	.short	0x2480		| 099c: movel d0,a2@
	.short	0xcb8e		| 099e: exg d5,a6
	.short	0x7a00		| 09a0: moveq #0,d5
	.short	0x4a92		| 09a2: tstl a2@
	.short	0x56c5		| 09a4: sne d5
	.short	0x4405		| 09a6: negb d5
	.short	0x3c05		| 09a8: movew d5,d6
	.short	0x3006		| 09aa: movew d6,d0
	.short	0x48c0		| 09ac: extl d0
	.short	0x4e5d		| 09ae: unlk a5
	.short	0x4cdf		| 09b0: moveml sp@+,d2/d4-d7/a2-a3/a6
	.short	0x4cf4		| 09b2:
	.short	0x4e75		| 09b4: rts
	.short	0x48e7		| 09b6: moveml d2/d5-d7/a2-a3/a6,sp@-
	.short	0x2732		| 09b8:
	.short	0x2648		| 09ba: moveal a0,a3
	.short	0x2e00		| 09bc: movel d0,d7
	.short	0x2449		| 09be: moveal a1,a2
	.short	0x4e55		| 09c0: linkw a5,#-20
	.short	0xffec		| 09c2:
	.short	0x7a00		| 09c4: moveq #0,d5
	.short	0x2207		| 09c6: movel d7,d1
	.short	0x202c		| 09c8: movel a4@(-32758),d0
	.short	0x800a		| 09ca:
	.short	0x2f0e		| 09cc: movel a6,sp@-
	.short	0x2c40		| 09ce: moveal d0,a6
	.short	0x4eae		| 09d0: jsr a6@(-126)
	.short	0xff82		| 09d2:
	.short	0x2c00		| 09d4: movel d0,d6
	.short	0x2c5f		| 09d6: moveal sp@+,a6
	.short	0x204a		| 09d8: moveal a2,a0
	.short	0x2c6c		| 09da: moveal a4@(-32754),a6
	.short	0x800e		| 09dc:
	.short	0x4eae		| 09de: jsr a6@(-78)
	.short	0xffb2		| 09e0:
	.short	0x2c40		| 09e2: moveal d0,a6
	.short	0x200e		| 09e4: movel a6,d0
	.short	0x6700		| 09e6: beqw 0xb02
	.short	0x011a		| 09e8:
	.short	0x276e		| 09ea: movel a6@(74),a3@(44)
	.short	0x004a		| 09ec:
	.short	0x002c		| 09ee:
	.short	0x102e		| 09f0: moveb a6@(48),d0
	.short	0x0030		| 09f2:
	.short	0x5700		| 09f4: subqb #3,d0
	.short	0x6708		| 09f6: beqs 0xa00
	.short	0x5300		| 09f8: subqb #1,d0
	.short	0x671c		| 09fa: beqs 0xa18
	.short	0x6000		| 09fc: braw 0xaf0
	.short	0x00f2		| 09fe:
	.short	0x204b		| 0a00: moveal a3,a0
	.short	0x2007		| 0a02: movel d7,d0
	.short	0x224a		| 0a04: moveal a2,a1
	.short	0x6100		| 0a06: bsrw 0x886
	.short	0xfe7e		| 0a08:
	.short	0x3a00		| 0a0a: movew d0,d5
	.short	0x226b		| 0a0c: moveal a3@(36),a1
	.short	0x0024		| 0a0e:
	.short	0x2751		| 0a10: movel a1@,a3@(40)
	.short	0x0028		| 0a12:
	.short	0x6000		| 0a14: braw 0xaf0
	.short	0x00da		| 0a16:
	.short	0x2b6e		| 0a18: movel a6@(50),a5@(-4)
	.short	0x0032		| 0a1a:
	.short	0xfffc		| 0a1c:
	.short	0x222d		| 0a1e: movel a5@(-4),d1
	.short	0xfffc		| 0a20:
	.short	0x202c		| 0a22: movel a4@(-32758),d0
	.short	0x800a		| 0a24:
	.short	0x2f0e		| 0a26: movel a6,sp@-
	.short	0x2c40		| 0a28: moveal d0,a6
	.short	0x4eae		| 0a2a: jsr a6@(-870)
	.short	0xfc9a		| 0a2c:
	.short	0x2240		| 0a2e: moveal d0,a1
	.short	0x2c5f		| 0a30: moveal sp@+,a6
	.short	0xb3ed		| 0a32: cmpal a5@(-4),a1
	.short	0xfffc		| 0a34:
	.short	0x673c		| 0a36: beqs 0xa74
	.short	0x204b		| 0a38: moveal a3,a0
	.short	0x226d		| 0a3a: moveal a5@(-4),a1
	.short	0xfffc		| 0a3c:
	.short	0x2007		| 0a3e: movel d7,d0
	.short	0x6100		| 0a40: bsrw 0x886
	.short	0xfe44		| 0a42:
	.short	0x2400		| 0a44: movel d0,d2
	.short	0x4a42		| 0a46: tstw d2
	.short	0x6710		| 0a48: beqs 0xa5a
	.short	0x204b		| 0a4a: moveal a3,a0
	.short	0x2007		| 0a4c: movel d7,d0
	.short	0x224a		| 0a4e: moveal a2,a1
	.short	0x6100		| 0a50: bsrw 0x886
	.short	0xfe34		| 0a52:
	.short	0x3400		| 0a54: movew d0,d2
	.short	0x4a42		| 0a56: tstw d2
	.short	0x6604		| 0a58: bnes 0xa5e
	.short	0x7400		| 0a5a: moveq #0,d2
	.short	0x6002		| 0a5c: bras 0xa60
	.short	0x7401		| 0a5e: moveq #1,d2
	.short	0x3a02		| 0a60: movew d2,d5
	.short	0x4a45		| 0a62: tstw d5
	.short	0x6700		| 0a64: beqw 0xaf0
	.short	0x008a		| 0a66:
	.short	0x226b		| 0a68: moveal a3@(36),a1
	.short	0x0024		| 0a6a:
	.short	0x2751		| 0a6c: movel a1@,a3@(40)
	.short	0x0028		| 0a6e:
	.short	0x6000		| 0a70: braw 0xaf0
	.short	0x007e		| 0a72:
	.short	0x2b6b		| 0a74: movel a3@(36),a5@(-8)
	.short	0x0024		| 0a76:
	.short	0xfff8		| 0a78:
	.short	0x204b		| 0a7a: moveal a3,a0
	.short	0x2007		| 0a7c: movel d7,d0
	.short	0x224a		| 0a7e: moveal a2,a1
	.short	0x6100		| 0a80: bsrw 0x886
	.short	0xfe04		| 0a82:
	.short	0x3400		| 0a84: movew d0,d2
	.short	0x4a42		| 0a86: tstw d2
	.short	0x6716		| 0a88: beqs 0xaa0
	.short	0x204b		| 0a8a: moveal a3,a0
	.short	0x226d		| 0a8c: moveal a5@(-8),a1
	.short	0xfff8		| 0a8e:
	.short	0x2011		| 0a90: movel a1@,d0
	.short	0x226d		| 0a92: moveal a5@(-4),a1
	.short	0xfffc		| 0a94:
	.short	0x6100		| 0a96: bsrw 0x886
	.short	0xfdee		| 0a98:
	.short	0x3400		| 0a9a: movew d0,d2
	.short	0x4a42		| 0a9c: tstw d2
	.short	0x6604		| 0a9e: bnes 0xaa4
	.short	0x7400		| 0aa0: moveq #0,d2
	.short	0x6002		| 0aa2: bras 0xaa6
	.short	0x7401		| 0aa4: moveq #1,d2
	.short	0x3a02		| 0aa6: movew d2,d5
	.short	0x4a45		| 0aa8: tstw d5
	.short	0x6744		| 0aaa: beqs 0xaf0
	.short	0x7408		| 0aac: moveq #8,d2
	.short	0xd4ad		| 0aae: addl a5@(-8),d2
	.short	0xfff8		| 0ab0:
	.short	0x2b42		| 0ab2: movel d2,a5@(-20)
	.short	0xffec		| 0ab4:
	.short	0x226d		| 0ab6: moveal a5@(-8),a1
	.short	0xfff8		| 0ab8:
	.short	0x2b69		| 0aba: movel a1@(4),a5@(-12)
	.short	0x0004		| 0abc:
	.short	0xfff4		| 0abe:
	.short	0x2b51		| 0ac0: movel a1@,a5@(-16)
	.short	0xfff0		| 0ac2:
	.short	0x226d		| 0ac4: moveal a5@(-8),a1
	.short	0xfff8		| 0ac6:
	.short	0x206d		| 0ac8: moveal a5@(-20),a0
	.short	0xffec		| 0aca:
	.short	0x2368		| 0acc: movel a0@(4),a1@(4)
	.short	0x0004		| 0ace:
	.short	0x0004		| 0ad0:
	.short	0x2290		| 0ad2: movel a0@,a1@
	.short	0x226d		| 0ad4: moveal a5@(-20),a1
	.short	0xffec		| 0ad6:
	.short	0x236d		| 0ad8: movel a5@(-12),a1@(4)
	.short	0xfff4		| 0ada:
	.short	0x0004		| 0adc:
	.short	0x22ad		| 0ade: movel a5@(-16),a1@
	.short	0xfff0		| 0ae0:
	.short	0x206d		| 0ae2: moveal a5@(-4),a0
	.short	0xfffc		| 0ae4:
	.short	0x2007		| 0ae6: movel d7,d0
	.short	0x6100		| 0ae8: bsrw 0x698
	.short	0xfbae		| 0aea:
	.short	0x2740		| 0aec: movel d0,a3@(40)
	.short	0x0028		| 0aee:
	.short	0x204e		| 0af0: moveal a6,a0
	.short	0x202c		| 0af2: movel a4@(-32754),d0
	.short	0x800e		| 0af4:
	.short	0x2f0e		| 0af6: movel a6,sp@-
	.short	0x2c40		| 0af8: moveal d0,a6
	.short	0x4eae		| 0afa: jsr a6@(-90)
	.short	0xffa6		| 0afc:
	.short	0x2c5f		| 0afe: moveal sp@+,a6
	.short	0x603c		| 0b00: bras 0xb3e
	.short	0x204b		| 0b02: moveal a3,a0
	.short	0x2007		| 0b04: movel d7,d0
	.short	0x224a		| 0b06: moveal a2,a1
	.short	0x6100		| 0b08: bsrw 0x886
	.short	0xfd7c		| 0b0a:
	.short	0x3a00		| 0b0c: movew d0,d5
	.short	0x4a45		| 0b0e: tstw d5
	.short	0x672c		| 0b10: beqs 0xb3e
	.short	0x220a		| 0b12: movel a2,d1
	.short	0x202c		| 0b14: movel a4@(-32758),d0
	.short	0x800a		| 0b16:
	.short	0x2f0e		| 0b18: movel a6,sp@-
	.short	0x2c40		| 0b1a: moveal d0,a6
	.short	0x4eae		| 0b1c: jsr a6@(-870)
	.short	0xfc9a		| 0b1e:
	.short	0x2240		| 0b20: moveal d0,a1
	.short	0x2c5f		| 0b22: moveal sp@+,a6
	.short	0xb5c9		| 0b24: cmpal a1,a2
	.short	0x670a		| 0b26: beqs 0xb32
	.short	0x226b		| 0b28: moveal a3@(36),a1
	.short	0x0024		| 0b2a:
	.short	0x2751		| 0b2c: movel a1@,a3@(40)
	.short	0x0028		| 0b2e:
	.short	0x600c		| 0b30: bras 0xb3e
	.short	0x204a		| 0b32: moveal a2,a0
	.short	0x2007		| 0b34: movel d7,d0
	.short	0x6100		| 0b36: bsrw 0x698
	.short	0xfb60		| 0b38:
	.short	0x2740		| 0b3a: movel d0,a3@(40)
	.short	0x0028		| 0b3c:
	.short	0x4a45		| 0b3e: tstw d5
	.short	0x6700		| 0b40: beqw 0xbc8
	.short	0x0086		| 0b42:
	.short	0x206b		| 0b44: moveal a3@(36),a0
	.short	0x0024		| 0b46:
	.short	0x2b68		| 0b48: movel a0@(4),a5@(-4)
	.short	0x0004		| 0b4a:
	.short	0xfffc		| 0b4c:
	.short	0x222b		| 0b4e: movel a3@(40),d1
	.short	0x0028		| 0b50:
	.short	0x202c		| 0b52: movel a4@(-32758),d0
	.short	0x800a		| 0b54:
	.short	0x2f0e		| 0b56: movel a6,sp@-
	.short	0x2c40		| 0b58: moveal d0,a6
	.short	0x4eae		| 0b5a: jsr a6@(-126)
	.short	0xff82		| 0b5c:
	.short	0x2c5f		| 0b5e: moveal sp@+,a6
	.short	0x222d		| 0b60: movel a5@(-4),d1
	.short	0xfffc		| 0b62:
	.short	0x7400		| 0b64: moveq #0,d2
	.short	0x202c		| 0b66: movel a4@(-32758),d0
	.short	0x800a		| 0b68:
	.short	0x2f0e		| 0b6a: movel a6,sp@-
	.short	0x2c40		| 0b6c: moveal d0,a6
	.short	0x4eae		| 0b6e: jsr a6@(-768)
	.short	0xfd00		| 0b70:
	.short	0x2740		| 0b72: movel d0,a3@(24)
	.short	0x0018		| 0b74:
	.short	0x2c5f		| 0b76: moveal sp@+,a6
	.short	0x7000		| 0b78: moveq #0,d0
	.short	0x4aab		| 0b7a: tstl a3@(24)
	.short	0x0018		| 0b7c:
	.short	0x56c0		| 0b7e: sne d0
	.short	0x4400		| 0b80: negb d0
	.short	0x3a00		| 0b82: movew d0,d5
	.short	0x4a45		| 0b84: tstw d5
	.short	0x6740		| 0b86: beqs 0xbc8
	.short	0x206d		| 0b88: moveal a5@(-4),a0
	.short	0xfffc		| 0b8a:
	.short	0x2c6c		| 0b8c: moveal a4@(-32754),a6
	.short	0x800e		| 0b8e:
	.short	0x4eae		| 0b90: jsr a6@(-78)
	.short	0xffb2		| 0b92:
	.short	0x2c40		| 0b94: moveal d0,a6
	.short	0x200e		| 0b96: movel a6,d0
	.short	0x672e		| 0b98: beqs 0xbc8
	.short	0x4aae		| 0b9a: tstl a6@(70)
	.short	0x0046		| 0b9c:
	.short	0x6718		| 0b9e: beqs 0xbb8
	.short	0x206e		| 0ba0: moveal a6@(70),a0
	.short	0x0046		| 0ba2:
	.short	0x6100		| 0ba4: bsrw 0x7f4
	.short	0xfc4e		| 0ba6:
	.short	0x2740		| 0ba8: movel d0,a3@(32)
	.short	0x0020		| 0baa:
	.short	0x7000		| 0bac: moveq #0,d0
	.short	0x4aab		| 0bae: tstl a3@(32)
	.short	0x0020		| 0bb0:
	.short	0x56c0		| 0bb2: sne d0
	.short	0x4400		| 0bb4: negb d0
	.short	0x3a00		| 0bb6: movew d0,d5
	.short	0x204e		| 0bb8: moveal a6,a0
	.short	0x202c		| 0bba: movel a4@(-32754),d0
	.short	0x800e		| 0bbc:
	.short	0x2f0e		| 0bbe: movel a6,sp@-
	.short	0x2c40		| 0bc0: moveal d0,a6
	.short	0x4eae		| 0bc2: jsr a6@(-90)
	.short	0xffa6		| 0bc4:
	.short	0x2c5f		| 0bc6: moveal sp@+,a6
	.short	0x2206		| 0bc8: movel d6,d1
	.short	0x202c		| 0bca: movel a4@(-32758),d0
	.short	0x800a		| 0bcc:
	.short	0x2f0e		| 0bce: movel a6,sp@-
	.short	0x2c40		| 0bd0: moveal d0,a6
	.short	0x4eae		| 0bd2: jsr a6@(-126)
	.short	0xff82		| 0bd4:
	.short	0x2c5f		| 0bd6: moveal sp@+,a6
	.short	0x3005		| 0bd8: movew d5,d0
	.short	0x48c0		| 0bda: extl d0
	.short	0x4e5d		| 0bdc: unlk a5
	.short	0x4cdf		| 0bde: moveml sp@+,d2/d5-d7/a2-a3/a6
	.short	0x4ce4		| 0be0:
	.short	0x4e75		| 0be2: rts
	.short	0x48e7		| 0be4: moveml d2-d7/a2-a3/a6,sp@-
	.short	0x3f32		| 0be6:
	.short	0x4e55		| 0be8: linkw a5,#-12
	.short	0xfff4		| 0bea:
	.short	0x2b48		| 0bec: movel a0,a5@(-4)
	.short	0xfffc		| 0bee:
	.short	0x7e14		| 0bf0: moveq #20,d7
	.short	0x97cb		| 0bf2: subal a3,a3
	.short	0x7c00		| 0bf4: moveq #0,d6
	.short	0x7a00		| 0bf6: moveq #0,d5
	.short	0x7800		| 0bf8: moveq #0,d4
	.short	0x7600		| 0bfa: moveq #0,d3
	.short	0x95ca		| 0bfc: subal a2,a2
	.short	0x2b6d		| 0bfe: movel a5@(-4),a5@(-8)
	.short	0xfffc		| 0c00:
	.short	0xfff8		| 0c02:
	.short	0x6000		| 0c04: braw 0xcbc
	.short	0x00b6		| 0c06:
	.short	0x2016		| 0c08: movel a6@,d0
	.short	0xd0bc		| 0c0a: addl #2147483644,d0
	.short	0x7fff		| 0c0c:
	.short	0xfffc		| 0c0e:
	.short	0x6700		| 0c10: beqw 0xca6
	.short	0x0094		| 0c12:
	.short	0x6a10		| 0c14: bpls 0xc26
	.short	0x5680		| 0c16: addql #3,d0
	.short	0x6722		| 0c18: beqs 0xc3c
	.short	0x5380		| 0c1a: subql #1,d0
	.short	0x6726		| 0c1c: beqs 0xc44
	.short	0x5380		| 0c1e: subql #1,d0
	.short	0x6758		| 0c20: beqs 0xc7a
	.short	0x6000		| 0c22: braw 0xcbc
	.short	0x0098		| 0c24:
	.short	0x5380		| 0c26: subql #1,d0
	.short	0x6700		| 0c28: beqw 0xcac
	.short	0x0082		| 0c2a:
	.short	0x5380		| 0c2c: subql #1,d0
	.short	0x6700		| 0c2e: beqw 0xcb2
	.short	0x0082		| 0c30:
	.short	0x5380		| 0c32: subql #1,d0
	.short	0x6700		| 0c34: beqw 0xcb8
	.short	0x0082		| 0c36:
	.short	0x6000		| 0c38: braw 0xcbc
	.short	0x0082		| 0c3a:
	.short	0x266e		| 0c3c: moveal a6@(4),a3
	.short	0x0004		| 0c3e:
	.short	0x6000		| 0c40: braw 0xcbc
	.short	0x007a		| 0c42:
	.short	0x4aae		| 0c44: tstl a6@(4)
	.short	0x0004		| 0c46:
	.short	0x6700		| 0c48: beqw 0xcbc
	.short	0x0072		| 0c4a:
	.short	0x222e		| 0c4c: movel a6@(4),d1
	.short	0x0004		| 0c4e:
	.short	0x202c		| 0c50: movel a4@(-32758),d0
	.short	0x800a		| 0c52:
	.short	0x74fe		| 0c54: moveq #-2,d2
	.short	0x2f0e		| 0c56: movel a6,sp@-
	.short	0x2c40		| 0c58: moveal d0,a6
	.short	0x4eae		| 0c5a: jsr a6@(-84)
	.short	0xffac		| 0c5c:
	.short	0x2400		| 0c5e: movel d0,d2
	.short	0x2c5f		| 0c60: moveal sp@+,a6
	.short	0x4a82		| 0c62: tstl d2
	.short	0x6756		| 0c64: beqs 0xcbc
	.short	0x2206		| 0c66: movel d6,d1
	.short	0x202c		| 0c68: movel a4@(-32758),d0
	.short	0x800a		| 0c6a:
	.short	0x2f0e		| 0c6c: movel a6,sp@-
	.short	0x2c40		| 0c6e: moveal d0,a6
	.short	0x4eae		| 0c70: jsr a6@(-90)
	.short	0xffa6		| 0c72:
	.short	0x2c5f		| 0c74: moveal sp@+,a6
	.short	0x2c02		| 0c76: movel d2,d6
	.short	0x6042		| 0c78: bras 0xcbc
	.short	0x222e		| 0c7a: movel a6@(4),d1
	.short	0x0004		| 0c7c:
	.short	0x202c		| 0c7e: movel a4@(-32758),d0
	.short	0x800a		| 0c80:
	.short	0x2f0e		| 0c82: movel a6,sp@-
	.short	0x2c40		| 0c84: moveal d0,a6
	.short	0x4eae		| 0c86: jsr a6@(-96)
	.short	0xffa0		| 0c88:
	.short	0x2400		| 0c8a: movel d0,d2
	.short	0x2c5f		| 0c8c: moveal sp@+,a6
	.short	0x4a82		| 0c8e: tstl d2
	.short	0x672a		| 0c90: beqs 0xcbc
	.short	0x2206		| 0c92: movel d6,d1
	.short	0x202c		| 0c94: movel a4@(-32758),d0
	.short	0x800a		| 0c96:
	.short	0x2f0e		| 0c98: movel a6,sp@-
	.short	0x2c40		| 0c9a: moveal d0,a6
	.short	0x4eae		| 0c9c: jsr a6@(-90)
	.short	0xffa6		| 0c9e:
	.short	0x2c5f		| 0ca0: moveal sp@+,a6
	.short	0x2c02		| 0ca2: movel d2,d6
	.short	0x6016		| 0ca4: bras 0xcbc
	.short	0x282e		| 0ca6: movel a6@(4),d4
	.short	0x0004		| 0ca8:
	.short	0x6010		| 0caa: bras 0xcbc
	.short	0x2a2e		| 0cac: movel a6@(4),d5
	.short	0x0004		| 0cae:
	.short	0x600a		| 0cb0: bras 0xcbc
	.short	0x262e		| 0cb2: movel a6@(4),d3
	.short	0x0004		| 0cb4:
	.short	0x6004		| 0cb6: bras 0xcbc
	.short	0x246e		| 0cb8: moveal a6@(4),a2
	.short	0x0004		| 0cba:
	.short	0x41ed		| 0cbc: lea a5@(-8),a0
	.short	0xfff8		| 0cbe:
	.short	0x2c6c		| 0cc0: moveal a4@(-32750),a6
	.short	0x8012		| 0cc2:
	.short	0x4eae		| 0cc4: jsr a6@(-48)
	.short	0xffd0		| 0cc6:
	.short	0x2c40		| 0cc8: moveal d0,a6
	.short	0x240e		| 0cca: movel a6,d2
	.short	0x6600		| 0ccc: bnew 0xc08
	.short	0xff3a		| 0cce:
	.short	0x240b		| 0cd0: movel a3,d2
	.short	0x6700		| 0cd2: beqw 0xe1e
	.short	0x014a		| 0cd4:
	.short	0x7400		| 0cd6: moveq #0,d2
	.short	0xb48a		| 0cd8: cmpl a2,d2
	.short	0x6706		| 0cda: beqs 0xce2
	.short	0x4a83		| 0cdc: tstl d3
	.short	0x6700		| 0cde: beqw 0xe1e
	.short	0x013e		| 0ce0:
	.short	0x240a		| 0ce2: movel a2,d2
	.short	0x6602		| 0ce4: bnes 0xce8
	.short	0x7600		| 0ce6: moveq #0,d3
	.short	0xb8bc		| 0ce8: cmpl #4096,d4
	.short	0x0000		| 0cea:
	.short	0x1000		| 0cec:
	.short	0x6406		| 0cee: bccs 0xcf6
	.short	0x283c		| 0cf0: movel #4096,d4
	.short	0x0000		| 0cf2:
	.short	0x1000		| 0cf4:
	.short	0x7402		| 0cf6: moveq #2,d2
	.short	0xd483		| 0cf8: addl d3,d2
	.short	0xe782		| 0cfa: asll #3,d2
	.short	0x7034		| 0cfc: moveq #52,d0
	.short	0xd480		| 0cfe: addl d0,d2
	.short	0x2002		| 0d00: movel d2,d0
	.short	0x6100		| 0d02: bsrw 0x64c
	.short	0xf948		| 0d04:
	.short	0x2c40		| 0d06: moveal d0,a6
	.short	0x200e		| 0d08: movel a6,d0
	.short	0x6700		| 0d0a: beqw 0xe1e
	.short	0x0112		| 0d0c:
	.short	0x1d7c		| 0d0e: moveb #0,a6@(9)
	.short	0x0000		| 0d10:
	.short	0x0009		| 0d12:
	.short	0x206c		| 0d14: moveal a4@(-32766),a0
	.short	0x8002		| 0d16:
	.short	0x2d68		| 0d18: movel a0@(44),a6@(14)
	.short	0x002c		| 0d1a:
	.short	0x000e		| 0d1c:
	.short	0x3d7c		| 0d1e: movew #40,a6@(18)
	.short	0x0028		| 0d20:
	.short	0x0012		| 0d22:
	.short	0x7000		| 0d24: moveq #0,d0
	.short	0x2d40		| 0d26: movel d0,a6@(24)
	.short	0x0018		| 0d28:
	.short	0x7000		| 0d2a: moveq #0,d0
	.short	0x2d40		| 0d2c: movel d0,a6@(28)
	.short	0x001c		| 0d2e:
	.short	0x7000		| 0d30: moveq #0,d0
	.short	0x2d40		| 0d32: movel d0,a6@(32)
	.short	0x0020		| 0d34:
	.short	0x41ee		| 0d36: lea a6@(52),a0
	.short	0x0034		| 0d38:
	.short	0x2d48		| 0d3a: movel a0,a6@(36)
	.short	0x0024		| 0d3c:
	.short	0x2d44		| 0d3e: movel d4,a6@(44)
	.short	0x002c		| 0d40:
	.short	0x2d6e		| 0d42: movel a6@(36),a6@(48)
	.short	0x0024		| 0d44:
	.short	0x0030		| 0d46:
	.short	0x204e		| 0d48: moveal a6,a0
	.short	0x224b		| 0d4a: moveal a3,a1
	.short	0x2006		| 0d4c: movel d6,d0
	.short	0x6100		| 0d4e: bsrw 0x9b6
	.short	0xfc66		| 0d50:
	.short	0x4a40		| 0d52: tstw d0
	.short	0x6700		| 0d54: beqw 0xe14
	.short	0x00be		| 0d56:
	.short	0x204e		| 0d58: moveal a6,a0
	.short	0x224a		| 0d5a: moveal a2,a1
	.short	0x2003		| 0d5c: movel d3,d0
	.short	0x6100		| 0d5e: bsrw 0x81c
	.short	0xfabc		| 0d60:
	.short	0x4a40		| 0d62: tstw d0
	.short	0x6700		| 0d64: beqw 0xe14
	.short	0x00ae		| 0d66:
	.short	0x222e		| 0d68: movel a6@(40),d1
	.short	0x0028		| 0d6a:
	.short	0x202c		| 0d6c: movel a4@(-32758),d0
	.short	0x800a		| 0d6e:
	.short	0x2f0e		| 0d70: movel a6,sp@-
	.short	0x2c40		| 0d72: moveal d0,a6
	.short	0x4eae		| 0d74: jsr a6@(-96)
	.short	0xffa0		| 0d76:
	.short	0x2400		| 0d78: movel d0,d2
	.short	0x2c5f		| 0d7a: moveal sp@+,a6
	.short	0x4a82		| 0d7c: tstl d2
	.short	0x6700		| 0d7e: beqw 0xe14
	.short	0x0094		| 0d80:
	.short	0x487a		| 0d82: pea %pc@(0x79c)
	.short	0xfa18		| 0d84:
	.short	0x4878		| 0d86: pea 0x2
	.short	0x0002		| 0d88:
	.short	0x2f02		| 0d8a: movel d2,sp@-
	.short	0x2f3c		| 0d8c: movel #-2147482632,sp@-
	.short	0x8000		| 0d8e:
	.short	0x03f8		| 0d90:
	.short	0x2f05		| 0d92: movel d5,sp@-
	.short	0x2f3c		| 0d94: movel #-2147482635,sp@-
	.short	0x8000		| 0d96:
	.short	0x03f5		| 0d98:
	.short	0x226e		| 0d9a: moveal a6@(36),a1
	.short	0x0024		| 0d9c:
	.short	0x2f29		| 0d9e: movel a1@(4),sp@-
	.short	0x0004		| 0da0:
	.short	0x2f3c		| 0da2: movel #-2147482636,sp@-
	.short	0x8000		| 0da4:
	.short	0x03f4		| 0da6:
	.short	0xb8ae		| 0da8: cmpl a6@(44),d4
	.short	0x002c		| 0daa:
	.short	0x6304		| 0dac: blss 0xdb2
	.short	0x2004		| 0dae: movel d4,d0
	.short	0x6004		| 0db0: bras 0xdb6
	.short	0x202e		| 0db2: movel a6@(44),d0
	.short	0x002c		| 0db4:
	.short	0x2f00		| 0db6: movel d0,sp@-
	.short	0x2f3c		| 0db8: movel #-2147482637,sp@-
	.short	0x8000		| 0dba:
	.short	0x03f3		| 0dbc:
	.short	0x2f2e		| 0dbe: movel a6@(24),sp@-
	.short	0x0018		| 0dc0:
	.short	0x2f3c		| 0dc2: movel #-2147482647,sp@-
	.short	0x8000		| 0dc4:
	.short	0x03e9		| 0dc6:
	.short	0x6100		| 0dc8: bsrw 0xea0
	.short	0x00d6		| 0dca:
	.short	0x4fef		| 0dcc: lea sp@(48),sp
	.short	0x0030		| 0dce:
	.short	0x2b40		| 0dd0: movel d0,a5@(-8)
	.short	0xfff8		| 0dd2:
	.short	0x4aad		| 0dd4: tstl a5@(-8)
	.short	0xfff8		| 0dd6:
	.short	0x672a		| 0dd8: beqs 0xe04
	.short	0x226d		| 0dda: moveal a5@(-8),a1
	.short	0xfff8		| 0ddc:
	.short	0x41e9		| 0dde: lea a1@(92),a0
	.short	0x005c		| 0de0:
	.short	0x2b48		| 0de2: movel a0,a5@(-12)
	.short	0xfff4		| 0de4:
	.short	0x2d6d		| 0de6: movel a5@(-12),a6@(20)
	.short	0xfff4		| 0de8:
	.short	0x0014		| 0dea:
	.short	0x206d		| 0dec: moveal a5@(-12),a0
	.short	0xfff4		| 0dee:
	.short	0x224e		| 0df0: moveal a6,a1
	.short	0x202c		| 0df2: movel a4@(-32762),d0
	.short	0x8006		| 0df4:
	.short	0x2f0e		| 0df6: movel a6,sp@-
	.short	0x2c40		| 0df8: moveal d0,a6
	.short	0x4eae		| 0dfa: jsr a6@(-366)
	.short	0xfe92		| 0dfc:
	.short	0x2c5f		| 0dfe: moveal sp@+,a6
	.short	0x7e00		| 0e00: moveq #0,d7
	.short	0x6010		| 0e02: bras 0xe14
	.short	0x2202		| 0e04: movel d2,d1
	.short	0x202c		| 0e06: movel a4@(-32758),d0
	.short	0x800a		| 0e08:
	.short	0x2f0e		| 0e0a: movel a6,sp@-
	.short	0x2c40		| 0e0c: moveal d0,a6
	.short	0x4eae		| 0e0e: jsr a6@(-90)
	.short	0xffa6		| 0e10:
	.short	0x2c5f		| 0e12: moveal sp@+,a6
	.short	0x4a87		| 0e14: tstl d7
	.short	0x6706		| 0e16: beqs 0xe1e
	.short	0x204e		| 0e18: moveal a6,a0
	.short	0x7000		| 0e1a: moveq #0,d0
	.short	0x6114		| 0e1c: bsrs 0xe32
	.short	0x2206		| 0e1e: movel d6,d1
	.short	0x2c6c		| 0e20: moveal a4@(-32758),a6
	.short	0x800a		| 0e22:
	.short	0x4eae		| 0e24: jsr a6@(-90)
	.short	0xffa6		| 0e26:
	.short	0x2007		| 0e28: movel d7,d0
	.short	0x4e5d		| 0e2a: unlk a5
	.short	0x4cdf		| 0e2c: moveml sp@+,d2-d7/a2-a3/a6
	.short	0x4cfc		| 0e2e:
	.short	0x4e75		| 0e30: rts
	.short	0x48e7		| 0e32: moveml d6-d7/a2-a3/a6,sp@-
	.short	0x0332		| 0e34:
	.short	0x2648		| 0e36: moveal a0,a3
	.short	0x2e00		| 0e38: movel d0,d7
	.short	0x244b		| 0e3a: moveal a3,a2
	.short	0x2c6a		| 0e3c: moveal a2@(36),a6
	.short	0x0024		| 0e3e:
	.short	0x2c2a		| 0e40: movel a2@(28),d6
	.short	0x001c		| 0e42:
	.short	0x6020		| 0e44: bras 0xe66
	.short	0x2216		| 0e46: movel a6@,d1
	.short	0x202c		| 0e48: movel a4@(-32758),d0
	.short	0x800a		| 0e4a:
	.short	0x2f0e		| 0e4c: movel a6,sp@-
	.short	0x2c40		| 0e4e: moveal d0,a6
	.short	0x4eae		| 0e50: jsr a6@(-90)
	.short	0xffa6		| 0e52:
	.short	0x2c5f		| 0e54: moveal sp@+,a6
	.short	0x4aae		| 0e56: tstl a6@(4)
	.short	0x0004		| 0e58:
	.short	0x6708		| 0e5a: beqs 0xe64
	.short	0x206e		| 0e5c: moveal a6@(4),a0
	.short	0x0004		| 0e5e:
	.short	0x6100		| 0e60: bsrw 0x676
	.short	0xf814		| 0e62:
	.short	0x508e		| 0e64: addql #8,a6
	.short	0x2006		| 0e66: movel d6,d0
	.short	0x5386		| 0e68: subql #1,d6
	.short	0x4a80		| 0e6a: tstl d0
	.short	0x66d8		| 0e6c: bnes 0xe46
	.short	0x4aaa		| 0e6e: tstl a2@(32)
	.short	0x0020		| 0e70:
	.short	0x6708		| 0e72: beqs 0xe7c
	.short	0x206a		| 0e74: moveal a2@(32),a0
	.short	0x0020		| 0e76:
	.short	0x6100		| 0e78: bsrw 0x676
	.short	0xf7fc		| 0e7a:
	.short	0x4aaa		| 0e7c: tstl a2@(24)
	.short	0x0018		| 0e7e:
	.short	0x6712		| 0e80: beqs 0xe94
	.short	0x222a		| 0e82: movel a2@(24),d1
	.short	0x0018		| 0e84:
	.short	0x202c		| 0e86: movel a4@(-32758),d0
	.short	0x800a		| 0e88:
	.short	0x2f0e		| 0e8a: movel a6,sp@-
	.short	0x2c40		| 0e8c: moveal d0,a6
	.short	0x4eae		| 0e8e: jsr a6@(-156)
	.short	0xff64		| 0e90:
	.short	0x2c5f		| 0e92: moveal sp@+,a6
	.short	0x204a		| 0e94: moveal a2,a0
	.short	0x6100		| 0e96: bsrw 0x676
	.short	0xf7de		| 0e98:
	.short	0x4cdf		| 0e9a: moveml sp@+,d6-d7/a2-a3/a6
	.short	0x4cc0		| 0e9c:
	.short	0x4e75		| 0e9e: rts
	.short	0x4e55		| 0ea0: linkw a5,#0
	.short	0x0000		| 0ea2:
	.short	0x41ed		| 0ea4: lea a5@(8),a0
	.short	0x0008		| 0ea6:
	.short	0x6100		| 0ea8: bsrw 0xef0
	.short	0x0046		| 0eaa:
	.short	0x2040		| 0eac: moveal d0,a0
	.short	0x2008		| 0eae: movel a0,d0
	.short	0x4e5d		| 0eb0: unlk a5
	.short	0x4e75		| 0eb2: rts
	.short	0x2248		| 0eb4: moveal a0,a1
	.short	0x6002		| 0eb6: bras 0xeba
	.short	0x5288		| 0eb8: addql #1,a0
	.short	0x4a10		| 0eba: tstb a0@
	.short	0x66fa		| 0ebc: bnes 0xeb8
	.short	0x2008		| 0ebe: movel a0,d0
	.short	0x9089		| 0ec0: subl a1,d0
	.short	0x4e75		| 0ec2: rts
	.short	0x2f0b		| 0ec4: movel a3,sp@-
	.short	0x2648		| 0ec6: moveal a0,a3
	.short	0x6004		| 0ec8: bras 0xece
	.short	0x5289		| 0eca: addql #1,a1
	.short	0x5288		| 0ecc: addql #1,a0
	.short	0x1091		| 0ece: moveb a1@,a0@
	.short	0x4a10		| 0ed0: tstb a0@
	.short	0x66f6		| 0ed2: bnes 0xeca
	.short	0x200b		| 0ed4: movel a3,d0
	.short	0x265f		| 0ed6: moveal sp@+,a3
	.short	0x4e75		| 0ed8: rts
	.short	0x4e71		| 0eda: nop
	.short	0x206f		| 0edc: moveal sp@(4),a0
	.short	0x0004		| 0ede:
	.short	0x42a8		| 0ee0: clrl a0@(4)
	.short	0x0004		| 0ee2:
	.short	0x2148		| 0ee4: movel a0,a0@(8)
	.short	0x0008		| 0ee6:
	.short	0x5888		| 0ee8: addql #4,a0
	.short	0x2108		| 0eea: movel a0,a0@-
	.short	0x4e75		| 0eec: rts
	.short	0x0000		| 0eee: orib #14,d0
	.short	0x2f0e		| 0ef0:
	.short	0x2208		| 0ef2: movel a0,d1
	.short	0x2c6c		| 0ef4: moveal a4@(-32758),a6
	.short	0x800a		| 0ef6:
	.short	0x4eae		| 0ef8: jsr a6@(-498)
	.short	0xfe0e		| 0efa:
	.short	0x2c5f		| 0efc: moveal sp@+,a6
	.short	0x4e75		| 0efe: rts
	.short	0x7000		| 0f00: moveq #0,d0
	.short	0x4e75		| 0f02: rts
	.short	0x7001		| 0f04: moveq #1,d0
	.short	0x4e75		| 0f06: rts
	.short	0x7000		| 0f08: moveq #0,d0
	.short	0x4e75		| 0f0a: rts
	.short	0x7001		| 0f0c: moveq #1,d0
	.short	0x4e75		| 0f0e: rts
	.short	0x4e75		| 0f10: rts
	.short	0x4e71		| 0f12: nop
	.short	0x4e75		| 0f14: rts
	.short	0x4e71		| 0f16: nop
	.short	0x4e75		| 0f18: rts
	.short	0x4e71		| 0f1a: nop

	.data
wbsdata:
	.long	0		| DATA+0: libbase (rest uninitialized)
