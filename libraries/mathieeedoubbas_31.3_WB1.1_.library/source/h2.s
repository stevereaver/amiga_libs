/*
 * mathieeedoubbas.library 31.3 (WB1.1) -- hunk 2: IEEE-double FP core.
 *
 * Byte-identical transcription.  The identical 1172-byte core is also
 * shipped verbatim inside mathieeedoubbas 33.9 (WB1.2).  Callers in
 * hunk 1 do `jsr _core` with a sub-op selector word inlined after the
 * jsr; the core picks it up through the stacked return address, masks
 * the low 5 bits, and dispatches via the 15-entry braw table at +0x1a.
 *
 * Selectors: ff08=_add ff09=_sub ff0a=_mul ff0b=_div
 *            ff0c=_neg ff0d=_cmp ff0e=_tst
 * Table slots 0-7 and 15 hit the dead tail at 0x48e (sets d1=224 and
 * falls off the end of the hunk -- preserved as shipped).
 *
 * Interface: a0 = dest double*, a1 = src double* for binary ops.
 */

	.text
	.globl	_core

/* ==== 0x000 dispatcher =========================================== */
_core:
	moveml	%d0/%d3/%d5/%a0,%sp@-
	moveal	%sp@(16),%a0		/* return addr -> selector word */
	movew	%a0@+,%d0
	movel	%a0,%sp@(16)		/* return past the selector */
	andil	#31,%d0
	asll	#2,%d0
	.short	0x4efb,0x0002		/* jmp pc@(0x1a,d0:w) */
/* 0x01a: 15-entry braw dispatch table */
	braw	_err			/* 0..7: unused -> dead tail */
	braw	_err
	braw	_err
	braw	_err
	braw	_err
	braw	_err
	braw	_err
	braw	_err
	braw	_add			/* 8  (ff08) */
	braw	_sub			/* 9  (ff09) */
	braw	_mul			/* 10 (ff0a) */
	braw	_div			/* 11 (ff0b) */
	braw	_neg			/* 12 (ff0c) */
	braw	_cmp			/* 13 (ff0d) */
	braw	_tst			/* 14 (ff0e) */
	braw	_err			/* 15 */

/* ==== 0x05a sub: *a0 = *a0 - *a1 ================================== */
_sub:
	moveml	%d1-%d2/%d4/%d6-%d7/%a1,%sp@-
	moveal	%d1,%a0
	moveal	%d2,%a1
	movel	%a1@,%d3
	bchg	#31,%d3
	braw	1f
/* ==== 0x06c add: *a0 = *a0 + *a1 ================================== */
_add:
	moveml	%d1-%d2/%d4/%d6-%d7/%a1,%sp@-
	moveal	%d1,%a0
	moveal	%d2,%a1
	movel	%a1@,%d3
1:	movel	%a0@,%d1
	movel	%d1,%d2
	movel	%d3,%d4
	movel	#0x7ff00000,%d7
	andl	%d7,%d4
	beqw	_add_ret		/* src exp==0 -> keep dest */
	andl	%d7,%d2
	bnes	2f
	movel	%d3,%a0@		/* dest exp==0 -> dest = src */
	movel	%a1@(4),%a0@(4)
	braw	_add_ret
2:	moveml	%d2/%d4,%sp@-
	notl	%d7
	bclr	#31,%d1
	sne	%d5
	bclr	#31,%d3
	sne	%d6
	andl	%d7,%d1
	andl	%d7,%d3
	bset	#20,%d1			/* hidden bits */
	bset	#20,%d3
	movel	%a0@(4),%d2
	movel	%a1@(4),%d4
	moveq	#0,%d7
	tstb	%d5
	beqs	3f
	notl	%d2			/* dest negative: 2's comp */
	notl	%d1
	addql	#1,%d2
	addxl	%d7,%d1
3:	tstb	%d6
	beqs	4f
	notl	%d4			/* src negative: 2's comp */
	notl	%d3
	addql	#1,%d4
	addxl	%d7,%d3
4:	moveml	%sp@+,%d5-%d6
	movel	%d5,%d0			/* d0 = exp diff (biased x16) */
	subl	%d6,%d0
	beqs	8f
	moveq	#20,%d7
	asrl	%d7,%d0
	bgts	5f
	exg	%d1,%d3			/* swap so dest is larger */
	exg	%d2,%d4
	negl	%d0
	movel	%d6,%d5
5:	cmpil	#53,%d0
	blts	7f
	tstl	%d1			/* diff>53: src shifted away */
	blts	6f
	moveq	#0,%d0
	bras	10f
6:	movel	#0x80000000,%d0		/* sticky: -inf rounding */
	moveq	#0,%d7
	notl	%d1
	notl	%d2
	addil	#1,%d2
	addxl	%d7,%d1
	bras	10f
7:	subql	#1,%d0			/* denormal-align src down */
_shftl:	asrl	#1,%d3
	roxrl	#1,%d4
	dbf	%d0,_shftl
	moveq	#0,%d0
	addxl	%d0,%d4
	addxl	%d0,%d3
8:	moveq	#0,%d7
	addl	%d4,%d2			/* 53-bit add */
	addxl	%d3,%d1
	beqw	_add_zero
	blts	9f
	moveq	#0,%d0
	bras	11f
9:	movel	#0x80000000,%d0		/* negative sum: sign-mag */
	notl	%d2
	notl	%d1
	addql	#1,%d2
	addxl	%d7,%d1
11:	movel	#0x200000,%d3
	movel	#0x100000,%d4
	cmpl	%d3,%d1
	blts	13f
	addl	%d4,%d5			/* carry: exp++, shift down */
	lsrl	#1,%d1
	roxrl	#1,%d2
	addxl	%d7,%d2
	addxl	%d7,%d1
	cmpl	%d3,%d1
	blts	10f
	addl	%d4,%d5
	lsrl	#1,%d1
	roxrl	#1,%d2
	bras	10f
13:	cmpl	%d4,%d1			/* normalize up */
	bges	10f
	subl	%d4,%d5
	lsll	#1,%d2
	roxll	#1,%d1
	bras	13b
10:	tstl	%d5			/* exp <= 0 -> underflow */
	bles	14f
	bclr	#20,%d1
	orl	%d5,%d1			/* exp back in */
	orl	%d0,%d1			/* sign */
	movel	%d1,%a0@
	movel	%d2,%a0@(4)
_add_ret:
	tstl	%a0@			/* ccr on result */
_add_pop:
	moveml	%sp@+,%d1-%d2/%d4/%d6-%d7/%a1
	braw	_done
_add_zero:
	clrl	%a0@
	clrl	%a0@(4)
	bras	_add_pop
14:	cmpil	#0xc0100000,%d5
	bges	_add_zero
	movel	#0x7fffffff,%d1		/* overflow -> +/-inf */
	moveq	#-1,%d2
	orl	%d0,%d1
	movel	%d1,%a0@
	movel	%d2,%a0@(4)
	movew	#3,%ccr
	bras	_add_pop		/* ccr already set: skip tstl a0@ */

/* ==== 0x1b8 mul: *a0 = *a0 * *a1 ================================== */
_mul:
	moveml	%d1-%d2/%d4/%d6-%d7/%a1,%sp@-
	moveal	%d1,%a0
	moveal	%d2,%a1
	movel	%a0@,%d1
	movel	%d1,%d2
	bclr	#31,%d1
	sne	%d0
	movel	%a1@,%d3
	movel	%d3,%d4
	bclr	#31,%d3
	sne	%d5
	movel	#0x7ff00000,%d6
	andl	%d6,%d2
	beqw	_mul_zero		/* dest exp==0 -> 0 */
	andl	%d6,%d4
	beqw	_mul_zero		/* src exp==0 -> 0 */
	notl	%d6
	andl	%d6,%d1
	andl	%d6,%d3
	addl	%d2,%d4			/* exponents add */
	eorb	%d5,%d0			/* signs xor */
	lsrb	#1,%d0
	roxlb	#1,%d4			/* sign -> d4 bit0 */
	movel	%d4,%sp@-		/* stash exp|sign */
	bset	#20,%d1			/* hidden bits */
	bset	#20,%d3
	movel	%a0@(4),%d2
	movel	%a1@(4),%d4
	.short	0x2a3c			/* movel #10,d5 (orig uses long form) */
	.long	10
1:	lsll	#1,%d2			/* mantissas << 11 */
	roxll	#1,%d1
	lsll	#1,%d4
	roxll	#1,%d3
	dbf	%d5,1b
	clrl	%a0@			/* 106-bit product -> a0[0..10] */
	clrl	%a0@(4)
	moveq	#0,%d7
	moveq	#0,%d5
	swap	%d1			/* 16x16 partial products */
	movew	%d4,%d6
	muluw	%d1,%d6
	clrw	%d6
	swap	%d6
	swap	%d3
	movew	%d2,%d0
	muluw	%d3,%d0
	clrw	%d0
	swap	%d0
	addl	%d0,%d6
	swap	%d1
	swap	%d4
	movew	%d4,%d0
	muluw	%d1,%d0
	clrw	%d0
	swap	%d0
	addl	%d0,%d6
	swap	%d2
	swap	%d3
	movew	%d3,%d0
	muluw	%d2,%d0
	clrw	%d0
	swap	%d0
	addl	%d0,%d6
	movew	%d3,%d0
	muluw	%d1,%d0
	addl	%d0,%d6
	addxw	%d7,%d5
	swap	%d1
	movew	%d4,%d0
	muluw	%d1,%d0
	addl	%d0,%d6
	addxw	%d7,%d5
	swap	%d3
	movew	%d2,%d0
	muluw	%d3,%d0
	addl	%d0,%d6
	addxw	%d7,%d5
	movew	%d6,%a0@(6)
	movew	%d5,%d6
	swap	%d6
	clrw	%d5
	swap	%d3
	movew	%d3,%d0
	muluw	%d1,%d0
	addl	%d0,%d6
	addxw	%d7,%d5
	swap	%d3
	swap	%d1
	movew	%d3,%d0
	muluw	%d1,%d0
	addl	%d0,%d6
	addxw	%d7,%d5
	movew	%d6,%a0@(4)
	movew	%d5,%d6
	swap	%d6
	swap	%d1
	muluw	%d3,%d1
	addl	%d1,%d6
	movel	%a0@(4),%d5
	movel	%sp@+,%d0		/* exp|sign back */
	moveq	#0,%d4
	lsrb	#1,%d0
	roxrl	#1,%d4
	movel	#-1023,%d2		/* unbias */
	.short	0x223c			/* movel #9,d1 (orig uses long form) */
	.long	9
2:	lsrl	#1,%d6			/* product >> 10 */
	roxrl	#1,%d5
	dbf	%d1,2b
	cmpil	#0x200000,%d6		/* normalize */
	blts	3f
	addql	#1,%d2
	lsrl	#1,%d6
	roxrl	#1,%d5
3:	moveq	#0,%d1			/* round (sticky shift) */
	addxl	%d1,%d5
	addxl	%d1,%d6
	cmpil	#0x200000,%d6
	blts	4f
	addql	#1,%d2
	lsrl	#1,%d6
	roxrl	#1,%d5
4:	bclr	#20,%d6			/* drop hidden bit */
	.short	0x263c			/* movel #20,d3 (orig uses long form) */
	.long	20
	lsll	%d3,%d2
	addl	%d2,%d0			/* rebias */
	bmis	6f
	beqs	6f
	orl	%d0,%d6
	orl	%d4,%d6
	movel	%d6,%a0@
	movel	%d5,%a0@(4)
	tstl	%a0@
_mul_pop:
	moveml	%sp@+,%d1-%d2/%d4/%d6-%d7/%a1
	braw	_done
_mul_zero:
	clrl	%a0@
	clrl	%a0@(4)
	bras	_mul_pop
6:	cmpil	#0xc0100000,%d0		/* under/overflow */
	bges	_mul_zero
	movel	#0x7fffffff,%d6		/* -> inf */
	orl	%d4,%d6
	movel	%d6,%a0@
	movel	#-1,%a0@(4)
	movew	#3,%ccr
	bras	_mul_pop

/* ==== 0x32e div: *a0 = *a0 / *a1 ================================== */
_div:
	moveml	%d1-%d2/%d4/%d6-%d7/%a1,%sp@-
	moveal	%d1,%a0
	moveal	%d2,%a1
	moveml	%a0@,%d1-%d2		/* dest d1:d2 */
	moveml	%a1@,%d3-%d4		/* src  d3:d4 */
	movel	%d1,%d7
	movel	%d3,%d6
	movel	#0x7ff00000,%d5
	movel	%d1,%d0
	andl	%d5,%d6
	beqw	_div_divzero		/* divisor exp==0 */
	andl	%d5,%d7
	beqw	_div_zero		/* dividend exp==0 -> 0 */
	subl	%d6,%d7			/* exponent diff + rebias */
	addil	#0x3ff00000,%d7
	eorl	%d3,%d0			/* sign */
	lsll	#1,%d0
	roxlb	#1,%d7
	movel	%d7,%d0
	notl	%d5
	bclr	#31,%d5
	andl	%d5,%d1
	bset	#20,%d1
	andl	%d5,%d3
	bset	#20,%d3
	moveq	#0,%d5			/* quotient lo */
	moveq	#0,%d6			/* quotient hi */
	moveq	#54,%d7			/* 55 iterations */
1:	subl	%d4,%d2			/* remainder - divisor */
	subxl	%d3,%d1
	blts	2f			/* borrow -> q bit 0 path */
/* 0x384: quotient bit 1 */
	addl	%d6,%d6			/* q<<1 */
	addxl	%d5,%d5
	addl	%d2,%d2			/* r<<1 */
	addxl	%d1,%d1
	bset	#0,%d6
	dbf	%d7,1b
	bras	3f
4:	addl	%d4,%d2			/* restore remainder (non-restoring) */
	addxl	%d3,%d1
	bgts	1b+6			/* went positive -> quotient bit 1 path */
2:	addl	%d6,%d6			/* q<<1, bit 0 */
	addxl	%d5,%d5
	addl	%d2,%d2
	addxl	%d1,%d1
	dbf	%d7,4b
3:	cmpil	#0x400000,%d5		/* normalize quotient */
	blts	4f
	lsrl	#1,%d5
	roxrl	#1,%d6
	bras	5f
4:	subil	#0x100000,%d0
5:	lsrl	#1,%d5
	roxrl	#1,%d6
	moveq	#0,%d7			/* round: sticky add */
	addxl	%d7,%d6
	addxl	%d7,%d5
	cmpil	#0x200000,%d5
	blts	6f
	addil	#0x100000,%d0
	lsrl	#1,%d5
	roxrl	#1,%d6
6:	exg	%d0,%d7
	lsrb	#1,%d7
	roxrl	#1,%d0
	tstl	%d7
	bles	8f
	bclr	#20,%d5
	orl	%d7,%d5
	orl	%d0,%d5
_div_store:
	moveml	%d5-%d6,%a0@
	moveml	%sp@+,%d1-%d2/%d4/%d6-%d7/%a1
	braw	_done
_div_zero:
	moveq	#0,%d5
	moveq	#0,%d6
	bras	_div_store
_div_divzero:
	movew	#7,%d3			/* x/0 -> inf, ccr=7 */
	bras	9f
8:	cmpil	#0xc0100000,%d7
	bges	_div_zero
	movew	#3,%d3			/* overflow -> inf, ccr=3 */
9:	movel	#0x7fffffff,%d5
	moveq	#-1,%d6
	orl	%d0,%d5
	movew	%d3,%ccr
	bras	_div_store

/* ==== 0x41c neg: flip sign of *a1 in place ======================== */
_neg:
	moveal	%d1,%a0
	movew	%a0@,%d0
	andiw	#0x7ff0,%d0
	beqs	1f
	eorib	#0x80,%a0@
1:	braw	_done

/* ==== 0x42e cmp: compare *a0 vs *a1 -> ccr ======================== */
_cmp:
	moveml	%d4/%d6,%sp@-
	moveal	%d1,%a0
	moveml	%a0@,%d5-%d6
	movel	%d5,%d0
	andil	#0x7ff00000,%d0
	bnes	1f
	moveq	#0,%d5			/* canonicalize -0 */
	moveq	#0,%d6
1:	moveal	%d2,%a0
	moveml	%a0@,%d3-%d4
	movel	%d3,%d0
	andil	#0x7ff00000,%d0
	bnes	2f
	moveq	#0,%d3
	moveq	#0,%d4
2:	movel	%d3,%d0
	andl	%d5,%d0
	bpls	3f
	exg	%d3,%d5			/* both negative: flip order */
	exg	%d4,%d6
3:	cmpl	%d3,%d5
	bnes	4f
	cmpl	%d4,%d6
	beqs	4f
	scs	%d0
	andib	#8,%d0
	movew	%d0,%ccr
4:	moveml	%sp@+,%d4/%d6
	bras	_done

/* ==== 0x47a tst: sign/exp of *a1 -> ccr ========================== */
_tst:
	moveal	%d1,%a0
	movew	%a0@,%d0
	movew	%d0,%d3
	andiw	#0x7ff0,%d0
	beqs	_done
	tstw	%d3
/* ==== 0x488 common exit ========================================== */
_done:
	moveml	%sp@+,%d0/%d3/%d5/%a0
	rts
/* ==== 0x48e dead tail (selectors 0-7/15 land here) =============== */
_err:
	movel	#224,%d1		/* then falls off hunk end */
