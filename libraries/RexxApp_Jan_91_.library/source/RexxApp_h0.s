** rexxapp.library -- "(dissidents Jan 91) rexxapp.library"
** ARexx host-application support library: owns a private message
** port, uniquifies its name via FindPort, pumps RexxMsgs and
** dispatches commands to a client handler table.  Singleton: SysBase
** and the seglist live in the code image at +0x94/+0x98.
**
** Non-AUTOINIT resident (rt_Flags=0): rt_Init stores the incoming
** regs and calls exec MakeLibrary with a1 = library-image template
** at +0x72.  The jmp table at +0x1e (14 absolute jmps) becomes the
** negative region: entry i lands at LVO -(84-6i):
**   -84/-78/-72 null, -66 VecRetMsg, -60 entry(B), -54 entry(null),
**   -48 entry(main), -42 cleanup, -36 dispatch, -30 portsetup,
**   -24 null, -18 Expunge, -12 Close, -6 Open.
** Public vectors take a context pointer in a5 (register-arg API).

	.section .text

** code+0 -- null vector stub
_LibNull:
	moveq	#0,%d0
	rts

** RomTag (code+4)
_RomTag:
	.short	0x4afc
	.long	_RomTag			| rt_MatchTag
	.long	_JmpTab			| rt_EndSkip -> jmp table
	.byte	0, 0, 9, 0		| flags 0, ver 0, NT_LIBRARY, pri 0
	.long	_LibName		| rt_Name
	.long	_IdStr			| rt_IdString
	.long	_Init			| rt_Init

** jmp table (code+0x1e)
_JmpTab:
	.short	0x4ef9
	.long	_LibNull		| -84
	.short	0x4ef9
	.long	_LibNull		| -78
	.short	0x4ef9
	.long	_LibNull		| -72
	.short	0x4ef9
	.long	_VecRetMsg		| -66
	.short	0x4ef9
	.long	_EntryB			| -60
	.short	0x4ef9
	.long	_EntryNull		| -54
	.short	0x4ef9
	.long	_EntryMain		| -48
	.short	0x4ef9
	.long	_Cleanup		| -42
	.short	0x4ef9
	.long	_Dispatch		| -36
	.short	0x4ef9
	.long	_PortSetup		| -30
	.short	0x4ef9
	.long	_LibNull		| -24
	.short	0x4ef9
	.long	_Expunge		| -18
	.short	0x4ef9
	.long	_Close			| -12
	.short	0x4ef9
	.long	_Open			| -6

** library-image template (code+0x72) -- MakeLibrary 'structure' arg
_LibImage:
	.long	0, 0			| ln_Succ/ln_Pred
	.byte	9, 0			| ln_Type=NT_LIBRARY, ln_Pri
	.long	_LibName		| ln_Name
	.byte	6, 0			| lib_Flags, pad
	.short	0x54, 0x3a		| NegSize=84, PosSize=58
	.short	0, 1			| Version=0, Revision=1
	.long	_IdStr			| lib_IdString
	.long	0			| lib_Sum
	.short	0			| lib_OpenCnt
_segptr:				| code+0x94: runtime seglist slot
	.long	0
_sysbase:				| code+0x98: runtime SysBase slot
	.long	0

** ----------------------------------------------------------------
** rt_Init (code+0x9c) -- a0=seglist, a6=SysBase
_Init:
	movel	%a3,%sp@-
	lea	_segptr(%pc),%a3
	movel	%a0,%a3@+		| seglist -> code+0x94
	movel	%a6,%a3@+		| SysBase -> code+0x98
	lea	_LibImage(%pc),%a1
	moveal	%a1,%a3
	jsr	%a6@(-396)		| MakeLibrary
	movel	%a3,%d0			| returns template ptr (not libbase!)
	moveal	%sp@+,%a3
	rts

** ----------------------------------------------------------------
** -6 Open (0xb6)
_Open:
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)		| LIBF_DELEXP
	movel	%a6,%d0
	rts

