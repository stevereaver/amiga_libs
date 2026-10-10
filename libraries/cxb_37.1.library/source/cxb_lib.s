	.file	"cxb_lib.s"
	.text

/*
**	cxb.library 37.1 -- AUTOINIT skeleton
**
**	RomTag, InitTable (word-offset FUNCTABLE, exact
**	InitStruct DATATABLE, INITFUNCTION that stores
**	execbase/seglist and clears the context table),
**	plus the static "(C) 1998 Captain Crossbones"
**	EasyStruct used by cxbRequest.
**
**	dataSize 0x430, 8 long-address vectors.
*/

/* -------- RomTag ---------------------------------------------- */
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
	.byte	0x25			/* rt_Version = 37	    */
	.byte	0x09			/* rt_Type    = NT_LIBRARY  */
	.byte	0x00			/* rt_Pri		    */
	.long	libname			/* rt_Name		    */
	.long	idstring		/* rt_IdString		    */
	.long	rt_Init			/* rt_Init -> InitTable	    */

/* -------- InitTable ------------------------------------------- */
	/* ULONG dataSize, APTR funcTable, APTR initDataTable,
	** APTR initRoutine					 */
rt_Init:
	.long	0x00000430		/* dataSize		    */
	.long	functab			/* funcTable (LONG addr)    */
	.long	datatab			/* initDataTable	    */
	.long	initfn			/* initRoutine		    */

/* -------- InitStruct DATATABLE (exact bytes from the original) -- */
/* a008 09 / 800a libname / a00e 06 / 9014 0025 / 9016 0001 /     */
/* 8018 libname / 0000 terminator				       */
datatab:
	.byte	0xa0,0x08		/* INITBYTE @ 8	-> ln_Type  */
	.byte	0x09,0x00		/*  = 9 (NT_LIBRARY)	    */
	.byte	0x80,0x0a		/* INITLONG @ 0xa -> ln_Name */
	.long	libname
	.byte	0xa0,0x0e		/* INITBYTE @ 0xe -> lib_Flags*/
	.byte	0x06,0x00		/*  = 6 (SUMUSED|CHANGED)    */
	.byte	0x90,0x14		/* INITWORD @ 0x14 -> version */
	.word	0x0025			/*  = 37			    */
	.byte	0x90,0x16		/* INITWORD @ 0x16 -> revision*/
	.word	0x0001			/*  = 1			    */
	.byte	0x80,0x18		/* INITLONG @ 0x18 -> IdString*/
	.long	libname			/*  = libname (quirk: not the */
					/*    $VER string)	    */
	.byte	0x00,0x00		/* terminator		    */
	.word	0x000c			/* pad			    */

/* -------- function table (8 long-address vectors) ------------- */
	.globl	functab
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_LibReserved		/* -24 Reserved		   */
	.long	_cxbFileInfo		/* -30 fileinfo		   */
	.long	_cxbMult		/* -36 mult		   */
	.long	_cxbMult209		/* -42 mult209		   */
	.long	_cxbRequest		/* -48 request		   */
	.word	0xffff			/* end			   */
	.word	0xffff			/* end			   */

/* -------- INITFUNCTION ---------------------------------------- */
/*	MOVE.L A6,36(A5); MOVE.L A0,44(A5); clear 128 longs @48   */
initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5			/* d0 = new library base    */
	movel	%a6,%a5@(36)		/* store execbase @36	    */
	movel	%a0,%a5@(44)		/* store seglist  @44	    */
	lea	%a5@(48),%a0		/* context table	    */
	moveq	#127,%d0
1:	clrl	%a0@+			/* clear 128 longs (512B)   */
	dbf	%d0,1b			/*   - only half the table  */
	movel	%a5,%d0
	moveal	%sp@+,%a5
	rts

rt_EndSkip:
	/* nothing */

/* -------- __mulsi3 -- 32x32 -> low 32, 16-bit mulu decomposition */
/*	a*b mod 2^32 = (a_lo*b_lo) + ((a_hi*b_lo + a_lo*b_hi)<<16) */
	.globl	___mulsi3
___mulsi3:
	movel	%d2,%sp@-
	movel	%d3,%sp@-
	movel	%sp@(12),%d0		/* a			    */
	movel	%sp@(16),%d1		/* b			    */
	movel	%d0,%d2
	swap	%d2			/* a_hi			    */
	mulu	%d1,%d2			/* a_hi * b_lo		    */
	movel	%d1,%d3
	swap	%d3			/* b_hi			    */
	mulu	%d0,%d3			/* a_lo * b_hi		    */
	addl	%d3,%d2			/* a_hi*b_lo + a_lo*b_hi    */
	swap	%d2			/* <<16			    */
	clrw	%d2
	mulu	%d1,%d0			/* a_lo * b_lo		    */
	addl	%d2,%d0
	movel	%sp@+,%d3
	movel	%sp@+,%d2
	rts

/* -------- static data ----------------------------------------- */
	.globl	_cxbeasy
	.even
_cxbeasy:
	/* struct EasyStruct:
	**  es_StructSize(2), es_Level(2), es_Flags(4),
	**  es_Title(4), es_TextFormat(4), es_GadgetFormat(4)  */
	.word	20			/* sizeof struct	    */
	.word	0			/* level		    */
	.long	0			/* flags		    */
	.long	cxbtitle		/* title		    */
	.long	cxbtext			/* body			    */
	.long	cxbgadget		/* gadget		    */

	.globl	_libname
libname:
	.ascii	"cxb.library\0"
	.globl	_idstring
idstring:
	.ascii	"cxb.library 37.1 (20.01.98)\0"
cxbtitle:
	.ascii	"cxb\0"
cxbtext:
	.ascii	"cxb library request\0"
cxbgadget:
	/* "(C) 1998 by Captain Crossbones" - the original gadget
	** text; kept as the requester body label		    */
	.ascii	"(C) 1998 by Captain Crossbones\0"

	.end
