/* tdisk.library 4.1 (26 February 1988) reconstruction
 *
 * "tdisk library V4.1 (26 February 1988) / Copyright 1987,1988 by
 * Fuller Computer Systems, Inc." — direct-hardware floppy library:
 * claims a drive through disk.resource, steps/selects via CIAA-B
 * ($bfd100) and transfers whole MFM tracks through the disk DMA
 * (DSKPT/DSKLEN/DSKBYT at $dff0xx), decoding/encoding sectors in
 * memory (0x4489 syncs, 0xaaaa gap fill).
 *
 * Single CODE hunk, RELOC32; RomTag RTF_AUTOINIT v4 rev1 pri0;
 * InitTable dataSize 0xb8, 11 vectors; InitStruct uses the
 * 24-bit-offset forms (e0=byte, d0=word, c0=long).
 *
 * Vectors:
 *   -6  Open       -24 null       -42 select/motor   -54 MFM read
 *   -12 Close      -30 GetUnit    -48 seek/step      -60 MFM write
 *   -18 Expunge    -36 GiveUnit                    -66 verify
 *
 * Library data (posSize 0xb8):
 *   +0x20 opencnt.w +0x22 seglist +0x26 ExecBase +0x2a diskres
 *   +0x2e..0x3d units[4] +0x3e saved CIAB prb (init 0xff)
 *   +0x3f flags (bit4 = drive claimed) +0x40 port A +0x4e port A ptr
 *   +0x48/+0x4a name cell +0x52 copyright str ptr (constant 0x56!)
 *   +0x62 saved CIAB prb  +0x96 port B +0x9e/+0xa0 name cell
 *   +0xa5 sigbit +0xa6 ThisTask
 *
 * Unit struct (32 bytes, InitStruct'd from one of two templates
 * chosen by disk.resource GetUnitID()):
 *   +0 unit# +2 flags +3 maxtrk +4 curtrk +5/+6/+7 precomp thresh
 *   +0xc track words (0x1982/0x1981) +0xe DSKSYNC 0x4489
 *   +0x10..+0x1c delays  +0x8 -> 16KB chip track buffer
 */
	.text

/*------------------------- entry stub ---------------------------*/
	.globl	_start
_start:	moveq	#0,%d0
	rts

/*------------------------- RomTag -------------------------------*/
_romtag:
	.short	0x4afc
	.long	_romtag
	.long	_endskip
	.byte	0x80,4,9,0		/* AUTOINIT v4 NT_LIBRARY pri0 */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:	.ascii	"tdisk.library\0"
_idstr:		.ascii	"tdisk library V4.1 (26 February 1988)\015\012"
_credit:	.ascii	"Copyright 1987,1988 by Fuller Computer Systems, Inc.\015\0"
_diskres:	.ascii	"disk.resource\0"
		.byte	0

/*------------------------- InitTable ----------------------------*/
	.align	2
_inittab:
	.long	0xb8
	.long	_functab
	.long	_datatab
	.long	_init

_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_null
	.long	_getunit
	.long	_giveunit
	.long	_select
	.long	_seek
	.long	_mfmread
	.long	_mfmwrite
	.long	_verify
	.long	-1

/*------------------------- InitStruct streams -------------------*/
_datatab:
	.byte	0xe0,0x00
	.short	0x0008
	.byte	0x09,0x00			/* ln_Type = NT_LIBRARY */
	.byte	0xc0,0x00
	.short	0x000a
	.long	_libname		/* ln_Name */
	.byte	0xe0,0x00
	.short	0x000e
	.byte	0x06,0x00			/* lib_Flags = 6 */
	.byte	0xd0,0x00
	.short	0x0014
	.short	4			/* lib_Version */
	.byte	0xd0,0x00
	.short	0x0016
	.short	1			/* lib_Revision */
	.byte	0xc0,0x00
	.short	0x0018
	.long	_idstr			/* lib_IdString */
	.byte	0xe0,0x00
	.short	0x003e
	.byte	0xff,0x00			/* CIAB cell -> 0xff */
	.byte	0xe0,0x00
	.short	0x0048
	.byte	0x05,0x00
	.byte	0xc0,0x00
	.short	0x004a
	.long	_libname
	.byte	0xc0,0x00
	.short	0x0052
	.long	0x56			/* NOT relocated: raw constant */
	.byte	0xe0,0x00
	.short	0x009e
	.byte	0x04,0x00
	.byte	0xc0,0x00
	.short	0x00a0
	.long	_libname
	.byte	0xe0,0x00
	.short	0x00a5
	.byte	0x04,0x00
	.long	0

/* unit InitStruct template A (GetUnitID == 0) */
_tmpl0:
	.byte	0xe0,0x00
	.short	0x0002
	.byte	0x80,0x00
	.byte	0xe0,0x00
	.short	0x0003
	.byte	0x52,0x00
	.byte	0xe0,0x00
	.short	0x0005
	.byte	0x28,0x00
	.byte	0xe0,0x00
	.short	0x0006
	.byte	0xff,0x00
	.byte	0xe0,0x00
	.short	0x0007
	.byte	0xff,0x00
	.byte	0xd0,0x00
	.short	0x000c
	.short	0x1982
	.byte	0xd0,0x00
	.short	0x000e
	.short	0x4489
	.byte	0xc0,0x00
	.short	0x0010
	.long	0x100
	.byte	0xc0,0x00
	.short	0x0014
	.long	0x400
	.byte	0xc0,0x00
	.short	0x0018
	.long	0x2000
	.byte	0xc0,0x00
	.short	0x001c
	.long	0x20000
	.long	0

/* unit InitStruct template B (GetUnitID != 0) */
_tmpl1:
	.byte	0xe0,0x00
	.short	0x0002
	.byte	0x80,0x00
	.byte	0xe0,0x00
	.short	0x0003
	.byte	0x2a,0x00
	.byte	0xe0,0x00
	.short	0x0005
	.byte	0x14,0x00
	.byte	0xe0,0x00
	.short	0x0006
	.byte	0xff,0x00
	.byte	0xe0,0x00
	.short	0x0007
	.byte	0xff,0x00
	.byte	0xd0,0x00
	.short	0x000c
	.short	0x1981
	.byte	0xd0,0x00
	.short	0x000e
	.short	0x4489
	.byte	0xc0,0x00
	.short	0x0010
	.long	0x100
	.byte	0xc0,0x00
	.short	0x0014
	.long	0x800
	.byte	0xc0,0x00
	.short	0x0018
	.long	0x4000
	.byte	0xc0,0x00
	.short	0x001c
	.long	0x20000
	.long	0

/*------------------------- init ---------------------------------*/
/* d0=libbase a0=seglist a6=execbase */
_init:
	moveml	%d2-%d4/%a2-%a6,%sp@-
	moveal	%d0,%a5
	movel	%a0,%a5@(34)		/* seglist */
	movel	%a6,%a5@(38)		/* execbase */
	lea	%pc@(_diskres),%a1
	jsr	%a6@(-498)		/* OpenResource(disk.resource) */
	movel	%d0,%a5@(42)
	beq.w	_initfail
	lea	%a5@(150),%a4		/* +0x96 port template */
	lea	%a4@(20),%a0		/* a0 = &port+14 */
	movel	%a0,%a0@
	addql	#4,%a0@
	clrl	%a0@(4)
	movel	%a0,%a0@(8)
	movel	%a4,%a5@(78)		/* +0x4e = &portB */
	moveq	#3,%d2
_initloop:
	movel	%d2,%d0
	moveal	%a5@(42),%a6		/* diskres */
	jsr	%a6@(-30)		/* GetUnitID(unit) */
	cmpil	#-1,%d0
	beqs	_initnext
	movel	%d0,%d4
	moveal	%a5@(38),%a6		/* exec */
	.short	0x203c
	.long	32
	movel	#65537,%d1		/* PUBLIC|CLEAR */
	jsr	%a6@(-198)		/* AllocMem */
	tstl	%d0
	beqs	_initnext
	moveal	%d0,%a3
	movel	#16384,%d0
	movel	#65538,%d1		/* CHIP|CLEAR */
	jsr	%a6@(-198)
	movel	%d0,%a3@(8)		/* track buffer */
	bnes	_initunit
	moveal	%a3,%a1
	.short	0x203c
	.long	32
	jsr	%a6@(-210)		/* FreeMem */
	bras	_initnext
_initunit:
	.short	0x1742,0x0000		/* moveb d2,a3@(0) unit# */
	tstl	%d4
	bnes	1f
	lea	%pc@(_tmpl0),%a1
	bras	2f
1:	lea	%pc@(_tmpl1),%a1
2:	moveq	#0,%d0
	moveal	%a3,%a2
	jsr	%a6@(-78)		/* InitStruct(tmpl,unit,0) */
	movel	%d2,%d0
	lsll	#2,%d0
	movel	%a3,%a5@(0x2e,%d0:l)
_initnext:
	dbf	%d2,_initloop
	movel	%a5,%d0
	moveml	%sp@+,%d2-%d4/%a2-%a6
	rts
_initfail:
	moveml	%d7/%a5-%a6,%sp@-
	movel	#0x80058021,%d7	/* alert AN_DiskError-ish */
	moveal	4:w,%a6
	jsr	%a6@(-108)		/* Alert */
	moveml	%sp@+,%d7/%a5-%a6
	/* falls through into Open — no rts (original quirk) */

/*------------------------- open ---------------------------------*/
_open:
	addqw	#1,%a6@(32)
	bclr	#3,%a6@(14)
	movel	%a6,%d0
	rts

/*------------------------- close --------------------------------*/
_close:
	moveq	#0,%d0
	subqw	#1,%a6@(32)
	bnes	1f
	btst	#3,%a6@(14)
	beqs	1f
	bsr.w	_expunge
1:	rts

/*------------------------- expunge ------------------------------*/
_expunge:
	moveml	%d2/%a3/%a5-%a6,%sp@-
	moveal	%a6,%a5
	moveal	%a5@(38),%a6		/* execbase */
	moveq	#3,%d2
	tstw	%a5@(32)
	beqs	1f
	bset	#3,%a5@(14)		/* set deferred-expunge flag */
	moveq	#0,%d0
	bras	3f
1:	lsll	#2,%d2
	tstl	%a5@(0x2e,%d2:l)
	beqs	2f
	moveal	%a5@(0x2e,%d2:l),%a3
	clrl	%a5@(0x2e,%d2:l)
	moveal	%a3@(8),%a1
	movel	#16384,%d0
	jsr	%a6@(-210)		/* free track buf */
	moveal	%a3,%a1
	.short	0x203c
	.long	32
	jsr	%a6@(-210)		/* free unit struct */
2:	lsrl	#2,%d2
	dbf	%d2,1b
	movel	%a5@(34),%d2		/* seglist */
	moveal	%a5,%a1
	jsr	%a6@(-252)		/* Remove */
	moveq	#0,%d0
	moveq	#0,%d1
	moveal	%a5,%a1
	movew	%a5@(16),%d1		/* negsize */
	subal	%d1,%a1
	movew	%a5@(18),%d0		/* possize */
	addl	%d1,%d0
	jsr	%a6@(-210)		/* FreeMem(lib) */
	movel	%d2,%d0
3:	moveml	%sp@+,%d2/%a3/%a5-%a6
	rts

/*------------------------- reserved -----------------------------*/
_null:	moveq	#0,%d0
	rts

/*------------------------- GetUnit (LVO -30) ---------------------*/
_getunit:
	moveml	%a4-%a6,%sp@-
	moveal	%a6,%a4
	moveal	%a4@(42),%a5		/* diskres */
	moveal	%a4@(38),%a6		/* exec */
	moveal	#0,%a1
	jsr	%a6@(-294)		/* FindTask(0) */
	movel	%d0,%a4@(166)		/* +0xa6 */
_gu_get:
	lea	%a4@(64),%a1		/* +0x40 port A */
	exg	%a5,%a6
	jsr	%a6@(-18)		/* diskres GetUnit(port) */
	tstl	%d0
	bnes	_gu_ok
	exg	%a5,%a6
_gu_wait:
	moveq	#0,%d0
	moveb	%a4@(165),%d0		/* +0xa5 sigbit */
	jsr	%a6@(-318)		/* Wait */
	moveal	%a4@(150),%a1		/* +0x96 port B */
	jsr	%a6@(-372)		/* GetMsg */
	tstl	%d0
	beqs	_gu_wait		/* no msg -> wait again */
	bras	_gu_get			/* got msg -> retry GetUnit */
_gu_ok:
	bset	#4,%a4@(63)		/* +0x3f: drive claimed */
	moveb	%a4@(62),%d1		/* +0x3e saved CIAB */
	orib	#127,%d1
	moveb	%d1,0xbfd100		/* all select/ctl lines high */
	lea	%a4@(64),%a0
	cmpal	%d0,%a0
	beqs	1f			/* GetUnit returned our port */
	movew	#1536,0xdff09e		/* ADKCON clr 0x0600 */
	movew	#-28416,0xdff09e	/* ADKCON set 0x9100 */
1:	moveml	%sp@+,%a4-%a6
	rts

/*------------------------- GiveUnit (LVO -36) --------------------*/
_giveunit:
	movel	%a6,%sp@-
	moveb	0xbfd100,%a6@(62)	/* save CIAB prb */
	bclr	#4,%a6@(63)
	moveal	%a6@(42),%a6		/* diskres */
	jsr	%a6@(-24)		/* GiveUnit */
	moveal	%sp@+,%a6
	rts

/*------------------------- select/motor (LVO -42) ----------------*/
/* a0=unit; d0: 0=select pulse, 1=motor kick; returns old flags */
_select:
	cmpil	#2,%d0
	bccs	_sel_err
	moveml	%d2/%a1,%sp@-
	movel	%d0,%d2
	moveq	#0,%d1
	moveb	%a0@(2),%d1		/* old flags */
	cmpil	#2,%d2
	beqs	_sel_out		/* dead check (d2<2 always) */
	moveb	#-128,%a0@(2)
	lea	0xbfd100,%a1		/* CIAB prb */
	moveb	#-1,%a1@
	moveq	#0,%d0
	.short	0x1028,0x0000		/* moveb a0@(0),d0 unit# */
	addqb	#3,%d0
	tstl	%d2
	beqs	_sel_pulse
	clrb	%a0@(2)			/* flags = 0 (motor kicked) */
	bclr	#7,%a1@			/* motor on */
	nop
	nop
	bclr	%d0,%a1@		/* select drive */
	movel	%d0,%sp@-
	movel	%a0@(28),%d0		/* settle delay */
	bsr.w	_delay
	movel	%sp@+,%d0
	bset	%d0,%a1@
	bset	#7,%a1@			/* motor off */
	bras	_sel_out
_sel_pulse:
	bclr	%d0,%a1@
	nop
	nop
	bset	%d0,%a1@
_sel_out:
	movel	%d1,%d0
	moveml	%sp@+,%d2/%a1
	rts
_sel_err:
	moveq	#-1,%d0
	rts

/*------------------------- seek (LVO -48) ------------------------*/
/* a0=unit; d0=track*2+side encoded (lsrb#1 -> cyl) */
_seek:
	moveml	%d2-%d4/%a2-%a3,%sp@-
	lsrb	#1,%d0
	moveb	%d0,%d4
	cmpb	%a0@(3),%d0		/* vs max track */
	bccs	_seek_err
	lea	0xbfd100,%a2
	moveb	#127,%d2
	orb	%a0@(2),%d2		/* flags | 0x7f */
	moveb	%d2,%a2@
	.short	0x1428,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@		/* select */
	tstb	%d0
	beqs	_seek_home		/* track 0 -> home seek */
	cmpb	%a0@(4),%d0		/* vs current track */
	beqs	_seek_done
	bccs	_seek_fwd
	moveb	%a0@(4),%d1		/* backward: d1=cur d2=new */
	moveb	%d0,%d2
	bras	_seek_go
_seek_fwd:
	moveb	%d0,%d1			/* forward: d1=new d2=cur */
	moveb	%a0@(4),%d2
	bclr	#1,%a2@			/* DIR = out */
_seek_go:
	subb	%d2,%d1			/* step count */
	moveb	%a2@,%d2
	moveb	%d2,%d3
	bclr	#0,%d2			/* STEP lo word */
_seek_step:
	moveb	%d2,%a2@		/* STEP low */
	nop
	nop
	moveb	%d3,%a2@		/* STEP high */
	movel	%a0@(20),%d0
	bsr.w	_delay
	subqb	#1,%d1
	bnes	_seek_step
_seek_done:
	movel	%a0@(24),%d0
	bsr.w	_delay
	orib	#127,%a2@		/* deselect, STEP/DIR/SIDE high */
	moveb	%d4,%a0@(4)		/* store current track */
	moveb	%d4,%d0
_seek_pop:
	moveml	%sp@+,%d2-%d4/%a2-%a3
	rts
_seek_err:
	moveq	#-1,%d0
	bras	_seek_pop
_seek_home:
	lea	0xbfe001,%a3		/* CIAA pra: /TRACK0 = bit4 */
	moveb	%a2@,%d2
	moveb	%d2,%d3
	bclr	#0,%d2
	bras	_seek_hchk
_seek_hpulse:
	moveb	%d2,%a2@
	nop
	nop
	moveb	%d3,%a2@
	movel	%a0@(20),%d0
	bsr.w	_delay
_seek_hchk:
	btst	#4,%a3@			/* until /TRACK0 active */
	bnes	_seek_hpulse
	bras	_seek_done

/*------------------------- MFM read (LVO -54) --------------------*/
/* a0=unit a1=dest; d0=track*2+side d1=len d2=sync? d3=flags */
_mfmread:
	moveml	%d3-%d7/%a2-%a6,%sp@-
	cmpiw	#8192,%d1
	bcss	1f
	moveq	#-1,%d0
	bra.w	_rd_out
1:	moveal	%a0,%a5
	moveal	%a1,%a4
	lea	0xdff000,%a3
	lea	0xbfd100,%a2
	lea	0xbfe001,%a1
	movel	%d3,%d6
	movel	%d2,%d5
	movel	%d1,%d4
	movel	%d0,%d3
	moveb	#127,%a2@
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@		/* select */
	btst	#2,%a1@			/* /RDY */
	bnes	2f
	.short	0x142d,0x0000
	addqb	#3,%d2
	bset	%d2,%a2@
	moveq	#-2,%d0
	bra.w	_rd_out
2:	btst	#7,%a5@(2)		/* motor-kick flag */
	beqs	3f
	moveq	#1,%d0
	moveal	%a5,%a0
	bsr.w	_select
3:	movel	%d3,%d0
	moveal	%a5,%a0
	bsr.w	_seek
	cmpil	#-1,%d0
	bnes	4f
	moveq	#-3,%d0
	bra.w	_rd_out
4:	moveb	#127,%a2@
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@
	movew	#32512,%a3@(158)	/* ADKCON = 0x7f00 clr */
	movew	#-28416,%a3@(158)	/* ADKCON set 0x9100 */
	btst	#4,%d6
	bnes	5f			/* bit4 -> keep old sync */
	movew	#-31744,%a3@(158)	/* ADKCON set 0x8400 */
	btst	#2,%d6
	bnes	6f			/* bit2 -> sync arg in d5 */
	movew	%a5@(14),%d5		/* else unit DSKSYNC */
6:	movew	%d5,%a3@(126)		/* DSKSYNC */
5:	lsrl	#1,%d3			/* cyl>>1, side in carry */
	bccs	7f
	bclr	#2,%a2@			/* SIDE = lower head */
	movel	%d0,%sp@-
	movel	%a5@(16),%d0
	bsr.w	_delay
	movel	%sp@+,%d0
7:	movel	%a5@(8),%a3@(32)	/* DSKPT = track buf */
	movew	#-32240,%a3@(150)	/* DMACON = 0x8210 */
	movew	#4098,%a3@(154)		/* INTENA = 0x1002 */
	movew	#2,%a3@(156)		/* INTREQ = 2 */
	movew	#16384,%a3@(36)		/* DSKLEN = 0x4000 idle */
	andiw	#16383,%d4
	oriw	#-32768,%d4		/* |0x8000 DMA ena */
	movew	%d4,%a3@(36)		/* DSKLEN strobe */
	btst	#1,%d6
	beqs	8f
	lea	0xbfdd00,%a0		/* CIAB icr */
	movew	#16384,%a3@(154)	/* INTENA = 0x4000 */
	btst	#4,%a0@			/* first poll discarded */
_rd_icrwait:
	btst	#4,%a0@			/* wait TOD/FLG */
	beqs	_rd_icrwait
	movew	%d4,%a3@(36)		/* re-strobe DSKLEN */
	movew	#-16384,%a3@(154)	/* INTENA = 0xc000 */
	bras	9f
8:	movew	%d4,%a3@(36)		/* re-strobe DSKLEN */
9:	movel	#458752,%d0		/* timeout 0x70000 */
	lea	%a3@(30),%a0		/* DSKBYT */
10:	movew	%a0@,%d1
	btst	#1,%d1			/* DSKRDY */
	bnes	11f
	subql	#1,%d0
	bnes	10b
11:	movew	#16384,%a3@(36)		/* DSKLEN off */
	.short	0x142d,0x0000
	addqb	#3,%d2
	bset	%d2,%a2@		/* deselect */
	tstl	%d0
	bnes	12f
	btst	#1,%d6
	beqs	14f			/* no retry -> -4 */
	bclr	#0,%d6			/* retry once: raw mode */
	movew	#1024,%a3@(158)		/* ADKCON = 0x0400 */
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@
	bra.w	7b			/* retry DMA */
14:	moveq	#-4,%d0
	bras	_rd_out
12:	andiw	#16383,%d4
	moveal	%a5@(8),%a0
	btst	#0,%d6
	bnes	15f			/* bit0 -> decode sectors */
	moveq	#0,%d0
_rd_raw:
	lsrw	#1,%d4			/* words -> longs-1 */
	subqw	#1,%d4
16:	movel	%a0@+,%a4@+		/* raw copy to dest */
	dbf	%d4,16b
	bras	_rd_out
15:	bsr.w	_decode			/* decode MFM sectors */
	tstl	%d0
	beqs	_rd_out
	btst	#1,%d6
	beqs	_rd_raw			/* decode err + !bit1 -> raw copy too */
	bsr.w	_postwr			/* bit1 -> rebuild pass */
_rd_out:
	moveml	%sp@+,%d3-%d7/%a2-%a6
	rts

/*--- decode: MFM sectors in trkbuf(a0) -> a4 dest ---------------*/
_decode:
	moveml	%d1-%d4/%a0-%a5,%sp@-
	moveal	%a0,%a3
	moveal	%a0,%a5
	cmpiw	#17545,%a3@		/* leading 4489? */
	bnes	1f
	addal	#2,%a3
1:	movel	#268,%d1
2:	movel	#-1431655766,%a4@+	/* fill 0xaaaa gaps (269x) */
	dbf	%d1,2b
	movel	%a3@,%d1
	andil	#1431655765,%d1		/* 0x55555555 even half */
	lsll	#1,%d1
	movel	%a3@(4),%d2
	andil	#1431655765,%d2		/* odd half */
	orl	%d2,%d1			/* decoded longword */
	andil	#255,%d1		/* sector count byte */
	cmpib	#11,%d1
	beqs	_dec_all		/* 11 = whole-track copy */
	blts	3f
	moveq	#-5,%d0
	bra.w	_dec_out
3:	cmpib	#1,%d1
	bges	4f
	moveq	#-5,%d0
	bra.w	_dec_out
4:	movel	%d1,%d2
	muluw	#272,%d2		/* 272 longs/sector */
	subql	#2,%d2
	.short	0x263c
	.long	11
	subl	%d1,%d3
	muluw	#272,%d3
	moveal	%a3,%a0
	lsll	#2,%d2
	addal	%d2,%a0			/* a0 -> target sector */
	lsrl	#2,%d2
	movel	#1088,%d0
5:	cmpiw	#17545,%a0@+		/* hunt next sync */
	beqs	6f
	dbf	%d0,5b
	moveq	#-6,%d0
	bras	_dec_out
6:	cmpiw	#17545,%a0@
	bnes	7f
	subal	#2,%a0
	bras	8f
7:	movel	#1149846665,%a0@-	/* insert 4489 4489 */
8:	movel	#-1431655766,%a0@-	/* preceded by aaaa aaaa */
9:	movel	%a0@+,%a4@+		/* copy tail sectors */
	dbf	%d3,9b
	movel	#1149846665,%a4@+
10:	movel	%a3@+,%a4@+		/* copy head sectors */
	dbf	%d2,10b
	bras	11f
_dec_all:
	movel	#-1431655766,%a4@+
	movel	#1149846665,%a4@+
	movel	#2992,%d0
12:	movel	%a3@+,%a4@+
	dbf	%d0,12b
	moveal	%a3,%a0
11:	moveq	#0,%d0
	lsll	#1,%d4
	subal	%a5,%a0
	cmpal	%d4,%a0		/* bytes consumed > 2*len? */
	bles	_dec_out
	moveq	#-7,%d0
_dec_out:
	moveml	%sp@+,%d1-%d4/%a0-%a5
	rts

/*--- postwr: rebuild pass over decoded area ----------------------*/
_postwr:
	moveml	%d1/%a0/%a4,%sp@-
	.short	0x223c
	.long	127
1:	movel	#-1431655766,%a4@+
	dbf	%d1,1b
	cmpiw	#17545,%a0@
	bnes	2f
	addal	#2,%a0
	movew	#17545,%a4@+
2:	movew	#17545,%a4@+
	movel	#3135,%d0
3:	movel	%a0@+,%a4@+
	dbf	%d0,3b
	movel	#-1431655766,%a4@+
	moveq	#0,%d0
	moveml	%sp@+,%d1/%a0/%a4
	rts

/*------------------------- MFM write (LVO -60) -------------------*/
/* a0=unit a1=src; d0=track*2+side d1=len d2=flags */
_mfmwrite:
	moveml	%d2-%d6/%a2-%a6,%sp@-
	moveal	%a0,%a5
	moveal	%a1,%a4
	lea	0xdff000,%a3
	lea	0xbfd100,%a2
	lea	0xbfe001,%a1
	movel	%d2,%d6
	movel	%d1,%d5
	movel	%d0,%d4
	btst	#3,%d6
	beqs	1f
	cmpiw	#8192,%d5		/* len arg path (bit3) */
	bcss	2f
	moveq	#-1,%d0
	bra.w	_wr_out
1:	cmpil	#-1431655766,%a4@	/* virgin src? */
	beqs	3f
	movel	#6384,%d5		/* default track words */
	bras	2f
3:	movew	%a5@(12),%d5		/* unit track words */
2:	moveb	#127,%a2@
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@		/* select */
	btst	#2,%a1@			/* /RDY */
	bnes	4f
	.short	0x142d,0x0000
	addqb	#3,%d2
	bset	%d2,%a2@
	moveq	#-2,%d0
	bra.w	_wr_out
4:	btst	#7,%a5@(2)
	beqs	5f
	moveq	#1,%d0
	moveal	%a5,%a0
	bsr.w	_select
	moveb	#127,%a2@
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@
5:	btst	#3,%a1@			/* /WPROT */
	bnes	6f
	.short	0x142d,0x0000
	addqb	#3,%d2
	bset	%d2,%a2@
	moveq	#-8,%d0
	bra.w	_wr_out
6:	movel	%d4,%d0
	moveal	%a5,%a0
	bsr.w	_seek
	cmpil	#-1,%d0
	bnes	7f
	moveq	#-3,%d0
	bra.w	_wr_out
7:	moveb	#127,%a2@
	.short	0x142d,0x0000
	addqb	#3,%d2
	bclr	%d2,%a2@
	lsrl	#1,%d4
	bccs	8f
	bclr	#2,%a2@			/* SIDE */
	movel	%d0,%sp@-
	movel	%a5@(16),%d0
	bsr.w	_delay
	movel	%sp@+,%d0
8:	movew	#32512,%a3@(158)	/* ADKCON clr */
	movew	#-28416,%a3@(158)	/* ADKCON 0x9100 */
	cmpb	%a5@(7),%d4		/* precomp thresholds */
	bcss	9f
	movew	#-8192,%a3@(158)	/* 0xe000 */
	bras	10f
9:	cmpb	%a5@(6),%d4
	bcss	11f
	movew	#-16384,%a3@(158)	/* 0xc000 */
	bras	10f
11:	cmpb	%a5@(5),%d4
	bcss	10f
	movew	#-24576,%a3@(158)	/* 0xa000 */
10:	cmpal	#524288,%a4		/* src >= $80000 (chip)? */
	bpls	12f
	movel	%a4,%a3@(32)		/* DSKPT = caller buf */
	bras	13f
12:	moveal	%a5@(8),%a0		/* else bounce via trkbuf */
	movel	%a0,%a3@(32)
	movew	%d5,%d2
	lsrw	#1,%d2
	subqw	#1,%d2
14:	movel	%a4@+,%a0@+
	dbf	%d2,14b
13:	movew	#-32240,%a3@(150)	/* DMACON 0x8210 */
	movew	#4098,%a3@(154)		/* INTENA 0x1002 */
	movew	#2,%a3@(156)		/* INTREQ 2 */
	movew	#16384,%a3@(36)		/* DSKLEN idle */
	andiw	#16383,%d5
	oriw	#-16384,%d5		/* |0xc000 write+DMA */
	movew	%d5,%a3@(36)		/* DSKLEN */
	btst	#1,%d6
	beqs	15f
	lea	0xbfdd00,%a0
	movew	#16384,%a3@(154)	/* INTENA 0x4000 */
	btst	#4,%a0@
_wr_icrwait:
	btst	#4,%a0@
	beqs	_wr_icrwait
	movew	%d5,%a3@(36)
	movew	#-16384,%a3@(154)	/* INTENA 0xc000 */
	bras	16f
15:	movew	%d5,%a3@(36)
16:	lea	%a3@(30),%a0		/* DSKBYT */
17:	movew	%a0@,%d1
	btst	#1,%d1
	beqs	17b			/* wait DSKRDY (NO timeout) */
	movew	#16384,%a3@(36)		/* DSKLEN off */
	.short	0x142d,0x0000
	addqb	#3,%d2
	bset	%d2,%a2@
	moveq	#0,%d0
_wr_out:
	moveml	%sp@+,%d2-%d6/%a2-%a6
	rts

/*------------------------- delay --------------------------------*/
_delay:	subql	#1,%d0
	bnes	_delay
	rts

/*------------------------- verify (LVO -66) ----------------------*/
/* wraps _mfmread then compares 3261 longs of dest vs a2 */
_verify:
	moveml	%d3/%a3,%sp@-
	moveal	%a1,%a3
	movel	%d2,%d3
	moveq	#0,%d2
	bsr.w	_mfmread
	tstl	%d0
	bnes	1f
	movel	#3260,%d1
2:	cmpml	%a2@+,%a3@+
	bnes	3f
	dbf	%d1,2b
1:	moveml	%sp@+,%d3/%a3
	rts
3:	moveq	#-9,%d0
	bras	1b

/*------------------------- delay --------------------------------*/

_endskip:
