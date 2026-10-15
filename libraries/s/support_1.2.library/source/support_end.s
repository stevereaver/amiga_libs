
|||| ------------------------------------------------------------------
||||	shared scratch workspace (240 zero bytes) + rt_EndSkip target,
||||	linked last so they sit at the hunk end like the shipped binary
|||| ------------------------------------------------------------------
	.globl	_sup_scratch
_sup_scratch:
	.zero	240

	.globl	_sup_end
_sup_end:					| rt_EndSkip target
