||||
||||	mhimpegit_lib.s -- resident module header + AUTOINIT tables
||||	for mhimpegit.library 4.0 (22.05.2022)
||||
||||	Shipped layout (3 hunks: CODE 1692B / DATA 84B / BSS 16B):
||||	  code+0    moveq #-1,d0; rts		(non-resident entry)
||||	  code+4    LibInit
||||	  code+0x62.. LibOpen/LibClose/LibExpunge/-24 stub
||||	  code+0x140  RomTag (rt_Init = data-hunk reloc -> data+4)
||||	  code+0x15e  datatab (InitStruct commands)
||||	  data+0    00dff000 const		data+4 InitTable
||||	  data+0x14 functab (14 longs)		data+0x50 00dff000
||||	  bss:      libbase, execbase, dosbase, preludebase
||||
||||	Vectors: -6 Open, -12 Close, -18 Expunge, -24 stub,
||||	  -30 Create, -36 Destroy, -42 Append, -48 Pop, -54 Query,
||||	  -60 Iterate, -66 Drain, -72 bare rts, -78 Classify,
||||	  -84 Dispatch.
||||
||||	All public entries use the original's register ABI
||||	(args in d0-d1/a0/a3, lib base in a6); stubs push the
||||	args and jbsr the normal-ABI C bodies.

	.section .text

	moveq	#-1,d0				| +0 executable entry
	rts

_LibInit:					| initRoutine (d0=lib a0=seg a6=sysbase)
	movel	a6,sp@-
	movel	a0,sp@-
	movel	d0,sp@-
	jbsr	_mh_init
	lea	sp@(12),sp
	rts

|||| ------------------------------------------------------------------
||||	vector stubs
|||| ------------------------------------------------------------------

	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_LibNull
	.globl	_Create
	.globl	_Destroy
	.globl	_Append
	.globl	_Pop
	.globl	_Query
	.globl	_Iterate
	.globl	_Drain
	.globl	_Stub
	.globl	_Classify
	.globl	_Dispatch

_LibOpen:					| -6
	movel	a6,sp@-
	jbsr	_mh_open
	addql	#4,sp
	rts

_LibClose:					| -12
	movel	a6,sp@-
	jbsr	_mh_close
	addql	#4,sp
	rts

_LibExpunge:					| -18
	movel	a6,sp@-
	jbsr	_mh_expunge
	addql	#4,sp
	rts

_LibNull:					| -24
	clrl	d0
	rts

_Create:					| -30 (tag0=a0, tag1=d0)
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_mh_Create
	addql	#8,sp
	rts

_Destroy:					| -36 (obj=a3)
	movel	a3,sp@-
	jbsr	_mh_Destroy
	addql	#4,sp
	rts

_Append:					| -42 (v0=a0, v1=d0, obj=a3)
	movel	a3,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_mh_Append
	lea	sp@(12),sp
	rts

_Pop:						| -48 (obj=a3)
	movel	a3,sp@-
	jbsr	_mh_Pop
	addql	#4,sp
	rts

_Query:						| -54 (obj=a3)
	movel	a3,sp@-
	jbsr	_mh_Query
	addql	#4,sp
	rts

_Iterate:					| -60 (obj=a3)
	movel	a3,sp@-
	jbsr	_mh_Iterate
	addql	#4,sp
	rts

_Drain:						| -66 (obj=a3)
	movel	a3,sp@-
	jbsr	_mh_Drain
	addql	#4,sp
	rts

_Stub:						| -72 bare rts (stale d0)
	rts

_Classify:					| -78 (code=d1)
	movel	d1,sp@-
	jbsr	_mh_Classify
	addql	#4,sp
	rts

_Dispatch:					| -84 (op=d0, val=d1, obj=a3)
	movel	a3,sp@-
	movel	d1,sp@-
	movel	d0,sp@-
	jbsr	_mh_Dispatch
	lea	sp@(12),sp
	rts

|||| ------------------------------------------------------------------
||||	strings (code hunk, as shipped)
|||| ------------------------------------------------------------------
	.even
_libname:
	.ascii	"mhimpegit.library"
	.byte	0
_idstr:
	.ascii	"$VER: mhimpegit.library 4.0 (22.05.2022)"
	.byte	0
	.even
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_end
	.byte	0x80				| RTF_AUTOINIT
	.byte	4				| RT_VERSION
	.byte	9				| NT_LIBRARY
	.byte	0				| RT_PRI
	.long	_libname
	.long	_idstr
	.long	_inittab

_str_doslib:
	.ascii	"dos.library"
	.byte	0
_str_prelib:
	.ascii	"prelude.library"
	.byte	0
_str_mpegit:
	.ascii	"MPEGit"
	.byte	0
_str_ver:
	.ascii	"4.0 (22.05.2022)"
	.byte	0
_str_author:
	.ascii	"Thomas Wenzel"
	.byte	0

	.even
_datatab:					| InitStruct image (as shipped)
	.word	0xe000,8,0x0900			| INITBYTE +8  = 9 (ln_Type)
	.byte	0x80,0x0a
	.long	_libname			| +10 name
	.word	0xe000,14,0x0600		| INITBYTE +14 = 6 (flags)
	.word	0xd000,20,4			| INITWORD +20 = version 4
	.word	0xd000,22,0			| INITWORD +22 = revision 0
	.byte	0x80,0x18
	.long	_idstr				| +24 idstring
	.word	0

	.globl	_libname
	.globl	_idstr
	.globl	_str_doslib
	.globl	_str_prelib
	.globl	_str_mpegit
	.globl	_str_ver
	.globl	_str_author
	.globl	_gbss

|||| ------------------------------------------------------------------
	.section .data

	.long	0xdff000			| shipped const (dead)
_inittab:
	.long	0x2e				| dataSize
	.long	_functab			| absolute-long table
	.long	_datatab			| InitStruct data
	.long	_LibInit			| initRoutine

_functab:
	.long	_LibOpen			| -6
	.long	_LibClose			| -12
	.long	_LibExpunge			| -18
	.long	_LibNull			| -24
	.long	_Create				| -30
	.long	_Destroy			| -36
	.long	_Append				| -42
	.long	_Pop				| -48
	.long	_Query				| -54
	.long	_Iterate			| -60
	.long	_Drain				| -66
	.long	_Stub				| -72
	.long	_Classify			| -78
	.long	_Dispatch			| -84
	.long	-1
	.long	0xdff000			| shipped tail const

	.section .bss
_gbss:
	.space	16				| libbase, exec, dos, prelude

	.section .text
	.even
_end:
