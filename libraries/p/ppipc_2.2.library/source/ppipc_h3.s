/* ppipc.library 2.2 -- hunk3 CODE (0xe8 bytes)
 * initfn + Open/Close/Expunge + null vector + jmp-to-h0 trampoline.
 * init stores SysBase -> hunk1+0x32 and seglist -> hunk4+0, copies
 * ver/rev from hunk2+0x2a/0x2c, then NewLists the port list (hunk6). */

	.globl	_init,_open,_close,_expunge,_nullret
	.globl	_sysbase,_segcell,_verword,_revword,_portlist,_newlist

	.text

/* ==== 0x00 initfn: d0=libbase, a0=seglist, a6=SysBase ============ */
_init:
	linkw	%a5,#-4
	moveml	%a2-%a3,%sp@-
	moveal	%a0,%a3				/* a3 = seglist */
	moveal	%a6,%a2				/* a2 = SysBase */
	.short	0x23ca
	.long	_sysbase			/* movel a2,_sysbase:l */
	.short	0x23cb
	.long	_segcell			/* movel a3,_segcell:l */
	moveal	%d0,%a0				/* a0 = libbase */
	.short	0x3179
	.long	_verword
	.short	20				/* movew _verword:l,a0@(20) */
	.short	0x3179
	.long	_revword
	.short	22				/* movew _revword:l,a0@(22) */
	.short	0x4879
	.long	_portlist			/* pea _portlist:l */
	movel	%d0,%a5@(-4)
	jsr	%pc@(_t_newlist)		/* -> 0xe0 stub -> h0+0x20 */
	movel	%a5@(-4),%d0			/* return libbase */
	moveml	%a5@(-12),%a2-%a3
	unlk	%a5
	rts

/* ==== 0x46 Open: opencnt++, clear DELEXP, return libbase ========= */
_open:
	movel	%a3,%sp@-
	moveal	%a6,%a3
	addqw	#1,%a3@(32)
	bclr	#3,%a3@(14)
	movel	%a3,%d0
	moveal	%sp@+,%a3
	rts

/* ==== 0x5a Expunge: refuses while opencnt or portlist nonzero ==== */
_expunge:
	linkw	%a5,#-4
	moveml	%a3/%a6,%sp@-
	moveal	%a6,%a3
	tstw	%a3@(32)
	beqs	1f
	bset	#3,%a3@(14)			/* LIBF_DELEXP */
	moveq	#0,%d0
	bras	3f
1:	.short	0x2079
	.long	_portlist			/* moveal _portlist:l,a0 */
	tstl	%a0@				/* portlist head != 0 -> refuse */
	beqs	2f
	moveq	#0,%d0
	bras	3f
2:	moveal	%a3,%a1
	moveal	4:w,%a6
	jsr	%a6@(-252)			/* Remove */
	moveal	%a3,%a0
	moveq	#0,%d0
	movew	%a3@(16),%d0			/* lib_NegSize */
	subal	%d0,%a0
	moveq	#0,%d1
	movew	%d0,%d1
	moveq	#0,%d0
	movew	%a3@(18),%d0			/* lib_PosSize */
	addl	%d0,%d1
	movel	%a0,%a5@(-4)
	moveal	%a0,%a1
	movel	%d1,%d0
	jsr	%a6@(-210)			/* FreeMem */
	.short	0x2039
	.long	_segcell			/* movel _segcell:l,d0 */
3:	moveml	%sp@+,%a3/%a6
	unlk	%a5
	rts

/* ==== 0xbc Close: opencnt--, deferred expunge ==================== */
_close:
	movel	%a3,%sp@-
	moveal	%a6,%a3
	subqw	#1,%a3@(32)
	bnes	4f
	btst	#3,%a3@(14)
	bnes	5f
4:	moveq	#0,%d0
	bras	6f
5:	moveal	%a3,%a6
	bsrs	_expunge
6:	moveal	%sp@+,%a3
	rts

/* ==== 0xda null vector ============================================ */
_nullret:
	moveq	#0,%d0
	rts
	.short	0				/* 0xde pad */

/* ==== 0xe0 trampoline jmp h0+0x20 ================================= */
_t_newlist:
	.short	0x4ef9
	.long	_newlist			/* jmp _newlist */
	.short	0x7061				/* 0xe6 tail bytes */
