/*
 * mathieeedoubbas.library 31.3 (WB1.1) -- hunk 1: dispatch layer.
 *
 * Vector entry stubs (+0x20c..0x278) are referenced from hunk 0's
 * functab (long-absolute, relocated against this hunk).  Each loads a
 * helper into a1 (PC-relative lea) then jmps a wrapper:
 *   +0x194 _w_una : unary helper  (d0/d1 -> scr0, d2/d3 -> scr1),
 *                   helper called with d0=&scr0, d1=&scr1
 *   +0x1b8 _w_unb : unary helper  (d0/d1 -> scr0), dst = scr2,
 *                   result returned from scr2 -> d0/d1
 *   +0x1da _w_bin : binary helper (d0/d1 -> scr0, d2/d3 -> scr1),
 *                   dst = scr2, result returned from scr2 -> d0/d1
 * Helpers +0x000 (fix), +0x06c (flt), +0x0b6 (abs) are pure 68k.
 * Stubs +0x0cc..+0x192 copy args into scratch cells then `jsr _core`
 * (hunk 2) with an inline selector word after the jsr.
 * +0x27c scr0, +0x284 scr1, +0x28c scr2: self-modifying cells inside
 * the code hunk (documented quirk).
 */

	.text
	.globl	_v_fix,_v_flt,_v_cmp,_v_tst,_v_abs
	.globl	_v_neg,_v_add,_v_sub,_v_mul,_v_div
	.extern	_core

/* ==== 0x000 fix: d0=double* -> d0=int ============================== */
/* rounding-mode bits in d0 are hardwired 0 (dead flag tests kept) */
_fix:
	moveal	%d0,%a1			/* a1 -> double */
	moveq	#0,%d0			/* flags */
	moveml	%d2-%d5,%sp@-
	moveml	%a1@,%d1-%d2		/* d1:d2 = double */
	movel	%d1,%d5			/* save sign/exp */
	movel	%d1,%d3
	andil	#0x7ff00000,%d3
	beqs	7f			/* exp==0 -> 0 */
	andil	#0xfffff,%d1
	moveq	#20,%d4
	bset	%d4,%d1			/* hidden bit */
	lsrl	%d4,%d3			/* biased exp */
	subiw	#1074,%d3		/* -1023-51 */
	negw	%d3			/* rshift count */
	cmpiw	#20,%d3
	blts	9f			/* |x| < 1 -> err path */
	cmpiw	#52,%d3
	bgts	10f			/* huge -> 0 */
1:	lsrl	#1,%d1
	roxrl	#1,%d2
	dbf	%d3,1b
	btst	#0,%d0			/* dead: flags==0 */
	beqs	2f
	addxl	%d1,%d2
	bcss	9f
2:	movel	%d2,%d1
	tstl	%d5
	bges	7f
	negl	%d1
7:	eorl	%d1,%d5			/* sign changed? -> error */
	bmis	8f
_fix_pop:
	moveml	%sp@+,%d2-%d5
	bras	_fix_ret
8:	btst	#1,%d0			/* dead: flags==0 */
	bnes	_fix_pop
9:	moveq	#107,%d1		/* error value */
	bras	_fix_pop
10:	clrl	%d1
	bras	_fix_pop
_fix_ret:
	movel	%d1,%d0
	rts

/* ==== 0x06c flt: d1=int, d0=outptr -> *out=dbl, d0=outptr ========== */
_flt:
	linkw	%a6,#0
	moveml	%d2-%d5/%a3,%sp@-
	subal	%a0,%a0
	moveal	%d0,%a3			/* a3 -> out */
	moveq	#0,%d2			/* lo mantissa */
	tstl	%d1
	beqs	_fltout
	slt	%d5			/* sign flag */
	bges	1f
	negl	%d1			/* abs(n) */
1:	moveq	#31,%d3			/* count leading zeros */
_fltl1:	lsll	#1,%d1
	dbcs	%d3,_fltl1
	moveq	#11,%d4
_fltl2:	lsrl	#1,%d1
	roxrw	#1,%d2
	dbf	%d4,_fltl2
	addiw	#1023,%d3		/* bias exp */
	moveq	#20,%d4
	asll	%d4,%d3
	orl	%d3,%d1
	tstb	%d5
	beqs	_fltout
	bset	#31,%d1			/* sign bit */
_fltout:
	moveml	%d1-%d2,%a3@
	movel	%a3,%d0
	moveml	%sp@+,%d2-%d5/%a3
	unlk	%a6
	rts

/* ==== 0x0b6 abs: *dst(d0) = |*src(d1)| ============================= */
_abs:
	moveal	%d0,%a0
	moveal	%d1,%a1
	movel	%a1@(4),%a0@(4)
	movel	%a1@,%d1
	bclr	#31,%d1
	movel	%d1,%a0@
	movel	%a0,%d0
	rts

/* ==== 0x0cc neg stub: copy src->dst, negate in place =============== */
/* in: d0=dstptr, d1=srcptr ; out: d0=dstptr */
_s_neg:
	movel	%d2,%sp@-
	movel	%d1,%d2			/* d2 = src */
	movel	%d0,%d1			/* d1 = dst */
	moveal	%d1,%a0
	moveal	%d2,%a1
	movel	%a1@+,%a0@+		/* dst = src */
	movel	%a1@+,%a0@+
	jsr	_core:l
	.short	0xff0c			/* neg */
	movel	%d1,%d0
	movel	%sp@+,%d2
	rts

/* ==== 0x0e8 cmp stub: (d0=&a, d1=&b) -> d0 = -1/0/+1 =============== */
_s_cmp:
	movel	%d2,%sp@-
	movel	%d1,%d2			/* d2 = b ptr */
	movel	%d0,%d1			/* d1 = a ptr */
	clrl	%d0
	jsr	_core:l
	.short	0xff0d			/* cmp -> ccr */
	moveml	%sp@+,%d2
	blts	1f
	bgts	2f
	rts				/* equal -> 0 */
1:	subql	#1,%d0			/* lt -> -1 */
	rts
2:	addql	#1,%d0			/* gt -> +1 */
	rts

/* ==== 0x10a tst stub: (d0=ptr) -> d0 = -1/0/+1 ===================== */
_s_tst:
	movel	%d0,%d1			/* d1 = arg ptr */
	clrl	%d0
	jsr	_core:l
	.short	0xff0e			/* tst -> ccr */
	blts	1f
	bgts	2f
	rts
1:	subql	#1,%d0
	rts
2:	addql	#1,%d0
	rts

/* ==== 0x124..0x192 binary stubs =================================== */
/* in: d0=dstptr(scr2), d1=src1ptr(scr0), d2=src2ptr(scr1 via a0) */
_s_add:
	movel	%d2,%sp@-
	movel	%a0,%d2			/* d2 = scr1 ptr */
	moveal	%d1,%a1			/* a1 = scr0 (arg1) */
	movel	%d0,%d1			/* d1 = scr2 (dst) */
	moveal	%d1,%a0
	movel	%a1@+,%a0@+		/* dst = arg1 */
	movel	%a1@+,%a0@+
	jsr	_core:l
	.short	0xff08			/* add */
	movel	%d1,%d0
	movel	%sp@+,%d2
	rts
_s_sub:
	movel	%d2,%sp@-
	movel	%a0,%d2
	moveal	%d1,%a1
	movel	%d0,%d1
	moveal	%d1,%a0
	movel	%a1@+,%a0@+
	movel	%a1@+,%a0@+
	jsr	_core:l
	.short	0xff09			/* sub */
	movel	%d1,%d0
	movel	%sp@+,%d2
	rts
_s_mul:
	movel	%d2,%sp@-
	movel	%a0,%d2
	moveal	%d1,%a1
	movel	%d0,%d1
	moveal	%d1,%a0
	movel	%a1@+,%a0@+
	movel	%a1@+,%a0@+
	jsr	_core:l
	.short	0xff0a			/* mul */
	movel	%d1,%d0
	movel	%sp@+,%d2
	rts
_s_div:
	movel	%d2,%sp@-
	movel	%a0,%d2
	moveal	%d1,%a1
	movel	%d0,%d1
	moveal	%d1,%a0
	movel	%a1@+,%a0@+
	movel	%a1@+,%a0@+
	jsr	_core:l
	.short	0xff0b			/* div */
	movel	%d1,%d0
	movel	%sp@+,%d2
	rts

/* ==== 0x194 wrapper: cmp/tst (result in d0) ======================== */
/* d0/d1 = arg1, d2/d3 = arg2 ; helper called d0=&scr0, d1=&scr1 */
_w_una:
	moveml	%d2-%d3,%sp@-
	lea	_scr0:l,%a0
	moveml	%d0-%d1,%a0@		/* scr0 = arg1 */
	movel	%a0,%d0
	lea	_scr1:l,%a0
	moveml	%d2-%d3,%a0@		/* scr1 = arg2 */
	movel	%a0,%d1
	jsr	%a1@			/* helper */
	moveml	%sp@+,%d2-%d3
	rts

/* ==== 0x1b8 wrapper: abs/neg (result scr2 -> d0/d1) ================ */
/* d0/d1 = arg ; helper called d0=&scr2(dst), d1=&scr0(src) */
_w_unb:
	lea	_scr0:l,%a0
	moveml	%d0-%d1,%a0@		/* scr0 = arg */
	movel	%a0,%d1
	lea	_scr2:l,%a0		/* a0 = scr2 (dst) */
	movel	%a0,%d0
	jsr	%a1@			/* helper */
	lea	_scr2:l,%a0
	moveml	%a0@,%d0-%d1		/* return double */
	rts

/* ==== 0x1da wrapper: add/sub/mul/div (result scr2 -> d0/d1) ======== */
/* d0/d1 = arg1, d2/d3 = arg2 ; helper called d0=&scr2(dst),
   d1=&scr0(arg1), a0=&scr1(arg2) — helper moves a0->d2 itself */
_w_bin:
	movel	%a2,%sp@-
	lea	_scr0:l,%a0
	moveml	%d0-%d1,%a0@		/* scr0 = arg1 */
	movel	%a0,%d1
	lea	_scr1:l,%a0
	moveml	%d2-%d3,%a0@		/* scr1 = arg2 */
	lea	_scr2:l,%a2
	movel	%a2,%d0			/* d0 = scr2 (dst) */
	jsr	%a1@			/* helper */
	lea	_scr2:l,%a0
	moveml	%a0@,%d0-%d1		/* return double */
	moveml	%sp@+,%a2
	rts

/* ==== 0x20c..0x278 vector entry stubs ============================== */
/* -30 IEEEDPFix(d0/d1) -> d0 int */
_v_fix:
	lea	%pc@(_fix),%a1	/* -> 0x000 */
	lea	_scr0:l,%a0
	moveml	%d0-%d1,%a0@		/* scr0 = arg */
	movel	%a0,%d0
	jsr	%a1@
	rts
/* -36 IEEEDPFlt(d0 int) -> d0/d1 double */
_v_flt:
	lea	%pc@(_flt),%a1	/* -> 0x06c */
	movel	%d0,%d1			/* int arg */
	lea	_scr2:l,%a0
	movel	%a0,%d0			/* out ptr */
	jsr	%a1@
	lea	_scr2:l,%a0
	moveml	%a0@,%d0-%d1
	rts
/* -42 IEEEDPCmp(d0/d1, d2/d3) -> d0 */
_v_cmp:
	lea	%pc@(_s_cmp),%a1	/* -> 0x0e8 */
	jmp	%pc@(_w_una)
/* -48 IEEEDPTst(d0/d1) -> d0 */
_v_tst:
	lea	%pc@(_s_tst),%a1	/* -> 0x10a */
	jmp	%pc@(_w_una)
/* -54 IEEEDPAbs(d0/d1) -> d0/d1 */
_v_abs:
	lea	%pc@(_abs),%a1	/* -> 0x0b6 */
	jmp	%pc@(_w_unb)
/* -60 IEEEDPNeg(d0/d1) -> d0/d1 */
_v_neg:
	lea	%pc@(_s_neg),%a1	/* -> 0x0cc */
	jmp	%pc@(_w_unb)
/* -66 IEEEDPAdd -> d0/d1 */
_v_add:
	lea	%pc@(_s_add),%a1	/* -> 0x124 */
	jmp	%pc@(_w_bin)
/* -72 IEEEDPSub */
_v_sub:
	lea	%pc@(_s_sub),%a1	/* -> 0x140 */
	jmp	%pc@(_w_bin)
/* -78 IEEEDPMul */
_v_mul:
	lea	%pc@(_s_mul),%a1	/* -> 0x15c */
	jmp	%pc@(_w_bin)
/* -84 IEEEDPDiv */
_v_div:
	lea	%pc@(_s_div),%a1	/* -> 0x178 */
	jmp	%pc@(_w_bin)

/* ==== 0x27c scratch cells (self-modifying code quirk) ============== */
_scr0:	.long	0,0			/* 0x27c */
_scr1:	.long	0,0			/* 0x284 */
_scr2:	.long	0,0			/* 0x28c */
