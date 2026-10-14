/* streplay.library V33.8 -- byte-exact reconstruction of
 * 'STReplay.Library V33.8 Kludged 2.10.89 by Olli, dem Groesten'
 * Single CODE hunk, AUTOINIT, 10 vectors.  All player state lives in
 * absolute-addressed cells inside this hunk (self-modifying code).
 */

	.text

/* ==== 0x000 DOS-run stub ========================================= */
	moveq	#20,%d0
	rts

/* ==== 0x004 RomTag (AUTOINIT) ==================================== */
_RomTag:
	.short	0x4afc
	.long	_RomTag			/* matchtag -> self */
	.long	_EndSkip		/* -> 0x23e */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	33			/* version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* pri */
	.long	_libname		/* -> 0x1e */
	.long	_idstr			/* -> 0x2f */
	.long	_InitTable		/* -> 0x6e */

/* ==== 0x01e strings ============================================== */
_libname:
	.ascii	"streplay.library\0"		/* note: 'n' before it is the init ptr lo byte */
_idstr:
	.ascii	"STReplay.Library V33.8 Kludged 2.10.89 by Olli, dem Gr\366\337ten\r\n"
	.byte	0,0

/* ==== 0x06e InitTable ============================================ */
_InitTable:
	.long	0x30			/* dataSize */
	.long	_functab		/* -> 0x7e */
	.long	_datatab		/* -> 0xaa */
	.long	_initfn			/* -> 0xd6 */

/* ==== 0x07e functab: 10 absolute longs =========================== */
_functab:
	.long	_open			/* -6   0x104 */
	.long	_close			/* -12  0x112 */
	.long	_expunge		/* -18  0x122 */
	.long	_null			/* -24  0x166 */
	.long	_loadmod		/* -30  0x178 */
	.long	_unload			/* -36  0x1fc */
	.long	_modptr			/* -42  0x172 */
	.long	_play			/* -48  0x202 */
	.long	_stop			/* -54  0x21c */
	.long	_isplay			/* -60  0x16a */
	.long	-1

/* ==== 0xaa datatab (InitStruct stream, e0/c0/d0 forms) ============ */
_datatab:
	.byte	0xe0,0x00
	.short	0x08
	.byte	0x09,0x00		/* ln_Type = NT_LIBRARY (+pad) */
	.byte	0xc0,0x00
	.short	0x0a
	.long	_libname		/* ln_Name */
	.byte	0xe0,0x00
	.short	0x0e
	.byte	0x06,0x00		/* lib_Flags = LIBF_CHANGED|SUMUSED */
	.byte	0xd0,0x00
	.short	0x14
	.short	33			/* lib_Version */
	.byte	0xd0,0x00
	.short	0x16
	.short	8			/* lib_Revision */
	.byte	0xc0,0x00
	.short	0x18
	.long	_idstr			/* ln_IdString */
	.short	0,0

/* ==== 0xd6 initfn: d0=libbase, a0=seglist ========================= */
_initfn:
	moveal	%d0,%a1
	movel	%a0,%a1@(34)		/* lib+0x22 = seglist */
	clrl	%a1@(38)		/* lib+0x26 = module buf */
	clrw	%a1@(46)		/* lib+0x2e = playing flag */
	rts

/* ==== 0xe6 freebuf helper (local) ================================= */
_freebuf:
	movel	%a6@(38),%d0		/* module buffer */
	beqs	_openrts		/* orig quirk: shares Open's rts */
	movel	%a6,%sp@-
	moveal	%d0,%a1
	movel	%a6@(42),%d0		/* size */
	moveal	4:w,%a6
	jsr	%a6@(-210)		/* FreeMem */
	moveal	%sp@+,%a6
	clrl	%a6@(38)
	rts

/* ==== 0x104 Open ================================================= */
_open:
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)		/* LIBF_DELEXP */
	movel	%a6,%d0
_openrts:
	rts

/* ==== 0x112 Close ================================================ */
_close:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	_openrts
	btst	#3,%a6@(14)
	beqs	_openrts
/* ==== 0x122 Expunge ============================================== */
_expunge:
	tstw	%a6@(32)
	beqs	1f
	bset	#3,%a6@(14)		/* deferred */
	moveq	#0,%d0
	rts
1:	bsrw	_stop			/* stop int + free via unload core */
	bsrs	_freebuf
	moveml	%d7/%a5,%sp@-
	moveal	%a6,%a5
	moveal	4:w,%a6
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove */
	movel	%a5@(34),%d7		/* seglist */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* negsize */
	subal	%d0,%a1
	addw	%a5@(18),%d0		/* + possize */
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d7,%d0
	moveml	%sp@+,%d7/%a5
	rts

/* ==== 0x166 null vector ========================================== */
_null:
	moveq	#0,%d0
	rts

/* ==== 0x16a -60 IsPlaying: d0 = lib+0x2e ========================= */
_isplay:
	movew	%a6@(46),%d0
	extl	%d0
	rts

/* ==== 0x172 -42 ModulePtr: d0 = lib+0x26 ========================= */
_modptr:
	movel	%a6@(38),%d0
	rts

/* ==== 0x178 -30 LoadModule: a0 = filename -> d0 (0/-1/-2) ========= */
_loadmod:
	moveml	%d2-%d5/%a5-%a6,%sp@-
	movel	%a0,%d3			/* name */
	bsrw	_stop
	bsrw	_freebuf
	moveal	%a6,%a5
	moveal	4:w,%a6
	lea	%pc@(_dosname),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)		/* OldOpenLibrary */
	movel	%d0,%d4
	moveal	%d0,%a6
	movel	%d3,%d1
	movel	#1005,%d2		/* MODE_OLDFILE */
	jsr	%a6@(-30)		/* dos.Open */
	movel	%d0,%d5
	bnes	1f
	moveq	#-1,%d0			/* open failed */
2:	moveml	%sp@+,%d2-%d5/%a5-%a6
	rts
1:	movel	%d5,%d1
	moveq	#0,%d2
	moveq	#1,%d3
	jsr	%a6@(-66)		/* Seek end? (0,1) */
	movel	%d5,%d1
	moveq	#0,%d2
	moveq	#-1,%d3
	jsr	%a6@(-66)		/* Seek(0,-1) -> end = size */
	movel	%d0,%a5@(42)		/* lib+0x2a = file size */
	moveq	#2,%d1			/* MEMF_CHIP */
	moveal	4:w,%a6
	jsr	%a6@(-198)		/* AllocMem */
	moveal	%d4,%a6		/* back to dosbase */
	movel	%d0,%a5@(38)		/* lib+0x26 = buffer */
	bnes	3f
	movel	%d5,%d1
	jsr	%a6@(-36)		/* Close */
	moveq	#-2,%d0
	bras	2b
3:	movel	%a5@(42),%d3		/* size */
	movel	%d5,%d1
	movel	%d0,%d2			/* buffer */
	jsr	%a6@(-42)		/* Read */
	movel	%d5,%d1
	jsr	%a6@(-36)		/* Close */
	moveq	#0,%d0
	bras	2b

/* ==== 0x1fc -36 Unload: stop + free ============================== */
_unload:
	bsrs	_stop
	braw	_freebuf

/* ==== 0x202 -48 Play ============================================= */
_play:
	tstl	%a6@(38)		/* have module? */
	beqs	1f
	tstw	%a6@(46)		/* already playing? */
	bnes	1f
	movew	#0x525a,%a6@(46)
	.short	0x4ef9
	.long	_play2
1:	rts

/* ==== 0x21c -54 Stop ============================================= */
_stop:
	tstl	%a6@(38)
	beqs	1b			/* shared rts inside _play */
	tstw	%a6@(46)
	beqs	1b
	clrw	%a6@(46)
	.short	0x4ef9
	.long	_stop2
					/* tail-jmp: no rts here */

/* ==== 0x232 dos.library name ===================================== */
_dosname:
	.ascii	"dos.library\0"
_EndSkip:				/* 0x23e */
	nop

/* ==== 0x240 Play part 2: install int server ======================= */
_play2:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	bsrw	_setup
	moveal	4:w,%a6
	lea	%pc@(_intstruct),%a1
	moveq	#5,%d0			/* INTB_VERTB */
	jsr	%a6@(-168)		/* AddIntServer */
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts

/* ==== 0x25c Stop part 2: remove int server ======================== */
_stop2:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	lea	%pc@(_intstruct),%a1
	moveq	#5,%d0
	moveal	4:w,%a6
	jsr	%a6@(-174)		/* RemIntServer */
	bsrw	_mute
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts

/* ==== 0x278 Interrupt struct ===================================== */
_intstruct:
	.long	0,0			/* ln_Succ/ln_Pred */
	.byte	2,0			/* ln_Type NT_INTERRUPT, ln_Pri */
	.long	_intname		/* ln_Name -> 0x28e */
	.long	0			/* is_Data */
	.long	_handler		/* is_Code -> 0x36a */
_intname:
	.ascii	"STReplay_Lib Interrupt\0"
	.byte	0

/* ==== 0x2a6 setup: build sample table, clear state ================ */
_setup:
	moveq	#6,%d0
	bsrw	_setspeed		/* reset tick + speed byte */
	moveal	%a6@(38),%a0		/* module buf */
	movel	%a0,_modbase:l		/* -> hunk+0x900 */
	addal	#952,%a0		/* pattern pos table */
	moveq	#127,%d0
	moveq	#0,%d1
_maxl:	movel	%d1,%d2			/* running max instr # */
	subqw	#1,%d0
_rdbyt:	moveb	%a0@+,%d1
	cmpb	%d2,%d1
	bgts	_maxl
	dbf	%d0,_rdbyt
	addqb	#1,%d2			/* patterns = max+1 */
	movel	%pc@(_modbase),%a0
	lea	%pc@(_samtab+4),%a1	/* -> 0x830 */
	asll	#8,%d2			/* npats*1024 = patt data size */
	asll	#2,%d2
	addil	#1080,%d2		/* + header -> sample data base */
	addl	%a0,%d2
	moveq	#30,%d0
3:	movel	%d2,%a1@+		/* samtab[i] = sample i start */
	moveq	#0,%d1
	movew	%a0@(42),%d1		/* sample len (2-byte words) */
	asll	#1,%d1			/* -> bytes */
	addl	%d1,%d2
	addal	#30,%a0
	dbf	%d0,3b
	lea	%pc@(_samtab+4),%a0
	moveq	#0,%d0
4:	moveal	%a0@(0,%d0:w),%a1	/* clear each sample's first long? */
	clrl	%a1@
	addqw	#4,%d0
	cmpiw	#124,%d0
	bnes	4b
	clrw	0xdff0a8:l		/* AUDxVOL = 0 */
	clrw	0xdff0b8:l
	clrw	0xdff0c8:l
	clrw	0xdff0d8:l
	clrl	_patidx:l		/* 0x822 */
	clrl	_patoff:l		/* 0x81e */
	clrl	_patptr:l		/* 0x828 */
	movel	%pc@(_modbase),%a0
	moveb	%a0@(950),_songlen+1:l	/* buf+0x3b6 -> 0x8ad */
	rts

/* ==== 0x348 mute: DMA off + vols ================================== */
_mute:
	clrw	0xdff0a8:l
	clrw	0xdff0b8:l
	clrw	0xdff0c8:l
	clrw	0xdff0d8:l
	movew	#15,0xdff096:l		/* DMACON: all 4 audio on */
	rts

/* ==== 0x36a interrupt handler ===================================== */
_handler:
	moveml	%d2-%d7/%a2-%a6,%sp@-
	bsrs	_tickmain
	moveml	%sp@+,%d2-%d7/%a2-%a6
	rts

/* ==== 0x376 tick dispatch ========================================= */
_tickmain:
	addqw	#1,_tick:l		/* 0x826 */
	.short	0x0c79			/* cmpiw #speed,_tick -- the speed */
	.byte	0			/* value lives in the immediate: */
_speed:	.byte	6			/* effect F writes this byte */
	.long	_tick
	bnew	_midtick
	clrw	_tick:l
	braw	_newrow

/* ==== 0x392 ticks 1..5: per-channel effects ======================= */
_midtick:
	lea	%pc@(_ch0),%a6		/* 0x7b6 */
	tstb	%a6@(3)
	beqw	1f
	lea	0xdff0a0:l,%a5
	bsrw	_effect
1:	lea	%pc@(_ch1),%a6		/* 0x7d0 */
	tstb	%a6@(3)
	beqw	2f
	lea	0xdff0b0:l,%a5
	bsrw	_effect
2:	lea	%pc@(_ch2),%a6		/* 0x7ea */
	tstb	%a6@(3)
	beqw	3f
	lea	0xdff0c0:l,%a5
	bsrw	_effect
3:	lea	%pc@(_ch3),%a6		/* 0x804 */
	tstb	%a6@(3)
	beqw	4f
	lea	0xdff0d0:l,%a5
	braw	_effect
4:	rts

/* ==== 0x3ec effect dispatch (mid-tick): a6=ch, a5=audregs ========== */
_effect:
	moveb	%a6@(2),%d0		/* effect byte */
	andib	#15,%d0
	tstb	%d0
	beqw	_arp			/* 0: arpeggio */
	cmpib	#1,%d0
	beqw	_pup			/* 1: portamento up */
	cmpib	#2,%d0
	beqw	_pdn			/* 2: portamento down */
	cmpib	#10,%d0
	beqw	_vsl			/* a: volume slide */
	rts

/* 0x414 fx1: portamento up */
_pup:
	moveq	#0,%d0
	moveb	%a6@(3),%d0		/* param */
	subw	%d0,%a6@(22)		/* period -= n */
	cmpiw	#113,%a6@(22)
	bplw	1f
	movew	#113,%a6@(22)
1:	movew	%a6@(22),%a5@(6)	/* AUDxPER */
	rts

/* 0x436 fx2: portamento down */
_pdn:
	moveq	#0,%d0
	moveb	%a6@(3),%d0
	addw	%d0,%a6@(22)
	cmpiw	#1336,%a6@(22)
	bmiw	1f
	movew	#1336,%a6@(22)
1:	movew	%a6@(22),%a5@(6)
	rts

/* 0x458 fxa: volume slide */
_vsl:
	moveq	#0,%d0
	moveb	%a6@(3),%d0
	lsrb	#4,%d0			/* hi nibble = up */
	tstb	%d0
	beqw	1f
	addw	%d0,%a6@(18)		/* vol += hi */
	cmpiw	#64,%a6@(18)
	bmiw	2f
	movew	#64,%a6@(18)
2:	movew	%a6@(18),%a5@(8)	/* AUDxVOL */
	rts
1:	moveq	#0,%d0
	moveb	%a6@(3),%d0
	andib	#15,%d0			/* lo nibble = down */
	subw	%d0,%a6@(18)
	bplw	3f
	clrw	%a6@(18)
3:	movew	%a6@(18),%a5@(8)
	rts

/* ==== 0x4a0 fx0: arpeggio ========================================== */
_arp:
	movew	%pc@(_tick),%d0
	cmpiw	#1,%d0
	beqw	_arphi			/* tick1: hi nibble */
	cmpiw	#2,%d0
	beqw	_arplo			/* tick2: lo nibble */
	cmpiw	#3,%d0
	beqw	_arpbase		/* tick3: base */
	cmpiw	#4,%d0
	beqw	_arphi			/* tick4: hi */
	cmpiw	#5,%d0
	beqw	_arplo			/* tick5: lo */
	rts
_arphi:
	moveq	#0,%d0
	moveb	%a6@(3),%d0
	lsrb	#4,%d0
	braw	_arpset
_arplo:
	moveq	#0,%d0
	moveb	%a6@(3),%d0
	andib	#15,%d0
	braw	_arpset
_arpbase:
	movew	%a6@(16),%d2		/* base note */
	braw	_arpset2
_arpset:
	addw	%d0,%d0			/* halftone*2 -> index */
	moveq	#0,%d1
	movew	%a6@(16),%d1		/* base period */
	andiw	#4095,%d1
	lea	%pc@(_pertab),%a0	/* 0x8b2 */
1:	movew	%a0@(0,%d0:w),%d2	/* candidate period */
	cmpw	%a0@,%d1		/* reached base period? */
	beqw	_arpset2
	addql	#2,%a0
	bras	1b
_arpset2:
	movew	%d2,%a5@(6)		/* AUDxPER */
	rts

/* ==== 0x514 new row: decode pattern row into channels ============== */
_newrow:
	movel	%pc@(_modbase),%a0	/* module base */
	moveal	%a0,%a3
	addal	#12,%a3			/* a3 = hdrs+12 (sample params) */
	moveal	%a0,%a2
	addal	#952,%a2		/* a2 = pattern pos table */
	addal	#1084,%a0		/* a0 = pattern data */
	movel	%pc@(_patidx),%d0	/* current pattern index */
	moveq	#0,%d1
	moveb	%a2@(0,%d0:w),%d1	/* pattern number */
	asll	#8,%d1			/* *1024 + base */
	asll	#2,%d1
	addl	%pc@(_patoff),%d1	/* + row offset (16B/row) */
	movel	%d1,_patptr:l
	clrw	_dmamask:l		/* 0x8ae */
	lea	0xdff0a0:l,%a5
	lea	%pc@(_ch0),%a6
	bsrw	_note
	lea	0xdff0b0:l,%a5
	lea	%pc@(_ch1),%a6
	bsrw	_note
	lea	0xdff0c0:l,%a5
	lea	%pc@(_ch2),%a6
	bsrw	_note
	lea	0xdff0d0:l,%a5
	lea	%pc@(_ch3),%a6
	bsrw	_note
	movew	#500,%d0		/* settle delay */
1:	dbf	%d0,1b
	movew	#-32768,%d0		/* 0x8000 */
	orw	_dmamask:l,%d0
	movew	%d0,0xdff096:l		/* DMACON set bits */
	lea	%pc@(_ch3),%a6		/* now (re)start each channel */
	cmpiw	#1,%a6@(14)
	bnew	2f
	movel	%a6@(10),0xdff0d0:l	/* AUDxLC */
	movew	#1,0xdff0d4:l		/* AUDxLEN */
2:	lea	%pc@(_ch2),%a6
	cmpiw	#1,%a6@(14)
	bnew	3f
	movel	%a6@(10),0xdff0c0:l
	movew	#1,0xdff0c4:l
3:	lea	%pc@(_ch1),%a6
	cmpiw	#1,%a6@(14)
	bnew	4f
	movel	%a6@(10),0xdff0b0:l
	movew	#1,0xdff0b4:l
4:	lea	%pc@(_ch0),%a6
	cmpiw	#1,%a6@(14)
	bnew	5f
	movel	%a6@(10),0xdff0a0:l
	movew	#1,0xdff0a4:l
5:	movel	%pc@(_patoff),%d0	/* next row */
	addil	#16,%d0
	movel	%d0,_patoff:l
	cmpil	#1024,%d0		/* 64 rows * 16 */
	bnew	6f
_wraprow:
	clrl	_patoff:l
	addql	#1,_patidx:l
	moveq	#0,%d0
	movew	%pc@(_songlen),%d0	/* 0x8ac word (len in lo byte) */
	movel	%pc@(_patidx),%d1
	cmpl	%d0,%d1
	bnew	6f
	clrl	_patidx:l		/* wrap song */
6:	tstw	_patbreak:l		/* 0x8b0 pending break? */
	beqw	7f
	clrw	_patbreak:l
	bras	_wraprow		/* -> clrl _patoff / next pattern */
7:	rts

/* ==== 0x664 note decode: a0=patbase,d1=rowoff; a6=ch,a5=audregs ===== */
_note:
	movel	%a0@(0,%d1:l),%a6@	/* 4-byte packed note -> ch+0 */
	addql	#4,%d1
	moveq	#0,%d2
	moveb	%a6@(2),%d2		/* instr = fxbyte hi nib + note hi nib */
	andib	#-16,%d2
	lsrb	#4,%d2
	moveb	%a6@,%d0
	andib	#-16,%d0
	orb	%d0,%d2			/* d2 = instrument 0..31 */
	tstb	%d2
	beqw	_nochange		/* 0: keep sample */
	moveq	#0,%d3
	lea	%pc@(_samtab),%a1	/* 0x82c: instr*4 indexed */
	movel	%d2,%d4
	asll	#2,%d2			/* *4 for table */
	muluw	#30,%d4			/* *30 for hdr */
	movel	%a1@(0,%d2:w),%a6@(4)	/* sample ptr -> ch+4 */
	movew	%a3@(0,%d4:l),%a6@(8)	/* len -> ch+8 (AUDxLEN) */
	movew	%a3@(2,%d4:l),%a6@(18)	/* default vol -> ch+18 */
	movew	%a3@(4,%d4:l),%d3	/* repoff -> d3 */
	tstw	%d3
	beqw	_norep
	movel	%a6@(4),%d2		/* looped: audlen = roff+rlen */
	addl	%d3,%d2
	movel	%d2,%a6@(4)
	movel	%d2,%a6@(10)		/* ch+10 = loop addr */
	movew	%a3@(6,%d4:l),%a6@(8)	/* rlen -> audlen? */
	movew	%a3@(6,%d4:l),%a6@(14)	/* ch+14 = loop len */
	movew	%a6@(18),%a5@(8)	/* AUDxVOL = vol */
	braw	_nochange
_norep:
	movel	%a6@(4),%d2
	addl	%d3,%d2
	movel	%d2,%a6@(10)		/* loop addr = end */
	movew	%a3@(6,%d4:l),%a6@(14)	/* loop len */
	movew	%a6@(18),%a5@(8)	/* AUDxVOL */
