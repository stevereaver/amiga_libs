/* freeanim.library 40.9 (11.8.95) - single CODE hunk reconstruction
 * AUTOINIT library: Open/Close/Expunge + return-0 reserved vector.
 * initfn stores the seglist at lib+0x22 (used by expunge for FreeMem).
 * Leading 'moveq #-1,d0;rts' stub at h0+0 is unreferenced dead code.
 */
	.text

/* ---- h0+0x00: dead stub (returns -1) ---- */
	moveq	#-1,%d0
	rts

/* ---- RomTag @0x04 ---- */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x81,0x28,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"freeanim.library\0"	/* @0x1e */
_idstr:	.ascii	"freeanim.library 40.9 (11.8.95)\r\n"	/* @0x2f */
	.byte	0			/* NUL @0x50 */
	.short	0x4e71			/* nop @0x51 */
	.byte	0			/* pad @0x53 */

/* ---- InitTable @0x54 ---- */
_inittab:
	.long	0x26			/* dsize */
	.long	_functab
	.long	_datatab
	.long	_initfn

/* ---- functab @0x64: word-offset mode, 4 entries ---- */
_functab:
	.short	0xffff			/* word mode marker */
	.short	_open-_functab		/* 0x8c -> 0xf0 */
	.short	_close-_functab		/* 0x94 -> 0xf8 */
	.short	_expunge-_functab	/* 0x30 -> 0x94 */
	.short	_null-_functab		/* 0x2c -> 0x90 */
	.short	0xffff

/* ---- datatab @0x70: InitStruct ---- */
_datatab:
	.short	0xa008,0x0900		/* INITBYTE ln_Type = NT_LIBRARY */
	.short	0x800a
	.long	_name			/* INITLONG ln_Name */
	.short	0xa00e,0x0600		/* INITBYTE lib_Flags = LIBF_SUMUSED|LIBF_CHANGED */
	.short	0x9014,0x0028		/* INITWORD lib_Version = 40 */
	.short	0x9016,0x0009		/* INITWORD lib_Revision = 9 */
	.short	0x8018
	.long	_idstr			/* INITLONG lib_IdString */
	.short	0			/* end */

/* ---- reserved vector -24 @0x8c: nop; moveq #0,d0; rts ---- */
	.short	0x4e71			/* nop @0x8c (pad to even code start) */
_null:	moveq	#0,%d0			/* @0x90 */
	rts

/* ---- _expunge -18 @0x94 ---- */
_expunge:
	subq.w	#8,%a7
	movem.l	%d2/%d7/%a5-%a6,-(%a7)
	movea.l	%a6,%a5
	moveq	#0,%d7
	tst.w	0x20(%a5)		/* opencnt */
	bne.b	_expset
	movea.l	(4).w,%a6		/* AbsExecBase */
	movea.l	%a5,%a1
	move.l	0x22(%a5),%d7		/* seglist */
	jsr	-0xfc(%a6)		/* exec.Remove */
	moveq	#0,%d0
	move.w	0x10(%a5),%d0		/* lib.negSize */
	moveq	#0,%d1
	move.w	0x12(%a5),%d1		/* lib.posSize */
	moveq	#0,%d2
	move.w	%d0,%d2
	add.l	%d1,%d2
	movea.l	%a5,%a0
	suba.l	%d0,%a0			/* base-negSize */
	move.l	%d2,0x14(%a7)
	lea	0x10(%a7),%a5
	move.l	%a0,(%a5)
	movea.l	(%a5)+,%a1		/* mem start */
	move.l	(%a5)+,%d0		/* byteSize */
	movea.l	(4).w,%a6
	jsr	-0xd2(%a6)		/* exec.FreeMem */
	bra.b	_expdone
_expset:bset.b	#3,0xe(%a5)		/* LIBF_DELEXP */
_expdone:
	move.l	%d7,%d0
	movem.l	(%a7)+,%d2/%d7/%a5-%a6
	addq.w	#8,%a7
	rts

/* ---- _open -6 @0xf0 ---- */
_open:	addq.w	#1,0x20(%a6)		/* opencnt++ */
	move.l	%a6,%d0
	rts

/* ---- _close -12 @0xf8 ---- */
_close:	move.l	%d7,-(%a7)
	moveq	#0,%d7
	move.w	0x20(%a6),%d0
	beq.b	_clstst			/* cnt already 0 -> skip dec */
	subq.w	#1,0x20(%a6)
_clstst:tst.w	0x20(%a6)
	bne.b	_clsdone
	btst.b	#3,0xe(%a6)		/* LIBF_DELEXP */
	beq.b	_clsdone
	bsr.w	_expunge
	move.l	%d0,%d7
_clsdone:
	move.l	%d7,%d0
	move.l	(%a7)+,%d7
	rts

/* ---- _initfn @0x120: d0=lib, a0=seglist ---- */
_initfn:
	subq.w	#4,%a7
	move.l	%a0,%d1			/* seglist */
	movea.l	%d0,%a0			/* libbase */
	move.l	%a6,(%a7)		/* execbase -> dead stack slot */
	move.l	%d1,0x22(%a0)		/* lib+0x22 = seglist */
	addq.w	#4,%a7
	rts

_endskip:

	.globl	_romtag
	.end
