/* ppipc.library 2.2 -- hunk7 CODE (0x134 bytes)
 * -96 BrokerRequest(name): find-or-create the named port; if not yet
 * signalled, build an 'IPPL'/'PORT' message on an anonymous reply port,
 * hand it to "PortBrokerPort", wait for the reply, then release allocs.
 * Tail is a row of jmp stubs to hunk5/hunk10 entry points. */

	.globl	_broker,_brokername
	.globl	_findport,_getport,_relport,_portsig,_freesig,_putmsg
	.globl	_allocmsg,_freemsg,_getmsgstub,_waitstub

	.text

_broker:					/* h7+0: -96 */
	linkw	%a5,#-20
	movel	%a3,%sp@-
	moveal	%a0,%a3				/* name */
	subal	%a0,%a0
	movel	%a0,%a5@(-16)			/* msgbuf */
	movel	%a0,%a5@(-12)			/* broker */
	movel	%a0,%a5@(-8)			/* reply port */
	movel	%a0,%a5@(-4)			/* port */
	moveal	%a3,%a0
	jsr	%pc@(_s_getport)		/* GetPort(name) */
	movel	%d0,%a5@(-4)
	tstl	%d0
	bnes	1f
	moveq	#0,%d0
	braw	9f
1:	movew	#0x9000,%d0
	moveal	%a5@(-4),%a0
	andw	%a0@(40),%d0
	beqs	2f
	movel	%a0,%d0				/* already ready */
	braw	9f
2:	subal	%a0,%a0
	jsr	%pc@(_s_portsig)		/* anon reply port + signal */
	movel	%d0,%a5@(-8)
	tstl	%d0
	beqs	8f
	moveq	#1,%d0
	moveq	#0,%d1
	moveal	%a5@(-8),%a0
	jsr	%pc@(_s_allocmsg)		/* AllocMsg(1,0,reply) */
	movel	%d0,%a5@(-16)
	tstl	%d0
	beqs	8f
	.short	0x41f9
	.long	_brokername			/* lea _brokername:l,a0 */
	jsr	%pc@(_s_findport)		/* FindPort("PortBrokerPort") */
	movel	%d0,%a5@(-12)
	tstl	%d0
	beqs	8f
	moveal	%a5@(-16),%a0
	movel	#0x4950504c,%a0@(20)		/* 'IPPL' @+0x14 */
	lea	%a0@(30),%a1
	movel	#0x504f5254,%a1@			/* 'PORT' @+0x1e */
	movel	%a5@(-4),%a1@(12)		/* port  @+0x2a */
	movel	%a1,%a5@(-20)
	moveal	%d0,%a0				/* broker */
	moveal	%a5@(-16),%a1			/* msg */
	jsr	%pc@(_s_putmsg)			/* PutMsg if ready */
	tstl	%d0
	beqs	4f
	movel	%a5@(-8),%sp@-
	jsr	%pc@(_s_waitstub)		/* WaitPort(reply) */
	movel	%a5@(-8),%sp@
	jsr	%pc@(_s_getmsgstub)		/* GetMsg(reply) */
	addqw	#4,%sp
4:	moveal	%a5@(-12),%a0
	jsr	%pc@(_s_relport)		/* ReleasePort(broker) */
8:	tstl	%a5@(-8)
	beqs	5f
	moveal	%a5@(-8),%a0
	jsr	%pc@(_s_freesig)		/* FreePortSignal(reply) */
5:	tstl	%a5@(-16)
	beqs	6f
	moveal	%a5@(-16),%a0
	jsr	%pc@(_s_freemsg)		/* FreeMsg(msgbuf) */
6:	movew	#0x9000,%d0
	moveal	%a5@(-4),%a0
	andw	%a0@(40),%d0
	beqs	7f
	movel	%a0,%d0				/* broker set port ready */
	bras	9f
7:	jsr	%pc@(_s_relport)		/* not ready -> release */
	moveq	#0,%d0
9:	moveal	%sp@+,%a3
	unlk	%a5
	rts

/* ==== 0xf8 jump stubs ============================================= */
_s_portsig:
	.short	0x4ef9
	.long	_portsig			/* jmp h5+0x1ce */
_s_freesig:
	.short	0x4ef9
	.long	_freesig			/* jmp h5+0x27a */
_s_waitstub:
	.short	0x4ef9
	.long	_waitstub			/* jmp h10+0x14 */
_s_getmsgstub:
	.short	0x4ef9
	.long	_getmsgstub			/* jmp h10+0 */
_s_relport:
	.short	0x4ef9
	.long	_relport			/* jmp h5+0x172 */
_s_freemsg:
	.short	0x4ef9
	.long	_freemsg			/* jmp h5+0x38c */
_s_findport:
	.short	0x4ef9
	.long	_findport			/* jmp h5+0xc6 */
_s_getport:
	.short	0x4ef9
	.long	_getport			/* jmp h5+0x114 */
_s_allocmsg:
	.short	0x4ef9
	.long	_allocmsg			/* jmp h5+0x32c */
_s_putmsg:
	.short	0x4ef9
	.long	_putmsg				/* jmp h5+0x2f6 */
