|||	runbar_lib.s -- resident module header + AUTOINIT tables
|||	for RunBar.library 1.0 (24.11.96)
|||
|||	The shipped binary is a SAS/C build in three hunks:
|||	hunk0 CODE: entry stub, RomTag, code;  hunk1 DATA: pad long +
|||	InitTable {dsize 0x194, functab->hunk2, datatab 0, initfunc}
|||	+ zero globals + version-string pointer + fixup count (0);
|||	hunk2 DATA: 12-entry LONG functab + name/idstr.
|||	This rebuild folds hunks 1+2 into .data -- the loader only sees
|||	relocated addresses.  The template is padded to the full 128
|||	bytes LibInit copies (the original reads 92B past its 36B hunk).
|||
|||	Vectors: -6 Open, -12 Close, -18 Expunge, -24 stub,
|||	-30 LockTable, -36 Add, -42 Remove, -48 Send, -54 Reset,
|||	-60 Teardown, -66 Update, -72 Unlock.
|||

	.section .text

||| executable entry for non-resident loaders: returns 0
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endtag			| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT
_endtag:

	.ascii	"$VER: "
	.globl	_verstr
_verstr:
	.ascii	"RunBar.library 1.0 (24.11.96)"
	.byte	0
	.even

||| ------------------------------------------------------------------
|||	dead hook stubs called by LibInit/LibExpunge
||| ------------------------------------------------------------------

	.globl	_rb_LibHook
_rb_LibHook:				| called by LibInit: moveq#0,rts
	moveq	#0,d0
	rts

	.globl	_rb_LibHookDead
_rb_LibHookDead:			| called by LibExpunge: bare rts
	rts

	.section .data

	.globl	_rbtempl

_rbtempl:				| DATA-hunk image LibInit copies
	.long	0			| +0x00 pad (template base)
_inittab:				| +0x04 -- rt_Init points here
	.long	0x194			| dataSize
	.long	_functab		| functionTable
	.long	0			| dataTable (none)
	.long	_LibInit		| initRoutine
	.long	0			| +0x14 global
	.long	0			| +0x18 global
	.long	_verstr			| +0x1c version-string ptr
	.long	0			| +0x20 fixup count (0)
	.space	92,0			| +0x24..+0x7f template pad

||| absolute-longword function table, -1 terminated
_functab:
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	0			| -24 reserved
	.long	_RB_LockTable		| -30
	.long	_RB_Add			| -36
	.long	_RB_Remove		| -42
	.long	_RB_Send		| -48
	.long	_RB_Reset		| -54
	.long	_RB_Teardown		| -60
	.long	_RB_Update		| -66
	.long	_RB_Unlock		| -72
	.long	-1

	.globl	_libname
	.globl	_idstr
_libname:
	.ascii	"RunBar.library"
	.byte	0
_idstr:
	.ascii	"RunBar.library 1.0"
	.byte	0
	.byte	0x97			| trailing byte from the original
	.even

	.globl	_LibInit
	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_RB_LockTable
	.globl	_RB_Add
	.globl	_RB_Remove
	.globl	_RB_Send
	.globl	_RB_Reset
	.globl	_RB_Teardown
	.globl	_RB_Update
	.globl	_RB_Unlock
