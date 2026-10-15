||||
||||	amigaflight_lib.s -- resident/tag/table block plus the
||||	carry-signalling hex-parse vectors for amigaflight.library
||||	"AmigaFlight BETA 1.2", reconstructed.
||||
||||	AFHexValue, AFGetChar, AFGetHexChar and AFReadHex are kept
||||	in asm to preserve the shipped register/CCR contract
||||	(carry = parse error; ReadHex returns d0 term / d1 value /
||||	d2 count).  The dos handle convention is a1 throughout.
||||
||||	Hunk map of the original (single hunk, 1068 bytes):
||||	  0x00  moveq #-1,d0 / rts    entry stub (returns -1)
||||	  0x04  RomTag                AUTOINIT, ver 1, NT_LIBRARY
||||	  0x1e  "amigaflight.library"
||||	  0x32  "AmigaFlight BETA 1.2 (12.06.94)\r\n"
||||	  0x56  "dos.library"
||||	  0x62  "  Enter Address : ", 0x76 "  *** INVALID ADDRESS *** "
||||	  0x92  InitTable             dataSize 0x30
||||	  0xa2  functab               19 absolute longwords + -1
||||	  0xf2  datatab               InitStruct stream
||||	  0x112 LibInit               SysBase@+0x24, dos@+0x28, seg@+0x2c
||||	  0x138 LibOpen (refuses d0<1), 0x14e Close, 0x162 Expunge
||||	  0x1b4 null, 0x1b8 HexVal, 0x1de NewLine, 0x1f2 EnterAddr
||||	  0x230 bell helper, 0x23c GetChar, 0x262 GetHexChar
||||	  0x2a0 CharAvail, 0x2bc ReadHex
||||	  0x2d0 *dead* duplicate prompt routine (a6 misuse, would
||||	      crash -- left in the shipped binary)
||||	  0x30c PutChar(FPutC+Flush), 0x330 Nibble, 0x342 Byte
||||	  0x35c dead CRLF dup, 0x36a Word, 0x390 dead CRLF dup
||||	  0x3a2 Long, 0x3d6 dead CRLF dup, 0x3e8 PutString
||||	  0x408 PutSpace, 0x414 PutSpaces
||||

	.text

	.globl	_start
	.globl	_LibInit
	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_LibNull
	.globl	_AFHexValue
	.globl	_AFNewLine
	.globl	_AFEnterAddress
	.globl	_AFGetChar
	.globl	_AFGetHexChar
	.globl	_AFCharAvail
	.globl	_AFReadHex
	.globl	_AFPutChar
	.globl	_AFPutNibble
	.globl	_AFPutByte
	.globl	_AFPutWord
	.globl	_AFPutLong
	.globl	_AFPutString
	.globl	_AFPutSpace
	.globl	_AFPutSpaces
	.globl	_s_doslib
	.globl	_s_prompt
	.globl	_s_badaddr

|||| entry point -- returns -1

_start:
	moveq	#-1,d0
	rts

|||| resident tag

_romtag:
	.word	0x4afc			|||| RTC_MATCHWORD
	.long	_romtag			|||| RT_MATCHTAG
	.long	_endmodule		|||| RT_ENDSKIP
	.byte	0x80			|||| RTF_AUTOINIT
	.byte	1			|||| RT_VERSION
	.byte	9			|||| NT_LIBRARY
	.byte	0			|||| RT_PRI
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"amigaflight.library"
	.byte	0
_idstr:
	.ascii	"AmigaFlight BETA 1.2 (12.06.94)"
	.byte	13,10,0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x30			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

_functab:
	.long	_LibOpen		|||| -6
	.long	_LibClose		|||| -12
	.long	_LibExpunge		|||| -18
	.long	_LibNull		|||| -24
	.long	_AFHexValue		|||| -30
	.long	_AFNewLine		|||| -36
	.long	_AFEnterAddress		|||| -42
	.long	_AFGetChar		|||| -48
	.long	_AFGetHexChar		|||| -54
	.long	_AFCharAvail		|||| -60
	.long	_AFReadHex		|||| -66
	.long	_AFPutChar		|||| -72
	.long	_AFPutNibble		|||| -78
	.long	_AFPutByte		|||| -84
	.long	_AFPutWord		|||| -90
	.long	_AFPutLong		|||| -96
	.long	_AFPutString		|||| -102
	.long	_AFPutSpace		|||| -108
	.long	_AFPutSpaces		|||| -114
	.long	-1

