|||	xpkNONE_v.s -- verbatim reconstruction of xpkNONE.library 1.4
|||	('NoPacker' dummy sublib, 19.07.1998).  Single CODE hunk,
|||	AUTOINIT RomTag, absolute-long functab (10 vectors).
|||
|||	Quirks preserved verbatim:
|||	  - RELOC32 tail is 28 entries in scrambled descending order
|||	    (island ptrs first, then functab/romtag/inittab interleaved;
|||	    fixup.py rewrites GNU ld's ascending list).
|||	  - rt_EndSkip = 0x9e -> resident copy ends at the name string;
|||	    all code sits below the RomTag (xpk loads it raw).
|||	  - initfn bsr's the trivial RESERVED stub and tests its result.
|||	  - dual 'NONE': inline signature in XpkInfo + a pointed-to string.

	.section .text

_stub:	moveq	#-1,%d0
	rts

_functab:
	.long	_open			| -6
	.long	_close			| -12
	.long	_expunge		| -18
	.long	_reserved		| -24
	.long	_xpkinfo		| -30
	.long	_libfunc1		| -36 -> -17
	.long	_reserved		| -42
	.long	_reserved		| -48
	.long	_copymem		| -54
	.long	_reserved		| -60
	.long	0xffffffff

	.even
	.space	0x24,0			| gap 0x30-0x53

_datatab:
	.byte	0xa0,0x08,0x09,0x00	| byte@+8 = 9  (ln_Type = NT_LIBRARY)
	.byte	0x80,0x0a
	.long	_name			| long@+0x0a = ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| byte@+0x0e = 6 (lib_Flags)
	.byte	0x90,0x14
	.short	1			| word@+0x14 = lib_Version
	.byte	0x90,0x16
	.short	4			| word@+0x16 = lib_Revision
	.byte	0x80,0x18
	.long	_idstr			| long@+0x18 = lib_IdString
	.word	0,0			| term + pad

_inittab:
	.long	0x2a			| dataSize
	.long	_functab
	.long	_datatab
	.long	_initfn

_romtag:
	.word	0x4afc
	.long	_romtag			| matchtag -> self
	.long	_name			| endskip -> 0x9e (mid-resident!)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| rt_Version
	.byte	9			| NT_LIBRARY
	.byte	0			| rt_Pri
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"xpkNONE.library\0"

|||	idstring; the three longs starting at +8 are covered by RELOC32
|||	records in the original (they are ASCII, not pointers -- load-time
|||	(no relocation corrupts them -- that earlier theory was wrong;
|||	0x1b6/0x1ba/0x1be are the island name/nopacker/desc pointers).
_idstr:	.ascii	"xpkNONE 1.4 (19.07.1998)\r\n\0"
	.byte	0			| pad to 0xca

_reserved:
	moveq	#0,%d0
	rts

_expunge:
	moveml	%d2/%d7/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveq	#0,%d7
	bset	#3,%a5@(14)
	tstw	%a5@(32)
	bnes	1f
	moveal	%a5@(38),%a6		| sysbase
	moveal	%a5,%a1
	jsr	%a6@(-252)		| Remove
	movel	%a5@(34),%d7		| seglist
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		| NegSize
	subal	%d0,%a1
	moveq	#0,%d1
	movew	%a5@(18),%d1		| PosSize
	moveq	#0,%d2
	movew	%d0,%d2
	addl	%d1,%d2
	movel	%d2,%d0
	jsr	%a6@(-210)		| FreeMem
1:	movel	%d7,%d0
	moveml	%sp@+,%d2/%d7/%a5-%a6
	rts

_close:
	movel	%d7,%sp@-
	moveq	#0,%d7
	subqw	#1,%a6@(32)
	bnes	2f
	btst	#3,%a6@(14)
	beqs	2f
	bsrs	_expunge
	movel	%d0,%d7
2:	movel	%d7,%d0
	movel	%sp@+,%d7
	rts

_open:
	bclr	#3,%a6@(14)
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	rts

_initfn:
	moveml	%d2/%a5,%sp@-
	movel	%a0,%d1
	moveal	%d0,%a5
	movel	%d1,%a5@(0x22)		| seglist
	movel	%a6,%a5@(0x26)		| sysbase
	bsrw	_reserved		| pointless call; always 0
	tstl	%d0
	beqs	3f
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(0x10),%d0
	subal	%d0,%a1
	moveq	#0,%d1
	movew	%a5@(0x12),%d1
	moveq	#0,%d2
	movew	%d0,%d2
	addl	%d1,%d2
	movel	%d2,%d0
	jsr	%a6@(-210)
	subal	%a5,%a5
3:	movel	%a5,%d0
	moveml	%sp@+,%d2/%a5
	rts

_xpkinfo:
	lea	%pc@(_xi),%a0
	movel	%a0,%d0
	rts

	.even
|||	mode/caps island at 0x184 (pointed to by XpkInfo+0x3c)
_modeblk:
	.long	0,0x64,1,0,0,0x77e,0x9ad,0
	.ascii	"normal\0"
	.byte	0
	.short	0			| pad word -> _xi lands at 0x1ae
_xi:						| XpkInfo @0x1ae
	.short	1			| xi_Version
	.short	1			| xi_Revision
	.short	0,0
	.long	_xs_none		| -> "NONE"   (0x206)
	.long	_xs_nopacker		| -> "NoPacker"
	.long	_xs_desc		| -> "A dummy..."
	.ascii	"NONE"			| inline signature (nul merges into pad word)
	.short	0
	.short	9			| xi_Flags
	.short	0
	.short	0x8000
	.short	0
	.short	0x14
	.short	0
	.short	0x8000
	.long	_xs_writing		| -> "Writing"   (0x240)
	.long	_xs_reading		| -> "Reading"
	.long	_xs_wrote		| -> "Wrote"
	.long	_xs_read		| -> "Read"
	.short	0x32,0
	.long	_modeblk		| -> mode/caps table (0x184)
	.space	0x18,0

	.even
_xs_none:	.ascii	"NONE\0"
	.byte	0
_xs_nopacker:	.ascii	"NoPacker\0"
	.byte	0
_xs_desc:	.ascii	"A dummy library that does no compression\0"
	.byte	0				| pad -> _xs_writing at 0x240
_xs_writing:	.ascii	"Writing\0"
_xs_reading:	.ascii	"Reading\0"
_xs_wrote:	.ascii	"Wrote\0"
_xs_read:	.ascii	"Read\0"
	.byte	0

_libfunc1:
	moveq	#-17,%d0
	rts

_copymem:
	moveml	%a5-%a6,%sp@-
	moveal	%a0,%a5
	movel	%a5@(4),%d0
	movel	%d0,%a5@(16)
	moveal	%a5@,%a0
	moveal	%a5@(8),%a1
	movel	%a5@(4),%d0
	moveal	%a6@(0x26),%a6
	jsr	%a6@(-624)		| CopyMem
	moveq	#0,%d0
	moveml	%sp@+,%a5-%a6
	rts

	.globl	_functab,_datatab,_inittab,_romtag,_name,_idstr
	.globl	_open,_close,_expunge,_reserved,_xpkinfo,_libfunc1,_copymem,_initfn
	.globl	_xi,_modeblk,_xs_none,_xs_nopacker,_xs_desc
	.globl	_xs_writing,_xs_reading,_xs_wrote,_xs_read
