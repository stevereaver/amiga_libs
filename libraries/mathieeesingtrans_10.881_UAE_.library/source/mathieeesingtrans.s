/*
 * mathieeesingtrans.library "MST 10.881" -- byte-exact reconstruction.
 * Kickstart 1.x disk library for the MC68881/68882 FPU.
 *
 * Single CODE hunk (0x91 longs = 0x244 bytes).  AUTOINIT RomTag with
 * rt_Version 45 (not the library version!), word-offset functab,
 * InitStruct datatab.  Relocations live in a compact 16-bit RELOC32SHORT
 * (0x3f7) chunk: 8 descending long refs in the RomTag/InitTable.
 *
 * Quirks:
 *  - hunk starts with a bare RTS before the RomTag.
 *  - rt_Name points 11 bytes into the "Libs:NoFPU/..." path string;
 *    the library name is carved out of the fallback path tail.
 *  - dataSize 0x3c leaves 26 unused bytes past the exec Library node;
 *    the seglist cell sits in CODE at 0x2c instead of the lib base.
 *  - no-FPU init path pushes the base, opens+closes
 *    Libs:NoFPU/mathieeesingtrans.library v36, pops the base into a1
 *    and runs the shared free tail on it; returns the (still zero)
 *    segcell -> init failure.
 *  - Open preserves FPCR unless it is 0 or in [0x40,0x80): then it is
 *    rewritten to 0x80.
 *  - Close falls through into Expunge; the moveq#0/rts at 0xd4 is both
 *    the Close null-return, the deferred-Expunge return, the reserved
 *    vector, AND a branch target inside Pow (0^positive -> return 0).
 *  - Tieee/Fieee share the bare RTS tail of Sincos at 0x1a4.
 *  - Pow NaN is materialized as 0x7fffffff via moveq #-1 + bchg d0,d0.
 *  - every 10-byte FPU stub is padded to 12 with a zero word.
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
	.long	_nofpu_path+11			/* RT_NAME: "mathieeesingtrans.library" */
						/* tail of the NoFPU path (reloc @0x10) */
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
	.short	_open-_functab			/* -6   LibOpen    0x92  */
	.short	_close-_functab			/* -12  LibClose   0xba  */
	.short	_expunge-_functab		/* -18  LibExpunge 0xc8  */
	.short	_libnull-_functab		/* -24  reserved   0xd4  */
	.short	_IEEESPAtan-_functab		/* -30  0x208 */
	.short	_IEEESPSin-_functab		/* -36  0x1a8 */
	.short	_IEEESPCos-_functab		/* -42  0x1b4 */
	.short	_IEEESPTan-_functab		/* -48  0x1c0 */
	.short	_IEEESPSincos-_functab		/* -54  0x198 */
	.short	_IEEESPSinh-_functab		/* -60  0x1cc */
	.short	_IEEESPCosh-_functab		/* -66  0x1d8 */
	.short	_IEEESPTanh-_functab		/* -72  0x1e4 */
	.short	_IEEESPExp-_functab		/* -78  0x220 */
	.short	_IEEESPLog-_functab		/* -84  0x22c */
	.short	_IEEESPPow-_functab		/* -90  0x130 */
	.short	_IEEESPSqrt-_functab		/* -96  0x214 */
	.short	_IEEESPTieee-_functab		/* -102 shared rts 0x1a4 */
	.short	_IEEESPFieee-_functab		/* -108 shared rts 0x1a4 */
	.short	_IEEESPAsin-_functab		/* -114 0x1f0 */
	.short	_IEEESPAcos-_functab		/* -120 0x1fc */
	.short	_IEEESPLog10-_functab		/* -126 0x238 */
	.short	0xffff

_datatab:					/* 0x5e InitStruct stream */
	.byte	0xa0,0x0e,0x06,0x00		/* INITBYTE lib_Flags(14)   = 0x06 */
	.byte	0x90,0x16,0x03,0x71		/* INITWORD lib_Revision(22) = 881 */
	.byte	0,0

/* initfn(d0=libBase, a0=segList, a6=execBase) -> d0=base or 0 */
_initfn:					/* 0x68 */
	tstl	d0
	beqs	1f				/* no base -> return 0 */
	btst	#4,a6@(0x129)			/* AFF_68881 in AttnFlags */
	beqs	_nofpu				/* -> open/close fallback + free */
	lea	_segcell(pc),a1			/* 0x74 */
	movel	a0,a1@				/* segcell = seglist */
1:	rts					/* 0x7a */

_nofpu:						/* 0x7c */
	movel	d0,a7@-				/* save the fresh base */
	moveq	#0x24,d0			/* version 36 */
	lea	_nofpu_path(pc),a1		/* "Libs:NoFPU/mathieeesingtrans.library" */
	jsr	a6@(-552)			/* exec OpenLibrary */
	moveal	d0,a1
	jsr	a6@(-414)			/* exec CloseLibrary(result) */
	moveal	a7@+,a1				/* a1 = fresh base again */
	bras	_freetail			/* 0x90 -> free it, return 0 */

_open:						/* 0x92 */
	fmovel	%fpcr,d0			/* read FPCR (sets CCR on Dn dest) */
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

_close:						/* 0xba */
	subqw	#1,a6@(32)			/* lib_OpenCnt-- */
	bnes	_libnull
	btst	#3,a6@(14)			/* LIBF_DELEXP? */
	beqs	_libnull
	/* fall through */
_expunge:					/* 0xc8 */
	tstw	a6@(32)				/* lib_OpenCnt */
	beqs	3f
	bset	#3,a6@(14)			/* defer: set LIBF_DELEXP */
_libnull:					/* 0xd4 reserved vector lands here */
	moveq	#0,d0				/* (Pow 0^exp>0 branches here too) */
	rts
3:						/* 0xd8 unlink node by hand */
	moveal	a6,a1
	moveal	a6@+,a0				/* a0 = ln_Succ, a6 -> ln_Pred */
	moveal	a6@,a6				/* a6 = ln_Pred */
	movel	a0,a6@				/* pred->succ = succ */
	movel	a6,a0@(4)			/* succ->pred = pred */
	moveal	(4).w,a6			/* a6 = ExecBase */
_freetail:					/* 0xe8 shared free tail */
	moveq	#0,d0
	movew	a1@(16),d0			/* lib_NegSize */
	subaw	d0,a1				/* a1 = mem block start */
	addw	a1@(0x12,d0:w),d0		/* += lib_PosSize */
	jsr	a6@(-210)			/* exec FreeMem */
	movel	_segcell(pc),d0			/* return seglist (or 0) */
	rts

_nofpu_path:					/* 0xfe */
	.ascii	"Libs:NoFPU/mathieeesingtrans.library"
	.byte	0
_idstr:						/* 0x123 */
	.ascii	"MST 10.881"
	.byte	0,0,0				/* NUL + 2 pad to 0x130 */

/* --- math vectors: arg single in d0 (d1 = exp for Pow); result d0 -- */

_IEEESPPow:					/* 0x130 */
	tstl	d0
	bles	4f				/* arg <= 0 */
	flog2s	d0,%fp0				/* fp0 = log2(arg) */
	fmuls	d1,%fp0				/* fp0 *= exp */
	ftwotoxx %fp0,%fp0			/* fp0 = 2^fp0 = arg^exp */
	fmoves	%fp0,d0
	rts
Lnan:						/* 0x146 shared NaN return */
	moveq	#-1,d0
	bchg	d0,d0				/* 0xffffffff -> 0x7fffffff NaN */
	rts
5:						/* 0x14c arg == +-0: classify exp */
	fmoves	d1,%fp1				/* fp1 = exp (FPSR from operand) */
	fbogt	_libnull			/* exp > 0 -> shared moveq#0/rts */
	fbne	Lnan				/* exp < 0 -> NaN */
	movel	#0x3f800000,d0			/* exp == 0 -> 1.0f */
	rts
4:						/* 0x160 arg <= 0 */
	fnegs	d0,%fp0				/* fp0 = |arg| (Z for +-0) */
	fbeq	5b				/* arg == +-0 -> classify exp */
	fintrzs	d1,%fp1				/* fp1 = trunc(exp) */
	fcmps	d1,%fp1				/* integral? */
	fbne	Lnan				/* no -> NaN */
	flog2x	%fp0,%fp0			/* fp0 = log2|arg| */
	fmulx	%fp1,%fp0			/* fp0 *= trunc(exp) */
	ftwotoxx %fp0,%fp0			/* fp0 = |arg|^exp */
	fmoves	%fp0,d0
	fmods	#0e2,%fp1			/* fp1 = trunc(exp) mod 2 */
	fbeq	6f				/* even -> keep positive */
	bset	#31,d0				/* odd -> negate result */
6:	rts
	.short	0				/* pad 0x196 */

_IEEESPSincos:					/* 0x198 (a0=cosptr, d0=x) -> d0=sin */
	fsincoss d0,%fp1:%fp0			/* cos->fp1, sin->fp0 */
	fmoves	%fp1,a0@			/* *cosptr = cos(x) */
	fmoves	%fp0,d0				/* d0 = sin(x) */
_IEEESPTieee:					/* 0x1a4 both conversions share */
_IEEESPFieee:					/*       this bare RTS (identity) */
	rts
	.short	0				/* pad 0x1a6 */

_IEEESPSin:					/* 0x1a8 */
	fsins	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1b2 */

_IEEESPCos:					/* 0x1b4 */
	fcoss	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1be */

_IEEESPTan:					/* 0x1c0 */
	ftans	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1ca */

_IEEESPSinh:					/* 0x1cc */
	fsinhs	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1d6 */

_IEEESPCosh:					/* 0x1d8 */
	fcoshs	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1e2 */

_IEEESPTanh:					/* 0x1e4 */
	ftanhs	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1ee */

_IEEESPAsin:					/* 0x1f0 */
	fasins	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x1fa */

_IEEESPAcos:					/* 0x1fc */
	facoss	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x206 */

_IEEESPAtan:					/* 0x208 */
	fatans	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x212 */

_IEEESPSqrt:					/* 0x214 */
	fsqrts	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x21e */

_IEEESPExp:					/* 0x220 */
	fetoxs	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x22a */

_IEEESPLog:					/* 0x22c */
	flogns	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x236 */

_IEEESPLog10:					/* 0x238 */
	flog10s	d0,%fp0
	fmoves	%fp0,d0
	rts
	.short	0				/* pad 0x242 */

_endskip:					/* 0x244 */
	.end
