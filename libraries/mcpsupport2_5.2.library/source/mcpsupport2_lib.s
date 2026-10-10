	.file	"mcpsupport2_lib.s"
	.text

/*
**	mcpsupport2.library 5.2 -- AUTOINIT skeleton
**	(c)1995-1998 by ALiENDESiGN
**
**	RomTag, InitTable (LONG FUNCTABLE, exact InitStruct
**	datatab), INITFUNCTION (AllocMem 12 for the aux block,
**	then OpenLibrary dos v37 / utility v36 into it).
**	dataSize 0x22 -- plain struct Library, no extra fields.
*/

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

	.globl	rt_MatchTag
	.globl	rt_EndSkip
rt_MatchTag:
	.word	0x4afc			/* UWORD	rt_MatchWord   */
	.long	rt_MatchTag		/* APTR		rt_MatchTag    */
	.long	rt_EndSkip		/* APTR		rt_EndSkip     */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	0x05			/* rt_Version = 5	    */
	.byte	0x09			/* rt_Type    = NT_LIBRARY  */
	.byte	0x00			/* rt_Pri		    */
	.long	libname			/* rt_Name		    */
	.long	idstring		/* rt_IdString		    */
	.long	rt_Init			/* rt_Init -> InitTable	    */

rt_Init:
	.long	0x00000022		/* dataSize (struct Lib)    */
	.long	functab			/* funcTable (LONG addr)    */
	.long	datatab			/* initDataTable	    */
	.long	initfn			/* initRoutine		    */

/* exact InitStruct datatab:  ln_Type=9, ln_Name=libname,
** lib_Flags=6, Ver=5, Rev=2, IdString=idstring		    */
datatab:
	.byte	0xa0,0x08		/* INITBYTE @ 8  -> ln_Type */
	.byte	0x09,0x00		/*  = 9 (NT_LIBRARY)	    */
	.byte	0x80,0x0a		/* INITLONG @ 0xa -> ln_Name*/
	.long	libname
	.byte	0xa0,0x0e		/* INITBYTE @ 0xe -> flags  */
	.byte	0x06,0x00		/*  = 6			    */
	.byte	0x90,0x14		/* INITWORD @ 0x14 -> ver   */
	.word	0x0005			/*  = 5			    */
	.byte	0x90,0x16		/* INITWORD @ 0x16 -> rev   */
	.word	0x0000			/*  = 0 (reports 5.0)	    */
	.byte	0x80,0x18		/* INITLONG @ 0x18 -> idstr */
	.long	idstring
	.byte	0x00,0x00		/* terminator		    */

/* 8 long-address vectors + 0xffff terminator		   */
	.globl	functab
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_start			/* -24 Reserved -> stub	   */
	.long	_mcpLoadFile		/* -30 load file	   */
	.long	_mcpCmdNameBuf		/* -36 cmdname -> buffer   */
	.long	_mcpCmdName		/* -42 cmdname -> ptr	   */
	.long	_mcpMatch		/* -48 wildcard match	   */
	.word	0xffff			/* end			   */

/* INITFUNCTION -- allocate the 12-byte aux block and open
** dos.library v37 / utility.library v36 into it.	      */
	.globl	initfn
initfn:
	moveml	%d0-%d7/%a0-%a6,%sp@-
	moveal	%a0,%a2			/* a0 = seglist		    */
	moveal	0x4,%a6			/* execbase		    */
	movel	#12,%d0			/* AllocMem(12, MEMF_...)  */
	movel	#0x00010001,%d1
	jsr	%a6@(-198)
	movel	%d0,_auxblock
	beqs	1f
	moveal	%d0,%a5
	movel	%a2,%a5@		/* aux[0] = seglist	    */
	moveq	#37,%d0			/* dos.library v37	    */
	lea	dosname,%a1
	jsr	%a6@(-552)
	movel	%d0,%a5@(4)
	beqs	1f
	moveq	#36,%d0			/* utility.library v36	    */
	lea	utilname,%a1
	jsr	%a6@(-552)
	movel	%d0,%a5@(8)
	beqs	1f
	moveml	%sp@+,%d0-%d7/%a0-%a6
	rts
1:	moveml	%sp@+,%d0-%d7/%a0-%a6
	moveq	#0,%d0
	rts

	.globl	_auxblock
	.even
_auxblock:
	.long	0

rt_EndSkip:
	/* nothing */

libname:
	.ascii	"mcpsupport2.library\0"
idstring:
	.ascii	"$VER: MCPSupport2.library 5.0 (14.10.98) \n(c)1995-1998 by ALiENDESiGN\0"
dosname:
	.ascii	"dos.library\0"
utilname:
	.ascii	"utility.library\0"

	.end
