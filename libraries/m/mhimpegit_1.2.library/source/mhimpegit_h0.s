|
|	mhimpegit_h0.s -- byte-verbatim reconstruction of
|	mhimpegit.library 1.2 (20.01.2017), 2200-byte two-hunk module.
|
|	Hunk 0 CODE (0x1a8 longs / 1696 bytes):
|	  0x000 moveq #-1,d0/rts        loader entry
|	  0x004 LibInit                 OpenLibrary(dos,0) +
|	                                MakeLibrary(data+0x56,dsize 42) +
|	                                hand-filled header + AddLibrary
|	  0x08e Open        LVO -6      OpenCnt++, clear flag3
|	  0x0a6 Close       LVO -12     OpenCnt--, deferred expunge
|	  0x0d8 Expunge     LVO -18
|	  0x13e stub        LVO -24     moveq#0/rts + nop
|	  0x144 Create      LVO -30
|	  0x1fc Destroy     LVO -36
|	  0x244 Append      LVO -42
|	  0x2ba Pop         LVO -48
|	  0x30a Query       LVO -54
|	  0x32e Iterate     LVO -60
|	  0x382 Drain       LVO -66
|	  0x3de stub        LVO -72     stale d0 (dead a4 reload)
|	  0x3ea Classify    LVO -78
|	  0x470 Dispatch    LVO -84     PC-indexed op jump table @0x4b0
|	  0x530 memcpy                  24B unrolled + PC-indexed tail @0x55c
|	  0x5c4 NewList(sparg) / 0x5c8 NewList(a0)
|	  0x5dc signed div wrapper / 0x60e divuw-based udiv
|	  0x69e pad word
|
|	Hunk 1 DATA (0x46 longs / 280 bytes):
|	  name, pad-byte idstring, $VER, packed RomTag @+0x3c,
|	  14-entry absolute-long functab @+0x56 (-1 terminated),
|	  exec/dos/libbase slots, lib-name strings, tag templates.
|
|	Quirks preserved verbatim:
|	  - the shipped failure/return paths branch into the MIDDLE of
|	    `cmpi.w #0x7000/#0x7001,d0` instructions: the immediate word
|	    doubles as `moveq #0/1,d0`.  Written as `.short 0x0c40` +
|	    labelled moveq.
|	  - `lea _data_base,a4` reloads (14x) carry the hunk0->hunk1
|	    relocs; all intra-code refs are PC-relative/short-form.
|	  - Dispatch op table (0x4b0) and memcpy tail table (0x55c) are
|	    word-offset data that objdump misdecodes as ori.w streams;
|	    stored as .short lists.
|	  - Dispatch ops 1/2/4 jump straight to the epilogue (no call).
|

	.text

| ----------------------------------------------------------------
| +0x000 loader entry: returns -1
| ----------------------------------------------------------------

	moveq	#-1,%d0
	rts

| ----------------------------------------------------------------
| +0x004 LibInit(a0=seglist, a6=execbase)
| ----------------------------------------------------------------

_libinit:				/* 0x004 */
	moveml	%d7/%a2/%a4-%a6,%sp@-
	movel	%a0,%d7			/* seglist */
	moveal	%a6,%a5			/* execbase */
	lea	_data_base,%a4		/* reloc -> hunk1 @0x0e */
	movel	%a5,%a4@(0x92)		/* data+0x92 = execbase */
	lea	%a4@(0x9e),%a1		/* "dos.library" */
	moveq	#0,%d0
	moveal	4,%a6
	jsr	%a6@(-552)		/* OpenLibrary(dos,0) */
	movel	%d0,%a4@(0x96)		/* data+0x96 = dosbase (unchecked) */
	lea	%a4@(0x56),%a0		/* functab */
	subal	%a1,%a1
	subal	%a2,%a2
	moveq	#42,%d0			/* dsize */
	moveq	#0,%d1
	jsr	%a6@(-84)		/* MakeLibrary */
	movel	%d0,%a4@(0x9a)		/* data+0x9a = libbase */
	beqs	L086			/* NULL -> mid-instruction moveq#0 */
	moveal	%d0,%a0
	moveb	#9,%a0@(8)		/* ln_Type = NT_LIBRARY */
	.short	0x41ec,0x0000		/* lea a4@(0),a0 -- noncanonical
					   d16 form (gas drops the 0) */
	lea	%a4@(0x9a),%a2
	moveal	%a2@,%a1
	movel	%a0,%a1@(10)		/* ln_Name */
	moveb	#6,%a1@(14)		/* lib_Flags = 6 */
	moveal	%a2@,%a0
	movew	#1,%a0@(20)		/* lib_Version */
	movew	#2,%a0@(22)		/* lib_Revision */
	lea	%a4@(0x12),%a1		/* data+0x12: pad byte (idstr bug) */
	movel	%a1,%a0@(24)		/* lib_IdString -> empty string */
	moveal	%a2@,%a0
	movel	%d7,%a0@(34)		/* seglist */
	movel	%a5,%a0@(38)		/* lib_SysBase */
	moveal	%a2@+,%a1
	jsr	%a6@(-396)		/* AddLibrary */
	movel	%a4@(0x9a),%d0		/* return libbase */
	.short	0x0c40			/* cmpiw -- immediate doubles as */
