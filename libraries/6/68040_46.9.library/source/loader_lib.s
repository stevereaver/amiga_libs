|||
|||	loader_lib.s -- resident module header for
|||	68040.library 46.9 ("040/060-Loader.library 46.9
|||	(21.11.2020) by Holger 'Lynxx' Hippenstiel.")
|||
|||	Matches the shipped binary's layout: code hunk starting with
|||	"moveq #0,d0/rts", RomTag, name/id strings, AUTOINIT InitTable
|||	(dataSize 0x34), an absolute-long function table and an
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

||| names used by LibInit -- the original binary references both
||| with a +2 offset (opening "060.library" and LoadSeg()ing
||| "bs:68040mmu.library"), a quirk reproduced in loader.c
	.globl	_str_68060,_str_mmu
_str_68060:
	.ascii	"68060.library"
	.byte	0
_str_mmu:
	.ascii	"Libs:68040mmu.library"
	.byte	0

	.ascii	"$VER: "
_idstr:
	.ascii	"040/060-Loader.library 46.9 (21.11.2020) by Holger 'Lynxx' Hippenstiel."
	.byte	0xa,0
	.even

||| InitTable: dataSize, funcTable, dataTable, initFunc
_inittab:
	.long	0x34			| sizeof(struct LynxxBase)
	.long	_functab
	.long	_datatab
	.long	_LibInit

||| absolute-long function table: Open, Close, Expunge, ExtFunc
||| (Close/Expunge/ExtFunc all point at the same stub)
_functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibClose
	.long	_LibClose
	.long	-1

||| old-style InitStruct data table (nibble 8=LONG, 9=WORD, A=BYTE<<8)
_datatab:
	.word	0xa008,0x0900		| INITBYTE  ln_Type     = NT_LIBRARY
	.word	0x800a
	.long	_libname		| INITLONG  ln_Name
	.word	0xa00e,0x0600		| INITBYTE  lib_Flags   = LIBF_CHANGED|LIBF_SUMUSED
	.word	0x9014,46		| INITWORD  lib_Version = 46
	.word	0x9016,9		| INITWORD  lib_Revision = 9
	.word	0x8018
	.long	_idstr			| INITLONG  lib_IdString
	.word	0x8030,0,0		| INITLONG  lb_OpenLib = NULL
	.word	0			| terminator
