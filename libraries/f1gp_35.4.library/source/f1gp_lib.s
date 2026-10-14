* jf1gp.library 35.4 (22.8.97) - (c) 1995-1997 Oliver Roberts / JAM
* Pure-asm reconstruction (byte-identical target).
* Non-AUTOINIT resident: rt_Init builds the library via MakeLibrary
* (long-absolute func table) and registers it with AddLibrary.
* Globals live in hunk 1 (DATA): a4 = data+0x7ffe is used as a
* self-referential base register, giving:
*   a4@(-32766) = data+0   LibBase
*   a4@(-32762) = data+4   seglist
*   a4@(-32758) = data+8   SysBase
*   a4@(-32662) = data+104 patch-installed flag (word)
*   a4@(-32660) = data+106 enabled flag (word)
*   a4@(-32658) = data+108 MinList (signal registrations)
*   a4@(-32646) = data+120 Semaphore (guards the list)
*   a4@(-32600) = data+166 patch-address array (8 longs)
*   a4@(-32670..-32754) = patch descriptor entries in the const table

	.text

start:
	moveq	#-1,d0
	rts

	* non-standard RomTag: endskip -> self, extra long -> init
	dc.w	0x4afc
	dc.l	start+4
	dc.l	_Init
	dc.b	0,35,9,0
	dc.l	_Name
	dc.l	_IdStr
	dc.l	_Init

	* the name string begins at 0x1e with "f1gp.library"; the
	* leading 'j' is the low byte of the preceding init pointer
_Name:
	.ascii	"f1gp.library\0"
_IdStr:
	.ascii	"f1gp 35.4 (22.8.97)\r\n\0"
	.ascii	"Copyright (c) 1995-1997 by Oliver Roberts"

* ----------------------------------------------------------------
* rt_Init (0x6a): called by InitResident; a0 = seglist
_Init:
	movel	a0,sp@-
	moveml	d2-d7/a2-a6,sp@-
	.short	0x2c79
	.long	4		/* moveal SysBase.l,a6 */
	lea	_DATA+0x7ffe,a4
	subal	a3,a3
	lea	a4@(-32766),a0
	.short	0x203c
	.long	26				/* movel #26,d0 */
	asll	#2,d0
	addal	d0,a0
	.short	0x203c
	.long	23				/* movel #23,d0 */
	moveq	#0,d1
	bras	1f
0:	movel	d1,a0@+
1:	dbf	d0,0b
	.short	0x90bc
	.long	0x10000				/* subl #65536,d0 */
	bccs	0b
	.short	0x4eb9
	.long	_Patch1
	bnes	_InitFail
	.short	0x4eb9
	.long	_Patch2
	bnes	_InitFail
	moveml	sp@+,d2-d7/a2-a6
	movel	sp@+,d0
	.short	0x4efa
	.short	_Init2-.
_InitFail:
	moveml	sp@+,d2-d7/a2-a6
	movel	sp@+,d0
	moveq	#0,d0
	rts

* ----------------------------------------------------------------
* -12 Close wrapper (0xc8): call core, then shared exit-cleanup
_VClose:
	bsrw	_Close
	bras	_ExitTail
* -18 Expunge wrapper (0xce)
_VExpunge:
	moveal	a6,a0
	bsrw	_Expunge
	bras	_ExitTail
* -24 null vector (0xd6)
_VNull:
	moveq	#0,d0
	rts
* shared tail: if core returned non-zero, run the two cleanup stubs
_ExitTail:
	tstl	d0
	beqs	1f
	moveml	d0/a4/a6,sp@-
	moveal	0x4:w,a6		/* orig uses the short form here */
	lea	_DATA+0x7ffe,a4
	.short	0x4eb9
	.long	_Stub88c
	.short	0x4eb9
	.long	_Stub888
	moveml	sp@+,d0/a4/a6
1:	rts
	nop

* ----------------------------------------------------------------
* -48 Checksum (0x100): d0 = f(a0=ptr, d0=len) -> d0 32-bit
* rolling checksum: d3 = (d3<<16)|rol3-accum in d2
_Checksum:
	moveml	d1-d3/a0,sp@-
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
0:	moveb	a0@+,d1
	addw	d1,d3
	andiw	#255,d1
	rolw	#3,d2
	addw	d1,d2
	subql	#1,d0
	bnes	0b
	swap	d3
	movel	d3,d0
	movew	d2,d0
	moveml	sp@+,d1-d3/a0
	rts

* patch-handler entry copied to hunk-start? actually callable glue:
* jsr ABS0 (patched at runtime), jsr _UnsigAll, rts
_VecGate:
	.short	0x4eb9		/* patched at runtime */
	.long	0
	.short	0x4eb9
	.long	_UnsigAll
	rts

* ----------------------------------------------------------------
* trap-handler 1 (0x134): swaps 6 longs between VBR+0x64 area and
* a patch buffer inside the victim seglist (a2 imm patched at install)
_HookSwap:
	moveml	d0/a0-a2,sp@-
	bsrs	_VBR
	moveal	d0,a1
	lea	a1@(100),a1
	lea	_DATA+0xa6,a0
moveal_patch0:
	moveal	#0,a2
	moveq	#6,d0
0:	movel	a1@,a2@+
	movel	a0@+,a1@+
	dbf	d0,0b
	moveml	sp@+,d0/a0-a2
	rts

* trap-handler 2 (0x15c): copies 6 longs data+0xa6 -> VBR+0x64
_HookLoad:
	moveml	d0/a0-a1,sp@-
	bsrs	_VBR
	moveal	d0,a1
	lea	a1@(100),a1
	moveq	#6,d0
0:	movel	a0@+,a1@+
	dbf	d0,0b
	moveml	sp@+,d0/a0-a1
	rts

* trap-handler 3 (0x176): store a0 into VBR+0x68/0x6c/0x70 area
_HookStore:
	moveml	d0/a1,sp@-
	bsrs	_VBR
	moveal	d0,a1
	movel	a0,a1@(108)
	movel	a0,a1@(104)
	lea	a0@(226),a0
	movel	a0,a1@(112)
	moveml	sp@+,d0/a1
	rts

* helper (0x194): d0 = VBR via exec Supervisor(-30)
_VBR:
	moveml	a5-a6,sp@-
	moveal	_DATA+8,a6
	lea	%pc@(_vbrstub),a5
	jsr	a6@(-30)
	moveml	sp@+,a5-a6
	rts
_vbrstub:
	movec	vbr,d0
	rte
	nop

* ----------------------------------------------------------------
* vector table (0x1b4): long-absolute, -1 terminated
_FuncTab:
	dc.l	_VOpen
	dc.l	_VClose
	dc.l	_VExpunge
	dc.l	_VNull
	dc.l	_FindPatch
	dc.l	_AllocNode
	dc.l	_FreeNode
	dc.l	_Checksum
	dc.l	-1

* ----------------------------------------------------------------
* real init (0x1d8): a4 = data+0x7ffe, d0 = caller d0 (seglist?)
_Init2:
	moveml	d7/a2-a4/a6,sp@-
	movel	d0,d7
	lea	_DATA+0x7ffe,a4
	movel	0x4:w,a4@(-32758)
	lea	%pc@(_FuncTab),a0
	subal	a1,a1
	subal	a2,a2
	moveq	#62,d0
	moveq	#0,d1
	moveal	a4@(-32758),a6
	jsr	a6@(-84)		/* MakeLibrary */
	moveal	d0,a3
	movel	a3,d1
	beqs	2f
	movel	a3,a4@(-32766)
	moveb	#9,a3@(8)
	.short	0x4df9
	.long	_Name			/* lea Name.l,a6 */
	movel	a6,a3@(10)
	moveb	#6,a3@(14)
	movew	#35,a3@(20)
	movew	#4,a3@(22)
	.short	0x4df9
	.long	_IdStr		/* lea IdStr.l,a6 */
	movel	a6,a3@(24)
	movel	d7,a4@(-32762)
	moveal	a3,a1
	moveal	a4@(-32758),a6
	jsr	a6@(-396)		/* AddLibrary */
	bsrw	_PostInit
2:	movel	a3,d0
	moveml	sp@+,d7/a2-a4/a6
	rts

* -6 Open (0x24e)
_VOpen:
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	rts

* Close core (0x25c)
_Close:
	tstw	a6@(32)
	beqs	1f
	subqw	#1,a6@(32)
	tstw	a6@(32)
	beqs	1f
	moveq	#0,d0
	bras	2f
1:	btst	#3,a6@(14)
	beqs	3f
	moveal	a6,a0
	bsrs	_Expunge
	bras	2f
3:	moveq	#0,d0
2:	rts

* Expunge core (0x282): a0 = libbase
_Expunge:
	moveml	d2/a3-a4/a6,sp@-
	moveal	a0,a3
	lea	_DATA+0x7ffe,a4
	tstw	a3@(32)
	bnes	1f
	tstw	a4@(-32662)
	beqs	2f
	tstw	a4@(-32660)
	beqs	2f
1:	bset	#3,a3@(14)
	moveq	#0,d0
	bras	9f
2:	.short	0x43d3		/* lea (a3),a1 */
	moveal	a4@(-32758),a6
	jsr	a6@(-252)		/* Remove */
	moveq	#0,d0
	movew	a3@(16),d0
	negl	d0
	moveal	a3,a1
	addal	d0,a1
	moveq	#0,d1
	movew	a3@(16),d1
	moveq	#0,d2
	movew	a3@(18),d2
	* d1=negsize d2=possize -> FreeMem(lib-negsize, neg+pos)
	movel	d1,d0
	addl	d2,d0
	moveal	a4@(-32758),a6
	jsr	a6@(-210)		/* FreeMem */
	bsrw	_SegFree
	movel	a4@(-32762),d0
9:	moveml	sp@+,d2/a3-a4/a6
	rts
	nop

* post-init (0x2e8): init list+semaphore, zero flags
_PostInit:
	movel	a6,sp@-
	movew	#0,a4@(-32662)
	movew	#0,a4@(-32660)
	lea	a4@(-32658),a0
	bsrw	_NewMinList
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-558)		/* InitSemaphore */
	moveal	sp@+,a6
	rts

* free the seg list buffer chain (0x30e)
_SegFree:
	moveml	a3/a6,sp@-
	bras	1f
0:	moveal	a3,a1
	moveq	#16,d0
	moveal	a4@(-32758),a6
	jsr	a6@(-210)		/* FreeMem */
1:	lea	a4@(-32658),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-258)		/* RemHead */
	moveal	d0,a3
	movel	a3,d0
	bnes	0b
	tstw	a4@(-32662)
	beqs	2f
	bsrw	_Unpatch
2:	moveml	sp@+,a3/a6
	rts
	nop

* ----------------------------------------------------------------
* -36 AllocNode (0x344): a0=task, d0=signals -> 16B node on list1
_AllocNode:
	moveml	d7/a2-a4/a6,sp@-
	moveal	a0,a3
	movel	d0,d7
	lea	_DATA+0x7ffe,a4
	moveq	#16,d0
	moveq	#1,d1
	moveal	a4@(-32758),a6
	jsr	a6@(-198)		/* AllocMem */
	moveal	d0,a2
	movel	a2,d1
	beqs	1f
	movel	a3,a2@(8)
	movel	d7,a2@(12)
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-564)		/* ObtainSemaphore */
	lea	a4@(-32658),a0
	moveal	a2,a1
	moveal	a4@(-32758),a6
	jsr	a6@(-246)		/* AddTail */
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-570)		/* ReleaseSemaphore */
1:	movel	a2,d0
	moveml	sp@+,d7/a2-a4/a6
	rts

* -42 FreeNode (0x39a): a0 = node -> remove+free
_FreeNode:
	moveml	a3-a4/a6,sp@-
	moveal	a0,a3
	lea	_DATA+0x7ffe,a4
	movel	a3,d0
	beqs	1f
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-564)		/* ObtainSemaphore */
	moveal	a3,a1
	moveal	a4@(-32758),a6
	jsr	a6@(-252)		/* Remove */
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-570)		/* ReleaseSemaphore */
	moveal	a3,a1
	moveq	#16,d0
	moveal	a4@(-32758),a6
	jsr	a6@(-210)		/* FreeMem */
1:	moveml	sp@+,a3-a4/a6
	rts

* ----------------------------------------------------------------
* UnsigAll (0x3de): walk signal list, Signal(task,mask) each
_UnsigAll:
	moveml	a3-a4/a6,sp@-
	lea	_DATA+0x7ffe,a4
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-564)		/* ObtainSemaphore */
	lea	a4@(-32658),a0
	bsrw	_FirstNode
	moveal	d0,a3
	bras	1f
0:	moveal	a3@(8),a1
	movel	a3@(12),d0
	moveal	a4@(-32758),a6
	jsr	a6@(-324)		/* Signal */
	moveal	a3,a0
	bsrw	_FirstNode
	moveal	d0,a3
1:	movel	a3,d0
	bnes	0b
	lea	a4@(-32646),a0
	moveal	a4@(-32758),a6
	jsr	a6@(-570)		/* ReleaseSemaphore */
	movew	#0,a4@(-32662)
	moveml	sp@+,a3-a4/a6
	rts

