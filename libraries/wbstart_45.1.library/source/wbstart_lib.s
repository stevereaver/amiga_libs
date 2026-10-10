||||
||||	wbstart_lib.s -- resident module header for
||||	wbstart.library 45.1 (16.12.00)
||||
||||	Two-hunk layout like the shipped binary:
||||	  CODE hunk: "moveq #-1,d0/rts" entry, "moveq #0,d0/rts"
||||	    reserved stub, init/open/close/expunge and the
||||	    WBStart vector, then the library-name string literals.
||||	  DATA hunk: absolute-longword function table
||||	    (-1L terminated), name/id strings, InitTable,
||||	    RomTag (RTF_AUTOINIT, RT_VERSION 2 -- yes, 2, as
||||	    shipped), and the EndSkip word.
||||
||||	Function vectors:
||||	  -6  Open    -18 Expunge  -30 reserved stub
||||	  -12 Close   -24 reserved -36 WBStart
||||
||||	There is no InitStruct data table: exec InitResident
||||	copies rt_Name/rt_IdString/rt_Version into the base and
||||	the init routine only writes lib_Revision = 2 itself.

	.section	.text

| loader entry -- returns -1 (module is not directly executable)

	.globl	_libentry
_libentry:
	moveq	#-1,d0
	rts
	nop

| reserved stub -- LVOs -24 and -30 both point here (returns 0)

	.globl	_reserved
_reserved:
	moveq	#0,d0
	rts
	nop

	.globl	_functab
	.globl	_libname
	.globl	_idstr
	.globl	_inittab
	.globl	_romtag

| ------------------------------------------------------------------
| DATA hunk (hunk 2 of the module): function table, strings,
| InitTable, RomTag, EndSkip -- exactly the original's order.
| ------------------------------------------------------------------

	.section	.data

_functab:
	.long	_LibOpen		| LVO -6
	.long	_LibClose		| LVO -12
	.long	_LibExpunge		| LVO -18
	.long	_reserved		| LVO -24
	.long	_reserved		| LVO -30
	.long	_WBStart		| LVO -36
	.long	-1

_libname:
	.ascii	"wbstart.library"
	.byte	0
_idstr:
	.ascii	"wbstart.library 45.1 (16.12.00)"
	.byte	0
	.even

| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x38			| sizeof(struct WBStartBase)
	.long	_functab
	.long	0			| no InitStruct data
	.long	_LibInit

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_enddata		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	2			| RT_VERSION  (shipped value!)
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

	.globl	_enddata
_enddata:
	.word	0
