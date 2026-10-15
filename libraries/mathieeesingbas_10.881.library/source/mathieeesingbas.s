/*
 * mathieeesingbas.library "MSB 10.881" -- byte-exact reconstruction.
 * Kickstart 1.x disk library for the MC68881/68882 FPU.
 *
 * Single CODE hunk (0x72 longs = 0x1c8 bytes).  AUTOINIT RomTag with
 * rt_Version 45 (not the library version!), word-offset functab,
 * InitStruct datatab.  Relocations live in a compact 16-bit RELOC32SHORT
 * (0x3f7) chunk: 8 descending long refs in the RomTag/InitTable.
 *
 * Quirks:
 *  - hunk starts with a bare RTS before the RomTag.
 *  - dataSize 0x3c leaves 26 unused bytes past the exec Library node;
 *    the seglist cell sits in CODE at 0x2c instead of the lib base.
 *  - initfn tail at 0xca is shared with Expunge's unlink/free tail:
 *    on a missing AFF_68881 it FreeMem()s the fresh base and returns
 *    the (still zero) segcell -> init failure.
 *  - Open preserves FPCR unless it is 0 or in [0x40,0x80): then it is
 *    rewritten to 0x80.
 *  - Close falls through into Expunge; the moveq#0/rts at 0xb6 is both
 *    the Close null-return and the deferred-Expunge return.
 */
	.text
	.globl	_romtag
	.globl	_endskip
	.globl	_inittab

	rts					/* 0x00 executable entry: bare RTS */

_romtag:					/* 0x02 */
	.short	0x4afc				/* RT_MATCHWORD */
	.long	_romtag				/* RT_MATCHTAG  (reloc @0x04) */
	.long	_endskip			/* RT_ENDSKIP   (reloc @0x08) */
	.byte	0x80,0x2d,0x09,0x00		/* AUTOINIT, ver 45, NT_LIBRARY, pri 0 */
	.long	_name				/* (reloc @0x10) */
	.long	_idstr				/* (reloc @0x14) */
	.long	_inittab			/* (reloc @0x18) */

_inittab:					/* 0x1c */
	.long	0x3c				/* dataSize */
	.long	_functab			/* (reloc @0x20) */
	.long	_datatab			/* (reloc @0x24) */
	.long	_initfn				/* (reloc @0x28) */

_segcell:					/* 0x2c seglist cell (in CODE!) */
	.long	0

_functab:					/* 0x30 word offsets rel. to table */
	.short	0xffff
	.short	_open-_functab			/* -6   LibOpen    0x44  */
	.short	_close-_functab			/* -12  LibClose   0x6c  */
	.short	_expunge-_functab		/* -18  LibExpunge 0x7a  */
	.short	_libnull-_functab		/* -24  reserved   0x86  */
	.short	_IEEESPFix-_functab		/* -30  0x104 */
	.short	_IEEESPFlt-_functab		/* -36  0x114 */
	.short	_IEEESPCmp-_functab		/* -42  0xdc  */
	.short	_IEEESPTst-_functab		/* -48  0xd4  */
	.short	_IEEESPAbs-_functab		/* -54  0xfe  */
	.short	_IEEESPNeg-_functab		/* -60  0x10e */
	.short	_IEEESPAdd-_functab		/* -66  0x158 */
	.short	_IEEESPSub-_functab		/* -72  0x168 */
	.short	_IEEESPMul-_functab		/* -78  0x178 */
	.short	_IEEESPDiv-_functab		/* -84  0x188 */
	.short	_IEEESPFloor-_functab		/* -90  0x120 */
	.short	_IEEESPCeil-_functab		/* -96  0x13c */
	.short	0xffff

_datatab:					/* 0x54 InitStruct stream */
	.byte	0xa0,0x0e,0x06,0x00		/* INITBYTE lib_Flags(14)   = 0x06 */
	.byte	0x90,0x16,0x03,0x71		/* INITWORD lib_Revision(22) = 881 */
	.byte	0,0

/* initfn(d0=libBase, a0=segList, a6=execBase) -> d0=base or 0 */
_initfn:					/* 0x5e */
	tstl	d0
	beqs	1f				/* no base -> return 0 */
	moveal	d0,a1				/* a1 = base (free-tail arg) */
	btst	#4,a6@(0x129)			/* AFF_68881 in AttnFlags */
	beqs	_nofpu				/* -> shared free tail */
	lea	_segcell(pc),a1			/* 0x6c */
	movel	a0,a1@				/* segcell = seglist */
1:	rts					/* 0x72 */

_open:						/* 0x74 */
	fmovel	%fpcr,d0			/* read FPCR */
	beqs	2f				/* 0   -> force 0x80 */
	cmpiw	#0x40,d0
	bcss	1f				/* <0x40 -> keep */
	cmpiw	#0x80,d0
	bccs	1f				/* >=0x80 -> keep */
2:	fmovel	#0x80,%fpcr			/* [0x40,0x80) or 0 -> 0x80 */
1:	addqw	#1,a6@(32)			/* lib_OpenCnt++ */
	bclr	#3,a6@(14)			/* clear LIBF_DELEXP */
	movel	a6,d0
	rts

_close:						/* 0x9c */
	subqw	#1,a6@(32)			/* lib_OpenCnt-- */
	bnes	_libnull
	btst	#3,a6@(14)			/* LIBF_DELEXP? */
	beqs	_libnull
	/* fall through */
_expunge:					/* 0xaa */
	tstw	a6@(32)				/* lib_OpenCnt */
	beqs	3f
	bset	#3,a6@(14)			/* defer: set LIBF_DELEXP */
_libnull:					/* 0xb6 reserved vector lands here */
	moveq	#0,d0
	rts
3:						/* 0xba unlink node by hand */
	moveal	a6,a1
	moveal	a6@+,a0				/* a0 = ln_Succ, a6 -> ln_Pred */
	moveal	a6@,a6				/* a6 = ln_Pred */
	movel	a0,a6@				/* pred->succ = succ */
	movel	a6,a0@(4)			/* succ->pred = pred */
	moveal	(4).w,a6			/* a6 = ExecBase */
_nofpu:						/* 0xca shared free tail */
	moveq	#0,d0
	movew	a1@(16),d0			/* lib_NegSize */
	subaw	d0,a1				/* a1 = mem block start */
	addw	a1@(0x12,d0:w),d0		/* += lib_PosSize */
	jsr	a6@(-210)			/* exec FreeMem */
	movel	_segcell(pc),d0			/* return seglist (or 0) */
	rts

_name:						/* 0xe0 */
	.ascii	"mathieeesingbas.library"
	.byte	0
_idstr:						/* 0xf8 */
	.ascii	"MSB 10.881"
	.byte	0,0				/* NUL + pad */

/* --- math vectors: regs d0[,d1], result d0; FPU stubs ------------- */

_IEEESPTst:					/* 0x104 sign-magnitude trick */
	addl	d0,d0				/* sign->C, mag->Z */
	bcss	8f				/* negative -> 0x128 */
	bnes	5f				/* positive nonzero -> 0x118 */
	rts					/* +0 -> 0 */
_IEEESPCmp:					/* 0x10c */
	tstl	d1
	bmis	6f				/* right < 0 -> 0x11c */
	beqs	_IEEESPTst			/* right == 0 -> Tst(left) */
	subl	d1,d0
	blts	7f				/* -> 0x12a */
	beqs	9f				/* -> 0x11a */
5:	moveq	#1,d0				/* 0x118 shared +1 tail */
9:	rts						/* 0x11a shared rts */
6:	tstl	d0				/* 0x11c */
	bnes	10f				/* -> 0x124 */
	bset	#31,d0				/* +0 vs neg -> -0 */
10:	subl	d1,d0				/* 0x124 */
	bcss	5b				/* -> 0x118 */
8:	beqs	11f				/* 0x128 shared eq tail */
7:	moveq	#-1,d0				/* 0x12a shared -1 tail */
11:	rts						/* 0x12c */

_IEEESPAbs:					/* 0x12e */
	bclr	#31,d0
	rts

_IEEESPFix:					/* 0x134 single -> long */
	fmoves	d0,%fp0
	fmovel	%fp0,d0
	rts

_IEEESPNeg:					/* 0x13e */
	bchg	#31,d0
	rts

_IEEESPFlt:					/* 0x144 long -> single */
	fmovel	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x14e */

_IEEESPFloor:					/* 0x150 */
	fintrzs	d0,%fp0				/* fp0 = trunc(x) */
	fcmps	d0,%fp0
	fbule	1f				/* keep when fp0<=x or NaN */
	fsubs	#0e1,%fp0			/* fp0 -= 1.0 */
1:	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x16a */

_IEEESPCeil:					/* 0x16c mirror of Floor */
	fintrzs	d0,%fp0
	fcmps	d0,%fp0
	fbuge	1f				/* keep when fp0>=x or NaN */
	fadds	#0e1,%fp0			/* fp0 += 1.0 */
1:	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x186 */

_IEEESPAdd:					/* 0x188 */
	fmoves	d0,%fp0
	fadds	d1,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x196 */

_IEEESPSub:					/* 0x198 */
	fmoves	d0,%fp0
	fsubs	d1,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1a6 */

_IEEESPMul:					/* 0x1a8 */
	fmoves	d0,%fp0
	fmuls	d1,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1b6 */

_IEEESPDiv:					/* 0x1b8 */
	fmoves	d0,%fp0
	fdivs	d1,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1c6 */

_endskip:					/* 0x1c8 */
	.end
