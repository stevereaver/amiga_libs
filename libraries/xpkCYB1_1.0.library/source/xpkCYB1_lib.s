|||
|||	xpkCYB1_lib.s -- resident module header for
|||	xpkCYB1.library v1.0 (24.04.1996) by Alexis Nasr (The Cyborg/NGC)
|||
|||	Single code hunk: "moveq #0,d0 / rts" entry stub, RomTag
|||	(version 1 / revision 0; RT_ENDSKIP points at the InitTable
|||	as shipped; RT_IDSTRING points INSIDE the "$VER:"-prefixed
|||	string, skipping the cookie), AUTOINIT InitTable
|||	(dataSize 0x4a), absolute-longword function table, and the
|||	static XpkInfo/XpkMode descriptor blocks.
|||
|||	This sublibrary is a stub: every codec LVO is a single
|||	"move.l #-1,d0 / rts".  Only XpksPackerInfo is real.
|||

	.section .text

_start:
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_inittab		| RT_ENDSKIP: points at InitTable (as shipped)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING (into the string, after "$VER:")
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"xpkCYB1.library"
	.byte	0
||| one string serves as both $VER cookie and idstring
	.ascii	"$VER:"
_idstr:
	.ascii	"xpkCYB1.library v1.0 (24.04.1996) by Alexis Nasr (The Cyborg/NGC)"
	.byte	0xd,0xa,0,0

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x4a			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab		| absolute-long function table
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

||| AUTOINIT function table, absolute-longword variant.
||| Order: Open Close Expunge Reserved PackerInfo PackChunk
|||        PackFree PackReset UnpackChunk UnpackFree
_functab:
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	_xstub			| -24 reserved -> return 0
	.long	_XpksPackerInfo		| -30
	.long	_xneg			| -36 PackChunk   -> -1
	.long	_xneg			| -42 PackFree    -> -1
	.long	_xneg			| -48 PackReset   -> -1
	.long	_xneg			| -54 UnpackChunk -> -1
	.long	_xneg			| -60 UnpackFree  -> -1
	.long	-1			| table terminator

||| InitStruct data.  The INITBYTE @0x0c lands inside the ln_Name
||| longword and is overwritten by the following INITLONG -- kept
||| verbatim as shipped.
_datatab:
	.byte	0xa0,0x0c		| INITBYTE  @0x0c = 9 (as shipped;
	.byte	9,0			|   odd offset inside ln_Name field)
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version
	.word	1
	.byte	0x90,22			| INITWORD  lib_Revision
	.word	0
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr
	.long	0			| InitStruct terminator

||| Shared "return 0" stub (reserved LVO -24 target).
	.globl	_xstub
_xstub:
	moveq	#0,d0
	rts

||| Shared "return -1" stub -- target of ALL codec LVOs as shipped
||| (move.l #0xffffffff,d0 / rts).
	.globl	_xneg
_xneg:
	move.l	#-1,d0
	rts

||| XpkInfo descriptor returned by XpksPackerInfo() (LVO -30).
	.globl	_xpkinfo
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	0			| xi_MasterVersion (0 as shipped)
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "CYB1"
	.long	_s_lname		| xi_LongName   "Crunch?Yes...Better!"
	.long	_s_desc			| xi_Description
	.long	0x43594231		| xi_ID         'CYB1'
	.long	9			| xi_Flags = XPKIF_PK_CHUNK|XPKIF_UP_CHUNK
	.long	0x80000			| xi_MaxPkInChunk (512K)
	.long	8			| xi_MinPkInChunk
	.long	0x8000			| xi_DefPkInChunk (32K)
	.long	_s_msg			| xi_PackMsg    "DummyMsg"
	.long	_s_msg			| xi_UnpackMsg  "DummyMsg"
	.long	_s_msg			| xi_PackedMsg  "DummyMsg"
	.long	_s_msg			| xi_UnpackedMsg "DummyMsg"
	.word	100			| xi_DefMode
	.word	0			| xi_Pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags = XPKMF_A3000SPEED
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	30			| xm_PackSpeed
	.long	600			| xm_UnpackSpeed
	.word	500			| xm_Ratio (500% -- sic, as shipped)
	.word	0			| xm_ChunkSize
||| desc bytes verbatim: "*;-)" + NUL,NUL,NUL,'x',NUL,NUL
	.byte	0x2a,0x3b,0x2d,0x29,0,0,0,0x78,0,0

_s_name:
	.ascii	"CYB1"
	.byte	0
_s_lname:
	.ascii	"Crunch?Yes...Better!"
	.byte	0
_s_desc:
	.ascii	"The totally adaptive Xpk SubLib!!!"
	.byte	0xa
	.ascii	"(c) 1996 A.Nasr (The Cyborg/NGC)"
	.byte	0
_s_msg:
	.ascii	"DummyMsg"
	.byte	0
	.even

_endcode:
	.end
