|
|	wbstart_h0.s -- verbatim reconstruction of
|	wbstart.library 45.1 (16.12.00), 1008-byte two-hunk module.
|
|	Hunk 0 CODE (0xc7 longs):
|	  0x000 moveq #-1,d0/rts/nop    loader entry (returns -1)
|	  0x006 moveq #0,d0/rts/nop     reserved stub (LVO -24/-30)
|	  0x00c initfunction            writes lib_Revision=2, opens
|	                                workbench v45 / dos v40 / utility v40
|	  0x056 LibOpen                 LVO -6
|	  0x068 LibExpunge              LVO -18
|	  0x0b4 LibClose                LVO -12
|	  0x0da "workbench.library\0"   18 bytes
|	  0x0ec "dos.library\0"         12 bytes
|	  0x0f8 "utility.library\0"     16 bytes
|	  0x108 openlibs(a0=base)->d0   bsr.w targets from init
|	  0x158 closelibs(a0=base)
|	  0x188 WBStart                 LVO -36
|	  0x31a pad word
|
|	Hunk 1 DATA (0x1e longs): absolute-longword functab (-1L
|	terminated), lib name, idstring, InitTable (dataSize 0x38,
|	no InitStruct), RomTag (RTF_AUTOINIT, rt_Version **2** as
|	shipped), EndSkip word.
|
|	Quirks preserved verbatim:
|	  - 0xd88f  addl %sp,%d4   (An as <ea> for ADD.L, not ADDA)
|	  - 0xbc8a  cmpl %a2,%d6   (An as <ea> for CMP.L, not CMPA)
|	  - 0x303b,0x0806 / 0x4efb,0x0002  PC-indexed jump table
|	  - beqw at 0x228 is word-form; bsr.w calls are word-form;
|	    all other branches are short-form.
|	  - WBStart returns 0 on success / 20 on failure (inverted
|	    vs the workbench.library BOOL).

	.text

| ----------------------------------------------------------------
| loader entry: not executable, returns -1
| ----------------------------------------------------------------

	.globl	_libentry
_libentry:				/* +0x000 */
	moveq	#-1,%d0
	rts
	nop

| reserved stub: LVOs -24 and -30 both vector here (returns 0)

	.globl	_reserved
_reserved:				/* +0x006 */
	moveq	#0,%d0
	rts
	nop

| ----------------------------------------------------------------
| initfunction(d0=base, a0=seglist, a6=exec)
| ----------------------------------------------------------------

	.globl	_LibInit
_LibInit:				/* +0x00c */
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%d0,%a2
	movel	%a6,%a2@(40)		/* base->SysBase */
	movel	%a0,%a2@(36)		/* base->seglist */
	movew	#2,%a2@(22)		/* lib_Revision = 2 (!) */
	moveal	%a2,%a0
	bsrw	_openlibs
	tstw	%d0
	bnes	1f
	moveal	%a2,%a0
	bsrw	_closelibs
	clrl	%d0
	movew	%a2@(16),%d0		/* NegSize */
	clrl	%d1
	movew	%a2@(18),%d1		/* PosSize */
	moveal	%a2@(40),%a6
	moveal	%a2,%a1
	subal	%d0,%a1
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem */
	moveq	#0,%d0
	bras	2f
1:	movel	%a2,%d0
2:	moveal	%sp@+,%a2
	moveal	%sp@+,%a6
	rts

| ----------------------------------------------------------------
| LVO -6 Open: clear DELEXP, bump OpenCnt, return base
| ----------------------------------------------------------------

	.globl	_LibOpen
_LibOpen:				/* +0x056 */
	movel	%a6,%sp@-
	andib	#0xf7,%a6@(14)
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	moveal	%sp@+,%a6
	rts

| ----------------------------------------------------------------
| LVO -18 Expunge
| ----------------------------------------------------------------

	.globl	_LibExpunge
_LibExpunge:				/* +0x068 */
	moveml	%d2/%a2/%a6,%sp@-
	moveal	%a6,%a2
	moveq	#0,%d2
	tstw	%a2@(32)
	beqs	3f
	orib	#8,%a2@(14)		/* set LIBF_DELEXP */
	bras	4f
3:	moveal	%a2,%a0
	bsrw	_closelibs
	moveal	%a2@(40),%a6
	moveal	%a2,%a1
	jsr	%a6@(-252)		/* Remove */
	movel	%a2@(36),%d2		/* seglist */
	clrl	%d0
	movew	%a2@(16),%d0
	clrl	%d1
	movew	%a2@(18),%d1
	moveal	%a2@(40),%a6
	moveal	%a2,%a1
	subal	%d0,%a1
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem */
4:	movel	%d2,%d0
	moveml	%sp@+,%d2/%a2/%a6
	rts

| ----------------------------------------------------------------
| LVO -12 Close
| ----------------------------------------------------------------

	.globl	_LibClose
_LibClose:				/* +0x0b4 */
	movel	%a6,%sp@-
	moveq	#0,%d0
	movew	%a6@(32),%d1
	beqs	5f
	moveaw	%d1,%a0
	subqw	#1,%a0
	movew	%a0,%a6@(32)
	cmpiw	#1,%d1
	bnes	6f
5:	btst	#3,%a6@(14)		/* LIBF_DELEXP */
	beqs	6f
	bsrs	_LibExpunge
6:	moveal	%sp@+,%a6
	rts

| ----------------------------------------------------------------
| support-library name literals (code hunk, +0x0da)
| ----------------------------------------------------------------

_s_workbench:				/* +0x0da */
	.ascii	"workbench.library"
	.byte	0
_s_dos:					/* +0x0ec */
	.ascii	"dos.library"
	.byte	0
_s_utility:				/* +0x0f8 */
	.ascii	"utility.library"
	.byte	0

| ----------------------------------------------------------------
| openlibs(a0=base) -> d0  (helper, +0x108)
| ----------------------------------------------------------------

_openlibs:
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%a0,%a2
	moveal	%a2@(40),%a6
	lea	%pc@(_s_workbench),%a1
	moveq	#45,%d0
	jsr	%a6@(-552)		/* OpenLibrary wb v45 */
	movel	%d0,%a2@(44)
	beqs	7f
	moveal	%a2@(40),%a6
	lea	%pc@(_s_dos),%a1
	moveq	#40,%d0
	jsr	%a6@(-552)		/* OpenLibrary dos v40 */
	movel	%d0,%a2@(52)
	beqs	7f
	moveal	%a2@(40),%a6
	lea	%pc@(_s_utility),%a1
	moveq	#40,%d0
	jsr	%a6@(-552)		/* OpenLibrary utility v40 */
	movel	%d0,%d1
	movel	%d1,%a2@(48)
	moveq	#1,%d0
	tstl	%d1
	bnes	8f
7:	moveq	#0,%d0
8:	moveal	%sp@+,%a2
	moveal	%sp@+,%a6
	rts

| ----------------------------------------------------------------
| closelibs(a0=base)  (helper, +0x158)
| ----------------------------------------------------------------

_closelibs:
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%a0,%a2
	moveal	%a2@(40),%a6
	moveal	%a2@(44),%a1
	jsr	%a6@(-414)		/* CloseLibrary wb */
	moveal	%a2@(40),%a6
	moveal	%a2@(52),%a1
	jsr	%a6@(-414)		/* CloseLibrary dos */
	moveal	%a2@(40),%a6
	moveal	%a2@(48),%a1
	jsr	%a6@(-414)		/* CloseLibrary utility */
	moveal	%sp@+,%a2
	moveal	%sp@+,%a6
	rts

| ----------------------------------------------------------------
| LVO -36 WBStart(a0=taglist) -> d0 0 ok / 20 fail (+0x188)
|
|  d6 name   d5 lock   d3 nargs   a2 args   d7 oldcd
|  a3 base   a4 ret(20)  d4 = sp+40 = &tagitem-store  sp@(40) = wbtags
| ----------------------------------------------------------------

	.globl	_WBStart
_WBStart:				/* +0x188 */
	subqw	#8,%sp
	moveml	%d2-%d7/%a2-%a4/%a6,%sp@-
	movel	%a0,%sp@(40)
	moveal	%a6,%a3
	subal	%a2,%a2
	moveq	#0,%d6
	moveq	#0,%d5
	moveq	#0,%d3
	moveaw	#20,%a4			/* RETURN_FAIL */
	moveq	#40,%d4
	addl	%sp,%d4			/* 0xd88f: add.l a7,d4 */
	bras	20f

| --- tag dispatch: ti_Tag - TAG_USER - 1 -> jump table ------------

10:	movel	%a0@(4),%d2		/* ti_Data */
	movel	%a0@,%d0		/* ti_Tag */
	addil	#0x7fffffff,%d0		/* tag - 0x80000001 */
	moveq	#6,%d1
	cmpl	%d0,%d1
	bcss	20f			/* out of range: ignore */
	addl	%d0,%d0
	.short	0x303b,0x0806		/* movew pc@(6,d0:l),d0 */
	.short	0x4efb,0x0002		/* jmp pc@(2,d0:w) -> jtab */
_jtab:	.short	0x000e			/* tag+1 name   -> +0x1d0 */
	.short	0x0012			/* tag+2 lock   -> +0x1d4 */
	.short	0x0030			/* tag+3 duplock-> +0x1f2 */
	.short	0x0052			/* tag+4 ignore -> +0x214 */
	.short	0x0052			/* tag+5 ignore -> +0x214 */
	.short	0x004c			/* tag+6 nargs  -> +0x20e */
	.short	0x0050			/* tag+7 args   -> +0x212 */

| --- +0x1d0  tag+1 WBSTARTA_Name ---------------------------------

	movel	%d2,%d6			/* name = ti_Data */
	bras	20f

| --- +0x1d4  tag+2 WBSTARTA_Lock (path string) -------------------

	tstl	%d2
	beqs	20f
	moveal	%a3@(52),%a6		/* DosBase */
	movel	%d5,%d1
	jsr	%a6@(-90)		/* UnLock(old) */
	moveal	%a3@(52),%a6
	movel	%d2,%d1
	moveq	#-2,%d2			/* ACCESS_READ */
	jsr	%a6@(-84)		/* Lock(path) */
	movel	%d0,%d5
	bras	20f

| --- +0x1f2  tag+3 WBSTARTA_DupLock (BPTR) ------------------------

	tstl	%d2
	beqs	20f
	moveal	%a3@(52),%a6
	movel	%d5,%d1
	jsr	%a6@(-90)		/* UnLock(old) */
	moveal	%a3@(52),%a6
	movel	%d2,%d1
	jsr	%a6@(-96)		/* DupLock */
	movel	%d0,%d5
	bras	20f

| --- +0x20e  tag+6 WBSTARTA_NumArgs / +0x212 tag+7 WBSTARTA_Args --

	movel	%d2,%d3			/* nargs */
	bras	20f
	moveal	%d2,%a2			/* args  (falls into loop) */

| --- +0x214  NextTagItem loop tail --------------------------------

20:	moveal	%a3@(48),%a6		/* UtilityBase */
	moveal	%d4,%a0			/* &tagitem-store */
	jsr	%a6@(-48)		/* NextTagItem */
	moveal	%d0,%a0
	cmpaw	#0,%a0
	bnes	10b

| --- end of tag list ----------------------------------------------

	tstl	%d6
	beqw	60f			/* no name: return 20 (word!) */
	tstl	%d3
	beqs	30f			/* no args */
	cmpaw	#0,%a2
	beqs	30f
	movel	%d3,%d0
	addql	#1,%d0
	moveal	%a3@(40),%a6		/* SysBase */
	lsll	#4,%d0			/* (nargs+1)*16 */
	moveq	#0,%d1			/* MEMF_ANY */
	jsr	%a6@(-684)		/* AllocVec */
	movel	%d0,%sp@(40)		/* wbtags */
	moveal	%d0,%a0
	cmpaw	#0,%a0
	beqs	31f
25:	movel	#0x8000a010,%a0@	/* WBOPENA_ArgLock */
	movel	%a2@,%a0@(4)
	addql	#8,%a0
	movel	#0x8000a011,%a0@	/* WBOPENA_ArgName */
	movel	%a2@(4),%a0@(4)
	addql	#8,%a0
	addql	#8,%a2
	subql	#1,%d3
	bnes	25b
	clrl	%a0@			/* TAG_DONE */
	bras	32f
31:	moveq	#-1,%d0			/* alloc fail: -1 marker */
	movel	%d0,%sp@(40)
	bras	32f
30:	clrl	%sp@(40)		/* no wbtags */
32:	moveq	#-1,%d1
	cmpl	%sp@(40),%d1
	beqs	60f			/* alloc failed: bail */
	tstl	%d5
	beqs	40f
	moveal	%a3@(52),%a6		/* DosBase */
	movel	%d5,%d1
	jsr	%a6@(-126)		/* oldcd = CurrentDir(lock) */
	movel	%d0,%d7
	bras	50f
40:	moveal	%a3@(52),%a6
	movel	%d6,%d1
	jsr	%a6@(-876)		/* PathPart(name) */
	moveal	%d0,%a2
	cmpl	%a2,%d6			/* 0xbc8a: cmp.l a2,d6 */
	beqs	50f			/* no path part */
	moveb	%a2@,%d3		/* split dir/name */
	clrb	%a2@
	moveal	%a3@(52),%a6
	movel	%d6,%d1
	moveq	#-2,%d2			/* ACCESS_READ */
	jsr	%a6@(-84)		/* Lock(dir) */
	movel	%d0,%d5
	beqs	41f
	moveal	%a3@(52),%a6
	movel	%d0,%d1
	jsr	%a6@(-126)		/* oldcd = CurrentDir(lock) */
	movel	%d0,%d7
41:	moveb	%d3,%a2@		/* restore separator */
	movel	%a2,%d6			/* name = pathpart */
	cmpib	#0x2f,%d3		/* '/'? */
	bnes	50f
	addql	#1,%d6			/* skip '/' */
50:	moveal	%a3@(44),%a6		/* WorkbenchBase */
	moveal	%d6,%a0
	moveal	%sp@(40),%a1		/* wbtags */
	jsr	%a6@(-96)		/* OpenWorkbenchObjectA */
	tstw	%d0
	beqs	51f
	subal	%a4,%a4			/* success: ret 0 (!) */
51:	tstl	%d5
	beqs	52f
	moveal	%a3@(52),%a6
	movel	%d7,%d1
	jsr	%a6@(-126)		/* CurrentDir(oldcd) */
52:	moveal	%a3@(40),%a6
	moveal	%sp@(40),%a1
	jsr	%a6@(-690)		/* FreeVec(wbtags) */
60:	moveal	%a3@(52),%a6
	movel	%d5,%d1
	jsr	%a6@(-90)		/* UnLock(lock) */
	movel	%a4,%d0
	moveml	%sp@+,%d2-%d7/%a2-%a4/%a6
	addqw	#8,%sp
	rts
	.short	0			/* +0x31a pad to 0xc7 longs */

| ================================================================
| DATA hunk (hunk 1): functab, strings, InitTable, RomTag, EndSkip
| ================================================================

	.data

_functab:				/* +0x00 */
	.long	_LibOpen		/* LVO -6  */
	.long	_LibClose		/* LVO -12 */
	.long	_LibExpunge		/* LVO -18 */
	.long	_reserved		/* LVO -24 */
	.long	_reserved		/* LVO -30 */
	.long	_WBStart		/* LVO -36 */
	.long	-1

_libname:				/* +0x1c */
	.ascii	"wbstart.library"
	.byte	0
_idstr:					/* +0x2c */
	.ascii	"wbstart.library 45.1 (16.12.00)"
	.byte	0

| InitTable at +0x4c: dataSize, funcTable, dataTable(0), initFunc

_inittab:
	.long	0x38			/* sizeof(WBStartBase) */
	.long	_functab
	.long	0			/* no InitStruct data */
	.long	_LibInit

_romtag:				/* +0x5c */
	.short	0x4afc			/* RT_MATCHWORD */
	.long	_romtag			/* RT_MATCHTAG */
	.long	_endskip		/* RT_ENDSKIP */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	2			/* RT_VERSION = 2 (shipped!) */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* RT_PRI */
	.long	_libname		/* RT_NAME */
	.long	_idstr			/* RT_IDSTRING */
	.long	_inittab		/* RT_INIT */
_endskip:				/* +0x76 */
	.short	0
