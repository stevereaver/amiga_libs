/*
 * cyberlayers.library 40.8 -- byte-exact reconstruction, hunk0 (2116 B).
 * AUTOINIT RomTag; word-offset functab (leading -1 marker) of 4 vectors;
 * all code references are pc-relative, so every relocation lives in the
 * RomTag/InitTable/datatab/patchtab data words.
 *
 * initfn stores exec@+34 seglist@+38 layers@+42 gfx@+46 stub@+50 cgx@+54.
 * initctx copies the layers.library Resident into AllocVec'd RAM using a
 * *packed* 26-byte Resident view (MatchTag@2, EndSkip@6, Name@14,
 * IdString@18, Init@22), renames it "layersdummy.library", re-points its
 * self-references at the copy, InitResident()s it, then rewrites the
 * copy's `jmp pc@(d16)' tail-calls that land on the copy's -126 vector
 * target into `jsr a6@(-126)', and finally re-points all 32 layers
 * vectors (-30..-216) at the copy's jump-table contents.
 * _patchinstall then walks the {lvo,newfunc} table and SetFunctions the
 * six cyberlayers hooks into the real layers.library, writing the lib
 * base and the previous vector into each CYBL record (+0xa/+0xe).
 */
	.text
	.globl	_stub,_romtag,_name,_idstr,_layname,_cgxname,_gfxname
	.globl	_dmyname,_inittab,_functab,_datatab,_initfn,_initctx
	.globl	_patchinstall,_patchtab,_open,_close,_expunge,_extfunc
	.globl	_cybrec,_cybfn,_h1end

/* ==== 0x00 DOS stub ============================================== */
_stub:	moveq	#-1,%d0
	rts

/* ==== 0x04 RomTag ================================================ */
_romtag:
	.short	0x4afc
	.long	_romtag			/* matchtag -> h0+4  (reloc)      */
	.long	_h1end			/* endskip  -> h1+0x29c (reloc)   */
	.byte	0x80,40			/* RTF_AUTOINIT, version 40     */
	.byte	9,0			/* NT_LIBRARY, pri 0            */
	.long	_name			/* -> h0+0x1e (reloc)           */
	.long	_idstr			/* -> h0+0x32 (reloc)           */
	.long	_inittab		/* -> h0+0xc2 (reloc)           */

/* ==== 0x1e strings =============================================== */
_name:	.ascii	"cyberlayers.library\0"
_idstr:	.ascii	"cyberlayers.library 40.8 (02.01.96) \251 by Vision Factory Development\015\012\0"
_layname:
	.ascii	"layers.library\0"
_cgxname:
	.ascii	"cybergraphics.library\0"
_gfxname:
	.ascii	"graphics.library\0"
_dmyname:
	.ascii	"layersdummy.library\0"

/* ==== 0xc2 InitTable ============================================= */
_inittab:
	.long	0x76			/* lib dataSize = 118          */
	.long	_functab		/* -> h0+0xd2 (reloc)          */
	.long	_datatab		/* -> h0+0xde (reloc)          */
	.long	_initfn			/* -> h0+0xfe (reloc)          */

/* ==== 0xd2 functab: word-offset table (leading -1 marker) ======== */
_functab:
	.short	-1			/* relative-table flag         */
	.short	_open-_functab		/* 0x3e0 -> 0x4b2              */
	.short	_close-_functab		/* 0x3ee -> 0x4c0              */
	.short	_expunge-_functab	/* 0x402 -> 0x4d4              */
	.short	_extfunc-_functab	/* 0x448 -> 0x51a              */
	.short	-1

/* ==== 0xde datatab =============================================== */
_datatab:
	.short	0xa008,0x0900		/* initbyte +8  ln_Type = 9    */
	.short	0x800a
	.long	_name			/* initlong +10 ln_Name (reloc)*/
	.short	0xa00e,0x0600		/* initbyte +14 ln_Flags = 6   */
	.short	0x9014,0x0028		/* initword +20 lib_Ver = 40   */
	.short	0x9016,0x0008		/* initword +22 lib_Rev = 8    */
	.short	0x8018
	.long	_idstr			/* initlong +24 lib_Id (reloc) */
	.short	0,0			/* end + pad                   */

/* ==== 0xfe initfn: d0=libbase, a0=seglist, a6=exec ================ */
_initfn:
	moveml	%d1/%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(34)		/* lib+34 = SysBase            */
	movel	%a0,%a5@(38)		/* lib+38 = seglist            */
	lea	_layname(%pc),%a1
	moveq	#39,%d0
	jsr	%a6@(-552)		/* OpenLibrary(layers,39)      */
	movel	%d0,%a5@(42)		/* lib+42 = layers base        */
	lea	_gfxname(%pc),%a1
	moveq	#39,%d0
	jsr	%a6@(-552)
	movel	%d0,%a5@(46)		/* lib+46 = graphics base      */
	lea	_cgxname(%pc),%a1
	moveq	#40,%d0
	jsr	%a6@(-552)
	movel	%d0,%a5@(54)		/* lib+54 = cybergraphics base */
	beqw	_ifail			/* fail -> rts w/o restore(!)  */
	lea	_extfunc(%pc),%a0
	movel	%a0,%a5@(50)		/* lib+50 = extfunc stub       */
	bsrw	_initctx
	bsrw	_patchinstall
	movel	%a5,%d0
	moveml	%sp@+,%d1/%a5
_ifail:	rts

/* ==== 0x152 initctx: copy layers resident + re-point vectors ===== */
_initctx:
	moveml	%d0-%a6,%sp@-
	moveal	4:w,%a6			/* SysBase                     */
	cmpiw	#39,%a6@(20)		/* exec lib_Version >= 39 ?    */
	bltw	_icfail
	lea	_layname(%pc),%a1
	jsr	%a6@(-96)		/* FindResident("layers.library") */
	tstl	%d0
	beqw	_icfail
	moveal	%d0,%a4			/* a4 = layers Resident        */
	movel	%a4@(6),%d0		/* packed pr_EndSkip @6        */
	subl	%a4,%d0			/* size = endskip - resident   */
	movel	%d0,%d2
	moveq	#1,%d1			/* MEMF_PUBLIC                 */
	jsr	%a6@(-684)		/* AllocVec(size,PUBLIC)       */
	tstl	%d0
	beqw	_icfail
	moveal	%d0,%a2			/* a2 = copy                   */
	moveal	%a4,%a0
	moveal	%a2,%a1
	movel	%d2,%d0
	jsr	%a6@(-624)		/* CopyMem(res,copy,size)      */
	movel	%a2,%a2@(2)		/* copy.pr_MatchTag @2 = copy  */
	movel	%a2,%d0
	addl	%d2,%d0
	movel	%d0,%a2@(6)		/* copy.pr_EndSkip @6          */
	lea	_dmyname(%pc),%a0
	movel	%a0,%a2@(14)		/* copy.pr_Name = "layersdummy.library" */
	movel	%a2@(18),%d0		/* re-point pr_IdString @18    */
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a2@(18)
	movel	%a2@(22),%d0		/* re-point pr_Init @22        */
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a2@(22)
	moveal	%d0,%a1			/* a1 = copy init entry        */
	movel	%a1@(4),%d0		/* re-point 4 longs inside it  */
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a1@(4)
	movel	%a1@(8),%d0
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a1@(8)
	movel	%a1@(12),%d0
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a1@(12)
	movel	%a1@(40),%d0
	subl	%a4,%d0
	addl	%a2,%d0
	movel	%d0,%a1@(40)
	moveal	%a2,%a1
	moveq	#0,%d1
	jsr	%a6@(-102)		/* InitResident(copy,seg=0)    */
	moveal	%d0,%a5			/* a5 = layersdummy base       */
	moveq	#0,%d0
	lea	_layname(%pc),%a1
	jsr	%a6@(-552)		/* OpenLibrary("layers.library") */
	tstl	%d0
	beqw	_icfail
	moveal	%d0,%a3			/* a3 = original layers base   */
	movel	%a5@(-124),%d1		/* copy's -126 vector target   */
	moveal	%a2,%a0
	lea	%a2@(0,%d2:l),%a1	/* a1 = copy end               */
_scan:	movew	%a0@+,%d0
	.short	0xb07c,0x4eba		/* cmpw #0x4eba,d0 (jmp pc@d16) */
	bnes	_scannxt
	movew	%a0@,%d0
	extl	%d0
	addl	%a0,%d0			/* target = pos + disp         */
	cmpl	%d1,%d0			/* == copy's -126 target ?     */
	beqs	_found
_scannxt:
	cmpal	%a0,%a1
	bhis	_scan
	braw	_icclose		/* not found -> close+fail     */
_found:	movew	#-126,%a0@		/* rewrite to `jsr a6@(-126)'  */
	movew	#0x4eae,%a0@(-2)
	jsr	%a6@(-636)		/* CacheClearU                 */
	jsr	%a6@(-132)		/* Forbid                      */
/* re-point every layers vector -30..-216 at the copy's vector target */
	movel	%a5@(-28),%d0
	moveal	%a3,%a1
	moveal	#-30,%a0
	jsr	%a6@(-420)
	movel	%a5@(-34),%d0
	moveal	%a3,%a1
	moveal	#-36,%a0
	jsr	%a6@(-420)
	movel	%a5@(-40),%d0
	moveal	%a3,%a1
	moveal	#-42,%a0
	jsr	%a6@(-420)
	movel	%a5@(-46),%d0
	moveal	%a3,%a1
	moveal	#-48,%a0
	jsr	%a6@(-420)
	movel	%a5@(-52),%d0
	moveal	%a3,%a1
	moveal	#-54,%a0
	jsr	%a6@(-420)
	movel	%a5@(-58),%d0
	moveal	%a3,%a1
	moveal	#-60,%a0
	jsr	%a6@(-420)
	movel	%a5@(-64),%d0
	moveal	%a3,%a1
	moveal	#-66,%a0
	jsr	%a6@(-420)
	movel	%a5@(-70),%d0
	moveal	%a3,%a1
	moveal	#-72,%a0
	jsr	%a6@(-420)
	movel	%a5@(-76),%d0
	moveal	%a3,%a1
	moveal	#-78,%a0
	jsr	%a6@(-420)
	movel	%a5@(-82),%d0
	moveal	%a3,%a1
	moveal	#-84,%a0
	jsr	%a6@(-420)
	movel	%a5@(-88),%d0
	moveal	%a3,%a1
	moveal	#-90,%a0
	jsr	%a6@(-420)
	movel	%a5@(-94),%d0
	moveal	%a3,%a1
	moveal	#-96,%a0
	jsr	%a6@(-420)
	movel	%a5@(-100),%d0
	moveal	%a3,%a1
	moveal	#-102,%a0
	jsr	%a6@(-420)
	movel	%a5@(-106),%d0
	moveal	%a3,%a1
	moveal	#-108,%a0
	jsr	%a6@(-420)
	movel	%a5@(-112),%d0
	moveal	%a3,%a1
	moveal	#-114,%a0
	jsr	%a6@(-420)
	movel	%a5@(-118),%d0
	moveal	%a3,%a1
	moveal	#-120,%a0
	jsr	%a6@(-420)
	movel	%a5@(-124),%d0
	moveal	%a3,%a1
	moveal	#-126,%a0
	jsr	%a6@(-420)
	movel	%a5@(-130),%d0
	moveal	%a3,%a1
	moveal	#-132,%a0
	jsr	%a6@(-420)
	movel	%a5@(-136),%d0
	moveal	%a3,%a1
	moveal	#-138,%a0
	jsr	%a6@(-420)
	movel	%a5@(-142),%d0
	moveal	%a3,%a1
	moveal	#-144,%a0
	jsr	%a6@(-420)
	movel	%a5@(-148),%d0
	moveal	%a3,%a1
	moveal	#-150,%a0
	jsr	%a6@(-420)
	movel	%a5@(-154),%d0
	moveal	%a3,%a1
	moveal	#-156,%a0
	jsr	%a6@(-420)
	movel	%a5@(-160),%d0
	moveal	%a3,%a1
	moveal	#-162,%a0
	jsr	%a6@(-420)
	movel	%a5@(-166),%d0
	moveal	%a3,%a1
	moveal	#-168,%a0
	jsr	%a6@(-420)
	movel	%a5@(-172),%d0
	moveal	%a3,%a1
	moveal	#-174,%a0
	jsr	%a6@(-420)
	movel	%a5@(-178),%d0
	moveal	%a3,%a1
	moveal	#-180,%a0
	jsr	%a6@(-420)
	movel	%a5@(-184),%d0
	moveal	%a3,%a1
	moveal	#-186,%a0
	jsr	%a6@(-420)
	movel	%a5@(-190),%d0
	moveal	%a3,%a1
	moveal	#-192,%a0
	jsr	%a6@(-420)
	movel	%a5@(-196),%d0
	moveal	%a3,%a1
	moveal	#-198,%a0
	jsr	%a6@(-420)
	movel	%a5@(-202),%d0
	moveal	%a3,%a1
	moveal	#-204,%a0
	jsr	%a6@(-420)
	movel	%a5@(-208),%d0
	moveal	%a3,%a1
	moveal	#-210,%a0
	jsr	%a6@(-420)
	movel	%a5@(-214),%d0
	moveal	%a3,%a1
	moveal	#-216,%a0
	jsr	%a6@(-420)
	jsr	%a6@(-138)		/* Permit                      */
_icclose:
	moveal	%a3,%a1
	jsr	%a6@(-414)		/* CloseLibrary(layers)        */
_icfail:
	moveml	%sp@+,%d0-%a6
	rts

/* ==== 0x454 patchinstall: SetFunction the CYBL hooks ============= */
_patchinstall:
	moveml	%a2-%a3,%sp@-
	lea	_patchtab(%pc),%a2
_piloop:
	movew	%a2@+,%d0		/* lvo word                    */
	beqs	_pidone			/* 0 -> done                   */
	moveaw	%d0,%a0
	movel	%a2@,%d0		/* new function (reloc'd)      */
	moveal	%a5@(42),%a1		/* layers base                 */
	addqw	#4,%a2
	moveal	%d0,%a3
	movew	%a3@(-14),%d1		/* record version word (39)    */
	cmpw	%a6@(20),%d1		/* > exec version -> stop      */
	bgts	_pidone
	moveal	4:w,%a6			/* SysBase                     */
	jsr	%a6@(-420)		/* SetFunction(layers,lvo,new) */
	movel	%d0,%a3@-		/* func-4 = old vector         */
	movel	%a5,%a3@-		/* func-8 = cyberlayers base   */
	braw	_piloop
_pidone:
	moveml	%sp@+,%a2-%a3
	rts

/* ==== 0x48c patchtab: {lvo.w, func.l} entries + 0 terminator ===== */
_patchtab:
	.short	-36
	.long	_h1f1			/* h1+0x12  CreateUpfrontLayer */
	.short	-186
	.long	_h1f2			/* h1+0x2e  CreateUpfrontHookLayer */
	.short	-60
	.long	_h1f3			/* h1+0xe4  MoveLayer          */
	.short	-180
	.long	_h1f5			/* h1+0x130 MoveSizeLayer      */
	.short	-66
	.long	_h1f4			/* h1+0x108 SizeLayer          */
	.short	-126
	.long	_cybfn			/* h0+0x530 SwapBitsRastPortClipRect */
	.short	0

/* ==== 0x4b2 -6 Open ============================================== */
_open:	addqw	#1,%a6@(32)		/* lib_OpenCnt++               */
	bclr	#3,%a6@(14)		/* clear private DELEXP bit    */
	movel	%a6,%d0
	rts

/* ==== 0x4c0 -12 Close ============================================ */
_close:	moveq	#0,%d0
	subqw	#1,%a6@(32)		/* lib_OpenCnt--               */
	bnes	_cldone
	btst	#3,%a6@(14)
	beqs	_cldone
	bsrs	_expunge
_cldone:
	rts

/* ==== 0x4d4 -18 Expunge ========================================== */
_expunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	tstw	%a5@(32)
	beqs	_exdo
	bset	#3,%a5@(14)		/* set private DELEXP bit      */
	moveq	#0,%d0
	bras	_exdone
_exdo:	movel	%a5@(38),%d2		/* seglist                     */
	moveal	%a5,%a1
	.short	0x2c79,0,4		/* moveal 4:l,a6  SysBase      */
	jsr	%a6@(-252)		/* Remove                      */
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0		/* lib_NegSize                 */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + lib_PosSize               */
	.short	0x2c79,0,4		/* moveal 4:l,a6               */
	jsr	%a6@(-210)		/* FreeMem                     */
	movel	%d2,%d0
_exdone:
	moveml	%sp@+,%d2/%a5-%a6
	rts

/* ==== 0x51a -24 ExtFunc stub ===================================== */
_extfunc:
	moveq	#0,%d0
	rts

/* ==== 0x51e CYBL record + new SwapBitsRastPortClipRect =========== */
_cybrec:
	.ascii	"CYBL"
	.short	0x27			/* required exec version 39    */
	.short	1,0
	.long	0			/* +0xa libbase slot (@0x528)  */
	.long	0			/* +0xe oldvec slot (@0x52c)   */

/* a0 = rastport, a1 = cliprect, a6 = layers base */
_cybfn:	moveml	%a2-%a3,%sp@-		/* 0x530                       */
	moveal	%a0@(4),%a2		/* rp->BitMap                  */
	btst	#0,%a2@(1)		/* bm+1 bit0 (native?)         */
	beqw	_sb_orig
	moveal	%a1@(12),%a2		/* cr->BitMap                  */
	btst	#0,%a2@(1)
	beqw	_sb_cache		/* not native -> cache path    */
	cmpil	#0x43594252,%a2@(36)	/* 'CYBR' magic @ bm+36 ?      */
	beqs	_sb_cgx
	moveal	4:w,%a2			/* SysBase                     */
	btst	#3,%a2@(297)		/* AttnFlags AFB_68020         */
	beqw	_sb_orig
_sb_cgx:
	moveml	%d0-%a2/%a6,%sp@-
	moveal	_cybrec+10(%pc),%a6	/* a6 = cyberlayers base       */
	moveal	%a6@(54),%a6		/* cybergraphics base          */
	moveal	%a1,%a2			/* a2 = cliprect               */
	moveal	%a0@(4),%a0		/* a0 = rp->BitMap             */
	moveal	%a1@(12),%a1		/* a1 = cr->BitMap             */
	movew	%a2@(16),%d0		/* cr bounds x0                */
	movew	%a2@(18),%d1		/* y0                          */
	movew	%d0,%d2
	andiw	#15,%d2			/* x0 & 15                     */
	moveq	#0,%d3
	movew	%a2@(20),%d4		/* x1                          */
	subw	%a2@(16),%d4
	addqw	#1,%d4			/* width                       */
	movew	%a2@(22),%d5		/* y1                          */
	subw	%a2@(18),%d5
	addqw	#1,%d5			/* height                      */
	moveq	#2,%d6
	jsr	%a6@(-84)		/* cybergfx call               */
	moveml	%sp@+,%d0-%a2/%a6
	moveml	%sp@+,%a2-%a3
	rts

/* ==== 0x5b2 dead/unreached helper variant ======================== */
_sbdead:
	moveml	%d0-%a4/%a6,%sp@-
	moveal	%a1,%a2
	moveal	%a0,%a3
	movew	%a2@(16),%d0
	extl	%d0
	movew	%a2@(18),%d1
	extl	%d1
	movel	%d0,%d3
	movew	%a2@(20),%d4
	extl	%d4
	subl	%d3,%d4
	addql	#1,%d4
	movel	%d1,%d3
	movew	%a2@(22),%d5
	extl	%d5
	subl	%d3,%d5
	addql	#1,%d5
	moveml	%d0-%d3/%a6,%sp@-
	movew	%d4,%d0
	addiw	#15,%d0
	andiw	#-16,%d0
	movew	%d5,%d1
	moveq	#8,%d2
	moveq	#16,%d3
	moveal	%a3@(4),%a0
	moveal	%a6@(34),%a6		/* *(a6+34) engine base        */
	jsr	%a6@(-918)
	tstl	%d0
	bnes	_sbd_ok
	moveml	%sp@+,%d0-%d3/%a6
	moveml	%sp@+,%d0-%a3/%a6
	braw	_sb_orig
_sbd_ok:
	moveal	%d0,%a4
	moveal	%a4,%a1
	moveal	%a2@(12),%a0		/* cr->BitMap                  */
	moveml	%sp@,%d0-%d3/%a6	/* peek saved regs             */
	moveq	#0,%d1
	moveq	#0,%d2
	movew	%d2,%d3
	movew	#0xc0,%d6
	moveq	#-1,%d7
	moveal	%a6@(34),%a6
	jsr	%a6@(-30)
	moveal	_cybrec+10(%pc),%a6
	moveal	%a6@(54),%a6		/* cybergraphics base          */
	moveal	%a1,%a2
	moveal	%a0@(4),%a0
	moveal	%a1@(12),%a1
	movew	%a2@(16),%d0
	movew	%a2@(18),%d1
	movew	%d0,%d2
	andiw	#15,%d2
	moveq	#0,%d3
	movew	%a2@(20),%d4
	subw	%a2@(16),%d4
	addqw	#1,%d4
	movew	%a2@(22),%d5
	subw	%a2@(18),%d5
	addqw	#1,%d5
	moveq	#2,%d6
	jsr	%a6@(-84)
	moveal	%a4,%a0
	moveal	%a6@(34),%a6
	jsr	%a6@(-924)
	moveml	%sp@+,%d0-%a4/%a6
	rts

/* ==== 0x67a cache path: 30-entry {bitmap,buffer} table @lib+58 ==== */
_sb_cache:
	moveq	#29,%d0
	moveal	_cybrec+10(%pc),%a2	/* a2 = cyberlayers base       */
	lea	%a2@(58),%a2		/* table @ lib+58              */
	moveal	%a1@(12),%a3		/* a3 = cr->BitMap             */
_cscan:	cmpal	%a2@,%a3		/* slot bitmap == cr->bm ?     */
	beqs	_sb_hit
	addql	#8,%a2
	dbf	%d0,_cscan
	movel	%a4,%sp@-
	moveal	_cybrec+10(%pc),%a4
	lea	%a4@(58),%a4
	moveq	#29,%d0
_fscan:	tstl	%a4@			/* empty slot ?                */
	beqs	_sb_slot
	addql	#8,%a4
	dbf	%d0,_fscan
	tstl	%a4@
	beqs	_sb_slot
	moveml	%d0-%d1/%a0-%a1/%a6,%sp@- /* table full -> evict */
	moveal	%a4@(4),%a0
	clrl	%a4@
	moveal	%a6@(34),%a6
	jsr	%a6@(-924)		/* free old buffer             */
	moveml	%sp@+,%d0-%d1/%a0-%a1/%a6
_sb_slot:
	moveal	%a0,%a3
	moveal	%a1,%a2
	bsrw	_sb_alloc		/* 0x740: alloc native buffer  */
	moveal	%a3,%a0
	moveal	%a2,%a1
	bsrw	_sb_fill		/* 0x7da: convert cr->bm       */
	movel	%a2@(12),%a4@		/* slot.bitmap = cr->BitMap    */
	moveal	%sp@+,%a4
	moveml	%sp@+,%a2-%a3
	rts

/* ==== 0x6de hit: use cached buffer then free it ================== */
_sb_hit:
	clrl	%a2@			/* clear slot bitmap           */
	moveml	%d0-%a6,%sp@-
	moveal	%a1,%a3			/* a3 = cliprect               */
	moveal	%a0@(4),%a1		/* a1 = rp->BitMap             */
	moveal	%a2@(4),%a0		/* a0 = slot buffer            */
	movew	%a3@(16),%d2
	extl	%d2
	movew	%a3@(18),%d3
	extl	%d3
	movew	%a3@(20),%d4
	extl	%d4
	subl	%d2,%d4
	addql	#1,%d4			/* width                       */
	movew	%a3@(22),%d5
	extl	%d5
	subl	%d3,%d5
	addql	#1,%d5			/* height                      */
	moveal	%a6@(34),%a6
	moveq	#-1,%d7
	moveq	#0,%d0
	moveq	#0,%d1
	movew	#0xc0,%d6
	jsr	%a6@(-30)		/* convert buffer->bm          */
	moveal	%a2@(4),%a0
	clrl	%a2@(4)
	jsr	%a6@(-924)		/* free buffer                 */
	moveml	%sp@+,%d0-%a6
	moveml	%sp@+,%a2-%a3
	rts

/* ==== 0x736 fall back to original vector ========================= */
_sb_orig:
	moveml	%sp@+,%a2-%a3
	movel	_cybrec+14(%pc),%sp@-	/* push saved old vector       */
	rts

/* ==== 0x740 _sb_alloc(a0=rp-like, a1=cr) ========================== */
_sb_alloc:
	moveml	%d2-%d7/%a2-%a3/%a6,%sp@-
	movew	%a2@(16),%d0
	extl	%d0
	movew	%a2@(18),%d1
	extl	%d1
	movel	%d0,%d3
	movew	%a2@(20),%d4
	extl	%d4
	subl	%d3,%d4
	addql	#1,%d4			/* width                       */
	movel	%d1,%d3
	movew	%a2@(22),%d5
	extl	%d5
	subl	%d3,%d5
	addql	#1,%d5			/* height                      */
	moveml	%d7/%a2/%a6,%sp@-
	moveml	%d0-%d3/%a6,%sp@-
	movew	%d4,%d0
	addiw	#15,%d0
	andiw	#-16,%d0		/* width rounded to 16         */
	movew	%d5,%d1			/* height                      */
	moveq	#8,%d2
	moveq	#16,%d3
	moveal	%a3@(4),%a0
	moveal	%a6@(34),%a6
	jsr	%a6@(-918)		/* alloc buffer                */
	tstl	%d0
	bnes	_alok
	moveml	%sp@+,%d0-%d3/%a6
	moveml	%sp@+,%d7/%a2/%a6
	moveml	%sp@+,%d2-%d7/%a2-%a3/%a6
	addql	#4,%sp			/* drop bsr return             */
	moveal	%sp@+,%a4		/* caller's saved a4           */
	moveal	%a2,%a1
	moveal	%a3,%a0
	moveml	%sp@+,%a2-%a3
	movel	_cybrec+14(%pc),%sp@-	/* tail-call original          */
	rts
_alok:	moveal	%d0,%a1
	movel	%d0,%a4@(4)		/* slot.buffer = d0            */
	moveml	%sp@+,%d0-%d3/%a6
	moveal	%a3@(4),%a0
	moveq	#0,%d2
	moveq	#0,%d3
	moveal	%a6@(34),%a6
	moveq	#-1,%d7
	subal	%a2,%a2
	movew	#0xc0,%d6
	jsr	%a6@(-30)
	moveml	%sp@+,%d7/%a2/%a6
	moveml	%sp@+,%d2-%d7/%a2-%a3/%a6
	rts

/* ==== 0x7da _sb_fill(a0=rp, a1=cr) ================================ */
_sb_fill:
	linkw	%a5,#-12
	moveml	%d2-%d7/%a2-%a3/%a6,%sp@-
	moveal	%a0,%a3			/* a3 = rastport               */
	moveal	%a1,%a2			/* a2 = cliprect               */
	movew	%a2@(16),%d0		/* x0                          */
	extl	%d0
	movel	%d0,%d1
	moveq	#15,%d2
	andl	%d2,%d0			/* d0 = x0 & 15                */
	movew	%a2@(18),%d2		/* y0                          */
	extl	%d2
	movel	%d1,%d3
	movew	%a2@(20),%d4		/* x1                          */
	extl	%d4
	subl	%d3,%d4
	addql	#1,%d4			/* width                       */
	movel	%d2,%d3
	movew	%a2@(22),%d5		/* y1                          */
	extl	%d5
	subl	%d3,%d5
	addql	#1,%d5			/* height                      */
	moveml	%d7/%a2/%a6,%sp@-
	movel	%d2,%sp@(56)		/* stash y0                    */
	movel	%d1,%d2			/* d2 = x0                     */
	movew	#0xc0,%d6
	moveal	%a2@(12),%a0		/* a0 = cr->BitMap             */
	moveq	#0,%d1
	moveal	%a3@(4),%a1		/* a1 = rp->BitMap             */
	movel	%sp@(56),%d3		/* d3 = y0                     */
	moveal	%a6@(34),%a6
	moveq	#-1,%d7
	subal	%a2,%a2
	jsr	%a6@(-30)
	moveml	%sp@+,%d7/%a2/%a6
	moveml	%sp@+,%d2-%d7/%a2-%a3/%a6
	unlk	%a5
	rts
