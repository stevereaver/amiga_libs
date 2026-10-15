||||	services.library 37.10 - RomTag, InitTable, static data
||||	reconstructed from the shipped binary.
||||
||||	Hunk map of the original (single hunk, 1204 bytes):
||||	  0x00  moveq #-1,d0 / rts   entry stub
||||	  0x04  RomTag               AUTOINIT, ver 37, NT_LIBRARY
||||	  0x1e  "services.library"
||||	  0x2f  "services 37.10 (16.12.92)"
||||	  0x4c  InitTable            dataSize 0x9a
||||	  0x5c  functab              word-offset format
||||	  0x6c  datatab              revision 10 only
||||	  0x74  LibInit              open utility v37, init sems/list
||||	  0xbc  openlib helper       v37 + Alert(0x3800c) on fail
||||	  0xe0  "utility.library"/0xf0 "nipc.library"
||||	  0x100 Open (lazy nipc open behind sem2)
||||	  0x152 Close / 0x172 Expunge
||||	  0x1d2 null
||||	  0x1d6 close-both-libs helper
||||	  0x1e8 free 342B-node list helper
||||	  0x220 -30 SvcControl       nipc service registration
||||	  0x434 {0x7800,"Services"}  blob for the nipc-126 tag
||||	  0x448 -36 SvcFormat        RawDoFmt into a buffer
||||	  0x4ae putch hook

	.text
	.globl	_start
	.globl	_LibInit
_start:
	moveq	#-1,d0
	rts

|||| resident tag

_romtag:
	.word	0x4afc			|||| RTC_MATCHWORD
	.long	_romtag			|||| RT_MATCHTAG
	.long	_endmodule		|||| RT_ENDSKIP
	.byte	0x80			|||| RTF_AUTOINIT
	.byte	37			|||| RT_VERSION
	.byte	9			|||| NT_LIBRARY
	.byte	0			|||| RT_PRI
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"services.library"
	.byte	0
_idstr:
	.ascii	"services 37.10 (16.12.92)"
	.byte	0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x9a			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

_datatab:
	.long	0x9016000a		|||| initword @22 = 10 (lib_Revision)
	.long	0x00000000		|||| end

_utilityname:
	.ascii	"utility.library"
	.byte	0
_nipcname:
	.ascii	"nipc.library"
	.byte	0

|||| {0x7800,"Services"} blob pointed at by the nipc-126 tag
_svcblob:
	.word	0x7800
	.ascii	"Services"
	.byte	0
	.align	2

	.globl	_utilityname
	.globl	_nipcname
	.globl	_svcblob

|||| RawDoFmt putch hook for SvcFormat (-36): append the
|||| character byte and advance the write cursor in a3.
	.globl	_SvcPutch
_SvcPutch:
	moveb	d0,a3@+
	rts
