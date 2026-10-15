|||
|||	68020_patch.s -- alert helper, dead-vector stub and the
|||	patch-function region for 68020.library 43.2 (MMU)
|||	(The MMU.lib development group, THOR).
|||
|||	The original binary keeps a contiguous "patch region" that
|||	starts with a code-hunk slot storing ExecBase and ends with
|||	the 68881 exception handlers.  Each installed patch
|||	function is preceded by a 4-byte slot holding the vector it
|||	replaced (SetFunction's return value); the stubs push that
|||	slot and "rts" into the original vector.
|||
|||	Layout reproduces the shipped offsets exactly because the
|||	patch tables in the data hunk address the region by offset:
|||
|||	  +0x000  slot: old ColdReboot
|||	  +0x004  ColdReboot replacement (supervisor: PMMU off,
|||	          CACR/VBR cleared, reset, jump to ROM reset vector)
|||	  +0x032  supervisor function used by ColdReboot
|||	  +0x06c  slot + CacheClearU trampolines: AddLibrary(0x70),
|||	          CloseLibrary(0x82), AddDevice(0x94),
|||	          AddResource(0xa6), AddTask(0xb8)
|||	  +0x0ca  AddIntServer trampoline (moveml variant)
|||	  +0x0e0  GetMsg replacement (INTENA-based, no Forbid,
|||	          early empty-list check)
|||	  +0x11c  exec -36 trampoline: tail call, reads INTREQR
|||	  +0x12c  SetIntVector trampoline (moveml variant)
|||	  +0x13e  slot: ExecBase for the patches that run with a6
|||	          = other library (input.device)
|||	  +0x142  unused pad slot
|||	  +0x146  slot: old input.device/BeginIO
|||	  +0x14a  BeginIO patch: flush icache on IND_ADDHANDLER (cmd 9)
|||	  +0x16a  InstallExcVecs wrapper (installs the 68881
|||	          handlers through Supervisor + CacheClearU)
|||	  +0x18c  supervisor function writing VBR and absolute
|||	          (VBR=0) exception vectors from table C
|||	  +0x1b6  slot: this library's base
|||	  +0x1ba  68881 handlers for vectors 48-54 (flag-gated
|||	          tail calls to the saved vectors)
|||	  +0x262  68881 fsave-frame fixup + rte
|||

	.section .text

	.globl	_LibAlert
	.globl	_DeadVector
	.globl	_patchbase
	.globl	_patch_sysbase
	.globl	_patch_lib

||| -----------------------------------------------------------------
||| _LibAlert -- C-callable alert drop-in: pushes d0 and slips into
||| LibAlertHelper exactly like the shipped "pea code / bsr" sites.
||| -----------------------------------------------------------------

_LibAlert:
	movel	%d0,%sp@-
	bsr	LibAlertHelper
	rts

||| LibAlertHelper: expects stack [ret][code], a6 = library base.
||| Restores ExecBase from lib+48, Alert(code) in d7 with a5 = 0,
||| then slides the return address over the pushed code.

LibAlertHelper:
	moveml	%d0-%d1/%d7-%a1/%a5-%a6,%sp@-
	movel	%sp@(32),%d7
	subal	%a5,%a5
	movel	%a6@(48),%a6
	jsr	%a6@(-108:W)		| Alert
	moveml	%sp@+,%d0-%d1/%d7-%a1/%a5-%a6
	movel	%sp@+,%sp@		| drop the pushed code
	rts

||| -----------------------------------------------------------------
||| _DeadVector -- LVO -30 .. -216 stub: Alert(0x3f000001), return 0.
||| -----------------------------------------------------------------

_DeadVector:
	pea	0x3f000001
	bsr	LibAlertHelper
	moveq	#0,%d0
	rts

||| -----------------------------------------------------------------
||| patch region -- the SetFunction target stubs
||| -----------------------------------------------------------------

	.align	2
_patchbase:

||| ---- ColdReboot (-726) -------------------------------------------

_patch_coldreboot_old:
	.long	0			| +0x000 old vector slot
	.globl pf_coldreboot
pf_coldreboot:				| +0x004
	moveml	%d7/%a5,%sp@-
	jsr	%a6@(-120:W)		| Disable
	moveq	#0,%d0
	moveq	#-1,%d1
	jsr	%a6@(-648:W)		| CacheControl(0,-1) all off
	lea	super_coldreboot(%pc),%a5
	jsr	%a6@(-30:W)		| Supervisor
	movel	#0x3f000002,%d7
	subal	%a5,%a5
	jsr	%a6@(-108:W)		| Alert(0x3f000002): reboot failed
	jsr	%a6@(-126:W)		| Enable
	moveml	%sp@+,%d7/%a5
	rts

super_coldreboot:			| +0x032
	oriw	#0x0700,%sr
	movel	_patch_lib(%pc),%a0
	btst	#1,%a0@(43)		| cpu_flags bit1: MMU present?
	bnes	1f
	clrl	%sp@-
	pmove	%sp@,%tc		| 68851/030 PMMU: translation off
	addql	#4,%sp
1:
	moveq	#0,%d0
	movec	%d0,%cacr		| caches off
	movec	%d0,%vbr		| VBR back to $00000000
	lea	0x1000000,%a0
	subal	%a0@(-20),%a0		| ROM base from kickstart tag
	movel	%a0@(4),%a0		| reset PC
	subql	#2,%a0
	bras	2f
3:
	reset				| reset peripherals
	jmp	%a0@			| enter ROM reset code
2:
	bras	3b

||| ---- CacheClearU trampolines -------------------------------------
||| pattern A: push old vector, CacheClearU, tail-call original

_patch_addlibrary_old:
	.long	0			| +0x06c
	.globl pf_addlibrary
pf_addlibrary:				| +0x070 AddLibrary (-396)
	movel	_patch_addlibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)		| CacheClearU
	movel	%sp@+,%a1
	rts

_patch_closelibrary_old:
	.long	0			| +0x07e
	.globl pf_closelibrary
pf_closelibrary:			| +0x082 CloseLibrary (-414)
	movel	_patch_closelibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_adddevice_old:
	.long	0			| +0x090
	.globl pf_adddevice
pf_adddevice:				| +0x094 AddDevice (-432)
	movel	_patch_adddevice_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_addresource_old:
	.long	0			| +0x0a2
	.globl pf_addresource
pf_addresource:				| +0x0a6 AddResource (-486)
	movel	_patch_addresource_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_addtask_old:
	.long	0			| +0x0b4
	.globl pf_addtask
pf_addtask:				| +0x0b8 AddTask (-282)
	movel	_patch_addtask_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

||| pattern B: same idea but the stubs save d0/a1 around CacheClearU

_patch_addintserver_old:
	.long	0			| +0x0c6
	.globl pf_addintserver
pf_addintserver:			| +0x0ca AddIntServer (-168)
	movel	_patch_addintserver_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

||| ---- GetMsg (-372): INTENA-based reimplementation -----------------
||| 43.2 adds an early out when the port list is empty (lh_TailPred ==
||| &lh_Head) so INTENA is not touched at all.  The single-element
||| quirk from 40.1 remains: a list whose head node's ln_Succ is 0
||| still returns 0 without unlinking.

_patch_getmsg_old:
	.long	0			| +0x0dc
	.globl pf_getmsg
pf_getmsg:				| +0x0e0 GetMsg (-372)
	lea	%a0@(20),%a0		| &port->mp_MsgList.lh_Head
	cmpal	%a0@(8),%a0		| lh_TailPred == &lh_Head?
	beqs	3f			| empty -> return 0
	movew	#0x4000,0xdff09a	| INTENA: master enable off
	movel	%a0@,%a1		| first node
	addqb	#1,%a6@(294)		| IDNestCnt++
	movel	%a1@,%d0		| node->ln_Succ
	beqs	1f			| no successor -> 0
	movel	%d0,%a0@		| lh_Head = succ
	exg	%d0,%a1			| d0 = node, a1 = succ
	movel	%a0,%a1@(4)		| succ->ln_Pred = &lh_Head
1:
	subqb	#1,%a6@(294)		| IDNestCnt--
	bges	2f
	movew	#0xc000,0xdff09a	| INTENA: master enable on
2:
	rts
3:
	moveq	#0,%d0
	rts

||| ---- exec -36 (unpublished internal slot) -------------------------
||| Tail call to the old vector after reading INTREQR; the tstw only
||| sets flags that the rts/tail call never consumes -- as shipped.

_patch_lvo36_old:
	.long	0			| +0x118
	.globl pf_lvo36
pf_lvo36:				| +0x11c exec internal slot -36
	movel	_patch_lvo36_old(%pc),%sp@-
	tstw	0xdff01e		| INTREQR, result unused
	rts

||| ---- SetIntVector (-162) ------------------------------------------

_patch_setintvector_old:
	.long	0			| +0x128
	.globl pf_setintvector
pf_setintvector:			| +0x12c
	movel	_patch_setintvector_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

||| ---- slots shared by the non-exec vector patches ------------------

_patch_sysbase:				| +0x13e (0x3e4 in the original)
	.long	0			| ExecBase, stored by InstallPatches
	.long	0			| +0x142 unused pad slot, as shipped

_patch_beginio_old:
	.long	0			| +0x146 input.device old BeginIO
	.globl pf_beginio
pf_beginio:				| +0x14a input.device -30 (BeginIO)
	movel	_patch_beginio_old(%pc),%sp@-
	cmpiw	#9,%a1@(28)		| io_Request.io_Command == IND_ADDHANDLER?
	bnes	1f
	moveml	%a1/%a6,%sp@-
	movel	_patch_sysbase(%pc),%a6
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a1/%a6
1:
	rts

||| ---- exception vector installer -----------------------------------

	.word	0			| +0x168 dead pad word, as shipped

	.globl	_InstallExcVecs
_InstallExcVecs:			| +0x16a (a6 = library base)
	moveml	%a2/%a4-%a6,%sp@-
	movel	%a6,%a4
	lea	super_excvec(%pc),%a5
	movel	%a4,_patch_lib		| keep libbase in the slot
	movel	%a4@(48),%a6		| ExecBase
	jsr	%a6@(-30:W)		| Supervisor(super_excvec)
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a2/%a4-%a6
	rts

||| supervisor body: install the 68881 exception handlers into both
||| the VBR-based vector table and the absolute low-memory copy
||| (covers VBR = 0).  Exits with rte -- exec's Supervisor entry
||| frame carries SR.

super_excvec:				| +0x18c
	oriw	#0x0700,%sr
	movec	%vbr,%a0
	lea	_patchtable_c,%a1	| {newfn, vbroff.w, saveoff.w}+
1:
	movel	%a1@+,%d0
	beqs	2f
	movel	%d0,%a2		| new handler
	movemw	%a1@+,%d0-%d1	| d0 = vbr offset, d1 = lib save offset
	.word	0x29b0,0x0000,0x1000	| movel a0@(0,d0:w),a4@(0,d1:w): save old
	movel	%a2,%a0@(0,%d0:w)		| VBR slot <- handler
	.word	0x218a,0x0190			| movel a2,@(0,d0:w): abs slot too
	bras	1b
2:
	rte

||| ---- the library-base slot + 68881 exception handlers -------------

_patch_lib:				| +0x1b6 (0x45c in the original)
	.long	0			| library base, stored by init

||| each handler: if flag bitN of the byte at lib+22 is set, run the
||| fsave-frame fixup; otherwise tail-call the saved original vector.
||| Encoded as .word sequences -- the memory-indirect PC operands are
||| not expressible in gas syntax.  The "bnes -> bra" double jump and
||| the handler lengths reproduce the shipped layout exactly.

	.globl pf_trap3
pf_trap3:				| +0x1ba (0x460) FPUnderflow, flag bit3
	.word	0x083b,0x0003,0x0162
	.word	_patch_lib - . + 2	| bd -> _patch_lib
	.word	0x0022			| od = 22
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x005c			| od = save offset lib+0x5c
	rts
1:
	bra.w	pf_fsavefix

	.globl pf_trap0
pf_trap0:				| +0x1d4 (0x47a) FPBSUN, flag bit0
	.word	0x083b,0x0000,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0050			| lib+0x50
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap5
pf_trap5:				| +0x1e8 (0x492) FPOverflow, flag bit4
	.word	0x083b,0x0004,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0064			| lib+0x64
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap6
pf_trap6:				| +0x1fc (0x4aa) FPSignalNaN, flag bit5
	.word	0x083b,0x0005,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0068			| lib+0x68
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap4
pf_trap4:				| +0x210 (0x4c2) FPOperandErr, flag bit6
	.word	0x083b,0x0006,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0060			| lib+0x60
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap1
pf_trap1:				| +0x224 (0x4da) FPInexact, flag bit1
	.word	0x083b,0x0001,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0054			| lib+0x54
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap2
pf_trap2:				| +0x238 (0x4f2) FPDivZero, flag bit2
	.word	0x083b,0x0002,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	pf_fsavefix		| short jump reaches pf_fsavefix
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0058			| lib+0x58
	rts

||| ---- common handler: 68881 fsave-frame fixup ----------------------

pf_fsavefix:				| +0x262 (0x508)
	movel	%d0,%sp@-
	fsave	%sp@-
	tstb	%sp@			| null frame?
	beqs	1f
	moveq	#0,%d0
	moveb	%sp@(1),%d0		| frame size/vector byte
	bset	#3,%sp@(0,%d0:w)	| mark the frame
1:
	frestore %sp@+
	movel	%sp@+,%d0
	rte

	.end
