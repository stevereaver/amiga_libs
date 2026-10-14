/* expname.library 1.4 (20.7.95) reconstruction
 *
 * "expname.library V1.4  (C) 1995 Richard Koerber" - the classic
 * expansion.library board-name database: ExName() maps a Zorro
 * expansion board (or manufacturer/product id pair) to human-
 * readable manufacturer and product name strings via sorted
 * lookup tables.  Unknown ids are rendered as decimal numbers.
 *
 * Layout mirrors the original hunk:
 *   +0x00  error stub (moveq #-1,d0; rts)
 *   +0x04  RomTag (AUTOINIT, ver 1 rev 4, NT_LIBRARY)
 *   +0x1e  "expname.library" / "$VER:" + id string / banner
 *   +0xaa  InitTable (dataSize 0x2c, functab, datatab, init)
 *   +0xf2  LibInit: stores libbase @ +0x8b2, execbase+seglist
 *   +0x112 Open / +0x120 Close / +0x134 Expunge / +0x17c null
 *   +0x180 RawDoFmt "%ld" decimal fallback helper
 *   +0x1ac ExName (the only public vector)
 *   +0x24a manufacturer table, then strings+product tables
 *   +0x8b2 self-referential libbase cell, +0x8b8 pad nops
 *
 * Library data (posSize 0x2c): +0x20 openCnt  +0x23 flag bit0
 * (deferred expunge)  +0x24 ExecBase  +0x28 seglist
 */
	.text
/*------------------------- error stub -------------------------*/
	.globl	_start
_start:	moveq	#-1,%d0
	rts

/*------------------------- RomTag -----------------------------*/
_romtag:
	.short	0x4afc
	.long	_romtag		/* MatchWord -> self */
	.long	_endskip
	.byte	0x80,1,9,0	/* AUTOINIT ver 1 NT_LIBRARY pri 0 */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:	.ascii	"expname.library\0"
		.ascii	"$VER:"
_idstr:		.ascii	"expname.library 1.4 (20.7.95)\015\012\0"
_banner:	.ascii	"expname.library V1.4  (C) 1995 Richard K\366rber     e-mail: shred@tfh.dssd.sub.org   \015\012\0"
		.align 2

/*------------------------- InitTable --------------------------*/
		.align 2
_inittab:
	.long	0x2c
	.long	_functab
	.long	_datatab
	.long	_init

_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_null
	.long	_exname
	.long	-1

_datatab:
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE  ln_Type      = NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG  ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE  lib_Flags    = 6 */
	.byte	0x90,0x14		/* INITWORD  lib_Version */
	.short	1
	.byte	0x90,0x16		/* INITWORD  lib_Revision */
	.short	4
	.byte	0x80,0x18		/* INITLONG  lib_IdString */
	.long	_idstr
	.long	0

/*------------------------- init -------------------------------*/
_init:
	moveml	%d1-%a6,%sp@-
	moveal	%d0,%a5
	movel	%d0,_libbase:l
	movel	%a6,%a5@(36)
	movel	%a0,%a5@(40)
	movel	%a5,%d0
	moveml	%sp@+,%d1-%a6
	rts
	moveq	#0,%d0		/* dead stub */
	bras	_init+0x16

/*------------------------- open -------------------------------*/
_open:
	addqw	#1,%a6@(32)
	bclr	#0,%a6@(35)
	movel	%a6,%d0
	rts

/*------------------------- close ------------------------------*/
_close:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	jne	2f
	btst	#0,%a6@(35)
	jeq	2f
	bsrs	_expunge
2:	rts

/*------------------------- expunge ----------------------------*/
_expunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(36),%a6
	tstw	%a5@(32)
	jeq	1f
	bset	#0,%a5@(35)
	moveq	#0,%d0
	bra.w	3f
1:	movel	%a5@(40),%d2
	moveal	%a5,%a1
	moveal	4:w,%a6
	jsr	%a6@(-252)
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0
	subal	%d0,%a1
	addw	%a5@(18),%d0
	moveal	4:w,%a6
	jsr	%a6@(-210)
	movel	%d2,%d0
3:	moveml	%sp@+,%d2/%a5-%a6
	rts

/*------------------------- reserved ---------------------------*/
_null:	moveq	#0,%d0
	rts

/*--- helper: format d0 as decimal string into buffer at a0 ----*/
_fmtnum:
	moveml	%d0-%d3/%a0-%a3,%sp@-
	moveal	%a0,%a3
	lea	%pc@(_fmtstr),%a0
	lea	%pc@(_putch),%a2
	movel	%d0,%sp@-
	moveal	%sp,%a1
	moveal	4:w,%a6
	jsr	%a6@(-522)		/* RawDoFmt */
	addql	#4,%sp
	moveml	%sp@+,%d0-%d3/%a0-%a3
	rts
_putch:	moveb	%d0,%a3@+
	rts
_fmtstr:	.ascii	"#%ld\0"
	.byte	0

/*--- ExName(board|mfr,prod, mfrbuf, prodbuf) ------------------*/
/* a0=mfrbuf a1=prodbuf a2=board|0 d0=mfr d1=prod -> d0=-1 found */
_exname:
	moveml	%d1-%a6,%sp@-
	moveal	%a0,%a4
	moveal	%a1,%a5
	moveq	#0,%d6
	moveq	#0,%d7
	movel	%a2,%d2
	beq.w	1f
	movew	%a2@(20),%d6
	moveb	%a2@(17),%d7
	bra.w	2f
1:	movew	%d0,%d6
	moveb	%d1,%d7
2:	lea	%pc@(_mfrtab),%a0
3:	movel	%a0@,%d0
	.short	0xb0bc
	.long	-1		/* cmpl #-1,d0 */
	beq.w	4f
	cmpl	%d0,%d6
	beq.w	5f
	bcs.w	4f
	lea	%a0@(12),%a0
	bra.w	3b
5:	moveal	%a0@(4),%a1
6:	moveb	%a1@+,%a4@+
	bne.w	6b
	moveal	%a0@(8),%a0
7:	movel	%a0@,%d0
	.short	0xb0bc
	.long	-1		/* cmpl #-1,d0 */
	beq.w	8f
	cmpl	%d0,%d7
	beq.w	9f
	bcs.w	8f
	addql	#8,%a0
	bra.w	7b
9:	moveal	%a0@(4),%a1
10:	moveb	%a1@+,%a5@+
	bne.w	10b
	bra.w	11f
4:	movel	%d6,%d0
	moveal	%a4,%a0
	bsr.w	_fmtnum
8:	movel	%d7,%d0
	moveal	%a5,%a0
	bsr.w	_fmtnum
	bra.w	12f
11:	moveq	#-1,%d0
	moveml	%sp@+,%d1-%a6
	rts
12:	moveq	#0,%d0
	bra.w	11b+2

/*------------------------- tables -----------------------------*/
	.align 2
_mfrtab:
	.long	0x100,s356,pt47e
	.long	0x201,s35e,pt498
	.long	0x202,s377,pt4b4
	.long	0x420,s390,pt528
	.long	0x7e1,s396,pt540
	.long	0x7fe,s3d3,pt59e
	.long	0x804,s3ac,pt5b6
	.long	0x807,s3b5,pt5cc
	.long	0x819,s3cd,pt5e8
	.long	0x82c,s3d3,pt5fc
	.long	0x836,s3d7,pt664
	.long	0x845,s3f3,pt68e
	.long	0x877,s400,pt6ba
	.long	0x87b,s40e,pt720
	.long	0x891,s396,pt6ee
	.long	0x89b,s422,pt744
	.long	0xa00,s434,pt75c
	.long	0x2017,s447,pt77a
	.long	0x2140,s44e,pt7d6
	.long	0x2222,s455,pt82a
	.long	0x3ff7,s45c,pt840
	.long	0x4754,s468,pt854
	.long	-1

s356:	.ascii	"Memphis\0"
s35e:	.ascii	"Commodore (Braunschweig)\0"
s377:	.ascii	"Commodore (West Chester)\0"
s390:	.ascii	"Supra\0"
s396:	.ascii	"Great Valley Products\0"
s3ac:	.ascii	"Jochheim\0"
s3b5:	.ascii	"Checkpoint Technologies\0"
s3cd:	.ascii	"Golem\0"
s3d3:	.ascii	"BSC\0"
s3d7:	.ascii	"Advanced Systems & Software\0"
s3f3:	.ascii	"XPert/ProDev\0"
s400:	.ascii	"VillageTronic\0"
s40e:	.ascii	"Utilities Unlimited\0"
s422:	.ascii	"MacroSystem (USA)\0"
s434:	.ascii	"Harms Professional\0"
s447:	.ascii	"Vortex\0"
s44e:	.ascii	"Phase5\0"
s455:	.ascii	"Apollo\0"
s45c:	.ascii	"Uwe Gerlach\0"
s468:	.ascii	"MacroSystem (Germany)\0"
pt47e:
	.long	0x0,s48a
	.long	-1
s48a:	.ascii	"Stormbringer\0"
	.byte	0
pt498:
	.long	0x1,s4a4
	.long	-1
s4a4:	.ascii	"XT Bridgeboard\0"
	.byte	0
pt4b4:
	.long	0x2,s4f0
	.long	0x3,s4f6
	.long	0x9,s501
	.long	0xa,s507
	.long	0x46,s50d
	.long	0x51,s513
	.long	0x70,s519
	.long	-1
