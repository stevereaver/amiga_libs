/* xpkRLEN.library 1.3 (01.04.1997) — XPK PackBits-style RLE sublib.
 * Two hunks: CODE (0x2a0) + DATA (0x84).  Absolute-long functab,
 * minimal 0x22-byte base, AUTOINIT, rt_EndSkip mid-module (0x102).
 * DATA hunk: XpkMode 'normal' descriptor at +0, unaligned XpkInfo
 * at +0x2a (long fields straddle 4-byte boundaries); its three name
 * pointers relocate into hunk0's string table, xi_ModeDesc self-relocates.
 * Quirks: initfn makes TWO dead bsr calls to the shared moveq#0/rts
 * stub (the bnes after it can never fire); expunge bsr's the same stub
 * as a dead cleanup hook; the seglist cell is the datatab's trailing
 * 4-byte zero terminator at code+0x7a; header carries a nonstandard
 * leading 0x00000002 long before first/last; two reloc groups on hunk0
 * (21 self + 1 into hunk1 for the lea operand); unpack stores xsp in
 * a stack local it never reads; pack shares bytes between cmpi.w and
 * moveq/addq instruction streams (0x0c40 overlap trick).
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_stub0:					/* 0x00 */
	moveq	#-1,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_endskip		/* rt_EndSkip -> 0x102 (mid-module) */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	1			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* 0x104 */
	.long	_idstr			/* 0x114 */
	.long	_inittab		/* 0x1e */

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0x1e */
	.long	0x22			/* dataSize: bare struct Library */
	.long	_functab		/* 0x2e */
	.long	_datatab		/* 0x5a */
	.long	_init			/* 0x7e */

_functab:				/* 0x2e, absolute longs */
	.long	_open			/* -6   Open        -> 0x9e */
	.long	_close			/* -12  Close       -> 0xac */
	.long	_expunge		/* -18  Expunge     -> 0xc0 */
	.long	_ret0			/* -24  reserved    -> 0x100 */
	.long	_xpkinfo		/* -30  PackerInfo  -> 0x134 */
	.long	_pack			/* -36  PackChunk   -> 0x184 */
	.long	_ret0x			/* -42  PackFree    -> 0x130 */
	.long	_ret0x			/* -48  PackReset   -> 0x130 */
	.long	_unpack			/* -54  UnpackChunk -> 0x25a */
	.long	_ret0x			/* -60  UnpackFree  -> 0x130 */
	.long	0xffffffff		/* 0x56 */

/* InitStruct: bare library node only (descriptors live in hunk1) */
_datatab:				/* 0x5a */
	.byte	0xa0,0x08,0x09,0x00	/* INITBYTE ln_Type=NT_LIBRARY */
	.byte	0x80,0x0a		/* INITLONG ln_Name */
	.long	_libname
	.byte	0xa0,0x0e,0x06,0x00	/* INITBYTE lib_Flags=6 */
	.byte	0x90,0x14,0x00,0x01	/* INITWORD lib_Version=1 */
	.byte	0x90,0x16,0x00,0x03	/* INITWORD lib_Revision=3 */
	.byte	0x80,0x18		/* INITLONG lib_IdString */
	.long	_idstr
	.long	0			/* 0x76: InitStruct terminator */
_segcell:
	.long	0			/* 0x7a: seglist cell (initfn
					   stores a0 via relocated abs) */
/* ---- code ----------------------------------------------------- */
_init:					/* 0x7e */
	movel	a5,sp@-
	moveal	d0,a5			/* a5 = new base */
	movel	a0,_segcell		/* seglist -> code+0x7a cell */
	bsrw	_ret0x			/* dead call -> moveq#0,rts */
	tstl	d0
	bnes	1f			/* never taken (d0==0 always) */
	movel	a5,d0			/* return base */
2:	moveal	sp@+,a5
	rts
1:	bsrw	_ret0x			/* dead: second call to the stub */
	moveq	#0,d0			/* would return 0 = init fail */
	bras	2b			/* skips the movel a5,d0 */

_open:					/* 0x9e */
	addqw	#1,a6@(0x20)		/* lib_OpenCnt++ */
	bclrb	#3,a6@(0xe)		/* LIBF_DELEXP */
	movel	a6,d0
	rts

_close:					/* 0xac */
	moveq	#0,d0
	subqw	#1,a6@(0x20)
	bnes	1f			/* still open -> ret 0 */
	btstb	#3,a6@(0xe)
	beqs	1f			/* no pending expunge -> ret 0 */
	bsrs	_expunge
1:	rts

_expunge:				/* 0xc0 */
	moveml	%d2/%a5-%a6,%sp@-
	moveal	a6,a5
	moveal	4,a6
	tstw	a5@(0x20)
	beqs	2f			/* cnt==0 -> real expunge */
	bsetb	#3,a6@(0xe)		/* deferred */
	moveq	#0,d0
	bras	3f
2:	movel	%pc@(_segcell),d2	/* seglist cell @0x7a (PC-rel) */
	moveal	a5,a1
	jsr	a6@(-0xfc)		/* Remove */
	bsrs	_ret0x			/* dead cleanup hook -> stub */
	moveq	#0,d0
	moveal	a5,a1
	movew	a5@(0x10),d0		/* negSize */
	subal	d0,a1
	addw	a5@(0x12),d0		/* +posSize */
	jsr	a6@(-0xd2)		/* FreeMem */
	movel	d2,d0			/* return seglist */
3:	moveml	%sp@+,%d2/%a5-%a6
	rts

_ret0:					/* 0x100 — -24 slot */
	moveq	#0,d0
_endskip:				/* 0x102 rt_EndSkip -> this rts */
	rts

_libname:				/* 0x104 */
	.ascii	"xpkRLEN.library"
	.byte	0
_idstr:					/* 0x114 */
	.ascii	"xpkRLEN 1.3 (01.04.1997)\r\n"
	.byte	0,0			/* 0x12e pad */

_ret0x:					/* 0x130 — shared stub: -42/-48/-60
					   and the dead bsr targets */
	moveq	#0,d0
	rts

_xpkinfo:				/* 0x134 — returns &hunk1 XpkInfo */
	lea	_xi,a0			/* operand reloc'd into hunk1 */
	movel	a0,d0
	rts

_s_id:	.ascii	"RLEN"			/* 0x13e xi_Name */
	.byte	0,0
_s_lname:
	.ascii	"Run Length"		/* 0x144 xi_LongName */
	.byte	0,0
_s_desc:.ascii	"Fast and simple compression usable for simple data"
	.byte	0,0			/* 0x150 .. 0x183 (2 pads) */

/* XpksPackChunk: PackBits RLE.
 * frame: subaw #12 + moveml 7 regs; locals at sp+0x20 (out ceiling),
 * sp+0x24 (xsp). */
_pack:					/* 0x184 */
	subaw	#12,sp
	moveml	%d5-%d7/%a2-%a5,%sp@-
	lea	a0@,a1			/* a1 = &xsp */
	moveal	a1@+,a5			/* a5 = xsp_InBuf */
	moveal	a5,a4			/* a4 = lit base */
	moveal	a5,a3
	addal	a1@+,a3			/* a3 = InBuf+InLen */
	moveal	a1@+,a2			/* a2 = OutBuf */
	moveal	a2,a1
	addal	a0@(0xc),a1		/* a1 = OutBuf+OutBufLen */
	movel	a0,sp@(0x24)		/* save xsp */
	movel	a1,sp@(0x20)		/* save out ceiling */
1:	moveb	a5@(1),d0		/* src[1] */
	moveb	a5@,d1			/* src[0] */
	cmpb	d0,d1
	bnes	2f			/* literal */
	cmpb	a5@(2),d0		/* src[2]==src[1]? */
	bnes	2f
	moveq	#1,d0			/* run detected */
	.short	0x0c40			/* cmpi.w — operand shares the
					   following moveq's 0x7000 bytes */
2:	moveq	#0,d0			/* literal flag */
	movel	d0,d7			/* d7 = 1(run)/0(lit) */
	movel	a5,d0
	movel	d0,d1
	subl	a4,d1			/* litlen = a5 - a4 */
	movel	d1,d6
	moveal	a2,a0
	addal	d6,a0
	lea	a0@(4),a1
	cmpal	sp@(0x20),a1		/* out+litlen+4 vs ceiling */
	blss	3f
	moveq	#-17,d0			/* XPKERR_EXPANSION */
	bras	9f
3:	tstl	d7
	bnes	4f			/* run -> flush literal */
	moveq	#127,d1
	cmpl	d1,d6
	beqs	4f			/* litlen==127 -> flush */
	cmpl	a3,d0			/* cursor==inend? */
	bnes	5f			/* not end -> literal */
4:	tstl	d6			/* flush literal run */
	beqs	6f
	movel	d6,d1
	moveb	d1,a2@+			/* token = litlen */
	movel	d1,d5
	bras	7f
8:	moveb	a4@+,a2@+		/* copy literal bytes */
	subql	#1,d5
7:	tstl	d5
	bgts	8b
6:	cmpal	a5,a3			/* cursor==inend? */
	bnes	10f
	clrb	a2@+			/* trailing 0 token */
	bras	11f			/* done */
10:	moveal	a5,a4			/* reset lit base */
5:	tstl	d7
	beqs	12f			/* literal -> advance cursor */
	moveq	#3,d7			/* run: start len 3 */
	.short	0x0c40			/* cmpi.w — operand shares
					   addq.l#1,d7's 0x5287 bytes */
13:	addql	#1,d7			/* 0x20c: run extend loop */
	moveal	a5,a0
	addal	d7,a0
	cmpal	a3,a0			/* src+d7 vs inend */
	bccs	14f
	moveb	a5@(-1,%d7:l),d0	/* src[d7-1] */
	cmpb	a0@,d0			/* src[d7] == prev? */
	bnes	14f
	moveq	#127,d0
	cmpl	d0,d7
	blts	13b
14:	moveal	a2,a0			/* emit run token */
	movel	d7,d0
	negl	d0
	moveb	d0,a0@			/* out[0] = -runlen */
	addql	#2,a2
	moveb	a5@,a0@(1)		/* out[1] = run byte */
	addal	d7,a5			/* advance cursor by runlen */
	moveal	a5,a4			/* lit base = cursor */
	braw	1b
12:	addql	#1,a5			/* literal: cursor++ */
	braw	1b
11:	movel	a2,d0			/* done */
	moveal	sp@(0x24),a0		/* xsp */
	subl	a0@(8),d0		/* outlen = a2 - OutBuf */
	movel	d0,a0@(0x10)		/* xsp_OutLen */
	moveq	#0,d0
9:	moveml	%sp@+,%d5-%d7/%a2-%a5
	addaw	#12,sp
	rts

/* XpksUnpackChunk: token<0 -> repeat -n+1 times, token>0 -> n literals,
 * 0 terminator.  Never reports xsp_OutLen; dead stores xsp to a local. */
_unpack:				/* 0x25a */
	subqw	#4,sp
	moveml	%d6-%d7/%a4,%sp@-
	moveal	a0@,a4			/* a4 = xsp_InBuf */
	moveal	a0@(8),a1		/* a1 = xsp_OutBuf */
	movel	a0,sp@(0xc)		/* dead store: xsp -> local */
	bras	4f
1:	tstl	d7
	bles	2f			/* token<0 -> run */
	bras	3f
5:	moveb	a4@+,a1@+		/* literal copy */
	subql	#1,d7
3:	tstl	d7
	bgts	5b
	bras	4f
2:	negl	d7			/* -n -> n+1 */
	moveb	a4@+,d6			/* run byte */
	bras	6f
7:	moveb	d6,a1@+
	subql	#1,d7
6:	tstl	d7
	bgts	7b
4:	moveb	a4@+,d0			/* next token */
	moveb	d0,d7
	extw	d7
	extl	d7			/* sign-extend */
	bnes	1b
	moveq	#0,d0
	moveml	%sp@+,%d6-%d7/%a4
	addqw	#4,sp
	rts
	nop				/* 0x29e pad to hunk end */

/* ---- hunk1: DATA ---------------------------------------------- */
	.data
_xm:					/* data+0x00 XpkMode 'normal' */
	.long	0
	.long	100			/* xm_Upto */
	.long	1
	.long	0,0
	.long	0x8c			/* 0x14 */
	.long	0x413			/* 0x18 */
	.long	0x002d0000		/* 0x1c */
	.ascii	"normal"		/* 0x20 */
	.byte	0,0			/* 0x26 */
	.short	0			/* 0x28 pad to 0x2a */
_xi:					/* data+0x2a XpkInfo (unaligned) */
	.short	1			/* xi_XpkInfoVersion */
	.short	1			/* xi_LibVersion */
	.short	0			/* xi_MasterVersion */
	.short	0			/* xi_ModesVersion */
	.long	_s_id			/* +0x08 xi_Name (hunk0) */
	.long	_s_lname		/* +0x0c xi_LongName */
	.long	_s_desc			/* +0x10 xi_Description */
	.long	0x524c454e		/* +0x14 xi_ID 'RLEN' */
	.long	9			/* +0x18 xi_Flags (PK|UP) */
	.long	0x7fffffff		/* +0x1c xi_MaxPkInChunk */
	.long	0			/* +0x20 xi_MinPkInChunk */
	.long	0x4004			/* +0x24 xi_DefPkInChunk */
	.long	0			/* +0x28 xi_PackMsg NULL */
	.long	0			/* +0x2c xi_UnpackMsg NULL */
	.long	0			/* +0x30 xi_PackedMsg NULL */
	.long	0			/* +0x34 xi_UnpackedMsg NULL */
	.short	0x32			/* +0x38 xi_DefMode = 50 */
	.short	0			/* +0x3a pad */
	.long	_xm			/* +0x3c xi_ModeDesc -> data+0 */
	.fill	26,1,0			/* +0x40 .. 0x83 */
