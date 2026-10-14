* screennotify.library 1.0 (26.3.95)
* Pure-asm reconstruction (byte-identical target).
* COLDSTART resident: rt_Init calls MakeLibrary on the long-absolute
* functab at 0x5e (10 vectors), fills the node header, sets up three
* 122-byte notify objects (MinList + SignalSemaphore + embedded
* 28-byte Message + MsgPort) at lib+44/+166/+288, then AddLibrary.
* Globals live in hunk 1 (DATA): a4 = _DATA+0x7ffe, giving
*   a4@(-32766) = data+0   SysBase
*   a4@(-32762) = data+4   LibBase
*   a4@(-32758) = data+8   old intuition -66  (CloseScreen)
*   a4@(-32754) = data+12  old intuition -78  (CloseWorkBench)
*   a4@(-32750) = data+16  old intuition -210 (OpenWorkBench)
*   a4@(-32746) = data+20  old intuition -552 (PubScreenStatus)

	.text
	.globl	start

* ---- 0x000: dead stub + strings ----
start:
	moveq	#-1,d0
	rts
_name:					/* 0x04 */
	.ascii	"screennotify.library\0"
_idstr:					/* 0x19 */
	.ascii	"$VER: screennotify.library 1.0 (26.3.95)\r\n\0"

* ---- RomTag @ 0x44: COLDSTART ----
_rt:
	dc.w	0x4afc
	.long	_rt
	.long	_functab			/* endskip */
	.byte	0,1,9,0
	.long	_name
	.long	_idstr
	.long	_init

* ---- 0x5e: functab (long-absolute, -1 terminated) ----
_functab:
	.long	_open,_close,_expunge,_null
	.long	_vec30,_vec36,_vec42,_vec48,_vec54,_vec60
	.long	-1

* ---- 0x8a _initobj: NewList+InitSemaphore+embedded msg/port ----
* a0 = 122-byte notify object
_initobj:
	moveml	a3/a6,sp@-
	moveal	a0,a3
	lea	a3@,a0
	bsrw	_newlist		| notify list @ +0
	lea	a3@(14),a0
	moveal	a4@(-32766),a6
	jsr	a6@(-558)		| InitSemaphore @ +14
	lea	a3@(88),a6
	movel	a6,a3@(74)		| msg.mn_ReplyPort = &port(+88)
	movew	#28,a3@(78)		| msg.mn_Length = 28
	lea	a3@(108),a0
	bsrw	_newlist		| port.mp_MsgList @ +108
	moveb	#4,a3@(96)		| port.ln_Type = NT_MSGPORT
	moveb	#0,a3@(102)		| port.mp_Flags = PA_SIGNAL
	moveml	sp@+,a3/a6
	rts

* ---- 0xca rt_Init: a0 = seglist ----
_init:
	moveml	d2/d7/a2/a4,sp@-
	movel	a0,d7			| seglist
	lea	_DATA+0x7ffe,a4
	movel	a6,a4@(-32766)		| SysBase
	lea	%pc@(_functab),a0
	subal	a1,a1
	subal	a2,a2
	movel	#410,d0			| dsize = 36 + 4 + 3*122
	moveq	#0,d1
	movel	a4@(-32766),d2
	exg	d2,a6
	jsr	a6@(-84)		| MakeLibrary
	movel	d0,a4@(-32762)		| LibBase
	exg	d2,a6
	tstl	a4@(-32762)
	beqw	_initout
	moveal	a4@(-32762),a2
	moveb	#9,a2@(8)		| ln_Type = NT_LIBRARY
	moveal	a4@(-32762),a2
	lea	%pc@(_name),a0
	movel	a0,a2@(10)		| ln_Name
	moveal	a4@(-32762),a2
	moveb	#6,a2@(14)		| lib_Flags = CHANGED|SUMUSED
	moveal	a4@(-32762),a2
	movew	#1,a2@(20)		| lib_Version
	moveal	a4@(-32762),a2
	movew	#0,a2@(22)		| lib_Revision
	moveal	a4@(-32762),a2
	lea	%pc@(_idstr),a0
	movel	a0,a2@(24)		| lib_IdString
	moveal	a4@(-32762),a2
	movel	d7,a2@(36)		| seglist
	moveal	a4@(-32762),a2
	moveq	#0,d2
	movel	d2,a2@(40)		| intuition base = 0
	moveal	a4@(-32762),a2
	lea	a2@(44),a0
	bsrw	_initobj		| obj0: screen-close list
	moveal	a4@(-32762),a0
	lea	a0@(166),a0
	bsrw	_initobj		| obj1: pubstatus list
	moveal	a4@(-32762),a0
	lea	a0@(288),a0
	bsrw	_initobj		| obj2: workbench list
	moveal	a4@(-32762),a1
	movel	a4@(-32766),d2
	exg	d2,a6
	jsr	a6@(-396)		| AddLibrary
	exg	d2,a6
_initout:
	movel	a4@(-32762),d0
	moveml	sp@+,d2/d7/a2/a4
	rts

* ---- 0x192 Open ----
_open:
	movel	a4,sp@-
	lea	_DATA+0x7ffe,a4
	addqw	#1,a6@(32)		| lib_OpenCnt++
	bclr	#3,a6@(14)		| clear DELEXP
	tstl	a6@(40)
	bnes	_openret		| intuition already open
	lea	%pc@(_intuname),a1	| "intuition.library"
	moveq	#37,d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-552)		| OpenLibrary
	moveal	d0,a0
	moveal	sp@+,a6
	movel	a0,a6@(40)
	tstl	a6@(40)
	beqs	_openret
	moveal	a6@(40),a0
	bsrw	_install		| patch 4 intuition vectors
_openret:
	movel	a6,d0
	moveal	sp@+,a4
	rts

* ---- 0x1d8 Close ----
_close:
	moveml	d7/a4,sp@-
	lea	_DATA+0x7ffe,a4
	moveq	#0,d7
	cmpiw	#0,a6@(32)
	blss	_closeret		| opencnt 0 -> skip
	subqw	#1,a6@(32)
	tstw	a6@(32)
	bnes	_closeret
	moveq	#0,d0
	moveb	a6@(14),d0
	btst	#3,d0
	beqs	_closeret		| DELEXP not set
	movel	a6,d0
	movel	a6,sp@-
	moveal	d0,a6
	bsrs	_expunge
	movel	d0,d7
	moveal	sp@+,a6
_closeret:
	movel	d7,d0
	moveml	sp@+,d7/a4
	rts

* ---- 0x216 Expunge ----
_expunge:
	moveml	d2/d7/a4,sp@-
	lea	_DATA+0x7ffe,a4
	moveq	#0,d7
	cmpiw	#0,a6@(32)
	blss	_doexp			| opencnt 0 -> expunge now
	bset	#3,a6@(14)		| else set DELEXP
	bras	_expret
_doexp:
	tstl	a6@(40)
	beqs	_nointu
	moveal	a6@(40),a0
	bsrw	_uninstall		| pull the 4 intuition hooks
	tstw	d0
	beqs	_expret			| still wrapped -> stay resident
_nointu:
	lea	a6@,a1
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-252)		| Remove
	moveal	sp@+,a6
	tstl	a6@(40)
	beqs	_noclose
	moveal	a6@(40),a1
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-414)		| CloseLibrary(intuition)
	moveal	sp@+,a6
_noclose:
	movel	a6@(36),d7		| seglist
	moveq	#0,d0
	movew	a6@(16),d0		| negsize
	moveal	a6,a1
	subal	d0,a1
	moveq	#0,d1
	movew	a6@(16),d1
	moveq	#0,d2
	movew	a6@(18),d2		| possize
	movel	d1,d0
	addl	d2,d0
	movel	a4@(-32766),d2
	exg	d2,a6
	jsr	a6@(-210)		| FreeMem
	exg	d2,a6
_expret:
	movel	d7,d0
	moveml	sp@+,d2/d7/a4
	rts

* ---- 0x29e null vector ----
_null:
	moveq	#0,d0
	rts

_intuname:				/* 0x2a2 */
	.ascii	"intuition.library\0"

* ---- 0x2b4 CloseScreen wrapper (intuition -66) ----
* a0 = closing Screen*, a6 = intuition base
_vec66:
	moveml	d7/a2-a4/a6,sp@-
	lea	_DATA+0x7ffe,a4
	linkw	a5,#-16
	movel	a0,a5@(-4)		| screen
	movel	a6,a5@(-8)		| intuition base
	moveq	#-1,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-330)		| AllocSignal(-1)
	moveb	d0,d7
	.short	0xbe3c,0x00ff		| cmpb #-1,d7
	beqw	_csout			| no signal -> just chain
	moveal	a4@(-32762),a6
	lea	a6@(44),a0		| obj0
	movel	a0,a5@(-12)		| obj
	moveal	a5@(-12),a6
	lea	a6@(88),a3		| a3 = embedded port
	moveal	a5@(-12),a6
	lea	a6@(60),a0
	movel	a0,a5@(-16)		| msg
	moveal	a5@(-12),a6
	lea	a6@(14),a0
	moveal	a4@(-32766),a6
	jsr	a6@(-564)		| ObtainSemaphore(obj+14)
	moveb	d7,a3@(15)		| port sigbit
	subal	a1,a1
	moveal	a4@(-32766),a6
	jsr	a6@(-294)		| FindTask(0)
	movel	d0,a3@(16)		| port sigtask = self
	moveal	a5@(-16),a6
	moveq	#0,d0
	movel	d0,a6@(20)		| msg.type = 0 (screen closing)
	moveal	a5@(-16),a6
	movel	a5@(-4),a6@(24)		| msg.screen = arg
	moveal	a5@(-12),a6
	lea	a6@,a0
	bsrw	_getnext		| first subscriber node
	moveal	d0,a2
	bras	_csnext
_csloop:
	tstl	a2@(14)
	beqs	_cssend			| wildcard node -> send
	movel	a2@(14),d0
	cmpl	a5@(-4),d0
	bnes	_csstep			| other screen -> skip
_cssend:
	moveal	a2@(10),a6		| subscriber port
	movel	a3@(16),d0
	cmpl	a6@(16),d0
	beqs	_csstep			| same task -> skip
	moveal	a6,a0
	moveal	a5@(-16),a1
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-366)		| PutMsg(port,msg)
	moveal	sp@+,a6
	moveal	a3,a0
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-384)		| WaitPort(own)
	moveal	sp@+,a6
	moveal	a3,a0
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-372)		| GetMsg(own)
	moveal	sp@+,a6
_csstep:
	moveal	a2,a0
	bsrw	_getnext
	moveal	d0,a2
_csnext:
	movel	a2,d0
	bnes	_csloop
	moveal	a5@(-12),a0
	lea	a0@(14),a0
	moveal	a4@(-32766),a6
	jsr	a6@(-570)		| ReleaseSemaphore
	moveb	d7,d0
	extw	d0
	extl	d0
	moveal	a4@(-32766),a6
	jsr	a6@(-336)		| FreeSignal
_csout:
	moveal	a5@(-4),a0		| screen
	moveal	a5@(-8),a6		| intuition
	moveal	a4@(-32758),a2		| old CloseScreen
	jsr	a2@
	unlk	a5
	moveml	sp@+,d7/a2-a4/a6
	rts

* ---- 0x3d4 _broadcast: d0=type, a0=obj, a1=msg-arg ----
_broadcast:
	moveml	d6-d7/a2-a3/a6,sp@-
	movel	d0,d7			| type
	linkw	a5,#-12
	movel	a0,a5@(-4)		| obj
	movel	a1,a5@(-8)		| arg
	moveq	#-1,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-330)		| AllocSignal(-1)
	moveb	d0,d6
	.short	0xbc3c,0x00ff		| cmpb #-1,d6
	beqw	_bcout
	moveal	a5@(-4),a6
	lea	a6@(88),a3		| own port
	moveal	a5@(-4),a6
	lea	a6@(60),a0
	movel	a0,a5@(-12)		| msg
	moveal	a5@(-4),a6
	lea	a6@(14),a0
	moveal	a4@(-32766),a6
	jsr	a6@(-564)		| ObtainSemaphore
	moveb	d6,a3@(15)		| port sigbit
	subal	a1,a1
	moveal	a4@(-32766),a6
	jsr	a6@(-294)		| FindTask(0)
	movel	d0,a3@(16)		| port sigtask = self
	moveal	a5@(-12),a6
	movel	d7,a6@(20)		| msg.type
	moveal	a5@(-12),a6
	movel	a5@(-8),a6@(24)		| msg.arg
	moveal	a5@(-4),a6
	lea	a6@,a0
	bsrw	_getnext
	moveal	d0,a2
	bras	_bcnext
_bcloop:
	moveal	a2@(10),a6		| subscriber port
	movel	a3@(16),d0
	cmpl	a6@(16),d0
	beqs	_bcstep			| same task -> skip
	moveal	a6,a0
	moveal	a5@(-12),a1
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-366)		| PutMsg
	moveal	sp@+,a6
	moveal	a3,a0
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-384)		| WaitPort(own)
	moveal	sp@+,a6
	moveal	a3,a0
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-372)		| GetMsg(own)
	moveal	sp@+,a6
_bcstep:
	moveal	a2,a0
	bsrw	_getnext
	moveal	d0,a2
_bcnext:
	movel	a2,d0
	bnes	_bcloop
	moveal	a5@(-4),a6
	lea	a6@(14),a0
	moveal	a4@(-32766),a6
	jsr	a6@(-570)		| ReleaseSemaphore
	moveb	d6,d0
	extw	d0
	extl	d0
	moveal	a4@(-32766),a6
	jsr	a6@(-336)		| FreeSignal
_bcout:
	unlk	a5
	moveml	sp@+,d6-d7/a2-a3/a6
	rts

* ---- 0x4c4 PubScreenStatus wrapper (intuition -552) ----
* a0 = screen/name arg, d0 = status arg, a6 = intuition base
_pubstat:
	moveml	d6-d7/a2-a4,sp@-
	moveal	a0,a3			| arg0
	movel	d0,d7			| arg1 (status)
	lea	_DATA+0x7ffe,a4
	linkw	a5,#-4
	subal	a2,a2
	jsr	a6@(-522)		| LockPubScreenList
	movel	d0,a5@(-4)
	tstl	a5@(-4)
	beqs	_pscall
	moveal	a5@(-4),a0
	bsrw	_getnext		| first PubScreenNode
	moveal	d0,a2
	bras	_psnext
_psloop:
	moveal	a2,a0
	bsrw	_getnext
	moveal	d0,a2
_psnext:
	movel	a2,d0
	beqs	_psunlock		| end of list
	cmpal	a2@(14),a3		| node+14 == arg?
	bnes	_psloop
_psunlock:
	jsr	a6@(-528)		| UnlockPubScreenList
_pscall:
	movel	a2,d0
	beqs	_psorig			| no matching node -> just call
	moveq	#1,d0
	andl	d7,d0
	moveq	#1,d1
	cmpl	d0,d1
	bnes	_psorig			| (arg&1)!=1 -> skip pre-notify
	moveal	a4@(-32762),a0
	lea	a0@(166),a0		| obj1
	moveq	#2,d0
	moveal	a2,a1			| arg = pubscreen node
	bsrw	_broadcast		| type 2 = about-to-change
_psorig:
	moveal	a3,a0
	movel	d7,d0
	moveal	a4@(-32746),a1		| old PubScreenStatus
	jsr	a1@
	movel	d0,d6			| result
	movel	a2,d0
	beqs	_psret			| no node -> return
	moveq	#1,d0
	andl	d7,d0
	tstl	d0
	bnes	_psalt
	moveq	#1,d0
	andl	d6,d0
	moveq	#1,d1
	cmpl	d0,d1
	beqs	_pspost			| req=0, res=1 -> changed
_psalt:
	moveq	#1,d0
	andl	d7,d0
	moveq	#1,d1
	cmpl	d0,d1
	bnes	_psret			| (arg&1)!=1 -> return
	moveq	#1,d0
	andl	d6,d0
	tstl	d0
	bnes	_psret			| (res&1)!=0 -> return
_pspost:
	moveal	a4@(-32762),a0
	lea	a0@(166),a0		| obj1
	moveq	#1,d0
	moveal	a2,a1
	bsrw	_broadcast		| type 1 = status changed
