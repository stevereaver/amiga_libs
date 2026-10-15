/* rexxserdev.library 5.02 — resident skeleton, lifecycle, dispatcher
 *
 * The code hunk opens with a 4-byte null stub (exec/entry prefix)
 * before the RomTag; all stored offsets count from code+0.
 */
	.text

/*------------------------- prefix stub (0x00) --------------------*/
entrystub:
	moveq	#0,%d0
	rts

/*------------------------- Resident (0x04) -----------------------*/
	.globl	romtag
romtag:
	.word	0x4afc			/* RTC_MATCHWORD   */
	.long	romtag			/* rt_MatchTag     */
	.long	endofcode		/* rt_EndSkip      */
	.byte	0x80			/* RTF_AUTOINIT    */
	.byte	5			/* rt_Version      */
	.byte	9			/* NT_LIBRARY      */
	.byte	0			/* rt_Pri          */
	.long	libname
	.long	_idstr
	.long	inittab			/* rt_Init         */
	.word	0			/* pad to 0x1c     */

/*------------------------- InitTable (0x1c) ----------------------*/
/* {dataSize=0x42, functab, datatab, initfn} */
inittab:
	.long	0x42
	.long	functab
	.long	datatab
	.long	initfn

/*------------------------- functab (0x2c) ------------------------*/
functab:
	.long	_LibOpen		/* -6  */
	.long	_LibClose		/* -12 */
	.long	_LibExpunge		/* -18 */
	.long	_LibNull		/* -24 */
	.long	_SerDispatch		/* -30 */
	.long	-1

/*------------------------- datatab (0x44) ------------------------*/
/* InitStruct byte-offset forms: a0=INITBYTE 90=INITWORD 80=INITLONG */
datatab:
	.byte	0xa0,0x08,0x09,0x00	/* BYTE @8  = 9  (ln_Type)    */
	.byte	0x80,0x0a
	.long	libname			/* LONG @10      (ln_Name)    */
	.byte	0xa0,0x0e,0x06,0x00	/* BYTE @14 = 6  (lib_Flags)  */
	.byte	0x90,0x14
	.word	5			/* WORD @20 = 5  (lib_Ver)    */
	.byte	0x90,0x16
	.word	2			/* WORD @22 = 2  (lib_Rev)    */
	.byte	0x80,0x18
	.long	_idstr			/* LONG @24      (lib_IdStr)  */
	.word	0			/* end */

/*------------------------- initfn (0x64) -------------------------*/
initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(34)		/* SysBase   */
	movel	%a0,%a5@(46)		/* seglist   */
	lea	rxsname(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)		/* OpenLibrary(rexxsyslib,0) */
	movel	%d0,%a5@(38)
	beqs	1f
	lea	utlname(%pc),%a1
	moveq	#37,%d0
	jsr	%a6@(-552)		/* OpenLibrary(utility,37) */
	movel	%d0,%a5@(42)
	beqs	1f
	lea	%a5@(54),%a1		/* NewList(&list) */
	movel	%a1,%a1@(8)
	addql	#4,%a1
	clrl	%a1@
	movel	%a1,%a1@-
	movel	%a5,%d0
1:	moveal	%sp@+,%a5
	rts

/*------------------------- -6 Open (0xa4) ------------------------*/
_LibOpen:
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)		/* LIBF_DELEXP */
	movel	%a6,%d0
	rts

/*------------------------- -12 Close (0xb2) ----------------------*/
_LibClose:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	1f
	btst	#3,%a6@(14)
	beqs	1f
	bsrs	_LibExpunge
1:	rts

/*------------------------- -18 Expunge (0xc6) --------------------*/
_LibExpunge:
	tstw	%a6@(32)
	beqs	1f
	bset	#3,%a6@(14)		/* LIBF_DELEXP */
	moveq	#0,%d0
	bras	3f
1:	movel	%a6@(46),%d0		/* seglist */
	moveml	%d0/%a5-%fp,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(34),%a6
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove(&lib->lib_Node) */
	tstl	%a5@(50)		/* dead test (open count) */
	moveal	%a5@(38),%a1
	jsr	%a6@(-414)		/* CloseLibrary(RexxSys) */
	moveal	%a5@(42),%a1
	jsr	%a6@(-414)		/* CloseLibrary(Utility) */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* NegSize */
	subaw	%d0,%a1
	addw	%a5@(18),%d0		/* + PosSize */
	jsr	%a6@(-210)		/* FreeMem */
	moveml	%sp@+,%d0/%a5-%fp
3:	rts

/*------------------------- -24 null (0x116) ----------------------*/
_LibNull:
	moveq	#0,%d0
	rts

/*------------------------- -30 dispatcher (0x11c) ----------------*/
/* a6=lib base, a0=request block; name at a0+40, handle arg at a0+44 */
_SerDispatch:
	moveml	%d2-%d4/%a2-%fp,%sp@-
	moveal	%a6,%a5
	movel	%a0,%d4
	movel	#13,%d3
	moveq	#0,%d2
	moveal	%a0@(40),%a3		/* requested name */
	lea	nametab(%pc),%a4
1:	moveal	%a3,%a0
	moveal	%a4@(0,%d2:w),%a1
	moveal	%a5@(42),%a6		/* UtilityBase */
	jsr	%a6@(-162)		/* Stricmp */
	cmpil	#0,%d0
	beqs	2f
	addql	#4,%d2
	dbf	%d3,1b
	moveq	#1,%d0			/* unknown function */
	bras	3f
2:	cmpil	#44,%d2			/* index >= 11: no object needed */
	bges	4f
	bsrs	getobj
	tstl	%d0
	bnes	3f
	movel	%d4,%a2@(12)		/* obj->msg = request */
4:	lea	apitab(%pc),%a4
	moveal	%a4@(0,%d2:w),%a4
	jsr	%a4@			/* call API vector stub */
3:	moveml	%sp@+,%d2-%d4/%a2-%fp
	rts

/* getobj: resolve handle arg (d4+44) through rexxsyslib -300 -> a2 */
getobj:
	moveal	%d4,%a1
	moveal	%a1@(44),%a0
	cmpal	#0,%a0
	beqs	1f
	moveal	%a5@(38),%a6		/* RexxSysBase */
	jsr	%a6@(-300)		/* argstring -> value */
	moveal	%d0,%a2
	moveq	#0,%d0
	rts
1:	moveq	#12,%d0			/* missing handle */
	rts

/*---------------- API vector stubs (a2=obj a5=lib d4=msg) --------*/
/* Each C function returns the error code in d0 and leaves the reply
 * argstring pointer in _g_result; the stub moves it to a1 as the
 * original code did. */
	.macro	APISTUB	name
	jsr	\name
	moveal	_g_result,%a1
	rts
	.endm

v_SerQuery:	APISTUB	_SerQuery
v_SerRead:	APISTUB	_SerRead
v_SerWrite:	APISTUB	_SerWrite
v_SerSetParms:	APISTUB	_SerSetParms
v_SerClear:	APISTUB	_SerClear
v_SerFlush:	APISTUB	_SerFlush
v_SerReset:	APISTUB	_SerReset
v_SerBreak:	APISTUB	_SerBreak
v_SerStart:	APISTUB	_SerStart
v_SerStop:	APISTUB	_SerStop
v_SerClose:	APISTUB	_SerClose
v_SerOpen:	APISTUB	_SerOpen
v_SerLibBase:	APISTUB	_SerLibBase
v_SerID:	APISTUB	_SerID

/*------------------------- strings -------------------------------*/
	.globl	_idstr
utlname:	.asciz	"utility.library"
libname:	.ascii	"rexxserdev.library\0\0"
_idstr:		.ascii	"rexxserdev 5.02 (24 March 1993)\r\n\0"
rxsname:	.asciz	"rexxsyslib.library"
	.globl	_rep_ok, _rep_err
_rep_ok:		.ascii	"1\0"
_rep_err:	.ascii	"0\0\0"
		.even

/*------------------------- tables --------------------------------*/
apitab:
	.long	v_SerQuery
	.long	v_SerRead
	.long	v_SerWrite
	.long	v_SerSetParms
	.long	v_SerClear
	.long	v_SerFlush
	.long	v_SerReset
	.long	v_SerBreak
	.long	v_SerStart
	.long	v_SerStop
	.long	v_SerClose
	.long	v_SerOpen
	.long	v_SerLibBase
	.long	v_SerID
nametab:
	.long	nm_query
	.long	nm_read
	.long	nm_write
	.long	nm_setparms
	.long	nm_clear
	.long	nm_flush
	.long	nm_reset
	.long	nm_break
	.long	nm_start
	.long	nm_stop
	.long	nm_close
	.long	nm_open
	.long	nm_libbase
	.long	nm_id

/* name strings (original memory order: SerClose's string sits between
 * SerReset and SerBreak, though its table slot is index 10) */
nm_query:	.ascii	"SerQuery\0"
nm_read:	.ascii	"SerRead\0\0"
nm_write:	.ascii	"SerWrite\0"
nm_setparms:	.ascii	"SerSetParms\0"
nm_clear:	.ascii	"SerClear\0"
nm_flush:	.ascii	"SerFlush\0"
nm_reset:	.ascii	"SerReset\0"
nm_close:	.ascii	"SerClose\0"
nm_break:	.ascii	"SerBreak\0\0"
nm_start:	.ascii	"SerStart\0"
nm_stop:	.ascii	"SerStop\0\0"
nm_open:	.ascii	"SerOpen\0\0"
nm_libbase:	.ascii	"SerLibBase\0"
nm_id:		.ascii	"SerID\0"
		.even

endofcode:
