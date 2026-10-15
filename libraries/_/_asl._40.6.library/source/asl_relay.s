|||
|||	asl_relay.s -- public vectors -30 .. -60 of _asl.library.
|||
|||	Each stub loads its own LVO number into d1 and falls into a
|||	shared relay tail which:
|||
|||	  1. opens "asl.library" v36 through a function pointer at
|||	     libbase+0x22  (NB: the library itself never initialises
|||	     this field -- see okf/findings),
|||	  2. calls the same LVO on the real asl base,
|||	  3. CloseLibrary()s it and returns the result.
|||
|||	Assembled verbatim from the original; this includes the
|||	failure-path bug where CloseLibrary() is invoked on the
|||	exec base when the open fails.
|||

	.section .text

	.globl	_AllocFileRequest
	.globl	_FreeFileRequest
	.globl	_RequestFile
	.globl	_AllocAslRequest
	.globl	_FreeAslRequest
	.globl	_AslRequest

_AllocFileRequest:			| LVO -30
	moveq	#-30,d1
	bra.s	relay
_FreeFileRequest:			| LVO -36
	moveq	#-36,d1
	bra.s	relay
_RequestFile:				| LVO -42
	moveq	#-42,d1
	bra.s	relay
_AllocAslRequest:			| LVO -48
	moveq	#-48,d1
	bra.s	relay
_FreeAslRequest:			| LVO -54
	moveq	#-54,d1
	bra.s	relay
_AslRequest:				| LVO -60
	moveq	#-60,d1

relay:					| d1 = target LVO
	move.l	a6,-(a7)		| save _asl base
	movem.l	d0-d1/a0-a1,-(a7)	| save call args
	movea.l	38(a6),a1		| +0x26: "asl.library"
	moveq	#36,d0			| version
	movea.l	34(a6),a0		| +0x22: OpenLibrary pointer
	movea.l	4,a6			| exec base
	jsr	(a0)			| OpenLibrary("asl.library",36)
	tst.l	d0
	beq.s	fail
	movea.l	d0,a6			| real asl base
	movem.l	(a7)+,d0-d1/a0-a1
	jsr	0(a6,d1.w)		| call asl LVO -30..-60
close:					| (label LAB_001A in original)
	movem.l	d0-d1/a0-a1,-(a7)
	movea.l	a6,a1			| library to close
	movea.l	4,a6
	jsr	-414(a6)		| CloseLibrary
	movem.l	(a7)+,d0-d1/a0-a1
	movea.l	(a7)+,a6		| restore _asl base
	rts
fail:					| (label LAB_001B in original)
	movem.l	(a7)+,d0-d1/a0-a1
	moveq	#0,d0
	bra.s	close			| original bug: a6 is still the
					| exec base here -> CloseLibrary
					| is called on exec.library
