|||||
|||||	68030_patch.s -- alert helper, dead-vector stub, the
|||||	patch-function region and the 46.5 init helpers for
|||||	68030.library 46.5 (MMU) (The MMU.lib development group,
|||||	THOR, (28.07.2018)).
|||||
|||||	The original binary keeps a contiguous "patch region" that
|||||	starts with a code-hunk slot storing ExecBase and ends with
|||||	the 68881 exception handlers.  Each installed patch
|||||	function is preceded by a 4-byte slot holding the vector it
|||||	replaced (SetFunction's return value); the stubs push that
|||||	slot and "rts" into the original vector.
|||||
|||||	Layout reproduces the shipped structure exactly because the
|||||	patch tables in the data hunk address the region by offset:
|||||
|||||	  +0x000  slot: old ColdReboot
|||||	  +0x004  ColdReboot replacement (supervisor: TT regs set,
|||||	          PMMU off, CACR/VBR cleared, reset, jump to ROM
|||||	          reset vector)
|||||	  +0x032  supervisor function used by ColdReboot
|||||	  +0x098  slot + CacheClearU trampolines: AddLibrary,
|||||	          CloseLibrary, AddDevice, AddResource, AddTask
|||||	  +0x0f6  AddIntServer trampoline (moveml variant)
|||||	  +0x10c  GetMsg replacement (INTENA-based, no Forbid,
|||||	          early empty-list check)
|||||	  +0x148  exec -36 trampoline: tail call, reads INTREQR
|||||	  +0x158  SetIntVector trampoline (moveml variant)
|||||	  +0x16a  slot: ExecBase for the patches that run with a6
|||||	          = other library (input.device)
|||||	  +0x16e  unused pad slot
|||||	  +0x172  slot: old input.device/BeginIO
|||||	  +0x176  BeginIO patch: flush icache on IND_ADDHANDLER (cmd 9)
|||||	  +0x194  dead pad word
|||||	  +0x196  InstallExcVecs wrapper (installs the 68881
|||||	          handlers through Supervisor + CacheClearU)
|||||	  +0x1b8  supervisor function writing VBR and absolute
|||||	          exception vectors from table C
|||||	  +0x1e2  slot: this library's base
|||||	  +0x1e6  68881 handlers for vectors 48-54 (flag-gated
|||||	          tail calls to the saved vectors)
|||||	  +0x28e  68881 fsave-frame fixup + rte
|||||
|||||	Init helpers unique to this build: _SuperTT performs a
|||||	Supervisor() call writing the 68030 transparent-translation
|||||	registers (TT0 = 0x00008514, TT1 = 0x00ff0125) when
|||||	GetMMUType reports NONE, _CopyMMUObj runs the
|||||	mmu.library -150/-282 object copy and _P5EmuExpunge the
|||||	expunge of p5emu.library via its -24 vector.  Init calls
|||||	CacheControl(0x2101,0x2101) between the two -- the only
|||||	code change from 46.3 besides the revision.

	.section .text

	.globl	_LibAlert
	.globl	_LibNull
	.globl	_DeadVector
	.globl	_patchbase
	.globl	_patch_sysbase
	.globl	_patch_lib
	.globl	_SuperTT
	.globl	_CopyMMUObj
	.globl	_P5EmuExpunge

||||| -----------------------------------------------------------------
||||| _LibAlert -- C-callable alert drop-in: pushes d0 and slips into
||||| LibAlertHelper exactly like the shipped "pea code / bsr" sites.
||||| -----------------------------------------------------------------

_LibAlert:
	movel	%d0,%sp@-
	bsr	LibAlertHelper
	rts

||||| LibAlertHelper: expects stack [ret][code], a6 = library base.
||||| Restores ExecBase from lib+48, Alert(code) in d7 with a5 = 0,
||||| then slides the return address over the pushed code.

LibAlertHelper:
	moveml	%d0-%d1/%d7-%a1/%a5-%a6,%sp@-
	movel	%sp@(32),%d7
	subal	%a5,%a5
	movel	%a6@(48),%a6
	jsr	%a6@(-108:W)		| Alert
	moveml	%sp@+,%d0-%d1/%d7-%a1/%a5-%a6
	movel	%sp@+,%sp@		| drop the pushed code
	rts

||||| -----------------------------------------------------------------
||||| _LibNull -- LVO -24 reserved stub: return 0.
||||| _DeadVector -- LVO -30 .. -216 stub: Alert(0x3f000001), return 0.
||||| -----------------------------------------------------------------

_LibNull:
	moveq	#0,%d0
	rts

_DeadVector:
	pea	0x3f000001
	bsr	LibAlertHelper
	moveq	#0,%d0
	rts

||||| -----------------------------------------------------------------
||||| _SuperTT -- the 68030-specific NOMMU setup run inside
||||| Supervisor(): writes the PMMU transparent-translation registers
||||| TT0 = 0x00008514 and TT1 = 0x00ff0125 and returns via rte.
||||| a6 = library base on entry (init convention: a4 = lib inside).
||||| -----------------------------------------------------------------

_SuperTT:
	moveml	%a5,%sp@-
	moveal	%a6@(48),%a6		| ExecBase
	lea	super_tt(%pc),%a5
	jsr	%a6@(-30:W)		| Supervisor(super_tt)
	moveml	%sp@+,%a5
	rts

super_tt:
	movel	#0x00008514,%sp@-
	.word	0xf017,0x0800		| pmove %sp@,%tt0
	nop
	movel	#0x00ff0125,%sp@
	.word	0xf017,0x0c00		| pmove %sp@,%tt1
	addql	#4,%sp
	nop
	rte

||||| -----------------------------------------------------------------
||||| _CopyMMUObj -- first post-PatchTable init step, a separate
||||| function in the shipped binary.  a6 = library base on entry.
||||| Calls mmu.library -150; on success calls mmu -282 twice on the
||||| result with ids 0x83e00403 / 0x83e00405 and copies 16 bytes
||||| from the first object into the second.
||||| -----------------------------------------------------------------

_CopyMMUObj:
	moveml	%a2-%a3,%sp@-
	moveal	%a6,%a4

	moveal	%a4@(68),%a6		| mmu.library base
	jsr	%a6@(-150:W)		| mmu -150 -> d0 (object)
	tstl	%d0
	beqs	2f
	moveal	%d0,%a3
	moveal	%d0,%a0
	movel	#0x83e00403,%d0
	jsr	%a6@(-282:W)		| mmu -282(obj, 0x83e00403) -> src
	moveal	%d0,%a2
	moveal	%a3,%a0
	movel	#0x83e00405,%d0
	jsr	%a6@(-282:W)		| mmu -282(obj, 0x83e00405) -> dst
	tstl	%d0
	beqs	2f
	moveal	%d0,%a0
	movel	%a2@,%a0@		| copy 16 bytes src -> dst
	movel	%a2@(4),%a0@(4)
	movel	%a2@(8),%a0@(8)
	movel	%a2@(12),%a0@(12)
2:
	moveml	%sp@+,%a2-%a3
	rts

||||| -----------------------------------------------------------------
||||| _P5EmuExpunge -- second post-PatchTable init step.  a6 =
||||| library base.  Forbid, FindName(&SysBase->LibList,
||||| "p5emu.library") and call its -24 vector with a1 = this
||||| library's base; Permit.
||||| -----------------------------------------------------------------

_P5EmuExpunge:
	moveal	%a6,%a4
	moveal	%a4@(48),%a6		| ExecBase
	jsr	%a6@(-132:W)		| Forbid
	lea	%a6@(378),%a0		| &SysBase->LibList
	lea	_p5emuname,%a1		| "p5emu.library" (data hunk)
	jsr	%a6@(-276:W)		| FindName
	tstl	%d0
	beqs	3f
	moveal	%a4,%a1			| a1 = this library's base
	moveal	%d0,%a6			| a6 = p5emu.library base
	jsr	%a6@(-24:W)		| call p5emu -24 (Expunge)
	moveal	%a4@(48),%a6		| restore ExecBase
3:
	jsr	%a6@(-138:W)		| Permit
	rts

||||| -----------------------------------------------------------------
||||| patch region -- the SetFunction target stubs
||||| -----------------------------------------------------------------

	.align	2
_patchbase:

||||| ---- ColdReboot (-726) -------------------------------------------

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
	movel	#0x00ff8707,%sp@-
	.word	0xf017,0x0800		| pmove %sp@,%tt0
	.word	0xf017,0x0c00		| pmove %sp@,%tt1
	addql	#4,%sp
	movel	_patch_lib(%pc),%a0
	btst	#1,%a0@(43)		| cpu_flags bit1: no MMU?
	bnes	1f
	clrl	%sp@-
	.word	0xf017,0x4000		| pmove %sp@,%tc: PMMU off
	addql	#4,%sp
1:
	moveq	#0,%d0
	movec	%d0,%cacr		| caches off
	movec	%d0,%vbr		| VBR back to $00000000
	nop
	lea	0x1000000,%a0
	lea	super_coldreboot(%pc),%a1
	subal	%a0@(-20),%a0		| ROM base from kickstart tag
	movel	%a0@(4),%a0		| reset PC
	cmpiw	#0x4e70,%a0@(-2)	| reset instruction in front?
	bnes	2f
	subql	#2,%a0			| yes: include it in the jump
2:
	cmpal	#0x200000,%a1		| patch code >= 2 MB?
	bras	5f
	nop				| dead bytes, as shipped
	.word	0
5:
	bras	4f
3:
	reset				| reset peripherals
	jmp	%a0@			| enter ROM reset code
4:
	bccs	3b			| a1 >= 2MB: reset first
	jmp	%a0@			| a1 < 2MB: jump straight in

||||| ---- CacheClearU trampolines -------------------------------------
||||| pattern A: push old vector, CacheClearU, tail-call original

_patch_addlibrary_old:
	.long	0
	.globl pf_addlibrary
pf_addlibrary:				| +0x09c AddLibrary (-396)
	movel	_patch_addlibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)		| CacheClearU
	movel	%sp@+,%a1
	rts

_patch_closelibrary_old:
	.long	0
	.globl pf_closelibrary
pf_closelibrary:			| +0x0ae CloseLibrary (-414)
	movel	_patch_closelibrary_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_adddevice_old:
	.long	0
	.globl pf_adddevice
pf_adddevice:				| +0x0c0 AddDevice (-432)
	movel	_patch_adddevice_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_addresource_old:
	.long	0
	.globl pf_addresource
pf_addresource:				| +0x0d2 AddResource (-486)
	movel	_patch_addresource_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

_patch_addtask_old:
	.long	0
	.globl pf_addtask
pf_addtask:				| +0x0e4 AddTask (-282)
	movel	_patch_addtask_old(%pc),%sp@-
	movel	%a1,%sp@-
	jsr	%a6@(-636:W)
	movel	%sp@+,%a1
	rts

||||| pattern B: same idea but the stubs save d0/a1 around CacheClearU

_patch_addintserver_old:
	.long	0
	.globl pf_addintserver
pf_addintserver:			| +0x0f6 AddIntServer (-168)
	movel	_patch_addintserver_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

||||| ---- GetMsg (-372): INTENA-based reimplementation -----------------
||||| keeps the early out when the port list is empty (lh_TailPred ==
||||| &lh_Head) so INTENA is not touched at all, and the single-element
||||| quirk: a list whose head node's ln_Succ is 0 returns 0 without
||||| unlinking.

_patch_getmsg_old:
	.long	0
	.globl pf_getmsg
pf_getmsg:				| +0x10c GetMsg (-372)
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

||||| ---- exec -36 (unpublished internal slot) -------------------------
||||| Tail call to the old vector after reading INTREQR; the tstw only
||||| sets flags that the rts/tail call never consumes -- as shipped.

_patch_lvo36_old:
	.long	0
	.globl pf_lvo36
pf_lvo36:				| +0x148 exec internal slot -36
	movel	_patch_lvo36_old(%pc),%sp@-
	tstw	0xdff01e		| INTREQR, result unused
	rts

||||| ---- SetIntVector (-162) ------------------------------------------

_patch_setintvector_old:
	.long	0
	.globl pf_setintvector
pf_setintvector:			| +0x158 SetIntVector (-162)
	movel	_patch_setintvector_old(%pc),%sp@-
	moveml	%d0/%a1,%sp@-
	jsr	%a6@(-636:W)
	moveml	%sp@+,%d0/%a1
	rts

||||| ---- slots shared by the non-exec vector patches ------------------

_patch_sysbase:
	.long	0			| +0x16a ExecBase, stored by init
	.long	0			| +0x16e unused pad slot, as shipped

_patch_beginio_old:
	.long	0			| +0x172 input.device old BeginIO
	.globl pf_beginio
pf_beginio:				| +0x176 input.device -30 (BeginIO)
	movel	_patch_beginio_old(%pc),%sp@-
	cmpiw	#9,%a1@(28)		| io_Request.io_Command == IND_ADDHANDLER?
	bnes	1f
	moveml	%a1/%a6,%sp@-
	movel	_patch_sysbase(%pc),%a6
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a1/%a6
1:
	rts

||||| ---- exception vector installer -----------------------------------

	.word	0			| +0x194 dead pad word, as shipped

	.globl	_InstallExcVecs
_InstallExcVecs:			| +0x196 (a6 = library base)
	moveml	%a2/%a4-%a6,%sp@-
	moveal	%a6,%a4
	lea	super_excvec(%pc),%a5
	movel	%a6,_patch_lib		| keep libbase in the slot
	movel	%a4@(48),%a6		| ExecBase
	jsr	%a6@(-30:W)		| Supervisor(super_excvec)
	jsr	%a6@(-636:W)		| CacheClearU
	moveml	%sp@+,%a2/%a4-%a6
	rts

||||| supervisor body: install the 68881 exception handlers into both
||||| the VBR-based vector table and the absolute copy at +0x190
||||| (covers VBR = 0).  Exits with rte -- exec's Supervisor entry
||||| frame carries SR.

super_excvec:				| +0x1b8
	oriw	#0x0700,%sr
	movec	%vbr,%a0
	lea	_patchtable_c,%a1	| {newfn, vbroff.w, saveoff.w}+
1:
	movel	%a1@+,%d0
	beqs	2f
	moveal	%d0,%a2		| new handler
	movemw	%a1@+,%d0-%d1	| d0 = vbr offset, d1 = lib save offset
	.word	0x29b0,0x0000,0x1000	| movel a0@(0,d0:w),a4@(0,d1:w): save old
	movel	%a2,%a0@(0,%d0:w)		| VBR slot <- handler
	.word	0x218a,0x0190			| movel a2,@(0,d0:w): abs slot too
	bras	1b
2:
	rte

||||| ---- the library-base slot + 68881 exception handlers -------------

_patch_lib:
	.long	0			| +0x1e2 library base, stored by init

||||| each handler: if flag bitN of the byte at lib+34 is set, run the
||||| fsave-frame fixup; otherwise tail-call the saved original vector.
||||| Encoded as .word sequences -- the memory-indirect PC operands are
||||| not expressible in gas syntax.  The "bnes -> bra" double jump and
||||| the handler lengths reproduce the shipped layout exactly.
||||| Saved vectors live at lib+0x54..0x6c.

	.globl pf_trap3
pf_trap3:				| +0x1e6 FPUnderflow, flag bit3
	.word	0x083b,0x0003,0x0162
	.word	_patch_lib - . + 2	| bd -> _patch_lib
	.word	0x0022			| od = 22 (flag byte lib+34)
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0060			| od = save offset lib+0x60
	rts
1:
	bra.w	pf_fsavefix

	.globl pf_trap0
pf_trap0:				| FPBSUN, flag bit0
	.word	0x083b,0x0000,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0054			| lib+0x54
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap5
pf_trap5:				| FPOverflow, flag bit4
	.word	0x083b,0x0004,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0068			| lib+0x68
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap6
pf_trap6:				| FPSignalNaN, flag bit5
	.word	0x083b,0x0005,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x006c			| lib+0x6c
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap4
pf_trap4:				| FPOperandErr, flag bit6
	.word	0x083b,0x0006,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0064			| lib+0x64
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap1
pf_trap1:				| FPInexact, flag bit1
	.word	0x083b,0x0001,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	1f
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x0058			| lib+0x58
	rts
1:
	bra.s	pf_fsavefix

	.globl pf_trap2
pf_trap2:				| FPDivZero, flag bit2
	.word	0x083b,0x0002,0x0162
	.word	_patch_lib - . + 2
	.word	0x0022
	bnes	pf_fsavefix		| short jump reaches pf_fsavefix
	.word	0x2f3b,0x0162
	.word	_patch_lib - . + 2
	.word	0x005c			| lib+0x5c
	rts

||||| ---- common handler: 68881 fsave-frame fixup ----------------------

pf_fsavefix:				| +0x28e
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
