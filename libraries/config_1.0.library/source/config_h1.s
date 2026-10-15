/* config.library 1.0 -- hunk 1: DATA (0x154 file bytes; table size 0x56
 * longs -- one longword bigger than the hunk body, quirk preserved by
 * fixup.py).  Holds format strings, lib base cells, RomTag, datatab,
 * InitTable and the absolute-long functab.  a4-relative small-data base
 * is _h1+0x7ffe.
 */
	.data
	.globl	_h1
_h1:
_fmt_ld:	.ascii	"%ld"		/* @0x00 */
	.byte	0
_fmt_eq:	.ascii	" = "		/* @0x04 */
	.byte	0
_fmt_ld2:	.ascii	"%ld"		/* @0x08 */
	.byte	0
_fmt_kvnl:	.ascii	"%s = %s\n"	/* @0x0c */
	.byte	0
_fmt_nl:	.ascii	"\n"		/* @0x15 */
	.byte	0
	.byte	0			/* @0x17 pad */
_fmt_sec:	.ascii	"%s[%s]\n"	/* @0x18 */
	.byte	0
_fmt_kv2:	.ascii	"%s = %s\n"	/* @0x20 */
	.byte	0
_fmt_s:		.ascii	"%s\n"		/* @0x29 */
	.byte	0
_fmt_kv3:	.ascii	"%s = %s\n"	/* @0x2d */
	.byte	0
_fmt_sep:	.ascii	" = "		/* @0x36 */
	.byte	0
_fmt_nl2:	.ascii	"\n"		/* @0x3a */
	.byte	0
	.byte	0			/* @0x3c pad */
_fmt_ss:	.ascii	"%s%s\n"	/* @0x3d */
	.byte	0
_fmt_kv4:	.ascii	"%s = %s\n"	/* @0x43 */
	.byte	0
_SysBaseG:	.long	0		/* @0x4c */
_DOSBaseG:	.long	0		/* @0x50 */
_IntuitionG:	.long	0		/* @0x54 */
_GfxBaseG:	.long	0		/* @0x58 */
_name:	.ascii	"config.library"	/* @0x5c */
	.byte	0
	.byte	0			/* @0x6b pad */
_idstr:	.ascii	"config 1.0 (12.10.96)" /* @0x6c */
	.byte	0
	.byte	0,0			/* @0x82 pad */
_copyr:	.ascii	"Copyright (C) 1996, Adam Dawes" /* @0x84 */
	.byte	0
	.byte	0			/* @0xa3 pad */
/* ---- RomTag @0xa4 (in DATA hunk!) -------------------------------- */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_h1end			/* endskip -> h1+0x154 */
	.byte	0x80,3,9,0		/* AUTOINIT, ver 3, NT_LIBRARY, pri 0 */
	.long	_name
	.long	_idstr
	.long	_inittab
/* ---- datatab @0xbe: mixed C-form rep + asm single cmds ------------ */
_datatab:
	.short	0xe000,0x0008,0x0900	/* INITBYTE +8  ln_Type=9 */
	.short	0x800a			/* INITLONG +10 ln_Name */
	.long	_name
	.short	0xe000,0x000e,0x0600	/* INITBYTE +14 lib_Flags=6 */
	.short	0xd000,0x0014,0x0003	/* INITWORD +20 lib_Version=3 */
	.short	0xd000,0x0016,0x0000	/* INITWORD +22 lib_Revision=0 */
	.short	0x8018			/* INITLONG +24 lib_IdString */
	.long	_idstr
	.short	0,0			/* end -> 0xe2 */
_gfxnam:	.ascii	"graphics.library" /* @0xe6 */
	.byte	0
_intnam:	.ascii	"intuition.library" /* @0xf7 */
	.byte	0
_dosnam:	.ascii	"dos.library"	/* @0x109 */
	.byte	0
	.byte	0,0,0			/* @0x115 pad */
/* ---- InitTable @0x118 --------------------------------------------- */
_inittab:
	.long	0x36			/* dsize */
	.long	_functab		/* -> h1+0x128 */
	.long	_datatab		/* -> h1+0xbe */
	.long	_initfn			/* -> h0+0x6fc */
_functab:				/* @0x128: 8 absolute entries */
	.long	_open,_close,_expunge,_nullv
	.long	_setstr,_setnum,_getstr,_getnum
	.long	0xffffffff
_libbase:	.long	0,0		/* @0x14c tail: libbase cell + pad */
_h1end:
