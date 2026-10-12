/*
** explode.library "Executable Explode Wedge V6.0.64" (28-Oct-91)
**
** Reconstruction skeleton.  The library wedges onto TWO dos.library
** vectors: LoadSeg (-150) and -- on exec >= 37 only -- NewLoadSeg
** (-768).  Each patch is a 6-byte 'jsr old' stub living in the lib's
** own hunk; after the real call returns, the shared checker inspects
** hunk0 for the packed-program signature ('movem.l allregs' at +4,
** then "explode.library" or the "ed explode.libra" variant at +40)
** and inflates the segment in place with the backward-reading
** LZ/Huffman decoder below.
**
** C side provides: LibInit (dual wedge install, raw slot byte
** save/restore like 5.6.29 -- NOT SetFunction-restore like 7.0),
** LibOpen, LibClose and the shared expunge body.
**
** Everything from _ExpMark to the Huffman tables is transcribed
** verbatim from the shipped binary: the bit reader is a
** register-level coroutine (state parked in the 54-byte a4 frame
** across ring-buffer refills) whose behaviour cannot be reproduced
** reliably in C.
**
** 6.0.64 vs 5.6.29: tab2 records are 10-byte stride (not 12),
** hunk-walk inlined at every use site, literal-run handler sits
** between match-xfer and block decrement, match-source wrap check
** moved inside the copy loop, NewLoadSeg hook added (KS2.0+).
*/

	.text
	.even

/* ---- hunk+0x00: 4-byte stub before the RomTag --------------------- */
	moveq	#-1,d0				/* 0x00 70ff */
	rts					/* 0x02 4e75 */

/* ---- hunk+0x04: Resident tag (AUTOINIT) ---------------------------- */
	.globl	_RomTag
_RomTag:
	.word	0x4afc
	.long	_RomTag				/* matchtag  */
	.long	_TagEnd				/* endskip   */
	.byte	0x80,6				/* RTF_AUTOINIT, ver 6 */
	.byte	9,0				/* NT_LIBRARY, pri 0 */
	.long	_exp_name			/* -> 0x1e */
	.long	_exp_idstr			/* -> 0x2e */
	.long	_exp_init			/* -> 0x72 */

/* ---- hunk+0x1e: strings ------------------------------------------- */
_exp_name:
	.ascii	"explode.library"
	.byte	0
_exp_idstr:					/* 0x2e */
	.ascii	"Executable Explode Wedge V6.0.64 (28-Oct-91 18:19:15)"
	.byte	13,10,0
	.globl	_exp_dosname
_exp_dosname:					/* 0x66 */
	.ascii	"dos.library"
	.byte	0

/* ---- hunk+0x72: AUTOINIT block ------------------------------------ */
_exp_init:
	.long	0x36				/* datasize = 54 */
	.long	_exp_functab
	.long	_exp_datatab
	.long	_LibInit			/* C: wedge install */

/* ---- hunk+0x82: function table (LONG form) ------------------------ */
_exp_functab:
	.long	_LibOpen			/* -6  */
	.long	_LibClose			/* -12 */
	.long	_exp_ret0			/* -18 (real expunge via close) */
	.long	_exp_ret0			/* -24 */
	.long	_ExpExplode			/* -30 */
	.long	_ExpMark			/* -36 */
	.long	-1

/* ---- hunk+0x9e: data table ---------------------------------------- */
_exp_datatab:
	.byte	0xe0,0x00,0x00,0x08,0x09,0x00	/* byte  @8  = 9  ln_Type   */
	.byte	0xc0,0x00,0x00,0x0a
	.long	_exp_name			/* long  @10    ln_Name   */
	.byte	0xe0,0x00,0x00,0x0e,0x06,0x00	/* byte  @14 = 6  lib_Flags */
	.byte	0xd0,0x00,0x00,0x14
	.word	6				/* word  @20    lib_Version */
	.byte	0xd0,0x00,0x00,0x16
	.word	0				/* word  @22    lib_Revision */
	.byte	0xc0,0x00,0x00,0x18
	.long	_exp_idstr			/* long  @24    lib_IdString */
	.byte	0,0,0,0				/* terminator + pad */

/* ---- shared return-0 stub (vectors -18/-24) ----------------------- */
	.globl	_exp_ret0
_exp_ret0:
	moveq	#0,d0
	rts

/* ---- -36: request expunge ------------------------------------------ */
/* 'bset #3,34(a6); rts' verbatim -- the private flag byte.            */
	.globl	_ExpMark
_ExpMark:
	bset	#3,a6@(34)
	rts

/* ---- wedge stubs installed into the dos vectors -------------------- */
/* NewLoadSeg (-768): jsr abs -- operand patched by LibInit at +2;     */
/* falls through to the signature check via the bra.                 */
	.globl	_ExpStubNL
_ExpStubNL:
	.word	0x4eb9				/* jsr abs -- operand */
	.long	0				/*   patched by LibInit */
	bras	_exp_chk

/* LoadSeg (-150): moveq#0,d0 ; jsr abs.  For a foreign 'moveq #n;d0   */
/* + bra' vector entry LibInit keeps the moveq arg (stub+1) and        */
/* installs stub+0; for a normal 'jmp abs' slot it installs stub+2.    */
	.globl	_ExpStub
_ExpStub:
	moveq	#0,d0				/* imm patched at +1    */
_ExpStubJ:
	.word	0x4eb9				/* jsr abs -- operand   */
	.long	0				/*   patched at +4      */

/* ---- signature check shared by both stubs -------------------------- */
/* d0 = seglist BPTR result; hunk0 must begin with 'movem.l all,-(sp)' */
/* and carry the decoder name at +0x28.                                */
_exp_chk:
	moveml	d0/a0,sp@-
	addl	d0,d0
	addl	d0,d0				/* BPTR -> address      */
	beqw	_exp_done
	moveal	d0,a0
	cmpil	#0x48e7ffff,a0@(4)		/* 'movem.l all,-(sp)'  */
	bnes	_exp_done
	addaw	#0x28,a0
	cmpil	#0x6578706c,a0@+		/* 'expl' */
	beqs	_exp_full
	cmpil	#0x65642065,a0@+		/* 'ed e' (variant)   */
	bnes	_exp_done
	cmpil	#0x78706c6f,a0@+		/* 'xplo' */
	bnes	_exp_done
	cmpil	#0x64652e6c,a0@+		/* 'de.l' */
	bnes	_exp_done
	cmpil	#0x69627261,a0@			/* 'ibra' (prefix only) */
	beqs	_exp_go
	bras	_exp_done
_exp_full:
	cmpil	#0x6f64652e,a0@+		/* 'ode.' */
	bnes	_exp_done
	cmpil	#0x6c696272,a0@+		/* 'libr' */
	bnes	_exp_done
	cmpil	#0x61727900,a0@			/* 'ary\0' */
	bnes	_exp_done
_exp_go:
	moveal	d0,a0
	moveml	d1-d7/a1-a6,sp@-
	lea	a0@(32),a5			/* a5 = packed control blk */
	subaw	#54,sp
	moveal	sp,a4
	bsrs	_exp_unpack			/* inflate the segment  */
	addaw	#54,sp
	moveml	sp@+,d1-d7/a1-a6
_exp_done:
	moveml	sp@+,d0/a0
	tstl	d0
	rts

/* ---- -30 Explode --------------------------------------------------- */
/* Called via jsr with the packed control block address on the stack   */
/* where a return address would be: popped into a5 it doubles as the   */
/* source pointer.  Caller must have saved d0-d7/a0-a6 beneath it;     */
/* the stacked retaddr slot is overwritten with the first hunk's       */
/* entry so the final rts lands in the decrunched code.                */
	.globl	_ExpExplode
_ExpExplode:
	subqw	#1,a6@(32)			/* lib_OpenCnt--        */
	moveal	sp@+,a5				/* a5 = src ptr         */
	subaw	#54,sp
	moveal	sp,a4
	bsrs	_exp_unpack
	moveal	a4@(48),a1			/* first hunk link ptr  */
	addql	#4,a1
	addaw	#54,sp
	movel	a1,sp@(60)			/* -> returns in saved d0 */
	.word	0x2c79,0x0000,0x0004	/* moveal 0x4,a6 absl */
	cmpiw	#37,a6@(20)
	bcss	1f
	jsr	a6@(-636)			/* CacheClearU (KS2.0+) */
1:	moveml	sp@+,d0-a6
	rts

/* ---- decompressor setup -------------------------------------------- */
/* a5 = packed control block (hunk+32); a4 = 54-byte work frame.       */
/* Frame: +0 litrun w, +2 bitbuf b, +3 resume b, +4 blocks l,          */
/* +8 tab1 12B (last byte overwritten by hi nibble), +20 len bases     */
/* 8w, +28 prefix sums 4w, +36 tab2 record 12B, +48 seg, +52 lim w.    */
_exp_unpack:
	movel	a5,sp@-				/* save source          */
	lea	_exp_tab1(pc),a0
	movel	a0@+,a4@(8)
	lea	a4@(12),a1
	movel	a0@+,a1@+
	movel	a0@+,a1@+
	moveb	a5@,d0
	lsrb	#4,d0
	moveb	d0,a1@-				/* hi nibble -> a4+19   */
	moveb	a5@+,d0
	andiw	#15,d0				/* lo nibble = tab slot */
	addw	d0,d0
	addw	d0,d0				/* *4                   */
	movew	d0,d1
	addw	d0,d0
	addw	d1,d0				/* *10 (10B stride)     */
	moveb	a5@+,a4@(2)			/* bitbuf init          */
	movew	a5@+,a4@			/* litrun count         */
	movel	a5@,a4@(4)			/* block counter        */
	clrb	a4@(3)
	lea	_exp_tab2(pc),a0
	addaw	d0,a0				/* a0 = tab2 + nib*10   */
	lea	a4@(36),a1
	movel	a0@+,a1@+
	movel	a0@+,a1@+
	movel	a0@+,a1@			/* 12B record -> a4+36  */
	lea	a4@(36),a0
	lea	a4@(20),a1
	moveq	#7,d1
1:	moveb	a0@+,d0				/* 8 length bytes       */
	bpls	2f
	andib	#127,d0				/* bit7 -> (b&127)+8    */
	addqb	#8,d0
2:	moveq	#0,d2
	bset	d0,d2				/* d2 = 1<<len          */
	tstl	a4@(4)
	bpls	3f
	subqw	#1,d2
3:	movew	d2,a1@+				/* -> a4+20..35         */
	dbf	d1,1b
	lea	a4@(20),a0
	lea	a4@(28),a1
	moveq	#3,d1
4:	movew	a0@+,d0
	addw	d0,a1@+				/* prefix sums -> a4+28 */
	dbf	d1,4b
	bclr	#31,a4@(4)
	moveal	sp@+,a0				/* a0 = source again    */
	lea	a0@(-32),a2			/* a2 = seg hunk base   */
	movel	a2,a4@(48)
	moveq	#-1,d0
5:	addqw	#1,d0				/* follow BPTR links:   */
	movel	a2@,d1				/* d0 = last hunk index */
	addl	d1,d1
	addl	d1,d1
	moveal	d1,a2
	bnes	5b
	movew	d0,a4@(52)
	subqw	#1,a4@(52)			/* = count-2 (out lim)  */
	movew	d0,d6
	movew	d6,d7				/* hunk[d6] -> a1       */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	6f
7:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,7b
6:	addql	#4,a1
	moveal	a1,a6
	movel	a1@(-8),d0
	subql	#8,d0
	movel	d0,d4				/* d4 = ring size       */
	addal	d0,a6				/* a6 = ring top        */
	moveal	a6,a2				/* a2 = ring read pos   */
	subqw	#1,d6
	movew	d6,d7				/* hunk[d6] -> a1       */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	8f
9:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,9b
8:	addql	#4,a1
	movel	a1@(-8),d0
	subql	#8,d0
	tstb	a0@(-23)			/* flag byte src+9      */
	beqs	10f
	subql	#4,d0				/* size = ((sz-4)<<8)|f */
	orb	a0@(-23),d0
10:	moveal	a1,a0
	addal	d0,a0				/* a0 = bitread top     */
	moveq	#0,d5

/* ---- control stream loop ------------------------------------------- */
/* a2 walks the ring forward: -1 header = next output hunk, header    */
/* with bit30 = relocation item, else literal run.                     */
_exp_mainloop:
	movew	d5,d6
	movew	d6,d7				/* hunk[d6] -> a3       */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	11f
12:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,12b
11:	addql	#4,a1
	moveal	a1,a3
_exp_fetch:
	cmpal	a6,a2				/* ring exhausted?      */
	bnes	13f
	bsrw	_exp_block			/* decode next ring seg */
13:	movel	a2@+,d0
	bpls	_exp_litblk
	addqw	#1,d5				/* -1: next out hunk    */
	cmpw	a4@(52),d5
	bnes	_exp_mainloop
	braw	_exp_fin

_exp_litblk:
	addl	d0,d0				/* test bit30           */
	bpls	_exp_rawcopy
_exp_rlitem:
	cmpal	a6,a2				/* reloc block          */
	bnes	14f
	bsrs	_exp_block
14:	movel	a2@+,d0
	movel	d0,d1				/* d1 = item count      */
	beqs	_exp_fetch
	cmpal	a6,a2
	bnes	15f
	bsrs	_exp_block
15:	movel	a2@+,d0
	movew	d0,d6				/* target hunk index    */
	movew	d6,d7
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	16f
17:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,17b
16:	addql	#4,a1
	movel	a1,d3				/* d3 = target hunk     */
	moveq	#0,d2
18:	cmpal	a6,a2
	bnes	19f
	bsrs	_exp_block
19:	addl	a2@+,d2				/* delta offsets        */
	addl	d3,a3@(0,d2:l)			/* *(a3+d2) += hunk ptr */
	subql	#1,d1
	bnes	18b
	bras	_exp_rlitem

_exp_rawcopy:
	lsrl	#1,d0				/* undo the test shift  */
	moveal	a3,a1
_exp_cpyl:
	lea	a6@(-32),a6			/* keep 32B margin      */
	moveml	d1-a0,sp@-
20:	subql	#8,d0
	bmis	21f
	cmpal	a6,a2
	bhis	21f
	moveml	a2@+,d1-a0			/* 8-long burst         */
	moveml	d1-a0,a1@
	addaw	#32,a1
	bras	20b
21:	moveml	sp@+,d1-a0
	lea	a6@(32),a6
	addql	#8,d0
	beqw	_exp_fetch
22:	cmpal	a6,a2				/* tail: wrap checks    */
	beqs	23f
	movel	a2@+,a1@+
	subql	#1,d0
	bnes	22b
	braw	_exp_fetch
23:	bsrs	_exp_block
	bras	_exp_cpyl			/* re-enter mid-copy    */

/* ---- ring wrap + decoder refill coroutine -------------------------- */
/* Entered via bsr when the ring read pos hits the top: wraps a2 to   */
/* the bottom, then decodes bitstream -> a3 until the ring is full     */
/* (d5<0) or blocks run out; parks state in the a4 frame.              */
_exp_block:
	subal	d4,a2				/* a2 -> ring bottom    */
	moveml	d0-d3/d5-d6/a3,sp@-
	moveal	a2,a3				/* a3 = ring write pos  */
	movew	d4,d5				/* d5 = ring space      */
	movew	a4@,d2				/* d2 = litrun count    */
	moveb	a4@(2),d1			/* d1 = bit buffer      */
	moveb	a4@(3),d0			/* d0 = resume len      */
	bnew	_exp_match
	braw	_exp_litrun

_exp_bloop:
	addb	d1,d1				/* --- bit reader ---   */
	bnes	24f
	moveb	a0@-,d1
	addxb	d1,d1
24:	bccs	_exp_len2			/* 0 -> len 2           */
	addb	d1,d1
	bnes	25f
	moveb	a0@-,d1
	addxb	d1,d1
25:	bccs	_exp_len3
	addb	d1,d1
	bnes	26f
	moveb	a0@-,d1
	addxb	d1,d1
26:	bccs	_exp_len4
	addb	d1,d1
	bnes	27f
	moveb	a0@-,d1
	addxb	d1,d1
27:	bccs	_exp_len5
	addb	d1,d1
	bnes	28f
	moveb	a0@-,d1
	addxb	d1,d1
28:	bccs	_exp_len6			/* 0 -> 6+3bit len      */
	moveb	a0@-,d0				/* 1 -> raw byte len    */
	moveq	#3,d7
	bras	_exp_dist
_exp_len6:
	addb	d1,d1
	bnes	29f
	moveb	a0@-,d1
	addxb	d1,d1
29:	addxb	d0,d0
	addb	d1,d1
	bnes	30f
	moveb	a0@-,d1
	addxb	d1,d1
30:	addxb	d0,d0
	addb	d1,d1
	bnes	31f
	moveb	a0@-,d1
	addxb	d1,d1
31:	addxb	d0,d0
	addqb	#6,d0
	moveq	#3,d7
	bras	_exp_dist
_exp_len5:
	moveq	#5,d0
	moveq	#3,d7
	bras	_exp_dist
_exp_len4:
	moveq	#4,d0
	moveq	#2,d7
	bras	_exp_dist
_exp_len3:
	moveq	#3,d0
	moveq	#1,d7
	bras	_exp_dist
_exp_len2:
	moveq	#2,d0
	moveq	#0,d7
_exp_dist:
	movew	d7,d3				/* d3 = dist-class idx  */
	addb	d1,d1
	bnes	32f
	moveb	a0@-,d1
	addxb	d1,d1
32:	bccs	_exp_dd				/* 0 -> short dist      */
	addb	d1,d1
	bnes	33f
	moveb	a0@-,d1
	addxb	d1,d1
33:	bccs	_exp_dm				/* 10 -> medium dist    */
	moveq	#0,d6				/* 11 -> tab1[class]    */
	moveb	a4@(8,d7:w),d6
	addqb	#4,d7
	bras	_exp_db
_exp_dd:
	addb	d1,d1
	bnes	34f
	moveb	a0@-,d1
	addxb	d1,d1
34:	addxw	d2,d2				/* dist = 2*d2 + bit    */
	bras	_exp_df
_exp_dm:
	moveq	#2,d6
_exp_db:
	moveb	a4@(12,d7:w),d7			/* d7 = tab1b bits      */
35:	addb	d1,d1
	bnes	36f
	moveb	a0@-,d1
	addxb	d1,d1
36:	addxw	d2,d2
	subqb	#1,d7
	bnes	35b
	addw	d6,d2
_exp_df:
	moveq	#0,d6
	moveaw	d6,a5				/* a5 = 0               */
	movew	d3,d7
	addb	d1,d1
	bnes	37f
	moveb	a0@-,d1
	addxb	d1,d1
37:	bccs	_exp_dh
	addw	d3,d3				/* d3 *= 2              */
	addb	d1,d1
	bnes	38f
	moveb	a0@-,d1
	addxb	d1,d1
38:	bccs	_exp_dg
	moveaw	a4@(28,d3:w),a5			/* prefix-sum base      */
	addqb	#8,d7
	bras	_exp_dh
_exp_dg:
	moveaw	a4@(20,d3:w),a5			/* length-table base    */
	addqb	#4,d7
_exp_dh:
	moveb	a4@(36,d7:w),d7			/* extra distance bits  */
	bpls	39f
	moveb	a0@-,d6				/* bit7 -> next byte    */
	andib	#127,d7
	beqs	40f
39:	addb	d1,d1
	bnes	41f
	moveb	a0@-,d1
	addxb	d1,d1
41:	addxw	d6,d6
	subqb	#1,d7
	bnes	39b
40:	addqw	#1,d6
	addw	a5,d6				/* distance = d6 + base */
	moveal	a3,a5
	subaw	d6,a5				/* a5 = match source    */
	cmpal	a2,a5				/* below ring bottom?   */
	bccs	42f
	addaw	d4,a5				/* wrap + ringsize      */
42:	cmpal	a5,a6				/* at ring top?         */
	bnes	_exp_match
	moveal	a2,a5				/* use ring read pos    */
_exp_match:
	subqw	#1,d5				/* ring space--         */
	bmis	_exp_save
	moveb	a5@+,a3@+			/* copy match byte      */
	subqb	#1,d0
	bnes	42b				/* incl. top re-check   */
_exp_litrun:
	tstw	d2
	beqs	_exp_next
43:	subqw	#1,d5				/* pending literal run  */
	bmis	_exp_save
	moveb	a0@-,a3@+
	subqw	#1,d2
	bnes	43b
_exp_next:
	subql	#1,a4@(4)			/* block counter--      */
	bnew	_exp_bloop
_exp_save:
	moveb	d0,a4@(3)			/* park resume len      */
	moveb	d1,a4@(2)			/* park bit buffer      */
	movew	d2,a4@				/* park litrun count    */
	moveml	sp@+,d0-d3/d5-d6/a3
	rts

/* ---- finished - free surplus hunks --------------------------------- */
_exp_fin:
	movew	a4@(52),d6
	addqw	#1,d6				/* d6 = last hunk index */
	.word	0x2c79,0x0000,0x0004	/* moveal 0x4,a6 absl */
44:	movew	d6,d7				/* hunk[d6] link ptr    */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	45f
46:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,46b
45:	subql	#4,a1				/* -> alloc header      */
	movel	a1@,d0
	jsr	a6@(-210)			/* FreeMem(hunk,size)   */
	subqw	#1,d6
	cmpw	a4@(52),d6
	bccs	44b				/* down to out limit+1  */
	movew	d6,d7				/* hunk[d6] +4          */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	47f
48:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,48b
47:	addql	#4,a1
	clrl	a1@-				/* clear last kept link */
	rts

/* ---- decoder tables ------------------------------------------------ */
_exp_tab1:
	.byte	0x06,0x0a,0x0a,0x12		/* a4+8  : dist base    */
	.byte	0x02,0x03,0x03,0x04,0x04,0x05,0x07,0x00 /* a4+12..19 */
_exp_tab2:					/* 10B-stride records   */
	.byte	0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05
	.byte	0x06,0x06,0x06,0x06,0x05,0x06,0x07,0x07
	.byte	0x06,0x06,0x06,0x06,0x07,0x07,0x06,0x06
	.byte	0x05,0x06,0x07,0x07,0x07,0x07,0x07,0x07
	.byte	0x80,0x80,0x80,0x80,0x05,0x06,0x07,0x80
	.byte	0x07,0x07,0x80,0x80,0x80,0x81,0x81,0x81
	.byte	0x06,0x07,0x07,0x80,0x07,0x80,0x81,0x81
	.byte	0x80,0x81,0x82,0x82,0x06,0x07,0x07,0x80
	.byte	0x07,0x81,0x81,0x82,0x80,0x82,0x83,0x83
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x81,0x82
	.byte	0x80,0x82,0x84,0x84,0x06,0x07,0x07,0x80
	.byte	0x07,0x81,0x82,0x82,0x80,0x83,0x84,0x85
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x82,0x83
	.byte	0x80,0x83,0x85,0x86

	.globl	_TagEnd
_TagEnd:
	.word	0
	.end
