|||
|||	mathieeedoubbas_lib.s -- resident module header +
|||	AUTOINIT tables for mathieeedoubbas.library 40.6
|||	"for 68881/82" (c) 1995 by Martin Berndt.
|||
|||	Same framework as the sibling mathieeesingtrans 40.6
|||	build: "moveq #0,d0/rts" loader entry, RomTag
|||	(RTF_AUTOINIT, rt_Version 40, NT_LIBRARY), name/id
|||	strings, InitTable (dataSize 0x2c), absolute-longword
|||	function table (-1L terminated) emitted directly here.
|||

	.section .text

||| loader entry -- returns 0 (also the ExtFunc target)

	.globl	_libentry
_libentry:
	moveq	#0,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
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
	.ascii	"mathieeedoubbas.library"
	.byte	0
_idstr:
	.ascii	"mathieeedoubbas 40.6 (7.4.95) for 68881/82"
	.byte	0xd,0xa
	.ascii	"(c) 1995 by Martin Berndt"
	.byte	0

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2c			| sizeof(struct MDBBase)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct byte stream
	.long	_LibInit		| init routine

||| absolute-longword AUTOINIT function table, -1L terminated.
||| LVO -24 (ExtFunc) points at the module entry (returns 0).

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_libentry		| LVO -24 ExtFunc -> moveq#0,rts
	.long	_IEEEDPFix		| LVO -30
	.long	_IEEEDPFlt		| LVO -36
	.long	_IEEEDPCmp		| LVO -42
	.long	_IEEEDPTst		| LVO -48
	.long	_IEEEDPAbs		| LVO -54
	.long	_IEEEDPNeg		| LVO -60
	.long	_IEEEDPAdd		| LVO -66
	.long	_IEEEDPSub		| LVO -72
	.long	_IEEEDPMul		| LVO -78
	.long	_IEEEDPDiv		| LVO -84
	.long	_IEEEDPFloor		| LVO -90
	.long	_IEEEDPCeil		| LVO -96
	.long	-1
