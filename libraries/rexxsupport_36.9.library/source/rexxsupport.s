/* rexxsupport.library 36.9 — reconstruction
 *
 * William S. Hawes' ARexx support library ("rexxsupport 36.9
 * (02-NOV-90)"): a 5-vector library whose -30 entry dispatches 23
 * ARexx host functions (NEXT NULL BADDR DELAY REPLY DELETE FORBID
 * GETARG GETPKT OFFSET PERMIT RENAME STATEF FORWARD FREEMEM MAKEDIR
 * SHOWDIR TYPEPKT WAITPKT ALLOCMEM OPENPORT SHOWLIST CLOSEPORT).
 *
 * The code hunk opens with a 4-byte `moveq #0,d0;rts` prefix stub;
 * all stored offsets count from code+0.  The function table uses the
 * word-offset form (leading -1, offsets relative to the table base).
 *
 * Dispatch protocol (a6 = lib base, a0 = request block):
 *   rq+20 -> task block T;  rq+31 = arg count (excluding the name)
 *   rq+40 = name argstring ptr,  rq+44.. = argument argstrings
 * Argstrings carry an 8-byte header: [size.l][len.w][0x46][cksum]
 * so name+? fields used: len at ptr-4, checksum at ptr-1.
 *
 * Result contract: d0 = error code, a0 = result argstring.
 * Result-type flags live in the high bits of d7 (argcount copy):
 *   bit31 -> raw string in a3 buffer, length d3
 *   bit16 -> numeric d3  -> rexxsyslib -312
 *   bit17 -> boolean d3  -> rexxsyslib rl_TRUE/rl_FALSE (+72/+68)
 *   bit18 -> empty       -> rexxsyslib rl_NULL+8, len 0
 *
 * 36.9 differences vs 34.9 (see okf/findings/deltas.md):
 *   - datatab drops the LONG@24 lib_IdString record; initfn stores
 *     _idstr to lib+24 itself and calls OpenLibrary(name,0) instead
 *     of OpenLibrary(name,36).
 *   - dispatcher pushes a scratch long, exg's a4/a6 so that a6 IS
 *     RexxSysBase for the whole body, allocates a 400-byte scratch
 *     argstring via rxs -126 as the a3 result buffer (34.9 used
 *     *T+136), and always frees it via rxs -132 on exit.
 *   - handler call framed by exg a4,a6 so handlers keep the 34.9
 *     register contract; the jsr's brief-extension displacement is
 *     -4, making jtab entries relative to the exg (jvec-2 vs jvec).
 *
 * Register state prepared for handlers by the dispatcher:
 *   a0 = arg0, a1 = arg1, a2 = &args[k] (k = flag-scanned args),
 *   then a2 = task block T;  a3 = 400-byte scratch argstring,
 *   a4 = RexxSysBase, a5 = request, d3 = last numeric arg value,
 *   d4 = SysBase, d5 = jump offset, d6 = 0, d7 = arg count,
 *   d0/d1 = argstring lens of arg0/arg1.
 * Calls via `exg d4,a6` hit exec/dos; via `exg a4,a6` hit rexxsyslib
 * internals (-222 stub-init, -180 findnode, -186 freechain,
 * -192 freenode, -198 makeport, -204 delport, -210 flatten,
 * -474 arg->value, -126/-132/-288/-294/-300/-306/-312/-318).
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
	.byte	36			/* rt_Version      */
	.byte	9			/* NT_LIBRARY      */
	.byte	0			/* rt_Pri          */
	.long	libname
	.long	_idstr
	.long	inittab			/* rt_Init         */
	.word	0x4e71			/* pad (assembles as nop) */

/*------------------------- InitTable (0x20) ----------------------*/
inittab:
	.long	0x2e			/* dataSize = 46   */
	.long	functab
	.long	datatab
	.long	initfn

/*------------------- functab (0x30) word-offsets -----------------*/
functab:
	.word	-1			/* word-offset mode */
	.word	_LibOpen-functab	/* -6  */
	.word	_LibClose-functab	/* -12 */
	.word	_LibExpunge-functab	/* -18 */
	.word	_LibNull-functab	/* -24 */
	.word	_SupportDispatch-functab/* -30 */
	.word	-1

/*------------------------- datatab (0x3e) ------------------------*/
datatab:
	.byte	0xa0,0x08,0x09,0x00	/* BYTE @8  = 9  (ln_Type)    */
	.byte	0x80,0x0a
	.long	libname			/* LONG @10      (ln_Name)    */
	.byte	0xa0,0x0e,0x06,0x00	/* BYTE @14 = 6  (lib_Flags)  */
	.byte	0x90,0x14
	.word	36			/* WORD @20 = 36 (lib_Ver)    */
	.byte	0x90,0x16
	.word	9			/* WORD @22 = 9  (lib_Rev)    */
	.word	0			/* end (no @24 IdStr record) */
	.word	0			/* pad */

/*------------------------- initfn (0x58) -------------------------*/
initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(34)		/* SysBase   */
	movel	%a0,%a5@(42)		/* seglist   */
	lea	_idstr(%pc),%a0
	movel	%a0,%a5@(24)		/* lib_IdString (was datatab) */
	lea	rxsname(%pc),%a1
	moveq	#0,%d0			/* any rexxsyslib version   */
	jsr	%a6@(-552)		/* OpenLibrary */
	movel	%d0,%a5@(38)		/* RexxSysBase */
	beqs	1f
	movel	%a5,%d0
1:	moveal	%sp@+,%a5
	rts

/*------------------------- -6 Open (0x82) ------------------------*/
_LibOpen:
	bclr	#3,%a6@(14)		/* LIBF_DELEXP */
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	rts

/*------------------------- -12 Close (0x90) ----------------------*/
/* close shares the expunge tail: open-count zero + DELEXP set
 * falls through into _LibExpunge's bset. */
_LibClose:
	subqw	#1,%a6@(32)
	bnes	_LibNull
	btst	#3,%a6@(14)
	beqs	_LibNull

/*------------------------- -18 Expunge (0x9e) --------------------*/
_LibExpunge:
	bset	#3,%a6@(14)
	tstw	%a6@(32)
	bnes	_LibNull		/* -> d0=0 */
	movel	%a6@(42),%d0		/* seglist */
	moveml	%d0/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(34),%a6		/* SysBase   */
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove    */
	moveal	%a5@(38),%a1
	jsr	%a6@(-414)		/* CloseLibrary(rexxsyslib) */
	moveal	%a5,%a1
	movemw	%a5@(16),%d0-%d1	/* NegSize/PosSize */
	subaw	%d0,%a1
	addw	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem   */
	moveml	%sp@+,%d0/%a5-%a6
	rts

/*------------------------- -24 null (0xdc) -----------------------*/
_LibNull:
	moveq	#0,%d0
	rts

/*--------------------- -30 dispatcher (0xe0) ---------------------*/
_SupportDispatch:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	clrl	%sp@-			/* slot for scratch buffer    */
	moveal	%a0,%a5		/* request block      */
	moveal	%a6@(38),%a4	/* RexxSysBase        */
	exg	%a4,%a6			/* a6 = rxs for the body    */
	moveq	#1,%d6
	moveal	%a5@(40),%a0	/* name argstring     */
	subqw	#8,%a0		/* -> header          */
	bsrw	namelookup
	movew	%d0,%d5		/* jump-table offset  */
	beqw	11f		/* 0 -> not ours (a0 stale!) */
	moveq	#15,%d2
	andb	%a0@,%d2	/* min slots (incl. name) */
	moveq	#0,%d7
	moveb	%a5@(31),%d7	/* arg count          */
	cmpb	%d2,%d7
	bltw	5f		/* too few -> err17   */
	lea	%a5@(40),%a1
1:	tstl	%a1@+
	dbeq	%d2,1b		/* required args must be non-NULL */
	beqw	5f		/* NULL found -> err17 */
	moveb	%a0@+,%d2
	lsrb	#4,%d2		/* max args           */
	cmpb	%d2,%d7
	bgtw	5f		/* too many -> err17  */
	lea	%a5@(44),%a2	/* arg array          */
	movew	%d7,%d2
	moveq	#0,%d3
	moveb	%a0@,%d6	/* arg flag bits      */
	bras	3f
2:	moveal	%a2@+,%a0
	asrb	#1,%d6
	bccs	3f		/* no numeric conv needed */
	movel	%a0,%d0
	beqs	3f		/* NULL arg ok        */
	subqw	#8,%a0		/* arg header (a6 is already rxs) */
	jsr	%a6@(-474)	/* rxs arg->value     */
	bnew	6f		/* -> err18           */
	movel	%d1,%d3
	bmiw	6f		/* negative -> err18  */
3:	tstb	%d6
	dbeq	%d2,2b
	moveq	#100,%d0
	lslw	#2,%d0		/* 400-byte scratch result buffer */
	subal	%a0,%a0
	jsr	%a6@(-126)	/* CreateArgstring(0,400) */
	movel	%d0,%sp@
	beqw	9f		/* alloc failed -> err3 */
	moveal	%d0,%a3		/* result buffer        */
	moveml	%a5@(44),%a0-%a1 /* arg0, arg1         */
	moveal	%a5@(20),%a2	/* task block           */
	moveq	#0,%d0
	moveq	#0,%d1
	moveq	#0,%d2
	movel	%a6@(36),%d4	/* SysBase              */
	cmpib	#1,%d7
	beqs	4f
	blts	10f
	movel	%a1,%d6
	beqs	4f
	movew	%a1@(-4),%d1	/* len(arg1)          */
4:	movel	%a0,%d6
	beqs	10f
	movew	%a0@(-4),%d0	/* len(arg0)          */
10:	moveq	#0,%d6
jvec:	exg	%a4,%a6		/* a6 = lib for handler   */
	jsr	jvec(%pc,%d5:w)	/* call handler (disp -4) */
	exg	%a4,%a6		/* a6 = rxs again         */
	tstl	%d6
	bnes	8f		/* error -> a0=0,d0=d6 */
	movel	%d7,%d0
	swap	%d0
	tstw	%d0
	beqs	11f		/* no result flags    */
	tstl	%d7
	bpls	1f
	moveal	%a3,%a0		/* bit31: raw string  */
	movel	%d3,%d0
	bras	mkarg		/* no header +8 for raw */
1:	btst	#16,%d7
	beqs	1f
	movel	%d3,%d0		/* bit16: numeric     */
	jsr	%a6@(-312)	/* value->argstring   */
	bras	3f
1:	moveal	%a6@(64),%a0	/* bit18: rl_NULL     */
	moveq	#0,%d0
	btst	#17,%d7
	beqs	2f
	moveq	#1,%d0		/* bit17: boolean     */
	moveml	%a6@(68),%a0-%a1 /* rl_FALSE/rl_TRUE  */
	tstl	%d3
	beqs	2f
	moveal	%a1,%a0
2:	addqw	#8,%a0		/* stored values are headers */
mkarg:	jsr	%a6@(-126)	/* CreateArgstring    */
3:	bnes	11f
9:	moveq	#3,%d6
	bras	8f
5:	moveq	#17,%d6		/* wrong args         */
	bras	8f
6:	moveq	#18,%d6		/* bad value          */
8:	subal	%a0,%a0		/* error path: a0 = 0   */
11:	moveal	%a0,%a2		/* save result          */
	moveal	%sp@+,%a0	/* scratch buffer       */
	jsr	%a6@(-132)	/* DeleteArgstring      */
	moveal	%a2,%a0		/* restore result       */
7:	movel	%d6,%d0
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts

/*---------------- shared handler exit stubs ---------------------*/
ret_raw:			/* 0x200: d3-byte raw string at a3 */
	bset	#31,%d7
	rts
ret_num:			/* 0x206: numeric result d3 */
	bset	#16,%d7
	rts
ret_bool:			/* 0x20c: boolean result d3 */
	bset	#17,%d7
	rts
ret_empty:			/* 0x212: empty string */
	bset	#18,%d7
	rts
err3:				/* 0x218: allocation/lock failure */
	moveq	#3,%d6
	rts
err18:				/* 0x21c: invalid argument */
	moveq	#18,%d6
	rts

/*---------------- name lookup (0x220) ---------------------------*/
/* a0 = argstring header (str-8); a3 = str-1.  Records are packed as
 * [cksum byte][name][minmax][flags]; the checksum byte matches the
 * byte rexxsyslib stores at str-1 (sum of name chars).
 * Returns d0 = jump-table word (offset from jvec), a0 = record tail. */
namelookup:
	lea	%a0@(7),%a3
	moveq	#0,%d2
	movew	%a0@(4),%d3	/* name length */
	moveq	#9,%d0
	cmpw	%d0,%d3
	bhis	4f		/* len>9 -> no match */
	moveb	ta_count(%pc,%d3:w),%d0
	moveb	tb_start(%pc,%d3:w),%d2
	bras	3f
1:	lea	cmdtab(%pc,%d2:w),%a0
	moveal	%a3,%a1
	movew	%d3,%d1
2:	cmpmb	%a0@+,%a1@+
	dbne	%d1,2b
	beqs	5f
	addw	%d3,%d2
	addqw	#3,%d2		/* next record */
3:	dbf	%d0,1b
4:	moveq	#0,%d0
	rts
5:	moveb	tc_last(%pc,%d3:w),%d3
	subw	%d0,%d3		/* jump index */
	addw	%d3,%d3
	lea	jtab(%pc),%a1
	addaw	%d3,%a1
	movew	%a1@,%d0
	rts

/* index tables: three 10-entry arrays overlapped into 16 bytes —
 * only indices 4..9 of each are used (lengths 4..9). */
ta_count:	.byte	0,0,0,0,2,3		/* @0x268 */
tc_last:	.byte	8,6,3,1,2,5		/* @0x26e */
tb_start:	.byte	13,19,22,23,0,14	/* @0x274 */
		.byte	38,110,170,203

/*------------------- packed command table (0x27e) ----------------*/
/* Records: [cksum][name][min|max<<4][argflags], packed linearly.
 * The per-length sections OVERLAP: a record serving as the last
 * entry of a shorter section is simultaneously the first entry of
 * the next-longer section (e.g. "BADD"+{52,11} read len-4 shares
 * bytes with "BADDR"+{11,00} read len-5).  CLOSEPORT's last trailer
 * byte is jtab[0]'s high byte. */
cmdtab:
	.byte	0x3f
	.ascii	"NEXT"
	.byte	0x21,0x02
	.byte	0x3b
	.ascii	"NULL"
	.byte	0x00,0x00
	.byte	0x5d			/* len4 rec2/len5 rec0 overlap */
	.ascii	"BADDR"
	.byte	0x11,0x00
	.byte	0x6f
	.ascii	"DELAY"
	.byte	0x11,0x01
	.byte	0x8c
	.ascii	"REPLY"
	.byte	0x31,0x02
	.byte	0xb3			/* len5 rec3/len6 rec0 overlap */
	.ascii	"DELETE"
	.byte	0x11,0x00
	.byte	0xb6
	.ascii	"FORBID"
	.byte	0x00,0x00
	.byte	0xba
	.ascii	"GETARG"
	.byte	0x21,0x02
	.byte	0xcf
	.ascii	"GETPKT"
	.byte	0x11,0x00
	.byte	0xc7
	.ascii	"OFFSET"
	.byte	0x22,0x00
	.byte	0xd1
	.ascii	"PERMIT"
	.byte	0x00,0x00
	.byte	0xb8
	.ascii	"RENAME"
	.byte	0x22,0x00
	.byte	0xc7
	.ascii	"STATEF"
	.byte	0x11,0x00
	.byte	0x15			/* len6 rec8/len7 rec0 overlap */
	.ascii	"FORWARD"
	.byte	0x22,0x00
	.byte	0x01
	.ascii	"FREEMEM"
	.byte	0x22,0x02
	.byte	0xfd
	.ascii	"MAKEDIR"
	.byte	0x11,0x00
	.byte	0x20
	.ascii	"SHOWDIR"
	.byte	0x31,0x00
	.byte	0x31
	.ascii	"TYPEPKT"
	.byte	0x21,0x00
	.byte	0x24
	.ascii	"WAITPKT"
	.byte	0x11,0x00
	.byte	0x4a			/* len7 rec6/len8 rec0 overlap */
	.ascii	"ALLOCMEM"
	.byte	0x21,0x01
	.byte	0x77
	.ascii	"OPENPORT"
	.byte	0x11,0x00
	.byte	0x7d
	.ascii	"SHOWLIST"
	.byte	0x41,0x00
	.byte	0xbb			/* len8 rec3/len9 rec0 overlap */
	.ascii	"CLOSEPORT"
	.byte	0x11			/* trailer1 = jtab[0] high byte */

/*------------------- jump table (0x354) -------------------------*/
/* words are offsets from jvec (the exg before the indexed jsr) */
jtab:
	.word	0			/* idx 0: unused */
	.word	h_NEXT-jvec		/*  1 NEXT    */
	.word	h_NULL-jvec		/*  2 NULL    */
	.word	h_BADDR-jvec		/*  3 BADDR   */
	.word	h_DELAY-jvec		/*  4 DELAY   */
	.word	h_REPLY-jvec		/*  5 REPLY   */
	.word	h_DELETE-jvec		/*  6 DELETE  */
	.word	h_FORBID-jvec		/*  7 FORBID  */
	.word	h_GETARG-jvec		/*  8 GETARG  */
	.word	h_GETPKT-jvec		/*  9 GETPKT  */
	.word	h_OFFSET-jvec		/* 10 OFFSET  */
	.word	h_PERMIT-jvec		/* 11 PERMIT  */
	.word	h_RENAME-jvec		/* 12 RENAME  */
	.word	h_STATEF-jvec		/* 13 STATEF  */
	.word	h_FORWARD-jvec		/* 14 FORWARD */
	.word	h_FREEMEM-jvec		/* 15 FREEMEM */
	.word	h_MAKEDIR-jvec		/* 16 MAKEDIR */
	.word	h_SHOWDIR-jvec		/* 17 SHOWDIR */
	.word	h_TYPEPKT-jvec		/* 18 TYPEPKT */
	.word	h_WAITPKT-jvec		/* 19 WAITPKT */
	.word	h_ALLOCMEM-jvec		/* 20 ALLOCMEM*/
	.word	h_OPENPORT-jvec		/* 21 OPENPORT*/
	.word	h_SHOWLIST-jvec		/* 22 SHOWLIST*/
	.word	h_CLOSEPORT-jvec	/* 23 CLOSEPORT*/

/*---------------- STATEF (0x384) --------------------------------*/
/* STATEF(path): lock+Examine -> "DIR|FILE size blocks prot date comm" */
h_STATEF:
	lea	%a3@(24),%a2		/* fib scratch */
	movel	%a4@(40),%d4		/* DOSBase */
	moveq	#32,%d5			/* space separator */
	movel	%a0,%d1
	moveq	#-2,%d2			/* ACCESS_READ */
	exg	%d4,%a6
	jsr	%a6@(-84)		/* Lock */
	movel	%d0,%d3
	beqs	1f
	movel	%d3,%d1
	movel	%a2,%d2
	jsr	%a6@(-102)		/* Examine */
	movel	%d3,%d1
	movel	%d0,%d3
	jsr	%a6@(-90)		/* UnLock */
1:	exg	%d4,%a6
	tstl	%d3
	beqw	ret_empty
	moveal	%a3,%a0
	lea	sf_dir(%pc),%a1		/* "DIR"/"FILE" */
	tstl	%a2@(4)			/* fib_DirEntryType */
	bpls	2f
	addql	#4,%a1
2:	moveb	%a1@+,%a0@+
	bnes	2b
	moveb	%d5,%a0@(-1)
	movel	%a2@(124),%d0		/* fib_Size */
	bsrs	sf_num
	movel	%a2@(128),%d0		/* fib_NumBlocks */
	bsrs	sf_num
	movel	%a2@(116),%d0		/* fib_Protection */
	moveq	#7,%d1
3:	moveb	sf_pset(%pc,%d1:w),%d2
	btst	%d1,%d0
	beqs	4f
	moveb	sf_pclr(%pc,%d1:w),%d2
4:	moveb	%d2,%a0@+
	dbf	%d1,3b
	moveb	%d5,%a0@+
	lea	%a2@(132),%a1		/* fib_DateStamp */
	moveq	#2,%d2
5:	movel	%a1@+,%d0
	movel	%a1,%sp@-
	bsrs	sf_num
	moveal	%sp@+,%a1
	dbf	%d2,5b
6:	moveb	%a1@+,%a0@+		/* fib_Comment */
	bnes	6b
	subql	#1,%a0
	movel	%a0,%d3
	subl	%a3,%d3
	braw	ret_raw

sf_num:				/* decimal(d0) + space into a0 */
	moveq	#12,%d1
	exg	%a4,%a6
	jsr	%a6@(-306)
	exg	%a4,%a6
	moveb	#32,%a0@+
	rts
sf_pset:	.ascii	"DEWR----"
sf_pclr:	.ascii	"----APSH"
sf_dir:		.ascii	"DIR\0FILE\0"
		.even

/*---------------- SHOWDIR (0x43a) -------------------------------*/
/* SHOWDIR(path[, 'A'|'D'|'F'[, sep]]) -> dir listing string */
h_SHOWDIR:
	lea	%a3@(24),%a2		/* fib scratch */
	movel	%a4@(40),%d4		/* DOSBase */
	moveq	#0,%d5			/* filter: all */
	moveq	#2,%d1
	cmpb	%d1,%d7
	blts	1f
	moveq	#65,%d0			/* default 'A' */
	bsrw	argbyte			/* d0 = first char of arg1 */
	bclr	#5,%d0
	subib	#65,%d0
	beqs	1f			/* 'A' -> all */
	moveq	#1,%d5
	subqb	#3,%d0
	beqs	1f			/* 'D' -> dirs */
	moveq	#-1,%d5
	subqb	#2,%d0
	bnew	err18			/* not 'F' -> err18 */
1:	movel	%a0,%d1
	moveq	#-2,%d2
	exg	%d4,%a6
	jsr	%a6@(-84)		/* Lock */
	movel	%d0,%d3
	beqs	2f
	movel	%d3,%d1
	movel	%a2,%d2
	jsr	%a6@(-102)		/* Examine */
2:	exg	%d4,%a6
	moveq	#0,%d2
	tstl	%d0
	beqs	6f			/* lock/examine failed */
	tstl	%a2@(4)			/* fib_DirEntryType */
	bmis	6f			/* file -> no listing */
	exg	%a4,%a6
	moveal	%a3,%a0
	jsr	%a6@(-222)		/* init stub list */
3:	movel	%d3,%d1
	movel	%a2,%d2
	exg	%d4,%a6
	jsr	%a6@(-108)		/* ExNext */
	exg	%d4,%a6
	tstl	%d0
	beqs	5f			/* done */
	tstl	%d5			/* filter? */
	beqs	4f
	smi	%d0
	tstl	%a2@(4)
	smi	%d1
	eorb	%d1,%d0
	bnes	3b			/* type mismatch -> skip */
4:	moveal	%a3,%a0
	lea	%a2@(8),%a1		/* fib_FileName */
	moveq	#32,%d0
	jsr	%a6@(-174)		/* append name node */
	movel	%d0,%d2
	bnes	3b
	bras	7f			/* append failed -> err3 */
5:	moveq	#32,%d0			/* default separator */
	moveq	#3,%d1
	moveal	%a5@(52),%a1		/* arg2 = separator */
	bsrs	argbyte
	moveal	%a3,%a0
	jsr	%a6@(-210)		/* flatten -> argstring */
	movel	%d0,%d2
	bnes	8f
7:	moveq	#3,%d6
8:	moveal	%a3,%a0
	jsr	%a6@(-186)		/* free stub chain */
	exg	%a4,%a6
6:	movel	%d3,%d1
	exg	%d4,%a6
	jsr	%a6@(-90)		/* UnLock */
	exg	%d4,%a6
	moveal	%d2,%a0
	tstl	%d2
	beqw	ret_empty
	rts

/* argbyte: pick first byte of a1 argstring (if argc>=d1 & valid) */
argbyte:
	cmpb	%d1,%d7
	blts	9f
	movel	%a1,%d1
	beqs	9f
	tstw	%a1@(-4)
	beqs	9f
	moveb	%a1@,%d0
9:	rts

/*---------------- DELAY (0x50a) ---------------------------------*/
h_DELAY:
	tstl	%d3
	bles	1f			/* ticks<=0 -> bool */
	movew	#-198,%d1
	moveal	%d3,%a0
	bsrs	doscall			/* Delay */
	movel	%d0,%d3
1:	braw	ret_bool

/*---------------- DELETE (0x51c) --------------------------------*/
h_DELETE:
	movew	#-72,%d1
	bsrs	doscall			/* DeleteFile */
	movel	%d0,%d3
	braw	ret_bool

/*---------------- RENAME (0x528) --------------------------------*/
h_RENAME:
	movew	#-78,%d1
	bsrs	doscall			/* Rename */
	movel	%d0,%d3
	braw	ret_bool

/*---------------- MAKEDIR (0x534) -------------------------------*/
h_MAKEDIR:
	movew	#-120,%d1
	bsrs	doscall			/* CreateDir */
	movel	%d0,%d3
	moveal	%d0,%a0
	movew	#-90,%d1
	bsrs	doscall			/* UnLock the dir lock */
	braw	ret_bool

/* doscall: call DOSBase vector (a0=LVO, args a0/a1/d1/d2) -> d0
 * shuffles: a0<->d1 (LVO into a0, arg into d1), d2<-a1 */
doscall:
	exg	%d1,%a0
	movel	%a1,%d2
	movel	%d0,%d3
	movel	%a4@(40),%d4		/* DOSBase */
	exg	%d4,%a6
	jsr	%a6@(0,%a0:w)
	exg	%d4,%a6
	rts

/*---------------- FORBID (0x55c) / PERMIT (0x564) ----------------*/
h_FORBID:
	exg	%d4,%a6
	jsr	%a6@(-132)		/* Forbid */
	bras	1f
h_PERMIT:
	exg	%d4,%a6
	jsr	%a6@(-138)		/* Permit */
1:	moveb	%a6@(295),%d3		/* TDNestCnt */
	extw	%d3
	extl	%d3
	exg	%d4,%a6
	braw	ret_num

/*---------------- NULL (0x578) ----------------------------------*/
h_NULL:
	clrl	%a3@
	bras	raw4

/*---------------- BADDR (0x57c) ---------------------------------*/
h_BADDR:
	subqw	#4,%d0			/* len(arg0)==4 -> BCPL ptr */
	bnes	9f
	movel	%a0@,%d0
	lsll	#2,%d0
	movel	%d0,%a3@
	bras	raw4

/*---------------- NEXT (0x588) ----------------------------------*/
h_NEXT:
	subqw	#4,%d0
	bnes	9f
	addl	%a0@,%d3		/* d3 = *(arg0) + arg1val */
	btst	#0,%d3
	bnes	9f			/* must be even */
	moveal	%d3,%a0
	movel	%a0@,%a3@
	bras	raw4

/*---------------- OFFSET (0x59a) --------------------------------*/
h_OFFSET:
	subqw	#4,%d0
	bnes	9f
	moveal	%a0@,%a2		/* base ptr token */
	lea	%a1@(-8),%a0		/* arg1 header */
	exg	%a4,%a6
	jsr	%a6@(-474)		/* arg1->value */
	exg	%a4,%a6
	bnes	9f
	addal	%d1,%a2
	movel	%a2,%a3@
	bras	raw4

/*---------------- ALLOCMEM (0x5b4) ------------------------------*/
h_ALLOCMEM:
	movel	%d3,%d0			/* size */
	beqs	9f
	.word	0x243c			/* movel #1,%d2 (long form, not moveq) */
	.long	1			/* flags */
	cmpib	#2,%d7
	bnes	1f
	subqw	#4,%d1			/* len(arg1)==4 -> flags token */
	bnes	9f
	movel	%a1@,%d2
1:	movel	%d2,%d1
	exg	%d4,%a6
	jsr	%a6@(-198)		/* AllocMem */
	exg	%d4,%a6
	movel	%d0,%a3@
	beqw	err3
raw4:	moveq	#4,%d3
	braw	ret_raw
9:	braw	err18

/*---------------- GETPKT (0x5e4) --------------------------------*/
h_GETPKT:
	moveal	%a0,%a1			/* port name */
	lea	%a2@(316),%a0		/* port list */
	moveq	#2,%d0
	exg	%a4,%a6
	jsr	%a6@(-180)		/* find named node */
	exg	%a4,%a6
	beqs	9b			/* not found -> err18 */
	moveal	%a0,%a2
	lea	%a2@(32),%a0		/* the MsgPort */
	exg	%d4,%a6
	jsr	%a6@(-372)		/* GetMsg */
	lea	%a2@(66),%a0		/* pending stub list */
	lea	%a0@(4),%a3
	tstl	%d0
	beqs	1f
	addqw	#4,%a3
	movel	%d0,%a1
	jsr	%a6@(-246)		/* AddTail(list, msg) */
1:	exg	%d4,%a6
	bras	raw4

/*---------------- TYPEPKT (0x61a) -------------------------------*/
h_TYPEPKT:
	subqw	#4,%d0
	bnes	9b
	moveal	%a0@,%a2		/* packet token */
	lea	%a2@(28),%a3
	movel	%a3@,%d2		/* rm_Action */
	moveb	%d2,%d3
	cmpib	#2,%d7
	blts	raw4			/* no arg1 -> raw action byte */
	moveb	%a1@,%d1
	bclr	#5,%d1			/* uppercase */
	subib	#65,%d1
	beqw	ret_num			/* 'A' -> numeric action */
	movel	#0x01000000,%d0
	subqb	#2,%d1
	beqs	1f			/* 'C' */
	movel	#0x02000000,%d0
	subqb	#3,%d1
	bnes	9b			/* other -> err18 ('F' hits) */
1:	andil	#0xff000000,%d2
	cmpl	%d0,%d2
	seq	%d3			/* bool: action class match */
	bras	bool

/*---------------- FREEMEM (0x65c) -------------------------------*/
h_FREEMEM:
	subqw	#4,%d0
	bnes	bail18
	movel	%d3,%d0			/* size (arg1) */
	beqs	bail18
	movel	%a0@,%d1		/* addr (arg0 token) */
	beqs	bail18
	moveal	%d1,%a1
	exg	%d4,%a6
	jsr	%a6@(-210)		/* FreeMem */
	exg	%d4,%a6
	moveq	#-1,%d3
	bras	bool

/*---------------- OPENPORT (0x676) ------------------------------*/
h_OPENPORT:
	moveal	%a0,%a3			/* name */
	exg	%d4,%a6
	jsr	%a6@(-132)		/* Forbid */
	moveal	%a3,%a1
	jsr	%a6@(-390)		/* FindPort */
	tstl	%d0
	bnes	1f			/* exists -> false */
	lea	%a2@(316),%a0		/* port list */
	moveal	%a3,%a1
	exg	%a4,%a6
	jsr	%a6@(-198)		/* create port node */
	exg	%a4,%a6
	sne	%d3			/* d3 = -1 if created */
1:	jsr	%a6@(-138)		/* Permit */
	exg	%d4,%a6
	bras	bool

/*---------------- CLOSEPORT (0x6a0) -----------------------------*/
h_CLOSEPORT:
	exg	%a4,%a6
	moveal	%a0,%a1			/* name */
	lea	%a2@(316),%a0		/* port list */
	moveq	#2,%d0
	jsr	%a6@(-180)		/* find named node */
	movel	%d0,%d3
	beqs	1f
	jsr	%a6@(-204)		/* delete port node */
1:	exg	%a4,%a6
bool:	braw	ret_bool		/* shared @0x6b8 */
bail18:	braw	err18			/* shared @0x6bc */

/*---------------- FORWARD (0x6c0) -------------------------------*/
h_FORWARD:
	subqw	#4,%d0
	bnes	bail18
	moveal	%a0@,%a2		/* msg token */
	exg	%d4,%a6
	jsr	%a6@(-132)		/* Forbid */
	jsr	%a6@(-390)		/* FindPort(arg1) */
	movel	%d0,%d3
	beqs	1f
	moveal	%a2,%a1
	jsr	%a6@(-252)		/* Remove(msg) */
	moveal	%d2,%a0		/* DEFECT: d2=argcount, should be d3 */
	moveal	%a2,%a1
	jsr	%a6@(-366)		/* PutMsg(d2!, msg) */
1:	jsr	%a6@(-138)		/* Permit */
	exg	%d4,%a6
	bras	bool

/*---------------- REPLY (0x6ea) ---------------------------------*/
h_REPLY:
	subqw	#4,%d0
	bnes	bail18
	movel	%a0@,%d0		/* msg token */
	beqs	bail18
	moveal	%d0,%a2
	clrl	%a2@(36)		/* rm_Result2 = 0 */
	movel	%d3,%a2@(32)		/* rm_Result1 = rc */
	bnes	2f			/* nonzero rc -> just reply */
	btst	#1,%a2@(29)		/* wants result string? */
	beqs	2f
	cmpib	#3,%d7
	blts	2f
	movel	%a5@(52),%d1		/* arg2 */
	beqs	2f
	moveal	%d1,%a0
	movew	%a0@(-4),%d0
	exg	%a4,%a6
	jsr	%a6@(-126)		/* CreateArgstring */
	exg	%a4,%a6
	movel	%d0,%a2@(36)		/* rm_Result2 = argstring */
2:	exg	%d4,%a6
	moveal	%a2,%a1
	jsr	%a6@(-252)		/* Remove(msg) */
	moveal	%a2,%a1
	jsr	%a6@(-378)		/* ReplyMsg */
	exg	%d4,%a6
	moveq	#-1,%d3
	bras	bool

/*---------------- WAITPKT (0x738) -------------------------------*/
h_WAITPKT:
	moveal	%a0,%a1			/* port name */
	lea	%a2@(316),%a0		/* port list */
	moveq	#2,%d0
	exg	%a4,%a6
	jsr	%a6@(-180)		/* find named node */
	exg	%a4,%a6
	beqw	err18
	moveal	%a0@(52),%a1		/* queued packet chain */
	movel	%a1@,%d3		/* first queued pkt */
	bnes	1f			/* -> TRUE */
	moveb	%a2@(235),%d1		/* caller signal bit */
	moveb	%a0@(47),%d2		/* port mp_SigBit */
	moveq	#0,%d0
	bset	%d1,%d0
	bset	%d2,%d0
	exg	%d4,%a6
	jsr	%a6@(-318)		/* Wait */
	exg	%d4,%a6
	btst	%d2,%d0
	sne	%d3			/* got port signal? */
1:	braw	ret_bool

/*---------------- GETARG (0x772) --------------------------------*/
h_GETARG:
	subqw	#4,%d0
	bnew	err18
	moveal	%a0@,%a2		/* packet token */
	movel	%a2@(28),%d1		/* action+argcount */
	moveb	%d1,%d2			/* count */
	andil	#0xff000000,%d1
	cmpil	#0x01000000,%d1
	beqs	1f
	cmpil	#0x02000000,%d1
	bnew	err18
1:	cmpl	%d2,%d3			/* index within range? */
	bgts	2f
	lsll	#2,%d3
	movel	%a2@(40,%d3:l),%d0	/* rm_Args[index] */
	beqs	2f
	moveal	%d0,%a3
	movew	%a3@(-4),%d3		/* len of argstring */
	braw	ret_raw
2:	braw	ret_empty

/*---------------- SHOWLIST (0x7b2) ------------------------------*/
/* SHOWLIST(list[, name[, sep[, 'A']]]): dump an exec/dos/rexx list */
h_SHOWLIST:
	movel	%a6,%sp@-
	lea	%sp@(-14),%sp		/* 14-byte stub list */
	moveal	%a0,%a2		/* list-name arg */
	moveal	%sp,%a0
	moveal	%a4,%a6
	jsr	%a6@(-222)		/* init stub */
	moveq	#0,%d2
	moveb	%a2@,%d0		/* first char of arg0 */
	bclr	#5,%d0			/* uppercase */
	subib	#64,%d0
	beqs	1f			/* '@' handled below */
	moveal	%d4,%a2		/* a2 = SysBase */
	moveq	#1,%d1
	subqb	#1,%d0
	beqs	sl_scan			/* 'A' -> devlist scan type1 */
	lea	%a2@(350),%a0		/* DeviceList */
	subqb	#3,%d0
	beqs	sl_list			/* 'D' */
	moveq	#0,%d1
	subqb	#4,%d0
	beqs	sl_scan			/* 'H' -> devlist scan type0 */
	lea	%a2@(364),%a0		/* IntrList */
	subqb	#1,%d0
	beqs	sl_list			/* 'I' */
	lea	%a2@(378),%a0		/* LibList */
	subqb	#3,%d0
	beqs	sl_list			/* 'L' */
	lea	%a2@(322),%a0		/* MemList */
	subqb	#1,%d0
	beqs	sl_list			/* 'M' */
	lea	%a2@(392),%a0		/* PortList */
	subqb	#3,%d0
	beqs	sl_list			/* 'P' */
	lea	%a2@(336),%a0		/* ResourceList */
	subqb	#2,%d0
	beqs	sl_list			/* 'R' */
	lea	%a2@(532),%a0		/* SemaphoreList */
	subqb	#1,%d0
	beqs	sl_list			/* 'S' */
	moveq	#2,%d1
	subqb	#3,%d0
	beqs	sl_scan			/* 'V' -> devlist scan type2 */
	moveq	#-1,%d2
	lea	%a2@(406),%a0		/* TaskReady */
	addqb	#2,%d0
	beqs	sl_list			/* 'T' */
	lea	%a2@(420),%a0		/* TaskWait */
	subqb	#3,%d0
	beqs	sl_list			/* 'W' */
sl_bad:	braw	5f			/* other -> err18 */
1:	subqw	#5,%d0
	bnes	sl_bad			/* '@' -> err18 */
	movel	%a0@+,%d0
	lsll	#8,%d0
	moveb	%a0@,%d0
	btst	#0,%d0
	bnes	sl_bad
	moveal	%d0,%a0
	tstl	%a0@(4)
	bnes	sl_bad
	bras	sl_list
sl_scan:				/* 'A'/'H'/'V': scan DOS devlist */
	moveal	%sp,%a0
	bsrs	sl_devscan
sl_list:
	cmpib	#2,%d7
	blts	3f			/* no name arg -> flatten all */
	movel	%a1,%d1
	beqs	3f
	moveal	%d4,%a6
	movel	%a0,%d3
	jsr	%a6@(-276)		/* FindName(list, arg1) */
	exg	%d0,%d3
	cmpib	#4,%d7
	blts	4f			/* argcount<4 -> bool result */
	movel	%a5@(56),%d1		/* arg3 */
	beqs	4f
	moveal	%d1,%a1
	moveb	%a1@,%d1
	bclr	#5,%d1
	cmpib	#65,%d1
	bnes	5f			/* arg3 != 'A' -> err18 */
	tstl	%d3
	beqs	2f
	cmpl	%sp,%d0			/* was the "list" the stub? */
	bnes	2f
	moveal	%d3,%a0
	movel	%a0@(24),%d3		/* node+24 = real object */
2:	movel	%d3,%a3@
	moveq	#4,%d3
	bset	#31,%d7			/* raw 4-byte result */
	bras	6f
4:	bset	#17,%d7			/* boolean result d3 */
	bras	6f
3:	moveq	#32,%d0			/* default separator */
	moveq	#3,%d1
	moveal	%a5@(52),%a1		/* arg2 = separator */
	bsrw	argbyte
	moveal	%a4,%a6
	movel	%d2,%d1
	jsr	%a6@(-210)		/* flatten -> argstring */
	bnes	6f
	moveq	#3,%d6
	bras	6f
5:	moveq	#18,%d6
6:	moveal	%a0,%a2
	moveal	%sp,%a0
	moveal	%a4,%a6
	jsr	%a6@(-186)		/* free stub chain */
	moveal	%a2,%a0
	lea	%sp@(14),%sp
	moveal	%sp@+,%a6
	rts

/* sl_devscan: append devlist node names (type==d1) to stub at sp */
sl_devscan:
	moveml	%d2-%d3/%d5/%a0-%a2/%a6,%sp@-
	linkw	%a5,#-256
	moveal	%a0,%a2		/* a2 = stub head */
	movel	%d1,%d2		/* required node type */
	moveal	%d4,%a6
	jsr	%a6@(-132)		/* Forbid */
	moveal	%a4,%a6
	moveal	%a6@(40),%a1		/* DOSBase */
	moveal	%a1@(34),%a1		/* dl_Root */
	moveal	%a1@(24),%a1		/* rn_Info (BPTR) */
	addal	%a1,%a1
	addal	%a1,%a1			/* C ptr */
	movel	%a1@(4),%d3		/* di_DevList (BPTR) */
	bras	4f
1:	moveal	%d3,%a0
	movel	%a0@,%d3		/* dl_Next */
	cmpl	%a0@(4),%d2		/* dl_Type == wanted? */
	bnes	4f
	movel	%a0,%d5
	movel	%a0@(40),%d0		/* dl_Name (BSTR) */
	lsll	#2,%d0
	moveal	%d0,%a0
	moveq	#0,%d1
	moveb	%a0@+,%d1		/* BSTR len */
	moveal	%sp,%a1
	bras	3f
2:	moveb	%a0@+,%d0
	jsr	%a6@(-294)		/* toupper */
	moveb	%d0,%a1@+
3:	dbf	%d1,2b
	clrb	%a1@
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%sp,%a1
	jsr	%a6@(-174)		/* append name node */
	beqs	4f
	movel	%d5,%a0@(24)		/* node+24 = real devnode */
4:	lsll	#2,%d3			/* next (BPTR->C) */
	bnes	1b
	moveal	%d4,%a6
	jsr	%a6@(-138)		/* Permit */
	unlk	%a5
	moveml	%sp@+,%d2-%d3/%d5/%a0-%a2/%a6
	rts

/*------------------------- strings -------------------------------*/
	.globl	_idstr
libname:	.ascii	"rexxsupport.library\0"
_idstr:		.ascii	"rexxsupport 36.9 (02-NOV-90)\n\0"
rxsname:	.asciz	"rexxsyslib.library"
		.even

endofcode:
