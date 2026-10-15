||
||	wbstart_h0.s -- verbatim reconstruction of
||	wbstart.library 45.2 (16.07.01) "Emulation by Stephan
||	Rupprecht", 1760-byte two-hunk module.
||
||	Hunk 0 CODE (0x169 longs):
||	  0x000 moveq #-1,d0/rts/nop    loader entry (returns -1)
||	  0x006 clr.l d0/rts/nop        reserved stub (LVO -24/-30)
||	  0x00c initfunction            lib_Revision=2, opens
||	                                workbench v45 / dos v40 /
||	                                utility v40; patches RomTag
||	                                rt_Version (self-modifying
||	                                write into the DATA hunk)
||	  0x062 LibOpen                 LVO -6
||	  0x074 LibExpunge              LVO -18
||	  0x0c2 LibClose                LVO -12
||	  0x0e8 "workbench.library\0"
||	  0x0fa "dos.library\0"
||	  0x106 "utility.library\0"
||	  0x116 openlibs(base@sp) ->d0  stack-arg helpers
||	  0x168 closelibs(base@sp)
||	  0x19a ".info\0"               suffix literal
||	  0x1a0 trylock(name@sp)        Lock(name) else
||	                                Lock("name.info") built in a
||	                                256-byte stack buffer
||	  0x1f8 startobj(name,wbtags)   object resolution:
||	                                bare name / "dev:" / "dev:dir/f"
||	                                / WB search path via
||	                                WorkbenchControlA, PrintFault
||	  0x3ba WBStart                 LVO -36
||	  0x50a pad word
||	  0x50c strcat   (dead code)
||	  0x52a strncat  (called by trylock)
||	  0x556 pad word
||	  0x558 strcpy   (dead code)
||	  0x570 strncpy  (called by trylock)
||	  0x59a pad: four zero words + 0x0002 (!)
||
||	Hunk 1 DATA (0x26 longs): absolute-longword functab (-1L
||	terminated), lib name, idstring, InitTable (dataSize 0x38,
||	no InitStruct), RomTag (RTF_AUTOINIT, RT_VERSION 2 as
||	shipped -- init rewrites the same byte with 2), EndSkip.
||
||	Quirks preserved verbatim:
||	  - reloc tails are plain HUNK_RELOC32 (0x3ec), both hunks;
||	    the CODE hunk's own relocs come from two absolute
||	    "jsr sym" calls and the move.b patch of rt_Version.
||	  - 0xd68f/0xd48f/0xda8f  addl %sp,%dN (An as <ea> for ADD.L)
||	  - 0x4a88/0x4a8b  tstl An (noncanonical; objdump shows .short)
||	  - 0x303b,0x0a06 / 0x4efb,0x0002  PC-indexed jump table
||	    (index d0.l*2, not the 45.1 d0.l*1 + pre-doubling)
||	  - lea 0x0,%aN absolute-word form used for NULL pointers
||	    (SAS/C-style codegen: 0x4bf8/0x47f8/0x49f8/0x41f8)
||	  - beqw at 0x244/0x320/0x458 are word-form; bsr.w calls are
||	    word-form; all other branches short-form.
||	  - WBStart returns 0 on success / 20 on failure (inverted
||	    vs the workbench.library BOOL), same contract as 45.1.
||
	.text

|| ----------------------------------------------------------------
|| loader entry: not executable, returns -1
|| ----------------------------------------------------------------

	.globl	_libentry
_libentry:				/* +0x000 */
	moveq	#-1,%d0
	rts
	nop

|| reserved stub: LVOs -24 and -30 both vector here (returns 0)
|| (45.1 used moveq #0,d0; this one uses clr.l)

	.globl	_reserved
_reserved:				/* +0x006 */
	clrl	%d0
	rts
	nop

|| ----------------------------------------------------------------
|| initfunction(d0=base, a0=seglist, a6=exec)
|| helpers take their base argument ON THE STACK (compiled C)
|| ----------------------------------------------------------------

	.globl	_LibInit
_LibInit:				/* +0x00c */
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%d0,%a2
	movel	%a6,%a2@(40)		/* base->SysBase */
	movel	%a0,%a2@(36)		/* base->seglist */
	movew	#2,%a2@(22)		/* lib_Revision = 2 */
	movel	%a2,%sp@-
	bsrw	_openlibs
	addql	#4,%sp
	tstw	%d0
	bnes	1f
	movel	%a2,%sp@-
	bsrw	_closelibs
	addql	#4,%sp
	clrl	%d0
	movew	%a2@(16),%d0		/* NegSize */
	clrl	%d1
	movew	%a2@(18),%d1		/* PosSize */
	moveal	%a2@(40),%a6
	moveal	%a2,%a1
	subal	%d0,%a1
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem */
	clrl	%d0
	bras	2f
1:	moveb	#2,_rtversion		/* self-patch rt_Version = 2 */
	movel	%a2,%d0
2:	moveal	%sp@+,%a2
	moveal	%sp@+,%a6
	rts

|| ----------------------------------------------------------------
|| LVO -6 Open: clear DELEXP, bump OpenCnt, return base
|| ----------------------------------------------------------------

	.globl	_LibOpen
_LibOpen:				/* +0x062 */
	movel	%a6,%sp@-
	andib	#0xf7,%a6@(14)
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	moveal	%sp@+,%a6
	rts

|| ----------------------------------------------------------------
|| LVO -18 Expunge
|| ----------------------------------------------------------------

	.globl	_LibExpunge
_LibExpunge:				/* +0x074 */
	moveml	%d2/%a2/%a6,%sp@-
	moveal	%a6,%a2
	clrl	%d2
	tstw	%a2@(32)
	beqs	3f
	orib	#8,%a2@(14)		/* set LIBF_DELEXP */
	bras	4f
3:	movel	%a2,%sp@-
	bsrw	_closelibs
	addql	#4,%sp
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

|| ----------------------------------------------------------------
|| LVO -12 Close
|| ----------------------------------------------------------------

	.globl	_LibClose
_LibClose:				/* +0x0c2 */
	movel	%a6,%sp@-
	clrl	%d0
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

|| ----------------------------------------------------------------
|| support-library name literals (+0x0e8)
|| ----------------------------------------------------------------

_s_workbench:				/* +0x0e8 */
	.ascii	"workbench.library"
	.byte	0
_s_dos:					/* +0x0fa */
	.ascii	"dos.library"
	.byte	0
_s_utility:				/* +0x106 */
	.ascii	"utility.library"
	.byte	0

|| ----------------------------------------------------------------
|| openlibs(base@12(sp)) -> d0  (helper, +0x116)
|| ----------------------------------------------------------------

_openlibs:
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%sp@(12),%a2
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
7:	clrl	%d0
8:	moveal	%sp@+,%a2
	moveal	%sp@+,%a6
	rts

|| ----------------------------------------------------------------
|| closelibs(base@12(sp))  (helper, +0x168)
|| ----------------------------------------------------------------

_closelibs:
	movel	%a6,%sp@-
	movel	%a2,%sp@-
	moveal	%sp@(12),%a2
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

|| ----------------------------------------------------------------
|| ".info" suffix literal (+0x19a)
|| ----------------------------------------------------------------

_s_info:				/* +0x19a */
	.ascii	".info"
	.byte	0

|| ----------------------------------------------------------------
|| trylock(name@280(sp)) -> d0  (+0x1a0)
||   Lock(name,ACCESS_READ); on failure build "name.info" in a
||   256-byte stack buffer (strncpy + strncat) and Lock it.
|| ----------------------------------------------------------------

	.globl	_trylock
_trylock:				/* +0x1a0 */
	addaw	#-260,%sp
	moveml	%d2-%d3/%a2/%a6,%sp@-
	movel	%sp@(280),%d3		/* name */
	moveal	%a6,%a2
	moveal	%a2@(52),%a6		/* DosBase */
	movel	%d3,%d1
	moveq	#-2,%d2			/* ACCESS_READ */
	jsr	%a6@(-84)		/* Lock(name) */
	tstl	%d0
	bnes	10f
	pea	0x100
	movel	%d3,%sp@-
	moveq	#24,%d3
	addl	%sp,%d3			/* 0xd68f: add.l a7,d3; buf */
	movel	%d3,%sp@-
	.short	0x4eb9			/* jsr abs.l (gas would relax */
	.long	_strncpy		/*  a .text symbol to jsr pc@) */
	pea	0x100
	pea	%pc@(_s_info)
	movel	%d3,%sp@-
	.short	0x4eb9			/* jsr abs.l */
	.long	_strncat
	addaw	#24,%sp
	moveal	%a2@(52),%a6
	movel	%d3,%d1
	jsr	%a6@(-84)		/* Lock("name.info") */
10:	moveml	%sp@+,%d2-%d3/%a2/%a6
	addaw	#260,%sp
	rts

|| ----------------------------------------------------------------
|| startobj(name@76(sp)=a4, wbtags@80(sp)=d5, a6=base) (+0x1f8)
||   a3=base  a5=ret  d3=lock  d2=node/oldcd  d4=oldcd2
||   d6=wbctrl taglist ptr  a2=&trylock (bare-name path)
||
||   name with ':' + tail  -> Lock(dev:dir) -> ParentDir ->
||     CurrentDir -> FilePart -> OWO -> restore
||   name ending ':'       -> OWO direct
||   bare name             -> trylock; fail -> walk Workbench
||     search path (WBCTRLA_DuplicateSearchPath), PrintFault on
||     miss, WBCTRLA_FreeSearchPath afterwards
|| ----------------------------------------------------------------

	.globl	_startobj
_startobj:				/* +0x1f8 */
	addaw	#-32,%sp
	moveml	%d2-%d6/%a2-%a6,%sp@-
	moveal	%sp@(76),%a4		/* name */
	movel	%sp@(80),%d5		/* wbtags */
	moveal	%a6,%a3
	moveal	%a4,%a0
	lea	0x0,%a5			/* ret = 0 (abs.w form) */
	tstb	%a4@
	beqs	20f			/* empty name: bare path */

|| --- scan name for ':' -------------------------------------------

11:	cmpib	#58,%a0@+		/* ':' */
	bnes	12f
	tstb	%a0@
	beqs	13f			/* "dev:" -> OWO direct */
	movel	%a4,%sp@-
	moveal	%a3,%a6
	bsrw	_trylock
	movel	%d0,%d3
	addql	#4,%sp
	bnes	14f			/* lock ok: dev:dir path */
	clrl	%d0
	braw	21f			/* return 0 */
12:	tstb	%a0@
	bnes	11b

|| --- bare name: try lock, else search path ------------------------

20:	movel	%a4,%sp@-
	lea	%pc@(_trylock),%a2
	moveal	%a3,%a6
	jsr	%a2@
	movel	%d0,%d3
	addql	#4,%sp
	beqw	22f			/* not found: search path */
	moveal	%a3@(44),%a6		/* WorkbenchBase */
	moveal	%a4,%a0
	moveal	%d5,%a1
	jsr	%a6@(-96)		/* OpenWorkbenchObjectA */
	moveaw	%d0,%a5
	moveal	%a3@(52),%a6
	movel	%d3,%d1
	jsr	%a6@(-90)		/* UnLock */
	braw	23f

|| --- "dev:" (nothing after colon): OWO direct ---------------------

13:	moveal	%a3@(44),%a6
	moveal	%a4,%a0
	moveal	%d5,%a1
	jsr	%a6@(-96)		/* OpenWorkbenchObjectA */
	extl	%d0
	braw	21f

|| --- "dev:dir/file": parent-dir cd + FilePart + OWO ---------------

14:	moveal	%a3@(52),%a6		/* DosBase */
	movel	%d3,%d1
	jsr	%a6@(-210)		/* ParentDir */
	moveal	%a3@(52),%a6
	movel	%d0,%d1
	jsr	%a6@(-126)		/* oldcd = CurrentDir(parent) */
	movel	%d0,%d2
	moveal	%a3@(52),%a6
	movel	%a4,%d1
	jsr	%a6@(-870)		/* FilePart(name) */
	moveal	%a3@(44),%a6
	moveal	%d0,%a0
	moveal	%d5,%a1
	jsr	%a6@(-96)		/* OpenWorkbenchObjectA(file) */
	moveaw	%d0,%a5
	moveal	%a3@(52),%a6
	movel	%d2,%d1
	jsr	%a6@(-126)		/* CurrentDir(oldcd) */
	moveal	%a3@(52),%a6
	movel	%d0,%d1
	jsr	%a6@(-90)		/* UnLock(parent) */
	moveal	%a3@(52),%a6
	movel	%d3,%d1
	jsr	%a6@(-90)		/* UnLock(orig) */
	braw	23f

|| --- search path exhausted: IoErr + PrintFault --------------------

15:	moveal	%a3@(52),%a6
	jsr	%a6@(-132)		/* IoErr */
	moveal	%a3@(52),%a6
	movel	%d0,%d1
	movel	%a4,%d2
	jsr	%a6@(-474)		/* PrintFault(err,name) */
	braw	24f

|| --- WBCTRLA_DuplicateSearchPath + walk ---------------------------

22:	clrl	%sp@(40)		/* result cell */
	movel	#0x8000a013,%sp@(44)	/* WBCTRLA_DuplicateSearchPath */
	lea	%sp@(40),%a0
	movel	%a0,%sp@(48)		/* &result */
	clrl	%sp@(52)
	movel	%sp@(44),%sp@(56)	/* copy tag item to sp+56 */
	movel	%a0,%sp@(60)
	movel	%sp@(52),%sp@(64)	/* TAG_DONE */
	moveq	#56,%d2
	addl	%sp,%d2			/* 0xd48f: taglist = sp+56 */
	moveal	%a3@(44),%a6
	lea	0x0,%a0
	moveal	%d2,%a1
	jsr	%a6@(-108)		/* WorkbenchControlA */
	movel	%sp@(40),%d0		/* path BPTR list */
	movel	%d2,%d6			/* keep taglist ptr */
	tstl	%d0
	beqw	23f
	movel	%d0,%d2
	lsll	#2,%d2			/* BPTR -> APTR */
	bras	26f
25:	moveal	%a3@(52),%a6
	movel	%d4,%d1
	jsr	%a6@(-126)		/* CurrentDir(prev old) */
	moveal	%d2,%a0
	movel	%a0@,%d2		/* next BPTR */
	lsll	#2,%d2
	beqs	15b			/* list end: fault */
26:	moveal	%a3@(52),%a6
	moveal	%d2,%a0
	movel	%a0@(4),%d1		/* node->sp_Lock */
	jsr	%a6@(-126)		/* CurrentDir(node lock) */
	movel	%d0,%d4
	movel	%a4,%sp@-
	moveal	%a3,%a6
	jsr	%a2@			/* trylock(name) */
	movel	%d0,%d3
	addql	#4,%sp
	beqs	25b			/* miss: next node */
	moveal	%a3@(44),%a6
	moveal	%a4,%a0
	moveal	%d5,%a1
	jsr	%a6@(-96)		/* OpenWorkbenchObjectA */
	moveaw	%d0,%a5
	moveal	%a3@(52),%a6
	movel	%d4,%d1
	jsr	%a6@(-126)		/* CurrentDir(old) */
	moveal	%a3@(52),%a6
	movel	%d3,%d1
	jsr	%a6@(-90)		/* UnLock */

24:	movel	#0x8000a014,%sp@(56)	/* WBCTRLA_FreeSearchPath */
	movel	%sp@(40),%sp@(60)
	clrl	%sp@(64)
	moveal	%d6,%a0
	movel	%a0@,%sp@(44)		/* copy rebuilt tag back */
	movel	%sp@(60),%sp@(48)
	movel	%sp@(64),%sp@(52)
	moveal	%a3@(44),%a6
	lea	0x0,%a0
	lea	%sp@(44),%a1
	jsr	%a6@(-108)		/* WorkbenchControlA */
23:	movel	%a5,%d0
21:	moveml	%sp@+,%d2-%d6/%a2-%a6
	addaw	#32,%sp
	rts

|| ----------------------------------------------------------------
|| LVO -36 WBStart(a0=taglist) -> d0 0 ok / 20 fail (+0x3ba)
||
||  d6 name   d4 lock   d3 nargs   a3 args   d7 oldcd
||  a2 base   a4 ret(20)  d5 = sp+40 = &tagitem-store / wbtags
|| ----------------------------------------------------------------

	.globl	_WBStart
_WBStart:				/* +0x3ba */
	subqw	#8,%sp
	moveml	%d2-%d7/%a2-%a4/%a6,%sp@-
	movel	%a0,%sp@(40)
	moveal	%a6,%a2
	lea	0x0,%a3			/* args = NULL (abs.w form) */
	clrl	%d6
	clrl	%d4
	clrl	%d3
	moveaw	#20,%a4			/* RETURN_FAIL */
	moveq	#40,%d5
	addl	%sp,%d5			/* 0xda8f: add.l a7,d5 */
	bras	30f

|| --- tag dispatch: ti_Tag - TAG_USER - 1 -> jump table ------------

31:	movel	%a0@(4),%d2		/* ti_Data */
	movel	%a0@,%d0		/* ti_Tag */
	addil	#0x7fffffff,%d0		/* tag - 0x80000001 */
	moveq	#6,%d1
	cmpl	%d0,%d1
	bcss	30f			/* out of range: ignore */
	.short	0x303b,0x0a06		/* movew pc@(6,d0:l*2),d0 */
	.short	0x4efb,0x0002		/* jmp pc@(2,d0:w) -> jtab */
_jtab:	.short	0x000e			/* tag+1 name   -> +0x402 */
	.short	0x0012			/* tag+2 lock   -> +0x406 */
	.short	0x0030			/* tag+3 duplock-> +0x424 */
	.short	0x0052			/* tag+4 ignore -> +0x446 */
	.short	0x0052			/* tag+5 ignore -> +0x446 */
	.short	0x004c			/* tag+6 nargs  -> +0x440 */
	.short	0x0050			/* tag+7 args   -> +0x444 */

|| --- +0x402  tag+1 WBSTARTA_Name ---------------------------------

	movel	%d2,%d6			/* name = ti_Data */
	bras	30f

|| --- +0x406  tag+2 WBSTARTA_Lock (path string) -------------------

	tstl	%d2
	beqs	30f
	moveal	%a2@(52),%a6		/* DosBase */
	movel	%d4,%d1
	jsr	%a6@(-90)		/* UnLock(old) */
	moveal	%a2@(52),%a6
	movel	%d2,%d1
	moveq	#-2,%d2			/* ACCESS_READ */
	jsr	%a6@(-84)		/* Lock(path) */
	movel	%d0,%d4
	bras	30f

|| --- +0x424  tag+3 WBSTARTA_DupLock (BPTR) ------------------------

	tstl	%d2
	beqs	30f
	moveal	%a2@(52),%a6
	movel	%d4,%d1
	jsr	%a6@(-90)		/* UnLock(old) */
	moveal	%a2@(52),%a6
	movel	%d2,%d1
	jsr	%a6@(-96)		/* DupLock */
	movel	%d0,%d4
	bras	30f

|| --- +0x440  tag+6 WBSTARTA_NumArgs / +0x444 tag+7 WBSTARTA_Args --

	movel	%d2,%d3			/* nargs */
	bras	30f
	moveal	%d2,%a3			/* args  (falls into loop) */

|| --- +0x446  NextTagItem loop tail --------------------------------

30:	moveal	%a2@(48),%a6		/* UtilityBase */
	moveal	%d5,%a0			/* &tagitem-store */
	jsr	%a6@(-48)		/* NextTagItem */
	moveal	%d0,%a0
	.short	0x4a88			/* tstl a0 */
	bnes	31b

|| --- end of tag list ----------------------------------------------

	tstl	%d6
	beqw	40f			/* no name: return 20 (word!) */
	tstl	%d3
	beqs	41f			/* no args */
	.short	0x4a8b			/* tstl a3 */
	beqs	41f
	movel	%d3,%d0
	addql	#1,%d0
	moveal	%a2@(40),%a6		/* SysBase */
	lsll	#4,%d0			/* (nargs+1)*16 */
	clrl	%d1			/* MEMF_ANY */
	jsr	%a6@(-684)		/* AllocVec */
	movel	%d0,%sp@(40)		/* wbtags */
	moveal	%d0,%a0
	.short	0x4a88			/* tstl a0 */
	beqs	42f
43:	movel	#0x8000a010,%a0@	/* WBOPENA_ArgLock */
	movel	%a3@,%a0@(4)
	addql	#8,%a0
	movel	#0x8000a011,%a0@	/* WBOPENA_ArgName */
	movel	%a3@(4),%a0@(4)
	addql	#8,%a0
	addql	#8,%a3
	subql	#1,%d3
	bnes	43b
	clrl	%a0@			/* TAG_DONE */
	bras	44f
42:	moveq	#-1,%d0			/* alloc fail: -1 marker */
	movel	%d0,%sp@(40)
	bras	44f
41:	clrl	%sp@(40)		/* no wbtags */
44:	moveq	#-1,%d1
	cmpl	%sp@(40),%d1
	beqs	40f			/* alloc failed: bail */
	tstl	%d4
	beqs	45f
	moveal	%a2@(52),%a6		/* DosBase */
	movel	%d4,%d1
	jsr	%a6@(-126)		/* oldcd = CurrentDir(lock) */
	movel	%d0,%d7
45:	movel	%sp@(40),%sp@-		/* wbtags */
	movel	%d6,%sp@-		/* name */
	moveal	%a2,%a6
	bsrw	_startobj
	addql	#8,%sp
	tstl	%d0
	beqs	46f
	lea	0x0,%a4			/* success: ret 0 (abs.w) */
46:	tstl	%d4
	beqs	47f
	moveal	%a2@(52),%a6
	movel	%d7,%d1
	jsr	%a6@(-126)		/* CurrentDir(oldcd) */
47:	moveal	%a2@(40),%a6
	moveal	%sp@(40),%a1
	jsr	%a6@(-690)		/* FreeVec(wbtags) */
40:	moveal	%a2@(52),%a6
	movel	%d4,%d1
	jsr	%a6@(-90)		/* UnLock(lock) */
	movel	%a4,%d0
	moveml	%sp@+,%d2-%d7/%a2-%a4/%a6
	addqw	#8,%sp
	rts
	.short	0			/* +0x50a pad word */

|| ----------------------------------------------------------------
|| dead libc-style string routines (+0x50c..0x599)
||  strcat / strncat / strcpy / strncpy -- link/unlk framed,
||  args at a5@(8),(12),(16); only strncat+strncpy are called
||  (by trylock, via absolute jsr); strcat+strcpy are dead.
|| ----------------------------------------------------------------

_strcat:				/* +0x50c */
	linkw	%a5,#0
	movel	%a5@(8),%d0
	moveal	%a5@(12),%a1
	moveal	%d0,%a0
50:	tstb	%a0@+
	bnes	50b
	subql	#1,%a0
51:	moveb	%a1@+,%a0@
	tstb	%a0@+
	bnes	51b
	unlk	%a5
	rts

_strncat:				/* +0x52a */
	linkw	%a5,#0
	movel	%a5@(8),%d0
	moveal	%a5@(12),%a1
	movel	%a5@(16),%d1
	moveal	%d0,%a0
52:	tstb	%a0@+
	bnes	52b
	subql	#1,%a0
	addql	#1,%d1
53:	subql	#1,%d1
	beqs	54f
	moveb	%a1@+,%a0@
	tstb	%a0@+
	bnes	53b
	bras	55f
54:	clrb	%a0@
55:	unlk	%a5
	rts
	.short	0			/* +0x556 pad word */

_strcpy:				/* +0x558 */
	linkw	%a5,#0
	movel	%a5@(8),%d0
	moveal	%a5@(12),%a1
	moveal	%d0,%a0
56:	moveb	%a1@+,%a0@
	tstb	%a0@+
	bnes	56b
	unlk	%a5
	rts

_strncpy:				/* +0x570 */
	linkw	%a5,#0
	movel	%a5@(8),%d0
	moveal	%a5@(12),%a1
	moveal	%d0,%a0
	movel	%a5@(16),%d1
	addql	#1,%d1
57:	subql	#1,%d1
	beqs	60f
	moveb	%a1@+,%a0@
	tstb	%a0@+
	bnes	57b
	bras	59f
58:	clrb	%a0@+
59:	subql	#1,%d1
	bnes	58b
60:	unlk	%a5
	rts
	.short	0,0,0,0,2		/* +0x59a tail: 4 zero words + 2 */

|| ================================================================
|| DATA hunk (hunk 1): functab, strings, InitTable, RomTag, EndSkip
|| ================================================================

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
	.ascii	"wbstart.library 45.2 (16.07.01) Emulation by Stephan Rupprecht"
	.byte	0,0

|| InitTable at +0x6c: dataSize, funcTable, dataTable(0), initFunc

_inittab:
	.long	0x38			/* sizeof(WBStartBase) */
	.long	_functab
	.long	0			/* no InitStruct data */
	.long	_LibInit

_romtag:				/* +0x7c */
	.short	0x4afc			/* RT_MATCHWORD */
	.long	_romtag			/* RT_MATCHTAG */
	.long	_endskip		/* RT_ENDSKIP */
	.byte	0x80			/* RTF_AUTOINIT */
	.globl	_rtversion
_rtversion:				/* +0x87 */
	.byte	2			/* RT_VERSION = 2 (repatched) */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* RT_PRI */
	.long	_libname		/* RT_NAME */
	.long	_idstr			/* RT_IDSTRING */
	.long	_inittab		/* RT_INIT */
_endskip:				/* +0x96 */
	.short	0
