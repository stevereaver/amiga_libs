|||
|||	xpkRLEN_lib.s -- resident module header for
|||	xpkRLEN.library v1.3 (01.04.1997) by Urban Dominik Muller
|||
|||	Two-hunk layout:
|||	  hunk0 (.text): entry stub, RomTag, AUTOINIT InitTable,
|||	    absolute-longword functab, InitStruct datatab, all
|||	    code, and the string table (the XpkInfo name strings
|||	    live here too).
|||	  hunk1 (.data): XpkMode at +0x00, XpkInfo at +0x2a.
|||	    xi_Name/xi_LongName/xi_Description point back into
|||	    hunk0's strings; xi_ModeDesc points into hunk1.
|||	    PackerInfo's "lea _xpkinfo,a0" is an absolute address
|||	    and carries the single hunk0->hunk1 relocation.
|||
|||	dataSize is only 0x22 (bare struct Library): the seglist
|||	is stored in a code-space longword (_segslot) written by
|||	LibInit and re-read by LibExpunge.
|||

	.section .text

_start:
	moveq	#-1,d0			| module entry returns -1
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endskip		| RT_ENDSKIP (orig: rts inside a null stub)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitTable: dataSize, funcTable, dataTable, initRoutine
_inittab:
	.long	0x22			| dataSize = sizeof(struct Library)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 ExtFunc
	.long	_XpksPackerInfo		| LVO -30
	.long	_XpksPackChunk		| LVO -36
	.long	_LibNull		| LVO -42 XpksPackFree
	.long	_LibNull		| LVO -48 XpksPackReset
	.long	_XpksUnpackChunk	| LVO -54
	.long	_LibNull		| LVO -60 XpksUnpackFree
	.long	-1

_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type = NT_LIBRARY
	.byte	9,0
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version = 1
	.word	1
	.byte	0x90,22			| INITWORD  lib_Revision = 3
	.word	3
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

||| seglist slot in code space: the original stores the InitFunc
||| a0 argument here ("movel a0,0x7a") and LibExpunge reads it
||| back pc-relative.  The 0x22-byte base has no room for it.
	.even
	.globl	_segslot
_segslot:
	.long	0

_libname:
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:
	.ascii	"xpkRLEN 1.3 (01.04.1997)"
	.byte	0xd,0xa,0

||| strings referenced from the hunk1 XpkInfo descriptor
_s_name:
	.ascii	"RLEN"
	.byte	0
_s_lname:
	.ascii	"Run Length"
	.byte	0
_s_desc:
	.ascii	"Fast and simple compression usable for simple data"
	.byte	0

||| EndSkip marker: the original points at the rts of the
||| moveq#0/rts null stub at hunk+0x102; ours bounds the romtag
||| match region just past the module header data.
	.even
_endskip:
	.word	0

	.section .data

||| hunk1: XpkMode at +0x00, XpkInfo at +0x2a
	.even
	.globl	_xpkmode
_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	140			| xm_PackSpeed
	.long	1043			| xm_UnpackSpeed
	.word	45			| xm_Ratio (45.0%)
	.word	0			| xm_ChunkSize
	.ascii	"normal"
	.byte	0,0,0,0			| xm_Description[10]

	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	0			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "RLEN"      -> hunk0
	.long	_s_lname		| xi_LongName   "Run Length" -> hunk0
	.long	_s_desc			| xi_Description           -> hunk0
	.long	0x524c454e		| xi_ID         'RLEN'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x7fffffff		| xi_MaxPkInChunk
	.long	0			| xi_MinPkInChunk
	.long	0x4004			| xi_DefPkInChunk
	.long	0			| xi_PackMsg
	.long	0			| xi_UnpackMsg
	.long	0			| xi_PackedMsg
	.long	0			| xi_UnpackedMsg
	.word	50			| xi_DefMode
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc   -> hunk1
	.long	0,0,0,0,0,0		| xi_Reserved[6]

	.end
