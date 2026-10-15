| mathffp_36.5.library — reconstructed skeleton
| Original: Commodore C= FFP math library (Motorola MC68343 FP firmware),
| single code hunk + data hunks, packed RomTag, word-offset functab.
|
| Vector map (word offsets from _functab, leading -1 marks offset-format):
|   -6 Open  -12 Close  -18 Expunge  -24 ExtFunc(rts)
|   -30 SPFix -36 SPFlt -42 SPCmp -48 SPTst -54 SPAbs -60 SPNeg
|   -66 SPAdd -72 SPSub -78 SPMul -84 SPDiv -90 SPFloor -96 SPCeil

	.text
	.globl	_start
_start:
| packed RomTag (26 bytes, no pad word)
	.word	0x4afc			| RT_MATCHWORD
	.long	_start			| rt_MatchTag (reloc → self)
	.long	_endmodule		| rt_EndSkip → end of code
	.byte	0x80, 36, 9, 0		| RTF_AUTOINIT, ver 36, NT_LIBRARY, pri 0
	.long	_name			| rt_Name
	.long	_idstr			| rt_IdString
	.long	_inittab		| rt_Init

_name:	.asciz	"mathffp.library"
_idstr:	.asciz	"mathffp 36.5 (6 Jul 1989)\r\n"	| rt_IdString
_inittab:
	.long	0x22			| dataSize = sizeof(struct Library)
	.long	_functab		| word-offset function table
	.long	_datatab		| InitStruct data
	.long	_initfn			| InitFunction (rts)
_idstr2: .asciz	"mathffp 36.5 (6 Jul 1989)\r\n"	| lib_IdString (datatab target)

| InitStruct stream: 0x80xx=LONG, 0x90xx=WORD, 0xa0xx=BYTE at offset xx
_datatab:
	.word	0xa008, 0x0900		| ln_Type @8  = NT_LIBRARY
	.word	0x800a			| ln_Name @10 (LONG → reloc)
	.long	_name
	.word	0xa00e, 0x0600		| lib_Flags @14 = LIBF_SUMUSED|LIBF_CHANGED
	.word	0x9014, 0x0024		| lib_Version @20 = 36
	.word	0x9016, 0x0005		| lib_Revision @22 = 5  (hence "36.5")
	.word	0x8018			| lib_IdString @24 (LONG → reloc)
	.long	_idstr2
	.word	0x0000			| end

	.globl	_initfn
_initfn:
	rts				| no per-base init

| --- lifecycle (transcribed verbatim) -----------------------------------
| LVO -18  Expunge: if opencnt -> set DELEXP, ret 0.  Else unlink node,
| FreeMem(base-negsize, negsize+possize).  (No seglist returned: quirk
| of the ROM-era original.)
	.globl	_LibExpunge
_LibExpunge:
	tst.w	32(a6)			| lib_OpenCnt
	bnes	1f
	moveal	a6,a1
	moveal	(a1),a0			| ln_Succ
	moveal	4(a1),a1		| ln_Pred
	move.l	a0,(a1)
	move.l	a1,4(a0)
	moveal	a6,a1
	moveq	#0,d0
	move.w	16(a6),d0		| lib_NegSize
	suba.w	d0,a1
	add.w	18(a6),d0		| + lib_PosSize
	move.l	a6,-(sp)
	moveal	4,a6
	jsr	a6@(-210)		| FreeMem
	moveal	(sp)+,a6
	moveq	#0,d0
	rts
1:	bset	#3,14(a6)		| LIBF_DELEXP
	moveq	#0,d0
	rts

| LVO -6   Open: DELEXP set -> -1; else opencnt++, return base
	.globl	_LibOpen
_LibOpen:
	btst	#3,14(a6)
	bnes	2f
	addq.w	#1,32(a6)
	move.l	a6,d0
	rts
2:	moveq	#-1,d0
	rts

| LVO -12  Close: opencnt--; if zero ret 0 (NO auto-expunge — quirk);
| if nonzero and DELEXP, expunge attempt (Expunge re-sets flag). 
	.globl	_LibClose
_LibClose:
	subq.w	#1,32(a6)
	beqs	3f
	btst	#3,14(a6)
	beqs	3f
	bsrs	_LibExpunge
3:	moveq	#0,d0
	rts

	.word	-1			| terminator

| Motorola firmware copyright banner (was hunk1 in the original)
	.globl	_motcr
| Original hunk1 held a Motorola firmware copyright notice; the verbatim
| text is intentionally not committed (see okf/index.md).  Kept same length.
_motcr:	.asciz	"MC68343-DERIVED FFP FIRMWARE - ORIGINAL NOTICE NOT REPRODUCED ."

