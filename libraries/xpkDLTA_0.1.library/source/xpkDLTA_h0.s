/* xpkDLTA.library v0.1 (1992) by Stephan Fuhrmann
 * "DELTA-Encryption Routines" — XPK sublib, byte-delta ('ByteMode')
 * filter packer.  Single CODE hunk; ABSOLUTE-LONG functab whose entries
 * are unrelocated hunk offsets (file carries no RELOC32 at all); the
 * XpkInfo/XpkMode descriptors live inside the 0xfc-byte library base
 * and are initialised by the InitStruct table.  Pack/unpack bound InLen
 * to OutBufLen (-10) and 64K (-11) and carry one byte of state in
 * xsp+0x34/xsp+0x38 when chaining chunks.
 * Quirks: expunge makes a dead bsr to a bare rts; -42/-48/-60 are three
 * separate moveq#0/rts stubs; word/long delta helpers are dead code.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:					/* 0x00 */
	moveq	#0,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_nopend			/* rt_EndSkip -> hunk end (0x320) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	0			/* rt_Version (0 as shipped) */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* 0x2e */
	.long	_idstr			/* 0x44 */
	.long	_inittab		/* 0xba */

_s_id:	.ascii	"DLTA"			/* 0x1e xi_Name */
	.byte	0
_s_lname:
	.ascii	"DELTA v0.1"		/* 0x23 xi_LongName */
	.byte	0
_libname:
	.ascii	"xpkDLTA.library"	/* 0x2e */
	.byte	0
	.ascii	"$VER: "			/* 0x3e — unreferenced cookie */
_idstr:	.ascii	"xpkDLTA.library v0.1"	/* 0x44 — rt_IdString skips it */
	.byte	0
_s_desc:.ascii	"DELTA-Encryption Routines \251 1992 Stephan Fuhrmann"
	.byte	0			/* 0x59 .. 0x8a */
_s_pack:.ascii	"Enciphering"		/* 0x8b */
	.byte	0
_s_unpack:
	.ascii	"Deciphering"		/* 0x97 */
	.byte	0
_s_packed:
	.ascii	"Enciphered"		/* 0xa3 */
	.byte	0
_s_unpacked:
	.ascii	"Deciphered"		/* 0xae */
	.byte	0,0

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0xba */
	.long	0xfc			/* dataSize: Library + seglist +
					   embedded XpkInfo + XpkMode */
	.long	_functab		/* 0xca */
	.long	_datatab		/* 0xf6 */
	.long	_init			/* 0x184 */

_functab:				/* 0xca, absolute longs (hunk
					   offsets — no relocs in file) */
	.long	_open			/* -6   Open        -> 0x19e */
	.long	_close			/* -12  Close       -> 0x1ac */
	.long	_expunge		/* -18  Expunge     -> 0x1c2 */
	.long	_ret0			/* -24  reserved    -> 0x206 */
	.long	_xpkinfo		/* -30  PackerInfo  -> 0x20c */
	.long	_pack			/* -36  PackChunk   -> 0x214 */
	.long	_ret0b			/* -42  PackFree    -> 0x266 */
	.long	_ret0c			/* -48  PackReset   -> 0x26a */
	.long	_unpack			/* -54  UnpackChunk -> 0x26e */
	.long	_ret0d			/* -60  UnpackFree  -> 0x2c0 */
	.long	0xffffffff

/* InitStruct: library node, then embedded XpkInfo at base+0x26 and
 * embedded XpkMode at base+0x7e. */
_datatab:				/* 0xf6 */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x00	/* INITWORD lib_Version=0 */
	.byte	0x90,0x16,0x00,0x01	/* INITWORD lib_Revision=1 */
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
	.byte	0x80,0x32		/* xi_LongName -> "DELTA v0.1" */
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
	.long	0			/* terminator */

/* ---- code ----------------------------------------------------- */
_init:					/* 0x184 */
	moveml	%d1-%d7/%a0-%a6,%sp@-
	moveal	d0,a5
	movel	a0,a5@(0x22)		/* lb_SegList */
	lea	a5@(0x7e),a0		/* &xsb_Mode */
	movel	a0,a5@(0x62)		/* xi_ModeDesc = &base+0x7e */
	movel	a5,d0			/* return base */
	moveml	%sp@+,%d1-%d7/%a0-%a6
	rts

_open:					/* 0x19e */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0x1ac */
	moveq	#0,d0
	subqw	#1,a6@(0x20)
	bnes	1f			/* still open -> ret 0 */
	btstb	#3,a6@(0xe)
	beqs	1f			/* no pending expunge -> ret 0 */
	bsrw	_expunge
1:	rts

_expunge:				/* 0x1c2 */
	tstw	a6@(0x20)
	bnes	2f			/* open -> defer */
	moveml	%d1-%d7/%a1-%a6,%sp@-
	moveal	a6,a5
	bsrw	_dead			/* dead call to a bare rts */
	moveal	a6,a5
	moveal	a6,a1
	moveal	4,a6
	jsr	a6@(-0xfc)		/* Remove */
	movel	a5@(0x22),d7		/* seglist */
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(0x10),d0		/* negSize */
	subal	d0,a1			/* lib - negSize */
	addw	a5@(0x12),d0		/* +posSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d7,d0			/* return seglist */
	moveml	%sp@+,%d1-%d7/%a1-%a6
	rts
2:	bsetb	#3,a6@(0xe)		/* 0x1fc: deferred expunge */
	moveq	#0,d0
	rts

_ret0:					/* 0x206 */
	moveq	#0,d0
	rts
_dead:					/* 0x20a — bare rts, bsr target */
	rts

_xpkinfo:				/* 0x20c */
	lea	a6@(0x26),a0		/* &xsb_Info */
	movel	a0,d0
	rts

/* XpksPackChunk: byte-delta; xsp fields read at fixed offsets;
 * carry in xsp+0x34(flag)/xsp+0x38(prev). */
_pack:					/* 0x214 */
	moveml	%d2/%a2,%sp@-
	moveal	a0@,a1			/* xsp_InBuf */
	movel	a0@(4),d2		/* xsp_InLen */
	moveal	a0@(8),a2		/* xsp_OutBuf */
	cmpl	a0@(0xc),d2		/* vs xsp_OutBufLen */
	bgts	_errsmall		/* -10 */
	.short	0xb4bc,0x0001,0x0000	/* cmpl #0x10000,d2 (longform) */
	bgts	_errlarge		/* -11 */
	movel	d2,a0@(0x10)		/* xsp_OutLen = InLen */
	tstl	a0@(0x34)		/* xsp+0x34: chained? */
	bnes	1f
	subql	#1,d2
	moveb	a1@+,d0			/* first byte raw */
	moveb	d0,a2@+
	bras	2f
1:	movel	a0@(0x38),d0		/* prev = xsp+0x38 */
2:	bsrw	_packb
	movel	d0,a0@(0x38)		/* xsp+0x38 = last byte */
	moveq	#0,d0
	moveml	%sp@+,%d2/%a2
	rts
_errlarge:				/* 0x256 */
	moveml	%sp@+,%d2/%a2
	moveq	#-11,d0
	rts
_errsmall:				/* 0x25e */
	moveml	%sp@+,%d2/%a2
	moveq	#-10,d0
	rts

_ret0b:					/* 0x266 */
	moveq	#0,d0
	rts
_ret0c:					/* 0x26a */
	moveq	#0,d0
	rts

/* XpksUnpackChunk: accumulate deltas; same bounds + carry scheme. */
_unpack:				/* 0x26e */
	moveml	%d2/%a2,%sp@-
	moveal	a0@,a1
	movel	a0@(4),d2
	moveal	a0@(8),a2
	cmpl	a0@(0xc),d2
	bgts	_uerrsmall
	.short	0xb4bc,0x0001,0x0000	/* cmpl #0x10000,d2 (longform) */
	bgts	_uerrlarge
	movel	d2,a0@(0x10)
	tstl	a0@(0x34)
	bnes	1f
	subql	#1,d2
	moveb	a1@+,d0
	moveb	d0,a2@+
	bras	2f
1:	movel	a0@(0x38),d0
2:	bsrw	_unpackb
	movel	d0,a0@(0x38)
	moveq	#0,d0
	moveml	%sp@+,%d2/%a2
	rts
_uerrsmall:				/* 0x2b0 */
	moveml	%sp@+,%d2/%a2
	moveq	#-10,d0
	rts
_uerrlarge:				/* 0x2b8 */
	moveml	%sp@+,%d2/%a2
	moveq	#-11,d0
	rts

_ret0d:					/* 0x2c0 */
	moveq	#0,d0
	rts

/* byte-delta pack helper: out[i] = in[i] - prev */
_packb:					/* 0x2c4 */
	subql	#1,d2
1:	moveb	a1@+,d1
	subb	d0,d1
	moveb	d1,a2@+
	addb	d1,d0
	dbf	d2,1b
	rts

/* byte-delta unpack helper: acc += in[i] */
_unpackb:				/* 0x2d4 */
	subql	#1,d2
1:	addb	a1@+,d0
	moveb	d0,a2@+
	dbf	d2,1b
	rts

/* dead word-delta helpers (only ByteMode is advertised) */
_packw:					/* 0x2e0 */
	lsrl	#1,d2
	subql	#1,d2
1:	movew	a1@+,d1
	subw	d0,d1
	movew	d1,a2@+
	addw	d1,d0
	dbf	d2,1b
	rts
_unpackw:				/* 0x2f2 */
	lsrl	#1,d2
	subql	#1,d2
1:	addw	a1@+,d0
	movew	d0,a2@+
	dbf	d2,1b
	rts

/* dead long-delta helpers */
_packl:					/* 0x300 */
	lsrl	#2,d2
	subql	#1,d2
1:	movel	a1@+,d1
	subw	d0,d1			/* (sic: sub.w on long data) */
	movel	d1,a2@+
	addl	d1,d0
	dbf	d2,1b
	rts
_unpackl:				/* 0x312 */
	lsrl	#2,d2
	subql	#1,d2
1:	addl	a1@+,d0
	movel	d0,a2@+
	dbf	d2,1b
	rts
_nopend:				/* 0x320 rt_EndSkip target */