** -12 Close (0xc4)
_Close:
	subqw	#1,%a6@(32)
	bnes	_closert
	bset	#3,%a6@(14)
	bnes	_exp2			| deferred -> expunge now
_closert:
	moveq	#0,%d0
	rts

** -18 Expunge (0xd6)
_Expunge:
	bset	#3,%a6@(14)
	movew	%a6@(32),%d1
	bnes	_closert		| open -> defer
_exp2:
	movel	%a6,%sp@-
	moveal	_sysbase(%pc),%a6
	lea	_LibImage(%pc),%a1	| removes the template node(!)
	jsr	%a6@(-252)		| Remove
	movel	_segptr(%pc),%d0	| return stored seglist
	moveal	%sp@+,%a6
	rts

** ----------------------------------------------------------------
** _h1 (0xf8): dual-callback helper -- a5+42=rexxsyslib base,
** a5+46/a5+50 = client function ptrs (called via jsr a6@).
_h1:
	tstl	%d0
	beqs	_h1alt			| -> 0x116
	tstl	%d1
	beqs	_h1err			| -> 0x136 "Severe RETURN or EXIT"
	movel	%d1,%d0
	movel	%d0,%sp@-
	moveal	%a5@(42),%a6
	jsr	%a6@(-96)		| rexxsyslib fn
	addql	#8,%a0
	movel	%sp@+,%d0
_h1mid:					| 0x110
	moveal	%a5@(46),%a6
	bras	_h1call			| -> 0x12a
_h1alt:					| 0x116
	exg	%d1,%d0
	subal	%a0,%a0
	btst	#1,%a2@(29)
	beqs	_h1b2
	moveal	%d0,%a0
	moveq	#0,%d0
_h1b2:					| 0x126
	moveal	%a5@(50),%a6
_h1call:				| 0x12a
	moveml	%d0/%a0/%a2/%a5,%sp@-
	jsr	%a6@			| call fn at a6+0
	moveml	%sp@+,%d0/%a0/%a2/%a5
	rts
_h1err:					| 0x136
	lea	_ErrExit(%pc),%a0	| "Severe RETURN or EXIT"
	moveq	#20,%d1
	subl	%d0,%d1
	blss	_h1mid
	subal	%a0,%a0
	bras	_h1b2

** _h2 (0x144): free port signal + RemPort; a0 = &port.sigbit
_h2:
	moveal	_sysbase(%pc),%a6
	moveb	%a0@,%d0		| sigbit
	bmis	_h2r			| <0 -> not allocated
	bset	#7,%a0@			| mark released
	movel	%a0,%sp@-
	jsr	%a6@(-336)		| FreeSignal
	moveal	%sp@+,%a0
	lea	%a0@(-15),%a1		| port base
	jsr	%a6@(-360)		| RemPort
	moveq	#0,%d0
_h2r:	rts				| bmis lands here: skips moveq

** ----------------------------------------------------------------
** -42 Cleanup (0x164): drain port, reply outstanding, remove port
_Cleanup:
	movel	%a6,%sp@-
	moveal	_sysbase(%pc),%a6
	bset	#7,%a5@(32)		| shutdown flag
_clloop:
	bsrs	_Dispatch			| poll/dispatch once
	moveb	%a5@(33),%d0		| outstanding count
	beqs	_cldone
	jsr	%a6@(-384)		| WaitPort
	bras	_clloop
_cldone:
	lea	%a5@(15),%a0		| &port.sigbit
	bsrs	_h2
	bclr	#7,%a5@(32)
	moveal	%sp@+,%a6
	braw	_Gone

** ----------------------------------------------------------------
** -36 Dispatch (0x190): a5 = ctx; message pump + cmd-table dispatch
_Dispatch:
	moveml	%d2/%a2-%a4/%a6,%sp@-
