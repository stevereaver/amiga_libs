||||
||||	patchtest_lib.s -- resident/tag/table block for
||||	patchtest.library V1.00 (SAS/C build, 3 hunks originally:
||||	code + InitTable data + functab/strings; reconstructed as
||||	a conventional single-hunk AUTOINIT module).
||||
||||	Hunk map of the original (hunk0 = code, 864 bytes):
||||	  0x00  moveq #0,d0 / rts       entry stub (returns 0)
||||	  0x04  RomTag                AUTOINIT, ver 1, NT_LIBRARY
||||	      (name/idstr -> hunk2 strings, init -> hunk1 table)
||||	  0x20  LibInit               SAS/C runtime init
||||	  0xda  LibOpen               per-open private copy + user init
||||	  0x1f4 LibClose              user cleanup + free copy + DELEXP
||||	  0x25e LibExpunge            free fixup buf + Remove + FreeMem
||||	  0x2d0 per-open init         OpenLibrary("intuition.library")
||||	  0x314 per-open cleanup      CloseLibrary
||||	  0x33c public vector         intuition DisplayBeep(NULL)
||||	hunk1 (data, 0x20): InitTable {dataSize 0x58,
||||	  functab->hunk2+0, datatab=0, init->hunk0+0x20}
||||	hunk2 (code, 0x74): functab {0xda,0x1f4,0x25e,0,0x33c,-1},
||||	  "patchtest.library", "patchtest.library V1.00
||||	  (c)1996 Hans B|hler (part of dev/misc/Palis.lha)"
||||

	.text

	.globl	_start
	.globl	_LibInit
	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_PTBeep

|||| entry point -- returns 0

_start:
	moveq	#0,d0
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
	.ascii	"patchtest.library"
	.byte	0
_idstr:
	.ascii	"patchtest.library V1.00 (c)1996 Hans B|hler (part of dev/misc/Palis.lha)"
	.byte	13,10,0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x2a			|||| dataSize (orig 0x58, SAS/C tail unused)
	.long	_functab
	.long	0			|||| no datatab (orig had none either)
	.long	_LibInit

_functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_start			|||| reserved -24: orig points at
					|||| hunk+0 (moveq#0;rts)
	.long	_PTBeep
	.long	-1

|||| strings used by the code

	.even
_s_intuition:
	.ascii	"intuition.library"
	.byte	0

	.even
	.globl	_s_intuition
