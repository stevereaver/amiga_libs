||||
||||	ted_lib.s -- ted.library 1.0 (28.12.95)
||||
||||	Full assembly reconstruction of the shipped binary
||||	(1116 bytes, sha256 6e3c74b3fcc53ad9fac52cf26b041013
||||	f96367c012d15deb994450402398019e).
||||
||||	Single CODE hunk: entry stub, RomTag (ver 1), name/id/
||||	dos strings, InitTable (dataSize 0x30, InitStruct data),
||||	absolute-longword function table (20 vectors + -1L),
||||	init/open/close/expunge/reserved, sixteen tiny user
||||	functions, then five code-hunk global pointers and a
||||	~255 byte scratch buffer -- all addressed absolutely.
||||
||||	The library is a shared-variable / method-dispatch shim:
||||	five long globals hold pointers supplied by clients;
||||	global 3 anchors an external structure whose offsets
||||	12 and 100..116 are used as a method table.

	.section	.text

| loader entry -- returns -1

	.globl	_libentry
_libentry:
	moveq	#-1,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endskip		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"ted.library"
	.byte	0
_idstr:
	.ascii	"ted 1.0 (28.12.95)"
	.byte	0xd,0xa,0
_dosname:
	.ascii	"dos.library"
	.byte	0
	.byte	0			| pad to even

| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x30			| sizeof(struct TedBase)
	.long	_functab
	.long	_datatab
	.long	_initfunc

| Function table: 20 absolute vectors, -1L terminated.
| (-6/-12/-18/-24 then sixteen user functions)
_functab:
	.long	_open			| -6
	.long	_close			| -12
	.long	_expunge		| -18
	.long	_reserved		| -24
	.long	_ted_setg1			| -30  g1 = a0
	.long	_ted_setg2			| -36  g2 = a0
	.long	_ted_getg1			| -42  d0 = *g1 (long)
	.long	_ted_getg2w			| -48  d0 = *g2 (uword)
	.long	_ted_setg3			| -54  g3 = a0
	.long	_ted_getg3			| -60  d0 = g3
	.long	_ted_callg3m12		| -66  jmp *(g3+12)
	.long	_ted_setg4			| -72  g4 = a0
	.long	_ted_setg5			| -78  g5 = a0
	.long	_ted_getg4			| -84  d0 = *g4
	.long	_ted_getg5			| -90  d0 = *g5
	.long	_ted_callg3m100		| -96  d0 = buf after jsr *(g3+100)(a1=buf)
	.long	_ted_strg3p104		| -102 d0 = buf = strcpy(*(g3+104))
	.long	_ted_strg3p108		| -108 d0 = buf = strcpy(*(g3+108))
	.long	_ted_getg3p112m2		| -114 d0 = *(*(g3+112)-2)
	.long	_ted_getg3p116m2		| -120 d0 = *(*(g3+116)-2)
	.long	-1

| InitStruct data (exec/initializers.i 16-bit-offset form):
| ln_Type=NT_LIBRARY, ln_Name, lib_Flags=SUMUSED|CHANGED,
| lib_Version=1, lib_Revision=0, lib_IdString
_datatab:
	.byte	0xa0,0x08,0x09,0x00	| INITBYTE @8 = 9 (NT_LIBRARY)
	.byte	0x80,0x0a		| INITLONG @0xa
	.long	_libname		|   ln_Name
	.byte	0xa0,0x0e,0x06,0x00	| INITBYTE @0xe = 6 (flags)
	.byte	0x90,0x14		| INITWORD @0x14
	.word	1			|   lib_Version = 1
	.byte	0x90,0x16		| INITWORD @0x16
	.word	0			|   lib_Revision = 0
	.byte	0x80,0x18		| INITLONG @0x18
	.long	_idstr			|   lib_IdString
	.word	0			| end
	.word	0			| pad (shipped: 2 zero words)

| initFunc (d0=base, a0=seglist, a6=sysbase): store pointers,
| open dos.library v0 -> base+40, always return the base.
_initfunc:
	movel	a5,-(sp)
	moveal	d0,a5
	movel	a6,36(a5)		| SysBase
	movel	a0,44(a5)		| seglist
	lea	_dosname(pc),a1
	moveq	#0,d0
	jsr	a6@(-552)		| OpenLibrary
	movel	d0,40(a5)		| DOSBase (unchecked)
	movel	a5,d0
	moveal	(sp)+,a5
	rts

| -6: opencnt++, clear private DELEXP flag at base+34, return base
_open:
	addqw	#1,32(a6)
	bclr	#3,34(a6)
	movel	a6,d0
	rts

| -12: opencnt--; at zero with flag set -> expunge
_close:
	moveq	#0,d0
	subqw	#1,32(a6)
	bne	1f
	btst	#3,34(a6)
	beq	1f
	bsr	_expunge
1:	rts

| -18: in use -> set private flag, ret 0; else unlink/close/free
_expunge:
	moveml	d2/a5-a6,-(sp)
	moveal	a6,a5
	moveal	36(a5),a6		| SysBase
	tstw	32(a5)
	beq	2f
	bset	#3,34(a5)
	moveq	#0,d0
	bra	3f
2:	movel	44(a5),d2		| seglist
	moveal	a5,a1
	jsr	a6@(-252)		| Remove
	moveal	40(a5),a1
	jsr	a6@(-414)		| CloseLibrary(dos)
	moveq	#0,d0
	moveal	a5,a1
	movew	16(a5),d0		| NegSize
	subal	d0,a1
	addw	18(a5),d0		| + PosSize
	jsr	a6@(-210)		| FreeMem
	movel	d2,d0
3:	moveml	(sp)+,d2/a5-a6
	rts

| -24: reserved
_reserved:
	moveq	#0,d0
	rts

| code-hunk globals (absolute-addressed like the original)
	.globl	_g1,_g2,_g3,_g4,_g5,_buf
_g1:	.long	0
_g2:	.long	0
_g3:	.long	0
_g4:	.long	0
_g5:	.long	0

| scratch buffer (~0xff bytes, ends at EndSkip)
_buf:	.fill	0xff,1,0

_endskip:
	.word	0
