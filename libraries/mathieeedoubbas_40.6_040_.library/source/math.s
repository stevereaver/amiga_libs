|||
|||	math.s -- 68040 build vector bodies (68881 opcodes, some trapped by FPSP) for
|||	mathieeedoubbas.library 40.6 "for 68040".
|||
|||	Arguments arrive as IEEE doubles split across d0/d1
|||	(d0 = sign/exp+high mantissa, d1 = low mantissa) and
|||	results leave the same way.  The routines move values
|||	through the stack: push the operand(s), fmove into fp0,
|||	operate, fmoved fp0,(sp) and pop into d0/d1.
|||
|||	IEEEDPCmp and IEEEDPTst are pure integer code (cmp.s).
|||

	.section .text

||| IEEEDPFix (LVO -30): double d0/d1 -> longword d0.
||| fmove.l fp0,d0 converts using the CURRENT FPCR rounding
||| mode -- with the default round-to-nearest this is not the
||| classic trunc-toward-zero IEEEDPFix semantics.

	.globl	_IEEEDPFix
_IEEEDPFix:
	movem.l	d0-d1,-(sp)
	fmoved	sp@+,fp0		| fp0 = arg, stack restored
	fmovel	fp0,d0			| convert to long (FPCR mode)
	rts

||| IEEEDPFlt (LVO -36): longword d0 -> double d0/d1.

	.globl	_IEEEDPFlt
_IEEEDPFlt:
	fmovel	d0,fp0			| long -> fp0
	fmoved	fp0,sp@-		| push as double
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPAdd (LVO -66): d0/d1 + d2/d3 -> d0/d1.
||| Both operands pushed in one movem; fmoved sp@+ consumes
||| the left operand, right stays for the fop.

	.globl	_IEEEDPAdd
_IEEEDPAdd:
	movem.l	d0-d3,-(sp)
	fmoved	sp@+,fp0		| fp0 = left
	faddd	sp@,fp0			| + right
	fmoved	fp0,sp@			| store over right
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPSub (LVO -72): d0/d1 - d2/d3 -> d0/d1.
||| Left pushed and consumed first, right pushed after.

	.globl	_IEEEDPSub
_IEEEDPSub:
	movem.l	d0-d1,-(sp)
	fmoved	sp@+,fp0		| fp0 = left
	movem.l	d2-d3,-(sp)
	fsubd	sp@,fp0			| - right
	fmoved	fp0,sp@
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPMul (LVO -78): d0/d1 * d2/d3 -> d0/d1.

	.globl	_IEEEDPMul
_IEEEDPMul:
	movem.l	d0-d3,-(sp)
	fmoved	sp@+,fp0
	fmuld	sp@,fp0
	fmoved	fp0,sp@
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPDiv (LVO -84): d0/d1 / d2/d3 -> d0/d1.

	.globl	_IEEEDPDiv
_IEEEDPDiv:
	movem.l	d0-d1,-(sp)
	fmoved	sp@+,fp0		| fp0 = dividend
	movem.l	d2-d3,-(sp)
	fdivd	sp@,fp0			| / divisor
	fmoved	fp0,sp@
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPFloor (LVO -90): largest integer <= x.
||| x >= 0: plain fintrz (truncate).  x < 0: switch FPCR to
||| round-toward-minus-infinity (0x20), fint, restore FPCR.

	.globl	_IEEEDPFloor
_IEEEDPFloor:
	tst.l	d0
	blt.s	_floorneg
	movem.l	d0-d1,-(sp)
	fintrzd	sp@,fp0			| trunc == floor for x >= 0
	fmoved	fp0,sp@
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts
_floorneg:
	movem.l	d0-d1,-(sp)
	fmoved	sp@,fp0			| fp0 = x
	fmovel	fpcr,d0			| save FPCR
	move.l	d0,d1
	move.b	#0x20,d0		| rounding mode -> -inf
	fmovel	d0,fpcr
	fintx	fp0,fp0			| floor(x)
	fmovel	d1,fpcr			| restore FPCR
	fmoved	fp0,sp@
	move.l	sp@+,d0
	move.l	sp@+,d1
	rts

||| IEEEDPCeil (LVO -96): ceil(x) = -floor(-x); the sign is
||| not restored when the result is zero so +0 never becomes -0.

	.globl	_IEEEDPCeil
_IEEEDPCeil:
	bchg	#31,d0			| -x
	bsr.s	_IEEEDPFloor
	tst.l	d0
	bne.s	_ceilflip
	tst.l	d1
	beq.s	_ceildone		| result is +0: leave alone
_ceilflip:
	bchg	#31,d0			| restore sign
_ceildone:
	rts
