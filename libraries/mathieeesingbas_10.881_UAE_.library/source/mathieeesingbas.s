/*
 * mathieeesingbas.library 10.881 "(UAE)" -- byte-exact reconstruction.
 *
 * Single CODE hunk, 0x72 longs (0x1c8 bytes).  RomTag RTF_AUTOINIT,
 * rt_Version=45, NT_LIBRARY, pri 0.  Kickstart 1.x IEEE single-precision
 * math library for machines with a 68881/68882 FPU.  The "(UAE)" badge
 * is purely a collection label: this image is byte-for-byte identical
 * to the plain mathieeesingbas_10.881.library disk image.
 *
 * functab is a word-offset AUTOINIT table (leading/trailing -1);
 * offsets are relative to _functab itself.
 *
 * GNU ld emits a standard HUNK_RELOC32 tail; the original was linked
 * with the compact 0x3f7 (DREL) record holding 16-bit offsets in
 * descending order -- fixup.py rewrites the tail after linking.
 */
	.text

/*------------------------------ RomTag ------------------------------*/
/* 0x00 */	rts					/* dead-stub / entry safety */
_romtag:						/* 0x02 */
	.short	0x4afc					/* RTC_MATCHWORD */
	.long	_romtag					/* rt_MatchTag  */
	.long	_endskip				/* rt_EndSkip   */
	.byte	0x80, 45, 9, 0				/* RTF_AUTOINIT, v45, NT_LIBRARY, pri 0 */
	.long	_libname				/* rt_Name      */
	.long	_idstr					/* rt_IdString  */
	.long	_inittab				/* rt_Init      */

/*---------------------------- AUTOINIT table ------------------------*/
_inittab:						/* 0x1c */
	.long	0x3c					/* lib data size            */
	.long	_functab				/* function table           */
	.long	_datatab				/* InitStruct table         */
	.long	_initfn					/* init routine             */

_segcell:						/* 0x2c -- seglist scratch  */
	.long	0

/*---------------------------- function table ------------------------*/
/* word offsets relative to _functab, -1 flagged, -1 terminated */
_functab:						/* 0x30 */
	.short	0xffff
	.short	_open - _functab			/* -6  Open              */
	.short	_close - _functab			/* -12 Close             */
	.short	_expunge - _functab			/* -18 Expunge           */
	.short	_nullvec - _functab			/* -24 reserved          */
	.short	_fix - _functab				/* -30 IEEESPFix         */
	.short	_flt - _functab				/* -36 IEEESPFlt         */
	.short	_cmp - _functab				/* -42 IEEESPCmp         */
	.short	_tst - _functab				/* -48 IEEESPTst         */
	.short	_abs - _functab				/* -54 IEEESPAbs         */
	.short	_neg - _functab				/* -60 IEEESPNeg         */
	.short	_add - _functab				/* -66 IEEESPAdd         */
	.short	_sub - _functab				/* -72 IEEESPSub         */
	.short	_mul - _functab				/* -78 IEEESPMul         */
	.short	_div - _functab				/* -84 IEEESPDiv         */
	.short	_floor - _functab			/* -90 IEEESPFloor       */
	.short	_ceil - _functab			/* -96 IEEESPCeil        */
	.short	0xffff

/*---------------------------- InitStruct data ------------------------*/
/* 0x54 */ _datatab:
	.byte	0xa0, 0x0e, 0x06, 0x00			/* INITBYTE  lib_Flags(0x0e)  = 0x06 */
	.byte	0x90, 0x16, 0x03, 0x71			/* INITWORD  lib_Revision(0x16)= 881  */
	.byte	0x00, 0x00				/* end                         */

/*---------------------------- init routine ---------------------------*/
/* called by MakeLibrary: d0=libbase, a0=seglist, a6=SysBase */
_initfn:						/* 0x5e */
	tstl	%d0
	beqs	_initret				/* no base: return 0        */
	moveal	%d0,%a1
	btst	#4,(297,%a6)				/* AttnFlags: AFF_68881     */
	beqs	_initfail				/* no FPU: free mem, fail   */
	lea	_segcell(%pc),%a1
	movel	%a0,(%a1)				/* stash seglist            */
_initret:
	rts

/*---------------------------- Open (-6) ------------------------------*/
_open:							/* 0x74 */
	fmovel	%fpcr,%d0				/* read FPCR                */
	beqs	_open_fpcr				/* unset -> force 0x80      */
	cmpiw	#0x40,%d0
	bcss	_open_ok				/* <0x40: leave alone       */
	cmpiw	#0x80,%d0
	bccs	_open_ok				/* >=0x80: leave alone      */
_open_fpcr:
	fmovel	#0x80,%fpcr				/* mode byte 0x80           */
_open_ok:
	addqw	#1,(32,%a6)				/* lib_OpenCnt++            */
	bclr	#3,(14,%a6)				/* clr LIBF_DELEXP          */
	movel	%a6,%d0
	rts

/*---------------------------- Close (-12) ----------------------------*/
_close:							/* 0x9c */
	subqw	#1,(32,%a6)				/* lib_OpenCnt--            */
	bnes	_ret0
	btst	#3,(14,%a6)				/* LIBF_DELEXP set?         */
	beqs	_ret0
/*---------------------------- Expunge (-18) --------------------------*/
_expunge:						/* 0xaa */
	tstw	(32,%a6)				/* still open?              */
	beqs	_doexpunge
	bset	#3,(14,%a6)				/* set LIBF_DELEXP          */
_ret0:							/* 0xb6 also reserved -24   */
_nullvec:
	moveq	#0,%d0
	rts
_doexpunge:						/* 0xba inline Remove()     */
	moveal	%a6,%a1
	moveal	(%a6)+,%a0				/* a0 = ln_Succ             */
	moveal	(%a6),%a6				/* a6 = ln_Pred             */
	movel	%a0,(%a6)				/* pred->succ = succ        */
	movel	%a6,(4,%a0)				/* succ->pred = pred        */
	moveal	4,%a6					/* a6 = SysBase             */
_initfail:						/* 0xca shared free tail    */
	moveq	#0,%d0
	movew	(16,%a1),%d0				/* lib_NegSize              */
	subaw	%d0,%a1					/* a1 = block start         */
	addw	(18,%a1,%d0.w),%d0			/* d0 += lib_PosSize        */
	jsr	-210(%a6)				/* exec FreeMem(a1,d0)      */
	movel	_segcell(%pc),%d0			/* return seglist (or 0)    */
	rts

/*---------------------------- strings --------------------------------*/
_libname:						/* 0xe0 */
	.ascii	"mathieeesingbas.library"
	.byte	0
_idstr:							/* 0xf8 */
	.ascii	"MSB 10.881"
	.byte	0, 0					/* nul + alignment pad */

/*---------------------------- IEEESPTst (-48) ------------------------*/
/* integer-only: sign-extract via addl carry */
_tst:							/* 0x104 */
	addl	%d0,%d0					/* carry = sign bit         */
	bcss	_tstneg					/* was negative             */
	bnes	_retplus				/* was positive nonzero     */
	rts						/* zero -> 0                */

/*---------------------------- IEEESPCmp (-42) ------------------------*/
_cmp:							/* 0x10c */
	tstl	%d1
	bmis	_cmpd1neg				/* d1 < 0                   */
	beqs	_tst					/* d1 == 0: shares Tst tail */
	subl	%d1,%d0
	blts	_retminus				/* d0 < d1 -> -1            */
	beqs	_reteq					/* equal -> 0               */
_retplus:						/* 0x118 */
	moveq	#1,%d0
_reteq:							/* 0x11a */
	rts
_cmpd1neg:						/* 0x11c */
	tstl	%d0
	bnes	_cmpsub
	bset	#31,%d0					/* d0==+0 -> make -0x80000000 */
_cmpsub:						/* 0x124 */
	subl	%d1,%d0
	bcss	_retplus				/* unsigned wrap -> +1      */
_tstneg:						/* 0x128 */
	beqs	_cmpdone
_retminus:						/* 0x12a */
	moveq	#-1,%d0
_cmpdone:						/* 0x12c */
	rts

/*---------------------------- IEEESPAbs (-54) ------------------------*/
_abs:							/* 0x12e */
	bclr	#31,%d0
	rts

/*---------------------------- IEEESPFix (-30) ------------------------*/
_fix:							/* 0x134 */
	fmoves	%d0,%fp0
	fmovel	%fp0,%d0				/* round per FPCR mode      */
	rts

/*---------------------------- IEEESPNeg (-60) ------------------------*/
_neg:							/* 0x13e */
	bchg	#31,%d0
	rts

/*---------------------------- IEEESPFlt (-36) ------------------------*/
_flt:							/* 0x144 */
	fmovel	%d0,%fp0
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPFloor (-90) ----------------------*/
_floor:							/* 0x150 */
	fintrzs	%d0,%fp0				/* fp0 = trunc(x)           */
	fcmps	%d0,%fp0				/* fp0 vs x                 */
	fbule	_floorout				/* fp0 <= x (or unord): ok  */
	fsubs	#0x3f800000,%fp0			/* fp0 -= 1.0               */
_floorout:						/* 0x164 */
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPCeil (-96) -----------------------*/
_ceil:							/* 0x16c */
	fintrzs	%d0,%fp0				/* fp0 = trunc(x)           */
	fcmps	%d0,%fp0
	fbuge	_ceilout				/* fp0 >= x (or unord): ok  */
	fadds	#0x3f800000,%fp0			/* fp0 += 1.0               */
_ceilout:						/* 0x180 */
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPAdd (-66) ------------------------*/
_add:							/* 0x188 */
	fmoves	%d0,%fp0
	fadds	%d1,%fp0
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPSub (-72) ------------------------*/
_sub:							/* 0x198 */
	fmoves	%d0,%fp0
	fsubs	%d1,%fp0
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPMul (-78) ------------------------*/
_mul:							/* 0x1a8 */
	fmoves	%d0,%fp0
	fmuls	%d1,%fp0
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

/*---------------------------- IEEESPDiv (-84) ------------------------*/
_div:							/* 0x1b8 */
	fmoves	%d0,%fp0
	fdivs	%d1,%fp0
	fmoves	%fp0,%d0
	rts
	.short	0					/* align pad */

_endskip:						/* 0x1c8 */
