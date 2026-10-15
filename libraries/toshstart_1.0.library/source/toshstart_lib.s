|||
|||  toshstart.library 1.0 -- resident shell (AUTOINIT)
|||  Kevin McIntosh's machine-support library.
|||

	.section .text

	.globl	_start
_start:	moveq	#-1,d0
	rts

RomTag:	dc.w	0x4afc
	dc.l	RomTag
	dc.l	_endcode
	dc.b	0x80			| RTF_AUTOINIT
	dc.b	1			| version
	dc.b	9			| NT_LIBRARY
	dc.b	0
	dc.l	_libname
	dc.l	_idstr
	dc.l	InitTable

	.globl	_libname
_libname:
	.ascii	"toshstart.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"$VER: Toshstart.Library Ver 1.0 By Kevin McIntosh."
	.byte	0

	.even
InitTable:
	dc.l	0x4c			| dataSize (as shipped)
	dc.l	FuncTable
	dc.l	DataTable
	dc.l	_LibInit

FuncTable:
	dc.l	LibOpen
	dc.l	LibClose
	dc.l	LibExpunge
	dc.l	LibNull
	dc.l	_ToshFunc0		| -30  dispatch wrapper
	dc.l	_ToshFunc1		| -36  DMA/copper setup
	dc.l	_ToshFunc2		| -42  AllocEntry
	dc.l	_ToshFunc3		| -48  FreeEntry
	dc.l	_ToshFunc4		| -54  wait tick change
	dc.l	_ToshFunc5		| -60  wait n ticks
	dc.l	_ToshFunc6		| -66  device SendIO
	dc.l	_ToshFunc7		| -72  device CheckIO
	dc.l	_ToshFunc8		| -78  device CheckIO (alt)
	dc.l	_ToshFunc9		| -84  dispatch+setup
	dc.l	_ToshFunc10		| -90  MakeLibrary call
	dc.l	_ToshFunc11		| -96  Supervisor path 1
	dc.l	_ToshFunc12		| -102 Supervisor path 2
	dc.l	_ToshFunc13		| -108 param call mode 2
	dc.l	_ToshFunc14		| -114 param call mode 3
	dc.l	_ToshFunc15		| -120 charset lookup
	dc.l	_ToshFunc16		| -126 return &sysbase2
	dc.l	_ToshFunc17		| -132 decimal formatter
	dc.l	_ToshFunc18		| -138 hex formatter
	dc.l	_ToshFunc19		| -144 tokenizer
	dc.l	_ToshFunc20		| -150 set callback ptr
	dc.l	_ToshFunc21		| -156 clear state block
	dc.w	0xffff,0xffff

||| extended c/d/e InitStruct encoding (as shipped)
DataTable:
	dc.w	0xe000,0x0008,0x0900	| ln_Type = NT_LIBRARY
	dc.w	0xc000,0x000a
	dc.l	_libname		| ln_Name
	dc.w	0xe000,0x000e,0x0600	| lib_Flags = SUMUSED|CHANGED
	dc.w	0xd000,0x0014,0x0001	| version 1
	dc.w	0xd000,0x0016,0x0000	| revision 0
	dc.w	0xc000,0x0018
	dc.l	_idstr			| lib_IdString
	dc.w	0,0

LibOpen:	addq.w	#1,0x20(a6)
		bclr	#3,14(a6)
		move.l	a6,d0
		rts
LibClose:	moveq	#0,d7
		subq.w	#1,0x20(a6)
		bne.s	1f
		btst	#3,14(a6)
		beq.s	1f
		bsr	LibExpunge
		move.l	d0,d7
1:		move.l	d7,d0
		rts
LibExpunge:	moveq	#0,d7
		bset	#3,14(a6)
		tst.w	0x20(a6)
		bne.s	2f
		movea.l	0x22(a6),a2
		move.l	a6,d1
		movea.l	a6,a1
		movea.l	4.w,a6
		jsr	-252(a6)		| Remove
		movea.l	d1,a1
		move.w	16(a1),d0
		move.l	d1,a0
		sub.l	d0,a0
		move.l	a0,-(sp)
		movea.l	a2,a1
		movea.l	(sp)+,a0
		move.w	18(a6),d0
		jsr	-210(a6)		| FreeMem
		move.l	a2,d7
2:		move.l	d7,d0
		rts
LibNull:	moveq	#0,d0
		rts

||| helpers for lib-internal vector calls (dos -60 packet dispatch,
||| gfx -228, exec Supervisor) - registers pass straight through.
	.globl	_DosDispatch
_DosDispatch:
	movem.l	a6,-(sp)
	movea.l	a0,a6
	jsr	-60(a6)
	movem.l	(sp)+,a6
	rts
	.globl	_GfxCall228
_GfxCall228:
	movem.l	a6,-(sp)
	movea.l	a0,a6
	jsr	-228(a6)
	movem.l	(sp)+,a6
	rts
	.globl	_ExecSuper
_ExecSuper:
	movem.l	a6,-(sp)
	movea.l	4.w,a6
	jsr	-30(a6)
	movem.l	(sp)+,a6
	rts
	.globl	_DosCall30
_DosCall30:
	movem.l	a6,-(sp)
	movea.l	a0,a6
	jsr	-30(a6)
	movem.l	(sp)+,a6
	rts
	.globl	_DosCall84
_DosCall84:
	movem.l	a6,-(sp)
	movea.l	a0,a6
	jsr	-84(a6)
	movem.l	(sp)+,a6
	rts
