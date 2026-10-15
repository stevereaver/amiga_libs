||||
||||	xpkFRLE_h0.s -- byte-verbatim reconstruction of
||||	xpkFRLE.library v1.1 ("Fast Run Length Encoder",
||||	XOR-obfuscated ByteRun XPK sublibrary).
||||
||||	Single CODE hunk (0x2f8 bytes), AUTOINIT, word-offset
||||	function table (10 vectors) BEFORE the InitStruct datatab,
||||	then the XpkInfo/XpkMode islands, then all strings, then
||||	the code at the end of the hunk.  The RELOC32 tail lists
||||	its 18 sites in DESCENDING order; source/fixup.py rewrites
||||	the linked tail to match.
||||
||||	Quirks: entry stub returns -1; no $VER: cookie; initfn
||||	stores only the seglist at lib+0x22 (dataSize 0x26, no
||||	saved SysBase -- expunge reloads exec base from 4.w and
||||	moves through the stack, not registers); the four unused
||||	vectors (-24/-42/-48/-60) share the moveq#0;rts stub at
||||	0x1b8 (which is also the deferred-expunge tail); XpkInfo
||||	is a static island inside the code hunk; xm_Description
||||	says "ByteRun"; unpack uses AND.B/SUB.B with immediate
||||	eas (noncanonical encodings -> raw .short) and asymmetric
||||	+0x20/+0x1f biases for repeat vs literal counts.
||||

	.section .text

|||| executable-entry stub: non-resident loaders get -1
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP = hunk end (0x2f8)
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME   -> 0xe8
	.long	_idstr			| RT_IDSTRING -> 0xf8
	.long	_inittab		| RT_INIT

|||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x26			| dataSize = Library + seglist only
	.long	_functab		| -> 0x2e (BEFORE datatab)
	.long	_datatab		| -> 0x46
	.long	_LibInit		| -> 0x15e

|||| word-offset function table (signed, relative to _functab);
|||| bracketed by -1 markers.
_functab:
	.word	-1
	.word	_LibOpen-_functab	| LVO  -6  -> 0x166
	.word	_LibClose-_functab	| LVO -12  -> 0x174
	.word	_LibExpunge-_functab	| LVO -18  -> 0x182
	.word	_stub0-_functab		| LVO -24  -> 0x1b8 ret0
	.word	_XpkInfo-_functab	| LVO -30  -> 0x1bc
	.word	_XpkPack-_functab	| LVO -36  -> 0x1c4
	.word	_stub0-_functab		| LVO -42  -> 0x1b8
	.word	_stub0-_functab		| LVO -48  -> 0x1b8
	.word	_XpkUnpack-_functab	| LVO -54  -> 0x2a4
	.word	_stub0-_functab		| LVO -60  -> 0x1b8
	.word	-1

|||| InitStruct datatab: 8-bit-offset commands
|||| (0x80 long / 0x90 word / 0xa0 byte), word-aligned.
_datatab:
	.byte	0xa0,0x08,0x09		| INITBYTE @8  ln_Type = NT_LIBRARY
	.byte	0x00			| pad
	.byte	0x80,0x0a		| INITLONG @10 ln_Name
	.long	_libname
	.byte	0xa0,0x0e,0x06		| INITBYTE @14 lib_Flags = 6
	.byte	0x00			| pad
	.byte	0x90,0x14		| INITWORD @20 lib_Version = 1
	.word	1
	.byte	0x90,0x16		| INITWORD @22 lib_Revision = 1
	.word	1
	.byte	0x80,0x18		| INITLONG @24 lib_IdString
	.long	_idstr
	.long	0			| terminator + pad

|||| XpkInfo island, static inside the code hunk (0x66).
_xpkinfo:
	.word	1			| xi_XpkInfoVersion
	.word	1			| xi_LibVersion
	.word	2			| xi_MasterVersion
	.word	0			| xi_ModesVersion
	.long	_s_name			| xi_Name       "FRLE"
	.long	_s_lname		| xi_LongName   "Fast Run Length Encoder 1.0"
	.long	_s_desc			| xi_Description "Cache-optimized RLE"
	.ascii	"FRLE"			| xi_ID
	.long	9			| xi_Flags = PK_CHUNK|UP_CHUNK
	.long	0x00020000		| xi_MaxPkInChunk = 131072
	.long	0x10			| xi_MinPkInChunk = 16
	.long	0x8000			| xi_DefPkInChunk = 32768
	.long	_s_pack			| xi_PackMsg    "Packing"
	.long	_s_unpack		| xi_UnpackMsg  "Unpacking"
	.long	_s_packed		| xi_PackedMsg  "Packed"
	.long	_s_unpacked		| xi_UnpackedMsg "Unpacked"
	.word	0x10			| xi_DefMode = 16
	.word	0			| pad
	.long	_xpkmode		| xi_ModeDesc
	.long	0,0,0,0,0,0		| xi_Reserved[6]

|||| XpkMode island (0xbe); xm_Description literally says "ByteRun".
_xpkmode:
	.long	0			| xm_Next
	.long	100			| xm_Upto
	.long	1			| xm_Flags
	.long	0			| xm_PackMemory
	.long	0			| xm_UnpackMemory
	.long	800			| xm_PackSpeed
	.long	1480			| xm_UnpackSpeed
	.word	2			| xm_Ratio = 2%
	.word	0			| xm_ChunkSize
	.ascii	"ByteRun"
	.byte	0
	.word	0			| pad to 0xe8

|||| strings
_libname:
	.ascii	"xpkFRLE.library"	| 0xe8
	.byte	0
_idstr:
	.ascii	"xpkFRLE v1.1"		| 0xf8 (no $VER: cookie)
	.byte	0xd,0xa,0
_s_name:
	.ascii	"FRLE"			| 0x107
	.byte	0
_s_lname:
	.ascii	"Fast Run Length Encoder 1.0"	| 0x10c
	.byte	0
_s_desc:
	.ascii	"Cache-optimized RLE"	| 0x128
	.byte	0
_s_pack:
	.ascii	"Packing"		| 0x13c
	.byte	0
_s_unpack:
	.ascii	"Unpacking"		| 0x144
	.byte	0
_s_packed:
	.ascii	"Packed"			| 0x14e
	.byte	0
_s_unpacked:
	.ascii	"Unpacked"		| 0x155
	.byte	0

|||| LibInit (0x15e): saves only the seglist at lib+0x22.
_LibInit:
	moveal	d0,a1
	movel	a0,a1@(34)		| xsb_SegList
	rts

|||| LVO -6 LibOpen (0x166): OpenCnt++, clear flag bit 3, ret base.
_LibOpen:
	addqw	#1,a6@(32)
	andib	#-9,a6@(14)		| LIBF_DELEXP off (andi.b #0xf7)
	movel	a6,d0
	rts

|||| LVO -12 LibClose (0x174): OpenCnt--; at 0 consult flag bit 3.
_LibClose:
	subqw	#1,a6@(32)
	bnes	_stub0
	btst	#3,a6@(14)
	beqs	_stub0

|||| LVO -18 LibExpunge (0x182): deferred via lib_Flags bit 3;
|||| real path stack-saves seglist+libbase, SysBase from 4.w.
_LibExpunge:
	tstw	a6@(32)
	bnes	_exp_defer
	moveal	a6,a1
	movel	a6@(34),sp@-		| seglist
	movel	a6,sp@-
	moveal	4,a6			| SysBase (absolute)
	jsr	a6@(-252)		| Remove
	moveal	sp@,a0
	moveal	sp@,a1
	moveq	#0,d0
	movew	a0@(16),d0		| NegSize
	subal	d0,a1
	addw	a0@(18),d0		| + PosSize
	jsr	a6@(-210)		| FreeMem
	moveal	sp@+,a6
	movel	sp@+,d0			| return seglist
	rts
_exp_defer:
	bsetb	#3,a6@(14)		| LIBF_DELEXP on
_stub0:					| 0x1b8 shared ret0 vector
	moveq	#0,d0
	rts

|||| LVO -30 XpksPackerInfo (0x1bc): -> static island at 0x66.
_XpkInfo:
	lea	_xpkinfo(pc),a0
	movel	a0,d0
	rts

|||| LVO -36 XpksPackChunk (0x1c4): FRLE encode.
|||| pb: a1=InBuf, a2=InLen->in end, a3=OutBuf, a4=OutBuf+OutBufLen.
|||| d4 = 0x9f (repeat key), d5 = 0x1f (literal key).
|||| Repeat token = (n-2)^0x9f; literal token = (len-1)^0x1f.
|||| Literal scanner is a 4-unrolled pair lookahead (d3=31 budget);
|||| a 3-equal-byte run ends a literal, an isolated pair does not.
_XpkPack:
	moveml	d2-d5/a2-a6,sp@-
	moveml	a0@+,a1-a4		| pb[0..3]
	addal	a1,a2			| a2 = in end
	addal	a3,a4			| a4 = OutBuf + OutBufLen bound
	moveq	#-97,d4			| 0x9f repeat XOR key
	moveq	#31,d5			| 0x1f literal XOR key
	bras	_lit
_runcnt:				| 0x1d6: extend repeat run
	cmpb	a1@+,d1
	bnes	_runout
	subqb	#1,d3
	bccs	_runcnt
	addqw	#1,a1			| budget out: keep the last byte
_runout:				| 0x1e0: emit repeat record
	cmpal	a4,a3
	bccs	_over			| out full -> -17
	subqw	#1,a1			| un-eat the mismatching byte
	movel	a1,d2
	subl	a5,d2			| run len
	cmpal	a2,a1
	bcss	_runmid
	movel	a2,d2			| tail run: len = inend - base
	subl	a5,d2
	beqs	_runbra
	subqw	#2,d2
	eorb	d4,d2			| token = (len-2)^0x9f
	moveb	d2,a3@+
	moveb	d1,a3@+
_runbra:
	braw	_done			| long branch (disp16, quirky)
_runmid:				| 0x200
	subqw	#2,d2
	eorb	d4,d2
	moveb	d2,a3@+
	moveb	d1,a3@+
_lit:					| 0x208: literal segment scan
	moveal	a1,a5			| a5 = segment base
	moveb	a1@+,d1			| first byte
	moveq	#126,d3			| run budget
	moveb	a1@+,d0			| second byte
	cmpb	d0,d1
	beqs	_runcnt			| equal pair -> repeat path
	moveq	#31,d3			| literal budget (~4-byte groups)
	bras	_l3
_l1:	moveb	a1@+,d1			| 0x218
	cmpb	d0,d1
	beqs	_lb
_l2:	moveb	a1@+,d0			| 0x21e
	cmpb	d1,d0
	beqs	_lc
_l3:	moveb	a1@+,d1			| 0x224
	cmpb	d0,d1
	beqs	_ld
_l4:	moveb	a1@+,d0			| 0x22a
	cmpb	d1,d0
	beqs	_lf
	subqb	#1,d3
	bccs	_l1
	bras	_lemit
_lb:	moveb	a1@+,d0			| 0x236: pair at pos 1 confirmed
	cmpb	d1,d0
	bnes	_l3
	bras	_lcut
_lc:	moveb	a1@+,d1			| 0x23e: pair at pos 2 confirmed
	cmpb	d0,d1
	bnes	_l4
	bras	_lcut
_ld:	moveb	a1@+,d0			| 0x246: pair at pos 3 confirmed
	cmpb	d1,d0
	beqs	_lcut
	subqb	#1,d3
	bccs	_l1
	bras	_lemit
_over:					| 0x252: output overflow -> -17
	moveq	#-17,d0
	bras	_ret
_lf:	moveb	a1@+,d1			| 0x256: pair at pos 4 confirmed
	cmpb	d0,d1
	beqs	_lcut
	subqb	#1,d3
	bccs	_l2
	addqw	#2,a1
