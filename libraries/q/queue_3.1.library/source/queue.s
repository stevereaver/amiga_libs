|||	queue.s -- queue.library 3.1 (Bernhard Fastenrath / SHW, 03.12.96)
|||	hand reconstruction of the SAS/C build, byte-identical.
|||
|||	Shipped binary layout (3 hunks):
|||	  hunk0 CODE (0x26b longs): entry stub, RomTag, initfn + all code.
|||	  hunk1 DATA (8 longs):    pad long + InitTable {dsize 0x8c,
|||	                           functab->hunk2, datatab 0, initfunc}
|||	                           + 3 zero longs (reloc-table count @+0x1c).
|||	  hunk2 CODE (0x17 longs): 13-entry absolute-longword functab,
|||	                           -1L terminator, name + idstr, "#$" tail.
|||
|||	The gas/amiga link can only emit one CODE + one DATA hunk, so the
|||	link puts [template | functab | strings] into a single DATA hunk;
|||	fixup.py then re-splits it into the original hunk1 DATA and
|||	hunk2 CODE records and rewrites every RELOC32 group in the
|||	original (descending-offset) order.
|||
|||	Vectors: -6 Open, -12 Close, -18 Expunge, -24 null,
|||	-30 QOpen, -36 QClose, -42 QAddMsg, -48 QRemMsg, -54 QGetMsg,
|||	-60 QReplyMsg, -66 QFlush, -72 QAllocMsg, -78 QFreeMsg.

	.section .text

||| entry stub / reserved LVO -24 vector: returns 0.
_LibNull:
	moveq	#0,%d0			| 0x00
	rts

_romtag:				| 0x04
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endtag			| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	3			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME	-> hunk2+0x38
	.long	_idstr			| RT_IDSTRING	-> hunk2+0x48
	.long	_inittab		| RT_INIT	-> hunk1+0x04
_endtag:				| 0x1e
	.word	0			| dead pad word before initfn

||| ------------------------------------------------------------------
||| __UserLibInit + SAS/C small-data template copy (hunk0+0x20)
||| ------------------------------------------------------------------
_LibInit:				| 0x20
	subqw	#8,%sp
	moveml	%d7/%a2-%a3/%a5-%a6,%sp@-
	moveal	%d0,%a5			| a5 = libbase
	movel	%a0,%a5@(34)		| lib+34 = seglist
	moveb	#9,%a5@(8)		| ln_Type = NT_LIBRARY
	movel	#_libname,%a5@(10)	| ln_Name = "queue.library"
	moveb	#6,%a5@(14)		| lib_Flags = LIBF_SUMUSED|LIBF_CHANGED
	lea	0x3:l,%a1		| version 3 (abs.l long, not reloc)
	movel	%a1,%d0
	lea	%a5@(20),%a0
	movew	%d0,%a0@+		| lib_Version = 3
	lea	0x1:l,%a1		| revision 1
	movel	%a1,%d0
	movew	%d0,%a0@+		| lib_Revision = 1
	movel	#_idstr,%a0@+		| lib_IdString
	lea	%a5@(48),%a3		| a3 = globals base (lib+48)
	lea	0x7:l,%a1		| 7 longs
	movel	%a1,%d0
	movel	%d0,%d1
	asll	#2,%d1			| d1 = 28 (bytes to copy)
	movel	%a6,%sp@(24)		| save execbase
	lea	_rbtempl:l,%a1		| a1 = template (hunk1+0)
	moveal	%a3,%a6			| a6 = dest = lib+48
copyloop:
	cmpiw	#0x1cd9,%d0		| overlap: imm 0x1cd9 doubles as
					|   "move.b (a1)+,(a6)+" at +2
	subql	#1,%d1
	bccs	copyloop+2		| loop into the cmpiw immediate
	asll	#2,%d0			| d0 = 28
	lea	_rbtempl:l,%a0		| a0 = template base
	addal	%d0,%a0			| a0 = template+28 = fixup count
	movel	%a0@,%d7		| d7 = count (0 in this build)
	lea	%a0@(4),%a2		| a2 = fixup table
	moveal	%sp@(24),%a6		| a6 = execbase
	bras	fixtest
fixloop:
	movel	%a3,%d0
	addl	%a2@+,%d0		| dest = a3 + *a2++
	movel	%a3,%d1
	moveal	%d0,%a0
	addl	%d1,%a0@		| *dest += a3 (rebase pointer)
	subql	#1,%d7
fixtest:
	tstl	%d7
	bgts	fixloop
	moveal	%a5,%a6			| a6 = libbase
	bsrw	_LibInitPost		| init globals/semaphore/list
	tstl	%d0
	moveal	%sp@(24),%a6
	beqs	good+2			| -> mid-cmpiw: movel a5,d0
	moveq	#0,%d0
good:
	cmpiw	#0x200d,%d0		| overlap: imm 0x200d doubles as
					|   "move.l a5,d0" at +2
	moveml	%sp@+,%d7/%a2-%a3/%a5-%a6
	addqw	#8,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -6  LibOpen
