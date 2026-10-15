|||||	mdt406_v.s -- verbatim reconstruction of mathieeedoubtrans.library
|||||	40.6 (7.4.95) for 68881/82 by Martin Berndt.  Single CODE hunk,
|||||	AUTOINIT, absolute-long functab (21 vectors, -6..-126).
|||||
|||||	Quirks preserved verbatim:
|||||	  - rt_EndSkip = 0x82 -> the InitTable itself; the resident copy
|||||	    ends before functab/datatab/code (mid-module quirk).
|||||	  - functab -24 slot holds literal 0; its RELOC32 entry makes it
|||||	    resolve to the code+0 'moveq #0,rts' entry stub.
|||||	  - init gate is a btst PAIR on AttnFlags: bit1 (AFF_68020) then
|||||	    bit4 (AFF_68881) -- a 68882 sets bit5, so 68882-only systems
|||||	    are rejected despite the "68881/82" idstring.
|||||	  - Private deferred-expunge flag is bit 3 of lib+0x2a (not the
|||||	    lib_Flags byte).
|||||	  - IEEE doubles move through the USER stack (fXXXd (sp) /
|||||	    fmoved fp0,(sp)); fp0/fp1 are caller-clobbered.
|||||	  - IEEEDPPow: x<0 with non-integer y returns +0.0 (not NaN);
|||||	    odd/even test via fmodd #2.0; 'fmoved (sp)+,fp0' doubles as
|||||	    pop+reload of saved y; core forces FPCR round-to-nearest
|||||	    (clrb) around log/exp and restores it on exit.
|||||	  - FPU line-F words emitted raw (gas mnemonics could differ).

	.section .text

_entry:	moveq	#0,%d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_inittab		| rt_EndSkip=0x82 -> InitTable (mid-module)
	.byte	0x80			| rt_Flags = RTF_AUTOINIT
	.byte	40			| rt_Version
	.byte	9			| rt_Type = NT_LIBRARY
	.byte	0			| rt_Pri
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"mathieeedoubtrans.library\0"
_idstr:	.ascii	"mathieeedoubtrans 40.6 (7.4.95) for 68881/82\r\n\0"
	.ascii	"(c) 1995 by Martin Berndt\0"
	.byte	0			| pad -> 0x82

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
	.long	_dpatan			| -30
	.long	_dpsin			| -36
	.long	_dpcos			| -42
	.long	_dptan			| -48
	.long	_dpsincos		| -54
	.long	_dpsinh			| -60
	.long	_dpcosh			| -66
	.long	_dptanh			| -72
	.long	_dpexp			| -78
	.long	_dplog			| -84
	.long	_dppow			| -90
	.long	_dpsqrt			| -96
	.long	_dptieee		| -102
	.long	_dpfieee		| -108
	.long	_dpasin			| -114
	.long	_dpacos			| -120
	.long	_dplog10		| -126
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
	.short	0			| pad -> 0x10c

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
	.short	0			| pad -> 0x134

_open:					| -6
	addqw	#1,%a6@(0x20)
	bclr	#3,%a6@(0x2a)		| private deferred flag
	movel	%a6,%d0
3:	rts
	.short	0			| pad -> 0x144

_close:					| -12
	moveq	#0,%d0
	subqw	#1,%a6@(0x20)
	bnes	3b			| cnt>0 -> rts
	btst	#3,%a6@(0x2a)
	beqs	3b			| flag clear -> rts
	| fall into expunge

_expunge:				| -18
	moveml	%d1/%d2/%a0-%a1/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(0x22),%a6		| sysbase
	tstw	%a5@(0x20)
	beqs	4f
	bset	#3,%a5@(0x2a)		| defer
	moveq	#0,%d0
	bras	5f
	.short	0			| pad -> 0x170
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

_dpatan:				| -30: fatan.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x540a		| fatan.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x1a8

_dpsin:					| -36: fsin.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x540e		| fsin.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x1bc

_dpcos:					| -42: fcos.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x541d		| fcos.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x1d0

_dptan:					| -48: ftan.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x540f		| ftan.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x1e4

_dpsincos:				| -54: sin->d0:d1, cos->(a0)
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5431		| fsincos.d (sp),fp1:fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)  (sin)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	.short	0xf210,0x7480		| fmove.d fp1,(a0)  (cos)
	rts
	.short	0			| pad -> 0x1fc

_dpsinh:				| -60: fsinh.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5402		| fsinh.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x210

_dpcosh:				| -66: fcosh.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5419		| fcosh.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x224

_dptanh:				| -72: ftanh.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5409		| ftanh.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x238

_dpexp:					| -78: fetox.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5410		| fetox.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x24c

_dplog:					| -84: flogn.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5414		| flogn.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x260

_dppow:					| -90: x^y, x=d0:d1 y=d2:d3
	tstl	%d0
	bpls	6f			| x>=0 -> core
	bclr	#31,%d0			| |x|
	moveml	%d2-%d3,%sp@-		| save y
	.short	0xf217,0x5401		| fint.d (sp),fp0  (trunc y)
	.short	0xf217,0x5428		| fsub.d (sp),fp0  (trunc(y)-y)
	.short	0xf28e,0x001e		| fbne 8f  (non-integer y -> +0.0)
	bsrs	6f			| pow(|x|,y)
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0 (pop saved y)
	.short	0xf23c,0x5421		| fmod.d #2.0,fp0
	.long	0x40000000,0x00000000
	.short	0xf281,0x0006		| fbeq 7f  (even y -> positive)
	bset	#31,%d0			| odd y -> re-negate
7:	rts
8:	addqw	#8,%sp			| drop saved y
	moveq	#0,%d0
	moveq	#0,%d1
	rts
6:	moveml	%d0-%d3,%sp@-		| core: push x,y
	.short	0xf200,0xb000		| fmove.l fpcr,d0
	movel	%d0,%d1			| save fpcr
	clrb	%d0			| -> round-to-nearest
	.short	0xf200,0x9000		| fmove.l d0,fpcr
	.short	0xf21f,0x5414		| flogn.d (sp)+,fp0 (ln x, pop x)
	.short	0xf217,0x5423		| fmul.d (sp),fp0  (*y)
	.short	0xf200,0x0010		| fetox.x fp0,fp0  (e^..)
	.short	0xf217,0x7400		| fmove.d fp0,(sp) (over y slot)
	.short	0xf201,0x9000		| fmove.l d1,fpcr (restore)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x2c8

_dpsqrt:				| -96: fsqrt.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5404		| fsqrt.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x2dc

_dptieee:				| -102: double d0:d1 -> single d0
	moveml	%d0-%d1,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0
	.short	0xf200,0x6400		| fmove.s fp0,d0
	rts
	.short	0			| pad -> 0x2ec

_dpfieee:				| -108: single d0 -> double d0:d1
	.short	0xf200,0x4400		| fmove.s d0,fp0
	.short	0xf227,0x7400		| fmove.d fp0,-(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x2fc

_dpasin:				| -114: fasin.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x540c		| fasin.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x310

_dpacos:				| -120: facos.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x541c		| facos.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x324

_dplog10:				| -126: flog10.d
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5415		| flog10.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x338 (hunk end)

	.globl	_open,_close,_expunge,_initfn
