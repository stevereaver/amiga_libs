|||
|||	helpers.s -- asm helpers for the Phase5 68040.library 46.5
|||
|||	_ProbeBody is invoked via exec's Supervisor(): it temporarily
|||	installs an illegal-instruction exception handler (vector 4,
|||	(16,vbr)) that skips a `movec pcr,a1` instruction (control
|||	register 0x808).  PCR is a 68060-only register -- on a real
|||	68040 the instruction traps and the handler returns d0=0;
|||	on a 68060 it executes and d0=1.  This is the classic
|||	040-vs-060 distinguisher used by the Phase5-era loaders.
|||
|||	Supervisor() user functions run on an exception stack frame
|||	and must terminate with RTE -- hence assembler, not C.

	.section .text

	.globl	_ProbeBody
_ProbeBody:
	movec	%vbr,%a0		| a0 = vector base
	move.l	(16,%a0),%d1		| save illegal-instruction vector
	lea	(_ProbeFault,%pc),%a1
	move.l	%a1,(16,%a0)		| install skip-handler
	moveq	#1,%d0
	.word	0x4e7a,0x9808		| movec %pcr,%a1 (68060 only)
	move.l	%d1,(16,%a0)		| restore vector
	rte				| Supervisor() return convention

_ProbeFault:
	addq.l	#4,(2,%a7)		| skip the faulting instruction
	moveq	#0,%d0
	rte

|||	_InitResidentD0 -- reproduce the original's InitResident()
|||	call convention exactly: resident in a1, segList in d0
|||	(the usual ABI is segList in d1), SysBase in a6.
|||
|||	a6 = SysBase, a1 = resident, d0 = segList
	.globl	_InitResidentD0
_InitResidentD0:
	jsr	-102(%a6)		| InitResident
	rts

|||	dos.library calls through an explicit base in a6
|||	_DOSLoadSeg:   a6 = DOSBase, d1 = name    -> d0 = seglist
|||	_DOSUnLoadSeg: a6 = DOSBase, d1 = seglist -> d0 = bool
	.globl	_DOSLoadSeg,_DOSUnLoadSeg
_DOSLoadSeg:
	jsr	-150(%a6)		| LoadSeg
	rts
_DOSUnLoadSeg:
	jsr	-156(%a6)		| UnLoadSeg
	rts
