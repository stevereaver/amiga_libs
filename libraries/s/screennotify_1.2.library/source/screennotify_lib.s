	.file	"screennotify_lib.s"
	.text

/*
**	screennotify.library 1.2 -- AUTOINIT skeleton + code images
**
**	Layout follows the original hunk:
**	  0x000  EndSkip stub (moveq #-1,d0; rts)
**	  0x004  RomTag 4afc / AUTOINIT, pri 0x82
**	  0x01e  init table (dataSize 0x386)
**	  0x02e  function table (word offsets)
**	  0x046  data table
**	  0x062  strings
**	  0x0d4  list-block init helper
**	  0x10c  LibInit/Open/Close/Expunge + publics
**	  0x494  worker-process code image (0x9c bytes) + proc name
**	  0x530  intuition-patch code image (0x1b0 bytes)
**
**	The patch image is copied into the library base at +470 and
**	installed over four intuition vectors.  Its PC-relative
**	references are written so that, when executed from inside the
**	library base, each reference lands on a base field:
**
**	    image ref target file offset = (lib offset) + 0x35a
**
**	The .set shadow symbols below express exactly that mapping.
*/

	.globl	_start
_start:
	moveq	#-1,d0
	rts

/* -------- RomTag ------------------------------------------------- */
	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endmodule
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0x82			/* priority		    */
	.long	_libname
	.long	_idstr
	.long	_inittab

/* -------- InitTable ---------------------------------------------- */
_inittab:
	.long	0x00000386		/* dataSize		    */
	.long	_functab
	.long	_datatab
	.long	_LibInit

_functab:
	.word	0xffff			/* word-offset mode	    */
	.word	_LibOpen - _functab	/* -6			   */
	.word	_LibClose - _functab	/* -12			   */
	.word	_LibExpunge - _functab	/* -18			   */
	.word	_LibNull - _functab	/* -24			   */
	.word	_SNAdd1 - _functab	/* -30			   */
	.word	_SNRem1 - _functab	/* -36			   */
	.word	_SNAdd2 - _functab	/* -42			   */
	.word	_SNRem2 - _functab	/* -48			   */
	.word	_SNAdd3 - _functab	/* -54			   */
	.word	_SNRem3 - _functab	/* -60			   */
	.word	0xffff

/* -------- datatab ------------------------------------------------- */
	.globl	_datatab
_datatab:
	.byte	0xa0,0x08		/* INITBYTE @8 -> ln_Type   */
	.byte	0x09,0x00		/*  = NT_LIBRARY	    */
	.byte	0x80,0x0a		/* INITLONG @0xa -> ln_Name */
	.long	_libname
	.byte	0xa0,0x0e		/* INITBYTE @0xe -> flags   */
	.byte	0x06,0x00		/*  = 6			    */
	.byte	0x90,0x14		/* INITWORD @0x14 -> ver    */
	.word	0x0001			/*  = 1			    */
	.byte	0x90,0x16		/* INITWORD @0x16 -> rev    */
	.word	0x0002			/*  = 2			    */
	.byte	0x80,0x18		/* INITLONG @0x18 -> IdStr  */
	.long	_idstr
	.byte	0x00			/* terminator		    */

/* -------- strings ------------------------------------------------- */
_libname:
	.ascii	"screennotify.library"
	.byte	0
	.ascii	"$VER: "		/* version cmd cookie	    */
_idstr:
	.ascii	"screennotify.library 1.2 (18.1.2005)"
	.byte	13,10
	.globl	_sn_intu_name
_sn_intu_name:
	.byte	0			/* also idstr terminator    */
	.ascii	"intuition.library"
	.globl	_sn_gfx_name
_sn_gfx_name:
	.byte	0			/* also intu terminator	    */
	.ascii	"graphics.library"
	.byte	0
	.globl	_sn_dos_name
_sn_dos_name:
	.ascii	"dos.library"
	.byte	0

/* =====================================================================
**	worker process code image -- 0x9c bytes, copied by LibInit
**	into an AllocVec buffer and run via CreateNewProcTagList.
**
**	Handshakes with the library over pr_MsgPort, creates its own
**	port (returned as the library's "worker context"), then waits
**	for messages.  Each message -> Delay(10) -> broadcast a
**	type-3/arg-1 event on list block 3 through the library-base
**	copy of the walker at lib+548.  A bare signal -> suicide:
**	DeleteMsgPort + FreeVec(own image).
** ===================================================================== */

	.globl	_sn_worker_img
_sn_worker_img:
wstart:
	moveal	0x4,a6			/* ExecBase		    */
	subal	a1,a1
	jsr	a6@(-294)		/* FindTask(NULL)	    */
	moveal	d0,a0
	lea	a0@(92),a2		/* &pr->pr_MsgPort	    */
	moveal	a2,a0
wwait:
	jsr	a6@(-384)		/* WaitPort		    */
	bsrs	wgetmsg			/* a3 = msg		    */
	moveal	a3@(20),a5		/* body[0] = lib base	    */
	jsr	a6@(-666)		/* CreateMsgPort	    */
	movel	d0,a3@(20)		/* reply body = our port    */
	beqs	wfail
	moveal	d0,a2
	moveq	#1,d2
	moveb	a2@(15),d0		/* mp_SigBit		    */
	lsll	d0,d2			/* d2 = wait mask	    */
	moveal	a3,a1
	jsr	a6@(-378)		/* ReplyMsg(handshake)	    */
wloop:
	bsrs	wwaitmsg		/* Wait + GetMsg	    */
	beqs	wdie
	moveal	a5@(52),a6		/* dos base		    */
	moveq	#10,d1
	jsr	a6@(-198)		/* Delay(10)		    */
	moveal	a5@(40),a6		/* exec base		    */
	tstb	a5@(34)			/* wb-open flag		    */
	bnes	wloop
	moveq	#3,d0			/* type 3		    */
	lea	a5@(332),a0		/* list block 3	    */
	moveaw	#1,a1			/* arg 1		    */
	pea	wloop(pc)
	jmp	a5@(548)		/* lib+548 = walker copy    */
wdie:
	moveal	a2,a0
	jsr	a6@(-672)		/* DeleteMsgPort	    */
	lea	wstart(pc),a1
	jmp	a6@(-690)		/* FreeVec(own image)	    */
wfail:
	moveal	a3,a1
	jmp	a6@(-378)		/* ReplyMsg, proc exits	    */
wwaitmsg:
	movel	d2,d0
	jsr	a6@(-318)		/* Wait(mask)		    */
wgetmsg:
	moveal	a2,a0
	jsr	a6@(-372)		/* GetMsg		    */
	tstl	d0
	beqs	wgot
	moveal	d0,a3
wgot:
	rts
	.ascii	"scn service process"	/* at image+136	    */
	.byte	0
	.even

/* =====================================================================
**	intuition patch image -- 0x1b0 bytes, copied to lib+470.
**
**	Entries (offsets in library base):
**	  +470  OpenScreenTagList hook  (intuition -612)
**	  +528  CloseScreen hook	     (intuition -66)
**	  +548  synchronous broadcast walker
**	  +688  PubScreenStatus hook    (intuition -552)
**	  +836  CloseWorkBench hook     (intuition -78)
**	  +892  next-node helper
**
**	Shadow symbols: a PC-relative ref whose target is written as
**	xNN lands, inside the library base, at offset NN.
** ===================================================================== */

	.globl	_sn_patch_img
_sn_patch_img:
pstart:

/* shadow symbols -> library base offsets when executed from the copy */
	.set	x34,  pstart + 34  - 470	/* flag		    */
	.set	x40,  pstart + 40  - 470	/* exec base	    */
	.set	x56,  pstart + 56  - 470	/* handshake msg	    */
	.set	x84,  pstart + 84  - 470	/* worker port	    */
	.set	x88,  pstart + 88  - 470	/* block 1	    */
	.set	x210, pstart + 210 - 470	/* block 2	    */
	.set	x332, pstart + 332 - 470	/* block 3	    */
	.set	x454, pstart + 454 - 470	/* old OpenScreenTagList */
	.set	x458, pstart + 458 - 470	/* old CloseScreen	    */
	.set	x462, pstart + 462 - 470	/* old CloseWorkBench    */
	.set	x466, pstart + 466 - 470	/* old PubScreenStatus   */

/* -------- OpenScreenTagList patch --------------------------------- */
ph_ostl:
	movel	a2,sp@-
	moveal	x454(pc),a2		/* original vector	    */
	jsr	a2@
	tstl	d0
	beqs	ph_done
	moveal	d0,a2			/* a2 = new screen	    */
	movew	a2@(20),d1		/* sc_Flags		    */
	andiw	#0x000f,d1
	subqw	#1,d1			/* == WBENCHSCREEN ?	    */
	bnes	ph_done
	movel	a6,sp@-
	moveal	x40(pc),a6		/* exec			    */
	moveal	x84(pc),a0		/* worker port	    */
	lea	x56(pc),a1		/* handshake msg	    */
	jsr	a6@(-366)		/* PutMsg		    */
	moveal	sp@+,a6
	movel	a2,d0			/* return screen	    */
	lea	x34(pc),a2
	clrb	a2@			/* flag = wb open    */
ph_done:
	moveal	sp@+,a2
	rts

/* -------- CloseScreen patch ---------------------------------------- */
ph_cs:
	movel	a0,sp@-			/* save screen	    */
	moveal	a0,a1
	lea	x88(pc),a0		/* block 1		    */
	moveq	#0,d0			/* type 0		    */
	bsrs	walker
	moveal	x458(pc),a1		/* original vector	    */
	moveal	sp@+,a0
	jmp	a1@

/* -------- walker: synchronous broadcast over a client list ---------
**	in: a0 = list block, d0 = type, a1 = arg
**	obtains the block semaphore, fills body {type,arg}, then for
**	each client node (skip self-task, skip arg mismatch when
**	type 0): PutMsg + WaitPort + GetMsg handshake.
** ----------------------------------------------------------------- */
walker:
	moveml	d4-d7/a2-a3/a6,sp@-
	movel	d0,d7			/* type			    */
	moveal	a0,a2			/* block		    */
	movel	a1,d4			/* arg			    */
	moveal	x40(pc),a6		/* exec			    */
	lea	a2@(88),a3		/* embedded port	    */
	lea	a2@(60),a1		/* embedded msg	    */
	movel	a1,d6
	lea	a2@(14),a0		/* semaphore		    */
	movel	a0,d5
	jsr	a6@(-564)		/* ObtainSemaphore	    */
	moveb	#0x08,a3@(15)		/* port.mp_SigBit = 8	    */
	subal	a1,a1
	jsr	a6@(-294)		/* FindTask(NULL)	    */
	movel	d0,a3@(16)		/* port.mp_SigTask	    */
	moveal	d6,a0
	movel	d7,a0@(20)		/* body[0] = type	    */
	movel	d4,a0@(24)		/* body[1] = arg	    */
	moveal	a2,a0
	bsrw	nextnode		/* first node		    */
	moveal	d0,a2
	bras	wn_loop
wn_chk:
	tstl	d7
	bnes	wn_send			/* type != 0 -> always	    */
	movel	a2@(14),d0
	beqs	wn_send			/* arg == 0 -> always	    */
	cmpl	d4,d0
	bnes	wn_next			/* arg filter mismatch	    */
wn_send:
	moveal	a2@(10),a0		/* client port (ln_Name)    */
	movel	a3@(16),d0
	cmpl	a0@(16),d0		/* same task?		    */
	beqs	wn_next
	moveal	d6,a1
	jsr	a6@(-366)		/* PutMsg		    */
	moveal	a3,a0
	jsr	a6@(-384)		/* WaitPort		    */
	moveal	a3,a0
	jsr	a6@(-372)		/* GetMsg		    */
wn_next:
	moveal	a2,a0
	bsrw	nextnode
	moveal	d0,a2
wn_loop:
	movel	a2,d0
	bnes	wn_chk
	moveal	d5,a0
	jsr	a6@(-570)		/* ReleaseSemaphore	    */
	moveml	sp@+,d4-d7/a2-a3/a6
	rts

/* -------- PubScreenStatus patch ------------------------------------
**	a0 = screen, d0 = requested flags (a6 = intuition base)
** ----------------------------------------------------------------- */
ph_pss:
	moveml	d5-d7/a2-a3,sp@-
	moveal	a0,a3			/* screen		    */
	movel	d0,d7			/* requested status	    */
	subal	a2,a2
	jsr	a6@(-522)		/* LockPubScreenList	    */
	movel	d0,d5
	beqs	pp_call
	moveal	d5,a0
	bsrw	nextnode		/* first PubScreenNode	    */
	moveal	d0,a2
	bras	pp_scan
pp_next:
	moveal	a2,a0
	bsrw	nextnode
	moveal	d0,a2
pp_scan:
	movel	a2,d0
	beqs	pp_found
	cmpal	a2@(14),a3		/* psn+14 == screen?	    */
	bnes	pp_next
pp_found:
	jsr	a6@(-528)		/* UnlockPubScreenList	    */
	movel	a2,d0
	beqs	pp_call			/* not a pub screen	    */
	moveq	#1,d0
	andl	d7,d0
	moveq	#1,d1
	cmpl	d0,d1
	bnes	pp_call			/* only when bit0 set	    */
	lea	x210(pc),a0		/* block 2		    */
	moveq	#2,d0			/* type 2		    */
	moveal	a2,a1			/* arg = pubscreen node	    */
	bsrw	walker
pp_call:
	moveal	a3,a0
	movel	d7,d0
	moveal	x466(pc),a1		/* original vector	    */
	jsr	a1@
	movel	d0,d6			/* d6 = result		    */
	movel	a2,d0
	beqs	pp_ret
	moveq	#1,d0
	andl	d7,d0
	tstl	d0
	bnes	pp_p1			/* bit0 requested	    */
	moveq	#1,d0
	andl	d6,d0
	moveq	#1,d1
	cmpl	d0,d1
	beqs	pp_notify		/* result bit0 -> notify	    */
pp_p1:
	moveq	#1,d0
	andl	d7,d0
	moveq	#1,d1
	cmpl	d0,d1
	bnes	pp_ret
	moveq	#1,d0
	andl	d6,d0
	tstl	d0
	bnes	pp_ret			/* result bit0 -> skip	    */
pp_notify:
	lea	x210(pc),a0		/* block 2		    */
	moveq	#1,d0			/* type 1		    */
	moveal	a2,a1
	bsrw	walker
pp_ret:
	movel	d6,d0
	moveml	sp@+,d5-d7/a2-a3
	rts

/* -------- CloseWorkBench patch ------------------------------------- */
ph_cwb:
	movel	d7,sp@-
	moveq	#3,d0			/* type 3		    */
	moveb	x34(pc),d1		/* flag			    */
	bnes	cw_skip			/* already closed	    */
	lea	x332(pc),a0		/* block 3		    */
	subal	a1,a1			/* arg 0		    */
	bsrw	walker
cw_skip:
	moveal	x462(pc),a1		/* original vector	    */
	jsr	a1@
	movel	d0,d7
	lea	x34(pc),a0
	sne	a0@			/* flag = (ret != 0)	    */
	bnes	cw_ret			/* close ok -> done	    */
	moveq	#3,d0			/* close failed: type 3    */
	lea	x332(pc),a0
	moveaw	#1,a1			/* arg 1		    */
	bsrw	walker
	movel	d7,d0
cw_ret:
	movel	sp@+,d7
	rts

/* -------- next-node iterator (list walk) --------------------------- */
nextnode:
	moveal	a0@,a0			/* ln_Succ		    */
	movel	a0@,d0
	beqs	nn_end
	movel	a0,d0
nn_end:
	rts
