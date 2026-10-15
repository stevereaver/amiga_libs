|||
|||	68030_h0.s -- byte-verbatim reconstruction of
|||	68030.library 40.1 (MMU) (THOR MMULib CPU driver,
|||	"$VER: 68030.library 40.1 (4.12.99) (c) 1999 The MMU.lib
|||	development group, THOR"), 2196 bytes, two hunks.
|||
|||	hunk0 .text 0x52c: entry stub, RomTag (AUTOINIT, ver 40,
|||	endskip literal 0), -24 ret0 stub, DeadVector alert stub
|||	(LVOs -30..-216), LibAlertHelper, LibInit (exactly-a-68030
|||	gate: AFF_68040 clear + AFF_68030 set, opens expansion/
|||	utility, FindName input.device, installs patch tables A/B,
|||	mmu.library/GetMMUType + optional 68881 exception vectors,
|||	frees its own base on failure), LibOpen, LibClose (decrement
|||	only, never expunges), LibExpunge (ret0 stub), PatchTable/
|||	UnpatchTable ({liboff.w,vecoff.w,fnoff.w} record drivers
|||	over exec SetFunction under Disable), FPUControl (LVO -222,
|||	disable-protected flag-byte RMW at lib+34), install/unpatch
|||	wrappers, then the patch region: SetFunction target slots,
|||	ColdReboot replacement (supervisor body shuts the 030 PMMU
|||	down -- pmove tc/tt0/tt1 -- then reset + ROM reset vector),
|||	CacheClearU trampolines, INTENA-based GetMsg, BeginIO icache
|||	flush, AddConfigDev alert, InstallExcVecs + supervisor body
|||	(movec vbr, VBR + absolute vector slots), libbase slot, the
|||	seven 68881 exception handlers (memory-indirect PC slots)
|||	and the fsave-frame fixup.
|||
|||	hunk1 .data 0x200: InitTable (dataSize 0x70, functab ->
|||	data+0x10, datatab 0, initfunc -> code+0x4a), 37-entry
|||	absolute-long functab + -1L, strings (incl. dead
|||	mathieeedoubbas/mathieeesingbas names and "$VER: "
|||	prefix), patch tables A (ColdReboot), B (10 SetFunction
|||	records: exec + input.device + expansion.library) and C
|||	(68881 vectors VBR+0xc0..0xd8, flag-gated handlers).
|||
|||	Relocs: code hunk -- group hunk0 [0x424,0x27e,0x278,0x6]
|||	(patch_lib stores + rt_MatchWord), group hunk1
|||	[0x444,0x284,0x290,0x29c,0x12,0x16,0x1a,0x86,0x8e,
|||	0xa6,0xba,0xd6,0xf6] (lea patchtables + rt_Name/IdString/
|||	Init + ln_Name/IdString immediates + lea strings).
|||	DATA hunk -- group hunk0 [0x1c4..0x1f4 step8,0x174,
|||	0x180,0xc..0xa0 step4] (table C handlers + A/B region +
|||	initfunc/functab), group hunk1 [0x4] (InitTable.functab).
|||	Original order is NOT ascending (multi-object link);
|||	source/fixup.py splices the original RELOC32 tails.
|||
|||	Deltas vs the 68020 40.1 sibling (see okf/log.md):
|||	btst #3/#2 CPU gate, two extra pmove's (tt0/tt1) in
|||	super_coldreboot (+8 region shift), "68030.library"
|||	strings, shifted fnoffs/patch slots.

	.text

_entry:					| 0x000 hunk entry: non-resident load
	moveq	#-1,%d0
	rts

_romtag:				| 0x004
	.short	0x4afc			| rt_MatchWord
	.long	_romtag			| rt_MatchTag (reloc hunk0 @6)
	.long	0			| rt_EndSkip = literal 0
	.byte	0x80			| RTF_AUTOINIT
	.byte	40			| rt_Version
	.byte	9			| NT_LIBRARY
	.byte	0			| pri
	.long	_libname		| rt_Name (reloc hunk1 @0x12)
	.long	_idstr			| rt_IdString (reloc hunk1 @0x16)
	.long	_inittab		| rt_Init -> DATA+0 (reloc hunk1 @0x1a)

_ret0:					| 0x01e -- LVO -24 (reserved)
	moveq	#0,%d0
	rts

_DeadVector:				| 0x022 -- LVOs -30..-216
	pea	0x3f000001		| Alert(0x3f000001)
	bsrw	L_alert
	moveq	#0,%d0
	rts

L_alert:				| 0x030 LibAlertHelper
	moveml	%d0-%d1/%d7-%a1/%a5-%a6,%sp@-
	movel	%sp@(32),%d7
	subal	%a5,%a5
	moveal	%a6@(48),%a6		| xb_SysBase
	jsr	%a6@(-108:W)		| Alert
	moveml	%sp@+,%d0-%d1/%d7-%a1/%a5-%a6
	movel	%sp@+,%sp@		| drop pushed code
	rts

_LibInit:				| 0x04a (initfunc; d0=base a0=seg a6=sys)
	moveml	%d2/%a4-%a6,%sp@-
	moveal	%d0,%a4
	movel	%a6,%a4@(48)		| xb_SysBase
	movel	%a0,%a4@(44)		| xb_SegList
	moveb	%a6@(297),%d0		| AttnFlags
	btst	#3,%d0			| AFF_68040 -> reject (040/060)
	bnew	L_fail
	btst	#2,%d0			| require AFF_68030
	beqw	L_fail
	btst	#4,%d0			| AFF_68881
	bnes	L_078
	bset	#0,%a4@(43)		| cpu_flags bit0: no 68881
L_078:
	moveb	#9,%a4@(8)		| ln_Type = NT_LIBRARY
	moveb	#6,%a4@(14)		| ln_Flags = SUMUSED|CHANGED
	movel	#_libname,%a4@(10)	| ln_Name (reloc hunk1 @0x86)
	movel	#_idstr,%a4@(24)	| lib_IdString (reloc hunk1 @0x8e)
	movel	#0x00280001,%a4@(20)	| lib_Version 40 / lib_Revision 1
	movel	#0x54484f52,%a4@(36)	| xb_Magic = 'THOR'
	lea	_expansionname,%a1	| (reloc hunk1 @0xa6)
	moveq	#37,%d0
	jsr	%a6@(-552:W)		| OpenLibrary
	movel	%d0,%a4@(56)		| xb_Expansion
	beqw	L_158
	lea	_utilityname,%a1	| (reloc hunk1 @0xba)
	moveq	#37,%d0
	jsr	%a6@(-552:W)
	movel	%d0,%a4@(52)		| xb_Utility
	beqw	L_150
	jsr	%a6@(-132:W)		| Forbid
	lea	%a6@(350),%a0		| &SysBase->DeviceList
	lea	_inputname,%a1		| (reloc hunk1 @0xd6)
	jsr	%a6@(-276:W)		| FindName
	movel	%d0,%a4@(72)		| xb_Input
	jsr	%a6@(-138:W)		| Permit
	tstl	%d0
	beqs	L_140
	moveal	%a4,%a6
	bsrw	L_install		| slots + PatchTable(A)
	moveal	%a4@(48),%a6		| ExecBase
	lea	_mmuname,%a1		| (reloc hunk1 @0xf6)
	moveq	#0,%d0
	jsr	%a6@(-552:W)		| OpenLibrary(mmu.library,0)
	movel	%d0,%a4@(68)		| xb_MMU
	beqs	L_12c
	moveal	%d0,%a6
	jsr	%a6@(-54:W)		| GetMMUType
	tstb	%d0
	bnes	L_116
	bset	#1,%a4@(43)		| cpu_flags bit1: MMU none
L_116:
	btst	#0,%a4@(43)		| no 68881?
	bnes	L_124
	moveal	%a4,%a6
	bsrw	L_excvec		| InstallExcVecs
L_124:
	moveal	%a4,%a6
	bsrw	L_patchb		| PatchTable(B)
	bras	L_ret
L_12c:
	moveal	%a4,%a6
	pea	0x3f02803e		| Alert: no mmu.library
	bsrw	L_alert
	moveal	%a4,%a6
	bsrw	L_unpatcha		| UnpatchTable(A)
	bras	L_cleanup
L_140:
	pea	0x3f028021		| Alert: no input.device
	bras	L_alertc
	pea	0x3f028005		| (dead alert site, as shipped)
	bras	L_alertc
L_150:
	pea	0x3f02800c		| Alert: no utility.library
	bras	L_alertc
L_158:
	pea	0x3f02800a		| Alert: no expansion.library
L_alertc:
	moveal	%a4,%a6
	bsrw	L_alert
L_cleanup:
	moveal	%a4@(48),%a6		| ExecBase
	movel	%a4@(68),%d0		| xb_MMU
	beqs	L_174
	moveal	%d0,%a1
	jsr	%a6@(-414:W)		| CloseLibrary
L_174:
	movel	%a4@(52),%d0		| xb_Utility
	beqs	L_180
	moveal	%d0,%a1
	jsr	%a6@(-414:W)
L_180:
	movel	%a4@(56),%d0		| xb_Expansion
	beqs	L_fail
	moveal	%d0,%a1
	jsr	%a6@(-414:W)
L_fail:					| 0x18c free the base and fail
	moveal	%a4,%a1
	moveq	#0,%d0
	moveq	#0,%d1
	movew	%a4@(16),%d0		| lib_NegSize
	movew	%a4@(18),%d1		| lib_PosSize
	subal	%d0,%a1
	addl	%d1,%d0
	jsr	%a6@(-210:W)		| FreeMem
	subal	%a4,%a4
L_ret:					| 0x1a4
	movel	%a4,%d0
	moveml	%sp@+,%d2/%a4-%a6
	rts

_LibOpen:				| 0x1ac LVO -6
	bclr	#3,%a6@(14)		| clear LIBF_DELEXP
	addqw	#1,%a6@(32)		| lib_OpenCnt++
	movel	%a6,%d0
	rts

_LibClose:				| 0x1ba LVO -12 (never expunges)
	tstw	%a6@(32)
	beqs	L_1c4
	subqw	#1,%a6@(32)
L_1c4:
	moveq	#0,%d0
	rts

_LibExpunge:				| 0x1c8 LVO -18 (stub)
	moveq	#0,%d0
	rts

_PatchTable:				| 0x1cc (a0=table, a6=libbase)
	moveml	%a2-%a6,%sp@-
	moveal	%a0,%a2
	moveal	%a6,%a4
	moveal	%a2@+,%a3		| region base
	moveal	%a4@(48),%a6		| ExecBase
	jsr	%a6@(-120:W)		| Disable
L_1de:
	movew	%a2@+,%d0		| liboff
	beqs	L_202
	moveal	%a4@(0,%d0:w),%a1	| target library
	moveaw	%a2@+,%a0		| vecoff (sign-extends via moveaw)
	movew	%a2@+,%d0		| fnoff
	lea	%a3@(0,%d0:w),%a5	| new vector
	movel	%a5,%d0
	movel	%a1,%d1
	beqs	L_1fe
	jsr	%a6@(-420:W)		| SetFunction
	movel	%d0,%a5@(-4)		| save old vector in slot
	bras	L_1de
L_1fe:
	movel	%d1,%a5@		| quirk: stores at fn, not fn-4
	bras	L_1de
L_202:
	jsr	%a6@(-126:W)		| Enable
	moveml	%sp@+,%a2-%a6
	rts

_UnpatchTable:				| 0x20c
	moveml	%a2-%a6,%sp@-
	moveal	%a0,%a2
	moveal	%a6,%a4
	moveal	%a2@+,%a3
	moveal	%a4@(48),%a6
	jsr	%a6@(-120:W)		| Disable
L_21e:
	movew	%a2@+,%d0
	beqs	L_23e
	moveal	%a4@(0,%d0:w),%a1
	moveaw	%a2@+,%a0
	movew	%a2@+,%d0
	lea	%a3@(0,%d0:w),%a5
	movel	%a5@(-4),%d0		| old vector
	beqs	L_23c
	movel	%a1,%d1
	beqs	L_23c
	jsr	%a6@(-420:W)		| SetFunction
L_23c:
	bras	L_21e
L_23e:
	jsr	%a6@(-126:W)		| Enable
	moveml	%sp@+,%a2-%a6
	rts

_FPUControl:				| 0x248 LVO -222 (d0=flags d1=mask)
	moveml	%d2/%a4/%a6,%sp@-
	moveal	%a6,%a4
	andl	%d1,%d0			| flags &= mask
	moveal	%a6@(48),%a6		| ExecBase
	moveq	#0,%d2
	jsr	%a6@(-120:W)		| Disable
	notl	%d1
	moveb	%a4@(34),%d2		| old flag byte
	andl	%d2,%d1			| old & ~mask
	orl	%d0,%d1			| | flags
	moveb	%d1,%a4@(34)
	jsr	%a6@(-126:W)		| Enable
	movel	%d2,%d0
	moveml	%sp@+,%d2/%a4/%a6
	rts

L_install:				| 0x274 region slots + PatchTable(A)
	movel	%a6@(48),_patch_sysbase	| abs store (reloc hunk0 @0x278)
	movel	%a6,_patch_lib		| (reloc hunk0 @0x27e)
	lea	_patchtable_a,%a0	| (reloc hunk1 @0x284)
	bsrw	_PatchTable
	rts

L_unpatcha:				| 0x28e UnpatchTable(A)
	lea	_patchtable_a,%a0	| (reloc hunk1 @0x290)
	bsrw	_UnpatchTable
	rts

L_patchb:				| 0x29a PatchTable(B)
	lea	_patchtable_b,%a0	| (reloc hunk1 @0x29c)
	bsrw	_PatchTable
	rts

||| ---- patch region -------------------------------------------------
||| every SetFunction target is a stub preceded by a 4-byte slot that
||| receives the replaced vector; fnoff in the tables points at the
||| stub (slot = fn-4).

_patchbase:				| 0x2a6 region+0
L_coldreboot_old:
	.long	0			| +0x000 old ColdReboot
pf_coldreboot:				| +0x004 ColdReboot (-726)
	moveml	%d7/%a5,%sp@-
	jsr	%a6@(-120:W)		| Disable
	moveq	#0,%d0
	moveq	#-1,%d1
	jsr	%a6@(-648:W)		| CacheControl(0,-1)
	lea	super_coldreboot(%pc),%a5
	jsr	%a6@(-30:W)		| Supervisor
	movel	#0x3f000002,%d7
	subal	%a5,%a5
	jsr	%a6@(-108:W)		| Alert(0x3f000002)
	jsr	%a6@(-126:W)		| Enable
	moveml	%sp@+,%d7/%a5
	rts

super_coldreboot:			| +0x032 (0x2d8)
	oriw	#0x0700,%sr
	moveal	_patch_lib(%pc),%a0
	btst	#1,%a0@(43)		| cpu_flags bit1: MMU present?
	bnes	L_2f8
	clrl	%sp@-
	pmove	%sp@,%tc		| 030 PMMU translation off
	pmove	%sp@,%tt0		| transparent translation 0 off
	pmove	%sp@,%tt1		| transparent translation 1 off
	addql	#4,%sp
L_2f8:
	lea	0x1000000,%a0
	subal	%a0@(-20),%a0		| ROM base via kickstart tag
	moveal	%a0@(4),%a0		| reset PC
	subql	#2,%a0
	bras	L_30c
	.short	0			| dead word, as shipped
L_30c:
	reset				| reset peripherals
	jmp	%a0@			| ROM reset vector

||| ---- CacheClearU trampolines: push old vector, CacheClearU, rts --

L_addlibrary_old:
	.long	0			| +0x06a (0x310)
pf_addlibrary:				| +0x06e AddLibrary (-396)
	movel	L_addlibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)		| CacheClearU
	moveal	%sp@+,%a1
	rts

