	.file	"mm_lib.s"
	.text

/*
**	memorymanage.library 1.01 -- AUTOINIT skeleton + supervisor thunks
**
**	  0x000  _start: moveq #-1,d0 / rts   (LibOpen wrap lands here)
**	  0x004  RomTag 0x4afc AUTOINIT v1, rt_EndSkip -> _start
**	  0x01e  init table: dataSize 0x53 / functab / datatab=0 / LibInit
**	  0x02e  functab: 11 x DC.L absolute pointers + ffffffff
**	  0x652  "memorymanage.library"
**	  0x66c  "$VER:memorymanage 1.01 (c) 2000"
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

/* -------- RomTag ------------------------------------------------- */
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_start			/* rt_EndSkip -> stub	    */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	0x09			/* NT_LIBRARY		    */
	.byte	0x00			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

/* -------- init table --------------------------------------------- */
_inittab:
	.long	0x00000053		/* dataSize		    */
	.long	_functab
	.long	0			/* no datatab		    */
	.long	_LibInit

_functab:
	.long	_LibOpen		/* -6			   */
	.long	_LibClose		/* -12			   */
	.long	_LibExpunge		/* -18			   */
	.long	_LibNull		/* -24			   */
	.long	_MMUAttach		/* -30			   */
	.long	_MMUDetach		/* -36			   */
	.long	_MMUMap			/* -42			   */
	.long	_MMUMapIdentity		/* -48			   */
	.long	_MMUReadRegs		/* -54			   */
	.long	_MMUWriteRegs		/* -60			   */
	.long	_MMUTranslate		/* -66			   */
	.word	0xffff
	.word	0xffff

/* -------- strings ------------------------------------------------ */
_libname:
	.ascii	"memorymanage.library"
	.byte	0
_idstr:
	.ascii	"$VER:memorymanage 1.01 (c) 2000"
	.byte	0

/* -------- MMU register profiles (28B each, patched at attach) ----- */
/* {URP, SRP, DTT0, DTT1, ITT0, ITT1, TC.w} -- TTRs 0x00ff4000 are
** disabled entries; TC 0x8000 = enable, 4KB pages.  +4/+12 get the
** FreeVec return patched in at attach (quirk, see okf).		    */
	.globl	_prof_att
_prof_att:
	.long	0, 0
	.long	0x00ff4000, 0x00ff4000, 0x00ff4000, 0x00ff4000
	.word	0x8000
	.globl	_prof_det
_prof_det:
	.long	0, 0
	.long	0x00ff4000, 0x00ff4000, 0x00ff4000, 0x00ff4000
	.word	0x8000

/* -------- supervisor thunks -------------------------------------- */
/* run under Supervisor(): a0 = register block			    */
	.globl	_sv_loadregs
_sv_loadregs:
	movel	%a0@+,%d0
	.word	0x4e7b,0x0806		/* movec %d0,%urp	    */
	movel	%a0@+,%d0
	.word	0x4e7b,0x0807		/* movec %d0,%srp	    */
	movel	%a0@+,%d0
	.word	0x4e7b,0x0006		/* movec %d0,%dtt0	    */
	movel	%a0@+,%d0
	.word	0x4e7b,0x0007		/* movec %d0,%dtt1	    */
	movel	%a0@+,%d0
	.word	0x4e7b,0x0004		/* movec %d0,%itt0	    */
	movel	%a0@+,%d0
	.word	0x4e7b,0x0005		/* movec %d0,%itt1	    */
	movew	%a0@,%d0
	.word	0x4e7b,0x0003		/* movec %d0,%tc	    */
	.word	0xf518			/* pflusha		    */
	rte

	.globl	_sv_readregs
_sv_readregs:
	.word	0x4e7a,0x0806		/* movec %urp,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0807		/* movec %srp,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0006		/* movec %dtt0,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0007		/* movec %dtt1,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0004		/* movec %itt0,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0005		/* movec %itt1,%d0	    */
	movel	%d0,%a0@+
	.word	0x4e7a,0x0003		/* movec %tc,%d0	    */
	movew	%d0,%a0@+
	.word	0x4e7a,0x0805		/* movec %mmusr,%d0	    */
	movew	%d0,%a0@
	rte

	.globl	_sv_ptest
_sv_ptest:
	moveq	#1,%d0
	.word	0x4e7b,0x0001		/* movec %d0,%dfc	    */
	.word	0xf548			/* ptest (%a0)		    */
	.word	0x4e7a,0x0805		/* movec %mmusr,%d0	    */
	rte
