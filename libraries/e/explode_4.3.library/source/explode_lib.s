|||
|||  explode.library 4.3 -- "Executable file exploder" (29 May 1989, DSI)
|||  library shell: RomTag, InitTable, vectors, LoadSeg hook install,
|||  and the -30 decrunch-and-run entry.  Decoder core lives in
|||  explode.c (explode_do); this file reproduces the shipped
|||  register/stack conventions exactly.
|||

	.section .text

||| ------ module entry: returns -1 (shipped behaviour) ------
	.globl	_start
_start:	moveq	#-1,d0
	rts

||| ------ RomTag ------
RomTag:	dc.w	0x4afc
	dc.l	RomTag
	dc.l	_endcode
	dc.b	0x80			| RTF_AUTOINIT
	dc.b	4			| version
	dc.b	9			| NT_LIBRARY
	dc.b	0			| pri
	dc.l	_libname
	dc.l	_idstr
	dc.l	InitTable

	.globl	_libname
_libname:
	.ascii	"explode.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"Executable file exploder V4.3 (29 May 1989) "
	.byte	0xa9
	.ascii	" DSI"
	.byte	0x0d,0x0a,0x00
_dosname:
	.ascii	"dos.library"
	.byte	0,0,0			| pad to InitTable

||| ------ InitTable (AUTOINIT) ------
InitTable:
	dc.l	0x36			| data size
	dc.l	FuncTable
	dc.l	DataTable
	dc.l	InitFunc

||| ------ function table (absolute longs, -1 terminator) ------
FuncTable:
	dc.l	LibOpen
	dc.l	LibNull			| close
	dc.l	LibNull			| expunge
	dc.l	LibNull			| reserved
	dc.l	Explode			| -30
	dc.l	-1

||| ------ InitStruct data (extended c/d/e encoding) ------
DataTable:
	dc.w	0xe000,0x000c,0x0900	| byte @0x0c = 9 (dead: overwritten
					|  by the ln_Name long below)
	dc.w	0xc000,0x000a
	dc.l	_libname		| ln_Name
	dc.w	0xe000,0x000e,0x0600	| lib_Flags = SUMUSED|CHANGED
	dc.w	0xd000,0x0014,0x0004	| version 4
	dc.w	0xd000,0x0016,0x0003	| revision 3
	dc.w	0xc000,0x0018
	dc.l	_idstr			| lib_IdString
	dc.w	0x0000,0x0000		| terminator (+pad)

||| ------ InitFunc: installs the DOS LoadSeg hook ------
||| a5 = lib base (InitRoutine arg), a0 = seglist
InitFunc:
	move.l	a5,-(sp)
	movea.l	d0,a5
	move.w	#1,32(a5)		| lib_OpenCnt = 1
	move.l	a0,38(a5)		| seglist
	lea	_dosname(pc),a1
	moveq	#33,d0
	movea.l	4.w,a6
	jsr	-552(a6)		| OldOpenLibrary("dos.library")
	move.l	d0,34(a5)
	bne.s	1f
	movem.l	d7/a5-a6,-(sp)
	move.l	#0x00038007,d7		| Alert AG_OpenLib|AO_DOSLib
	movea.l	4.w,a6
	jsr	-108(a6)		| Alert
	movem.l	(sp)+,d7/a5-a6
1:	movea.l	34(a5),a0
	adda.w	#0xff6a,a0		| DOSBase - 0x96 = LoadSeg vector
	lea	LoadSegStub(pc),a1
	cmpi.w	#0x4ef9,(a0)		| JMP-style vector (KS2+)?
	bne.s	2f
	move.l	2(a0),4(a1)		| patch JSR operand
	moveq	#2,d1			| hook starts at the JSR
	bra.s	3f
2:	cmpi.b	#0x70,(a0)+		| BCPL-style: MOVEQ #n,D0
	bne.s	1b
	move.b	(a0)+,1(a1)		| copy function number
	cmpi.w	#0x6000,(a0)+		| BRA dispatcher
	bne.s	1b
	adda.w	(a0),a0
	move.l	a0,4(a1)		| patch JSR operand
	moveq	#0,d1			| hook starts at the MOVEQ
3:	lea	46(a5),a0
	clr.l	(a0)			| xb_stub_ctr1 = 0
	lea	HookCount(pc),a1
	move.l	a0,2(a1)		| patch counter address
	lea	50(a5),a0
	clr.l	(a0)			| xb_stub_ctr2 = 0
	lea	ByteCount(pc),a1
	move.l	a0,2(a1)		| patch counter address
	clr.l	42(a5)			| xb_opencnt = 0
	movea.l	34(a5),a1		| DOSBase
	movea.w	#0xff6a,a0		| offset -0x96
	move.l	#LoadSegStub,d0
	add.l	d1,d0			| stub entry (+0 BCPL / +2 JMP)
	jsr	-420(a6)		| SetFunction
	move.l	a5,d0
	movea.l	(sp)+,a5
	rts

||| ------ standard vectors ------
LibOpen:
	addq.l	#1,42(a6)		| private open count
	move.l	a6,d0
	rts
LibNull:
	moveq	#0,d0
	rts

||| ------ LoadSeg hook stub (self-patched by InitFunc) ------
||| [moveq #n,d0  - BCPL vector number]  jsr original_LoadSeg
LoadSegStub:
	moveq	#0,d0			| BCPL func no. patched in
	dc.w	0x4eb9,0,0		| jsr 0.l (operand patched)
	movem.l	d0/a0,-(sp)
	lsl.l	#2,d0			| BCPL seglist -> real ptr
	movea.l	d0,a0
	cmpi.l	#0x48e7ffff,4(a0)	| decrunch-stub prologue?
	bne.s	9f
	cmpi.l	#0x6578706c,40(a0)	| "expl"
	bne.s	9f
	cmpi.l	#0x61727900,52(a0)	| "ary\0"
	bne.s	9f
HookCount:
	dc.w	0x52b9,0,0		| addq.l #1,0.l (operand patched)
	movem.l	d1-d7/a1-a6,-(sp)
	lea	32(a0),a5		| packed stream = seg0 data+32
	suba.w	#0x44,a7
	movea.l	a7,a4
	bsr	ExplodeFrame		| frame init + decode
	adda.w	#0x44,a7
	movem.l	(sp)+,d1-d7/a1-a6
9:	movem.l	(sp)+,d0/a0
	tst.l	d0
	rts
ByteCount:
	dc.w	0xd1b9,0,0		| add.l d0,0.l (operand patched)
	rts

||| ------ ExplodeFrame: shared shim into C ------
||| in: a5 = stream, a4 = 0x44 frame.  Mirrors LAB_001D's
||| stream-header setup by calling explode_do(&f, stream).
ExplodeFrame:
	movem.l	d2-d7/a2-a3/a6,-(sp)
	pea	(a5)			| arg2: stream
	move.l	a4,-(sp)		| arg1: struct ExplodeFrame *f
	bsr	_explode_do		| ULONG explode_do(f, stream)
	addq.l	#8,sp
	movem.l	(sp)+,d2-d7/a2-a3/a6
	rts

||| ------ LVO -30: decrunch-and-run ------
||| Call convention (shipped): caller pushes all regs, JSR -30(base);
||| the return address points AT the packed stream (inline data).
||| Frame alloc'd under the reg save; decoder runs; the function then
||| "returns" by jumping to chain[0]+4 (the decrunched program).
Explode:
	movea.l	(sp)+,a5		| a5 = packed stream
	suba.w	#0x44,a7
	movea.l	a7,a4
	suba.l	a1,a1
	movea.l	4.w,a6
	jsr	-294(a6)		| FindTask(NULL)
	move.l	d0,60(a4)
	movea.l	d0,a1
	moveq	#15,d0
	jsr	-300(a6)		| SetTaskPri(task,15)
	move.w	d0,58(a4)
	bsr	ExplodeFrame
	movea.l	60(a4),a1
	move.w	58(a4),d0
	movea.l	4.w,a6
	jsr	-300(a6)		| restore priority
	movea.l	52(a4),a1		| chain base
	addq.l	#4,a1			| chain[0] data -> entry
	adda.w	#0x44,a7
	move.l	a1,60(a7)		| overwrite saved ret addr
	movem.l	(a7)+,d0-d7/a0-a6
	rts				| tail-jump into decrunched code

	.globl	_explode_do
	.extern	_explode_do
