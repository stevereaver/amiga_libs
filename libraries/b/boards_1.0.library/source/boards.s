/* boards.library 1.0 (14.4.96) — Richard Körber "shred"
 * Replaces boards.library by Torsten Bach: a one-vector shim that
 * opens "expname.library" at init and proxies user LVO -30 to it
 * (result inverted with not.l).  Single CODE hunk; the lib-base and
 * expname-base cells live in the code at +0x1f6/+0x1fa (self-
 * modifying).  DREL16 (0x3f7) reloc tail — see fixup.py.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
	moveq	#-1,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_endskip		/* rt_EndSkip = 0x200 */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	1			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name			/* 0x1e */
	.long	_idstr			/* 0x2d */
	.long	_inittab		/* 0xd0 */

_name:	.ascii	"boards.library"
	.byte	0
_idstr:	.ascii	"boards.library 1.0 (14.4.96)\015\012"
	.byte	0
_banner:
	.ascii	"boards.library V1.0  Replaces boards.library by Torsten Bach    (C) 1995-96 Richard K\366rber     e-mail: shred@tfh.dssd.sub.org   \015\012"
	.byte	0,0

/* ---- InitTable ----------------------------------------------- */
	.even
_inittab:
	.long	0x2c			/* dataSize */
	.long	_functab		/* 0xe0 */
	.long	_datatab		/* 0xf8 */
	.long	_init			/* 0x118 */

_functab:
	.long	_open			/* -6   Open    0x162 */
	.long	_close			/* -12  Close   0x170 */
	.long	_expunge		/* -18  Expunge 0x184 */
	.long	_null			/* -24          0x1de */
	.long	_getflag		/* -30  user    0x1e2 */
	.long	-1

_datatab:
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE  ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG  ln_Name */
	.long	_name
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE  lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x01	/* INITWORD  lib_Version=1 */
	.byte	0x90,0x16,0x00,0x00	/* INITWORD  lib_Revision=0 */
	.byte	0x80,0x18		/* INITLONG  lib_IdString */
	.long	_idstr
	.byte	0,0,0,0

/* ---- init ----------------------------------------------------- */
_init:
	moveml	d1-d7/a0-a6,sp@-
	moveal	d0,a5
	movel	d0,_libself		/* self cell in code */
	movel	a6,a5@(0x24)		/* lb_SysBase */
	movel	a0,a5@(0x28)		/* lb_SegList */
	lea	_expname(pc),a1
	moveq	#1,d0
	moveal	4,a6
	jsr	a6@(-0x228)		/* OpenLibrary */
	movel	d0,_expbase
	beqw	_initfail
	movel	a5,d0
_initpop:
	moveml	sp@+,d1-d7/a0-a6
	rts
_initfail:
	moveq	#0,d0
	braw	_initpop

_expname:
	.ascii	"expname.library"
	.byte	0
	.even

/* ---- vectors -------------------------------------------------- */
_open:
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#0,a6@(0x23)		/* clear deferred-expunge flag */
	movel	a6,d0
	rts

_close:
	moveq	#0,d0
	subqw	#1,a6@(0x20)
	bnes	1f
	btstb	#0,a6@(0x23)
	beqs	1f
	bsrs	_expunge
1:	rts

_expunge:
	moveml	d2/a5-a6,sp@-
	moveal	a6,a5
	moveal	a5@(0x24),a6
	tstw	a5@(0x20)
	beqs	2f
	bsetb	#0,a5@(0x23)		/* mark deferred expunge */
	moveq	#0,d0
	braw	3f
2:	movel	a5@(0x28),d2		/* seglist */
	moveal	a5,a1
	moveal	4,a6
	jsr	a6@(-0xfc)		/* Remove */
	movel	_expbase(pc),d0
	beqw	4f
	moveal	d0,a1
	moveal	4,a6
	jsr	a6@(-0x19e)		/* CloseLibrary(expname) */
4:	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(0x10),d0		/* negSize */
	subal	d0,a1
	addw	a5@(0x12),d0		/* +posSize */
	moveal	4,a6
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0
3:	moveml	sp@+,d2/a5-a6
	rts

_null:
	moveq	#0,d0
	rts

/* user vector -30: proxy expname.-30, return ~result */
_getflag:
	moveml	d1-d3/a0-a3/a6,sp@-
	moveal	_expbase(pc),a6
	jsr	a6@(-0x1e)
	notl	d0
	moveml	sp@+,d1-d3/a0-a3/a6
	rts

/* ---- self-modifying cells + tail ------------------------------ */
_libself:
	.long	0			/* 0x1f6: this lib's base */
_expbase:
	.long	0			/* 0x1fa: expname.library base */
	nop
_endskip:
