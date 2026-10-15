/*
 * cachefile_lib.s -- cachefile.library 1.67 (25.8.94)  (c) Ralph Schmidt 1993
 *
 * Header, lifecycle and embedded "CacheFile_Notify" daemon.
 * The daemon is launched by CreateNewProc with a BPTR pointing into this
 * hunk (hunk+0x238); it runs in-place from the library's own segment and
 * talks back through the statics at hunk+0xf0 (libbase) / hunk+0xf4
 * (daemon task handoff).
 *
 * Shipped quirk: vector -18 and Close's expunge path both land on the
 * "return 0" stub at 0x1be.  The real expunge body at 0x1c2 is dead
 * code -- the library can never actually be expunged.
 */

	.section	.text

_libentry:
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			/* RT_MATCHWORD */
	.long	_romtag			/* RT_MATCHTAG */
	.long	_endskip		/* RT_ENDSKIP */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	1
	.byte	9			/* NT_LIBRARY */
	.byte	0
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"cachefile.library\0"
_idstr:
	.ascii	"assembler/library/cachefile 1.67 (25.8.94)\r\n\0"
	.byte	0xa9			/* (c) */
	.ascii	" Ralph Schmidt 1993\0"
_procname:
	.ascii	"CacheFile_Notify\0"
_dosname:
	.ascii	"dos.library\0"

	.even
_inittab:
	.long	0x76			/* sizeof(struct CFileBase) = 118 */
	.long	_functab
	.long	_datatab
	.long	_initfunc

/* 11 vectors + -1L terminator */
_functab:
	.long	_open			/* -6  */
	.long	_close			/* -12 */
	.long	_stub			/* -18 -> return 0 (expunge dead) */
	.long	_reserved		/* -24 -> return 0 */
	.long	_cf_find		/* -30 find node by name */
	.long	_cf_load		/* -36 load fh into named node */
	.long	_cf_free		/* -42 free one node */
	.long	_cf_freeall		/* -48 free all nodes */
	.long	_cf_getlist		/* -54 -> &list */
	.long	_cf_data		/* -60 -> node data buf */
	.long	_cf_size		/* -66 -> node filesize */
	.long	-1

/* InitStruct: NT_LIBRARY, ln_Name, flags 6, ver 1, rev 0, idstr */
_datatab:
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE @8 = 9 */
	.byte	0x80,0x0a		/* INITLONG @0xa */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE @0xe = 6 */
	.byte	0x90,0x14		/* INITWORD @0x14 */
	.word	1
	.byte	0x90,0x16		/* INITWORD @0x16 */
	.word	0
	.byte	0x80,0x18		/* INITLONG @0x18 */
	.long	_idstr
	.word	0
	.word	0			/* shipped pad word */

/* statics (absolute + pc-relative refs from init/expunge/daemon) */
	.globl	_lbase
_lbase:	.long	0				/* hunk+0xf0 */
	.globl	_ltask
_ltask:	.long	0				/* hunk+0xf4 */

/* initFunc: d0=base, a0=seglist, a6=sysbase.
 * stores statics, opens dos.library (Alert 0x38007 on failure),
 * inits sem + list, patches NP_Seglist BPTR, spawns the daemon. */
_initfunc:
	moveml	a5-a6,sp@-
	moveal	d0,a5
	movel	d0,_lbase			/* static libbase for daemon */
	movel	a6,a5@(36)			/* SysBase */
	movel	a0,a5@(44)			/* seglist */
	lea	_dosname(pc),a1
	moveq	#0,d0
	jsr	a6@(-552)			/* OpenLibrary */
	movel	d0,a5@(40)			/* DOSBase */
	bnes	1f
	moveml	d7/a5-a6,sp@-
	movel	#229383,d7			/* Alert 0x38007 */
	moveal	0x4,a6
	jsr	a6@(-108)
	moveml	sp@+,d7/a5-a6
1:	lea	a5@(94),a0			/* NewList(lh@94) */
	movel	a0,a0@(8)
	addql	#4,a0
	clrl	a0@
	movel	a0,a0@-
	lea	a5@(48),a0			/* InitSemaphore(sem@48) */
	jsr	a6@(-558)
	lea	_daemonseg(pc),a0
	movel	a0,d0
	lsrl	#2,d0				/* BPTR(daemonseg) */
	lea	_tags+12(pc),a0
	movel	d0,a0@				/* patch NP_Seglist data */
	lea	_tags(pc),a0
	movel	a0,d1				/* TagItem* in d1 */
	moveal	a5@(40),a6			/* DOSBase */
	jsr	a6@(-498)			/* CreateNewProc */
	tstl	d0
	bnes	2f
	moveml	sp@+,a5-a6
	rts					/* fail: returns d0 = 0 */
2:	movel	a5,d0				/* success: return base */
	moveml	sp@+,a5-a6
	rts

/* CreateNewProc TagItem array (patched at init) */
_tags:	.long	0x800003f4			/* NP_Name */
	.long	_procname
	.long	0x800003e9			/* NP_Seglist */
	.long	0				/* patched: BPTR(daemon) */
	.long	0x800003ea			/* NP_FreeSeglist */
	.long	0
	.long	0x800003f3			/* NP_StackSize */
	.long	0x1000
	.long	0				/* TAG_DONE */

/* -6 */
_open:	addqw	#1,a6@(32)
	bclr	#3,a6@(34)
	movel	a6,d0
	rts

/* -12: on last close + flag3 the original branches to _stub,
 * NOT to _deadexpunge -- the library never expunges. */
_close:	moveq	#0,d0
	subqw	#1,a6@(32)
	bnes	1f
	btst	#3,a6@(34)
	beqs	1f
	braw	_stub
1:	rts

/* -18: shipped stub -- real expunge body below is dead code */
_stub:	moveq	#0,d0
	rts

/* DEAD CODE (hunk+0x1c2): the intended expunge, never reached.
 * Emitted verbatim: Remove, free nodes, signal daemon (bit 12),
 * busy-wait for its ack, CloseLibrary(dos), FreeMem, ret seglist. */
_deadexpunge:
	moveml	d2/a5-a6,sp@-
	moveal	a6,a5
	moveal	a5@(36),a6
	tstw	a5@(32)
	beqw	2f
	bset	#3,a5@(34)
	moveq	#0,d0
	bras	3f
2:	movel	a5@(44),d2			/* seglist */
	moveal	a5,a1
	jsr	a6@(-252)			/* Remove */
	moveal	a5,a6
	bsrw	_cf_freenodes			/* free all cache nodes */
	moveal	a5@(36),a6
	movel	_ltask(pc),d1			/* daemon task */
	beqs	1f
	moveal	d1,a1
	movel	#0x1000,d0
	jsr	a6@(-324)			/* Signal(daemon,bit12) */
1:	tstl	_ltask
	bnes	1b				/* busy-wait for ack */
	moveal	a5@(40),a1
	jsr	a6@(-414)			/* CloseLibrary(dos) */
	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(16),d0
	subal	d0,a1
	addw	a5@(18),d0
	jsr	a6@(-210)			/* FreeMem */
	movel	d2,d0
3:	moveml	sp@+,d2/a5-a6
	rts

_reserved:
	moveq	#0,d0
	rts
	.word	0x4e71

/* ---------------------------------------------------------------
 * embedded daemon (launched by CreateNewProc at seg+0x238)
 * --------------------------------------------------------------- */
	.long	0				/* hunk+0x234 pad */
_daemonseg:
	.long	0				/* hunk+0x238 seglist link */
_daemon:
	moveal	_lbase(pc),a5			/* libbase static */
	moveal	a5@(36),a6			/* execbase */
	movel	a6@(276),_ltask			/* ThisTask -> handoff */
	jsr	a6@(-666)			/* CreateMsgPort */
	movel	d0,a5@(110)			/* base->notifyport */
	moveal	d0,a4
	moveq	#0,d7
	moveb	a4@(15),d0			/* mp_SigBit */
	bset	d0,d7				/* d7 = waitmask */
d_loop:	moveal	a5@(36),a6
	moveal	a4,a0
	jsr	a6@(-372)			/* GetMsg */
	tstl	d0
	bnes	d_msg
	movel	d7,d0
	jsr	a6@(-318)			/* Wait(waitmask) */
	btst	#12,d0
	bnew	d_quit
	moveal	a4,a0
	jsr	a6@(-372)			/* GetMsg */
	tstl	d0
	beqs	d_loop
d_msg:	addqw	#1,a5@(32)			/* opencnt++ (block expunge) */
	movel	d0,sp@-
	bsrw	_sem_obtain			/* ObtainSemaphore */
	moveal	sp@+,a1
	moveal	a5@(36),a6
	moveal	a1@(26),a3			/* nm_NReq -> NR */
	jsr	a6@(-378)			/* ReplyMsg */
d_flush:lea	a4@(20),a0			/* port msglist */
	cmpal	a0@(8),a0			/* list empty? */
	beqw	d_work
	moveal	a0@,a0			/* head node */
	moveal	a0@(26),a0			/* its nm_NReq */
	cmpal	a0,a3
	bnes	d_work
	moveal	a4,a0
	jsr	a6@(-372)			/* GetMsg */
	tstl	d0
	beqs	d_work
	moveal	d0,a1
	jsr	a6@(-378)			/* reply same-NR msgs */
	bras	d_flush
d_work:	lea	a3@(-14),a3			/* NR-14 = node */
	lea	a5@(94),a2			/* node list */
d_scan:	moveal	a2@,a2
	tstl	a2@
	beqs	d_done
	cmpal	a2,a3
	beqs	d_found
	bras	d_scan
d_found:
	moveal	a5@(40),a6			/* DOSBase */
	lea	a3@(318),a0			/* node->path */
	movel	a0,d1
	movel	#1005,d2			/* MODE_READWRITE */
	jsr	a6@(-30)			/* Open */
	movel	d0,d6
	bnes	1f
	braw	d_relse
1:
	moveal	a5,a6				/* libbase */
	moveal	a3@(10),a1			/* node->name */
	bsrw	_cf_load			/* reload into fresh node */
	moveal	a5@(40),a6			/* DOSBase */
	movel	d6,d1
	jsr	a6@(-36)			/* Close */
d_relse:
	moveal	a5,a6
	moveal	a3,a1
	bsrw	_cf_free			/* drop the stale node */
d_done:	bsrw	_sem_release
	subqw	#1,a5@(32)			/* opencnt-- */
	braw	d_loop
d_quit:	moveal	a5@(36),a6
	moveal	a5@(110),a0
	jsr	a6@(-672)			/* DeleteMsgPort */
	clrl	_ltask				/* release expunge wait */
	rts

/* semaphore helpers (shared by daemon + API) -------------------- */
	.globl	_sem_obtain
_sem_obtain:					/* 0x330: ObtainSemaphore(sem@48) */
	moveal	a5@(36),a6
	lea	a5@(48),a0
	jmp	a6@(-564)

	.globl	_sem_release
_sem_release:					/* 0x33c: ReleaseSemaphore */
	moveal	a5@(36),a6
	lea	a5@(48),a0
	jmp	a6@(-570)

	.globl	_sem_locksh
_sem_locksh:					/* 0x348: shared-obtain shim */
	moveal	a5@(36),a6
	cmpiw	#39,a6@(20)			/* exec lib_Version < 39? */
	bcss	1f
	lea	a5@(48),a0
	jmp	a6@(-678)			/* V39+: ObtainSemaphoreShared */
1:	lea	a5@(48),a0
	jsr	a6@(-720)			/* AttemptSemaphoreShared */
	tstl	d0
	beqs	2f
	lea	a5@(48),a0
	jsr	a6@(-576)			/* AttemptSemaphore */
	tstl	d0
	beqs	2f
	lea	a5@(48),a0
	jmp	a6@(-678)			/* ObtainSemaphoreShared */
2:	rts

	.globl	_sem_unlocksh
_sem_unlocksh:					/* 0x37e: ReleaseSemaphore */
	moveal	a5@(36),a6
	lea	a5@(48),a0
	jmp	a6@(-570)

	.even
_endskip:
	.word	0
