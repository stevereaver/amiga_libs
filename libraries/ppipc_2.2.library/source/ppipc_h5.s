/* ppipc.library 2.2 -- hunk5 CODE (0x3c0 bytes)
 * MsgPort-like object allocator + all port-management vectors.
 * Object layout (allocated 50+namelen bytes):
 *   +0x00 Node (succ,pred,type=4,pri,name@0xa)
 *   +0x0e mp_Flags byte (2 on create, 0 after portsig)
 *   +0x0f sigbit   +0x10 sigtask   +0x14 msg list (12B)
 *   +0x26 usecount (word)   +0x28 flags word (0x9000 ready-mask)
 *   +0x2a alloc size (word) +0x30 name copy
 * The internal port list lives in hunk6 BSS; searched via FindName. */

	.globl	_mkport,_sigport,_findport,_getport,_relport,_portsig
	.globl	_setsig,_freesig,_portflags,_putmsg,_allocmsg,_freemsg
	.globl	_portlist,_newlist,_strlen,_strcpy

	.text

/* ==== 0x00 CreatePort(name@sp+32): MsgPort alloc + AddHead ======== */
_mkport:
	linkw	%a5,#-8
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveal	%sp@(32),%a3			/* name */
	movel	%a3,%d0
	beqs	1f
	movel	%a3,%sp@-
	jsr	%pc@(_t_strlen)
	addqw	#4,%sp
	bras	2f
1:	moveq	#0,%d0
2:	movel	%d0,%d7
	moveq	#50,%d1
	addl	%d1,%d7				/* size = 50+strlen */
	movel	%d7,%d0
	movel	#65537,%d1			/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	4:w,%a6
	jsr	%a6@(-198)			/* AllocMem */
	movel	%d0,%a5@(-4)
	tstl	%d0
	beqs	5f
	movel	%d7,%d1
	moveal	%d0,%a0
	movew	%d1,%a0@(42)			/* +0x2a = alloc size */
	lea	%a0@(20),%a1			/* &msglist */
	movel	%a1,%sp@-
	jsr	%pc@(_t_newlist)
	addqw	#4,%sp
	moveal	%a5@(-4),%a0
	moveb	#4,%a0@(8)			/* ln_Type = NT_MSGPORT */
	moveb	#2,%a0@(14)			/* mp_Flags = PA_SIGNAL */
	movel	%a3,%d0
	beqs	5f
	lea	%a0@(48),%a1			/* name buf at +0x30 */
	movel	%a1,%a0@(10)			/* ln_Name */
	lea	%a0@(48),%a1
	movel	%a3,%sp@-
	movel	%a1,%sp@-
	jsr	%pc@(_t_strcpy)
	addqw	#8,%sp
	.short	0x41f9
	.long	_portlist			/* lea _portlist:l,a0 */
	moveal	%a5@(-4),%a1
	moveal	4:w,%a6
	jsr	%a6@(-240)			/* AddHead */
5:	movel	%a5@(-4),%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x96 UsePort(port): usecount++, signal if flag41.0 ========== */
_sigport:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	addqw	#1,%a3@(38)
	btst	#0,%a3@(41)
	beqs	6f
	moveq	#0,%d0
	moveb	%a3@(15),%d0			/* sigbit */
	moveq	#1,%d1
	asll	%d0,%d1
	moveal	%a3@(16),%a1			/* sigtask */
	movel	%d1,%d0
	moveal	4:w,%a6
	jsr	%a6@(-324)			/* Signal */
6:	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0xc6 -30 FindPort(name): ready ports only, usecount++ ======= */
_findport:
	linkw	%a5,#-4
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3				/* name */
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	.short	0x41f9
	.long	_portlist			/* lea _portlist:l,a0 */
	moveal	%a3,%a1
	jsr	%a6@(-276)			/* FindName */
	movel	%d0,%a5@(-4)
	tstl	%d0
	beqs	7f
	movew	#0x9000,%d1
	moveal	%d0,%a0
	andw	%a0@(40),%d1
	beqs	8f
	bsrs	_sigport
	bras	7f
8:	clrl	%a5@(-4)			/* found but not ready -> 0 */
7:	moveal	4:w,%a6
	jsr	%a6@(-138)			/* Permit */
	movel	%a5@(-4),%d0
	moveml	%sp@+,%a3/%a6
	unlk	%a5
	rts

/* ==== 0x114 -36 GetPort(name): find or create + usecount++ ======== */
_getport:
	linkw	%a5,#-4
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	clrl	%a5@(-4)
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	movel	%a3,%d0
	beqs	9f
	.short	0x41f9
	.long	_portlist			/* lea _portlist:l,a0 */
	moveal	%a3,%a1
	jsr	%a6@(-276)			/* FindName */
	movel	%d0,%a5@(-4)
9:	tstl	%a5@(-4)
	bnes	10f
	movel	%a3,%sp@-
	bsrw	_mkport				/* CreatePort(name) */
	addqw	#4,%sp
	movel	%d0,%a5@(-4)
10:	tstl	%a5@(-4)
	beqs	11f
	moveal	%a5@(-4),%a0
	bsrw	_sigport			/* usecount++ */
11:	moveal	4:w,%a6
	jsr	%a6@(-138)			/* Permit */
	movel	%a5@(-4),%d0
	moveml	%sp@+,%a3/%a6
	unlk	%a5
	rts

/* ==== 0x172 -48 ReleasePort(port): usecount--, free at 0 ========== */
_relport:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	movel	%a3,%d0
	beqs	15f
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	subqw	#1,%a3@(38)
	bnes	12f
	tstl	%a3@(10)			/* ln_Name set -> linked */
	beqs	13f
	moveal	%a3,%a1
	jsr	%a6@(-252)			/* Remove */
13:	jsr	%a6@(-138)			/* Permit */
	moveq	#0,%d0
	movew	%a3@(42),%d0			/* alloc size */
	moveal	%a3,%a1
	jsr	%a6@(-210)			/* FreeMem */
	bras	15f
12:	btst	#0,%a3@(41)
	beqs	14f
	moveq	#0,%d0
	moveb	%a3@(15),%d0
	moveq	#1,%d1
	asll	%d0,%d1
	moveal	%a3@(16),%a1
	movel	%d1,%d0
	jsr	%a6@(-324)			/* Signal */
14:	jsr	%a6@(-138)			/* Permit */
15:	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x1ce -54 PortSignal(name): GetPort + AllocSignal =========== */
_portsig:
	linkw	%a5,#-4
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	moveal	%a3,%a0
	bsrw	_getport
	movel	%d0,%a5@(-4)
	tstl	%d0
	beqs	20f
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	movew	#-16384,%d0			/* 0xc000 */
	moveal	%a5@(-4),%a0
	andw	%a0@(40),%d0
	bnes	16f
	moveq	#-1,%d0
	jsr	%a6@(-330)			/* AllocSignal(-1) */
	moveal	%a5@(-4),%a0
	moveb	%d0,%a0@(15)			/* sigbit */
	cmpib	#-1,%d0
	bnes	17f
16:	bsrw	_relport			/* already sig'd or fail */
	subal	%a0,%a0
	movel	%a0,%a5@(-4)
	bras	19f
17:	clrb	%a0@(14)			/* mp_Flags = 0 */
	subal	%a1,%a1
	jsr	%a6@(-294)			/* FindTask(0) */
	moveal	%a5@(-4),%a0
	movel	%d0,%a0@(16)			/* sigtask */
	movew	#-32768,%a0@(40)		/* flags = 0x8000 */
19:	moveal	4:w,%a6
	jsr	%a6@(-138)			/* Permit */
20:	movel	%a5@(-4),%d0
	moveml	%sp@+,%a3/%a6
	unlk	%a5
	rts

/* ==== 0x248 -60 SetSigMode(port): flags|0x40, clr 0x8000 ========= */
_setsig:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	bset	#6,%a3@(40)
	moveq	#0,%d0
	movew	%a3@(40),%d0
	andiw	#32767,%d0			/* 0x7fff */
	movew	%d0,%a3@(40)
	moveb	#2,%a3@(14)			/* mp_Flags = PA_SIGNAL */
	jsr	%a6@(-138)			/* Permit */
	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x27a -66 FreePortSignal(port) ============================== */
_freesig:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	moveq	#0,%d0
	moveb	%a3@(15),%d0			/* sigbit */
	moveal	4:w,%a6
	jsr	%a6@(-336)			/* FreeSignal */
	clrl	%a3@(16)			/* sigtask = 0 */
	moveq	#0,%d0
	movew	%a3@(40),%d0
	andiw	#16128,%d0			/* 0x3f00 */
	movew	%d0,%a3@(40)
	moveal	%a3,%a0
	bsrw	_relport
	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x2ac -72 PortFlags(port,d0): set low flag byte, get info === */
_portflags:
	moveml	%d6-%d7/%a3/%a6,%sp@-
	moveal	%a0,%a3				/* port */
	movel	%d0,%d7				/* flags arg */
	movew	%a3@(40),%d6			/* old flags */
	subal	%a1,%a1
	moveal	4:w,%a6
	jsr	%a6@(-294)			/* FindTask(0) */
	moveal	%a3@(16),%a0
	cmpal	%d0,%a0				/* sigtask == self? */
	bnes	22f
	movew	#-256,%d0			/* 0xff00 */
	andw	%a3@(40),%d0
	movel	%d7,%d1
	andiw	#255,%d1
	orw	%d1,%d0
	movew	%d0,%a3@(40)
22:	btst	#15,%d7
	beqs	23f
	moveq	#0,%d0
	movew	%d6,%d0				/* return old flags */
	bras	24f
23:	moveq	#0,%d0
	movew	%a3@(38),%d0			/* return usecount */
24:	moveml	%sp@+,%d6-%d7/%a3/%a6
	rts

/* ==== 0x2f6 -78 PutMsg(port,msg) if port ready ==================== */
_putmsg:
	moveml	%a2-%a3/%a6,%sp@-
	moveal	%a0,%a3				/* port */
	moveal	%a1,%a2				/* msg */
	moveal	4:w,%a6
	jsr	%a6@(-132)			/* Forbid */
	movew	#0x9000,%d0
	andw	%a3@(40),%d0
	beqs	25f
	moveal	%a3,%a0
	moveal	%a2,%a1
	jsr	%a6@(-366)			/* PutMsg */
	jsr	%a6@(-138)			/* Permit */
	moveq	#1,%d0
	bras	26f
25:	jsr	%a6@(-138)			/* Permit */
	moveq	#0,%d0
26:	moveml	%sp@+,%a2-%a3/%a6
	rts

/* ==== 0x32c -84 AllocMsg(idx,base,port): sized request block ====== */
_allocmsg:
	linkw	%a5,#-12
	moveml	%d2/%d4-%d7/%a3/%a6,%sp@-
	movel	%d0,%d7				/* index */
	movel	%d1,%d6				/* base size */
	moveal	%a0,%a3				/* port */
	movel	%d7,%d0
	subql	#1,%d0
	asll	#4,%d0
	addl	%d6,%d0
	movel	%d0,%d5
	moveq	#46,%d1
	addl	%d1,%d5				/* size = base+(idx-1)*16+46 */
	movel	%d5,%d4
	moveq	#20,%d0
	subl	%d0,%d4				/* d4 = size-20 */
	cmpil	#65535,%d4
	blss	27f
	moveq	#0,%d0
	bras	28f
27:	movel	%d5,%d0
	movel	#65537,%d1			/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	4:w,%a6
	jsr	%a6@(-198)			/* AllocMem */
	movel	%d0,%a5@(-12)
	tstl	%d0
	beqs	28f
	movel	%d4,%d1
	moveal	%d0,%a0
	movew	%d1,%a0@(18)			/* +0x12 = size-20 */
	movel	%d7,%d2
	movew	%d2,%a0@(28)			/* +0x1c = index */
	movel	%a3,%a0@(14)			/* +0x0e = port */
28:	moveml	%sp@+,%d2/%d4-%d7/%a3/%a6
	unlk	%a5
	rts

/* ==== 0x38c -90 FreeMsg(buf) ====================================== */
_freemsg:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	moveq	#0,%d0
	movew	%a3@(18),%d0
	moveq	#20,%d1
	addl	%d1,%d0
	moveal	%a3,%a1
	moveal	4:w,%a6
	jsr	%a6@(-210)			/* FreeMem */
	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x3ac trampolines to hunk0 helpers ========================== */
_t_strlen:
	.short	0x4ef9
	.long	_strlen				/* jmp h0+0x34 */
_t_newlist:
	.short	0x4ef9
	.long	_newlist			/* jmp h0+0x20 */
_t_strcpy:
	.short	0x4ef9
	.long	_strcpy				/* jmp h0+0x48 */
	.short	0x7061				/* 0x3be tail bytes */
