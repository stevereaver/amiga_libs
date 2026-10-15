/* xpkNONE.library V1.5 (1 Oct 2013) by Dirk Stoecker
 * "A dummy library that does no compression" — XPK sublib.
 * Single CODE hunk; word-offset functab (nulls are backward offsets
 * to the moveq#0/rts stub at code+0); self-modifying code cells none,
 * but seglist lives at lib+0x22 and info table is a code data island.
 * Quirk: rt_EndSkip stores literal 0, no relocation emitted.
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
	.byte	1			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"xpkNONE.library"
	.byte	0
_idstr:	.ascii	"$VER: xpkNONE V1.5 (1 Oct 2013) by Dirk Stoecker\015\012"
	.byte	0,0

/* ---- InitTable ------------------------------------------------ */
_inittab:
	.long	0x26			/* dataSize */
	.long	_functab		/* 0x92 */
	.long	_datatab		/* 0x72 */
	.long	_init			/* 0xaa */

_datatab:
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_name
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x01	/* INITWORD lib_Version=1 */
	.byte	0x90,0x16,0x00,0x05	/* INITWORD lib_Revision=5 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.byte	0,0,0,0

_functab:				/* word offsets from _functab */
	.short	0xffff
	.short	_open    - _functab	/* -6   Open    0xb2 */
	.short	_close   - _functab	/* -12  Close   0xc0 */
	.short	_expunge - _functab	/* -18  Expunge 0xd2 */
	.short	_stub0   - _functab	/* -24  stub    0x00 */
	.short	_xpkinfo - _functab	/* -30  info    0x110 */
	.short	_xpkerr  - _functab	/* -36  -17     0x118 */
	.short	_stub0   - _functab	/* -42  stub */
	.short	_stub0   - _functab	/* -48  stub */
	.short	_xpkcopy - _functab	/* -54  CopyMem 0x11c */
	.short	_stub0   - _functab	/* -60  stub */
	.short	0xffff

/* ---- code ----------------------------------------------------- */
_init:
	moveal	d0,a1
	movel	a0,a1@(0x22)		/* lb_SegList */
	rts

_open:
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:
	subqw	#1,a6@(0x20)
	bnew	_stub0			/* still open -> ret 0 via stub */
	btstb	#3,a6@(0xe)
	beqw	_stub0			/* no pending expunge -> ret 0 */

_expunge:
	tstw	a6@(0x20)
	beqs	1f
	bsetb	#3,a6@(0xe)		/* deferred expunge */
	braw	_stub0			/* ret 0 via stub */
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

_xpkinfo:
	lea	_xinfo(pc),a0
	movel	a0,d0
	rts

_xpkerr:
	moveq	#-17,d0			/* 0xef */
	rts

_xpkcopy:
	movel	a6,sp@-
	movel	a0@(4),d0		/* len */
	movel	d0,a0@(0x10)		/* store len into param+16 */
	moveal	a0@(8),a1		/* dst */
	.short	0x2068,0x0000		/* movea.l 0(a0),a0 (disp16 form) */
	moveal	4,a6
	jsr	a6@(-0x270)		/* CopyMem */
	moveq	#0,d0
	moveal	sp@+,a6
	rts

/* ---- data islands -------------------------------------------- */
_xinfo:					/* 0x13c XpkInfo block */
	.short	1,1,2,0
	.long	_nopack			/* 0x144 -> "NoPacker" */
	.long	_nopack			/* 0x148 -> "NoPacker" */
	.long	_desc			/* 0x14c -> desc */
	.ascii	"NONE"			/* xpkSign, 0x150 (no NUL pad) */
	.long	9			/* 0x154 */
	.long	0x8000			/* 0x158 */
	.long	0x14			/* 0x15c */
	.long	0x8000			/* 0x160 */
	.long	_str_writing		/* 0x164 */
	.long	_str_reading		/* 0x168 */
	.long	_str_wrote		/* 0x16c */
	.long	_str_read		/* 0x170 */
	.long	0x00640000		/* 0x174 */
	.long	_blk194			/* 0x178 self-ref */
	.long	0,0,0,0,0,0		/* 0x17c-0x193 */

_blk194:				/* 0x194 */
	.long	0,0x64,1,0,0,0x5aa,0x5aa,0
	.ascii	"normal"			/* 0x1b4 */
	.byte	0,0,0,0
_nopack:
	.ascii	"NoPacker"		/* 0x1be */
	.byte	0
_desc:
	.ascii	"A dummy library that does no compression" /* 0x1c7 */
	.byte	0
_str_writing:
	.ascii	"Writing"		/* 0x1f0 */
	.byte	0
_str_reading:
	.ascii	"Reading"		/* 0x1f8 */
	.byte	0
_str_wrote:
	.ascii	"Wrote"			/* 0x200 */
	.byte	0
_str_read:
	.ascii	"Read"			/* 0x206 */
	.byte	0,0
