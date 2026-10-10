|||
|||	helpers.s -- asm shims for the Phase5 dummy 68040.library 44.1
|||
|||	_InitResidentD0 -- reproduce the original's InitResident()
|||	call convention exactly: resident in a1, segList in d0
|||	(the usual ABI is segList in d1), SysBase in a6.
|||
|||	a6 = SysBase, a1 = resident, d0 = segList

	.section .text

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
