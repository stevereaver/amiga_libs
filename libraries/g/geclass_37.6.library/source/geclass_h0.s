/* geclass.library 37.6 (16 Dec 1994) -- byte-exact reconstruction.
 * h0 CODE (0xaecB): RomTag + InitTable + 6-vector functab + code.
 * BOOPSI image class container: init MakeClass()es an anonymous
 * "frameiclass" subclass (dispatcher = _dispatch entry hook) and
 * grabs "iff.library" -LVO30 for the "textfieldgclass" class.
 * Exports NewObjectA/DisposeObject wrappers that map the private
 * class names "getfileiclass"/"textfieldgclass" to those classes.
 * All private state lives in h1 (BSS, 0xc0B), reached via abs lea.
 * Compiled C (stack-args, callee-pops via rtd/jmp-trampolines);
 * contains 68010 rtd and a 68020 trapf oddity.
 */

	.text
_stub:	moveq	#-1,%d0			/* 0x00 */
	rts

/* ---- Resident @4 ------------------------------------------------ */
_romtag:
	.short	0x4afc			/* rt_MatchWord */
	.long	_romtag			/* rt_MatchTag */
	.long	_end			/* rt_EndSkip -> 0xd6 */
	.byte	0x80			/* rt_Flags = RTF_AUTOINIT */
	.byte	37			/* rt_Version */
	.byte	9			/* rt_Type = NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name			/* rt_Name -> 0x1e */
	.long	_idstr			/* rt_IdString -> 0x3e */
	.long	_inittab		/* rt_Init -> 0x7e */

_name:	.ascii	"geclass.library"
	.byte	0
	.fill	16,1,0			/* -> 0x3e */
_idstr:	.ascii	"GEClass 37.6 (16 Dec 1994)\r\n"
	.byte	0
	.fill	35,1,0			/* -> 0x7e */

/* ---- InitTable @0x7e -------------------------------------------- */
_inittab:
	.long	0x22			/* dataSize (plain Library) */
	.long	_functab		/* 0xba */
	.long	_datatab		/* 0x8e */
	.long	_initfn			/* 0xd8 */

_datatab:				/* @0x8e, 16-bit-offset cmds */
	.short	0xe000,0x0008,0x0900	/* initbyte +8  ln_Type=NT_LIBRARY */
	.short	0xc000,0x000a
	.long	_name			/* initlong +10 ln_Name */
	.short	0xe000,0x000e,0x0600	/* initbyte +14 lib_Flags=6 */
	.short	0xd000,0x0014,0x0025	/* initword +20 ver=37 */
	.short	0xd000,0x0016,0x0006	/* initword +22 rev=6 */
	.short	0xc000,0x0018
	.long	_idstr			/* initlong +24 ln_IdString */
	.short	0,0

_functab:				/* @0xba: 6 absolute entries */
	.long	_open,_close,_expunge,_nullv
	.long	_makenew,_dispose
	.long	0xffffffff
_end:
	.short	0			/* pad -> 0xd8 */

/* ---- code @0xd8 -------------------------------------------------- */

/* _init(d0=libbase,a0=seglist,a6=sysbase) -- AUTOINIT entry */
_initfn:
	moveml	%d2/%a4, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	.short	0x43f9			/* lea _bss:l,a1 */
	.long	_bss
	moveq	#0x0, %d1
	.short	0x243c
	.long	0x30			/* movel #48,d2 (not moveq) */
	brab	Lf4
Lf2:	movel	%d1, %a1@+		/* clear 48 longs of bss */
Lf4:	dbra	%d2, Lf2
	movel	%d0, %a4@(0x10)		/* b.Library */
	movel	%a0, %a4@(0xc)		/* b.SegList */
	movel	%sp, %a4@(0x80)		/* b.SaveSP (bailout) */
	moveal	0x4:w, %a0
	movew	%a0@(0x14), %a4@(0x72)	/* b.ExecVer */
	leal	L120(%pc), %a0
	movel	%a0, %a4@(0x84)		/* b.FailCont */
	jsr	L764(%pc)		/* open deps + build classes */
	movel	%a4@(0x10), %d0
	bneb	L12a
L120:	moveal	%a4@(0x80), %sp		/* longjmp: restore stack */
	bsrw	L130			/* free all deps */
	moveq	#0x0, %d0		/* init failed -> NULL */
L12a:	moveml	%a7@+, %d2/%a4
	rts

/* free-once cleanup latch */
L130:	movel	%a4, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	bsetb	#0x0, %a4@(0x88)	/* b.Cleaned latch */
	bneb	L146
	jsr	L7fc(%pc)
	moveq	#0x0, %d0
L146:	moveal	%a7@+, %a4
	rts
	nop

/* assert-like trap: bsr target hits the illegal 4afc */
L14c:	.short	0x4afc			/* illegal -> deliberate crash */
	nop
/* _check(flag@a5+12): flag==0 -> crash, else pop 6 arg bytes & tail-ret */
L150:	linkw	%a5, #0x0
	tstb	%a5@(0xc)
	bneb	L15c
	bsrb	L14c
L15c:	unlk	%a5
	moveal	%a7@+, %a0
	addql	#0x6, %sp
	jmp	%a0@

/* _openlib(d0=ver,a1=name)->d0; NULL -> clear b.Library & longjmp */
L164:	movel	%a6, %a7@-
	moveal	0x4:w, %a6
	jsr	%a6@(-0x228)		/* OpenLibrary */
	moveal	%a7@+, %a6
	tstl	%d0
	bneb	L17e
	clrl	%a4@(0x10)
	moveal	%a4@(0x84), %a0
	jmp	%a0@
L17e:	rts

/* _closelib(a1=lib) */
L180:	movel	%a1, %d0
	beqb	L190
	movel	%a6, %a7@-
	moveal	0x4:w, %a6
	jsr	%a6@(-0x19e)		/* CloseLibrary */
	moveal	%a7@+, %a6
L190:	rts
	nop
L194:	rts				/* ctor stub (dead) */
L196:	rts				/* dtor stub (dead) */

/* ---- vectors ---------------------------------------------------- */
_open:					/* -6 */
	addqw	#0x1, %a6@(0x20)
	bclrb	#0x3, %a6@(0xe)
	movel	%a6, %d0
	rts
	nop
_close:					/* -12 */
	moveq	#0x0, %d0
	subqw	#0x1, %a6@(0x20)
	bneb	L1ba
	btstb	#0x3, %a6@(0xe)
	beqb	L1ba
	bsrb	L1bc
L1ba:	rts
_expunge:				/* -18 */
L1bc:	tstw	%a6@(0x20)
	beqb	L1cc
	bsetb	#0x3, %a6@(0xe)
	moveq	#0x0, %d0
	rts
L1cc:	moveml	%a4-%a6, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	moveal	%a6, %a5
	moveal	%a5, %a1
	moveal	0x4:w, %a6
	jsr	%a6@(-0xfc)		/* Remove */
	jsr	L130(%pc)		/* cleanup deps */
	moveal	%a5, %a1
	moveq	#0x0, %d0
	movew	%a5@(0x10), %d0		/* lib_NegSize */
	subaw	%d0, %a1
	addw	%a5@(0x12), %d0		/* + PosSize */
	jsr	%a6@(-0xd2)		/* FreeMem */
	movel	%a4@(0xc), %d0		/* seglist */
	moveml	%a7@+, %a4-%a6
	rts
	nop
_nullv:					/* -24 */
	moveq	#0x0, %d0
	rts

/* scale helpers: d0 = round-ish(argw * ptr[-2 | -4] / 20 | 14) */
L208:	linkw	%a5, #0x0
	moveml	%d5-%d7/%a3, %a7@-
	movew	%a5@(0xc), %d7
	moveal	%a5@(8), %a3
	mulsw	%a3@(-0x2), %d7
	movel	%d7, %d6
	moveq	#0x14, %d5
	eorw	%d5, %d6
	bplb	L22e
	subw	%d5, %d7
	bplb	L22c
	addqw	#0x1, %d7
	brab	L22e
