/*
 * lh.library 1.8 (16 Dec 1990) -- Holger P. Krekel & Olaf Barthel.
 * Byte-exact reconstruction. Single CODE hunk (0x2aa longs).
 *
 * Runtime library of the LHa/LZH adaptive-Huffman codec:
 *  -30 lhAllocHandle(d0): d0!=0 -> 4500B model, d0==0 -> 40000B, +28B handle
 *  -36 lhFreeHandle(a0)
 *  -42 lhEncode(a0=handle) -> engine @0x628  (needs the 40000B model)
 *  -48 lhDecode(a0=handle) -> engine @0x210  (needs only nonzero fields)
 *
 * Handle: +0 src cursor, +4 src end, +8 dst base, +12 dst result,
 *         +16 model buffer, +20 bufsize.
 * Decode model (4500B): tree arrays at +634/+1902/+3168/+3802, root
 *   at a3+1264.
 * Encode model (40000B): same plus symbol/freq/pos arrays at
 *   +4434/+12506/+12746/+16902/+20940/+25094/+29134/+29646.
 *
 * Quirks preserved verbatim:
 *  - initfn stores the seglist into a data cell parked inside the
 *    datatab tail (h0+0xe8) via `movel a0,abs.l`; Expunge reads it
 *    back with `movel pc@(0xe8),d0`.
 *  - Expunge unlinks via a hand-inlined Remove.
 *  - decode dispatches literal runs via `jmp pc@(0x7e,d7:w)` with
 *    negative d7 into the middle of the 30x unrolled `moveb` copy loop.
 *  - packed word tables at 0x428 and 0x9b2 live between code paths.
 */
	.text
	.globl	_romtag,_initfn,_functab,_open,_close,_expunge
	.globl	_segcell

	moveq	#-1,d0			/* 0x00 entry stub */
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* matchtag -> h0+4 */
	.long	_endskip			/* endskip (relocated!) -> h0+0x20e */
	.byte	0x80,1,9,0		/* AUTOINIT, ver 1, NT_LIBRARY */
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"lh.library"		/* 0x1e */
	.byte	0,0			/* NUL + pad -> _idstr @0x2a */
_idstr:	.byte	108,104,46,108,105,98,114,97,114,121,32,49,46,56,32,40,49,54,32,68,101,99,32,49,57,57,48,41,32,169,32,67,111,112,121,114,105,103,104,116,32,49,57,57,48,32,98,121,32,72,111,108,103,101,114,32,80,46,32,75,114,101,107,101,108,32,38,32,79,108,97,102,32,66,97,114,116,104,101,108,44,32,97,108,108,32,114,105,103,104,116,115,32,114,101,115,101,114,118,101,100,46,13,10
	.byte	0,0			/* NUL + pad -> inittab @0x94 */
_inittab:				/* 0x94 */
	.long	0x22			/* dsize = sizeof(struct Library) */
	.long	_functab
	.long	_dt
	.long	_initfn

_functab:				/* 0xa4 absolute longs */
	.long	_open,_close,_expunge,_stub24,_lhopen,_lhclose,_lhenc,_lhdec
	.long	0xffffffff

_dt:					/* 0xc8 InitStruct datatab */
	.short	0xa008
	.byte	9,0			/* ln_Type = NT_LIBRARY */
	.short	0x800a
	.long	_name			/* ln_Name */
	.short	0xa00e
	.byte	6,0			/* lib_Flags */
	.short	0x9014,1		/* lib_Version = 1 */
	.short	0x9016,8		/* lib_Revision = 8 */
	.short	0x8018
	.long	_idstr			/* ln_IdString */
	.short	0			/* terminator */
	.short	0			/* pad */
_segcell:
	.long	0			/* 0xe8 seglist cell */

/* ==== initfn @0xec ==== */
_initfn:
	movel	a0,_segcell:l
	rts

/* ==== -6 Open @0xf4 ==== */
_open:	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	rts

/* ==== -12 Close @0x102 ==== */
_close:	moveq	#0,d0
	subqw	#1,a6@(32)
	bnes	_cx
	btst	#3,a6@(14)
	beqs	_cx
	bsrs	_expunge
_cx:	rts