_nochange:
	movew	%a6@,%d0		/* packed note word */
	andiw	#4095,%d0		/* period? */
	tstw	%d0
	beqw	_nostart		/* 0: no new note */
	movew	%a6@,%a6@(16)		/* ch+16 = note */
	movew	%a6@(20),0xdff096:l	/* ch+20 = DMA off bit */
	movel	%a6@(4),%a5@		/* AUDxLCH/L */
	movew	%a6@(8),%a5@(4)		/* AUDxLEN */
	movew	%a6@,%d0
	andiw	#4095,%d0
	movew	%d0,%a5@(6)		/* AUDxPER */
	movew	%a6@(20),%d0
	orw	%d0,_dmamask:l		/* accumulate restart mask */
_nostart:
	tstw	%a6@
	beqw	_rowfx
	movew	%a6@,%a6@(22)		/* ch+22 = cur period */
_rowfx:
	moveb	%a6@(2),%d0		/* row-time effects: b..f */
	andib	#15,%d0
	cmpib	#11,%d0
	beqw	_fxb			/* position jump */
	cmpib	#12,%d0
	beqw	_fxc			/* set volume */
	cmpib	#13,%d0
	beqw	_fxd			/* pattern break */
	cmpib	#14,%d0
	beqw	_fxe			/* filter toggle */
	cmpib	#15,%d0
	beqw	_fxf			/* set speed */
	rts
_fxb:	notw	_patbreak:l		/* set pending break */
	moveq	#0,%d0
	moveb	%a6@(3),%d0
	subqb	#1,%d0
	movel	%d0,_patidx:l		/* next pattern = param-1 */
	rts
_fxc:	moveb	%a6@(3),%a5@(8)		/* AUDxVOL = param */
	rts
_fxd:	notw	_patbreak:l
	rts
_fxe:	moveq	#0,%d0
	moveb	%a6@(3),%d0
	andib	#1,%d0
	rolb	#1,%d0
	andib	#-3,0xbfe001:l		/* CIA-A LED bit (audio filter) */
	orb	%d0,0xbfe001:l
	rts
_fxf:	moveb	%a6@(3),%d0
	andib	#15,%d0
	beqw	1f			/* param 0 -> ignore */
_setspeed:				/* 0x7a8: also called by _setup */
	clrw	_tick:l
	moveb	%d0,_speed:l		/* -> cmpiw immediate byte */
1:	rts

/* ==== 0x7b6 channel state: 4 * 26 bytes =========================== */
/* +0 packed note  +2 fx byte  +3 param  +4 samptr  +8 audlen
   +10 loopaddr    +14 looplen +16 note  +18 vol    +20 dmaoff +22 period */
_ch0:	.long	0,0,0,0,0
	.short	0x0001			/* DMACON bit */
	.long	0
_ch1:	.long	0,0,0,0,0
	.short	0x0002
	.long	0
_ch2:	.long	0,0,0,0,0
	.short	0x0004
	.long	0
_ch3:	.long	0,0,0,0,0
	.short	0x0008
	.long	0

/* ==== 0x81e globals ============================================== */
_patoff:	.long	0		/* 0x81e */
_patidx:	.long	0		/* 0x822 */
_tick:		.word	0		/* 0x826 */
_patptr:	.long	0		/* 0x828 */
_samtab:	.long	0		/* 0x82c (slot 0 unused) */
		.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
					/* 0x830..0x8ab: 31 sample ptrs */
_songlen:	.word	0		/* 0x8ac (lo byte = buf+0x3b6) */
_dmamask:	.word	0		/* 0x8ae */
_patbreak:	.word	0		/* 0x8b0 */
_pertab:				/* 0x8b2: 36 periods */
	.short	0x358,0x328,0x2fa,0x2d0,0x2a6,0x280
	.short	0x25c,0x23a,0x21a,0x1fc,0x1e0,0x1c5
	.short	0x1ac,0x194,0x17d,0x168,0x153,0x140
	.short	0x12e,0x11d,0x10d,0x0fe,0x0f0,0x0e2
	.short	0x0d6,0x0ca,0x0be,0x0b4,0x0aa,0x0a0
	.short	0x097,0x08f,0x087,0x07f,0x078,0x071
	.word	0,0,0			/* 0x8fa pad */
_modbase:	.long	0		/* 0x900: module ptr (self-mod) */