L22c:	subqw	#0x1, %d7
L22e:	extl	%d7
	divsw	#0x14, %d7
	movew	%d7, %d0
	extl	%d0
	moveml	%a7@+, %d5-%d7/%a3
	unlk	%a5
	.short	0x4e74, 0x0006		/* rtd #6 */
L242:	linkw	%a5, #0x0
	moveml	%d5-%d7/%a3, %a7@-
	movew	%a5@(0xc), %d7
	moveal	%a5@(8), %a3
	mulsw	%a3@(-0x4), %d7
	movel	%d7, %d6
	moveq	#0xe, %d5
	eorw	%d5, %d6
	bplb	L268
	subw	%d5, %d7
	bplb	L266
	addqw	#0x1, %d7
	brab	L268
L266:	subqw	#0x1, %d7
L268:	extl	%d7
	divsw	#0xe, %d7
	movew	%d7, %d0
	extl	%d0
	moveml	%a7@+, %d5-%d7/%a3
	unlk	%a5
	.short	0x4e74, 0x0006		/* rtd #6 */

/* class dispatcher body: f(msg@8,obj@c,cl@10) */
L27c:	linkw	%a5, #-0x3a
	moveml	%d5-%d7/%a2-%a3/%a6, %a7@-
	moveal	%a5@(8), %a3
	movel	%a3@, %d7		/* methodID */
	braw	L686			/* switch */

/* OM_NEW (0x101) handler */
L28e:	movel	%a5@(0x10), %a7@-
	movel	%a5@(0xc), %a7@-
	movel	%a5@(8), %a7@-
	jsr	L968(%pc)		/* DoSuperMethod */
	movel	%d0, %a5@(0xc)		/* new obj */
	tstl	%a5@(0xc)
	beqb	L2f4
	movel	#0x80020003, %a7@-	/* IA_Width */
	moveal	%a5@(8), %a3
	moveal	%a3@(4), %a0		/* ops_AttrList */
	movel	%a7@+, %d0
	moveal	%a4@(0xac), %a6		/* UtilityBase */
	jsr	%a6@(-0x1e)		/* FindTagItem */
	tstl	%d0
	bneb	L2ce
	moveal	%a5@(0xc), %a2
	movew	#0x14, %a2@(4)		/* im_Width=20 */
L2ce:	movel	#0x80020004, %a7@-	/* IA_Height */
	moveal	%a5@(8), %a3
	moveal	%a3@(4), %a0
	movel	%a7@+, %d0
	moveal	%a4@(0xac), %a6
	jsr	%a6@(-0x1e)		/* FindTagItem */
	tstl	%d0
	bneb	L2f4
	moveal	%a5@(0xc), %a2
	movew	#0xe, %a2@(6)		/* im_Height=14 */
L2f4:	movel	%a5@(0xc), %d0
	addql	#0x4, %sp		/* dead adjust (unlk fixes) */
	braw	L6a0

/* IM_DRAW (0x202) handler */
L2fe:	movel	%a5@(0x10), %a7@-
	movel	%a5@(0xc), %a7@-
	movel	%a5@(8), %a7@-
	jsr	L968(%pc)		/* DoSuperMethod */
	moveal	%a5@(0xc), %a3		/* obj */
	movew	%a3@(4), %a5@(-0x2)	/* im_Width */
	movew	%a3@(6), %a5@(-0x4)	/* im_Height */
	clrw	%a5@(-0x3a)		/* i=0 */
L322:	cmpiw	#0xc, %a5@(-0x3a)	/* i>12 -> done */
	bgtb	L38e
	movew	%a5@(-0x3a), %d7
	aslw	#0x2, %d7
	leal	%a5@(-0x38), %a3		/* poly[i].x */
	movew	%a5@(-0x3a), %d6
	aslw	#0x2, %d6
	leal	L858(%pc), %a2		/* border coord table */
	movew	%a2@(0,%d6:w), %d5
	addqw	#0x4, %d5
	movew	%d5, %a7@-
	pea	%a5@
	bsrw	L208			/* scale_x */
	moveal	%a5@(8), %a2		/* msg */
	addw	%a2@(8), %d0		/* + imp_Offset.X */
	movew	%d0, %a3@(0,%d7:w)
	movew	%a5@(-0x3a), %d7
	aslw	#0x2, %d7
	leal	%a5@(-0x38), %a3		/* poly[i].y */
	movew	%a5@(-0x3a), %d6
	aslw	#0x2, %d6
	leal	L858(%pc), %a1
	movew	%a1@(2,%d6:w), %d5
	addiw	#0xa, %d5
	movew	%d5, %a7@-
	pea	%a5@
	bsrw	L242			/* scale_y */
	moveal	%a5@(8), %a2
	addw	%a2@(0xa), %d0		/* + imp_Offset.Y */
	movew	%d0, %a3@(2,%d7:w)
	addqw	#0x1, %a5@(-0x3a)
	bvcb	L322			/* loop (always) */
L38e:	moveal	%a5@(8), %a3		/* msg */
	moveal	%a3@(4), %a1		/* imp_RPort */
	moveb	#0x1, %a7@-
	moveq	#0x0, %d0
	moveb	%a7@+, %d0		/* d0=1 */
	moveal	%a4@(0xb4), %a6		/* GfxBase */
	jsr	%a6@(-0x162)		/* gfx -354 */
	cmpil	#0x1, %a3@(0xc)		/* imp_State==1? */
	bneb	L3ce
	tstl	%a3@(0x10)		/* imp_DrInfo */
	beqb	L3c8
	moveal	%a3@(0x10), %a2
	moveal	%a2@(4), %a2		/* dri field@4 (pens) */
	movew	%a2@(0xc), %d7		/* pens[6] */
	movew	%d7, %a5@(-0x3a)
	brab	L3f0
L3c8:	clrw	%a5@(-0x3a)		/* pen=0 */
	brab	L3f0
L3ce:	moveal	%a5@(8), %a3
	tstl	%a3@(0x10)
	beqb	L3ea
	moveal	%a3@(0x10), %a2
	moveal	%a2@(4), %a2
	movew	%a2@(4), %d7		/* pens[2] */
	movew	%d7, %a5@(-0x3a)
	brab	L3f0
L3ea:	movew	#0x1, %a5@(-0x3a)	/* pen=1 */
L3f0:	moveal	%a5@(8), %a3
	moveal	%a3@(4), %a1
	movew	%a5@(-0x3a), %d7
	movew	%d7, %a7@-
	moveq	#0x0, %d0
	movew	%a7@+, %d0
	moveal	%a4@(0xb4), %a6
	jsr	%a6@(-0x156)		/* SetAPen */
	moveal	%a3@(4), %a1
	movel	%a1, %a7@-		/* save rp */
	movew	#0x4, %a7@-
	pea	%a5@
	bsrw	L208			/* scale_x(4) */
	moveal	%a7@+, %a1
	moveal	%a5@(8), %a3
	movew	%a3@(8), %d7
	addw	%d0, %d7
	movew	%d7, %a7@-		/* x2 */
	movel	%a1, %a7@-
	movew	#0xa, %a7@-
	pea	%a5@
	bsrw	L242			/* scale_y(10) */
	moveal	%a7@+, %a1
	moveal	%a5@(8), %a3
	movew	%a3@(0xa), %d7
	addw	%d0, %d7
	movew	%d7, %a7@-		/* y2 */
	movew	%a7@+, %d1
	movew	%a7@+, %d0
	extl	%d0
	extl	%d1
	jsr	%a6@(-0xf0)		/* Move(rp,x,y) */
	moveal	%a3@(4), %a1
	movew	#0xd, %a7@-
	leal	%a5@(-0x38), %a0	/* poly array */
	movew	%a7@+, %d0		/* count=13 */
	extl	%d0
	jsr	%a6@(-0x150)		/* PolyDraw */
	moveq	#0x1, %d0		/* TRUE */
	addql	#0x4, %sp		/* dead adjust */
	braw	L6a0

/* default: pass everything up to superclass */
L46a:	movel	%a5@(0x10), %a7@-
	movel	%a5@(0xc), %a7@-
	movel	%a5@(8), %a7@-
	jsr	L968(%pc)		/* DoSuperMethod */
	addql	#0x4, %sp		/* dead adjust */
	braw	L6a0

/* ---- dispatch jump table (offsets rel L482) ---------------------- */
	.short	0xffe8			/* index -1: default -> 0x46a */
L482:	.short	0xfe0c			/* [0x101] OM_NEW -> 0x28e */
	.fill	0x100,2,0xffe8		/* [0x102..0x201] -> 0x46a */
	.short	0xfe7c			/* [0x202] IM_DRAW -> 0x2fe */

/* switch dispatch + epilogue */
L686:	leal	L482(%pc), %a3
	subiw	#0x101, %d7
	cmpiw	#0x101, %d7
	blsb	L696
	moveq	#-1, %d7		/* out of range -> default */
L696:	aslw	#0x1, %d7
	movew	%a3@(0,%d7:w), %d7
	jsr	%a3@(0,%d7:w)
L6a0:	moveml	%a7@+, %d5-%d7/%a2-%a3/%a6
	unlk	%a5
	.short	0x4e74, 0x000c		/* rtd #12 */
	nop

/* class dispatcher hook entry: h_Entry(a0=cl,a1=msg,a2=obj) */
L6ac:	moveml	%a2-%a4, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	movel	%a0, %a7@-		/* cl */
	movel	%a2, %a7@-		/* obj */
	movel	%a1, %a7@-		/* msg */
	jsr	L27c(%pc)
	moveml	%a7@+, %a2-%a4
	rts
	nop

/* resolve private classID names then NewObjectA(class,ID,tags) */
L6c8:	linkw	%a5, #0x0
	moveml	%d7/%a2/%a4/%a6, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	tstl	%a5@(0x10)		/* arg2 = name (orig a0) */
	beqb	L71a
	moveq	#0xc, %d7
	movel	%d7, %a7@-
	pea	L88e(%pc)		/* "getfileiclass" */
	pea	0xff:w
	movel	%a5@(0x10), %a7@-
	jsr	Lxa90(%pc)		/* bounded strcmp */
	tstl	%d0
	bneb	L6fc
	movel	%a4@(0x90), %a5@(0x10)	/* -> GetFileImageClass */
	brab	L71a
L6fc:	moveq	#0xe, %d7
	movel	%d7, %a7@-
	pea	L89c(%pc)		/* "textfieldgclass" */
	pea	0xff:w
	movel	%a5@(0x10), %a7@-
	jsr	Lxa90(%pc)
	tstl	%d0
	bneb	L71a
	movel	%a4@(0x94), %a5@(0x10)	/* -> if.library class */
L71a:	moveal	%a5@(0x10), %a0
	moveal	%a5@(0xc), %a1
	moveal	%a5@(8), %a2
	moveal	%a4@(0xbc), %a6		/* IntuitionBase */
	jsr	%a6@(-0x27c)		/* NewObjectA(-636) */
	moveml	%a7@+, %d7/%a2/%a4/%a6
	unlk	%a5
	.short	0x4e74, 0x000c		/* rtd #12 */

_makenew:				/* -30: f(a0=name,a1,a2=tags) */
	movel	%a0, %a7@-
	movel	%a1, %a7@-
	movel	%a2, %a7@-
	jsr	L6c8(%pc)
	rts

_dispose:				/* -36: f(a0=obj) */
	moveml	%a4/%a6, %a7@-
	.short	0x49f9			/* lea _bss:l,a4 */
	.long	_bss
	movel	%a0, %a7@-		/* save a0 */
	movel	%a0, %a7@-
	moveal	%a7@+, %a0		/* (push+pop, dead) */
	moveal	%a4@(0xbc), %a6		/* IntuitionBase */
	jsr	%a6@(-0x282)		/* DisposeObject(-642) */
	moveal	%a7@+, %a0
	moveml	%a7@+, %a4/%a6
	rts

/* subsystem open-all (runs once) */
L764:	moveml	%a2-%a3/%a6, %a7@-
	addqw	#0x1, %a4@(0x8c)	/* b.DepCnt++ */
	cmpiw	#0x1, %a4@(0x8c)
	bnew	L7f6
	.short	0x51fc			/* trapf (68020 nop-ish) */
	jsr	L194(%pc)		/* ctor stub */
	jsr	Lae8(%pc)		/* ctor stub */
	jsr	L8fc(%pc)		/* open exec.library 33 */
	jsr	La48(%pc)		/* open intuition.library 33 */
	jsr	La00(%pc)		/* open graphics.library 33 */
	jsr	L9bc(%pc)		/* open utility.library 36 */
	jsr	L998(%pc)		/* module counter++ */
	movew	#0x1, %a4@(0x8c)
	subal	%a0, %a0		/* a0=0 (classID: private) */
	leal	L8ac(%pc), %a1		/* "frameiclass" superclass */
	moveal	%a0, %a2		/* a2=0 (superptr) */
	movel	%a0, %d0		/* instsize=0 */
	movel	%d0, %d1		/* flags=0 */
	moveal	%a4@(0xbc), %a6		/* IntuitionBase */
	jsr	%a6@(-0x2a6)		/* MakeClass(-678) */
	movel	%d0, %a4@(0x90)		/* b.GetFileImageClass */
	tstl	%a4@(0x90)
	sne	%sp@-			/* flag byte: class made? */
	pea	L8b8(%pc)		/* "GEClass: Make ... failed !" */
	jsr	L150(%pc)		/* assert(flag): crash if 0 */
	leal	L6ac(%pc), %a3		/* dispatcher entry */
	moveal	%a4@(0x90), %a2
	movel	%a3, %a2@(8)		/* cl_Dispatcher.h_Entry */
	leal	L8e2(%pc), %a1		/* "iff.library" */
	moveq	#0x0, %d0
	moveal	%a4@(0xa0), %a6		/* ExecBase */
	jsr	%a6@(-0x228)		/* OpenLibrary(iff,0) */
	movel	%d0, %a4@(0x98)		/* b.IffLib */
	tstl	%a4@(0x98)
	beqb	L7f2
	moveal	%a4@(0x98), %a6
	jsr	%a6@(-0x1e)		/* iff -30 -> class */
	movel	%d0, %a4@(0x94)		/* b.TextFieldClass */
	brab	L7f6
L7f2:	clrl	%a4@(0x94)
L7f6:	moveml	%a7@+, %a2-%a3/%a6
	rts

/* subsystem close-all (runs once) */
L7fc:	movel	%a6, %a7@-
	subqw	#0x1, %a4@(0x8c)
	bneb	L852
	tstl	%a4@(0x90)
	beqb	L81c
	moveal	%a4@(0x90), %a0
	moveal	%a4@(0xbc), %a6
	jsr	%a6@(-0x2ca)		/* FreeClass(-714) */
	tstb	%d0			/* dead test */
	clrl	%a4@(0x90)
L81c:	clrl	%a4@(0x94)
	tstl	%a4@(0x98)
	beqb	L836
	moveal	%a4@(0x98), %a1
	moveal	%a4@(0xa0), %a6
	jsr	%a6@(-0x19e)		/* CloseLibrary(iff) */
	clrl	%a4@(0x98)
L836:	jsr	L9b0(%pc)		/* module counter-- */
	jsr	L9e0(%pc)		/* utility-- */
	jsr	La24(%pc)		/* gfx-- */
	jsr	La6c(%pc)		/* intuition-- */
	jsr	L920(%pc)		/* exec-- */
	jsr	Laea(%pc)		/* dtor stub */
	jsr	L196(%pc)		/* dtor stub */
L852:	moveal	%a7@+, %a6
	rts
	nop

/* ---- IM_DRAW border coordinate table (13 x,y pairs) -------------- */
L858:	.short	0x0000,0xfffa
	.short	0x0001,0xfffa
	.short	0x0001,0x0000
	.short	0x000b,0x0000
	.short	0x000b,0xfffa
	.short	0x0009,0xfff8
	.short	0x0006,0xfff8
	.short	0x0004,0xfffa
	.short	0x0002,0xfffa
	.short	0x0002,0xfffb
	.short	0x0005,0xfffb
	.short	0x0006,0xfffc
	.short	0x000a,0xfffc

	.short	0			/* pad -> 0x88e */
L88e:	.ascii	"getfileiclass"
	.byte	0
L89c:	.ascii	"textfieldgclass"
	.byte	0
L8ac:	.ascii	"frameiclass"
	.byte	0
L8b8:	.ascii	"GEClass: Make GetFileImageClass failed !"
	.byte	0
	.byte	0			/* pad -> 0x8e2 */
L8e2:	.ascii	"iff.library"
	.byte	0
	.fill	14,1,0			/* -> 0x8fc */

/* ---- exec.library open/close (BSS+0x9c cnt, +0xa0 base, +0x9e ver) */
L8fc:	addqw	#0x1, %a4@(0x9c)
	cmpiw	#0x1, %a4@(0x9c)
	bneb	L91e
	moveq	#0x21, %d0
	leal	L930(%pc), %a1
	jsr	L164(%pc)
	movel	%d0, %a4@(0xa0)
	moveal	%d0, %a0
	movew	%a0@(0x14), %a4@(0x9e)
L91e:	rts
L920:	subqw	#0x1, %a4@(0x9c)
	bneb	L92e
	moveal	%a4@(0xa0), %a1
	jsr	L180(%pc)
L92e:	rts
L930:	.ascii	"exec.library"
	.byte	0
	.byte	0,0,0			/* -> 0x940 */

/* CallHook trampoline: args(hook,arg1,arg2) -> h_Entry(a0=hook,a1,a2) */
L940:	moveal	%a7@+, %a0		/* ret */
	moveal	%a7@+, %a1		/* arg1 */
	movel	%a7@+, %d0		/* arg2 */
	movel	%a7@+, %d1		/* hook */
	movel	%a0, %a7@-		/* ret back */
	movel	%a2, %a7@-
	tstl	%d0
	beqb	L962
	tstl	%d1
	beqb	L962
	moveal	%d0, %a2
	moveal	%d1, %a0
	pea	L964(%pc)
	movel	%a0@(8), %a7@-		/* h_Entry */
	rts
L962:	moveq	#0x0, %d0
L964:	moveal	%a7@+, %a2
	rts

/* DoSuperMethod wrapper: f(msg@8,obj@c,cl@10) -> CallHook(cl->super) */
L968:	linkw	%a5, #0x0
	movel	%a3, %a7@-
	tstl	%a5@(0x10)		/* cl */
	beqb	L988
	moveal	%a5@(0x10), %a3
	movel	%a3@(0x18), %a7@-	/* cl_Super */
	movel	%a5@(0xc), %a7@-	/* obj */
	movel	%a5@(8), %a7@-		/* msg */
	bsrb	L940			/* CallHook */
	brab	L98a
L988:	moveq	#0x0, %d0
L98a:	moveal	%a7@+, %a3
	unlk	%a5
	moveal	%a7@+, %a0
	lea	%a7@(0xc), %sp		/* pop 12 arg bytes */
	jmp	%a0@
	nop

/* module counter pair (SAS/C module init placeholder) */
L998:	addqw	#0x1, %a4@(0xa4)
	cmpiw	#0x1, %a4@(0xa4)
	bneb	L9ae
	jsr	L194(%pc)		/* ctor stub */
	movew	#0x1, %a4@(0xa4)
L9ae:	rts
L9b0:	subqw	#0x1, %a4@(0xa4)
	bneb	L9ba
	jsr	L196(%pc)		/* dtor stub */
L9ba:	rts

/* ---- utility.library (BSS+0xa8 cnt, +0xac base, +0xaa ver) -------- */
L9bc:	addqw	#0x1, %a4@(0xa8)
	cmpiw	#0x1, %a4@(0xa8)
	bneb	L9de
	moveq	#0x24, %d0
	leal	L9f0(%pc), %a1
	jsr	L164(%pc)
	movel	%d0, %a4@(0xac)
	moveal	%d0, %a0
	movew	%a0@(0x14), %a4@(0xaa)
L9de:	rts
L9e0:	subqw	#0x1, %a4@(0xa8)
	bneb	L9ee
	moveal	%a4@(0xac), %a1
	jsr	L180(%pc)
L9ee:	rts
L9f0:	.ascii	"utility.library"
	.byte	0

/* ---- graphics.library (BSS+0xb0 cnt, +0xb4 base, +0xb2 ver) ------- */
La00:	addqw	#0x1, %a4@(0xb0)
	cmpiw	#0x1, %a4@(0xb0)
	bneb	La22
	moveq	#0x21, %d0
	leal	La34(%pc), %a1
	jsr	L164(%pc)
	movel	%d0, %a4@(0xb4)
	moveal	%d0, %a0
	movew	%a0@(0x14), %a4@(0xb2)
La22:	rts
La24:	subqw	#0x1, %a4@(0xb0)
	bneb	La32
	moveal	%a4@(0xb4), %a1
	jsr	L180(%pc)
La32:	rts
La34:	.ascii	"graphics.library"
	.byte	0
	.byte	0,0,0			/* -> 0xa48 */

/* ---- intuition.library (BSS+0xb8 cnt, +0xbc base, +0xba ver) ------ */
La48:	addqw	#0x1, %a4@(0xb8)
	cmpiw	#0x1, %a4@(0xb8)
	bneb	La6a
	moveq	#0x21, %d0
	leal	La7c(%pc), %a1
	jsr	L164(%pc)
	movel	%d0, %a4@(0xbc)
	moveal	%d0, %a0
	movew	%a0@(0x14), %a4@(0xba)
La6a:	rts
La6c:	subqw	#0x1, %a4@(0xb8)
	bneb	La7a
	moveal	%a4@(0xbc), %a1
	jsr	L180(%pc)
La7a:	rts
La7c:	.ascii	"intuition.library"
	.byte	0
	.byte	0,0			/* -> 0xa90 */

/* bounded string compare: f(s1,s2,n1,n2) on stack, callee pops 16 */
Lxa90:	moveml	%d2-%d3/%a2, %a7@-
	lea	%a7@(0x10), %a2
	moveal	%a2@+, %a0		/* s1 */
	movel	%a2@+, %d2		/* 0xff bound */
	moveal	%a2@+, %a1		/* s2 */
	movel	%a2@+, %d1		/* n bound */
	moveq	#0x0, %d0
Lxaa2:	cmpl	%d1, %d0
	bleb	Laba
	cmpl	%d2, %d0
	bleb	Laae
Laaa:	moveq	#0x0, %d0
	brab	Ladc
Laae:	tstb	%a0@(0,%d0:l)
	beqb	Laaa
Lab4:	addql	#0x1, %d0
	negl	%d0
	brab	Ladc
Laba:	cmpl	%d2, %d0
	bleb	Lac8
	tstb	%a1@(0,%d0:l)
	beqb	Laaa
Lac4:	addql	#0x1, %d0
	brab	Ladc
Lac8:	moveb	%a1@(0,%d0:l), %d3
	cmpb	%a0@(0,%d0:l), %d3
	bltb	Lab4
	bgtb	Lac4
	tstb	%d3
	beqb	Laaa
	addql	#0x1, %d0
	brab	Lxaa2
Ladc:	moveml	%a7@+, %d2-%d3/%a2
	moveal	%a7@+, %a0
	lea	%a7@(0x10), %sp		/* pop 16 arg bytes */
	jmp	%a0@
Lae8:	rts				/* ctor stub */
Laea:	rts				/* dtor stub */
