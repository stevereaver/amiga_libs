	.file	"fastlayers_lib.s"
	.text

/*
**	fastlayers.library 40.48 -- AUTOINIT skeleton
**
**	A. Kneer / T. Abt (16.03.98).  "FastLayers": relocates the
**	layers.library module from ROM to an AllocVec'd RAM copy,
**	rewrites its internal `jmp pc@(d16)' tail-calls to
**	SwapBitsRastPortClipRect (LVO -126) into `jsr a6@(-126)'
**	vector calls, re-points every still-ROM vector at the copy,
**	then installs five custom routines from _patchtab:
**
**	  -186  CreateUpfrontHookLayer	(new cheap-layer path)
**	  -36   CreateUpfrontLayer	(wrapper -> new CUHL, hook=0)
**	  -60   MoveLayer		(wrapper -> new MoveSizeLayer)
**	  -180  MoveSizeLayer		(new, SMART->SIMPLE trick)
**	  -66   SizeLayer		(wrapper -> new MoveSizeLayer)
**
**	dataSize 0x3c, LONG-address functable, Expunge is a stub.
*/

/* -------- preamble + RomTag (packed layout, 26 bytes) --------- */
	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	rt_MatchTag
	.globl	rt_EndSkip
	.globl	rt_Init
rt_MatchTag:
	.word	0x4afc			/* UWORD	rt_MatchWord   */
	.long	rt_MatchTag		/* APTR		rt_MatchTag    */
	.long	rt_EndSkip		/* APTR		rt_EndSkip     */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0x28			/* rt_Version = 40	    */
	.byte	0x09			/* rt_Type    = NT_LIBRARY  */
	.byte	0x00			/* rt_Pri		    */
	.long	libname			/* rt_Name		    */
	.long	idstring		/* rt_IdString		    */
	.long	rt_Init			/* rt_Init -> InitTable	    */

/* -------- strings --------------------------------------------- */
	.byte	0			/* pad byte, as original    */
verstring:
	.ascii	"$VER: fastlayers.library 40.48 (16.03.98) \2511996 A.Kneer T.Abt\015\012\0"
	.globl	_idstring
idstring:
	.ascii	"fastlayers.library 40.48 (16.03.98)\015\012\0"
	.globl	_libname
libname:
	.ascii	"fastlayers.library\0"
	.globl	_gfxname
_gfxname:
	.ascii	"graphics.library\0"
	.globl	_utyname
_utyname:
	.ascii	"utility.library\0"
	.globl	_layname
_layname:
	.ascii	"layers.library\0"
	.even

/* -------- fastlayers library base slot (hunk0+0xc8) ------------ */
/*	INIT stores the library base here; the patched layers     */
/*	routines read it back to find the fastlayers base (and    */
/*	through it GfxBase).				       */
	.globl	_flbase
_flbase:
	.long	0

/* -------- InitTable ------------------------------------------- */
rt_Init:
	.long	0x0000003c		/* dataSize 0x3c = 60	    */
	.long	functab			/* funcTable (LONG addrs)    */
	.long	datatab			/* initDataTable	    */
	.long	_LibInit		/* initRoutine		    */

/* -------- function table (4 long-address vectors) ------------- */
/*	Open, Close, Expunge, and the reserved vector all land    */
/*	on working stubs; the real work happens in LibInit.       */
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge (stub)	   */
	.long	_LibExpunge		/* -24 Reserved -> stub	   */
	.word	0xffff
	.word	0xffff

/* -------- InitStruct DATATABLE (exact bytes) ------------------ */
/*	a008 09 / a009 b0 / 800a libname / a00e 06 / 9014 0028 /  */
/*	9016 0030 / 8018 idstring / 0000			   */
datatab:
	.byte	0xa0,0x08		/* INITBYTE @ 8	-> ln_Type  */
	.byte	0x09,0x00		/*  = 9 (NT_LIBRARY)	    */
	.byte	0xa0,0x09		/* INITBYTE @ 9	-> ln_Pri   */
	.byte	0xb0,0x00		/*  = 0xb0 (-80, quirk)	    */
	.byte	0x80,0x0a		/* INITLONG @ 0xa -> ln_Name */
	.long	libname
	.byte	0xa0,0x0e		/* INITBYTE @ 0xe -> lib_Flags*/
	.byte	0x06,0x00		/*  = 6 (SUMUSED|CHANGED)    */
	.byte	0x90,0x14		/* INITWORD @ 0x14 -> version */
	.word	0x0028			/*  = 40			    */
	.byte	0x90,0x16		/* INITWORD @ 0x16 -> revision*/
	.word	0x0030			/*  = 48			    */
	.byte	0x80,0x18		/* INITLONG @ 0x18 -> IdString*/
	.long	idstring
	.byte	0x00,0x00		/* terminator		    */

/* -------- patch table ----------------------------------------- */
/*	Five {lvo, newfunc, saved} entries, terminated by lvo=-1. */
/*	LibInit SetFunction()s each lvo to newfunc and stores the */
/*	returned old routine in .saved; the new routines call the */
/*	originals back through these slots.  In the shipped       */
/*	binary the table sits at hunk0+0x22a.		       */
	.globl	_patchtab
_patchtab:
	.long	-186			/* CreateUpfrontHookLayer   */
	.long	_NewCreateUpfrontHookLayer
	.long	0
	.long	-36			/* CreateUpfrontLayer	   */
	.long	_NewCreateUpfrontLayer
	.long	0
	.long	-60			/* MoveLayer		   */
	.long	_NewMoveLayer
	.long	0
	.long	-180			/* MoveSizeLayer	   */
	.long	_NewMoveSizeLayer
	.long	0
	.long	-66			/* SizeLayer		   */
	.long	_NewSizeLayer
	.long	0
	.long	-1			/* terminator		   */

rt_EndSkip:
	/* nothing */