/* ==== -18 Expunge @0x116 ==== */
_expunge:
	moveq	#0,d0
	tstw	a6@(32)
	beqs	_ex
	bset	#3,a6@(14)
	rts
_ex:	moveal	a6,a1
	moveal	a1@,a0
	moveal	a1@(4),a1
	movel	a0,a1@
	movel	a1,a0@(4)
	moveal	a6,a1
	movew	a6@(16),d0
	subal	d0,a1
	addw	a6@(18),d0
	moveal	0x4,a6
	jsr	a6@(-210)
	movel	_segcell(pc),d0
	rts

/* ==== -24 stub @0x14e ==== */
_stub24:
	moveq	#0,d0
	rts

/* ==== -30 lhAllocHandle @0x152 ==== */
_lhopen:
	moveml	d2/a2/a6,sp@-
	moveal	0x4,a6
	tstl	d0
	beqs	_o1
	movel	#4500,d0
	bras	_o2
_o1:	movel	#40000,d0
_o2:	movel	d0,d2
	movel	#0x10001,d1
	jsr	a6@(-198)
	tstl	d0
	beqs	_oout
	moveal	d0,a2
	moveq	#28,d0
	movel	#0x10001,d1
	jsr	a6@(-198)
	tstl	d0
	beqs	_ofree
	moveal	d0,a0
	movel	a2,a0@(16)
	movel	d2,a0@(20)
	bras	_oout
_ofree:	moveal	a2,a1
	movel	d2,d0
	jsr	a6@(-210)
	moveq	#0,d0
_oout:	moveml	sp@+,d2/a2/a6
	rts

/* ==== -36 lhFreeHandle @0x1aa ==== */
_lhclose:
	movel	a0,d0
	beqs	_c0
	pea	a6@
	pea	a0@
	moveal	0x4,a6
	moveal	a0@(16),a1
	movel	a0@(20),d0
	jsr	a6@(-210)
	moveal	sp@+,a1
	moveq	#28,d0
	jsr	a6@(-210)
	moveal	sp@+,a6
_c0:	rts

/* ==== -42 lhEncode @0x1ce ==== */
_lhenc:	movel	a0,d0
	beqs	_badr
	cmpil	#40000,a0@(20)
	bmis	_badr
	movel	a0@,d0
	beqs	_badr
	movel	a0@(4),d0
	beqs	_badr
	movel	a0@(8),d0
	beqs	_badr
	jmp	_enc:l
_badr:	moveq	#0,d0
	rts

/* ==== -48 lhDecode @0x1f6 ==== */
_lhdec:	movel	a0,d0
	beqs	_badr2
	movel	a0@,d0
	beqs	_badr2
	movel	a0@(8),d0
	beqs	_badr2
	jmp	_dec:l
_badr2:	moveq	#0,d0
	rts
_endskip:
	.short	0			/* 0x20e pad; rt_EndSkip points here (relocated) */

/* ==== decode engine entry @0x210 ==== */
_dec:	moveml	d2-d7/a2-a6,sp@-
	pea	a0@
	bsrw	_dinit
	movel	a1,d0
	moveal	sp@+,a0
	subl	a0@(8),d0
	movel	d0,a0@(12)
	moveml	sp@+,d2-d7/a2-a6
	rts

/* unrolled 30x literal copy @0x22c; decode jmp-dispatches into it */
_dcopy:	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	moveb	a2@+,a1@+
	braw	_dloop

/* ==== decode model init @0x2a8 ==== */
_dinit:	pea	a0@
	moveal	a0@(16),a6
	moveal	a6,a0
	lea	a6@(3168),a1
	lea	a6@(1902),a2
	moveq	#-2,d0
	moveq	#0,d3
	moveq	#1,d1
	moveq	#2,d2
	movew	#316,d7
_dil:	movew	d1,a0@+
	movew	d0,a1@+
	movew	d3,a2@-
	subw	d2,d0
	addw	d2,d3
	dbf	d7,_dil
	moveq	#0,d6
	movel	#634,d7
	moveal	a6,a0
	lea	a6@(634),a1
	lea	a6@(3802),a2
	lea	a6@(1902),a3
	moveq	#4,d4
	moveq	#2,d2
	movew	#315,d1
