|||
|||	math.s -- mathieeesingbas.library "MSB 10.881"
|||	IEEE-single primitives, verbatim 68881 sequences from the
|||	shipped binary.  Tst/Cmp/Abs/Neg are pure integer code
|||	(sign-magnitude IEEE trick); the rest are 2-3 instruction
|||	FPU stubs.  Register args per the .fd: d0/d1.
|||

	.section .text

	.globl	_IEEESPFix
	.globl	_IEEESPFlt
	.globl	_IEEESPCmp
	.globl	_IEEESPTst
	.globl	_IEEESPAbs
	.globl	_IEEESPNeg
	.globl	_IEEESPAdd
	.globl	_IEEESPSub
	.globl	_IEEESPMul
	.globl	_IEEESPDiv
	.globl	_IEEESPFloor
	.globl	_IEEESPCeil
	.globl	_XFreeMem

|||	LONG IEEESPTst(d0 parm) -> -1/0/+1
_IEEESPTst:
	add.l	d0,d0			| sign -> C, magnitude -> Z
	bcs.s	1f			| negative
	bne.s	2f			| positive nonzero
	rts				| +0.0 -> 0
2:	moveq	#1,d0
	rts
1:	beq.s	3f			| -0.0 -> 0
	moveq	#-1,d0
3:	rts

|||	LONG IEEESPCmp(d0 leftParm, d1 rightParm) -> -1/0/+1
|||	positive IEEE singles compare like integers; the sign
|||	bit makes the negative side need a magnitude flip.
_IEEESPCmp:
	tst.l	d1
	bmi.s	1f			| right < 0
	beq.s	_IEEESPTst		| right == 0 -> Tst(left)
	sub.l	d1,d0
	blt.s	5f
	beq.s	6f
	moveq	#1,d0
6:	rts
5:	moveq	#-1,d0
	rts
1:	tst.l	d0
	bne.s	2f
	bset	#31,d0			| left +0.0 vs neg -> -0.0
2:	sub.l	d1,d0
	bcs.s	3f
	beq.s	6b
	moveq	#-1,d0
	rts
3:	moveq	#1,d0
	rts

|||	long IEEESPFix(d0 parm) -- single -> long (FPCR rounding)
_IEEESPFix:
	fmoves	d0,%fp0
	fmovel	%fp0,d0
	rts

|||	float IEEESPFlt(d0 integer) -- long -> single
_IEEESPFlt:
	fmovel	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPAbs(d0 parm)
_IEEESPAbs:
	bclr	#31,d0
	rts

|||	float IEEESPNeg(d0 parm)
_IEEESPNeg:
	bchg	#31,d0
	rts

|||	float IEEESPAdd(d0 leftParm, d1 rightParm)
_IEEESPAdd:
	fmoves	d0,%fp0
	fadds	d1,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPSub(d0 leftParm, d1 rightParm)
_IEEESPSub:
	fmoves	d0,%fp0
	fsubs	d1,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPMul(d0 leftParm, d1 rightParm)
_IEEESPMul:
	fmoves	d0,%fp0
	fmuls	d1,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPDiv(d0 dividend, d1 divisor)
_IEEESPDiv:
	fmoves	d0,%fp0
	fdivs	d1,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPFloor(d0 parm)
|||	fp0 = trunc(x); if fp0 > x subtract 1 (fp0-x > 0 tests
|||	via fcmp + fbule: keep when fp0 <= x or unordered).
_IEEESPFloor:
	fintrzs	d0,%fp0
	fcmps	d0,%fp0
	fbule	1f
	fsubs	#0e1,%fp0
1:	fmoves	%fp0,d0
	rts

|||	float IEEESPCeil(d0 parm) -- mirror of Floor
_IEEESPCeil:
	fintrzs	d0,%fp0
	fcmps	d0,%fp0
	fbuge	1f
	fadds	#0e1,%fp0
1:	fmoves	%fp0,d0
	rts

|||	exec.library call thunk: FreeMem(a1 memBlock, d0 byteSize)
|||	called with a6 = ExecBase.
_XFreeMem:
	jsr	-210(a6)
	rts

	.end
