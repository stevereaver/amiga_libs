** mathtrans.library 43.6 (8.4.2001) (C) 1997-2001 Jess Sosnoski
** "6888x" FPU edition -- reconstructed in m68k asm
**
** Single CODE hunk; RomTag@+4; AUTOINIT word-offset functab.
** Requires a 68881-class FPU (Init tests AttnFlags bit 4).
**
** Argument convention: each scalar arg arrives in d0/d1 in the
** packed "trans" format  [mantissa24 | sign:1+exp:7 (bias 64)].
** The stubs expand it to IEEE single for the FPU, run one f<op>.s,
** then pack the single result back into the same format.  All
** rounding/denormal/overflow handling lives in the shared pack tail.

	.section .text

** ----------------------------------------------------------------
** code+0 -- null vector stub (moveq #0,d0 / rts)
_LibNull:
	moveq	#0,%d0
	rts

** ----------------------------------------------------------------
** RomTag (code+4)
_RomTag:
	.short	0x4afc
	.long	_RomTag			| rt_MatchTag
	.long	_RomEnd			| rt_EndSkip -> trailing pad nop
	.byte	0x80, 43, 9, 0		| RTF_AUTOINIT, ver 43, NT_LIBRARY, pri 0
	.long	_LibName		| rt_Name
	.long	_IdStr			| rt_IdString
	.long	_InitTab		| rt_Init

_LibName:
	.ascii	"mathtrans.library\0"
	.even
_IdStr:
	.ascii	" mathtrans.library_6888x_version 43.6 (8.4.2001) \251 1997-2001 Jess Sosnoski \0"

** ----------------------------------------------------------------
** InitTable (code+0x7c)
	.even
_InitTab:
	.long	0x30			| dataSize: lib + 48 bytes
	.long	_functab
	.long	_datatab
	.long	_Init

** ----------------------------------------------------------------
** functab (code+0x8c) -- word offsets relative to _functab
	.even
_functab:
	.short	-1
	.short	_Open-_functab		| -6
	.short	_Close-_functab		| -12
	.short	_Expunge-_functab	| -18
	.short	_LibNull-_functab	| -24
	.short	_SPAtan-_functab	| -30
	.short	_SPSin-_functab		| -36
	.short	_SPCos-_functab		| -42
	.short	_SPTan-_functab		| -48
	.short	_SPSinCos-_functab	| -54
	.short	_SPSinh-_functab	| -60
	.short	_SPCosh-_functab	| -66
	.short	_SPTanh-_functab	| -72
	.short	_SPExp-_functab		| -78
	.short	_SPLog-_functab		| -84
	.short	_SPPow-_functab		| -90
	.short	_SPSqrt-_functab	| -96
	.short	_SPTieee-_functab	| -102
	.short	_SPFieee-_functab	| -108
	.short	_SPAsin-_functab	| -114
	.short	_SPAcos-_functab	| -120
	.short	_SPLog10-_functab	| -126
	.short	_SPTenX-_functab	| -132 (extra vector)
	.short	-1

** ----------------------------------------------------------------
** datatab (code+0xbc) -- InitStruct, 8-bit-offset forms
_datatab:
	.byte	0xa0, 8, 9		| INITBYTE  ln_Type = NT_LIBRARY
	.byte	0
	.byte	0x80, 10		| INITLONG  ln_Name
	.long	_LibName
	.byte	0xa0, 14, 6		| INITBYTE  lib_Flags = 6
	.byte	0
	.byte	0x90, 20		| INITWORD  lib_Version = 43
	.short	43
	.byte	0x90, 22		| INITWORD  lib_Revision = 6
	.short	6
	.byte	0x80, 24		| INITLONG  lib_IdString
	.long	_IdStr
	.byte	0, 0, 0, 0		| terminator + pad
	.even

** ----------------------------------------------------------------
** initfn (code+0xdc) -- d0=lib base, a0=seglist, a6=SysBase
** stores SysBase@+34, seglist@+38; requires AFF_68881 (btst #4);
** seeds word@+32 (OpenCnt) to 1 -- the library then never
** reaches OpenCnt==0 through Open/Close pairs (see defects).
_Init:
	moveal	%d0,%a1
	movel	%a6,%a1@(34)
	movel	%a0,%a1@(38)
	movew	%a6@(296),%d0		| SysBase->AttnFlags
	btst	#4,%d0			| AFF_68881
	beqs	_initfail
	movew	#1,%a1@(32)		| OpenCnt = 1
	movel	%a1,%d0
	rts
	nop
_initfail:
	moveq	#0,%d0
	rts

** ----------------------------------------------------------------
** -6 Open (code+0x100)
_Open:
	addqw	#1,%a6@(32)		| OpenCnt++
	bclr	#3,%a6@(42)		| clear LIBF_DELEXP
	movel	%a6,%d0
	rts
	nop

** ----------------------------------------------------------------
** -12 Close (code+0x110)
_Close:
	moveq	#0,%d0
	subqw	#1,%a6@(32)		| OpenCnt--
	bnes	_closed
	btst	#3,%a6@(42)		| deferred expunge pending?
	bnes	_Expunge
_closed:
	rts
	nop

** ----------------------------------------------------------------
** -18 Expunge (code+0x124)
_Expunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(34),%a6		| SysBase
	tstw	%a5@(32)		| OpenCnt
	beqs	1f
	bset	#3,%a5@(42)		| LIBF_DELEXP
	moveq	#0,%d0
	bras	2f
	nop
1:	movel	%a5@(38),%d2		| seglist
	moveal	%a5,%a1
	jsr	%a6@(-252)		| Remove
	moveal	%a5,%a1
	moveq	#0,%d1
	moveq	#0,%d0
	movew	%a5@(16),%d1		| lib_NegSize
	subal	%d1,%a1
	movew	%a5@(18),%d0		| lib_PosSize
	addl	%d1,%d0
	jsr	%a6@(-210)		| FreeMem
	movel	%d2,%d0
2:	moveml	%sp@+,%d2/%a5-%a6
	rts

** ================================================================
** math vectors
**
** EXPAND:  packed [mant24|s+e7] in Dn -> IEEE single in Dn
** (mantissa zero -> leaves d0 = 0, i.e. IEEE +0)
.macro EXPAND rg
	addl	\rg,\rg
	beqs	9f
	lsrb	#1,\rg
	addib	#62,\rg
	swap	\rg
	roll	#7,\rg
9:
.endm

** PACK: IEEE single in d0 -> packed trans format.
** Handles overflow (V after the exponent doubling), the
** exponent-124/126 denormal fix-up and the saturation/failure
** path (returns 0x7fffffff with CCR bit1 set).
** Args n,m,k,j = trailing nop counts per block; the original pads
** each stub's four basic blocks to keep the fixed vector offsets.
.macro PACK n m k j
	swap	%d0
	rorl	#7,%d0
	eorib	#-128,%d0
	addb	%d0,%d0
	bvss	1f
	addqb	#5,%d0
	bvss	4f
	eorib	#-128,%d0
	rorl	#1,%d0
3:	rts
	.rept	\n
	nop
	.endr
1:	bccs	5f
	cmpib	#124,%d0
	beqs	6f
	cmpib	#126,%d0
	bnes	7f
6:	addib	#-123,%d0
	rorl	#1,%d0
	tstb	%d0
	bnes	3b
7:	moveq	#0,%d0
	rts
	.rept	\m
	nop
	.endr
5:	cmpib	#-2,%d0
	bnes	4f
	andil	#-134217728,%d0
	beqs	4f
	moveq	#0,%d0
	rts
	.rept	\k
	nop
	.endr
4:	moveq	#-1,%d0
	lsrb	#1,%d0
	orib	#2,%ccr
	rts
	.rept	\j
	nop
	.endr
.endm

** ----------------------------------------------------------------
** -90 SPPow (code+0x168) -- d0=base, d1=power; base^power.
** Note: `andib #0x7f` on the expanded d0 clears bit 7 of the IEEE
** mantissa low byte rather than the sign -- the intended |base|
** fix-up for flogn actually corrupts the mantissa (documented
** defect; kept).
_SPPow:
	EXPAND	%d0
	EXPAND	%d1
	andib	#0x7f,%d0
	flogns	%d0,%fp0
	fsglmuls %d1,%fp0
	fetoxx	%fp0,%fp0
	fmoves	%fp0,%d0
	PACK	0, 2, 3, 1

** ----------------------------------------------------------------
** -30 SPAtan (code+0x1f4)
_SPAtan:
	EXPAND	%d0
	fatans	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -36 SPSin (code+0x26c)
_SPSin:
	EXPAND	%d0
	fsins	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -42 SPCos (code+0x2e4)
_SPCos:
	EXPAND	%d0
	fcoss	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -48 SPTan (code+0x35c)
_SPTan:
	EXPAND	%d0
	ftans	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -102 SPTieee (code+0x3d4) -- packed->IEEE single expand only
_SPTieee:
	EXPAND	%d0
	rts

** ----------------------------------------------------------------
** -60 SPSinh (code+0x3e4)
_SPSinh:
	EXPAND	%d0
	fsinhs	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -66 SPCosh (code+0x45c)
_SPCosh:
	EXPAND	%d0
	fcoshs	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -72 SPTanh (code+0x4d4)
_SPTanh:
	EXPAND	%d0
	ftanhs	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -78 SPExp (code+0x54c)
_SPExp:
	EXPAND	%d0
	fetoxs	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -84 SPLog (code+0x5c4)
_SPLog:
	EXPAND	%d0
	flogns	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -96 SPSqrt (code+0x63c)
_SPSqrt:
	EXPAND	%d0
	fsqrts	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -114 SPAsin (code+0x6b4)
_SPAsin:
	EXPAND	%d0
	fasins	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -120 SPAcos (code+0x72c)
_SPAcos:
	EXPAND	%d0
	facoss	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -126 SPLog10 (code+0x7a4)
_SPLog10:
	EXPAND	%d0
	flog10s	%d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -54 SPSinCos (code+0x81c) -- d0=angle, d1=&cosresult;
** returns sin in d0, stores cos at *d1.
_SPSinCos:
	EXPAND	%d0
	moveal	%d1,%a0
	fsincoss %d0,%fp0,%fp1
	fmoves	%fp0,%d0
	bsrw	_SPFieee		| pack fp0 -> *a0
	movel	%d0,%a0@
	fmoves	%fp1,%d0
	PACK	1, 2, 3, 1

** ----------------------------------------------------------------
** -132 SPTenX (code+0x89c) -- extra vector: ftentox (10^x)
_SPTenX:
	EXPAND	%d0
	ftentoxs %d0,%fp0
	fmoves	%fp0,%d0
	PACK	3, 2, 3, 1

** ----------------------------------------------------------------
** -108 SPFieee (code+0x914) -- pack IEEE single (fmoves form)
** back to the packed trans format; shared tail used by SPSinCos.
_SPFieee:
	PACK	2, 2, 3, 0
_RomEnd:
	nop
