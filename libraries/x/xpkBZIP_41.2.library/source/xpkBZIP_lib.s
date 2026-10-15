/* xpkBZIP.library 41.2 — library skeleton + data hunk
 *
 * Original layout: 2 hunks — CODE (0x508) + DATA (0x314).
 * DATA hunk holds the exec Resident (0x4afc RomTag at +0xd0,
 * AUTOINIT v41 pri 2, rt_Init -> InitTable at +0x00), the
 * functab, datatab, name/$VER strings, 10 XpkMode records
 * and the XpkInfo descriptor.
 *
 * Lib private data (dataSize 0x32): +34 seglist, +38 SysBase,
 * +42 ppcbase.  DATA-hunk globals (a4-relative):
 *   +60 libbase  +120 SysBase  +124 ppcbase
 */
	.text

/*---------------------- h0+0 entry stub ----------------------*/
/* returns -1 — never called by exec (the RomTag lives in the  */
/* DATA hunk); fires only if the file is run/jumped directly.  */
	.globl	entry
entry:
	movel	%a4,%sp@-
	moveq	#-1,%d0
	lea	datapc,%a4
	moveal	%sp@+,%a4
	rts

/*---------------------- LibInit ------------------------------*/
/* a0=seglist d0=lib a6=SysBase -> d0=lib or 0                 */
	.globl	libinit
libinit:
	moveml	%a2/%a4,%sp@-
	moveal	%d0,%a1
	lea	datapc,%a4
	movel	%a1,%a4@(60)		/* lib -> data+60    */
	movel	%a6,%a1@(38)		/* SysBase -> lib+38 */
	moveal	%a0,%a2			/* seglist           */
	moveal	%a4@(60),%a0
	movel	%a2,%a0@(34)		/* seglist -> lib+34 */
	bsrw	initppc
	tstl	%d0
	beqs	1f
	movel	%a4@(60),%d0		/* success: return lib */
	bras	2f
1:	bsrw	exitppc
	moveq	#0,%d0
2:	moveml	%sp@+,%a2/%a4
	rts

/*---------------------- LibOpen ------------------------------*/
	.globl	libopen
libopen:
	movel	%a4,%sp@-
	lea	datapc,%a4
	addqw	#1,%a6@(32)
	movel	%a6,%d0
	bclr	#3,%a6@(14)
	moveal	%sp@+,%a4
	rts

/*---------------------- LibClose -----------------------------*/
/* opencnt--; if 0 & DELEXP -> expunge.  QUIRK: early exits    */
/* branch into the operand of a dead cmpi.w #0x7000,d0 where   */
/* the bytes 0x7000 decode as moveq #0,d0.                     */
	.globl	libclose
libclose:
	movel	%a4,%sp@-
	lea	datapc,%a4
	subqw	#1,%a6@(32)
	bnes	1f
	btst	#3,%a6@(14)
	beqs	1f
	bsrw	libexpunge
	.byte	0x0c,0x40		/* dead cmpi.w head — 1f sits in its operand */
1:	moveq	#0,%d0			/* 0x7000 */
	moveal	%sp@+,%a4
	rts

/*---------------------- LibExpunge ---------------------------*/
/* a6=lib. opencnt!=0 -> DELEXP+0; else Remove, close ppc,     */
/* FreeMem(lib-negsize, neg+pos), return seglist (lib+34).     */
	.globl	libexpunge
libexpunge:
	moveml	%a3-%a6,%sp@-
	moveal	%a6,%a5
	tstw	%a5@(32)
	lea	datapc,%a4
	bnes	1f
	moveal	%a5,%a1
	moveal	%a4@(120),%a6		/* SysBase (data hunk) */
	moveal	%a5@(34),%a3		/* seglist */
	jsr	%a6@(-252)		/* Remove */
	bsrw	exitppc
	moveq	#0,%d1
	moveq	#0,%d0
	movew	%a5@(16),%d1
	moveal	%a5,%a1
	subal	%d1,%a1
	movew	%a5@(18),%d0
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem */
	movel	%a3,%d0
	bras	2f
1:	bset	#3,%a5@(14)		/* DELEXP */
	moveq	#0,%d0
2:	moveml	%sp@+,%a3-%a6
	rts

/*---------------------- reserved null stub -------------------*/
	.globl	libnull
libnull:
	movel	%a4,%sp@-
	moveq	#0,%d0
	lea	datapc,%a4
	moveal	%sp@+,%a4
	rts

/*---------------------- initppc ------------------------------*/
/* SysBase->data+120; OpenLibrary("ppc.library",44)->data+124, */
/* lib+42; d0=1 ok / 0 fail                                    */
initppc:
	moveml	%a4/%a6,%sp@-
	lea	datapc,%a4
	moveal	4:l,%a1
	movel	%a1,%a4@(120)
	lea	pcname,%a1		/* "ppc.library" */
	moveal	%a4@(120),%a6
	moveq	#44,%d0
	jsr	%a6@(-552)		/* OpenLibrary */
	movel	%d0,%a4@(124)
	beqs	1f
	moveal	%a4@(60),%a0
	movel	%d0,%a0@(42)		/* ppcbase -> lib+42 */
	moveq	#1,%d0
1:	moveml	%sp@+,%a4/%a6
	rts

/*---------------------- exitppc ------------------------------*/
/* CloseLibrary(data+124); clear                               */
exitppc:
	moveml	%a4/%a6,%sp@-
	lea	datapc,%a4
	movel	%a4@(124),%d0
	beqs	1f
	moveal	%d0,%a1
	moveal	%a4@(120),%a6
	jsr	%a6@(-414)		/* CloseLibrary */
	clrl	%a4@(124)
1:	moveml	%sp@+,%a4/%a6
	rts

/*---------------------- XpksPackerInfo -----------------------*/
/* returns APTR to the XpkInfo descriptor (data+0x2b8)         */
	.globl	packerinfo
packerinfo:
	movel	%a4,%sp@-
	lea	datapc,%a4
	lea	%a4@(696),%a0		/* datapc + 0x2b8 */
	movel	%a0,%d0
	moveal	%sp@+,%a4
	rts

/*---------------------- second null stub (-48) ---------------*/
	.globl	libnull2
libnull2:
	movel	%a4,%sp@-
	moveq	#0,%d0
	lea	datapc,%a4
	moveal	%sp@+,%a4
	rts

/*---------------------- code-hunk strings --------------------*/
	.globl	pcname, elfpath, bzipname, bziplong, bzipdesc
	.globl	pmsg, umsg, pkdmsg, upkdmsg, _elfpath
pcname:	 .ascii	"ppc.library\0"
	.even
bzipname:.ascii	"BZIP\0"
	.even
bziplong:.ascii	"BZIP (PPC) 41.2\0"
	.even
bzipdesc:.ascii	"BZIP, a block-sorting file compressor (requires a PowerPC processor)\0"
	.even
pmsg:	 .ascii	"Compressing\0"
	.even
umsg:	 .ascii	"Decompressing\0"
	.even
pkdmsg:	 .ascii	"Compressed\0"
	.even
upkdmsg: .ascii	"Decompressed\0"
	.even
elfpath:
_elfpath:
	 .ascii	"LIBS:ppc/xpkBZIP.elf\0"
	.even

/*=============================================================*/
/* DATA hunk — InitTable, functab, globals, strings, RomTag,   */
/* datatab, XpkMode records, XpkInfo                           */
/*=============================================================*/
	.data
	.globl	datapc, _datapc
datapc:
_datapc:
	.long	0x32			/* dataSize */
	.long	functab			/* -> +0x10 */
	.long	datatab			/* -> +0xec */
	.long	libinit			/* -> code  */

functab:				/* +0x10: 10 absolute longs + -1 */
	.long	libopen			/* -6  */
	.long	libclose		/* -12 */
	.long	libexpunge		/* -18 */
	.long	libnull			/* -24 */
	.long	packerinfo		/* -30 */
	.long	_XpksPackChunk		/* -36 */
	.long	_XpksPackFree		/* -42 */
	.long	libnull2		/* -48 */
	.long	_XpksUnpackChunk	/* -54 */
	.long	_XpksUnpackFree		/* -60 */
	.long	-1

	.space	0x48,0			/* +0x3c..+0x83 globals:
						   +60 lib, +120 SysBase,
						   +124 ppcbase */
libname:
	.ascii	"xpkBZIP.library\0"	/* +0x84 */
verstr:					/* +0x94 */
	.ascii	"$VER: xpkBZIP.library 41.2 (18.08.97) \251 by Andr\351 Osterhues\0"
	.byte	0			/* pad to +0xd0 */

/* exec Resident (RomTag) — rt_Init -> InitTable at +0x00 */
romtag:					/* +0xd0 */
	.word	0x4afc			/* RTC_MATCHWORD */
	.long	romtag			/* rt_MatchTag  */
	.long	dataend			/* rt_EndSkip   */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	41			/* rt_Version   */
	.byte	9			/* NT_LIBRARY   */
	.byte	2			/* rt_Pri       */
	.long	libname			/* rt_Name      */
	.long	verstr			/* rt_IdString  */
	.long	datapc			/* rt_Init      */
	.word	0			/* pad to +0xec */

/* InitStruct datatab — 24-bit-offset forms + 8-bit longs */
datatab:				/* +0xec */
	.byte	0xe0,0x00,0x00,0x08,0x09,0x00	/* byte@8  = 9 (type)   */
	.byte	0x80,0x0a
	.long	libname			/* long@10 = name       */
	.byte	0xe0,0x00,0x00,0x0e,0x06,0x00	/* byte@14 = 6 (flags)  */
	.byte	0xd0,0x00,0x00,0x14
	.word	41			/* word@20 = version    */
	.byte	0xd0,0x00,0x00,0x16
	.word	2			/* word@22 = revision   */
	.byte	0x80,0x18
	.long	verstr			/* long@24 = idstring   */
	.long	0

/* 10 XpkMode records (42 B each), chained BACKWARD via        */
/* xm_Next: each record points at the previous one; the        */
/* XpkInfo anchors the list at the last (" 100 K") record.     */
/* fields: next upto flags packmem unpackmem packspeed         */
/*         unpackspeed ratio chunksize name[6] (no NUL)        */
modes:
	.long	0
	.long	100, 0, 0x00810004, 0x005dc000, 43, 168
	.word	0x0297, 1000
	.ascii	"1000 K"
	.byte	0,0,0,0
	.long	modes
	.long	90, 0, 0x00748004, 0x00546000, 46, 166
	.word	0x0283, 900
	.ascii	" 900 K"
	.byte	0,0,0,0
	.long	modes+0x2a
	.long	80, 0, 0x00680004, 0x004b0000, 49, 164
	.word	0x0262, 800
	.ascii	" 800 K"
	.byte	0,0,0,0
	.long	modes+0x54
	.long	70, 0, 0x005b8004, 0x0041a000, 51, 166
	.word	0x0240, 700
	.ascii	" 700 K"
	.byte	0,0,0,0
	.long	modes+0x7e
	.long	60, 0, 0x004f0004, 0x00384000, 54, 164
	.word	0x0224, 600
	.ascii	" 600 K"
	.byte	0,0,0,0
	.long	modes+0xa8
	.long	50, 0, 0x00428004, 0x002ee000, 55, 161
	.word	0x0218, 500
	.ascii	" 500 K"
	.byte	0,0,0,0
	.long	modes+0xd2
	.long	40, 0, 0x00360004, 0x00258000, 59, 168
	.word	0x0214, 400
	.ascii	" 400 K"
	.byte	0,0,0,0
	.long	modes+0xfc
	.long	30, 0, 0x00298004, 0x001c2000, 61, 173
	.word	0x0211, 300
	.ascii	" 300 K"
	.byte	0,0,0,0
	.long	modes+0x126
	.long	20, 0, 0x001d0004, 0x0012c000, 65, 173
	.word	0x020d, 200
	.ascii	" 200 K"
	.byte	0,0,0,0
	.long	modes+0x150
	.long	10, 0, 0x00108004, 0x00096000, 72, 187
	.word	0x0203, 100
	.ascii	" 100 K"
	.byte	0,0,0,0

/* XpkInfo descriptor (88 B) — returned by -30 XpksPackerInfo */
	.globl	xpkinfo
xpkinfo:				/* +0x2b8 */
	.word	1, 1, 2, 1		/* xpkver/libver/mstver/modver */
	.long	bzipname		/* xi_Name -> "BZIP"        */
	.long	bziplong		/* xi_LongName              */
	.long	bzipdesc		/* xi_Description           */
	.long	0x425a4950		/* xi_ID 'BZIP'             */
	.long	0x8409			/* xi_Flags                 */
	.long	0xfa000			/* xi_MaxPkInChunk 1024000  */
	.long	0x64			/* xi_MinPkInChunk 100      */
	.long	0xfa000			/* xi_MaxPkOutChunk         */
	.long	pmsg			/* xi_PackMsg               */
	.long	umsg			/* xi_UnpackMsg             */
	.long	pkdmsg			/* xi_PackedMsg             */
	.long	upkdmsg			/* xi_UnpackedMsg           */
	.word	100			/* xi_DefMode               */
	.word	0
	.long	modes+0x17a		/* xi_ModeDesc -> last rec  */
	.space	24,0			/* +0x40..+0x57 zeros       */
dataend:
	.long	0			/* hunk tail pad (+0x310)  */
