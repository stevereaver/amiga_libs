/* xpkCBR0.library V1.2 (1 Oct 2013) by Bilbo -- verbatim reconstruction.
 * Single CODE hunk, AUTOINIT RomTag.  Word-offset functab bracketed by
 * 0xffff; unused slots (-24,-42,-48,-60) point at the entry stub at
 * hunk offset 0 (offset -0x8a).  Quirks: rt_EndSkip = 0; the InitTable
 * stores pointers in functab-after-datatab order (datatab 0x6a precedes
 * functab 0x8a); init stores only the seglist (dataSize 0x26, no saved
 * SysBase -- expunge loads exec base from absolute 4); pack bounds the
 * output by OutBuf+InLen (xsp_OutBufLen is ignored) and returns -17 on
 * overflow.  Codec: IFF-ByteRun1-style RLE (n>=0: n+1 literals;
 * n<0: -n+1 repeats) with a 125-entry look-ahead in the encoder.
 */
	.text

/* ---- 0x00 entry stub / shared null vector ----------------------- */
_stub0:
	moveq	#0,d0
	rts

/* ---- 0x04 RomTag ------------------------------------------------ */
_romtag:
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	0			/* rt_EndSkip = 0 (quirky) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	0x01			/* rt_Version */
	.byte	0x09			/* NT_LIBRARY */
	.byte	0x00			/* rt_Pri */
	.long	_libname		/* 0x1e */
	.long	_idstr			/* 0x2e */
	.long	_inittab		/* 0x5a */

_libname:
	.ascii	"xpkCBR0.library"	/* 0x1e */
	.byte	0
_idstr:
	.ascii	"$VER: xpkCBR0 V1.2 (1 Oct 2013) by Bilbo"	/* 0x2e */
	.byte	0x0d,0x0a
	.byte	0,0			/* NUL + pad to 0x5a */

/* ---- 0x5a InitTable --------------------------------------------- */
_inittab:
	.long	0x26			/* dataSize: Library + seglist */
	.long	_functab		/* 0x8a (after datatab!) */
	.long	_datatab		/* 0x6a */
	.long	_init			/* 0xa2 */

/* ---- 0x6a InitStruct data table --------------------------------- */
_datatab:
	.byte	0xa0,0x08,0x09,0x00	/* byte[+8] = 9 ln_Type */
	.byte	0x80,0x0a
	.long	_libname		/* ln_Name */
	.byte	0xa0,0x0e,0x06,0x00	/* byte[+0xe] = 6 lib_Flags */
	.byte	0x90,0x14
	.short	1			/* lib_Version = 1 */
	.byte	0x90,0x16
	.short	2			/* lib_Revision = 2 -> "1.2" */
	.byte	0x80,0x18
	.long	_idstr			/* lib_IdString */
	.byte	0,0,0,0			/* terminator + pad */

/* ---- 0x8a word-offset function table (offsets from _functab) ----- */
_functab:
	.short	0xffff
	.short	_open    - _functab	/* -6   -> 0xaa */
	.short	_close   - _functab	/* -12  -> 0xb8 */
	.short	_expunge - _functab	/* -18  -> 0xca */
	.short	_stub0   - _functab	/* -24  -> 0x00 */
	.short	_xpkinfo - _functab	/* -30  -> 0x108 */
	.short	_pack    - _functab	/* -36  -> 0x110 */
	.short	_stub0   - _functab	/* -42  -> 0x00 */
	.short	_stub0   - _functab	/* -48  -> 0x00 */
	.short	_unpack  - _functab	/* -54  -> 0x1cc */
	.short	_stub0   - _functab	/* -60  -> 0x00 */
	.short	0xffff

/* ---- code ------------------------------------------------------- */
_init:					/* 0xa2 */
	moveal	d0,a1			/* lib base */
	movel	a0,a1@(0x22)		/* xsb_SegList (no SysBase saved) */
	rts

_open:					/* 0xaa */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0x0e)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xb8 */
	subqw	#1,a6@(0x20)
	bnew	_stub0			/* still open -> ret 0 */
	btstb	#3,a6@(0x0e)
	beqw	_stub0			/* no pending expunge -> ret 0 */
					/* else fall into expunge */

_expunge:				/* 0xca */
	tstw	a6@(0x20)
	beqs	1f			/* cnt==0 -> real expunge */
	bsetb	#3,a6@(0x0e)		/* deferred: LIBF_DELEXP */
	braw	_stub0			/* -> ret 0 (0x00) */
1:					/* 0xda */
	moveml	d2/a5-a6,sp@-
	movel	a6@(0x22),d2		/* seglist */
	moveal	a6,a5
	moveal	a5,a1
	moveal	4,a6			/* SysBase (absolute, none saved) */
	jsr	a6@(-0xfc)		/* Remove */
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(0x10),d0		/* NegSize */
	subal	d0,a1
	addw	a5@(0x12),d0		/* + PosSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0			/* return seglist */
	moveml	sp@+,d2/a5-a6
	rts

_xpkinfo:				/* 0x108 -30 XpksPackerInfo */
	lea	_xpkdata(pc),a0		/* -> 0x1f6 */
	movel	a0,d0
	rts

/* -36 XpksPackChunk: ByteRun0 encoder.  a1=in, a2=inlen->in-end,
 * a3=out, a4=OutBuf+InLen bound.  Repeat runs (>2 equals) emit
 * -(len-1),byte; literal runs emit len-1 then the bytes; runs are
 * capped at 125 via d2 (dbcc counters). */
_pack:					/* 0x110 */
	moveml	d2-d6/a2-a6,sp@-
	moveml	a0@,a1-a3		/* pb[0..2]: in,inlen,out */
	moveal	a3,a4
	addal	a2,a4			/* a4 = OutBuf + InLen bound */
	addal	a1,a2			/* a2 = in end */
	bras	_lit
_runcnt:				/* 0x120: extend repeat run */
	cmpb	a1@+,d1
	dbne	d2,_runcnt
	beqs	_runout
	subqw	#1,a1			/* rolled over on equal bytes */
_runout:				/* 0x12a: emit repeat run */
	cmpal	a4,a3
	bccw	_over			/* out would pass bound -> -17 */
	movel	a1,d0
	subl	a5,d0			/* run len */
	cmpal	a2,a1			/* input left? */
	bcss	_runmid
	movel	a2,d0			/* last run: len = inend - base */
	subl	a5,d0
	beqw	_done
	subqb	#1,d0
	negb	d0
	moveb	d0,a3@+			/* count -(len-1) */
	moveb	d1,a3@+			/* byte value */
	braw	_done
_runmid:				/* 0x14c */
	subqb	#1,d0
	negb	d0
	moveb	d0,a3@+
	moveb	d1,a3@+
_lit:					/* 0x154: literal scan */
	moveal	a1,a5			/* a5 = run base */
	moveq	#125,d2			/* max look-ahead */
	moveb	a1@+,d1
	moveb	a1@+,d0
	cmpb	d0,d1
	beqs	_runcnt			/* equal pair -> repeat path */
_lit2:					/* 0x160 */
	moveb	a1@+,d1
	cmpb	d0,d1
	dbeq	d2,_lit4
	bnes	_litx			/* != -> end literal run */
	cmpb	a1@,d1			/* ==: check 4th byte too */
	dbeq	d2,_lit4
	bnes	_litx
	bras	_lit6
_lit4:					/* 0x174 */
	moveb	a1@+,d0
	cmpb	d0,d1
	dbeq	d2,_lit2
	bnes	_litx
	cmpb	a1@,d0
	dbeq	d2,_lit2
	bnes	_litx
_lit6:					/* 0x186 */
	subqw	#2,a1			/* back up before the run */
_litx:					/* 0x188: emit literal run */
	movel	a1,d0
	subl	a5,d0			/* len */
	lea	a3@(1,d0:w),a6		/* a6 = out+1+len */
	cmpal	a4,a6
	bccs	_over			/* would pass bound -> -17 */
	cmpal	a2,a1			/* input left? */
	bccs	_litlast
	subqb	#1,d0
	moveb	d0,a3@+			/* count len-1 */
_litcp:	moveb	a5@+,a3@+		/* 0x19c */
	dbf	d0,_litcp
	bras	_lit
_litlast:				/* 0x1a4: flush trailing literal */
	movel	a2,d0
	subl	a5,d0
	beqs	_done
	subqb	#1,d0
	moveb	d0,a3@+
_litcl:	moveb	a5@+,a3@+		/* 0x1ae */
	dbf	d0,_litcl
_done:					/* 0x1b4 */
	subal	a0@(8),a3		/* outlen = a3 - OutBuf */
	movel	a3,a0@(16)		/* xsp_OutLen */
	moveml	sp@+,d2-d6/a2-a6
	moveq	#0,d0
	rts
_over:					/* 0x1c4 output overflow -> -17 */
	moveml	sp@+,d2-d6/a2-a6
	moveq	#-17,d0
	rts

/* -54 XpksUnpackChunk: ByteRun1 decode.  a0=in,a1=inlen->end,a2=out.
 * n>=0: copy n+1; n<0: write next byte -n+1 times.  No bounds. */
_unpack:				/* 0x1cc */
	movel	a2,sp@-
	moveml	a0@,a0-a2		/* pb[0..2]: in,inlen,out */
	addal	a0,a1			/* a1 = in end */
_ulp:					/* 0x1d4 */
	cmpal	a1,a0
	bccs	_udone
	moveb	a0@+,d1			/* count byte n */
	bmis	_urun			/* n<0 -> repeat */
_ulit:	moveb	a0@+,a2@+		/* 0x1dc: copy n+1 */
	subqb	#1,d1
	bccs	_ulit
	bras	_ulp
_urun:					/* 0x1e4 */
	moveb	a0@+,d0			/* byte value */
	negb	d1
_urunl:	moveb	d0,a2@+			/* 0x1e8: write -n+1 */
	subqb	#1,d1
	bccs	_urunl
	bras	_ulp
_udone:					/* 0x1f0 */
	moveal	sp@+,a2
	moveq	#0,d0
	rts

/* ---- 0x1f6 XpkInfo data island (in the code hunk) ---------------- */
_xpkdata:
	.short	1			/* xi_XpkInfoVersion */
	.short	1			/* xi_LibVersion */
	.short	2			/* xi_MasterVersion */
	.short	0			/* xi_ModesVersion */
	.long	_s_name			/* xi_Name        -> "ByteRun0" */
	.long	_s_lname		/* xi_LongName    -> "Cmp ByteRun0 Packer V1.2" */
	.long	_s_desc			/* xi_Description -> "Fast and simple RLE compression" */
	.ascii	"CBR0"			/* xi_ID */
	.long	9			/* xi_Flags */
	.long	0x7fffffff		/* xi_MaxPkInChunk */
	.long	0			/* xi_MinPkInChunk */
	.long	0x8000			/* xi_DefPkInChunk = 32K */
	.long	0			/* xi_PackMsg = NULL */
	.long	0			/* xi_UnpackMsg = NULL */
	.long	0			/* xi_PackedMsg = NULL */
	.long	0			/* xi_UnpackedMsg = NULL */
	.short	100			/* xi_DefMode */
	.short	0			/* pad */
	.long	_xpkmode		/* xi_ModeDesc -> 0x24e */
	.long	0,0,0,0,0,0		/* xi_Reserved[6] */

/* ---- 0x24e XpkMode ---------------------------------------------- */
_xpkmode:
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	372			/* xm_PackSpeed */
	.long	1150			/* xm_UnpackSpeed */
	.short	48			/* xm_Ratio */
	.short	0			/* xm_ChunkSize */
	.ascii	"normal"		/* xm_Description[8?] */
	.byte	0,0

_s_modepad:
	.byte	0,0			/* 0x276: pad to strings */

_s_name:.ascii	"ByteRun0"		/* 0x278 */
	.byte	0
_s_lname:
	.ascii	"Cmp ByteRun0 Packer V1.2"	/* 0x281 */
	.byte	0
_s_desc:.ascii	"Fast and simple RLE compression"	/* 0x29a */
	.byte	0,0			/* NUL + pad to hunk end 0x2bc */
