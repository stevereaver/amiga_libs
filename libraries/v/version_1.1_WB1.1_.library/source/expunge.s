|||
|||	expunge.s -- LibExpunge for version.library 1.1 (WB1.1)
|||
|||	Reproduces the original routine verbatim, including its two
|||	defects:
|||
|||	  * exec Remove() is called with the node in a0; Remove's
|||	    argument is a node in a1 on every documented exec (fd13
|||	    and later).  Unless Kickstart 1.1's Remove really took a0,
|||	    expunging this library unlinks a garbage node.
|||	  * the FreeMem block/size are computed with longword reads
|||	    at lib_NegSize/lib_PosSize (+0x10/+0x12): the base is
|||	    pushed back by (NegSize<<16|PosSize) and the size is
|||	    (NegSize<<16|PosSize)+(PosSize<<16|lib_Version) --
|||	    i.e. a wild free, not neg+pos bytes.
|||
|||	Register interface: a6 = library base on entry, d0 = seglist
|||	(or 0) on exit.  Called by exec via the LVO -18 vector and by
|||	LibClose via a normal call.
|||

	.section .text
	.globl	_LibExpunge

_LibExpunge:
	movem.l	d2/a5-a6,-(sp)
	movea.l	a6,a5			| a5 = library base
	movea.l	34(a5),a6		| vb_SysBase
	tst.w	32(a5)			| lib_OpenCnt
	beq.w	1f
	bset	#3,42(a5)		| vb_Flags |= VBF_DELEXP
	moveq	#0,d0
	bra.s	2f
1:
	move.l	38(a5),d2		| vb_SegList
	movea.l	a5,a0			| BUG: node in a0, not a1
	jsr	-252(a6)		| Remove
	movea.l	a5,a1
	move.l	16(a5),d0		| BUG: longword NegSize|PosSize
	suba.l	d0,a1
	add.l	18(a5),d0		| BUG: + longword PosSize|Version
	jsr	-210(a6)		| FreeMem
	move.l	d2,d0
2:
	movem.l	(sp)+,d2/a5-a6
	rts

|||
|||	LibNull (LVO -24, ExtFunc/reserved): always returns 0.
|||	Kept here so the link order stays Init,Open,Close,Expunge,
|||	Null like the original binary.
|||
	.globl	_LibNull
_LibNull:
	moveq	#0,d0
	rts
