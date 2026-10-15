|||
|||  ptreplay.library 4.16 (03.01.95) -- resident shell (AUTOINIT)
|||  ProTracker module replay library ("Fashion of Ability"-era).
|||  Private architecture: playback runs on a spawned
|||  "ptreplay_server" process + "ptreplay_ctrltask".
|||
	.section .text
	.globl	_start
_start:	moveq	#-1,d0
	rts

RomTag:	dc.w	0x4afc
	dc.l	RomTag
	dc.l	_endcode
	dc.b	0x80
	dc.b	4
	dc.b	9
	dc.b	0
	dc.l	_libname
	dc.l	_idstr
	dc.l	InitTable

	.globl	_libname
_libname:
	.ascii	"ptreplay.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"ptreplay 4.16 (03.01.95)"
	.byte	0
	.even
_str_server:	.ascii	"ptreplay_server"
	.byte	0
_str_ctrl:	.ascii	"ptreplay_ctrltask"
	.byte	0
_str_dos:	.ascii	"dos.library"
	.byte	0

	.even
InitTable:
	dc.l	0x60
	dc.l	FuncTable
	dc.l	DataTable
	dc.l	_LibInit

FuncTable:
	dc.l	LibOpen
	dc.l	LibClose
	dc.l	LibExpunge
	dc.l	_start			| -24 module entry
	dc.l	_PTLoadModule		| -30
	dc.l	_PTUnloadModule		| -36
	dc.l	_PTPlay			| -42
	dc.l	_PTStop			| -48
	dc.l	_PTPause		| -54
	dc.l	_PTResume		| -60
	dc.l	_PTSetVolume		| -66
	dc.l	_PTSongPos		| -72
	dc.l	_PTPatternPos		| -78
	dc.l	_PTSongLen		| -84
	dc.l	_PTGetChan		| -90
	dc.l	_PTGetSample		| -96
	dc.l	_PTSetPri		| -102
	dc.l	_PTMute			| -108
	dc.l	_PTClearChannelPtrList	| -114
	dc.l	_PTGetModName		| -120
	dc.w	0xffff,0xffff

DataTable:
	dc.w	0xe000,0x0008,0x0900
	dc.w	0xc000,0x000a
	dc.l	_libname
	dc.w	0xe000,0x000e,0x0600
	dc.w	0xd000,0x0014,0x0004
	dc.w	0xd000,0x0016,0x0010
	dc.w	0xc000,0x0018
	dc.l	_idstr
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
		jsr	-252(a6)
		movea.l	d1,a1
		move.w	16(a1),d0
		move.l	d1,a0
		sub.l	d0,a0
		move.l	a0,-(sp)
		movea.l	a2,a1
		movea.l	(sp)+,a0
		move.w	18(a6),d0
		jsr	-210(a6)
		move.l	a2,d7
2:		move.l	d7,d0
		rts
