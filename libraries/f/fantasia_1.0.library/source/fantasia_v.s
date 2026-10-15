|||	fantasia_v.s -- verbatim reconstruction of fantasia.library 1.0
|||	(joystick decoder: JOY1DAT/POTGOR/CIAA quadrature + buttons).
|||	Single CODE hunk, AUTOINIT RomTag, absolute-long functab.
|||
|||	Quirks preserved verbatim:
|||	  - datatab `a0 0c 09` writes byte 9 at lib+0x0c (inside the
|||	    ln_Name long) immediately before the name-ptr write at +0x0a
|||	    overwrites it -> dead store, ln_Type stays 0.
|||	  - `bne.l +4` after OpenLibrary: branch target == fall-through,
|||	    dos-open failure is never tested (degenerate compiler artefact).
|||	  - Close tests the deferred-expunge flag via a5 (+0x2e) instead
|||	    of a6 -- caller's a5, latent defect.
|||	  - rt_EndSkip = 0x52 points at the InitTable (mid-resident).

	.section .text

_stub:	moveq	#0,%d0
	rts

_romtag:
	.word	0x4afc
	.long	_romtag			| matchtag -> self
	.long	_inittab		| endskip -> 0x52 (InitTable)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| rt_Version
	.byte	9			| NT_LIBRARY
	.byte	0			| rt_Pri
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"fantasia.library\0"
_idstr:	.ascii	"fantasia.library 1.0\r\n\0"
_dosstr:
	.ascii	"dos.library\0"

	.even
_inittab:
	.long	0x30			| dataSize
	.long	_functab
	.long	_datatab
	.long	_initfn

_functab:
	.long	_open			| -6
	.long	_close			| -12
	.long	_expunge		| -18
	.long	_nullvec		| -24
	.long	_joydir			| -30 -> d3
	.long	_joybtn			| -36 -> d2
	.long	0xffffffff

_datatab:
	.byte	0xa0,0x0c,0x09,0x00	| byte@+0x0c = 9 (dead store)
	.byte	0x80,0x0a
	.long	_name			| long@+0x0a = ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| byte@+0x0e = 6 (lib_Flags)
	.byte	0x90,0x14
	.short	1			| word@+0x14 = lib_Version
	.byte	0x90,0x16
	.short	0			| word@+0x16 = lib_Revision
	.byte	0x80,0x18
	.long	_idstr			| long@+0x18 = lib_IdString
	.long	0			| end + pad

_initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(0x22)		| sysbase
	movel	%a0,%a5@(0x2a)		| seglist
	lea	%pc@(_dosstr),%a1
	.short	0x203c
	.long	1
	jsr	%a6@(-552)		| OpenLibrary
	movel	%d0,%a5@(0x26)		| dosbase
	.word	0x66ff,0x0000,0x0004	| bne.l +4 -> falls into next insn anyway
	movel	%a5,%d0
	moveal	%sp@+,%a5
	rts

_open:
	addqw	#1,%a6@(0x20)
	bclr	#3,%a6@(0x2e)		| private DELEXP flag
	movel	%a6,%d0
	rts

_close:
	clrl	%d0
	subqw	#1,%a6@(0x20)
	bnes	1f
	btst	#3,%a5@(0x2e)		| BUG: a5 not a6
	beqs	1f
	bsrw	_expunge
1:	rts

_expunge:
	moveml	%d1/%a5-%a6,%sp@-	| quirk: pushes d1 but restores d2
	moveal	%a6,%a5
	moveal	%a5@(0x22),%a6		| sysbase
	tstw	%a5@(0x20)
	beqw	2f
	bset	#3,%a5@(0x2e)
	clrl	%d0
	bras	3f
2:	movel	%a5@(0x2a),%d2		| seglist
	moveal	%a5,%a1
	jsr	%a6@(-252)		| Remove
	moveal	%a5@(0x26),%a1		| dosbase
	jsr	%a6@(-414)		| CloseLibrary
	clrl	%d0
	moveal	%a5,%a1
	movew	%a5@(0x10),%d0		| NegSize
	subal	%d0,%a1
	addw	%a5@(0x12),%d0		| +PosSize
	jsr	%a6@(-210)		| FreeMem
	movel	%d2,%d0
3:	moveml	%sp@+,%d2/%a5-%a6
	rts

_nullvec:
	moveq	#0,%d0
	rts

||| JOY1DAT quadrature decode -> d3 = direction index 0..8
_joydir:
	clrl	%d0
	clrl	%d3
	clrl	%d4
	clrl	%d5
	movew	0xdff00c,%d0		| JOY1DAT
	btst	#9,%d0
	bnew	_jd_horiz
	movew	0xdff00c,%d4
	movew	%d4,%d5
	lsrw	#1,%d5
	eorw	%d4,%d5			| gray->binary
	btst	#0,%d5
	bnew	_jd_dn
	btst	#8,%d4
	bnew	_jd_up
	movew	0xdff00c,%d0
	btst	#1,%d0
	bnew	_jd_d2_3
	braw	_jd_d0
_jd_dn:	movew	0xdff00c,%d0
	btst	#1,%d0
	bnew	_jd_d2_4
	.short	0x263c
	.long	5
	braw	_jd_out
_jd_d2_4:
	.short	0x263c
	.long	4
	braw	_jd_out
_jd_up:	movew	0xdff00c,%d0
	btst	#1,%d0
	bnew	_jd_d2_1
	.short	0x263c
	.long	1
	braw	_jd_out
_jd_d2_1:
	.short	0x263c
	.long	2
	braw	_jd_out
_jd_d2_3:
	.short	0x263c
	.long	3
	braw	_jd_out
_jd_horiz:
	movew	0xdff00c,%d4
	movew	%d4,%d5
	lsrw	#1,%d5
	eorw	%d4,%d5
	btst	#0,%d5
	bnew	_jd_hz2
	btst	#8,%d4
	bnew	_jd_hz1
	.short	0x263c
	.long	8
	braw	_jd_out
_jd_hz1:
	.short	0x263c
	.long	7
	braw	_jd_out
_jd_hz2:
	.short	0x263c
	.long	6
	braw	_jd_out
_jd_d0:	.short	0x263c
	.long	0
_jd_out:
	rts

||| CIAA-PRA bit7 + POTGOR bits14/12 -> d2 = button code 0..4
_joybtn:
	clrl	%d0
	clrl	%d2
	btst	#7,0xbfe001		| CIAA PRA fire/2nd btn
	beqw	_jb_1
	movew	0xdff016,%d0		| POTGOR
	btst	#14,%d0
	beqw	_jb_2
	.short	0x4ef9
	.long	_jb_t0
_jb_1:	movew	0xdff016,%d0
	btst	#14,%d0
	beqw	_jb_3
	.short	0x243c
	.long	1
	.short	0x4ef9
	.long	_jb_t4
_jb_3:	.short	0x243c
	.long	4
	.short	0x4ef9
	.long	_jb_t4
	.short	0x4ef9
	.long	_jb_t4			| dead
	.short	0x4ef9
	.long	_jb_t4			| dead
_jb_2:	movew	0xdff016,%d0
	btst	#12,%d0
	beqw	_jb_4
	.short	0x243c
	.long	2
	.short	0x4ef9
	.long	_jb_t4
_jb_4:	.short	0x4ef9
	.long	_jb_t4
	.short	0x4ef9
	.long	_jb_t4			| dead
_jb_t0:	.short	0x243c
	.long	0
_jb_t4:	rts

	.globl	_stub,_romtag,_name,_idstr,_inittab,_functab,_datatab
	.globl	_open,_close,_expunge,_nullvec,_joydir,_joybtn,_end
_end:
