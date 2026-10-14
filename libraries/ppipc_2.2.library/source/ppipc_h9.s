/* ppipc.library 2.2 -- hunk9 CODE (0x84 bytes)
 * -102 Str2ID(str): pack <=4 chars into a long.
 * -108 FindID(tbl,id,cursor): scan 16-byte records at tbl+0x1e,
 *   tbl+0x1c = record count; a1 cursor -> resume after it. */

	.globl	_str2id,_findid

	.text

_str2id:					/* h9+0: -102 */
	moveml	%d6-%d7/%a3,%sp@-
	moveal	%a0,%a3				/* str */
	moveq	#0,%d7
	moveq	#4,%d6
1:	movel	%d6,%d0
	subql	#1,%d6
	tstl	%d0
	beqs	2f
	movel	%d7,%d0
	asll	#8,%d0
	moveb	%a3@,%d1
	extw	%d1
	extl	%d1
	orl	%d1,%d0
	movel	%d0,%d7
	tstb	%a3@
	beqs	1b
	addql	#1,%a3
	bras	1b
2:	movel	%d7,%d0
	moveml	%sp@+,%d6-%d7/%a3
	rts

_findid:					/* h9+0x30: -108 */
	moveml	%d2/%d6-%d7/%a2-%a3,%sp@-
	moveal	%a0,%a3				/* table */
	movel	%d0,%d7				/* id */
	moveal	%a1,%a2				/* cursor (0 -> start) */
	movel	%a2,%d0
	beqs	3f
	lea	%a3@(30),%a0			/* first record */
	movel	%a2,%d0
	movel	%a0,%d1
	subl	%d1,%d0
	asrl	#4,%d0				/* records skipped */
	moveq	#0,%d1
	movew	%a3@(28),%d1			/* record count */
	movel	%d1,%d2
	subl	%d0,%d2
	movel	%d2,%d6
	bras	4f
3:	moveq	#0,%d6
	movew	%a3@(28),%d6
	lea	%a3@(30),%a2
4:	movel	%d6,%d0
	subql	#1,%d6
	tstl	%d0
	beqs	6f
	movel	%a2@,%d0
	cmpl	%d7,%d0
	bnes	5f
	movel	%a2,%d0
	bras	7f
5:	addaw	#16,%a2
	bras	4b
6:	moveq	#0,%d0
7:	moveml	%sp@+,%d2/%d6-%d7/%a2-%a3
	rts
	.short	0				/* h9+0x82 pad */
