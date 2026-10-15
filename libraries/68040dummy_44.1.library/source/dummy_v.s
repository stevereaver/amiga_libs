* verbatim reconstruction of 68040dummy_44.1.library (Phase5 dummy loader, 692B)
	.text

	/* 0x000 entry stub */
	moveq	#0,%d0
	rts

	/* 0x004 RomTag */
_romtag:
	.short	0x4afc
	.long	_romtag		/* rt_MatchTag */
	.long	_endskip	/* rt_EndSkip */
	.byte	0x80		/* RTF_AUTOINIT */
	.byte	0x2c		/* version 44 */
	.byte	0x09		/* NT_LIBRARY */
	.byte	0x00		/* pri */
_romtag_name:
	.long	_libname
	.long	_idstr
	.long	_inittab

	/* 0x01e name */
_libname:
	.ascii	"68040.library"
	.byte	0

	/* 0x02c idstr */
_idstr:
	.ascii	"68040.library 44.1 (21.6.98) \251 1994-1998 by Phase5, written by Ralph Schmidt"
	.byte	0x0d,0x0a,0,0,0
	.ascii	"$VER: 68040.library 44.1 (21.6.98) \251 1994-1998 by Phase5, written by Ralph Schmidt"
	.byte	0

	/* 0x0d0 InitTable */
	.even
_inittab:
	.long	0x38		/* dataSize (not relocated) */
	.long	_functab
	.long	_datatab
	.long	_initfn

	/* 0x0e0 long-offset function table (4 vectors + -1) */
_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_null
	.long	-1

	/* 0x0f4 InitStruct data table (word-aligned commands) */
_datatab:
	.byte	0xa0,0x08,0x09		/* byte[+8]  = 9   ln_Type = NT_LIBRARY */
	.byte	0
	.byte	0x80,0x0a
	.long	_libname		/* long[+0xa] = ln_Name */
	.byte	0xa0,0x0e,0x06		/* byte[+0xe] = 6  ln_Flags */
	.byte	0
	.byte	0x90,0x14
	.short	0x2c			/* word[+0x14] = lib_Version 44 */
	.byte	0x90,0x16
	.short	0x0001			/* word[+0x16] = lib_Revision 1 */
	.byte	0x80,0x18
	.long	_idstr			/* long[+0x18] = lib_IdString */
	.byte	0x80,0x2c
	.long	0			/* long[+0x2c] = real 68040 lib base */
	.byte	0x80,0x28
	.long	0			/* long[+0x28] = 68060.library base */
	.byte	0,0,0,0

	/* 0x120 initfn (d0=lib base, a0=seglist) */
_initfn:
	moveml	%d2/%a2/%a5-%a6,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(0x24)
	movel	%a0,%a5@(0x30)
	leal	_dosstr(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-0x228)		/* OpenLibrary("dos.library",0) */
	movel	%d0,%a5@(0x34)
	beqs	_ret
	btst	#7,%a6@(0x129)		/* AFB_68060: pass through */
	bnes	_selfret
	btst	#3,%a6@(0x129)		/* AFB_68040 */
	beqs	_fail0
	btst	#6,%a6@(0x129)		/* AFB_FPU40 */
	beqs	_nfpu
	leal	_newstr(%pc),%a1	/* "68040new.library" */
	moveq	#0,%d0
	bsrw	_loadseg
	movel	%d0,%a5@(0x2c)
	bnes	_fail0
	leal	_oldstr(%pc),%a1	/* "68040old.library" */
	moveq	#0,%d0
	bsrw	_loadseg
	movel	%d0,%a5@(0x2c)
	beqs	_ret
_fail0:
	moveq	#0,%d0			/* loader done: dummy self-frees */
	bras	_ret
	nop
_nfpu:
	leal	_060str(%pc),%a1	/* "68060.library" */
	moveq	#0,%d0
	jsr	%a6@(-0x228)		/* OpenLibrary */
	movel	%d0,%a5@(0x28)
	beqs	_ret
_selfret:
	movel	%a5,%d0
_ret:
	moveml	%sp@+,%d2/%a2/%a5-%a6
	rts

	/* 0x194 LIBS: path strings (lea targets point past "LIBS:") */
	.ascii	"LIBS:"
_060str:.ascii	"68060.library"
	.byte	0
	.ascii	"LIBS:"
_oldstr:.ascii	"68040old.library"
	.byte	0
	.ascii	"LIBS:"
_newstr:.ascii	"68040new.library"
	.byte	0
_dosstr:.ascii	"dos.library"
	.byte	0,0

	/* 0x1e0 RomTag-walk helper: d2=seglist BPTR -> resident ptr or 0 */
_walkseg:
	movel	%d2,%d0
	lsll	#2,%d0
	beqs	_walkout
	moveal	%d0,%a0
	movel	%a0@(-4),%d1
	movel	%a0@+,%d0
_wloop:
	subql	#2,%d1
	blss	_wfail
	cmpiw	#0x4afc,%a0@+
	bnes	_wloop
	leal	%a0@(-2),%a1
	cmpal	%a1@(2),%a1
	bnes	_wloop
	movel	%a1,%d0
	rts
_wfail:
	bras	_walkseg+2		/* bra back to the lsl (next hunk link) */
_walkout:
	rts

	/* 0x20a LoadSeg+InitResident helper: a1=name(bare), d0=0 */
_loadseg:
	moveal	%a1,%a2
	movel	%a2,%d1
	subql	#5,%d1			/* back to "LIBS:" prefix */
	moveal	%a5@(0x34),%a6		/* dosbase */
	jsr	%a6@(-0x96)		/* dos.LoadSeg */
	movel	%d0,%d2
	beqs	_lfail
	bsrw	_walkseg
	tstl	%d0
	bnes	_initres
	movel	%d2,%d1
	jsr	%a6@(-0x9c)		/* dos.UnLoadSeg */
	moveq	#0,%d0
_lfail:
	moveal	%a5@(0x24),%a6		/* execbase */
	rts
_initres:
	moveal	%a5@(0x24),%a6
	moveal	%d0,%a1
	movel	%d2,%d0
	jsr	%a6@(-0x66)		/* exec.InitResident */
	rts

	/* 0x240 open: bump OpenCnt, clear DELEXP, re-store type, proxy to 060 lib */
_open:
	addqw	#1,%a6@(0x20)
	bclrb	#3,%a6@(0x22)
	moveb	#9,%a6@(0x08)
	movel	%a6@(0x28),%d0
	bnes	_openout
	movel	%a6,%d0
_openout:
	rts

	/* 0x25a close / 0x25e expunge / 0x262 reserved: all pinned, return 0 */
_close:
	moveq	#0,%d0
	rts
_expunge:
	moveq	#0,%d0
	rts
_null:
	moveq	#0,%d0
	rts
	nop
_endskip:
