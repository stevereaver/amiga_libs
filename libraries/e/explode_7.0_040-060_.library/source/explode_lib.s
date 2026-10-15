/*
** explode.library 7.0 (28.08.96) — Struijk/Brouwer, 68040/60 bugfix by
** Grzegorz Calkowski.
**
** Reconstruction skeleton.  Wedges onto TWO dos.library vectors this
** time: LoadSeg (-150) and NewLoadSeg (-768).  Each gets its own
** six-byte 'jsr old' stub; after the real call returns the shared
** checker inspects hunk0 for the packed signature (movem.l allregs at
** +4, "explode.library" or the "ed explode.libra" variant at +40) and
** inflates the segment in place with the backward-reading LZ/Huffman
** decoder below.
**
** C side provides: LibInit (dual wedge install), LibOpen, LibClose,
** the shared expunge body and ExpMark (-36).
**
** Everything from _ExpStubNL to the Huffman tables is transcribed
** verbatim from the shipped binary: the bit reader is a register-level
** coroutine (state parked in the 54-byte a4 frame across ring-buffer
** refills) whose behaviour cannot be reproduced reliably in C.
**
** 7.0 differences vs 5.6.29: unconditional CacheClearU (040/060 fix),
** hunk-walk inlined at every use site, movem.l burst copies in the
** block mover, decoder blocks reordered (same algorithm).
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
	.byte	0x80,7				/* RTF_AUTOINIT, ver 7 */
	.byte	9,0				/* NT_LIBRARY, pri 0 */
	.long	_exp_name			/* -> 0x1e */
	.long	_exp_idstr			/* -> 0x2e */
	.long	_exp_init			/* -> 0xa6 */

/* ---- hunk+0x1e: strings ------------------------------------------- */
_exp_name:
	.ascii	"explode.library"
	.byte	0
_exp_idstr:
	.ascii	"explode.library 7.0 (28.08.96) written by P.Struijk & A.J.Brouwer, 68040/60 bugfix by Grzegorz Calkowski"
	.byte	13,10,0
	.globl	_exp_dosname
_exp_dosname:					/* 0x99 */
	.ascii	"dos.library"
	.byte	0,0

/* ---- hunk+0xa6: AUTOINIT block ------------------------------------ */
_exp_init:
	.long	0x36				/* datasize = 54 */
	.long	_exp_functab
	.long	_exp_datatab
	.long	_LibInit			/* C: wedge install */

/* ---- hunk+0xb6: function table (LONG form) ------------------------ */
_exp_functab:
	.long	_LibOpen			/* -6  */
	.long	_LibClose			/* -12 */
	.long	_exp_ret0			/* -18 (real expunge via close) */
	.long	_exp_ret0			/* -24 */
	.long	_ExpExplode			/* -30 */
	.long	_ExpMark			/* -36 */
	.long	-1

/* ---- hunk+0xd2: data table (24-bit-offset InitStruct form) -------- */
/* NOTE: word@0x14 = 6, word@0x16 = 0 — the shipped binary carries    */
/* lib_Version 6.0 in the node while the idstring/rt_Version say 7.0. */
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

/* ---- hunk+0x1f2: -768 NewLoadSeg stub ------------------------------ */
/* jsr old-vector (operand patched by LibInit); bra skips the second   */
/* stub so the signature check runs once.                              */
	.globl	_ExpStubNL
_ExpStubNL:
	.word	0x4eb9				/* jsr abs                 */
	.long	0				/*   patched by LibInit    */
	bras	_exp7_check

/* ---- hunk+0x1fa: -150 LoadSeg stub -------------------------------- */
	.globl	_ExpStub
_ExpStub:
	.word	0x4eb9				/* jsr abs                 */
	.long	0				/*   patched by LibInit    */

/* ---- hunk+0x200: shared post-call signature check ------------------ */
_exp7_check:
	moveml	d0/a0,sp@-
	addl	d0,d0				/* seglist BPTR -> address */
	addl	d0,d0
	beqw	_exp7_done
	moveal	d0,a0
	cmpil	#0x48e7ffff,a0@(4)		/* 'movem.l all,-(sp)'     */
	bnes	_exp7_done
	addaw	#0x28,a0
	cmpil	#0x6578706c,a0@+		/* 'expl'                  */
	beqs	_exp7_expl
	cmpil	#0x65642065,a0@+		/* 'ed e'  (sig variant)   */
	bnes	_exp7_done
	cmpil	#0x78706c6f,a0@+		/* 'xplo'                  */
	bnes	_exp7_done
	cmpil	#0x64652e6c,a0@+		/* 'de.l'                  */
	bnes	_exp7_done
	cmpil	#0x69627261,a0@			/* 'ibra'                  */
	beqs	_exp7_go
	bras	_exp7_done
_exp7_expl:
	cmpil	#0x6f64652e,a0@+		/* 'ode.'                  */
	bnes	_exp7_done
	cmpil	#0x6c696272,a0@+		/* 'libr'                  */
	bnes	_exp7_done
	cmpil	#0x61727900,a0@			/* 'ary\0'                 */
	bnes	_exp7_done
_exp7_go:
	moveal	d0,a0
	moveml	d1-d7/a1-a6,sp@-
	lea	a0@(32),a5			/* a5 = packed control blk */
	subaw	#54,sp
	moveal	sp,a4
	bsrs	_exp7_unpack			/* inflate the segment     */
	addaw	#54,sp
	moveal	0x4,a6
	jsr	a6@(-636)			/* CacheClearU             */
	moveml	sp@+,d1-d7/a1-a6
_exp7_done:
	moveml	sp@+,d0/a0
	tstl	d0
	rts

/* ---- hunk+0x288: -30 Explode -------------------------------------- */
/* Called via jsr with the packed control block immediately after the  */
/* jsr: the pushed return address doubles as the source pointer.       */
/* Caller must have saved d0-d7/a0-a6 (60 bytes) beneath the retaddr.  */
/* On return, rts enters hunk0+4 of the freshly inflated segment: the  */
/* a1 stored at 60(sp) lands in the slot the final rts pops.           */
	.globl	_ExpExplode
_ExpExplode:
	subqw	#1,a6@(32)			/* lib_OpenCnt--          */
	moveal	sp@+,a5				/* a5 = retaddr = src ptr */
	subaw	#54,sp
	moveal	sp,a4
	bsrs	_exp7_unpack
	moveal	a4@(48),a1			/* a1 = seg base           */
	addql	#4,a1				/*   +4 = hunk0 data start */
	addaw	#54,sp
	movel	a1,sp@(60)			/* -> the rts slot         */
	moveal	0x4,a6
	jsr	a6@(-636)			/* CacheClearU             */
	moveml	sp@+,d0-a6
	rts

/* ---- hunk+0x2b2: decompressor setup ------------------------------- */
/* a5 = packed control block (hunk+32); a4 = 54-byte work frame.       */
/* Frame layout: +0 litrun w, +2 bitbuf b, +3 resume b, +4 blocks l,   */
/* +8 tab1 4B, +12 tab1b 8B, +20 lensums 16B, +36 tab2 12B, +48 seg,   */
/* +52 last-output-hunk index w.                                       */
_exp7_unpack:
	movel	a5,sp@-				/* save source            */
	lea	_exp7_tab1(pc),a0
	movel	a0@+,a4@(8)
	lea	a4@(12),a1
	movel	a0@+,a1@+
	movel	a0@+,a1@+
	moveb	a5@,d0
	lsrb	#4,d0
	moveb	d0,a1@-				/* hi nibble -> a4+19     */
	moveb	a5@+,d0
	andiw	#15,d0				/* lo nibble = table slot */
	addw	d0,d0
	addw	d0,d0
	movew	d0,d1
	addw	d0,d0
	addw	d1,d0				/* d0 = nibble*12         */
	moveb	a5@+,a4@(2)			/* bitbuf init            */
	movew	a5@+,a4@			/* litrun count           */
	movel	a5@,a4@(4)			/* block counter          */
	clrb	a4@(3)
	lea	_exp7_tab2(pc),a0
	addaw	d0,a0				/* a0 = tab2 + nibble*12  */
	lea	a4@(36),a1
	movel	a0@+,a1@+
	movel	a0@+,a1@+
	movel	a0@+,a1@			/* 12B record -> a4+36    */
	lea	a4@(36),a0
	lea	a4@(20),a1
	moveq	#7,d1
_ls:	moveb	a0@+,d0				/* 8 length bytes         */
	bpls	1f
	andib	#127,d0				/* bit7 -> (b&127)+8      */
	addqb	#8,d0
1:	moveq	#0,d2
	bset	d0,d2				/* d2 = 1<<len            */
	tstl	a4@(4)
	bpls	2f
	subqw	#1,d2
2:	movew	d2,a1@+				/* -> a4+20..35           */
	dbf	d1,_ls
	lea	a4@(20),a0
	lea	a4@(28),a1
	moveq	#3,d1
_ps:	movew	a0@+,d0
	addw	d0,a1@+				/* prefix sums -> a4+28   */
	dbf	d1,_ps
	bclr	#31,a4@(4)
	moveal	sp@+,a0				/* a0 = source again      */
	lea	a0@(-32),a2			/* a2 = seg hunk base     */
	movel	a2,a4@(48)
	moveq	#-1,d0
_cnt:	addqw	#1,d0				/* follow BPTR links:     */
	movel	a2@,d1				/* d0 = last hunk index   */
	addl	d1,d1
	addl	d1,d1
	moveal	d1,a2
	bnes	_cnt
	movew	d0,a4@(52)
	subqw	#1,a4@(52)			/* = count-2 (output lim) */
	movew	d0,d6				/* inlined hunk[d6] walk  */
	movew	d6,d7
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	3f
_w1:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w1
3:	addql	#4,a1				/* a1 = last hunk +4      */
	moveal	a1,a6
	movel	a1@(-8),d0
	subql	#8,d0
	movel	d0,d4				/* d4 = ring size         */
	addal	d0,a6				/* a6 = ring top          */
	moveal	a6,a2				/* a2 = ring read pos     */
	subqw	#1,d6
	movew	d6,d7
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	4f
_w2:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w2
4:	addql	#4,a1				/* a1 = hunk[count-2]     */
	movel	a1@(-8),d0
	subql	#8,d0
	tstb	a0@(-23)			/* flag byte src+9        */
	beqs	5f
	subql	#4,d0				/* size = ((sz-4)<<8)|flg */
	orb	a0@(-23),d0
5:	moveal	a1,a0
	addal	d0,a0				/* a0 = packed data end   */
	moveq	#0,d5				/* d5 = hunk index        */
_hl:	movew	d5,d6				/* inlined hunk[d6] walk  */
	movew	d6,d7
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	6f
_w3:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w3
6:	addql	#4,a1
	moveal	a1,a3				/* a3 = dest write pos    */
_ctll:	cmpal	a6,a2				/* control long (inlined  */
	bnes	11f				/*   ring-read + refill)  */
	bsrw	_exp7_rewind
11:	movel	a2@+,d0
	bpls	7f
	addqw	#1,d5				/* sign set -> next hunk  */
	cmpw	a4@(52),d5
	bnes	_hl
	braw	_exp7_tail			/* all done               */
7:	addl	d0,d0
	bpls	_exp7_copy			/* bit30 clr -> copy run  */
_exp7_rlitem:
	cmpal	a6,a2				/* reloc count (inlined)  */
	bnes	12f
	bsrw	_exp7_rewind
12:	movel	a2@+,d0
	movel	d0,d1
	beqs	_ctll				/* 0 = end of list        */
	cmpal	a6,a2				/* reloc hunk idx(inlined)*/
	bnes	13f
	bsrs	_exp7_rewind
13:	movel	a2@+,d0
	movew	d0,d6				/* inlined hunk[d6] walk  */
	movew	d6,d7
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	8f
_w4:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w4
8:	addql	#4,a1
	movel	a1,d3				/* relocation base        */
	moveq	#0,d2
_rl:	cmpal	a6,a2				/* ring wrap check        */
	bnes	9f
	bsrs	_exp7_rewind
9:	addl	a2@+,d2				/* accumulate offset      */
	addl	d3,a3@(0,d2:l)			/* *(a3+d2) += hunk base  */
	subql	#1,d1
	bnes	_rl
	bras	_exp7_rlitem

/* ---- copy d0 ring longs to dest (32B movem bursts) ----------------- */
_exp7_copy:
	lsrl	#1,d0				/* undo the test shift    */
	moveal	a3,a1
_exp7_cpyl:
	lea	a6@(-32),a6			/* keep 32B margin        */
	moveml	d1-d7/a0,sp@-
_cpy:	subql	#8,d0
	bmis	11f
	cmpal	a6,a2
	bhis	11f
	moveml	a2@+,d1-d7/a0
	moveml	d1-d7/a0,a1@
	addaw	#32,a1
	bras	_cpy
11:	moveml	sp@+,d1-d7/a0
	lea	a6@(32),a6
	addql	#8,d0
	beqw	_ctll
_tc:	cmpal	a6,a2				/* tail: slow wrap checks */
	beqs	12f
	movel	a2@+,a1@+
	subql	#1,d0
	bnes	_tc
	braw	_ctll
12:	bsrs	_exp7_rewind
	bras	_exp7_cpyl			/* re-enter mid-copy      */

/* ---- ring wrap + decoder refill coroutine -------------------------- */
/* Entered via bsr whenever the read pointer hits the ring top: wraps  */
/* a2 to the bottom, then decodes bitstream -> a3 until the ring is    */
/* full (d5<0) or the block counter runs out; parks its state in the   */
/* a4 frame and rts's back to the caller's copy loop.                  */
_exp7_rewind:
	subal	d4,a2				/* a2 -> ring bottom      */
	moveml	d0-d3/d5-d6/a3,sp@-
	moveal	a2,a3				/* a3 = ring write pos    */
	movew	d4,d5				/* d5 = ring space        */
	movew	a4@,d2				/* d2 = litrun count      */
	moveb	a4@(2),d1			/* d1 = bit buffer        */
	moveb	a4@(3),d0			/* d0 = resume match len  */
	bnew	_exp7_mxfer
	braw	_exp7_litchk
_exp7_bits:					/* --- bit reader ---     */
	addb	d1,d1
	bnes	13f
	moveb	a0@-,d1
	addxb	d1,d1
13:	bccs	_exp7_len2			/* 0 -> literal-run hdr   */
	addb	d1,d1
	bnes	14f
	moveb	a0@-,d1
	addxb	d1,d1
14:	bccs	_exp7_len3
	addb	d1,d1
	bnes	15f
	moveb	a0@-,d1
	addxb	d1,d1
15:	bccs	_exp7_len4
	addb	d1,d1
	bnes	16f
	moveb	a0@-,d1
	addxb	d1,d1
16:	bccs	_exp7_len5
	addb	d1,d1
	bnes	17f
	moveb	a0@-,d1
	addxb	d1,d1
17:	bccs	_exp7_len6			/* 0 -> 6+3bit length     */
	moveb	a0@-,d0				/* 1 -> raw byte length   */
	moveq	#3,d7
	bras	_exp7_dist
_exp7_len6:
	addb	d1,d1
	bnes	18f
	moveb	a0@-,d1
	addxb	d1,d1
18:	addxb	d0,d0
	addb	d1,d1
	bnes	19f
	moveb	a0@-,d1
	addxb	d1,d1
19:	addxb	d0,d0
	addb	d1,d1
	bnes	20f
	moveb	a0@-,d1
	addxb	d1,d1
20:	addxb	d0,d0
	addqb	#6,d0
	moveq	#3,d7
	bras	_exp7_dist
_exp7_len5:
	moveq	#5,d0
	moveq	#3,d7
	bras	_exp7_dist
_exp7_len4:
	moveq	#4,d0
	moveq	#2,d7
	bras	_exp7_dist
_exp7_len3:
	moveq	#3,d0
	moveq	#1,d7
	bras	_exp7_dist
_exp7_len2:
	moveq	#2,d0
	moveq	#0,d7
_exp7_dist:
	movew	d7,d3				/* d3 = dist-class idx    */
	addb	d1,d1
	bnes	21f
	moveb	a0@-,d1
	addxb	d1,d1
21:	bccs	_exp7_dd			/* 0 -> short dist        */
	addb	d1,d1
	bnes	22f
	moveb	a0@-,d1
	addxb	d1,d1
22:	bccs	_exp7_dm			/* 10 -> medium dist      */
	moveq	#0,d6				/* 11 -> tab1[class]      */
	moveb	a4@(8,d7:w),d6
	addqb	#4,d7
	bras	_exp7_db
_exp7_dd:
	addb	d1,d1
	bnes	23f
	moveb	a0@-,d1
	addxb	d1,d1
23:	addxw	d2,d2				/* dist = 2*d2 + bit      */
	bras	_exp7_df
_exp7_dm:
	moveq	#2,d6
_exp7_db:
	moveb	a4@(12,d7:w),d7			/* d7 = tab1b[class] bits */
_dbl:	addb	d1,d1
	bnes	24f
	moveb	a0@-,d1
	addxb	d1,d1
24:	addxw	d2,d2
	subqb	#1,d7
	bnes	_dbl
	addw	d6,d2
_exp7_df:
	moveq	#0,d6
	moveaw	d6,a5				/* a5 = 0                 */
	movew	d3,d7
	addb	d1,d1
	bnes	25f
	moveb	a0@-,d1
	addxb	d1,d1
25:	bccs	_exp7_dh
	addw	d3,d3				/* d3 *= 2                */
	addb	d1,d1
	bnes	26f
	moveb	a0@-,d1
	addxb	d1,d1
26:	bccs	_exp7_dg
	moveaw	a4@(28,d3:w),a5			/* prefix-sum base        */
	addqb	#8,d7
	bras	_exp7_dh
_exp7_dg:
	moveaw	a4@(20,d3:w),a5			/* length-table base      */
	addqb	#4,d7
_exp7_dh:
	moveb	a4@(36,d7:w),d7			/* extra distance bits    */
	bpls	_dhl
	moveb	a0@-,d6				/* bit7 -> next byte      */
	andib	#127,d7
	beqs	_exp7_dj
_dhl:	addb	d1,d1
	bnes	28f
	moveb	a0@-,d1
	addxb	d1,d1
28:	addxw	d6,d6
	subqb	#1,d7
	bnes	_dhl
_exp7_dj:
	addqw	#1,d6
	addw	a5,d6				/* distance = d6 + base   */
	moveal	a3,a5
	subaw	d6,a5				/* a5 = match source      */
	cmpal	a2,a5				/* below ring bottom?     */
	bccs	29f
	addaw	d4,a5				/* wrap + ringsize        */
29:	cmpal	a5,a6				/* at ring top?           */
	bnes	_exp7_mxfer
	moveal	a2,a5				/* use ring bottom        */
_exp7_mxfer:
	subqw	#1,d5				/* ring space--           */
	bmis	_exp7_save
	moveb	a5@+,a3@+			/* copy match byte        */
	subqb	#1,d0
	bnes	29b				/* incl. ring-top re-check*/
_exp7_litchk:
	tstw	d2
	beqs	_exp7_blk
_lit:	subqw	#1,d5				/* pending literal run    */
	bmis	_exp7_save
	moveb	a0@-,a3@+
	subqw	#1,d2
	bnes	_lit
_exp7_blk:
	subql	#1,a4@(4)			/* block counter--        */
	bnew	_exp7_bits
_exp7_save:
	moveb	d0,a4@(3)			/* park resume len        */
	moveb	d1,a4@(2)			/* park bit buffer        */
	movew	d2,a4@				/* park litrun count      */
	moveml	sp@+,d0-d3/d5-d6/a3
	rts

/* ---- finished - free surplus hunks ---------------------------------- */
_exp7_tail:
	movew	a4@(52),d6
	addqw	#1,d6				/* d6 = last hunk index   */
	moveal	0x4,a6
_freel:	movew	d6,d7				/* inlined hunk[d6] walk  */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	30f
_w5:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w5
30:	subql	#4,a1				/* a1 -> alloc header     */
	movel	a1@,d0
	jsr	a6@(-210)			/* FreeMem(hunk,size)     */
	subqw	#1,d6
	cmpw	a4@(52),d6
	bccs	_freel				/* down to output limit+1 */
	movew	d6,d7				/* inlined hunk[d6] walk  */
	moveal	a4@(48),a1
	subqw	#1,d7
	bmis	31f
_w6:	moveal	a1@,a1
	addal	a1,a1
	addal	a1,a1
	dbf	d7,_w6
31:	addql	#4,a1
	clrl	a1@-				/* clear last kept link   */
	rts

/* ---- decoder tables -------------------------------------------------- */
_exp7_tab1:
	.byte	0x06,0x0a,0x0a,0x12		/* a4+8  : dist class base */
	.byte	0x02,0x03,0x03,0x04,0x04,0x05,0x07,0x00 /* a4+12..19     */
_exp7_tab2:					/* 12B records, lo nibble  */
	.byte	0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06
	.byte	0x05,0x06,0x07,0x07,0x06,0x06,0x06,0x06,0x07,0x07,0x06,0x06
	.byte	0x05,0x06,0x07,0x07,0x07,0x07,0x07,0x07,0x80,0x80,0x80,0x80
	.byte	0x05,0x06,0x07,0x80,0x07,0x07,0x80,0x80,0x80,0x81,0x81,0x81
	.byte	0x06,0x07,0x07,0x80,0x07,0x80,0x81,0x81,0x80,0x81,0x82,0x82
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x81,0x82,0x80,0x82,0x83,0x83
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x81,0x82,0x80,0x82,0x84,0x84
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x82,0x82,0x80,0x83,0x84,0x85
	.byte	0x06,0x07,0x07,0x80,0x07,0x81,0x82,0x83,0x80,0x83,0x85,0x86

/* ---- shared return-0 stub (vectors -18/-24) ------------------------ */
	.globl	_exp_ret0
_exp_ret0:
	moveq	#0,d0
	rts

	.globl	_TagEnd
_TagEnd:
	.end
