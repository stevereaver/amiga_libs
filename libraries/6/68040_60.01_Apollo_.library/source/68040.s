/*
 * 68040.library 60.01 (Apollo) -- byte-exact reconstruction.
 * ($VER:68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani))
 *
 * Single 0x11c-byte CODE hunk: "moveq #0,d0/rts" loader entry, RomTag
 * (RTF_AUTOINIT, RT_VERSION=60), name + $VER: id strings, AUTOINIT
 * InitTable (dataSize 0x22 == bare struct Library), an absolute-long
 * function table (Open, Close, Expunge, ExtFunc -- the last two share
 * one moveq/rts stub) and an old-style InitStruct data table.
 *
 * LibClose falls through into the shared Expunge/ExtFunc stub and so
 * returns 0 (never expunges).  LibInit OpenLibrary()s the real Apollo
 * CPU-support library as a side effect; it is deliberately never
 * closed so it stays resident.
 *
 * LVOs: -6 Open, -12 Close, -18 Expunge, -24 ExtFunc.  No user API.
 */
	.text

	moveq	#0,d0
	rts

_romtag:
	.short	0x4afc			/* RT_MATCHWORD */
	.long	_romtag			/* RT_MATCHTAG */
	.long	_endskip		/* RT_ENDSKIP */
	.byte	0x80,0x3c,0x09,0x00	/* RTF_AUTOINIT, ver 60, NT_LIBRARY, pri 0 */
	.long	_libname		/* RT_NAME */
	.long	_idstr			/* RT_IDSTRING (points past "$VER:") */
	.long	_inittab		/* RT_INIT */

_libname:
	.ascii	"68040.library"
	.byte	0
	.ascii	"$VER:"
_idstr:
	.ascii	"68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani)"
	.byte	0xd,0xa,0
	.even

/* InitTable: dataSize, funcTable, dataTable, initFunc */
_inittab:
	.long	0x22			/* sizeof(struct Library), no privates */
	.long	_functab
	.long	_datatab
	.long	_initfn

/* absolute-long function table, -1L terminated */
_functab:
	.long	_open			/* LVO -6  */
	.long	_close			/* LVO -12 */
	.long	_expunge		/* LVO -18 */
	.long	_expunge		/* LVO -24 (ExtFunc shares the stub) */
	.long	0xffffffff

/* old-style InitStruct data table (InitStruct() nibble commands) */
_datatab:
	.short	0xa008
	.byte	9,0			/* INITBYTE ln_Type = NT_LIBRARY */
	.short	0x800a
	.long	_libname		/* INITLONG ln_Name */
	.short	0xa00e
	.byte	6,0			/* INITBYTE lib_Flags = CHANGED|SUMUSED */
	.short	0x9014
	.short	60			/* INITWORD lib_Version = 60 */
	.short	0x9016
	.short	0			/* INITWORD lib_Revision = 0 (!) */
	.short	0x8018
	.long	_idstr			/* INITLONG lib_IdString */
	.short	0,0			/* terminator + pad */

/* --- vectors -------------------------------------------------------- */
/* Open (a6 = libbase): OpenCnt++, return base in d0 */
_open:
	addqw	#1,a6@(32)
	movel	a6,d0
	rts

/* Close (a6 = libbase): OpenCnt--, then falls through into the shared
 * Expunge/ExtFunc stub: returns 0, never expunges */
_close:
	subqw	#1,a6@(32)
_expunge:
	moveq	#0,d0
	rts

/* --- init ----------------------------------------------------------- */
/* called by InitResident with d0 = libbase, a0 = seglist, a6 = SysBase.
 * requires AFB_68040; if AttnFlags == $80ff (real support lib already
 * installed its marker) skip loading and return the base; else open
 * "68o4o.library" (AFF_FPU40 set) or "68060.library" (no FPU). */
_initfn:
	moveml	d1-d7/a0-a6,sp@-
	movel	d0,d7			/* d7 = libbase */
	moveq	#0,d0			/* default: fail */
	btst	#3,a6@(297)		/* AttnFlags low byte: AFB_68040 */
	beqs	_idone			/*   not a 040-class CPU -> 0 */
	movel	d7,d0			/* default: success = base */
	cmpiw	#0x80ff,a6@(296)	/* whole AttnFlags == $80ff? */
	beqs	_idone			/*   marker present -> base */
	btst	#6,a6@(297)		/* AFB_FPU40 */
	beqs	_inofpu
	lea	_str_68o4o(pc),a1	/* FPU present: "68o4o.library" */
	bras	_iopen
_inofpu:
	lea	_str_68060(pc),a1	/* no FPU: "68060.library" */
_iopen:
	moveq	#0,d0			/* version 0 */
	jsr	a6@(-552)		/* _LVOOpenLibrary */
	tstl	d0
	beqs	_idone			/* open failed -> 0 */
	movel	d7,d0			/* else return base */
_idone:
	moveml	sp@+,d1-d7/a0-a6
	rts

_str_68o4o:
	.ascii	"68o4o.library"		/* Apollo's own 040 lib, letter 'o' */
	.byte	0
_str_68060:
	.ascii	"68060.library"
	.byte	0
	.short	0			/* tail pad to longword hunk end */
_endskip:
