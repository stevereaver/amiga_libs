|||
|||	math.s -- mathieeedoubbas.library "MDB 10.881"
|||	IEEE-double primitives, verbatim 68881 sequences from the
|||	shipped binary.  Args: doubles in d0/d1 (+ d2/d3 for dyads).
|||	Stack carries doubles to/from the FPU; Tst/Cmp/Abs/Neg are
|||	pure integer sign-magnitude logic.
|||

	.section .text

	.globl	_IEEEDPFix
	.globl	_IEEEDPFlt
	.globl	_IEEEDPCmp
	.globl	_IEEEDPTst
	.globl	_IEEEDPAbs
	.globl	_IEEEDPNeg
	.globl	_IEEEDPAdd
	.globl	_IEEEDPSub
	.globl	_IEEEDPMul
	.globl	_IEEEDPDiv
	.globl	_IEEEDPFloor
	.globl	_IEEEDPCeil
	.globl	_XFreeMem
	.globl	_XOpenLibrary
	.globl	_XCloseLibrary

|||	LONG IEEEDPTst(d0/d1 parm) -> -1/0/+1
_IEEEDPTst:
	add.l	d0,d0			| sign of hi word -> C
	bcs.s	1f			| negative
	bne.s	2f			| positive nonzero
	move.l	d1,d0			| hi == 0 -> test lo
	bne.s	2f
	rts				| +0.0 -> 0
1:	bne.s	3f
	move.l	d1,d0
	bne.s	3f
	rts				| -0.0 -> 0
2:	moveq	#1,d0
	rts
3:	moveq	#-1,d0
	rts

|||	LONG IEEEDPCmp(d0/d1 left, d2/d3 right) -> -1/0/+1
_IEEEDPCmp:
	tst.l	d2
	bmi.s	2f			| right < 0
	bne.s	1f			| right > 0
	tst.l	d3
	beq.s	_IEEEDPTst		| right == 0 -> Tst(left)
1:	sub.l	d2,d0
	blt.s	Lm1
	bne.s	Lp1
	cmp.l	d3,d1
	bhi.s	Lp1
	beq.s	Lret
Lm1:	moveq	#-1,d0
Lret:	rts
Lp1:	moveq	#1,d0
	rts
2:	tst.l	d0
	bne.s	3f
	tst.l	d1
	bne.s	Lp1			| left nonzero vs negative -> +1
	bset	#31,d0			| left +0.0 vs neg -> -0.0
3:	sub.l	d2,d0
	bcs.s	Lp1
	bne.s	Lm1
	cmp.l	d3,d1
	bhi.s	Lm1
	beq.s	Lret
	moveq	#1,d0
	rts

|||	long IEEEDPFix(d0/d1 parm) -- double -> long (FPCR rounding)
_IEEEDPFix:
	moveml	d0-d1,%sp@-
	fmoved	%sp@+,%fp0
	fmovel	%fp0,d0
	rts

|||	double IEEEDPFlt(d0 integer) -- long -> double
_IEEEDPFlt:
	fmovel	d0,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPAbs(d0/d1 parm)
_IEEEDPAbs:
	bclr	#31,d0
	rts

|||	double IEEEDPNeg(d0/d1 parm)
_IEEEDPNeg:
	bchg	#31,d0
	rts

|||	double IEEEDPAdd(d0/d1 left, d2/d3 right)
_IEEEDPAdd:
	moveml	d0-d3,%sp@-
	fmoved	%sp@+,%fp0		| fp0 = left
	faddd	%sp@,%fp0		| fp0 += right (still on stack)
	fmoved	%fp0,%sp@		| result over right slot
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPSub(d0/d1 left, d2/d3 right)
_IEEEDPSub:
	moveml	d0-d3,%sp@-
	fmoved	%sp@+,%fp0
	fsubd	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPMul(d0/d1 factor1, d2/d3 factor2)
_IEEEDPMul:
	moveml	d0-d3,%sp@-
	fmoved	%sp@+,%fp0
	fmuld	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPDiv(d0/d1 dividend, d2/d3 divisor)
_IEEEDPDiv:
	moveml	d0-d3,%sp@-
	fmoved	%sp@+,%fp0
	fdivd	%sp@,%fp0
	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPFloor(d0/d1 parm)
|||	fp0 = trunc(x); if fp0 > x subtract 1 (fp0-x > 0 tests
|||	via fcmp + fbule: keep when fp0 <= x or unordered).
_IEEEDPFloor:
	moveml	d0-d1,%sp@-
	fmoved	%sp@,%fp1		| fp1 = x
	fintrzx	%fp1,%fp0		| fp0 = trunc(x)
	fcmpx	%fp1,%fp0		| fp0 vs x
	fbule	1f			| fp0 <= x -> keep
	fsubs	#0e1,%fp0
1:	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPCeil(d0/d1 parm) -- mirror of Floor
_IEEEDPCeil:
	moveml	d0-d1,%sp@-
	fmoved	%sp@,%fp1
	fintrzx	%fp1,%fp0
	fcmpx	%fp1,%fp0
	fbuge	1f			| fp0 >= x -> keep
	fadds	#0e1,%fp0
1:	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	exec.library call thunks -- a6 = ExecBase.
|||	FreeMem(a1 memBlock, d0 byteSize)
_XFreeMem:
	jsr	-210(a6)
	rts

|||	OpenLibrary(a1 libName, d0 version) -> d0
_XOpenLibrary:
	jsr	-552(a6)
	rts

|||	CloseLibrary(a1 library)
_XCloseLibrary:
	jsr	-414(a6)
	rts

	.end
