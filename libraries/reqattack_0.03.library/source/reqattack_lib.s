||||
||||	reqattack.library 0.03 - RomTag, strings, vector table
||||	reconstructed from the shipped binary (SAS/C-style build).
||||
||||	The RomTag's RT_INIT is NULL and RT_ENDSKIP points at
||||	+0x1e (mid-init): the library is NOT built by
||||	InitResident.  A private loader reads the manual
||||	InitTable in .data (dataSize 0x38, functab, init fn)
||||	and calls MakeLibrary itself.
||||
||||	Function table = six absolute longwords:
||||	  -6  LibOpen / -12 LibClose / -18 LibExpunge /
||||	  -24 0      / -30 Fn1     / -36 Fn2

	.text
	.globl	_start
	.globl	_LibInit
_start:
	moveq	#0,d0
	rts

|||| resident tag (RTF_AUTOINIT set but RT_INIT = 0 -- decorative)

_romtag:
	.word	0x4afc			|||| RTC_MATCHWORD
	.long	_romtag			|||| RT_MATCHTAG
	.long	_endmodule		|||| RT_ENDSKIP (shipped: +0x1e, mid-init)
	.byte	0x80			|||| RT_FLAGS (AUTOINIT set, unused)
	.byte	0			|||| RT_VERSION
	.byte	9			|||| RT_TYPE = NT_LIBRARY
	.byte	0			|||| RT_PRI
	.long	_libname
	.long	_idstr
	.long	0			|||| RT_INIT = NULL

	.globl	_libname
_libname:
	.ascii	"reqattack.library"
	.byte	0
	.byte	0,0			|||| shipped pad
	.globl	_idstr
_idstr:
	.ascii	"reqattack.library 0.03 (22.10.01)"
	.byte	0
	.byte	0x6c,0x69		|||| dead "li" tail bytes in the hunk

|||| strings referenced by init / the wrappers

	.even
	.globl	_s_intuition
_s_intuition:
	.ascii	"intuition.library"
	.byte	0
	.globl	_s_semname
_s_semname:
	.ascii	"ReqAttack SubLibrary"
	.byte	0
	.globl	_s_portname
_s_portname:
	.ascii	"ReqAttack Warp Core"
	.byte	0

|||| function vector table (absolute longwords, MakeFunctions)

	.even
	.globl	_functab
_functab:
	.long	_LibOpen		|||| -6
	.long	_LibClose		|||| -12
	.long	_LibExpunge		|||| -18
	.long	0			|||| -24 reserved
	.long	_RARequest		|||| -30 ReqAttackEasyRequestArgs
	.long	_RABuildRequest		|||| -36 ReqAttackBuildEasyRequestArgs

|||| manual InitTable (read by the private loader, in .data)

	.section .data
	.globl	_ra_inittab
_ra_inittab:
	.long	0x38			|||| libSize
	.long	_functab		|||| funcTable
	.long	0			|||| dataTable (none)
	.long	_LibInit		|||| initRoutine

|||| SAS/C far-data fixup table -- {count, offs..}; count=0
|||| (shipped hunk1 = two zero longs: a template left empty)

	.globl	_ra_fixup
_ra_fixup:
	.long	0
	.long	0

|||| globals (far data)

	.globl	_ra_sysbase
_ra_sysbase:
	.long	0			|||| ExecBase stash
	.globl	_ra_intuition
_ra_intuition:
	.long	0			|||| intuition.library base
	.globl	_ra_warpcore
_ra_warpcore:
	.long	0			|||| port+46 WarpCore base
