/*
 * mathieeedoubbas.library 31.3 (WB1.1) -- hunk 0: headers + lifecycle.
 *
 * RomTag (AUTOINIT, v31) -> InitTable @0x58: dsize 0x22, functab @0x98
 * (long-absolute, -1 terminated), datatab @0x70, initfn @0x68.
 * The initfn doubles as the -24 reserved vector: it stores the
 * incoming seglist (a0) into the code-hunk cell at +0x13e so Expunge
 * can return it.
 * Vectors -30..-84 live in hunk 1 (their functab longs relocate
 * against hunk1); the FP core is hunk 2.
 */

	.text
	.globl	_v_fix,_v_flt,_v_cmp,_v_tst,_v_abs
	.globl	_v_neg,_v_add,_v_sub,_v_mul,_v_div

/* ==== 0x000 RomTag ================================================= */
_romtag:
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_end			/* rt_EndSkip = 0x144 */
	.byte	0x81			/* RTF_AUTOINIT + bit0 */
	.byte	31			/* version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* pri */
	.long	_libname
	.long	_idstr
	.long	_inittab

/* ==== 0x01a strings ================================================ */
_libname:
	.ascii	"mathieeedoubbas.library\0"
_idstr:
	.ascii	"mathieeedoubbas 31.3 (23 Nov 1985)\r\n\0"
	.byte	0			/* pad to 0x58 */

/* ==== 0x058 InitTable ============================================== */
_inittab:
	.long	0x22			/* dataSize (posSize) */
	.long	_functab
	.long	_datatab
	.long	_initfn

/* ==== 0x068 initfn / reserved -24 vector =========================== */
_initfn:
	movel	%a0,_seglist:l		/* stash seglist */
	rts

/* ==== 0x070 datatab (InitStruct stream) ============================ */
_datatab:
	.byte	0xe0,0x00		/* INITBYTE off24 */
	.short	0x0008
	.byte	0x09,0x00		/* ln_Type = NT_LIBRARY */
	.byte	0xc0,0x00		/* INITLONG off24 */
	.short	0x000a
	.long	_libname		/* ln_Name */
	.byte	0xd0,0x00		/* INITWORD off24 */
	.short	0x0016
	.short	3			/* lib_Revision */
	.byte	0xd0,0x00
	.short	0x0014
	.short	31			/* lib_Version */
	.byte	0xe0,0x00
	.short	0x000e
	.byte	0x06,0x00		/* lib_Flags = 6 */
	.byte	0xd0,0x00
	.short	0x0020
	.short	0			/* lib_OpenCnt = 0 */
	.byte	0,0			/* end */

/* ==== 0x098 functab (long-absolute, -1 term) ======================= */
_functab:
	.long	_open			/* -6  */
	.long	_close			/* -12 */
	.long	_expunge		/* -18 */
	.long	_initfn			/* -24 reserved -> initfn quirk */
	.long	_v_fix			/* -30 IEEEDPFix  */
	.long	_v_flt			/* -36 IEEEDPFlt  */
	.long	_v_cmp			/* -42 IEEEDPCmp  */
	.long	_v_tst			/* -48 IEEEDPTst  */
	.long	_v_abs			/* -54 IEEEDPAbs  */
	.long	_v_neg			/* -60 IEEEDPNeg  */
	.long	_v_add			/* -66 IEEEDPAdd  */
	.long	_v_sub			/* -72 IEEEDPSub  */
	.long	_v_mul			/* -78 IEEEDPMul  */
	.long	_v_div			/* -84 IEEEDPDiv  */
	.long	-1

/* ==== 0x0d4 Expunge ================================================ */
_expunge:
	tstw	%a6@(32)		/* openCnt */
	bnes	_exp_dly
	moveal	%a6,%a1			/* unlink node */
	moveal	%a1@,%a0
	moveal	%a1@(4),%a1
	movel	%a0,%a1@
	movel	%a1,%a0@(4)
	moveal	%a6,%a1
	moveq	#0,%d0
	movew	%a6@(16),%d0		/* negsize */
	subaw	%d0,%a1
	addw	%a6@(18),%d0		/* + possize */
	movel	%a6,%sp@-
	.short	0x2c79			/* moveal 4:l,a6 (long-abs) */
	.long	4
	jsr	%a6@(-210)		/* FreeMem */
	moveal	%sp@+,%a6
	movel	_seglist:l,%d0		/* return seglist */
	rts
_exp_dly:
	bset	#3,%a6@(14)		/* LIBF_DELEXP */
	moveq	#0,%d0
	rts

/* ==== 0x116 Open =================================================== */
_open:
	btst	#3,%a6@(14)		/* refuse while DELEXP */
	bnes	1f
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	rts
1:	moveq	#-1,%d0
	rts

/* ==== 0x12a Close ================================================== */
_close:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	2f
	btst	#3,%a6@(14)
	beqs	2f
	bsrs	_expunge		/* deferred expunge */
2:	rts

/* ==== 0x13e seglist cell + pad ===================================== */
_seglist:
	.long	0
	.short	0			/* pad; rt_EndSkip = 0x144 */
_end:
