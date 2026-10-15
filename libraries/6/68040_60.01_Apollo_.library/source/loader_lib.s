|||
|||	loader_lib.s -- resident module header for the Apollo
|||	68040.library 60.01 loader stub
|||	($VER:68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani))
|||
|||	Matches the shipped binary's layout: code hunk starting with
|||	"moveq #0,d0/rts", RomTag, name/id strings, AUTOINIT InitTable
|||	(dataSize 0x22 == bare struct Library), an absolute-long
|||	function table and an old-style InitStruct data table.
|||
|||	The function table uses absolute 32-bit addresses (terminated
|||	by -1), not word offsets, so no two-pass table generation is
|||	needed: the linker emits RELOC32 entries for every entry.

	.section .text

||| executable-entry return value for non-resident loaders
	moveq	#0,d0
	rts

	.even
_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_endcode		| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	60			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"68040.library"
	.byte	0
	.ascii	"$VER:"
_idstr:
	.ascii	"68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani)"
	.byte	0xd,0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x22			| sizeof(struct Library)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| absolute-long function table: Open, Close, Expunge, ExtFunc
||| (Expunge and ExtFunc share the same stub in the original)
_functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_LibExpunge
	.long	-1

||| old-style InitStruct data table (InitStruct() format used by
||| Kickstart 1.x/3.x modules: nibble 8=LONG, 9=WORD, A=BYTE <<8)
_datatab:
	.word	0xa008,0x0900		| INITBYTE  ln_Type     = NT_LIBRARY
	.word	0x800a
	.long	_libname		| INITLONG  ln_Name
	.word	0xa00e,0x0600		| INITBYTE  lib_Flags   = LIBF_CHANGED|LIBF_SUMUSED
	.word	0x9014,60		| INITWORD  lib_Version = 60
	.word	0x9016,0		| INITWORD  lib_Revision = 0
	.word	0x8018
	.long	_idstr			| INITLONG  lib_IdString
	.word	0			| terminator

||| library names opened by LibInit, kept as global labels so the
||| C code can reference them (and the mid-string offset quirk)
	.globl	_str_68o4o,_str_68060
_str_68o4o:
	.ascii	"68o4o.library"		| Apollo "68040.library" work-alike
	.byte	0
_str_68060:
	.ascii	"68060.library"
	.byte	0
	.even
