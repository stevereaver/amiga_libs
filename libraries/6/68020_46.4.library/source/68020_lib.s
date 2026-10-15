||||
||||	68020_lib.s -- resident module header + AUTOINIT tables
||||	for 68020.library 46.4 (MMU) (The MMU.lib development group,
||||	THOR, (23.07.2017)).
||||
||||	Matches the shipped binary: a code hunk starting with
||||	"moveq #-1,d0 / rts" (rt_EndSkip is a literal 0), the RomTag,
||||	and a data hunk holding the InitTable (dataSize 0x74, four
||||	bytes larger than 43.2's 0x70 -- TrapSave moved +4), an
||||	absolute longword function table (37 entries + -1L), the
||||	dependency strings (incl. the new "p5emu.library") and the
||||	two patch record tables.
||||
||||	Vectors: -6/-12/-18 standard (Expunge is a "return 0" stub),
||||	-24 is a reserved null stub (moveq #0/rts just before the
||||	dead vector), -30 .. -216 are dead-vector stubs raising
||||	Alert(0x3f000001), and -222 is FPUControl(flags d0,
||||	mask d1) -> old flag byte.
||||

	.section .text

|||| executable entry for non-resident loaders: returns -1.
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	0			| RT_ENDSKIP: literal 0, no
					|   relocation (as shipped)
	.byte	0x80			| RTF_AUTOINIT
	.byte	46			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

	.globl	_libname
	.globl	_idstr
	.globl	_expansionname
	.globl	_utilityname
	.globl	_mmuname
	.globl	_inputname
	.globl	_p5emuname
	.globl	_patchtable_a
	.globl	_patchtable_b
	.globl	_patchtable_c

	.section .data

|||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x74			| dataSize = sizeof(struct Lib68020Base)
	.long	_functab
	.long	0			| no InitStruct data (init code sets all)
	.long	_LibInit

|||| Function table: absolute longword vectors, -1L terminated.
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18 (stub: return 0)
	.long	_LibNull		| LVO -24 (reserved null stub)
	.long	_DeadVector		| LVO -30
	.long	_DeadVector		| LVO -36
	.long	_DeadVector		| LVO -42
	.long	_DeadVector		| LVO -48
	.long	_DeadVector		| LVO -54
	.long	_DeadVector		| LVO -60
	.long	_DeadVector		| LVO -66
	.long	_DeadVector		| LVO -72
	.long	_DeadVector		| LVO -78
	.long	_DeadVector		| LVO -84
	.long	_DeadVector		| LVO -90
	.long	_DeadVector		| LVO -96
	.long	_DeadVector		| LVO -102
	.long	_DeadVector		| LVO -108
	.long	_DeadVector		| LVO -114
	.long	_DeadVector		| LVO -120
	.long	_DeadVector		| LVO -126
	.long	_DeadVector		| LVO -132
	.long	_DeadVector		| LVO -138
	.long	_DeadVector		| LVO -144
	.long	_DeadVector		| LVO -150
	.long	_DeadVector		| LVO -156
	.long	_DeadVector		| LVO -162
	.long	_DeadVector		| LVO -168
	.long	_DeadVector		| LVO -174
	.long	_DeadVector		| LVO -180
	.long	_DeadVector		| LVO -186
	.long	_DeadVector		| LVO -192
	.long	_DeadVector		| LVO -198
	.long	_DeadVector		| LVO -204
	.long	_DeadVector		| LVO -210
	.long	_DeadVector		| LVO -216
	.long	_FPUControl		| LVO -222
	.long	-1

_libname:
	.ascii	"68020.library"
	.byte	0
_mmuname:
	.ascii	"mmu.library"
	.byte	0
_utilityname:
	.ascii	"utility.library"
	.byte	0
_expansionname:
	.ascii	"expansion.library"
	.byte	0
|||| dead data: the math library names are present in the shipped
|||| data hunk but never referenced.  "input.device" is used via
|||| FindName on the device list; "p5emu.library" (new in 46.3) is
|||| located on the library list and expunged at init.
	.ascii	"mathieeedoubbas.library"
	.byte	0
	.ascii	"mathieeesingbas.library"
	.byte	0
_inputname:
	.ascii	"input.device"
	.byte	0
_p5emuname:
	.ascii	"p5emu.library"
	.byte	0
|||| "$VER: " immediately precedes the id string so version scanners
|||| find the usual "$VER: <id>" sequence even though lib_IdString
|||| itself starts after the cookie (as in the original binary).
	.ascii	"$VER: "
_idstr:
	.ascii	"68020.library 46.4 (23.07.2017) (c) 1999-2016 The MMU.lib development group, THOR"
	.byte	10,13,0

|||| ------------------------------------------------------------------
|||| patch record tables, consumed by PatchTable()/UnpatchTable().
|||| Format: .long code region base, then {liboff.w, vecoff.w, fnoff.w}
|||| records, word 0 terminated.  liboff indexes into the library base:
|||| 0x30 = ExecBase, 0x48 = input.device.  Same vector set as 43.2.
|||| ------------------------------------------------------------------

	.balign	4
_patchtable_a:
	.long	_patchbase
	.word	0x30,-726,4		| ColdReboot -> pf_coldreboot
	.word	0

_patchtable_b:
	.long	_patchbase
	.word	0x30,-396,0x8c		| AddLibrary    -> pf_addlibrary
	.word	0x30,-414,0x9e		| CloseLibrary  -> pf_closelibrary
	.word	0x30,-432,0xb0		| AddDevice     -> pf_adddevice
	.word	0x30,-486,0xc2		| AddResource   -> pf_addresource
	.word	0x30,-282,0xd4		| AddTask       -> pf_addtask
	.word	0x30,-168,0xe6		| AddIntServer  -> pf_addintserver
	.word	0x30,-162,0x148		| SetIntVector  -> pf_setintvector
	.word	0x30,-372,0xfc		| GetMsg        -> pf_getmsg
	.word	0x30,-36,0x138		| exec internal -36 -> pf_lvo36
	.word	0x48,-30,0x166		| input.device BeginIO -> pf_beginio
	.word	0

|||| exception-vector table: {newfn, vbr offset, lib save offset}.
|||| Installed in supervisor mode by super_excvec (only when a 68881
|||| FPU is present).  The vectors are the 68881/68882 FPU exception
|||| vectors 48-54 (VBR+0xc0..0xd8): BSUN, Inexact, DivZero,
|||| Underflow, OperandError, Overflow, Signaling-NaN.  46.3 stores
|||| the saved vectors at lib+0x54..0x6c (43.2 used lib+0x50..0x68).
	.balign	4
_patchtable_c:
	.long	pf_trap5
	.word	0xd4,0x68		| VBR+0xd4 FPOverflow -> lib+0x68
	.long	pf_trap3
	.word	0xcc,0x60		| VBR+0xcc FPUnderflow -> lib+0x60
	.long	pf_trap6
	.word	0xd8,0x6c		| VBR+0xd8 FPSignalNaN -> lib+0x6c
	.long	pf_trap4
	.word	0xd0,0x64		| VBR+0xd0 FPOperandErr -> lib+0x64
	.long	pf_trap0
	.word	0xc0,0x54		| VBR+0xc0 FPBSUN -> lib+0x54
	.long	pf_trap1
	.word	0xc4,0x58		| VBR+0xc4 FPInexact -> lib+0x58
	.long	pf_trap2
	.word	0xc8,0x5c		| VBR+0xc8 FPDivZero -> lib+0x5c
	.long	0

	.end
