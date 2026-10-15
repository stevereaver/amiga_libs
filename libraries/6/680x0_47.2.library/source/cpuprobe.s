|||
|||	cpuprobe.s -- supervisor-mode 68060 / Apollo-core probe
|||
|||	Called via exec.library/Supervisor() from LibInit.  Builds a
|||	fake vector table on the stack, points the VBR at it and runs
|||	a "movec pcr,d1" (control register $808 -- the 68060 Processor
|||	Configuration Register).  On a 68040 or older the instruction
|||	is illegal / line-F and the exception trampoline reports
|||	failure.  When the PCR is readable, its high word is checked
|||	against the 68060 signature $0430 (masked with $fffe); a
|||	mismatch means an Apollo/AC68080-class core.
|||
|||	Runs in supervisor state on the supervisor stack and, like the
|||	original, exits with RTE (exec dispatches Supervisor functions
|||	through an exception frame).
|||
|||	returns: d0 = +1  genuine 68060 (PCR high word == $0430/1)
|||	         d0 = -1  PCR readable but not a 68060 (Apollo core)
|||	         d0 =  0  no PCR (68040 or older)
|||

	.section .text
	.globl	_Probe060

_Probe060:
	ori.w	#0x0700,%sr		| kill interrupts
	lea	-128(%a7),%a7		| room for a fake vector table
	moveq	#0,%d1
	movec	%vbr,%a0		| save the real VBR
	lea	_probe_trap(%pc),%a1
	move.l	%a1,16(%a7)		| vector 4: illegal instruction
	move.l	%a1,44(%a7)		| vector 11: line-1111 emulator
	lea	_probe_rte(%pc),%a1
	move.l	%a1,124(%a7)		| vector 31
	movec	%a7,%vbr		| vectors now point at the stack
	moveq	#1,%d0
	.word	0x4e7a,0x1808		| movec $808,%d1  (PCR, 68060 only)
	swap	%d1
	moveq	#-1,%d0
	andi.w	#0xfffe,%d1
	cmpi.w	#0x0430,%d1
	bne.s	_probe_done		| not a genuine 68060 -> -1
	moveq	#1,%d0
_probe_done:
	movec	%a0,%vbr		| restore the real VBR
	lea	128(%a7),%a7
_probe_rte:
	rte
_probe_trap:				| illegal/line-F took us here
	moveq	#0,%d0
	addq.l	#8,%a7			| drop the exception stack frame
	bra.s	_probe_done

	.end
