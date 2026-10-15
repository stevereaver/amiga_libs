|||
|||  mhimasstd.library 1.5 -- resident shell (SAS/C layout:
|||  code+strings hunk, DATA hunk with RomTag/InitTable/FuncTab,
|||  BSS hunk for base globals).
|||

	.section .text

	.globl	_MpLibName
_MpLibName:
	.ascii	"mhimasstd.library"
	.byte	0,0,0
	.globl	_MpLibID
_MpLibID:
	.ascii	"mhimasstd 1.6 (18.12.2024)"
	.byte	0,0
	.ascii	"$VER: mhimasstd.library 1.5 (18.12.2024)"
	.byte	0

	.globl	_start
_start:	moveq	#-1,d0
	rts

	.even
||| ------ DATA hunk: RomTag + InitTable + functab ------
	.section .data
	.globl	_RomTag
_RomTag:
	dc.w	0x4afc
	dc.l	_RomTag
	dc.l	_endcode
	dc.l	0x80010900		| flags/ver/type/pri packed
	dc.l	_MpLibName
	dc.l	_MpLibID
	dc.l	_InitTab

_DataTab:
	dc.l	0xe0000008,0x0900800a	| INITBYTE ln_Type=9, INITLONG ln_Name
	dc.l	_MpLibName
	dc.l	0xe000000e,0x0600d000	| flags=6, INITWORD ver
	dc.l	0x00140001,0xd0000016	| ver=1, INITWORD rev
	dc.l	0x00068018		| ...
	dc.l	_MpLibID
	dc.l	0
	dc.w	0

_InitTab:
	dc.l	0x2e			| dataSize
	dc.l	_FuncTab
	dc.l	_DataTab
	dc.l	_LibInit

_FuncTab:
	dc.l	LibOpen
	dc.l	LibClose
	dc.l	LibExpunge
	dc.l	ExtFunc
	dc.l	_MHIAllocDecoder	| -30
	dc.l	_MHIFreeDecoder		| -36
	dc.l	_MHIQueueBuffer		| -42
	dc.l	_MHIGetEmpty		| -48
	dc.l	_MHIGetStatus		| -54
	dc.l	_MHIPlay		| -60
	dc.l	_MHIStop		| -66
	dc.l	_MHIPause		| -72
	dc.l	_MHIQuery		| -78
	dc.l	_MHISetParam		| -84
	dc.l	0xffffffff

||| standard vectors
	.section .text
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
ExtFunc:	moveq	#0,d0
		rts

||| misc.resource vectors: AllocMiscResource -6, FreeMiscResource -12
	.globl	_AllocMiscResource
_AllocMiscResource:		| d0=unit, a1=name -> d0
	movem.l	a6,-(sp)
	movea.l	_g_MiscBase,a6
	jsr	-6(a6)
	movem.l	(sp)+,a6
	rts
	.globl	_FreeMiscResource
_FreeMiscResource:		| d0=unit
	movem.l	a6,-(sp)
	movea.l	_g_MiscBase,a6
	jsr	-12(a6)
	movem.l	(sp)+,a6
	rts
