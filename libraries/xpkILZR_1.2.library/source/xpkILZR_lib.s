|||
|||	xpkILZR_lib.s -- resident module header for
|||	xpkILZR.library 1.2 "Incremental LZ-Renau"
|||	(Jose Renau, Feb 19 1994 -- idstring claims "v1.3").
|||
|||	Single code hunk; "moveq #0,d0 / rts" entry stub (also the
|||	-24 vector target via a NEGATIVE word offset, -46); packed
|||	RomTag (RTF_AUTOINIT, ver 1, NT_LIBRARY); InitTable with
|||	dataSize 0x114, a word-offset FUNCTABLE, NULL datatab
|||	(InitStruct clears the base), and initRoutine = LibInit.
|||
|||	The 192-byte `descblock` below is copied to base+0x3c by
|||	LibInit; it carries the $VER string (with the shipped
|||	"xpkIZLR" typo), the mode record, and the XpkInfo whose
|||	xi_ModeDesc field is a block-relative offset (0x38) -- the
|||	Open-time fixup that would relocate it is dead code.
|||
|||	Original vector map (offsets relative to _functab):
|||	  -6  LibOpen        -24 _start (ret0 stub, off -0x2e)
|||	  -12 LibClose       -30 XpksPackerInfo
|||	  -18 LibExpunge     -36 XpksPackChunk
|||	                     -42 XpksPackFree   (drops ptrs, leaks)
|||	                     -48 XpksPackReset  (clears head only)
|||	                     -54 XpksUnpackChunk
|||	                     -60 XpksUnpackFree = bare rts (d0 undef)
|||

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endmodule		|| rt_EndSkip
	.byte	0x80			|| RTF_AUTOINIT
	.byte	1			|| version
	.byte	9			|| NT_LIBRARY
	.byte	0			|| pri
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_libname
_libname:
	.ascii	"xpkILZR.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"xpkILZR v1.3"		|| sic: "v1.3" idstring
	.byte	0
	.even

	.globl	_inittab
_inittab:
	.long	0x114			|| dataSize = sizeof(IlzrBase)
	.long	_functab
	.long	0			|| no datatab: InitStruct clears
	.long	_LibInit

|||
|||	descblock: 192 bytes copied to base+0x3c by LibInit.
|||	Layout mirrors the shipped hunk at code+0xea..0x1a9:
|||	  +0x00  4 zero bytes
|||	  +0x04  "$VER: xpkIZLR.library 1.2 (Feb 19 1994) Jose Renau"
|||	  +0x38  XpkMode record ("Fast": upto 100, flags 1, speeds
|||	         200/300, ratio 655)
|||	  +0x62  XpkInfo (flags 0x8009, maxin/defin 0x4000,
|||	         DefMode 50, ModeDesc = block-relative 0x38)
|||	  +0xbc  suballoc minsize long = 0x1000 (inside the tail)
|||
	.globl	_descblock
_descblock:
	.long	0			|| +0x00 pad
	.ascii	"$VER: xpkIZLR.library 1.2 (Feb 19 1994) Jose Renau"
	.byte	0,0			|| +0x36 NUL, +0x37 pad

	|| +0x38 XpkMode record
	.long	0			|| next
	.long	100			|| upto
	.long	1			|| flags
	.long	0			|| packmem
	.long	0			|| unpackmem
	.long	200			|| packspeed
	.long	300			|| unpackspeed
	.word	0x028f			|| ratio = 655
	.word	0			|| chunksize
	.ascii	"Fast"			|| description[10]
	.byte	0,0,0,0,0,0

	|| +0x62 XpkInfo
	.word	1,0,0,0			|| xpkver/libver/masterver/modesver
	.long	_s_name			|| xi_Name "ILZR"
	.long	_s_lname		|| xi_LongName
	.long	_s_desc			|| xi_Description
	.long	0x494c5a52		|| xi_ID 'ILZR'
	.long	0x8009			|| xi_Flags
	.long	0x4000			|| xi_MaxPkInChunk
	.long	0			|| xi_MinPkInChunk
	.long	0x4000			|| xi_DefPkInChunk
	.long	_s_pack			|| xi_PackMsg "Compressing"
	.long	_s_unpack		|| xi_UnpackMsg "Expanding"
	.long	_s_packed		|| xi_PackedMsg "Packed"
	.long	_s_unpacked		|| xi_UnpackedMsg "unpacked"
	.word	50			|| xi_DefMode
	.word	0			|| pad
	.long	0x38			|| xi_ModeDesc (block-relative!)
	.long	0,0,0,0,0,0		|| xi_Reserved[6]
	.long	0			|| +0xba tail
	.word	0x1000			|| +0xbe (minsize long @+0xbc = 0x1000)

_s_name:
	.ascii	"ILZR"
	.byte	0
_s_lname:
	.ascii	"Incremental Lempel Ziv Renau"
	.byte	0
_s_desc:
	.ascii	"A very fast low memory compression, fast hash version of LZSS"
	.byte	0
_s_pack:
	.ascii	"Compressing"
	.byte	0
_s_unpack:
	.ascii	"Expanding"
	.byte	0
_s_packed:
	.ascii	"Packed"
	.byte	0
_s_unpacked:
	.ascii	"unpacked"
	.byte	0
	.even

|||
|||	-60 vector: the original's bare `rts` -- d0 undefined.
|||
	.globl	_XpksUnpackFree
_XpksUnpackFree:
	rts

_endmodule:
	nop
