||||
||||	mhimpegit_lib.s -- entry stubs + packed RomTag/data block
||||	for mhimpegit.library 1.2 (20.01.2017)
||||
||||	Shipped layout (2 hunks: CODE 1696B / DATA 280B):
||||	  code+0    moveq #-1,d0; rts	(executable-entry stub)
||||	  code+4    LibInit (rt_Init -> self MakeLibrary/AddLibrary)
||||	  data+0x00 "mhimpegit.library"
||||	  data+0x12 pad byte + "$VER: ...1.2 (20.01.2017)"
||||	  data+0x3c PACKED RomTag (flags 0, ver 1, NT_LIBRARY)
||||	  data+0x56 functab (14 longs + -1)
||||	  data+0x92/+0x96/+0x9a exec/dos/lib bases
||||	  data+0x9e "dos.library"   data+0xac create tag template
||||	  data+0xcc "prelude.library"  data+0xdc "MPEGit"
||||	  data+0xe4 "1.2 (20.01.2017)"   data+0xf6 "Thomas Wenzel"
||||	  data+0x104 dispatch tag template   data+0x114 prelude base
||||
||||	All public entries use the original's register ABI
||||	(args in d0-d1/a0/a3, lib base in a6); stubs push the
||||	args and jbsr the normal-ABI C bodies.

	.section .text

	moveq	#-1,d0				| +0 executable entry
	rts

_LibInit:					| +4 rt_Init (a0=seg a6=sys)
	movel	a6,sp@-
	movel	a0,sp@-
	jbsr	_mh_boot
	addql	#8,sp
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

_Stub:						| -72 (stale d0; original reloads a4)
	movel	a4,sp@-
	moveal	sp@+,a4
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
||||	data hunk: strings, packed RomTag, functab, globals, templates
|||| ------------------------------------------------------------------
	.section .data

_g_name:
	.ascii	"mhimpegit.library"
	.byte	0
_g_idstr:					| shipped idstr lands on this
	.byte	0				| pad byte -> empty string
	.ascii	"$VER: mhimpegit.library 1.2 (20.01.2017)"
	.byte	0
|||| +0x3c: packed RomTag (unaligned fields, as shipped)
_g_romtag:
	.word	0x4afc				| rt_MatchWord
	.long	_g_romtag			| rt_MatchTag
	.long	_g_functab			| rt_EndSkip -> data+0x56
	.byte	0				| rt_Flags (no AUTOINIT)
	.byte	1				| rt_Version
	.byte	9				| rt_Type NT_LIBRARY
	.byte	0				| rt_Pri
	.long	_g_name				| rt_Name
	.long	_g_idstr			| rt_IdString (points at pad!)
	.long	_LibInit			| rt_Init -> code+4

_g_functab:
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

	.globl	_g_exec
	.globl	_g_dos
	.globl	_g_lib
	.globl	_g_prelude
_g_exec:
	.long	0				| +0x92
_g_dos:
	.long	0				| +0x96
_g_lib:
	.long	0				| +0x9a
_g_doslib:
	.ascii	"dos.library"
	.byte	0
	.byte	0,0				| 2 pad bytes as shipped
_g_create_tmpl:					| +0xac (32 bytes)
	.long	0x80000032, 0
	.long	0x80000033, 0
	.long	0x8000003f, 0
	.long	0, 0
_g_prelib:
	.ascii	"prelude.library"
	.byte	0
_g_mpegit:
	.ascii	"MPEGit"
	.byte	0
	.byte	0				| pad
_g_ver:
	.ascii	"1.2 (20.01.2017)"
	.byte	0
	.byte	0				| pad
_g_author:
	.ascii	"Thomas Wenzel"
	.byte	0
_g_dispatch_tmpl:				| +0x104 (16 bytes)
	.long	0x8000003f, 0, 0, 0
_g_prelude:
	.long	0				| +0x114

	.globl	_g_name
	.globl	_g_idstr
	.globl	_g_romtag
	.globl	_g_functab
	.globl	_g_doslib
	.globl	_g_create_tmpl
	.globl	_g_prelib
	.globl	_g_mpegit
	.globl	_g_ver
	.globl	_g_author
	.globl	_g_dispatch_tmpl
