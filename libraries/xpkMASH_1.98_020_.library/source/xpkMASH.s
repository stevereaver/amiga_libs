/*
 * xpkMASH.library 1.98 (68020 build) -- assembly reconstruction
 * of binary/xpkMASH_1.98(020).library
 *   $VER: xpkMASH.library_020 V1.98
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
/*
 * 020 differences vs the 000 build: CHKW/LSR prologue at 0x356 and
 * scaled-index addressing ((An,Xn.l*2), (PC,Xn.w*4)) throughout the
 * matcher and decoder tables.  Same algorithm, same stream format.
 */
	.file	"xpkMASH_020.s"
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
	.ascii	" $VER: xpkMASH.library_020 V1.98"
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
	.ascii	"MASH.020 V1.98, good packer"
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
	bsrw	L_610
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
	bsrw	L_570
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
	bsrw	L_89a
	moveal	%sp@+,%a1
	moveq	#0,%d0
	rts	
_XpksPackerInfo:
	exg	%d0,%a0
	lea	_xpkinfo(%pc),%a0
	exg	%d0,%a0
	rts	
	.short	0x4b90
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
	bccs	L_3ee
	addl	%d5,%d7
	movel	%d7,%d4
	moveq	#0,%d7
	bras	L_3ee
L_3be:
	lslw	#8,%d1
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l*2),%a5
	movew	%a4,%d0
	movew	%a5@,%d6
	bnes	L_3d0
	movew	%d3,%d0
L_3d0:
	movew	%a4,%a5@
	subw	%d6,%d0
	swap	%d0
	lslw	#8,%d1
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l*2),%a5
	movew	%a4,%d0
	movew	%a5@,%d6
	bnes	L_3e8
	movew	%d3,%d0
L_3e8:
	movew	%a4,%a5@
	subw	%d6,%d0
	movel	%d0,%a2@+
L_3ee:
	dbf	%d4,L_3be
	movew	#32415,%d5
	lslw	#8,%d1
	bras	L_434
L_3fa:
	swap	%d7
L_3fc:
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l*2),%a5
	movew	%a5@,%d6
	beqs	L_410
	movew	%a4,%d0
	subw	%d6,%d0
	cmpw	%d5,%d0
	bcss	L_412
L_410:
	movew	%d3,%d0
L_412:
	movew	%a4,%a5@
	lslw	#8,%d1
	swap	%d0
	moveb	%a0@+,%d1
	addqw	#1,%a4
	lea	%a3@(0,%d1:l*2),%a5
	movew	%a5@,%d6
	beqs	L_42c
	movew	%a4,%d0
	subw	%d6,%d0
	cmpw	%d5,%d0
	bcss	L_42e
L_42c:
	movew	%d3,%d0
L_42e:
	movew	%a4,%a5@
	lslw	#8,%d1
	movel	%d0,%a2@+
L_434:
	dbf	%d7,L_3fc
	swap	%d7
	dbf	%d7,L_3fa
	moveml	%sp@+,%d7/%a2
	addal	%d7,%a2
	addal	%d7,%a2
	movew	%d3,%a2@(-2)
	moveml	%sp@+,%d1-%d7/%a0-%a4
	rts	
_flush:
	movew	%a0,%a3@+
	clrl	%a3@+
	braw	L_560
	.short	0x000e
L_45a:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	moveq	#0,%d0
	movel	%a4@(64),%d5
	swap	%d5
	addql	#2,%a2
	movew	#256,%d5
L_46c:
	addql	#1,%a0
	cmpal	%d7,%a0
	bccs	_flush
L_472:
	moveal	%a2,%a1
	movew	%a2@+,%d0
	bmis	L_46c
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
L_48e:
	lea	%a0@(2),%a4
	lea	%a5@(2),%a6
L_496:
	cmpmb	%a4@+,%a6@+
	beqs	L_496
	cmpl	%a4,%d6
	bccs	L_4b6
	movew	%a0,%d3
	movew	%a4,%d6
	subw	%a5,%d3
	moveb	%a4@-,%d5
	swap	%d3
	subal	%a0,%a4
	movew	%a4,%d3
	tstw	%a2@(-4,%d3:w*2)
	bmis	L_51c
	cmpw	%d5,%d3
	bccs	L_52a
L_4b6:
	movew	%a1@,%d0
	bmis	L_4d4
L_4ba:
	subal	%d0,%a1
	subal	%d0,%a5
	subal	%d0,%a1
	cmpb	%a5@(0,%d3:w),%d5
	dbeq	%d1,L_4b6
	bnes	L_4d4
	cmpal	%d4,%a5
	bccs	L_48e
	movew	#65535,%a1@(0,%d0:l*2)
L_4d4:
	tstl	%d2
	bnes	L_50e
	movel	%d3,%d2
	cmpiw	#2,%d2
	bnes	L_4ea
	cmpil	#33554432,%d2
L_4e6:
	bcc	L_46c
L_4ea:
	movel	%a0,%d6
	moveal	%a2,%a1
	addql	#5,%d6
	movew	%a2@+,%d1
	addql	#1,%a0
	addql	#1,%d4
	movew	%d1,%d0
	subqw	#1,%d1
	beqs	L_500
	movel	%d5,%d1
	swap	%d1
L_500:
	moveal	%a0,%a5
	moveb	%a0@(0,%d3:w),%d5
	tstw	%a2@(-4,%d3:w*2)
	bpls	L_4ba
	bras	L_53a
L_50e:
	cmpw	%d3,%d2
	bccs	L_53a
	movel	%d3,%d2
	cmpiw	#15,%d3
	bcss	L_4ea
	bras	L_52c
L_51c:
	cmpiw	#2,%d3
	bnes	L_52a
	cmpil	#33554432,%d3
	bccs	L_4e6
L_52a:
	movel	%d3,%d2
L_52c:
	addql	#2,%a2
	cmpiw	#32700,%d2
	bcss	L_53c
	movew	#32700,%d2
	addql	#1,%a0
L_53a:
	subql	#1,%a0
L_53c:
	subqw	#2,%d2
	movew	%a0,%a3@+
	lea	%a2@(0,%d2:w*2),%a2
	lea	%a0@(2,%d2:w),%a0
	movel	%d2,%a3@+
	cmpal	%d7,%a0
	bcs	L_472
	movel	%a0,%d0
	subql	#1,%d0
	subl	%d7,%d0
	bcss	L_560
	subw	%d0,%d2
	bccs	L_55e
	clrw	%d2
L_55e:
	movew	%d2,%a3@-
L_560:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
	.short	0x312e
	.short	0x3938
	.short	0x0d0a
	.short	0x0000
	.short	0x0000
L_570:
	moveml	%d1-%d7/%a0-%a6,%sp@-
	movel	#131072,%d0
	moveq	#0,%d1
	lea	%a3@(0,%d0:l),%a6
	bsrw	_clear
	bsrw	_pass1
	addl	%a0,%d7
	movel	%a1,%sp@-
	bsrw	L_45a
	lea	_distwt(%pc),%a2
	moveq	#0,%d6
	moveal	%a4@(60),%a4
L_59a:
	movew	%a3@+,%d0
	cmpal	%a4,%a1
	bccs	L_5fc
	movel	%a3@+,%d3
	subw	%a0,%d0
	movew	%d0,%d5
	bsrw	L_836
	bras	L_5ae
L_5ac:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_5ae:
	dbf	%d5,L_5ac
	lea	%a0@(2,%d3:w),%a0
	movew	%d3,%d0
	bnes	L_5c2
	movel	%d3,%d0
	moveq	#10,%d1
	lsll	#5,%d0
	bras	L_5e0
L_5c2:
	bsrw	L_820
	moveq	#0,%d0
	swap	%d3
	moveal	%a2,%a5
	movew	%d3,%d0
L_5ce:
	movel	%a5@+,%d1
	subw	%d1,%d0
	bccs	L_5ce
	addw	%d1,%d0
	swap	%d1
	orl	%a5@(28),%d0
	rorl	%d1,%d0
	subqw	#1,%d1
L_5e0:
	bsrw	L_848
	cmpal	%d7,%a0
	bcss	L_59a
	moveq	#0,%d0
	moveq	#7,%d1
	bsrw	L_848
	movel	%sp@+,%d0
	exg	%d0,%a1
	subl	%a1,%d0
L_5f6:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
L_5fc:
	addql	#4,%a7
	moveq	#0,%d0
	bras	L_5f6
	.short	0x0064
	.short	0x0000
	.short	0x000e
	.short	0x4ada
	.short	0x0000
	.short	0x0000
	.short	0x0000
L_610:
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
	bras	L_64a
L_648:
	movel	%a0,%sp@-
L_64a:
	moveq	#1,%d3
	bsrw	L_708
	bcss	L_664
L_652:
	movel	%d3,%sp@-
	addql	#1,%a0
	bsrw	L_708
	bcss	L_66e
	movel	%sp@+,%d2
	cmpw	%d3,%d2
	bcss	L_652
	bras	L_670
L_664:
	addql	#1,%a0
	cmpal	%d7,%a0
	bcss	L_64a
	moveq	#0,%d3
	bras	L_674
L_66e:
	movel	%sp@+,%d2
L_670:
	movel	%d2,%d3
	subql	#1,%a0
L_674:
	cmpal	%a4@(60),%a1
	bcc	L_702
	moveal	%sp@+,%a5
	movel	%a0,%d0
	subl	%a5,%d0
	bsrw	L_836
	bras	L_68a
L_688:
	.short	0x12dd	/* move.b (a5)+, (a1)+ */
L_68a:
	cmpal	%a0,%a5
	bcss	L_688
	addql	#1,%a0
	movew	%d3,%d2
	bras	L_6b2
L_694:
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
L_6b2:
	addql	#1,%a0
	dbf	%d2,L_694
	movew	%d3,%d0
	bnes	L_6c4
	movel	%d3,%d0
	lsll	#5,%d0
	moveq	#10,%d1
	bras	L_6e4
L_6c4:
	bsrw	L_820
	moveq	#0,%d0
	swap	%d3
	movew	%d3,%d0
	lea	_distwt(%pc),%a5
L_6d2:
	movel	%a5@+,%d1
	subw	%d1,%d0
	bccs	L_6d2
	addw	%d1,%d0
	swap	%d1
	orl	%a5@(28),%d0
	rorl	%d1,%d0
	subqw	#1,%d1
L_6e4:
	bsrw	L_848
	cmpal	%d7,%a0
	bcs	L_648
	moveq	#0,%d0
	moveq	#7,%d1
	bsrw	L_848
	movel	%sp@+,%d0
	exg	%d0,%a1
	subl	%a1,%d0
L_6fc:
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts	
L_702:
	addql	#8,%a7
	moveq	#0,%d0
	bras	L_6fc
L_708:
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
	bccs	L_73e
	rts	
L_73e:
	moveml	%d5-%d6/%a4,%sp@-
	movel	%a0,%d6
	moveb	%a0@(0,%d3:w),%d5
	movel	%a4@(64),%d1
L_74c:
	movel	%a5,%d4
	moveal	%a0,%a4
	cmpmb	%a4@+,%a5@+
	bnes	L_798
	cmpmb	%a4@+,%a5@+
	bnes	L_77e
	movew	#521,%d0
L_75c:
	cmpmb	%a4@+,%a5@+
	dbne	%d0,L_75c
	cmpl	%a4,%d6
	bccs	L_77e
	movel	%a4,%d6
	moveb	%a4@-,%d5
	movew	%a0,%d3
	subw	%d4,%d3
	swap	%d3
	cmpal	%d7,%a4
	bccs	L_7aa
	movew	%a4,%d3
	subw	%a0,%d3
	cmpiw	#256,%d3
	bccs	L_798
L_77e:
	moveal	%d4,%a5
L_780:
	movel	%a5,%d4
	addw	%d4,%d4
	movew	%a2@(0,%d4:w),%d0
	subal	%d0,%a5
	cmpal	%d2,%a5
	bcss	L_798
	cmpb	%a5@(0,%d3:w),%d5
	dbeq	%d1,L_780
	beqs	L_74c
L_798:
	moveml	%sp@+,%d5-%d6/%a4
	subqw	#2,%d3
	bnes	L_7a8
	movel	%d3,%d0
	addil	#-33554432,%d0
L_7a8:
	rts	
L_7aa:
	movew	%d7,%d3
	subw	%a0,%d3
	bras	L_798
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
L_820:
	moveq	#16,%d1
	movew	%d0,%d2
	addw	%d0,%d0
	movew	_lenwt(%pc,%d0:w),%d0
	subw	%d1,%d2
	bcss	L_844
	moveq	#16,%d4
	moveq	#9,%d1
	moveq	#-32,%d0
	bras	L_87a
L_836:
	moveq	#8,%d1
	movew	%d0,%d2
	subw	%d1,%d2
	bccs	L_874
	addw	%d0,%d0
	movew	_runwt(%pc,%d0:w),%d0
L_844:
	moveb	%d0,%d1
	swap	%d0
L_848:
	tstb	%d6
	bnes	L_852
L_84c:
	moveal	%a1,%a6
	addql	#1,%a1
	moveq	#1,%d6
L_852:
	addl	%d0,%d0
	addxb	%d6,%d6
	dbcs	%d1,L_852
	bcss	L_85e
	rts	
L_85e:
	moveb	%d6,%a6@
	subqw	#8,%d1
	bcss	L_86a
	roll	#8,%d0
	subqw	#8,%d1
	moveb	%d0,%a1@+
L_86a:
	addqw	#8,%d1
	dbf	%d1,L_84c
	moveq	#0,%d6
	rts	
L_874:
	moveq	#4,%d4
	moveq	#10,%d1
	moveq	#-8,%d0
L_87a:
	cmpw	%d4,%d2
	bcss	L_88a
L_87e:
	subw	%d4,%d2
	addl	%d0,%d0
	addqw	#2,%d1
	addw	%d4,%d4
	cmpw	%d4,%d2
	bccs	L_87e
L_88a:
	orw	%d2,%d0
	rorl	%d1,%d0
	subqw	#1,%d1
	bras	L_848
	.short	0x6014
	.short	0x48e6
	.short	0x7ffc
	.short	0x48e6
L_89a:
	moveml	%d1-%d5/%a2-%a5,%sp@-
	lea	_runc(%pc),%a4
	lea	_lenc(%pc),%a5
	movel	#65280,%d5
	moveq	#0,%d4
	moveq	#-128,%d3
L_8b0:
	addb	%d3,%d3
	bnes	L_8b8
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8b8:
	bccs	L_91a
	addb	%d3,%d3
	bnes	L_8c2
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8c2:
	bccs	L_918
	addb	%d3,%d3
	bnes	L_8cc
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8cc:
	bccs	L_916
	addb	%d3,%d3
	bnes	L_8d6
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8d6:
	bccs	L_914
	addb	%d3,%d3
	bnes	L_8e0
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8e0:
	bccs	L_912
	addb	%d3,%d3
	bnes	L_8ea
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8ea:
	bccs	L_910
	moveal	%a4,%a2
L_8ee:
	addql	#4,%a2
	addb	%d3,%d3
	bnes	L_8f8
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_8f8:
	bcss	L_8ee
	movew	%a2@+,%d4
L_8fc:
	addb	%d3,%d3
	bnes	L_904
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_904:
	addxw	%d4,%d4
	bccs	L_8fc
	addw	%a2@,%d4
L_90a:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
	dbf	%d4,L_90a
L_910:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_912:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_914:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_916:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_918:
	.short	0x12d8	/* move.b (a0)+, (a1)+ */
L_91a:
	addb	%d3,%d3
	bnes	L_922
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_922:
	bcss	L_936
	moveq	#1,%d2
	addb	%d3,%d3
	bnes	L_92e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_92e:
	bcss	L_954
	movel	%d5,%d1
	moveq	#0,%d2
	bras	L_978
L_936:
	moveal	%a5,%a2
L_938:
	addql	#4,%a2
	addb	%d3,%d3
	bnes	L_942
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_942:
	bcss	L_938
	movew	%a2@+,%d2
L_946:
	addb	%d3,%d3
	bnes	L_94e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_94e:
	addxw	%d2,%d2
	bccs	L_946
	addw	%a2@,%d2
L_954:
	moveq	#0,%d4
	addb	%d3,%d3
	bnes	L_95e
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_95e:
	addxw	%d4,%d4
	addb	%d3,%d3
	bnes	L_968
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_968:
	addxw	%d4,%d4
	addb	%d3,%d3
	bnes	L_972
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_972:
	addxw	%d4,%d4
	movel	_distc(%pc,%d4:w*4),%d1
L_978:
	movew	%d1,%d4
L_97a:
	addb	%d3,%d3
	bnes	L_98a
	cmpw	%d5,%d4
	bcss	L_986
	lslw	#8,%d4
	moveb	%a0@+,%d4
L_986:
	moveb	%a0@+,%d3
	addxb	%d3,%d3
L_98a:
	addxw	%d4,%d4
	bcss	L_97a
	swap	%d1
	addw	%d1,%d4
	moveal	%a1,%a3
	subal	%d4,%a3
L_996:
	.short	0x12db	/* move.b (a3)+, (a1)+ */
	dbf	%d2,L_996
	.short	0x12db	/* move.b (a3)+, (a1)+ */
	cmpl	%a1,%d0
	bhi	L_8b0
	moveml	%sp@+,%d1-%d5/%a2-%a5
	rts	
	.short	0x49e8
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
