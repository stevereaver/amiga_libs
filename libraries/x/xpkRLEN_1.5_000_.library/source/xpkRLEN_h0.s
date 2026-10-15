/* xpkRLEN.library V1.5 (1 Oct 2013) by Urban Dominik Muller --
 * verbatim asm reconstruction of the (000) build.  XPK PackBits-style
 * run-length chunk packer.  AUTOINIT library with a word-offset
 * functab (this build IS autoinit -- the 1.5 okf's earlier claim of a
 * non-AUTOINIT absolute-longword table was wrong).  Entry stub returns
 * 0 and doubles as the shared null vector: the four dead functab slots
 * hold offset -0x98 back to hunk 0, and Close/deferred-Expunge use
 * word branches to the same stub.  rt_EndSkip is literal 0 (not a
 * pointer, no reloc).  Single CODE hunk, 13 RELOC32 entries, already
 * ascending (GNU ld order -- no fixup needed).
 *
 * DataSize is 0x26 = Library(0x22) + seglist only.  XpkInfo/XpkMode
 * "normal" are static islands near the hunk end.  Rewritten encoder:
 * dbra-counted run scan (cap 124), output ceiling = OutBuf + InLen
 * (xsp_OutBufLen is never read!), incompressible input returns -17
 * instead of expanding past the input length.  Decoder uses bmi/beq
 * dispatch: token 0x80 emits the byte 128 times (neg.b of -128 wraps
 * and the bne loop runs the full cycle) -- 1.4 skipped it instead.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:					/* 0x00, also the null vector */
	moveq	#0,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	0			/* rt_EndSkip = 0 (quirk, no reloc) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	1			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* -> 0x1e */
	.long	_idstr			/* -> 0x2e */
	.long	_inittab		/* -> 0x68 */

_libname:				/* 0x1e */
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:					/* 0x2e */
	.ascii	"$VER: xpkRLEN V1.5 (1 Oct 2013) by Urban Dominik Muller\015\012"
	.byte	0

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0x68 */
	.long	0x26			/* dataSize: Library + seglist */
	.long	_functab		/* -> 0x98 */
	.long	_datatab		/* -> 0x78 */
	.long	_init			/* -> 0xb0 */

/* InitStruct: only the Library node header; XpkInfo/XpkMode are
 * static islands, not built by the table. */
_datatab:				/* 0x78 */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x01	/* INITWORD lib_Version=1 */
	.byte	0x90,0x16,0x00,0x05	/* INITWORD lib_Revision=5 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.short	0,0			/* terminator */

_functab:				/* 0x98, word offsets from _functab */
	.short	0xffff
	.short	_open    - _functab	/* -6   Open        -> 0xb8 */
	.short	_close   - _functab	/* -12  Close       -> 0xc6 */
	.short	_expunge - _functab	/* -18  Expunge     -> 0xd8 */
	.short	_stub0   - _functab	/* -24  reserved    -> 0x00 */
	.short	_xpkinfo - _functab	/* -30  PackerInfo  -> 0x116 */
	.short	_pack    - _functab	/* -36  PackChunk   -> 0x11e */
	.short	_stub0   - _functab	/* -42  PackFree    -> 0x00 */
	.short	_stub0   - _functab	/* -48  PackReset   -> 0x00 */
	.short	_unpack  - _functab	/* -54  UnpackChunk -> 0x1d8 */
	.short	_stub0   - _functab	/* -60  UnpackFree  -> 0x00 */
	.short	0xffff

/* ---- code ----------------------------------------------------- */
_init:					/* 0xb0 */
	moveal	d0,a1
	movel	a0,a1@(0x22)		/* lb_SegList */
	rts

_open:					/* 0xb8 */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xc6 */
	subqw	#1,a6@(0x20)
	bnew	_stub0			/* still open -> moveq#0,rts */
	btstb	#3,a6@(0xe)
	beqw	_stub0			/* no pending expunge -> ret 0 */

_expunge:				/* 0xd8 */
	tstw	a6@(0x20)
	beqs	_exreal			/* closed -> real expunge */
	bsetb	#3,a6@(0xe)		/* deferred expunge */
	braw	_stub0			/* -> moveq#0,rts */
_exreal:				/* 0xe8 */
	moveml	d2/a5-a6,sp@-
	movel	a6@(0x22),d2		/* seglist */
	moveal	a6,a5			/* lib */
	moveal	a5,a1
	moveal	4,a6
	jsr	a6@(-0xfc)		/* Remove */
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(0x10),d0		/* negSize */
	subal	d0,a1			/* lib - negSize */
	addw	a5@(0x12),d0		/* +posSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0			/* return seglist */
	moveml	sp@+,d2/a5-a6
	rts

_xpkinfo:				/* 0x116 */
	lea	_xinfo(pc),a0		/* XpkInfo island @0x1fe */
	movel	a0,d0
	rts

/* XpksPackChunk (-36): rewritten PackBits encoder.
 * a1=src, a2=inend (InLen folded in), a3=dst, a4=dst+InLen (ceiling --
 * xsp_OutBufLen never consulted), a5=seg_start, d1=run byte, d2=dbra
 * run counter (124), d0=scratch/len.  Error -17 when an emit would
 * reach the ceiling, i.e. the packer refuses to expand beyond InLen. */
_pack:					/* 0x11e */
	moveml	d2-d6/a2-a6,sp@-
	moveml	a0@,a1-a3		/* InBuf,InLen,OutBuf only! */
	moveal	a3,a4
	addal	a2,a4			/* ceiling = OutBuf + InLen */
	addal	a1,a2			/* inend = InBuf + InLen */
	bras	_seg
_rscan:					/* 0x12e run scan (beq from _seg) */
	cmpb	a1@+,d1
	dbne	d2,_rscan		/* while equal, up to 124 */
	beqs	_rend			/* counter out -> a1 already past */
	subqw	#1,a1			/* stop at first differing byte */
_rend:					/* 0x138 */
	cmpal	a4,a3
	bccw	_perr			/* dst at ceiling -> -17 */
	movel	a1,d0
	subl	a5,d0			/* runlen = a1 - seg_start */
	cmpal	a2,a1
	bcss	_emitrun		/* not at inend -> emit run pair */
	movel	a2,d0
	subl	a5,d0			/* clamp to inend - seg_start */
	beqw	_pdone			/* nothing left -> terminator */
	negb	d0
	moveb	d0,a3@+			/* tail run: -len, byte */
	moveb	d1,a3@+
	braw	_pdone
_emitrun:				/* 0x158 */
	negb	d0
	moveb	d0,a3@+			/* -count */
	moveb	d1,a3@+			/* byte */
_seg:					/* 0x15e next segment */
	moveal	a1,a5			/* seg_start */
	moveq	#124,d2
	moveb	a1@+,d1			/* first byte */
	moveb	a1@+,d0			/* second byte */
	cmpb	d0,d1
	beqs	_rscan			/* equal pair -> run scan */
_lscan:					/* 0x16a literal scan */
	moveb	a1@+,d1
	cmpb	d0,d1
	dbeq	d2,_ltrip		/* equal -> check for triple */
	bnes	_emit			/* differ -> emit segment */
	cmpb	a1@,d1			/* third byte equal too? */
	dbeq	d2,_ltrip
	bnes	_emit
	bras	_lhit			/* run found -> back up 2 */
_ltrip:					/* 0x17e */
	moveb	a1@+,d0
	cmpb	d0,d1
	dbeq	d2,_lscan
	bnes	_emit
	cmpb	a1@,d0
	dbeq	d2,_lscan
	bnes	_emit
_lhit:					/* 0x190 */
	subqw	#2,a1			/* un-eat the run's first two */
_emit:					/* 0x192 literal emit */
	movel	a1,d0
	subl	a5,d0			/* litlen = a1 - seg_start */
	lea	a3@(1,d0:w),a6		/* dst + litlen + 1 */
	cmpal	a4,a6
	bccs	_perr			/* would reach ceiling -> -17 */
	cmpal	a2,a1
	bccs	_lastlit		/* overshot inend -> clamp & done */
	moveb	d0,a3@+			/* literal header */
	subqb	#1,d0
_lcopy:					/* 0x1a6 */
	moveb	a5@+,a3@+
	dbf	d0,_lcopy
	bras	_seg
_lastlit:				/* 0x1ae */
	movel	a2,d0
	subl	a5,d0			/* clamp litlen to inend */
	beqs	_pdone
	moveb	d0,a3@+
	subqb	#1,d0
_lcopy2:				/* 0x1b8 */
	moveb	a5@+,a3@+
	dbf	d0,_lcopy2
_pdone:					/* 0x1be */
	clrb	a3@+			/* 0 terminator */
	subal	a0@(8),a3		/* produced len */
	movel	a3,a0@(0x10)		/* xsp_OutLen */
	moveml	sp@+,d2-d6/a2-a6
	moveq	#0,d0
	rts
_perr:					/* 0x1d0 */
	moveml	sp@+,d2-d6/a2-a6
	moveq	#-17,d0
	rts

/* XpksUnpackChunk (-54): PackBits decoder, no output bounds check,
 * never writes xsp_OutLen.  Token d0: 0 -> done; <0 -> repeat next
 * byte -d0 times -- but 0x80 wraps to -128 and the bne loop emits the
 * byte 128 times (vs 1.4 which skipped it); >0 -> copy d0 literals. */
_unpack:				/* 0x1d8 */
	.short	0x2268,0x0000		/* moveal a0@(0),a1 = xsp_InBuf
					   (gas canonicalises to a0@) */
	moveal	a0@(8),a0		/* xsp_OutBuf */
_unxtok:				/* 0x1e0 */
	moveb	a1@+,d0
	bmis	_urun			/* <0 -> repeat run */
	beqs	_udone			/* 0 -> done */
_ulit:					/* 0x1e6 */
	moveb	a1@+,a0@+
	subqb	#1,d0
	bnes	_ulit
	bras	_unxtok
_urun:					/* 0x1ee */
	moveb	a1@+,d1
	negb	d0
_urunl:					/* 0x1f2 */
	moveb	d1,a0@+
	subqb	#1,d0
	bnes	_urunl			/* 0x80 wraps: emits 128 bytes */
	bras	_unxtok
_udone:					/* 0x1fa */
	moveq	#0,d0
	rts

/* ---- XpkInfo island -------------------------------------------- */
_xinfo:					/* 0x1fe */
	.short	1			/* xi_XpkInfoVersion */
	.short	1			/* xi_LibVersion */
	.short	2			/* xi_MasterVersion */
	.short	0			/* xi_ModesVersion */
	.long	_s_id			/* xi_Name -> 0x280 */
	.long	_s_lname		/* xi_LongName -> 0x285 */
	.long	_s_desc			/* xi_Description -> 0x29c */
	.long	0x524c454e		/* xi_ID = 'RLEN' */
	.long	9			/* xi_Flags */
	.long	0x7fffffff		/* xi_MaxPkInChunk */
	.long	0			/* xi_MinPkInChunk */
	.long	0x8000			/* xi_DefPkInChunk = 32768 */
	.long	0			/* xi_PackMsg = NULL */
	.long	0			/* xi_UnpackMsg = NULL */
	.long	0			/* xi_PackedMsg = NULL */
	.long	0			/* xi_UnpackedMsg = NULL */
	.short	0x64			/* xi_DefMode = 100 */
	.short	0			/* pad */
	.long	_xmode			/* xi_ModeDesc -> 0x256 */
	.long	0,0,0,0,0,0		/* 0x23e..0x255 */

/* ---- XpkMode "normal" island ----------------------------------- */
_xmode:					/* 0x256 */
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	0x174			/* xm_PackSpeed 372 */
	.long	0x47e			/* xm_UnpackSpeed 1150 */
	.short	0x30			/* xm_Ratio 48 */
	.short	0			/* xm_ChunkSize */
	.ascii	"normal"			/* xm_Description[10] */
	.byte	0,0,0,0

_s_id:	.ascii	"RLEN"			/* 0x280 xi_Name */
	.byte	0
_s_lname:
	.ascii	"Run Length Packer V1.5"	/* 0x285 xi_LongName */
	.byte	0
_s_desc:.ascii	"Fast and simple RLE compression"
	.byte	0			/* 0x29c .. 0x2bb (hunk end) */
