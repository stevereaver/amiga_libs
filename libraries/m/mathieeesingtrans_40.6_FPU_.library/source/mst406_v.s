|||	mst406_v.s -- verbatim reconstruction of mathieeesingtrans.library
|||	40.6 (7.4.95) for 68881/82 by Martin Berndt.  Single CODE hunk,
|||	AUTOINIT, absolute-long functab (21 vectors, -6..-126).
|||
|||	Quirks preserved verbatim:
|||	  - rt_EndSkip = 0x82 -> the InitTable itself; the resident copy
|||	    ends before functab/datatab/code (mid-module quirk).
|||	  - functab -24 slot holds literal 0; its RELOC32 entry makes it
|||	    resolve to the code+0 'moveq #0,rts' entry stub.
|||	  - -102/-108 (IEEESPTieee/IEEESPFieee) are NOT implemented: both
|||	    point at the shared rts at 0x258 (Sprintf/ieee unimplemented).
|||	  - Pow's 'fbne.w' at 0x220 (x<0 && frac(y)!=0) branches back to
|||	    CODE+0 -- the entry stub's 'moveq #0;rts' -- so pow(-x,nonint)
|||	    early-returns 0 by reusing the hunk prologue.
|||	  - 'fbeq.w +6' after fmod(y,2) skips the sign restore for even
|||	    exponents; pow(-x,even) is positive, pow(-x,odd) negative.
|||	  - Private deferred-expunge flag is bit 3 of lib+0x2a (not the
|||	    lib_Flags byte).
|||	  - FPU line-F words emitted raw (gas mnemonics could differ).

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

_name:	.ascii	"mathieeesingtrans.library\0"
_idstr:	.ascii	"mathieeesingtrans 40.6 (7.4.95) for 68881/82\r\n\0"
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
	.long	_ieeespatan		| -30
	.long	_ieeespsin		| -36
	.long	_ieeespcos		| -42
	.long	_ieeesptan		| -48
	.long	_ieeespsincos		| -54
	.long	_ieeespsinh		| -60
	.long	_ieeespcosh		| -66
	.long	_ieeesptanh		| -72
	.long	_ieeespexp		| -78
	.long	_ieeesplog		| -84
	.long	_ieeesppow		| -90
	.long	_ieeespsqrt		| -96
	.long	_bare_rts		| -102 IEEESPTieee (unimpl.)
	.long	_bare_rts		| -108 IEEESPFieee (unimpl.)
	.long	_ieeespasin		| -114
	.long	_ieeespacos		| -120
	.long	_ieeesplog10		| -126
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

_open:
	addqw	#1,%a6@(0x20)
	bclr	#3,%a6@(0x2a)		| private deferred flag
	movel	%a6,%d0
3:	rts
	.short	0			| pad -> 0x144

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

	|  Each math stub: f<op>.s d0 -> fp0; fmove.s fp0 -> d0; rts
_ieeespatan:
	.short	0xf200,0x440a		| fatan.s d0,fp0
	.short	0xf200,0x6400		| fmove.s fp0,d0
	rts
	.short	0
_ieeespsin:
	.short	0xf200,0x440e		| fsin.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeespcos:
	.short	0xf200,0x441d		| fcos.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeesptan:
	.short	0xf200,0x440f		| ftan.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeespsincos:
	.short	0xf200,0x4431		| fsincos.s d0,fp1:fp0
	.short	0xf200,0x6400		| fmove.s fp0,d0 (sin)
	.short	0xf210,0x6480		| fmove.s fp1,(a0) (cos)
	rts
	.short	0
_ieeespsinh:
	.short	0xf200,0x4402		| fsinh.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeespcosh:
	.short	0xf200,0x4419		| fcosh.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeesptanh:
	.short	0xf200,0x4409		| ftanh.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeespexp:
	.short	0xf200,0x4410		| fetox.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeesplog:
	.short	0xf200,0x4414		| flogn.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeesppow:				| -90: pow(x=d0, y=d1)
	tstl	%d0
	bpls	6f			| x>=0 -> common x^y helper
	bclr	#31,%d0			| x = |x|
	.short	0xf201,0x4401		| fint.s d1,fp1 (int part of exp)
	.short	0xf201,0x4428		| fsub.s d1,fp1 (fp1 = frac)
	.short	0xf28e			| fbne.w ...
	.short	0xfdde			| ... -> CODE+0 (early return 0)
	bsrs	6f			| d0 = |x|^y
	.short	0xf201,0x4400		| fmove.s d1,fp1
	.short	0xf23c,0x4421		| fmod.s #2.0,fp1 (exponent parity)
	.long	0x40000000
	.short	0xf281,0x0006		| fbeq.w +6 (even -> skip sign flip)
	bset	#31,%d0			| odd exponent -> restore sign
	rts
6:	.short	0xf200,0x4414		| flogn.s d0,fp0  (ln x)
	.short	0xf201,0x4423		| fmul.s d1,fp1   (y * ln x)
	.short	0xf200,0x0010		| fetox.x fp0,fp0 (e^(..))
	.short	0xf200,0x6400		| fmove.s fp0,d0
	rts
	.short	0			| pad -> 0x250

_ieeespsqrt:
	.short	0xf200,0x4404		| fsqrt.s d0,fp0
	.short	0xf200,0x6400
_bare_rts:				| -102/-108 share this rts
	rts
	.short	0
_ieeespasin:
	.short	0xf200,0x440c		| fasin.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeespacos:
	.short	0xf200,0x441c		| facos.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0
_ieeesplog10:
	.short	0xf200,0x4415		| flog10.s d0,fp0
	.short	0xf200,0x6400
	rts
	.short	0			| pad -> 0x280

_endskip:

	.globl	_open,_close,_expunge,_initfn
