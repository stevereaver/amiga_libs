/* xpkRLEN.library 1.4 (1.12.2010) -- verbatim asm reconstruction.
 * XPK PackBits-style run-length chunk packer.  AUTOINIT library with a
 * word-offset functab; entry stub returns -1; rt_EndSkip points one
 * byte past the 0x278-byte hunk (module end).  Single CODE hunk, 14
 * RELOC32 entries stored DESCENDING (fixed up post-link by fixup.py).
 *
 * DataSize is 0x2a = Library(0x22) + seglist + one unused long.
 * XpkInfo and the single XpkMode "normal" live as data islands at the
 * end of the hunk (not embedded in the base).  xi_MasterVersion is 0,
 * all four progress message pointers are NULL, xi_DefPkInChunk=0x4004.
 * Unpack has no output bounds check and treats a 0x80 control byte as
 * "consume one byte, emit nothing" (neg.b of -128 stays negative).
 * Pack reads src[1..2] unconditionally (reads past end on len<2) and
 * reserves 4+litlen bytes of headroom; error return is -17.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:					/* 0x00 */
	moveq	#-1,d0			/* 70ff: returns -1, not 0 */
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_hend			/* rt_EndSkip -> 0x278 (hunk end) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	1			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* -> 0x66 */
	.long	_idstr			/* -> 0x76 */
	.long	_inittab		/* -> 0x1e */

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0x1e */
	.long	0x2a			/* dataSize: Library + seglist + 1 long */
	.long	_functab		/* -> 0x2e */
	.long	_datatab		/* -> 0x46 */
	.long	_init			/* -> 0xd4 */

_functab:				/* 0x2e, word offsets from _functab */
	.short	0xffff
	.short	_open    - _functab	/* -6   Open        -> 0xdc */
	.short	_close   - _functab	/* -12  Close       -> 0xea */
	.short	_expunge - _functab	/* -18  Expunge     -> 0xf8 */
	.short	_ret0    - _functab	/* -24  reserved    -> 0x12e */
	.short	_xpkinfo - _functab	/* -30  PackerInfo  -> 0x158 */
	.short	_pack    - _functab	/* -36  PackChunk   -> 0x160 */
	.short	_ret0    - _functab	/* -42  PackFree    -> 0x12e */
	.short	_ret0    - _functab	/* -48  PackReset   -> 0x12e */
	.short	_unpack  - _functab	/* -54  UnpackChunk -> 0x132 */
	.short	_ret0    - _functab	/* -60  UnpackFree  -> 0x12e */
	.short	0xffff

/* InitStruct: only the Library node header; the XpkInfo/XpkMode data
 * is a static island, not built by the table. */
_datatab:				/* 0x46 */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x01	/* INITWORD lib_Version=1 */
	.byte	0x90,0x16,0x00,0x04	/* INITWORD lib_Revision=4 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.short	0,0			/* terminator */

_libname:				/* 0x66 */
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:					/* 0x76, no $VER cookie */
	.ascii	"xpkRLEN 1.4 (1.12.2010)\015\012"
	.byte	0
_s_id:	.ascii	"RLEN"			/* 0x90 xi_Name */
	.byte	0
_s_lname:
	.ascii	"Run Length"		/* 0x95 xi_LongName */
	.byte	0
_s_desc:.ascii	"Fast and simple compression usable for simple data"
	.byte	0,0			/* 0xa0 .. 0xd3 */

/* ---- code ----------------------------------------------------- */
_init:					/* 0xd4 */
	moveal	d0,a1
	movel	a0,a1@(0x22)		/* lb_SegList */
	rts

_open:					/* 0xdc */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xea */
	subqw	#1,a6@(0x20)
	bnes	_ret0			/* still open -> ret 0 */
	btstb	#3,a6@(0xe)
	beqs	_ret0			/* no pending expunge -> ret 0 */

_expunge:				/* 0xf8 */
	tstw	a6@(0x20)
	bnes	_defer			/* open -> defer */
	moveal	a6,a1
	movel	a6@(0x22),sp@-		/* seglist */
	movel	a6,sp@-			/* lib */
	moveal	4,a6
	jsr	a6@(-0xfc)		/* Remove */
	moveal	sp@,a0			/* a0 = lib (peek) */
	moveal	sp@,a1			/* a1 = lib (peek) */
	moveq	#0,d0
	movew	a0@(0x10),d0		/* negSize */
	subal	d0,a1			/* lib - negSize */
	addw	a0@(0x12),d0		/* +posSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	moveal	sp@+,a6			/* pop lib */
	movel	sp@+,d0			/* return seglist */
	rts
_defer:					/* 0x128 */
	bsetb	#3,a6@(0xe)		/* deferred expunge, falls through */
_ret0:					/* 0x12e shared null vector */
	moveq	#0,d0
	rts

/* XpksUnpackChunk (-54): PackBits decoder, no output bounds check,
 * never writes xsp_OutLen, returns 0 via the shared _ret0 stub.
 * Token byte d0: 0 -> done; <0 -> repeat next byte -d0 times (0x80
 * degenerates to a skip); >0 -> copy d0 literals.  The trailing
 * bras at 0x156 is unreachable (all three cases already covered). */
_unpack:				/* 0x132 */
	moveal	a0@,a1			/* xsp_InBuf */
	moveal	a0@(8),a0		/* xsp_OutBuf (params ptr lost) */
	bras	_unxtok
_ulit:					/* 0x13a */
	moveb	a1@+,a0@+
	subqb	#1,d0
	bgts	_ulit
	bras	_unxtok
_urun:					/* 0x142 */
	moveb	a1@+,d1			/* run byte */
	negb	d0
	bles	_unxtok			/* 0x80: consume byte, emit nothing */
_urunl:					/* 0x148 */
	moveb	d1,a0@+
	subqb	#1,d0
	bgts	_urunl
_unxtok:				/* 0x14e */
	moveb	a1@+,d0
	beqs	_ret0			/* -> moveq#0,rts */
	bles	_urun
	bgts	_ulit
	bras	_unxtok			/* dead code */

_xpkinfo:				/* 0x158 */
	lea	_xinfo(pc),a0		/* XpkInfo island @0x21e */
	movel	a0,d0
	rts

/* XpksPackChunk (-36): greedy PackBits encoder.
 * a1=src, a2=InLen->tmp, a3=inend, a4=lit_start, a5=dst, a6=outend.
 * d2=pending run len, d6=litlen.  Error -17 when out+4+litlen>outend. */
_pack:					/* 0x160 */
	moveml	d2-d6/a2-a6,sp@-
	moveml	a0@,a1-a2/a5-a6		/* InBuf,InLen,OutBuf,OutBufLen */
	lea	a1@(0,a2:l),a3		/* inend */
	moveal	a1,a4			/* lit_start */
	addal	a5,a6			/* outend */
_ploop:					/* 0x170 */
	moveq	#0,d2
	moveb	a1@(1),d0		/* peek src[1] (past end on len<2) */
	cmpb	a1@,d0
	bnes	_norun
	cmpb	a1@(2),d0		/* peek src[2] */
	bnes	_norun
	moveq	#2,d2			/* three equal -> run seeded */
_norun:					/* 0x182 */
	movel	a1,d6
	subl	a4,d6			/* litlen = src - lit_start */
	lea	a5@(4,d6:l),a2		/* reserve litlen+4 */
	cmpal	a6,a2
	blss	_fits
	moveq	#-17,d0			/* XPKERR_EXPANSION */
	bras	_pepilog
_fits:					/* 0x192 */
	tstl	d2
	bnes	_flush			/* run pending -> flush literal now */
	.short	0xbcbc,0x0000,0x007f	/* cmpl #0x7f,d6 (gas wants cmpi) */
	beqs	_emitlit		/* literal cap reached */
	cmpal	a3,a1
	bnes	_adv			/* input left -> keep scanning */
_flush:					/* 0x1a2 */
	tstl	d6
	beqs	_flushed
_emitlit:				/* 0x1a6 */
	moveb	d6,a5@+			/* literal header */
	tstl	d6
	bles	_flushed
_litcopy:				/* 0x1ac */
	moveb	a4@+,a5@+
	subql	#1,d6
	bgts	_litcopy
_flushed:				/* 0x1b2 */
	cmpal	a1,a3
	beqs	_done			/* inend reached -> finish */
	moveal	a1,a4			/* lit_start = src */
	tstl	d2
	bnes	_run
_adv:					/* 0x1bc */
	addqw	#1,a1
	bras	_ploop
_run:					/* 0x1c0 */
	addqb	#1,d2
	lea	a1@(0,d2:w),a2		/* probe = src + runlen */
	cmpal	a3,a2
	bccs	_emitrun		/* hit inend -> emit */
	moveb	a2@,d0
	cmpb	a2@-,d0			/* still equal? */
	bnes	_emitrun
	.short	0xb43c,0x007f		/* cmpb #0x7f,d2 (gas wants cmpi) */
	blts	_run			/* extend while < 127 */
_emitrun:				/* 0x1d6 */
	addaw	d2,a4			/* lit_start += runlen */
	negw	d2
	moveb	d2,a5@+			/* -count */
	moveb	a1@,a5@+		/* byte */
	moveal	a4,a1
	bras	_ploop
_done:					/* 0x1e2 */
	clrb	a5@+			/* 0 terminator */
	subal	a0@(8),a5		/* produced len */
	movel	a5,a0@(0x10)		/* xsp_OutLen */
	moveq	#0,d0
_pepilog:				/* 0x1ee */
	moveml	sp@+,d2-d6/a2-a6
	rts

/* ---- XpkMode "normal" island ----------------------------------- */
_xmode:					/* 0x1f4 */
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	0x8c			/* xm_PackSpeed 140 */
	.long	0x413			/* xm_UnpackSpeed 1043 */
	.short	0x2d			/* xm_Ratio 45 */
	.short	0			/* xm_ChunkSize */
	.ascii	"normal"			/* xm_Description[10] */
	.byte	0,0,0,0

/* ---- XpkInfo island -------------------------------------------- */
_xinfo:					/* 0x21e */
	.short	1			/* xi_XpkInfoVersion */
	.short	1			/* xi_LibVersion */
	.short	0			/* xi_MasterVersion = 0 (quirk) */
	.short	0			/* xi_ModesVersion */
	.long	_s_id			/* xi_Name -> "RLEN" */
	.long	_s_lname		/* xi_LongName -> "Run Length" */
	.long	_s_desc			/* xi_Description */
	.long	0x524c454e		/* xi_ID = 'RLEN' */
	.long	9			/* xi_Flags */
	.long	0x7fffffff		/* xi_MaxPkInChunk */
	.long	0			/* xi_MinPkInChunk */
	.long	0x4004			/* xi_DefPkInChunk = 16388 (quirk) */
	.long	0			/* xi_PackMsg = NULL */
	.long	0			/* xi_UnpackMsg = NULL */
	.long	0			/* xi_PackedMsg = NULL */
	.long	0			/* xi_UnpackedMsg = NULL */
	.short	0x32			/* xi_DefMode = 50 */
	.short	0			/* pad */
	.long	_xmode			/* xi_ModeDesc -> 0x1f4 */
	.long	0,0,0,0,0,0		/* 0x25e..0x275 */
	.short	0			/* 0x276 */
_hend:					/* 0x278 rt_EndSkip target */
