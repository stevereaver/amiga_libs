/*
 * fwfiltertype.library 3.0 -- byte-exact reconstruction.
 * SoftWood AUTOINIT library, single CODE hunk (0x6d longs).
 *
 * Quirks reproduced verbatim:
 *  - rt_EndSkip = 0x138 (initfn offset), not end of module.
 *  - rt_IdString / lib_IdString point at h0+0x39 = PAST the "$VER: "
 *    prefix, i.e. "fwfiltertype.library 3.0 (6.8.93)".
 *  - initfn and the expunge seglist helper both do a dead
 *    `subq #4,a7; move.l a6,(a7); ...; addq #4,a7` (store a6 into a
 *    scratch stack slot that is immediately discarded).
 *  - FwFilterType dead-stores its d0 arg at 0xc(a7).
 *  - RELOC32 entries stored descending (fixup.py reorders).
 */
	.text
	.globl	_dosstub
	.globl	_romtag
	.globl	_endskip
	.globl	_inittab

_dosstub:
	moveq	#0,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_initfn				/* rt_EndSkip = 0x138 (!) */
	.byte	0x80,0x03,0x09,0x00
	.long	_name
	.long	_idstr+6			/* skips "$VER: " */
	.long	_inittab

_name:	.ascii	"fwfiltertype.library"
	.byte	0
_idstr:	.ascii	"$VER: fwfiltertype.library 3.0 (6.8.93)\012"
	.byte	0
	.ascii	"Copyright \251 1993 SoftWood, Inc.\012"
	.byte	0,0

_inittab:
	.long	0x28
	.long	_functab
	.long	_dtab
	.long	_initfn

_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_stub
	.long	_FwFilterType
	.long	_stub
	.long	-1

_dtab:
	.short	0xa008
	.byte	9,0				/* ln_Type */
	.short	0x800a
	.long	_name				/* ln_Name */
	.short	0xa00e
	.byte	6,0				/* ln_Flags */
	.short	0x9014
	.short	3				/* lib_Version */
	.short	0x9016
	.short	0				/* lib_Revision */
	.short	0x8018
	.long	_idstr+6			/* lib_IdString (past "$VER: ") */
	.short	0,0

_open:
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	rts

_close:
	moveq	#0,d0
	subqw	#1,a6@(32)
	bnes	_cret
	btst	#3,a6@(14)
	beqs	_cret
	bsrw	_expunge
_cret:	rts

_expunge:
	tstw	a6@(32)
	beqw	_unlink
	bset	#3,a6@(14)
	moveq	#0,d0
	rts
_unlink:
	moveml	d2/a2/a6,sp@-
	moveal	a6,a2
	moveal	(4).l,a6			/* exec base */
	moveal	a2,a1
	jsr	a6@(-252)			/* Remove */
	.short	0x4eb9
	.long	_expseg				/* jsr abs-long (reloc site) */
	movel	d0,d2
	moveq	#0,d0
	moveal	a2,a1
	movew	a2@(16),d0
	subal	d0,a1
	addw	a2@(18),d0
	jsr	a6@(-210)			/* FreeMem */
	movel	d2,d0
	moveml	sp@+,d2/a2/a6
	rts

_stub:	moveq	#0,d0
	rts

/* initfn + seglist helper share the dead a6-stack-store pattern */
_initfn:
	subqw	#4,a7
	movel	a0,d1
	moveal	d0,a0
	movel	a6,a7@				/* dead store */
	movel	d1,a0@(0x24)			/* seglist */
	addqw	#4,a7
	rts

_alpha:	.ascii	"alpha"
	.byte	0
_fwpen:	.ascii	"fwpenpal.library"
	.byte	0,0

_expseg:
	subqw	#4,a7
	movel	a6,a7@				/* dead store */
	movel	a2@(0x24),d0			/* seglist */
	addqw	#4,a7
	rts

/* FwFilterType(a0=typefield, a1=&out, d0=arg):
 *   if typefield[0xc:0x10] == "alph" -> *out = "fwpenpal.library", ret 3
 *   else ret 0 */
_FwFilterType:
	subqw	#4,a7
	moveml	d7/a4-a5,sp@-
	moveal	a1,a4
	moveal	a0,a5
	movel	d0,a7@(0xc)			/* dead store */
	moveq	#0,d7
	lea	a5@(0xc),a0
	moveq	#4,d0
	lea	_alpha(pc),a1
_ftcmp:	moveb	a0@+,d1
	cmpb	a1@+,d1
	dbne	d0,_ftcmp
	bnes	_ftdone
	moveq	#3,d7
_ftdone:
	movel	a4,d0
	beqs	_ftret
	movew	d7,d0
	extl	d0
	subql	#3,d0
	bnes	_ftclr				/* mid-insn entry: clr.l a4@ */
	lea	_fwpen(pc),a0
	movel	a0,a4@
	.short	0x0c40				/* cmpi.w opcode prefix (dead cmp) */
_ftclr:	.short	0x4294				/* clr.l (a4): *out = 0 */
_ftret:	movew	d7,d0
	moveml	sp@+,d7/a4-a5
	addqw	#4,a7
	rts
	nop
_endskip:
