||||	mdb406_v.s -- verbatim reconstruction of mathieeedoubbas.library
||||	40.6 (7.4.95) for 68881/82 by Martin Berndt.  Single CODE hunk,
||||	AUTOINIT, absolute-long functab (16 vectors, -6..-96).
||||
||||	Quirks preserved verbatim:
||||	  - rt_EndSkip = 0x7e -> the InitTable itself; the resident copy
||||	    ends before functab/datatab/code (mid-module quirk).
||||	  - functab -24 slot holds literal 0; its RELOC32 entry makes it
||||	    resolve to the code+0 'moveq #0,rts' entry stub.
||||	  - Open writes FPCR = 0x90 (double precision, round-to-zero)
||||	    via moveq #72 / add.l d0,d0.
||||	  - IEEEDPFix uses 'fmove.l fp0,d0' -- converts under the CURRENT
||||	    FPCR (which Open just set to round-to-zero, so it truncates).
||||	  - IEEEDPFloor on x<0 saves FPCR (fmove.l fpcr,d0 / move.l d0,d1),
||||	    loads 0x20 (round->-inf), fint.x fp0,fp0, restores FPCR.
||||	  - IEEEDPCeil = -floor(-x), but skips the sign restore when the
||||	    result is +0/-0 (tst.l d0/d1 guard) so ceil(-x) keeps +0.
||||	  - Private deferred-expunge flag is bit 3 of lib+0x2a (not the
||||	    lib_Flags byte).
||||	  - IEEE doubles move through the USER stack (fmoved sp@+ / fopd
||||	    (sp) / fmoved fp0,(sp)); fp0 is caller-clobbered.
||||	  - FPU line-F words emitted raw (gas mnemonics could differ).

	.section .text

_entry:	moveq	#0,%d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_inittab		| rt_EndSkip=0x7e -> InitTable (mid-module)
	.byte	0x80			| rt_Flags = RTF_AUTOINIT
	.byte	40			| rt_Version
	.byte	9			| rt_Type = NT_LIBRARY
	.byte	0			| rt_Pri
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"mathieeedoubbas.library\0"
_idstr:	.ascii	"mathieeedoubbas 40.6 (7.4.95) for 68881/82\r\n\0"
	.ascii	"(c) 1995 by Martin Berndt\0"
	.byte	0			| pad -> 0x7e

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
	.long	_dpfix			| -30
	.long	_dpflt			| -36
	.long	_dpcmp			| -42
	.long	_dptst			| -48
	.long	_dpabs			| -54
	.long	_dpneg			| -60
	.long	_dpadd			| -66
	.long	_dpsub			| -72
	.long	_dpmul			| -78
	.long	_dpdiv			| -84
	.long	_dpfloor		| -90
	.long	_dpceil			| -96
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
	.short	0			| pad -> 0xf4

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
	.short	0			| pad -> 0x11c

_open:					| -6
	moveq	#72,%d0
	addl	%d0,%d0			| d0 = 0x90
	.short	0xf200,0x9000		| fmove.l d0,fpcr (dbl prec, RZ)
	addqw	#1,%a6@(0x20)
	bclr	#3,%a6@(0x2a)		| private deferred flag
	movel	%a6,%d0
3:	rts
	.short	0			| pad -> 0x134

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

_dpfix:					| -30: long <- double d0:d1
	moveml	%d0-%d1,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0
	.short	0xf200,0x6000		| fmove.l fp0,d0 (FPCR mode)
	rts
	.short	0			| pad -> 0x194

_dpflt:					| -36: double <- long d0
	.short	0xf200,0x4000		| fmove.l d0,fp0
	.short	0xf227,0x7400		| fmove.d fp0,-(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x1a4

_dpcmp:					| -42: integer cmp tree, +0==-0
	tstl	%d0
	bmis	6f			| a<0
	tstl	%d2
	bpls	7f			| b>=0
	tstl	%d0
	bnes	8f			| a>0 -> +1
	tstl	%d1
	bnes	8f
	tstl	%d3
	bnes	8f
	movel	%d2,%d0			| a==+0: -0==+0 test on b
	addl	%d0,%d0
	bnes	8f
	moveq	#0,%d0
	rts
	.short	0			| pad -> 0x1c4
7:	cmpl	%d2,%d0			| a,b >= 0
	bmis	9f			| a<b -> -1
	bgts	8f			| a>b -> +1
	cmpl	%d1,%d3			| d3-d1
	bcss	8f
	bnes	9f
	moveq	#0,%d0
	rts
6:	tstl	%d2			| a<0
	bmis	10f			| b<0 too
	bnes	9f			| b>0 -> -1
	tstl	%d3
	bnes	9f
	tstl	%d1
	bnes	9f
	addl	%d0,%d0			| b==+0: a==-0?
	bnes	9f
	moveq	#0,%d0
	rts
	.short	0			| pad -> 0x1ec
10:	cmpl	%d0,%d2			| a,b < 0: d2-d0
	bmis	9f
	bgts	8f
	cmpl	%d3,%d1			| d1-d3
	bcss	8f
	bhis	9f
11:	moveq	#0,%d0
	rts
_dptst:					| -48: sign test via add.l d0,d0
	addl	%d0,%d0			| sign*2 -> C, rest -> Z
	bcss	12f			| bit31 set -> negative check
	bnes	8f			| nonzero -> +1
	tstl	%d1
	beqs	11b			| all zero -> 0
8:	moveq	#1,%d0
	rts
	.short	0			| pad -> 0x20c
12:	bnes	9f			| exp/mantissa nonzero -> -1
	tstl	%d1
	beqs	11b			| -0 -> 0
9:	moveq	#-1,%d0
	rts
	.short	0			| pad -> 0x218

_dpabs:					| -54
	bclr	#31,%d0
	rts
	.short	0			| pad -> 0x220

_dpneg:					| -60
	bchg	#31,%d0
	rts
	.short	0			| pad -> 0x228

_dpadd:					| -66: (d0:d1) + (d2:d3)
	moveml	%d0-%d3,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0   (left)
	.short	0xf217,0x5422		| fadd.d (sp),fp0     (right)
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x240

_dpsub:					| -72
	moveml	%d0-%d1,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0   (left)
	moveml	%d2-%d3,%sp@-
	.short	0xf217,0x5428		| fsub.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x25c

_dpmul:					| -78
	moveml	%d0-%d3,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0
	.short	0xf217,0x5423		| fmul.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x274

_dpdiv:					| -84
	moveml	%d0-%d1,%sp@-
	.short	0xf21f,0x5400		| fmove.d (sp)+,fp0
	moveml	%d2-%d3,%sp@-
	.short	0xf217,0x5420		| fdiv.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x290

_dpfloor:				| -90
	tstl	%d0
	blts	13f			| x<0 -> FPCR path
	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5403		| fintrz.d (sp),fp0
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts
	.short	0			| pad -> 0x2a6
13:	moveml	%d0-%d1,%sp@-
	.short	0xf217,0x5400		| fmove.d (sp),fp0 (no pop)
	.short	0xf200,0xb000		| fmove.l fpcr,d0
	movel	%d0,%d1			| save fpcr
	moveb	#0x20,%d0		| round->-inf
	.short	0xf200,0x9000		| fmove.l d0,fpcr
	.short	0xf200,0x0001		| fint.x fp0,fp0
	.short	0xf201,0x9000		| fmove.l d1,fpcr (restore)
	.short	0xf217,0x7400		| fmove.d fp0,(sp)
	movel	%sp@+,%d0
	movel	%sp@+,%d1
	rts

_dpceil:				| -96: -floor(-x)
	bchg	#31,%d0			| -x
	bsrs	_dpfloor
	tstl	%d0
	bnes	14f
	tstl	%d1
	beqs	15f			| +0/-0 -> keep sign as-is
14:	bchg	#31,%d0			| negate back
15:	rts

	.globl	_open,_close,_expunge,_initfn
