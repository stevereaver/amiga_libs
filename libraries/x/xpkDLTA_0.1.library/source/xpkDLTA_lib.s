||||
||||	xpkDLTA_lib.s -- resident module header for
||||	xpkDLTA.library V0.1 "DELTA-Encryption Routines
||||	(c) 1992 Stephan Fuhrmann".
||||
||||	Single code hunk: "moveq #0,d0 / rts" entry stub,
||||	RomTag (version 0!), AUTOINIT InitTable with
||||	dataSize 0xfc -- the InitStruct stream fills the
||||	embedded XpkInfo (base+0x26, 88 bytes) and most of
||||	the embedded XpkMode (base+0x7e, 42 bytes); only
||||	xi_ModeDesc is patched by LibInit.
||||
||||	Hunk map of the original (offset -> contents):
||||	  0x00  moveq #0,d0 / rts       entry stub (returns 0)
||||	  0x04  RomTag                  AUTOINIT, ver 0, NT_LIBRARY
||||	  0x1e  "DLTA"                  short name
||||	  0x23  "DELTA v0.1"            long name
||||	  0x2e  "xpkDLTA.library"
||||	  0x3e  "$VER: xpkDLTA.library v0.1" (idstr points at +0x44)
||||	  0x58  "DELTA-Encryption Routines (c) 1992 Stephan Fuhrmann"
||||	  0x8b  "Enciphering"/"Deciphering"/"Enciphered"/"Deciphered"
||||	  0xba  InitTable               dataSize 0xfc
||||	  0xca  functab                 10 absolute longwords + -1
||||	  0xf6  datatab                 InitStruct stream (fills base
||||	                              incl. XpkInfo/XpkMode fields)
||||	  0x184 LibInit                 seglist->+0x22, ModeDesc->+0x62
||||	  0x19e LibOpen / LibClose / LibExpunge
||||	  0x206 null stub (ExtFunc), 0x20a cleanup hook (rts)
||||	  0x20c XpksPackerInfo          returns base+0x26
||||	  0x214 XpksPackChunk           byte-delta encoder
||||	  0x266 LibNull x2 (PackFree/PackReset)
||||	  0x26e XpksUnpackChunk         byte-delta decoder
||||	  0x2c0 LibNull (UnpackFree)
||||	  0x2c4 delta-encode/decode byte kernels
||||	  0x2e0..0x31f word/long delta kernels -- DEAD CODE,
||||	                              unreachable from the functab
||||	  0x320 end
||||

	.section .text

_start:
	moveq	#0,d0			| module entry returns 0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endmodule		| RT_ENDSKIP (orig: hunk end)
	.byte	0x80			| RTF_AUTOINIT
	.byte	0			| RT_VERSION (v0.1!)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| strings -- note the interleaved/overlapping layout of the
||| original is reproduced semantically (not bit-laid-out).
_s_name:
	.ascii	"DLTA"
	.byte	0
_s_lname:
	.ascii	"DELTA v0.1"
	.byte	0
_libname:
	.ascii	"xpkDLTA.library"
	.byte	0
_verstr:
	.ascii	"$VER: xpkDLTA.library v0.1"
	.byte	0
_idstr = _verstr + 6			| idstr is inside the $VER: string
_s_desc:
	.ascii	"DELTA-Encryption Routines \251 1992 Stephan Fuhrmann"
	.byte	0
_s_pack:
	.ascii	"Enciphering"
	.byte	0
_s_unpack:
	.ascii	"Deciphering"
	.byte	0
_s_packed:
	.ascii	"Enciphered"
	.byte	0
_s_unpacked:
	.ascii	"Deciphered"
	.byte	0

	.even
||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0xfc			| dataSize = sizeof(struct XpkSubBase)
	.long	_functab		| absolute-longword vectors
	.long	_datatab		| InitStruct data
	.long	_LibInit		| initRoutine

||| absolute-longword AUTOINIT function table, -1L terminated.
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

||| InitStruct stream -- standard lib fields plus the
||| embedded descriptor writes (base+0x26..0x64).
||| String-pointer fields carry hunk relocs; scalars are
||| literals, exactly as shipped.
_datatab:
	.byte	0xa0,8			| INITBYTE  ln_Type = NT_LIBRARY
	.byte	9,0
	.byte	0x80,10			| INITLONG  ln_Name
	.long	_libname
	.byte	0xa0,14			| INITBYTE  lib_Flags
	.byte	6,0			|   = LIBF_SUMUSED|LIBF_CHANGED
	.byte	0x90,20			| INITWORD  lib_Version
	.word	0
	.byte	0x90,22			| INITWORD  lib_Revision
	.word	1
	.byte	0x80,24			| INITLONG  lib_IdString
	.long	_idstr

||| embedded XpkMode tail field first (stream order kept):
|||   base+0x82 = xm_Upto = 100
	.byte	0x80,0x82
	.long	100
|||   base+0x9e/0xa2 = xm_Description "ByteMode" (literal longs)
	.byte	0x80,0x9e
	.long	0x42797465		| "Byte"
	.byte	0x80,0xa2
	.long	0x4d6f6465		| "Mode"

||| embedded XpkInfo at base+0x26:
|||   +0x26 XpkInfoVersion=1 / LibVersion=0
|||   +0x2a MasterVersion=1 / ModesVersion=0
	.byte	0x90,0x26
	.word	1
	.byte	0x90,0x28
	.word	0
	.byte	0x90,0x2a
	.word	1
	.byte	0x90,0x2c
	.word	0
|||   +0x2e xi_Name "DLTA"
	.byte	0x80,0x2e
	.long	_s_name
|||   +0x32 xi_LongName "DELTA v0.1"
	.byte	0x80,0x32
	.long	_s_lname
|||   +0x36 xi_Description
	.byte	0x80,0x36
	.long	_s_desc
|||   +0x3a xi_ID 'DLTA'
	.byte	0x80,0x3a
	.long	0x444c5441
|||   +0x3e xi_Flags = 0x2000 (XPKIF_BYTE-mode encryption flag)
	.byte	0x80,0x3e
	.long	0x2000
|||   +0x42 MaxPkInChunk = 0x10000
	.byte	0x80,0x42
	.long	0x10000
|||   +0x46 MinPkInChunk = 1
	.byte	0x80,0x46
	.long	1
|||   +0x4a DefPkInChunk = 0x10000
	.byte	0x80,0x4a
	.long	0x10000
|||   +0x4e..+0x5a the four progress strings
	.byte	0x80,0x4e
	.long	_s_pack
	.byte	0x80,0x52
	.long	_s_unpack
	.byte	0x80,0x56
	.long	_s_packed
	.byte	0x80,0x5a
	.long	_s_unpacked
|||   +0x5e DefMode = 100
	.byte	0x90,0x5e
	.word	100
	.byte	0,0			| InitStruct terminator

	.end
