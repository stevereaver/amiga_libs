|||
|||	mathieeesingtrans_lib.s -- resident module header +
|||	AUTOINIT tables for mathieeesingtrans.library 40.6
|||	"for 68881/82" (c) 1995 by Martin Berndt.
|||
|||	Code-hunk layout (as shipped):
|||	  0x00  "moveq #0,d0/rts"     loader entry (returns 0, the
|||	                        failure/exit path for IEEESPPow too)
|||	  0x04  RomTag (RTF_AUTOINIT, rt_Version 40, NT_LIBRARY)
|||	  0x1e  "mathieeesingtrans.library\0"
|||	  0x38  idstring (no trailing \r\n)
|||	  0x82  InitTable (dataSize 0x2c)
|||	  0x92  absolute-longword function table (-1L terminated)
|||
|||	The function table is absolute longwords, so it is emitted
|||	here directly -- no two-pass word-offset generation needed.
|||

	.section .text

||| loader entry -- returns 0 (also IEEESPPow's failure branch)

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
	.ascii	"mathieeesingtrans.library"
	.byte	0
_idstr:
	.ascii	"mathieeesingtrans 40.6 (7.4.95) for 68881/82"
	.byte	0xd,0xa
	.ascii	"(c) 1995 by Martin Berndt"
	.byte	0

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2c			| sizeof(struct MSTBase)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct byte stream
	.long	_LibInit		| init routine

||| absolute-longword AUTOINIT function table, -1L terminated.
||| LVO -24 (ExtFunc) points at the module entry (returns 0).
||| IEEESPTieee/IEEESPFieee both point at the shared rts stub
||| (identity conversion in an IEEE-native build).

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_libentry		| LVO -24 ExtFunc -> moveq#0,rts
	.long	_IEEESPAtan		| LVO -30
	.long	_IEEESPSin		| LVO -36
	.long	_IEEESPCos		| LVO -42
	.long	_IEEESPTan		| LVO -48
	.long	_IEEESPSincos		| LVO -54
	.long	_IEEESPSinh		| LVO -60
	.long	_IEEESPCosh		| LVO -66
	.long	_IEEESPTanh		| LVO -72
	.long	_IEEESPExp		| LVO -78
	.long	_IEEESPLog		| LVO -84
	.long	_IEEESPPow		| LVO -90
	.long	_IEEESPSqrt		| LVO -96
	.long	_MathNull		| LVO -102 IEEESPTieee -> rts
	.long	_MathNull		| LVO -108 IEEESPFieee -> rts
	.long	_IEEESPAsin		| LVO -114
	.long	_IEEESPAcos		| LVO -120
	.long	_IEEESPLog10		| LVO -126
	.long	-1