s4f0:	.ascii	"A2091\0"
s4f6:	.ascii	"A2091/A590\0"
s501:	.ascii	"A2060\0"
s507:	.ascii	"A205x\0"
s50d:	.ascii	"A2232\0"
s513:	.ascii	"A2630\0"
s519:	.ascii	"A2065 Ethernet\0"
pt528:
	.long	0x10,s534
	.long	-1
s534:	.ascii	"2400 Modem\0"
	.byte	0
pt540:
	.long	0xa,s564
	.long	0xb,s572
	.long	0x20,s581
	.long	0xff,s590
	.long	-1
s564:	.ascii	"Series II RAM\0"
s572:	.ascii	"Series II SCSI\0"
s581:	.ascii	"IV-24 Graphics\0"
s590:	.ascii	"I/O-Extender\0"
	.byte	0
pt59e:
	.long	0x3,s5aa
	.long	-1
s5aa:	.ascii	"ALF 3 SCSI\0"
	.byte	0
pt5b6:
	.long	0x1,s5c2
	.long	-1
s5c2:	.ascii	"RAM board\0"
pt5cc:
	.long	0x0,s5d8
	.long	-1
s5d8:	.ascii	"Serial Solution\0"
pt5e8:
	.long	0x2,s5f4
	.long	-1
s5f4:	.ascii	"SCSI-II\0"
pt5fc:
	.long	0x5,s628
	.long	0x6,s635
	.long	0x10,s63c
	.long	0x12,s649
	.long	0x40,s657
	.long	-1
s628:	.ascii	"Oktagon 2008\0"
s635:	.ascii	"Tandem\0"
s63c:	.ascii	"Par/Ser Card\0"
s649:	.ascii	"MultiFace III\0"
s657:	.ascii	"ISDN Master\0"
	.byte	0
pt664:
	.long	0x1,s678
	.long	0x8,s683
	.long	-1
s678:	.ascii	"Nexus SCSI\0"
s683:	.ascii	"Nexus RAM\0"
	.byte	0
pt68e:
	.long	0x3,s6a2
	.long	0x4,s6ad
	.long	-1
s6a2:	.ascii	"Merlin RAM\0"
s6ad:	.ascii	"Merlin Board\0"
pt6ba:
	.long	0xb,s6ce
	.long	0xc,s6dd
	.long	-1
s6ce:	.ascii	"Picasso II RAM\0"
s6dd:	.ascii	"Picasso II Board\0"
pt6ee:
	.long	0x1,s702
	.long	0x2,s70f
	.long	-1
s702:	.ascii	"Spectrum RAM\0"
s70f:	.ascii	"Spectrum Graphic\0"
pt720:
	.long	0x15,s734
	.long	0x20,s734
	.long	-1
s734:	.ascii	"Emplant Deluxe\0"
	.byte	0
pt744:
	.long	0x13,s750
	.long	-1
s750:	.ascii	"Warp Engine\0"
pt75c:
	.long	0xd0,s768
	.long	-1
s768:	.ascii	"3500 Turbo board\0"
	.byte	0
pt77a:
	.long	0x7,s796
	.long	0x8,s7ae
	.long	0x9,s7be
	.long	-1
s796:	.ascii	"Golden Gate 80386 Board\0"
s7ae:	.ascii	"Golden Gate RAM\0"
s7be:	.ascii	"Golden Gate 80486 Board\0"
pt7d6:
	.long	0xa,s7f2
	.long	0xb,s7ff
	.long	0x22,s81e
	.long	-1
s7f2:	.ascii	"FastLane RAM\0"
s7ff:	.ascii	"FastLane SCSI\0"
	.byte	0x42,0x6c,0x69,0x7a,0x7a,0x61,0x72,0x64,0x20,0x31,0x32,0x33,0x30,0x2d,0x49,0x49,0x00
s81e:	.ascii	"CyberVision\0"
pt82a:
	.long	0x22,s836
	.long	-1
s836:	.ascii	"AT-Apollo\0"
pt840:
	.long	0xd4,s84c
	.long	-1
s84c:	.ascii	"RAM/ROM\0"
pt854:
	.long	0x3,s880
	.long	0x4,s888
	.long	0x5,s88d
	.long	0x6,s898
	.long	0x8,s8a2
	.long	-1
s880:	.ascii	"Maestro\0"
s888:	.ascii	"VLab\0"
s88d:	.ascii	"MaestroPro\0"
s898:	.ascii	"Retina Z2\0"
s8a2:	.ascii	"MultiEvolution\0"

	.byte	0	/* pad */
_libbase:	.long	0	/* init stores libbase here (abs ref) */
	nop
_endskip:
	nop
	nop
