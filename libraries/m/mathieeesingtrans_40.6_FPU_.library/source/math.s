|||
|||	math.s -- 68881/68882 vector bodies for
|||	mathieeesingtrans.library 40.6 "for 68881/82".
|||
|||	Each public vector is a single FPU instruction followed by
|||	"fmoves fp0,d0; rts": the argument arrives in d0 (IEEE
|||	single) and the result leaves in d0.
|||
|||	IEEESPSincos returns sin in d0 and stores cos through the
|||	cosptr in a0.  IEEESPPow is a real routine: it computes
|||	exp(y*ln|x|) and restores the sign when x<0 and y is an odd
|||	integer; non-integer y with x<0 branches to the module entry
|||	(moveq #0,d0; rts) -- returns 0.0.
|||
|||	IEEESPTieee/IEEESPFieee are identity conversions in this
|||	IEEE-native build: both vectors point at a bare rts.
|||

	.section .text

	.globl	_IEEESPAtan
_IEEESPAtan:
	fatans	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPSin
_IEEESPSin:
	fsins	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPCos
_IEEESPCos:
	fcoss	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPTan
_IEEESPTan:
	ftans	d0,fp0
	fmoves	fp0,d0
	rts

||| sin in d0, cos stored through cosptr (a0)
	.globl	_IEEESPSincos
_IEEESPSincos:
	fsincoss d0,fp1:fp0		| fp1 = cos, fp0 = sin
	fmoves	fp0,d0			| return sin
	fmoves	fp1,a0@			| *cosptr = cos
	rts

	.globl	_IEEESPSinh
_IEEESPSinh:
	fsinhs	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPCosh
_IEEESPCosh:
	fcoshs	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPTanh
_IEEESPTanh:
	ftanhs	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPExp
_IEEESPExp:
	fetoxs	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPLog
_IEEESPLog:
	flogns	d0,fp0
	fmoves	fp0,d0
	rts

||| pow(x,y): exp(y*ln|x|), sign fixup for odd integer y when x<0.
||| The fbeq/fbne encodings are word-displacement branches, like
||| the original (f281/f28e forms).
	.globl	_IEEESPPow
_IEEESPPow:
	tst.l	d0
	bpl.s	_powcore		| x>0: straight exp(y*ln x)
	bclr	#31,d0			| x = |x|
	fints	d1,fp0			| fp0 = int(y)
	fsubs	d1,fp0			| fp0 = int(y)-y
	fbne	_libentry		| non-integer y -> return 0.0
	bsr.s	_powcore		| d0 = |x|^y
	fmoves	d1,fp0
	.word	0xf23c,0x4421		| fmods #2.0,fp0 (gas can't spell the
	.word	0x4000,0x0000		|  immediate -- emitted verbatim)
	fbeq	_powdone		| y even -> keep positive
	bset	#31,d0			| y odd  -> restore sign
_powdone:
	rts

_powcore:
	flogns	d0,fp0			| ln |x|
	fmuls	d1,fp0			| y*ln|x|
	fetoxx	fp0,fp0			| exp(...)
	fmoves	fp0,d0
	rts

	.globl	_IEEESPSqrt
_IEEESPSqrt:
	fsqrts	d0,fp0
	fmoves	fp0,d0
	rts

||| shared no-op: IEEESPTieee and IEEESPFieee (identity in an
||| IEEE-native build) point here -- and at the tail rts of the
||| previous vector in the original; same effect.
	.globl	_MathNull
_MathNull:
	rts

	.globl	_IEEESPAsin
_IEEESPAsin:
	fasins	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPAcos
_IEEESPAcos:
	facoss	d0,fp0
	fmoves	fp0,d0
	rts

	.globl	_IEEESPLog10
_IEEESPLog10:
	flog10s	d0,fp0
	fmoves	fp0,d0
	rts
