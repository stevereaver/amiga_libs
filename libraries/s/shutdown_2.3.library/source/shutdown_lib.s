	.file	"shutdown_lib.s"
	.text

/*
**	shutdown.library 2.3 -- AUTOINIT skeleton
**
**	RomTag, InitTable (dataSize 0xe0, LONG FUNCTABLE,
**	exact InitStruct datatab, INITFUNCTION storing
**	execbase@36 / seglist@44).  The original is a SAS/C
**	far-data manual-init build; this skeleton uses the
**	standard AUTOINIT layout for a functional equivalent.
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
	.byte	0x02			/* ver 2		    */
	.byte	0x09			/* NT_LIBRARY		    */
	.byte	0x00
	.long	libname
	.long	idstring
	.long	rt_Init

rt_Init:
	.long	0x000000e0		/* dataSize 0xe0	    */
	.long	functab
	.long	datatab
	.long	initfn

datatab:
	.byte	0xa0,0x08		/* ln_Type = 9	    */
	.byte	0x09,0x00
	.byte	0x80,0x0a		/* ln_Name	    */
	.long	libname
	.byte	0xa0,0x0e		/* lib_Flags = 6    */
	.byte	0x06,0x00
	.byte	0x90,0x14		/* version = 2	    */
	.word	0x0002
	.byte	0x90,0x16		/* revision = 3    */
	.word	0x0003
	.byte	0x80,0x18		/* idstring	    */
	.long	idstring
	.byte	0x00,0x00

	.globl	functab
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_start			/* -24 Reserved		   */
	.long	_sdStub			/* -30 stub		   */
	.long	_RegisterShutdown	/* -36 register		   */
	.long	_UnregisterShutdown	/* -42 unregister	   */
	.long	_FireShutdown		/* -48 fire		   */
	.word	0xffff

initfn:
	movel	%a6,%d1
	moveal	%d0,%a6			/* d0 = lib base	    */
	movel	%d1,%a6@(36)		/* execbase @36	    */
	movel	%a0,%a6@(44)		/* seglist @44	    */
	movel	%a6,%d0
	rts

rt_EndSkip:
	/* nothing */

libname:
	.ascii	"shutdown.library\0"
idstring:
	.ascii	"shutdown.library 2.3\0"

	.end
