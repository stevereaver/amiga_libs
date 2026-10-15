* verbatim reconstruction of xpkNONE_1.2.library (732B, long functab,
* rt_EndSkip=0x102 ends the resident before the strings/XpkInfo island)
	.text

	/* 0x000 entry stub */
	moveq	#-1,%d0
	rts

	/* 0x004 RomTag */
_romtag:
	.short	0x4afc
	.long	_romtag		/* rt_MatchTag */
	.long	_endskip	/* rt_EndSkip: mid-insn, cuts at 0x102 */
	.byte	0x80		/* RTF_AUTOINIT */
	.byte	0x01		/* version 1 */
	.byte	0x09		/* NT_LIBRARY */
	.byte	0x00		/* pri */
	.long	_libname
	.long	_idstr
	.long	_inittab

	/* 0x01e InitTable */
_inittab:
	.long	0x22		/* dataSize (not relocated) */
	.long	_functab
	.long	_datatab
	.long	_initfn

	/* 0x02e long-offset function table (10 vectors + -1) */
_functab:
	.long	_open		/* -6 */
	.long	_close		/* -12 */
	.long	_expunge	/* -18 */
	.long	_null1		/* -24 */
	.long	_xpkinfo	/* -30 */
	.long	_fail		/* -36 */
	.long	_null2		/* -42 */
	.long	_null2		/* -48 */
	.long	_copymem	/* -54 */
	.long	_null2		/* -60 */
	.long	-1

	/* 0x05a InitStruct data table (word-aligned commands) */
_datatab:
	.byte	0xa0,0x08,0x09		/* byte[+8] = 9 ln_Type */
	.byte	0
	.byte	0x80,0x0a
	.long	_libname		/* ln_Name */
	.byte	0xa0,0x0e,0x06		/* byte[+0xe] = 6 ln_Flags */
	.byte	0
	.byte	0x90,0x14
	.short	1			/* lib_Version = 1 */
	.byte	0x90,0x16
	.short	2			/* lib_Revision = 2 -> "1.2" */
	.byte	0x80,0x18
	.long	_idstr			/* lib_IdString */
	.byte	0,0,0,0			/* 0x76: end + zeros */

	/* 0x07a seglist cell (inside dead datatab space) */
_segcell:
	.long	0

	/* 0x07e initfn */
_initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,_segcell		/* segcell (absolute long) */
	bsrw	_null2
	tstl	%d0
	bnes	_iretry
	movel	%a5,%d0
_ipop:	moveal	%sp@+,%a5
	rts
_iretry:
	bsrw	_null2
	moveq	#0,%d0
	bras	_ipop

	/* 0x09e open */
_open:
	addqw	#1,%a6@(0x20)
	bclrb	#3,%a6@(0x0e)
	movel	%a6,%d0
	rts

	/* 0x0ac close */
_close:
	moveq	#0,%d0
	subqw	#1,%a6@(0x20)
	bnes	2f
	btstb	#3,%a6@(0x0e)
	beqs	2f
	bsrs	_expunge
2:	rts

	/* 0x0c0 expunge */
_expunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	0x4.w,%a6
	tstw	%a5@(0x20)
	beqs	3f
	bsetb	#3,%a6@(0x0e)
	moveq	#0,%d0
	bras	4f
3:	movel	_segcell(%pc),%d2
	moveal	%a5,%a1
	jsr	%a6@(-0xfc)		/* Remove */
	bsrs	_null2
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(0x10),%d0		/* NegSize */
	subal	%d0,%a1
	addw	%a5@(0x12),%d0		/* + PosSize */
	jsr	%a6@(-0xd2)		/* FreeMem */
	movel	%d2,%d0		/* return seglist */
4:	moveml	%sp@+,%d2/%a5-%a6
	rts

	/* 0x100 reserved -24; rt_EndSkip lands on the rts at 0x102 */
_null1:
	moveq	#0,%d0
_endskip:
	rts

	/* 0x104 strings (beyond endskip!) */
_libname:
	.ascii	"xpkNONE.library"
	.byte	0
_idstr:
	.ascii	"xpkNONE 1.2 (01.04.1997)"
	.byte	0x0d,0x0a,0,0		/* NUL + pad (code resumes even) */

	/* 0x130 shared null (-42/-48/-60 + init helper) */
_null2:
	moveq	#0,%d0
	rts

	/* 0x134 -30 XPKInfo */
_xpkinfo:
	leal	_xpkdata(%pc),%a0
	movel	%a0,%d0
	rts

	/* 0x13c -36 -> -17 */
_fail:
	moveq	#-17,%d0
	rts

	/* 0x140 -54 CopyMem passthrough */
_copymem:
	movel	%a6,%sp@-
	moveal	%a0@(8),%a1		/* dst = pb[2] */
	movel	%a0@(4),%d0		/* len = pb[1] */
	movel	%d0,%a0@(16)		/* pb[4] = len */
	moveal	%a0@,%a0		/* src = pb[0] */
	moveal	0x4.w,%a6
	jsr	%a6@(-0x270)		/* CopyMem */
	moveal	%sp@+,%a6
	moveq	#0,%d0
	rts

	/* 0x15e XpkInfo island */
_xpkdata:
	.short	0x0001,0x0001		/* version fields */
	.long	0
	.long	_sig			/* sig ptr -> string "NONE" */
	.long	_nopacker		/* name ptr */
	.long	_desc			/* desc ptr */
	.ascii	"NONE"			/* inline signature @0x172 */
	.long	9
	.long	0x7d00
	.long	0x14
	.long	0x7d00
	.long	_writing		/* status ptrs */
	.long	_reading
	.long	_wrote
	.long	_read
	.long	0x00320000
	.long	_xpkext			/* -> second struct @0x20a */
	.long	0,0,0,0,0,0

	/* strings */
_sig:	.ascii	"NONE"			/* 0x1b6 signature str */
	.byte	0
_nopacker:
	.ascii	"NoPacker"
	.byte	0
_desc:
	.ascii	"A dummy library that does no compression."
	.byte	0
_reading:
	.ascii	"Reading"
	.byte	0			/* 0x1ee */
_writing:
	.ascii	"Writing"
	.byte	0			/* 0x1f6 */
_read:	.ascii	"Read"
	.byte	0			/* 0x1fe */
_wrote:	.ascii	"Wrote"
	.byte	0,0			/* 0x203 + pad to 0x20a */

	/* 0x20a second param struct */
_xpkext:
	.long	0
	.long	0x64
	.long	1
	.long	0
	.long	0
	.long	0x77e
	.long	0x9ad
	.long	0
	.ascii	"normal"
	.byte	0,0,0,0			/* 0x22a + pads to 0x234 */
