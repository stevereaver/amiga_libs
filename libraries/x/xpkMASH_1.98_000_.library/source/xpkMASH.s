/*
 * xpkMASH.library 1.98 (68000 build) -- assembly reconstruction
 * of binary/xpkMASH_1.98(000).library
 *   $VER: xpkMASH.library_000 V1.98
 *
 * Faithful transcription of the original code hunk: resident module,
 * RomTag, InitTable (absolute-long functab, RELOC32-covered), InitStruct
 * data, XPK sublibrary info block + mode record, and the complete
 * compressor/decompressor.
 *
 * Rebuilds to a BYTE-IDENTICAL library (hunk map, code, strings,
 * relocations).  A few instructions are emitted as .short because
 * gas optimizes their encodings:
 *   - movea.l $0(An),Am   -> gas drops the explicit 0 disp word
 *   - move.b  (Ax)+,(Ay)+ -> the mem-to-mem byte copy form
 * Those lines are marked with the disassembly in a comment.
 *
 * xsp layout used by the packer:
 *   +0 InBuf  +4 InLen  +8 OutBuf  +12 OutBufLen(unused)
 *   +16 OutLen(out)  +28 mode(=100)  +52 sub-ptr  +60 out-end  +64 hashsize
 */
	.file	"xpkMASH_000.s"
	.text
	.globl	_start
_start:
	moveq	#-1,%d0
	rts
_romtag:
	.word	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_endmodule		/* rt_EndSkip = code end */
	.byte	0x80,1,9,0		/* AUTOINIT, v1, NT_LIBRARY, pri 0 */
	.long	_libname
	.long	_idstr
	.long	_inittab
_libname:
	.ascii	"xpkMASH.library"
	.byte	0
_idstr:
	.ascii	" $VER: xpkMASH.library_000 V1.98"
	.byte	13,10,0,0
_inittab:
	.long	0x4a			/* dataSize */
	.long	_functab
	.long	_datatab
	.long	_LibInit
_functab:
	.long	_LibOpen		/* -6   */
	.long	_LibClose		/* -12  */
	.long	_LibExpunge		/* -18  */
	.long	_ret0a			/* -24  */
	.long	_XpksPackerInfo		/* -30  */
	.long	_XpksPackChunk		/* -36  */
	.long	_ret0b			/* -42  */
	.long	_ret0b			/* -48  */
	.long	_XpksUnpackChunk	/* -54  */
	.long	_ret0b			/* -60  */
	.long	0xffffffff
_datatab:
	.word	0xa00c			/* byte @0x0c */
	.byte	9,0
	.word	0x800a			/* long @0x0a = ln_Name */
	.long	_libname
	.word	0xa00e			/* byte @0x0e = lib_Flags */
	.byte	6,0
	.word	0x9014			/* word @0x14 = version */
	.short	1
	.word	0x9016			/* word @0x16 = revision */
	.short	0x62
	.word	0x8018			/* long @0x18 = idstring */
	.long	_idstr
	.short	0,0
_xpkinfo:
	.short	1,1,2,0		/* xpkver,libver,masterver,modesver */
	.long	_sname
	.long	_slong
	.long	_sdesc
	.long	0x4d415348		/* 'MASH' */
	.long	0x8009			/* flags */
	.long	0x0007ffff		/* max packed chunk */
	.long	0x00000028		/* min packed chunk */
	.long	0x00010000		/* def packed chunk */
	.long	_sPack
	.long	_sUnpack
	.long	_sPacked
	.long	_sUnpacked
	.short	100,0			/* def mode */
	.long	_modes
	.long	0,0,0,0,0,0		/* reserved */
_sname:
	.ascii	"Mashiner"
	.byte	0
_slong:
	.ascii	"MASH.000 V1.98, good packer"
	.byte	0
_sdesc:
	.ascii	"WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"
	.byte	0
_sPack:
	.ascii	"Mashing"
	.byte	0
_sPacked:
	.ascii	"Mashed"
	.byte	0
_sUnpack:
	.ascii	"UnMashing"
	.byte	0