_djl:	movew	a0@+,d0
	addw	a0@+,d0
	movew	d0,a1@+
	movew	d6,a2@+
	movew	d7,a3@+
	movew	d7,a3@+
	addw	d4,d6
	addw	d2,d7
	dbf	d1,_djl
	movew	d1,a1@
	clrw	a6@(3166)
	moveal	sp@+,a5
	moveal	a5@,a0
	moveal	a5@(8),a1
	moveal	a5@(16),a6
	moveal	a6,a5
	lea	a6@(1902),a4
	lea	a6@(3168),a3
	moveq	#1,d4
	moveq	#15,d5
	movew	a0@+,d6
	bras	_dloop

/* literal emit: d7<0 -> -(d7+1)>>1 literals via _dcopy dispatch */
_dlit:	negw	d7
	lsrw	d4,d7
	subw	d4,d7
	moveb	d7,a1@+

/* ==== decode main loop @0x330 ==== */
_dloop:	movew	a3@(1264),d7		/* tree root */
_dbit:	addw	d6,d6			/* shift next bit */
	bccw	_dleft
	movew	a3@(2,d7:w),d7		/* right child */
	dbmi	d5,_dbit
	bmiw	_drefill
_dmore:	moveq	#15,d5
	movew	a0@+,d6
	bras	_dbit
_dleft:	movew	a3@(0,d7:w),d7		/* left child */
	dbmi	d5,_dbit
	bpls	_dmore
_drefill:
	dbf	d5,_dset
	movew	a0@+,d6
	moveq	#15,d5
_dset:	cmpiw	#-32768,a5@(1264)	/* rebuild needed? */
	beqw	_dcode
_dfix:	movew	a4@(0,d7:w),d0		/* adaptive freq walk */
_dfl:	lea	a5@(0,d0:w),a2
	movew	a2@,d1
	addw	d4,d1
	movew	d1,a2@+
	cmpw	a2@+,d1
	blss	_dfs
_dfw:	cmpw	a2@+,d1
	bhis	_dfw
	subql	#4,a2
	movel	a2,d2
	subl	a5,d2
	movew	a2@,a5@(0,d0:w)
	movew	d1,a2@
	movew	a3@(0,d0:w),d1
	bmis	_dfs0
	movew	d2,a4@(2,d1:w)
_dfs0:	movew	d2,a4@(0,d1:w)
	movew	a3@(0,d2:w),d3
	bmis	_dfs1
	movew	d0,a4@(2,d3:w)
_dfs1:	movew	d1,a3@(0,d2:w)
	movew	d0,a4@(0,d3:w)
	movew	d3,a3@(0,d0:w)
	movew	a4@(0,d2:w),d0
	bnes	_dfl
	bras	_dcode
_dfs:	movew	a4@(0,d0:w),d0
	bnes	_dfl
_dcode:	cmpiw	#-512,d7
	bgew	_dlit			/* d7>=-512 -> literal */
	cmpiw	#-634,d7
	bgts	_dpos			/* -634<d7<-512 -> position code */
	rts				/* d7<=-634 -> end marker */
_dpos:	rolw	#8,d6
	subqw	#7,d5
	bccs	_dpc2
	moveq	#0,d3
	movew	a0@+,d3
	swap	d3
	negw	d5
	roll	d5,d3
	movew	d3,d1
	orb	d6,d1
	swap	d3
	movew	d3,d6
	negw	d5
	moveq	#15,d2
	addw	d2,d5
	bras	_dpc3
_dpc2:	moveq	#0,d1
	moveb	d6,d1
	clrb	d6
	dbf	d5,_dpc3
	movew	a0@+,d6
	moveq	#15,d5
_dpc3:	movew	d1,d3
	addw	d3,d3
	movew	_dtab1(pc,d3:w),d3	/* packed len/code */
	clrw	d2
	moveb	d3,d2
	clrb	d3
	lsrw	#2,d3
_dpb:	addw	d6,d6			/* extra position bits */
	addxw	d1,d1
	dbf	d5,_dpb2
	moveq	#15,d5
	movew	a0@+,d6
_dpb2:	dbf	d2,_dpb
	andiw	#63,d1
	orw	d3,d1
	lea	a1@,a2
	subaw	d1,a2
	.short	0x4efb,0x707e		/* jmp pc@(0x7e,d7:w) -> _dcopy+N */

/* packed code table @0x428 */
_dtab1:
	.short 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	.short 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	.short 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	.short 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
	.short 0x0101,0x0101,0x0101,0x0101,0x0101,0x0101,0x0101,0x0101
	.short 0x0101,0x0101,0x0101,0x0101,0x0101,0x0101,0x0101,0x0101
	.short 0x0201,0x0201,0x0201,0x0201,0x0201,0x0201,0x0201,0x0201
	.short 0x0201,0x0201,0x0201,0x0201,0x0201,0x0201,0x0201,0x0201
	.short 0x0301,0x0301,0x0301,0x0301,0x0301,0x0301,0x0301,0x0301
	.short 0x0301,0x0301,0x0301,0x0301,0x0301,0x0301,0x0301,0x0301
	.short 0x0402,0x0402,0x0402,0x0402,0x0402,0x0402,0x0402,0x0402
	.short 0x0502,0x0502,0x0502,0x0502,0x0502,0x0502,0x0502,0x0502
	.short 0x0602,0x0602,0x0602,0x0602,0x0602,0x0602,0x0602,0x0602
	.short 0x0702,0x0702,0x0702,0x0702,0x0702,0x0702,0x0702,0x0702
	.short 0x0802,0x0802,0x0802,0x0802,0x0802,0x0802,0x0802,0x0802
	.short 0x0902,0x0902,0x0902,0x0902,0x0902,0x0902,0x0902,0x0902
	.short 0x0a02,0x0a02,0x0a02,0x0a02,0x0a02,0x0a02,0x0a02,0x0a02
	.short 0x0b02,0x0b02,0x0b02,0x0b02,0x0b02,0x0b02,0x0b02,0x0b02
	.short 0x0c03,0x0c03,0x0c03,0x0c03,0x0d03,0x0d03,0x0d03,0x0d03
	.short 0x0e03,0x0e03,0x0e03,0x0e03,0x0f03,0x0f03,0x0f03,0x0f03
	.short 0x1003,0x1003,0x1003,0x1003,0x1103,0x1103,0x1103,0x1103
	.short 0x1203,0x1203,0x1203,0x1203,0x1303,0x1303,0x1303,0x1303
	.short 0x1403,0x1403,0x1403,0x1403,0x1503,0x1503,0x1503,0x1503
	.short 0x1603,0x1603,0x1603,0x1603,0x1703,0x1703,0x1703,0x1703
	.short 0x1804,0x1804,0x1904,0x1904,0x1a04,0x1a04,0x1b04,0x1b04
	.short 0x1c04,0x1c04,0x1d04,0x1d04,0x1e04,0x1e04,0x1f04,0x1f04
	.short 0x2004,0x2004,0x2104,0x2104,0x2204,0x2204,0x2304,0x2304
	.short 0x2404,0x2404,0x2504,0x2504,0x2604,0x2604,0x2704,0x2704
	.short 0x2804,0x2804,0x2904,0x2904,0x2a04,0x2a04,0x2b04,0x2b04
	.short 0x2c04,0x2c04,0x2d04,0x2d04,0x2e04,0x2e04,0x2f04,0x2f04
	.short 0x3005,0x3105,0x3205,0x3305,0x3405,0x3505,0x3605,0x3705
	.short 0x3805,0x3905,0x3a05,0x3b05,0x3c05,0x3d05,0x3e05,0x3f05
/* ==== encode engine entry @0x628 ==== */
_enc:	moveml	d2-d7/a2-a6,sp@-
	pea	a0@
	bsrw	_einit
	moveal	sp@+,a0
	subal	a0@(8),a1
	cmpiw	#16,d7
	beqs	_eok
	addql	#2,a1
_eok:	movel	a1,a0@(12)
	movel	a1,d0
	moveml	sp@+,d2-d7/a2-a6
	rts

/* ==== encode match-record helper @0x64c ==== */
_ematch:
	moveq	#1,d4
	lea	a3@(-8312),a6
	lea	a6@,a2
	addaw	d0,a2
	movew	a2@+,d5
	addiw	#4097,d5
	addw	d5,d5
	movew	#8192,d6
	movew	d6,a3@(0,d0:w)
	movew	d6,a4@(0,d0:w)
	moveq	#0,d6
	movel	a2,d3
_ems:	moveal	d3,a2
_ems2:	tstw	d4
	bpls	_emz
	movew	a3@(0,d5:w),d2
	cmpiw	#8192,d2
	bnes	_emc
	movew	d0,a3@(0,d5:w)
	movew	d5,a5@(0,d0:w)
	rts
_emz:	movew	a4@(0,d5:w),d2
	cmpiw	#8192,d2
	bnes	_emc
	movew	d0,a4@(0,d5:w)
	movew	d5,a5@(0,d0:w)
	rts
_emc:	movew	d2,d5
	lea	a3@(-8310),a6
	addaw	d2,a6
	movel	a2,d3
	movew	a2@+,d4
	subw	a6@+,d4
	bnes	_ems
	movew	a2@+,d4
	subw	a6@+,d4
	bnes	_ems
	moveq	#57,d2
_emx:	movew	a2@+,d4
	subw	a6@+,d4
	dbne	d2,_emx
	negw	d2
	addiw	#60,d2
	moveal	d3,a2
	cmpw	d6,d2
	blts	_ems2
	beqs	_eme
	movew	d2,d6
	movew	d0,d3
	subw	d5,d3
	andiw	#8190,d3
	movew	d3,a3@(25094)
	cmpiw	#60,d2
	bcss	_ems2
	bras	_emr
_eme:	movew	d0,d3
	subw	d5,d3
	andiw	#8190,d3
	cmpw	a3@(25094),d3
	bccs	_ems2
	movew	d3,a3@(25094)
	braw	_ems2
_emr:	movew	a5@(0,d5:w),a5@(0,d0:w)
	movew	a3@(0,d5:w),a3@(0,d0:w)
	movew	a4@(0,d5:w),a4@(0,d0:w)
	movew	a3@(0,d5:w),d2
	movew	d0,a5@(0,d2:w)
	movew	a4@(0,d5:w),d2
	movew	d0,a5@(0,d2:w)
	movew	a5@(0,d5:w),d2
	cmpw	a4@(0,d2:w),d5
	bnes	_emq
	movew	d0,a4@(0,d2:w)
	bras	_ems3
_emq:	movew	d0,a3@(0,d2:w)
_ems3:	movew	#8192,a5@(0,d5:w)
	rts

/* ==== encode model update @0x734 ==== */
_eupd:	movew	#8192,d4
	cmpw	a5@(0,d0:w),d4
	beqs	_euout
	cmpw	a4@(0,d0:w),d4
	bnes	_eu1
	movew	a3@(0,d0:w),d2
	bras	_eu4
_eu1:	cmpw	a3@(0,d0:w),d4
	bnes	_eu2
	movew	a4@(0,d0:w),d2
	bras	_eu4
_eu2:	movew	a3@(0,d0:w),d2
	cmpw	a4@(0,d2:w),d4
	beqs	_eu3
_eu2l:	movew	a4@(0,d2:w),d2
	cmpw	a4@(0,d2:w),d4
	bnes	_eu2l
	movew	a5@(0,d2:w),d3
	movew	a3@(0,d2:w),a4@(0,d3:w)
	movew	a3@(0,d2:w),d3
	movew	a5@(0,d2:w),a5@(0,d3:w)
	movew	a3@(0,d0:w),d3
	movew	d3,a3@(0,d2:w)
	movew	d2,a5@(0,d3:w)
_eu3:	movew	a4@(0,d0:w),d3
	movew	d3,a4@(0,d2:w)
	movew	d2,a5@(0,d3:w)
_eu4:	movew	a5@(0,d0:w),d3
	movew	d3,a5@(0,d2:w)
	cmpw	a4@(0,d3:w),d0
	beqs	_eu5
	movew	d2,a3@(0,d3:w)
	movew	d4,a5@(0,d0:w)
	rts
_eu5:	movew	d2,a4@(0,d3:w)
	movew	d4,a5@(0,d0:w)
_euout:	rts

/* ==== encode emit-symbol helper @0x7b8 ==== */
_eput:	addw	d0,d0
	movew	d0,d1
	negw	d1
	lea	a3@(-10844),a2
	movew	a2@(-2,d1:w),d1
	moveq	#0,d3
	moveq	#1,d2
	moveq	#0,d4
_epw:	lsrw	d2,d3
	btst	d2,d1
	beqs	_epn
	oriw	#-32768,d3
_epn:	addw	d2,d4
	movew	a2@(0,d1:w),d1
	cmpiw	#1264,d1
	bnes	_epw
	swap	d3
	clrw	d3
	roll	d7,d3
	orw	d3,a1@
	subb	d4,d7
	bgts	_epf
	addql	#2,a1
	swap	d3
	movew	d3,a1@
	moveq	#16,d3
	addw	d3,d7
_epf:	cmpiw	#-32768,a3@(-11482)
	beqs	_epout
	lea	a3@(-12746),a5
	lea	a3@(-10844),a4
	lea	a3@(-9578),a3
	moveq	#1,d4
	negw	d0
	movew	a4@(-2,d0:w),d0
_epfl:	lea	a5@(0,d0:w),a2
	movew	a2@,d1
	addw	d4,d1
	movew	d1,a2@+
	cmpw	a2@+,d1
	blss	_epfs
_epfw:	cmpw	a2@+,d1
	bhis	_epfw
	subql	#4,a2
	movel	a2,d2
	subl	a5,d2
	movew	a2@,a5@(0,d0:w)
	movew	d1,a2@
	movew	a3@(0,d0:w),d1
	bmis	_eps0
	movew	d2,a4@(2,d1:w)
_eps0:	movew	d2,a4@(0,d1:w)
	movew	a3@(0,d2:w),d3
	bmis	_eps1
	movew	d0,a4@(2,d3:w)
_eps1:	movew	d1,a3@(0,d2:w)
	movew	d0,a4@(0,d3:w)
	movew	d3,a3@(0,d0:w)
	movew	a4@(0,d2:w),d0
	bnes	_epfl
	bras	_epd
_epfs:	movew	a4@(0,d0:w),d0
	bnes	_epfl
_epd:	lea	a5@(12746),a3
	lea	a5@(20940),a4
	lea	a5@(29646),a5
_epout:	rts

/* ==== encode model init @0x872 ==== */
_einit:	pea	a0@
	moveal	a0@(16),a6
	moveal	a6,a0
	lea	a6@(3168),a1
	lea	a6@(1902),a2
	moveq	#-2,d0
	moveq	#0,d3
	moveq	#1,d1
	moveq	#2,d2
	movew	#316,d7
_eil:	movew	d1,a0@+
	movew	d0,a1@+
	movew	d3,a2@-
	subw	d2,d0
	addw	d2,d3
	dbf	d7,_eil
	moveq	#0,d6
	movel	#634,d7
	moveal	a6,a0
	lea	a6@(634),a1
	lea	a6@(3802),a2
	lea	a6@(1902),a3
	moveq	#4,d4
	moveq	#2,d2
	movew	#315,d1
_ejl:	movew	a0@+,d0
	addw	a0@+,d0
	movew	d0,a1@+
	movew	d6,a2@+
	movew	d7,a3@+
	movew	d7,a3@+
	addw	d4,d6
	addw	d2,d7
	dbf	d1,_ejl
	movew	d1,a1@
	clrw	a6@(3166)
	moveq	#127,d0
	movel	#0x20002000,d1
	lea	a6@(29134),a0
_ezl:	movel	d1,a0@+
	dbf	d0,_ezl
	movew	#1023,d0
	lea	a6@(29646),a0
_ezl2:	movel	d1,a0@+
	movel	d1,a0@+
	dbf	d0,_ezl2
	moveal	sp@+,a6
	moveal	a6@,a0
	moveal	a6@(8),a1
	movel	a6@(4),d0
	moveal	a6@(16),a2
	addl	a0,d0
	movel	d0,sp@-
	lea	a2@(4434),a6
	movew	#2018,d1
	moveq	#0,d0
_ecl:	movel	d0,a6@+
	dbf	d1,_ecl
	lea	a2@(12506),a6
	moveq	#0,d2
	moveq	#0,d3
_eget:	moveb	a0@+,d3
	cmpal	sp@,a0
	bhis	_egot
	movew	d3,a6@+
	addqw	#1,d2
	cmpiw	#60,d2
	bcss	_eget
_egot:	lea	a2@(12746),a3
	lea	a2@(20940),a4
	lea	a2@(29646),a5
	movew	d2,a4@(16902)
	clrw	a1@
	moveq	#16,d7
	moveq	#0,d0
	movew	#8072,d1
	movew	d0,sp@-
	movew	d1,sp@-
	movew	d1,d0
	bsrw	_ematch
	movew	sp@+,d1
	movew	sp@+,d0
_emain:	cmpw	a4@(16902),d6
	blss	_em2
	movew	a4@(16902),d6
_em2:	cmpiw	#2,d6
	bcsw	_elit
	movew	d1,sp@-
	movew	d0,sp@-
	movew	d6,d0
	addiw	#255,d0
	bsrw	_eput
	moveq	#0,d0
	movew	a3@(25094),d0
	rorl	#7,d0
	addw	d0,d0
	.short	0x323b,0x002c	/* movew pc@(0x2c,d0:w),d1 -> _dtab2 */
	moveb	d1,d3
	clrb	d1
	swap	d0
	lsrw	d3,d0
	orw	d0,d1
	addqw	#6,d3
	swap	d1
	clrw	d1
	roll	d7,d1
	orw	d1,a1@
	subb	d3,d7
	bgts	_emo
	addql	#2,a1
	swap	d1
	movew	d1,a1@
	moveq	#16,d1
	addw	d1,d7
_emo:	movew	sp@+,d0
	movew	sp@+,d1
	braw	_enext

/* packed code table @0x9b2 */
_dtab2:
	.short 0x0003,0x2004,0x3004,0x4004,0x5005,0x5805,0x6005,0x6805
	.short 0x7005,0x7805,0x8005,0x8805,0x9006,0x9406,0x9806,0x9c06
	.short 0xa006,0xa406,0xa806,0xac06,0xb006,0xb406,0xb806,0xbc06
	.short 0xc007,0xc207,0xc407,0xc607,0xc807,0xca07,0xcc07,0xce07
	.short 0xd007,0xd207,0xd407,0xd607,0xd807,0xda07,0xdc07,0xde07
	.short 0xe007,0xe207,0xe407,0xe607,0xe807,0xea07,0xec07,0xee07
	.short 0xf008,0xf108,0xf208,0xf308,0xf408,0xf508,0xf608,0xf708
	.short 0xf808,0xf908,0xfa08,0xfb08,0xfc08,0xfd08,0xfe08,0xff08

/* lit path @0xa32 */
_elit:	moveq	#1,d6
	movew	d1,sp@-
	movew	d0,sp@-
	lea	a3@(-8312),a6
	movew	a6@(0,d1:w),d0
	bsrw	_eput
	movew	sp@+,d0
	movew	sp@+,d1
_enext:	movew	d6,d5
	subqw	#1,d5
_ewalk:	bsrw	_eupd
	moveb	a0@+,d3
	cmpal	sp@,a0
	blss	_estore
	subqw	#1,a4@(16902)
	bnes	_eadv
	bgtw	_emain
	moveq	#0,d0
	movew	#316,d0
	bsrw	_eput
	addql	#4,sp
	rts
_estore:
	lea	a3@(-8312),a6
	moveb	d3,a6@(1,d0:w)
	cmpiw	#118,d0
	bccs	_eadv
	lea	a6@(8192),a2
	moveb	d3,a2@(1,d0:w)
_eadv:	moveq	#2,d2
	addw	d2,d0
	addw	d2,d1
	movew	#8190,d2
	andw	d2,d0
	andw	d2,d1
	movew	d5,sp@-
	movew	d0,sp@-
	movew	d1,d0
	bsrw	_ematch
	movew	sp@+,d0
	movew	sp@+,d5
	dbf	d5,_ewalk
	braw	_emain

