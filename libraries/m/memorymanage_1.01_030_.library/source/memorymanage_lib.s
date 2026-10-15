/*
 * memorymanage_lib.s -- memorymanage.library 1.01 (c) 2000
 *
 * Header, functab, strings, PMMU supervisor bodies, the two canned MMU
 * context blocks, and the page-table walker (mm_map / mm_mapid).
 *
 * The library builds a 3-level 68030 descriptor tree (128*32MB root,
 * 128*256KB level-B, 64*4KB level-C; TC=0x80c07760 -> TIA=7,TIB=7,TIC=6)
 * over an identity-mapped physical space so callers can re-describe
 * ranges with per-page flags.
 *
 * mm_map is transcribed verbatim from the shipped binary (hunk 0x2a2-
 * 0x4d1) because two defects live in its control flow and cannot be
 * expressed in C:
 *   - a non-initialized call jumps into the movem-restore epilogue
 *     without a pushed frame: it eats 56 bytes of caller stack and
 *     returns through garbage;
 *   - the level-B "descend for the <256KB remainder" branch targets the
 *     C-table fill loop (0x458) instead of the descend path (0x3fe), so
 *     it runs a dbf fill with stale a3(a4)/d3/d4, links a bogus free
 *     node at a4+256, then writes B[d1]=2 (a table descriptor pointing
 *     at address 0) and stores PTEs into low memory.
 */

	.section	.text

_libentry:
	moveq	#-1,d0				/* hunk+0 "run" entry: -1 */
	rts

_romtag:
	.word	0x4afc				/* RT_MATCHWORD */
	.long	_romtag				/* RT_MATCHTAG (relocated) */
	.long	0				/* RT_ENDSKIP = 0, shipped oddity */
	.byte	0x80				/* RTF_AUTOINIT */
	.byte	1				/* rt_Version */
	.byte	9				/* NT_LIBRARY */
	.byte	0				/* rt_Pri */
	.long	_libname
	.long	_idstr
	.long	_inittab

	.even
_inittab:
	.long	0x4f				/* sizeof(struct MMBase) = 79 */
	.long	_functab
	.long	0				/* no datatab */
	.long	_mm_initfunc

/* 11 vectors + $ffff terminator */
_functab:
	.long	_mm_open			/* -6  */
	.long	_mm_close			/* -12 */
	.long	_mm_expunge			/* -18 */
	.long	_mm_reserved			/* -24 */
	.long	_mm_enable			/* -30 create/adopt MMU tables */
	.long	_mm_disable			/* -36 release tables */
	.long	mm_map				/* -42 map pages -> a2 */
	.long	mm_mapid			/* -48 identity-map shim */
	.long	_mm_saveregs			/* -54 store MMU regs to block */
	.long	_mm_loadregs			/* -60 load MMU regs from block */
	.long	_mm_vatophys			/* -66 translate VA -> phys */
	.word	-1
	.word	-1

_libname:
	.ascii	"memorymanage.library\0"
_verstr:
	.ascii	"$VER:"
_idstr:
	.ascii	"memorymanage 1.01 (c) 2000\0"
	.even

/* ------------------------------------------------------------------ */
/* supervisor bodies -- run via exec Supervisor() in system context    */
/* ------------------------------------------------------------------ */

	.globl	_mm_sup_load
_mm_sup_load:					/* hunk 0x248: a0 = 28B ctx block */
	pmove	a0@,crp
	pmove	a0@(8),srp
	pmove	a0@(16),tt0
	pmove	a0@(20),tt1
	pmove	a0@(24),tc
	pflusha
	rte

	.globl	_mm_sup_save
_mm_sup_save:					/* hunk 0x570: a0 = 30B ctx block */
	pmove	crp,a0@
	pmove	srp,a0@(8)
	pmove	tt0,a0@(16)
	pmove	tt1,a0@(20)
	pmove	tc,a0@(24)
	pmove	psr,a0@(28)			/* MMUSR/PSR is read-only */
	rte

	.globl	_mm_sup_ptest
_mm_sup_ptest:					/* hunk 0x536: a0 = VA -> a1 = &desc */
	ptestr	#1,a0@,#7,a1
	rte

/* ------------------------------------------------------------------ */
/* canned MMU register images                                          */
/* ------------------------------------------------------------------ */

	.globl	_mm_ctx_enable
_mm_ctx_enable:					/* hunk 0x26a LAB_0017 */
	.long	0x7fff0002			/* CRP limit 0x7fff, DT=2 */
	.long	0				/*      addr patched -> root */
	.long	0x7fff0002			/* SRP limit 0x7fff, DT=2 */
	.long	0				/*      addr patched -> root */
	.long	0x00ff0107			/* TT0 */
	.long	0x00ff0107			/* TT1 */
	.long	0x80c07760			/* TC: E,PS=12(4K),TIA7,TIB7,TIC6 */

	.globl	_mm_ctx_disable
_mm_ctx_disable:				/* hunk 0x286 LAB_0018 */
	.long	0x7fff0001			/* CRP DT=1 (invalid) */
	.long	0
	.long	0x7fff0001			/* SRP DT=1 */
	.long	0
	.long	0x00ff0107			/* TT0 */
	.long	0x00ff0107			/* TT1 */
	.long	0x00c07760			/* TC: E=0 -> translation off */

/* ------------------------------------------------------------------ */
/* -42 mm_map(d0=len, a0=va, a1=pa, d1=flags) -> a2                    */
/*     verbatim transcription of hunk 0x2a2-0x4d1                      */
/* ------------------------------------------------------------------ */

	.globl	mm_map
mm_map:
	tst.l	38(a6)				/* 2a2 */
	beq	mm_done				/* 2a6 -> LAB_0024 (no frame!) */
	movem.l	d0-d7/a0-a1/a3-a6,-(sp)		/* 2aa */
	and.l	#0xfffff000,d0			/* 2ae len &= ~0xfff */
	move.l	a1,d2				/* 2b4 */
	and.l	#0xfffff000,d2			/* 2b6 */
	move.b	d1,d3				/* 2bc flags bit1 -> bit6 (CI) */
	lsl.b	#5,d3				/* 2be */
	and.b	#0x40,d3			/* 2c0 */
	add.b	d3,d2				/* 2c4 */
	move.b	d1,d3				/* 2c6 flags bit2 -> bit2 */
	and.b	#0x04,d3			/* 2c8 */
	add.b	d3,d2				/* 2cc */
	not.b	d1				/* 2ce */
	and.b	#0x01,d1			/* 2d0 ~flags bit0 -> DT bit0 */
	add.b	d1,d2				/* 2d4 */
	movea.l	d2,a1				/* 2d6 a1 = PTE */
	movea.l	38(a6),a2			/* 2d8 */
	tst.b	78(a6)				/* 2dc foreign MMU? */
	bne.s	mm_rent				/* 2e0 */
	move.l	4(a2),d1			/* 2e2 node.block */
	addq.l	#8,d1				/* 2e6 */
	addq.l	#7,d1				/* 2e8 */
	and.l	#0xfffffff0,d1			/* 2ea */
	movea.l	d1,a2				/* 2f0 a2 = root table */
mm_rent:					/* 2f2 LAB_001A */
	move.l	a0,d1				/* 2f2 */
	rol.l	#7,d1				/* 2f4 */
	and.w	#0x007f,d1			/* 2f6 root idx = VA[31:25] */
	move.l	a0,d2				/* 2fa */
	and.l	#0x01ffffff,d2			/* 2fc */
	bne.s	mm_rdesc			/* 302 */
mm_rfill:					/* 304 LAB_001B */
	cmp.l	#0x02000000,d0			/* 304 */
	bcs.s	mm_rdesc			/* 30a */
	move.l	a1,a2@(d1.w*4)			/* 30c root[d1] = pte */
	adda.l	#0x02000000,a1			/* 310 */
	adda.l	#0x02000000,a0			/* 316 */
	subi.l	#0x02000000,d0			/* 31c */
	beq	mm_done				/* 322 a2 = root */
	addq.w	#1,d1				/* 326 */
	and.w	#0x007f,d1			/* 328 */
	bra.s	mm_rfill			/* 32c */
mm_rdesc:					/* 32e LAB_001C */
	move.l	a2@(d1.w*4),d2			/* 32e */
	and.l	#0xfffffff0,d2			/* 332 */
	movea.l	d2,a3				/* 338 */
	btst	#1,a2@(3,d1.w*4)		/* 33a DT bit1 of low byte */
	bne	mm_bdesc			/* 340 already a table */
	movem.l	d0-d1/a0-a2,-(sp)		/* 344 */
	move.l	#0x00000220,d0			/* 348 */
	move.l	#0x00000001,d1			/* 34e MEMF_PUBLIC */
	movem.l	a6,-(sp)			/* 354 */
	movea.l	4.w,a6				/* 358 */
	jsr	-684(a6)			/* 35c AllocVec */
	movem.l	(sp)+,a6			/* 360 */
	move.l	d0,d2				/* 364 */
	movem.l	(sp)+,d0-d1/a0-a2		/* 366 */
	beq	mm_fail				/* 36a */
	movea.l	d2,a5				/* 36e a5 = block */
	addq.l	#8,d2				/* 370 */
	addq.l	#7,d2				/* 372 */
	and.l	#0xfffffff0,d2			/* 374 */
	movea.l	d2,a3				/* 37a a3 = new B table */
	moveq	#127,d3				/* 37c */
	move.l	a2@(d1.w*4),d4			/* 37e d4 = old root desc */
	and.l	#0xfffc0000,d4			/* 382 256KB-aligned base */
mm_bfill:					/* 388 LAB_001D split 32MB->128*256KB */
	move.l	d4,d5				/* 388 */
	addq.l	#1,d5				/* 38a */
	move.l	d5,(a3)+			/* 38c */
	addi.l	#0x00040000,d4			/* 38e */
	dbf	d3,mm_bfill			/* 394 */
	move.l	42(a6),(a3)			/* 398 node.next = freelist */
	move.l	a3,42(a6)			/* 39c freelist = node */
	move.l	a5,4(a3)			/* 3a0 node.block */
	lea	a2@(d1.w*4),a5			/* 3a4 */
	move.l	a5,8(a3)			/* 3a8 node.descaddr */
	move.l	a2@(d1.w*4),12(a3)		/* 3ac node.olddesc */
	movea.l	d2,a3				/* 3b2 a3 = new B table */
	addq.l	#2,d2				/* 3b4 */
	move.l	d2,a2@(d1.w*4)			/* 3b6 root[d1] = newtab|2 */
mm_bdesc:					/* 3ba LAB_001E */
	move.l	a0,d1				/* 3ba */
	rol.l	#7,d1				/* 3bc */
	rol.l	#7,d1				/* 3be B idx = VA[24:18] */
	and.w	#0x007f,d1			/* 3c0 */
	move.l	a0,d2				/* 3c4 */
	and.l	#0x0003ffff,d2			/* 3c6 */
	bne.s	mm_cdesc			/* 3cc */
mm_bloop:					/* 3ce LAB_001F */
	cmp.l	#0x00040000,d0			/* 3ce */
	bcs	mm_cfill			/* 3d4 SHIPPED DEFECT -> LAB_0021 */
	move.l	a1,a3@(d1.w*4)			/* 3d8 B[d1] = pte */
	adda.l	#0x00040000,a1			/* 3dc */
	adda.l	#0x00040000,a0			/* 3e2 */
	subi.l	#0x00040000,d0			/* 3e8 */
	beq	mm_outa3			/* 3ee LAB_0026 a2 = B tab */
	addq.w	#1,d1				/* 3f2 */
	cmp.w	#0x0080,d1			/* 3f4 */
	bcc	mm_rent				/* 3f8 wrap -> LAB_001A */
	bra.s	mm_bloop			/* 3fc */
mm_cdesc:					/* 3fe LAB_0020 */
	move.l	a3@(d1.w*4),d2			/* 3fe */
	and.l	#0xfffffff0,d2			/* 402 */
	movea.l	d2,a4				/* 408 */
	btst	#1,a3@(3,d1.w*4)		/* 40a */
	bne	mm_cidx				/* 410 already a table */
	movem.l	d0-d1/a0-a2,-(sp)		/* 414 */
	move.l	#0x00000120,d0			/* 418 */
	move.l	#0x00000001,d1			/* 41e */
	movem.l	a6,-(sp)			/* 424 */
	movea.l	4.w,a6				/* 428 */
	jsr	-684(a6)			/* 42c AllocVec */
	movem.l	(sp)+,a6			/* 430 */
	move.l	d0,d2				/* 434 */
	movem.l	(sp)+,d0-d1/a0-a2		/* 436 */
	beq	mm_fail				/* 43a */
	movea.l	d2,a5				/* 43e */
	addq.l	#8,d2				/* 440 */
	addq.l	#7,d2				/* 442 */
	and.l	#0xfffffff0,d2			/* 444 */
	movea.l	d2,a4				/* 44a a4 = new C table */
	moveq	#63,d3				/* 44c */
	move.l	a3@(d1.w*4),d4			/* 44e d4 = old B desc */
	and.l	#0xfffff000,d4			/* 452 4KB-aligned base */
mm_cfill:					/* 458 LAB_0021 split 256KB->64*4KB */
	move.l	d4,d5				/* 458 */
	addq.l	#1,d5				/* 45a */
	move.l	d5,(a4)+			/* 45c */
	addi.l	#0x00001000,d4			/* 45e */
	dbf	d3,mm_cfill			/* 464 */
	move.l	42(a6),(a4)			/* 468 node.next = freelist */
	move.l	a4,42(a6)			/* 46c freelist = node */
	move.l	a5,4(a4)			/* 470 node.block */
	lea	a3@(d1.w*4),a5			/* 474 */
	move.l	a5,8(a4)			/* 478 node.descaddr */
	move.l	a3@(d1.w*4),12(a4)		/* 47c node.olddesc */
	movea.l	d2,a4				/* 482 a4 = new C table */
	addq.l	#2,d2				/* 484 */
	move.l	d2,a3@(d1.w*4)			/* 486 B[d1] = newtab|2 */
mm_cidx:					/* 48a LAB_0022 */
	move.l	a0,d1				/* 48a */
	ror.l	#8,d1				/* 48c */
	ror.l	#4,d1				/* 48e C idx = VA[17:12] */
	and.w	#0x003f,d1			/* 490 */
mm_cloop:					/* 494 LAB_0023 */
	cmp.l	#0x00001000,d0			/* 494 */
	bcs.s	mm_done				/* 49a a2 = whatever */
	move.l	a1,a4@(d1.w*4)			/* 49c C[d1] = pte */
	adda.l	#0x00001000,a1			/* 4a0 */
	adda.l	#0x00001000,a0			/* 4a6 */
	subi.l	#0x00001000,d0			/* 4ac */
	beq.s	mm_outa4			/* 4b2 LAB_0025 a2 = C tab */
	addq.w	#1,d1				/* 4b4 */
	cmp.w	#0x0040,d1			/* 4b6 */
	bcc	mm_bdesc			/* 4ba wrap -> LAB_001E */
	bra.s	mm_cloop			/* 4be */
mm_done:					/* 4c0 LAB_0024 */
	movem.l	(sp)+,d0-d7/a0-a1/a3-a6		/* 4c0 a2 is NOT restored */
	rts					/* 4c4 */
mm_outa4:					/* 4c6 LAB_0025 */
	movea.l	a4,a2				/* 4c6 */
	bra.s	mm_done				/* 4c8 */
mm_outa3:					/* 4ca LAB_0026 */
	movea.l	a3,a2				/* 4ca */
	bra.s	mm_done				/* 4cc */
mm_fail:					/* 4ce LAB_0027 */
	movea.l	d0,a2				/* 4ce a2 = 0 */
	bra.s	mm_done				/* 4d0 */

/* -48 mm_mapid(d0=len, a0=va) -> a2 : identity-map shim (hunk 0x4d2) */
	.globl	mm_mapid
mm_mapid:
	movem.l	d1/a1,-(sp)			/* 4d2 */
	movea.l	a0,a1				/* 4d6 pa = va */
	clr.l	d1				/* 4d8 flags = 0 */
	bsr	mm_map				/* 4da bsr.w in original */
	movem.l	(sp)+,d1/a1			/* 4de */
	rts					/* 4e2 */
