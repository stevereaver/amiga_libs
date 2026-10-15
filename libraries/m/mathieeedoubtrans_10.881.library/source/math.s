|||
|||	math.s -- mathieeedoubtrans.library "MDT 10.881"
|||	IEEE-double transcendentals, verbatim 68881 sequences from
|||	the shipped binary.  Args: doubles in d0/d1 (+ d2/d3 for
|||	Pow's exponent); Sincos takes cosptr in a0.  Operands ride
|||	the stack: moveml d0-d3 pushes, fmoved sp@+ loads.
|||	Tieee/Fieee are real conversions here (unlike singtrans).
|||

	.section .text

	.globl	_IEEEDPAtan
	.globl	_IEEEDPSin
	.globl	_IEEEDPCos
	.globl	_IEEEDPTan
	.globl	_IEEEDPSincos
	.globl	_IEEEDPSinh
	.globl	_IEEEDPCosh
	.globl	_IEEEDPTanh
	.globl	_IEEEDPExp
	.globl	_IEEEDPLog
	.globl	_IEEEDPPow
	.globl	_IEEEDPSqrt
	.globl	_IEEEDPTieee
	.globl	_IEEEDPFieee
	.globl	_IEEEDPAsin
	.globl	_IEEEDPAcos
	.globl	_IEEEDPLog10
	.globl	_XFreeMem
	.globl	_XOpenLibrary
	.globl	_XCloseLibrary

|||	double IEEEDPAtan(d0/d1 parm)
_IEEEDPAtan:
	moveml	d0-d1,%sp@-
	fatand	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPSin(d0/d1 parm)
_IEEEDPSin:
	moveml	d0-d1,%sp@-
	fsind	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPCos(d0/d1 parm)
_IEEEDPCos:
	moveml	d0-d1,%sp@-
	fcosd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPTan(d0/d1 parm)
_IEEEDPTan:
	moveml	d0-d1,%sp@-
	ftand	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPSincos(a0 cosptr, d0/d1 parm)
|||	fsincos leaves cos in fp1, sin in fp0; cos stored to *a0.
_IEEEDPSincos:
	moveml	d0-d1,%sp@-
	fsincosd %sp@,%fp1:%fp0
	fmoved	%fp1,%a0@
	fmoved	%fp0,%sp@
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPSinh(d0/d1 parm)
_IEEEDPSinh:
	moveml	d0-d1,%sp@-
	fsinhd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPCosh(d0/d1 parm)
_IEEEDPCosh:
	moveml	d0-d1,%sp@-
	fcoshd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPTanh(d0/d1 parm)
_IEEEDPTanh:
	moveml	d0-d1,%sp@-
	ftanhd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPExp(d0/d1 parm)
_IEEEDPExp:
	moveml	d0-d1,%sp@-
	fetoxd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPLog(d0/d1 parm)
_IEEEDPLog:
	moveml	d0-d1,%sp@-
	flognd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPPow(d0/d1 arg, d2/d3 exp)
|||	arg > 0  -> 2^(exp*log2(arg))
|||	arg == 0 -> +0 (exp>0; d1 left as the popped arg lo),
|||	            1.0 (exp==0), NaN 0x7fffffff/0xffffffff (exp<0)
|||	arg < 0  -> |arg|^exp if exp integral, sign applied when
|||	            trunc(exp) is odd; NaN otherwise.
_IEEEDPPow:
	moveml	d0-d3,%sp@-		| push arg,exp (arg on top)
	fmoved	%sp@+,%fp0		| fp0 = arg, exp stays at (sp)
	fbole	1f			| arg <= 0 (ordered)
	flog2x	%fp0,%fp0
	fmuld	%sp@,%fp0		| fp0 *= exp
	ftwotoxx %fp0,%fp0
	fmoved	%fp0,%sp@		| result over exp slot
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

| shared NaN tail: d0=0x7fffffff, d1=0xffffffff
Lnan:
	moveq	#-1,d0
	bchg	d0,d0
	moveq	#-1,d1
	rts

| arg == 0 (exp still at (sp))
2:	fmoved	%sp@+,%fp1		| fp1 = exp, pop exp
	fbogt	Lzero			| exp > 0 -> return +0 (d1=arglo)
	fbne	Lnan			| exp < 0 -> NaN
	move.l	#0x3ff00000,d0		| exp == 0 -> 1.0 (d1=0)
	rts

| arg < 0 (exp still at (sp))
1:	fbeq	2b			| arg == 0
	fintrzd	%sp@,%fp1		| fp1 = trunc(exp)
	fcmpd	%sp@+,%fp1		| fp1 vs exp, pop exp
	fbne	Lnan			| non-integral -> NaN
	fnegx	%fp0,%fp0		| fp0 = |arg|
	flog2x	%fp0,%fp0
	fmulx	%fp1,%fp0		| fp0 *= trunc(exp)
	ftwotoxx %fp0,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0		| d0/d1 = |arg|^exp
	movel	%sp@+,d1
	fmods	#0e2,%fp1		| exp mod 2 -> odd/even
	fbeq	3f
	bset	#31,d0			| odd -> negate
3:	rts

Lzero:
	moveq	#0,d0			| shipped: jumps into the
	rts				|  reserved (moveq#0/rts) vector

|||	double IEEEDPSqrt(d0/d1 parm)
_IEEEDPSqrt:
	moveml	d0-d1,%sp@-
	fsqrtd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	float IEEEDPTieee(d0/d1 parm) -- double -> IEEE single in d0
_IEEEDPTieee:
	moveml	d0-d1,%sp@-
	fmoved	%sp@+,%fp0
	fmoves	%fp0,d0
	rts

|||	double IEEEDPFieee(d0 parm) -- arg converted via fmove.l
|||	(shipped behaviour: loads d0 as LONG integer, not a float)
_IEEEDPFieee:
	fmovel	d0,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPAsin(d0/d1 parm)
_IEEEDPAsin:
	moveml	d0-d1,%sp@-
	fasind	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPAcos(d0/d1 parm)
_IEEEDPAcos:
	moveml	d0-d1,%sp@-
	facosd	%sp@+,%fp0
	fmoved	%fp0,%sp@-
	movel	%sp@+,d0
	movel	%sp@+,d1
	rts

|||	double IEEEDPLog10(d0/d1 parm)
_IEEEDPLog10:
	moveml	d0-d1,%sp@-
	flog10d	%sp@+,%fp0
	fmoved	%fp0,%sp@-
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
