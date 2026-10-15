/*
 * 68040.library 46.9 -- byte-exact reconstruction.
 * Holger 'Lynxx' Hippenstiel "040/060-Loader" (21.11.2020).
 * Single CODE hunk (0x73 longs). AUTOINIT v46.
 *
 * A loader masquerading as 68040.library: init requires AFF_68040,
 * then a supervisor-mode probe installs an Illegal-Instruction
 * handler and tries `movec caar,a1` (020/030-only control reg ->
 * faults on real 040/060).  On the 040 path it LoadSegs
 * "Libs:68040mmu.library" through a base stored at lib+0x2c
 * (result of an exec LVO -0x32a call) and InitResidents the found
 * RomTag; on the 060 path it OpenLibrarys "68060.library" into
 * lib+0x30, which Open then returns instead of its own base.
 *
 * Quirks:
 *  - init returns 0 (fails) after successfully loading the 040mmu
 *    library -- the loader's job is done, exec unloads the stub.
 *  - Close/Expunge/-24 are all one shared moveq#0/rts stub: the
 *    library can never be closed or expunged.
 *  - Open clears bit3 of lib+0x22 (not ln_Flags@+0xe) and re-writes
 *    ln_Type=9 on every call.
 *  - rt_IdString/lib+0x18 point past the "$VER: " prefix.
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
	.long	_endskip
	.byte	0x80,0x2e,0x09,0x00
	.long	_name
	.long	_idstr+6			/* past "$VER: " */
	.long	_inittab

_name:	.ascii	"68040.library"
	.byte	0
_lib060:.ascii	"68060.library"
	.byte	0
_libmmu:.ascii	"Libs:68040mmu.library"
	.byte	0
_idstr:	.ascii	"$VER: 040/060-Loader.library 46.9 (21.11.2020) by Holger 'Lynxx' Hippenstiel.\012"
	.byte	0,0

_inittab:
	.long	0x34
	.long	_functab
	.long	_dtab
	.long	_initfn

_functab:
	.long	_open
	.long	_stub				/* Close  = stub */
	.long	_stub				/* Expunge= stub */
	.long	_stub				/* -24    = stub */
	.long	-1

_dtab:
	.short	0xa008
	.byte	9,0				/* ln_Type */
	.short	0x800a
	.long	_name				/* ln_Name */
	.short	0xa00e
	.byte	6,0				/* ln_Flags */
	.short	0x9014
	.short	46				/* lib_Version */
	.short	0x9016
	.short	9				/* lib_Revision */
	.short	0x8018
	.long	_idstr+6			/* lib_IdString */
	.short	0x8030
	.long	0				/* lib+0x30 = 060 lib base */
	.short	0,0

_initfn:
	moveml	d2/a2/a5-a6,sp@-
	moveal	d0,a5
	movel	a6,a5@(0x24)			/* exec base */
	movel	a0,a5@(0x28)			/* seglist */
	moveq	#4,d0
	jsr	a6@(-0x32a)			/* -> dos-ish base */
	movel	d0,a5@(0x2c)
	btst	#3,a6@(0x129)			/* AFF_68040 */
	beqb	_ifail
	movel	a5,sp@-
	lea	_super(pc),a5
	jsr	a6@(-0x1e)			/* Supervisor */
	moveal	sp@+,a5
	tstl	d0
	bneb	_i060
	lea	_libmmu(pc),a1
	bsrb	_loadseg			/* then always ret 0: */
_ifail:	moveq	#0,d0
	brab	_idone
_i060:	lea	_lib060(pc),a1
	moveq	#0,d0
	jsr	a6@(-0x228)			/* OpenLibrary */
	movel	d0,a5@(0x30)
	beqb	_idone
	movel	a5,d0
_idone:	moveml	sp@+,d2/a2/a5-a6
	rts

/* LoadSeg via the base at lib+0x2c, walk hunks for a self-consistent
 * RomTag, InitResident it (exec -0x66); UnLoadSeg on failure. */
_loadseg:
	movel	a1,d1
	moveal	a5@(0x2c),a6
	jsr	a6@(-0x96)			/* LoadSeg */
	movel	d0,d2
	beqb	_lsret
_lswalk:
	lsll	#2,d0				/* bptr -> ptr */
	beqb	_lsnone
	moveal	d0,a0
	movel	a0@(-4),d1			/* next seg */
	movel	a0@+,d0
	lsnext:	subql	#2,d1
	blsb	_lswalk
	cmpiw	#0x4afc,a0@+
	bneb	lsnext
	lea	a0@(-2),a1
	cmpal	a1@(2),a1			/* matchtag == self? */
	bneb	lsnext
	movel	a1,d0
_lsnone:
	tstl	d0
	bneb	_lsinit
	movel	d2,d1
	jsr	a6@(-0x9c)			/* UnLoadSeg */
_lsret:	moveal	a5@(0x24),a6
	rts
_lsinit:
	moveal	a5@(0x24),a6
	moveal	d0,a1
	movel	d2,d0
	jmp	a6@(-0x66)			/* InitResident */

/* supervisor probe: a0=VBR; save illegal-inst vector, install
 * handler, try movec caar,a1 (faults on 040/060 -> d0=0), restore. */
_super:
	.short	0x4e7a,0x8801			/* movec vbr,a0 */
	movel	a0@(0x10),d1			/* old Illegal vector */
	lea	_faulth(pc),a1
	movel	a1,a0@(0x10)			/* install handler */
	moveq	#1,d0
	.short	0x4e7a,0x9808			/* movec caar,a1 (faults) */
	movel	d1,a0@(0x10)			/* restore vector */
	rte
_faulth:
	addql	#4,a7@(2)			/* skip faulted movec */
	moveq	#0,d0
	rte

_open:
	addqw	#1,a6@(32)
	bclr	#3,a6@(0x22)			/* (not ln_Flags) */
	moveb	#9,a6@(8)			/* ln_Type = NT_LIBRARY */
	movel	a6@(0x30),d0			/* real 060 base? */
	bnes	_oret
	movel	a6,d0
_oret:	rts

_stub:	moveq	#0,d0
	rts

_endskip:
	.short	0