_dqcore:				| 0x194: shared poll head
	moveb	%a5@(15),%d0		| sigbit / PA flag
	bpls	_dgetmsg
_dpop:
	moveml	%sp@+,%d2/%a2-%a4/%a6
_dprts:
	rts
_dcallfn:				| 0x1a0: bsr target (d0 msg+100)
	beqs	_dprts			| d0==0 -> bare rts
	moveal	%d0,%a6
	moveal	%a2,%a0
_dcall2:				| 0x1a6: bsr target (a6 preset)
	movel	%a2@(32),%d0
	movel	%a2@(36),%d1
	jmp	%a6@			| tail-call, returns to bsr site
_dgetmsg:				| 0x1b0
	moveal	%a5,%a0
	moveal	_sysbase(%pc),%a6
	jsr	%a6@(-372)		| GetMsg(port)
	moveal	%a5,%a0
	movel	%d0,%d1
	beqs	_dpop			| empty
	moveal	%d0,%a2		| a2 = msg
	moveal	%a2@(40),%a4	| arg ptr
	cmpal	%a2@(14),%a0		| ours? (dest vs a5 ctx)
	bnes	_dname
	lea	_h1(%pc),%a6		| arg-callback helper
	bsrs	_dcall2			| _h1(msg) via a6
	movel	%a2@(100),%d0
	bsrs	_dcallfn		| call msg+100 fn if set
	movel	%a2@(28),%d2		| action/flags
	movel	%a4,%d0
	bsrw	_msgdone
	bras	_dgetmsg
_dname:					| 0x1e4: command-name dispatch
	moveq	#32,%d0			| ' '
	moveq	#9,%d1			| tab
_dskip:	cmpb	%a4@+,%d0
	beqs	_dskip
	cmpb	%a4@(-1),%d1
	beqs	_dskip
	subql	#1,%a4
	lea	%a5@(62),%a3		| command table head
	clrl	%a2@(32)
	clrl	%a2@(36)
	moveb	%a5@(32),%d0		| shutdown flag
	bpls	_dnext
	moveb	#100,%a2@(35)		| shutting down -> rc 100
	bras	_dreply
_dcmp:					| 0x20e: compare *a1 vs *a0
	moveal	%a4,%a1
	moveal	%d0,%a0
_dcmp2:	moveb	%a0@+,%d0
	beqs	_dmatch			| table name ended -> match
	moveb	%a1@+,%d1
	cmpb	%d1,%d0
	beqs	_dcmp2
	bset	#5,%d1			| fold case
	cmpb	%d0,%d1
	bnes	_dmiss
	moveq	#97,%d0			| 'a'
	subb	%d1,%d0
	bhis	_dmiss
	cmpib	#122,%d1		| 'z'
	blss	_dcmp2
	bras	_dmiss
_dmatch:
	moveal	%a1,%a4			| a4 = rest of input
	moveal	%a3@,%a3		| table entry handler
	moveml	%a2-%a5,%sp@-
	moveal	%a5@(38),%a0		| client handler fn
	jsr	%a0@
	moveml	%sp@+,%a2-%a5
	movel	%d0,%d1
	beqs	_dloop			| handler ret 0 -> skip reply
_dreply:
	moveal	%a2,%a1
	moveal	_sysbase(%pc),%a6
	jsr	%a6@(-378)		| ReplyMsg
_dloop:
	braw	_dgetmsg
_dmiss:	addql	#4,%a3
_dnext:	movel	%a3@+,%d0
	bnes	_dcmp
	movel	%a5@(34),%a2@(112)	| msg+112 = a5+34
	beqs	_drc30
	moveal	%a2,%a1
	moveal	%a4,%a0
	bsrs	_EntryB			| retmsg path (a1=&_RetMsg)
	bras	_dloop
_drc30:	moveb	#30,%a2@(35)
	bras	_dreply

** ----------------------------------------------------------------
** -54 entry: handler=NULL ; -60 entry: handler=_RetMsg
_EntryNull:				| 0x274
	subal	%a1,%a1
	bras	_epre
