||||
||||	math.s -- 68881/68882 vector bodies for
||||	mathtrans.library 40.6 "for 68881/82".
||||
||||	The SP* API is FFP format (Amiga fast floating
||||	point): a 32-bit value in d0 laid out as
||||	  [31:9]  mantissa, binary point left of bit31,
||||	          leading 1 explicit (m in [0.5,1.0))
||||	  [8]     sign bit
||||	  [7:0]   exponent, biased 64:
||||	          value = sign * (m/2^24) * 2^(e-64)
||||	Every vector converts FFP -> IEEE single (d0),
||||	runs one 68881 single-precision operation, then
||||	converts IEEE -> FFP back into d0.  The two
||||	converters are also public vectors: SPTieee is
||||	the FFP->IEEE routine, SPFieee the IEEE->FFP one.
||||
||||	Code order mirrors the shipped binary: the SPPow
||||	negative-x tail and error exit sit between Expunge
||||	and SPPow, SPTieee sits between SPSincos and
||||	SPSinh, and SPFieee closes the module.
||||

	.section .text

|||| ---------------------------------------------------------
|||| error exit for SPPow: return FFP 0 through the output
|||| converter (d0 = 0 converts to FFP 0).
||||

_pow_err:
	moveq	#0,d0
	bra.w	_SPFieee

	.word	0			| pad (as shipped)

|||| ---------------------------------------------------------
|||| negative-x path of SPPow (reached by the bmi in _SPPow).
|||| d1 still holds the FFP power, d0 holds IEEE x < 0.
||||

_pow_neg:
	bclr	#31,d0			| |x|  (IEEE sign bit)
	exg	d0,d1			| d0 = y (FFP), d1 = |x| (IEEE)
	bsr.w	_SPTieee			| d0 = IEEE y
	fints	d0,fp0			| fp0 = int(y)
	fsubs	d0,fp0			| fp0 = int(y) - y
	fbne	_pow_err			| non-integral y -> FFP 0
	flogns	d1,fp0			| fp0 = ln|x|
	fmuls	d0,fp0			| fp0 = y * ln|x|
	fetoxx	fp0,fp0			| fp0 = |x|^y
	move.l	d0,d1			| d1 = IEEE y
	fmoves	fp0,d0			| d0 = IEEE result
	fmoves	d1,fp0			| fp0 = y
	fmods	#0x40000000,fp0		| fp0 = fmod(y, 2.0)
	fbeq	_pow_done			| even -> keep result
	bset	#31,d0			| odd  -> negate result
_pow_done:
	bra.w	_SPFieee			| IEEE -> FFP, rts

|||| ---------------------------------------------------------
|||| SPPow (LVO -90): d0 = arg, d1 = power -> d0 = arg^power
|||| exp(y*ln(x)) for x > 0; the |x|^y-with-parity path above
|||| for x < 0.
||||

	.globl	_SPPow
_SPPow:
	bsr.s	_SPTieee			| d0 = IEEE x
	bmi.s	_pow_neg			| x < 0 -> |x| path
	flogns	d0,fp0			| fp0 = ln x
	move.l	d1,d0			| d0 = y (FFP)
	bsr.s	_SPTieee			| d0 = IEEE y
	fmuls	d0,fp0			| fp0 = y * ln x
	fetoxx	fp0,fp0			| fp0 = x^y
	bra.w	_conv_out			| fmoves + IEEE -> FFP

|||| ---------------------------------------------------------
|||| single-argument wrappers: convert, one FPU op, convert back
||||

	.globl	_SPAtan
_SPAtan:
	bsr.s	_SPTieee
	fatans	d0,fp0
	bra.w	_conv_out

	.globl	_SPSin
_SPSin:
	bsr.s	_SPTieee
	fsins	d0,fp0
	bra.w	_conv_out

	.globl	_SPCos
_SPCos:
	bsr.s	_SPTieee
	fcoss	d0,fp0
	bra.s	_conv_out

	.globl	_SPTan
_SPTan:
	bsr.s	_SPTieee
	ftans	d0,fp0
	bra.s	_conv_out

	.globl	_SPSincos
_SPSincos:
	bsr.s	_SPTieee
	movea.l	d1,a0			| cosResult pointer
	fsincoss d0,fp0:fp1		| fp0 = cos, fp1 = sin
	fmoves	fp0,d0			| d0 = IEEE cos
	bsr.s	_SPFieee			| d0 = FFP cos
	move.l	d0,a0@			| *cosResult = FFP cos
	fmoves	fp1,d0			| d0 = IEEE sin
	bra.s	_SPFieee			| d0 = FFP sin, rts

|||| ---------------------------------------------------------
|||| SPTieee (LVO -102): FFP d0 -> IEEE single d0.
|||| add.l doubles the FFP exp byte into the top byte (the
|||| leading mantissa 1 and the carry land in X/C); the byte
|||| ops re-bias it to the IEEE exponent; swap+rol7 parks
|||| everything into IEEE field positions.  FFP 0 -> IEEE 0.
||||

	.globl	_SPTieee
_SPTieee:
	add.l	d0,d0
	beq.s	_tie_out
	eori.b	#0x80,d0
	asr.b	#1,d0
	subi.b	#0x82,d0
	swap	d0
	rol.l	#7,d0
_tie_out:
	rts

|||| ---------------------------------------------------------
|||| remaining single-argument wrappers
||||

	.globl	_SPSinh
_SPSinh:
	bsr.s	_SPTieee
	fsinhs	d0,fp0
	bra.s	_conv_out

	.globl	_SPCosh
_SPCosh:
	bsr.s	_SPTieee
	fcoshs	d0,fp0
	bra.s	_conv_out

	.globl	_SPTanh
_SPTanh:
	bsr.s	_SPTieee
	ftanhs	d0,fp0
	bra.s	_conv_out

	.globl	_SPExp
_SPExp:
	bsr.s	_SPTieee
	fetoxs	d0,fp0
	bra.s	_conv_out

	.globl	_SPLog
_SPLog:
	bsr.s	_SPTieee
	flogns	d0,fp0
	bra.s	_conv_out

	.globl	_SPSqrt
_SPSqrt:
	bsr.s	_SPTieee
	fsqrts	d0,fp0
	bra.s	_conv_out

	.globl	_SPAsin
_SPAsin:
	bsr.s	_SPTieee
	fasins	d0,fp0
	bra.s	_conv_out

	.globl	_SPAcos
_SPAcos:
	bsr.s	_SPTieee
	facoss	d0,fp0
	bra.s	_conv_out

	.globl	_SPLog10
_SPLog10:
	bsr.s	_SPTieee
	flog10s	d0,fp0
|||| falls through into _conv_out (as shipped)

|||| ---------------------------------------------------------
|||| _conv_out: shared tail -- pull the IEEE single result out
|||| of fp0 and run the IEEE->FFP converter (SPFieee).
||||

_conv_out:
	fmoves	fp0,d0

|||| ---------------------------------------------------------
|||| SPFieee (LVO -108): IEEE single d0 -> FFP d0.
|||| IEEE is sign[31] | exp8+127 | mantissa23;
|||| FFP is mantissa23[31:9] | sign[8] | exp8-64.
|||| swap+ror7 moves exp to byte0, sign to bit8, mantissa to
|||| [31:9]; the byte ops re-bias the exponent.
|||| Edge cases: bvs on the doubled exponent byte clamps to
|||| FFP 0 (underflow) or to a 0xFFFFFFFF-style error pattern
|||| returned with V set.
||||

	.globl	_SPFieee
_SPFieee:
	swap	d0
	ror.l	#7,d0
	eori.b	#0x80,d0
	add.b	d0,d0
	bvs.s	_fie_case1
	addq.b	#5,d0
	bvs.s	_fie_case2
	eori.b	#0x80,d0
	ror.l	#1,d0
	rts
_fie_case1:
	bls.s	_fie_case1b
	cmpi.b	#0x7c,d0
	beq.s	_fie_case1a
	cmpi.b	#0x7e,d0
	bne.s	_fie_case1c
_fie_case1a:
	addi.b	#0x85,d0
	ror.l	#1,d0
	tst.b	d0
	bne.s	_fie_out
	moveq	#0,d0
	rts
_fie_case1c:
	andi.w	#0xfeff,d0
	tst.l	d0
	beq.s	_fie_out
	moveq	#0,d0
	rts
_fie_case1b:
	cmpi.b	#0xfe,d0
	bne.s	_fie_case2
	moveq	#9,d1
	lsr.l	d1,d0
	beq.s	_fie_case2b
	moveq	#0,d0
	rts
_fie_case2:
	lsl.w	#8,d0
_fie_case2b:
	moveq	#-1,d0
	roxr.b	#1,d0
	ori.b	#2,ccr
_fie_out:
	rts