L_closelibrary_old:
	.long	0			| +0x07c (0x322)
pf_closelibrary:			| +0x080 CloseLibrary (-414)
	movel	L_closelibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	moveal	%sp@+,%a1
	rts

L_adddevice_old:
	.long	0			| +0x08e (0x334)
pf_adddevice:				| +0x092 AddDevice (-432)
	movel	L_adddevice_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	moveal	%sp@+,%a1
	rts

L_addresource_old:
	.long	0			| +0x0a0 (0x346)
pf_addresource:				| +0x0a4 AddResource (-486)
	movel	L_addresource_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	moveal	%sp@+,%a1
	rts

L_addtask_old:
	.long	0			| +0x0b2 (0x358)
pf_addtask:				| +0x0b6 AddTask (-282)
	movel	L_addtask_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	moveal	%sp@+,%a1
	rts

L_addintserver_old:
	.long	0			| +0x0c4 (0x36a)
pf_addintserver:			| +0x0c8 AddIntServer (-168)
	movel	L_addintserver_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

L_getmsg_old:
	.long	0			| +0x0da (0x380)
pf_getmsg:				| +0x0de GetMsg (-372), INTENA-based
	lea	%a0@(20),%a0		| &port->mp_MsgList.lh_Head
	movew	#0x4000,0xdff09a	| INTENA master off
	moveal	%a0@,%a1		| first node
	addqb	#1,%a6@(294)		| IDNestCnt++
	movel	%a1@,%d0		| node->ln_Succ
	beqs	L_3a2			| empty -> 0 (single-elt quirk)
	movel	%d0,%a0@		| lh_Head = succ
	exg	%d0,%a1			| d0 = node, a1 = succ
	movel	%a0,%a1@(4)		| succ->ln_Pred = &lh_Head
L_3a2:
	subqb	#1,%a6@(294)		| IDNestCnt--
	bges	L_3b2
	movew	#0xc000,0xdff09a	| INTENA master on
	nop
L_3b2:
	rts

L_setintvector_old:
	.long	0			| +0x10e (0x3b4)
pf_setintvector:			| +0x112 SetIntVector (-162)
	movel	L_setintvector_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

||| ---- shared slots for the non-exec vector patches -----------------

_patch_sysbase:				| +0x124 (0x3ca)
	.long	0			| ExecBase copy (L_install)
	.long	0			| unused pad slot, as shipped

L_beginio_old:
	.long	0			| +0x12c (0x3d2) old BeginIO
pf_beginio:				| +0x130 input.device -30
	movel	L_beginio_old(%pc),%sp@-
	cmpiw	#9,%a1@(28)		| io_Command == IND_ADDHANDLER?
	bnes	L_3f2
	moveml	%a1/%a6,%sp@-
	moveal	_patch_sysbase(%pc),%a6
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a1/%a6
L_3f2:
	rts

L_addconfigdev_old:
	.long	0			| +0x14e (0x3f4) old AddConfigDev
pf_addconfigdev:			| +0x152 expansion.library -30
	movel	L_addconfigdev_old(%pc),%sp@-
	moveml	%d0-%d1/%d7/%a5-%a6,%sp@-
	moveal	_patch_sysbase(%pc),%a6
	movel	#0x3f000015,%d7
	subal	%a5,%a5
	jsr	%a6@(-108:W)		| Alert(0x3f000015) recoverable
	moveml	%sp@+,%d0-%d1/%d7/%a5-%a6
	rts

	.short	0			| +0x170 (0x416) dead pad word

||| ---- 68881 exception-vector installer -----------------------------

L_excvec:				| +0x172 (0x418) InstallExcVecs
	moveml	%a2/%a4-%a6,%sp@-
	moveal	%a6,%a4
	lea	super_excvec(%pc),%a5
	movel	%a4,_patch_lib		| (reloc hunk0 @0x424)
	moveal	%a4@(48),%a6		| ExecBase
	jsr	%a6@(-30:W)		| Supervisor(super_excvec)
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a2/%a4-%a6
	rts

super_excvec:				| +0x194 (0x43a)
	oriw	#0x0700,%sr
	movec	%vbr,%a0
	lea	_patchtable_c,%a1	| (reloc hunk1 @0x444)
L_448:
	movel	%a1@+,%d0		| new handler
	beqs	L_462
	moveal	%d0,%a2
	movemw	%a1@+,%d0-%d1		| d0=vbr offset, d1=save offset
	.short	0x29b0,0x0000,0x1000	| movel a0@(0,d0:w),a4@(0,d1:w)
	movel	%a2,%a0@(0,%d0:w)	| VBR slot <- handler
	.short	0x218a,0x0190		| movel a2,@(0,d0:w): abs slot too
	bras	L_448
L_462:
	rte

_patch_lib:				| +0x1be (0x464)
	.long	0			| library base slot

