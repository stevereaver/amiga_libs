|||
|||	xpknone_lib.s -- resident module header + AUTOINIT tables
|||	for xpkNONE.library 1.4 (19.07.1998), XPK "store" sublibrary
|||
|||	Nonstandard layout matching the shipped binary: the code hunk
|||	starts with "moveq #-1,d0 / rts", then the absolute-longword
|||	function table at +4, zero padding, the compact InitStruct
|||	data, the InitTable (dataSize 0x2a), and only then the
|||	RomTag.  The library's IdString has no "$VER:" cookie.
|||
|||	Ten vectors: the four standard system vectors plus the XPK
|||	sublibrary slots (see Include/ASM/lvo/xpksub_lib.i):
|||	  -30 XpksPackerInfo  -36 XpksPackChunk  -42 XpksPackFree
|||	  -48 XpksPackReset   -54 XpksUnpackChunk -60 XpksUnpackFree
|||

	.section .text

||| hunk entry for non-resident loaders: the original returns -1
	moveq	#-1,d0
	rts

||| Function table FIRST (absolute longword vectors, -1L terminated).
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved)
	.long	_XpksPackerInfo		| LVO -30
	.long	_XpksPackChunk		| LVO -36
	.long	_LibNull		| LVO -42 (reserved)
	.long	_LibNull		| LVO -48 (reserved)
	.long	_XpksUnpackChunk	| LVO -54
	.long	_LibNull		| LVO -60 (reserved)
	.long	-1

	.space	0x24			| padding as in the original

||| InitStruct data for the library base (compact byte-offset form).
_datatab:
	.byte	0xa0,0x08		| INITBYTE  ln_Type @ 8
	.byte	0x09,0x00		|   = NT_LIBRARY (9)
	.byte	0x80,0x0a		| INITLONG  ln_Name @ 10
	.long	_libname
	.byte	0xa0,0x0e		| INITBYTE  lib_Flags @ 14
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,0x14		| INITWORD  lib_Version @ 20
	.word	1
	.byte	0x90,0x16		| INITWORD  lib_Revision @ 22
	.word	4
	.byte	0x80,0x18		| INITLONG  lib_IdString @ 24
	.long	_idstr
	.word	0			| end of InitStruct data
	.word	0			| pad word

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x2a			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_libname		| RT_ENDSKIP (points at the name string)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"xpkNONE.library"
	.byte	0
||| NOTE: no "$VER:" cookie -- the IdString is a plain banner.
_idstr:
	.ascii	"xpkNONE 1.4 (19.07.1998)"
	.byte	0xd,0xa,0
	.even
