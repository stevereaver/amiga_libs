/* recent.library 0.9 (September 20, 1999) -- byte-exact reconstruction.
 * Single CODE hunk (2848B). MRU "recent documents" list manager:
 * per-{block = key,count,DateStamp-stamped 20B records} lists stored
 * under ENVARC:Recent/<name> with "RCNT" block magic.
 * deps: dos.library, gadtools.library v36.  SAS/C-style compiled C.
 */

	.text
_stub:	moveq	#0,%d0			/* 0x00 */
	rts

/* ---- Resident @4 ------------------------------------------------ */
_romtag:
	.short	0x4afc			/* rt_MatchWord */
	.long	_romtag			/* rt_MatchTag */
	.long	_inittab		/* rt_EndSkip -> 0x74 */
	.byte	0x80			/* rt_Flags = RTF_AUTOINIT */
	.byte	0			/* rt_Version = 0 */
	.byte	9			/* rt_Type = NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name			/* rt_Name -> 0x1e */
	.long	_idstr			/* rt_IdString -> 0x2d */
	.long	_inittab		/* rt_Init -> 0x74 */

_name:	.ascii	"recent.library"
	.byte	0
_idstr:	.ascii	"recent.library 0.9 (September 20, 1999)"
	.byte	0
_dosnam:.ascii	"dos.library"
	.byte	0
	.byte	0			/* pad @0x61 */
_gadnam:.ascii	"gadtools.library"
	.byte	0
	.byte	0			/* pad @0x73 */

/* ---- InitTable @0x74 -------------------------------------------- */
_inittab:
	.long	0x34			/* dataSize */
	.long	_functab
	.long	_datatab
	.long	_initfn

_functab:				/* @0x84: 13 absolute entries */
	.long	_open,_close,_expunge,_nullv
	.long	_load,_free,_touch,_addblk
	.long	_getblk,_save,_setmax,_menu
	.long	_savefree
	.long	0xffffffff

_datatab:				/* @0xbc InitStruct data */
	.short	0xa00c,0x0900		/* initbyte +12 = 9 */
	.short	0x800a
	.long	_name			/* initlong +10 ln_Name */
	.short	0xa00e,0x0600		/* initbyte +14 flags=6 */
	.short	0x9014,0x0000		/* initword +20 ver=0 */
	.short	0x9016,0x0009		/* initword +22 rev=9 */
	.short	0x8018
	.long	_idstr			/* initlong +24 ln_IdString */
	.short	0,0

/* ---- code @0xdc -------------------------------------------------- */

_initfn:
	movel	%a5, %a7@-
	moveal	%d0, %a5
	movel	%a6, %a5@(0x22)
	movel	%a0, %a5@(0x2e)
	leal	_dosnam(%pc), %a1
	moveq	#0x0, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a5@(0x26)
	bneb	L110
	moveml	%d7/%a5-%a6, %a7@-
	movel	#0x38007, %d7
	moveal	0x4:l, %a6
	jsr	%a6@(-0x6c)
	moveml	%a7@+, %d7/%a5-%a6
L110:
	leal	_gadnam(%pc), %a1
	moveq	#0x24, %d0
	jsr	%a6@(-0x228)
	movel	%d0, %a5@(0x2a)
	movel	%a5, %d0
	moveal	%a7@+, %a5
	rts	

_open:
	addqw	#0x1, %a6@(0x20)
	bclrb	#0x3, %a6@(0x32)
	movel	%a6, %d0
	rts	

_close:
	moveq	#0x0, %d0
	subqw	#0x1, %a6@(0x20)
	bneb	L144
	btstb	#0x3, %a5@(0x32)
	beqb	L144
	bsrb	L146
L144:
	rts	

_expunge:
L146:
	moveml	%d1/%a5-%a6, %a7@-
	moveal	%a6, %a5
	moveal	%a5@(0x22), %a6
	tstw	%a5@(0x20)
	beqb	L160
	bsetb	#0x3, %a5@(0x32)
	moveq	#0x0, %d0
	brab	L196
L160:
	movel	%a5@(0x2e), %d2
	moveal	%a5, %a1
	jsr	%a6@(-0xfc)
	moveal	%a5@(0x26), %a1
	jsr	%a6@(-0x19e)
	moveal	%a5@(0x2a), %a1
	cmpal	#0x0, %a1
	beqb	L182
	jsr	%a6@(-0x19e)
L182:
	moveq	#0x0, %d0
	moveal	%a5, %a1
	movew	%a5@(0x10), %d0
	subal	%d0, %a1
	addw	%a5@(0x12), %d0
	jsr	%a6@(-0xd2)
	movel	%d2, %d0
L196:
	moveml	%a7@+, %d2/%a5-%a6
	rts	

_nullv:
	moveq	#0x0, %d0
	rts	

_load:
	moveml	%d2-%d5/%a3-%a5, %a7@-
	moveal	%a0, %a3
	moveal	%a1, %a4
	.short	0x203c
	.long	0xc		/* movel #12,d0 */
	moveq	#0x0, %d1
	movel	%a6, %a7@-
	moveal	0x4:w, %a6
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqw	L3f0
	moveal	%d0, %a5
	movel	%d0, %a4@
	moveal	%a3, %a0
L1c6:
	cmpib	#0x0, %a0@+
	bneb	L1c6
	subal	%a3, %a0
	movel	%a0, %d0
	moveal	%d0, %a4
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqw	L3ea
	.short	0x2b40,0x0000		/* movel d0,a5@(0) */
	movel	%a4, %d0
	addil	#0xe, %d0
	moveq	#0x0, %d1
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqw	L3e2
	movel	%d0, %a5@(4)
	moveal	%a3, %a0
	moveal	%d0, %a4
	leal	_envarc(%pc), %a1
	moveq	#0xe, %d0
	subql	#0x1, %d0
L20a:
	moveb	%a1@+, %a4@+
	dbra	%d0,L20a
	.short	0x226d,0x0000	/* moveal a5@(0),a1 */
L214:
	moveb	%a0@, %a1@+
	moveb	%a0@, %a4@+
	cmpib	#0x0, %a0@+
	bneb	L214
	moveal	#0x0, %a3
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	movel	%a5@(4), %d1
	movel	#0x3ed, %d2
	jsr	%a6@(-0x1e)
	tstl	%d0
	beqw	L3a4
	movel	%d0, %d5
	moveal	0x4:w, %a6
	moveq	#0x5, %d0
	moveq	#0x0, %d1
	jsr	%a6@(-0x2ac)
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	tstl	%d0
	beqw	L3a8
	moveal	%d0, %a3
	movel	%d5, %d1
	movel	%a3, %d2
	moveq	#0x4, %d3
	jsr	%a6@(-0x2a)
	movel	_magic(%pc), %d0
	movel	%a3@, %d1
	cmpl	%d0, %d1
	bnew	L3a8
	leal	%a5@(8), %a5
L274:
	movel	%d5, %d1
	movel	%a3, %d2
	moveq	#0x4, %d3
	jsr	%a6@(-0x2a)
	.short	0xb0bc
	.long	0x4		/* cmpl #4,d0 */
	bnew	L38c
	movel	%d5, %d1
	leal	%a3@(4), %a0
	movel	%a0, %d2
	moveq	#0x1, %d3
	jsr	%a6@(-0x2a)
	.short	0xb0bc
	.long	0x1		/* cmpl #1,d0 */
	bnew	L3a8
	moveal	0x4:w, %a6
	moveb	%a3@(4), %d0
	muluw	#0x14, %d0
	addil	#0x14, %d0
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	tstl	%d0
	beqw	L3a8
	movel	%d0, %a5@
	moveal	%d0, %a5
	movel	%a3@, %a5@(4)
	moveb	%a3@(4), %a5@(8)
	moveb	%a3@(4), %a5@(9)
	movel	%d5, %d1
	leal	%a5@(0xa), %a0
	movel	%a0, %d2
	moveq	#0x1, %d3
	jsr	%a6@(-0x2a)
	.short	0xb0bc
	.long	0x1		/* cmpl #1,d0 */
	bnew	L3a8
	moveq	#0x0, %d4
	moveb	%a5@(0xa), %d4
	subql	#0x1, %d4
	leal	%a5@(0x14), %a4
L300:
	movel	%d5, %d1
	leal	%a3@(4), %a0
	movel	%a0, %d2
	moveq	#0x1, %d3
	jsr	%a6@(-0x2a)
	.short	0xb0bc
	.long	0x1		/* cmpl #1,d0 */
	bnew	L3a8
	moveal	0x4:w, %a6
	moveq	#0x0, %d0
	moveb	%a3@(4), %d0
	moveq	#0x0, %d1
	jsr	%a6@(-0x2ac)
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	tstl	%d0
	beqb	L3a8
	movel	%d0, %a4@(4)
	movel	%d5, %d1
	movel	%d0, %d2
	moveq	#0x0, %d3
	moveb	%a3@(4), %d3
	jsr	%a6@(-0x2a)
	cmpb	%a3@(4), %d0
	bneb	L3a8
	movel	%d5, %d1
	leal	%a4@(8), %a0
	movel	%a0, %d2
	moveq	#0xc, %d3
	jsr	%a6@(-0x2a)
	.short	0xb0bc
	.long	0xc		/* cmpl #12,d0 */
	bneb	L3a8
	moveal	%a4@(4), %a0
L364:
	cmpib	#0x0, %a0@+
	bneb	L364
L36a:
	cmpib	#0x2f, %a0@-
	beqb	L376
	cmpib	#0x3a, %a0@
	bneb	L36a
L376:
	addal	#0x1, %a0
	.short	0x2948,0x0000		/* movel a0,a4@(0) */
	leal	%a4@(0x14), %a4
	dbra	%d4,L300
	braw	L274
L38c:
	movel	%d5, %d1
	jsr	%a6@(-0x24)
	moveal	0x4:w, %a6
	cmpal	#0x0, %a3
	beqb	L3a4
	moveal	%a3, %a1
	jsr	%a6@(-0x2b2)
L3a4:
	moveq	#0x1, %d0
	brab	L3f8
L3a8:
	movel	%d5, %d1
	.short	0x243c,0x0000,0x0000	/* movel #0,d2 */
	.short	0x263c,0x0000,0x0000	/* movel #0,d3 */
	jsr	%a6@(-0x42)
	moveal	%a7@+, %a6
	moveml	%a7@+, %d2-%d5/%a3-%a5
	rts	
	jsr	%a6@(-0x24)
	moveal	0x4:w, %a6
	cmpal	#0x0, %a3
	beqb	L3da
	moveal	%a3, %a1
	jsr	%a6@(-0x2b2)
	brab	L3f0
L3da:
	moveal	%a5@(4), %a1
	jsr	%a6@(-0x2b2)
L3e2:
	.short	0x226d,0x0000		/* moveal a5@(0),a1 */
	jsr	%a6@(-0x2b2)
L3ea:
	moveal	%a5, %a1
	jsr	%a6@(-0x2b2)
L3f0:
	moveq	#0x0, %d0
	movel	#0x0, %a4@		/* 0x28bc mode2 */
L3f8:
	moveal	%a7@+, %a6
	moveml	%a7@+, %d2-%d5/%a3-%a5
	rts	

_free:
L400:
	moveml	%d5-%d6/%a3-%a5, %a7@-
	movel	%a6, %a7@-
	moveal	%a1, %a5
	moveal	%a5@, %a4
	movel	%a4, %d0
	beqw	L4aa
	moveal	0x4:w, %a6
	.short	0x202c,0x0000		/* movel a4@(0),d0 */
	beqb	L420
	moveal	%d0, %a1
	jsr	%a6@(-0x2b2)
L420:
	movel	%a4@(4), %d0
	beqb	L42c
	moveal	%d0, %a1
	jsr	%a6@(-0x2b2)
L42c:
	movel	%a4@(8), %d0
	beqb	L49e
L432:
	moveal	%d0, %a3
	moveq	#0x0, %d5
	.short	0x2c2b,0x0000		/* movel a3@(0),d6 */
	moveb	%a3@(9), %d5
L43e:
	.short	0xbabc
	.long	0x0		/* cmpl #0,d5 */
	beqb	L46a
	subql	#0x1, %d5
	leal	%a3@(0x14), %a1
	movel	%d5, %d0
	muluw	#0x14, %d0
	addal	%d0, %a1
	addal	#0x4, %a1
	cmpil	#0x0, %a1@
	beqb	L43e
	moveal	%a1@, %a1
	jsr	%a6@(-0x2b2)
	brab	L43e
L46a:
	moveal	%a3@(0x10), %a1
	cmpal	#0x0, %a1
	beqb	L47a
	jsr	%a6@(-0x2b2)
L47a:
	moveal	%a3@(0xc), %a0
	cmpal	#0x0, %a0
	beqb	L494
	moveal	%a7@, %a6
	moveal	%a6@(0x2a), %a6
	jsr	%a6@(-0x36)
	moveal	0x4:w, %a6
L494:
	moveal	%a3, %a1
	jsr	%a6@(-0x2b2)
	movel	%d6, %d0
	bneb	L432
L49e:
	moveal	%a4, %a1
	jsr	%a6@(-0x2b2)
	movel	#0x0, %a5@
L4aa:
	moveal	%a7@+, %a6
	moveml	%a7@+, %d5-%d6/%a3-%a5
	rts	

_touch:
	moveml	%d3-%d5/%a4-%a5, %a7@-
	movel	%a6, %a7@-
	cmpal	#0x0, %a0
	beqw	L58c
	moveml	%d1/%a0, %a7@-
	moveal	%a6@(0x26), %a6
	movel	%a1, %d1
	.short	0x243c
	.long	0xfffffffe	/* movel #-2,d2 */
	jsr	%a6@(-0x54)
	moveml	%a7@+, %d1/%a0
	tstl	%d0
	movel	%d0, %d5
	beqw	L58c
	moveal	%a0@(8), %a4
	cmpal	#0x0, %a4
	beqw	L594
L4f0:
	movel	%a4@(4), %d0
	cmpl	%d1, %d0
	beqw	L5d2
	.short	0x202c,0x0000		/* movel a4@(0),d0 */
	beqw	L594
	moveal	%d0, %a4
	brab	L4f0
L506:
	moveq	#0x0, %d0
	moveb	%a4@(9), %d0
	subb	%a4@(0xa), %d0
	beqw	L5a4
L514:
	moveb	%a4@(0xa), %d0
	muluw	#0x14, %d0
	addib	#0x1, %a4@(0xa)
	leal	%a4@(0x14), %a4
	leal	%a4@(0,%d0:w), %a5
L52a:
	cmpal	%a5, %a4
	beqb	L552
	movel	%a5@(-0x4), %a5@(0x10)
	movel	%a5@(-0x8), %a5@(0xc)
	movel	%a5@(-0xc), %a5@(8)
	movel	%a5@(-0x10), %a5@(4)
	.short	0x2b6d,0xffec,0x0000	/* movel a5@(-20),a5@(0) */
	leal	%a5@(-0x14), %a5
	brab	L52a
L552:
	movel	%d4, %a4@(4)
	movel	%a4, %d1
	addil	#0x8, %d1
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	jsr	%a6@(-0xc0)
	moveal	%a4@(4), %a5
L56c:
	cmpib	#0x0, %a5@+
	bneb	L56c
L572:
	cmpib	#0x2f, %a5@-
	beqb	L580
	cmpib	#0x3a, %a5@
	beqb	L580
	brab	L572
L580:
	addal	#0x1, %a5
	.short	0x294d,0x0000		/* movel a5,a4@(0) */
L58a:
	moveq	#0x1, %d0
L58c:
	moveal	%a7@+, %a6
	moveml	%a7@+, %d3-%d5/%a4-%a5
	rts	
L594:
	movel	%d5, %d1
	moveal	%a7@, %a6
	moveal	%a6@(0x26), %a6
	jsr	%a6@(-0x5a)
	moveq	#0x0, %d0
	brab	L58c
L5a4:
	moveb	%a4@(0xa), %d0
	subql	#0x1, %d0
	moveb	%d0, %a4@(0xa)
	muluw	#0x14, %d0
	leal	%a4@(0x14,%d0:w), %a1
	moveal	0x4:w, %a6
	moveal	%a1@(4), %a1
	cmpal	#0x0, %a1
	beqw	L514
	jsr	%a6@(-0x2b2)
	moveq	#0x0, %d0
	braw	L514
L5d2:
	moveal	0x4:w, %a6
	movel	#0x100, %d0
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqb	L594
	movel	%d0, %d4
	moveal	%a7@, %a5
	moveal	%a5@(0x26), %a6
	movel	%d5, %d1
	movel	%d0, %d2
	movel	#0x100, %d3
	jsr	%a6@(-0x192)
	.short	0xb0bc
	.long	0x0		/* cmpl #0,d0 */
	beqb	L594
	movel	%d5, %d1
	jsr	%a6@(-0x5a)
	moveb	%a4@(0xa), %d0
	tstb	%d0
	beqw	L506
	leal	%a4@(0x14), %a2
L61c:
	moveal	%a2@(4), %a0
	moveal	%d4, %a1
L622:
	cmpmb	%a0@+, %a1@+
	bneb	L630
	cmpib	#0x0, %a0@(-0x1)
	beqb	L63e
	brab	L622
L630:
	subqb	#0x1, %d0
	tstb	%d0
	beqw	L506
	leal	%a2@(0x14), %a2
	brab	L61c
L63e:
	leal	%a4@(0x14), %a0
	cmpal	%a0, %a2
	beqw	L698
	.short	0x203c
	.long	0xffffffec	/* movel #-20,d0 */
	.short	0x206a,0x0000		/* moveal a2@(0),a0 */
	.short	0x2572,0x0000,0x0000	/* movel a2@(0,d0:w),a2@(0) */
	movel	%a0, %a2@(0,%d0:w)
	moveal	%a2@(4), %a0
	movel	%a2@(4,%d0:w), %a2@(4)
	movel	%a0, %a2@(4,%d0:w)
	moveal	%a2@(8), %a0
	movel	%a2@(8,%d0:w), %a2@(8)
	movel	%a0, %a2@(8,%d0:w)
	moveal	%a2@(0xc), %a0
	movel	%a2@(0xc,%d0:w), %a2@(0xc)
	movel	%a0, %a2@(0xc,%d0:w)
	moveal	%a2@(0x10), %a0
	movel	%a2@(0x10,%d0:w), %a2@(0x10)
	movel	%a0, %a2@(0x10,%d0:w)
	addal	%d0, %a2
	brab	L63e
L698:
	movel	%a0, %d1
	addil	#0x8, %d1
	jsr	%a6@(-0xc0)
	moveal	%d4, %a1
	moveal	0x4:w, %a6
	jsr	%a6@(-0x2b2)
	braw	L58a

_addblk:
	moveml	%d4-%d5/%a4-%a6, %a7@-
	cmpal	#0x0, %a0
	beqb	L71e
	moveal	%a0, %a4
	moveal	%a4@(8), %a5
L6c4:
	cmpal	#0x0, %a5
	beqb	L6d8
	cmpl	%a5@(4), %d0
	beqb	L716
	.short	0x2a6d,0x0000		/* moveal a5@(0),a5 */
	brab	L6c4
L6d8:
	moveal	%a4@(8), %a5
	movel	%d0, %d5
	movel	%d1, %d4
	moveal	0x4:w, %a6
	moveq	#0x14, %d0
	muluw	#0x14, %d1
	addl	%d1, %d0
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqb	L71e
	movel	%d0, %a4@(8)
	moveal	%d0, %a4
	.short	0x294d,0x0000		/* movel a5,a4@(0) */
	movel	%d5, %a4@(4)
	moveb	%d4, %a4@(8)
	moveb	%d4, %a4@(9)
	moveb	#0x0, %a4@(0xa)
L716:
	moveq	#0x1, %d0
	moveml	%a7@+, %d4-%d5/%a4-%a6
	rts	
L71e:
	moveq	#0x0, %d0
	moveml	%a7@+, %d4-%d5/%a4-%a6
	rts	

_getblk:
	cmpal	#0x0, %a0
	beqb	L7a2
	moveal	%a0@(8), %a0
	cmpal	#0x0, %a0
	beqw	L7a2
L73c:
	movel	%a0@(4), %d1
	cmpl	%d1, %d0
	beqb	L752
	.short	0x2068,0x0000		/* moveal a0@(0),a0 */
	cmpal	#0x0, %a0
	beqb	L7a2
	brab	L73c
L752:
	moveq	#0x0, %d1
	moveb	%a0@(0xa), %d1
	movel	%d1, %d0
	cmpal	#0x0, %a1
	beqb	L7a0
	cmpb	%d1, %d2
	bgew	L76c
	moveb	%d2, %d1
	movel	%d2, %d0
L76c:
	tstl	%d1
	beqb	L7a0
	subqb	#0x1, %d1
	leal	%a0@(0x14), %a0
L776:
	.short	0x2368,0x0000,0x0000	/* movel a0@(0),a1@(0) */
	movel	%a0@(4), %a1@(4)
	movel	%a0@(8), %a1@(8)
	movel	%a0@(0xc), %a1@(0xc)
	movel	%a0@(0x10), %a1@(0x10)
	leal	%a0@(0x14), %a0
	leal	%a1@(0x14), %a1
	dbra	%d1,L776
L7a0:
	rts	
L7a2:
	moveq	#-1, %d0
	rts	

_save:
L7a6:
	moveml	%d4-%d6/%a3-%a6, %a7@-
	movel	%a0, %d0
	beqw	L89c
	moveal	%a6@(0x26), %a6
	moveal	%a0, %a5
	movel	%a0@(4), %d1
	movel	#0x3ee, %d2
	jsr	%a6@(-0x1e)
	tstl	%d0
	beqw	L89c
	movel	%d0, %d6
	movel	%d0, %d1
	movel	#_magic,%d2
	moveq	#0x4, %d3
	jsr	%a6@(-0x30)
	.short	0xb0bc
	.long	0x4		/* cmpl #4,d0 */
	bltw	L896
	moveal	%a5@(8), %a4
L7e8:
	cmpal	#0x0, %a4
	beqw	L88c
	movel	%d6, %d1
	leal	%a4@(4), %a0
	movel	%a0, %d2
	moveq	#0x4, %d3
	jsr	%a6@(-0x30)
	.short	0xb0bc
	.long	0x4		/* cmpl #4,d0 */
	bltw	L896
	movel	%d6, %d1
	leal	%a4@(9), %a0
	movel	%a0, %d2
	moveq	#0x2, %d3
	jsr	%a6@(-0x30)
	.short	0xb0bc
	.long	0x2		/* cmpl #2,d0 */
	bltb	L896
	moveq	#0x0, %d5
	moveb	%a4@(0xa), %d5
	subql	#0x1, %d5
	leal	%a4@(0x14), %a3
L82c:
	movel	%d6, %d1
	movel	%a3@(4), %d2
	moveal	%d2, %a0
L834:
	cmpib	#0x0, %a0@+
	bneb	L834
	subal	%d2, %a0
	movel	%a0, %d4
	moveb	%d4, %a4@(0xb)
	leal	%a4@(0xb), %a0
	movel	%a0, %d2
	moveq	#0x1, %d3
	jsr	%a6@(-0x30)
	.short	0xb0bc
	.long	0x1		/* cmpl #1,d0 */
	bltb	L896
	movel	%d6, %d1
	movel	%a3@(4), %d2
	movel	%d4, %d3
	jsr	%a6@(-0x30)
	cmpl	%d4, %d0
	bltb	L896
	movel	%d6, %d1
	leal	%a3@(8), %a0
	movel	%a0, %d2
	moveq	#0xc, %d3
	jsr	%a6@(-0x30)
	.short	0xb0bc
	.long	0xc		/* cmpl #12,d0 */
	bltb	L896
	leal	%a3@(0x14), %a3
	dbra	%d5,L82c
	.short	0x286c,0x0000		/* moveal a4@(0),a4 */
	braw	L7e8
L88c:
	movel	%d6, %d1
	jsr	%a6@(-0x24)
	moveq	#0x1, %d0
	brab	L89e
L896:
	movel	%d6, %d1
	jsr	%a6@(-0x24)
L89c:
	moveq	#0x0, %d0
L89e:
	moveml	%a7@+, %d4-%d6/%a3-%a6
	rts	

_setmax:
	moveml	%a4-%a5, %a7@-
	cmpal	#0x0, %a0
	beqw	L9be
	tstl	%d1
	beqw	L9be
	leal	%a0@(8), %a1
	moveal	%a1@, %a0
	cmpal	#0x0, %a0
	beqw	L9be
L8c8:
	cmpl	%a0@(4), %d0
	beqb	L8e2
	.short	0x43e8,0x0000		/* lea a0@(0),a1 */
	.short	0x2068,0x0000		/* moveal a0@(0),a0 */
	cmpal	#0x0, %a0
	beqw	L9be
	brab	L8c8
L8e2:
	cmpb	%a0@(8), %d1
	blew	L93e
	moveml	%d1/%a6, %a7@-
	moveq	#0x0, %d0
	moveb	%d1, %d0
	muluw	#0x14, %d0
	addil	#0x14, %d0
	moveal	%a0, %a4
	moveal	%a1, %a5
	moveal	0x4:w, %a6
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	tstl	%d0
	beqw	L9ba
	moveal	%a4, %a0
	movel	%d0, %a5@
	moveal	%d0, %a1
	moveq	#0x0, %d0
	moveb	%a0@(0xa), %d0
	muluw	#0x14, %d0
	addil	#0x14, %d0
	jsr	%a6@(-0x270)
	moveal	%a4, %a1
	jsr	%a6@(-0x2b2)
	moveml	%a7@+, %d1/%a6
	moveal	%a5@, %a0
	moveb	%d1, %a0@(8)
L93e:
	moveb	%d1, %a0@(9)
	cmpb	%a0@(0xa), %d1
	bgeb	L9b2
	moveml	%d5/%a6, %a7@-
	moveq	#0x0, %d5
	moveb	%a0@(0xa), %d5
	moveb	%d1, %a0@(0xa)
	subb	%d1, %d5
	subqb	#0x1, %d5
	moveal	0x4:w, %a6
	leal	%a0@(0x14), %a4
	moveq	#0x0, %d0
	moveb	%a0@(0xa), %d0
	muluw	#0x14, %d0
	addal	%d0, %a4
L96e:
	moveal	%a4@(4), %a1
	cmpal	#0x0, %a1
	beqb	L9a6
	jsr	%a6@(-0x2b2)
	.long	0x297c0000,0x00000000	/* movel #0,a4@(0) */
	movel	#0x0, %a4@(4)
	movel	#0x0, %a4@(8)
	movel	#0x0, %a4@(0xc)
	movel	#0x0, %a4@(0x10)
L9a6:
	leal	%a4@(0x14), %a4
	dbra	%d5,L96e
	moveml	%a7@+, %d5/%a6
L9b2:
	moveq	#0x1, %d0
	moveml	%a7@+, %a4-%a5
	rts	
L9ba:
	moveml	%a7@+, %d1/%a6
L9be:
	moveq	#0x0, %d0
	moveml	%a7@+, %a4-%a5
	rts	

_menu:
	moveml	%d5/%a3-%a5, %a7@-
	movel	%a6, %a7@-
	cmpal	#0x0, %a0
	beqw	Laf2
	cmpil	#0x0, %a6@(0x2a)
	beqw	Laf2
	moveal	%a0@(8), %a0
	cmpal	#0x0, %a0
	beqw	Laf2
L9f0:
	cmpl	%a0@(4), %d0
	beqb	La06
	.short	0x2068,0x0000		/* moveal a0@(0),a0 */
	cmpal	#0x0, %a0
	beqw	Laf2
	brab	L9f0
La06:
	moveal	%a0, %a5
	moveal	0x4:w, %a6
	moveq	#0x0, %d5
	moveb	%a5@(0xa), %d5
	addql	#0x2, %d5
	muluw	#0x14, %d5
	moveal	%a5@(0x10), %a1
	cmpal	#0x0, %a1
	beqb	La3e
	movel	%a1@+, %d0
	cmpl	%d5, %d0
	bgeb	La5e
	movel	%d1, %a7@-
	moveal	%a5@(0x10), %a1
	jsr	%a6@(-0x2b2)
	movel	%a7@+, %d1
	movel	#0x0, %a5@(0x10)
La3e:
	movel	%d1, %a7@-
	movel	%d5, %d0
	addql	#0x4, %d0
	movel	#0x10000, %d1
	jsr	%a6@(-0x2ac)
	movel	%a7@+, %d1
	tstl	%d0
	beqw	Laf2
	movel	%d0, %a5@(0x10)
	moveal	%d0, %a1
	movel	%d5, %a1@+
La5e:
	leal	%a5@(0x14), %a4
	moveq	#0x0, %d5
	moveb	%a5@(0xa), %d5
	.short	0x137c,0x0002,0x0000	/* moveb #2,a1@(0) */
	movel	#0x0, %a1@(2)
	leal	%a1@(0x14), %a1
	tstl	%d5
	beqb	Lab6
	subql	#0x1, %d5
La80:
	.short	0x137c,0x0003,0x0000	/* moveb #3,a1@(0) */
	.short	0x236c,0x0000,0x0002	/* movel a4@(0),a1@(2) */
	movel	#0x0, %a1@(6)
	movew	#0x0, %a1@(0xa)
	movel	#0x0, %a1@(0xc)
	movel	#0x0, %a1@(0x10)
	leal	%a4@(0x14), %a4
	leal	%a1@(0x14), %a1
	dbra	%d5,La80
Lab6:
	.long	0x237c0000,0x00000000	/* movel #0,a1@(0) */
	moveal	%a7@, %a6
	moveal	%a6@(0x2a), %a6
	moveal	%a5@(0x10), %a0
	addql	#0x4, %a0
	moveal	#0x0, %a1
	jsr	%a6@(-0x30)
	tstl	%d0
	beqb	Laf2
	movel	%d0, %d5
	moveal	%a5@(0xc), %a0
	cmpal	#0x0, %a0
	beqb	Laea
	jsr	%a6@(-0x36)
Laea:
	movel	%d5, %a5@(0xc)
	movel	%d5, %d0
	brab	Laf4
Laf2:
	moveq	#0x0, %d0
Laf4:
	moveal	%a7@+, %a6
	moveml	%a7@+, %d5/%a3-%a5
	rts	

_savefree:
	movel	%a1, %a7@-
	moveal	%a1@, %a0
	bsrw	L7a6
	moveal	%a7@+, %a1
	bsrw	L400
	rts	

/* ---- embedded data @0xb0c --------------------------------------- */
_envarc:.ascii	"ENVARC:Recent/"		/* 14B open-name prefix */
_magic:	.ascii	"RCNT"			/* @0xb1a file magic */
	.short	0				/* pad -> 0xb20 */
