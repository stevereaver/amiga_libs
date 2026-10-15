| mhimdev.library 1.5 (04.03.2023) - Michael Henke
| MHI driver library wrapping mpeg.device
| byte-exact transcription of the single CODE hunk

	.section .text

| ---- startup stub (returns -1 if run as a program) ----
	linkw	a5,#0
	moveq	#-1,d0
	unlk	a5
	rts

| ---- Resident tag @ 0x0a ----
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_inittab			| endskip
	.byte	0x80,1,9,0			| AUTOINIT, ver 1, NT_LIBRARY, pri 0
	.long	_libname
	.long	_idstr
	.long	_inittab

_idstr:	.ascii	"mhimdev.library 1.5 (04.03.2023)\0"
_libname:
	.ascii	"mhimdev.library\0"
	.byte	0

| ---- vec -24: null (returns 0) @ 0x56 ----
_vec24:
	linkw	a5,#0
	moveq	#0,d0
	unlk	a5
	rts

| ---- vec -6: Open @ 0x60 ----
_vec6:
	linkw	a5,#0
	movel	a6,sp@-
	andib	#0xf7,a6@(14)
	addqw	#1,a6@(32)
	movel	a6,d0
	moveal	sp@+,a6
	unlk	a5
	rts

| ---- vec -18: Expunge @ 0x78 ----
_vec18:
	linkw	a5,#0
	moveml	d2/a2-a3/a6,sp@-
	moveal	a6,a3
	tstw	a3@(32)
	beqs	.Lexp
	orib	#8,a3@(14)
	moveq	#0,d0
	bras	.Lexp_ret
.Lexp:	moveal	a3@(38),a2
	movel	a3@(34),d2
	moveal	a2,a6
	moveal	a3,a1
	jsr	a2@(-252)			| Remove
	clrl	d1
	movew	a3@(16),d1
	clrl	d0
	movew	a3@(18),d0
	addl	d1,d0
	moveal	a3,a1
	subal	d1,a1
	jsr	a2@(-210)			| FreeMem
	movel	d2,d0
.Lexp_ret:
	moveml	a5@(-16),d2/a2-a3/a6
	unlk	a5
	rts

| ---- vec -12: Close @ 0xc4 ----
_vec12:
	linkw	a5,#0
	movel	a6,sp@-
	subqw	#1,a6@(32)
	bnes	.Lcl_ret
	btst	#3,a6@(14)
	beqs	.Lcl_ret
	bsrs	_vec18
	bras	.Lcl_out
.Lcl_ret:
	moveq	#0,d0
.Lcl_out:
	moveal	a5@(-4),a6
	unlk	a5
	rts

| ---- initfn @ 0xe6: store seglist + sysbase ----
_initfn:
	linkw	a5,#0
	movel	a6,sp@-
	moveal	d0,a1
	movel	a0,a1@(34)
	movel	a6,a1@(38)
	moveal	sp@+,a6
	unlk	a5
	rts

| ---- function table @ 0xfc ----
_functab:
	.long	_vec6
	.long	_vec12
	.long	_vec18
	.long	_vec24
	.long	_vec30
	.long	_vec36
	.long	_vec42
	.long	_vec48
	.long	_vec54
	.long	_vec60
	.long	_vec66
	.long	_vec72
	.long	_vec78
	.long	_vec84
	.long	0xffffffff

| ---- InitStruct data table @ 0x138 ----
| nibble: 8=long, 9=word, a=byte(high byte of data word), 0=end
_datatab:
	.short	0xa008,0x0900			| byte@8 = 9 (ln_Type)
	.short	0x800a
	.long	_libname			| long@10 = name
	.short	0xa00e,0x0600			| byte@14 = 6 (lib_Flags)
	.short	0x9014,0x0001			| word@20 = 1 (version)
	.short	0x9016,0x0005			| word@22 = 5 (revision)
	.short	0x8018
	.long	_idstr				| long@24 = idstring
	.short	0x0000,0x0000			| end + pad

| ---- InitTable @ 0x158 ----
_inittab:
	.long	0x2a				| dataSize
	.long	_functab
	.long	_datatab
	.long	_initfn

_dosstr:
	.ascii	"dos.library\0"
_mhivar:
	.ascii	"MHIMDEV\0"
_argtmpl:
	.ascii	"DEVICE,UNIT/N\0"

| ---- vec -30: open/alloc driver @ 0x18a ----
|   in: a0 = task to signal, d0 = signal mask
|   out: d0 = driver handle (a3) or 0
_vec30:
	linkw	a5,#-16
	moveml	d2-d6/a2-a4/a6,sp@-
	movel	a0,d2				| task
	movel	d0,d3				| sigmask
	moveal	a6@(38),a4			| sysbase
	tstl	d2
	beqw	.Lv30_null
	moveal	a4,a6
	movel	#65537,d1			| MEMF_PUBLIC|MEMF_CLEAR
	movel	#348,d0
	jsr	a4@(-684)			| AllocVec
	moveal	d0,a3
	cmpaw	#0,a3
	beqw	.Lv30_null
	movel	a4,a3@(344)			| sysbase
	movel	d2,a3@(298)			| task
	movel	d3,a3@(302)			| sigmask
	moveb	#1,a3@(257)			| state = 1
	moveq	#100,d0
	movel	d0,a3@(332)			| volume = 100
	moveq	#50,d0
	movel	d0,a3@(336)			| balance = 50
	clrl	a3@(328)			| pending = 0
	pea	a3@(270)
	lea	_newlist:l,a2
	jsr	a2@				| NewList freelist
	pea	a3@(284)
	jsr	a2@				| NewList donelist
	clrl	a5@(-16)			| args[0..3]
	clrl	a5@(-12)
	clrl	a5@(-8)
	clrl	a5@(-4)
	moveal	a4,a6
	moveq	#37,d0
	lea	_dosstr:l,a1
	jsr	a4@(-552)			| OldOpenLibrary("dos.library")
	movel	d0,d5				| d5 = dosbase
	addql	#8,sp
	beqw	.Lv30_mkport			| no dos -> skip arg parsing
	movel	#65537,d1
	movel	#1024,d0
	jsr	a4@(-684)			| AllocVec -> d6 buf
	movel	d0,d6
	beqw	.Lv30_closedos
	moveal	d5,a6
	moveq	#0,d4
	movel	#1024,d3
	movel	d6,d2
	movel	#_mhivar,d1
	lea	a6@(-906),a0
	jsr	a0@				| GetVar("MHIMDEV",buf,1024,0)
	movel	d0,d3
	bles	.Lv30_freebuf
	movel	a5,d2
	subql	#8,d2				| d2 = a5-8 (RDArgs tags)
	moveq	#5,d1				| DOS_RDARGS
	lea	a6@(-228),a1
	jsr	a1@				| AllocDosObject(5,a5-8)
	moveal	d0,a2
	cmpaw	#0,a2
	beqs	.Lv30_freebuf
	movel	d6,a2@				| rda buf
	movel	d3,a2@(4)			| bufsize
	movel	d4,a2@(8)
	moveq	#4,d0
	movel	d0,a2@(28)
	movel	d4,a2@(12)
	movel	a2,d3
	moveq	#-16,d2
	addl	a5,d2				| d2 = a5-16 arg array
	movel	#_argtmpl,d1
	lea	a6@(-798),a0
	jsr	a0@				| ReadArgs("DEVICE,UNIT/N",args,rdargs)
	movel	d0,d2
	tstl	a5@(-16)			| DEVICE arg
	beqs	.Lv30_unit
	moveal	a4,a6
	moveq	#0,d0
	notb	d0				| d0 = 255
	lea	a3@(1),a1			| dst = devname buf
	moveal	a5@(-16),a0			| src = arg0 string
	jsr	a4@(-624)			| CopyMem(...,255)
.Lv30_unit:
	lea	a5@(-16),a0
	tstl	a0@(4)				| UNIT arg
	beqs	.Lv30_freeargs
	moveal	a0@(4),a0
	moveb	a0@(3),a3@			| unit = unitstr[3]
.Lv30_freeargs:
	moveal	d5,a6
	movel	d2,d1
	lea	a6@(-858),a1
	jsr	a1@				| FreeArgs
	movel	a2,d2
	moveq	#5,d1
	lea	a6@(-234),a0
	jsr	a0@				| FreeDosObject
.Lv30_freebuf:
	moveal	a4,a6
	moveal	d6,a1
	jsr	a4@(-690)			| FreeVec buf
.Lv30_closedos:
	moveal	a4,a6
	moveal	d5,a1
	jsr	a4@(-414)			| CloseLibrary dos
.Lv30_mkport:
	lea	a4@(-666),a2			| a2 = CreateMsgPort
	moveal	a4,a6
	jsr	a2@
	moveal	d0,a0
	movel	a0,a3@(258)			| port1
	beqw	.Lv30_fa3
	movel	a3,a3@(320)			| intr.is_Data = a3
	movel	#_sofint,a3@(324)		| intr.is_Code
	lea	a3@(306),a1
	movel	a1,a0@(16)			| port1.mp_SigTask = &intr
	moveal	a3@(258),a0
	moveb	#1,a0@(14)			| mp_Flags = PA_SOFTINT
	jsr	a2@				| CreateMsgPort
	movel	d0,d1
	movel	d1,a3@(262)			| port2
	beqw	.Lv30_fp1
	moveq	#86,d0
	moveal	d1,a0
	jsr	a4@(-654)			| CreateIORequest(port2,86)
	movel	d0,a3@(266)			| ioreq1
	beqs	.Lv30_fp2
	moveq	#1,d1
	moveq	#86,d0
	jsr	a4@(-198)			| AllocMem(86,CLEAR)
	movel	d0,a3@(340)			| ioreq2
	beqs	.Lv30_fio
	moveq	#0,d0
	moveal	a3,a0
	moveb	a0@+,d0				| d0 = unit
	moveq	#0,d1
	moveal	a3@(266),a1
	jsr	a4@(-444)			| OpenDevice(devname,unit,ioreq1,0)
	tstb	d0
	bnes	.Lv30_fmem
	moveq	#86,d0
	moveal	a3@(340),a1
	moveal	a3@(266),a0
	jsr	a4@(-624)			| CopyMem(ioreq1->ioreq2,86)
	moveal	a3@(340),a0
	movew	#9,a0@(28)			| ioreq2.cmd = 9
	moveal	a3@(340),a0
	clrb	a0@(30)
	moveal	a3@(340),a0
	moveb	#2,a0@(51)
	pea	0x1:w
	movel	a3@(266),sp@-
	movel	a4,sp@-
	bsrw	_sendcmd			| sendcmd(sysbase,ioreq1,1=CMD_RESET)
	movel	a3,d0
	bras	.Lv30_out
| --- cascading fail path ---
.Lv30_fmem:
	moveal	a4,a6
	moveq	#86,d0
	moveal	a3@(340),a1
	jsr	a4@(-210)			| FreeMem ioreq2
.Lv30_fio:
	moveal	a4,a6
	moveal	a3@(266),a0
	jsr	a4@(-660)			| DeleteIORequest
.Lv30_fp2:
	moveal	a4,a6
	moveal	a3@(262),a0
	jsr	a4@(-672)			| DeleteMsgPort port2
.Lv30_fp1:
	moveal	a4,a6
	moveal	a3@(258),a0
	jsr	a4@(-672)			| DeleteMsgPort port1
.Lv30_fa3:
	moveal	a4,a6
	moveal	a3,a1
	jsr	a4@(-690)			| FreeVec a3
.Lv30_null:
	moveq	#0,d0
.Lv30_out:
	moveml	a5@(-52),d2-d6/a2-a4/a6
	unlk	a5
	rts

| ---- vec -36: free driver @ 0x3b8 ----  (a3 = handle)
_vec36:
	linkw	a5,#0
	moveml	d2/a2-a4/a6,sp@-
	movel	a3,d2
	moveal	a6@(38),a4
	beqs	.Lv36_out
	bsrw	_vec66				| stop/drain first
	bras	.Lv36_drain
.Lv36_free:
	moveal	a4,a6
	moveq	#86,d0
	moveal	d1,a1
	jsr	a4@(-210)			| FreeMem node
.Lv36_drain:
	moveal	a4,a6
	moveal	d2,a0
	lea	a0@(270),a0
	jsr	a4@(-258)			| RemHead freelist
	movel	d0,d1
	bnes	.Lv36_free
	moveal	d2,a0
	moveal	a0@(266),a1
	jsr	a4@(-450)			| CloseDevice(ioreq1)
	moveq	#86,d0
	moveal	d2,a0
	moveal	a0@(340),a1
	jsr	a4@(-210)			| FreeMem ioreq2
	moveal	d2,a1
	moveal	a1@(266),a0
	jsr	a4@(-660)			| DeleteIORequest
	lea	a4@(-672),a2
	moveal	d2,a1
	moveal	a1@(262),a0
	jsr	a2@				| DeleteMsgPort port2
	moveal	d2,a1
	moveal	a1@(258),a0
	jsr	a2@				| DeleteMsgPort port1
	moveal	d2,a1
	jsr	a4@(-690)			| FreeVec a3
.Lv36_out:
	moveml	a5@(-20),d2/a2-a4/a6
	unlk	a5
	rts

| ---- vec -42: queue write buffer @ 0x42c ----  (a3=handle, a0=buf, d0=len)
_vec42:
	linkw	a5,#0
	moveml	d2-d4/a2-a4/a6,sp@-
	movel	a0,d3				| buf
	movel	d0,d4				| len
	moveal	a3,a4				| a4 = handle
	moveal	a6@(38),a3			| a3 = sysbase
	cmpaw	#0,a4
	beqs	.Lv42_fail
	tstl	d3
	beqs	.Lv42_fail
	tstl	d4
	beqs	.Lv42_fail
	moveal	a3,a6
	lea	a4@(270),a0
	jsr	a3@(-258)			| RemHead freelist
	moveal	d0,a2
	cmpaw	#0,a2
	bnes	.Lv42_send
	clrw	d2
.Lv42_alloc:
	moveal	a3,a6
	moveq	#1,d1
	moveq	#86,d0
	jsr	a3@(-198)			| AllocMem(86,CLEAR)
	moveal	d0,a2
	cmpaw	#0,a2
	beqs	.Lv42_next
	moveal	a2,a1
	lea	a4@(270),a0
	jsr	a3@(-246)			| AddTail freelist
.Lv42_next:
	addqw	#1,d2
	cmpiw	#31,d2
	blss	.Lv42_alloc
	moveal	a3,a6
	lea	a4@(270),a0
	jsr	a3@(-258)			| RemHead freelist
	moveal	d0,a2
	cmpaw	#0,a2
	bnes	.Lv42_send
.Lv42_fail:
	moveq	#0,d0
	bras	.Lv42_out
.Lv42_send:
	moveal	a3,a6
	moveq	#86,d0
	moveal	a2,a1
	moveal	a4@(266),a0
	jsr	a3@(-624)			| CopyMem(ioreq1->node,86)
	movel	a4@(258),a2@(14)		| mn_ReplyPort = port1
	movew	#3,a2@(28)			| io_Command = 3 (CMD_WRITE)
	movel	d3,a2@(40)			| io_Data = buf
	movel	d4,a2@(36)			| io_Length = len
	clrb	a2@(30)				| io_Flags = 0
	moveb	#2,a2@(51)
	clrl	a2@(52)
	addql	#1,a4@(328)			| pending++
	moveal	a2,a1
	jsr	a3@(-462)			| SendIO
	moveq	#1,d0
.Lv42_out:
	moveml	a5@(-28),d2-d4/a2-a4/a6
	unlk	a5
	rts

| ---- vec -48: get completed buffer @ 0x4e0 ----  (a3=handle) -> d0 buf
_vec48:
	linkw	a5,#0
	moveml	d2/a2-a3/a6,sp@-
	movel	a3,d2
	moveal	a6@(38),a2
	beqs	.Lv48_null
	moveal	a2,a6
	jsr	a2@(-120)			| Disable
	moveal	d2,a0
	lea	a0@(284),a0
	jsr	a2@(-258)			| RemHead donelist
	moveal	d0,a3
	jsr	a2@(-126)			| Enable
	cmpaw	#0,a3
	beqs	.Lv48_null
	moveal	a3,a1
	moveal	d2,a0
	lea	a0@(270),a0
	jsr	a2@(-246)			| AddTail freelist (recycle)
	movel	a3@(40),d0			| return io_Data
	bras	.Lv48_out
.Lv48_null:
	moveq	#0,d0
.Lv48_out:
	moveml	a5@(-16),d2/a2-a3/a6
	unlk	a5
	rts

| ---- vec -54: status @ 0x52a ----  (a3=handle) -> d0
_vec54:
	linkw	a5,#0
	movel	a3,sp@-
	cmpaw	#0,a3
	bnes	.Lv54_chk
	moveq	#1,d0
	bras	.Lv54_out
.Lv54_chk:
	tstl	a3@(328)			| pending
	bgts	.Lv54_state
	moveq	#2,d0
	tstb	a3@(257)
	beqs	.Lv54_out
.Lv54_state:
	clrl	d0
	moveb	a3@(257),d0
.Lv54_out:
	moveal	sp@+,a3
	unlk	a5
	rts

| ---- vec -60: start/resume @ 0x554 ----  (a3=handle)
_vec60:
	linkw	a5,#0
	movel	a6,sp@-
	movel	a3,sp@-
	moveal	a6@(38),a0
	cmpaw	#0,a3
	beqs	.Lv60_out
	cmpib	#3,a3@(257)
	bnes	.Lv60_send
	bsrw	_vec72				| paused -> unpause
	bras	.Lv60_out
.Lv60_send:
	moveal	a0,a6
	moveal	a3@(340),a1
	jsr	a0@(-462)			| SendIO(ioreq2)
	clrb	a3@(257)			| state = 0
.Lv60_out:
	moveal	a5@(-8),a3
	moveal	a5@(-4),a6
	unlk	a5
	rts

| ---- vec -66: stop/drain @ 0x58e ----  (a3=handle)
_vec66:
	linkw	a5,#0
	moveml	a2-a3/a6,sp@-
	moveal	a6@(38),a2
	cmpaw	#0,a3
	beqw	.Lv66_out
	cmpib	#1,a3@(257)
	beqs	.Lv66_dis
	moveal	a2,a6
	moveal	a3@(340),a1
	jsr	a2@(-480)			| AbortIO(ioreq2)
	moveal	a3@(340),a1
	jsr	a2@(-474)			| WaitIO(ioreq2)
.Lv66_dis:
	moveal	a2,a6
	jsr	a2@(-120)			| Disable
	moveal	a3@(258),a0
	moveb	#2,a0@(14)			| port1 mp_Flags = PA_IGNORE
	jsr	a2@(-126)			| Enable
	bras	.Lv66_chkd
.Lv66_mv:
	moveal	a2,a6
	moveal	d0,a1
	lea	a3@(270),a0
	jsr	a2@(-246)			| AddTail freelist
