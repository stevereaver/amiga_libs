	.file	"warpHW_lib.s"
	.text

/*
**	warpHW.library 1.0 -- "WarpUp hardware driver for
**	BlizzardPPC" (10-Apr-98).  AUTOINIT skeleton.
**
**	The original is a SAS/C far-data multi-hunk build
**	holding 68k framework + BlizzardPPC register-poke
**	routines + embedded PowerPC code.  This skeleton
**	reproduces the RomTag, InitTable, datatab and the
**	functab; the hardware-poke and PPC routines live in
**	warpHW.c / the .byte blobs below.
**
**	dataSize 0x22 -- plain struct Library.
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	rt_MatchTag
	.globl	rt_EndSkip
rt_MatchTag:
	.word	0x4afc
	.long	rt_MatchTag
	.long	rt_EndSkip
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0x01			/* rt_Version = 1	    */
	.byte	0x09			/* NT_LIBRARY		    */
	.byte	0x00
	.long	libname
	.long	idstring
	.long	rt_Init

rt_Init:
	.long	0x00000022		/* dataSize		    */
	.long	functab
	.long	datatab
	.long	initfn

/* exact InitStruct datatab: Type=9,Name,Flags=6,Ver=1,Rev=0,Id */
datatab:
	.byte	0xa0,0x08
	.byte	0x09,0x00
	.byte	0x80,0x0a
	.long	libname
	.byte	0xa0,0x0e
	.byte	0x06,0x00
	.byte	0x90,0x14
	.word	0x0001
	.byte	0x90,0x16
	.word	0x0000
	.byte	0x80,0x18
	.long	idstring
	.byte	0x00,0x00

	.globl	functab
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_start			/* -24 Reserved		   */
	.long	_whwDesc		/* -30 desc ptr		   */
	.long	_whwVer			/* -36 returns 1	   */
	.long	_whwFindIO		/* -42 find PPC io window  */
	.long	_whwPoke3		/* -48 PPC reg sequence    */
	.long	_whwPoke4		/* -54 single poke	   */
	.long	_whwPPC			/* -60 PPC routine ptr	   */
	.word	0xffff

/* INITFUNCTION -- the original stores execbase/seglist in
** far-data globals and runs a sub-init; we keep the same
** globals.							  */
	.globl	initfn
initfn:
	movel	%a6,%sp@-
	movel	%a6,%d1
	moveal	%d0,%a6			/* d0 = lib base	    */
	movel	%d1,_wh_sys		/* execbase -> global	    */
	movel	%a0,_wh_seg		/* a0 = seglist		    */
	movel	%sp@+,%a6
	rts

rt_EndSkip:
	/* nothing */

	.globl	_wh_sys
	.globl	_wh_seg
	.globl	_wh_desc
	.globl	_wh_ppc
	.even
_wh_sys:
	.long	0
_wh_seg:
	.long	0

/* driver descriptor returned by -30 (the original's
** LAB_0025 jump/desc table -- opaque to the 68k)	   */
_wh_desc:
	.long	0x00000025		/* descriptor tag	    */
	.long	0
	.long	0x000003ef		/* size			    */
	.long	0,0,0,0,0
	.long	0xffffffff
	.long	0
	.long	0xffffffff

/* embedded PowerPC code blob -- reproduced verbatim from
** the original (PPC instructions, big-endian).  This is a
** small PPC routine that pokes a BlizzardPPC register via
** lis r11,0xf6 / ori / stb and blr.			      */
_wh_ppc:
	.byte	0x4b,0xff,0xff,0xd9	/* bl	-0x24		    */
	.byte	0x94,0x21,0xff,0xe0	/* stwu r1,-0x20(r1)	    */
	.byte	0x4b,0xff,0xff,0xc5	/* bl	-0x38		    */
	.byte	0x39,0x80,0xff,0x81	/* li	r12,0xff81	    */
	.byte	0x3d,0x60,0x00,0xf6	/* lis	r11,0xf6	    */
	.byte	0x61,0x6b,0x00,0x38	/* ori	r11,r11,0x38	    */
	.byte	0x99,0x8b,0x00,0x00	/* stb	r12,0(r11)	    */
	.byte	0x4b,0xff,0xff,0xb1	/* bl	-0x4c		    */
	.byte	0x38,0x21,0x00,0x20	/* addi r1,r1,0x20	    */
	.byte	0x80,0x01,0x00,0x08	/* lwz	r0,8(r1)	    */
	.byte	0x7c,0x08,0x03,0xa6	/* mtlr r0		    */
	.byte	0x80,0x41,0x00,0x14	/* lwz	r2,0x14(r1)	    */
	.byte	0x4e,0x80,0x00,0x20	/* blr			    */

libname:
	.ascii	"warpHW.library\0"
idstring:
	.ascii	"$VER: warpHW.library 1.0 (10-Apr-98)\0"

	.end
