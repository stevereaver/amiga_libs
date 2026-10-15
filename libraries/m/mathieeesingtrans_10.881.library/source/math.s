|||
|||	math.s -- mathieeesingtrans.library "MST 10.881"
|||	IEEE-single transcendentals, verbatim 68881 sequences from
|||	the shipped binary.  Args: single in d0 (+ d1 for Pow);
|||	Sincos takes cosptr in a0.  Tieee/Fieee are stubs in the
|||	original (one shared bare RTS).
|||

	.section .text

	.globl	_IEEESPAtan
	.globl	_IEEESPSin
	.globl	_IEEESPCos
	.globl	_IEEESPTan
	.globl	_IEEESPSincos
	.globl	_IEEESPSinh
	.globl	_IEEESPCosh
	.globl	_IEEESPTanh
	.globl	_IEEESPExp
	.globl	_IEEESPLog
	.globl	_IEEESPPow
	.globl	_IEEESPSqrt
	.globl	_IEEESPTieee
	.globl	_IEEESPFieee
	.globl	_IEEESPAsin
	.globl	_IEEESPAcos
	.globl	_IEEESPLog10
	.globl	_XFreeMem
	.globl	_XOpenLibrary
	.globl	_XCloseLibrary

|||	float IEEESPAtan(d0 parm)
_IEEESPAtan:
	fatans	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPSin(d0 parm)
_IEEESPSin:
	fsins	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPCos(d0 parm)
_IEEESPCos:
	fcoss	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPTan(d0 parm)
_IEEESPTan:
	ftans	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPSincos(a0 cosptr, d0 parm)
|||	fsincos leaves cos in fp1, sin in fp0; cos stored to *a0.
_IEEESPSincos:
	fsincoss d0,%fp1:%fp0
	fmoves	%fp1,%a0@
	fmoves	%fp0,d0
	rts

|||	float IEEESPSinh(d0 parm)
_IEEESPSinh:
	fsinhs	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPCosh(d0 parm)
_IEEESPCosh:
	fcoshs	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPTanh(d0 parm)
_IEEESPTanh:
	ftanhs	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPExp(d0 parm)
_IEEESPExp:
	fetoxs	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPLog(d0 parm)
_IEEESPLog:
	flogns	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPPow(d1 exp, d0 arg)
|||	arg > 0  -> 2^(exp*log2(arg))
|||	arg == 0 -> 0 (exp>0), 1.0 (exp==0), NaN (exp<0)
|||	arg < 0  -> |arg|^exp if exp integral, sign applied when
|||	            exp odd; NaN (0x7fffffff) otherwise.
_IEEESPPow:
	tst.l	d0
	ble.s	1f			| arg <= 0
	flog2s	d0,%fp0
	fmuls	d1,%fp0
	ftwotoxx %fp0,%fp0
	fmoves	%fp0,d0
	rts
Lnan:
	moveq	#-1,d0
	bchg	d0,d0			| 0xffffffff -> 0x7fffffff (NaN)
	rts
1:	fnegs	d0,%fp0			| fp0 = -arg (Z set for +-0)
	fbeq	2f			| arg == 0
	fintrzs	d1,%fp1			| fp1 = trunc(exp)
	fcmps	d1,%fp1			| integral?
	fbne	Lnan			| no -> NaN
	flog2x	%fp0,%fp0		| fp0 = log2|arg|
	fmulx	%fp1,%fp0		| fp0 *= exp
	ftwotoxx %fp0,%fp0
	fmoves	%fp0,d0			| d0 = |arg|^exp
	fmods	#0e2,%fp1		| exp mod 2 -> odd/even
	fbeq	3f
	bset	#31,d0			| odd -> negate
3:	rts
2:	fmoves	d1,%fp1			| exp -> fp1, sets FPSR
	fbogt	Lzero			| exp > 0 -> return +0
	fbne	Lnan			| exp < 0 -> NaN
	move.l	#0x3f800000,d0		| exp == 0 -> 1.0
	rts
Lzero:
	moveq	#0,d0			| shipped: jumps into the
	rts				|  reserved (moveq#0/rts) vector

|||	float IEEESPSqrt(d0 parm)
_IEEESPSqrt:
	fsqrts	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPTieee(d0 parm) / float IEEESPFieee(d0 parm)
|||	both LVOs point at the same bare RTS in the shipped binary:
|||	the IEEE single argument is returned unchanged.
_IEEESPTieee:
_IEEESPFieee:
	rts

|||	float IEEESPAsin(d0 parm)
_IEEESPAsin:
	fasins	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPAcos(d0 parm)
_IEEESPAcos:
	facoss	d0,%fp0
	fmoves	%fp0,d0
	rts

|||	float IEEESPLog10(d0 parm)
_IEEESPLog10:
	flog10s	d0,%fp0
	fmoves	%fp0,d0
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