* InstallPatches (0x434): write jsr/bra trampolines into victim
_Install:
	moveml	d7/a2-a3/a6,sp@-
	movew	#0,a4@(-32660)
	moveal	a4@(-32758),a6
	jsr	a6@(-132)		/* Forbid */
	moveal	a4@(-32758),a6
	btst	#0,a6@(297)
	beqw	9f
	movew	#1,a4@(-32660)
	lea	a4@(-32670),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movew	#0x600e,a3@		/* bra +14 */
	lea	a4@(-32710),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	moveq	#0,d7
	bras	2f
1:	movel	d7,d0
	asll	#2,d0
	lea	a4@(-32600),a0
	addal	d0,a0
	moveal	a0,a2
	movel	d7,d0
	moveq	#10,d1
	bsrw	_MulDiv
	movel	a3@(2,d0:l),a2@
	addql	#1,d7
2:	moveq	#7,d0
	cmpl	d7,d0
	bgts	1b
	moveq	#2,d0
	lea	%pc@(_HookSwap+0x12),a2		/* code+0x146 */
	addl	a2,d0
	moveal	d0,a2
	lea	a4@(-32686),a0
	bsrw	_PatchAddr
	movel	d0,a2@		/* patch moveal #0,a2 imm */
	movew	#0x4eb9,a3@		/* jsr abs.l */
	lea	%pc@(_HookSwap),a2		/* code+0x134 */
	movel	a2,a3@(2)
	movel	#0x6000003e,a3@(6)		/* bra +0x0c ; pad */
	lea	a4@(-32702),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movew	#0x4eb9,a3@		/* jsr abs.l */
	lea	%pc@(_HookLoad),a0		/* code+0x15c */
	movel	a0,a3@(2)
	movew	#0x600c,a3@(6)		/* bra +0x0c */
	lea	a4@(-32694),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movew	#0x4eb9,a3@		/* jsr abs.l */
	lea	%pc@(_HookLoad),a0		/* code+0x15c */
	movel	a0,a3@(2)
	movew	#0x600c,a3@(6)		/* bra +0x0c */
	lea	a4@(-32678),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movew	#0x4eb9,a3@		/* jsr abs.l */
	lea	%pc@(_HookStore),a0		/* code+0x176 */
	movel	a0,a3@(2)
	movew	#0x6008,a3@(6)		/* bra +8 */
9:	lea	%pc@(_VecGate),a2		/* code+0x126 */
	lea	a4@(-32726),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movel	a3@,a2@(2)		/* save old vec -> VecGate jsr */
	movel	a2,a3@		/* install VecGate */
	lea	a4@(-32718),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movel	a2,a3@
	movel	a2,a3@(178)
	lea	a4@(-32742),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movel	#0x4e714e71,a3@(100)
	movel	a3@(100),a3@
	lea	a4@(-32754),a0
	movel	a0,sp@-
	lea	a4@(-32734),a1
	movel	a1,d0
	movel	a0,sp@-
	moveal	d0,a0
	bsrs	_PatchAddr
	movel	d0,d7
	moveal	sp@+,a0
	moveal	d7,a1
	moveq	#11,d0
	moveal	a4@(-32758),a6
	moveal	sp@+,a0
	jsr	a6@(-624)		/* CopyMem */
	moveal	a4@(-32758),a6
	jsr	a6@(-138)		/* Permit */
	moveal	a4@(-32758),a6
	cmpiw	#37,a6@(20)
	bcss	8f
	moveal	a4@(-32758),a6
	jsr	a6@(-636)		/* CacheClearU */
8:	moveml	sp@+,d7/a2-a3/a6
	rts

* PatchAddr (0x58c): a0 = descriptor ptr -> d0 = computed patch addr
* uses LibBase(=a4@(-32766)) fields +34/+36/+38/+54/+58
_PatchAddr:
	movel	a0@,d0
	moveal	a4@(-32766),a1
	.short	0xb0bc
	.long	301324				/* cmpl #301324,d0 */
	blss	1f
	addl	a1@(58),d0
	bras	2f
1:	addl	a1@(54),d0
2:	movel	a1@(34),d1
	subql	#2,d1
	beqs	3f
	subql	#1,d1
	beqs	4f
	bras	5f
4:	movew	a0@(4),d1
	extl	d1
	addl	d1,d0
	bras	5f
3:	movew	a0@(6),d1
	extl	d1
	addl	d1,d0
5:	rts

* Unpatch (0x5c6): restore patched sites
_Unpatch:
	moveml	d7/a3/a6,sp@-
	lea	a4@(-32726),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movel	%pc@(_VecGate+2),d7		/* saved orig vector */
	moveal	a4@(-32758),a6
	jsr	a6@(-132)		/* Forbid */
	movel	d7,a3@
	lea	a4@(-32718),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movel	d7,a3@(178)
	movel	a3@(178),a3@
	tstw	a4@(-32660)
	beqs	9f
	lea	a4@(-32670),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movew	#0x22d8,a3@		/* move.l (a0)+,(a1)+ */
	lea	a4@(-32710),a0
	bsrs	_PatchAddr
	moveal	d0,a3
	movew	#0x23fc,a3@		/* move.l #imm,-(a1)? */
	movel	a4@(-32600),a3@(2)
	moveq	#100,d0
	movel	d0,a3@(6)
	lea	a4@(-32702),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movel	#0x227c0000,a3@		/* move.l #imm,a... */
	movel	#0x006422d8,a3@(4)
	lea	a4@(-32694),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movel	#0x227c0000,a3@
	movel	#0x006422d8,a3@(4)
	lea	a4@(-32678),a0
	bsrw	_PatchAddr
	moveal	d0,a3
	movel	#0x21c8006c,a3@		/* move.l a0,0x6c */
	movel	#0x21c80068,a3@(4)		/* move.l a0,0x68 */
9:	moveal	a4@(-32758),a6
	jsr	a6@(-138)		/* Permit */
	moveal	a4@(-32758),a6
	cmpiw	#37,a6@(20)
	bcss	8f
	moveal	a4@(-32758),a6
	jsr	a6@(-636)		/* CacheClearU */
8:	moveml	sp@+,d7/a3/a6
	rts

* ----------------------------------------------------------------
* -30 FindPatch (0x684): walk task lists, detect F1GP, install
_FindPatch:
	moveml	d7/a4,sp@-
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32758),a1
	moveal	a1@(406),a0		/* TaskReady */
	bsrw	_WalkTasks
	movel	d0,d7
	tstl	d7
	bnes	1f
	moveal	a4@(-32758),a1
	moveal	a1@(420),a0		/* TaskWait */
	bsrw	_WalkTasks
	movel	d0,d7
1:	moveal	a4@(-32766),a0
	movel	d7,a0@(34)		/* LibBase+34 = version */
	tstw	a4@(-32662)
	bnes	2f
	tstl	d7
	beqs	2f
	movew	#1,a4@(-32662)
	bsrw	_Install
2:	movel	d7,d0
	moveml	sp@+,d7/a4
	rts

* CheckSeg (0x6d2): a0 = segptr -> d7 = 1/2/3 version, d6 = size
_CheckSeg:
	moveml	d2/d6-d7/a3,sp@-
	moveal	a0,a3
	moveq	#0,d7
	movel	a3,d0
	beqw	9f
	movel	a3@(-4),d0
	.short	0x90bc
	.long	281180				/* subl #281180,d0 */
	beqs	1f
	subql	#8,d0
	beqs	2f
	moveq	#12,d1
	subl	d1,d0
	beqs	3f
	bras	4f
1:	moveq	#1,d7
	movel	#301324,d6
	bras	4f
2:	moveq	#2,d7
	movel	#301328,d6
	bras	4f
3:	moveq	#3,d7
	movel	#301344,d6
4:	tstl	d7
	beqs	5f
	movel	a3@,d1
	asll	#2,d1
	movel	d1,d0
	moveal	d0,a0
	cmpil	#174408,a0@(-4)
	beqs	5f
	moveq	#0,d7
5:	tstl	d7
	beqs	9f
	moveal	a4@(-32766),a0
	moveq	#0,d0
	bras	7f
6:	movel	d0,d1
	asll	#2,d1
	lea	a3@(4),a1
	movel	a1,a0@(38,d1:l)
	movel	a3@,d1
	asll	#2,d1
	moveal	d1,a3
	addql	#1,d0
7:	moveq	#4,d1
	cmpl	d0,d1
	bgts	6b
	movel	a0@(38),d1
	moveq	#44,d2
	subl	d2,d1
	movel	d1,a0@(54)
	movel	a0@(46),d1
	subl	d6,d1
	movel	d1,a0@(58)
9:	movel	d7,d0
	moveml	sp@+,d2/d6-d7/a3
	rts

* WalkTasks (0x770): a0 = task list head -> d6 = found version
_WalkTasks:
	moveml	d6-d7/a2-a3/a6,sp@-
	moveal	a0,a3
	moveq	#0,d6
	moveal	a4@(-32758),a6
	jsr	a6@(-120)		/* Disable */
	braw	8f
0:	cmpib	#13,a3@(8)		/* NT_TASK? */
	bnew	7f
	tstl	a3@(172)
	beqs	1f
	movel	a3@(172),d0
	asll	#2,d0
	moveal	d0,a0
	movel	a0@(60),d0
	asll	#2,d0
	moveal	d0,a2
	bras	2f
1:	movel	a3@(128),d1
	asll	#2,d1
	movel	d1,d0
	moveaw	#12,a2
	addal	d0,a2
	movel	a2@,d0
	asll	#2,d0
	moveal	d0,a2
2:	movel	a2,d0
	beqs	6f
	movel	a2@(-4),d0
	.short	0x90bc
	.long	844				/* subl #844,d0 */
	beqs	3f
	moveq	#64,d1
	subl	d1,d0
	beqs	4f
	.short	0x90bc
	.long	404				/* subl #404,d0 */
	beqs	5f
	moveq	#80,d1
	subl	d1,d0
	beqs	10f
	bras	11f
4:	moveq	#-75,d7
	bras	12f
3:	moveq	#-91,d7
	bras	12f
10:	moveq	#-5,d7
	bras	12f
5:	moveq	#-25,d7
	bras	12f
11:	moveq	#0,d7
12:	tstb	d7
	beqs	13f
	moveq	#0,d0
	moveb	d7,d0
	extl	d0
	asll	#2,d0
	movel	a2@(0,d0:l),d0
	asll	#2,d0
	moveal	d0,a0
	bsrw	_CheckSeg
	movel	d0,d6
	bras	6f
13:	moveal	a2,a0
	bsrw	_CheckSeg
	movel	d0,d6
6:	tstl	d6
	beqs	7f
	moveal	a3,a1
	moveq	#-100,d0
	moveal	a4@(-32758),a6
	jsr	a6@(-300)		/* SetTaskPri */
7:	moveal	a3@,a3
8:	movel	a3,d0
	beqs	14f
	tstl	d6
	beqw	0b
14:	moveal	a4@(-32758),a6
	jsr	a6@(-126)		/* Enable */
	movel	d6,d0
	moveml	sp@+,d6-d7/a2-a3/a6
	rts
	nop

* MulDiv (0x844): 32x32 partial-product helper -> d0
_MulDiv:
	moveml	d0-d1,sp@-
	swap	d0
	muluw	d1,d0
	swap	d1
	muluw	sp@(2),d1
	addl	d1,d0
	swap	d0
	clrw	d0
	movew	sp@(2),d1
	muluw	sp@(6),d1
	addl	d1,d0
	addql	#8,sp
	rts
	nop

* FirstNode (0x868 entry via stack / 0x86c direct): next list node
_NextNodeStk:
	moveal	sp@(4),a0
_FirstNode:
	moveal	a0@,a0
	movel	a0@,d0
	beqs	1f
	movel	a0,d0
1:	rts
	nop

* protection-check stubs: always pass (patched out in this build)
_Patch1:
	moveq	#0,d0
	rts
	moveq	#1,d0
	rts
_Patch2:
	moveq	#0,d0
	rts
	moveq	#1,d0
	rts
_Stub888:
	rts
	nop
_Stub88c:
	rts
	nop

* NewMinList (0x890 stack-entry / 0x894 direct)
_NewMinListStk:
	moveal	sp@(4),a0
_NewMinList:
	clrl	a0@(4)
	movel	a0,a0@(8)
	addql	#4,a0
	movel	a0,a0@-
	rts
	dc.w	0,0x4e75,0x4e71

* ================================================================
	.data
_DATA:
* 104 bytes of version/patch descriptor constants. The hunk header
* declares 196 bytes; the tail is uninitialised and cleared by init.
	dc.l	0,0,0
	dc.l	0xfc03e8e6,0x83342800,0x106b1200,0x00076d1e
	dc.l	0xfff8ff4c,0x00026dd1,0x0014000a,0x000008dc
	dc.l	0x00000000,0x000009cc,0x0000fff6,0x00049a10
	dc.l	0x00140004,0x00076818,0x003e002e,0x0007e5ea
	dc.l	0xfff8ff4c,0x00081d9e,0xfff8ff4c,0x0007e57c
	dc.l	0xfff8ff4c,0x000762da,0x003e002e
