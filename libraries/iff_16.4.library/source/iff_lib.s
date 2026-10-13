/* iff.library 16.4 — resident/library skeleton
 *
 * Layout mirrors the original hunk:
 *   +0x00  CLI bootstrap ('CHW!' sig; prints ID string, returns WARN)
 *   +0x34  RomTag (AUTOINIT, ver 16, NT_LIBRARY, pri 1, ENDSKIP→API start)
 *   +0x4e  "iff.library" / ID string / "dos.library"
 *   +0x94  InitTable (dataSize 58, functab, datatab, initfn)
 *   +0xa4  absolute-long functab, 15 vectors + -1 terminator
 *   +0xe4  datatab (24-bit-offset INITBYTE/WORD/LONG forms)
 *   +0x110 LibInit: opens dos.library v31, NEWLISTs handle list
 *   +0x13e LibOpen / LibClose / LibExpunge
 *   +0x206 reserved rts stub
 *   API code follows (C objects linked after this file).
 *
 * Library private data area (posSize = 92):
 *   +34 seglist  +38 flag byte (bit3 = delayed expunge)
 *   +40 DOSBase  +44 MinList of per-task OpenNodes
 */
	.text

/*------------------------- CLI bootstrap -------------------------*/
boot:
	bras	1f
	.ascii	"CHW!"
1:	lea	dosname(%pc),%a1
	moveal	4:l,%a6
	jsr	%a6@(-408)		/* OldOpenLibrary(dos)	    */
	moveal	%d0,%a6
	jsr	%a6@(-60)		/* Output()		    */
	movel	%d0,%d1
	lea	idstr(%pc),%a0
	movel	%a0,%d2
	moveq	#45,%d3
	jsr	%a6@(-48)		/* Write(stdout,idstr,45)   */
	moveal	%a6,%a1
	moveal	4:l,%a6
	jsr	%a6@(-414)		/* CloseLibrary(dos)	    */
	moveq	#5,%d0			/* RETURN_WARN		    */
	rts

/*--------------------------- Resident ----------------------------*/
	.globl	romtag
romtag:
	.word	0x4afc
	.long	romtag
	.long	endofresident		/* ENDSKIP → API code start */
	.byte	0x80,16,9,1		/* AUTOINIT, ver 16, LIB, pri 1 */
	.long	libname
	.long	idstr
	.long	inittab

libname:
	.ascii	"iff.library"
	.byte	0
idstr:
	.ascii	"IFF 16.4 (16-May-1989) by Christian A. Weber\n"
	.byte	0
dosname:
	.ascii	"dos.library"
	.byte	0

/*---------------------------- InitTable --------------------------*/
inittab:
	.long	0x3a			/* dataSize = 58	*/
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
	.long	-1			/* table terminator	*/

/*---------------------------- datatab ----------------------------*/
datatab:
	.byte	0xe0,0x00		/* INITBYTE 24-bit off	*/
	.word	8
	.byte	9,0			/* ln_Type = NT_LIBRARY	*/
	.byte	0xc0,0x00		/* INITLONG 24-bit off	*/
	.word	10
	.long	libname			/* ln_Name		*/
	.byte	0xe0,0x00
	.word	14
	.byte	6,0			/* lib_Flags		*/
	.byte	0xd0,0x00		/* INITWORD 24-bit off	*/
	.word	20
	.word	16			/* lib_Version		*/
	.byte	0xd0,0x00
	.word	22
	.word	4			/* lib_Revision		*/
	.byte	0xc0,0x00
	.word	24
	.long	idstr			/* lib_IdString		*/
	.byte	0,0,0,0			/* end + pad		*/

/*------------------------------ LibInit --------------------------*/
/* d0 = lib base, a0 = seglist, a6 = SysBase			*/
initfn:
	moveml	%d0-%d1/%a0-%a1/%a5,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* seglist		*/
	lea	dosname(%pc),%a1
	moveq	#31,%d0
	jsr	%a6@(-552)		/* OpenLibrary(dos,31)	*/
	movel	%d0,%a5@(40)		/* DOSBase		*/
	lea	%a5@(44),%a0		/* NEWLIST(handle list)	*/
	movel	%a0,%a0@
	addql	#4,%a0@
	clrl	%a0@(4)
	movel	%a0,%a0@(8)
	moveml	%sp@+,%d0-%d1/%a0-%a1/%a5
	rts

/*----------------------------- findnode --------------------------*/
/* helper: a5 = lib → d0/a0 = this task's OpenNode or 0		*/
findnode:
	subal	%a1,%a1
	moveal	4:l,%a6
	jsr	%a6@(-294)		/* FindTask(0)		*/
	movel	%d0,%d1
	movel	%a5@(44),%d0
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
	moveq	#1,%d1
	moveal	4:l,%a6
	jsr	%a6@(-198)		/* AllocMem(22,PUBLIC)	*/
	tstl	%d0
	beqs	9f
	moveal	%d0,%a2
	subal	%a1,%a1
	jsr	%a6@(-294)		/* FindTask(0)		*/
	movel	%d0,%a2@(14)		/* node.task		*/
	clrl	%a2@(18)		/* node.error = 0	*/
	lea	%a5@(44),%a0
	moveal	%a2,%a1
	jsr	%a6@(-246)		/* AddTail		*/
	addqw	#1,%a5@(32)		/* opencnt++		*/
	bclr	#3,%a5@(38)		/* clear DELEXP		*/
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
	moveal	4:l,%a6
	jsr	%a6@(-252)		/* Remove(node)		*/
	moveq	#22,%d0
	moveal	%a2,%a1
	jsr	%a6@(-210)		/* FreeMem(node,22)	*/
1:	moveml	%sp@+,%a2/%a5-%a6
	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* opencnt--		*/
	bnes	2f
	btst	#3,%a6@(38)		/* delayed expunge?	*/
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
	bset	#3,%a5@(38)		/* mark for later	*/
	moveq	#0,%d0
	bras	2f
1:	moveal	%a5,%a1
	moveal	4:l,%a6
	jsr	%a6@(-252)		/* Remove(lib)		*/
	moveal	%a5@(40),%a1
	jsr	%a6@(-414)		/* CloseLibrary(DOS)	*/
	movel	%a5@(34),%d2		/* seglist		*/
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
