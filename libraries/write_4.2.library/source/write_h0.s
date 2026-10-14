/* write.library 4.2 -- Tim Teulings (7.11.95)
 * CODE hunk 0 reconstruction (0x868 bytes).
 * RomTag: AUTOINIT, ver 4, NT_LIBRARY pri 0.
 *   name    -> hunk1+0x24 "write.library"
 *   idstr   -> hunk1+0x34 "Version 1.0"
 *   init    -> hunk2+4  (5-field InitTable: pad,dsize,ftab,dtab,initfn)
 * Functab (hunk1): 8 vectors:
 *   -6  Open     @0x0d0   -12 Close   @0x1fe   -18 Expunge @0x268
 *   -24 Null     @0x000   -30 vec30   @0x2d8   -36 vec36   @0x356
 *   -42 vec42    @0x4c4   -48 vec48   @0x59c
 * Globals area a4 = lib+0x3c; a4@(96)=dosver arg, a4@(100)=rexxsyslib
 * base, a4@(104)=rexxsyslib alt, a4@(108)=dosbase, a4@(112)=dos alt.
 */

	.globl	_libname,_idstr,_open,_close,_expunge,_nullvec
	.globl	_vec30,_vec36,_vec42,_vec48,_initfn
	.globl	_verstr,_listwalk,_openrexx,_opendos,_closedos,_closerexx

	.text

/* ==== 0x00 DOS stub + RomTag ===================================== */
_nullvec:				/* h0+0 also serves as -24 vector */
	moveq	#0,%d0
	rts
_RomTag:
	.short	0x4afc
	.long	_RomTag		/* matchtag -> h0+4 */
	.long	_EndSkip	/* endskip  -> h0+0x1e */
	.byte	0x80,4		/* RTF_AUTOINIT, version 4 */
	.byte	9,0		/* NT_LIBRARY, pri 0 */
	.long	_libname	/* -> hunk1 "write.library" */
	.long	_idstr		/* -> hunk1 "Version 1.0" */
	.long	_template+4	/* -> hunk2+4 */
_EndSkip:
	.short	0		/* pad */

/* ==== 0x20 initfn: d0=libbase, a0=seglist ======================== */
_initfn:
	subqw	#8,%sp
	moveml	%d7/%a2-%a3/%a5-%a6,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* ln_Succ? lib+0x22 = seglist */
	moveb	#9,%a5@(8)		/* ln_Type */
	movel	#_libname,%a5@(10)
	moveb	#6,%a5@(14)		/* ln_Flags */
	.short	0x43f9,0,4		/* lea 4:l,a1 -> d0=4 */
	movel	%a1,%d0
	lea	%a5@(20),%a3
	movew	%d0,%a3@+		/* lib_Version = 4 */
	.short	0x43f9,0,2		/* lea 2:l,a1 */
	movel	%a1,%d0
	movew	%d0,%a3@+		/* lib_Revision = 2 */
	movel	#_idstr,%a3@+		/* ln_IdString */
	lea	%a5@(46),%a3
	clrl	%a3@+			/* lib+0x2e = 0 */
	movel	%a5,%a3@+		/* lib+0x32 = libbase */
	movel	#48,%a3@+		/* lib+0x36 = 48 */
	lea	%a5@(60),%a1
	.short	0x45f9,0,0x13		/* lea 0x13:l,a2 */
	movel	%a2,%d0
	movel	%d0,%d1
	asll	#2,%d1
	movel	%a6,%sp@(24)
	.short	0x45f9
	.long	_template		/* lea _template(h2),a2 */
	.short	0x0c40			/* "cmpiw #,d0" prefix; imm word doubles
					   as the loop instruction */
1:	.short	0x12da			/* #4826 == moveb a2@+,a1@+ */
	subql	#1,%d1
	bccs	1b
	asll	#2,%d0
	.short	0x47f9
	.long	_template		/* lea _template(h2),a3 */
	addal	%d0,%a3
	movel	%a3@,%d0		/* count = template[19] = 1 */
	moveal	%sp@(24),%a6
	beqs	2f
	movel	%d0,%d7
	asll	#2,%d7
	addql	#4,%d7
	movel	%d7,%d0
	moveq	#1,%d1			/* MEMF_PUBLIC */
	moveal	4:w,%a6
	jsr	%a6@(-198)		/* AllocMem */
	movel	%d0,%a5@(46)		/* lib+0x2e = table buf */
	moveal	%sp@(24),%a6
	beqs	4f			/* alloc failed -> pop+rts */
	moveal	%d0,%a1
	.short	0x0c40			/* ditto: imm word is the copy insn */
3:	.short	0x12db			/* #4827 == moveb a3@+,a1@+ */
	subql	#1,%d7
	bccs	3b
2:	movel	%a5,%d0
4:	moveml	%sp@+,%d7/%a2-%a3/%a5-%a6
	addqw	#8,%sp
	rts

/* ==== 0xd0 Open: bumps opencnt, allocs per-client ctx ============ */
_open:
	subaw	#20,%sp
	moveml	%d2/%a2-%a3/%a5-%a6,%sp@-
	moveal	4:w,%a1
	moveal	%a6,%a5
	addqw	#1,%a5@(32)		/* lib_OpenCnt */
	bclr	#3,%a5@(14)		/* LIBF_DELEXP */
	moveal	%a5@(50),%a0		/* lib+0x32 = libbase */
	movel	%a1,%sp@(24)
	.short	0x43f9,0,0x74	/* lea 0x74:l,a1 */
	movel	%a1,%d0
	addl	%a0@(54),%d0		/* lib+0x36 = 48 */
	moveq	#60,%d1
	addl	%d1,%d0			/* size = 0x74+48+60 */
	movel	%a6,%sp@(32)
	movel	%a6,%sp@(36)
	movel	#65537,%d1		/* MEMF_PUBLIC|MEMF_CLEAR? */
	moveal	4:w,%a6
	jsr	%a6@(-198)		/* AllocMem */
	moveal	%d0,%a3
	movel	%d0,%sp@(28)
	moveal	%sp@(36),%a6
	beqw	6f
	moveal	%a5@(50),%a0
	moveal	%a5,%a1
	movel	%a0@(54),%d1
	subal	%d1,%a1			/* src = lib - 48 */
	.short	0x4df9,0,0x13	/* lea 0x13:l,a6 */
	movel	%a6,%d0
	asll	#2,%d0
	addl	%d1,%d0
	moveq	#60,%d1
	addl	%d1,%d0			/* count-ish */
	moveal	%a3,%a0
	.short	0x0c40			/* cmpiw prefix; imm word = copy insn */
4:	.short	0x10d9			/* #4313 == moveb a1@+,a0@+ */
	subql	#1,%d0
	bccs	4b
	moveal	%a5@(50),%a0
	moveal	%a3,%a2
	addal	%a0@(54),%a2		/* ctx = buf+48 */
	clrl	%a2@(46)
	lea	%a2@(60),%a5		/* a5 = ctx+0x3c */
	moveal	%a2@(50),%a0
	moveal	%a0@(46),%a1
	moveal	%sp@(36),%a6
	movel	%a1,%d1
	beqs	5f
	lea	%a1@(4),%a3
	movel	%a1@,%d2
	bras	8f
7:	movel	%a5,%d0
	movel	%a3@+,%d1
	addl	%d0,%d1
	moveal	%d1,%a0
	addl	%d0,%a0@
	subql	#1,%d2
8:	tstl	%d2
	bgts	7b
5:	moveal	%sp@(24),%a0
	cmpiw	#36,%a0@(20)		/* SysBase->lib_Version >=36 ? */
	moveal	%sp@(36),%a6
	bcss	9f
	moveal	4:w,%a6
	jsr	%a6@(-636)		/* CacheClearU */
9:	moveal	%a2,%a6
	bsrw	_hook1			/* 0x618: call template[+0x1c] */
	moveal	%sp@(36),%a6
	tstl	%d0
	bnes	10f
	moveal	%a2,%a6
	bsrw	_stub0			/* 0x67c -> d0=0 */
	tstl	%d0
	moveal	%sp@(36),%a6
	beqs	_ov1
10:	moveal	%a2,%a6
	bsrw	_hook2			/* 0x64c: call template[+0x28] */
	moveal	%a2@(50),%a0
	.short	0x43f9,0,0x74	/* lea 0x74:l,a1 */
	movel	%a1,%d0
	addl	%a0@(54),%d0
	moveq	#60,%d1
	addl	%d1,%d0
	moveal	%sp@(28),%a1
	moveal	4:w,%a6
	jsr	%a6@(-210)		/* FreeMem on fail path */
	moveal	%sp@(36),%a6
6:	moveal	%sp@(32),%a1
	moveal	%a1@(50),%a0
	subqw	#1,%a0@(32)
	moveq	#0,%d0
	.short	0x0c40			/* cmpiw prefix; imm word doubles */
_ov1:	.short	0x200a			/* #8202 == movel a2,d0 */
11:	moveml	%sp@+,%d2/%a2-%a3/%a5-%a6
	addaw	#20,%sp
	rts

/* ==== 0x1fe Close ================================================ */
_close:
	subqw	#4,%sp
	moveml	%d7/%a3/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveq	#0,%d7
	movel	%a6,%sp@(16)
	moveal	%a5@(50),%a0
	cmpal	%a5,%a0
	beqs	12f
	moveal	%a5,%a6
	bsrw	_stubrts		/* 0x678: rts */
	bsrw	_hook2			/* 0x64c */
	moveal	%a5@(50),%a3
	movel	%a3@(54),%d0
	subal	%d0,%a5
	.short	0x43f9,0,0x74	/* lea 0x74:l,a1 */
	movel	%a1,%d0
	addl	%a3@(54),%d0
	moveq	#60,%d1
	addl	%d1,%d0
	moveal	%a5,%a1
	moveal	4:w,%a6
	jsr	%a6@(-210)		/* FreeMem */
	moveal	%a3,%a5
12:	subqw	#1,%a5@(32)
	moveal	%sp@(16),%a6
	bnes	13f
	btst	#3,%a5@(14)
	beqs	13f
	moveal	%a5,%a6
	bsrw	_expunge		/* deferred expunge */
	movel	%d0,%d7
13:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a3/%a5-%a6
	addqw	#4,%sp
	rts

/* ==== 0x268 Expunge ============================================== */
_expunge:
	subqw	#8,%sp
	moveml	%d2/%d7/%a5-%a6,%sp@-
	moveq	#0,%d7
	moveal	%a6@(50),%a5		/* a5 = lib+0x32 chain? */
	bset	#3,%a5@(14)		/* set DELEXP */
	movel	%a6,%sp@(16)
	movel	%a6,%sp@(20)
	tstw	%a5@(32)
	bnes	14f
	movel	%a5@(46),%d0		/* table buf */
	beqs	15f
	moveal	%d0,%a0
	movel	%a0@,%d1
	asll	#2,%d1
	addql	#4,%d1
	moveal	%d0,%a1
	movel	%d1,%d0
	moveal	4:w,%a6
	jsr	%a6@(-210)		/* FreeMem buf */
15:	movel	%a5@(34),%d7		/* seglist */
	moveal	%a5,%a1
	moveal	4:w,%a6
	jsr	%a6@(-252)		/* Remove */
	moveq	#0,%d0
	movew	%a5@(18),%d0		/* lib_PosSize */
	moveq	#0,%d1
	movew	%a5@(16),%d1		/* lib_NegSize */
	movel	%d1,%d2
	addl	%d0,%d2
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%d1,%d0
	subal	%d0,%a1
	movel	%d2,%d0
	jsr	%a6@(-210)		/* FreeMem lib node */
14:	movel	%d7,%d0
	moveml	%sp@+,%d2/%d7/%a5-%a6
	addqw	#8,%sp
	rts

/* ==== 0x2d8 vec -30: a4<->lib+0x3c dance (returns nothing useful) = */
_vec30:
	subqw	#4,%sp
	movel	%a4,%sp@-
	lea	%a6@(60),%a4		/* a4 = lib+0x3c */
	moveal	%sp@+,%a4		/* restore a4 (lea result lost) */
	addqw	#4,%sp
	rts

/* ==== 0x2df strings ============================================== */
_verstr:
	.ascii	"$VER:write.library 4.2 (7.11.95) \251 1995 Tim Teulings\0"
	.byte	0
_s_write:				/* 0x31c */
	.ascii	"WRITE\0"
_s_wpath:				/* 0x322 */
	.ascii	"WRITEPATH\0"
_s_pdir:				/* 0x32c */
	.ascii	"PROGDIR:\0"
	.byte	0
_s_pdirw:				/* 0x336 */
	.ascii	"PROGDIR:WRITE\0"
_s_noinit:				/* 0x344 */
	.ascii	" NOINITIALWINDOW\0"
	.byte	0

/* ==== 0x356 vec -36: open write port ============================= */
_vec36:
	subaw	#264,%sp
	moveml	%d2-%d4/%d7/%a4-%a6,%sp@-
	movel	%a2,%sp@(28)
	lea	%a6@(60),%a4		/* globals */
	movel	%a6,%sp@(32)
	lea	%pc@(_s_write),%a1	/* "WRITE" */
	moveal	4:w,%a6
	jsr	%a6@(-390)		/* FindPort? */
	moveal	%sp@(32),%a6
	tstl	%d0
	beqs	16f
	moveq	#0,%d0
	braw	23f
16:	lea	%pc@(_s_wpath),%a0	/* "WRITEPATH" */
	movel	%a0,%d1
	lea	%sp@(36),%a0
	movel	%a0,%d2
	moveal	%a4@(108),%a6		/* dosbase */
	moveq	#64,%d3
	lsll	#2,%d3			/* 256 */
	moveq	#0,%d4
	jsr	%a6@(-906)		/* dos: get var? */
	tstl	%d0
	moveal	%sp@(32),%a6
	bnes	17f
	lea	%pc@(_s_pdir),%a0	/* "PROGDIR:" */
	moveal	%d2,%a1
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	clrb	%a1@
	lea	%pc@(_s_pdirw),%a0	/* "PROGDIR:WRITE" */
	movel	%a0,%d1
	moveal	%a4@(108),%a6
	moveq	#-2,%d2
	jsr	%a6@(-84)		/* dos ?? */
	movel	%d0,%d7
	moveal	%sp@(32),%a6
	bnes	18f
	moveq	#1,%d0
	braw	23f
18:	movel	%d7,%d1
	moveal	%a4@(108),%a6
	jsr	%a6@(-90)
17:	lea	%sp@(36),%a0
	movel	%a0,%d1
	lea	%pc@(_s_write),%a0	/* "WRITE" */
	movel	%a0,%d2
	moveal	%a4@(108),%a6
	moveq	#64,%d3
	lsll	#2,%d3
	jsr	%a6@(-882)		/* dos ?? */
	tstw	%d0
	moveal	%sp@(32),%a6
	bnes	19f
	moveq	#3,%d0
	braw	23f
19:	lea	%sp@(36),%a0
	movel	%a0,%d1
	moveal	%a4@(108),%a6
	moveq	#-2,%d2
	jsr	%a6@(-84)
	movel	%d0,%d7
	moveal	%sp@(32),%a6
	bnes	20f
	moveq	#3,%d0
	braw	23f
20:	movel	%d7,%d1
	moveal	%a4@(108),%a6
	jsr	%a6@(-90)
	pea	0x100:w
	pea	%pc@(_s_noinit)		/* " NOINITIALWINDOW" */
	pea	%sp@(44)
	moveal	%sp@(44),%a6
	bsrw	_strcat			/* 0x680 */
	lea	%sp@(12),%sp
	clrl	%sp@-
	pea	0x7530:w
	movel	#0x800003f3,%sp@-
	clrl	%sp@-
	movel	#0x80000022,%sp@-
	clrl	%sp@-
	movel	#0x80000021,%sp@-
	pea	0x1:w
	movel	#0x80000023,%sp@-
	lea	%sp@(72),%a0
	movel	%a0,%d1
	moveal	%a4@(108),%a6
	movel	%sp,%d2
	jsr	%a6@(-606)		/* dos ?? taglist */
	lea	%sp@(36),%sp
	subal	%a5,%a5
	moveq	#0,%d2
	moveal	%sp@(32),%a6
	bras	22f
21:	moveal	%a4@(108),%a6
	moveq	#25,%d1
	jsr	%a6@(-198)		/* Delay(25)? via dosbase */
	addql	#1,%d2
	moveal	%sp@(32),%a6
22:	moveq	#10,%d0
	cmpl	%d0,%d2
	bges	24f
	lea	%pc@(_s_write),%a1
	moveal	4:w,%a6
	jsr	%a6@(-390)		/* FindPort loop */
	moveal	%d0,%a5
	tstl	%d0
	moveal	%sp@(32),%a6
	beqs	21b
24:	movel	%a5,%d0
	beqs	25f			/* a5? -> into the cmpiw imm word */
	moveq	#0,%d0
	.short	0x0c40			/* "cmpiw #" prefix; imm word doubles */
25:	.short	0x7002			/* #28674 == moveq #2,d0 */
23:	moveml	%sp@+,%d2-%d4/%d7/%a4-%a6
	addaw	#264,%sp
	rts

/* ==== 0x4c4 vec -42 ============================================== */
_vec42:
	subaw	#16,%sp
	moveml	%a4-%a6,%sp@-
	movel	%a4,%sp@(20)
	lea	%a6@(60),%a4
	moveal	%a1,%a5			/* a1 = arg */
	movel	%a6,%sp@(24)
	movel	%a1,%sp@(16)
	moveal	4:w,%a6
	jsr	%a6@(-132)		/* Forbid? */
	moveal	%a5,%a1
	jsr	%a6@(-390)		/* FindPort */
	moveal	%sp@(24),%a6
	movel	%d0,%sp@(12)
	beqw	30f
	moveal	%a3,%a0
	moveal	%a4@(100),%a6		/* rexxsyslib */
	subal	%a1,%a1
	moveq	#0,%d0
	jsr	%a6@(-144)		/* rexxsyslib ?? */
	moveal	%d0,%a5
	moveal	%sp@(24),%a6
	tstl	%d0
	beqs	30f
	moveal	%a2,%a0
	tstb	%a0@+
	bnes	.-2
	subql	#1,%a0
	subal	%a2,%a0
	movel	%a0,%d0
	moveal	%a2,%a0
	moveal	%a4@(100),%a6
	jsr	%a6@(-126)
	movel	%d0,%a5@(40)
	moveal	%sp@(24),%a6
	beqs	31f
	movel	#16908288,%a5@(28)	/* 0x01020000 */
	moveal	%sp@(12),%a0
	moveal	%a5,%a1
	moveal	4:w,%a6
	jsr	%a6@(-366)		/* PutMsg? */
	moveal	%sp@(24),%a6
33:	moveal	%a3,%a0
	moveal	4:w,%a6
	jsr	%a6@(-384)
	moveal	%a3,%a0
	jsr	%a6@(-372)
	moveal	%d0,%a5
	moveal	%sp@(24),%a6
	tstl	%d0
	beqs	32f
	movel	%a5@(32),%a4@(88)
32:	movel	%a5,%d0
	beqs	33b
	moveal	4:w,%a6
	jsr	%a6@(-138)
	movel	%a5,%d0
	bras	34f
31:	moveal	%a5,%a0
	moveal	%a4@(100),%a6
	jsr	%a6@(-150)
	moveq	#0,%d0
	bras	34f
30:	moveal	4:w,%a6
	jsr	%a6@(-138)
	moveq	#0,%d0
34:	moveml	%sp@+,%a4-%a6
	addaw	#16,%sp
	rts

/* ==== 0x59c vec -48 ============================================== */
_vec48:
	subqw	#4,%sp
	moveml	%a4-%a6,%sp@-
	moveal	%a1,%a5
	lea	%a6@(60),%a4
	movel	%a6,%sp@(12)
	movel	%a5,%d0
	beqs	35f
	tstl	%a5@(32)
	bnes	36f
	movel	%a5@(36),%d0
	beqs	36f
	moveal	%d0,%a0
	moveal	%a4@(100),%a6
	jsr	%a6@(-132)
36:	moveal	%a5@(40),%a0
	moveal	%a4@(100),%a6
	jsr	%a6@(-132)
	moveal	%a5,%a0
	jsr	%a6@(-150)
35:	moveml	%sp@+,%a4-%a6
	addqw	#4,%sp
	rts

/* ==== 0x5e0 list walk helper ===================================== */
_listwalk:
	movel	%d7,%sp@-
	moveq	#0,%d7
	addql	#4,%a4@(52)
	bras	38f
37:	tstb	%a4@(92)
	bnes	39f
	tstl	%d7
	bnes	40f
39:	moveal	%a4@(52),%a1
	moveal	%a1@,%a0
	jsr	%a0@
	movel	%d0,%d7
40:	addql	#4,%a4@(52)
38:	moveal	%a4@(52),%a0
	tstl	%a0@
	bnes	37b
	moveb	#1,%a4@(92)
	movel	%d7,%d0
	movel	%sp@+,%d7
	rts
	nop

/* ==== 0x618 hook1: if template[+0x1c] call *(template[+0x18]) ===== */
_hook1:
	subqw	#8,%sp
	movel	%a4,%sp@-
	.short	0x41f9
	.long	_template+0x1c		/* lea tmpl+0x1c,a0 */
	lea	%a6@(60),%a4
	movel	%a0,%sp@(8)
	movel	%a6,%sp@(4)
	tstl	%sp@(8)
	beqs	41f
	.short	0x2079
	.long	_template+0x18		/* moveal tmpl+0x18:l,a0 */
	jsr	%a0@
	tstl	%d0
	beqs	41f
	moveq	#1,%d0
	.short	0x0c40			/* cmpiw prefix; imm word doubles */
41:	.short	0x7000			/* #28672 == moveq #0,d0 */
	moveal	%sp@+,%a4
	addqw	#8,%sp
	rts

/* ==== 0x64c hook2: if template[+0x28] call *(template[+0x18]) ===== */
_hook2:
	subqw	#8,%sp
	movel	%a4,%sp@-
	.short	0x41f9
	.long	_template+0x28		/* lea tmpl+0x28,a0 */
	lea	%a6@(60),%a4
	movel	%a0,%sp@(8)
	movel	%a6,%sp@(4)
	tstl	%sp@(8)
	beqs	42f
	.short	0x2079
	.long	_template+0x18		/* moveal tmpl+0x18:l,a0 */
	jsr	%a0@
42:	moveal	%sp@+,%a4
	addqw	#8,%sp
	rts
	nop

/* ==== 0x678/0x67c dead stubs ===================================== */
_stubrts:
	rts
	.short	0
_stub0:
	moveq	#0,%d0
	rts

/* ==== 0x680 strcat helper: a0 dst,a1 src,d0 maxlen -> d0 dst ====== */
_strcat:
	moveal	%sp@(8),%a1
	moveal	%sp@(4),%a0
	movel	%sp@(12),%d0
	movel	%a0,%d1
43:	tstb	%a0@+
	bnes	43b
	subql	#1,%a0
	bras	45f
44:	moveb	%a1@+,%a0@+
	beqs	46f
45:	subql	#1,%d0
	bccs	44b
	clrb	%a0@+
46:	movel	%d1,%d0
	rts

/* ==== 0x6a4 error reporter ======================================= */
_errmsg:
	subaw	#52,%sp
	moveml	%d2-%d3/%d7/%a2-%a3/%a5-%a6,%sp@-
	lea	%pc@(_s_dos),%a1		/* "dos.library" */
	moveal	4:w,%a6
	moveq	#0,%d0
	moveal	%a0,%a5
	jsr	%a6@(-552)		/* OldOpenLibrary */
	moveal	%d0,%a3
	tstl	%a4@(76)
	bnes	47f
	moveal	%a3,%a6
	jsr	%a6@(-60)		/* dos: ? */
	movel	%d0,%d7
	bras	48f
47:	lea	%a4@(56),%a0
	movel	%a0,%d1
	movel	#1006,%d2		/* MODE_NEWFILE */
	moveal	%a3,%a6
	jsr	%a6@(-30)		/* dos.Open */
	movel	%d0,%d7
48:	tstl	%d7
	beqs	53f
	lea	%pc@(_s_arg),%a0		/* data @0x79e */
	movel	%a3,%sp@-
	lea	%a4@(96),%a1
	lea	%sp@(34),%a3
	moveal	4:w,%a6
	moveal	%a0,%a2
	lea	%pc@(_s_fmt),%a0		/* "Can't open version %ld of " */
	jsr	%a6@(-522)		/* RawDoFmt */
	moveal	%sp@+,%a3
	lea	%sp@(30),%a0
	moveal	%a0,%a1
49:	tstb	%a1@+
	bnes	49b
	subql	#1,%a1
	movel	%a0,%d2
	subal	%a0,%a1
	moveal	%a3,%a6
	movel	%a1,%d3
	movel	%d7,%d1
	jsr	%a6@(-48)		/* dos.Write */
	moveal	%a5,%a0
50:	tstb	%a0@+
	bnes	50b
	subql	#1,%a0
	subal	%a5,%a0
	movel	%a0,%d3
	movel	%d7,%d1
	movel	%a5,%d2
	jsr	%a6@(-48)		/* dos.Write */
	lea	%pc@(_s_nl),%a0		/* "\n" */
	movel	%d7,%d1
	movel	%a0,%d2
	moveq	#1,%d3
	jsr	%a6@(-48)		/* dos.Write */
	tstl	%a4@(76)
	beqs	53f
	moveq	#100,%d1
	addl	%d1,%d1
	jsr	%a6@(-198)		/* ?? AllocMem(200) */
	movel	%d7,%d1
	jsr	%a6@(-36)		/* dos.Close */
53:	moveal	%a3,%a1
	moveal	4:w,%a6
	jsr	%a6@(-414)		/* CloseLibrary */
	subal	%a1,%a1
	jsr	%a6@(-294)		/* FindTask(0) */
	moveq	#122,%d1
	moveal	%d0,%a0
	movel	%d1,%a0@(148)		/* task->tc_?? = 122 */
	moveml	%sp@+,%d2-%d3/%d7/%a2-%a3/%a5-%a6
	addaw	#52,%sp
	rts

/* ==== 0x776 strings 2 ============================================ */
_s_dos:
	.ascii	"dos.library\0"
_s_fmt:
	.ascii	"Can't open version %ld of \0"
	.byte	0
_s_arg:
	.short	0x16c0			/* data @0x79e (fmt arg?) */
	.short	0x4e75
	.short	0x0000
_s_nl:
	.byte	0x0a,0x00			/* "\n" @0x7a4 */
	nop

/* ==== 0x7a8 open rexxsyslib ====================================== */
_openrexx:
	movel	%a6,%sp@-
	lea	%pc@(_s_rexx),%a1		/* "rexxsyslib.library" */
	movel	%a4@(96),%d0		/* version */
	moveal	4:w,%a6
	jsr	%a6@(-552)		/* OldOpenLibrary */
	movel	%d0,%a4@(100)
	movel	%d0,%a4@(104)
	bnes	54f
	lea	%pc@(_s_rexx),%a0
	bsrw	_errmsg
	moveq	#1,%d0
	.short	0x0c40			/* cmpiw prefix; imm word doubles */
54:	.short	0x7000			/* #28672 == moveq #0,d0 */
	moveal	%sp@+,%a6
	rts
_s_rexx:
	.ascii	"rexxsyslib.library\0"
	.byte	0

/* ==== 0x7ea close rexxsyslib ===================================== */
_closerexx:
	movel	%a6,%sp@-
	movel	%a4@(104),%d0
	beqs	55f
	moveal	%d0,%a1
	moveal	4:w,%a6
	jsr	%a6@(-414)		/* CloseLibrary */
	subal	%a0,%a0
	movel	%a0,%a4@(100)
	movel	%a0,%a4@(104)
55:	moveal	%sp@+,%a6
	rts
	nop

/* ==== 0x80c open dos.library ===================================== */
_opendos:
	movel	%a6,%sp@-
	lea	%pc@(_s_dos2),%a1		/* "dos.library" */
	movel	%a4@(96),%d0		/* version */
	moveal	4:w,%a6
	jsr	%a6@(-552)
	movel	%d0,%a4@(108)
	movel	%d0,%a4@(112)
	bnes	56f
	lea	%pc@(_s_dos2),%a0
	bsrw	_errmsg
	moveq	#1,%d0
	.short	0x0c40			/* cmpiw prefix */
56:	.short	0x7000			/* #28672 == moveq #0,d0 */
	moveal	%sp@+,%a6
	rts
_s_dos2:
	.ascii	"dos.library\0"

/* ==== 0x846 close dos.library ==================================== */
_closedos:
	movel	%a6,%sp@-
	movel	%a4@(112),%d0
	beqs	57f
	moveal	%d0,%a1
	moveal	4:w,%a6
	jsr	%a6@(-414)
	subal	%a0,%a0
	movel	%a0,%a4@(108)
	movel	%a0,%a4@(112)
57:	moveal	%sp@+,%a6
	rts
	nop
