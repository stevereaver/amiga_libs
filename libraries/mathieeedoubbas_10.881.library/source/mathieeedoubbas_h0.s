/* mathieeedoubbas.library "MDB 10.881" — verbatim reconstruction.
 * IEEE double-precision basic math, 68881 FPU backed.
 * Single CODE hunk 0x230 bytes; AUTOINIT; word-offset functab.
 * Quirks vs a normal Amiga lib:
 *  - rt_MatchTag/EndSkip/Name/Id/Init and the three InitTable pointer
 *    fields are relocated (DREL16, descending order); dataSize is not.
 *  - lib name pointer lands mid-string inside "Libs:NoFPU/...".
 *  - No-FPU init path frees the freshly allocated library and returns
 *    the (still-zero) seglist cell -> init fails on 68881-less machines.
 *  - Open unconditionally writes FPCR := 0x10.
 */
	.text

	rts					/* 0x00 dead entry stub */

_romtag:					/* 0x02 */
	.short	0x4afc
	.long	_romtag				/* rt_MatchTag */
	.long	_endskip			/* rt_EndSkip -> 0x230 */
	.byte	0x80				/* RTF_AUTOINIT */
	.byte	0x2d				/* rt_Version = 45 */
	.byte	9				/* NT_LIBRARY */
	.byte	0				/* rt_Pri */
	.long	_name				/* -> 0xeb (mid-string!) */
	.long	_idstr				/* -> 0x103 */
	.long	_inittab			/* -> 0x1c */

_inittab:					/* 0x1c */
	.long	0x3c				/* dataSize (NOT relocated) */
	.long	_functab			/* 0x20 -> 0x30 */
	.long	_datatab			/* 0x24 -> 0x54 */
	.long	_init				/* 0x28 -> 0x5e */
_cell:	.long	0				/* 0x2c seglist cell (init writes, expunge reads) */

_functab:					/* 0x30 word offsets from _functab */
	.short	0xffff
	.short	_open-_functab			/* -6   LibOpen     0x88 */
	.short	_close-_functab			/* -12  LibClose    0x9c */
	.short	_expunge-_functab		/* -18  LibExpunge  0xaa */
	.short	_null-_functab			/* -24  reserved    0xb6 */
	.short	_dpfix-_functab			/* -30  IEEEDPFix   0x16c */
	.short	_dpflt-_functab			/* -36  IEEEDPFlt   0x158 */
	.short	_dpcmp-_functab			/* -42  IEEEDPCmp   0x10e */
	.short	_dptst-_functab			/* -48  IEEEDPTst   0x144 */
	.short	_dpabs-_functab			/* -54  IEEEDPAbs   0x166 */
	.short	_dpneg-_functab			/* -60  IEEEDPNeg   0x17a */
	.short	_dpadd-_functab			/* -66  IEEEDPAdd   0x180 */
	.short	_dpsub-_functab			/* -72  IEEEDPSub   0x198 */
	.short	_dpmul-_functab			/* -78  IEEEDPMul   0x1b0 */
	.short	_dpdiv-_functab			/* -84  IEEEDPDiv   0x1c8 */
	.short	_dpfloor-_functab		/* -90  IEEEDPFloor 0x1e0 */
	.short	_dpceil-_functab		/* -96  IEEEDPCeil  0x208 */
	.short	0xffff

_datatab:					/* 0x54 */
	.byte	0xa0,0x0e,0x06,0x00		/* INITBYTE lib_Flags = 6 */
	.byte	0x90,0x16,0x03,0x71		/* INITWORD lib_Revision = 881 */
	.byte	0,0

/* ---- init ----------------------------------------------------- */
_init:						/* 0x5e (d0=libbase,a0=seglist,a6=exec) */
	tstl	d0
	beqs	1f
	btstb	#4,a6@(0x129)			/* AFF_68881 */
	beqs	_nofpu
	lea	_cell(pc),a1			/* FPU present: stash seglist */
	movel	a0,a1@
1:	rts

_nofpu:						/* 0x72 */
	movel	d0,sp@-				/* save new lib base */
	moveq	#0x24,d0			/* version 36 */
	lea	_nofpu_name(pc),a1
	jsr	a6@(-0x228)			/* exec.OpenLibrary */
	moveal	d0,a1
	jsr	a6@(-0x19e)			/* exec.CloseLibrary */
	moveal	sp@+,a1				/* a1 = NEW lib base */
	bras	_freetail			/* quirk: frees the fresh lib, ret segcell(0) */

_open:						/* 0x88 */
	moveq	#0x10,d0
	fmovel	d0,%fpcr			/* unconditional FPCR := 0x10 */
	addqw	#1,a6@(0x20)
	bclrb	#3,a6@(0xe)
	movel	a6,d0
	rts

_close:						/* 0x9c */
	subqw	#1,a6@(0x20)
	bnes	_null
	btstb	#3,a6@(0xe)
	beqs	_null
_expunge:					/* 0xaa */
	tstw	a6@(0x20)
	beqs	1f
	bsetb	#3,a6@(0xe)
_null:						/* 0xb6 */
	moveq	#0,d0
	rts
1:						/* 0xba unlink node, fall into freetail */
	moveal	a6,a1
	moveal	a6@+,a0				/* ln_Succ */
	moveal	a6@,a6				/* ln_Pred */
	movel	a0,a6@
	movel	a6,a0@(4)
	moveal	4,a6				/* exec base */
_freetail:					/* 0xca shared free tail */
	moveq	#0,d0
	movew	a1@(0x10),d0			/* NegSize */
	subaw	d0,a1
	addw	a1@(0x12,d0:w),d0		/* + PosSize */
	jsr	a6@(-0xd2)			/* exec.FreeMem */
	movel	_cell(pc),d0			/* return stored seglist */
	rts					/* 0xde */

/* ---- strings -------------------------------------------------- */
_nofpu_name:					/* 0xe0 */
	.ascii	"Libs:NoFPU/"
_name:	.ascii	"mathieeedoubbas.library"	/* 0xeb shares the tail */
	.byte	0
_idstr:	.ascii	"MDB 10.881"			/* 0x103 */
	.byte	0

/* ---- math vectors: doubles in d0:d1 / d2:d3 -------------------- */
_dpcmp:						/* 0x10e IEEEDPCmp */
	tstl	d2
	bmis	2f
	bnes	1f
	tstl	d3
	beqs	_dptst
1:	subl	d2,d0
	blts	_cmp_lt
	bnes	_cmp_gt
	cmpl	d3,d1
	bhis	_cmp_gt
	beqs	_cmp_eq
_cmp_lt:	moveq	#-1,d0			/* 0x124 */
_cmp_eq:	rts				/* 0x126 (d0=0) */
2:						/* 0x128 d2<0 path */
	tstl	d0
	bnes	3f
	tstl	d1
	bnes	_cmp_gt
	bsetb	#0x1f,d0			/* fabricate -0 sign */
3:	subl	d2,d0				/* 0x134 */
	bcss	_cmp_gt
	bnes	_cmp_lt
	cmpl	d3,d1
	bhis	_cmp_lt
	beqs	_cmp_rts
_cmp_gt:	moveq	#1,d0			/* 0x140 */
_cmp_rts:	rts				/* 0x142 */

_dptst:						/* 0x144 IEEEDPTst */
	addl	d0,d0
	bcss	4f
	bnes	_cmp_gt
	movel	d1,d0
	bnes	_cmp_gt
	rts
4:	bnes	_cmp_lt				/* 0x150 */
	movel	d1,d0
	bnes	_cmp_lt
	rts

_dpflt:						/* 0x158 IEEEDPFlt */
	fmovel	d0,%fp0
	fmoved	%fp0,sp@-
	movel	sp@+,d0
	movel	sp@+,d1
	rts

_dpabs:						/* 0x166 IEEEDPAbs */
	bclrb	#0x1f,d0
	rts

_dpfix:						/* 0x16c IEEEDPFix */
	moveml	d0-d1,sp@-
	fmoved	%sp@+,%fp0
	fmovel	%fp0,d0
	rts

_dpneg:						/* 0x17a IEEEDPNeg */
	bchgb	#0x1f,d0
	rts

_dpadd:						/* 0x180 IEEEDPAdd */
	moveml	d0-d3,sp@-
	fmoved	%sp@+,%fp0
	faddd	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x196 */

_dpsub:						/* 0x198 IEEEDPSub */
	moveml	d0-d3,sp@-
	fmoved	%sp@+,%fp0
	fsubd	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1ae */

_dpmul:						/* 0x1b0 IEEEDPMul */
	moveml	d0-d3,sp@-
	fmoved	%sp@+,%fp0
	fmuld	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1c6 */

_dpdiv:						/* 0x1c8 IEEEDPDiv */
	moveml	d0-d3,sp@-
	fmoved	%sp@+,%fp0
	fdivd	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x1de */

_dpfloor:					/* 0x1e0 IEEEDPFloor */
	moveml	d0-d1,sp@-
	fmoved	%sp@,%fp1
	fintrzx	%fp1,%fp0
	fcmpx	%fp1,%fp0
	fbule	5f
	fsubs	#0e1,%fp0
5:	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x206 */

_dpceil:					/* 0x208 IEEEDPCeil */
	moveml	d0-d1,sp@-
	fmoved	%sp@,%fp1
	fintrzx	%fp1,%fp0
	fcmpx	%fp1,%fp0
	fbuge	6f
	fadds	#0e1,%fp0
6:	fmoved	%fp0,%sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.short	0				/* pad 0x22e */

_endskip:					/* 0x230 */
