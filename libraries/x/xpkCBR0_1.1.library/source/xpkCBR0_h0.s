|||
|||	xpkCBR0_h0.s -- byte-verbatim reconstruction of
|||	xpkCBR0.library v1.1 (ByteRun0 RLE XPK sublibrary).
|||
|||	Single CODE hunk (0x358 bytes), AUTOINIT, word-offset
|||	function table (10 vectors, signed offsets relative to the
|||	table base), 24-bit... no, 8-bit-offset InitStruct datatab,
|||	name/idstr/XpkInfo string island mid-hunk, then the code.
|||	The RELOC32 tail lists its 10 sites in DESCENDING order;
|||	source/fixup.py reorders the linked tail to match.
|||
|||	Quirks: -36 is Pack and -54 is Unpack (-42/-48/-60 are the
|||	shared moveq#0 stub); XpkInfo@-30 returns a pointer to an
|||	in-base struct built by initfn at lib+0x28 (with a mode
|||	block at lib+0x80); initfn also stores the seglist at
|||	lib+0x24; expunge uses the bit-3 private flag at lib+0xe and
|||	reads SysBase absolutely via 0x4.
|||

	.section .text

||| executable-entry stub: non-resident loaders get -1
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP (module end)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION = 1
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI = 0
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0xaa			| sizeof(struct CBR0Base)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| InitStruct datatab: 8-bit-offset commands
||| (0x80 long / 0x90 word / 0xa0 byte), word-aligned.
_datatab:
	.byte	0xa0,0x08,0x09		| INITBYTE @8  ln_Type = 9
	.byte	0x00			| pad
	.byte	0x80,0x0a		| INITLONG @10 ln_Name
	.long	_libname
	.byte	0xa0,0x0e,0x06		| INITBYTE @14 lib_Flags = 6
	.byte	0x00			| pad
	.byte	0x90,0x14		| INITWORD @20 lib_Version
	.word	1
	.byte	0x90,0x16		| INITWORD @22 lib_Revision
	.word	1
	.byte	0x80,0x18		| INITLONG @24 lib_IdString
	.long	_idstr
	.long	0			| terminator

_libname:
	.ascii	"xpkCBR0.library"
	.byte	0
_idstr:
	.ascii	"xpkCBR0 v1.1"
	.byte	0xd,0xa,0
_xpi_name:
	.ascii	"CBR0"
	.byte	0
_xpi_long:
	.ascii	"Cmp Byte Run 0 Packer v1.1"
	.byte	0
_xpi_desc:
	.ascii	"fast and simple compression of data containing many repeating equal bytes"
	.byte	0
_xpi_cing:
	.ascii	"Compressing"
	.byte	0
_xpi_ding:
	.ascii	"Decompressing"
	.byte	0
_xpi_ced:
	.ascii	"Compressed"
	.byte	0
_xpi_ded:
	.ascii	"Decompressed"
	.byte	0
	.byte	0			| pad to even

||| word-offset function table (signed, relative to _functab);
||| bracketed by -1 markers (0xffff ... 0xffff).
_functab:
	.word	-1			| table marker
	.word	_LibOpen-_functab	| LVO  -6
	.word	_LibClose-_functab	| LVO -12
	.word	_LibExpunge-_functab	| LVO -18
	.word	_stub0-_functab		| LVO -24 (moveq #0; rts)
	.word	_XpkInfo-_functab	| LVO -30
	.word	_XpkPack-_functab	| LVO -36
	.word	_stubrts-_functab	| LVO -42
	.word	_stubrts-_functab	| LVO -48
	.word	_XpkUnpack-_functab	| LVO -54
	.word	_stubrts-_functab	| LVO -60
	.word	-1

||| LibInit: seglist->+0x24, then fill the mode block at +0x80
||| and the XpkInfo struct at +0x28.
_LibInit:
	moveal	d0,a1
	movel	a0,a1@(36)		| seglist
	lea	a1@(128),a1		| mode block @ +0x80
	clrl	a1@+
	movel	#100,a1@+
	movel	#1,a1@+
	clrl	a1@+
	clrl	a1@+
	movel	#410,a1@+
	movel	#1918,a1@+
	movel	#0x1f003f,a1@+
	movel	#0x6e6f726d,a1@+	| 'norm'
	movel	#0x616c0000,a1@		| 'al\0\0'
	moveal	d0,a1
	lea	a1@(40),a1		| XpkInfo @ +0x28
	movel	#0x10001,a1@+		| version=1 rev=1
	movel	#0x10000,a1@+
	lea	_xpi_name,a0
	movel	a0,a1@+
	lea	_xpi_long,a0
	movel	a0,a1@+
	lea	_xpi_desc,a0
	movel	a0,a1@+
	movel	#0x43425230,a1@+	| 'CBR0'
	movel	#9,a1@+
	movel	#0xfffc,a1@+
	clrl	a1@+
	movel	#0xfffc,a1@+
	lea	_xpi_cing,a0
	movel	a0,a1@+
	lea	_xpi_ding,a0
	movel	a0,a1@+
	lea	_xpi_ced,a0
	movel	a0,a1@+
	lea	_xpi_ded,a0
	movel	a0,a1@+
	moveal	d0,a0
	movel	#0x320000,a1@+
	lea	a0@(128),a0		| mode block ptr
	movel	a0,a1@+
	clrl	a1@+
	clrl	a1@+
	clrl	a1@+
	clrl	a1@+
	clrl	a1@+
	clrl	a1@			| (no a1@+ on the last one)
	rts

||| LVO -6 LibOpen: OpenCnt++, clear flag bit 3, return base.
_LibOpen:
	addqw	#1,a6@(32)
	andib	#-9,a6@(14)
	movel	a6,d0
	rts

||| LVO -12 LibClose: OpenCnt--; at 0 consult flag bit 3.
_LibClose:
	subqw	#1,a6@(32)
	bnes	_stub0
	btst	#3,a6@(14)
	beqs	_stub0

||| LVO -18 LibExpunge: deferred via lib_Flags bit 3; real path
||| Remove()s and FreeMem()s the whole base, returns seglist.
_LibExpunge:
	tstw	a6@(32)
	bnes	_exp_defer
	moveal	a6,a1
	movel	a6@(36),sp@-		| seglist
	movel	a6,sp@-
	moveal	0x4,a6			| absolute SysBase
	jsr	a6@(-252)		| Remove
	moveal	sp@,a0
	moveal	sp@,a1
	moveq	#0,d0
	movew	a0@(16),d0
	subal	d0,a1
	addw	a0@(18),d0
	jsr	a6@(-210)		| FreeMem
	moveal	sp@+,a6
	movel	sp@+,d0
	rts
_exp_defer:
	orib	#8,a6@(14)		| set flag bit 3
_stub0:
	moveq	#0,d0
_stubrts:
	rts

||| LVO -30 XpkInfo: return &lib's in-base XpkInfo struct.
_XpkInfo:
	lea	a6@(40),a0
	movel	a0,d0
	rts

||| LVO -54 XpksUnpackChunk(xsp=a0): ByteRun1 decode.
||| token >0 -> literal run of token+? bytes (token count),
||| token <0 -> repeat run of -token bytes, 0 -> end.
||| No output bound is checked.
_XpkUnpack:
	moveal	a0@+,a1			| xsp_InBuf
	movel	a0@+,d0			| xsp_InLen
	beqs	_unp_empty
	.short	0xb0bc			| cmp.l #0xfffc,d0 (longform)
	.long	0xfffc
	bhis	_unp_toolong
	movel	a1,d1			| inend
	moveml	d2/a2-a3,sp@-
	moveal	a0@+,a2			| xsp_OutBuf
	addl	d0,d1
	lea	a2@(256),a3
	addal	a0@,a3			| bound = OutBuf+256+OutBufLen (+256 slack!)
_unp_loop:
	cmpl	a1,d1
	blss	_unp_done
	moveq	#0,d2
	moveb	a1@+,d2			| token
	bmis	_unp_run
_unp_lit:				| d2 = literal count
	cmpal	a2,a3
	blss	_unp_outfull
	moveb	a1@+,a2@+
	subqw	#1,d2
	bccs	_unp_lit
	bras	_unp_loop
_unp_run:
	moveb	a1@+,d0			| run byte
	negb	d2			| count = -token
_unp_runl:
	cmpal	a2,a3
	blss	_unp_outfull
	moveb	d0,a2@+
	subqw	#1,d2
	bccs	_unp_runl
	bras	_unp_loop
_unp_done:
	subal	a0@-,a2			| a0@- -> +8 (OutBuf): a2 -= OutBuf
	movel	a2,a0@(8)		| -> xsp_OutLen @+16
	moveq	#0,d0
	bras	_unp_ret
_unp_outfull:
	moveq	#-10,d0			| XPKERR_... output full
_unp_ret:
	moveml	sp@+,d2/a2-a3
	rts
_unp_empty:
	clrl	a0@(8)			| OutLen = 0
	moveq	#0,d0
	rts
_unp_toolong:
	moveq	#-11,d0			| input too long
	rts

||| LVO -36 XpksPackChunk(xsp=a0): ByteRun1 encode.
||| Ceiling: inlen must be < 0xfffc; output headroom is the
||| mode-derived cap a4 = OutBuf+256+xsp_OutBufLen... see OKF.
_XpkPack:
	moveal	a0@+,a1			| xsp_InBuf
	movel	a0@+,d0			| xsp_InLen
	beqs	_unp_empty		| shared empty path
	.short	0xb0bc			| cmp.l #0xfffc,d0 (longform)
	.long	0xfffc
	bhis	_unp_toolong		| shared toolong path
	movel	a1,d1			| inend = InBuf + InLen
	moveml	d2-d3/a2-a4,sp@-
	moveal	a0@+,a2			| xsp_OutBuf
	addl	d0,d1
	lea	a2@(256),a4
	addal	a0@,a4			| a4 = OutBuf+256+OutBufLen
	movel	a2,d3
	addl	d0,d3			| d3 = OutBuf + InLen (expansion ceiling)
_pack_loop:
	cmpl	a1,d1
	blsw	_pack_done
	moveb	a1@,d0			| current byte
	lea	a1@(1),a3
	cmpl	a3,d1			| last byte? (inend <= a1+1)
	bhis	_pack_have2
	lea	a2@(2),a3		| emit lone byte: need 2 out bytes
	cmpal	a4,a3
	bhiw	_pack_outfull
	cmpal	d3,a3
	bhis	_pack_ceiling
	clrb	a2@+			| literal token 0
	moveb	d0,a2@+
	bras	_pack_done
_pack_have2:
	cmpb	a3@,d0			| run if next byte == cur
	beqs	_pack_run
	lea	a2@(1),a3		| literal path: reserve token cell
	movew	#127,d2
_pack_lit_loop:
	cmpal	a3,a4
	blss	_pack_outfull
	cmpl	a3,d3
	blss	_pack_ceiling
	cmpb	a1@(1),d0		| next byte equal -> close lit
	beqs	_pack_lit_close
	moveb	a1@+,a3@+		| copy byte
	cmpl	a1,d1
	blss	_pack_lit_close127	| ran off input end
	moveb	a1@,d0			| next input byte
	subqw	#1,d2
	bccs	_pack_lit_loop
_pack_lit_close:
	.short	0x943c			| sub.b #126,d2 (noncanonical)
	.short	0x007e
	negb	d2
	moveb	d2,a2@			| patch literal token
	moveal	a3,a2
	bras	_pack_loop
_pack_run:
	lea	a2@(2),a3		| run pair needs 2 out bytes
	cmpal	a4,a3
	bhis	_pack_outfull
	cmpal	d3,a3
	bhis	_pack_ceiling
	movew	#127,d2
_pack_run_loop:
	cmpb	a1@,d0
	bnes	_pack_run_close
	addqw	#1,a1
	cmpl	a1,d1
	blss	_pack_run_closelen
	subqw	#1,d2
	bccs	_pack_run_loop
_pack_run_close:
	.short	0x943c			| sub.b #126,d2 (noncanonical)
	.short	0x007e
	moveb	d2,a2@+			| negative count byte
	moveb	d0,a2@+
	bras	_pack_loop
_pack_run_closelen:
	.short	0x943c			| sub.b #127,d2 (noncanonical)
	.short	0x007f
	moveb	d2,a2@+
	moveb	d0,a2@+
_pack_done:
	subal	a0@-,a2			| a0@- -> +8 (OutBuf): a2 -= OutBuf
	movel	a2,a0@(8)		| -> xsp_OutLen @+16
	moveq	#0,d0
	bras	_pack_ret
_pack_lit_close127:
	.short	0x943c			| sub.b #127,d2 (noncanonical)
	.short	0x007f
	negb	d2
	moveb	d2,a2@			| patch literal token
	moveal	a3,a2
	bras	_pack_done
_pack_ceiling:
	moveq	#-17,d0			| XPKERR_EXPANSION
	bras	_pack_ret
_pack_outfull:
	moveq	#-10,d0			| XPKERR_... output full
_pack_ret:
	moveml	sp@+,d2-d3/a2-a4
	rts

	.globl	_endcode
_endcode:
