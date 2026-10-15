/* cachemap.library 34.5 (10.3.92) — byte-verbatim reconstruction.
 * Single CODE hunk (0x39c), AUTOINIT RomTag, word-offset functab
 * (-1W marker/terminator, offsets from table start), 12 vectors:
 * -6 Open, -12 Close, -18 Expunge, -24 -> module entry (neg offset),
 * then 8 user LVOs -30..-72 (CreateMap/DeleteMap/AllocMapPlanes/
 * LockMap/UnlockMap/MapPlaneSize/FillMapPlanes/ScaleBits).
 * Quirks kept verbatim: strings butt-packed (libname at odd 0x371,
 * gfx name "graphics.library" sits at 0x360 in front of it),
 * CreateMap AllocMem flags 0x00010001 (MEMF_CLEAR | undocumented
 * low bit), expunge frees plane buffers but leaks the node blocks,
 * all three string literals share the tail of the code stream.
 * Relocs (single hunk0 group) ascend 6,a,12,16,1a,22,2a like ld.
 */
	.text

/* ---- entry stub + RomTag ------------------------------------- */
_entry:					/* 0x00 -- module entry / LVO -24 */
	moveq	#0,d0
	rts

_romtag:				/* 0x04 */
	.short	0x4afc			/* RT_MATCHWORD */
	.long	_romtag			/* rt_MatchTag */
	.long	_endskip		/* rt_EndSkip -> 0x39c */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	34			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_libname		/* 0x371 */
	.long	_idstr			/* 0x382 */
	.long	_inittab		/* 0x1e */

/* ---- InitTable ------------------------------------------------ */
_inittab:				/* 0x1e */
	.long	0x3c			/* dataSize */
	.long	_functab		/* 0x2e */
	.long	0			/* no InitStruct data */
	.long	_init			/* 0x4a */

/* ---- word-offset function table ------------------------------- */
_functab:				/* 0x2e */
	.short	0xffff			/* word-offset marker */
	.short	_open-_functab		/* -6   Open        -> 0x9e  */
	.short	_close-_functab		/* -12  Close       -> 0xa6  */
	.short	_expunge-_functab	/* -18  Expunge     -> 0xae  */
	.short	_entry-_functab		/* -24  -> 0x00 (0xffd2)     */
	.short	_createmap-_functab	/* -30  CreateMap   -> 0x118 */
	.short	_deletemap-_functab	/* -36  DeleteMap   -> 0x1bc */
	.short	_allocplanes-_functab	/* -42  AllocPlanes -> 0x220 */
	.short	_lockmap-_functab	/* -48  LockMap     -> 0x266 */
	.short	_unlockmap-_functab	/* -54  UnlockMap   -> 0x27e */
	.short	_mapplanesize-_functab	/* -60  PlaneSize   -> 0x284 */
	.short	_fillplanes-_functab	/* -66  FillPlanes  -> 0x28a */
	.short	_scalebits-_functab	/* -72  ScaleBits   -> 0x2da */
	.short	0xffff			/* 0x48 terminator */

/* ---- init: fill in Library fields, open graphics -------------- */
_init:					/* 0x4a (d0=base a0=seglist a6=exec) */
	moveal	d0,%a1
	movel	%a6,%a1@(40)		/* execbase */
	movel	%a0,%a1@(36)		/* seglist */
	clrw	%a1@(34)		/* opencnt */
	clrw	%a1@(32)		/* pad */
	lea	%a1@(48),%a0		/* node list */
	movel	%a0,%a0@(8)		/* lh_TailPred = head */
	addql	#4,%a0
	clrl	%a0@			/* lh_Tail = NULL */
	movel	%a0,%a0@-		/* lh_Head = &tail */
	lea	%pc@(_libname),%a0
	movel	%a0,%a1@(10)		/* ln_Name */
	lea	%pc@(_idstr),%a0
	movel	%a0,%a1@(24)		/* lib_IdString */
	movew	#34,%a1@(20)		/* lib_Version */
	movew	#5,%a1@(22)		/* lib_Revision */
	movel	%a1,%sp@-
	lea	%pc@(_gfxname),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)		/* OpenLibrary("graphics.library",0) */
	moveal	%sp@+,%a1
	movel	%d0,%a1@(44)		/* gfxbase */
	beqs	1f			/* open failed -> d0 stays 0 */
	movel	%a1,%d0		/* else return libbase */
1:	rts				/* 0x9c */

/* ---- LVO -6 Open ---------------------------------------------- */
_open:					/* 0x9e */
	addqw	#1,%a6@(34)
	movel	%a6,%d0
	rts

/* ---- LVO -12 Close -------------------------------------------- */
_close:					/* 0xa6 */
	subqw	#1,%a6@(34)
	moveq	#0,%d0
	rts

/* ---- LVO -18 Expunge ------------------------------------------ */
_expunge:				/* 0xae */
	movel	%a6,%sp@-
	moveal	%a6@(40),%a6
	jsr	%a6@(-132)		/* Forbid */
	moveal	%sp@+,%a6
	movel	%a6@(48),%d0		/* lh_Head */
2:	moveal	%d0,%a1
	movel	%a1@,%d0		/* ln_Succ */
	beqs	3f
	tstw	%a1@(16)		/* node lock count */
	bnes	2b
	bsrw	_freeplanes		/* free this node's planes (leaks node) */
	bras	2b
3:	movel	%a6,%sp@-
	moveal	%a6@(40),%a6
	jsr	%a6@(-138)		/* Permit */
	moveal	%sp@+,%a6
	moveq	#0,%d0
	tstw	%a6@(34)		/* opencnt */
	bnes	4f
	moveal	%a6,%a1
	movew	%a6@(16),%d0		/* lib_NegSize */
	subal	%d0,%a1		/* a1 = base - negsize */
	addw	%a6@(18),%d0		/* d0 = neg+pos size */
	moveml	%d2/%a6,%sp@-
	movel	%a6@(36),%d2		/* seglist (returned) */
	moveal	%a6,%a0
	moveal	%a6@(40),%a6
	moveml	%d0/%a1,%sp@-
	moveal	%a0,%a1
	jsr	%a6@(-252)		/* Remove(node) */
	moveml	%sp@+,%d0/%a1
	jsr	%a6@(-210)		/* FreeMem(memstart,size) */
	movel	%d2,%d0
	moveml	%sp@+,%d2/%a6
4:	rts				/* 0x116 */

/* ---- LVO -30 CreateMap ---------------------------------------- */
/* d0=width d1=height d2=depth d3=dataSize d4=plane-alloc flags      */
_createmap:				/* 0x118 */
	moveml	%d2-%d7/%a2-%a3,%sp@-
	moveal	%a6,%a3		/* a3 = libbase */
	movel	%d0,%d5
	movel	%d1,%d6
	moveq	#0,%d0
	moveq	#3,%d7
	andl	%d3,%d7		/* dataSize must be long-aligned */
	bnew	5f			/* 0x1b6 -> return 0 */
	moveq	#36,%d0
	addl	%d3,%d0		/* node hdr + caller data */
	movel	%d2,%d1
	addl	%d1,%d1
	addl	%d1,%d1		/* 4*depth (BitMap struct) */
	addl	%d1,%d0
	movel	#0x00010001,%d1	/* MEMF_CLEAR + undocumented low bit */
	moveal	%a6@(40),%a6
	movel	%d0,%d7		/* alloc size */
	jsr	%a6@(-198)		/* AllocMem */
	moveal	%a3,%a6
	moveal	%d0,%a2		/* a2 = node */
	tstl	%d0
	beqs	5f
	movel	%d7,%a2@(8)		/* +8  allocsize (FreeMem) */
	movel	%d3,%a2@(12)		/* +12 dataSize */
	movew	%d2,%a2@(18)		/* +18 depth */
	movel	%d4,%a2@(24)		/* +24 plane flags */
	lea	%a2@(28),%a0
	addal	%a2@(12),%a0		/* a0 = node+28+dataSize = BitMap */
	movel	%d2,%d0		/* depth */
	movel	%d5,%d1		/* width */
	movel	%d6,%d2		/* height */
	moveal	%a6@(44),%a6		/* gfxbase */
	movel	%a0,%d3
	jsr	%a6@(-390)		/* InitBitMap(bm,depth,w,h) */
	moveal	%d3,%a0
	moveal	%a3,%a6
	moveq	#0,%d0
	movew	%a0@,%d0		/* bm_BytesPerRow */
	movew	%a0@(2),%d1		/* bm_Rows */
	muluw	%d1,%d0		/* plane size */
	movel	%d0,%a2@(20)		/* +20 planeSize */
	moveal	%a2,%a1
	bsrw	_allocplanes		/* allocate depth plane buffers */
	tstl	%d0
	beqs	6f			/* fail -> free node */
	moveal	%a6@(40),%a6
	jsr	%a6@(-132)		/* Forbid */
	moveal	%a2,%a1
	lea	%a3@(48),%a0
	jsr	%a6@(-240)		/* AddTail(list,node) */
	jsr	%a6@(-138)		/* Permit */
	moveal	%a3,%a6
	movel	%a2,%d0
	bras	5f
6:	moveal	%a2,%a1
	bsrs	_freenode		/* free node block */
	moveq	#0,%d0
5:	moveml	%sp@+,%d2-%d7/%a2-%a3	/* 0x1b6 */
	rts

/* ---- LVO -36 DeleteMap ---------------------------------------- */
_deletemap:				/* 0x1bc (a1=node) */
	moveml	%a1/%a6,%sp@-
	lea	%a6@(48),%a0
	moveal	%a6@(40),%a6
	jsr	%a6@(-132)		/* Forbid */
	jsr	%a6@(-252)		/* Remove(node) */
	jsr	%a6@(-138)		/* Permit */
	moveml	%sp@+,%a1/%a6
	bsrs	_freeplanes		/* free planes, fall into freenode */
_freenode:				/* 0x1da */
	movel	%a1@(8),%d0		/* allocsize */
	movel	%a6,%sp@-
	moveal	%a6@(40),%a6
	jsr	%a6@(-210)		/* FreeMem(node,size) */
	moveal	%sp@+,%a6
	rts

/* ---- helper: free all plane buffers of a node ----------------- */
_freeplanes:				/* 0x1ec (a1=node) */
	moveml	%d0-%d3/%a0-%a2/%a6,%sp@-
	moveal	%a6@(40),%a6
	movel	%a1@(20),%d2		/* planeSize */
	movew	%a1@(18),%d3		/* depth */
	subqw	#1,%d3
	lea	%a1@(28),%a2
	addal	%a1@(12),%a2		/* &BitMap */
	addql	#8,%a2			/* bm_Planes[] */
7:	movel	%a2@,%d1		/* plane ptr */
	beqs	8f
	moveal	%d1,%a1
	movel	%d2,%d0
	jsr	%a6@(-210)		/* FreeMem(plane,planeSize) */
8:	clrl	%a2@+
	dbf	%d3,7b
	moveml	%sp@+,%d0-%d3/%a0-%a2/%a6
	rts

/* ---- LVO -42 AllocMapPlanes ----------------------------------- */
_allocplanes:				/* 0x220 (a1=node) -> dataarea or 0 */
	moveml	%d2/%a2-%a3,%sp@-
	movew	%a1@(18),%d2		/* depth */
	subqw	#1,%d2
	lea	%a1@(28),%a2
	addal	%a1@(12),%a2		/* &BitMap */
	addql	#8,%a2			/* bm_Planes[] */
	moveal	%a1,%a3
	movel	%a6,%sp@-
	moveal	%a6@(40),%a6
9:	movel	%a3@(20),%d0		/* planeSize */
	movel	%a3@(24),%d1		/* flags */
	jsr	%a6@(-198)		/* AllocMem */
	movel	%d0,%a2@+		/* store plane ptr */
	dbeq	%d2,9b			/* loop while alloc ok */
	moveal	%sp@+,%a6
	moveal	%a3,%a1
	bnes	10f			/* last alloc failed */
	bsrs	_freeplanes		/* unwind partial allocs */
	moveq	#0,%d0
	bras	11f
10:	lea	%a1@(28),%a0		/* return &node->dataarea */
	movel	%a0,%d0
11:	moveml	%sp@+,%d2/%a2-%a3
	rts

/* ---- LVO -48 LockMap ------------------------------------------ */
_lockmap:				/* 0x266 (a1=node) -> dataarea or 0 */
	addqw	#1,%a1@(16)		/* lock++ */
	lea	%a1@(28),%a0
	movel	%a0,%d0		/* dataarea */
	addal	%a1@(12),%a0		/* &BitMap */
	tstl	%a0@(8)			/* bm_Planes[0] */
	bnes	12f
	moveq	#0,%d0		/* no planes -> fail (still locked) */
12:	rts

/* ---- LVO -54 UnlockMap ---------------------------------------- */
_unlockmap:				/* 0x27e (a1=node) */
	subqw	#1,%a1@(16)
	rts

/* ---- LVO -60 MapPlaneSize ------------------------------------- */
_mapplanesize:				/* 0x284 (a1=node) -> planeSize */
	movel	%a1@(20),%d0
	rts

/* ---- LVO -66 FillMapPlanes ------------------------------------ */
/* d0 = fill bit pattern; copies bit0 of d0 shifted per plane,      */
/* fills each allocated plane with 0x00000000 or 0xffffffff.       */
_fillplanes:				/* 0x28a (a1=node) */
	moveml	%d2-%d4/%a2,%sp@-
	addqw	#1,%a1@(16)		/* lock++ */
	lea	%a1@(28),%a0
	addal	%a1@(12),%a0		/* &BitMap */
	addql	#8,%a0			/* planes[] */
	movel	%a1@(20),%d3		/* planeSize */
	movew	%a1@(18),%d2		/* depth */
	bras	16f
13:	moveq	#0,%d4			/* 0x2a6 */
	lsrw	#1,%d0			/* next fill bit -> X */
	subxl	%d4,%d4			/* d4 = 0 or -1 */
	movel	%a0@+,%d1		/* plane ptr */
	beqs	16f			/* unallocated plane -> skip */
	moveal	%d1,%a2
	movel	%d3,%d1
	lsrl	#2,%d1			/* longword fill count */
	bras	15f
14:	movel	%d4,%a2@+
15:	dbf	%d1,14b
	moveq	#3,%d1
	andl	%d3,%d1			/* remainder bytes */
	beqs	16f
	bras	18f
17:	moveb	%d4,%a2@+
18:	dbf	%d1,17b
16:	dbf	%d2,13b			/* 0x2cc next plane */
	subqw	#1,%a1@(16)		/* lock-- */
	moveml	%sp@+,%d2-%d4/%a2
	rts

/* ---- LVO -72 ScaleBits ---------------------------------------- */
/* Bresenham bit-stream replicator: expand a0 bitstream (d0 src     */
/* bits) into a1 buffer at ratio d0:d1; d1 counts output bits.      */
_scalebits:				/* 0x2da */
	moveml	%d2-%d7/%a2-%a5,%sp@-
	movel	%d1,%d2
	divuw	%d0,%d2			/* lo=quot hi=rem */
	moveaw	%d0,%a5		/* srcbits */
	movew	%d0,%d3
	asrw	#1,%d3
	negw	%d3			/* err = -srcbits/2 */
	exg	%d3,%a2			/* a2 <- err */
	exg	%d2,%a2			/* a2 <- quot+rem pair, d2 <- err */
	moveq	#32,%d6		/* out bits free in d7 */
	moveq	#1,%d4			/* src reload countdown */
	subql	#1,%d0
19:	addl	%d5,%d5			/* 0x2f4: next src bit -> sign */
	subqw	#1,%d4
	bnes	20f
	movel	%a0@+,%d5		/* reload src long */
	moveq	#32,%d4
20:	movel	%a2,%d3			/* 0x2fe: quot:rem */
	swap	%d3			/* rem in low word */
	addw	%d3,%d2			/* err += rem */
	bmis	21f
	swap	%d3			/* quot */
	addqw	#1,%d3			/* emit quot+1 copies */
	subw	%a5,%d2			/* err -= srcbits */
	bras	22f
21:	swap	%d3			/* emit quot copies */
22:	tstw	%d3			/* 0x310 */
	beqs	26f			/* zero repeats -> next bit */
	moveal	%d0,%a3		/* save srcbit counter */
	moveaw	%d4,%a4		/* save reload countdown */
23:	movew	%d3,%d0			/* 0x318: n = min(d3,d6) */
	cmpw	%d0,%d6
	bpls	24f
	movew	%d6,%d0
24:	asll	%d0,%d7			/* room for n bits */
	tstl	%d5			/* src bit set? (sign) */
	bpls	25f
	moveq	#1,%d4
	asll	%d0,%d4
	subql	#1,%d4			/* (1<<n)-1 */
	orl	%d4,%d7			/* emit n one-bits */
25:	subw	%d0,%d6			/* 0x32e: out bits free -= n */
	bnes	27f
	movel	%d7,%a1@+		/* flush 32-bit word */
	moveq	#32,%d6
	subl	%d6,%d1			/* outbits left -= 32 */
	subw	%d0,%d3			/* repeats left -= n */
	bnes	23b
27:	movew	%a4,%d4			/* 0x33c: restore countdown */
	movel	%a3,%d0			/* restore srcbit counter */
26:	dbf	%d0,19b			/* 0x340: next src bit */
	tstl	%d1			/* leftover out bits? */
	beqs	30f
	asll	%d6,%d7			/* flush partial, pad low */
	cmpil	#17,%d1			/* >=17 left -> long store */
	bpls	29f
	swap	%d7
	movew	%d7,%a1@+		/* word store */
	bras	30f
29:	movel	%d7,%a1@+		/* long store */
30:	moveml	%sp@+,%d2-%d7/%a2-%a5	/* 0x35a */
	rts

/* ---- packed strings (no alignment!) ---------------------------- */
_gfxname:				/* 0x360 */
	.ascii	"graphics.library"
	.byte	0
_libname:				/* 0x371 (odd address) */
	.ascii	"cachemap.library"
	.byte	0
_idstr:					/* 0x382 */
	.ascii	"CacheMap 34.5 (10.3.92)"
	.byte	13,10,0			/* "\r\n\0" -> ends at 0x39c */
_endskip:
	.end
