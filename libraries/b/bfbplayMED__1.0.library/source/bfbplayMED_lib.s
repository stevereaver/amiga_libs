	.file	"bfbplayMED_lib.s"
	.text

/*
**	bfbplayMED!.library V1.0 -- AUTOINIT skeleton
**	"bfbplayMED!.library V1.0 (28.03.1996)" by Teijo Kinnunen
**
**	MED / OctaMED module player wrapper on medplayer.library.
**	dataSize 0xb2 (178), LONG functab, 14 vectors.
**	LibInit opens dos.library (+40); EndModule/Expunge use
**	medplayer.library (+48) opened lazily by InitModule (-30).
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

/* -------- RomTag ------------------------------------------------- */
	.globl	rt_MatchTag
	.globl	rt_EndSkip
	.globl	rt_Init
rt_MatchTag:
	.word	0x4afc
	.long	rt_MatchTag
	.long	rt_EndSkip
	.byte	0x80			/* RTF_AUTOINIT	    */
	.byte	1			/* version = 1	    */
	.byte	0x09			/* NT_LIBRARY	    */
	.byte	0x00			/* pri		    */
	.long	libname
	.long	idstring
	.long	rt_Init

libname:
	.ascii	"bfbplayMED!.library\0"
	.globl	_idstring
idstring:
	.ascii	"bfbplayMED!.library V1.0 (28.03.1996)\015\012\0"
	.globl	_mpname
_mpname:
	.ascii	"medplayer.library\0"
	.globl	_dosname
_dosname:
	.ascii	"dos.library\0"
	.ascii	"MED / OctaMED\0"	/* unused, as shipped	    */
	.globl	_desc
_desc:
	.ascii	"MED, OctaMED and medplayer.library\012by Teijo Kinnunen\0"
	.even

/* -------- InitTable ---------------------------------------------- */
rt_Init:
	.long	0x000000b2		/* dataSize 0xb2 = 178	    */
	.long	functab
	.long	datatab
	.long	_LibInit

functab:
	.long	_LibOpen		/* -6			   */
	.long	_LibClose		/* -12			   */
	.long	_LibExpunge		/* -18			   */
	.long	_LibNull		/* -24			   */
	.long	_InitModule		/* -30			   */
	.long	_EndModule		/* -36			   */
	.long	_PlayModule		/* -42			   */
	.long	_StopModule		/* -48			   */
	.long	_ContModule		/* -54			   */
	.long	_RetM1			/* -60 stub -> -1	   */
	.long	_RetM1			/* -66 stub -> -1	   */
	.long	_SetVolume		/* -72			   */
	.long	_LibNull		/* -78 stub -> 0	   */
	.long	_GetDesc		/* -84			   */
	.word	0xffff
	.word	0xffff

/* -------- datatab (exact bytes) ---------------------------------- */
datatab:
	.byte	0xa0,0x08		/* INITBYTE @8 -> ln_Type   */
	.byte	0x09,0x00		/*  = 9			    */
	.byte	0x80,0x0a		/* INITLONG @0xa -> ln_Name */
	.long	libname
	.byte	0xa0,0x0e		/* INITBYTE @0xe -> flags   */
	.byte	0x06,0x00		/*  = 6			    */
	.byte	0x90,0x14		/* INITWORD @0x14 -> ver    */
	.word	0x0001			/*  = 1			    */
	.byte	0x90,0x16		/* INITWORD @0x16 -> rev    */
	.word	0x0000			/*  = 0			    */
	.byte	0x80,0x18		/* INITLONG @0x18 -> IdStr  */
	.long	idstring
	.byte	0x00,0x00		/* terminator		    */
	.even