|||| InitStruct data stream

_datatab:
	.byte	0xa0,0x08		|||| INITBYTE ln_Type = NT_LIBRARY
	.word	0x0900
	.byte	0x80,0x0a		|||| INITLONG ln_Name
	.long	_libname
	.byte	0xa0,0x0e		|||| INITBYTE lib_Flags = 6
	.word	0x0600
	.byte	0x90,0x14		|||| INITWORD lib_Version = 1
	.word	0x0001
	.byte	0x90,0x16		|||| INITWORD lib_Revision = 2
	.word	0x0002
	.byte	0x80,0x18		|||| INITLONG lib_IdString
	.long	_idstr
	.word	0x0000			|||| terminator

|||| ------------------------------------------------------------------
|||| asm vectors preserving the shipped carry/register contract
|||| ------------------------------------------------------------------

|||| -30 AFHexValue: hex char in d0 -> nibble; C flag on bad input

_AFHexValue:
	cmpb	#'0',d0
	blo.s	3$
	cmpb	#'9',d0
	bls.s	1$
	cmpb	#'A',d0
	blo.s	3$
	cmpb	#'F',d0
	bhi.s	3$
	subq	#7,d0
1$:	andb	#15,d0			|||| clears carry too
	bra.s	2$
3$:	orib	#1,%ccr			|||| set carry = error
2$:	rts

|||| -48 AFGetChar: FGetC(handle a1) -> d0; 0x9b (CSI) -> 0

_AFGetChar:
	moveml	d1/a6,sp@-
	movel	a1,d1			|||| dos arg: handle
	moveal	a6@(40),a6		|||| a6 = dosbase (base+0x28)
	jsr	a6@(-306)		|||| FGetC
	moveml	sp@+,d1/a6
	cmpb	#0x9b,d0
	bne.s	1$
	moveq	#0,d0
1$:	rts

|||| -54 AFGetHexChar: read+echo+uppercase+hexval; C flag on bad
|||| (a1/a6 pushed around the C _AFPutChar call -- a1 is
|||| caller-saved under the C ABI)

_AFGetHexChar:
	moveml	a1/a6,sp@-
	bsr	_AFGetChar		|||| d0 = char
	movel	d0,sp@-
	bsr	_AFPutChar		|||| echo (d0/a1/a6 args live)
	movel	sp@+,d0
	moveml	sp@+,a1/a6
	cmpb	#'a',d0
	blo.s	_AFHexValue
	cmpb	#'z',d0
	bhi.s	_AFHexValue
	subb	#32,d0
	bra	_AFHexValue

|||| -66 AFReadHex: loop AFGetHexChar -> d1 value / d2 count /
|||| d0 terminator; exits with C set (as shipped).  d3/d4 are
|||| callee-saved under the C ABI so C calls preserve them.

_AFReadHex:
	moveml	d3/d4/a1/a6,sp@-
	moveq	#0,d3			|||| value
	moveq	#0,d4			|||| count
1$:	bsr	_AFGetHexChar
	bcs.s	2$
	lsll	#4,d3
	addb	d0,d3
	addqw	#1,d4
	bra.s	1$
2$:	movel	d3,d1
	movel	d4,d2
	moveml	sp@+,d3/d4/a1/a6	|||| movem leaves CCR alone
	rts

|||| ------------------------------------------------------------------
|||| strings
|||| ------------------------------------------------------------------

	.even
_s_doslib:
	.ascii	"dos.library"
	.byte	0
_s_prompt:
	.ascii	"  Enter Address : "
	.byte	0
_s_badaddr:
	.ascii	"  *** INVALID ADDRESS *** "
	.byte	0

	.even