_sUnpacked:
	.ascii	"UnMashed"
	.byte	0
_modes:
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0x11000			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	17			/* xm_PackSpeed */
	.long	400			/* xm_UnpackSpeed */
	.short	0x1d8			/* xm_Ratio = 472 */
	.short	0			/* xm_MaxPacked */
	.byte	32,45,45,62,32,32,32,32,0,0,0,0	/* " -->    " */
_LibInit:
	exg	%d0,%a5
	movel	%a6,%a5@(34)
	movel	%a0,%a5@(38)
	exg	%d0,%a5
	rts	
_LibOpen:
	addqw	#1,%a6@(32)
	bclr.b	#3,%a6@(14)
	movel	%a6,%d0
L_1d0:
	rts	
_LibClose:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	L_1d0
	btst.b	#3,%a6@(14)
	beqs	L_1d0
_LibExpunge:
	moveml	%d1-%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(34),%a6
	tstw	%a5@(32)
	beqs	L_1fc
	bset.b	#3,%a5@(14)
	moveq	#0,%d0
	bras	L_21a
L_1fc:
	movel	%a5@(38),%d2
	moveal	%a5,%a1
	jsr	%a6@(-252)
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0
	subal	%d0,%a1
	addw	%a5@(18),%d0
	jsr	%a6@(-210)
	movel	%d2,%d0
L_21a:
	moveml	%sp@+,%d1-%d2/%a5-%a6
	rts	
_ret0a:
	moveq	#0,%d0
	rts	
_XpksPackChunk:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a0,%a4
	moveal	%a5@(34),%a6
	movel	#131088,%d3
	movel	%a4@(4),%d7
	cmpil	#65537,%d7
	bccs	L_254
	addl	%d7,%d7
	addl	%d7,%d3
	moveq	#1,%d1
	movel	%d3,%d0
	jsr	%a6@(-198)
	tstl	%d0
	bne	L_2ec
L_254:
	movel	#65536,%d0
	movel	%d0,%d3
	moveq	#1,%d1
	jsr	%a6@(-198)
	tstl	%d0
	beq	L_2dc
	moveal	%d0,%a2
	moveml	%d3/%a2,%sp@-
	movel	#131072,%d3
	moveq	#5,%d5
L_276:
	movel	%d3,%d0
	moveq	#1,%d1
	jsr	%a6@(-198)
	tstl	%d0
	bnes	L_28a
	lsrl	#1,%d3
	subqw	#1,%d5
	bnes	L_276
	bras	L_2d4
L_28a:
	addqw	#3,%d5
	moveal	%d0,%a3
	moveml	%d3/%a3,%sp@-
	.short	0x206c	/* movea.l $0(a4), a0 */
	.short	0x0000	/*  */
	movel	%a4@(4),%d7
	moveal	%a4@(8),%a1
	lea	%a1@(-10,%d7:l),%a5
	movel	%a5,%a4@(60)
	movel	%a4@(28),%d1
	divsw	#10,%d1
	moveq	#1,%d2
	aslw	%d1,%d2
	movel	%d2,%a4@(64)
	bsrw	L_620
	movel	%d0,%d7
	moveml	%sp@+,%d0/%a1
	jsr	%a6@(-210)
	moveml	%sp@+,%d0/%a1
	jsr	%a6@(-210)
L_2cc:
	tstl	%d7
	bnes	L_2e0
	moveq	#-17,%d0
	bras	L_2e6
L_2d4:
	moveml	%sp@+,%d0/%a1
	jsr	%a6@(-210)
L_2dc:
	moveq	#-7,%d0
	bras	L_2e6
L_2e0:
	movel	%d7,%a4@(16)
	moveq	#0,%d0
L_2e6:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
L_2ec:
	moveal	%d0,%a3
	moveml	%d3/%a3,%sp@-
	.short	0x206c	/* movea.l $0(a4), a0 */
	.short	0x0000	/*  */
	movel	%a4@(4),%d7
	moveal	%a4@(8),%a1
	lea	%a1@(-10,%d7:l),%a5
	movel	%a5,%a4@(60)
	movel	%a4@(28),%d1
	divsw	#10,%d1
	moveq	#1,%d2
	aslw	%d1,%d2
	movel	%d2,%a4@(64)
	moveal	%a3,%a2
	addal	#131072,%a2
	bsrw	L_580
	movel	%d0,%d7
	moveml	%sp@+,%d0/%a1
	jsr	%a6@(-210)
	bras	L_2cc
_ret0b:
	moveq	#0,%d0
	rts	
_XpksUnpackChunk:
	movel	%a1,%sp@-
	moveal	%a0@(8),%a1
	movel	%a0@(16),%d0
	.short	0x2068	/* movea.l $0(a0), a0 */
	.short	0x0000	/*  */
	addl	%a1,%d0
	bsrw	L_8aa
	moveal	%sp@+,%a1
	moveq	#0,%d0
	rts	
_XpksPackerInfo:
	exg	%d0,%a0
	lea	_xpkinfo(%pc),%a0
	exg	%d0,%a0
	rts	
	.short	0x001c
_clear:
	lsrl	#8,%d0
	moveml	%d1-%d7/%a0-%a6,%sp@-
	movel	%d1,%d2
	movel	%d1,%d3
	movel	%d1,%d4
	movel	%d1,%d5
	movel	%d1,%d6
	movel	%d1,%d7
	moveal	%d1,%a0
	moveal	%d1,%a1
	moveal	%d1,%a2
	moveal	%d1,%a3
	moveal	%d1,%a4
	moveal	%d1,%a5
	bras	L_38c
L_378:
	moveml	%d1-%d7/%a0-%a5,%a6@-
	moveml	%d1-%d7/%a0-%a5,%a6@-
	moveml	%d1-%d7/%a0-%a5,%a6@-
	moveml	%d1-%d7/%a0-%a5,%a6@-
	moveml	%d1-%d7/%a0-%a4,%a6@-
L_38c:
	dbf	%d0,L_378
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
_pass1:
	moveml	%d1-%d7/%a0-%a4,%sp@-
	moveml	%d7/%a2,%sp@-
	subal	%a4,%a4
	moveq	#-1,%d3
	moveq	#0,%d1
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lsrl	#1,%d7
	movel	#16203,%d5
	movew	%d5,%d4
	subl	%d5,%d7
	bccs	L_3f2
	addl	%d5,%d7
	movel	%d7,%d4
	moveq	#0,%d7
	bras	L_3f2
L_3be:
	lslw	#8,%d1
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l),%a5
	addal	%d1,%a5
	movew	%a4,%d0
	movew	%a5@,%d6
	bnes	L_3d2
	movew	%d3,%d0
L_3d2:
	movew	%a4,%a5@
	subw	%d6,%d0
	swap	%d0
	lslw	#8,%d1
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l),%a5
	addal	%d1,%a5
	movew	%a4,%d0
	movew	%a5@,%d6
	bnes	L_3ec
	movew	%d3,%d0
L_3ec:
	movew	%a4,%a5@
	subw	%d6,%d0
	movel	%d0,%a2@+
L_3f2:
	dbf	%d4,L_3be
	movew	#32415,%d5
	lslw	#8,%d1
	bras	L_43c
L_3fe:
	swap	%d7
L_400:
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l),%a5
	addal	%d1,%a5
	movew	%a5@,%d6
	beqs	L_416
	movew	%a4,%d0
	subw	%d6,%d0
	cmpw	%d5,%d0
	bcss	L_418
L_416:
	movew	%d3,%d0
L_418:
	movew	%a4,%a5@
	lslw	#8,%d1
	swap	%d0
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l),%a5
	addal	%d1,%a5
	movew	%a5@,%d6
	beqs	L_434
	movew	%a4,%d0
	subw	%d6,%d0
	cmpw	%d5,%d0
	bcss	L_436
L_434:
	movew	%d3,%d0
L_436:
	movew	%a4,%a5@
	lslw	#8,%d1
	movel	%d0,%a2@+
L_43c:
	dbf	%d7,L_400
	swap	%d7
	dbf	%d7,L_3fe
	moveml	%sp@+,%d7/%a2
	addal	%d7,%a2
	addal	%d7,%a2
	movew	%d3,%a2@(-2)
	moveml	%sp@+,%d1-%d7/%a0-%a4
	rts	
_flush:
	movew	%a0,%a3@+
	clrl	%a3@+
	braw	L_574
	.short	0x007c
L_462:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	moveq	#0,%d0
	movel	%a4@(64),%d5
	swap	%d5
	addql	#2,%a2
	movew	#256,%d5
L_474:
	addql	#1,%a0
	cmpal	%d7,%a0
	bccs	_flush
L_47a:
	moveal	%a2,%a1
	movew	%a2@+,%d0
	bmis	L_474
	movel	%d5,%d1
	lea	%a0@(-32415),%a6
	swap	%d1
	moveal	%a0,%a5
	movel	%a6,%d4
	movel	%a0,%d6
	moveq	#0,%d2
	subal	%d0,%a1
	subal	%d0,%a5
	subal	%d0,%a1
L_496:
	lea	%a0@(2),%a4
	lea	%a5@(2),%a6
L_49e:
	cmpmb	%a4@+,%a6@+
	beqs	L_49e
	cmpl	%a4,%d6
	bccs	L_4c2
	movew	%a0,%d3
	movew	%a4,%d6
	subw	%a5,%d3
	moveb	%a4@-,%d5
	swap	%d3
	subal	%a0,%a4
	movew	%a4,%d3
	lea	%a2@(-4,%a4:l),%a6
	tstw	%a6@(0,%d3:w)
	bmis	L_52e
	cmpw	%d5,%d3
	bccs	L_53c
L_4c2:
	movew	%a1@,%d0
	bmis	L_4e2
L_4c6:
	subal	%d0,%a1
	subal	%d0,%a5
	subal	%d0,%a1
	cmpb	%a5@(0,%d3:w),%d5
	dbeq	%d1,L_4c2
	bnes	L_4e2
	cmpal	%d4,%a5
	bccs	L_496
	addal	%d0,%a1
	movew	#65535,%a1@(0,%d0:l)
L_4e2:
	tstl	%d2
	bnes	L_520
	movel	%d3,%d2
	cmpiw	#2,%d2
	bnes	L_4f8
	cmpil	#33554432,%d2
L_4f4:
	bcc	L_474
L_4f8:
	movel	%a0,%d6
	moveal	%a2,%a1
	addql	#5,%d6
	movew	%a2@+,%d1
	addql	#1,%a0
	addql	#1,%d4
	movew	%d1,%d0
	subqw	#1,%d1
	beqs	L_50e
	movel	%d5,%d1
	swap	%d1
L_50e:
	moveal	%a0,%a5
	moveb	%a0@(0,%d3:w),%d5
	lea	%a2@(-4,%d3:w),%a6
	tstw	%a6@(0,%d3:w)
	bpls	L_4c6
	bras	L_54c
L_520:
	cmpw	%d3,%d2
	bccs	L_54c
	movel	%d3,%d2
	cmpiw	#15,%d3
	bcss	L_4f8
	bras	L_53e
L_52e:
	cmpiw	#2,%d3
	bnes	L_53c
	cmpil	#33554432,%d3
	bccs	L_4f4
L_53c:
	movel	%d3,%d2
L_53e:
	addql	#2,%a2
	cmpiw	#32700,%d2
	bcss	L_54e
	movew	#32700,%d2
	addql	#1,%a0
L_54c:
	subql	#1,%a0
L_54e:
	subqw	#2,%d2
	movew	%a0,%a3@+
	movew	%d2,%d0
	addql	#2,%a0
	movel	%d2,%a3@+
	addal	%d0,%a2
	addal	%d0,%a0
	addal	%d0,%a2
	cmpal	%d7,%a0
	bcs	L_47a
	movel	%a0,%d0
	subql	#1,%d0
	subl	%d7,%d0
	bcss	L_574
	subw	%d0,%d2
	bccs	L_572
	clrw	%d2
L_572:
	movew	%d2,%a3@-
L_574:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
	.short	0x0b19
	.short	0x011a
	.short	0x002a
L_580:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	movel	#131072,%d0
	moveq	#0,%d1
	lea	%a3@(0,%d0:l),%a6
	bsrw	_clear
	bsrw	_pass1
	addl	%a0,%d7
	movel	%a1,%sp@-
	bsrw	L_462
	lea	_distwt(%pc),%a2
	moveq	#0,%d6
	moveal	%a4@(60),%a4
L_5aa:
	movew	%a3@+,%d0
	cmpal	%a4,%a1
	bccs	L_60c
	movel	%a3@+,%d3
	subw	%a0,%d0
	movew	%d0,%d5
	bsrw	L_846
	bras	L_5be
L_5bc:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_5be:
	dbf	%d5,L_5bc
	lea	%a0@(2,%d3:w),%a0
	movew	%d3,%d0
	bnes	L_5d2
	movel	%d3,%d0
	moveq	#10,%d1
	lsll	#5,%d0
	bras	L_5f0
L_5d2:
	bsrw	L_830
	moveq	#0,%d0
	swap	%d3
	moveal	%a2,%a5
	movew	%d3,%d0
L_5de:
	movel	%a5@+,%d1
	subw	%d1,%d0
	bccs	L_5de
	addw	%d1,%d0
	swap	%d1
	orl	%a5@(28),%d0
	rorl	%d1,%d0
	subqw	#1,%d1
L_5f0:
	bsrw	L_858
	cmpal	%d7,%a0
	bcss	L_5aa
	moveq	#0,%d0
	moveq	#7,%d1
	bsrw	L_858
	movel	%sp@+,%d0
	exg	%d0,%a1
	subl	%a1,%d0
L_606:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
L_60c:
	addql	#4,%a7
	moveq	#0,%d0
	bras	L_606
	.short	0x0e72
	.short	0x0b49
	.short	0x06da
	.short	0x007d
	.short	0x13b5
	.short	0x1379
	.short	0x0332
L_620:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	moveq	#-1,%d1
	movel	#32768,%d0
	addal	%d0,%a2
	moveq	#0,%d2
	movew	%a0,%d2
	addw	%d2,%d2
	movew	%d1,%a2@(0,%d2:w)
	movew	%a0,%d1
	swap	%d1
	movew	%a0,%d1
	moveq	#64,%d0
	aslw	#3,%d0
	asll	%d5,%d0
	moveal	%a3,%a6
	addal	%d0,%a6
	bsrw	_clear
	addl	%a0,%d7
	movel	%a1,%sp@-
	moveq	#0,%d6
	movel	%a0,%sp@-
	addql	#1,%a0
	bras	L_65a
L_658:
	movel	%a0,%sp@-
L_65a:
	moveq	#1,%d3
	bsrw	L_718
	bcss	L_674
L_662:
	movel	%d3,%sp@-
	addql	#1,%a0
	bsrw	L_718
	bcss	L_67e
	movel	%sp@+,%d2
	cmpw	%d3,%d2
	bcss	L_662
	bras	L_680
L_674:
	addql	#1,%a0
	cmpal	%d7,%a0
	bcss	L_65a
	moveq	#0,%d3
	bras	L_684
L_67e:
	movel	%sp@+,%d2
L_680:
	movel	%d2,%d3
	subql	#1,%a0
L_684:
	cmpal	%a4@(60),%a1
	bcc	L_712
	moveal	%sp@+,%a5
	movel	%a0,%d0
	subl	%a5,%d0
	bsrw	L_846
	bras	L_69a
L_698:
	.short	0x12dd	/* move.b (a5)+, (a1)+ */
L_69a:
	cmpal	%a0,%a5
	bcss	L_698
	addql	#1,%a0
	movew	%d3,%d2
	bras	L_6c2
L_6a4:
	moveq	#0,%d1
	moveb	%a0@(1),%d1
	lslw	%d5,%d1
	moveb	%a0@,%d1
	addl	%d1,%d1
	movew	%a0,%d0
	lea	%a3@(0,%d1:l),%a5
	subw	%a5@,%d0
	movew	%a0,%a5@
	movew	%a0,%d1
	addw	%d1,%d1
	movew	%d0,%a2@(0,%d1:w)
L_6c2:
	addql	#1,%a0
	dbf	%d2,L_6a4
	movew	%d3,%d0
	bnes	L_6d4
	movel	%d3,%d0
	lsll	#5,%d0
	moveq	#10,%d1
	bras	L_6f4
L_6d4:
	bsrw	L_830
	moveq	#0,%d0
	swap	%d3
	movew	%d3,%d0
	lea	_distwt(%pc),%a5
L_6e2:
	movel	%a5@+,%d1
	subw	%d1,%d0
	bccs	L_6e2
	addw	%d1,%d0
	swap	%d1
	orl	%a5@(28),%d0
	rorl	%d1,%d0
	subqw	#1,%d1
L_6f4:
	bsrw	L_858
	cmpal	%d7,%a0
	bcs	L_658
	moveq	#0,%d0
	moveq	#7,%d1
	bsrw	L_858
	movel	%sp@+,%d0
	exg	%d0,%a1
	subl	%a1,%d0
L_70c:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
L_712:
	addql	#8,%a7
	moveq	#0,%d0
	bras	L_70c
L_718:
	moveq	#0,%d0
	moveq	#0,%d1
	moveb	%a0@(1),%d1
	lslw	%d5,%d1
	moveb	%a0@,%d1
	addl	%d1,%d1
	movew	%a0,%d0
	lea	%a3@(0,%d1:l),%a5
	subw	%a5@,%d0
	movew	%a0,%a5@
	movew	%a0,%d1
	addw	%d1,%d1
	movew	%d0,%a2@(0,%d1:w)
	swap	%d0
	clrw	%d0
	swap	%d0
	lea	%a0@(-32415),%a5
	movel	%a5,%d2
	moveal	%a0,%a5
	subal	%d0,%a5
	cmpal	%d2,%a5
	bccs	L_74e
	rts	
L_74e:
	moveml	%d5-%d6/%a4,%sp@-
	movel	%a0,%d6
	moveb	%a0@(0,%d3:w),%d5
	movel	%a4@(64),%d1
L_75c:
	movel	%a5,%d4
	moveal	%a0,%a4
	cmpmb	%a4@+,%a5@+
	bnes	L_7a8
	cmpmb	%a4@+,%a5@+
	bnes	L_78e
	movew	#521,%d0
L_76c:
	cmpmb	%a4@+,%a5@+
	dbne	%d0,L_76c
	cmpl	%a4,%d6
	bccs	L_78e
	movel	%a4,%d6
	moveb	%a4@-,%d5
	movew	%a0,%d3
	subw	%d4,%d3
	swap	%d3
	cmpal	%d7,%a4
	bccs	L_7ba
	movew	%a4,%d3
	subw	%a0,%d3
	cmpiw	#256,%d3
	bccs	L_7a8
L_78e:
	moveal	%d4,%a5
L_790:
	movel	%a5,%d4
	addw	%d4,%d4
	movew	%a2@(0,%d4:w),%d0
	subal	%d0,%a5
	cmpal	%d2,%a5
	bcss	L_7a8
	cmpb	%a5@(0,%d3:w),%d5
	dbeq	%d1,L_790
	beqs	L_75c
L_7a8:
	moveml	%sp@+,%d5-%d6/%a4
	subqw	#2,%d3
	bnes	L_7b8
	movel	%d3,%d0
	addil	#-33554432,%d0
L_7b8:
	rts	
L_7ba:
	movew	%d7,%d3
	subw	%a0,%d3
	bras	L_7a8
_distwt:
	.short	0x0008
	.short	0x0020
	.short	0x000a
	.short	0x0080
	.short	0x000c
	.short	0x0200
	.short	0x000d
	.short	0x0400
	.short	0x000e
	.short	0x0800
	.short	0x000f
	.short	0x1000
	.short	0x0010
	.short	0x2000
	.short	0x0011
	.short	0x4000
_distor:
	.short	0x0000
	.short	0x0000
	.short	0x0000
	.short	0x0080
	.short	0x0000
	.short	0x0400
	.short	0x0000
	.short	0x0c00
	.short	0x0000
	.short	0x2000
	.short	0x0000
	.short	0x5000
	.short	0x0000
	.short	0xc000
	.short	0x0001
	.short	0xc000
_lenwt:
	.short	0x0001
	.short	0x4001
	.short	0x8002
	.short	0xa002
	.short	0xc004
	.short	0xc804
	.short	0xd004
	.short	0xd804
	.short	0xe006
	.short	0xe206
	.short	0xe406
	.short	0xe606
	.short	0xe806
	.short	0xea06
	.short	0xec06
	.short	0xee06
_runwt:
	.short	0x0000
	.short	0x8001
	.short	0xc002
	.short	0xe003
	.short	0xf004
	.short	0xf805
	.short	0xfc07
	.short	0xfd07
L_830:
	moveq	#16,%d1
	movew	%d0,%d2
	addw	%d0,%d0
	movew	_lenwt(%pc,%d0:w),%d0
	subw	%d1,%d2
	bcss	L_854
	moveq	#16,%d4
	moveq	#9,%d1
	moveq	#-32,%d0
	bras	L_88a
L_846:
	moveq	#8,%d1
	movew	%d0,%d2
	subw	%d1,%d2
	bccs	L_884
	addw	%d0,%d0
	movew	_runwt(%pc,%d0:w),%d0
L_854:
	moveb	%d0,%d1
	swap	%d0
L_858:
	tstb	%d6
	bnes	L_862
L_85c:
	moveal	%a1,%a6
	addql	#1,%a1
	moveq	#1,%d6
L_862:
	addl	%d0,%d0
	addxb	%d6,%d6
	dbcs	%d1,L_862
	bcss	L_86e
	rts	
L_86e:
	moveb	%d6,%a6@
	subqw	#8,%d1
	bcss	L_87a
	roll	#8,%d0
	subqw	#8,%d1
	moveb	%d0,%a1@+
L_87a:
	addqw	#8,%d1
	dbf	%d1,L_85c
	moveq	#0,%d6
	rts	
L_884:
	moveq	#4,%d4
	moveq	#10,%d1
	moveq	#-8,%d0
L_88a:
	cmpw	%d4,%d2
	bcss	L_89a
L_88e:
	subw	%d4,%d2
	addl	%d0,%d0
	addqw	#2,%d1
	addw	%d4,%d4
	cmpw	%d4,%d2
	bccs	L_88e
L_89a:
	orw	%d2,%d0
	rorl	%d1,%d0
	subqw	#1,%d1
	bras	L_858
	.short	0x0061
	.short	0x0061
	.short	0x0057
	.short	0x0001
L_8aa:
	moveml	%d1-%d5/%a2-%a5,%sp@-
	lea	_runc(%pc),%a4
	lea	_lenc(%pc),%a5
	movel	#65280,%d5
	moveq	#0,%d4
	moveq	#-128,%d3
L_8c0:
	addb	%d3,%d3
	bnes	L_8c8
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8c8:
	bccs	L_92a
	addb	%d3,%d3
	bnes	L_8d2
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8d2:
	bccs	L_928
	addb	%d3,%d3
	bnes	L_8dc
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8dc:
	bccs	L_926
	addb	%d3,%d3
	bnes	L_8e6
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8e6:
	bccs	L_924
	addb	%d3,%d3
	bnes	L_8f0
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8f0:
	bccs	L_922
	addb	%d3,%d3
	bnes	L_8fa
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8fa:
	bccs	L_920
	moveal	%a4,%a2
L_8fe:
	addql	#4,%a2
	addb	%d3,%d3
	bnes	L_908
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_908:
	bcss	L_8fe
	movew	%a2@+,%d4
L_90c:
	addb	%d3,%d3
	bnes	L_914
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_914:
	addxw	%d4,%d4
	bccs	L_90c
	addw	%a2@,%d4
