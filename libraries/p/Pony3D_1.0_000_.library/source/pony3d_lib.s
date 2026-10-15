/* Pony3D.library 1.0 — resident/library skeleton
 *
 * Layout mirrors the original hunks:
 *   h0+0x00  CLI bootstrap: reqtools v38 requester showing the
 *            credits text (rtAlloc/-66/-free sequence), falls
 *            back to Write(Output(), idstr, 119) via dos;
 *            always returns d0=20 (RETURN_ERROR)
 *   h0+0xc6  RomTag (AUTOINIT, ver 1, NT_LIBRARY, pri 0)
 *   h0+0x16e InitTable (dataSize 0x2a, functab, datatab, initfn)
 *   h0+0x17e absolute-long functab, 8 vectors + -1 terminator
 *   h0+0x1a2 datatab (8-bit-offset INITBYTE/WORD/LONG forms;
 *            includes a dead byte@12=9 write clobbered by the
 *            name pointer — reproduced verbatim)
 *   h0+0x1c2 LibInit / +0x1d8 LibOpen / +0x1e6 LibClose /
 *            +0x1fa LibExpunge / +0x240 reserved null stub
 *   API functions follow (C objects linked after this file).
 *
 * Private data area (dataSize = 0x2a):
 *   +34 SysBase   +38 seglist
 */
	.text

/*---------------------- CLI bootstrap -------------------------*/
/* running the file as a command shows the credits requester.   */
/* QUIRK: the dos fallback path never restores the moveml'd     */
/* registers — it returns with 56 bytes still on the stack, so  */
/* the caller's next rts jumps to the saved a6 (wild return).   */
	.globl	bootentry
bootentry:
	moveml	%d0-%a6,%sp@-
	moveal	4:l,%a6
	movel	#38,%d0
	lea	rtname,%a1		/* "reqtools.library" v38 */
	jsr	%a6@(-552)		/* OldOpenLibrary	    */
	tstl	%d0
	beqs	9f			/* no reqtools -> dos path */
	moveal	%d0,%a6
	movel	#1,%d0
	moveal	#0,%a0
	jsr	%a6@(-30)		/* alloc request object   */
	tstl	%d0
	beqs	8f			/* alloc fail -> close+dos*/
	moveal	%d0,%a3
	movel	#1,%a3@(0)
	movel	#rtitle,%a3@(12)	/* title "Pony3D.library" */
	bset	#2,%a3@(16)
	lea	rtbody,%a1		/* credits text	    */
	lea	rtokay,%a2		/* "OKAY"		    */
	moveal	#0,%a4
	moveal	#0,%a0
	jsr	%a6@(-66)		/* show requester	    */
	moveal	%a3,%a1
	jsr	%a6@(-36)		/* free request object    */
	moveal	%a6,%a1
	moveal	4:l,%a6
	jsr	%a6@(-414)		/* CloseLibrary	    */
	moveml	%sp@+,%d0-%a6
	moveq	#20,%d0			/* RETURN_ERROR	    */
	rts

8:	moveal	%a6,%a1			/* close failed reqtools   */
	moveal	4:l,%a6
	jsr	%a6@(-414)		/* CloseLibrary	    */
9:	moveal	4:l,%a6			/* dos fallback (no rest.) */
	movel	#0,%d0
	lea	dosname,%a1		/* "dos.library" v0	    */
	jsr	%a6@(-552)		/* OldOpenLibrary	    */
	tstl	%d0
	beqs	3f
	moveal	%d0,%a6
	jsr	%a6@(-60)		/* Output()		    */
	movel	%d0,%d1
	lea	idstr,%a0
	movel	%a0,%d2
	movel	idstrlen,%d3		/* 119		    */
	jsr	%a6@(-48)		/* Write(stdout,id,119)   */
	moveal	%a6,%a1
	moveal	4:l,%a6
	jsr	%a6@(-414)		/* CloseLibrary	    */
3:	moveq	#20,%d0			/* wild rts, regs on stack */
	rts

/*--------------------------- Resident -------------------------*/
	.globl	romtag
romtag:
	.word	0x4afc
	.long	romtag
	.long	endofresident
	.byte	0x80,1,9,0		/* AUTOINIT, ver 1, LIB, pri 0 */
	.long	libname
	.long	idstr
	.long	inittab

libname:
	.ascii	"Pony3D.library"
	.byte	0
idstr:
	.byte	13,10
	.ascii	" Pony3D.library 1.0 (13-Feb-2000)."
	.byte	13,10
	.ascii	" Written with the ASM-One version 1.25 by Tomasz \"Pony van Deathface\" P\353czek."
	.byte	13,10,13,10,0
	.even
idstrlen:
	.long	119

/*---------------------------- InitTable ------------------------*/
inittab:
	.long	0x2a			/* dataSize = 42	*/
	.long	functab
	.long	datatab
	.long	initfn

/*--------------------- function vector table -------------------*/
functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_LibReserved
	.long	__Rotate
	.long	__Translate
	.long	__Project
	.long	__Plot
	.long	-1

/*--------------------------- datatab ---------------------------*/
/* 8-bit-offset InitStruct forms: byte@12=9 is a dead write
 * (inside ln_Name, clobbered by the following long@10).       */
datatab:
	.byte	0xa0,0x0c,0x09,0x00	/* byte @12 = 9  (dead)  */
	.byte	0x80,0x0a
	.long	libname			/* long @10 = ln_Name   */
	.byte	0xa0,0x0e,0x06,0x00	/* byte @14 = flags 6   */
	.byte	0x90,0x14
	.word	1			/* word @20 = version   */
	.byte	0x90,0x16
	.word	0			/* word @22 = revision  */
	.byte	0x80,0x18
	.long	idstr			/* long @24 = idstring  */
	.byte	0,0,0,0

/*---------------------------- LibInit --------------------------*/
initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5			/* a5 = lib base	    */
	movel	%a0,%a5@(38)		/* seglist -> lib+38	    */
	movel	%a6,%a5@(34)		/* SysBase -> lib+34	    */
	movel	%a5,%d0
	.word	0x6000,0x0002		/* braw +2: SKIPS the a5  */
	moveal	%sp@+,%a5		/*   restore (dead code,  */
	rts					/*   +4 stack leak quirk) */

/*---------------------------- LibOpen --------------------------*/
	.globl	_LibOpen
_LibOpen:
	addqw	#1,%a6@(32)		/* opencnt++		    */
	bclr	#3,%a6@(14)		/* clear DELEXP	    */
	movel	%a6,%d0
	rts

/*--------------------------- LibClose --------------------------*/
	.globl	_LibClose
_LibClose:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	1f
	btst	#3,%a6@(14)
	beqs	1f
	bsrs	_LibExpunge
1:	rts

/*-------------------------- LibExpunge -------------------------*/
	.globl	_LibExpunge
_LibExpunge:
	moveml	%d2/%a5-%a6,%sp@-
	tstw	%a6@(32)
	beqs	1f
	bset	#3,%a6@(14)		/* defer: set DELEXP	    */
	movel	#0,%d0
	bras	2f
1:	moveal	%a6,%a5
	moveal	%a5@(34),%a6		/* SysBase		    */
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove		    */
	movel	%a5@(38),%d2		/* seglist		    */
	moveal	%a5,%a1
	movel	#0,%d0
	movew	%a5@(16),%d0
	subal	%d0,%a1			/* lib - neg	    */
	addw	%a5@(18),%d0		/* neg + pos	    */
	jsr	%a6@(-210)		/* FreeMem		    */
	movel	%d2,%d0
2:	moveml	%sp@+,%d2/%a5-%a6
	rts

/*-------------------------- reserved ---------------------------*/
	.globl	_LibReserved
_LibReserved:
	moveq	#0,%d0
	rts

/*------------------------ data section -------------------------*/
	.data
rtname:
	.ascii	"reqtools.library"
	.byte	0
	.even
rtbody:
	.ascii	"Pony3D.library version 1.0\n(13-02-2000)\nWritten with the ASM-One version 1.25\nby Tomasz <Pony van Deathface> P\353czek"
	.byte	0
	.even
rtitle:
	.ascii	"Pony3D.library"
	.byte	0
	.even
rtokay:
	.ascii	"OKAY"
	.byte	0,0
dosname:
	.ascii	"dos.library"
	.byte	0
	.even

endofresident:
