/*
** dsp3210.library 2.1 (4.3.2021)
**
** Reconstruction skeleton.  Manual-init (non-AUTOINIT) library:
** rt_Init points at code that runs MakeLibrary + AddLibrary itself.
** Implements an AT&T DSP3210 big-endian COFF loader/relocator:
**
**   -30  dsp_objsize  (C)  validate image, return load bytes
**   -36  dsp_loadimg  (asm verbatim) copy sections + apply relocs
**   -42  dsp_loadfile (C)  file -> memory -> descriptor -> loaded image
**   -48  dsp_unload   (C)  free a descriptor from dsp_loadfile
**
** The -36 reloc engine is transcribed verbatim: it reads an external
** symbol table out of the caller's stack frame (entry+12) which cannot
** be expressed in C, and its reloc-type dispatch must be bit-exact.
*/

	.text
	.even

/* ---- hunk+0x00: stub before RomTag -------------------------------- */
	moveq	#0,d0				/* 0x00 */
	rts					/* 0x02 */

/* ---- hunk+0x04: Resident tag (non-AUTOINIT) ------------------------ */
	.globl	_RomTag
_RomTag:
	.word	0x4afc
	.long	_RomTag				/* matchtag  */
	.long	_dsp_end			/* endskip   */
	.byte	0,2				/* flags, ver 2 */
	.byte	9,0				/* NT_LIBRARY, pri 0 */
	.long	_dsp_name			/* -> 0x1e */
	.long	_dsp_idstr			/* -> 0x34 */
	.long	_dsp_initcode			/* -> 0x64 */

/* ---- hunk+0x1e: strings ------------------------------------------- */
_dsp_name:					/* 0x1e */
	.ascii	"dsp3210.library"
	.byte	0
	.ascii	"$VER: "			/* 0x2e: $VER token */
_dsp_idstr:					/* 0x34 (points inside) */
	.ascii	"dsp3210.library 2.1 (4.3.2021)"
	.byte	13,10,0
	.byte	0				/* pad @0x55 */
	.globl	_dsp_dosname
_dsp_dosname:					/* 0x56 */
	.ascii	"dos.library"
	.byte	0
	.word	0				/* pad to 0x64 */

/* ---- hunk+0x64: rt_Init — manual MakeLibrary + AddLibrary ---------- */
/* called by InitResident with a0 = seglist                            */
_dsp_initcode:					/* 0x64 */
	moveml	d1-d7/a1-a6,sp@-
	moveal	0x4,a6
	movel	a0,d1				/* seglist */
	lea	_dsp_functab(pc),a0
	subal	a1,a1				/* no structInit */
	lea	_dsp_libinit(pc),a2
	moveq	#46,d0				/* datasize */
	jsr	a6@(-84)			/* MakeLibrary */
	tstl	d0
	beqs	1f
	moveal	d0,a1
	jsr	a6@(-396)			/* AddLibrary */
	moveq	#1,d0
1:	moveml	sp@+,d1-d7/a1-a6
	rts

/* ---- hunk+0x90: libInit (MakeLibrary libInit routine) -------------- */
/* d0 = new base, a0 = seglist                                         */
_dsp_libinit:					/* 0x90 */
	moveml	a1,sp@-
	moveal	a0,a1				/* seglist */
	moveal	d0,a0				/* base */
	movel	a1,a0@(34)			/* base->seglist */
	moveb	#9,a0@(8)			/* ln_Type = NT_LIBRARY */
	lea	_dsp_name(pc),a1
	movel	a1,a0@(10)			/* ln_Name */
	movew	#2,a0@(20)			/* lib_Version */
	movew	#1,a0@(22)			/* lib_Revision */
	lea	_dsp_idstr(pc),a1
	movel	a1,a0@(24)			/* lib_IdString */
	clrw	a0@(32)				/* lib_OpenCnt */
	movel	d0,d0
	moveml	sp@+,a1
	rts

/* ---- -6: LibOpen --------------------------------------------------- */
	.globl	_LibOpen
_LibOpen:					/* 0xca */
	moveq	#0,d0
	movel	a6,d0				/* return base */
	addqw	#1,a6@(32)			/* OpenCnt++ */
	bclr	#3,a6@(14)			/* clear LIBF_DELEXP */
	rts

/* ---- -12: LibClose ------------------------------------------------- */
	.globl	_LibClose
_LibClose:					/* 0xda */
	moveq	#0,d0
	tstw	a6@(32)
	beqs	1f
	subqw	#1,a6@(32)			/* OpenCnt-- */
	bnes	1f
	btst	#3,a6@(14)			/* LIBF_DELEXP? */
	beqs	1f
	bsrs	_LibExpunge
1:	rts

/* ---- -18: LibExpunge ------------------------------------------------ */
	.globl	_LibExpunge
_LibExpunge:					/* 0xf4 */
	moveq	#0,d0
	moveml	d2/a5-a6,sp@-
	bsrw	_dsp_closedos			/* close dosbase if open */
	moveal	a6,a5
	moveal	0x4,a6
	tstw	a5@(32)				/* OpenCnt */
	beqs	2f
	bset	#3,a5@(14)			/* in use: mark DELEXP */
	bras	3f
2:	movel	a5@(34),d2			/* seglist -> d0 */
	moveal	a5,a1
	jsr	a6@(-252)			/* Remove */
	moveal	a5,a1
	moveq	#0,d0
	movew	a5@(16),d0			/* lib_NegSize */
	subal	d0,a1
	addw	a5@(18),d0			/* + lib_PosSize */
	jsr	a6@(-210)			/* FreeMem */
	movel	d2,d0
3:	moveml	sp@+,d2/a5-a6
	rts

/* ---- -24: reserved stub -------------------------------------------- */
	.globl	_dsp_ret0
_dsp_ret0:					/* 0x136 */
	moveq	#0,d0
	rts

/* ---- hunk+0x13a: function table (absolute-long form) ---------------- */
	.globl	_dsp_functab
_dsp_functab:
	.long	_LibOpen			/* -6  */
	.long	_LibClose			/* -12 */
	.long	_LibExpunge			/* -18 */
	.long	_dsp_ret0			/* -24 */
	.long	_dsp_objsize			/* -30 (C) */
	.long	_dsp_loadimg			/* -36 (asm below) */
	.long	_dsp_loadfile			/* -42 (C) */
	.long	_dsp_unload			/* -48 (C) */
	.long	-1

/* ---- helpers (verbatim) --------------------------------------------- */
/* _dsp_rdlong: read big-endian long at a2 into d7 (a2 preserved)       */
	.globl	_dsp_rdlong
_dsp_rdlong:
	movel	a2,sp@-
	moveb	a2@+,d7
	lslw	#8,d7
	moveb	a2@+,d7
	swap	d7
	moveb	a2@+,d7
	lslw	#8,d7
	moveb	a2@+,d7
	moveal	sp@+,a2
	rts

/* _dsp_rdword: read big-endian word at a2 into d7 (a2 preserved)       */
	.globl	_dsp_rdword
_dsp_rdword:
	movel	a2,sp@-
	moveq	#0,d7
	moveb	a2@+,d7
	lslw	#8,d7
	moveb	a2@+,d7
	moveal	sp@+,a2
	rts

/* ---- -36: _dsp_loadimg (verbatim transcribe) ------------------------- */
/* a0 = COFF image, a1 = dest, a2 = saved to dead local, d0 = img len   */
/* stack: entry+12 = external symbol table {name,value} pairs (8B),    */
/*        NULL-name terminated; resolves UNDEF (n_scnum==0) symbols.    */
/* returns d0 = 0 or <0 error (-1 bad img, -3 alloc, -10 r_type,        */
/* -20 scnum<0, -21 undef w/o table, -30 16-bit overflow)               */
	.globl	_dsp_loadimg
_dsp_loadimg:					/* 0x1fa */
	subqw	#8,sp
	moveml	d2-d7/a2-a6,sp@-
	cmpiw	#0x166,a0@			/* f_magic */
	bnew	img_bad1
	movel	a0@(12),d2			/* f_nsyms */
	muluw	#18,d2
	addl	a0@(8),d2			/* + f_symptr = symtab end */
	cmpl	d0,d2
	bhiw	img_bad1
	movel	a2,sp@(48)
	moveal	a0,a5				/* a5 = image */
	moveal	a1,a4				/* a4 = dest cursor */
	moveq	#0,d6
	movew	a0@(2),d6			/* f_nscns */
	beqw	img_bad1
	movel	d6,d0
	addl	d0,d0
	addl	d0,d0				/* nscns*4 */
	movel	d0,sp@(44)
	movel	#0x10001,d1			/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	0x4,a6
	jsr	a6@(-198)			/* AllocMem */
	tstl	d0
	beqw	img_bad3
	moveal	d0,a6				/* a6 = section desc[] */
	movew	a5@(16),d0			/* f_opthdr */
	lea	a5@(20,d0:w),a3			/* a3 = section table */
	moveml	d6/a3-a4/a6,sp@-
/* pass 1: record load addrs, copy section data */
1:	movel	a4,a6@+				/* desc[i] = dest */
	moveal	a4,a1
	lea	a3@(20),a2			/* s_scnptr */
	bsrw	_dsp_rdlong
	moveal	a5,a0
	addal	d7,a0				/* src = img+scnptr */
	lea	a3@(16),a2			/* s_size */
	bsrw	_dsp_rdlong
	movel	d7,d0
	beqs	2f				/* size 0: no data */
	addql	#3,d7
	andiw	#-4,d7
	addal	d7,a4				/* dest += aligned size */
3:	moveb	a0@+,a1@+
	subql	#1,d0
	bnes	3b
2:	lea	a3@(40),a3
	subql	#1,d6
	bnes	1b
	moveml	sp@+,d6/a3-a4/a6
/* pass 2: relocations */
	moveml	d6/a4/a6,sp@-
	moveal	a6,a4
4:	moveal	a4@,a0				/* a0 = desc[0] = img base */
	btst	#2,a5@(19)			/* f_flags F_EXEC bit */
	beqs	5f
	addql	#4,a0
5:	lea	a3@(30),a2			/* scn+30: nreloc (lnno==0) */
	bsrw	_dsp_rdlong
	movel	d7,d5				/* d5 = nreloc */
	beqw	9f
	lea	a3@(24),a2			/* s_relptr */
	bsrw	_dsp_rdlong
	tstl	d7
	beqw	9f
	moveal	a5,a1
	addal	d7,a1				/* a1 = reloc table */
	moveml	a3,sp@-
	moveal	a5@(8),a3			/* f_symptr */
	addal	a5,a3				/* a3 = symtab */
/* per-reloc loop */
6:	moveal	a1,a2
	bsrw	_dsp_rdlong			/* d7 = r_vaddr */
	movel	d7,d3				/* d3 = r_vaddr */
	lea	a1@(4),a2			/* r_symndx */
	bsrw	_dsp_rdlong
	muluw	#18,d7
	moveal	a3,a2
	addal	d7,a2				/* a2 = symtab + ndx*18 */
	movel	a2,sp@-
	lea	a2@(8),a2			/* n_value */
	bsrw	_dsp_rdlong
	movel	d7,d4				/* d4 = n_value */
	moveal	sp@+,a2
	movel	a2,sp@-
	lea	a2@(12),a2			/* n_scnum */
	bsrw	_dsp_rdword
	moveal	sp@+,a2
	tstw	d7
	beqw	20f				/* UNDEF: resolve by name */
	bmiw	img_bad20
	bras	8f
/* UNDEF: find symbol name, walk exttab */
20:	moveml	d0-d2/a0-a2,sp@-
	tstb	a2@				/* n_name[0]? inline name */
	bnes	21f
	lea	a2@(6),a2			/* n_offset low word */
	bsrw	_dsp_rdword
	moveal	a5,a2
	movel	a5@(12),d0			/* f_nsyms */
	muluw	#18,d0
	addl	a5@(8),d0			/* symtab end = strtab */
	addal	d0,a2
	addal	d7,a2				/* a2 = string name */
21:	movel	sp@(88),d0			/* exttab (caller frame) */
	beqs	23f
	moveal	d0,a0
22:	movel	a0@,d0				/* entry.name */
	beqs	23f
	moveal	d0,a1
	bsrw	_dsp_cmpstr			/* a1 vs a2 */
	lea	a0@(8),a0
	bnes	22b
	movel	a0@(-4),d4			/* d4 = entry.value */
	moveml	sp@+,d0-d2/a0-a2
	bras	10f
23:	moveal	a2,a3				/* not found -> -21 */
	moveml	sp@+,d0-d2/a0-a2
	moveal	a3,a2
	braw	img_bad21
/* defined symbol: d4 = host addr of sym value */
8:	subql	#1,d7				/* scnum-1 */
	moveml	d7,sp@-
	movew	a5@(16),d0
	lea	a5@(20,d0:w),a2			/* section table */
	muluw	#40,d7
	lea	a2@(12,d7:w),a2			/* scn[scnum-1].s_vaddr */
	bsrw	_dsp_rdlong
	subl	d7,d4				/* d4 = offset in section */
	moveml	sp@+,d7			/* scnum-1 */
	addl	d7,d7
	addl	d7,d7				/* *4 */
	addl	a6@(0,d7:w),d4			/* d4 += desc[scnum-1] */
10:	lea	a1@(8),a2			/* r_type */
	bsrw	_dsp_rdword
	cmpiw	#44,d7
	beqs	11f
	cmpiw	#46,d7
	beqs	12f
	cmpiw	#47,d7
	beqs	13f
	cmpiw	#28,d7
	beqs	14f
	cmpiw	#34,d7
	beqs	14f
	cmpiw	#35,d7
	beqs	14f
	braw	img_bad10
11:	moveq	#0,d1				/* 32-bit store */
	movel	a0,sp@-
	addal	d3,a0
	movel	d4,a0@
	moveal	sp@+,a0
	bras	15f
12:	moveq	#0,d1				/* 16-bit lo @ +2 */
	movel	a0,sp@-
	addql	#2,d3
	addal	d3,a0
	movew	d4,a0@
	moveal	sp@+,a0
	bras	15f
13:	moveq	#0,d1				/* 16-bit hi @ +2 */
	movel	a0,sp@-
	addql	#2,d3
	addal	d3,a0
	swap	d4
	movew	d4,a0@
	moveal	sp@+,a0
	bras	15f
14:	moveq	#0,d1				/* 16-bit @ +2, overflow chk */
	movel	a0,sp@-
	addql	#2,d3
	addal	d3,a0
	movew	d4,a0@
	moveal	sp@+,a0
	andil	#-65536,d4
	bnew	img_bad30
	bras	15f
	nop
15:	lea	a1@(10),a1			/* next reloc (10B) */
	subql	#1,d5
	bnew	6b
	moveml	sp@+,a3
9:	lea	a3@(40),a3			/* next section */
	subql	#1,d6
	bnew	4b
	moveml	sp@+,d6/a4/a6
	moveq	#0,d0
16:	movel	d0,d2
	movel	sp@(44),d0			/* nscns*4 */
	moveal	a6,a1
	moveal	0x4,a6
	jsr	a6@(-210)			/* FreeMem desc[] */
	movel	d2,d0
	moveal	a2,a0
17:	moveml	sp@+,d2-d7/a2-a6
	addqw	#8,sp
	rts
img_bad1:
	moveq	#-1,d0
	bras	17b
img_bad2:
	moveq	#-2,d0
	bras	17b				/* dead: nothing branches here */
img_bad3:
	moveq	#-3,d0
	bras	17b
img_clean:					/* pop inner saves, free desc */
	moveml	sp@+,a3
	moveml	sp@+,d6/a4/a6
	bras	16b
img_bad10:
	moveq	#-10,d0
	bras	img_clean
img_bad20:
	moveq	#-20,d0
	bras	img_clean
img_bad21:
	moveq	#-21,d0
	bras	img_clean
img_bad30:
	moveq	#-30,d0
	bras	img_clean

/* _dsp_cmpstr: compare a1 vs a2, Z = equal */
_dsp_cmpstr:
	moveml	a1-a2,sp@-
1:	tstb	a2@
	beqs	2f
	cmpmb	a1@+,a2@+
	beqs	1b
	bras	3f
2:	tstb	a1@
3:	moveml	sp@+,a1-a2
	rts

/* ---- -42/-48 helper: lazy dos.library open -------------------------- */
/* a6 = base.  if base+42 == 0: base+42 = OpenLibrary("dos.library",36) */
	.globl	_dsp_opendos
_dsp_opendos:
	tstl	a6@(42)
	bnes	1f
	movel	a6,sp@-
	moveal	0x4,a6
	moveq	#36,d0
	lea	_dsp_dosname(pc),a1
	jsr	a6@(-552)			/* OpenLibrary */
	moveal	sp@+,a6
	movel	d0,a6@(42)
1:	rts

/* ---- expunge helper: close dosbase ---------------------------------- */
_dsp_closedos:
	movel	a6@(42),d0
	beqs	1f
	movel	a6,sp@-
	moveal	d0,a1
	moveal	0x4,a6
	jsr	a6@(-414)			/* CloseLibrary */
	moveal	sp@+,a6
	clrl	a6@(42)
1:	rts

	.globl	_dsp_end
_dsp_end:
	.end
