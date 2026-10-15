|||
|||	asdg_h0.s -- byte-verbatim reconstruction of
|||	asdg-low-mem.library (10-Jun-87), by Perry S. Kivolowitz
|||	(ASDG Inc., 1987).
|||
|||	Single CODE hunk, 0x2ec bytes: entry stub, RomTag
|||	(ver 0, pri 0), 24-bit-offset InitStruct datatab, absolute
|||	longword function table, AUTOINIT InitTable (dataSize
|||	0x3c), name/id/copyright strings, then the code.
|||
|||	The hunk FILE is unusual: the hunk table declares three
|||	hunks (CODE 0xbb words, then two empty hunks) and the
|||	stream carries an empty DATA hunk and an empty BSS hunk
|||	after the CODE hunk.  fixup.py rewrites the linked
|||	single-hunk output into that shape.
|||
|||	Quirks: Open keeps the exec lib_OpenCnt (+0x20) cleared and
|||	bumps a private count at +0x38; Close at count 0 expunges
|||	immediately (no deferred-expunge flag is consulted); the
|||	-18 "LibExpunge" vector is not an expunge at all but the
|||	low-memory alert trigger that re-PutMsg()es every
|||	registered message whose lm_flag is still 'ASDG'; -24 is
|||	the module entry stub; -42 (LMSQuery) always returns 1.
|||

	.section .text

||| executable-entry stub: non-resident loaders get a clean 0
_module_entry:
	clr.l	d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP (module end)
	.byte	0x80			| RTF_AUTOINIT
	.byte	0			| RT_VERSION = 0
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI = 0
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitStruct datatab: 24-bit-offset command form
||| (0xc0 long / 0xd0 word / 0xe0 byte), word-aligned cells.
_datatab:
	.byte	0xe0,0x00,0x00,0x08	| INITBYTE off16 @ 8  (ln_Type)
	.byte	0x09,0x00		|   = NT_LIBRARY, pad
	.byte	0xc0,0x00,0x00,0x0a	| INITLONG off16 @ 10 (ln_Name)
	.long	_libname
	.byte	0xe0,0x00,0x00,0x0e	| INITBYTE off16 @ 14 (lib_Flags)
	.byte	0x06,0x00		|   = LIBF_SUMUSED|LIBF_CHANGED, pad
	.byte	0xd0,0x00,0x00,0x14	| INITWORD off16 @ 20 (lib_Version)
	.word	0
	.byte	0xd0,0x00,0x00,0x16	| INITWORD off16 @ 22 (lib_Revision)
	.word	0
	.byte	0xc0,0x00,0x00,0x18	| INITLONG off16 @ 24 (lib_IdString)
	.long	_idstr
	.long	0			| terminator + pad

||| Function table: absolute longwords, -1L terminated.
_functab:
	.long	_LibOpen		| LVO  -6
	.long	_LibClose		| LVO -12 (falls into expunge at cnt 0)
	.long	_LibExpunge		| LVO -18 (alert trigger, not an expunge)
	.long	_module_entry		| LVO -24 (module entry stub)
	.long	_RegLowMemReq		| LVO -30
	.long	_DeRegLowMemReq		| LVO -36
	.long	_LMSQuery		| LVO -42
	.long	-1

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x3c			| sizeof(struct LowMemBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

_libname:
	.ascii	"asdg-low-mem.library"
	.byte	0
_idstr:
	.ascii	"asdg low memory alert server (10-Jun-87)"
	.byte	0xd,0xa,0
||| copyright strings embedded in the code hunk (unreferenced)
	.ascii	"Copyright 1987 By ASDG Incorporated"
	.byte	0xd,0xa,0
	.ascii	"Perry S. Kivolowitz"
	.byte	0xd,0xa,0

||| LibInit: SysBase->+0x22, SegList->+0x26, NewList at +0x2a.
_LibInit:
	moveml	a1-a2,sp@-
	moveal	d0,a1
	movel	a6,a1@(34)
	movel	a0,a1@(38)
	lea	a1@(46),a2
	movel	a2,a1@(42)		| lh_Head = &lh_Tail
	clrl	a1@(46)			| lh_Tail = NULL
	lea	a1@(42),a2
	movel	a2,a1@(50)		| lh_TailPred = &lh_Head
	moveml	sp@+,a1-a2
	rts

||| LVO -6 LibOpen: private count at +0x38, lib_OpenCnt stays 0.
_LibOpen:
	addqw	#1,a6@(56)
	clrw	a6@(32)
	movel	a6,d0
	rts

||| LVO -12 LibClose: private count--; at 0 the code falls
||| straight through into the expunge body (no deferred flag).
_LibClose:
	subqw	#1,a6@(56)
	beqs	_expunge_body
	clrl	d0
	rts

||| shared expunge body: Remove(lib), drain the registration
||| list, FreeMem the base region, return the seglist.
_expunge_body:
	moveml	d2/a5-a6,sp@-
	movel	a6@(38),d2		| seglist
	moveal	a6,a5
	moveal	a6@(34),a6		| SysBase
	moveal	a5,a1
	jsr	a6@(-252)		| Remove
	bsrs	_clearall
	moveal	a5,a1
	clrl	d0
	movew	a5@(16),d0		| lib_NegSize
	subal	d0,a1
	addw	a5@(18),d0		| + lib_PosSize
	moveal	a5@(34),a6
	jsr	a6@(-210)		| FreeMem
	movel	d2,d0
	moveml	sp@+,d2/a5-a6
	rts

||| _clearall: RemHead every node off the +0x2a list and
||| _freenode() it.
_clearall:
	moveml	d0/a0,sp@-
_cal_loop:
	moveal	a5@(34),a6
	lea	a5@(42),a0
	jsr	a6@(-258)		| RemHead
	tstl	d0
	beqs	_cal_done
	bsrw	_freenode
	bras	_cal_loop
_cal_done:
	moveml	sp@+,d0/a0
	rts

||| LVO -18 "LibExpunge": the low-memory alert trigger.  For
||| each registered node, FindPort the port name; if found and
||| the message's lm_flag (+0x14) still reads 'ASDG', clear the
||| flag, re-init the Message fields (ln_Type=NT_REPLYMSG,
||| reply port NULL, pri 0, length 4) and PutMsg it.
_LibExpunge:
	moveml	a0-a1/a4-a6,sp@-
	moveal	a6,a5
	moveal	a5@(42),a4		| lh_Head
_lex_loop:
	movel	a4,d0
	beqs	_lex_ret
	moveal	a4@(10),a1		| node.ln_Name (port name)
	moveal	a5@(34),a6
	jsr	a6@(-390)		| FindPort
	tstl	d0
	beqs	_lex_next
	moveal	d0,a0			| port
	moveal	a4@(14),a1		| node.msg
	cmpil	#0x41534447,a1@(20)	| lm_flag == 'ASDG'?
	bnes	_lex_next
	clrl	a1@(20)			| lm_flag = 0 (one-shot)
	moveb	#5,a1@(8)		| ln_Type = NT_REPLYMSG
	clrl	a1@(14)			| mn_ReplyPort = NULL
	clrb	a1@(9)			| ln_Pri = 0
	movew	#4,a1@(18)		| mn_Length = 4
	moveal	a5@(34),a6
	jsr	a6@(-366)		| PutMsg
_lex_next:
	moveal	a4@,a4			| ln_Succ
	bras	_lex_loop
_lex_ret:
	moveml	sp@+,a0-a1/a4-a6
	clrl	d0
	rts

||| LVO -30 RegLowMemReq(a0=portName, a1=LowMemMsg):
||| duplicate if the name is already on the list -> -1; AllocMem
||| failure -> -2; otherwise copy the name, build a 20-byte
||| node (ln_Name=copy, +0xe=msg, +0x12=nameLen) and AddHead.
_RegLowMemReq:
	moveml	d5/a0-a6,sp@-
	moveal	a0,a2			| name
	moveal	a1,a3			| msg
	moveal	a6,a5
	moveal	a5@(34),a6
	moveal	a0,a1
	lea	a5@(42),a0
	jsr	a6@(-276)		| FindName
	tstl	d0
	beqs	_reg_new
	moveq	#-1,d0			| already registered
	bras	_reg_out
_reg_new:
	moveal	a2,a0
	bsrw	_strlen			| d0 = strlen+1
	movel	d0,d5
	moveq	#0,d1
	moveal	a5@(34),a6
	jsr	a6@(-198)		| AllocMem (name copy)
	tstl	d0
	bnes	_reg_nameok
_reg_nomem:
	moveq	#-2,d0			| no memory (shared tail)
	bras	_reg_out
_reg_nameok:
	moveal	d0,a1
	moveal	a1,a4			| name copy
	moveal	a2,a0
	bsrw	_strcpy
	clrl	d1
	moveq	#20,d0
	moveal	a5@(34),a6
	jsr	a6@(-198)		| AllocMem (the node)
	tstl	d0
	bnes	_reg_nodeok
	moveal	a4,a1			| free the name copy
	movel	d5,d0
	moveal	a5@(34),a6
	jsr	a6@(-210)		| FreeMem
	bras	_reg_nomem
_reg_nodeok:
	moveal	d0,a1
	movel	a4,a1@(10)		| ln_Name = name copy
	movel	a3,a1@(14)		| node.msg
	movew	d5,a1@(18)		| node.nameLen
	clrb	a1@(8)			| ln_Type = 0
	clrb	a1@(9)			| ln_Pri = 0
	lea	a5@(42),a0
	moveal	a5@(34),a6
	jsr	a6@(-240)		| AddHead
	clrl	d0
_reg_out:
	moveml	sp@+,d5/a0-a6
	rts

||| LVO -36 DeRegLowMemReq(a0=portName): FindName the node,
||| Remove + _freenode it; return 0 either way.
_DeRegLowMemReq:
	moveml	a1/a4-a6,sp@-
	moveal	a6,a5
	moveal	a5@(34),a6
	moveal	a0,a1
	lea	a5@(42),a0
	jsr	a6@(-276)		| FindName
	tstl	d0
	beqs	_dreg_ret
	moveal	d0,a1
	moveal	a1,a4
	moveal	a5@(34),a6
	jsr	a6@(-252)		| Remove
	movel	a4,d0
	bsrs	_freenode
_dreg_ret:
	clrl	d0
	moveml	sp@+,a1/a4-a6
	rts

||| LVO -42 LMSQuery: undocumented probe, always returns 1.
_LMSQuery:
	moveq	#1,d0
	rts

||| _strlen(a0) -> d0 = strlen+1 (the allocation size).
_strlen:
	movel	a0,sp@-
	clrl	d0
_strl_loop:
	tstb	a0@+
	beqs	_strl_done
	addql	#1,d0
	bras	_strl_loop
_strl_done:
	moveal	sp@+,a0
	addql	#1,d0
	rts

||| _strcpy(a0=src, a1=dst)
_strcpy:
	moveml	a0-a1,sp@-
_strc_loop:
	moveb	a0@+,a1@+
	bnes	_strc_loop
	moveml	sp@+,a0-a1
	rts

||| _freenode(d0=node): FreeMem(node.name, node.nameLen) then
||| FreeMem(node, 20).
_freenode:
	moveml	d0/a1-a2/a5,sp@-
	moveal	d0,a2
	moveal	a2@(10),a1		| name copy
	clrl	d0
	movew	a2@(18),d0		| nameLen
	moveal	a5@(34),a6
	jsr	a6@(-210)		| FreeMem
	moveal	a2,a1
	moveq	#20,d0
	moveal	a5@(34),a6
	jsr	a6@(-210)		| FreeMem
	moveml	sp@+,d0/a1-a2/a5
	rts

	.globl	_endcode
_endcode:
