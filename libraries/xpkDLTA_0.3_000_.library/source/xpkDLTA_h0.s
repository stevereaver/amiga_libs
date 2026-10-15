/* xpkDLTA.library V0.3 (1 Oct 2013) by Stephan Fuhrmann
 * "DELTA-Encryption Routines" — XPK sublib, byte-delta ('bytemode')
 * filter packer.  Single CODE hunk; word-offset functab (null slots
 * are backward offsets to the moveq#0/rts stub at code+0); XpkInfo and
 * the single XpkMode are code data islands; LibInit stores only the
 * seglist.  Quirk: rt_EndSkip stores literal 0, no relocation emitted.
 * Unlike V0.2 there are no bounds checks and no cross-chunk carry.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:
	moveq	#0,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	0			/* rt_EndSkip = 0 literal, UNRELOCATED (quirk) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	0			/* rt_Version (0 as shipped) */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"xpkDLTA.library"	/* 0x1e */
	.byte	0
_idstr:	.ascii	"$VER: xpkDLTA V0.3 (1 Oct 2013) by Stephan Fuhrmann\015\012"
	.byte	0			/* ends 0x64 */

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0x64 */
	.long	0x26			/* dataSize: Library + seglist only */
	.long	_functab		/* 0x94 */
	.long	_datatab		/* 0x74 */
	.long	_init			/* 0xac */

_datatab:				/* 0x74 */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_name
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x00	/* INITWORD lib_Version=0 */
	.byte	0x90,0x16,0x00,0x03	/* INITWORD lib_Revision=3 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.byte	0,0,0,0

_functab:				/* 0x94, word offsets from _functab */
	.short	0xffff
	.short	_open    - _functab	/* -6   Open    -> 0xb4 */
	.short	_close   - _functab	/* -12  Close   -> 0xc2 */
	.short	_expunge - _functab	/* -18  Expunge -> 0xd4 */
	.short	_stub0   - _functab	/* -24  stub    -> 0x00 */
	.short	_xpkinfo - _functab	/* -30  info    -> 0x112 */
	.short	_pack    - _functab	/* -36  PackChunk -> 0x11a */
	.short	_stub0   - _functab	/* -42  PackFree stub */
	.short	_stub0   - _functab	/* -48  PackReset stub */
	.short	_unpack  - _functab	/* -54  UnpackChunk -> 0x140 */
	.short	_stub0   - _functab	/* -60  UnpackFree stub */
	.short	0xffff

/* ---- code ----------------------------------------------------- */
_init:					/* 0xac */
	moveal	d0,a1
	movel	a0,a1@(0x22)		/* lb_SegList */
	rts

_open:					/* 0xb4 */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xc2 */
	subqw	#1,a6@(0x20)
	bne	_stub0			/* bne.w — word disp back to 0 */
	btstb	#3,a6@(0xe)
	beq	_stub0			/* beq.w */

_expunge:				/* 0xd4 */
	tstw	a6@(0x20)
	beqs	1f			/* cnt==0 -> real expunge */
	bsetb	#3,a6@(0xe)		/* deferred expunge */
	bra	_stub0			/* bra.w — ret 0 via stub */
1:	moveml	d2/a5-a6,sp@-
	movel	a6@(0x22),d2		/* seglist */
	moveal	a6,a5
	moveal	a5,a1
	moveal	4,a6
	jsr	a6@(-0xfc)		/* Remove */
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(0x10),d0		/* negSize */
	subal	d0,a1
	addw	a5@(0x12),d0		/* +posSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0
	moveml	sp@+,d2/a5-a6
	rts

_xpkinfo:				/* 0x112 */
	lea	_xinfo(pc),a0
	movel	a0,d0
	rts

/* XpksPackChunk: out[0]=in[0]-0; out[i]=in[i]-in[i-1].
 * No OutBufLen/64K checks, no xsp_Sub carry — always returns 0. */
_pack:					/* 0x11a */
	.short	0x2268,0x0000		/* movea.l 0(a0),a1 (disp16 form) */
	movel	a0@(4),d1		/* xsp_InLen */
	movel	d1,a0@(0x10)		/* xsp_OutLen = InLen */
	moveal	a0@(8),a0		/* xsp_OutBuf */
	movel	d2,sp@-
	moveq	#0,d0			/* prev = 0 */
1:	moveb	a1@+,d2
	subb	d0,d2			/* delta = in[i] - prev */
	moveb	d2,a0@+
	addb	d2,d0			/* prev = in[i] */
	subql	#1,d1
	bnes	1b
	movel	sp@+,d2
	moveq	#0,d0
	rts

/* XpksUnpackChunk: accumulate deltas.  Quirk: never writes
 * xsp_OutLen. */
_unpack:				/* 0x140 */
	.short	0x2268,0x0000		/* movea.l 0(a0),a1 (disp16 form) */
	movel	a0@(4),d1
	moveal	a0@(8),a0
	moveq	#0,d0
1:	addb	a1@+,d0			/* acc += in[i] */
	moveb	d0,a0@+
	subql	#1,d1
	bnes	1b
	moveq	#0,d0
	rts

/* ---- data islands --------------------------------------------- */
_xinfo:					/* 0x15a XpkInfo block */
	.short	1,0			/* xi_XpkInfoVersion, xi_LibVersion */
	.short	2,0			/* xi_MasterVersion, xi_ModesVersion */
	.long	_s_id			/* xi_Name -> "Delta" */
	.long	_s_lname		/* xi_LongName -> "Delta Encryptor V0.3" */
	.long	_s_desc			/* xi_Description */
	.ascii	"DLTA"			/* xi_ID (no NUL pad) */
	.long	0x2009			/* xi_Flags: PK_CHUNK|UP_CHUNK|ENCRYPTION */
	.long	0x10000			/* xi_MaxPkInChunk */
	.long	0			/* xi_MinPkInChunk */
	.long	0x10000			/* xi_DefPkInChunk */
	.long	_s_pack			/* xi_PackMsg */
	.long	_s_unpack		/* xi_UnpackMsg */
	.long	_s_packed		/* xi_PackedMsg */
	.long	_s_unpacked		/* xi_UnpackedMsg */
	.short	100,0			/* xi_DefMode, xi_Pad */
	.long	_xmode			/* xi_ModeDesc */
	.long	0,0,0,0,0,0		/* xi_Reserved[6] */

_xmode:					/* 0x1b2 XpkMode */
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	531			/* xm_PackSpeed */
	.long	743			/* xm_UnpackSpeed */
	.short	0			/* xm_Ratio */
	.short	0			/* xm_ChunkSize */
	.ascii	"bytemode"		/* xm_Description[10] */
	.byte	0,0

_s_id:	.ascii	"Delta"			/* 0x1dc */
	.byte	0
_s_lname:.ascii	"Delta Encryptor V0.3"	/* 0x1e2 */
	.byte	0
_s_desc:.ascii	"DELTA-Encryption Routines \251 1992 Stephan Fuhrmann"
	.byte	0			/* 0x1f7 .. 0x228 */
_s_pack:.ascii	"Enciphering"		/* 0x229 */
	.byte	0
_s_unpack:
	.ascii	"Deciphering"		/* 0x235 */
	.byte	0
_s_packed:
	.ascii	"Enciphered"		/* 0x241 */
	.byte	0
_s_unpacked:
	.ascii	"Deciphered"		/* 0x24c */
	.byte	0,0
