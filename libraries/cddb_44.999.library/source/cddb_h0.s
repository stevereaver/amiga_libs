/* cddb.library 44.999 - hunk0 CODE reconstruction
 * Compiled-C freedb/CDDB client. Private ctx = 96-byte copy of the
 * DATA hunk at lib+48; ext bases at ctx+20 (freedb) / ctx+24 (utility)
 * / ctx+104 (exec, beyond copy). Transcribed to match original bytes.
 */
	.text

/* ---- DOS stub @0x00 (also -24 vector) ---- */
_dsstub:
	moveq	#0,%d0
	rts

/* ---- RomTag @0x04 ---- */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x2c,0x09,0x00
	.long	_name
	.long	_idstr
	.long	_inittab
_endskip:
	.short	0			/* pad @0x1e */

/* ---- initfn @0x20 (d0=libbase) ---- */
_init:
	subqw	#8,%sp
	moveml	%d7/%a2-%a3/%a5-%a6,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* seglist */
	moveb	#9,%a5@(8)		/* ln_Type */
	movel	#_name,%a5@(10)
	moveb	#6,%a5@(14)		/* lib_Flags */
	.short	0x43f9,0,0x2c		/* lea 0x2c:l,a1 - version 44 */
	movel	%a1,%d0
	lea	%a5@(20),%a0
	movew	%d0,%a0@+
	.short	0x43f9,0,0x3e7		/* lea 0x3e7:l,a1 - revision 999 */
	movel	%a1,%d0
	movew	%d0,%a0@+
	movel	#_idstr,%a0@+
	lea	%a5@(48),%a3		/* ctx */
	.short	0x43f9,0,0x18		/* lea 0x18:l,a1 - 24 -> 96 bytes */
	movel	%a1,%d0
	movel	%d0,%d1
	asll	#2,%d1
	movel	%a6,%sp@(24)
	lea	_dt0,%a1		/* h1 base */
	moveal	%a3,%a6
	.short	0x0c40			/* overlap: cmpiw#0x1cd9 once */
_copyl:	moveb	%a1@+,%a6@+		/* 1cd9 - loop entry */
	subql	#1,%d1
	bccs	_copyl
	asll	#2,%d0
	lea	_dt0,%a0
	addal	%d0,%a0			/* h1+0x60 */
	movel	%a0@,%d7			/* fix count = 1 */
	lea	%a0@(4),%a2		/* h1+0x64 = fix delta list */
	moveal	%sp@(24),%a6
	bras	_fixt
_fixl:	movel	%a3,%d0
	addl	%a2@+,%d0
	movel	%a3,%d1
	moveal	%d0,%a0
	addl	%d1,%a0@
	subql	#1,%d7
_fixt:	tstl	%d7
	bgts	_fixl
	moveal	%a5,%a6
	bsrw	_openlibs
	tstl	%d0
	moveal	%sp@(24),%a6
	beqs	_retlib
	moveq	#0,%d0
	.short	0x0c40			/* overlap: cmpiw#0x200d once */
_retlib: movel	%a5,%d0		/* 0x200d - init-ok branch target */
	moveml	%sp@+,%d7/%a2-%a3/%a5-%a6
	addqw	#8,%sp
	rts

/* ---- Open @0xc4 ---- */
_open:
	subqw	#4,%sp
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)
	movel	%a6,%d0
	addqw	#4,%sp
	rts

/* ---- Close @0xd6 ---- */
_close:
	subqw	#4,%sp
	movel	%d7,%sp@-
	moveq	#0,%d7
	subqw	#1,%a6@(32)
	movel	%a6,%sp@(4)
	tstw	%a6@(32)
	bnes	_clret
	btst	#3,%a6@(14)
	beqs	_clret
	bsrw	_expunge
	movel	%d0,%d7
_clret:	movel	%d7,%d0
	movel	%sp@+,%d7
	addqw	#4,%sp
	rts

/* ---- Expunge @0x100 ---- */
_expunge:
	subqw	#4,%sp
	moveml	%d2/%d7/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveq	#0,%d7
	bset	#3,%a5@(14)
	movel	%a6,%sp@(16)
	tstw	%a5@(32)
	bnes	_exdone
	moveal	%a5,%a6
	bsrw	_closelibs
	movel	%a5@(34),%d7
	moveal	%a5,%a1
	moveal	0x4,%a6
	jsr	%a6@(-252)		/* Remove */
	moveq	#0,%d0
	movew	%a5@(18),%d0		/* neg size */
	moveq	#0,%d1
	movew	%a5@(16),%d1		/* pos size */
	movel	%d1,%d2
	addl	%d0,%d2
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%d1,%d0
	subal	%d0,%a1
	movel	%d2,%d0
	jsr	%a6@(-210)		/* FreeMem */
_exdone:
	movel	%d7,%d0
	moveml	%sp@+,%d2/%d7/%a5-%a6
	addqw	#4,%sp
	rts
	nop

/* ---- _openlibs @0x158: a6=lib; a4=ctx ---- */
_openlibs:
	subqw	#8,%sp
	moveml	%a4/%a6,%sp@-
	movel	%a6,%sp@(8)
	lea	%a6@(48),%a4
	moveal	0x4,%a1
	movel	%a1,%a4@(104)		/* ctx+104 = execbase */
	movel	%a6,%sp@(12)
	lea	%pc@(_utilstr),%a1
	moveal	%a4@(104),%a6
	moveq	#36,%d0
	jsr	%a6@(-552)		/* OldOpenLibrary */
	movel	%d0,%a4@(24)		/* ctx+24 = utilitybase */
	moveal	%sp@(12),%a6
	bnes	_olutil
	moveq	#1,%d0
	bras	_olfail
_olutil:
	lea	%pc@(_freedbstr),%a1
	moveal	%a4@(104),%a6
	moveq	#2,%d0
	jsr	%a6@(-552)
	movel	%d0,%a4@(20)		/* ctx+20 = freedbbase */
	moveal	%sp@(12),%a6
	bnes	_olok
	moveal	%a4@(24),%a1
	moveal	%a4@(104),%a6
	jsr	%a6@(-414)		/* CloseLibrary */
	clrl	%a4@(24)
	moveq	#1,%d0
	.short	0x0c40			/* overlap: loop tgt = moveq#0 */
_olok:	moveq	#0,%d0
_olfail:
	moveml	%sp@+,%a4/%a6
	addqw	#8,%sp
	rts
_utilstr:
	.ascii	"utility.library\0"
_freedbstr:
	.ascii	"freedb.library\0"
	.even

/* ---- _closelibs @0x1e4: a6=lib ---- */
_closelibs:
	subqw	#8,%sp
	moveml	%a4/%a6,%sp@-
	movel	%a6,%sp@(8)
	lea	%a6@(48),%a4
	movel	%a6,%sp@(12)
	moveal	%a4@(20),%a1
	moveal	%a4@(104),%a6
	jsr	%a6@(-414)		/* CloseLibrary(freedb) */
	moveal	%a4@(24),%a1
	jsr	%a6@(-414)		/* CloseLibrary(utility) */
	moveml	%sp@+,%a4/%a6
	addqw	#8,%sp
	rts
	nop

/* ---- _tagquery @0x214: wrapper - freedb -36 + utility SetTagData ---- */
_tagquery:
	subaw	#16,%sp
	moveml	%a2/%a4-%a6,%sp@-
	movel	%a1,%d0
	moveal	%a0,%a5
	movel	%a2,%sp@(16)
	lea	%a6@(48),%a4
	movel	%a6,%sp@(20)
	moveal	%a4@(20),%a6
	jsr	%a6@(-36)		/* freedb call */
	moveal	%sp@(20),%a6
	tstl	%d0
	beqs	_tqret
	movel	#0x80000006,%sp@(24)
	movel	%d0,%sp@(28)
	moveal	%a5@(16),%a0
	lea	%sp@(24),%a1
	moveal	%a4@(24),%a6
	subal	%a2,%a2
	jsr	%a6@(-102)		/* utility: SetTagData? */
_tqret:	moveq	#0,%d0
	moveml	%sp@+,%a2/%a4-%a6
	addaw	#16,%sp
	rts
_cdname:
	.ascii	"cddb.library\0"
	.byte	0
_cdver:
	.ascii	"44.999\0"
	.even

/* ---- _strncpy @0x27c: a5=dst a1=src d0=max ---- */
_strncpy:
	subqw	#4,%sp
	moveml	%a5-%a6,%sp@-
	movel	%d0,%d1
	moveal	%a0,%a5
	moveal	%a1,%a0
_snlen:	tstb	%a0@+
	bnes	_snlen
	subql	#1,%a0
	subal	%a1,%a0			/* srclen */
	movel	%a6,%sp@(8)
	cmpal	%d1,%a0
	blts	_sncpy			/* src fits -> plain copy */
	movel	%d1,%d0
	subql	#1,%d0
	moveal	%a1,%a0
	moveal	%a5,%a1
	.short	0x0c40			/* overlap: cmpiw#0x12d8 once */
_sncl:	moveb	%a0@+,%a1@+		/* 12d8 - loop entry */
	subql	#1,%d0
	bccs	_sncl
	clrb	%a5@(-1,%d1:l)
	moveal	%sp@(8),%a6
	bras	_sndone
_sncpy:	moveb	%a1@+,%a5@+
	bnes	_sncpy
_sndone:
	moveml	%sp@+,%a5-%a6
	addqw	#4,%sp
	rts

/* ---- _discid @0x2be: a0=ctx a1=cdinfo; discid + track table build ---- */
_discid:
	subqw	#8,%sp
	moveml	%d2-%d3/%d6-%d7/%a2-%a3,%sp@-
	moveal	%a1,%a2		/* cdinfo */
	moveal	%a0,%a3		/* track table out */
	movel	%a2@(404),%d0		/* ntracks */
	movel	%d0,%d1
	asll	#4,%d1
	subl	%d0,%d1			/* *15 */
	movel	%d1,%d0
	asll	#2,%d0
	addl	%d1,%d0			/* *75 -> frames */
	movel	%d0,%a3@(16)
	movel	%a2@(404),%d0
	moveq	#60,%d1
	bsrw	_divmod
	movel	%d0,%a3@(20)		/* secs */
	movel	%a2@(404),%d0
	moveq	#60,%d1
	bsrw	_divmod
	movel	%d1,%a3@(24)		/* rem */
	movel	%a0,%sp@(24)
	movel	%a6,%sp@(28)
	moveal	%a2,%a0
	bsrw	_cddbid			/* full discid over tracks */
	movel	%d0,%a3@(32)
	movel	%a2@(400),%d7		/* leadin? */
	movel	%d7,%a3@(36)
	moveq	#0,%d6
	bras	_dltest
_dloop:	moveq	#0,%d0
	moveb	%a2@(2),%d0		/* track min? */
	moveq	#0,%d1
	moveb	%a2@(1),%d1
	moveq	#0,%d2
	moveb	%a2@,%d2
	movel	%d2,%d3
	asll	#4,%d3
	subl	%d2,%d3			/* *15 */
	asll	#2,%d3
	addl	%d1,%d3			/* +min */
	movel	%d3,%d1
	asll	#4,%d1
	subl	%d3,%d1
	movel	%d1,%d2
	asll	#2,%d2
	addl	%d1,%d2
	addl	%d0,%d2			/* frames */
	moveq	#75,%d0
	addl	%d0,%d0			/* 150 */
	subl	%d0,%d2			/* -150 (2s offset) */
	movel	%d2,%a3@(44)
	addql	#1,%d6
	addaw	#62,%a3			/* next track entry */
	addql	#4,%a2
_dltest:
	cmpl	%d7,%d6
	bcss	_dloop
	moveq	#1,%d0
	moveal	%sp@(24),%a0
	movel	%d0,%a0@		/* ctx+0: ok */
	movel	%a0@(36),%a0@(4)
	clrl	%a0@(8)
	movel	%a0@(16),%a0@(12)
	clrl	%a0@(28)
	moveml	%sp@+,%d2-%d3/%d6-%d7/%a2-%a3
	addqw	#8,%sp
	rts

/* ---- -30 @0x378: CDDB query (a0=tags a1=cdinfo) ---- */
_query:
	subaw	#60,%sp
	moveml	%d4-%d7/%a2-%a6,%sp@-
	lea	%a6@(48),%a4
	moveal	%a1,%a2			/* cdinfo */
	movel	%a6,%sp@(64)
	movel	%a0,%sp@(56)		/* tags */
	movel	%a1,%sp@(60)
	moveal	%a2,%a0
	moveal	%a4@(24),%a6		/* utility */
	movel	#0x80000008,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)		/* GetTagData? */
	movel	%d0,%d4
	clrl	%sp@(88)
	clrl	%sp@(92)
	moveal	%a2,%a0
	movel	#0x80000006,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	moveal	%sp@(64),%a6
	movel	%d0,%sp@(36)
	beqs	_qnohost
	lea	%pc@(_tagquery),%a0
	movel	%a0,%sp@(76)
	movel	%d0,%sp@(84)
_qnohost:
	moveal	%a2,%a0
	moveal	%a4@(24),%a6
	movel	#0x80000007,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	moveal	%sp@(64),%a6
	tstl	%d0
	beqs	_qportok
	moveq	#10,%d0			/* err: no tags */
	braw	_qret
_qportok:
	moveal	%a2,%a0
	moveal	%a4@(24),%a6
	movel	#0x80000001,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	movel	%d0,%sp@(48)
	moveal	%a2,%a0
	movel	#0x80000002,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	moveal	%d0,%a3
	movel	%a3,%sp@(52)
	moveal	%a2,%a0
	movel	#0x80000003,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	movel	%d0,%sp@(44)
	moveal	%a2,%a0
	movel	#0x80000004,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	movel	%d0,%sp@(40)
	moveal	%a2,%a0
	movel	#0x80000005,%d0
	moveq	#0,%d1
	jsr	%a6@(-36)
	moveal	%d0,%a2
	tstl	%sp@(48)
	moveal	%sp@(64),%a6
	beqs	_qnotags
	movel	%a3,%d0
	beqs	_qnotags
	tstl	%sp@(44)
	beqs	_qnotags
	tstl	%sp@(40)
	beqs	_qnotags
	movel	%a2,%d0
	bnes	_qtagsok
_qnotags:
	moveq	#10,%d0
	braw	_qret
_qtagsok:
	clrl	%sp@-
	moveal	%a4@(20),%a6		/* freedb */
	moveq	#2,%d0
	moveal	%sp,%a0
	jsr	%a6@(-48)		/* freedb: alloc/seq */
	lea	%sp@(4),%sp
	moveal	%d0,%a5
	tstl	%d0
	moveal	%sp@(64),%a6
	bnes	_qgotctx
	moveq	#51,%d0			/* err: no cdinfo */
	braw	_qret
_qgotctx:
	movel	%a5,%d0
	addil	#1724,%d0
	moveal	%d0,%a3
	moveal	%a3,%a0
	moveal	%sp@(56),%a1		/* tags */
	moveal	%sp@(64),%a6
	bsrw	_discid
	movel	#0xfec9020f,%d0		/* freedb tags */
	tstl	%sp@(36)
	bnes	_qh1
	moveq	#1,%d0
_qh1:	movel	%d0,%d1
	movel	#0xfec90214,%d0
	tstw	%d4
	bnes	_qh2
	moveq	#1,%d0
_qh2:	clrl	%sp@-
	pea	0x1
	movel	%d0,%sp@-
	pea	%sp@(80)
	movel	%d1,%sp@-
	pea	%sp@(108)
	movel	#0xfec901f5,%sp@-
	pea	%sp@(120)
	movel	#0xfec90216,%sp@-
	movel	%a5,%sp@-
	movel	#0xfec901f8,%sp@-
	movel	%a3,%sp@-
	movel	#0xfec901f6,%sp@-
	moveal	%a4@(20),%a6
	moveal	%sp,%a0
	jsr	%a6@(-126)		/* freedb: query call */
	lea	%sp@(52),%sp
	movel	%d0,%d7
	subql	#2,%d0
	moveal	%sp@(64),%a6
	bnes	_qnoresc
	moveal	%sp@(92),%a0
	moveal	%a4@(20),%a6
	jsr	%a6@(-96)
	movel	%d0,%sp@(88)
_qnoresc:
	tstl	%sp@(88)
	moveal	%sp@(64),%a6
	bnew	_qerr2
	moveal	%sp@(48),%a1
	movel	%a5@,%a1@		/* copy result head */
	lea	%a5@(40),%a1
	moveal	%sp@(52),%a0
	moveq	#30,%d0
	bsrw	_strncpy		/* disc title */
	lea	%a5@(808),%a0
	moveal	%a0,%a1
	moveal	%sp@(44),%a0
	moveq	#100,%d0
	bsrw	_strncpy		/* artist */
	lea	%a5@(552),%a0
	moveal	%a0,%a1
	moveal	%sp@(40),%a0
	moveq	#100,%d0
	bsrw	_strncpy		/* album */
	moveq	#0,%d6
	moveq	#0,%d5
	bras	_qtloop
_qtrack:
	moveal	%a2@(0,%d5:l),%a0	/* src track str */
	movel	%d5,%d0
	addil	#1324,%d0
	moveal	%a5@(0,%d0:l),%a1	/* dst slot */
	moveq	#100,%d0
	bsrw	_strncpy
	addql	#1,%d6
	addql	#4,%d5
_qtloop:
	cmpl	%a5@(24),%d6		/* ntracks */
	bcss	_qtrack
	movel	%d7,%d0
	subql	#2,%d0
	bnes	_qerr2
	movew	%d4,%d0
	extl	%d0
	clrl	%sp@-
	pea	%pc@(_cdver)		/* "44.999" */
	movel	#0xfec90209,%sp@-
	pea	%pc@(_cdname)		/* "cddb.library" */
	movel	#0xfec90208,%sp@-
	movel	%d0,%sp@-
	movel	#0xfec90201,%sp@-
	movel	%a5,%sp@-
	movel	#0xfec901f8,%sp@-
	movel	%a5@,%sp@-
	movel	#0xfec901fa,%sp@-
	moveal	%a4@(20),%a6
	moveal	%sp,%a0
	jsr	%a6@(-72)		/* freedb: second call */
	lea	%sp@(44),%sp
_qerr2:	moveal	%sp@(64),%a6
	movel	%sp@(92),%d0
	beqs	_qclose
	moveal	%d0,%a0
	moveal	%a4@(20),%a6
	jsr	%a6@(-114)
_qclose:
	moveal	%a5,%a0
	moveal	%a4@(20),%a6
	jsr	%a6@(-60)		/* freedb: free ctx */
	movel	%sp@(88),%d0
_qret:	moveml	%sp@+,%d4-%d7/%a2-%a6
	addaw	#60,%sp
	rts

/* ---- -36 @0x5fc: stub returning 0 ---- */
_vec36:
	subaw	#12,%sp
	movel	%a4,%sp@-
	moveml	%d0/%a0,%sp@(4)
	lea	%a6@(48),%a4
	moveq	#0,%d0
	moveal	%sp@+,%a4
	addaw	#12,%sp
	rts
	nop

/* ---- _dsum @0x618: digit-sum of d0 ---- */
_dsum:	subqw	#4,%sp
	moveml	%d6-%d7,%sp@-
	movel	%d0,%d7
	moveq	#0,%d6
	movel	%a6,%sp@(8)
	bras	_dstest
_dsloop:
	movel	%d7,%d0
	moveq	#10,%d1
	bsrw	_divmod
	addl	%d1,%d6			/* += d0%10 */
	movel	%d7,%d0
	moveq	#10,%d1
	bsrw	_divmod
	movel	%d0,%d7			/* d0/=10 */
_dstest:
	moveq	#0,%d0
	cmpl	%d0,%d7
	bhis	_dsloop
	movel	%d6,%d0
	moveml	%sp@+,%d6-%d7
	addqw	#4,%sp
	rts

/* ---- _cddbid @0x64c: a0=cdinfo -> d0 discid ---- */
_cddbid:
	subqw	#8,%sp
	moveml	%d2/%d6-%d7/%a3/%a5,%sp@-
	moveal	%a0,%a5
	moveq	#0,%d7
	moveq	#0,%d6
	moveal	%a5,%a3
	movel	%a6,%sp@(24)
	bras	_cdtest
_cdloop:
	moveq	#0,%d0
	moveb	%a3@(1),%d0		/* sec */
	moveq	#0,%d1
	moveb	%a3@,%d1		/* min */
	movel	%d1,%d2
	asll	#4,%d2
	subl	%d1,%d2			/* *15 */
	asll	#2,%d2			/* *60 */
	addl	%d2,%d0			/* total secs */
	bsrs	_dsum
	addl	%d0,%d6			/* sum digits */
	addql	#1,%d7
	addql	#4,%a3
_cdtest:
	cmpl	%a5@(400),%d7		/* ntracks */
	bcss	_cdloop
	movel	%a5@(404),%d0		/* leadout frames? */
	asll	#8,%d0			/* <<8 */
	movel	%d0,%sp@(20)
	movel	%d6,%d0
	moveq	#0,%d1
	notb	%d1			/* d1=0xff */
	bsrw	_divmod
	swap	%d1
	clrw	%d1			/* d1 = (d6%255)<<16? */
	asll	#8,%d1
	orl	%sp@(20),%d1		/* | (leadout<<8) */
	orl	%a5@(400),%d1		/* | ntracks */
	movel	%d1,%d0
	moveml	%sp@+,%d2/%d6-%d7/%a3/%a5
	addqw	#8,%sp
	rts

/* ---- -42 @0x6ae: set discid at a0+408 ---- */
_setid:
	subqw	#4,%sp
	moveml	%a4-%a5,%sp@-
	moveal	%a0,%a5
	lea	%a6@(48),%a4
	movel	%a6,%sp@(8)
	bsrs	_cddbid
	movel	%d0,%a5@(408)
	moveml	%sp@+,%a4-%a5
	addqw	#4,%sp
	rts

/* ---- -48 @0x6cc: error-code -> string via ctx+28 table ---- */
_errstr:
	subqw	#4,%sp
	moveml	%d7/%a4/%a6,%sp@-
	movel	%d0,%d7			/* err code */
	lea	%a6@(48),%a4
	movel	%a6,%sp@(12)
	moveal	%a4@(20),%a6		/* freedb */
	jsr	%a6@(-36)
	moveal	%sp@(12),%a6
	tstl	%d0
	bnes	_esret			/* freedb err overrides */
	moveq	#0,%d0
	cmpl	%d0,%d7
	moveal	%sp@(12),%a6
	bcss	_esunk			/* d7<0 -> unknown */
	moveq	#11,%d0
	cmpl	%d0,%d7
	bhis	_esunk			/* d7>=11 -> unknown */
	asll	#2,%d7
	lea	%a4@(28),%a0		/* ctx+28 = err table */
	movel	%a0@(0,%d7:l),%d0
	bras	_esret
_esunk:	lea	%pc@(_unkerr),%a0
	movel	%a0,%d0
_esret:	moveml	%sp@+,%d7/%a4/%a6
	addqw	#4,%sp
	rts

/* ---- error strings @0x716 (h1 table points here) ---- */
_err0:	.ascii	"No Error!\0"
_err1:	.ascii	"No TCP/IP stack is running, go online first!\0"
	.byte	0
_err2:	.ascii	"Failed to resolve the host!\0"
_err3:	.ascii	"s.Socket() failed!\0"
	.byte	0
_err4:	.ascii	"s.Connect() failed!\0"
_err5:	.ascii	"Server comes up with an error after connect!\0"
	.byte	0
_err6:	.ascii	"Hello cmd failed!\0"
_err7:	.ascii	"Query cmd failed!\0"
_err8:	.ascii	"No matching discid found in query!\0"
	.byte	0
_err9:	.ascii	"Inexact matches found in query!\0"
_err10:	.ascii	"No Tags specified!\0"
	.byte	0
_err11:	.ascii	"No CDInfo struct specified!\0"
_unkerr:
	.ascii	"Unknown error\0"
	nop				/* 4e71 pad to 0x868 */

/* ---- functab @0x868 ---- */
_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_dsstub
	.long	_query
	.long	_vec36
	.long	_setid
	.long	_errstr
	.long	-1
_name:	.ascii	"cddb.library\0"
	.byte	0,0,0
_idstr:	.ascii	"cddb.library 44.999\0"

/* ---- _runlist @0x8b0: ctx fn-list iterator (a4=ctx) ---- */
_runlist:
	movel	%d7,%sp@-
	moveq	#0,%d7
	addql	#4,%a4@(92)		/* cursor */
	bras	_rltest
_rlloop:
	tstb	%a4@(100)		/* done flag */
	bnes	_rlcall
	tstl	%d7
	bnes	_rlskip
_rlcall:
	moveal	%a4@(92),%a1
	moveal	%a1@,%a0
	jsr	%a0@
	movel	%d0,%d7
_rlskip:
	addql	#4,%a4@(92)
_rltest:
	moveal	%a4@(92),%a0
	tstl	%a0@
	bnes	_rlloop
	moveb	#1,%a4@(100)
	movel	%d7,%d0
	movel	%sp@+,%d7
	rts
	nop

/* ---- _sdiv @0x8e8: signed divide wrapper ---- */
_sdiv:	tstl	%d0
	bplw	_sdp0
	negl	%d0
	tstl	%d1
	bplw	_sdn
	negl	%d1
	bsrw	_divmod
	negl	%d1
	rts
_sdn:	bsrw	_divmod
	negl	%d0
	negl	%d1
	rts
_sdp0:	tstl	%d1
	bplw	_divmod
	negl	%d1
	bsrw	_divmod
	negl	%d0
	rts

/* ---- _divmod @0x91a: d0/d1 -> d0=quot d1=rem ---- */
_divmod:
	movel	%d2,%sp@-
	swap	%d1
	movew	%d1,%d2
	bnew	_dvdiff
	swap	%d0
	swap	%d1
	swap	%d2
	movew	%d0,%d2
	beqw	_dvd2
	divuw	%d1,%d2
	movew	%d2,%d0
_dvd2:	swap	%d0
	movew	%d0,%d2
	divuw	%d1,%d2
	movew	%d2,%d0
	swap	%d2
	movew	%d2,%d1
	movel	%sp@+,%d2
	rts
_dvdiff:
	movel	%d3,%sp@-
	moveq	#16,%d3
	cmpiw	#256,%d1
	bccw	_dv4
	roll	#8,%d1
	subqw	#8,%d3
_dv4:	cmpiw	#4096,%d1
	bccw	_dv8
	roll	#4,%d1
	subqw	#4,%d3
_dv8:	cmpiw	#16384,%d1
	bccw	_dv16
	roll	#2,%d1
	subqw	#2,%d3
_dv16:	tstw	%d1
	bmiw	_dvgo
	roll	#1,%d1
	subqw	#1,%d3
_dvgo:	movew	%d0,%d2
	lsrl	%d3,%d0
	swap	%d2
	clrw	%d2
	lsrl	%d3,%d2
	swap	%d3
	divuw	%d1,%d0
	movew	%d0,%d3
	movew	%d2,%d0
	movew	%d3,%d2
	swap	%d1
	muluw	%d1,%d2
	subl	%d2,%d0
	bccw	_dvfix
	subqw	#1,%d3
	addl	%d1,%d0
_dvfix:	moveq	#0,%d1
	movew	%d3,%d1
	swap	%d3
	roll	%d3,%d0
	swap	%d0
	exg	%d0,%d1
	movel	%sp@+,%d3
	movel	%sp@+,%d2
	rts

/* ---- tail data @0x9aa (reached via h1 ptr 0x9ac) ---- */
	.byte	0x00,0x00
_stub0:					/* h1+0x50 -> 0x9ac */
	.short	0x307c,0x0004		/* movew #4,d0 */
	.short	0x2950			/* ??? raw bytes */
	.short	0x0068,0x7000,0x4e75

	.globl	_name
	.globl	_idstr
	.globl	_functab
	.globl	_dt0
	.globl	_init
	.globl	_err0,_err1,_err2,_err3,_err4,_err5,_err6
	.globl	_err7,_err8,_err9,_err10,_err11,_runlist,_stub0
	.globl	_dsstub
	.end
