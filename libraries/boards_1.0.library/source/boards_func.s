|||
|||	boards_func.s -- the single public vector of
|||	boards.library 1.0 plus its code-resident data cells.
|||
|||	The original keeps two longword cells inside the code hunk
|||	(end of the hunk): the library base (written once by init,
|||	never read anywhere -- dead store) and the expname.library
|||	base.  The public function loads the expname base
|||	PC-relative, calls its LVO -30 and returns NOT(result).
|||
|||	Layout at hunk end (original offsets):
|||	  0x1e2  BoardsFunc
|||	  0x1f6  _selfbase cell
|||	  0x1fa  _expnamebase cell
|||	  0x1fe  NOP pad
|||
|||	The "expname.library" string sits at code+0x152 in the
|||	original, between LibInit and LibOpen; here it lives in
|||	this file -- position differs, contents identical.
|||

	.section .text

	.globl	_expnamename
_expnamename:
	.ascii	"expname.library"
	.byte	0
	.even

	.globl	_BoardsFunc
_BoardsFunc:				| LVO -30
	movem.l	d1-d3/a0-a3/a6,-(sp)
	movea.l	_expnamebase(pc),a6
	jsr	-30(a6)
	not.l	d0
	movem.l	(sp)+,d1-d3/a0-a3/a6
	rts

|||	code-resident data cells (written via absolute stores)
	.globl	_selfbase
_selfbase:
	.long	0			| libbase -- dead store
	.globl	_expnamebase
_expnamebase:
	.long	0			| expname.library base
	nop				| original trailing pad