L_91a:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
	dbf	%d4,L_91a
L_920:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_922:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_924:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_926:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_928:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_92a:
	addb	%d3,%d3
	bnes	L_932
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_932:
	bcss	L_946
	moveq	#1,%d2
	addb	%d3,%d3
	bnes	L_93e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_93e:
	bcss	L_964
	movel	%d5,%d1
	moveq	#0,%d2
	bras	L_98c
L_946:
	moveal	%a5,%a2
L_948:
	addql	#4,%a2
	addb	%d3,%d3
	bnes	L_952
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_952:
	bcss	L_948
	movew	%a2@+,%d2
L_956:
	addb	%d3,%d3
	bnes	L_95e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_95e:
	addxw	%d2,%d2
	bccs	L_956
	addw	%a2@,%d2
L_964:
	moveq	#0,%d4
	addb	%d3,%d3
	bnes	L_96e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_96e:
	addxw	%d4,%d4
	addb	%d3,%d3
	bnes	L_978
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_978:
	addxw	%d4,%d4
	addb	%d3,%d3
	bnes	L_982
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_982:
	addxw	%d4,%d4
	addw	%d4,%d4
	addw	%d4,%d4
	movel	_distc(%pc,%d4:w),%d1
L_98c:
	movew	%d1,%d4
L_98e:
	addb	%d3,%d3
	bnes	L_99e
	cmpw	%d5,%d4
	bcss	L_99a
	lslw	#8,%d4
	moveb	%a0@+,%d4
L_99a:
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_99e:
	addxw	%d4,%d4
	bcss	L_98e
	swap	%d1
	addw	%d1,%d4
	moveal	%a1,%a3
	subal	%d4,%a3
L_9aa:
	.short	0x12db	/* move.b (a3)+, (a1)+ */
	dbf	%d2,L_9aa
	.short	0x12db	/* move.b (a3)+, (a1)+ */
	cmpl	%a1,%d0
	bhi	L_8c0
	moveml	%sp@+,%d1-%d5/%a2-%a5
	rts	
	.short	0x061b
_distc:
	.short	0x0000
	.short	0xf000
	.short	0x0020
	.short	0xfc00
	.short	0x00a0
	.short	0xff00
	.short	0x02a0
	.short	0xff80
	.short	0x06a0
	.short	0xffc0
	.short	0x0ea0
	.short	0xffe0
	.short	0x1ea0
	.short	0xfff0
_lenc:
	.short	0x3ea0
	.short	0xfff8
	.short	0x8000
	.short	0x0002
	.short	0x4000
	.short	0x0004
	.short	0x2000
	.short	0x0008
	.short	0x1000
	.short	0x0010
	.short	0x0800
	.short	0x0020
	.short	0x0400
	.short	0x0040
	.short	0x0200
	.short	0x0080
	.short	0x0100
	.short	0x0100
	.short	0x0080
	.short	0x0200
	.short	0x0040
	.short	0x0400
	.short	0x0020
	.short	0x0800
	.short	0x0010
	.short	0x1000
	.short	0x0008
	.short	0x2000
	.short	0x0004
	.short	0x4000
_runc:
	.short	0x0002
	.short	0x8000
	.short	0x8000
	.short	0x0000
	.short	0x4000
	.short	0x0002
	.short	0x2000
	.short	0x0006
	.short	0x1000
	.short	0x000e
	.short	0x0800
	.short	0x001e
	.short	0x0400
	.short	0x003e
	.short	0x0200
	.short	0x007e
	.short	0x0100
	.short	0x00fe
	.short	0x0080
	.short	0x01fe
	.short	0x0040
	.short	0x03fe
	.short	0x0020
	.short	0x07fe
	.short	0x0010
	.short	0x0ffe
	.short	0x0008
	.short	0x1ffe
	.short	0x0004
	.short	0x3ffe
	.short	0x0002
	.short	0x7ffe
	.short	0x0001
	.short	0xfffe
	.globl _endmodule
_endmodule:
