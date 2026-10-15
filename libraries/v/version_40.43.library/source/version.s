/* version.library 39.29 (WB) - single CODE hunk reconstruction
 * Tiny WB-version placeholder: Open/Close + inline unconditional
 * expunge on last close; -18/-24 share a return-0 stub.
 * initfn writes revision 42 to lib+22.
 */
	.text

/* ---- DOS stub @0x00 ---- */
	moveq	#-1,%d0
	rts

/* ---- RomTag @0x04 ---- */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x28,0x09,0x00	/* AUTOINIT, ver 40, NT_LIBRARY */
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"version.library\0"	/* @0x1e */
_idstr:	.ascii	"version 40.43 (07.2.11)\r\n\0"	/* @0x2e - 26B, no pad */

/* ---- InitTable @0x48 ---- */
_inittab:
	.long	0x2a			/* dsize */
	.long	_functab
	.long	0			/* datatab */
	.long	_init			/* initfn */

/* ---- functab @0x58: word-offset mode ---- */
_functab:
	.short	0xffff
	.short	0x0020			/* -6  -> 0x78 Open */
	.short	0x0028			/* -12 -> 0x80 Close */
	.short	0x0062			/* -18 -> 0xba stub */
	.short	0x0062			/* -24 -> 0xba stub */
	.short	0xffff

/* ---- initfn @0x64 ---- */
_init:	exg	%d0,%a5			/* a5=libbase, d0 saved */
	movel	%a6,%a5@(34)		/* execbase */
	movel	%a0,%a5@(38)		/* seglist */
	movew	#42,%a5@(22)		/* revision 42 */
	exg	%d0,%a5			/* d0=libbase out */
	rts

/* ---- Open @0x78 ---- */
_open:	addqw	#1,%a6@(32)
	movel	%a6,%d0
	rts

/* ---- Close @0x80: dec opencnt, expunge inline when 0 ---- */
_close:	subqw	#1,%a6@(32)
	bnes	_clret
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	movel	%a5@(38),%d2		/* seglist */
	moveal	%a5,%a1
	moveal	%a1@+,%a0		/* inline Remove */
	moveal	%a1@,%a1
	movel	%a0,%a1@
	movel	%a1,%a0@(4)
	moveal	%a5@(34),%a6		/* execbase */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* negsize */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + possize */
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d2,%d0		/* return seglist */
	moveml	%sp@+,%d2/%a5-%a6
_clret:	rts

/* ---- -18/-24 stub @0xba ---- */
_stub:	moveq	#0,%d0
	rts
_endskip:				/* EndSkip -> 0xbe */

	.globl	_romtag
	.end
