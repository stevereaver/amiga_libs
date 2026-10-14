/*
 * queue.library 3.2 -- byte-exact reconstruction, hunk0 (main CODE).
 * AUTOINIT RomTag; InitTable lives in hunk1 (DATA, embedded at h1+4),
 * the absolute-long functab + name/id strings live in hunk2 (CODE).
 *
 * Quirks preserved verbatim:
 *  - ln_Name / ln_IdString written as literal constants 0x38 / 0x48
 *    (hunk2-relative offsets, never relocated -> broken pointers).
 *  - rt_EndSkip = h0+0x1e (just past the RomTag, not the hunk end).
 *  - initfn copies the 28-byte hunk1 template (which *contains* the
 *    relocated InitTable fields) into lib+48 via an overlapped
 *    `cmpiw #0x1cd9,d0` / `moveb (a1)+,(a6)+` instruction pair.
 *  - functab[3] = 0 -> relocated to the h0+0 stub (not a null entry).
 *  - compiler frame idiom: `subqw #4,sp` prologues and
 *    `movel a6,sp@(N)` libbase stash/reload around exec calls.
 */
	.text
	.globl	_qstub
	.globl	_romtag
	.globl	_endskip

_qstub:	moveq	#0,d0
	rts

_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,0x03,0x09,0x00
	.long	_qname
	.long	_qidstr
	.long	_qdata+4
_endskip:
	.short	0

/* ---------- initfn @ 0x20 ---------- */
	.globl	_initfn
_initfn:
	subqw	#8,sp
	moveml	d7/a2-a3/a5-a6,sp@-
	moveal	d0,a5
	movel	a0,a5@(34)
	moveb	#9,a5@(8)
	movel	#_qname,a5@(10)
	moveb	#6,a5@(14)
	.short	0x43f9,0,3		/* lea 0x3:l,a1 - version */
	movel	a1,d0
	lea	a5@(20),a0
	movew	d0,a0@+
	.short	0x43f9,0,2		/* lea 0x2:l,a1 - revision */
	movel	a1,d0
	movew	d0,a0@+
	movel	#_qidstr,a0@+
	lea	a5@(48),a3
	.short	0x43f9,0,7		/* lea 0x7:l,a1 - 7 longs */
	movel	a1,d0
	movel	d0,d1
	asll	#2,d1
	movel	a6,sp@(24)
	lea	_qdata,a1
	moveal	a3,a6
_copy:	cmpiw	#0x1cd9,d0	/* overlaps moveb a1@+,a6@+ */
	subql	#1,d1
	bccs	_copy+2
	asll	#2,d0
	lea	_qdata,a0
	addal	d0,a0
	movel	a0@,d7
	lea	a0@(4),a2
	moveal	sp@(24),a6
	bras	_fixtest
_fixlp:	movel	a3,d0
	addl	a2@+,d0
	movel	a3,d1
	moveal	d0,a0
	addl	d1,a0@
	subql	#1,d7
_fixtest:
	tstl	d7
	bgts	_fixlp
	moveal	a5,a6
	bsrw	_initctx
	tstl	d0
	moveal	sp@(24),a6
	beqs	_iret+2		/* -> movel a5,d0 inside the cmpiw */
	moveq	#0,d0
_iret:	cmpiw	#0x200d,d0	/* overlaps movel a5,d0 */
_idone:	moveml	sp@+,d7/a2-a3/a5-a6
	addqw	#8,sp
	rts

/* ---------- -6 Open @ 0xc4 ---------- */
	.globl	_open
_open:	subqw	#4,sp
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	addqw	#4,sp
	rts

/* ---------- -12 Close @ 0xd6 ---------- */
	.globl	_close
_close:	subqw	#4,sp
	movel	d7,sp@-
	moveq	#0,d7
	subqw	#1,a6@(32)
	movel	a6,sp@(4)
	tstw	a6@(32)
	bnes	_cdone
	btst	#3,a6@(14)
	beqs	_cdone
	bsrw	_expunge
	movel	d0,d7
_cdone:	movel	d7,d0
	movel	sp@+,d7
	addqw	#4,sp
	rts

/* ---------- -18 Expunge @ 0x100 ---------- */
	.globl	_expunge
_expunge:
	subqw	#4,sp
	moveml	d2/d7/a5-a6,sp@-
	moveal	a6,a5
	moveq	#0,d7
	bset	#3,a5@(14)
	movel	a6,sp@(16)
	tstw	a5@(32)
	bnes	_edone
	moveal	a5,a6
	bsrw	_restore
	movel	a5@(34),d7
	moveal	a5,a1
	moveal	0x4,a6
	jsr	a6@(-252)
	moveq	#0,d0
	movew	a5@(18),d0
	moveq	#0,d1
	movew	a5@(16),d1
	movel	d1,d2
	addl	d0,d2
	moveal	a5,a1
	moveq	#0,d0
	movew	d1,d0
	subal	d0,a1
	movel	d2,d0
	jsr	a6@(-210)
_edone:	movel	d7,d0
	moveml	sp@+,d2/d7/a5-a6
	addqw	#4,sp
	rts
	nop

/* ---------- helper: reparent node (Remove + Enqueue) @ 0x158 ---- */
_rechain:
	subqw	#4,sp
	moveml	a2-a3/a5-a6,sp@-
	moveal	sp@(28),a3
	moveal	sp@(24),a5
	moveal	a5@(12),a2
	movel	a6,sp@(16)
	tstl	a5@(28)
	beqs	_rc2
	lea	a5@(28),a0
	moveal	a0,a1
	moveal	0x4,a6
	jsr	a6@(-252)
_rc2:	lea	a2@(14),a0
	lea	a5@(28),a1
	movel	a2,sp@-
	moveal	a3,a2
	moveal	0x4,a6
	jsr	a6@(-234)
	moveal	sp@+,a2
	moveml	sp@+,a2-a3/a5-a6
	addqw	#4,sp
	rts

/* ---------- helper: Remove + clear @ 0x1a0 ---------- */
_rmvclear:
	subqw	#4,sp
	moveml	a5-a6,sp@-
	moveal	sp@(16),a5
	lea	a5@(28),a0
	movel	a6,sp@(8)
	moveal	a0,a1
	moveal	0x4,a6
	jsr	a6@(-252)
	clrl	a5@(28)
	moveml	sp@+,a5-a6
	addqw	#4,sp
	rts

/* ---------- helper: free a sub-node + signal @ 0x1c8 ---------- */
_killnode:
	subqw	#4,sp
	moveml	a3/a5-a6,sp@-
	moveal	sp@(20),a5
	movel	a6,sp@(12)
	tstw	a5@(10)
	bnes	_kn2
	moveal	a5@(16),a3
	moveal	a5,a1
	moveal	0x4,a6
	jsr	a6@(-252)
	lea	a3@(24),a0
	moveal	a5,a1
	jsr	a6@(-240)
	moveal	a3@(20),a1
	movel	a3@(16),d0
	jsr	a6@(-324)
	moveal	sp@(12),a6
	bras	_kn3
_kn2:	movew	#6,a5@(8)
_kn3:	moveml	sp@+,a3/a5-a6
	addqw	#4,sp
	rts

/* ---------- helper: dec/occupy counter, maybe kill @ 0x214 ------ */
_bump:
	subqw	#4,sp
	moveml	a3/a5,sp@-
	moveal	sp@(20),a3
	moveal	sp@(16),a5
	subqw	#1,a3@(10)
	addql	#1,a3@(12)
	movel	a6,sp@(8)
	movel	a3@(12),d0
	cmpl	a5@(32),d0
	bccs	_bk
	moveq	#6,d0
	cmpw	a3@(8),d0
	bnes	_bdone
_bk:	movel	a3,sp@-
	bsrs	_killnode
	addqw	#4,sp
_bdone:	moveml	sp@+,a3/a5
	addqw	#4,sp
	rts

/* ---------- helper: init lib+48 queue context @ 0x24e ---------- */
_initctx:
	subqw	#4,sp
	moveml	a4-a6,sp@-
	moveal	a6,a5
	lea	a6@(48),a4
	moveaw	#4,a0
	movel	a0@,a4@(20)
	movel	a5,a4@(24)
	movel	a6,sp@(12)
	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-558)
	pea	a4@(78)
	moveal	sp@(16),a6
	bsrw	_newlist
	addqw	#4,sp
	moveq	#0,d0
	moveml	sp@+,a4-a6
	addqw	#4,sp
	rts

/* ---------- helper: restore-regs frame @ 0x28e ---------- */
_restore:
	subqw	#4,sp
	moveml	a4-a6,sp@-
	moveal	a6,a5
	lea	a6@(48),a4
	moveml	sp@+,a4-a6
	addqw	#4,sp
	rts

/* ---------- -30 create queue @ 0x2a2 ---------- */
	.globl	_create
_create:
	subqw	#4,sp
	moveml	d2/d5-d7/a2-a6,sp@-
	movel	d1,d6
	movel	d0,d7
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a6,sp@(36)
	moveq	#42,d0
	movel	#0x10001,d1
	moveal	0x4,a6
	jsr	a6@(-198)
	moveal	d0,a3
	moveal	a3,a0
	movel	a0,d0
	moveal	sp@(36),a6
	bnes	_nodeok
	moveq	#0,d0
	braw	_crdone
_nodeok:
	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-564)
	lea	a4@(78),a0
	moveal	a5,a1
	jsr	a6@(-276)
	moveal	d0,a2
	moveal	a2,a0
	movel	a0,d0
	moveal	sp@(36),a6
	bnew	_crdup
	moveq	#96,d0
	movel	#0x10001,d1
	moveal	0x4,a6
	jsr	a6@(-198)
	moveal	d0,a2
	moveal	a2,a0
	movel	a0,d0
	moveal	sp@(36),a6
	bnes	_hdrok
	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveal	a3,a1
	moveq	#42,d0
	jsr	a6@(-210)
	moveq	#0,d0
	braw	_crdone
_hdrok:
	lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-558)
	lea	a2@(50),a0
	jsr	a6@(-564)
	moveal	a5,a0
_slen:	tstb	a0@+
	bnes	_slen
	subql	#1,a0
	subal	a5,a0
	movel	a0,d0
	movel	d0,d5
	addql	#1,d5
	movel	d5,d0
	moveq	#1,d1
	jsr	a6@(-198)
	movel	d0,a2@(10)
	tstl	d0
	moveal	sp@(36),a6
	bnes	_nameok
	lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	lea	a4@(32),a0
	jsr	a6@(-570)
	moveal	a3,a1
	moveq	#42,d0
	jsr	a6@(-210)
	moveal	a2,a1
	moveq	#96,d0
	jsr	a6@(-210)
	moveq	#0,d0
	braw	_crdone
_nameok:
	moveal	d0,a1
	moveal	a5,a0
	movel	d5,d0
	moveal	0x4,a6
	jsr	a6@(-624)
	lea	a4@(78),a0
	moveal	a2,a1
	jsr	a6@(-240)
	lea	a2@(36),a0
	movel	a0,sp@-
	moveal	sp@(40),a6
	bsrw	_newlist
	lea	a2@(14),a0
	movel	a0,sp@
	bsrw	_newlist
	addqw	#4,sp
	moveq	#1,d0
	movel	d0,a2@(28)
	bras	_crdone2
_crdup:
	lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-564)
	addql	#1,a2@(28)
_crdone2:
	lea	a2@(36),a0
	moveal	a3,a1
	moveal	0x4,a6
	jsr	a6@(-240)
	movel	d7,d0
	movew	d0,a3@(8)
	movel	a2,a3@(12)
	movel	d6,d1
	moveq	#0,d2
	bset	d1,d2
	movel	d2,a3@(16)
	subal	a1,a1
	jsr	a6@(-294)
	movel	d0,a3@(20)
	movel	d7,d0
	subql	#1,d0
	moveal	sp@(36),a6
	bnes	_crnosig
	addql	#1,a2@(32)
	movew	#10,a3@(36)
	moveal	a3@(20),a1
	movel	a3@(16),d0
	moveal	0x4,a6
	jsr	a6@(-324)
	moveal	sp@(36),a6
	bras	_crsem
_crnosig:
	lea	a3@(24),a0
	movel	a0,sp@-
	bsrw	_newlist
	addqw	#4,sp
_crsem:	lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	lea	a4@(32),a0
	jsr	a6@(-570)
	movel	a3,d0
_crdone:
	moveml	sp@+,d2/d5-d7/a2-a6
	addqw	#4,sp
	rts

/* ---------- -36 delete queue @ 0x45e ---------- */
	.globl	_delete
_delete:
	subaw	#16,sp
	moveml	d7/a2-a6,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a3
	moveal	a5,a2
	movel	a6,sp@(24)
	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-564)
	lea	a3@(50),a0
	jsr	a6@(-564)
	moveq	#2,d0
	cmpw	a2@(8),d0
	moveal	sp@(24),a6
	bnes	_dwalk
	movel	a2@(38),d7
	tstl	d7
	beqs	_dcont
	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	lea	a3@(50),a0
	jsr	a6@(-570)
	movel	d7,d0
	braw	_ddone
_dcont:	moveal	sp@(24),a6
	braw	_dunlink
_dwalk:	moveal	a2@(28),a0
	movel	a0,sp@(36)
	beqs	_dsub
	movel	a2,sp@-
	bsrw	_rmvclear
	addqw	#4,sp
	moveal	sp@(36),a0
	movel	a0@(4),sp@(28)
	bras	_dnext
_dsub:	moveal	a2@(24),a1
	movel	a1,sp@(36)
	beqs	_dnext
	subqw	#1,a1@(10)
	addql	#1,a1@(12)
	movel	a1,sp@(28)
_dnext:	movel	sp@(28),d0
	beqs	_dpre
	movel	d0,sp@(32)
_dscan:	moveal	sp@(32),a1
	moveal	a1@(4),a0
	movel	a0,sp@(28)
	beqs	_dout
	movew	a1@(8),d0
	moveq	#1,d1
	cmpw	d1,d0
	beqs	_dsig
	subqw	#6,d0
	bnes	_dadv
_dsig:	subql	#1,a1@(12)
_dadv:	movel	sp@(28),sp@(32)
	bras	_dscan
_dpre:	moveal	a3@(14),a0
	movel	a0,sp@(36)
_dout:	movel	sp@(36),sp@(32)
_dloop:	moveal	sp@(32),a1
	moveal	a1@,a0
	movel	a0,sp@(28)
	beqs	_dlast
	movew	a1@(8),d0
	moveq	#1,d1
	cmpw	d1,d0
	bnes	_dt6
	movel	a1@(12),d1
	cmpl	a3@(32),d1
	bccs	_dkill
_dt6:	subqw	#6,d0
	bnes	_dadv2
_dkill:	movel	a1,sp@-
	bsrw	_killnode
	addqw	#4,sp
_dadv2:	moveq	#10,d0
	moveal	sp@(32),a0
	cmpw	a0@(8),d0
	beqs	_dlast
	movel	sp@(28),sp@(32)
	bras	_dloop
_dlast:	subql	#1,a3@(32)
_dunlink:
	moveal	a2,a1
	moveal	0x4,a6
	jsr	a6@(-252)
	moveal	a2,a1
	moveq	#42,d0
	jsr	a6@(-210)
	subql	#1,a3@(28)
	moveal	sp@(24),a6
	bnes	_dsem
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveal	a3,a1
	jsr	a6@(-252)
	moveal	a3@(10),a0
	movel	a0,d0
_dlen:	tstb	a0@+
	bnes	_dlen
	subql	#1,a0
	subal	d0,a0
	movel	a0,d0
	addql	#1,d0
	moveal	a3@(10),a1
	jsr	a6@(-210)
	moveal	a3,a1
	moveq	#96,d0
	jsr	a6@(-210)
	moveal	sp@(24),a6
	bras	_dsem2
_dsem:	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
_dsem2:	lea	a4@(32),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveq	#0,d0
_ddone:	moveml	sp@+,d7/a2-a6
	addaw	#16,sp
	rts

/* ---------- -42 enqueue @ 0x5f2 ---------- */
	.globl	_enq
_enq:	subqw	#8,sp
	moveml	a2-a6,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a2
	movel	a5,sp@(24)
	movel	a5,a3@(16)
	clrw	a3@(10)
	clrl	a3@(12)
	movew	#1,a3@(8)
	lea	a2@(50),a0
	movel	a6,sp@(20)
	moveal	0x4,a6
	jsr	a6@(-564)
	lea	a2@(14),a0
	moveal	a3,a1
	jsr	a6@(-246)
	moveal	sp@(24),a0
	addql	#1,a0@(38)
	moveal	sp@(20),a6
	tstl	a2@(32)
	beqs	_eqfree
	movel	a2@(36),sp@(24)
_eqlp:	moveal	sp@(24),a0
	tstl	a0@
	beqs	_eqdone
	moveq	#1,d0
	cmpw	a0@(8),d0
	bnes	_eqnext
	moveal	a0@(20),a1
	movel	a0@(16),d0
	moveal	0x4,a6
	jsr	a6@(-324)
_eqnext:moveal	sp@(20),a6
	moveal	sp@(24),a0
	movel	a0@,sp@(24)
	bras	_eqlp
_eqfree:movel	a3,sp@-
	bsrw	_killnode
	addqw	#4,sp
_eqdone:lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveml	sp@+,a2-a6
	addqw	#8,sp
	rts

/* ---------- -48 remove-waiter @ 0x696 ---------- */
	.globl	_rmwait
_rmwait:
	subqw	#4,sp
	moveml	a2-a6,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a2
	lea	a2@(50),a0
	movel	a6,sp@(20)
	moveal	0x4,a6
	jsr	a6@(-564)
	movel	a3,sp@-
	moveal	sp@(24),a6
	bsrw	_killnode
	lea	a2@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	addqw	#4,sp
	moveml	sp@+,a2-a6
	addqw	#4,sp
	rts

/* ---------- -54 dequeue/head @ 0x6d8 ---------- */
	.globl	_deq
_deq:	subaw	#12,sp
	moveml	a2-a6,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a3
	moveal	a5,a2
	lea	a3@(50),a0
	movel	a6,sp@(20)
	moveal	0x4,a6
	jsr	a6@(-564)
	moveq	#2,d0
	cmpw	a2@(8),d0
	moveal	sp@(20),a6
	bnes	_dqw
	lea	a2@(24),a0
	moveal	0x4,a6
	jsr	a6@(-264)
	moveal	sp@(20),a6
	movel	d0,sp@(28)
	tstl	d0
	beqs	_dqtail
	subql	#1,a2@(38)
_dqtail:
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	movel	sp@(28),d0
	braw	_dqdone
_dqw:	moveal	a2@(24),a0
	moveal	sp@(20),a6
	movel	a0,sp@(28)
	movel	a0,d0
	beqs	_dqempty
	movel	a0@,sp@(24)
	movel	d0,sp@-
	movel	a3,sp@-
	bsrw	_bump
	addqw	#8,sp
	movel	sp@(24),sp@(28)
	bras	_dqwalk
_dqempty:
	moveal	a2@(28),a1
	movel	a1,sp@(28)
	movel	a1,d0
	beqs	_dqroot
	movel	a2,sp@-
	bsrw	_rmvclear
	addqw	#4,sp
	bras	_dqwalk
_dqroot:movel	a3@(14),sp@(28)
_dqwalk:
	moveal	sp@(28),a1
	moveal	a1@,a0
	movel	a0,sp@(24)
	movel	a0,d0
	bnes	_dqtest
	movel	a1@(4),sp@-
	movel	a2,sp@-
	bsrw	_rechain
	addqw	#8,sp
	subal	a0,a0
	movel	a0,sp@(28)
	bras	_dqset
_dqtest:
	moveal	sp@(28),a0
	btst	#1,a0@(9)
	beqs	_dqincr
	moveq	#6,d0
	cmpw	a0@(8),d0
	bnes	_dqadv
	movel	a0,sp@-
	bsrw	_killnode
	addqw	#4,sp
_dqadv:	movel	sp@(24),sp@(28)
	bras	_dqwalk
_dqincr:
	moveal	sp@(28),a0
	addqw	#1,a0@(10)
_dqset:	movel	sp@(28),a2@(24)
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	movel	sp@(28),d0
_dqdone:
	moveml	sp@+,a2-a6
	addaw	#12,sp
	rts

/* ---------- -60 walk+free list @ 0x7e8 ---------- */
	.globl	_walk
_walk:	subaw	#12,sp
	moveml	a2-a6,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a3
	moveal	a5,a2
	moveal	a2@(24),a0
	movel	a0,sp@(28)
	movel	a6,sp@(20)
	movel	a0,d0
	beqw	_wdone
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-564)
	movel	sp@(28),sp@-
	movel	a2,sp@-
	moveal	sp@(28),a6
	bsrw	_rechain
	moveal	sp@(36),a0
	movel	a0@,sp@(32)
	movel	a0,sp@
	movel	a3,sp@-
	bsrw	_bump
	lea	sp@(12),sp
	movel	sp@(24),d0
	beqs	_wclear
	movel	d0,sp@(28)
_wlp:	moveal	sp@(28),a1
	moveal	a1@,a0
	movel	a0,sp@(24)
	beqs	_wclear
	moveq	#1,d0
	cmpw	a1@(8),d0
	bnes	_wadv
	moveal	a2@(20),a1
	movel	a2@(16),d0
	moveal	0x4,a6
	jsr	a6@(-324)
	moveal	sp@(20),a6
	bras	_wclear
_wadv:	moveal	sp@(20),a6
	movel	sp@(24),sp@(28)
	bras	_wlp
_wclear:
	clrl	a2@(24)
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveq	#1,d0
_wdone:	moveml	sp@+,a2-a6
	addaw	#12,sp
	rts

/* ---------- -66 type-10 cleanup @ 0x898 ---------- */
	.globl	_clean
_clean:	subqw	#8,sp
	moveml	a2-a6,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(12),a3
	lea	a3@(50),a0
	movel	a6,sp@(20)
	moveal	0x4,a6
	jsr	a6@(-564)
	moveal	a3@(14),a2
	moveal	sp@(20),a6
_cllp:	moveal	a2@,a0
	movel	a0,sp@(24)
	beqs	_cldone
	moveq	#10,d0
	cmpw	a2@(8),d0
	beqs	_clnext
	movel	a2,sp@-
	bsrw	_killnode
	addqw	#4,sp
_clnext:
	moveal	sp@(24),a2
	bras	_cllp
_cldone:
	lea	a3@(50),a0
	moveal	0x4,a6
	jsr	a6@(-570)
	moveq	#1,d0
	moveml	sp@+,a2-a6
	addqw	#8,sp
	rts

/* ---------- -72 alloc item @ 0x8f4 ---------- */
	.globl	_alloc
_alloc:	subqw	#4,sp
	moveml	d7/a4-a6,sp@-
	movel	d0,d7
	lea	a6@(48),a4
	movel	a6,sp@(16)
	moveq	#24,d0
	movel	#0x10001,d1
	moveal	0x4,a6
	jsr	a6@(-198)
	moveal	d0,a5
	moveal	a5,a0
	movel	a0,d0
	moveal	sp@(16),a6
	bnes	_alok
	moveq	#0,d0
	bras	_aldone
_alok:	moveal	sp@(16),a6
	tstl	d7
	beqs	_alret
	movel	d7,d0
	moveq	#0,d1
	moveal	0x4,a6
	jsr	a6@(-198)
	movel	d0,a5@(20)
	tstl	d0
	moveal	sp@(16),a6
	bnes	_alret
	moveal	a5,a1
	moveq	#24,d0
	moveal	0x4,a6
	jsr	a6@(-210)
	moveq	#0,d0
	bras	_aldone
_alret:	movel	a5,d0
_aldone:
	moveml	sp@+,d7/a4-a6
	addqw	#4,sp
	rts

/* ---------- -78 free item @ 0x95e ---------- */
	.globl	_free
_free:	subqw	#4,sp
	moveml	d7/a4-a6,sp@-
	movel	d0,d7
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a6,sp@(16)
	movel	a5@(20),d0
	beqs	_fritem
	moveal	d0,a1
	movel	d7,d0
	moveal	0x4,a6
	jsr	a6@(-210)
_fritem:
	moveal	a5,a1
	moveq	#24,d0
	moveal	0x4,a6
	jsr	a6@(-210)
	moveml	sp@+,d7/a4-a6
	addqw	#4,sp
	rts
	nop

/* ---------- helper: NewList @ 0x998 ---------- */
_newlist:
	moveal	sp@(4),a0
	clrl	a0@(4)
	movel	a0,a0@(8)
	addql	#4,a0
	movel	a0,a0@-
	rts
	.short	0