L086:	moveq	#0,%d0			/*   `moveq #0,d0' for the beqs */
	moveml	%sp@+,%d7/%a2/%a4-%a6
	rts

| ----------------------------------------------------------------
| +0x08e Open (LVO -6)
| ----------------------------------------------------------------

_open:					/* 0x08e */
	movel	%a4,%sp@-
	lea	_data_base,%a4		/* reloc @0x92 */
	addqw	#1,%a6@(32)		/* lib_OpenCnt++ */
	bclrb	#3,%a6@(14)		/* clear deferred-expunge flag */
	movel	%a6,%d0
	moveal	%sp@+,%a4
	rts

| ----------------------------------------------------------------
| +0x0a6 Close (LVO -12)
| ----------------------------------------------------------------

_close:					/* 0x0a6 */
	moveml	%d7/%a4,%sp@-
	lea	_data_base,%a4		/* reloc @0xac */
	moveq	#0,%d7
	movew	%a6@(32),%d0
	moveq	#0,%d1
	cmpw	%d1,%d0
	blss	L0d0			/* OpenCnt<=0 (unsigned) -> out */
	subqw	#1,%a6@(32)
	bnes	L0d0			/* still open -> out */
	btstb	#3,%a6@(14)
	beqs	L0d0			/* no deferred flag -> out */
	bsrw	_expunge
	movel	%d0,%d7
L0d0:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a4
	rts

| ----------------------------------------------------------------
| +0x0d8 Expunge (LVO -18)
| ----------------------------------------------------------------

_expunge:				/* 0x0d8 */
	moveml	%d2-%d3/%d7/%a4-%a6,%sp@-
	moveal	%a6,%a5			/* libbase */
	lea	_data_base,%a4		/* reloc @0xe0 */
	moveq	#0,%d7
	cmpiw	#0,%a5@(32)
	blss	L0f6			/* OpenCnt==0 -> real expunge */
	bsetb	#3,%a5@(14)		/* defer */
	bras	L122
L0f6:	moveal	%a5,%a1			/* Remove(lib) */
	moveal	4,%a6
	jsr	%a6@(-252)
	movel	%a5@(34),%d7		/* seglist */
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* NegSize */
	movel	%a5,%d1
	subl	%d0,%d1			/* base - NegSize */
	moveq	#0,%d2
	movew	%a5@(18),%d2		/* PosSize */
	moveq	#0,%d3
	movew	%d0,%d3
	addl	%d2,%d3			/* Neg+Pos */
	moveal	%d1,%a1
	movel	%d3,%d0
	jsr	%a6@(-210)		/* FreeMem */
L122:	movel	%a4@(0x96),%d0		/* dosbase */
	beqs	L132
	moveal	%d0,%a1
	moveal	4,%a6
	jsr	%a6@(-414)		/* CloseLibrary(dos) */
L132:	clrl	%a4@(0x96)
	movel	%d7,%d0			/* return seglist */
	moveml	%sp@+,%d2-%d3/%d7/%a4-%a6
	rts

| ----------------------------------------------------------------
| +0x13e reserved stub (LVO -24)
| ----------------------------------------------------------------

_stub24:				/* 0x13e */
	moveq	#0,%d0
	rts
	nop

| ----------------------------------------------------------------
| +0x144 Create (LVO -30), a0=tag0 d0=tag1
| ----------------------------------------------------------------

_create:				/* 0x144 */
	subaw	#32,%sp
	moveml	%d7/%a3-%a6,%sp@-
	movel	%d0,%d7			/* tag1 */
	moveal	%a0,%a5			/* tag0 */
	lea	_data_base,%a4		/* reloc @0x152 */
	lea	%a4@(0xac),%a0		/* 32B tag template */
	lea	%sp@(20),%a1
	moveq	#32,%d0
	bsrw	_memcpy
	lea	%a4@(0xcc),%a1		/* "prelude.library" */
	moveq	#5,%d0
	moveal	4,%a6
	jsr	%a6@(-552)		/* OpenLibrary(prelude,5) */
	movel	%d0,%a4@(0x114)		/* stored before any check */
	beqs	L1f0			/* NULL -> mid-instr moveq#0 */
	moveq	#5,%d1
	moveal	%d0,%a0
	cmpw	%a0@(20),%d1		/* gate: fail iff ver==5 && rev<2 */
	bnes	L18a
	cmpiw	#2,%a0@(22)
	bcss	L1f0
L18a:	moveal	%d0,%a1
	moveal	%a1@(56),%a0
	btstb	#0,%a0@(21)		/* feature bit */
	beqs	L1f0
	moveq	#16,%d0			/* 16B obj */
	moveq	#1,%d1
	swap	%d1			/* flags 0x10000 (CLEAR) */
	moveal	4,%a6
	jsr	%a6@(-684)		/* AllocVec */
	moveal	%d0,%a3
	tstl	%d0
	beqs	L1f0
	movel	%a5,%a3@		/* obj+0 = tag0 */
	movel	%d7,%a3@(4)		/* obj+4 = tag1 */
	moveq	#12,%d0			/* 12B MinList block */
	movel	#0x10001,%d1		/* PUBLIC|CLEAR */
	jsr	%a6@(-684)		/* AllocVec (unchecked) */
	movel	%d0,%a3@(12)
	moveal	%d0,%a0
	bsrw	_newlist_a0
	movel	%a3@,%sp@(24)		/* tag 0x80000032 <- obj+0 */
	movel	%a3@(4),%sp@(32)	/* tag 0x80000033 <- obj+4 */
	moveq	#99,%d0			/* tag 0x8000003f <- 99 */
	movel	%d0,%sp@(40)
	lea	%sp@(20),%a0
	moveal	%a4@(0x114),%a6
	jsr	%a6@(-90)		/* prelude@-90 */
	moveal	%a6@(0x8e),%a0
	clrl	%a0@(16)		/* shared prelude flag = 0 */
	movel	%a3,%d0			/* return obj */
	.short	0x0c40			/* cmpiw -- immediate doubles as */
L1f0:	moveq	#0,%d0			/*   `moveq #0,d0' for beq paths */
	moveml	%sp@+,%d7/%a3-%a6
	addaw	#32,%sp
	rts

| ----------------------------------------------------------------
| +0x1fc Destroy (LVO -36), a3=obj
| ----------------------------------------------------------------

_destroy:				/* 0x1fc */
	moveml	%a4/%a6,%sp@-
	lea	_data_base,%a4		/* reloc @0x202 */
	movel	%a3,%d0
	beqs	L23e			/* NULL -> ret (prelude leak) */
	moveal	%a4@(0x114),%a1
	moveal	4,%a6
	jsr	%a6@(-414)		/* CloseLibrary(prelude) first */
	bras	L222
L218:	moveal	%a0,%a1
	moveal	4,%a6
	jsr	%a6@(-690)		/* FreeVec(node) */
L222:	moveal	%a3@(12),%a0		/* list block */
	moveal	4,%a6
	jsr	%a6@(-258)		/* RemHead */
	moveal	%d0,%a0
	tstl	%d0
	bnes	L218
	moveal	%a3,%a1
	moveal	4,%a6
	jsr	%a6@(-690)		/* FreeVec(obj) */
L23e:	moveml	%sp@+,%a4/%a6		/* 12B list block never freed */
	rts