_lcut:					| 0x262
	subqw	#3,a1			| rewind to before the equal pair
_lemit:					| 0x264: emit literal run
	movel	a1,d2
	subl	a5,d2			| literal len
	lea	a3@(1,d2:w),a6		| a6 = out+1+len
	cmpal	a4,a6
	bccs	_over
	cmpal	a2,a1
	bccs	_llast			| input exhausted -> tail literal
	subqw	#1,d2			| len-1
	movew	d2,d1			| copy count
	eorb	d5,d2			| token = (len-1)^0x1f
	moveb	d2,a3@+
_lcp:	moveb	a5@+,a3@+		| 0x27c
	subqw	#1,d1
	bccs	_lcp
	bras	_lit
_llast:					| 0x284: tail literal
	movel	a2,d2
	subl	a5,d2
	beqs	_done
	subqw	#1,d2
	eorb	d2,d5			| QUIRK: corrupts d5 (dead after)
	moveb	d5,a3@+
_llcp:	moveb	a5@+,a3@+		| 0x290
	subqw	#1,d2
	bccs	_llcp
_done:					| 0x296
	subal	a0@(-8),a3		| a3 -= pb[2] OutBuf -> outlen
	movel	a3,a0@			| pb[4] = xsp_OutLen (a0 = pb+0x10)
	moveq	#0,d0
_ret:					| 0x29e
	moveml	sp@+,d2-d5/a2-a6
	rts

|||| LVO -54 XpksUnpackChunk (0x2a4): FRLE decode.
|||| Token t<<1; bit7 (carry) = repeat.  Counts:
||||   literal: d0 = (t&0x7f) - 2*(t&0x1f) + 0x1f   (+0x1f bias!)
||||   repeat:  d0 = (t&0x7f) - 2*(t&0x1f) + 0x20   (+0x20 bias)
|||| (written as and.b/sub.b with immediate eas -- noncanonical,
||||  emitted raw so gas doesn't turn them into andi/subi.)
|||| No output bound check; stops on input exhaustion.
_XpkUnpack:
	moveml	a2-a3,sp@-
	moveml	a0@+,a1-a3		| pb[0..2]: in,inlen,out
	addal	a1,a2			| a2 = in end
	moveq	#0,d0
	bras	_utest
_urep:					| 0x2b2: repeat record
	moveb	d0,d1
	.short	0xc23c,0x003e		| and.b #0x3e,d1 (noncanonical)
	.short	0x923c,0x0020		| sub.b #0x20,d1 (noncanonical)
	lsrb	#1,d0			| d0 = t&0x7f
	subb	d1,d0			| count-1 = t&0x7f -2*(t&0x1f)+0x20
	moveb	a1@+,d1			| run byte
_urepl:	moveb	d1,a3@+			| 0x2c2
	subqb	#1,d0
	bccs	_urepl
_utest:					| 0x2c8
	cmpal	a2,a1
	bccs	_udone
_unext:					| 0x2cc
	moveb	a1@+,d0			| token
	addb	d0,d0			| t<<1, carry = bit7
	bcss	_urep
	moveb	d0,d1			| literal record
	.short	0xc23c,0x003e		| and.b #0x3e,d1
	.short	0x923c,0x001f		| sub.b #0x1f,d1 (+0x1f bias!)
	lsrb	#1,d0
	subb	d1,d0
_ulitl:	moveb	a1@+,a3@+		| 0x2e0
	subqb	#1,d0
	bccs	_ulitl
	cmpal	a2,a1
	bcss	_unext
_udone:					| 0x2ea
	subal	a0@-,a3			| a0@-(4) -> pb+8 OutBuf; a3 -= it
	movel	a3,a0@(8)		| -> pb+0x10 xsp_OutLen
	moveal	sp@+,a2
	moveal	sp@+,a3
	moveq	#0,d0
	rts

	.globl	_endcode
_endcode:
