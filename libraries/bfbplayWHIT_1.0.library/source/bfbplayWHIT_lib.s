	.file	"bfbplayWHIT_lib.s"
	.text

/*
**	bfbplayWHIT.library V1.0 -- AUTOINIT skeleton + interrupt tail
**	"bfbplayWHIT.library V1.0 (13.06.1996)"
**
**	Whittaker module player: tag-driven wrapper calling embedded
**	68k routines inside the loaded module image; replay ticked by
**	a CIA timer ICR interrupt -> exec Cause -> softint dispatcher.
**	dataSize 0xb2 (178), LONG functab, 13 vectors.
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
	.ascii	"bfbplayWHIT.library\0"
idstring:
	.ascii	"bfbplayWHIT.library V1.0 (13.06.1996)\015\012\0"
	.globl	_dosname
_dosname:
	.ascii	"dos.library\0"
	.globl	_cianame
_cianame:
	.ascii	"ciaa.resource\0"
	.globl	_whitname
_whitname:
	.ascii	"David Whittaker\0"	/* unused format-name remnant */
	.globl	_desc
_desc:
	.ascii	"Whittaker moduletype probably by David Whittaker.\012New CIA routines by K-P Koljonen, adapted by\012Jarkko Vatjus-Anttila.\012\0"
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
	.long	_StopModule		/* -48 modbuf+28 stop	   */
	.long	_ContModule		/* -54 resume		   */
	.long	_RetM1			/* -60 stub -> -1	   */
	.long	_RetM1			/* -66 stub -> -1	   */
	.long	_SetSubsong		/* -72			   */
	.long	_GetInfo		/* -78			   */
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
	.long	0			/* terminator		    */
	.word	0x4e71			/* trailing nop (orig)	    */

/* -------- interrupt tail ----------------------------------------- */
/* cur_sess: code-hunk global set by InitModule (never cleared --    */
/* EndModule leaves it dangling, faithful)			    */
	.globl	_cur_sess
_cur_sess:
	.long	0

/* tick dispatcher (0x208): softint code -- a1 = inner is_Data
** (CIAA_PRA, unused).  If a session is live and its running byte is
** set, calls the module image's +14 routine (modbuf = sess+2).	    */
	.globl	_tick_dispatch
_tick_dispatch:
	moveml	%d0-%d7/%a0-%a6,%sp@-
	movel	_cur_sess(%pc),%d0
	beqs	1f
	movel	%d0,%a1
	tstb	%a1@(1)			/* running byte		    */
	beqs	1f
	movel	%a1@(2),%a5		/* modbuf		    */
	jsr	%a5@(14)		/* mod+14: tick		    */
1:	moveml	%sp@+,%d0-%d7/%a0-%a6
	moveq	#0,%d0
	rts

/* CIA handler: a1 = is_Data = the inner interrupt; exec Cause(-180)
** fires it as a softint.  a6 = SysBase per the interrupt convention. */
_cause_tramp:
	jsr	%a6@(-180:W)		/* exec Cause		    */
	moveq	#0,%d0
	rts

/* outer interrupt given to AddICRVector (timer underflow) + inner
** interrupt fired by Cause (type=2 NT_INTERRUPT, pri=0).	    */
	.globl	_icr_intr
_icr_intr:
	.long	0, 0			/* ln_Succ, ln_Pred	    */
	.byte	2, 0			/* ln_Type, ln_Pri	    */
	.long	_intrname		/* ln_Name		    */
	.long	_inner_intr		/* is_Data -> inner int	    */
	.long	_cause_tramp		/* is_Code		    */
_inner_intr:
	.long	0, 0
	.byte	2, 0
	.long	0			/* name = NULL		    */
	.long	0xbfe001		/* is_Data = CIAA_PRA	    */
	.long	_tick_dispatch		/* is_Code = tick dispatch  */
_intrname:
	.ascii	"BFBPlay CIA timer.\0"

	.globl	rt_EndSkip
rt_EndSkip:
	nop
