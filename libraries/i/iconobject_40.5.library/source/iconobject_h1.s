/* iconobject.library 40.5 -- hunk1: data block (368 B).
 * SAS/C 6.58 absolute-data model (a4 = _LinkerDB = 0; all data refs are
 * absolute .l into this hunk).  Layout: strings, functab, InitTable,
 * RomTag, then 5 zeroed library-base globals.
 * Relocs: 12 -> hunk0 (functab vectors + initfn), 6 self (romtag/inittab).
 * Original group order (descending, quirky) restored by fixup.py.        */
	.data
	.globl	_libname, _verstr, _iffnam, _dosnam, _intuinam, _utilnam
	.globl	_dtpath1, _dtext1, _dtpath2, _dtext2, _infoext, _hashinfo
	.globl	_devsdt, _zfc, _zfe
	.globl	_gd_sysb, _gd_intuition, _gd_utility, _gd_dos, _gd_iffparse

_libname:	.ascii	"iconobject.library"
		.byte	0,0
_verstr:	.ascii	"$VER: iconobject.library 40.5 (13 Sep 2005 20:01:11)  (SAS/C 6.58) "
		.byte	0xa9
		.ascii	"1999-2006 The Scalos Team"
		.byte	0
_iffnam:	.ascii	"iffparse.library"
		.byte	0,0
_dosnam:	.ascii	"dos.library"
		.byte	0
_intuinam:	.ascii	"intuition.library"
	.byte	0
_utilnam:	.ascii	"utility.library"
	.byte	0
_dtpath1:	.ascii	"datatypes/"
	.byte	0,0
_dtext1:	.ascii	".datatype"
	.byte	0
_dtpath2:	.ascii	"datatypes/"
	.byte	0,0
_dtext2:	.ascii	".datatype"
	.byte	0
_infoext:	.ascii	".info"
	.byte	0
_hashinfo:	.ascii	"#?.info"
	.byte	0
_devsdt:	.ascii	"DEVS:Datatypes/"
	.byte	0
_zfc:	.short	0		/* +0xfc referenced as taglist end */
_zfe:	.short	0		/* +0xfe */

_functab:
	.long	_open		/* LVO -6   */
	.long	_close		/* LVO -12  */
	.long	_expunge	/* LVO -18  */
	.long	_reserved	/* LVO -24  (returns 0) */
	.long	_v30		/* LVO -30  */
	.long	_v36		/* LVO -36  */
	.long	_v42		/* LVO -42  */
	.long	_v48		/* LVO -54? */
	.long	_v54		/* LVO -54  */
	.long	_v60		/* LVO -60  */
	.long	_v66		/* LVO -66  */
	.long	0xffffffff

_inittab:
	.long	0x68		/* data base size (LIB + priv) */
	.long	_functab
	.long	0		/* no InitStruct data table */
	.long	_initfn

_romtag:
	.short	0x4afc		/* RTC_MATCHTAG */
	.long	_romtag		/* rt_MatchTag */
	.long	_endskip	/* rt_EndSkip */
	.byte	0x80		/* rt_Flags = RTF_AUTOINIT */
	.byte	0x28		/* rt_Version = 40 */
	.byte	0x09		/* rt_Type = NT_LIBRARY */
	.byte	0x00		/* rt_Pri */
	.long	_libname	/* rt_Name */
	.long	_verstr		/* rt_IdString */
	.long	_inittab	/* rt_Init */
_endskip:
	.short	0
_gd_sysb:	.long	0	/* +0x15c SysBase stashed by _initfn */
_gd_intuition:	.long	0	/* +0x160 IntuitionBase */
_gd_utility:	.long	0	/* +0x164 UtilityBase */
_gd_dos:	.long	0	/* +0x168 DOSBase */
_gd_iffparse:	.long	0	/* +0x16c IFFParseBase */