_psret:
	movel	d6,d0
	unlk	a5
	moveml	sp@+,d6-d7/a2-a4
	rts

* ---- 0x574 CloseWorkBench wrapper (intuition -78) ----
_closewb:
	moveml	d7/a4,sp@-
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32762),a0
	lea	a0@(288),a0		| obj2
	moveq	#3,d0
	subal	a1,a1			| arg = 0
	bsrw	_broadcast		| type 3: workbench closing
	moveal	a4@(-32754),a1		| old CloseWorkBench
	jsr	a1@
	movel	d0,d7
	tstl	d7
	bnes	_cwbret			| old != 0 -> done
	moveal	a4@(-32762),a1
	lea	a1@(288),a0
	moveq	#3,d0
	moveaw	#1,a1			| arg = 1
	bsrw	_broadcast		| type 3: workbench closed
_cwbret:
	movel	d7,d0
	moveml	sp@+,d7/a4
	rts

* ---- 0x5b4 OpenWorkBench wrapper (intuition -210) ----
_openwb:
	moveml	d7/a4,sp@-
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32750),a0		| old OpenWorkBench
	jsr	a0@
	movel	d0,d7
	tstl	d7
	beqs	_owbret			| failed -> no notify
	moveal	a4@(-32762),a0
	lea	a0@(288),a0		| obj2
	moveq	#3,d0
	moveaw	#1,a1			| arg = 1
	bsrw	_broadcast		| type 3: workbench opened
_owbret:
	movel	d7,d0
	moveml	sp@+,d7/a4
	rts

* ---- 0x5e4 _install: patch 4 intuition vectors ----
* a0 = intuition base
_install:
	moveml	a2-a3/a6,sp@-
	moveal	a0,a3
	moveal	a3,a1
	moveaw	#-66,a0
	lea	%pc@(_vec66),a2
	movel	a2,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-420)		| SetFunction: CloseScreen
	movel	d0,a4@(-32758)
	moveal	a3,a1
	moveaw	#-78,a0
	lea	%pc@(_closewb),a6
	movel	a6,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-420)		| SetFunction: CloseWorkBench
	movel	d0,a4@(-32754)
	moveal	a3,a1
	moveal	#-210,a0
	lea	%pc@(_openwb),a6
	movel	a6,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-420)		| SetFunction: OpenWorkBench
	movel	d0,a4@(-32750)
	moveal	a3,a1
	moveal	#-552,a0
	lea	%pc@(_pubstat),a6
	movel	a6,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-420)		| SetFunction: PubScreenStatus
	movel	d0,a4@(-32746)
	moveml	sp@+,a2-a3/a6
	rts

* ---- 0x654 _uninstall: restore the 4 vectors ----
* a0 = intuition base; returns w in d0: 1 = all four slots held our
* handlers (clean removal), 0 = someone wrapped us (tops restored,
* expunge must abort so our saved-ptr chain stays valid)
_uninstall:
	moveml	d7/a2-a3/a6,sp@-
	moveal	a0,a3
	linkw	a5,#-8
	moveal	a3,a1
	moveaw	#-66,a0
	movel	a4@(-32758),d0		| saved old
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	movel	d0,a5@(-4)		| returned current
	moveal	sp@+,a6
	moveal	a3,a1
	moveaw	#-78,a0
	movel	a4@(-32754),d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	movel	d0,a5@(-8)
	moveal	sp@+,a6
	moveal	a3,a1
	moveal	#-210,a0
	movel	a4@(-32750),d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	moveal	d0,a2
	moveal	sp@+,a6
	moveal	a3,a1
	moveal	#-552,a0
	movel	a4@(-32746),d0
	moveal	a4@(-32766),a6
	jsr	a6@(-420)
	moveal	d0,a6
	lea	%pc@(_vec66),a0
	cmpal	a5@(-4),a0
	bnes	_unfail
	lea	%pc@(_closewb),a0
	cmpal	a5@(-8),a0
	bnes	_unfail
	lea	%pc@(_openwb),a0
	cmpal	a2,a0
	bnes	_unfail
	lea	%pc@(_pubstat),a0
	cmpal	a6,a0
	beqs	_unok
_unfail:
	moveq	#0,d0
	bras	_unflag
_unok:
	moveq	#1,d0
_unflag:
	movew	d0,d7
	tstw	d7
	bnes	_undone			| clean -> pass1 already restored
	moveal	a3,a1
	moveaw	#-66,a0
	movel	a5@(-4),d0		| reinstate foreign handler
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	moveal	sp@+,a6
	moveal	a3,a1
	moveaw	#-78,a0
	movel	a5@(-8),d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	moveal	sp@+,a6
	moveal	a3,a1
	moveal	#-210,a0
	movel	a2,d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	moveal	sp@+,a6
	moveal	a3,a1
	moveal	#-552,a0
	movel	a6,d0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-420)
	moveal	sp@+,a6
_undone:
	movew	d7,d0
	extl	d0
	unlk	a5
	moveml	sp@+,d7/a2-a3/a6
	rts

* ---- 0x764 _addnode: AllocMem + enqueue under sem ----
* a0 = obj (list@+0 sem@+14), a1 = port, d0 = node size, d1 = pri
_addnode:
	moveml	d6-d7/a2-a3/a6,sp@-
	moveal	a0,a3			| obj
	movel	d0,d7			| size
	moveal	a1,a2			| port
	movel	d1,d6			| pri
	movel	d7,d0
	moveq	#1,d1			| MEMF_PUBLIC
	moveal	a4@(-32766),a6
	jsr	a6@(-198)		| AllocMem
	moveal	d0,a6
	movel	a6,d1
	beqs	_addret
	movel	a2,a6@(10)		| node.ln_Name = port
	moveb	d6,a6@(9)		| node.ln_Pri
	lea	a3@(14),a0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-564)		| ObtainSemaphore
	moveal	sp@+,a6
	lea	a3@,a0
	moveal	a6,a1
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-270)		| Enqueue
	moveal	sp@+,a6
	lea	a3@(14),a0
	movel	a4@(-32766),d1
	movel	a6,sp@-
	moveal	d1,a6
	jsr	a6@(-570)		| ReleaseSemaphore
	moveal	sp@+,a6
_addret:
	movel	a6,d0
	moveml	sp@+,d6-d7/a2-a3/a6
	rts

* ---- 0x7c8 _remnode: Attempt + Remove + FreeMem ----
* a0 = &sem (obj+14), a1 = node, d0 = size
_remnode:
	moveml	d6-d7/a2-a3/a6,sp@-
	moveal	a0,a3			| sem
	moveal	a1,a2			| node
	movel	d0,d7			| size
	moveq	#0,d6
	moveal	a3,a0
	moveal	a4@(-32766),a6
	jsr	a6@(-576)		| AttemptSemaphore
	tstl	d0
	beqs	_remfail
	moveal	a2,a1
	moveal	a4@(-32766),a6
	jsr	a6@(-252)		| Remove(node)
	moveal	a3,a0
	moveal	a4@(-32766),a6
	jsr	a6@(-570)		| ReleaseSemaphore
	moveal	a2,a1
	movel	d7,d0
	moveal	a4@(-32766),a6
	jsr	a6@(-210)		| FreeMem(node,size)
	moveq	#1,d6
	bras	_remret
_remfail:
	moveal	a2@(10),a0		| node.ln_Name = client port
	moveal	a4@(-32766),a6
	jsr	a6@(-372)		| GetMsg(port)
	moveal	d0,a6
	movel	a6,d0
	beqs	_remret
	moveal	a6,a1
	movel	a4@(-32766),d0
	movel	a6,sp@-
	moveal	d0,a6
	jsr	a6@(-378)		| ReplyMsg stray msg
	moveal	sp@+,a6
_remret:
	movew	d6,d0
	extl	d0
	moveml	sp@+,d6-d7/a2-a3/a6
	rts

* ---- 0x832 -30: register close-screen notify ----
* a0 = screen, a1 = port, d0 = pri -> 18-byte node or 0
_vec30:
	moveml	d7/a2-a4/a6,sp@-
	moveal	a0,a3			| screen
	moveal	a1,a2			| port
	movel	d0,d7			| pri
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32762),a0
	lea	a0@(44),a0		| obj0
	moveq	#18,d0
	moveal	a2,a1
	moveb	d7,d1
	bsrw	_addnode
	moveal	d0,a6
	movel	a6,d1
	beqs	_v30ret
	movel	a3,a6@(14)		| node+14 = screen
_v30ret:
	movel	a6,d0
	moveml	sp@+,d7/a2-a4/a6
	rts

* ---- 0x866 -36: unregister close-screen notify ----
* a0 = node -> bool
_vec36:
	moveml	a3-a4,sp@-
	moveal	a0,a3
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32762),a0
	lea	a0@(58),a0		| obj0+14 = sem
	moveal	a3,a1
	moveq	#18,d0
	bsrw	_remnode
	extl	d0
	moveml	sp@+,a3-a4
	rts

* ---- 0x88a -42: register pubstatus notify ----
* a0 = port, d0 = pri -> 14-byte node or 0
_vec42:
	moveml	d7/a2-a4,sp@-
	moveal	a0,a3			| port
	movel	d0,d7			| pri
	lea	_DATA+0x7ffe,a4
	moveq	#14,d0
	moveal	a3,a1
	moveb	d7,d1
	moveal	a4@(-32762),a2
	lea	a2@(166),a0		| obj1
	bsrw	_addnode
	moveal	d0,a0
	movel	a0,d0
	moveml	sp@+,d7/a2-a4
	rts

* ---- 0x8b4 -48: unregister pubstatus notify ----
* a0 = node -> bool
_vec48:
	moveml	a3-a4,sp@-
	moveal	a0,a3
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32762),a0
	lea	a0@(180),a0		| obj1+14 = sem
	moveal	a3,a1
	moveq	#14,d0
	bsrw	_remnode
	extl	d0
	moveml	sp@+,a3-a4
	rts

* ---- 0x8d8 -54: register workbench notify ----
* a0 = port, d0 = pri -> 14-byte node or 0
_vec54:
	moveml	d7/a2-a4,sp@-
	moveal	a0,a3			| port
	movel	d0,d7			| pri
	lea	_DATA+0x7ffe,a4
	moveq	#14,d0
	moveal	a3,a1
	moveb	d7,d1
	moveal	a4@(-32762),a2
	lea	a2@(288),a0		| obj2
	bsrw	_addnode
	moveal	d0,a0
	movel	a0,d0
	moveml	sp@+,d7/a2-a4
	rts

* ---- 0x902 -60: unregister workbench notify ----
* a0 = node -> bool
_vec60:
	moveml	a3-a4,sp@-
	moveal	a0,a3
	lea	_DATA+0x7ffe,a4
	moveal	a4@(-32762),a0
	lea	a0@(302),a0		| obj2+14 = sem
	moveal	a3,a1
	moveq	#14,d0
	bsrw	_remnode
	extl	d0
	moveml	sp@+,a3-a4
	rts

* ---- 0x926: stack-arg wrapper for getnext (dead) ----
	nop
	moveal	sp@(4),a0
* ---- 0x92c _getnext: MinList walker (a0=node -> d0=next or 0) ----
_getnext:
	moveal	a0@,a0
	movel	a0@,d0
	beqs	1f
	movel	a0,d0
1:	rts

* ---- 0x936: stack-arg wrapper for NewList (dead) ----
	nop
	moveal	sp@(4),a0
* ---- 0x93c _newlist ----
_newlist:
	clrl	a0@(4)			| lh_Tail = 0
	movel	a0,a0@(8)		| lh_TailPred = &head
	addql	#4,a0
	movel	a0,a0@-			| lh_Head = &tail
	rts

* ---- 0x94a: dead tail stubs (vbcc pad block) ----
	dc.w	0x0000,0x7000,0x4e75
	dc.w	0x7001,0x4e75
	dc.w	0x7000,0x4e75
	dc.w	0x7001,0x4e75
	dc.w	0x4e75
	dc.w	0x4e71,0x4e75
	dc.w	0x4e71,0x4e75
	dc.w	0x4e71

* ================================================================
	.data
_DATA:
* 8 bytes on disk; hunk header declares 24 bytes (6 longs) so the
* globals tail is loader-zeroed.  +0 SysBase, +4 LibBase,
* +8..+20 saved intuition vectors.
	dc.l	0,0
