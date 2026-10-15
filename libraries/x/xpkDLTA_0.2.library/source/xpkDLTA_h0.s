/* xpkDLTA.library v0.2 (1992) by Stephan Fuhrmann
 * "DELTA-Encryption Routines" — XPK sublib, byte-delta ('ByteMode')
 * filter packer.  Single CODE hunk; word-offset functab whose null
 * slots point at a shared moveq#0/rts INSIDE XpksPackChunk; the
 * XpkInfo/XpkMode descriptors live inside the 0xfc-byte library base
 * and are initialised by the InitStruct table (offsets >0x7f are
 * plain byte offsets).  Pack/unpack bound InLen to OutBufLen (-10)
 * and 64K (-11) and carry one byte of state in xsp_Sub[0]/xsp_Sub[1].
 * Quirks: lib version 0.2; xi_Flags lacks PK_CHUNK/UP_CHUNK; pack
 * error exits branch into the unpack epilogue; InitStruct ordering.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:					/* 0x00 */
	moveq	#0,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_nopend			/* rt_EndSkip -> trailing nop @0x256 */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	0			/* rt_Version (0 as shipped) */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* 0x2e */
	.long	_idstr			/* 0x3e */
	.long	_inittab		/* 0xb4 */

_s_id:	.ascii	"DLTA"			/* 0x1e xi_Name */
	.byte	0
_s_lname:
	.ascii	"DELTA v0.2"		/* 0x23 xi_LongName */
	.byte	0
_libname:
	.ascii	"xpkDLTA.library"	/* 0x2e */
	.byte	0
_idstr:	.ascii	"xpkDLTA.library v0.2"	/* 0x3e, no $VER cookie */
	.byte	0
_s_desc:.ascii	"DELTA-Encryption Routines \251 1992 Stephan Fuhrmann"
	.byte	0			/* 0x53 .. 0x84 */
_s_pack:.ascii	"Enciphering"		/* 0x85 */
	.byte	0
_s_unpack:
	.ascii	"Deciphering"		/* 0x91 */
	.byte	0
_s_packed:
	.ascii	"Enciphered"		/* 0x9d */
	.byte	0
_s_unpacked:
	.ascii	"Deciphered"		/* 0xa8 */
	.byte	0,0

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0xb4 */
	.long	0xfc			/* dataSize: Library + seglist +
					   embedded XpkInfo + XpkMode */
	.long	_functab		/* 0xc4 */
	.long	_datatab		/* 0xdc */
	.long	_init			/* 0x16a */

_functab:				/* 0xc4, word offsets from _functab */
	.short	0xffff
	.short	_open    - _functab	/* -6   Open        -> 0x17a */
	.short	_close   - _functab	/* -12  Close       -> 0x188 */
	.short	_expunge - _functab	/* -18  Expunge     -> 0x196 */
	.short	_ret0    - _functab	/* -24  reserved    -> 0x20a */
	.short	_xpkinfo - _functab	/* -30  PackerInfo  -> 0x216 */
	.short	_pack    - _functab	/* -36  PackChunk   -> 0x1ce */
	.short	_ret0    - _functab	/* -42  PackFree    -> 0x20a */
	.short	_ret0    - _functab	/* -48  PackReset   -> 0x20a */
	.short	_unpack  - _functab	/* -54  UnpackChunk -> 0x21e */
	.short	_ret0    - _functab	/* -60  UnpackFree  -> 0x20a */
	.short	0xffff

/* InitStruct: library node, then embedded XpkInfo at base+0x26 and
 * embedded XpkMode at base+0x7e (offset bytes are flat 8-bit). */
_datatab:				/* 0xdc */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x00	/* INITWORD lib_Version=0 */
	.byte	0x90,0x16,0x00,0x02	/* INITWORD lib_Revision=2 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.byte	0x80,0x82		/* xm_Upto = 100 (literal) */
	.long	100
	.byte	0x80,0x9e		/* xm_Description[0] 'Byte' */
	.long	0x42797465
	.byte	0x80,0xa2		/* xm_Description[4] 'Mode' */
	.long	0x4d6f6465
	.byte	0x90,0x26,0x00,0x01	/* xi_XpkInfoVersion = 1 */
	.byte	0x90,0x28,0x00,0x00	/* xi_LibVersion = 0 */
	.byte	0x90,0x2a,0x00,0x01	/* xi_MasterVersion = 1 */
	.byte	0x90,0x2c,0x00,0x00	/* xi_ModesVersion = 0 */
	.byte	0x80,0x2e		/* xi_Name -> "DLTA" */
	.long	_s_id
	.byte	0x80,0x32		/* xi_LongName -> "DELTA v0.2" */
	.long	_s_lname
	.byte	0x80,0x36		/* xi_Description */
	.long	_s_desc
	.byte	0x80,0x3a		/* xi_ID = 'DLTA' (literal) */
	.long	0x444c5441
	.byte	0x80,0x3e		/* xi_Flags = 0x2000 (ENCRYPTION only) */
	.long	0x2000
	.byte	0x80,0x42		/* xi_MaxPkInChunk = 64K */
	.long	0x10000
	.byte	0x80,0x46		/* xi_MinPkInChunk = 1 */
	.long	1
	.byte	0x80,0x4a		/* xi_DefPkInChunk = 64K */
	.long	0x10000
	.byte	0x80,0x4e		/* xi_PackMsg */
	.long	_s_pack
	.byte	0x80,0x52		/* xi_UnpackMsg */
	.long	_s_unpack
	.byte	0x80,0x56		/* xi_PackedMsg */
	.long	_s_packed
	.byte	0x80,0x5a		/* xi_UnpackedMsg */
	.long	_s_unpacked
	.byte	0x90,0x5e,0x00,0x64	/* xi_DefMode = 100 */
	.short	0,0			/* terminator + pad */

/* ---- code ----------------------------------------------------- */
_init:					/* 0x16a */
	moveal	d0,a1
	movel	a0,a1@(0x22)		/* lb_SegList */
	lea	a1@(0x7e),a0		/* &xsb_Mode */
	movel	a0,a1@(0x62)		/* xi_ModeDesc = &base+0x7e */
	rts

_open:					/* 0x17a */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0x188 */
	subqw	#1,a6@(0x20)
	bnes	_ret0			/* still open -> ret 0 */
	btstb	#3,a6@(0xe)
	beqs	_ret0			/* no pending expunge -> ret 0 */

_expunge:				/* 0x196 */
	tstw	a6@(0x20)
	bnes	1f			/* open -> defer */
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
1:	bsetb	#3,a6@(0xe)		/* 0x1c6: deferred expunge */
	bras	_ret0

/* XpksPackChunk: out[0]=in[0]; out[i]=in[i]-in[i-1]; carry in
 * xsp_Sub[0]/[1] when chaining chunks. */
_pack:					/* 0x1ce */
	movel	a2,sp@-
	moveal	a0@+,a1			/* xsp_InBuf */
	movel	a0@+,d1			/* xsp_InLen */
	moveal	a0@+,a2			/* xsp_OutBuf */
	cmpl	a0@+,d1			/* vs xsp_OutBufLen */
	bgts	_errsmall		/* -10 */
	.short	0xb2bc,0x0001,0x0000	/* cmpl #0x10000,d1 */
	bgts	_errlarge		/* -11 */
	movew	d2,sp@-
	movel	d1,a0@			/* xsp_OutLen = InLen */
	moveb	a1@+,d0			/* first byte raw */
	moveb	d0,a2@+
	subql	#1,d1
	tstl	a0@(0x24)		/* xsp_Sub[0]: chained? */
	beqs	1f
	movel	a0@(0x28),d0		/* prev = xsp_Sub[1] */
1:	moveb	a1@+,d2
	subb	d0,d2			/* delta = in[i] - prev */
	moveb	d2,a2@+
	addb	d2,d0			/* prev = in[i] */
	subqw	#1,d1
	bccs	1b
	movel	d0,a0@(0x28)		/* xsp_Sub[1] = last byte */
	movew	sp@+,d2
	moveal	sp@+,a2
_ret0:					/* 0x20a — shared null vector */
	moveq	#0,d0
	rts
_errsmall:				/* 0x20e */
	moveq	#-10,d0
	bras	_epilog			/* into unpack epilogue @0x252 */
_errlarge:				/* 0x212 */
	moveq	#-11,d0
	bras	_epilog

_xpkinfo:				/* 0x216 */
	lea	a6@(0x26),a0		/* &xsb_Info */
	movel	a0,d0
	rts

/* XpksUnpackChunk: accumulate deltas; same bounds + carry scheme. */
_unpack:				/* 0x21e */
	movel	a2,sp@-
	moveal	a0@+,a1
	movel	a0@+,d1
	moveal	a0@+,a2
	cmpl	a0@+,d1
	bgts	_errsmall
	.short	0xb2bc,0x0001,0x0000	/* cmpl #0x10000,d1 */
	bgts	_errlarge
	movel	d1,a0@
	moveb	a1@+,d0
	moveb	d0,a2@+
	subql	#1,d1
	tstl	a0@(0x24)
	beqs	2f
	movel	a0@(0x28),d0
2:	addb	a1@+,d0			/* acc += in[i] */
	moveb	d0,a2@+
	subqw	#1,d1
	bccs	2b
	movel	d0,a0@(0x28)
	moveq	#0,d0
_epilog:				/* 0x252 — shared by pack errors */
	moveal	sp@+,a2
	rts
_nopend:				/* 0x256 rt_EndSkip target */
	nop
