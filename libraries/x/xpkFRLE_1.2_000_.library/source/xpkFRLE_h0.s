||| xpkFRLE_h0.s -- byte-verbatim reconstruction of xpkFRLE.library 1.2(000)
||| ($VER: xpkFRLE V1.2 (1 Oct 2013) by Jorma Oksanen; 984 bytes,
||| single HUNK_DATA hunk of 0x370 bytes).
|||
||| Layout: ret0 stub + RomTag with rt_EndSkip=0 at hunk+4, name and
||| idstring, then an InitTable mid-hunk (dataSize=0x26, minimal
||| library base), a word-offset functab with leading 0xffff marker,
||| datatab, initfn storing the seglist at lib+0x22, then the
||| routines.  XpkInfo + mode tables + strings in the hunk tail.
||| Ascending 13-entry RELOC32 tail -- no fixup needed.
|||
||| Vectors: -6 Open, -12 Close, -18 Expunge, -24/-42/-48/-60 shared
||| moveq#0;rts, -30 XpkInfo, -36 pack, -54 unpack.

	.text

_ret0:					/* hunk+0x00 */
	moveq	#0,%d0
	rts

_romtag:				/* hunk+0x04 */
	.short	0x4afc			/* RTC_MATCHWORD */
	.long	_romtag			/* rt_MatchTag */
	.long	0			/* rt_EndSkip = literal 0 */
	.byte	0x80			/* rt_Flags = RTF_AUTOINIT */
	.byte	1			/* rt_Version */
	.byte	9			/* rt_Type = NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name			/* rt_Name */
	.long	_idstr			/* rt_IdString (includes $VER: cookie) */
	.long	_inittab		/* rt_Init */

_name:					/* hunk+0x1e */
	.ascii	"xpkFRLE.library\0"
_idstr:					/* hunk+0x2e */
	.ascii	"$VER: xpkFRLE V1.2 (1 Oct 2013) by Jorma Oksanen\r\n"
	.byte	0,0

_inittab:				/* hunk+0x62 */
	.long	0x26			/* dataSize (minimal base) */
	.long	_functab
	.long	_datatab
	.long	_init

_datatab:				/* hunk+0x72 */
	.byte	0xa0,0x08,0x09,0x00	/* ln_Type = NT_LIBRARY */
	.byte	0x80,0x0a
	.long	_name			/* ln_Name */
	.byte	0xa0,0x0e,0x06,0x00	/* lib_Flags = 6 */
	.byte	0x90,0x14,0x00,0x01	/* lib_Version = 1 */
	.byte	0x90,0x16,0x00,0x02	/* lib_Revision = 2 */
	.byte	0x80,0x18
	.long	_idstr			/* lib_IdString */
	.long	0			/* terminator */

_functab:				/* hunk+0x92, word offsets rel. table */
	.short	0xffff			/* marker */
	.short	_open-_functab		/* -6  Open */
	.short	_close-_functab		/* -12 Close */
	.short	_expunge-_functab	/* -18 Expunge */
	.short	_ret0-_functab		/* -24 (ret0) */
	.short	_xpkinfo-_functab	/* -30 XpkInfo */
	.short	_pack-_functab		/* -36 pack */
	.short	_ret0-_functab		/* -42 (ret0) */
	.short	_ret0-_functab		/* -48 (ret0) */
	.short	_unpack-_functab	/* -54 unpack */
	.short	_ret0-_functab		/* -60 (ret0) */
	.short	0xffff			/* terminator */

_init:					/* hunk+0xaa: d0=base a0=seglist */
	moveal	%d0,%a1
	movel	%a0,%a1@(0x22)		/* seglist at lib+0x22 */
	rts

_open:					/* hunk+0xb2 (-6) */
	addqw	#1,%a6@(0x20)		/* OpenCnt++ */
	bclr	#3,%a6@(0xe)		/* clear private DELEXP */
	movel	%a6,%d0
	rts

_close:					/* hunk+0xc0 (-12) */
	subqw	#1,%a6@(0x20)
	bne	_ret0			/* still open -> 0 */
	btst	#3,%a6@(0xe)
	beq	_ret0			/* no deferred expunge -> 0 */

_expunge:				/* hunk+0xd2 (-18, also Close tail) */
	tstw	%a6@(0x20)
	beqs	_expunge_do
	bset	#3,%a6@(0xe)		/* defer */
	bra	_ret0

_expunge_do:				/* hunk+0xe2 */
	moveml	%d2/%a5-%a6,%sp@-
	movel	%a6@(0x22),%d2		/* seglist */
	moveal	%a6,%a5
	moveal	%a5,%a1
	moveal	4,%a6			/* SysBase */
	jsr	%a6@(-252)		/* Remove */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(0x10),%d0		/* NegSize */
	subal	%d0,%a1
	addw	%a5@(0x12),%d0		/* NegSize+PosSize */
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d2,%d0			/* return seglist */
	moveml	%sp@+,%d2/%a5-%a6
	rts

_xpkinfo:				/* hunk+0x110 (-30) */
	lea	%pc@(_info),%a0
	movel	%a0,%d0
	rts

_pack:					/* hunk+0x118 (-36) RLE pack */
	moveml	%d2-%d6/%a2-%a6,%sp@-
	moveml	%a0@,%a1-%a3		/* a1=InBuf a2=InLen a3=OutBuf */
	moveal	%a3,%a4
	addal	%a2,%a4			/* a4 = OutBuf+InLen bound */
	addal	%a1,%a2			/* a2 = InEnd */
	moveq	#0x1f,%d3		/* literal token bias */
	moveq	#-0x61,%d4		/* 0x9f repeat token bias */
	bras	_pack_loop
_pack_run:				/* 0x12c: extend run */
	cmpb	%a1@+,%d1
	dbne	%d2,_pack_run
	beqs	1f
	subqw	#1,%a1
1:	cmpal	%a4,%a3
	bccw	_pack_over
	movel	%a1,%d0
	subl	%a5,%d0
	cmpal	%a2,%a1
	bcss	_pack_lit_tail
	movel	%a2,%d0
	subl	%a5,%d0
	beqw	_pack_done
	subqb	#2,%d0
	bmis	_pack_short
	eorb	%d4,%d0			/* repeat token (len-2)^0x9f */
	moveb	%d0,%a3@+
	moveb	%d1,%a3@+
	braw	_pack_done
_pack_short:				/* 0x15a */
	moveb	%d3,%a3@+		/* 0x1f token */
	moveb	%a2@-,%a3@+		/* byte before inend */
	braw	_pack_done
_pack_lit_tail:				/* 0x162: literal crossing inend */
	subqb	#2,%d0
	eorb	%d4,%d0
	moveb	%d0,%a3@+
	moveb	%d1,%a3@+
_pack_loop:				/* 0x16a */
	moveal	%a1,%a5			/* literal base */
	moveq	#126,%d2
	moveb	%a1@+,%d1
	moveb	%a1@+,%d0
	cmpb	%d0,%d1
	beqs	_pack_run
	moveq	#125,%d2
_pack_scan2:				/* 0x178 */
	moveb	%a1@+,%d1
	cmpb	%d0,%d1
	dbeq	%d2,_pack_scan3
	bnes	_pack_lit
	cmpb	%a1@,%d1
	dbeq	%d2,_pack_scan3
	bnes	_pack_lit
	bras	_pack_lit_back
_pack_scan3:				/* 0x18c */
	moveb	%a1@+,%d0
	cmpb	%d0,%d1
	dbeq	%d2,_pack_scan2
	bnes	_pack_lit
	cmpb	%a1@,%d0
	dbeq	%d2,_pack_scan2
	bnes	_pack_lit
_pack_lit_back:				/* 0x19e */
	subqw	#2,%a1
_pack_lit:				/* 0x1a0: emit literal a5..a1 */
	movel	%a1,%d0
	subl	%a5,%d0
	lea	%a3@(1,%d0:w),%a6	/* outpos + len + 1 */
	cmpal	%a4,%a6
	bccs	_pack_over
	cmpal	%a2,%a1
	bccs	_pack_lit_end
	subqb	#1,%d0
	moveb	%d0,%d1
	eorb	%d3,%d1			/* token (len-1)^0x1f */
	moveb	%d1,%a3@+
_pack_lit_cp:				/* 0x1b8 */
	moveb	%a5@+,%a3@+
	dbf	%d0,_pack_lit_cp
	bras	_pack_loop
_pack_lit_end:				/* 0x1c0: literals to inend */
	movel	%a2,%d0
	subl	%a5,%d0
	beqs	_pack_done
	subqb	#1,%d0
	eorb	%d0,%d3			/* token ^= len-1 (dead eor quirk) */
	moveb	%d3,%a3@+
_pack_lit_end_cp:
	moveb	%a5@+,%a3@+
	dbf	%d0,_pack_lit_end_cp
_pack_done:				/* 0x1d2 */
	subal	%a0@(8),%a3		/* outlen = a3 - OutBuf */
	movel	%a3,%a0@(0x10)		/* xsp_OutLen */
	moveml	%sp@+,%d2-%d6/%a2-%a6
	moveq	#0,%d0
	rts
_pack_over:				/* 0x1e2 */
	moveml	%sp@+,%d2-%d6/%a2-%a6
	moveq	#-17,%d0		/* overflow */
	rts

_unpack:				/* hunk+0x1ea (-54) RLE unpack */
	moveml	%d2-%d3/%a2,%sp@-
	moveml	%a0@,%a0-%a2		/* a0=InBuf a1=InLen a2=OutBuf */
	addal	%a0,%a1			/* a1 = InEnd */
	moveq	#6,%d3
	bras	_u_next
_u_rep:					/* 0x1f8: repeat run */
	moveb	%a0@+,%d2
	andw	%d0,%d1
	lsrw	%d3,%d0
	.short	0x4efb,0x1002		/* jmp pc@(2,d1:w) -> _u_rep_blk+N */
_u_rep_blk:				/* 0x202: 32 unrolled stores */
	.rept	32
	moveb	%d2,%a2@+
	.endr
	dbf	%d0,_u_rep_blk		/* 0x242 */
	moveb	%d2,%a2@+		/* 0x246: last one */
_u_next:				/* 0x248 */
	cmpal	%a1,%a0
	bccs	_u_done
_u_tok:					/* 0x24c */
	moveq	#0,%d0
	moveb	%a0@+,%d0		/* token */
	moveq	#62,%d1
	addb	%d0,%d0			/* bit7 -> carry = type */
	bcss	_u_rep
	andw	%d0,%d1
	lsrw	%d3,%d0
	.short	0x4efb,0x1002		/* jmp pc@(2,d1:w) -> _u_lit_blk+N */
_u_lit_blk:				/* 0x25e: 32 unrolled copies */
	.rept	32
	moveb	%a0@+,%a2@+
	.endr
	dbf	%d0,_u_lit_blk		/* 0x29e */
	cmpal	%a1,%a0			/* 0x2a2 */
	bcss	_u_tok
_u_done:				/* 0x2a6 */
	moveml	%sp@+,%d2-%d3/%a2
	moveq	#0,%d0
	rts

_info:					/* hunk+0x2ae: XpkInfo */
	.short	1,1			/* xpi_Version, xpi_Revision */
	.long	0x00020000		/* xpi_Flags */
	.long	_short			/* xpi_ShortName */
	.long	_long			/* xpi_LongName */
	.long	_desc			/* xpi_Description */
	.ascii	"FRLE"
	.long	9			/* top byte doubles as ID nul */
	.long	0x7fffffff		/* xpi_MaxChunk */
	.long	0
	.long	0x8000
	.long	0,0,0,0
	.long	0x00640000
	.long	_modes			/* xpi_XpkModes -> 0x306 */
	.long	0,0,0,0,0,0
_modes:					/* 0x306: XpkMode array */
	.long	0,0x64,1,0,0
	.long	0x172,0x47e
	.long	0x00300000		/* trailing field */

	.ascii	"normal\0"		/* 0x326 */
	.byte	0,0,0
_short:					/* 0x330 */
	.ascii	"FastRLE\0"
_long:					/* 0x338 */
	.ascii	"Fast Run Length Encoder V1.2\0"
_desc:					/* 0x355 */
	.ascii	"Optimized RLE for 68000\0"
	.ascii	"EVE"			/* 0x36d: trailing junk bytes */
