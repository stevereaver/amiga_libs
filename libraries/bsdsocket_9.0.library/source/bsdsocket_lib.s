|||
|||  bsdsocket.library 9.0 -- resident shell
|||  AUTOINIT, v9.  Functab in .text (absolute longs).
|||

	.section .text

	.globl	_start
_start:	moveq	#-1,d0
	rts

RomTag:	dc.w	0x4afc
	dc.l	RomTag
	dc.l	_endcode
	dc.b	0x80
	dc.b	9
	dc.b	9
	dc.b	0
	dc.l	_libname
	dc.l	_idstr
	dc.l	InitTable

	.globl	_libname
_libname:
	.ascii	"bsdsocket.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"bsdsocket.library 9.0"
	.byte	0

	.even
InitTable:
	dc.l	0xf6			| dataSize as shipped
	dc.l	FuncTable
	dc.l	DataTable
	dc.l	_LibInit

FuncTable:
	dc.l	LibOpen
	dc.l	LibClose
	dc.l	LibExpunge
	dc.l	LibNull
	dc.l	_socket		| -30
	dc.l	_bind		| -36
	dc.l	_listen		| -42
	dc.l	_accept		| -48
	dc.l	_connect	| -54
	dc.l	_sendto		| -60
	dc.l	_send		| -66
	dc.l	_recvfrom	| -72
	dc.l	_recv		| -78
	dc.l	_shutdown	| -84
	dc.l	_setsockopt	| -90
	dc.l	_getsockopt	| -96
	dc.l	_getsockname	| -102
	dc.l	_getpeername	| -108
	dc.l	_IoctlSocket	| -114
	dc.l	_CloseSocket	| -120
	dc.l	_WaitSelect	| -126
	dc.l	_SetSocketSignals | -132
	dc.l	_getdtablesize	| -138
	dc.l	_NoImpl		| -144 gethostid (stub -1)
	dc.l	_NoImpl		| -150 gethostname
	dc.l	_NoImpl		| -156 getdomainname
	dc.l	_SbGetField	| -162
	dc.l	_sethostname	| -168
	dc.l	_NoImpl		| -174 setdomainname?
	dc.l	_gethostname	| -180
	dc.l	_SyslogAp	| -186
	dc.l	_SetLogFunc	| -192
	dc.l	_Errno		| -198
	dc.l	_SetErrnoPtr	| -204
	dc.l	_Inet_NtoA	| -210
	dc.l	_inet_addr	| -216
	dc.l	_NoOpOk		| -222
	dc.l	_Inet_LtoOf	| -228
	dc.l	_Inet_OfToL	| -234
	dc.l	_Inet_MakeAddr	| -240
	dc.l	_inet_network	| -246
	dc.l	_inet_netof	| -252
	dc.l	_inet_lnaof	| -258
	dc.l	_inet_makeaddr	| -264
	dc.l	_Dup2Socket	| -270
	dc.l	_ObtainSocket	| -276
	dc.l	_ReleaseSocket	| -282
	dc.l	_ReleaseCopyOfSocket | -288
	dc.l	_NoOpOk		| -294
	dc.l	_Is_Localhost	| -300
	dc.l	_NoOpOk		| -306
	dc.w	0xffff,0xffff

DataTable:
	dc.w	0xe000,0x0008,0x0900
	dc.w	0xc000,0x000a
	dc.l	_libname
	dc.w	0xe000,0x000e,0x0600
	dc.w	0xd000,0x0014,0x0009
	dc.w	0xd000,0x0016,0x0000
	dc.w	0xc000,0x0018
	dc.l	_idstr
	dc.w	0,0

LibOpen:	addq.w	#1,0x20(a6)
		bclr	#3,14(a6)
		move.l	a6,d0
		rts
LibClose:	moveq	#0,d7
		subq.w	#1,0x20(a6)
		bne.s	1f
		btst	#3,14(a6)
		beq.s	1f
		bsr	LibExpunge
		move.l	d0,d7
1:		move.l	d7,d0
		rts
LibExpunge:	moveq	#0,d7
		bset	#3,14(a6)
		tst.w	0x20(a6)
		bne.s	2f
		movea.l	0x22(a6),a2
		move.l	a6,d1
		movea.l	a6,a1
		movea.l	4.w,a6
		jsr	-252(a6)
		movea.l	d1,a1
		move.w	16(a1),d0
		move.l	d1,a0
		sub.l	d0,a0
		move.l	a0,-(sp)
		movea.l	a2,a1
		movea.l	(sp)+,a0
		move.w	18(a6),d0
		jsr	-210(a6)
		move.l	a2,d7
2:		move.l	d7,d0
		rts
LibNull:	moveq	#0,d0
		rts

||| shared wire-message block (bss)
	.section .bss
	.globl	__MsgBlock
__MsgBlock:	ds.b	256