||| ------------------------------------------------------------------
_LibOpen:				| 0xc4
	subqw	#4,%sp
	addqw	#1,%a6@(32)		| lib_OpenCnt++
	bclr	#3,%a6@(14)		| clear LIBF_DELEXP
	movel	%a6,%d0
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -12  LibClose
||| ------------------------------------------------------------------
_LibClose:				| 0xd6
	subqw	#4,%sp
	movel	%d7,%sp@-
	moveq	#0,%d7
	subqw	#1,%a6@(32)		| lib_OpenCnt--
	movel	%a6,%sp@(4)
	tstw	%a6@(32)
	bnes	cdone
	btst	#3,%a6@(14)		| LIBF_DELEXP?
	beqs	cdone
	bsrw	_LibExpunge		| word-form bsr (disp would fit .s)
	movel	%d0,%d7
cdone:
	movel	%d7,%d0
	movel	%sp@+,%d7
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -18  LibExpunge
||| ------------------------------------------------------------------
_LibExpunge:				| 0x100
	subqw	#4,%sp
	moveml	%d2/%d7/%a5-%a6,%sp@-
	moveal	%a6,%a5			| a5 = libbase
	moveq	#0,%d7
	bset	#3,%a5@(14)		| set LIBF_DELEXP
	movel	%a6,%sp@(16)
	tstw	%a5@(32)		| open count?
	bnes	edone
	moveal	%a5,%a6
	bsrw	_LibHookDead		| __UserLibCleanup (empty)
	movel	%a5@(34),%d7		| seglist
	moveal	%a5,%a1
	moveal	0x4,%a6			| execbase
	jsr	%a6@(-252:W)		| Remove(lib)
	moveq	#0,%d0
	movew	%a5@(18),%d0		| negSize
	moveq	#0,%d1
	movew	%a5@(16),%d1		| posSize
	movel	%d1,%d2
	addl	%d0,%d2			| d2 = pos+neg
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%d1,%d0
	subal	%d0,%a1			| a1 = lib - posSize
	movel	%d2,%d0
	jsr	%a6@(-210:W)		| FreeMem
edone:
	movel	%d7,%d0
	moveml	%sp@+,%d2/%d7/%a5-%a6
	addqw	#4,%sp
	rts
	nop				| 0x156 pad (4-align next fn)

||| ------------------------------------------------------------------
||| SetMarker(qh, msg)  -- insert handle's embedded marker MinNode
||| into the queue list after msg.  (f_158)
||| ------------------------------------------------------------------
f_SetMarker:				| 0x158
	subqw	#4,%sp
	moveml	%a2-%a3/%a5-%a6,%sp@-
	moveal	%sp@(28),%a3		| a3 = msg (pred)
	moveal	%sp@(24),%a5		| a5 = qh
	moveal	%a5@(12),%a2		| a2 = qn
	movel	%a6,%sp@(16)
	tstl	%a5@(28)		| qhl_MinNode.mln_Succ
	beqs	smins
	lea	%a5@(28),%a0
	moveal	%a0,%a1
	moveal	0x4,%a6
	jsr	%a6@(-252:W)		| Remove(&marker)
smins:
	lea	%a2@(14),%a0		| &qn->qn_List
	lea	%a5@(28),%a1		| &qh->qhl_MinNode
	movel	%a2,%sp@-
	moveal	%a3,%a2			| a2 = pred
	moveal	0x4,%a6
	jsr	%a6@(-234:W)		| Insert(list,node,pred)
	moveal	%sp@+,%a2
	moveml	%sp@+,%a2-%a3/%a5-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| ClearMarker(qh)  -- unlink embedded marker MinNode (f_1a0)
||| ------------------------------------------------------------------
f_ClearMarker:				| 0x1a0
	subqw	#4,%sp
	moveml	%a5-%a6,%sp@-
	moveal	%sp@(16),%a5		| a5 = qh
	lea	%a5@(28),%a0		| &qh->qhl_MinNode
	movel	%a6,%sp@(8)
	moveal	%a0,%a1
	moveal	0x4,%a6
	jsr	%a6@(-252:W)		| Remove
	clrl	%a5@(28)		| mln_Succ = NULL
	moveml	%sp@+,%a5-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| RemoveAndReply(msg)  (f_1c8)
||| ------------------------------------------------------------------
f_RemoveAndReply:			| 0x1c8
	subqw	#4,%sp
	moveml	%a3/%a5-%a6,%sp@-
	moveal	%sp@(20),%a5		| a5 = msg
	movel	%a6,%sp@(12)
	tstw	%a5@(10)		| qm_Refs
	bnes	rremoved
	moveal	%a5@(16),%a3		| a3 = qm_Owner (QueueHandle)
	moveal	%a5,%a1
	moveal	0x4,%a6
	jsr	%a6@(-252:W)		| Remove(msg)
	lea	%a3@(24),%a0		| &qh->qhs_ReplyList
	moveal	%a5,%a1
	jsr	%a6@(-240:W)		| AddHead
	moveal	%a3@(20),%a1		| qh_SigTask
	movel	%a3@(16),%d0		| qh_SigMask
	jsr	%a6@(-324:W)		| Signal
	moveal	%sp@(12),%a6
	bras	rdone
rremoved:
	movew	#6,%a5@(8)		| qm_Status = QMS_REMOVED
rdone:
	moveml	%sp@+,%a3/%a5-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| ReplyQMessage(qn, msg)  (f_214)
||| ------------------------------------------------------------------
f_ReplyQMessage:			| 0x214
	subqw	#4,%sp
	moveml	%a3/%a5,%sp@-
	moveal	%sp@(20),%a3		| a3 = msg
	moveal	%sp@(16),%a5		| a5 = qn
	subqw	#1,%a3@(10)		| qm_Refs--
	addql	#1,%a3@(12)		| qm_Replies++
	movel	%a6,%sp@(8)
	movel	%a3@(12),%d0
	cmpl	%a5@(32),%d0		| qm_Replies >= qn_Read?
	bccs	rreply
	moveq	#6,%d0
	cmpw	%a3@(8),%d0		| qm_Status == QMS_REMOVED?
	bnes	rdn2
rreply:
	movel	%a3,%sp@-
	bsrs	f_RemoveAndReply
	addqw	#4,%sp
rdn2:
	moveml	%sp@+,%a3/%a5
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| __UserLibInit  (f_24e) -- SysBase/QueueBase, sem + queue list
||| ------------------------------------------------------------------
_LibInitPost:				| 0x24e
	subqw	#4,%sp
	moveml	%a4-%a6,%sp@-
	moveal	%a6,%a5			| a5 = libbase
	lea	%a6@(48),%a4		| a4 = globals
	moveaw	#4,%a0
	movel	%a0@,%a4@(20)		| SysBase = *4
	movel	%a5,%a4@(24)		| QueueBase = libbase
	movel	%a6,%sp@(12)
	lea	%a4@(32),%a0		| &QueuesSemaphore
	moveal	0x4,%a6
	jsr	%a6@(-558:W)		| InitSemaphore
	pea	%a4@(78)		| &Queues
	moveal	%sp@(16),%a6
	bsrw	f_NewList
	addqw	#4,%sp
	moveq	#0,%d0			| success
	moveml	%sp@+,%a4-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| __UserLibCleanup  (f_28e) -- empty hook
||| ------------------------------------------------------------------
_LibHookDead:				| 0x28e
	subqw	#4,%sp
	moveml	%a4-%a6,%sp@-
	moveal	%a6,%a5
	lea	%a6@(48),%a4
	moveml	%sp@+,%a4-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -30  QOpen(name=a0, mode=d0, sigbit=d1)
||| ------------------------------------------------------------------
_QOpen:					| 0x2a2
	subqw	#4,%sp
	moveml	%d2/%d5-%d7/%a2-%a6,%sp@-
	movel	%d1,%d6			| d6 = sigbit
	movel	%d0,%d7			| d7 = mode
	moveal	%a0,%a5			| a5 = name
	lea	%a6@(48),%a4		| a4 = globals
	movel	%a6,%sp@(36)
	moveq	#42,%d0			| sizeof(QueueHandle)
	movel	#65537,%d1		| MEMF_PUBLIC|MEMF_CLEAR
	moveal	0x4,%a6
	jsr	%a6@(-198:W)		| AllocMem
	moveal	%d0,%a3			| a3 = qh
	moveal	%a3,%a0
	movel	%a0,%d0
	moveal	%sp@(36),%a6
	bnes	qh_ok
	moveq	#0,%d0
	braw	qfail
qh_ok:					| 0x2d8
	lea	%a4@(32),%a0		| &QueuesSemaphore
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	lea	%a4@(78),%a0		| &Queues
	moveal	%a5,%a1
	jsr	%a6@(-276:W)		| FindName(&Queues,name)
	moveal	%d0,%a2			| a2 = qn
	moveal	%a2,%a0
	movel	%a0,%d0
	moveal	%sp@(36),%a6
	bnew	qexists
	moveq	#96,%d0			| sizeof(QueueNode)
	movel	#65537,%d1
	moveal	0x4,%a6
	jsr	%a6@(-198:W)		| AllocMem
	moveal	%d0,%a2			| a2 = qn
	moveal	%a2,%a0
	movel	%a0,%d0
	moveal	%sp@(36),%a6
	bnes	qn_ok
	lea	%a4@(32),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore(&QueuesSem)
	moveal	%a3,%a1
	moveq	#42,%d0
	jsr	%a6@(-210:W)		| FreeMem(qh,42)
	moveq	#0,%d0
	braw	qfail
qn_ok:					| 0x332
	lea	%a2@(50),%a0		| &qn->qn_Semaphore
	moveal	0x4,%a6
	jsr	%a6@(-558:W)		| InitSemaphore
	lea	%a2@(50),%a0
	jsr	%a6@(-564:W)		| ObtainSemaphore
	moveal	%a5,%a0			| strlen(name)
strlen1:
	tstb	%a0@+
	bnes	strlen1
	subql	#1,%a0
	subal	%a5,%a0
	movel	%a0,%d0
	movel	%d0,%d5			| d5 = len
	addql	#1,%d5			| len+1
	movel	%d5,%d0
	moveq	#1,%d1			| MEMF_PUBLIC
	jsr	%a6@(-198:W)		| AllocMem(len+1,PUBLIC)
	movel	%d0,%a2@(10)		| qn_Node.ln_Name
	tstl	%d0
	moveal	%sp@(36),%a6
	bnes	nameok
	lea	%a2@(50),%a0		| name alloc failed
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore(qn sem)
	lea	%a4@(32),%a0
	jsr	%a6@(-570:W)		| ReleaseSemaphore(&QueuesSem)
	moveal	%a3,%a1
	moveq	#42,%d0
	jsr	%a6@(-210:W)		| FreeMem(qh)
	moveal	%a2,%a1
	moveq	#96,%d0
	jsr	%a6@(-210:W)		| FreeMem(qn)
	moveq	#0,%d0
	braw	qfail
nameok:					| 0x394
	moveal	%d0,%a1
	moveal	%a5,%a0
	movel	%d5,%d0
	moveal	0x4,%a6
	jsr	%a6@(-624:W)		| CopyMem(name,ln_Name,len+1)
	lea	%a4@(78),%a0		| &Queues
	moveal	%a2,%a1
	jsr	%a6@(-240:W)		| AddHead(&Queues,qn)
	lea	%a2@(36),%a0		| &qn->qn_Handles
	movel	%a0,%sp@-
	moveal	%sp@(40),%a6
	bsrw	f_NewList		| NewList(&qn_Handles)
	lea	%a2@(14),%a0		| &qn->qn_List
	movel	%a0,%sp@		| reuse pushed arg slot
	bsrw	f_NewList		| NewList(&qn_List)
	addqw	#4,%sp
	moveq	#1,%d0
	movel	%d0,%a2@(28)		| qn_Refs = 1
	bras	qaddh
qexists:				| 0x3ce
	lea	%a2@(50),%a0		| &qn->qn_Semaphore
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	addql	#1,%a2@(28)		| qn_Refs++
qaddh:					| 0x3de
	lea	%a2@(36),%a0		| &qn->qn_Handles
	moveal	%a3,%a1
	moveal	0x4,%a6
	jsr	%a6@(-240:W)		| AddHead(&qn_Handles,qh)
	movel	%d7,%d0
	movew	%d0,%a3@(8)		| qh_Mode = mode
	movel	%a2,%a3@(12)		| qh_QNode = qn
	movel	%d6,%d1			| sigbit
	moveq	#0,%d2
	bset	%d1,%d2			| 1<<sigbit
	movel	%d2,%a3@(16)		| qh_SigMask
	subal	%a1,%a1
	jsr	%a6@(-294:W)		| FindTask(NULL)
	movel	%d0,%a3@(20)		| qh_SigTask
	movel	%d7,%d0
	subql	#1,%d0			| mode == QMODE_LISTEN?
	moveal	%sp@(36),%a6
	bnes	qsend
	addql	#1,%a2@(32)		| qn_Read++
	movew	#10,%a3@(36)		| qhl_Status = QMS_MARKER
	moveal	%a3@(20),%a1
	movel	%a3@(16),%d0
	moveal	0x4,%a6
	jsr	%a6@(-324:W)		| Signal(SigTask,SigMask)
	moveal	%sp@(36),%a6
	bras	qrel
qsend:					| 0x434
	lea	%a3@(24),%a0		| &qh->qhs_ReplyList
	movel	%a0,%sp@-
	bsrw	f_NewList
	addqw	#4,%sp
qrel:					| 0x440
	lea	%a2@(50),%a0		| &qn->qn_Semaphore
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	lea	%a4@(32),%a0
	jsr	%a6@(-570:W)		| ReleaseSemaphore(&QueuesSem)
	movel	%a3,%d0			| return qh
qfail:					| 0x456
	moveml	%sp@+,%d2/%d5-%d7/%a2-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -36  QClose(qh=a0)
||| ------------------------------------------------------------------
_QClose:				| 0x45e
	subaw	#16,%sp
	moveml	%d7/%a2-%a6,%sp@-
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a3		| a3 = qn
	moveal	%a5,%a2			| a2 = qh
	movel	%a6,%sp@(24)
	lea	%a4@(32),%a0		| &QueuesSemaphore
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	lea	%a3@(50),%a0		| &qn->qn_Semaphore
	jsr	%a6@(-564:W)		| ObtainSemaphore
	moveq	#2,%d0
	cmpw	%a2@(8),%d0		| qh_Mode == QMODE_SEND?
	moveal	%sp@(24),%a6
	bnes	clisten
	movel	%a2@(38),%d7		| count = qhs_MsgCount
	tstl	%d7
	beqs	csendfree
	lea	%a4@(32),%a0		| busy: release & return count
	moveal	0x4,%a6
	jsr	%a6@(-570:W)
	lea	%a3@(50),%a0
	jsr	%a6@(-570:W)
	movel	%d7,%d0
	braw	cret
csendfree:				| 0x4b8
	moveal	%sp@(24),%a6
	braw	cremove
clisten:				| 0x4c0
	moveal	%a2@(28),%a0		| qhl_MinNode.mln_Succ
	movel	%a0,%sp@(36)
	beqs	cnomark
	movel	%a2,%sp@-
	bsrw	f_ClearMarker		| marker set: ClearMarker(qh)
	addqw	#4,%sp
	moveal	%sp@(36),%a0
	movel	%a0@(4),%sp@(28)	| next = marker.mln_Pred
	bras	cnext0
cnomark:				| 0x4de
	moveal	%a2@(24),%a1		| qhl_Message
	movel	%a1,%sp@(36)
	beqs	cnext0
	subqw	#1,%a1@(10)		| qm_Refs--
	addql	#1,%a1@(12)		| qm_Replies++
	movel	%a1,%sp@(28)		| next = cmsg
cnext0:					| 0x4f4
	movel	%sp@(28),%d0
	beqs	clisthead
	movel	%d0,%sp@(32)
cdecwalk:				| 0x4fe
	moveal	%sp@(32),%a1
	moveal	%a1@(4),%a0		| mln_Pred
	movel	%a0,%sp@(28)
	beqs	cdonedec
	movew	%a1@(8),%d0		| qm_Status
	moveq	#1,%d1
	cmpw	%d1,%d0			| QMS_ACTIVE?
	beqs	cdec
	subqw	#6,%d0			| QMS_REMOVED?
	bnes	cnext1
cdec:
	subql	#1,%a1@(12)		| qm_Replies--
cnext1:
	movel	%sp@(28),%sp@(32)
	bras	cdecwalk
clisthead:				| 0x526
	moveal	%a3@(14),%a0		| qn_List.lh_Head
	movel	%a0,%sp@(36)
cdonedec:				| 0x52e
	movel	%sp@(36),%sp@(32)
crepwalk:				| 0x534
	moveal	%sp@(32),%a1
	moveal	%a1@,%a0		| mln_Succ
	movel	%a0,%sp@(28)
	beqs	crepdone
	movew	%a1@(8),%d0		| qm_Status
	moveq	#1,%d1
	cmpw	%d1,%d0			| QMS_ACTIVE?
	bnes	cnotact
	movel	%a1@(12),%d1		| qm_Replies
	cmpl	%a3@(32),%d1		| >= qn_Read?
	bccs	creply
cnotact:
	subqw	#6,%d0			| QMS_REMOVED?
	bnes	cmarker
creply:
	movel	%a1,%sp@-
	bsrw	f_RemoveAndReply
	addqw	#4,%sp
cmarker:
	moveq	#10,%d0
	moveal	%sp@(32),%a0
	cmpw	%a0@(8),%d0		| QMS_MARKER?
	beqs	crepdone
	movel	%sp@(28),%sp@(32)
	bras	crepwalk
crepdone:				| 0x574
	subql	#1,%a3@(32)		| qn_Read--
cremove:				| 0x578
	moveal	%a2,%a1			| qh
	moveal	0x4,%a6
	jsr	%a6@(-252:W)		| Remove(qh)
	moveal	%a2,%a1
	moveq	#42,%d0
	jsr	%a6@(-210:W)		| FreeMem(qh,42)
	subql	#1,%a3@(28)		| qn_Refs--
	moveal	%sp@(24),%a6
	bnes	ckeep
	lea	%a3@(50),%a0		| last ref: teardown
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore(qn sem)
	moveal	%a3,%a1
	jsr	%a6@(-252:W)		| Remove(qn)
	moveal	%a3@(10),%a0		| ln_Name
	movel	%a0,%d0
strlen2:
	tstb	%a0@+
	bnes	strlen2
	subql	#1,%a0
	subal	%d0,%a0
	movel	%a0,%d0
	addql	#1,%d0			| len+1
	moveal	%a3@(10),%a1
	jsr	%a6@(-210:W)		| FreeMem(name,len+1)
	moveal	%a3,%a1
	moveq	#96,%d0
	jsr	%a6@(-210:W)		| FreeMem(qn,96)
	moveal	%sp@(24),%a6
	bras	cgsem
ckeep:					| 0x5ce
	lea	%a3@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore(qn sem)
cgsem:					| 0x5da
	lea	%a4@(32),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore(&QueuesSem)
	moveq	#0,%d0
cret:					| 0x5e8
	moveml	%sp@+,%d7/%a2-%a6
	addaw	#16,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -42  QAddMsg(qh=a0, msg=a1)
||| ------------------------------------------------------------------
_QAddMsg:				| 0x5f2
	subqw	#8,%sp
	moveml	%a2-%a6,%sp@-
	moveal	%a1,%a3			| a3 = msg
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a2		| a2 = qn
	movel	%a5,%sp@(24)
	movel	%a5,%a3@(16)		| qm_Owner = qh
	clrw	%a3@(10)		| qm_Refs = 0
	clrl	%a3@(12)		| qm_Replies = 0
	movew	#1,%a3@(8)		| qm_Status = QMS_ACTIVE
	lea	%a2@(50),%a0		| &qn->qn_Semaphore
	movel	%a6,%sp@(20)
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	lea	%a2@(14),%a0		| &qn->qn_List
	moveal	%a3,%a1
	jsr	%a6@(-246:W)		| AddTail(qn_List,msg)
	moveal	%sp@(24),%a0
	addql	#1,%a0@(38)		| qhs_MsgCount++
	moveal	%sp@(20),%a6
	tstl	%a2@(32)		| qn_Read?
	beqs	areply
	movel	%a2@(36),%sp@(24)	| qn_Handles.lh_Head
asigwalk:				| 0x64c
	moveal	%sp@(24),%a0
	tstl	%a0@			| mln_Succ
	beqs	adone
	moveq	#1,%d0
	cmpw	%a0@(8),%d0		| qh_Mode == QMODE_LISTEN?
	bnes	asigskip
	moveal	%a0@(20),%a1		| qh_SigTask
	movel	%a0@(16),%d0		| qh_SigMask
	moveal	0x4,%a6
	jsr	%a6@(-324:W)		| Signal
asigskip:
	moveal	%sp@(20),%a6
	moveal	%sp@(24),%a0
	movel	%a0@,%sp@(24)		| next
	bras	asigwalk
areply:					| 0x67a
	movel	%a3,%sp@-
	bsrw	f_RemoveAndReply	| no readers: reply immediately
	addqw	#4,%sp
adone:					| 0x682
	lea	%a2@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	moveml	%sp@+,%a2-%a6
	addqw	#8,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -48  QRemMsg(qh=a0, msg=a1)
||| ------------------------------------------------------------------
_QRemMsg:				| 0x696
	subqw	#4,%sp
	moveml	%a2-%a6,%sp@-
	moveal	%a1,%a3			| a3 = msg
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a2		| a2 = qn
	lea	%a2@(50),%a0		| &qn->qn_Semaphore
	movel	%a6,%sp@(20)
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	movel	%a3,%sp@-
	moveal	%sp@(24),%a6
	bsrw	f_RemoveAndReply
	lea	%a2@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	addqw	#4,%sp
	moveml	%sp@+,%a2-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -54  QGetMsg(qh=a0)
||| ------------------------------------------------------------------
_QGetMsg:				| 0x6d8
	subaw	#12,%sp
	moveml	%a2-%a6,%sp@-
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a3		| a3 = qn
	moveal	%a5,%a2			| a2 = qh
	lea	%a3@(50),%a0		| &qn->qn_Semaphore
	movel	%a6,%sp@(20)
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	moveq	#2,%d0
	cmpw	%a2@(8),%d0		| qh_Mode == QMODE_SEND?
	moveal	%sp@(20),%a6
	bnes	glisten
	lea	%a2@(24),%a0		| &qh->qhs_ReplyList
	moveal	0x4,%a6
	jsr	%a6@(-264:W)		| RemTail
	moveal	%sp@(20),%a6
	movel	%d0,%sp@(28)
	tstl	%d0
	beqs	gsdone
	subql	#1,%a2@(38)		| qhs_MsgCount--
gsdone:					| 0x724
	lea	%a3@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	movel	%sp@(28),%d0
	braw	gret
glisten:				| 0x738
	moveal	%a2@(24),%a0		| qhl_Message
	moveal	%sp@(20),%a6
	movel	%a0,%sp@(28)
	movel	%a0,%d0
	beqs	gnomsg
	movel	%a0@,%sp@(24)		| next = msg->mln_Succ
	movel	%d0,%sp@-
	movel	%a3,%sp@-
	bsrw	f_ReplyQMessage		| auto-reply current msg
	addqw	#8,%sp
	movel	%sp@(24),%sp@(28)	| msg = next
	bras	gfind
gnomsg:					| 0x75e
	moveal	%a2@(28),%a1		| qhl_MinNode.mln_Succ
	movel	%a1,%sp@(28)
	movel	%a1,%d0
	beqs	ghead
	movel	%a2,%sp@-
	bsrw	f_ClearMarker		| ClearMarker(qh)
	addqw	#4,%sp
	bras	gfind
ghead:					| 0x774
	movel	%a3@(14),%sp@(28)	| qn_List.lh_Head
gfind:					| 0x77a
	moveal	%sp@(28),%a1
	moveal	%a1@,%a0		| mln_Succ
	movel	%a0,%sp@(24)
	movel	%a0,%d0
	bnes	gcheck
	movel	%a1@(4),%sp@-		| mln_Pred
	movel	%a2,%sp@-
	bsrw	f_SetMarker		| SetMarker(qh,pred)
	addqw	#8,%sp
	subal	%a0,%a0
	movel	%a0,%sp@(28)		| msg = NULL
	bras	gset
gcheck:					| 0x79c
	moveal	%sp@(28),%a0
	btst	#1,%a0@(9)		| qm_Status & QMS_INACTIVE?
	beqs	gtake
	moveq	#6,%d0
	cmpw	%a0@(8),%d0		| == QMS_REMOVED?
	bnes	gskip
	movel	%a0,%sp@-
	bsrw	f_RemoveAndReply
	addqw	#4,%sp
gskip:
	movel	%sp@(24),%sp@(28)	| msg = next
	bras	gfind
gtake:					| 0x7c0
	moveal	%sp@(28),%a0
	addqw	#1,%a0@(10)		| qm_Refs++
gset:					| 0x7c8
	movel	%sp@(28),%a2@(24)	| qhl_Message = msg
	lea	%a3@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	movel	%sp@(28),%d0
gret:					| 0x7de
	moveml	%sp@+,%a2-%a6
	addaw	#12,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -60  QReplyMsg(qh=a0)
||| ------------------------------------------------------------------
_QReplyMsg:				| 0x7e8
	subaw	#12,%sp
	moveml	%a2-%a6,%sp@-
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a3		| a3 = qn
	moveal	%a5,%a2			| a2 = qh
	moveal	%a2@(24),%a0		| qhl_Message
	movel	%a0,%sp@(28)
	movel	%a6,%sp@(20)
	movel	%a0,%d0
	beqw	qpret
	lea	%a3@(50),%a0		| &qn->qn_Semaphore
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	movel	%sp@(28),%sp@-
	movel	%a2,%sp@-
	moveal	%sp@(28),%a6
	bsrw	f_SetMarker		| SetMarker(qh,msg)
	moveal	%sp@(36),%a0		| msg (arg slot)
	movel	%a0@,%sp@(32)		| next = msg->mln_Succ
	movel	%a0,%sp@		| reuse arg slot: msg
	movel	%a3,%sp@-
	bsrw	f_ReplyQMessage		| ReplyQMessage(qn,msg)
	lea	%sp@(12),%sp		| pop args+slot
	movel	%sp@(24),%d0		| next
	beqs	qpclr
	movel	%d0,%sp@(28)
qpwalk:					| 0x846
	moveal	%sp@(28),%a1
	moveal	%a1@,%a0		| mln_Succ
	movel	%a0,%sp@(24)
	beqs	qpclr
	moveq	#1,%d0
	cmpw	%a1@(8),%d0		| QMS_ACTIVE?
	bnes	qpnext
	moveal	%a2@(20),%a1		| qh_SigTask
	movel	%a2@(16),%d0		| qh_SigMask
	moveal	0x4,%a6
	jsr	%a6@(-324:W)		| Signal (remind: more msgs)
	moveal	%sp@(20),%a6
	bras	qpclr
qpnext:
	moveal	%sp@(20),%a6
	movel	%sp@(24),%sp@(28)
	bras	qpwalk
qpclr:					| 0x87c
	clrl	%a2@(24)		| qhl_Message = NULL
	lea	%a3@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	moveq	#1,%d0
qpret:					| 0x88e
	moveml	%sp@+,%a2-%a6
	addaw	#12,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -66  QFlush(qh=a0)
||| ------------------------------------------------------------------
_QFlush:				| 0x898
	subqw	#8,%sp
	moveml	%a2-%a6,%sp@-
	moveal	%a0,%a5			| a5 = qh
	lea	%a6@(48),%a4		| a4 = globals
	moveal	%a5@(12),%a3		| a3 = qn
	lea	%a3@(50),%a0		| &qn->qn_Semaphore
	movel	%a6,%sp@(20)
	moveal	0x4,%a6
	jsr	%a6@(-564:W)		| ObtainSemaphore
	moveal	%a3@(14),%a2		| msg = qn_List.lh_Head
	moveal	%sp@(20),%a6
fwalk:					| 0x8c0
	moveal	%a2@,%a0		| mln_Succ
	movel	%a0,%sp@(24)
	beqs	fdone
	moveq	#10,%d0
	cmpw	%a2@(8),%d0		| qm_Status == QMS_MARKER?
	beqs	fskip
	movel	%a2,%sp@-
	bsrw	f_RemoveAndReply
	addqw	#4,%sp
fskip:
	moveal	%sp@(24),%a2		| msg = next
	bras	fwalk
fdone:					| 0x8de
	lea	%a3@(50),%a0
	moveal	0x4,%a6
	jsr	%a6@(-570:W)		| ReleaseSemaphore
	moveq	#1,%d0
	moveml	%sp@+,%a2-%a6
	addqw	#8,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -72  QAllocMsg(size=d0)
||| ------------------------------------------------------------------
_QAllocMsg:				| 0x8f4
	subqw	#4,%sp
	moveml	%d7/%a4-%a6,%sp@-
	movel	%d0,%d7			| d7 = size
	lea	%a6@(48),%a4		| a4 = globals
	movel	%a6,%sp@(16)
	moveq	#24,%d0			| sizeof(QMessage)
	movel	#65537,%d1		| MEMF_PUBLIC|MEMF_CLEAR
	moveal	0x4,%a6
	jsr	%a6@(-198:W)		| AllocMem
	moveal	%d0,%a5			| a5 = msg
	moveal	%a5,%a0
	movel	%a0,%d0
	moveal	%sp@(16),%a6
	bnes	amsgok
	moveq	#0,%d0
	bras	amret
amsgok:					| 0x924
	moveal	%sp@(16),%a6
	tstl	%d7
	beqs	amdone			| size == 0 -> done
	movel	%d7,%d0
	moveq	#0,%d1			| MEMF_SHARED_READ (0 here)
	moveal	0x4,%a6
	jsr	%a6@(-198:W)		| AllocMem(size)
	movel	%d0,%a5@(20)		| qm_Data
	tstl	%d0
	moveal	%sp@(16),%a6
	bnes	amdone
	moveal	%a5,%a1			| data alloc failed
	moveq	#24,%d0
	moveal	0x4,%a6
	jsr	%a6@(-210:W)		| FreeMem(msg,24)
	moveq	#0,%d0
	bras	amret
amdone:					| 0x954
	movel	%a5,%d0
amret:					| 0x956
	moveml	%sp@+,%d7/%a4-%a6
	addqw	#4,%sp
	rts

||| ------------------------------------------------------------------
||| LVO -78  QFreeMsg(msg=a0, size=d0)
||| ------------------------------------------------------------------
_QFreeMsg:				| 0x95e
	subqw	#4,%sp
	moveml	%d7/%a4-%a6,%sp@-
	movel	%d0,%d7			| d7 = size
	moveal	%a0,%a5			| a5 = msg
	lea	%a6@(48),%a4		| a4 = globals
	movel	%a6,%sp@(16)
	movel	%a5@(20),%d0		| qm_Data
	beqs	fmnodata
	moveal	%d0,%a1
	movel	%d7,%d0
	moveal	0x4,%a6
	jsr	%a6@(-210:W)		| FreeMem(qm_Data,size)
fmnodata:				| 0x982
	moveal	%a5,%a1
	moveq	#24,%d0
	moveal	0x4,%a6
	jsr	%a6@(-210:W)		| FreeMem(msg,24)
	moveml	%sp@+,%d7/%a4-%a6
	addqw	#4,%sp
	rts
	nop				| 0x996 pad (4-align f_NewList)

||| ------------------------------------------------------------------
||| f_NewList(list)  -- exec NewList clone (helper, bsr-called)
||| ------------------------------------------------------------------
f_NewList:				| 0x998
	moveal	%sp@(4),%a0
	clrl	%a0@(4)			| lh_Tail = NULL
	movel	%a0,%a0@(8)		| lh_TailPred = &lh_Head
	addql	#4,%a0
	movel	%a0,%a0@-		| lh_Head = &lh_Tail
	rts

	.space	2,0			| pad hunk0 to 0x9ac bytes

	.section .data

||| ------------------------------------------------------------------
||| DATA template copied to lib+48 by _LibInit (28 bytes used);
||| doubles as the AUTOINIT InitTable at +4 (rt_Init target).
||| ------------------------------------------------------------------
_rbtempl:				| hunk1+0
	.long	0			| copied to g+0
_inittab:				| hunk1+4
	.long	0x8c			| dataSize = 140
	.long	_functab		| functionTable -> hunk2+0
	.long	0			| dataTable = NULL
	.long	_LibInit		| initRoutine -> hunk0+0x20
	.long	0			| copied to g+20 (SysBase)
	.long	0			| copied to g+24 (QueueBase)
	.long	0			| +0x1c: fixup count (0)

||| ------------------------------------------------------------------
||| absolute-longword function table (hunk2+0)
||| ------------------------------------------------------------------
_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_LibNull		| LVO -24 (reserved -> entry stub)
	.long	_QOpen			| LVO -30
	.long	_QClose			| LVO -36
	.long	_QAddMsg		| LVO -42
	.long	_QRemMsg		| LVO -48
	.long	_QGetMsg		| LVO -54
	.long	_QReplyMsg		| LVO -60
	.long	_QFlush			| LVO -66
	.long	_QAllocMsg		| LVO -72
	.long	_QFreeMsg		| LVO -78
	.long	-1

_libname:				| hunk2+0x38
	.ascii	"queue.library"
	.byte	0,0,0			| pad to 0x48
_idstr:					| hunk2+0x48
	.ascii	"queue.library 3.1"
	.byte	0
	.byte	0x23,0x24		| "#$" tail bytes (hunk2+0x5a)
