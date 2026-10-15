/* xpkCYB1.library v1.0 (24.04.1996) by Alexis Nasr (The Cyborg/NGC)
 * Verbatim reconstruction.  Single CODE hunk, AUTOINIT RomTag.
 * Absolute-LONG functab (10 vectors, -1 terminator).  All five packer
 * slots (-36..-60) share one "movel #-1,d0; rts" stub: this is an
 * info-only sublibrary.  Quirks: rt_EndSkip == rt_Init (0x78); the
 * IdString pointer skips the "$VER:" prefix (+0x33 into the string);
 * InitStruct writes NT_LIBRARY to base+0x0c instead of ln_Type(+0x08);
 * expunge runs Remove with a6 = SysBase pulled from the library base.
 */
	.text

/* ---- 0x00 entry stub (also the shared null result) ------------- */
_stub0:
	moveq	#0,d0
	rts

/* ---- 0x04 RomTag ---------------------------------------------- */
_romtag:
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_inittab		/* rt_EndSkip = 0x78 (== rt_Init) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	0x01			/* rt_Version */
	.byte	0x09			/* NT_LIBRARY */
	.byte	0x00			/* rt_Pri */
	.long	_libname		/* 0x1e */
	.long	_idstr			/* 0x33, past the "$VER:" prefix */
	.long	_inittab		/* 0x78 */

_libname:
	.ascii	"xpkCYB1.library"	/* 0x1e */
	.byte	0
_verstr:
	.ascii	"$VER:"			/* 0x2e prefix (skipped) */
_idstr:					/* 0x33: id starts past "$VER:" */
	.ascii	"xpkCYB1.library v1.0 (24.04.1996) by Alexis Nasr (The Cyborg/NGC)"
	.byte	0x0d,0x0a		/* ..0x75 */
	.byte	0,0			/* NUL + pad to 0x78 */

/* ---- 0x78 InitTable -------------------------------------------- */
_inittab:
	.long	0x4a			/* dataSize: Library + sysbase +
					   seglist + 0x20 spare */
	.long	_functab		/* 0x88 */
	.long	_datatab		/* 0xb4 */
	.long	_init			/* 0xd4 */

/* ---- 0x88 absolute-long function table (10 vectors + -1) ------- */
_functab:
	.long	_open			/* -6   -> 0xe4  */
	.long	_close			/* -12  -> 0xf2  */
	.long	_expunge		/* -18  -> 0x10c */
	.long	_ret0			/* -24  -> 0x14e */
	.long	_xpkinfo		/* -30  -> 0x152 */
	.long	_fail			/* -36  PackChunk   -> 0x15c (-1) */
	.long	_fail			/* -42  PackFree    -> 0x15c (-1) */
	.long	_fail			/* -48  PackReset   -> 0x15c (-1) */
	.long	_fail			/* -54  UnpackChunk -> 0x15c (-1) */
	.long	_fail			/* -60  UnpackFree  -> 0x15c (-1) */
	.long	-1

/* ---- 0xb4 InitStruct data table ---------------------------------
 * Quirk: NT_LIBRARY is written to base+0x0c, not ln_Type (base+0x08);
 * ln_Type is left 0 in the built library node. */
_datatab:
	.byte	0xa0,0x0c,0x09,0x00	/* byte[+0x0c] = 9 (ln_Type bug) */
	.byte	0x80,0x0a
	.long	_libname		/* ln_Name */
	.byte	0xa0,0x0e,0x06,0x00	/* byte[+0x0e] = 6 lib_Flags */
	.byte	0x90,0x14
	.short	1			/* lib_Version = 1 */
	.byte	0x90,0x16
	.short	0			/* lib_Revision = 0 -> "1.0" */
	.byte	0x80,0x18
	.long	_idstr			/* lib_IdString -> 0x33 */
	.byte	0,0,0,0			/* terminator + pad */

/* ---- code ------------------------------------------------------ */
_init:					/* 0xd4 */
	movel	a5,sp@-
	moveal	d0,a5			/* lib base */
	movel	a6,a5@(0x22)		/* xsb_SysBase */
	movel	a0,a5@(0x26)		/* xsb_SegList */
	moveal	sp@+,a5
	rts

_open:					/* 0xe4 */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0x0e)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xf2 */
	moveq	#0,d0
	subqw	#1,a6@(0x20)
	bnew	1f			/* still open -> ret 0 */
	btstb	#3,a6@(0x0e)
	beqw	1f			/* no pending expunge -> ret 0 */
	bsrw	_expunge
1:	rts				/* 0x10a */

_expunge:				/* 0x10c */
	moveml	d1-d2/a5-a6,sp@-
	moveal	a6,a5			/* lib */
	moveal	a5@(0x22),a6		/* SysBase (from lib base) */
	tstw	a5@(0x20)
	beqw	2f			/* cnt==0 -> real expunge */
	bsetb	#3,a5@(0x0e)		/* deferred: LIBF_DELEXP */
	moveq	#0,d0
	braw	3f
2:	movel	a5@(0x26),d2		/* 0x12a: seglist */
	moveal	a5,a1
	jsr	a6@(-0xfc)		/* Remove */
	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(0x10),d0		/* NegSize */
	subal	d0,a1
	addw	a5@(0x12),d0		/* + PosSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0			/* return seglist */
3:	moveml	sp@+,d1-d2/a5-a6	/* 0x148 */
	rts

_ret0:					/* 0x14e reserved -24 */
	moveq	#0,d0
	rts

_xpkinfo:				/* 0x152 -30 XpksPackerInfo */
	movel	a0,d0			/* swap-in arg via exg */
	lea	_xpkdata(pc),a0		/* -> 0x164 */
	exg	d0,a0
	rts

_fail:					/* 0x15c all packer slots -> -1 */
	.short	0x203c,0xffff,0xffff	/* movel #-1,d0 (gas would fold to moveq) */
	rts

/* ---- 0x164 XpkInfo data island (in the code hunk) --------------- */
_xpkdata:
	.short	1			/* xi_XpkInfoVersion */
	.short	1			/* xi_LibVersion */
	.short	0			/* xi_MasterVersion */
	.short	0			/* xi_ModesVersion */
	.long	_s_name			/* xi_Name        -> "CYB1" */
	.long	_s_lname		/* xi_LongName    -> "Crunch?Yes...Better!" */
	.long	_s_desc			/* xi_Description */
	.ascii	"CYB1"			/* xi_ID */
	.long	9			/* xi_Flags */
	.long	0x00080000		/* xi_MaxPkInChunk = 512K */
	.long	8			/* xi_MinPkInChunk */
	.long	0x00008000		/* xi_DefPkInChunk = 32K */
	.long	_s_msg			/* xi_PackMsg     -> "DummyMsg" */
	.long	_s_msg			/* xi_UnpackMsg */
	.long	_s_msg			/* xi_PackedMsg */
	.long	_s_msg			/* xi_UnpackedMsg */
	.short	100			/* xi_DefMode */
	.short	0			/* pad */
	.long	_xpkmode		/* xi_ModeDesc    -> 0x224 */
	.long	0,0,0,0,0,0		/* xi_Reserved[6] ..0x1bb */

_s_name:.ascii	"CYB1"			/* 0x1bc */
	.byte	0
_s_lname:
	.ascii	"Crunch?Yes...Better!"	/* 0x1c1 */
	.byte	0
_s_desc:.ascii	"The totally adaptive Xpk SubLib!!!"	/* 0x1d6 */
	.byte	0x0a
	.ascii	"(c) 1996 A.Nasr (The Cyborg/NGC)"
	.byte	0
_s_msg:	.ascii	"DummyMsg"		/* 0x21a */
	.byte	0,0			/* pad to 0x224 */

/* ---- 0x224 XpkMode --------------------------------------------- */
_xpkmode:
	.long	0			/* xm_Next */
	.long	100			/* xm_Upto */
	.long	1			/* xm_Flags */
	.long	0			/* xm_PackMemory */
	.long	0			/* xm_UnpackMemory */
	.long	30			/* xm_PackSpeed */
	.long	600			/* xm_UnpackSpeed */
	.short	500			/* xm_Ratio */
	.short	0			/* xm_ChunkSize */
	.byte	0x2a,0x3b,0x2d,0x29	/* xm_Description: "*;-)" */
	.byte	0,0,0,0x78		/*   + 3 NUL pads + stray 0x78 */
					/* (8-byte field, hunk ends 0x24c) */