| ----------------------------------------------------------------
| +0x244 Append (LVO -42), a0=v0 d0=v1 a3=obj
| ----------------------------------------------------------------

_append:				/* 0x244 */
	moveml	%d2/%a2/%a4-%a6,%sp@-
	movel	%d0,%d2			/* v1 */
	moveal	%a0,%a5			/* v0 */
	lea	_data_base,%a4		/* reloc @0x24e */
	movel	%a3,%d0
	beqs	L2b2			/* NULL obj -> clrw d0 (hi leak) */
	moveq	#18,%d0			/* 18B node */
	movel	#0x10001,%d1
	moveal	4,%a6
	jsr	%a6@(-684)		/* AllocVec (unchecked) */
	moveal	%d0,%a2
	moveal	%d0,%a0
	lea	%a0@(8),%a1
	movel	%a5,%a1@+		/* node+8 = v0 */
	movel	%d2,%a1@+		/* node+12 = v1 */
	clrw	%a1@+			/* node+16.w = 0 */
	moveal	%d0,%a1
	moveal	%a3@(12),%a0
	jsr	%a6@(-246)		/* AddTail(list,node) */
	addql	#1,%a3@(8)		/* obj count++ */
	moveal	%a4@(0x114),%a1
	moveal	%a1@(0x8e),%a0
	tstl	%a0@(16)		/* prelude shared flag */
	beqs	L2ae
	movew	#1,%a2@(16)		/* node flag = notified */
	moveal	%a5,%a0
	movel	%d2,%d0
	moveal	%a4@(0x114),%a6
	movel	#0x1008,%d1
	movel	#0x5622,%d2		/* 22050 */
	jsr	%a6@(-60)		/* prelude@-60 */
L2ae:	moveq	#1,%d0
	.short	0x0c40			/* cmpiw -- immediate doubles as */
L2b2:	moveq	#0,%d0			/*   `moveq #0,d0' for NULL obj */
	moveml	%sp@+,%d2/%a2/%a4-%a6
	rts

| ----------------------------------------------------------------
| +0x2ba Pop (LVO -48), a3=obj
| ----------------------------------------------------------------

_pop:					/* 0x2ba */
	moveml	%a4-%a6,%sp@-
	lea	_data_base,%a4		/* reloc @0x2c0 */
	subal	%a5,%a5			/* result = 0 */
	movel	%a3,%d0
	beqs	L302			/* NULL obj -> 0 */
	moveal	%a4@(0x114),%a1
	moveal	%a1@(0x8e),%a0
	movel	%a0@(16),%d0		/* prelude flag/depth */
	cmpl	%a3@(8),%d0		/* gate: flag >= count -> 0 */
	bccs	L302
	moveal	%a3@(12),%a0
	moveal	4,%a6
	jsr	%a6@(-258)		/* RemHead */
	tstl	%d0
	beqs	L2f8
	moveal	%d0,%a0
	moveal	%a0@(8),%a5		/* r = node data0 */
	moveal	%d0,%a1
	jsr	%a6@(-690)		/* FreeVec(node) */
L2f8:	movel	%a3@(8),%d0
	beqs	L302
	subql	#1,%a3@(8)		/* count-- if nonzero */
L302:	movel	%a5,%d0
	moveml	%sp@+,%a4-%a6
	rts

| ----------------------------------------------------------------
| +0x30a Query (LVO -54), a3=obj
| ----------------------------------------------------------------

_query:					/* 0x30a */
	movel	%a4,%sp@-
	lea	_data_base,%a4		/* reloc @0x30e */
	movel	%a3,%d0
	beqs	L328			/* NULL obj -> mid-instr moveq#1 */
	moveal	%a4@(0x114),%a1
	moveal	%a1@(0x8e),%a0
	tstl	%a0@(16)
	beqs	L328			/* flag clear -> moveq#1 */
	moveq	#0,%d0
	.short	0x0c40			/* cmpiw -- immediate doubles as */
L328:	moveq	#1,%d0			/*   `moveq #1,d0' (0x7001) */
	moveal	%sp@+,%a4
	rts

| ----------------------------------------------------------------
| +0x32e Iterate (LVO -60), a3=obj
| ----------------------------------------------------------------

_iterate:				/* 0x32e */
	subqw	#4,%sp
	moveml	%d2/%a4-%a6,%sp@-
	lea	_data_base,%a4		/* reloc @0x336 */
	moveal	%a3,%a5
	movel	%a3,%sp@(16)
	movel	%a5,%d0
	beqs	L37a			/* NULL -> ret */
	moveal	%a5@(12),%a0
	moveal	%a0@,%a5		/* a5 = lh_Head (sentinel on empty) */
	bras	L376
L34c:	tstw	%a5@(16)		/* node flag */
	bnes	L374
	moveal	%a5@(8),%a0		/* data0 */
	movel	%a5@(12),%d0		/* data1 */
	moveal	%a4@(0x114),%a6
	movel	#0x1008,%d1
	movel	#0x5622,%d2		/* 22050 */
	jsr	%a6@(-60)		/* prelude@-60 */
	movew	#1,%a5@(16)
L374:	moveal	%a5@,%a5		/* node = node->succ */
L376:	tstl	%a5@			/* succ NULL -> done */
	bnes	L34c
L37a:	moveml	%sp@+,%d2/%a4-%a6
	addqw	#4,%sp
	rts

| ----------------------------------------------------------------
| +0x382 Drain (LVO -66), a3=obj
| ----------------------------------------------------------------

_drain:					/* 0x382 */
	moveml	%a4/%a6,%sp@-
	lea	_data_base,%a4		/* reloc @0x388 */
	movel	%a3,%d0
	beqs	L3d8			/* NULL -> ret */
	moveal	%a4@(0x114),%a6
	moveq	#64,%d0
	addl	%d0,%d0			/* 128 literal */
	jsr	%a6@(-84)		/* prelude@-84(128) */
	jsr	%a6@(-36)		/* prelude@-36 */
	moveal	%a4@(0x96),%a6		/* dosbase */
	moveq	#35,%d1
	jsr	%a6@(-198)		/* Delay(35) */
	bras	L3b6
L3ac:	moveal	%a0,%a1
	moveal	4,%a6
	jsr	%a6@(-690)		/* FreeVec(node) */
L3b6:	moveal	%a3@(12),%a0
	moveal	4,%a6
	jsr	%a6@(-258)		/* RemHead */
	moveal	%d0,%a0
	tstl	%d0
	bnes	L3ac
	moveal	%a4@(0x114),%a1
	moveal	%a1@(0x8e),%a0
	clrl	%a0@(16)		/* prelude flag = 0 */
	clrl	%a3@(8)			/* obj count = 0 */
L3d8:	moveml	%sp@+,%a4/%a6
	rts

| ----------------------------------------------------------------
| +0x3de stub (LVO -72): dead a4 reload, returns stale d0
| ----------------------------------------------------------------

_stub72:				/* 0x3de */
	movel	%a4,%sp@-
	lea	_data_base,%a4		/* reloc @0x3e2 (dead) */
	moveal	%sp@+,%a4
	rts

| ----------------------------------------------------------------
| +0x3ea Classify (LVO -78), d1=code
| ----------------------------------------------------------------

_classify:				/* 0x3ea */
	movel	%a4,%sp@-
	movel	%d1,%d0
	lea	_data_base,%a4		/* reloc @0x3f0 */
	subql	#1,%d0			/* 1 */
	beqs	L45e
	subql	#1,%d0			/* 2 */
	beqs	L45e
	subql	#1,%d0			/* 3 */
	beqs	L45e
	subql	#7,%d0			/* 10 */
	beqs	L45a
	subql	#1,%d0			/* 11 */
	beqs	L45a
	subql	#1,%d0			/* 12 */
	beqs	L45a
	subql	#8,%d0			/* 20 */
	beqs	L45e
	subql	#1,%d0			/* 21 */
	beqs	L45e
	moveq	#9,%d1
	subl	%d1,%d0			/* 30 */
	beqs	L466
	subql	#1,%d0			/* 31 */
	beqs	L466
	moveq	#9,%d1
	subl	%d1,%d0			/* 40 */
	beqs	L462
	subql	#1,%d0			/* 41 */
	beqs	L462
	subil	#0x3bf,%d0		/* 1000 */
	beqs	L43e
	subql	#1,%d0			/* 1001 */
	beqs	L446
	subql	#1,%d0			/* 1002 */
	beqs	L44e
	subql	#8,%d0			/* 1010 */
	beqs	L456
	bras	L46a			/* unknown -> mid-instr moveq#0 */
L43e:	lea	%a4@(0xdc),%a0		/* "MPEGit" */
	movel	%a0,%d0
	bras	L46c
L446:	lea	%a4@(0xe4),%a0		/* "1.2 (20.01.2017)" */
	movel	%a0,%d0
	bras	L46c
L44e:	lea	%a4@(0xf6),%a0		/* "Thomas Wenzel" */
	movel	%a0,%d0
	bras	L46c
L456:	moveq	#1,%d0			/* 1010 -> 1 */
	bras	L46c
L45a:	moveq	#1,%d0			/* 10/11/12 */
	bras	L46c
L45e:	moveq	#1,%d0			/* 1/2/3/20/21 */
	bras	L46c
L462:	moveq	#1,%d0			/* 40/41 */
	bras	L46c
L466:	moveq	#1,%d0			/* 30/31 */
	.short	0x0c40			/* cmpiw -- immediate doubles as */
L46a:	moveq	#0,%d0			/*   `moveq #0,d0' fall-through */
L46c:	moveal	%sp@+,%a4
	rts

| ----------------------------------------------------------------
| +0x470 Dispatch (LVO -84), d0=op d1=val a3=obj
| ----------------------------------------------------------------

_dispatch:				/* 0x470 */
	subaw	#16,%sp
	moveml	%d6/%a4/%a6,%sp@-
	movel	%d1,%d6			/* val */
	movel	%d0,%d1			/* op */
	lea	_data_base,%a4		/* reloc @0x47e */
	lea	%a4@(0x104),%a0		/* 16B tag template */
	lea	%sp@(12),%a1
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a3,%d0
	beqw	L524			/* NULL obj -> out */
	moveq	#0,%d0
	movew	%d1,%d0			/* op.w only (hi bits ignored) */
	cmpil	#7,%d0
	bccw	L524			/* op >= 7 -> out */
	addw	%d0,%d0
	movew	%pc@(L4b0,%d0:w),%d0
	jmp	%pc@(L4b2,%d0:w)
L4b0:	.short	0x000c			/* op0 -> 0x4be */
L4b2:	.short	0x0072,0x0072,0x0034	/* op1->0x524 op2->0x524 op3->0x4e6 */
	.short	0x0072,0x0046,0x0022	/* op4->0x524 op5->0x4f8 op6->0x4d4 */
L4be:	moveq	#100,%d0		/* op0: {0x8000003f, min(v,100)} */
	cmpl	%d0,%d6
	blss	L4c6
	movel	%d0,%d6
L4c6:	movel	#0x8000003f,%sp@(12)
	movel	%d6,%sp@(16)
	bras	L518
L4d4:	moveq	#100,%d0		/* op6: {0x8000003b, 15*min/50} */
	cmpl	%d0,%d6
	blss	L4dc
	movel	%d0,%d6
L4dc:	movel	#0x8000003b,%sp@(12)
	bras	L508
L4e6:	moveq	#100,%d0		/* op3: {0x8000003c, 15*min/50} */
	cmpl	%d0,%d6
	blss	L4ee
	movel	%d0,%d6
L4ee:	movel	#0x8000003c,%sp@(12)
	bras	L508
L4f8:	moveq	#100,%d0		/* op5: {0x8000003d, 15*min/50} */
	cmpl	%d0,%d6
	blss	L500
	movel	%d0,%d6
L500:	movel	#0x8000003d,%sp@(12)
L508:	movel	%d6,%d0			/* 15*min(v,100)/50 */
	asll	#4,%d0
	subl	%d6,%d0
	moveq	#50,%d1
	bsrw	_udiv
	movel	%d0,%sp@(16)
L518:	lea	%sp@(12),%a0
	moveal	%a4@(0x114),%a6
	jsr	%a6@(-90)		/* prelude@-90 */
L524:	moveml	%sp@+,%d6/%a4/%a6
	addaw	#16,%sp
	rts
	nop					/* 0x52e pad */

| ----------------------------------------------------------------
| +0x530 memcpy(a0=src,a1=dst,d0=n): 24B unrolled + computed tail
| ----------------------------------------------------------------

_memcpy:				/* 0x530 */
	cmpil	#24,%d0
	blts	L552
L538:	movel	%a0@+,%a1@+		/* 24 bytes per iter */
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	subil	#24,%d0
	cmpil	#24,%d0
	bges	L538
L552:	addw	%d0,%d0			/* 0..46 word index */
	movew	%pc@(L55c,%d0:w),%d0
	jmp	%pc@(L55c,%d0:w)
L55c:	.short	0x0066,0x0058,0x004a,0x003a	/* tails for 0..3 rem */
	.short	0x0064,0x0056,0x0048,0x0038	/* 4..7 */
	.short	0x0062,0x0054,0x0046,0x0036	/* 8..11 */
	.short	0x0060,0x0052,0x0044,0x0034	/* 12..15 */
	.short	0x005e,0x0050,0x0042,0x0032	/* 16..19 */
	.short	0x005c,0x004e,0x0040,0x0030	/* 20..23 */
	movel	%a0@+,%a1@+		/* 0x58c: 23B tail entry */
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movew	%a0@+,%a1@+
	moveb	%a0@+,%a1@+
	rts
	movel	%a0@+,%a1@+		/* 0x59c: 22B tail entry */
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movew	%a0@+,%a1@+
	rts
	movel	%a0@+,%a1@+		/* 0x5aa: 21B tail entry */
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	moveb	%a0@+,%a1@+
	rts
	movel	%a0@+,%a1@+		/* 0x5b8: 20B tail entry */
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	movel	%a0@+,%a1@+
	rts					/* 0x5c2: 0B tail entry */

| ----------------------------------------------------------------
| +0x5c4 NewList(stack arg) / +0x5c8 NewList(a0)
| ----------------------------------------------------------------

_newlist_sp:				/* 0x5c4 */
	moveal	%sp@(4),%a0
_newlist_a0:				/* 0x5c8 */
	clrl	%a0@(4)			/* lh_Tail = NULL */
	movel	%a0,%a0@(8)		/* lh_TailPred = &head */
	addql	#4,%a0
	movel	%a0,%a0@-		/* lh_Head = &tail */
	rts
	.short	0			/* 0x5d6 pad */
	rts					/* 0x5d8 dead rts */
	nop					/* 0x5da pad */

| ----------------------------------------------------------------
| +0x5dc signed 32/16 division wrapper -> _udiv
| ----------------------------------------------------------------

_sdiv:					/* 0x5dc */
	tstl	%d0
	bplw	L5fe
	negl	%d0
	tstl	%d1
	bplw	L5f4
	negl	%d1
	bsrw	_udiv
	negl	%d1
	rts
L5f4:	bsrw	_udiv
	negl	%d0
	negl	%d1
	rts
L5fe:	tstl	%d1
	bplw	_udiv
	negl	%d1
	bsrw	_udiv
	negl	%d0
	rts

| ----------------------------------------------------------------
| +0x60e udiv: d0.l / d1.w -> d0=quot d1=rem (divuw bit-normalise)
| ----------------------------------------------------------------

_udiv:					/* 0x60e */
	movel	%d2,%sp@-
	swap	%d1
	movew	%d1,%d2
	bnew	L638			/* divisor >= 0x10000 -> big path */
	swap	%d0
	swap	%d1
	swap	%d2
	movew	%d0,%d2
	beqw	L628
	divuw	%d1,%d2
	movew	%d2,%d0
L628:	swap	%d0
	movew	%d0,%d2
	divuw	%d1,%d2
	movew	%d2,%d0
	swap	%d2
	movew	%d2,%d1
	movel	%sp@+,%d2
	rts
L638:	movel	%d3,%sp@-
	moveq	#16,%d3
	cmpiw	#0x100,%d1
	bccw	L648
	roll	#8,%d1
	subqw	#8,%d3
L648:	cmpiw	#0x1000,%d1
	bccw	L654
	roll	#4,%d1
	subqw	#4,%d3
L654:	cmpiw	#0x4000,%d1
	bccw	L660
	roll	#2,%d1
	subqw	#2,%d3
L660:	tstw	%d1
	bmiw	L66a
	roll	#1,%d1
	subqw	#1,%d3
L66a:	movew	%d0,%d2
	lsrl	%d3,%d0
	swap	%d2
	clrw	%d2
	lsrl	%d3,%d2
	swap	%d3
	divuw	%d1,%d0
	movew	%d0,%d3
	movew	%d2,%d0
	movew	%d3,%d2
	swap	%d1
	muluw	%d1,%d2
	subl	%d2,%d0
	bccw	L68c
	subqw	#1,%d3
	addl	%d1,%d0
L68c:	moveq	#0,%d1
	movew	%d3,%d1
	swap	%d3
	roll	%d3,%d0
	swap	%d0
	exg	%d0,%d1
	movel	%sp@+,%d3
	movel	%sp@+,%d2
	rts
	.short	0			/* 0x69e pad to hunk end */

| ================================================================
| Hunk 1: DATA (280 bytes)
| ================================================================

	.data

_data_base:				/* data+0x00 */
_libname:
	.ascii	"mhimpegit.library"
	.byte	0			/* +0x11 */
_idstr:	.byte	0			/* +0x12 pad: rt_IdString AND
					   lib+24 point HERE -- the
					   reported idstring is empty */
	.ascii	"$VER: mhimpegit.library 1.2 (20.01.2017)"
	.byte	0			/* +0x3b */

_rttag:					/* data+0x3c packed Resident */
	.short	0x4afc			/* rt_MatchWord */
	.long	_rttag			/* rt_MatchTag -> +0x3c */
	.long	_functab		/* rt_EndSkip -> +0x56 */
	.byte	0			/* rt_Flags: 0 (NOT autoinit) */
	.byte	1			/* rt_Version */
	.byte	9			/* rt_Type = NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* rt_Name -> +0 */
	.long	_idstr			/* rt_IdString -> +0x12 */
	.long	_libinit		/* rt_Init -> code+4 */

_functab:				/* data+0x56: 14 abs-long LVOs */
	.long	_open			/* -6  Open        -> code+0x08e */
	.long	_close			/* -12 Close       -> code+0x0a6 */
	.long	_expunge		/* -18 Expunge     -> code+0x0d8 */
	.long	_stub24			/* -24             -> code+0x13e */
	.long	_create			/* -30 Create      -> code+0x144 */
	.long	_destroy		/* -36 Destroy     -> code+0x1fc */
	.long	_append			/* -42 Append      -> code+0x244 */
	.long	_pop			/* -48 Pop         -> code+0x2ba */
	.long	_query			/* -54 Query       -> code+0x30a */
	.long	_iterate		/* -60 Iterate     -> code+0x32e */
	.long	_drain			/* -66 Drain       -> code+0x382 */
	.long	_stub72			/* -72             -> code+0x3de */
	.long	_classify		/* -78 Classify    -> code+0x3ea */
	.long	_dispatch		/* -84 Dispatch    -> code+0x470 */
	.long	-1			/* +0x8e terminator */

	.long	0			/* +0x92 ExecBase slot */
	.long	0			/* +0x96 DOSBase slot */
	.long	0			/* +0x9a libbase slot */

_s_dos:					/* +0x9e */
	.ascii	"dos.library"
	.byte	0,0,0			/* +0xa9 NUL + 2 pad -> +0xac */

_ctmpl:					/* +0xac Create tag template */
	.long	0x80000032,0		/* tag0 <- obj+0 */
	.long	0x80000033,0		/* tag1 <- obj+4 */
	.long	0x8000003f,0		/*     <- 99 */
	.long	0,0			/* TAG_DONE */

_s_prelude:				/* +0xcc */
	.ascii	"prelude.library"
	.byte	0			/* +0xdb */

_s_mpegit:				/* +0xdc */
	.ascii	"MPEGit"
	.byte	0,0			/* +0xe2 NUL + pad */

_s_ver:					/* +0xe4 */
	.ascii	"1.2 (20.01.2017)"
	.byte	0,0			/* +0xf4 NUL + pad */

_s_author:				/* +0xf6 */
	.ascii	"Thomas Wenzel"
	.byte	0			/* +0x103 */

_dtmpl:					/* +0x104 Dispatch tag template */
	.long	0x8000003f,0		/* tag + value patched in */
	.long	0,0

	.long	0			/* +0x114 PreludeBase slot */

	.end