_EntryB:				| 0x278
	lea	_RetMsg(%pc),%a1
_epre:					| 0x27c
	movel	#16777216,%d0		| 0x01000000
	moveq	#0,%d1
	bras	_EntryMain

** _GetRXL (0x286): ensure rexxsyslib base in a5+42 -> a6
_GetRXL:
	lea	_ErrNoLib(%pc),%a4	| "Can't find rexxsyslib.library"
_GetRXL2:				| 0x28a entry (a4 preset by caller)
	moveal	_sysbase(%pc),%a6
	movel	%a5@(42),%d0
	bnes	_gotrx
	lea	_RXLName(%pc),%a1
	jsr	%a6@(-552)		| OpenLibrary
	movel	%d0,%a5@(42)
_gotrx:	moveal	%d0,%a6
	rts

** ----------------------------------------------------------------
** -48 EntryMain (0x2a4): the real entry
_EntryMain:
	moveml	%d2/%a2-%a4/%a6,%sp@-
	exg	%d1,%a2			| a2 = flags, d2 = d0
	movel	%d0,%d2
	moveml	%d1/%a1-%a2,%sp@-	| save d1(fn?)/a1(handler)/a2(flags)
	moveal	%a0,%a3			| a3 = argstr
	lea	_ErrNoPort(%pc),%a4	| "Rexx port not setup"
	moveb	%a5@(15),%d0		| port sigbit/flag
	bmiw	_mdone			| not setup -> bail
	lea	_ErrMany(%pc),%a4	| "Too many Rexx msgs"
	moveb	%a5@(33),%d0		| msg count
	addqb	#1,%d0
	beqs	_mhave			| was 255
	bsrs	_GetRXL			| ensure rexxsyslib
_mhave:					| 0x2cc
	beqw	_mdone			| no rexxsyslib -> bail
	lea	_ErrNoMem(%pc),%a4	| "No mem for Rexx msg"
	moveal	%a5,%a0
	movel	%a0@(10),%d0		| port name
	moveal	%a5@(34),%a1
	jsr	%a6@(-144)		| rexxsyslib fn (SetSR? private)
	moveal	%d0,%a2			| a2 = new msg
	movel	%d0,%d1
	beqs	_mmsg			| alloc fail -> msgdone path
	movel	%d2,%a2@(28)		| action = flags
	btst	#20,%d2
	bnes	_mnock
	addqb	#1,%a5@(33)		| count++
	btst	#18,%d2
	bnes	_mset			| keep-count flag
_mnock:	bclr	#18,%d2
	moveal	%a3,%a0
	bsrw	_strlen			| arg -> argstring via a6 fn
	movel	%d0,%a3
_mset:	moveml	%sp@,%d1/%a0-%a1	| reload d1/a1 (peek)
	movel	%a3,%a2@(40)		| rm_Args[0]
	beqs	_mmsg
	movel	%a5@(10),%a2@(10)
	movel	%a0,%a2@(100)
	movel	%d1,%a2@(96)
	movel	%a1,%d1			| handler set?
	beqs	_msend
	moveml	%a2/%a5,%sp@-
	jsr	%a1@			| user setup fn
	moveml	%sp@+,%a2/%a5
	moveal	%d0,%a4
	movel	%d0,%d1
	bnes	_mret			| handler refused -> errstr path
_msend:					| 0x334
	lea	_ErrNoSrv(%pc),%a4	| "Can't find Rexx server"
	moveal	_sysbase(%pc),%a6
	jsr	%a6@(-132)		| Forbid
	lea	_RXPort(%pc),%a1	| "REXX"
	jsr	%a6@(-390)		| FindPort
	movel	%d0,%sp@		| overwrite saved d1
	beqs	_mperm
	moveal	%a2,%a1
	moveal	%d0,%a0
	jsr	%a6@(-366)		| PutMsg -> REXX
_mperm:	jsr	%a6@(-138)		| Permit
	movel	%sp@,%d0		| found?
	bnes	_mret2
_mret:	movel	%a3,%d0		| 0x35c
_mmsg:	bsrs	_msgdone		| 0x35e: release/finish
_mdone:					| 0x360
	subal	%a2,%a2
_mret2:					| 0x362
	moveml	%sp@+,%d1/%a0-%a1
	moveal	%a4,%a0			| errstr/result ptr
	movel	%a2,%d0
	moveml	%sp@+,%d2/%a2-%a4/%a6
	rts

** _msgdone (0x370): cleanup/release msg a2, result in d0
_msgdone:
	moveal	%a5@(42),%a6		| rexxsyslib
	beqs	_mdfree
	btst	#18,%d2
	bnes	_mdfree
	moveal	%d0,%a0
	jsr	%a6@(-132)		| DeleteArgstring
_mdfree:
	movel	%a2,%d0
	beqs	_mdgone
	btst	#20,%d2
	bnes	_mdsm
	subqb	#1,%a5@(33)		| count--
	btst	#17,%d2
	beqs	_mdsm
	movel	%a2@(32),%d0
	bnes	_mdsm
	movel	%a2@(36),%d0
	beqs	_mdsm
	moveal	%d0,%a0
	jsr	%a6@(-132)
_mdsm:	moveal	%a2,%a0
	jsr	%a6@(-150)		| delete msg (rexxsyslib)
_mdgone:
	braw	_Gone

** _RetMsg (0x3b2): a0 = source; takes a0+96 msg, replies it
_RetMsg:
	moveal	%a0@(96),%a1
	movel	%a1,%sp@-
	subal	%a0,%a0			| a0=0 -> fill-path
	bsrs	_VecRetMsg
	moveal	%sp@+,%a1
	movel	%a6,%sp@-
	moveal	_sysbase(%pc),%a6
	jsr	%a6@(-378)		| ReplyMsg
	moveal	%sp@+,%a6
	rts

** _strlen (0x3cc): d0 = strlen(a0), then tail-jmp a6@(-126)
_strlen:
	moveal	%a0,%a1
1:	moveb	%a1@+,%d0
	bnes	1b
	subql	#1,%a1
	movel	%a1,%d0
	subl	%a0,%d0
	jmp	%a6@(-126)		| CreateArgstring tail

** ----------------------------------------------------------------
** -66 VecRetMsg (0x3dc): store result pair, maybe reply
_VecRetMsg:
	movel	%d1,%a1@(36)
	movel	%d0,%a1@(32)
	bnes	_Gone
	btst	#1,%a1@(29)
	beqs	_Gone
	movel	%a0,%d0
	beqs	_vstore
	movel	%a6,%sp@-
	moveml	%a0-%a1,%sp@-
	bsrw	_GetRXL2
	moveml	%sp@,%a0-%a1		| peek (not pop)
	beqs	_vnosl
	bsrs	_strlen
_vnosl:	moveml	%sp@+,%a0-%a1
	moveal	%sp@+,%a6
_vstore:
	movel	%d0,%a1@(36)
_Gone:					| 0x40e: close-lib tail
	moveb	%a5@(33),%d0		| outstanding msgs?
	bnes	_h3rts			| shared rts at 0x44e
	lea	%a5@(42),%a0		| &rexxsyslib slot
	movel	%a0@,%d1
	beqs	_h3rts
	movel	%a6,%sp@-
	moveal	_sysbase(%pc),%a6
	clrl	%a0@
	moveal	%d1,%a1
	jsr	%a6@(-414)		| CloseLibrary
	moveal	%sp@+,%a6
	rts

** _h3 (0x42e): AllocSignal + wire port (a0 = &port.sigtask)
_h3:
	movel	%a0,%sp@-
	moveq	#-1,%d0
	jsr	%a6@(-330)		| AllocSignal
	moveal	%sp@+,%a0
	movel	%a6@(276),%a0@		| SysBase.ThisTask -> sigtask
	moveb	%d0,%a0@-		| sigbit
	bmis	_h3rts			| alloc fail -> bare rts
	lea	%a0@(-15),%a1		| port base (a5+0)
	jsr	%a6@(-354)		| AddPort
_h3err:					| 0x448 (entered from _h4 bmis)
	lea	_ErrNoPort(%pc),%a0	| "Rexx port not setup"
	moveq	#0,%d0
_h3rts:	rts				| 0x44e

** _h4 (0x450): init ctx port fields; falls into shared tail at 0x47c
_h4:
	moveal	%a5,%a0
	clrl	%a0@+			| succ/pred
	clrl	%a0@+
	moveq	#4,%d0
	moveb	%d0,%a0@+		| ln_Type = NT_MSGPORT
	clrb	%a0@			| ln_Pri
	clrb	%a0@(5)			| mp_Flags (+14)
	lea	%a5@(20),%a0		| &mp_MsgList
	movel	%a0,%a0@		| NewList
	movel	%a0,%a0@(8)
	addql	#4,%a0@+
	clrl	%a0@
	clrw	%a5@(32)		| shutdown/count
	clrl	%a5@(42)		| rexxsyslib
	lea	%a5@(16),%a0		| &sigtask -> _h3
	bsrs	_h3
_h4tail:				| 0x47c: shared with PortSetup
	jsr	%a6@(-138)		| Permit
	moveml	%sp@+,%d2/%a6
	moveb	%a5@(15),%d1		| sigbit
	bmis	_h3err			| marked -> errstr ret
	moveq	#0,%d0
	bset	%d1,%d0			| 1<<sigbit
	movel	%d0,%a5@(54)		| signal mask
	rts

** ----------------------------------------------------------------
** -30 PortSetup (0x494): a1 = desired name -> a5+10; uniquify
_PortSetup:
	movel	%a1,%a5@(10)
	bset	#7,%a5@(15)		| mark sigbit byte
	moveml	%d2/%a6,%sp@-
	moveq	#8,%d2			| 8 retries
_psloop:				| 0x4a4
	moveal	_sysbase(%pc),%a6
	addqb	#1,%a6@(295)		| IDNestCnt++ (Forbid)
_psretry:				| 0x4ac: dbf loop target
	moveal	%a5@(10),%a1
	jsr	%a6@(-390)		| FindPort
	movel	%d0,%d1
	beqs	_h4			| name free -> init port
	moveal	%a5@(10),%a1
1:	moveb	%a1@+,%d0		| scan to nul
	bnes	1b
	bset	#31,%d2			| first collision -> mark
	beqs	2f
	subql	#1,%a1
2:	moveq	#58,%d0			| ':' base + retry index
	subb	%d2,%d0
	moveb	%d0,%a1@(-1)		| overwrite/append suffix
	clrb	%a1@
	dbf	%d2,_psretry
	bras	_h4tail			| give up -> permit/restore tail

** ----------------------------------------------------------------
** strings (code+0x4d8)
	.even
_RXPort:	.ascii	"REXX\0"
_ErrNoLib:	.ascii	"Can't find rexxsyslib.library\0"
_ErrNoPort:	.ascii	"Rexx port not setup\0"
_ErrMany:	.ascii	"Too many Rexx msgs\0"
_ErrNoSrv:	.ascii	"Can't find Rexx server\0"
_ErrNoMem:	.ascii	"No mem for Rexx msg\0"
_ErrExit:	.ascii	"Severe RETURN or EXIT\0"
_IdStr:		.ascii	"(dissidents Jan 91) rexxapp.library\0"
	.even
_LibName = _IdStr + 20			| "rexxapp.library" tail
_RXLName = _ErrNoLib + 11		| "rexxsyslib.library" tail of errstr
_RomEnd:
