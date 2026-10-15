/* mathieeedoubtrans.library "MDT 10.881" — verbatim reconstruction.
 * IEEE double-precision transcendental math, 68881 FPU backed.
 * Single CODE hunk 0x2d4 bytes; AUTOINIT; word-offset functab.
 * Doubles are passed in d0:d1 (arg) and d2:d3 (exp for Pow);
 * IEEEDPSincos also takes a result pointer in a0.
 * Quirks vs a normal Amiga lib:
 *  - rt_Name points 11 bytes into the "Libs:NoFPU/..." path string;
 *    the library name is carved out of the fallback path tail.
 *  - no-FPU init path pushes the fresh base, opens+closes
 *    Libs:NoFPU/mathieeedoubtrans.library v36, pops the base into a1
 *    and runs the shared free tail on it; returns the (still zero)
 *    segcell -> init failure.
 *  - Open unconditionally writes FPCR := 0x10.
 *  - the seglist cell sits in CODE at 0x2c instead of the lib base.
 *  - the moveq#0/rts at 0xc0 is the reserved vector, the Close/
 *    deferred-Expunge return AND a branch target inside Pow
 *    (0^positive -> return +0, d1 keeps the arg low word).
 *  - Pow NaN is materialized as 0x7fffffff:0xffffffff via
 *    moveq #-1 + bchg d0,d0 / moveq #-1,d1.
 *  - every 18-byte math stub is padded to 20 with a zero word.
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
	.long	_name				/* RT_NAME: "mathieeedoubtrans.library" */
						/* tail of the NoFPU path (reloc @0x10) */
	.long	_idstr				/* (reloc @0x14) */
	.long	_inittab			/* (reloc @0x18) */

_inittab:					/* 0x1c */
	.long	0x3c				/* dataSize (NOT relocated) */
	.long	_functab			/* (reloc @0x20) */
	.long	_datatab			/* (reloc @0x24) */
	.long	_initfn				/* (reloc @0x28) */

_segcell:					/* 0x2c seglist cell (in CODE!) */
	.long	0

_functab:					/* 0x30 word offsets rel. to table */
	.short	0xffff
	.short	_open-_functab			/* -6   LibOpen    0x92  */
	.short	_close-_functab			/* -12  LibClose   0xa6  */
	.short	_expunge-_functab		/* -18  LibExpunge 0xb4  */
	.short	_libnull-_functab		/* -24  reserved   0xc0  */
	.short	_IEEEDPAtan-_functab		/* -30  0x284 */
	.short	_IEEEDPSin-_functab		/* -36  0x1d0 */
	.short	_IEEEDPCos-_functab		/* -42  0x1e4 */
	.short	_IEEEDPTan-_functab		/* -48  0x1f8 */
	.short	_IEEEDPSincos-_functab		/* -54  0x1b8 */
	.short	_IEEEDPSinh-_functab		/* -60  0x20c */
	.short	_IEEEDPCosh-_functab		/* -66  0x220 */
	.short	_IEEEDPTanh-_functab		/* -72  0x234 */
	.short	_IEEEDPExp-_functab		/* -78  0x248 */
	.short	_IEEEDPLog-_functab		/* -84  0x2ac */
	.short	_IEEEDPPow-_functab		/* -90  0x11c */
	.short	_IEEEDPSqrt-_functab		/* -96  0x298 */
	.short	_IEEEDPTieee-_functab		/* -102 0x198 */
	.short	_IEEEDPFieee-_functab		/* -108 0x1a8 */
	.short	_IEEEDPAsin-_functab		/* -114 0x25c */
	.short	_IEEEDPAcos-_functab		/* -120 0x270 */
	.short	_IEEEDPLog10-_functab		/* -126 0x2c0 */
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
	lea	_nofpu_path(pc),a1		/* "Libs:NoFPU/mathieeedoubtrans.library" */
	jsr	a6@(-552)			/* exec OpenLibrary */
	moveal	d0,a1
	jsr	a6@(-414)			/* exec CloseLibrary(result) */
	moveal	a7@+,a1				/* a1 = fresh base again */
	bras	_freetail			/* 0x90 -> free it, return 0 */

_open:						/* 0x92 */
	moveq	#0x10,d0
	fmovel	d0,%fpcr			/* unconditional FPCR := 0x10 */
	addqw	#1,a6@(32)			/* lib_OpenCnt++ */
	bclr	#3,a6@(14)			/* clear LIBF_DELEXP */
	movel	a6,d0
	rts

_close:						/* 0xa6 */
	subqw	#1,a6@(32)			/* lib_OpenCnt-- */
	bnes	_libnull
	btst	#3,a6@(14)			/* LIBF_DELEXP? */
	beqs	_libnull
	/* fall through */
_expunge:					/* 0xb4 */
	tstw	a6@(32)				/* lib_OpenCnt */
	beqs	3f
	bset	#3,a6@(14)			/* defer: set LIBF_DELEXP */
_libnull:					/* 0xc0 reserved vector lands here */
	moveq	#0,d0				/* (Pow 0^exp>0 branches here too) */
	rts
3:						/* 0xc4 unlink node by hand */
	moveal	a6,a1
	moveal	a6@+,a0				/* a0 = ln_Succ, a6 -> ln_Pred */
	moveal	a6@,a6				/* a6 = ln_Pred */
	movel	a0,a6@				/* pred->succ = succ */
	movel	a6,a0@(4)			/* succ->pred = pred */
	moveal	(4).w,a6			/* a6 = ExecBase */
_freetail:					/* 0xd4 shared free tail */
	moveq	#0,d0
	movew	a1@(16),d0			/* lib_NegSize */
	subaw	d0,a1				/* a1 = mem block start */
	addw	a1@(0x12,d0:w),d0		/* += lib_PosSize */
	jsr	a6@(-210)			/* exec FreeMem */
	movel	_segcell(pc),d0			/* return seglist (or 0) */
	rts

_nofpu_path:					/* 0xea */
	.ascii	"Libs:NoFPU/"
_name:	.ascii	"mathieeedoubtrans.library"	/* 0xf5 shares the tail */
	.byte	0
_idstr:						/* 0x10f */
	.ascii	"MDT 10.881"
	.byte	0,0,0				/* NUL + 2 pad to 0x11c */

/* --- math vectors: doubles in d0:d1 (d2:d3 = exp for Pow) -------- */

_IEEEDPPow:					/* 0x11c (a0..d3 pushed) */
	moveml	d0-d3,sp@-			/* [sp]=arg, [sp+8]=exp */
	fmoved	sp@+,%fp0			/* fp0 = arg (FPSR from arg) */
	fbole	5f				/* arg <= 0 -> classify */
	flog2x	%fp0,%fp0			/* fp0 = log2(arg) */
	fmuld	sp@,%fp0			/* fp0 *= exp */
	ftwotoxx %fp0,%fp0			/* fp0 = arg^exp */
	fmoved	%fp0,sp@			/* write back into arg slot */
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x13e */
4:						/* 0x140 arg == +-0: classify exp */
	fmoved	sp@+,%fp1			/* fp1 = exp (FPSR from exp) */
	fbogt	_libnull			/* exp > 0 -> shared moveq#0/rts */
	fbne	Lnan				/* exp < 0 or NaN -> NaN */
	movel	#0x3ff00000,d0			/* exp == 0 -> 1.0 */
	rts					/* (d1 = arg low word = 0) */
Lnan:						/* 0x154 shared NaN return */
	moveq	#-1,d0
	bchg	d0,d0				/* 0xffffffff -> 0x7fffffff */
	moveq	#-1,d1				/* NaN = 0x7fffffff:0xffffffff */
	rts
5:						/* 0x15c arg <= 0 */
	fbeq	4b				/* arg == +-0 -> classify exp */
	fintrzd	sp@,%fp1			/* fp1 = trunc(exp) */
	fcmpd	sp@+,%fp1			/* integral? (pops exp) */
	fbne	Lnan				/* no -> NaN */
	fnegx	%fp0,%fp0			/* fp0 = |arg| */
	flog2x	%fp0,%fp0			/* fp0 = log2|arg| */
	fmulx	%fp1,%fp0			/* fp0 *= trunc(exp) */
	ftwotoxx %fp0,%fp0			/* fp0 = |arg|^exp */
	fmoved	%fp0,sp@-			/* push result */
	movel	sp@+,d0
	movel	sp@+,d1
	fmods	#0e2,%fp1			/* fp1 = trunc(exp) mod 2 */
	fbeq	6f				/* even -> keep positive */
	bset	#31,d0				/* odd -> negate result */
6:	rts
	.short	0				/* pad 0x196 */

_IEEEDPTieee:					/* 0x198 (d0:d1) -> d0 single */
	moveml	d0-d1,sp@-
	fmoved	sp@+,%fp0
	fmoves	%fp0,d0				/* convert to single, set CCR */
	rts
	.short	0				/* pad 0x1a6 */

_IEEEDPFieee:					/* 0x1a8 (d0 single) -> d0:d1 */
	fmoves	d0,%fp0				/* single arg in d0 */
	fmoved	%fp0,sp@-			/* widen to double */
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1b6 */

_IEEEDPSincos:					/* 0x1b8 (a0=cosptr, d0:d1=x) -> d0:d1 sin */
	moveml	d0-d1,sp@-
	fsincosd sp@,%fp1:%fp0			/* cos->fp1, sin->fp0 */
	fmoved	%fp1,a0@			/* *cosptr = cos(x) */
	fmoved	%fp0,sp@			/* d0:d1 = sin(x) */
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1ce */

_IEEEDPSin:					/* 0x1d0 */
	moveml	d0-d1,sp@-
	fsind	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1e2 */

_IEEEDPCos:					/* 0x1e4 */
	moveml	d0-d1,sp@-
	fcosd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1f6 */

_IEEEDPTan:					/* 0x1f8 */
	moveml	d0-d1,sp@-
	ftand	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x20a */

_IEEEDPSinh:					/* 0x20c */
	moveml	d0-d1,sp@-
	fsinhd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x21e */

_IEEEDPCosh:					/* 0x220 */
	moveml	d0-d1,sp@-
	fcoshd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x232 */

_IEEEDPTanh:					/* 0x234 */
	moveml	d0-d1,sp@-
	ftanhd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x246 */

_IEEEDPExp:					/* 0x248 */
	moveml	d0-d1,sp@-
	fetoxd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x25a */

_IEEEDPAsin:					/* 0x25c */
	moveml	d0-d1,sp@-
	fasind	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x26e */

_IEEEDPAcos:					/* 0x270 */
	moveml	d0-d1,sp@-
	facosd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x282 */

_IEEEDPAtan:					/* 0x284 */
	moveml	d0-d1,sp@-
	fatand	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x296 */

_IEEEDPSqrt:					/* 0x298 */
	moveml	d0-d1,sp@-
	fsqrtd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x2aa */

_IEEEDPLog:					/* 0x2ac */
	moveml	d0-d1,sp@-
	flognd	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x2be */

_IEEEDPLog10:					/* 0x2c0 */
	moveml	d0-d1,sp@-
	flog10d	sp@,%fp0
	fmoved	%fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x2d2 (endskip-2) */

_endskip:					/* 0x2d4 */
	.end
