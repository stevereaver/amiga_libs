|||
|||	dsp3210_lib.s -- resident module header for dsp3210.library 1.1
|||	(3.1.2020, Thomas Winischhofer / d32 object loader)
|||
|||	NON-AUTOINIT resident module (rt_Flags = 0): rt_Init points at
|||	bootstrap code (_ResidentInit) which calls exec MakeLibrary()
|||	and AddLibrary() itself instead of going through the AUTOINIT
|||	table path.  The function table is an absolute-longword vector
|||	list consumed directly by MakeLibrary.
|||
|||	Six vectors: the four standard system vectors plus
|||	DSPCalcLen (-30) and DSPRelocate (-36).
|||

	.section .text
	.globl	_libname
	.globl	_idstr

||| hunk entry for non-resident loaders
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x00			| rt_Flags = 0 (NOT AUTOINIT!)
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_ResidentInit		| RT_INIT -> code, not a table

_libname:
	.ascii	"dsp3210.library"
	.byte	0
||| lib_IdString points into the "$VER:" string, after the cookie.
_verprefix:
	.ascii	"$VER: "
_idstr:
	.ascii	"dsp3210.library 1.1 (3.1.2020)"
	.byte	0
	.even

||| Function table handed to MakeLibrary by _ResidentInit:
||| absolute longword vectors, -1L terminated.
	.globl	_functab
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved)
	.long	_DSPCalcLen		| LVO -30
	.long	_DSPRelocate		| LVO -36
	.long	-1
