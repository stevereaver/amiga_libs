|||
|||	ksort_lib.s -- resident/AutoInit structure and library
|||	lifecycle for ksort.library 34.1 (01 Jan 93).
|||
|||	Reconstructed layout (original hunk0 offsets):
|||	  0x00  entry stub (moveq #0,d0; rts)
|||	  0x04  RomTag 0x4afc / AUTOINIT / ver 34 / pri 1
|||	  0x1e  "ksort.library"        0x2c  id string
|||	  0x4d  "dos.library"          0x59  "intuition.library"
|||	  0x6b  "graphics.library"
|||	  0x7c  InitTable {dataSize 0x2a, functab@0x8c,
|||	        datatab@0xbc, initfunc@0xdc}
|||	  0x8c  absolute-long functab, 11 vectors + -1
|||	  0xbc  data table (type/name/flags/ver/rev/idstr)
|||	  0xdc  LibInit       0x150 LibOpen   0x15e LibClose
|||	  0x172 LibExpunge    0x214 null stub (-24)
|||
|||	The sort workers and the stricmp comparator live in hunk2
|||	and hunk3 of the original; here they are the C file.
|||
|||	Static block (original hunk1, 64B BSS):
|||	  +0  SysBase   +4  DOSBase   +8  IntuitionBase  +12 GfxBase
|||	The three library bases are opened by LibInit and only
|||	ever used to be closed again by LibExpunge -- vestigial
|||	SAS/C framework boilerplate.
|||

	.section .text

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_inittab
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0x22			/* version 34		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	1			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.globl	_inittab
_inittab:
	.long	0x2a			/* dataSize 42: Library+2   */
	.long	_functab
	.long	_datatab
	.long	_LibInit

/* absolute-longword function table, 11 vectors		    */
	.globl	_functab
_functab:
	.long	_LibOpen		/* -6			    */
	.long	_LibClose		/* -12			    */
	.long	_LibExpunge		/* -18			    */
	.long	_libret0		/* -24 null stub	    */
	.long	_KSortI8		/* -30 signed bytes	    */
	.long	_KSortU8		/* -36 unsigned bytes	    */
	.long	_KSortI16		/* -42 signed words	    */
	.long	_KSortU16		/* -48 unsigned words	    */
	.long	_KSortI32		/* -54 signed longs	    */
	.long	_KSortU32		/* -60 unsigned longs	    */
	.long	_KSortStr		/* -66 string pointers	    */
	.long	-1			/* terminator		    */

	.globl	_datatab
_datatab:
	.byte	0xa0,0x08		/* ln_Type = 9		    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name		    */
	.long	_libname
	.byte	0xa0,0x0e		/* lib_Flags = 6	    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 34	    */
	.word	0x0022
	.byte	0x90,0x16		/* revision = 1	    */
	.word	0x0001
	.byte	0x80,0x18		/* idstring		    */
	.long	_idstr
	.byte	0x00,0x00,0x00,0x00	/* end			    */

/* ------------------------------------------------------------ */
/* LibInit -- d0 = libbase, a0 = seglist, a6 = ExecBase.	   */
/* Stores SysBase and the seglist into the library data area,   */
/* parks ExecBase in the static block and opens the three       */
/* framework libraries (no error checking, bases unused).       */
/* ------------------------------------------------------------ */
	.even
	.globl	_LibInit
_LibInit:
	moveml	%a4/%a5,%sp@-
	lea	_gdata,%a4		/* a4 = static block	    */
	moveal	%d0,%a5			/* a5 = libbase		    */
	movel	%a6,%a4@(0)		/* gdata[0] = SysBase	    */
	movel	%a6,%a5@(38)		/* lib+38 = SysBase	    */
	movel	%a0,%a5@(34)		/* lib+34 = seglist	    */
	lea	_dosname,%a1
	moveq	#0,%d0
	movel	%a6,%sp@-
	moveal	%a4@(0),%a6		/* a6 = SysBase		    */
	jsr	%a6@(-552)		/* OpenLibrary("dos",0)	    */
	moveal	%sp@+,%a6
	movel	%d0,%a4@(4)		/* DOSBase		    */
	lea	_intname,%a1
	moveq	#0,%d0
	movel	%a6,%sp@-
	moveal	%a4@(0),%a6
	jsr	%a6@(-552)		/* OpenLibrary("intuition") */
	moveal	%sp@+,%a6
	movel	%d0,%a4@(8)		/* IntuitionBase	    */
	lea	_gfxname,%a1
	moveq	#0,%d0
	movel	%a6,%sp@-
	moveal	%a4@(0),%a6
	jsr	%a6@(-552)		/* OpenLibrary("graphics")  */
	moveal	%sp@+,%a6
	movel	%d0,%a4@(12)		/* GfxBase		    */
	movel	%a5,%d0			/* return libbase	    */
	moveml	%sp@+,%a4/%a5
	rts

/* ------------------------------------------------------------ */
/* LibOpen -- a6 = libbase.					   */
/* ------------------------------------------------------------ */
	.even
	.globl	_LibOpen
_LibOpen:
	addqw	#1,%a6@(32)		/* lib_OpenCnt++	    */
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP	    */
	movel	%a6,%d0
	rts

/* ------------------------------------------------------------ */
/* LibClose -- a6 = libbase.					   */
/* ------------------------------------------------------------ */
	.even
	.globl	_LibClose
_LibClose:
	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* lib_OpenCnt--	    */
	bnes	1f
	btst	#3,%a6@(14)		/* LIBF_DELEXP?	    */
	beqs	1f
	bsrs	_LibExpunge
1:	rts

/* ------------------------------------------------------------ */
/* LibExpunge -- a6 = libbase.					   */
/*								   */
/* Shipped quirks reproduced verbatim:				   */
/*   - the open-count test reads 32(a5) -- the CALLER's a5,	   */
/*     never loaded: a wild read.  Deferred expunge fires only   */
/*     if that random word is nonzero.			   */
/*   - the "close libraries" calls pass the NAME STRINGS in a1   */
/*     (a1 = "dos.library", not the opened base): the original   */
/*     literally executes CloseLibrary("dos.library").	   */
/*   - after the closes it stores the seglist to ABSOLUTE	   */
/*     ADDRESS 0 (a missing relocation in the shipped hunk),	   */
/*     and the d0 result is whatever the last CloseLibrary	   */
/*     returned -- never the seglist.				   */
/* ------------------------------------------------------------ */
	.even
	.globl	_LibExpunge
_LibExpunge:
	moveml	%d2/%a2/%a6,%sp@-
	tstw	%a5@(32)		/* BUG: caller's a5, wild  */
	beqs	1f
	bset	#3,%a6@(14)		/* LIBF_DELEXP on the lib  */
	moveq	#0,%d0
	braw	2f
1:	moveal	%a6,%a2			/* a2 = libbase		    */
	moveal	%a2,%a1
	movel	%a6,%sp@-
	moveal	_gdata,%a6		/* SysBase		    */
	jsr	%a6@(-252)		/* Remove(lib)		    */
	moveal	%sp@+,%a6
	movel	%a2@(34),%d2		/* d2 = seglist		    */
	moveal	%a2,%a1
	moveq	#0,%d0
	movew	%a2@(16),%d0		/* NegSize		    */
	subal	%d0,%a1
	addw	%a2@(18),%d0		/* + PosSize		    */
	movel	%a6,%sp@-
	moveal	_gdata,%a6
	jsr	%a6@(-210)		/* FreeMem		    */
	moveal	%sp@+,%a6
	lea	_dosname,%a1
	movel	%a6,%sp@-
	moveal	_gdata,%a6
	jsr	%a6@(-414)		/* CloseLibrary("dos")	    */
	moveal	%sp@+,%a6
	movel	%d0,_gdata+4		/* overwrite DOSBase slot  */
	lea	_intname,%a1
	movel	%a6,%sp@-
	moveal	_gdata,%a6
	jsr	%a6@(-414)		/* CloseLibrary("int")	    */
	moveal	%sp@+,%a6
	movel	%d0,_gdata+8
	lea	_gfxname,%a1
	movel	%a6,%sp@-
	moveal	_gdata,%a6
	jsr	%a6@(-414)		/* CloseLibrary("gfx")	    */
	moveal	%sp@+,%a6
	movel	%d0,_gdata+12
	movel	%d2,0x0			/* BUG: wild write to 0    */
2:	moveml	%sp@+,%d2/%a2/%a6
	rts

/* null stub (-24 vector)					    */
	.even
	.globl	_libret0
_libret0:
	moveq	#0,%d0
	rts

/* ------------------------------------------------------------ */
/* strings								    */
/* ------------------------------------------------------------ */

	.globl	_libname
_libname:
	.ascii	"ksort.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"ksort.library 34.1 (01 Jan 93)"
	.byte	13,10,0
_dosname:
	.ascii	"dos.library"
	.byte	0
_intname:
	.ascii	"intuition.library"
	.byte	0
_gfxname:
	.ascii	"graphics.library"
	.byte	0
	.even

/* ------------------------------------------------------------ */
/* static block: original hunk1, 64 bytes BSS			    */
/* ------------------------------------------------------------ */

	.section .bss
	.globl	_gdata
_gdata:
	.space	64			/* +0 SysBase, +4 DOS,    */
					/* +8 Intuition, +12 Gfx  */

	.section .text
	.globl	_endmodule
_endmodule:
