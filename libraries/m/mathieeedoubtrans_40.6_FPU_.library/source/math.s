|||
|||	math.s -- 68881/68882 vector bodies for
|||	mathieeedoubtrans.library 40.6 "for 68881/82".
|||
|||	Arguments arrive as IEEE doubles split across d0/d1
|||	(d0 = sign/exp+high mantissa, d1 = low mantissa) and
|||	results leave the same way.  Every monadic stub pushes
|||	the operand, runs one 68881 double-precision operation
|||	on the stack image, and pops the result back.
|||
|||	IEEEDPSincos returns sin in d0/d1 and stores cos at a0@
|||	(fsincos loads COS into the FIRST listed register, SIN
|||	into the second: fp1 = cos, fp0 = sin).
|||
|||	IEEEDPPow is the only non-trivial routine: x^y =
|||	e^(y*log(x)) with the negative-x sign logic factored
|||	out front; the shared exponentiation core saves FPCR,
|||	forces round-to-nearest and restores it.

	.section .text

||| ---------------------------------------------------------
||| monadic stubs: push d0:d1, fXXXd sp@ -> fp0, store double.

.macro	DSTUB	name, op
	.globl	\name
\name:
	moveml	d0-d1,-(sp)
	\op	sp@,fp0
	fmoved	fp0,sp@
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.word	0			| pad, as shipped
.endm

	DSTUB	_IEEEDPAtan,	fatand
	DSTUB	_IEEEDPSin,	fsind
	DSTUB	_IEEEDPCos,	fcosd
	DSTUB	_IEEEDPTan,	ftand

||| IEEEDPSincos (LVO -54): sin -> d0:d1, cos -> a0@.
||| fsincos src,FPc:FPs -> fp1 = cos, fp0 = sin.

	.globl	_IEEEDPSincos
_IEEEDPSincos:
	moveml	d0-d1,-(sp)
	fsincosd sp@,fp1:fp0
	fmoved	fp0,sp@			| sin on stack
	movel	sp@+,d0
	movel	sp@+,d1
	fmoved	fp1,a0@			| cos -> *cosptr
	rts
	.word	0			| pad, as shipped

	DSTUB	_IEEEDPSinh,	fsinhd
	DSTUB	_IEEEDPCosh,	fcoshd
	DSTUB	_IEEEDPTanh,	ftanhd
	DSTUB	_IEEEDPExp,	fetoxd
	DSTUB	_IEEEDPLog,	flognd

||| ---------------------------------------------------------
||| IEEEDPPow (LVO -90): x^y = e^(y*log x).
||| x < 0: integer y -> pow(|x|,y) re-negated for odd y;
|||        non-integer y -> 0 (shipped semantic, not NaN).
||| The y-mod-2 test recovers y from the stack by popping the
||| saved d2/d3 straight into fp0 with fmoved sp@+ -- the same
||| instruction restores the stack pointer.

	.globl	_IEEEDPPow
_IEEEDPPow:
	tstl	d0
	bpls	_pow_core		| x >= 0: direct
	bclr	#31,d0			| |x|
	moveml	d2-d3,-(sp)		| save y
	fintd	sp@,fp0			| trunc(y)
	fsubd	sp@,fp0			| trunc(y) - y
	fbne	_pow_zero		| non-integer y -> 0
	bsrs	_pow_core		| pow(|x|,y) -> d0:d1
	fmoved	sp@+,fp0		| recover y (and drop saves)
	fmodd	#0x4000000000000000,fp0	| y mod 2
	fbeq	_pow_ret
	bset	#31,d0			| odd y -> re-negate result
_pow_ret:
	rts
_pow_zero:
	addqw	#8,sp			| drop saved y
	moveq	#0,d0
	moveq	#0,d1
	rts

_pow_core:
	moveml	d0-d3,-(sp)		| [x, y]
	fmovel	fpcr,d0
	movel	d0,d1			| save FPCR
	clrb	d0			| rounding -> nearest
	fmovel	d0,fpcr
	flognd	sp@+,fp0		| log(x), drops x
	fmuld	sp@,fp0			| y*log(x)
	fetoxx	fp0,fp0			| e^(y*log x)
	fmoved	fp0,sp@			| result over the y slot
	fmovel	d1,fpcr			| restore FPCR
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.word	0			| pad, as shipped

	DSTUB	_IEEEDPSqrt,	fsqrtd

||| ---------------------------------------------------------
||| IEEEDPTieee (LVO -102): double d0:d1 -> single d0.
||| Push, reload as double, demote to single.

	.globl	_IEEEDPTieee
_IEEEDPTieee:
	moveml	d0-d1,-(sp)
	fmoved	sp@+,fp0
	fmoves	fp0,d0
	rts
	.word	0			| pad, as shipped

||| ---------------------------------------------------------
||| IEEEDPFieee (LVO -108): single d0 -> double d0:d1.

	.globl	_IEEEDPFieee
_IEEEDPFieee:
	fmoves	d0,fp0
	fmoved	fp0,sp@-
	movel	sp@+,d0
	movel	sp@+,d1
	rts
	.word	0			| pad, as shipped

	DSTUB	_IEEEDPAsin,	fasind
	DSTUB	_IEEEDPAcos,	facosd
	DSTUB	_IEEEDPLog10,	flog10d

	.end
