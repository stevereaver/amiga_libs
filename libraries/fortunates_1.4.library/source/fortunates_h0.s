/*
 * fortunates.library 1.4 -- hunk 0: CODE, byte-exact.
 * 'fortunates 1.4 (08.06.97)'; 3 hunks: h0 CODE 2516B, h1 DATA 16B
 * ("Select a file.."), h2 BSS 152B (global base cells).
 * AUTOINIT RomTag; InitTable @0xda {dsize 0x30, ftab 0xea (17 abs
 * entries), dtab 0x132, initfn 0x152}.
 * BSS map: +0 execbase(copy of $4), +4 dos, +8 intuition, +0xc gfx,
 * +0x10 gadtools, +0x14 icon, +0x18 diskfont, +0x1c asl,
 * +0x20 reqtools, +0x24 workbench, +0x28 scratch, +0x2c.. misc.
 */
	.text

_stub:	moveq	#-1,%d0
	rts

/* ---- RomTag ------------------------------------------------------ */
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_end			/* endskip -> h0+0x9d2 */
	.byte	0x80,1,9,0		/* AUTOINIT, v1, NT_LIBRARY, 0 */
	.long	_name
	.long	_idstr
	.long	_inittab

_name:	.ascii	"fortunates.library"
	.byte	0
_idstr:	.ascii	"fortunates 1.4 (08.06.97)\r\n"
	.byte	0
_dosnam: .ascii	"dos.library"
	.byte	0
_intnam: .ascii	"intuition.library"
	.byte	0
_gfxnam: .ascii	"graphics.library"
	.byte	0
_gadnam: .ascii	"gadtools.library"
	.byte	0
_iconnam: .ascii	"icon.library"
	.byte	0
_dfnam:	.ascii	"diskfont.library"
	.byte	0
_aslnam: .ascii	"asl.library"
	.byte	0
_rqnam:	.ascii	"reqtools.library"
	.byte	0
_wbnam:	.ascii	"workbench.library"
	.byte	0

/* ---- InitTable @0xda --------------------------------------------- */
_inittab:
	.long	0x30			/* dsize */
	.long	_functab		/* -> 0xea */
	.long	_datatab		/* -> 0x132 */
	.long	_initfn			/* -> 0x152 */

_functab:				/* 0xea: 17 absolute entries */
	.long	_open,_close,_expunge,_nullv
	.long	_availmemcmp,_bssptr,_loadfile,_findtag
	.long	_reqfortune,_shiftbit,_penmetric,_unpackrow
	.long	_unpackcol,_interleave,_interleave2,_makebody
	.long	_makeimg
	.long	0xffffffff		/* abs-long functab terminator */

_datatab:				/* @0x132 InitStruct data */
	.short	0xa008,0x0900		/* initbyte +8  type=9 */
	.short	0x800a
	.long	_name			/* initlong +10 ln_Name */
	.short	0xa00e,0x0600		/* initbyte +14 flags=6 */
	.short	0x9014,0x0001		/* initword +20 ver=1 */
	.short	0x9016,0x0004		/* initword +22 rev=4 */
	.short	0x8018
	.long	_idstr			/* initlong +24 ln_IdString */
	.short	0,0

/* ---- initfn @0x152 ----------------------------------------------- */
_initfn:
	movel	%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(36)
	movel	%a0,%a5@(44)
	lea	_dosnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,%a5@(40)
	movel	%d0,_bss+4		/* h2+4 = dosbase */
	movel	4:w,_bss+0		/* h2+0 = SysBase copy */
	lea	_intnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+8
	lea	_gfxnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+12
	lea	_gadnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+16
	lea	_iconnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+20
	lea	_dfnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+24
	lea	_aslnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+28
	lea	_rqnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+32
	lea	_wbnam(%pc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)
	movel	%d0,_bss+36
	bnes	_iok
	moveml	%d7/%a5-%a6,%sp@-
	movel	#0x38007,%d7
	.short	0x2c79,0x0000,0x0004	/* moveal ($4).l,a6 -- SysBase */
	jsr	%a6@(-108)		/* Alert(AN_Unknown|AG_OpenLib) */
	moveml	%sp@+,%d7/%a5-%a6
