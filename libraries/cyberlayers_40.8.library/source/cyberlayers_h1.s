/*
 * cyberlayers.library 40.8 -- byte-exact reconstruction, hunk1 (668 B).
 * Five CYBL records; _patchinstall fills +0xa with the cyberlayers lib
 * base and +0xe with the previous layers vector.
 *
 *   -36  CreateUpfrontLayer      @0x12   -> CUHL body with hook=NULL
 *   -186 CreateUpfrontHookLayer  @0x2e   SUPER->orig; else create as
 *          SIMPLE via CreateBehindHookLayer+UpfrontLayer, restore real
 *          flags, store hook @layer+118, ClearRegion, DoHookClipRects
 *   -60  MoveLayer               @0xe4   -> MSL(l,dx,dy,0,0)
 *   -66  SizeLayer               @0x108  -> MSL(l,0,0,dx,dy)
 *   -180 MoveSizeLayer           @0x130  SMART layers: if no obscured
 *          cliprects and no overlap with layers in front, temporarily
 *          relabel SIMPLE and call orig; else call orig unchanged
 *   0x26e rect-overlap helper
 *
 * rt_EndSkip points at h1+0x29c (end of file).
 */
	.text
	.globl	_h1f1,_h1f2,_h1f3,_h1f4,_h1f5,_h1end

/* ==== 0x00 record 1: CreateUpfrontLayer ========================== */
	.ascii	"CYBL"
	.short	0x27			/* required exec version 39    */
	.short	1,0
	.long	0			/* +0xa libbase slot (@0x0a)   */
	.long	0			/* +0xe oldvec slot (@0x0e)    */
_h1f1:	movel	%a3,%sp@-		/* 0x12                        */
	subal	%a3,%a3			/* hook = NULL                 */
	bsrs	_h1f2
	moveal	%sp@+,%a3
	rts

/* ==== 0x1c record 2: CreateUpfrontHookLayer ====================== */
_rec2:	.ascii	"CYBL"
	.short	0x27
	.short	1,0
	.long	0			/* +0xa libbase slot (@0x26)   */
	.long	0			/* +0xe oldvec slot (@0x2a)    */
_h1f2:	btst	#2,%d4			/* 0x2e: flags & 4 (SUPER)?    */
	beqs	_f2new
	movel	_rec2+14(%pc),%sp@-	/* SUPER -> orig vector        */
	rts
_f2new:	moveml	%a4,%sp@-		/* 0x3a                        */
	moveal	%a0,%a4			/* a4 = layerinfo              */
	moveml	%d0-%d1/%a0-%a1,%sp@-
	jsr	%a6@(-120)		/* LockLayerInfo(li)           */
	moveml	%sp@+,%d0-%d1/%a0-%a1
	moveml	%d4/%a2,%sp@-
	moveml	%a3,%sp@-
	lea	1:w,%a3			/* hook = (Hook*)1 sentinel    */
	andib	#-3,%d4			/* flags &= ~2 (clr SMART)     */
	orib	#1,%d4			/* flags |= 1 (set SIMPLE)     */
	jsr	%a6@(-192)		/* CreateBehindHookLayer       */
	moveml	%sp@+,%a3
	moveal	%d0,%a2			/* a2 = new layer              */
	tstl	%d0
	beqs	_f2done
	moveal	%a2,%a1
	subal	%a0,%a0			/* dummy = 0                   */
	jsr	%a6@(-48)		/* UpfrontLayer(0,layer)       */
	movel	%sp@,%d4		/* d4 = original flags         */
	andiw	#-4,%a2@(30)		/* layer->Flags &= ~3          */
	andiw	#3,%d4
	orw	%d4,%a2@(30)		/* restore type bits           */
	movel	%a3,%a2@(118)		/* layer+118 = real hook       */
	movel	%a6,%sp@-
	movel	_rec2+10(%pc),%a6	/* a6 = cyberlayers base       */
	moveal	%a6@(46),%a6		/* graphics base               */
	moveal	%a2@(156),%a0		/* layer+156 = ClipRegion      */
	jsr	%a6@(-528)		/* ClearRegion                 */
	moveal	%sp@+,%a6
	andiw	#-1665,%a2@(30)		/* Flags &= ~0x680             */
	cmpal	#1,%a3			/* hook sentinel?              */
	beqs	_f2done
	moveml	%a2,%sp@-
	moveal	%a3,%a0			/* hook                        */
	moveal	%a2@(12),%a1		/* layer->rp                   */
	subal	%a2,%a2			/* rect = NULL                 */
	jsr	%a6@(-216)		/* DoHookClipRects             */
	moveml	%sp@+,%a2
_f2done:
	moveal	%a4,%a0			/* 0xc0: layerinfo             */
	jsr	%a6@(-138)		/* UnlockLayerInfo             */
	movel	%a2,%d0
	moveml	%sp@+,%d4/%a2
	moveml	%sp@+,%a4
	rts

/* ==== 0xd2 record 3: MoveLayer =================================== */
	.ascii	"CYBL"
	.short	0x27
	.short	1,0
	.long	0			/* +0xa libbase slot (@0xdc)   */
	.long	0			/* +0xe oldvec slot (@0xe0)    */
_h1f3:	moveml	%d2-%d3,%sp@-		/* 0xe4                        */
	moveq	#0,%d2			/* dw = 0                      */
	movel	%d2,%d3			/* dh = 0                      */
	moveal	%a1,%a0			/* a0 = layer                  */
	bsrs	_h1f5			/* -> MoveSizeLayer            */
	moveml	%sp@+,%d2-%d3
	rts

/* ==== 0xf6 record 4: SizeLayer =================================== */
	.ascii	"CYBL"
	.short	0x27
	.short	1,0
	.long	0			/* +0xa libbase slot (@0x100)  */
	.long	0			/* +0xe oldvec slot (@0x104)   */
_h1f4:	moveml	%d2-%d3,%sp@-		/* 0x108                       */
	movel	%d0,%d2			/* dw = dx arg                 */
	movel	%d1,%d3			/* dh = dy arg                 */
	moveq	#0,%d0			/* dx = 0                      */
	movel	%d0,%d1			/* dy = 0                      */
	moveal	%a1,%a0			/* a0 = layer                  */
	bsrs	_h1f5			/* -> MoveSizeLayer            */
	moveml	%sp@+,%d2-%d3
	rts

/* ==== 0x11e record 5: MoveSizeLayer ============================== */
_rec5:	.ascii	"CYBL"
	.short	0x27
	.short	1,0
	.long	0			/* +0xa libbase slot (@0x128)  */
	.long	0			/* +0xe oldvec slot (@0x12c)   */
_h1f5:	movemw	%d0,%sp@-		/* 0x130                       */
	movew	%a0@(30),%d0		/* layer->Flags                */
	andiw	#7,%d0
	.short	0xb07c,0x0002		/* cmpw #2,d0 (SMART?)         */
	movemw	%sp@+,%d0
	bnew	_msl_orig		/* not SMART -> orig           */
	movemw	%d0,%sp@-
	orw	%d1,%d0			/* any of dx|dy|dw|dh != 0 ?   */
	orw	%d2,%d0
	orw	%d3,%d0
	tstw	%d0
	movemw	%sp@+,%d0
	bnes	_msl_check
	moveq	#1,%d0
	rts				/* no-op move -> return 1      */
_msl_check:
	lea	%sp@(-8),%sp		/* local rect                  */
	.short	0x3f68,0x0010,0x0000	/* movew a0@(16),sp@(0)        */
	.short	0xd16f,0x0000		/* addw  d0,sp@(0)  MinX+dx    */
	.short	0x3f68,0x0012,0x0002	/* movew a0@(18),sp@(2)        */
	.short	0xd36f,0x0002		/* addw  d1,sp@(2)  MinY+dy    */
	.short	0x3f68,0x0014,0x0004	/* movew a0@(20),sp@(4)        */
	.short	0xd16f,0x0004		/* addw  d0,sp@(4)             */
	.short	0xd56f,0x0004		/* addw  d2,sp@(4)  MaxX+dx+dw */
	.short	0x3f68,0x0016,0x0006	/* movew a0@(22),sp@(6)        */
	.short	0xd36f,0x0006		/* addw  d1,sp@(6)             */
	.short	0xd76f,0x0006		/* addw  d3,sp@(6)  MaxY+dy+dh */
	movemw	%d0,%sp@-
	movew	%sp@(6),%d0		/* new MaxY                    */
	cmpw	%sp@(2),%d0		/* < new MinY?                 */
	blts	_msl_bad
	movew	%sp@(8),%d0		/* new MaxX (d0 push shifted)  */
	cmpw	%sp@(4),%d0		/* < new MinX?                 */
	blts	_msl_bad
	movemw	%sp@+,%d0
	bras	_msl_go
_msl_bad:
	addqw	#2,%sp			/* drop pushed word            */
	moveq	#0,%d0
	rts				/* degenerate rect -> 0        */
_msl_go:
	moveml	%d7,%sp@-
	moveq	#1,%d7			/* d7 = fast-path flag         */
	moveml	%d0-%d1/%a0-%a1,%sp@-
	moveal	%a0@(68),%a0		/* layer+68 = LayerInfo        */
	jsr	%a6@(-120)		/* LockLayerInfo               */
	moveml	%sp@+,%d0-%d1/%a0-%a1
	moveal	%a0@(68),%a1		/* li                          */
	.short	0xb1e9,0x0000		/* cmpal a1@(0),a0             */
	beqs	_msl_scan2		/* layer == li+0 -> skip scan  */
	moveal	%a0@(8),%a1		/* a1 = layer->ClipRect        */
_msl_scan:
	tstl	%a1@(8)			/* cr->lobs ?                  */
	bnes	_msl_obs		/* obscured -> slow path       */
	.short	0x4aa9,0x0000		/* tstl a1@(0)  cr->Next       */
	beqs	_msl_test		/* end of chain -> test        */
	.short	0x2269,0x0000		/* moveal a1@(0),a1            */
	bras	_msl_scan
_msl_obs:
	moveq	#0,%d7
_msl_test:
	tstl	%d7
	beqs	_msl_scan2
	lea	%sp@(4),%a1		/* a1 = new rect               */
	moveml	%d0-%d1/%a0/%a2,%sp@-
	moveal	%a0,%a2			/* a2 = layer                  */
_msl_front:
	.short	0x202a,0x0000		/* movel a2@(0),d0 (front ptr) */
	beqs	_msl_fdone
	moveal	%d0,%a2
	lea	%a2@(16),%a0		/* front layer bounds          */
	bsrw	_roverlap		/* overlap with new rect?      */
	tstl	%d0
	beqs	_msl_front		/* keep scanning               */
	moveq	#0,%d7			/* overlaps -> slow path       */
_msl_fdone:
	moveml	%sp@+,%d0-%d1/%a0/%a2
_msl_scan2:
	tstl	%d7
	beqs	_msl_slow
	moveml	%sp@+,%d7
	lea	%sp@(8),%sp		/* drop local rect             */
	bclr	#1,%a0@(31)		/* Flags &= ~2 (clr SMART)     */
	bset	#0,%a0@(31)		/* Flags |= 1 (set SIMPLE)     */
	movel	%a0,%sp@-
	bsrs	_msl_orig		/* call orig as SIMPLE         */
	moveal	%sp@+,%a0
	bset	#1,%a0@(31)		/* restore SMART               */
	bclr	#0,%a0@(31)		/* restore ~SIMPLE             */
	bras	_msl_fin
_msl_slow:
	moveml	%sp@+,%d7
	lea	%sp@(8),%sp
	moveml	%a0,%sp@-
	pea	_msl_ret(%pc)		/* 0x258                       */
_msl_orig:
	movel	_rec5+14(%pc),%sp@-	/* push orig MSL vector        */
	rts
_msl_ret:
	moveml	%sp@+,%a0
_msl_fin:
	moveml	%d0,%sp@-
	moveal	%a0@(68),%a0		/* LayerInfo                   */
	jsr	%a6@(-138)		/* UnlockLayerInfo             */
	moveml	%sp@+,%d0
	rts

/* ==== 0x26e rect overlap: (a0,a1) -> d0 =========================== */
_roverlap:
	moveq	#0,%d0
	movew	%a0@(4),%d1		/* a0.MaxX                     */
	.short	0xb269,0x0000		/* cmpw a1@(0),d1  < a1.MinX ? */
	blts	_rodone
	.short	0x3228,0x0000		/* movew a0@(0),d1 a0.MinX     */
	cmpw	%a1@(4),%d1		/* > a1.MaxX ?                 */
	bgts	_rodone
	movew	%a0@(6),%d1		/* a0.MaxY                     */
	cmpw	%a1@(2),%d1		/* < a1.MinY ?                 */
	blts	_rodone
	movew	%a0@(2),%d1		/* a0.MinY                     */
	cmpw	%a1@(6),%d1		/* > a1.MaxY ?                 */
	bgts	_rodone
	moveq	#1,%d0
_rodone:
	rts

_h1end:					/* rt_EndSkip = h1+0x29c       */
