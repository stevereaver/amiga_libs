/*
 * dospath.library 1.0 (25.8.96) -- assembly reconstruction
 * of binary/dospath_1.0.library
 *
 *   $VER: dospath.library 1.0 (25.8.96)
 *
 * Compiled-C library (linkw-style frames). dos.library lock/device-list
 * path resolution. Clone-per-open library (Open returns a fresh lib made
 * by MakeLibrary with dos.library+utility.library bases in lib+36/40).
 *
 * Hunks: h0 CODE 2464B; h1 DATA 12B alloc / 4B body (header table
 * long patched to 3 by fixup.py).
 * Globals hunk h1: +0 libbase, +4 seglist, +8 sysbase; reached via
 * a4 = h1+0x7ffe with negative displacements
 *   a4@(-32758)=h1+8 (sysbase) a4@(-32762)=h1+4 (seglist)
 *   a4@(-32766)=h1+0 (libbase)
 * lea h1+0x7ffe,a4 sites carry the 12 h0->h1 RELOC32 relocs.
 */
	.file	"dospath.s"
	.text
	.globl	_start
_start:
	moveq	#0,%d0				/* 0x000 dead stub */
	rts
_name:
	.ascii	"dospath.library"
	.byte	0				/* 0x004..0x013 */
_idstr:
	.ascii	"$VER: dospath.library 1.0 (25.8.96)"
	.byte	13,10,0				/* 0x014..0x039 */
_romtag:					/* 0x03a */
	.short	0x4afc
	.long	_romtag				/* rt_MatchTag 0x3c */
	.long	_functab			/* rt_EndSkip 0x40 ->0x54 */
	.byte	0,1,9,0				/* COLDSTART v1 NT_LIBRARY */
	.long	_name				/* 0x48 */
	.long	_idstr				/* 0x4c */
	.long	_init				/* 0x50 */
_functab:					/* 0x54 */
	.long	_open				/* -6  0x14e */
	.long	_close				/* -12 0x1ee */
	.long	_expunge			/* -18 0x264 */
	.long	_ret0				/* -24 0x2a2 */
	.long	_ret0				/* -30 0x2a2 */
	.long	_freelist			/* -36 0x71c */
	.long	_f628				/* -42 */
	.long	_f59a				/* -48 */
	.long	_f768				/* -54 */
	.long	_f894				/* -60 */
	.long	_f82e				/* -66 */
	.long	_f856				/* -72 */
	.long	_f918				/* -78 */
	.long	0xffffffff			/* 0x088 */
	.short	0				/* 0x08c pad */

/* ---- _makelib (0x08e): MakeLibrary helper ------------------------ */
_makelib:
	moveml	%a2-%a3/%a6,%sp@-
	lea	%pc@(_functab),%a0
	subal	%a1,%a1
	subal	%a2,%a2
	moveq	#44,%d0
	moveq	#0,%d1
	moveal	%a4@(-32758),%a6		/* sysbase */
	jsr	%a6@(-84)			/* MakeLibrary */
	moveal	%d0,%a3
	movel	%a3,%d1
	beqs	1f
	moveb	#9,%a3@(8)			/* ln_Type=NT_LIBRARY */
	lea	%pc@(_name),%a6
	movel	%a6,%a3@(10)
	moveb	#6,%a3@(14)			/* lib_Flags */
	movew	#1,%a3@(20)
	movew	#0,%a3@(22)
	lea	%pc@(_idstr),%a6
	movel	%a6,%a3@(24)
1:	movel	%a3,%d0
	moveml	%sp@+,%a2-%a3/%a6
	rts					/* 0x0da */

/* ---- _freemem (0x0dc): FreeMem(lib-neg, neg+pos) ----------------- */
_freemem:
	moveml	%d2/%a3/%a6,%sp@-
	moveal	%a0,%a3
	moveq	#0,%d0
	movew	%a3@(16),%d0
	moveal	%a3,%a1
	subal	%d0,%a1
	moveq	#0,%d1
	movew	%a3@(16),%d1
	moveq	#0,%d2
	movew	%a3@(18),%d2
	movel	%d1,%d0
	addl	%d2,%d0
	moveal	%a4@(-32758),%a6
	jsr	%a6@(-210)			/* FreeMem */
	moveml	%sp@+,%d2/%a3/%a6
	rts					/* 0x108 */

/* ---- _init (0x10a): rt_Init -------------------------------------- */
_init:
	moveml	%d7/%a3-%a4,%sp@-
	movel	%a0,%d7				/* seglist */
	lea	_globs+0x7ffe,%a4
	subal	%a3,%a3
	cmpiw	#37,%a6@(20)
	bcss	1f
	movel	%a6,%a4@(-32758)		/* sysbase */
	bsrw	_makelib
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	1f
	moveal	%a3,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-396)			/* AddLibrary */
	moveal	%sp@+,%a6
	movel	%a3,%a4@(-32766)		/* h1+0 libbase */
	movel	%d7,%a4@(-32762)		/* h1+4 seglist */
1:	movel	%a3,%d0
	moveml	%sp@+,%d7/%a3-%a4
	rts					/* 0x14c */

/* ---- _open (0x14e): clone-per-open ------------------------------- */
_open:
	moveml	%a3-%a4,%sp@-
	lea	_globs+0x7ffe,%a4
	bsrw	_makelib
	moveal	%d0,%a3
	movel	%a3,%d0
	beqw	4f
	lea	%pc@(_dosname),%a1		/* 0x2b6 */
	moveq	#37,%d0
	movel	%a4@(-32758),%d1
	movel	%a6,%sp@-
	moveal	%d1,%a6
	jsr	%a6@(-552)			/* OpenLibrary */
	movel	%d0,%a3@(36)
	moveal	%sp@+,%a6
	tstl	%a3@(36)
	beqs	2f
	lea	%pc@(_utilname),%a1		/* 0x2a6 */
	moveq	#37,%d0
	movel	%a4@(-32758),%d1
	movel	%a6,%sp@-
	moveal	%d1,%a6
	jsr	%a6@(-552)			/* OpenLibrary */
	movel	%d0,%a3@(40)
	moveal	%sp@+,%a6
	tstl	%a3@(40)
	beqs	3f
	moveal	%a3,%a1
	movel	%a4@(-32758),%d1
	movel	%a6,%sp@-
	moveal	%d1,%a6
	jsr	%a6@(-426)			/* SumLibrary */
	moveal	%sp@+,%a6
	addqw	#1,%a6@(32)			/* caller opencnt++ */
	movew	#1,%a3@(32)			/* clone opencnt=1 */
	bclr	#3,%a6@(14)			/* clear DELEXP */
	bras	4f
3:	moveal	%a3@(36),%a1
	movel	%a4@(-32758),%d1
	movel	%a6,%sp@-
	moveal	%d1,%a6
	jsr	%a6@(-414)			/* CloseLibrary */
	moveal	%sp@+,%a6
	moveal	%a3,%a0
	bsrw	_freemem
	subal	%a3,%a3
	bras	4f
2:	moveal	%a3,%a0
	bsrw	_freemem
	subal	%a3,%a3
4:	movel	%a3,%d0
	moveml	%sp@+,%a3-%a4
	rts					/* 0x1ec */

/* ---- _close (0x1ee) ---------------------------------------------- */
_close:
	moveml	%d7/%a4,%sp@-
	lea	_globs+0x7ffe,%a4
	moveq	#0,%d7
	moveal	%a6@(40),%a1			/* clone's utility base */
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-414)			/* CloseLibrary */
	moveal	%sp@+,%a6
	moveal	%a6@(36),%a1			/* clone's dos base */
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-414)			/* CloseLibrary */
	moveal	%sp@+,%a6
	moveal	%a6,%a0
	bsrw	_freemem				/* free the clone */
	moveal	%a4@(-32766),%a0
	cmpiw	#0,%a0@(32)
	blss	1f				/* opencnt<0: skip */
	moveal	%a4@(-32766),%a0
	subqw	#1,%a0@(32)
	tstw	%a0@(32)
	bnes	1f
	moveal	%a4@(-32766),%a0
	moveq	#0,%d0
	moveb	%a0@(14),%d0
	btst	#3,%d0				/* DELEXP? */
	beqs	1f
	movel	%a4@(-32766),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	bsrs	_expunge
	movel	%d0,%d7
	moveal	%sp@+,%a6
1:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a4
	rts					/* 0x262 */

/* ---- _expunge (0x264) -------------------------------------------- */
_expunge:
	moveml	%d7/%a4,%sp@-
	lea	_globs+0x7ffe,%a4
	moveq	#0,%d7
	cmpiw	#0,%a6@(32)
	blss	1f				/* opencnt<0 -> expunge now */
	bset	#3,%a6@(14)			/* DELEXP */
	bras	2f
1:	lea	%a6@,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-252)			/* Remove */
	moveal	%sp@+,%a6
	movel	%a4@(-32762),%d7		/* seglist */
	moveal	%a6,%a0
	bsrw	_freemem
2:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a4
	rts					/* 0x2a0 */

_ret0:	moveq	#0,%d0				/* 0x2a2 */
	rts
_utilname:
	.ascii	"utility.library"
	.byte	0				/* 0x2a6..0x2b5 */
_dosname:
	.ascii	"dos.library"
	.byte	0				/* 0x2b6..0x2c1 */
	nop					/* 0x2c2 */

/* ---- _f2c4: lock-array -> linked {flag,lock} list ----------------
   a0 = ptr to array of name ptrs, a1 = &head (or 0), d0 = clone base */
_f2c4:
	moveml	%d2-%d3/%a2-%a3/%a6,%sp@-
	moveal	%a1,%a3
	linkw	%a5,#-24
	movel	%a0,%a5@(-4)			/* array ptr */
	movel	%d0,%a5@(-8)			/* libbase */
	subal	%a2,%a2
	tstl	%a5@(-4)
	beqw	10f
	moveal	%a5@(-8),%a0
	movel	%a0@(36),%a5@(-12)		/* dos base */
	moveq	#2,%d1				/* ADO_FHB */
	moveq	#0,%d2
	moveal	%a5@(-12),%a6
	jsr	%a6@(-228)			/* AllocDosObject */
	movel	%d0,%a5@(-16)			/* fib */
	tstl	%a5@(-16)
	beqw	10f
	movel	%a3,%d2
	beqs	1f
	movel	%a3@,%a5@(-20)			/* *head -> last-link ptr */
	bras	2f
1:	moveq	#0,%d2
	movel	%d2,%a5@(-20)
2:	subal	%a6,%a6				/* cur node = 0 */
	braw	7f
3:	moveq	#0,%d2
	cmpl	%a6,%d2
	bnes	4f
	moveq	#8,%d0
	moveq	#1,%d1				/* MEMF_PUBLIC */
	moveal	%a4@(-32758),%a6
	jsr	%a6@(-684)			/* AllocVec */
	moveal	%d0,%a6
	movel	%a6,%d1
	beqw	8f
4:	movel	%a5@(-24),%d1			/* name str */
	moveq	#-2,%d2				/* SHARED_LOCK */
	movel	%a5@(-12),%d3
	exg	%d3,%a6
	jsr	%a6@(-84)			/* Lock */
	exg	%d3,%a6
	movel	%d0,%a6@(4)			/* node->lock */
	tstl	%a6@(4)
	beqw	7f
	movel	%a6@(4),%d1
	movel	%a5@(-16),%d2			/* fib */
	movel	%a5@(-12),%d3
	exg	%d3,%a6
	jsr	%a6@(-102)			/* Examine */
	exg	%d3,%a6
	tstl	%d0
	beqs	5f
	moveal	%a5@(-16),%a0
	tstl	%a0@(4)				/* fib DirEntryType > 0? */
	bles	5f
	moveq	#0,%d0
	movel	%d0,%a6@				/* node->flag=0 */
	movel	%a2,%d0
	bnes	6f
	moveal	%a6,%a2				/* first node */
6:	tstl	%a5@(-20)
	beqs	6f
	moveal	%a5@(-20),%a0
	movel	%a6,%d0
	asrl	#2,%d0				/* BPTR link */
	movel	%d0,%a0@
6:	movel	%a6,%a5@(-20)
	subal	%a6,%a6
	bras	7f
5:	movel	%a6@(4),%d1
	movel	%a5@(-12),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-90)			/* UnLock */
	moveal	%sp@+,%a6
	bras	7f
8:	moveal	%a2,%a0				/* alloc fail: free list */
	movel	%a5@(-8),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	bsrw	_freelist
	moveal	%sp@+,%a6
	subal	%a2,%a2
	movel	%a3,%d0
	beqs	9f
	tstl	%a3@
	beqs	9f
	moveal	%a3@,%a0
	moveq	#0,%d0
	movel	%d0,%a0@				/* *head->next=0 */
	bras	9f
7:	moveal	%a5@(-4),%a0			/* next name */
	addql	#4,%a5@(-4)
	movel	%a0@,%a5@(-24)
	tstl	%a5@(-24)
	bnew	3b
9:	movel	%a6,%d0				/* free pending node */
	beqs	9f
	moveal	%a6,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-690)			/* FreeVec */
	moveal	%sp@+,%a6
9:	movel	%a3,%d0
	beqs	9f
	movel	%a2,%d0
	beqs	9f
	movel	%a5@(-20),%a3@			/* *head = last */
9:	moveq	#2,%d1				/* ADO_FHB */
	movel	%a5@(-16),%d2
	movel	%a5@(-12),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-234)			/* FreeDosObject */
	moveal	%sp@+,%a6
10:	movel	%a2,%d0
	unlk	%a5
	moveml	%sp@+,%d2-%d3/%a2-%a3/%a6
	rts					/* 0x41a */

/* ---- _f41c: BPTR lock list -> {flag,lock} via DupLock -------------
   a0 = &BPTR list head, a1 = &head (or 0), d0 = clone base */
_f41c:
	moveml	%d2-%d3/%a2-%a3/%a6,%sp@-
	linkw	%a5,#-28
	movel	%a0,%a5@(-4)
	movel	%a1,%a5@(-8)
	movel	%d0,%a5@(-12)
	subal	%a3,%a3
	tstl	%a5@(-4)
	beqw	10f
	moveal	%a5@(-12),%a0
	movel	%a0@(36),%a5@(-16)		/* dos base */
	moveq	#2,%d1
	moveq	#0,%d2
	moveal	%a5@(-16),%a6
	jsr	%a6@(-228)			/* AllocDosObject */
	movel	%d0,%a5@(-20)			/* fib */
	tstl	%a5@(-20)
	beqw	10f
	tstl	%a5@(-8)
	beqs	1f
	moveal	%a5@(-8),%a0
	movel	%a0@,%a5@(-24)
	bras	2f
1:	moveq	#0,%d2
	movel	%d2,%a5@(-24)
2:	subal	%a2,%a2
	moveal	%a5@(-4),%a0
	moveal	%a0@,%a6				/* first BPTR (<<2? raw) */
	braw	8f
3:	movel	%a6@(10),%a5@(-28)		/* node +10 */
	tstl	%a5@(-28)
	beqw	7f
	moveq	#0,%d2
	cmpl	%a2,%d2
	bnes	4f
	moveq	#8,%d0
	moveq	#1,%d1
	movel	%a4@(-32758),%d2
	exg	%d2,%a6
	jsr	%a6@(-684)			/* AllocVec */
	moveal	%d0,%a2
	exg	%d2,%a6
	movel	%a2,%d2
	beqw	9f
4:	movel	%a5@(-28),%d1
	moveq	#-2,%d2
	movel	%a5@(-16),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-84)			/* Lock */
	movel	%d0,%a2@(4)
	moveal	%sp@+,%a6
	tstl	%a2@(4)
	beqw	7f
	movel	%a2@(4),%d1
	movel	%a5@(-20),%d2			/* fib */
	movel	%a5@(-16),%d3
	exg	%d3,%a6
	jsr	%a6@(-102)			/* Examine */
	exg	%d3,%a6
	tstl	%d0
	beqs	5f
	moveal	%a5@(-20),%a0
	tstl	%a0@(4)
	bles	5f
	moveq	#0,%d0
	movel	%d0,%a2@
	movel	%a3,%d0
	bnes	6f
	moveal	%a2,%a3
6:	tstl	%a5@(-24)
	beqs	6f
	moveal	%a5@(-24),%a0
	movel	%a2,%d0
	asrl	#2,%d0
	movel	%d0,%a0@
6:	movel	%a2,%a5@(-24)
	subal	%a2,%a2
	bras	7f
5:	movel	%a2@(4),%d1
	movel	%a5@(-16),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-90)			/* UnLock */
	moveal	%sp@+,%a6
	bras	7f
9:	moveal	%a3,%a0				/* alloc fail */
	movel	%a5@(-12),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	bsrw	_freelist
	moveal	%sp@+,%a6
	subal	%a3,%a3
	tstl	%a5@(-8)
	beqs	6f
	moveal	%a5@(-8),%a0
	tstl	%a0@
	beqs	6f
	moveal	%a5@(-8),%a0
	moveal	%a0@,%a0
	moveq	#0,%d0
	movel	%d0,%a0@
	bras	6f
7:	moveal	%a6@,%a6				/* next BPTR */
8:	tstl	%a6@
	bnew	3b
6:	movel	%a2,%d0				/* free pending node */
	beqs	4f
	moveal	%a2,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-690)			/* FreeVec */
	moveal	%sp@+,%a6
4:	tstl	%a5@(-8)
	beqs	5f
	movel	%a3,%d0
	beqs	5f
	moveal	%a5@(-8),%a1
	movel	%a5@(-24),%a1@
5:	moveq	#2,%d1
	movel	%a5@(-20),%d2
	movel	%a5@(-16),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-234)			/* FreeDosObject */
	moveal	%sp@+,%a6
10:	movel	%a3,%d0
	unlk	%a5
	moveml	%sp@+,%d2-%d3/%a2-%a3/%a6
	rts					/* 0x598 */

/* ---- _f59a (-48): taglist walker ----------------------------------
   a0 = out-ptr, a1 = taglist, a6 = dospath lib */
_f59a:
	moveml	%a2-%a4/%a6,%sp@-
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-20
	movel	%a0,%a5@(-4)
	movel	%a1,%a5@(-8)
	movel	%a6,%a5@(-12)			/* libbase */
	subal	%a3,%a3
	tstl	%a5@(-8)
	beqs	9f
	moveal	%a5@(-12),%a0
	movel	%a0@(40),%a5@(-16)		/* utility base */
	movel	%a5@(-8),%a5@(-20)		/* tagptr */
	bras	8f
1:	subal	%a6,%a6
	movel	%a2@,%d0				/* ti_Tag */
	.short	0x90bc				/* subl #imm,d0 (generic SUB form) */
	.long	0x80001001
	beqs	2f
	subql	#1,%d0
	beqs	3f
	bras	4f
2:	moveal	%a2@(4),%a0			/* ti_Data */
	moveal	%a5@(-4),%a1
	movel	%a5@(-12),%d0
	bsrw	_f2c4				/* tag 0x80001001 */
	moveal	%d0,%a6
	bras	4f
3:	moveal	%a2@(4),%a0
	moveal	%a5@(-4),%a1
	movel	%a5@(-12),%d0
	bsrw	_f41c				/* tag 0x80001002 */
	moveal	%d0,%a6
4:	movel	%a3,%d0
	bnes	8f
	moveal	%a6,%a3				/* first result */
8:	lea	%a5@(-20),%a0
	moveal	%a5@(-16),%a6
	jsr	%a6@(-48)			/* NextTagItem */
	moveal	%d0,%a2
	movel	%a2,%d0
	bnes	1b
9:	movel	%a3,%d0
	unlk	%a5
	moveml	%sp@+,%a2-%a4/%a6
	rts					/* 0x626 */

/* ---- _f628 (-42): DupLock chain walker ---------------------------- */
_f628:
	moveml	%d2/%a2-%a4/%a6,%sp@-
	moveal	%a1,%a3
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-16
	movel	%a0,%a5@(-4)			/* node ptr */
	movel	%a6,%a5@(-8)			/* libbase */
	subal	%a2,%a2
	movel	%a3,%d0
	beqs	1f
	movel	%a3@,%a5@(-12)
	bras	2f
1:	moveq	#0,%d0
	movel	%d0,%a5@(-12)
2:	subal	%a6,%a6
	moveal	%a5@(-8),%a0
	movel	%a0@(36),%a5@(-16)		/* dos base */
	braw	7f
3:	moveq	#0,%d0
	cmpl	%a6,%d0
	bnes	4f
	moveq	#8,%d0
	moveq	#1,%d1
	moveal	%a4@(-32758),%a6
	jsr	%a6@(-684)			/* AllocVec */
	moveal	%d0,%a6
	movel	%a6,%d1
	beqs	8f
4:	moveal	%a5@(-4),%a0
	movel	%a0@(4),%d1			/* lock */
	movel	%a5@(-16),%d2
	exg	%d2,%a6
	jsr	%a6@(-96)			/* DupLock */
	exg	%d2,%a6
	movel	%d0,%a6@(4)
	tstl	%a6@(4)
	beqs	6f
	moveq	#0,%d0
	movel	%d0,%a6@
	movel	%a2,%d0
	bnes	5f
	moveal	%a6,%a2
5:	tstl	%a5@(-12)
	beqs	5f
	moveal	%a5@(-12),%a0
	movel	%a6,%d0
	asrl	#2,%d0
	movel	%d0,%a0@
5:	movel	%a6,%a5@(-12)
	subal	%a6,%a6
	bras	6f
8:	moveal	%a2,%a0				/* alloc fail */
	movel	%a5@(-8),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	bsrw	_freelist
	moveal	%sp@+,%a6
	subal	%a2,%a2
	movel	%a3,%d0
	beqs	9f
	tstl	%a3@
	beqs	9f
	moveal	%a3@,%a0
	moveq	#0,%d0
	movel	%d0,%a0@
	bras	9f
6:	moveal	%a5@(-4),%a0
	movel	%a0@,%d0
	asll	#2,%d0				/* next BPTR */
	movel	%d0,%a5@(-4)
7:	tstl	%a5@(-4)
	bnew	3b
9:	movel	%a6,%d0
	beqs	9f
	moveal	%a6,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-690)			/* FreeVec */
	moveal	%sp@+,%a6
9:	movel	%a3,%d0
	beqs	9f
	movel	%a2,%d0
	beqs	9f
	movel	%a5@(-12),%a3@
9:	movel	%a2,%d0
	unlk	%a5
	moveml	%sp@+,%d2/%a2-%a4/%a6
	rts					/* 0x718 */
	nop					/* 0x71a */

/* ---- _freelist (-36, 0x71c): UnLock+FreeVec each node ------------- */
_freelist:
	moveml	%a2-%a4/%a6,%sp@-
	moveal	%a0,%a3
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-4
	movel	%a6,%a5@(-4)			/* libbase */
	moveal	%a5@(-4),%a0
	moveal	%a0@(36),%a6			/* dos base */
	bras	2f
1:	movel	%a2@,%d0
	asll	#2,%d0				/* next node via BPTR */
	moveal	%d0,%a3
	movel	%a2@(4),%d1			/* lock */
	jsr	%a6@(-90)			/* UnLock */
	moveal	%a2,%a1
	movel	%a4@(-32758),%d1
	movel	%a6,%sp@-
	moveal	%d1,%a6
	jsr	%a6@(-690)			/* FreeVec */
	moveal	%sp@+,%a6
2:	moveal	%a3,%a2
	movel	%a2,%d1
	bnes	1b
	unlk	%a5
	moveml	%sp@+,%a2-%a4/%a6
	rts					/* 0x764 */
	nop					/* 0x766 */

/* ---- _f768 (-54): CurrentDir + Lock-chain node count -------------- */
_f768:
	moveml	%d2/%d5-%d7/%a2-%a4/%a6,%sp@-
	moveal	%a1,%a3
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-8
	movel	%a0,%a5@(-4)
	movel	%a6,%a5@(-8)
	moveal	%a5@(-8),%a0
	moveal	%a0@(36),%a2			/* dos base */
	moveq	#0,%d1
	moveal	%a2,%a6
	jsr	%a6@(-126)			/* CurrentDir */
	movel	%d0,%d7				/* old */
	moveq	#0,%d6
	movel	%a3,%d1
	beqs	6f
	tstl	%a5@(-4)
	beqs	6f
	moveal	%a5@(-4),%a0
	moveal	%a0@,%a6				/* first chain node */
	bras	4f
1:	movel	%a6@(4),%d1			/* node lock */
	movel	%a2,%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-126)			/* CurrentDir */
	moveal	%sp@+,%a6
	movel	%a3,%d1
	moveq	#-2,%d2
	movel	%a2,%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-84)			/* Lock(name,SHARED) */
	movel	%d0,%d5
	moveal	%sp@+,%a6
	tstl	%d5
	beqs	2f
	movel	%d5,%d1
	movel	%a2,%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-90)			/* UnLock */
	moveal	%sp@+,%a6
	movel	%a6@(4),%d6			/* keep lock value */
	bras	5f
2:	movel	%a6@,%d0
	asll	#2,%d0
	moveal	%d0,%a6				/* next */
4:	movel	%a6,%d5
	bnes	1b
5:	moveal	%a5@(-4),%a0
	movel	%a6,%d5
	beqs	3f
	movel	%a6@,%d0
	asll	#2,%d0
	movel	%d0,%d5
	movel	%d5,%a0@				/* store next */
	bras	6f
3:	moveq	#0,%d5
	movel	%d5,%a0@
6:	movel	%d7,%d1
	moveal	%a2,%a6
	jsr	%a6@(-126)			/* restore CurrentDir */
	movel	%d6,%d0
	unlk	%a5
	moveml	%sp@+,%d2/%d5-%d7/%a2-%a4/%a6
	rts					/* 0x810 */
	nop					/* 0x812 */

/* ---- _h814: DevNode type-13 -> vol list (leaf helper) ------------- */
_h814:
	cmpib	#13,%a0@(8)			/* dol_Type? */
	bnes	1f
	movel	%a0@(172),%d1			/* +0xac */
	asll	#2,%d1
	movel	%d1,%d0
	moveal	%d0,%a1
	bras	2f
1:	subal	%a1,%a1
2:	movel	%a1,%d0
	rts					/* 0x82c */

/* ---- _f82e (-66): node -> next volume ptr ------------------------- */
_f82e:
	moveml	%a2-%a4/%a6,%sp@-
	moveal	%a0,%a3
	lea	_globs+0x7ffe,%a4
	subal	%a6,%a6
	moveal	%a3,%a0
	bsrs	_h814
	moveal	%d0,%a2
	movel	%a2,%d0
	beqs	1f
	movel	%a2@(8),%d0
	asll	#2,%d0
	moveal	%d0,%a6
1:	movel	%a6,%d0
	moveml	%sp@+,%a2-%a4/%a6
	rts					/* 0x854 */

/* ---- _f856 (-72): node -> next vol ptr, write a1>>2 at +8 --------- */
_f856:
	moveml	%a2-%a4/%a6,%sp@-
	moveal	%a1,%a3
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-4
	movel	%a0,%a5@(-4)
	subal	%a6,%a6
	moveal	%a5@(-4),%a0
	bsrs	_h814
	moveal	%d0,%a2
	movel	%a2,%d0
	beqs	1f
	movel	%a2@(8),%d0
	asll	#2,%d0
	moveal	%d0,%a6
	movel	%a3,%d0
	asrl	#2,%d0
	movel	%d0,%a2@(8)
1:	movel	%a6,%d0
	unlk	%a5
	moveml	%sp@+,%a2-%a4/%a6
	rts					/* 0x890 */
	nop					/* 0x892 */

/* ---- _f894 (-60): SameLock chain prune ----------------------------
   a0 = node chain, a1 = lock; keeps node whose +4 lock SameLock's */
_f894:
	moveml	%d2-%d3/%d7/%a2-%a4/%a6,%sp@-
	moveal	%a0,%a3
	movel	%a1,%d7				/* lock */
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-8
	movel	%a6,%a5@(-4)			/* libbase */
	moveal	%a5@(-4),%a0
	movel	%a0@(36),%a5@(-8)		/* dos base */
	moveal	%a3,%a2				/* head result */
	subal	%a6,%a6				/* prev node */
	bras	4f
1:	movel	%a3@(4),%d1			/* node lock */
	movel	%d7,%d2
	movel	%a5@(-8),%d3
	exg	%d3,%a6
	jsr	%a6@(-420)			/* SameLock */
	exg	%d3,%a6
	tstl	%d0
	bnes	3f				/* same -> keep */
	movel	%a6,%d0				/* unlink+free node */
	beqs	2f
	movel	%a3@,%a6@				/* prev->next = cur->next */
	bras	6f
2:	movel	%a3@,%d0
	asll	#2,%d0
	moveal	%d0,%a2				/* head = next */
6:	movel	%a3@(4),%d1
	movel	%a5@(-8),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-90)			/* UnLock */
	moveal	%sp@+,%a6
	moveal	%a3,%a1
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-690)			/* FreeVec */
	moveal	%sp@+,%a6
	bras	5f
3:	moveal	%a3,%a6				/* prev = cur */
	movel	%a3@,%d0
	asll	#2,%d0
	moveal	%d0,%a3				/* cur = next */
4:	movel	%a3,%d0
	bnes	1b
5:	movel	%a2,%d0
	unlk	%a5
	moveml	%sp@+,%d2-%d3/%d7/%a2-%a4/%a6
	rts					/* 0x916 */

/* ---- _f918 (-78): Workbench/arg task -> f82e -> f628 -------------- */
_f918:
	moveml	%a2-%a4,%sp@-
	lea	_globs+0x7ffe,%a4
	linkw	%a5,#-8
	movel	%a0,%a5@(-4)
	movel	%a1,%a5@(-8)
	subal	%a2,%a2
	tstl	%a5@(-4)
	beqs	1f
	moveal	%a5@(-4),%a0
	moveal	%a0@(14),%a0
	moveal	%a0@(16),%a3
	bras	2f
1:	lea	%pc@(_wbname),%a1		/* 0x97a "Workbench" */
	movel	%a4@(-32758),%d0
	movel	%a6,%sp@-
	moveal	%d0,%a6
	jsr	%a6@(-294)			/* FindTask */
	moveal	%d0,%a0
	moveal	%sp@+,%a6
	moveal	%a0,%a3
2:	movel	%a3,%d0
	beqs	3f
	moveal	%a3,%a0
	bsrw	_f82e
	moveal	%d0,%a0
	moveal	%a5@(-8),%a1
	bsrw	_f628
	moveal	%d0,%a2
3:	movel	%a2,%d0
	unlk	%a5
	moveml	%sp@+,%a2-%a4
	rts					/* 0x978 */

_wbname:
	.ascii	"Workbench"
	.byte	0				/* 0x97a..0x983 */
	moveq	#0,%d0				/* 0x984 tail stubs */
	rts
	moveq	#1,%d0
	rts
	moveq	#0,%d0
	rts
	moveq	#1,%d0
	rts
	rts					/* 0x994 */
	nop
	rts
	nop
	rts
	nop					/* 0x99e */

/* ---- globals hunk (h1): libbase, seglist, sysbase ----------------- */
	.data
	.globl	_globs
_globs:
	.long	0				/* 4B body of 12B alloc */
