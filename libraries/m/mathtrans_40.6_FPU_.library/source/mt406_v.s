||||	mt406_v.s -- verbatim reconstruction of mathtrans.library
||||	40.6 (7.4.95) for 68881/82 by Martin Berndt.  Single CODE hunk,
||||	AUTOINIT, absolute-long functab (21 vectors, -6..-126).
||||
||||	FFP library: every SP* vector converts d0 FFP->IEEE single via
||||	_sptieee, runs one 68881 .s op, then _spfieee converts back
||||	with range checks (error = 0xffffffff + V set).
||||
||||	Quirks preserved verbatim:
||||	  - rt_EndSkip = 0x72 -> the InitTable itself (mid-module quirk).
||||	  - functab -24 slot holds literal 0; its RELOC32 entry makes it
||||	    resolve to the code+0 'moveq #0,rts' entry stub.
||||	  - SPPow(-x, non-integral y) fBcc's back to a 'moveq #0; bra
||||	    _spfieee' stub at 0x184 -> returns FFP 0.
||||	  - Pow negative path lives between expunge and SPAtan (0x18c),
||||	    entered by bmi.s; exponent parity via fmod(y,2), odd -> bset
||||	    #31 (negative result, |x|^y via logn/mul/etox).
||||	  - SPSincos takes the cos result pointer in d1 (movea.l d1,a0),
||||	    fsincos.s d0,fp0:fp1 -- cos->fp0 converted+stored first.
||||	  - SPFieee edge tree: bvs/bcc splits, andi.w #0xfeff+tst.l dead-
||||	    ish paths, 'lsl.w #8,d0' dead work before moveq #-1, error
||||	    returns 0xffffffff with V set via ori.b #2,ccr.
||||	  - Private deferred-expunge flag is bit 3 of lib+0x2a.
||||	  - FPU line-F words emitted raw (gas mnemonics could differ).

	.section .text

_entry:	moveq	#0,%d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_inittab		| rt_EndSkip=0x72 -> InitTable (mid-module)
	.byte	0x80			| rt_Flags = RTF_AUTOINIT
	.byte	40			| rt_Version
	.byte	9			| rt_Type = NT_LIBRARY
	.byte	0			| rt_Pri
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"mathtrans.library\0"
_idstr:	.ascii	"mathtrans 40.6 (7.4.95) for 68881/82\r\n\0"
	.ascii	"(c) 1995 by Martin Berndt\0"
	.byte	0			| pad -> 0x72

_inittab:
	.long	0x2c			| dataSize
	.long	_functab
	.long	_datatab
	.long	_initfn

_functab:
	.long	_open			| -6
	.long	_close			| -12
	.long	_expunge		| -18
	.long	_entry			| -24  -> code+0 stub via reloc
	.long	_spatan			| -30
	.long	_spsin			| -36
	.long	_spcos			| -42
	.long	_sptan			| -48
	.long	_spsincos		| -54
	.long	_spsinh			| -60
	.long	_spcosh			| -66
	.long	_sptanh			| -72
	.long	_spexp			| -78
	.long	_splog			| -84
	.long	_sppow			| -90
	.long	_spsqrt			| -96
	.long	_sptieee		| -102 FFP -> IEEE single
	.long	_spfieee		| -108 IEEE single -> FFP
	.long	_spasin			| -114
	.long	_spacos			| -120
	.long	_splog10		| -126
	.long	0xffffffff

_datatab:
	.byte	0xa0,0x08,0x09,0x00	| byte@+8 = 9 (ln_Type)
	.byte	0x80,0x0a
	.long	_name			| long@+0xa = ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| byte@+0xe = 6 (lib_Flags)
	.byte	0x90,0x14
	.short	40			| word@+0x14 = lib_Version
	.byte	0x90,0x16
	.short	6			| word@+0x16 = lib_Revision
	.byte	0x80,0x18
	.long	_idstr			| long@+0x18 = lib_IdString
	.long	0
	.short	0			| pad -> 0xfc

_initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	clrw	%a5@(0x20)		| OpenCnt
	movel	%a6,%a5@(0x22)		| sysbase
	movel	%a0,%a5@(0x26)		| seglist
	moveal	%sp@+,%a5
	btst	#1,%a6@(0x129)		| AFF_68020 (AttnFlags low byte)
	beqs	1f			| no 020+ -> fail
	btst	#4,%a6@(0x129)		| AFF_68881
	bnes	2f			| has FPU -> return base in d0
1:	moveq	#0,%d0
2:	rts
	.short	0			| pad -> 0x124

_open:
	addqw	#1,%a6@(0x20)
	bclr	#3,%a6@(0x2a)		| private deferred flag
	movel	%a6,%d0
3:	rts
	.short	0			| pad -> 0x134

_close:
	moveq	#0,%d0
	subqw	#1,%a6@(0x20)
	bnes	3b			| cnt>0 -> rts
	btst	#3,%a6@(0x2a)
	beqs	3b			| flag clear -> rts
	| fall into expunge

_expunge:
	moveml	%d1/%d2/%a0-%a1/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(0x22),%a6		| sysbase
	tstw	%a5@(0x20)
	beqs	4f
	bset	#3,%a5@(0x2a)		| defer
	moveq	#0,%d0
	bras	5f
	.short	0			| pad -> 0x160
4:	movel	%a5@(0x26),%d2		| seglist
	moveal	%a5,%a1
	jsr	%a6@(-252)		| Remove
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(0x10),%d0		| NegSize
	subal	%d0,%a1
	addw	%a5@(0x12),%d0		| + PosSize
	jsr	%a6@(-210)		| FreeMem
	movel	%d2,%d0
5:	moveml	%sp@+,%d1/%d2/%a0-%a1/%a5-%a6
	rts

	|  SPPow(-x, non-integral y) early return: FFP 0 via _spfieee
_powzero:
	moveq	#0,%d0
	braw	_spfieee
	.short	0			| pad -> 0x18c

	|  SPPow negative-x path (entered via bmi from _sppow)
_powneg:
	bclr	#31,%d0			| |x|
	exg	%d0,%d1			| d0=y(FFP), d1=|x|(IEEE)
	bsrw	_sptieee		| d0 = IEEE(y)
	.short	0xf200,0x4401		| fint.s d0,fp0
	.short	0xf200,0x4428		| fsub.s d0,fp0 (int(y)-y)
	.short	0xf28e,0xffe4		| fbne.w _powzero (non-integral)
	.short	0xf201,0x4414		| flogn.s d1,fp0 (ln|x|)
	.short	0xf200,0x4423		| fmul.s d0,fp0  (y*ln|x|)
	.short	0xf200,0x0010		| fetox.x fp0,fp0
	movel	%d0,%d1			| save IEEE(y)
	.short	0xf200,0x6400		| fmove.s fp0,d0 (|x|^y)
	.short	0xf201,0x4400		| fmove.s d1,fp0 (y)
	.short	0xf23c,0x4421		| fmod.s #2.0,fp0 (parity)
	.long	0x40000000
	.short	0xf281,0x0006		| fbeq.w +6 (even -> skip)
	bset	#31,%d0			| odd exponent -> negative
	braw	_spfieee

_sppow:					| -90: pow(x=d0, y=d1), FFP
	bsrs	_sptieee		| d0 = IEEE(x)
	bmis	_powneg			| x<0
	.short	0xf200,0x4414		| flogn.s d0,fp0
	movel	%d1,%d0			| y
	bsrs	_sptieee		| d0 = IEEE(y)
	.short	0xf200,0x4423		| fmul.s d0,fp0
	.short	0xf200,0x0010		| fetox.x fp0,fp0
	braw	_outsp			| fmove.s fp0,d0; _spfieee

_spatan:				| -30
	bsrs	_sptieee
	.short	0xf200,0x440a		| fatan.s d0,fp0
	braw	_outsp
	.short	0			| pad -> 0x1f0

_spsin:					| -36
	bsrs	_sptieee
	.short	0xf200,0x440e		| fsin.s d0,fp0
	braw	_outsp
	.short	0			| pad -> 0x1fc

_spcos:					| -42
	bsrs	_sptieee
	.short	0xf200,0x441d		| fcos.s d0,fp0
	bras	_outsp

_sptan:					| -48
	bsrs	_sptieee
	.short	0xf200,0x440f		| ftan.s d0,fp0
	bras	_outsp

_spsincos:				| -54: d0=angle, d1=cos ptr
	bsrs	_sptieee
	moveal	%d1,%a0			| cos destination pointer
	.short	0xf200,0x44b0		| fsincos.s d0,fp0:fp1
	.short	0xf200,0x6400		| fmove.s fp0,d0 (cos)
	bsrs	_spfieee		| cos -> FFP
	movel	%d0,%a0@		| *ptr = cos
	.short	0xf200,0x6480		| fmove.s fp1,d0 (sin)
	bras	_spfieee
	.short	0			| pad -> 0x224

_sptieee:				| FFP -> IEEE single (d0)
	addl	%d0,%d0
	beqs	6f			| FFP 0 -> IEEE 0
	eorib	#0x80,%d0		| sign -> bit7 wrap
	asrb	#1,%d0			| exp|sign byte
	subib	#0x82,%d0		| re-bias 64 -> 127
	swap	%d0
	roll	#7,%d0			| IEEE fields into place
6:	rts

_spsinh:				| -60
	bsrs	_sptieee
	.short	0xf200,0x4402		| fsinh.s d0,fp0
	bras	_outsp

_spcosh:				| -66
	bsrs	_sptieee
	.short	0xf200,0x4419		| fcosh.s d0,fp0
	bras	_outsp

_sptanh:				| -72
	bsrs	_sptieee
	.short	0xf200,0x4409		| ftanh.s d0,fp0
	bras	_outsp

_spexp:					| -78
	bsrs	_sptieee
	.short	0xf200,0x4410		| fetox.s d0,fp0
	bras	_outsp

_splog:					| -84
	bsrs	_sptieee
	.short	0xf200,0x4414		| flogn.s d0,fp0
	bras	_outsp

_spsqrt:				| -96
	bsrs	_sptieee
	.short	0xf200,0x4404		| fsqrt.s d0,fp0
	bras	_outsp

_spasin:				| -114
	bsrs	_sptieee
	.short	0xf200,0x440c		| fasin.s d0,fp0
	bras	_outsp

_spacos:				| -120
	bsrs	_sptieee
	.short	0xf200,0x441c		| facos.s d0,fp0
	bras	_outsp

_splog10:				| -126
	bsrs	_sptieee
	.short	0xf200,0x4415		| flog10.s d0,fp0
	| fall through
_outsp:					| fp0 -> d0 -> _spfieee
	.short	0xf200,0x6400		| fmove.s fp0,d0

_spfieee:				| IEEE single -> FFP (d0)
	swap	%d0
	rorl	#7,%d0
	eorib	#0x80,%d0
	addb	%d0,%d0			| exp*2; V on edge
	bvss	7f
	addqb	#5,%d0			| re-bias 127 -> 64(+2)
	bvss	13f			| overflow -> error path
	eorib	#0x80,%d0
	rorl	#1,%d0
8:	rts
	.short	0			| pad -> 0x29a
7:	bccs	10f			| huge positive exp
	cmpib	#0x7c,%d0
	beqs	9f
	cmpib	#0x7e,%d0
	bnes	12f
9:	addib	#0x85,%d0		| 0x7c/0x7e edge: re-wrap
	rorl	#1,%d0
	tstb	%d0
	bnes	8b			| nonzero -> done
	moveq	#0,%d0
	rts
12:	andiw	#0xfeff,%d0		| clear stray bit8
	tstl	%d0
	beqs	8b			| -> rts (returns 0)
	moveq	#0,%d0
	rts
10:	cmpib	#0xfe,%d0		| inf/NaN-class exponent
	bnes	13f
	moveq	#9,%d1
	lsrl	%d1,%d0			| mantissa must vanish
	beqs	11f			| still 0 -> error
	moveq	#0,%d0
	rts
13:	lslw	#8,%d0			| dead work (d0 overwritten)
11:	moveq	#-1,%d0
	roxrb	#1,%d0			| d0.b = 0xff, X=1
	orib	#0x02,%ccr		| V set: error result
	rts

	.globl	_open,_close,_expunge,_initfn