.Lv66_chkd:
	moveal	a2,a6
	lea	a3@(284),a0
	jsr	a2@(-258)			| RemHead donelist
	tstl	d0
	bnes	.Lv66_mv
	tstl	a3@(328)			| pending
	beqs	.Lv66_done
	pea	0x8:w
	movel	a3@(266),sp@-
	movel	a2,sp@-
	bsrw	_sendcmd			| sendcmd(sysbase,ioreq1,8=CMD_FLUSH)
	lea	sp@(12),sp
	bras	.Lv66_drain
.Lv66_mv2:
	moveal	a2,a6
	moveal	d0,a1
	lea	a3@(270),a0
	jsr	a2@(-246)			| AddTail freelist
.Lv66_drain:
	moveal	a2,a6
	moveal	a3@(258),a0
	jsr	a2@(-372)			| GetMsg port1
	tstl	d0
	bnes	.Lv66_mv2
	clrl	a3@(328)			| pending = 0
.Lv66_done:
	moveal	a3@(258),a0
	moveb	#1,a0@(14)			| mp_Flags = PA_SOFTINT
	moveb	#1,a3@(257)			| state = 1
.Lv66_out:
	moveml	a5@(-12),a2-a3/a6
	unlk	a5
	rts

| ---- vec -72: pause toggle @ 0x63e ----  (a3=handle)
_vec72:
	linkw	a5,#0
	movel	a6,sp@-
	movel	a3,sp@-
	movel	a6@(38),d0
	cmpaw	#0,a3
	beqs	.Lv72_out
	tstb	a3@(257)
	bnes	.Lv72_unp
	moveal	a3@(266),a0
	moveq	#1,d1
	movel	d1,a0@(56)			| ioreq1+56 = 1 (pause flag)
	moveb	#3,a3@(257)			| state = 3 (paused)
	bras	.Lv72_cmd
.Lv72_unp:
	cmpib	#3,a3@(257)
	bnes	.Lv72_out
	moveal	a3@(266),a0
	clrl	a0@(56)				| ioreq1+56 = 0
	clrb	a3@(257)			| state = 0
.Lv72_cmd:
	pea	0xa:w
	movel	a3@(266),sp@-
	movel	d0,sp@-
	bsrw	_sendcmd			| sendcmd(sysbase,ioreq1,10)
.Lv72_out:
	moveal	a5@(-8),a3
	moveal	a5@(-4),a6
	unlk	a5
	rts

| ---- strings for Query @ 0x696 ----
_s_desc:
	.ascii	"MHI driver for mpeg.device\0"
_s_idstr:
	.ascii	"mhimdev.library 1.5 (04.03.2023)\0"
_s_author:
	.ascii	"Michael Henke\0"

| ---- vec -78: query @ 0x6e0 ----  (d1 = code) -> d0
_vec78:
	linkw	a5,#0
	moveq	#21,d0
	cmpl	d1,d0
	bcss	.Lv78_big			| d1 > 21
	moveq	#20,d0
	cmpl	d1,d0
	blss	.Lv78_one			| d1 in {20,21} -> ret 1
	moveq	#1,d0
	cmpl	d1,d0
	bhis	.Lv78_zero			| d1 <= 1 -> ret 0
	moveq	#3,d0
	cmpl	d1,d0
	bccs	.Lv78_one			| d1 <= 3 -> ret 1
	moveq	#12,d0
	cmpl	d1,d0
	bcss	.Lv78_zero			| d1 > 12 -> ret 0
	moveq	#10,d0
	bras	.Lv78_cmp
.Lv78_big:
	cmpil	#1000,d1
	beqs	.Lv78_desc
	bhis	.Lv78_gt1000
	moveq	#41,d0
	cmpl	d1,d0
	bcss	.Lv78_zero			| d1 > 41 -> ret 0
	moveq	#40,d0
.Lv78_cmp:
	cmpl	d1,d0
	bhis	.Lv78_zero			| d1 <= d0 -> ret 0
	bras	.Lv78_one			| else ret 1
.Lv78_gt1000:
	cmpil	#1002,d1
	beqs	.Lv78_auth
	bcss	.Lv78_name			| d1 == 1001
	cmpil	#1010,d1
	beqs	.Lv78_one			| d1 == 1010 -> ret 1
	bras	.Lv78_zero
.Lv78_desc:
	movel	#_s_desc,d0			| 1000 -> description
	bras	.Lv78_out
.Lv78_name:
	movel	#_s_idstr,d0			| 1001 -> id string
	bras	.Lv78_out
.Lv78_auth:
	movel	#_s_author,d0			| 1002 -> author
	bras	.Lv78_out
.Lv78_one:
	moveq	#1,d0
	bras	.Lv78_out
.Lv78_zero:
	moveq	#0,d0
.Lv78_out:
	unlk	a5
	rts

| ---- vec -84: set volume/balance @ 0x754 ----  (a3=handle, d0=chan, d1=val)
_vec84:
	linkw	a5,#-8
	moveml	d2/a3/a6,sp@-
	movew	d0,d2
	moveal	a6@(38),a6			| a6 = sysbase
	cmpaw	#0,a3
	beqw	.Lv84_out
	tstw	d0
	bnes	.Lv84_bal
	movel	d1,d0				| chan 0: volume
	moveq	#100,d2
	cmpl	d1,d2
	bccs	.Lv84_vol
	moveq	#100,d0
.Lv84_vol:
	movel	d0,a3@(332)
	bras	.Lv84_send
.Lv84_bal:
	cmpiw	#1,d2
	bnew	.Lv84_out
	moveq	#100,d0				| chan 1: balance
	cmpl	d1,d0
	bccs	.Lv84_bset
	moveq	#100,d1
.Lv84_bset:
	movel	d1,a3@(336)
.Lv84_send:
	movel	a3@(332),d1			| d1 = volume
	movel	d1,d0
	swap	d0
	clrw	d0				| d0 = vol<<16
	movel	d0,d2
	subl	d1,d2				| d2 = vol*65535
	moveq	#50,d1
	cmpl	a3@(336),d1			| 50 vs balance
	bccs	.Lv84_flat
	moveq	#100,d0
	subl	a3@(336),d0			| 100 - balance
	movel	d0,sp@-
	movel	d2,sp@-
	jsr	_mul:l				| d2*(100-bal)
	addqw	#4,sp
	movel	#5000,sp@
	movel	d0,sp@-
	bras	.Lv84_dv
.Lv84_flat:
	pea	0x64:w
	movel	d2,sp@-
.Lv84_dv:
	jsr	_div:l				| /(100-bal or 100)
	addql	#8,sp
	movew	d0,a5@(-6)			| left vol
	movel	a3@(336),d0
	moveq	#50,d1
	cmpl	d0,d1
	bccs	.Lv84_r
	moveq	#50,d0				| min(bal,50)
.Lv84_r:
	movel	d0,sp@-
	movel	d2,sp@-
	jsr	_mul:l				| d2*min(bal,50)
	addqw	#4,sp
	movel	#5000,sp@
	movel	d0,sp@-
	jsr	_div:l				| /5000
	addql	#8,sp
	movew	d0,a5@(-4)			| right vol
	movew	#-1,a5@(-2)			| terminator
	moveal	a3@(266),a0
	lea	a5@(-6),a1
	movel	a1,a0@(40)			| io_Data = &volumes
	moveal	a3@(266),a0
	moveq	#6,d0
	movel	d0,a0@(36)			| io_Length = 6
	pea	0x14:w
	movel	a3@(266),sp@-
	movel	a6,sp@-
	bsrs	_sendcmd			| sendcmd(sysbase,ioreq1,20)
.Lv84_out:
	moveml	a5@(-20),d2/a3/a6
	unlk	a5
	rts

| ---- sendcmd helper @ 0x834: (sysbase, ioreq, cmd) ----
_sendcmd:
	linkw	a5,#0
	movel	a6,sp@-
	moveal	a5@(8),a0			| sysbase
	moveal	a5@(12),a1			| ioreq
	movew	a5@(18),a1@(28)			| io_Command = cmd
	clrb	a1@(30)				| io_Flags = 0
	moveb	#2,a1@(51)
	moveal	a0,a6
	jsr	a0@(-456)			| DoIO
	moveal	a5@(-4),a6
	unlk	a5
	rts

| ---- softint handler @ 0x860 ----
|   is_Data(a1) = handle: moves replied msgs to donelist, signals task
_sofint:
	linkw	a5,#0
	moveml	a2-a3/a6,sp@-
	moveal	a1,a3				| a3 = handle
	moveal	a3@(344),a2			| sysbase
	bras	.Lsi_next
.Lsi_mv:
	moveal	a2,a6
	moveal	d0,a1
	lea	a3@(284),a0
	jsr	a2@(-246)			| AddTail donelist
	subql	#1,a3@(328)			| pending--
.Lsi_next:
	moveal	a2,a6
	moveal	a3@(258),a0
	jsr	a2@(-372)			| GetMsg port1
	tstl	d0
	bnes	.Lsi_mv
	movel	a3@(302),d0			| sigmask
	moveal	a3@(298),a1			| task
	jsr	a2@(-324)			| Signal(task,mask)
	moveml	a5@(-12),a2-a3/a6
	unlk	a5
	rts

| ---- NewList helper @ 0x8a4: list ptr on stack ----
_newlist:
	moveal	sp@(4),a0
	clrl	a0@(4)
	movel	a0,a0@(8)
	addql	#4,a0
	movel	a0,a0@-
	rts
	.short	0				| pad @ 0x8b6

| ---- __mulsi3 @ 0x8b8: (d0 * d1) stack args -> d0 ----
_mul:
	moveml	sp@(4),d0-d1
	moveml	d2-d3,sp@-
	movel	d0,d3
	muluw	d1,d0
	movel	d1,d2
	swap	d2
	muluw	d3,d2
	swap	d3
	muluw	d1,d3
	addl	d2,d3
	swap	d3
	clrw	d3
	addl	d3,d0
	moveml	sp@+,d2-d3
	rts
	nop

| ---- __udivmodsi4 @ 0x8e0: stack args -> d0=quot d1=rem ----
|   internal register-arg entry at 0x8e6 (called by the signed wrapper)
_div:
	moveml	sp@(4),d0-d1
_divreg:
	swap	d1
	tstw	d1
	bnes	.Lud_big			| divisor > 16 bits
	swap	d1
	moveml	d2-d3,sp@-
	movew	d1,d3
	movew	d0,d2
	clrw	d0
	swap	d0
	divuw	d3,d0
	movel	d0,d1
	swap	d0
	movew	d2,d1
	divuw	d3,d1
	movew	d1,d0
	clrw	d1
	swap	d1
	moveml	sp@+,d2-d3
	rts
.Lud_big:
	swap	d1
	moveml	d2-d4,sp@-
	moveq	#31,d2
	moveq	#0,d3
	moveq	#0,d4
.Lud_loop:
	addl	d3,d3
	addl	d0,d0
	roxll	#1,d4
	cmpl	d1,d4
	bcss	.Lud_skip
	subl	d1,d4
	addql	#1,d3
.Lud_skip:
	dbf	d2,.Lud_loop
	movel	d4,d1
	movel	d3,d0
	moveml	sp@+,d2-d4
	rts

| ---- __divmodsi4 signed wrapper @ 0x938 ----
	moveml	sp@(4),d0-d1
	tstl	d0
	bmis	.Lsd_neg
	tstl	d1
	bpls	_divreg			| both positive
	negl	d1
	bsrs	_divreg
	negl	d0
	rts
.Lsd_neg:
	negl	d0
	tstl	d1
	bpls	.Lsd_np
	negl	d1
	bsrs	_divreg
	negl	d1
	rts
.Lsd_np:
	bsrs	_divreg
	negl	d0
	negl	d1
	rts

| ---- tail data @ 0x964 ----
	.long	0
	.long	1
