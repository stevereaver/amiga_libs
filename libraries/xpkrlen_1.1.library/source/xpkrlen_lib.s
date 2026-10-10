||||||
||||||	xpkrlen_lib.s -- resident module + SAS/C-style init for
||||||	xpkRLEN.library V1.0/1.1 "Run Length" (Nov 2 1992)
||||||
||||||	Two-hunk SAS/C build.  The DATA hunk carries a 276-byte
||||||	template (InitTable + strings + XpkInfo/XpkMode) that
||||||	INITFUNCTION copies into the library base at base+58,
||||||	then relocates four descriptor pointer fields by adding
||||||	base+58.  FUNCTABLE is the LONG-address format.
||||||
||||||	Hunk map (original):
||||||	  CODE: entry stub, RomTag -> INIT (data hunk),
||||||	        INITFUNCTION, OPEN/CLOSE/EXPUNGE, LIBFUNC_0..5,
||||||	        FUNCTABLE (longs), name/idstr
||||||	  DATA: template [0x00..0x113] + reloc list [0x100]
||||||	        reloc: count=4, offsets {0xe2,0xb6,0xb2,0xae}
||||||

	.section .text

_start:
	moveq	#0,d0			| module entry + null vector
	rts
	.globl	_start

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endmodule		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_INIT			| RT_INIT -> DATA-hunk InitTable

||||| ------------------------------------------------------------
||||| INITFUNCTION -- SAS/C data-copy + fixup initialiser
|||||   d0 = library base, a0 = seglist
||||| ------------------------------------------------------------
	.globl	_INITFUNCTION
_INITFUNCTION:
	movem.l	d6-d7/a2-a3,-(sp)
	movea.l	d0,a3			| a3 = base
	move.l	a0,34(a3)		| base+0x22 = seglist
	move.b	#9,8(a3)		| ln_Type = NT_LIBRARY
	move.l	#_libname,10(a3)	| ln_Name
	move.b	#6,14(a3)		| lib_Flags = SUMUSED|CHANGED
	move.w	#1,20(a3)		| lib_Version = 1
	clr.w	22(a3)			| lib_Revision = 0
	move.l	#_idstr,24(a3)		| lib_IdString

	| copy the 256-byte template SECSTRT_1 -> base+58
	lea	_SECSTRT_1,a0
	movea.l	a3,a1
	adda.w	#58,a1
	move.l	#0x40,d0
	lsl.l	#2,d0			| 0x100 bytes
1:	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bcc.s	1b

	| reloc pass: read count + offsets from SECSTRT_1+0x100,
	| each field gets (base+58) added -> absolute pointer
	lea	_SECSTRT_1+0x100,a0
	move.l	(a0)+,d7
2:	tst.l	d7
	ble.s	3f
	movea.l	a3,a1
	adda.w	#58,a1			| a1 = base+58
	adda.l	(a0)+,a1		| + field offset
	move.l	a3,d0
	addi.l	#58,d0			| d0 = base+58
	add.l	d0,(a1)			| *target += base+58
	subq.l	#1,d7
	bra.s	2b
3:	move.l	a3,d0			| return base
	movem.l	(sp)+,d6-d7/a2-a3
	rts

||||| ------------------------------------------------------------
||||| FUNCTABLE -- LONG-address format (10 vectors + ffff guards)
||||| ------------------------------------------------------------
	.even
	.globl	_FUNCTABLE
_FUNCTABLE:
	.long	_LibOpen		| -6   Open
	.long	_LibClose		| -12  Close
	.long	_LibExpunge		| -18  Expunge
	.long	_start			| -24  ExtFunc (null)
	.long	_XpksPackerInfo		| -30  XpksPackerInfo
	.long	_XpksPackChunk		| -36  XpksPackChunk
	.long	_XpksPackFree		| -42  XpksPackFree (stub)
	.long	_XpksPackReset		| -48  XpksPackReset (stub)
	.long	_XpksUnpackChunk	| -54  XpksUnpackChunk
	.long	_XpksUnpackFree		| -60  XpksUnpackFree (stub)
	.word	0xffff
	.word	0xffff

_libname:
	.ascii	"xpkRLEN.library"
	.byte	0
	.globl	_libname
_idstr:
	.ascii	"$VER: RLEN 1.1 (Nov  2 1992)"
	.byte	13,10,0
	.globl	_idstr

||||| ------------------------------------------------------------
||||| DATA hunk: the 276-byte template copied to base+58 by
||||| INITFUNCTION, then the reloc list it consumes.
||||| Pointer fields hold template-relative offsets; the init
||||| adds base+58 to turn them absolute.
||||| ------------------------------------------------------------
	.data
	.globl	_SECSTRT_1
_SECSTRT_1:
	.long	0			| 0x00 copied marker
_INIT:						| 0x04 InitTable
	.long	0x13a			|   dataSize = 314
	.long	_FUNCTABLE		|   funcTable
	.long	0			|   dataTable
	.long	_INITFUNCTION		|   initRoutine
						| 0x14
	.ascii	"$VER: RLEN 1.1 (Nov  2 1992)"
	.byte	0			| 0x30 NUL
	.byte	0			| 0x31 pad
mode_node:				| 0x32 XpkMode node (42B)
	.long	0			| next
	.long	100			| upto
	.long	1			| flags
	.long	0			| packmem
	.long	0			| unpackmem
	.long	0x8c			| packspeed 140
	.long	0x413			| unpackspeed 1043
	.word	0x2d			| ratio 45
	.word	0			| chunksize
	.ascii	"normal"		| desc[10]
	.byte	0,0,0,0			| pad desc to 10 -> 0x5c
_s_name:					| 0x5c "RLEN"
	.ascii	"RLEN"
	.byte	0,0			| 0x60-0x61
_s_lname:					| 0x62 "Run Length 1.0"
	.ascii	"Run Length 1.0"
	.byte	0,0			| 0x70-0x71
_s_desc:					| 0x72 "Fast and simple..."
	.ascii	"Fast and simple compression usable for simple data"
	.byte	0			| string NUL ends 0xa4
	.byte	0			| 0xa5 pad -> desc at 0xa6
						| 0xa6 XpkInfo
_xpkinfo:
	.word	1,0,0,0			| ver words 1,0,0,0
f_name:	.long	_s_name - _SECSTRT_1	| +8  xi_Name -> "RLEN"
f_lname:.long	_s_lname - _SECSTRT_1	| +12 xi_LongName -> "Run Length 1.0"
f_desc:	.long	_s_desc - _SECSTRT_1	| +16 xi_Description -> "Fast..."
	.long	0x524c454e		| +20 xi_ID 'RLEN'
	.long	9			| +24 xi_Flags
	.long	0x7d00			| +28 xi_MaxPkInChunk 32000
	.long	0			| +32 xi_MinPkInChunk
	.long	0x7d00			| +36 xi_DefPkInChunk
	.long	0			| +40 xi_PackMsg
	.long	0			| +44 xi_UnpackMsg
	.long	0			| +48 xi_PackedMsg
	.long	0			| +52 xi_UnpackedMsg
	.word	50			| +56 xi_DefMode
	.word	0			| +58 pad
f_mode:	.long	mode_node - _SECSTRT_1	| +60 xi_ModeDesc -> mode_node
	.space	26,0			| +64 reserved -> 0x100
						| 0x100 reloc list
	.globl	_reloclist
_reloclist:
	.long	4			| count
	.long	f_mode - _SECSTRT_1	| 0xe2
	.long	f_desc - _SECSTRT_1	| 0xb6
	.long	f_lname - _SECSTRT_1	| 0xb2
	.long	f_name - _SECSTRT_1	| 0xae

	.end
