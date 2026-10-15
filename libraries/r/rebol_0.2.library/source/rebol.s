/*
 * rebol.library 0.2 (07.07.2001) -- byte-exact reconstruction.
 * Single CODE hunk (2780 bytes). AUTOINIT RomTag, InitTable @0x1e,
 * InitStruct datatab @0x2e, functab (absolute longs) @0x730.
 * Public API: RebolDo(-30), RebolFreeResult(-36).
 * C-compiled original (link/unlk frames, stack-arg helpers, a4 context).
 */
	.text
	.globl	_romtag

/* ---------- 0x00: ROM entry stub ---------- */
	moveq	#-1,d0
	rts

/* ---------- 0x04: RomTag ---------- */
_romtag:
	.short	0x4afc
	.long	_romtag			/* matchtag */
	.long	_endskip		/* endskip -> 0x1fe */
	.byte	0x80,0,9,0		/* AUTOINIT, ver 0, NT_LIBRARY, pri 0 */
	.long	_name			/* "rebol.library" */
	.long	_idstr			/* "$VER: rebol.library 0.2 ..." */
	.long	_inittab		/* InitTable @0x1e */

/* ---------- 0x1e: InitTable ---------- */
_inittab:
	.long	0x2c			/* dsize = 44 (struct Library) */
	.long	_functab		/* 0x730 */
	.long	_datatab		/* 0x2e */
	.long	_initfn			/* 0x4e */

/* ---------- 0x2e: InitStruct datatab ----------
 * a0xx = byte at offset xx (data word, value in high byte)
 * 80xx = long, 90xx = word. Quirk: idstring field (offset 24)
 * gets _name, not _idstr. Trailing word 0x000e after terminator.
 */
_datatab:
	.short	0xa008,0x0900		/* ln_Type = NT_LIBRARY */
	.short	0x800a
	.long	_name			/* ln_Name */
	.short	0xa00e,0x0600		/* lib_Flags = 6 (SUMUSED|CHANGED) */
	.short	0x9014,0x0000		/* lib_Version = 0 */
	.short	0x9016,0x0002		/* lib_Revision = 2 */
	.short	0x8018
	.long	_name			/* lib_IdString -> "rebol.library" (!) */
	.short	0			/* terminator */
	.short	0x000e			/* stray pad word */

/* ---------- 0x4e: initfn (d0=lib,a0=seglist,a6=sysbase) ---------- */
_initfn:
	moveml	a1/a5,sp@-
	moveal	d0,a5
	lea	a5@(34),a1		/* &lib->seglist cell */
	bset	#0,a1@(9)		/* set bit0 of lib+43 ("survived one expunge") */
	movel	a0,a1@			/* lib+34 = seglist */
	clrl	a1@(4)			/* lib+38 = ctxlist head = 0 */
	movel	a5,d0
	moveml	sp@+,a1/a5
	rts

/* ---------- 0x6c: Open (LVO -6) ---------- */
_open:
	addqw	#1,a6@(32)		/* OpenCnt++ */
	bsrw	_findslot		/* find ctx slot for ThisTask */
	cmpal	#0,a0
	bnew	_openbump
	bsrw	_newslot		/* none -> alloc/link ctx node */
	braw	_openinit
_openfail:
	subqw	#1,a6@(32)
	moveq	#0,d0
	rts
_openinit:
	moveml	d2-d7/a0/a2-a6,sp@-
	moveal	a0,a5			/* a5 = slot+4 */
	bsrw	_ctxinit		/* build ctx (opens dos/intuition/gfx) */
	moveml	sp@+,d2-d7/a0/a2-a6
	tstl	d0
	beqs	_openfail
_openbump:
	addiw	#1,a0@(4)		/* slot.count++ */
	movel	a6,d0
	rts

/* ---------- 0xaa: Close (LVO -12) ---------- */
_close:
	bsrw	_findslot
	cmpal	#0,a0
	beqw	_closeret		/* no slot -> rts */
	subiw	#1,a0@(4)		/* slot.count-- */
	moveq	#0,d0
	tstw	a0@(4)
	bnew	_closeret
	moveml	d2-d7/a2-a6,sp@-
	moveal	a0@,a4			/* a4 = ctx */
	clrl	a0@			/* slot.ctx = 0 */
	clrl	a0@-			/* slot.task = 0 (frees slot) */
	bsrw	_ctxfree		/* tear down ctx */
	moveml	sp@+,d2-d7/a2-a6
	moveq	#0,d0
	subqw	#1,a6@(32)		/* OpenCnt-- */
	bnes	_closeret
	bsrw	_expunge		/* count hit 0 -> expunge */
_closeret:
	rts

/* ---------- 0xe8: Expunge (LVO -18) ---------- */
_expunge:
	moveml	d2/d7/a4-a6,sp@-
	lea	a6@(34),a4		/* a4 = &seglist cell */
	moveal	a6,a5
	tstw	a5@(32)			/* OpenCnt != 0 -> fail */
	bnes	_exzero
	btst	#0,a4@(9)		/* lib+43 bit0 set (from init) -> */
	beqs	_exdo			/*   clear it once, stay resident */
	bclr	#0,a4@(9)
_exzero:
	moveq	#0,d0
	bras	_exdone
_exdo:
	movel	a4@,d7			/* d7 = seglist */
	.short	0x2c79,0,4		/* moveal 0x4:w,a6 (SysBase) */
	moveal	a4@(4),a4		/* a4 = ctx node list @ lib+38 */
_explp:	moveal	a4,a1
	moveal	a1@,a4			/* next node */
	movel	#2564,d0		/* node size */
	jsr	a6@(-210)		/* FreeMem */
	cmpal	#0,a4
	bnew	_explp
	moveal	a5,a1
	jsr	a6@(-252)		/* Remove */
	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(16),d0		/* NegSize */
	subal	d0,a1
	addw	a5@(18),d0		/* + PosSize */
	jsr	a6@(-210)		/* FreeMem */
	movel	d7,d0			/* return seglist */
_exdone:
	moveml	sp@+,d2/d7/a4-a6
	rts

/* ---------- 0x14e: LVO -24 stub ---------- */
_stub24:
	moveq	#0,d0
	rts

/* ---------- 0x152: find ctx slot for ThisTask ----------
 * ctx nodes @ lib+38 (singly linked): node+0=next,
 * then 255 10-byte slots at +4: {task.l, ctx.l, count.w}
 * returns a0 = slot+4 (&ctx field) or 0.
 */
_findslot:
	lea	a6@(38),a0
	moveal	a0@,a0
	.short	0x2278,4		/* moveal 0x4:w,a1 */
	movel	a1@(276),d0		/* SysBase->ThisTask */
_fsnxt:	cmpal	#0,a0
	beqw	_fsfail
	moveal	a0,a1
	moveal	a1@,a0			/* a0 = next node */
	addql	#8,a1			/* a1 = node+8 = &slot[0]+4 */
	movel	#255,d1
_fsscan:
	cmpl	a1@(-4),d0		/* slot.task == ThisTask? */
	beqw	_fsfound
	lea	a1@(10),a1		/* next slot (+10) */
	dbf	d1,_fsscan
	braw	_fsnxt
_fsfail:
	rts				/* a0 = 0 */
_fsfound:
	moveal	a1,a0			/* a0 = slot+4 */
	rts

/* ---------- 0x190: find free slot / alloc ctx node ---------- */
_newslot:
	lea	a6@(38),a0
	moveal	a0@,a0
	.short	0x2278,4
	movel	a1@(276),d0		/* ThisTask */
_nsnxt:	cmpal #0,a0
	beqw	_nsalloc
	moveal	a0,a1
	moveal	a1@,a0
	addql	#8,a1
	movel	#255,d1
_nsscan:
	tstl	a1@(-4)			/* slot.task == 0 -> free slot */
	beqw	_nsfree
	lea	a1@(10),a1
	dbf	d1,_nsscan
	braw	_nsnxt
_nsalloc:
	moveml	d0/a6,sp@-
	.short	0x2c78,4		/* moveal 0x4:w,a6 */
	movel	#2564,d0
	movel	#0x10001,d1		/* MEMF_PUBLIC|MEMF_CLEAR */
	jsr	a6@(-198)		/* AllocMem */
	moveal	d0,a0			/* NULL not checked (!) */
	moveml	sp@+,d0/a6
	lea	a6@(38),a1
	movel	a1@,a0@			/* link node at head */
	movel	a0,a1@
	addql	#8,a0
	movel	d0,a0@(-4)		/* slot[0].task = ThisTask */
	rts
_nsfree:
	moveal	a1,a0
	movel	d0,a0@(-4)		/* slot.task = ThisTask */
	rts

/* ---------- 0x1fe: ctx init (a5 = slot+4, a6 = lib) ----------
 * Allocs 3896-byte ctx buffer (MEMF_PUBLIC only, NOT cleared),
 * switches SP into it under Forbid, links a4 frame, opens
 * intuition/graphics/dos v33. Returns -1 ok, 0 fail.
 * NOTE: rt_EndSkip points HERE (not at hunk end).
 */
_ctxinit:
_endskip:
	moveal	sp,a3
	.short	0x2c78,4		/* moveal 0x4:w,a6 = SysBase */
	movel	#3896,d0
	movel	#0x10000,d1		/* MEMF_PUBLIC (no CLEAR!) */
	movel	d0,d2
	jsr	a6@(-198)		/* AllocMem */
	tstl	d0
	beqw	_ctxzero		/* -> rts, d0=0 */
	movel	d0,d6			/* d6 = ctx buf */
	addl	d2,d0			/* top of buffer */
	jsr	a6@(-132)		/* Forbid */
	moveal	d0,sp			/* run on stack inside ctx buf */
	addal	#0,sp			/* (nop adda.l #0) */
	linkw	a4,#-512		/* ctx frame @ buf+3896-516 */
	jsr	a6@(-138)		/* Permit */
	movel	a3,a4@(-4)		/* ctx-4 = old SP */
	movel	d6,a4@(-64)		/* ctx-64 = buffer base */
	movel	a6,a4@(-40)		/* ctx-40 = SysBase */
	lea	_libintui(pc),a1
	moveq	#33,d0
	jsr	a6@(-552)		/* OpenLibrary("intuition.library",33) */
	movel	d0,a4@(-48)		/* ctx-48 */
	beqw	_ctxfail0
	lea	_libgfx(pc),a1
	moveq	#33,d0
	jsr	a6@(-552)
	movel	d0,a4@(-52)		/* ctx-52 */
	beqw	_ctxfail1
	lea	_libdos(pc),a1
	moveq	#33,d0
	jsr	a6@(-552)
	movel	d0,a4@(-44)		/* ctx-44 */
	beqw	_ctxfail2
	movel	a4,a5@			/* slot.ctx = a4 */
	bras	_ctxok			/* -> jmp _ctxret */
_libdos:	.ascii	"dos.library"
	.byte	0
_libintui:	.ascii	"intuition.library"
	.byte	0
_libgfx:	.ascii	"graphics.library"
	.byte	0,0			/* pad to even */
_ctxok:	.short	0x4ef9
	.long	_ctxret			/* jmp _ctxret (abs, relocated) */
_ctxzero:
	rts				/* 0x2b0 rts (also call target!) */
/* ---------- 0x2b2: ctx teardown (a4 = ctx) ---------- */
_ctxfree:
	.short	0x4eb9
	.long	_closecon		/* jsr _closecon (abs, relocated) */
	.short	0x4eb9
	.long	_ctxzero		/* jsr _ctxzero -> rts (noop call) */
	movel	sp,a4@(-4)
	.short	0x2c78,4		/* moveal 0x4:w,a6 */
	moveal	a4@(-20),a2		/* ctx-20 alloc list (NEVER init'd) */
	movel	a2,d0
	beqs	_cflibs
_cflp:	moveal	a2,a1
	movel	a2@(4),d0		/* size */
	moveal	a2@,a2			/* next */
	jsr	a6@(-210)		/* FreeMem */
	movel	a2,d0
	bnes	_cflp
_cflibs:
	moveal	a4@(-44),a1
	jsr	a6@(-414)		/* CloseLibrary(dos) */
_ctxfail2:
	moveal	a4@(-52),a1
	jsr	a6@(-414)		/* CloseLibrary(gfx) */
_ctxfail1:
	moveal	a4@(-48),a1
	jsr	a6@(-414)		/* CloseLibrary(intuition) */
_ctxfail0:
	movel	#3896,d0
	moveal	a4@(-64),a1
	moveal	a4@(-4),sp		/* restore caller SP */
	jsr	a6@(-210)		/* FreeMem(ctx buf) */
	moveq	#0,d0
	rts

/* ---------- 0x30c / 0x31a: name + id strings ---------- */
_name:	.ascii	"rebol.library"
	.byte	0
_idstr:	.ascii	"$VER: rebol.library 0.2 (07.07.2001) (22:55:56/"
	.byte	0xa9
	.ascii	" 2000,2001 Jean Holzammer <Development@Holzammer.net>)"
	.byte	0,0

/* ---------- 0x382: ctx-init success epilogue ----------
 * (entered via the abs jmp at _ctxok): restores caller SP, returns -1.
 */
_ctxret:
	bsrw	_minus1			/* d0 = -1 */
	bsrw	_zero392		/* d0 = 0 */
	moveal	a4@(-4),sp		/* restore caller SP */
	moveq	#-1,d0			/* return -1 */
	rts
/* ---------- 0x392 ---------- */
_zero392:
	linkw	a5,#0
	moveq	#0,d0
	unlk	a5
	rts

/* ---------- 0x39c: RebolDo core (a4 = ctx; arg @ a5@(8)) ---------- */
_reboldo:
	linkw	a5,#-32
	lea	sp@(-1004),sp		/* buf1: 1000 counted bytes */
	movel	sp,a5@(-24)
	clrw	sp@
	movel	#0x03e80000,sp@-	/* hdr: cap=1000 */
	clrl	sp@-
	lea	sp@(-1204),sp		/* buf2: 1200 counted bytes */
	movel	sp,a5@(-4)
	clrw	sp@
	movel	#0x04b00000,sp@-
	clrl	sp@-
	lea	sp@(-52),sp		/* buf3: 48 */
	movel	sp,a5@(-20)
	clrw	sp@
	movel	#0x00320000,sp@-
	clrl	sp@-
	lea	sp@(-104),sp		/* buf4: 100 */
	movel	sp,a5@(-32)
	clrw	sp@
	movel	#0x00640000,sp@-
	clrl	sp@-
	moveml	d3-d4,sp@-
	addaw	#-16,sp
	lea	_strcount2(pc),a0	/* "RebolLibCount" (#2) */
	movel	a0,d0
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	movel	a5@(-20),sp@(4)
	moveq	#50,d0
	movel	d0,sp@(8)
	clrl	sp@(12)
	moveal	a4@(-44),a6		/* DOSBase */
	moveml	sp@+,d1-d4
	jsr	a6@(-906)		/* dos GetVar */
	moveml	sp@+,d3-d4
	movel	a5@(-20),sp@-
	pea	0:w
	bsrw	_strtol			/* parse env count */
	addql	#8,sp
	movel	d0,a5@(-8)
	movel	a5@(-8),d0
	.short	0xb0bc,0,1		/* cmpl #1,d0 */
	bgew	_rdok
	moveq	#1,d0
	movel	d0,a5@(-8)
	braw	_rdfmt
_rdok:	addql	#1,a5@(-8)		/* count++ */
_rdfmt:
	moveml	d3-d4,sp@-
	addaw	#-16,sp
	lea	_strcount1(pc),a0	/* "RebolLibCount" (#1) */
	movel	a0,d0
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	movel	a5@(-20),sp@-
	pea	_strpctld(pc)		/* "%ld" */
	.short	0xdefc,0xfffc		/* addaw #-4,sp */
	movel	a5@(-8),d0
	movel	d0,sp@
	pea	4:w
	bsrw	_fmt
	addaw	#16,sp
	movel	d0,sp@(4)
	moveq	#3,d0
	movel	d0,sp@(8)
	clrl	sp@(12)
	moveal	a4@(-44),a6
	moveml	sp@+,d1-d4
	jsr	a6@(-900)		/* dos SetVar */
	moveml	sp@+,d3-d4
	addaw	#-8,sp
	movel	a5@(-32),sp@-
	pea	_strscript(pc)		/* "T:RebolLibScript.%ld" */
	.short	0xdefc,0xfffc
	movel	a5@(-8),d0
	movel	d0,sp@
	pea	4:w
	bsrw	_fmt
	addaw	#16,sp
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	movel	#1006,sp@(4)		/* MODE_NEWFILE */
	moveal	a4@(-44),a6
	moveml	sp@+,d1-d2
	jsr	a6@(-30)		/* dos Open(scriptpath) */
	movel	d0,a5@(-12)		/* fh */
	tstl	d0
	beqw	_rdres
	movel	a5@(-12),a4@(-8)	/* ctx-8 = script fh */
	pea	_strrebol(pc)		/* REBOL [] wrapper script */
	.short	0xdefc,0xfff8		/* addaw #-8,sp */
	movel	a5@(8),d0		/* arg: source string */
	movel	d0,sp@
	movel	a5@(-8),d0
	movel	d0,sp@(4)
	pea	8:w
	bsrw	_fputs			/* format wrapper + FPuts to script fh */
	addaw	#16,sp
	moveq	#0,d0
	movel	d0,a4@(-8)		/* ctx-8 = 0 */
	movel	a5@(-12),d1
	moveal	a4@(-44),a6
	jsr	a6@(-36)		/* dos Close(script fh) */
	moveml	d3-d4,sp@-
	addaw	#-16,sp
	lea	_strhome(pc),a0		/* "REBOL_HOME" */
	movel	a0,d0
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	movel	a5@(-24),sp@(4)
	movel	#1000,sp@(8)
	clrl	sp@(12)
	moveal	a4@(-44),a6
	moveml	sp@+,d1-d4
	jsr	a6@(-906)		/* GetVar("REBOL_HOME") */
	moveml	sp@+,d3-d4
	addaw	#-8,sp
	movel	a5@(-4),sp@-
	pea	_strcmd(pc)		/* "%sRebol -cs %s" */
	.short	0xdefc,0xfff8		/* addaw #-8,sp */
	movel	a5@(-24),d0
	movel	d0,sp@
	movel	a5@(-32),d0
	movel	d0,sp@(4)
	pea	8:w
	bsrw	_fmt			/* buf2 = "<home>Rebol -cs <script>" */
	addaw	#20,sp
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	clrl	sp@(4)
	moveal	a4@(-44),a6
	moveml	sp@+,d1-d2
	jsr	a6@(-606)		/* dos SystemTagList(cmd, NULL) */
	movel	a5@(-32),d1
	moveal	a4@(-44),a6
	jsr	a6@(-72)		/* DeleteFile(script) */
_rdres:
	addaw	#-8,sp
	movel	a5@(-32),sp@-
	pea	_strresult(pc)		/* "T:RebolLibResult.%ld" */
	.short	0xdefc,0xfffc
	movel	a5@(-8),d0
	movel	d0,sp@
	pea	4:w
	bsrw	_fmt
	addaw	#16,sp
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	movel	#1005,sp@(4)		/* MODE_OLDFILE */
	moveal	a4@(-44),a6
	moveml	sp@+,d1-d2
	jsr	a6@(-30)		/* Open(resultpath) */
	movel	d0,a5@(-12)
	tstl	d0
	beqw	_rdout
	addaw	#-8,sp
	movel	a5@(-32),sp@-
	bsrw	_filesize		/* Lock+Examine -> fib_Size */
	addql	#4,sp
	.short	0x2f40,0x0000		/* movel d0,sp@(0) */
	clrl	sp@(4)
	moveal	a4@(-40),a6		/* SysBase */
	moveml	sp@+,d0-d1
	jsr	a6@(-684)		/* AllocVec(size) */
	movel	d0,a5@(-16)
	tstl	d0
	beqw	_rdnobuf
	movel	a5@(-12),sp@-
	movel	a5@(-32),sp@-
	bsrw	_filesize
	addql	#4,sp
	movel	d0,sp@-
	pea	1:w
	movel	a5@(-16),sp@-
	bsrw	_readfile		/* Read(fh, buf, size) + count */
	addaw	#16,sp
_rdnobuf:
	movel	a5@(-12),d1
	moveal	a4@(-44),a6
	jsr	a6@(-36)		/* Close(result fh) */
	movel	a5@(-16),a5@(-28)
	movel	a5@(-32),d1
	moveal	a4@(-44),a6
	jsr	a6@(-72)		/* DeleteFile(result) */
_rdout:
	movel	a5@(-28),d0		/* return result buf / 0 */
	addal	#2396,sp
	unlk	a5
	rts

/* ---------- 0x64e: RebolFreeResult core (arg @ a5@(8)) ---------- */
_freecore:
	linkw	a5,#0
	movel	a5@(8),d0
	beqw	_fcret
	moveal	a5@(8),a1
	moveal	a4@(-40),a6		/* SysBase */
	jsr	a6@(-690)		/* FreeVec */
_fcret:	moveq	#0,d0
	unlk	a5
	rts

/* ---------- strings 0x66c-0x72b ---------- */
_strresult:	.ascii	"T:RebolLibResult.%ld"
	.byte	0
_strcmd:	.ascii	"%sRebol -cs %s"
	.byte	0
_strhome:	.ascii	"REBOL_HOME"
	.byte	0
_strrebol:	.ascii	"REBOL []\nresult: none\n%s\nif NOT none? result [write/binary %%/T/RebolLibResult.%ld result]\n"
	.byte	0
_strscript:	.ascii	"T:RebolLibScript.%ld"
	.byte	0
_strpctld:	.ascii	"%ld"
	.byte	0
_strcount1:	.ascii	"RebolLibCount"
	.byte	0
_strcount2:	.ascii	"RebolLibCount"
	.byte	0

/* ---------- 0x72c: return -1 ---------- */
_minus1:
	moveq	#-1,d2			/* (sic) */
	rts

/* ---------- 0x730: functab (absolute longs) ---------- */
_functab:
	.long	_open,_close,_expunge,_stub24,_rdovec,_freevec
	.long	0xffffffff

/* ---------- 0x74c: find ctx for ThisTask -> a4 ---------- */
_findctx:
	moveml	d0-d1/a0-a1,sp@-
	lea	a6@(38),a0
	moveal	a0@,a0
	.short	0x2278,4		/* moveal 0x4:w,a1 */
	movel	a1@(276),d0		/* ThisTask */
_fcnxt:	moveal	a0,a1
	moveal	a1@,a0
	addql	#8,a1
	movel	#255,d1
_fcscan:
	cmpl	a1@(-4),d0
	beqw	_fcfound
	lea	a1@(10),a1
	dbf	d1,_fcscan
	cmpal	#0,a0
	bnew	_fcnxt
	subal	a4,a4			/* a4 = 0 */
	rts
_fcfound:
	moveal	a1@,a4			/* a4 = slot.ctx */
	moveml	sp@+,d0-d1/a0-a1
	rts

/* ---------- 0x790: RebolDo veneer (LVO -30), d0 = source ---------- */
_rdovec:
	moveml	d2/a2-a6,sp@-
	movel	d0,sp@-
	bsrw	_findctx
	bsrw	_reboldo
	addql	#4,sp
	moveml	sp@+,d2/a2-a6
	rts

/* ---------- 0x7a6: RebolFreeResult veneer (LVO -36), d0 = result --- */
_freevec:
	moveml	d2/a2-a6,sp@-
	movel	d0,sp@-
	bsrw	_findctx
	bsrw	_freecore
	addql	#4,sp
	moveml	sp@+,d2/a2-a6
	rts

/* ---------- 0x7bc: close ctx CON handle ---------- */
_closecon:
	movel	a4@(-12),d1		/* ctx-12 = con fh */
	beqw	_ccret
	moveal	a4@(-44),a6		/* DOSBase */
	movel	d1,d4
	moveq	#0,d2
	moveq	#0,d3
	jsr	a6@(-42)		/* dos Read(fh,0,0) -- nop-ish */
	movel	d4,d1
	jsr	a6@(-36)		/* dos Close */
	clrl	a4@(-12)
_ccret:	rts

/* ---------- 0x7de: sprintf into ctx fmt buf, then copy into a
 * counted dest buffer (cap word @ dest-4, remaining word @ dest-2).
 * args: sp@(4)=index into its own arg block ---------- */
_fmt:
	movel	sp@(4),d0
	moveal	sp@(8,d0:l),a0		/* a0 = dest (arg[idx]) */
	lea	sp@(8),a1		/* a1 = &args */
	lea	_putch(pc),a2
	.short	0x2c78,4		/* moveal 0x4:w,a6 */
	moveal	a4@(-64),a3		/* a3 = ctx fmt buf (3896) */
	movel	a3,d2
	jsr	a6@(-522)		/* RawDoFmt(fmt,args,putch,buf) */
	moveal	d2,a1			/* a1 = formatted str */
	movel	sp@(4),d0
	moveal	sp@(0xc,d0:l),a0	/* a0 = dest (arg[idx]) -- disp 0xc! */
	moveal	a0,a2
	moveq	#0,d0
	movew	a0@(-4),d0		/* capacity word */
	movel	d0,d2
	subql	#1,d0
_fcopy:	moveb	a1@+,a0@+
	beqs	_fcdone
	dbf	d0,_fcopy
	moveb	#0,a0@+
_fcdone:
	addqw	#1,d0
	subw	d0,d2
	movew	d2,a2@(-2)		/* store remaining space */
	movel	d2,d1
	extl	d1
	movel	a2,d0
	rts
_putch:	moveb	d0,a3@+
	rts

/* ---------- 0x832: strtol-ish (sp@(24)=str -> a2, sp@(20)=out d5) ---
 * handles '-', '$' hex, '%' binary, decimal. returns d0, d1=consumed.
 */
_strtol:
	moveml	d3-d6,sp@-
	moveal	sp@(24),a2		/* a2 = string */
	movel	sp@(20),d5		/* d5 = out ptr (may be 0) */
	moveq	#0,d6			/* neg flag */
_stskip:
	moveb	a2@+,d0
	beqw	_stzero
	.short	0xb03c,33		/* cmpb #33,d0 */			/* skip <= ' ' */
	bmis	_stskip
	subql	#1,a2
	cmpib	#45,a2@			/* '-'? */
	bnes	_stnomin
	addql	#1,a2
	moveq	#-1,d6
_stnomin:
	cmpib	#36,a2@			/* '$' -> hex */
	beqw	_sthex
	cmpib	#37,a2@			/* '%' -> binary */
	beqw	_stbin
	lea	a2@(11),a1		/* max 11 digits */
	moveal	a2,a0			/* a0 = start */
_stscan:
	moveb	a2@+,d0
	.short	0xb03c,58		/* cmpb #58,d0 */
	bpls	_stsdone
	.short	0xb03c,48		/* cmpb #48,d0 */
	bpls	_stscan
_stsdone:
	subql	#1,a2
	movel	a2,d4			/* d4 = end */
	cmpal	a2,a0
	beqs	_stzero			/* no digits */
	moveq	#0,d0
	cmpal	a1,a2			/* > 11 digits? */
	bpls	_stzero
	lea	_pow10(pc),a3
_declp:	moveq	#0,d3
	moveb	a2@-,d3
	movel	a3@+,d2			/* next pow10 */
	subib	#48,d3
	movel	d3,d1
	muluw	d2,d3			/* 32x32 -> 64 via two mulu */
	swap	d2
	muluw	d2,d1
	swap	d1
	addl	d1,d3
	addl	d3,d0
	bcss	_stzero			/* overflow */
	cmpal	a0,a2
	bnes	_declp
	bras	_stout
_pow10:	.long	1,10,100,1000,10000,100000
	.long	1000000,10000000,100000000,1000000000
_stout:
	subl	sp@(24),d4		/* d4 = chars consumed */
	tstl	d5
	beqs	_stsign
	moveal	d5,a0
	movel	d4,a0@			/* *d5 = consumed */
_stsign:
	tstl	d6
	beqs	_stpos
	negl	d0
_stpos:	movel	d4,d1
	moveml	sp@+,d3-d6
	rts
_stzero:
	moveq	#0,d0
	moveq	#0,d1
	tstl	d5
	beqs	_stz2
	moveal	d5,a0
	clrl	a0@
_stz2:	moveml	sp@+,d3-d6
	rts
_sthex:
	addql	#1,a2			/* skip '$' */
	moveal	a2,a0
	movel	a0,d3
	moveq	#0,d1			/* value */
	moveq	#0,d2			/* nibble count */
_hxscan:
	moveb	a0@+,d0
	.short	0xb03c,71		/* cmpb #71,d0 */			/* > 'F'? */
	bpls	_hxbig
	.short	0xb03c,48		/* cmpb #48,d0 */
	bmis	_hxdone
	.short	0xb03c,58		/* cmpb #58,d0 */
	bpls	_hxup			/* '9'<c<'A' check */
	bras	_hxscan
_hxdone:
	subql	#1,a0
	movel	a0,d4
	cmpl	a0,d3
	beqs	_stzero			/* none */
_hxlp:	cmpl	a0,d3
	beqs	_hxret
	moveq	#0,d0
	moveb	a0@-,d0
	.short	0xb03c,65		/* cmpb #65,d0 */
	bpls	_hxalpha
	subib	#48,d0
_hxsh:	.short	0xb47c,32		/* cmpw #32,d2 */
	beqw	_stzero			/* >32 nibbles -> fail */
	lsll	d2,d0
	addl	d0,d1
	addql	#4,d2
	bras	_hxlp
_hxret:	movel	d1,d0
	bras	_stout
_hxup:	.short	0xb03c,65		/* cmpb #65,d0 */			/* 'A'-'F' ok? */
	bpls	_hxscan
	bras	_hxdone
_hxbig:	.short	0xb03c,97		/* cmpb #97,d0 */			/* 'a'-'f' */
	bmis	_hxdone
	.short	0xb03c,103		/* cmpb #103,d0 */
	bpls	_hxdone
	bras	_hxscan
_hxalpha:
	.short	0xb03c,97		/* cmpb #97,d0 */
	bpls	_hxlow
	subib	#55,d0			/* 'A'-'F' -> 10-15 */
	bras	_hxsh
_hxlow:	subib	#87,d0			/* 'a'-'f' -> 10-15 */
	bras	_hxsh
_stbin:
	addql	#1,a2			/* skip '%' */
	moveal	a2,a0
	movel	a0,d3
	moveq	#0,d1
	moveq	#0,d2
_bnscan:
	moveb	a0@+,d0
	.short	0xb03c,49		/* cmpb #49,d0 */			/* '1' */
	beqs	_bnscan
	.short	0xb03c,48		/* cmpb #48,d0 */			/* '0' */
	beqs	_bnscan
	subql	#1,a0
	movel	a0,d4
	cmpl	a0,d3
	beqw	_stzero
_bnlp:	cmpl	a0,d3
	beqs	_bnret
	moveq	#0,d0
	moveb	a0@-,d0
	.short	0xb03c,48		/* cmpb #48,d0 */
	beqs	_bnno
	.short	0x05c1			/* bset d2,d1 (encoded 'bsetb') */
_bnno:	.short	0xb47c,32		/* cmpw #32,d2 */
	beqw	_stzero
	addql	#1,d2
	bras	_bnlp
_bnret:	movel	d1,d0
	braw	_stout

/* ---------- 0x9bc: filesize(path) via Lock/Examine -> d0 or -1 ---- */
_filesize:
	moveml	d4/d6-d7,sp@-
	movel	sp@(16),d1		/* path */
	moveq	#-2,d2			/* SHARED_LOCK */
	moveal	a4@(-44),a6		/* DOSBase */
	jsr	a6@(-84)		/* dos Lock */
	movel	d0,d7
	beqs	_fszfail
	movel	d0,d1
	movel	#-260,d4
	movel	sp,d0
	btst	#1,d0			/* keep FIB stack long-aligned */
	beqs	_fseven
	subql	#2,d4
_fseven:
	lea	sp@(0,d4:l),sp		/* FIB on stack */
	movel	sp,d2
	jsr	a6@(-102)		/* dos Examine */
	movel	sp@(124),d6		/* fib_Size */
	negl	d4
	lea	sp@(0,d4:l),sp
	tstl	d0
	beqs	_fsunlock
	bsrw	_fsunlock2
	movel	d6,d0
	moveml	sp@+,d4/d6-d7
	rts
_fsunlock2:
	movel	d7,d1
	jsr	a6@(-90)		/* dos UnLock */
	rts
_fsunlock:
	bsrs	_fsunlock2
_fszfail:
	moveq	#-1,d0
	moveml	sp@+,d4/d6-d7
	rts

/* ---------- 0xa1a: FPuts(fmt'd) to ctx-8 fh; if none, open CON:
 * and jmp *(ctx-24) -- ctx-24 is NEVER INITIALIZED (bug). -------- */
_fputs:
	tstl	a4@(-8)
	beqw	_fpcon
	movel	sp@(4),d0
	moveal	sp@(8,d0:l),a0		/* a0 = fmt */
	lea	sp@(8),a1		/* a1 = args */
	lea	_fpput(pc),a2
	.short	0x2c78,4
	moveal	a4@(-64),a3
	movel	a3,d2
	jsr	a6@(-522)		/* RawDoFmt */
	movel	a4@(-8),d1		/* fh */
	moveal	a4@(-44),a6		/* DOSBase */
	jsr	a6@(-342)		/* dos FPuts(fh, str) */
	moveal	d2,a0
_fplen:	tstb	a0@+
	bnes	_fplen
	subal	d2,a0
	subql	#1,a0
	movel	a0,d0			/* return strlen */
	rts
_fpput:	moveb	d0,a3@+
	rts
_fpcon:	lea	_strcon(pc),a0		/* "CON:0/11/640/80/Output" */
	movel	a0,d1
	movel	#1006,d2		/* MODE_NEWFILE */
	moveal	a4@(-44),a6
	jsr	a6@(-30)		/* dos Open */
	movel	d0,a4@(-12)		/* ctx-12 = con fh */
	movel	d0,a4@(-8)
	tstl	d0
	bnes	_fputs+8		/* -> retry at movel sp@(4),d0 */
	moveq	#20,d0			/* error */
	movel	d0,a4@(-28)
	moveal	a4@(-24),a0		/* ctx-24: uninitialized! */
	jmp	a0@			/* jmp *(garbage) */
_strcon:	.ascii	"CON:0/11/640/80/Output"
	.byte	0,0

/* ---------- 0xaa2: Read(fh,buf,size) via dos; returns #chunks ----- */
_readfile:
	moveal	d3,a3
	movel	sp@(16),d1		/* fh */
	movel	sp@(12),d0		/* size */
	moveq	#0,d2
	movel	sp@(8),d3		/* =1 (pointless multiplier) */
	subql	#1,d3
_rfmul:	addl	d0,d2			/* d2 = size*1 */
	dbf	d3,_rfmul
	moveal	a4@(-44),a6		/* DOSBase */
	movel	sp@(4),d3		/* buf */
	exg	d2,d3			/* d2=buf, d3=size */
	jsr	a6@(-42)		/* dos Read(fh,buf,size) */
	moveq	#-1,d1
	movel	sp@(12),d2		/* size */
_rfcnt:	addql	#1,d1
	subl	d2,d0
	bplw	_rfcnt			/* count size-chunks read */
	movel	d1,d0
	movel	a3,d3
	rts
