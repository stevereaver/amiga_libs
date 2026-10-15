||
|||	680x0_h0.s -- byte-verbatim reconstruction of 680x0.library 46.1
||| (MMU) (04.07.2016) -- identical to the 40.4 build except the
|||	version/revision immediates and idstring text (864 bytes, 2 hunks).
|||
|||	hunk0 .text 0x20c: entry stub, RomTag (AUTOINIT, ver 40,
|||	endskip literal 0), -24 ret0 stub, LibInit (CPU detect via
|||	AttnFlags ladder + supervisor `movec pcr` probe, writes all
|||	base fields itself -- InitTable.datatab is 0), LibOpen,
|||	LibClose (decrement only -- NO expunge test at all), LibExpunge
|||	(shared ret0: this lib can never be expunged once resident),
|||	060 probe wrapper + supervisor code, 680N0.library open helper
|||	(name copied to a 32-byte stack buffer, digit patched in),
|||	CPUType, FPUType, MMUType, SetFPUExceptions.
|||
|||	hunk1 .data 0xa8: InitTable (dataSize 0x40, functab->data+0x10,
|||	datatab 0, initfn->code+0x22), 8-entry absolute-long functab
|||	(relocated to hunk0) + -1L, then strings.
|||
|||	Relocs: code hunk -- group hunk0 [0x6] (rt_MatchWord),
|||	group hunk1 [0x12,0x16,0x1a,0x7a,0x82,0x138,0x1a0]
|||	(rt_Name/IdString/Init + ln_Name/IdString immediates + the two
|||	`lea abs.l` name operands).  DATA hunk -- group hunk0
|||	[0xc..0x2c] (initfn + 8 functab slots), group hunk1 [0x4]
|||	(InitTable.functab self-pointer).
|||

	.text

_entry:					/* 0x00 hunk entry */
	moveq	#-1,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc			/* rt_MatchTag */
	.long	_romtag			/* rt_MatchWord (reloc hunk0 @6) */
	.long	0			/* rt_EndSkip = literal 0 */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	46			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* pri */
	.long	_s_libname		/* rt_Name (reloc hunk1 @0x12) */
	.long	_s_idstr		/* rt_IdString -> "680x0.library 40.4..." */
	.long	_inittab		/* rt_Init -> DATA+0 (reloc hunk1 @0x1a) */

_ret0:					/* 0x1e -- -24 slot */
	moveq	#0,d0
	rts

/* LibInit(d0=base, a0=seglist, a6=SysBase).  Requires exec >= 36;
 * detects CPU from AttnFlags (010..040) falling back to the PCR
 * probe for 060, then opens the matching 680N0.library driver --
 * frees itself and returns NULL if the driver is missing. */
_init:					/* 0x22 */
	moveml	%d2/%a2-%a6,%sp@-
	moveal	%d0,%a4
	movel	%a6,%a4@(0x38)		/* xb_SysBase */
	movel	%a0,%a4@(0x2c)		/* xb_SegList */
	cmpiw	#36,%a6@(0x14)		/* exec lib_Version >= 36 */
	bcsw	_fail
	moveq	#48,%d2			/* '0' */
	moveb	%a6@(0x129),%d0		/* AttnFlags */
	btst	#0,%d0			/* AFF_68010 */
	beqs	1f
	moveq	#49,%d2			/* '1' */
	btst	#1,%d0			/* AFF_68020 */
	beqs	1f
	moveq	#50,%d2			/* '2' */
	btst	#2,%d0			/* AFF_68030 */
	beqs	1f
	moveq	#51,%d2			/* '3' */
	btst	#3,%d0			/* AFF_68040 */
	beqs	1f
	moveq	#52,%d2			/* '4' */
	bsrw	_probe060
	beqs	1f
	moveq	#54,%d2			/* '6' */
1:	moveb	%d2,%a4@(0x3c)		/* xb_CPUType char */
	moveb	#9,%a4@(8)		/* ln_Type = NT_LIBRARY */
	moveb	#6,%a4@(0xe)		/* ln_Flags */
	movel	#_s_libname,%a4@(0xa)	/* ln_Name (imm reloc hunk1 @0x7a) */
	movel	#_s_idstr,%a4@(0x18)	/* ln_IdString (imm reloc @0x82) */
	movel	#0x002e0001,%a4@(0x14)	/* lib_Version=46 lib_Revision=1 */
	movel	#0x54484f52,%a4@(0x24)	/* 'THOR' */
	bsrw	_open680x0		/* try the driver lib */
	beqs	_fail
	bras	_done
_fail:
	moveal	%a4,%a1
	moveq	#0,%d0
	moveq	#0,%d1
	movew	%a4@(0x10),%d0		/* lib_NegSize */
	movew	%a4@(0x12),%d1		/* lib_PosSize */
	subal	%d0,%a1
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem(a1,d0) -- free self */
	subal	%a4,%a4			/* return NULL */
_done:
	movel	%a4,%d0
	moveml	%sp@+,%d2/%a2-%a6
	rts

/* LibOpen: clears DELEXP (bit3 of lib_Flags), OpenCnt++. */
_open:					/* 0xc0 */
	bclr	#3,%a6@(0xe)
	addqw	#1,%a6@(0x20)
	movel	%a6,%d0
	rts

/* LibClose: decrement only -- NEVER expunges (no flag test). */
_close:					/* 0xce */
	tstw	%a6@(0x20)
	beqs	1f
	subqw	#1,%a6@(0x20)
1:	moveq	#0,%d0
	rts

_expunge:				/* 0xdc -- shared ret0: no expunge */
	moveq	#0,d0
	rts

/* 68060 probe wrapper: Supervisor() through exec -30. */
_probe060:				/* 0xe0 */
	moveml	%a5,%sp@-
	moveal	%a4@(0x38),%a6		/* exec base */
	lea	%pc@(_super),%a5
	jsr	%a6@(-30)		/* Supervisor(a5) */
	tstl	%d0
	moveml	%sp@+,%a5
	rts

/* Supervisor-mode: fake a vector table on the stack, aim the VBR at
 * it, try 68060-only `movec pcr,d1`.  Illegal/line-F on <= 68040
 * takes vector 4/11 -> _probe_trap (d0=0); success rte's via
 * vector-31 path with d0=1. */
_super:					/* 0xf8 */
	oriw	#0x0700,%sr
	lea	%sp@(-128),%sp
	movec	%vbr,%a0
	lea	%pc@(_probe_trap),%a1
	movel	%a1,%sp@(0x10)		/* vector 4: illegal instruction */
	movel	%a1,%sp@(0x2c)		/* vector 11: line-F */
	lea	%pc@(_probe_rte),%a1
	movel	%a1,%sp@(0x7c)		/* vector 31 */
	movec	%sp,%vbr
	moveq	#1,%d0
	.short	0x4e7a,0x1808		/* movec %pcr,%d1 (68060 only) */
_probe_done:				/* 0x122 */
	movec	%a0,%vbr
	lea	%sp@(128),%sp
_probe_rte:				/* 0x12a */
	rte
_probe_trap:				/* 0x12c */
	moveq	#0,%d0
	addql	#8,%sp			/* drop exception frame */
	bras	_probe_done

/* Helper: copy "680x0.library" to a 32-byte stack buffer, patch
 * position 3 with the detected CPU digit, OpenLibrary(name,46). */
_open680x0:				/* 0x132 */
	lea	%sp@(-32),%sp
	lea	_s_libname,%a0		/* abs.l -> DATA+0x34 (reloc @0x138) */
	moveal	%sp,%a1
1:	moveb	%a0@+,%a1@+
	bnes	1b
	moveb	%a4@(0x3c),%sp@(3)	/* 'x' -> '0'..'4'/'6' */
	moveal	%a4@(0x38),%a6		/* exec base */
	moveal	%sp,%a1
	moveq	#46,%d0			/* driver must be >= 46.x */
	jsr	%a6@(-552)		/* OpenLibrary */
	lea	%sp@(32),%sp
	tstl	%d0
	rts

/* CPUType (-30): returns the stored digit char. */
_cputype:				/* 0x15c */
	moveq	#0,%d0
	moveb	%a6@(0x3c),%d0
	rts

/* FPUType (-36): 060 -> CPU digit; 68882 -> '2'; 68881 -> '1';
 * else 0. */
_fputype:				/* 0x164 */
	moveq	#0,%d1
	moveal	%a6@(0x38),%a0		/* exec base */
	moveb	%a0@(0x129),%d0		/* AttnFlags */
	btst	#6,%d0			/* AFF_68060 */
	bnes	1f
	btst	#5,%d0			/* AFF_68882 */
	bnes	2f
	btst	#4,%d0			/* AFF_68881 */
	beqs	3f
	moveq	#49,%d1			/* '1' */
	bras	3f
2:	moveq	#50,%d1			/* '2' */
	bras	3f
1:	moveb	%a6@(0x3c),%d1		/* CPU digit ('6') */
3:	moveq	#0,%d0
	moveb	%d1,%d0
	rts

/* MMUType (-42): OpenLibrary("mmu.library",40), calls its -54
 * vector, closes it again. */
_mmutype:				/* 0x192 */
	moveml	%d2/%a4/%a6,%sp@-
	moveal	%a6,%a4
	moveal	%a4@(0x38),%a6
	moveq	#0,%d0
	lea	_s_mmulib,%a1		/* abs.l -> DATA+0x42 (reloc @0x1a0) */
	jsr	%a6@(-552)		/* OpenLibrary */
	movel	%d0,%d2
	beqs	1f
	moveal	%d0,%a6		/* mmu.library base */
	jsr	%a6@(-54)		/* mmu type query vector */
	movel	%d0,%d2
	moveal	%a6,%a1
	moveal	%a4@(0x38),%a6
	jsr	%a6@(-414)		/* CloseLibrary */
1:	movel	%d2,%d0
	moveml	%sp@+,%d2/%a4/%a6
	rts

/* SetFPUExceptions (-48): opens the 680N0 driver, requires driver
 * lib_Version>=40 and lib_NegSize>=0xde (vector -222 exists), then
 * forwards (d0,d1) to the driver's -222 vector. */
_setfpu:				/* 0x1c6 */
	moveml	%d2-%d3/%a4/%a6,%sp@-
	moveal	%a6,%a4
	movel	%d0,%d2
	movel	%d1,%d3
	bsrw	_open680x0
	beqs	2f
	moveal	%d0,%a6		/* driver base */
	cmpiw	#40,%a6@(0x14)		/* lib_Version >= 40 */
	bcss	1f
	cmpiw	#222,%a6@(0x10)		/* lib_NegSize >= 0xde */
	bcss	1f
	movel	%d2,%d0
	movel	%d3,%d1
	jsr	%a6@(-222)		/* driver's SetFPUExceptions */
	movel	%d0,%d2
	bras	3f
1:	moveq	#0,%d2
3:	moveal	%a6,%a1
	moveal	%a4@(0x38),%a6
	jsr	%a6@(-414)		/* CloseLibrary */
	bras	4f
2:	moveq	#0,%d2
4:	movel	%d2,%d0
	moveml	%sp@+,%d2-%d3/%a4/%a6
	rts

/* ---- hunk1: DATA ---------------------------------------------- */
	.data

_inittab:				/* data+0x00 InitTable */
	.long	0x40			/* dataSize */
	.long	_functab		/* -> data+0x10 (reloc hunk1 @4) */
	.long	0			/* initDataTab: none */
	.long	_init			/* initRoutine -> code+0x22 */

_functab:				/* data+0x10 (relocs hunk0) */
	.long	_open			/* -6  0xc0 */
	.long	_close			/* -12 0xce */
	.long	_expunge		/* -18 0xdc (ret0: never expunges) */
	.long	_ret0			/* -24 0x1e */
	.long	_cputype		/* -30 0x15c */
	.long	_fputype		/* -36 0x164 */
	.long	_mmutype		/* -42 0x192 */
	.long	_setfpu			/* -48 0x1c6 */
	.long	0xffffffff

_s_libname:				/* data+0x34 */
	.ascii	"680x0.library"
	.byte	0
_s_mmulib:				/* data+0x42 */
	.ascii	"mmu.library"
	.byte	0
_s_cookie:				/* data+0x4e */
	.ascii	"$VER: "
_s_idstr:				/* data+0x54 -- points past cookie */
	.ascii	"680x0.library 46.1 (04.07.2016) (c) 1999-2016 The MMU.lib development group, THOR\n\r"
	.byte	0
