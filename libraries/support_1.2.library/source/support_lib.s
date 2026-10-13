||||
||||	support_lib.s -- skeleton + packed RomTag/tables for
||||	support.library 1.2 (11 Januar 96) by Thomas Wenzel (T&T)
||||
||||	Shipped layout (single CODE hunk, 2032 bytes):
||||	  +0x00 dead banner routine (OpenLibrary/Output/Write/Close)
||||	  +0x38 banner text "\nsupport.library v1.2 (13.03.) (c)..."
||||	  +0x66 packed RomTag (AUTOINIT, unaligned long fields)
||||	  +0x80 "support.library"   +0x90 idstr "1.2 (11 Januar 96)"
||||	  +0xb4 InitTable {dsize=42, functab, datatab, initfn}
||||	  +0xc4 functab (18 vectors + -1)
||||	  +0x110 InitStruct datatab
||||	  +0x130 "dos.library"
||||	  +0x13c initfn + vector routines
||||	  +0x700 shared scratch (240 bytes)
||||	  +0x7f0 hunk end (rt_EndSkip)
||||
||||	Public entries keep the original register ABI (args in
||||	d0-d3/a0-a3, lib in a6, mathffp base in a4 for -102);
||||	stubs marshal arguments and call the C bodies.

	.section .text

|||| ------------------------------------------------------------------
||||	code+0: dead banner-print routine (nothing calls it)
|||| ------------------------------------------------------------------
	moveal	4,a6				| +0 execbase
	.word	0x43f9				| lea (abs.l),a1 -- "dos.library"
	.long	_sup_dosname
	moveq	#0,d0
	jsr	a6@(-552)			| OpenLibrary
	moveal	d0,a6
	beqs	1f
	jsr	a6@(-60)			| Output()
	movel	d0,d1
	movel	#_sup_banner,d2			| +0x38 banner text
	.word	0x263c				| movel #46,d3 (long imm form)
	.long	46
	jsr	a6@(-48)			| Write(fh,buf,46)
	moveal	a6,a1
	moveal	4,a6
	jsr	a6@(-414)			| CloseLibrary
1:	moveq	#0,d0
	rts

||||	+0x38: banner text, exactly 46 bytes, no terminator
_sup_banner:
	.byte	0x0a
	.ascii	"support.library v1.2 (13.03.) "
	.byte	0xa9
	.ascii	" 1996 by T&T"
	.byte	0x0a,0x0a

||||	+0x66: packed RomTag (fields at byte offsets, as shipped)
_sup_romtag:
	.word	0x4afc				| rt_MatchWord
	.long	_sup_romtag			| rt_MatchTag -> self
	.long	_sup_end			| rt_EndSkip -> +0x7f0
	.byte	0x80				| rt_Flags RTF_AUTOINIT
	.byte	1				| rt_Version
	.byte	9				| rt_Type NT_LIBRARY
	.byte	0				| rt_Pri
	.long	_sup_name			| rt_Name
	.long	_sup_idstr			| rt_IdString
	.long	_sup_inittab			| rt_Init -> InitTable

_sup_name:					| +0x80
	.ascii	"support.library"
	.byte	0
_sup_idstr:					| +0x90
	.ascii	"support.library 1.2 (11 Januar 96)"
	.byte	0
	.byte	0				| pad -> +0xb4

||||	+0xb4: InitTable
_sup_inittab:
	.long	42				| dataSize
	.long	_sup_functab
	.long	_sup_datatab
	.long	_sup_initentry

||||	+0xc4: functab -- 18 vectors, -6..-108
_sup_functab:
	.long	_sup_open			| -6
	.long	_sup_close			| -12
	.long	_sup_expunge			| -18
	.long	_sup_null			| -24
	.long	_sup_snap			| -30
	.long	_sup_keep0			| -36
	.long	_sup_keep1			| -42
	.long	_sup_keep2			| -48
	.long	_sup_clear2			| -54
	.long	_sup_invert			| -60
	.long	_sup_gray			| -66
	.long	_sup_scanline			| -72
	.long	_sup_dither			| -78
	.long	_sup_swap3			| -84
	.long	_sup_mirror			| -90
	.long	_sup_swaprb			| -96
	.long	_sup_mosaic			| -102
	.long	_sup_transpose			| -108
	.long	-1

||||	+0x110: InitStruct datatab
||||	  byte +8  = 9     ln_Type NT_LIBRARY
||||	  long +10 = name  ln_Name
||||	  byte +14 = 6     ln_Flags
||||	  long +20 = 0x00030004   lib_Version=3 lib_Revision=4 (!)
_sup_datatab:
	.word	0xe000, 8, 0x0900
	.word	0xc000, 10
	.long	_sup_name
	.word	0xe000, 14, 0x0600
	.word	0xc000, 20
	.long	0x00030004
	.word	0				| end
	.word	0				| pad -> +0x130

_sup_dosname:					| +0x130
	.ascii	"dos.library"
	.byte	0

|||| ------------------------------------------------------------------
||||	vector stubs: marshal register args -> stack, call C body
|||| ------------------------------------------------------------------
_sup_initentry:					| exec AUTOINIT initfn
	movel	a0,sp@-				| (d0=lib, a0=seglist)
	movel	d0,sp@-
	jbsr	_sup_init
	addql	#8,sp
	rts

_sup_open:					| -6 (lib=a6)
	movel	a6,sp@-
	jbsr	_sup_open_body
	addql	#4,sp
	rts

_sup_close:					| -12
	movel	a6,sp@-
	jbsr	_sup_close_body
	addql	#4,sp
	rts

_sup_expunge:					| -18
	movel	a6,sp@-
	jbsr	_sup_expunge_body
	addql	#4,sp
	rts

_sup_null:					| -24
	clrl	d0
	rts

_sup_snap:					| -30 (w,h,mode,flag,pw,ph,wh2,ctr)
	movel	a3,sp@-
	movel	a2,sp@-
	movel	a1,sp@-
	movel	a0,sp@-
	movel	d3,sp@-
	movel	d2,sp@-
	movel	d1,sp@-
	movel	d0,sp@-
	jbsr	_sup_snap_body
	lea	sp@(32),sp
	rts

_sup_keep0:					| -36 (buf=a0,rowlen=d0,total=d1)
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_keep0_body
	lea	sp@(12),sp
	rts

_sup_keep1:					| -42
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_keep1_body
	lea	sp@(12),sp
	rts

_sup_keep2:					| -48
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_keep2_body
	lea	sp@(12),sp
	rts

_sup_clear2:					| -54
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_clear2_body
	lea	sp@(12),sp
	rts

_sup_invert:					| -60 (buf=a0,n=d0)
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_invert_body
	addql	#8,sp
	rts

_sup_gray:					| -66 (buf=a0,rows=d0,cols=d1)
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_gray_body
	lea	sp@(12),sp
	rts

_sup_scanline:					| -72 (buf=a0,rowlen=d0,total=d1)
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_scanline_body
	lea	sp@(12),sp
	rts

_sup_dither:					| -78 (buf=a0,n=d0)
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_dither_body
	addql	#8,sp
	rts

_sup_swap3:					| -84 (buf=a0,n=d0)
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_swap3_body
	addql	#8,sp
	rts

_sup_mirror:					| -90 (buf=a0,w=d0,rows=d1)
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_mirror_body
	lea	sp@(12),sp
	rts

_sup_swaprb:					| -96 (buf=a0,rowlen=d0,total=d2)
	movel	d2,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_swaprb_body
	lea	sp@(12),sp
	rts

_sup_mosaic:					| -102 (src=a0,w=d0,h=d1,mffp=a4)
	movel	a4,sp@-
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a0,sp@-
	jbsr	_sup_mosaic_body
	lea	sp@(16),sp
	rts

_sup_transpose:					| -108 (src=a0,dst=a1,w=d0,h=d1)
	movel	d1,sp@-
	movel	d0,sp@-
	movel	a1,sp@-
	movel	a0,sp@-
	jbsr	_sup_transpose_body
	lea	sp@(16),sp
	rts
