|||
|||	680x0_lib.s -- resident module header + AUTOINIT tables
|||	for 680x0.library 46.1 (The MMU.lib development group, THOR)
|||
|||	Matches the shipped binary: a code hunk starting with
|||	"moveq #-1,d0 / rts" (rt_EndSkip is a literal 0), the
|||	RomTag, and a data hunk holding
|||	the InitTable (dataSize 0x40), an absolute longword function
|||	table (-1L terminated) and all strings.
|||
|||	Exported vectors: the four standard library entries plus
|||	CPUType, FPUType, MMUType and SetFPUExceptions.
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
	.byte	46			| RT_VERSION
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
||| First word is 0x0000 (not -1), so MakeLibrary treats the
||| entries as absolute pointers.
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
_mmuname:
	.ascii	"mmu.library"
	.byte	0
||| "$VER: " immediately precedes the id string so version scanners
||| find the usual "$VER: <id>" sequence even though lib_IdString
||| itself starts after the cookie (as in the original binary).
	.ascii	"$VER: "
_idstr:
	.ascii	"680x0.library 46.1 (04.07.2016) (c) 1999-2016 The MMU.lib development group, THOR"
	.byte	10,13,0
	.even

	.end
