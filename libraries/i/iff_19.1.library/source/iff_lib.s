/* iff.library 19.1 — resident/library skeleton
 *
 * Layout mirrors the original hunk:
 *   +0x00  CLI bootstrap ('CHW!' sig; prints ID string, returns WARN)
 *   +0x34  RomTag (AUTOINIT, ver 19, NT_LIBRARY, pri 0, ENDSKIP→API start)
 *   +0x4e  "iff.library" / ID string / "dos.library"
 *   +0x94  InitTable (dataSize 60, functab, datatab, initfn)
 *   +0xa4  absolute-long functab, 16 vectors + -1 terminator
 *   +0xe8  datatab (8-bit-offset INITBYTE/WORD/LONG forms)
 *   +0x108 LibInit: stores ExecBase, OldOpenLibrary dos, NEWLISTs
 *   +0x138 LibOpen / LibClose / LibExpunge
 *   +0x1fc reserved rts stub, +0x1fe pad (ENDSKIP)
 *   API code follows (C objects linked after this file).
 *
 * Library private data area (dataSize = 60):
 *   +34 ExecBase  +38 DOSBase  +42 seglist  +46 MinList of
 *   per-task OpenNodes.  lib_Flags bit 3 (+14) doubles as the
 *   delayed-expunge marker (the real LIBF_DELEXP bit).
 */
	.text

/*------------------------- CLI bootstrap -------------------------*/
boot:
	bras	1f
	.ascii	"CHW!"
1:	lea	dosname(%pc),%a1
	moveal	4:w,%a6
	jsr	%a6@(-408)		/* OldOpenLibrary(dos)	    */
	moveal	%d0,%a6
	jsr	%a6@(-60)		/* Output()		    */
	movel	%d0,%d1
	lea	idstr(%pc),%a0
	movel	%a0,%d2
	moveq	#45,%d3
	jsr	%a6@(-48)		/* Write(stdout,idstr,45)   */
	moveal	%a6,%a1
	moveal	4:w,%a6
	jsr	%a6@(-414)		/* CloseLibrary(dos)	    */
	moveq	#5,%d0			/* RETURN_WARN		    */
	rts

/*--------------------------- Resident ----------------------------*/
	.globl	romtag
romtag:
	.word	0x4afc
	.long	romtag
	.long	endofresident		/* ENDSKIP → API code start */
	.byte	0x80,19,9,0		/* AUTOINIT, ver 19, LIB, pri 0 */
	.long	libname
	.long	idstr
	.long	inittab

libname:
	.ascii	"iff.library"
	.byte	0
idstr:
	.ascii	"IFF 19.1 (09-Oct-1990) by Christian A. Weber\n"
	.byte	0
dosname:
	.ascii	"dos.library"
	.byte	0

/*---------------------------- InitTable --------------------------*/
inittab:
	.long	0x3c			/* dataSize = 60	*/
	.long	functab
	.long	datatab
	.long	initfn

/*--------------------- function vector table ---------------------*/
functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_LibReserved
	.long	_OpenIFF
	.long	_CloseIFF
	.long	_FindChunk
	.long	_GetBMHD
	.long	_GetColorTab
	.long	_DecodePic
	.long	_SaveBitMap
	.long	_SaveClip
	.long	_IFFError
	.long	_GetViewModes
	.long	_NewOpenIFF
	.long	_DecodeAnim
	.long	-1			/* table terminator	*/

/*---------------------------- datatab ----------------------------*/
datatab:
	.byte	0xa0,8,9,0		/* INITBYTE off8  ln_Type (+even pad)   */
	.byte	0x80,10			/* INITLONG off10 ln_Name		   */
	.long	libname
	.byte	0xa0,14,6,0		/* INITBYTE off14 lib_Flags (+pad)	   */
	.byte	0x90,20			/* INITWORD off20 lib_Version = 19	   */
	.word	19
	.byte	0x90,22			/* INITWORD off22 lib_Revision = 1	   */
	.word	1
	.byte	0x80,24			/* INITLONG off24 lib_IdString		   */
	.long	idstr
	.byte	0,0,0,0			/* end + pad		*/

/*------------------------------ LibInit --------------------------*/
/* d0 = lib base, a0 = seglist, a6 = SysBase			*/
initfn:
	moveml	%d0-%d1/%a0-%a1/%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(34)		/* ExecBase		*/
	movel	%a0,%a5@(42)		/* seglist		*/
	lea	dosname(%pc),%a1
	jsr	%a6@(-408)		/* OldOpenLibrary(dos)	*/
	movel	%d0,%a5@(38)		/* DOSBase		*/
	lea	%a5@(46),%a0		/* NEWLIST(handle list)	*/
	movel	%a0,%a0@
	addql	#4,%a0@
	clrl	%a0@(4)
	movel	%a0,%a0@(8)
	moveml	%sp@+,%d0-%d1/%a0-%a1/%a5
	rts

/*----------------------------- findnode --------------------------*/
/* helper: a5 = lib → d0/a0 = this task's OpenNode or 0.
 * 19.1 reads ThisTask straight out of ExecBase — no FindTask call */
findnode:
	moveal	%a5@(34),%a6		/* ExecBase		*/
	movel	%a6@(276),%d1		/* SysBase->ThisTask	*/
	movel	%a5@(46),%d0		/* list head		*/
1:	moveal	%d0,%a0
	movel	%a0@,%d0
	beqs	2f
	cmpl	%a0@(14),%d1
	bnes	1b
	movel	%a0,%d0
2:	rts

/*----------------------------- LibOpen ---------------------------*/
	.globl	_LibOpen
_LibOpen:
	moveml	%d1/%a0-%a2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	bsr	findnode
	tstl	%d0
	bnes	9f			/* already open → fail	*/
	moveq	#22,%d0
	movel	#0x10001,%d1		/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	%a5@(34),%a6
	jsr	%a6@(-198)		/* AllocMem(22,CLEAR|PUBLIC) */
	tstl	%d0
	beqs	9f
	moveal	%d0,%a2
	movel	%a6@(276),%a2@(14)	/* node.task = ThisTask	*/
	lea	%a5@(46),%a0
	moveal	%a2,%a1
	jsr	%a6@(-246)		/* AddTail		*/
	addqw	#1,%a5@(32)		/* opencnt++		*/
	bclr	#3,%a5@(14)		/* clear DELEXP in lib_Flags */
	movel	%a5,%d0
1:	moveml	%sp@+,%d1/%a0-%a2/%a5-%a6
	rts
9:	moveq	#0,%d0
	bras	1b

/*----------------------------- LibClose --------------------------*/
	.globl	_LibClose
_LibClose:
	moveml	%a2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	bsr	findnode
	tstl	%d0
	beqs	1f
	moveal	%d0,%a2
	moveal	%d0,%a1
	moveal	%a5@(34),%a6
	jsr	%a6@(-252)		/* Remove(node)		*/
	moveq	#22,%d0
	moveal	%a2,%a1
	jsr	%a6@(-210)		/* FreeMem(node,22)	*/
1:	moveml	%sp@+,%a2/%a5-%a6
	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* opencnt--		*/
	bnes	2f
	btst	#3,%a6@(14)		/* delayed expunge?	*/
	beqs	2f
	bsrs	_LibExpunge
2:	rts

/*---------------------------- LibExpunge -------------------------*/
	.globl	_LibExpunge
_LibExpunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	tstw	%a5@(32)
	beqs	1f
	bset	#3,%a5@(14)		/* mark for later	*/
	moveq	#0,%d0
	bras	2f
1:	moveal	%a5,%a1
	moveal	%a5@(34),%a6
	jsr	%a6@(-252)		/* Remove(lib)		*/
	moveal	%a5@(38),%a1
	jsr	%a6@(-414)		/* CloseLibrary(DOS)	*/
	movel	%a5@(42),%d2		/* seglist		*/
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0		/* negsize		*/
	subaw	%d0,%a1
	addw	%a5@(18),%d0		/* + possize		*/
	jsr	%a6@(-210)		/* FreeMem		*/
	movel	%d2,%d0
2:	moveml	%sp@+,%d2/%a5-%a6
	rts

/*---------------------------- reserved ---------------------------*/
	.globl	_LibReserved
_LibReserved:
	rts

	.globl	endofresident
endofresident:
