||||
||||	mathtrans_lib.s -- resident module header +
||||	AUTOINIT tables for mathtrans.library 40.6
||||	"for 68881/82" (c) 1995 by Martin Berndt.
||||
||||	Same framework as the sibling mathieeesingtrans /
||||	mathieeedoubbas 40.6 builds: "moveq #0,d0/rts"
||||	loader entry, RomTag (RTF_AUTOINIT, rt_Version 40,
||||	NT_LIBRARY), name/id strings, InitTable
||||	(dataSize 0x2c), absolute-longword function table
||||	(-1L terminated) emitted directly here.
||||

	.section .text

|||| loader entry -- returns 0 (also the ExtFunc target)

	.globl	_libentry
_libentry:
	moveq	#0,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_inittab		| RT_ENDSKIP (as shipped: points at InitTable)
	.byte	0x80			| RTF_AUTOINIT
	.byte	40			| RT_VERSION (0x28)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

	.globl	_libname
	.globl	_idstr
_libname:
	.ascii	"mathtrans.library"
	.byte	0
_idstr:
	.ascii	"mathtrans 40.6 (7.4.95) for 68881/82"
	.byte	0xd,0xa
	.ascii	"(c) 1995 by Martin Berndt"
	.byte	0

|||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2c			| sizeof(struct MTBase)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct byte stream
	.long	_LibInit		| init routine

|||| absolute-longword AUTOINIT function table, -1L terminated.
|||| LVO -24 (ExtFunc) points at the module entry (returns 0).
|||| User vectors are the classic FFP (fast floating point)
|||| SP* API -- args/results in d0 (FFP format), SPSincos
|||| takes the cosine result pointer in d1, SPPow takes
|||| the power in d1.

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_libentry		| LVO -24 ExtFunc -> moveq#0,rts
	.long	_SPAtan			| LVO -30
	.long	_SPSin			| LVO -36
	.long	_SPCos			| LVO -42
	.long	_SPTan			| LVO -48
	.long	_SPSincos		| LVO -54
	.long	_SPSinh			| LVO -60
	.long	_SPCosh			| LVO -66
	.long	_SPTanh			| LVO -72
	.long	_SPExp			| LVO -78
	.long	_SPLog			| LVO -84
	.long	_SPPow			| LVO -90
	.long	_SPSqrt			| LVO -96
	.long	_SPTieee		| LVO -102
	.long	_SPFieee		| LVO -108
	.long	_SPAsin			| LVO -114
	.long	_SPAcos			| LVO -120
	.long	_SPLog10		| LVO -126
	.long	-1