||| ---- 68881 handlers: flag-gated tail calls -------------------------
||| the btst/movel memory-indirect PC operands are not expressible in
||| gas; verbatim .short sequences, bd = patch_lib - (ext word addr).

pf_trap3:				| +0x1c2 (0x468) FPUnderflow, bit3
	.short	0x083b,0x0003,0x0162
	.short	_patch_lib - . + 2	| bd -> _patch_lib
	.short	0x0022			| od = lib+0x22 (flag byte)
	bnes	L_47e
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x005c			| od = saved vector lib+0x5c
	rts
L_47e:
	braw	pf_fsavefix

pf_trap0:				| +0x1dc (0x482) FPBSUN, bit0
	.short	0x083b,0x0000,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	L_498
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0050			| lib+0x50
	rts
L_498:
	bras	pf_fsavefix

pf_trap5:				| +0x1f4 (0x49a) FPOverflow, bit4
	.short	0x083b,0x0004,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	L_4b0
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0064			| lib+0x64
	rts
L_4b0:
	bras	pf_fsavefix

pf_trap6:				| +0x20c (0x4b2) FPSignalNaN, bit5
	.short	0x083b,0x0005,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	L_4c8
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0068			| lib+0x68
	rts
L_4c8:
	bras	pf_fsavefix

pf_trap4:				| +0x224 (0x4ca) FPOperandErr, bit6
	.short	0x083b,0x0006,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	L_4e0
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0060			| lib+0x60
	rts
L_4e0:
	bras	pf_fsavefix

pf_trap1:				| +0x23c (0x4e2) FPInexact, bit1
	.short	0x083b,0x0001,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	L_4f8
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0054			| lib+0x54
	rts
L_4f8:
	bras	pf_fsavefix

pf_trap2:				| +0x254 (0x4fa) FPDivZero, bit2
	.short	0x083b,0x0002,0x0162
	.short	_patch_lib - . + 2
	.short	0x0022
	bnes	pf_fsavefix		| short jump reaches directly
	.short	0x2f3b,0x0162
	.short	_patch_lib - . + 2
	.short	0x0058			| lib+0x58
	rts

pf_fsavefix:				| +0x26a (0x510) fsave-frame fixup
	movel	%d0,%sp@-
	fsave	%sp@-
	tstb	%sp@			| null frame?
	beqs	L_524
	moveq	#0,%d0
	moveb	%sp@(1),%d0		| frame size byte
	bset	#3,%sp@(0,%d0:w)	| mark the frame
L_524:
	frestore %sp@+
	movel	%sp@+,%d0
	rte
	.short	0			| +0x52a tail pad (hunk is 0x52c)

||| ==================================================================
||| hunk1 .data 0x200
||| ==================================================================

	.data

_inittab:				| data+0x00 InitTable
	.long	0x70			| dataSize
	.long	_functab		| (reloc hunk1 @4)
	.long	0			| datatab NULL
	.long	_LibInit		| initfunc -> code+0x4a (reloc hunk0 @0xc)

_functab:				| data+0x10, absolute longs
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	_ret0			| -24
	.long	_DeadVector		| -30
	.long	_DeadVector		| -36
	.long	_DeadVector		| -42
	.long	_DeadVector		| -48
	.long	_DeadVector		| -54
	.long	_DeadVector		| -60
	.long	_DeadVector		| -66
	.long	_DeadVector		| -72
	.long	_DeadVector		| -78
	.long	_DeadVector		| -84
	.long	_DeadVector		| -90
	.long	_DeadVector		| -96
	.long	_DeadVector		| -102
	.long	_DeadVector		| -108
	.long	_DeadVector		| -114
	.long	_DeadVector		| -120
	.long	_DeadVector		| -126
	.long	_DeadVector		| -132
	.long	_DeadVector		| -138
	.long	_DeadVector		| -144
	.long	_DeadVector		| -150
	.long	_DeadVector		| -156
	.long	_DeadVector		| -162
	.long	_DeadVector		| -168
	.long	_DeadVector		| -174
	.long	_DeadVector		| -180
	.long	_DeadVector		| -186
	.long	_DeadVector		| -192
	.long	_DeadVector		| -198
	.long	_DeadVector		| -204
	.long	_DeadVector		| -210
	.long	_DeadVector		| -216
	.long	_FPUControl		| -222
	.long	-1

_libname:				| data+0xa8
	.ascii	"68030.library"
	.byte	0
_mmuname:				| data+0xb6
	.ascii	"mmu.library"
	.byte	0
_utilityname:				| data+0xc2
	.ascii	"utility.library"
	.byte	0
_expansionname:				| data+0xd2
	.ascii	"expansion.library"
	.byte	0
	.ascii	"mathieeedoubbas.library"	| data+0xe4 (dead string)
	.byte	0
	.ascii	"mathieeesingbas.library"	| data+0xfc (dead string)
	.byte	0
_inputname:				| data+0x114
	.ascii	"input.device"
	.byte	0
	.ascii	"$VER: "			| data+0x121
_idstr:					| data+0x127
	.ascii	"68030.library 40.1 (4.12.99) (c) 1999 The MMU.lib development group, THOR"
	.byte	10,13,0,0		| -> data+0x174

||| ---- patch record tables (region slots at fn-4 receive old vector) -

_patchtable_a:				| data+0x174
	.long	_patchbase		| region (reloc hunk0 @0x174)
	.word	0x30,-726,4		| exec ColdReboot -> pf_coldreboot
	.word	0

_patchtable_b:				| data+0x180
	.long	_patchbase		| (reloc hunk0 @0x180)
	.word	0x30,-396,0x6e		| AddLibrary
	.word	0x30,-414,0x80		| CloseLibrary
	.word	0x30,-432,0x92		| AddDevice
	.word	0x30,-486,0xa4		| AddResource
	.word	0x30,-282,0xb6		| AddTask
	.word	0x30,-168,0xc8		| AddIntServer
	.word	0x30,-162,0x112		| SetIntVector
	.word	0x30,-372,0xde		| GetMsg
	.word	0x48,-30,0x130		| input.device BeginIO
	.word	0x38,-30,0x152		| expansion AddConfigDev
	.word	0

	.balign	4			| pad to data+0x1c4
_patchtable_c:				| data+0x1c4 68881 vectors 48-54
	.long	pf_trap5		| (reloc hunk0 @0x1c4)
	.word	0xd4,0x64		| VBR+0xd4 FPOverflow -> lib+0x64
	.long	pf_trap3		| (reloc hunk0 @0x1cc)
	.word	0xcc,0x5c		| VBR+0xcc FPUnderflow -> lib+0x5c
	.long	pf_trap6		| (reloc hunk0 @0x1d4)
	.word	0xd8,0x68		| VBR+0xd8 FPSignalNaN -> lib+0x68
	.long	pf_trap4		| (reloc hunk0 @0x1dc)
	.word	0xd0,0x60		| VBR+0xd0 FPOperandErr -> lib+0x60
	.long	pf_trap0		| (reloc hunk0 @0x1e4)
	.word	0xc0,0x50		| VBR+0xc0 FPBSUN -> lib+0x50
	.long	pf_trap1		| (reloc hunk0 @0x1ec)
	.word	0xc4,0x54		| VBR+0xc4 FPInexact -> lib+0x54
	.long	pf_trap2		| (reloc hunk0 @0x1f4)
	.word	0xc8,0x58		| VBR+0xc8 FPDivZero -> lib+0x58
	.long	0

	.end
