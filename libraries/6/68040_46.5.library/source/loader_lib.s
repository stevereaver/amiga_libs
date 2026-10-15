|||
|||	loader_lib.s -- resident module header for the Phase5
|||	68040.library 46.5 loader stub
|||	(68040.library 46.5 (19.10.99) © 1994-1999 by Phase5,
|||	 written by Ralph Schmidt)
|||
|||	Matches the shipped binary's layout: code hunk starting with
|||	"moveq #0,d0/rts", RomTag, name/id strings, AUTOINIT InitTable
|||	(dataSize 0x38), an absolute-long function table and an
|||	old-style InitStruct data table.
|||
|||	The function table uses absolute 32-bit addresses (terminated
|||	by -1), so no two-pass table generation is needed.

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
	.byte	46			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

_libname:
	.ascii	"68040.library"
	.byte	0
_idstr:
	.ascii	"68040.library 46.5 (19.10.99) "
	.byte	0xa9			| (c)
	.ascii	" 1994-1999 by Phase5, written by Ralph Schmidt"
	.byte	0xd,0xa,0
	.even
	.ascii	"$VER: 68040.library 46.5 (19.10.99) "
	.byte	0xa9
	.ascii	" 1994-1999 by Phase5, written by Ralph Schmidt"
	.byte	0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x38			| sizeof(struct P5Base)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| absolute-long function table: Open, Close, Expunge, ExtFunc
_functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_LibNull
	.long	-1

||| old-style InitStruct data table (nibble 8=LONG, 9=WORD, A=BYTE<<8)
_datatab:
	.word	0xa008,0x0900		| INITBYTE  ln_Type     = NT_LIBRARY
	.word	0x800a
	.long	_libname		| INITLONG  ln_Name
	.word	0xa00e,0x0600		| INITBYTE  lib_Flags   = LIBF_CHANGED|LIBF_SUMUSED
	.word	0x9014,46		| INITWORD  lib_Version = 46
	.word	0x9016,5		| INITWORD  lib_Revision = 5
	.word	0x8018
	.long	_idstr			| INITLONG  lib_IdString
	.word	0x802c,0,0		| INITLONG  pb_LoadLib = NULL
	.word	0x8028,0,0		| INITLONG  pb_OpenLib = NULL
	.word	0			| terminator

||| library names used by LibInit, exported so loader.c can take
||| mid-string pointers exactly like the original does:
|||   str_68060 + 5 -> "68060.library"  (OpenLibrary basename)
|||   str_68040old/new + 5 -> basename; helper backs up 5 for "LIBS:"
	.globl	_str_68060,_str_68040old,_str_68040new,_str_dos
_str_68060:
	.ascii	"LIBS:68060.library"
	.byte	0
_str_68040old:
	.ascii	"LIBS:68040old.library"
	.byte	0
_str_68040new:
	.ascii	"LIBS:68040new.library"
	.byte	0
_str_dos:
	.ascii	"dos.library"
	.byte	0
	.even