_iok:	movel	%a5,%d0
	moveal	%sp@+,%a5
	rts

/* ---- -6 Open @0x21a ---------------------------------------------- */
_open:	addqw	#1,%a6@(32)
	bclr	#3,%a6@(34)
	movel	%a6,%d0
	rts

/* ---- -12 Close @0x228 -------------------------------------------- */
_close:	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	_cd
	btst	#3,%a6@(34)
	beqs	_cd
	bsrs	_expunge
_cd:	rts

/* ---- -18 Expunge @0x23c ------------------------------------------ */
_expunge:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(36),%a6
	tstw	%a5@(32)
	beqs	_eg
	bset	#3,%a5@(34)
	moveq	#0,%d0
	bras	_er
_eg:	movel	%a5@(44),%d2
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove */
	moveal	%a5@(40),%a1
	jsr	%a6@(-414)		/* CloseLibrary(dos) */
	moveal	_bss+8,%a1
	jsr	%a6@(-414)
	moveal	_bss+12,%a1
	jsr	%a6@(-414)
	moveal	_bss+16,%a1
	jsr	%a6@(-414)
	moveal	_bss+20,%a1
	jsr	%a6@(-414)
	moveal	_bss+24,%a1
	jsr	%a6@(-414)
	moveal	_bss+28,%a1
	jsr	%a6@(-414)
	moveal	_bss+32,%a1
	jsr	%a6@(-414)
	moveal	_bss+36,%a1
	jsr	%a6@(-414)
	moveq	#0,%d0
	moveal	%a5,%a1
	movew	%a5@(16),%d0
	subal	%d0,%a1
	addw	%a5@(18),%d0
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d2,%d0
_er:	moveml	%sp@+,%d2/%a5-%a6
	rts

/* ---- -24 null @0x2d2 ---------------------------------------------- */
_nullv:	moveq	#0,%d0
	rts

/* ---- -30 @0x2d6: max(AvailMem(0x20004),AvailMem(0x20002)) ---------- */
_availmemcmp:
	movel	#0x20004,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-216)		/* AvailMem(FAST|LARGEST) */
	movel	%d0,%sp@-
	movel	#0x20002,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-216)		/* AvailMem(CHIP|LARGEST) */
	movel	%sp@+,%d1
	cmpl	%d0,%d1
	bles	_am2
	movel	%d1,%d0
	moveq	#0,%d1
	bras	_am3
_am2:	moveq	#1,%d1
_am3:	rts

/* ---- -36 @0x308: return &bss+4 (dosbase cell) --------------------- */
_bssptr:
	lea	_bss+4,%a0
	rts

/* ---- -42 @0x310: load FORM/RGB8 file ------------------------------
 * error exits: Open-fail -> 0x44c straight to return (no Close --
 * nothing was opened); all later fails -> 0x434 FreeVec+Close+ret.
 */
_loadfile:
	movel	#1005,%d2		/* MODE_OLDFILE */
	moveal	_bss+4,%a6
	jsr	%a6@(-30)		/* dos Open */
	movel	%d0,%d6
	bnes	_lf1
	moveq	#1,%d7
	braw	_lfret
_lf1:	movel	#0x1000,%d0
	movel	#0x10001,%d1		/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	_bss+0,%a6
	jsr	%a6@(-684)		/* AllocVec */
	tstl	%d0
	bnes	_lf2
	moveq	#2,%d7
	braw	_lfcls			/* no buf yet: skip FreeVec, still Close */
_lf2:	moveal	%d0,%a2
	moveal	%a2,%a3
	addal	#12,%a3
	movel	%d6,%d1
	movel	%a2,%d2
	.short	0x263c,0,12		/* movel #12,d3 (not moveq!) */
	moveal	_bss+4,%a6
	jsr	%a6@(-42)		/* dos Read (12B header) */
	cmpil	#12,%d0
	beqs	_lf3
	moveq	#3,%d7
	braw	_lffree
_lf3:	.short	0x0caa,0x464f,0x524d,0x0000	/* cmpil #'FORM',a2@(0) */
	beqs	_lf4
	moveq	#4,%d7
	braw	_lffree
_lf4:	movel	%a2@(4),%d4		/* form size */
	subql	#4,%d4
	movel	%a2@(8),%a3@+		/* 'RGB8' -> buf+12 */
	.short	0x2a3c,0,12		/* movel #12,d5 */
_lfrd:	movel	%d6,%d1
	movel	%a2,%d2
	moveq	#8,%d3
	moveal	_bss+4,%a6
	jsr	%a6@(-42)		/* Read chunk hdr */
	cmpil	#8,%d0
	beqs	_lf5
	moveq	#3,%d7
	braw	_lffree
_lf5:	movel	%a2@(4),%d0
	btst	#0,%d0
	beqs	_lf6
	addql	#1,%d0
	movel	%d0,%a2@(4)
_lf6:	subql	#8,%d4
	.short	0x26ea,0x0000		/* movel a2@(0),a3@+ */
	movel	%d5,%a3@+
	subl	%a2@(4),%d4
	bles	_lfdone
	addl	%a2@(4),%d5
	addql	#8,%d5
	bnes	_lfnext
_lfdone:
	moveq	#0,%d7
	braw	_lfsz
_lfnext:
	movel	%d6,%d1
	movel	%a2@(4),%d2
	.short	0x263c,0,0		/* movel #0,d3 (not moveq!) */
	moveal	_bss+4,%a6
	jsr	%a6@(-66)		/* Seek(cur+size) */
	bras	_lfrd
_lfsz:	movel	%a3,%d0
	subl	%a2,%d0
	subil	#8,%d0
	moveml	%d0/%a3,%sp@-
	movel	#0x10001,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-684)		/* AllocVec(payload) */
	movel	%d0,%d1
	bnes	_lf7
	moveq	#2,%d7
	bras	_lffree
_lf7:	moveml	%sp@+,%d0/%a3
	subql	#4,%d0
	subal	%d0,%a3
	moveal	%d1,%a0
	lsrl	#2,%d0
	subql	#1,%d0
	movel	%a0,%d5
_lfcp:	movel	%a3@+,%a0@+
	dbf	%d0,_lfcp
_lffree:
	moveal	%a2,%a1
	moveal	_bss+0,%a6
	jsr	%a6@(-690)		/* FreeVec */
_lfcls:	movel	%d6,%d1
	moveal	_bss+4,%a6
	jsr	%a6@(-36)		/* dos Close */
_lfret:
	movel	%d7,%d0
	movel	%d5,%d1
	rts

/* ---- -48 @0x452: tag list scan {key,val} for d0 -------------------- */
_findtag:
	addql	#4,%a0
	movel	%a0@+,%d1
	bnes	_ftc
	moveq	#-1,%d0
	bras	_ftr
_ftc:	cmpl	%d0,%d1
	beqs	_ftg
	bras	_findtag
_ftg:	movel	%a0@+,%d0
_ftr:	rts

/* ---- -54 @0x466: reqtools file requester --------------------------- */
_reqfortune:
	movel	%a0,%sp@-
	.short	0x203c,0,64		/* movel #64,d0 */
	movel	#0x10001,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-684)		/* AllocVec(64) */
	moveal	%sp@+,%a0
	moveal	%d0,%a1
	movel	%a1,%d4
	movel	%d4,%d6
	movel	%a0@(4),%d0
	beqs	_r1
	movel	#0x80000033,%a1@+	/* tag 0x33 + val */
	movel	%d0,%a1@+
_r1:	moveal	%d4,%a1
	addal	#32,%a1
	movel	%a1,%d4
	.short	0x2028,0x0000		/* movel a0@(0),d0 */
	beqs	_r2
	movel	#0x80000001,%a1@+
	movel	%d0,%a1@+
_r2:	tstb	%a0@(8)
	beqs	_r3
	movel	#0x8000000a,%a1@+
	movel	#-1,%a1@+
_r3:	movel	#0x80000003,%a1@+
	movel	#0,%a1@+
	movel	#0x80000028,%a1@+
	movel	#16,%a1@
	tstb	%a0@(9)
	beqs	_r4
	oril	#1,%a1@
	.short	0x4eb9			/* jsr abs.l */
	.long	_f5ba			/* relocated 0x5ba */
	movel	%d0,%d7
	rts
_r4:	.short	0x203c,0,0		/* movel #0,d0 */
	subal	%a0,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-30)		/* reqtools -30 */
	movel	%d0,%d7
	moveal	%d0,%a1
	moveal	%d6,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-48)		/* reqtools -48 */
	moveal	%d7,%a1
	lea	_bss+0x28,%a2
	lea	_h1str,%a3		/* "Select a file.." */
	moveal	%d4,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-54)		/* reqtools -54 (file req) */
	movel	%d0,%sp@-
	moveal	%d6,%a1
	moveal	_bss+0,%a6
	jsr	%a6@(-690)		/* FreeVec */
	movel	%sp@+,%d0
	movel	%d0,%d6
	beqs	_r5
	moveal	%d7,%a0
	moveal	%a0@(16),%a0
	movel	%a0,%d0
_rq1:	cmpib	#0,%a0@+
	bnes	_rq1
	subal	%d0,%a0
	lea	_bss+0x28,%a1
	moveal	%a1,%a2
_rq2:	cmpib	#0,%a1@+
	bnes	_rq2
	subal	%a2,%a1
	addal	%a0,%a1
	movel	%a1,%d0
	btst	#0,%d0
	beqs	_rq3
	addql	#1,%d0
_rq3:	movel	#0x10001,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-684)		/* AllocVec(len) */
	movel	%d0,%d6
	moveal	%d6,%a1
	moveal	%d7,%a0
	moveal	%a0@(16),%a0
_rq4:	cmpib	#0,%a0@
	beqs	_rq6			/* empty drawer: skip append */
_rq5l:	moveb	%a0@+,%d0
	beqs	_rq5
	moveb	%d0,%a1@+
	bras	_rq5l
_rq5:	cmpib	#0x3a,%a1@(-1)	/* ':' */
	beqs	_rq6
	moveb	#0x2f,%a1@+		/* '/' */
_rq6:	lea	_bss+0x28,%a0
_rq7:	moveb	%a0@+,%d0
	beqs	_r5
	moveb	%d0,%a1@+
	bras	_rq7
_r5:	moveal	%d7,%a1
	moveal	_bss+32,%a6
	jsr	%a6@(-36)		/* reqtools -36 */
	movel	%d6,%d0
	rts

/* ---- 0x5ba req variant ------------------------------------------- */
_f5ba:
	.short	0x203c,0,0		/* movel #0,d0 */
	subal	%a0,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-30)
	movel	%d0,%d7
	moveal	%d7,%a1
	moveal	%d6,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-48)
	moveal	%d7,%a1
	lea	_bss+0x28,%a2
	lea	_h1str,%a3
	moveal	%d4,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-54)
	movel	%d0,%sp@-
	moveal	%d6,%a1
	moveal	_bss+0,%a6
	jsr	%a6@(-690)
	movel	%sp@+,%d0
	movel	%d0,%d6
	beqs	_f5bae
	.short	0x4eb9			/* jsr abs.l */
	.long	_f62e			/* relocated 0x62e */
	movel	%d0,%d6
	moveal	%d4,%a0
	moveal	_bss+32,%a6
	jsr	%a6@(-60)
_f5bae:
	moveal	%d7,%a1
	moveal	_bss+32,%a6
	jsr	%a6@(-36)
	movel	%d6,%d0
	rts

/* ---- 0x62e path-string copy --------------------------------------- */
_f62e:
	movel	%d0,%d4
	moveal	%d7,%a0
	moveal	%a0@(16),%a0
	movel	%a0,%d1
_f62a:	cmpib	#0,%a0@+
	bnes	_f62a
	subal	%d1,%a0
	exg	%d0,%a0
	addql	#1,%d0
	btst	#0,%d0
	beqs	_f62b
	addql	#1,%d0
_f62b:	addql	#4,%d0
	moveal	%d0,%a5
	moveal	%d4,%a0
	.short	0x4eb9			/* jsr abs.l */
	.long	_f69e			/* relocated 0x69e */
	lsll	#2,%d3
	addql	#4,%d3
	movel	%d3,%sp@-
	addl	%d3,%d2
	addl	%a5,%d2
	movel	%d2,%d0
	movel	#0x10001,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-684)
	movel	%d0,%d6
	moveal	%sp@+,%a2
	moveal	%d4,%a0
	moveal	%d6,%a1
	addal	%a5,%a1
	addal	%d6,%a2
	addal	%a5,%a2
	moveal	%d6,%a4
	movel	%a1,%a4@+
	.short	0x4eb9			/* jsr abs.l */
	.long	_f6b6			/* relocated 0x6b6 */
	moveal	%d7,%a0
	moveal	%a0@(16),%a0
	moveq	#0,%d0
_f62c:	moveb	%a0@+,%d0
	moveb	%d0,%a4@+
	bnes	_f62c
	movel	%d6,%d0
	rts

/* ---- 0x69e list measure ------------------------------------------- */
_f69e:	moveq	#0,%d2
	moveq	#0,%d3
_f69l:	addl	%a0@(4),%d2
	addql	#2,%d2
	addql	#1,%d3
	moveal	%a0@+,%a0
	cmpal	#0,%a0
	bnes	_f69l
	rts

/* ---- 0x6b6 node copy ---------------------------------------------- */
_f6b6:	movel	%a0@(4),%d0
	subql	#1,%d0
	moveal	%a0@(8),%a3
	movel	%a2,%a1@+
_f6bl:	moveb	%a3@+,%a2@+
	dbf	%d0,_f6bl
	moveb	#0,%a2@+
	moveal	%a0@,%a0
	cmpal	#0,%a0
	bnes	_f6b6
	rts

/* ---- -60 @0x6d8: 1<<(a0+86->a0+15) --------------------------------- */
_shiftbit:
	moveal	%a0@(86),%a0
	moveq	#1,%d1
	clrl	%d0
	moveb	%a0@(15),%d0
	lsll	%d0,%d1
	exg	%d1,%d0
	rts

/* ---- -66 @0x6ea: pen metric ---------------------------------------- */
_penmetric:
	movel	#0x10000,%d2
	divuw	%d0,%d2
	movel	#0x10000,%d3
	divuw	%d1,%d3
	movel	#0x1000,%d4
	divuw	%d2,%d4
	muluw	%d3,%d4
	lsrw	#4,%d4
	moveq	#-1,%d0
	andil	#0xffff,%d4
	cmpiw	#407,%d4
	bles	_pm1
	moveq	#0,%d0
_pm1:	rts

/* ---- -72 @0x718: byte-run unpack (vert) ---------------------------- */
_unpackrow:
	clrl	%d2
_ur1:	clrw	%d1
	moveb	%a0@+,%d1
	cmpib	#-128,%d1
	beqs	_ur1
	blss	_ur2
	notb	%d1
	moveb	%d1,%d2
	addqb	#2,%d2
	addqb	#1,%d1
	moveb	%a0@+,%d3
_ur3:	moveb	%d3,%a1@+
	dbf	%d1,_ur3
	subl	%d2,%d0
	bles	_urd
	bras	_ur1
_ur2:	moveb	%d1,%d2
	addqb	#1,%d2
_ur4:	moveb	%a0@+,%a1@+
	dbf	%d1,_ur4
	subl	%d2,%d0
	bles	_urd
	bras	_ur1
_urd:	rts

/* ---- -78 @0x74e: byte-run unpack (scan) ---------------------------- */
_unpackcol:
	moveal	%a1,%a3
	moveal	%a0,%a2
	addal	%d0,%a2
	clrl	%d0
_uc1:	cmpal	%a0,%a2
	bles	_ucd
	moveb	%a0@+,%d0
	cmpib	#-128,%d0
	beqs	_uc1
	bcss	_uc2
	notb	%d0
	addqb	#1,%d0
	moveb	%a0@+,%d1
_uc3:	moveb	%d1,%a1@+
	dbf	%d0,_uc3
	clrw	%d0
	bras	_uc1
_uc2:	moveb	%a0@+,%a1@+
	dbf	%d0,_uc2
	clrw	%d0
	bras	_uc1
_ucd:	subal	%a0,%a2
	movel	%a2,%d0
	rts

/* ---- -84 @0x784: bitplane interleave ------------------------------- */
_interleave:
	exg	%d3,%d5
	exg	%d2,%d7
	exg	%d0,%d3
	exg	%d1,%d4
	moveal	%a1,%a3
	clrl	%d1
	subqw	#1,%d5
	movel	%d7,%d6
	subqw	#1,%d6
_il1:	moveal	%a3,%a1
_il2:	movel	%d1,%d0
	moveal	%a1@+,%a2
	movel	%d3,%d2
	subqw	#1,%d2
_il3:	movew	%a0@+,%a2@(0,%d0:l)
	addql	#2,%d0
	dbf	%d2,_il3
	dbf	%d6,_il2
	movel	%d7,%d6
	subqw	#1,%d6
	addl	%d4,%d1
	dbf	%d5,_il1
	rts

/* ---- -90 @0x7ba: swapped-arg interleave ----------------------------- */
_interleave2:
	exg	%a0,%a1
	.short	0x4eb9			/* jsr abs.l */
	.long	_interleave		/* relocated 0x784 */
	rts

/* ---- -96 @0x7c4: bitpack ------------------------------------------- */
_makebody:
	exg	%d3,%d7
	exg	%d2,%d6
	exg	%a2,%a6
	exg	%d4,%a2
	exg	%d1,%a3
	exg	%d0,%a4
	cmpil	#8,%d6
	bgts	_mbb
	moveq	#5,%d0
	cmpal	#0,%a6
	beqw	_mbdone
	moveq	#1,%d0
	lslw	%d6,%d0
	subqw	#1,%d0
	movel	%a6,%d2
_mb1:	clrl	%d1
	moveb	%a6@+,%d1
	rorl	#8,%d1
	moveb	%a6@+,%d1
	rorl	#8,%d1
	moveb	%a6@+,%d1
	swap	%d1
	movel	%d1,%sp@-
	dbf	%d0,_mb1
	moveq	#1,%d0
	lslw	%d6,%d0
	lsll	#2,%d0
	moveal	%d2,%a6
	addal	%d0,%a6
	lsrl	#2,%d0
	subqw	#1,%d0
_mb2:	movel	%sp@+,%a6@-
	dbf	%d0,_mb2
	moveal	%d2,%a6
	bras	_mbbig
_mbb:	moveq	#7,%d5
	clrl	%d0
	clrl	%d1
	clrl	%d2
	moveal	%a0,%a5
	subql	#1,%a4
	subql	#1,%d6
	movel	%d6,%d3
	movel	%a4,%d4
_mb3:	btst	%d5,%a0@(0,%d0:l)
	beqs	_mb4
	bset	%d1,%d2
_mb4:	addl	%d7,%d0
	addqb	#1,%d1
	dbf	%d3,_mb3
	movel	%d2,%a1@+
	clrl	%d1
	clrl	%d2
	movew	%d6,%d3
	dbf	%d4,_mb5
	bras	_mb6
_mb5:	clrl	%d0
	dbf	%d5,_mb3
	moveq	#7,%d5
	addql	#1,%a0
	bras	_mb3
_mb6:	addal	%a2,%a5
	moveal	%a5,%a0
	moveq	#7,%d5
	movel	%a4,%d4
	clrl	%d0
	subql	#1,%a3
	cmpaw	#0,%a3
	bnes	_mb3
_mbdone: rts
_mbbig:
	moveq	#7,%d5
	clrl	%d0
	clrl	%d1
	clrl	%d2
	moveal	%a0,%a5
	subql	#1,%a4
	subql	#1,%d6
	movel	%d6,%d3
	movel	%a4,%d4
_mb7:	btst	%d5,%a0@(0,%d0:l)
	beqs	_mb8
	bset	%d1,%d2
_mb8:	addl	%d7,%d0
	addqb	#1,%d1
	dbf	%d3,_mb7
	lslw	#2,%d2
	movel	%a6@(0,%d2:w),%a1@+
	clrl	%d1
	clrl	%d2
	movew	%d6,%d3
	dbf	%d4,_mb9
	bras	_mb10
_mb9:	clrl	%d0
	dbf	%d5,_mb7
	moveq	#7,%d5
	addql	#1,%a0
	bras	_mb7
_mb10: addal	%a2,%a5
	moveal	%a5,%a0
	moveq	#7,%d5
	movel	%a4,%d4
	clrl	%d0
	subql	#1,%a3
	cmpaw	#0,%a3
	bnes	_mb7
	rts

/* ---- -102 @0x8bc: build ILBM BODY/image ---------------------------- */
_makeimg:
	movel	%d1,%d4
	muluw	%d0,%d4
	moveml	%d0-%d4/%a0,%sp@-
	lsll	#2,%d4
	exg	%d4,%d0
	addil	#60,%d0
	movel	#0x10001,%d1
	moveal	_bss+0,%a6
	jsr	%a6@(-684)
	moveal	%d0,%a5
	tstl	%d0
	beqw	_miret
	moveml	%sp@+,%d0-%d4/%a0
	lea	%a5@(60),%a1
	moveq	#126,%d5
	addql	#1,%d4
_mi1:	movel	%a0@+,%d6
_mi2:	subql	#1,%d4
	beqs	_mihdr
	cmpl	%a0@+,%d6
	bnes	_mi3
	subqb	#1,%d5
	bnes	_mi2
_mi3:	notb	%d5
	andib	#0x7f,%d5
	rorl	#8,%d6
	moveb	%d6,%d7
	swap	%d6
	moveb	%d7,%d6
	swap	%d6
	moveb	%d5,%d6
	movel	%d6,%a1@+
	subql	#4,%a0
	moveq	#126,%d5
	bras	_mi1
_mihdr:	movel	#0x464f524d,%a5@		/* 'FORM' */
	movel	#0x52474238,%a5@(8)	/* 'RGB8' */
	movel	#0x424d4844,%a5@(12)	/* 'BMHD' */
	movel	#20,%a5@(16)
	movew	%d0,%a5@(20)
	movew	%d1,%a5@(22)
	clrl	%a5@(24)
	movel	#0x19000400,%a5@(28)
	movel	#0x00000101,%a5@(32)
	movew	%d0,%a5@(36)
	movew	%d1,%a5@(38)
	movel	#0x43414d47,%a5@(40)	/* 'CAMG' */
	movel	#4,%a5@(44)
	movel	%d3,%a5@(48)
	movel	#0x424f4459,%a5@(52)	/* 'BODY' */
	moveml	%a0-%a1,%sp@-
	movel	%d2,%d1
	movel	#1006,%d2		/* MODE_NEWFILE */
	moveal	_bss+4,%a6
	jsr	%a6@(-30)		/* dos Open */
	movel	%d0,%d5
	beqs	_micl
	moveml	%sp@+,%a0-%a1
	movel	%a5,%d2
	movel	%d5,%d1
	subal	%a5,%a1
	movel	%a1,%d3
	subql	#8,%a1
	movel	%a1,%a5@(4)
	subal	#52,%a1
	movel	%a1,%a5@(56)
	moveal	_bss+4,%a6
	jsr	%a6@(-48)		/* dos Write */
	movel	%d5,%d1
	moveal	_bss+4,%a6
	jsr	%a6@(-36)		/* dos Close */
_micl:	moveal	%a5,%a1
	moveal	_bss+0,%a6
	jsr	%a6@(-690)		/* FreeVec */
_miret:	rts
_end:					/* 0x9d2: endskip (before pad) */
	.short	0			/* 0x9d2: trailing pad */
