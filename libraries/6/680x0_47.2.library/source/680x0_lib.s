|||
|||	680x0_lib.s -- resident module header + AUTOINIT tables
|||	for 680x0.library 47.2 (The MMU.lib development group, THOR)
|||
|||	Matches the shipped binary: a code hunk starting with
|||	"moveq #-1,d0 / rts" (rt_EndSkip is a literal 0), the
|||	RomTag, and a data hunk holding the InitTable (dataSize
|||	0x40), an absolute longword function table (-1L
|||	terminated) and all strings.
|||
|||	Exported vectors: the four standard library entries plus
|||	CPUType, FPUType, MMUType and SetFPUExceptions.
|||
|||	Note: the data hunk carries an "apollo.library" string that
|||	no code in this build references (dead data, kept to match
|||	the shipped binary).
|||

	.section .text

||| executable entry for non-resident loaders: returns -1.
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	0			| RT_ENDSKIP: literal 0, no
					|   relocation (as shipped)
	.byte	0x80			| RTF_AUTOINIT
	.byte	47			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

	.globl	_libname
	.globl	_mmuname
	.globl	_idstr

	.section .data

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x40			| dataSize = sizeof(struct MC680X0Base)
	.long	_functab
	.long	0			| no InitStruct data (init code sets all)
	.long	_LibInit

||| Function table: absolute longword vectors, -1L terminated.
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved)
	.long	_CPUType		| LVO -30
	.long	_FPUType		| LVO -36
	.long	_MMUType		| LVO -42
	.long	_SetFPUExceptions	| LVO -48
	.long	-1

_libname:
	.ascii	"680x0.library"
	.byte	0
||| dead data: present in the shipped binary but never referenced
	.ascii	"apollo.library"
	.byte	0
_mmuname:
	.ascii	"mmu.library"
	.byte	0
||| "$VER: " immediately precedes the id string so version scanners
||| find the usual "$VER: <id>" sequence even though lib_IdString
||| itself starts after the cookie (as in the original binary).
	.ascii	"$VER: "
_idstr:
	.ascii	"680x0.library 47.2 (19.3.2022) (c) 1999-2017 The MMU.lib development group, THOR"
	.byte	10,13,0,0,0

	.end
