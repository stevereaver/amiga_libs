||||
||||	ghostrider_lib.s -- resident/tag/table/state block for
||||	GhostRider.library 37.2, reconstructed.
||||
||||	Absolute-longword function table (standard Amiga format);
||||	state block embedded in the code hunk like the original.
||||
||||	Hunk map of the original (offset -> contents):
||||	  0x00  moveq #20,d0 / rts      entry stub (returns 20)
||||	  0x04  RomTag                  AUTOINIT, ver 37, NT_LIBRARY
||||	  0x1e  InitTable               dataSize 0x2a
||||	  0x2e  functab                 8 absolute longwords + -1,-1
||||	  0x52  datatab                 InitStruct stream
||||	  0x72  LibInit                 seglist->+0x22, SysBase->+0x26
||||	  0x82  LibOpen, 0x90 LibClose, 0xa4 LibExpunge
||||	  0xe6  null stub, 0xea GRDispatch (calls table key 0)
||||	  0x100 FindPort("GhostRider.Port") -> port+0x22 table scan
||||	  0x138 GRCall6 (key 6, Disable/VBR/CacheClearU/Enable)
||||	  0x164 GRCall7 (key 7, preserves d1)
||||	  0x194 supervisor helper       movec d4,vbr on 68010+
||||	  0x1b6 GRArm                   IND_ADD/REMHANDLER install
||||	  0x260 input.device open + reply port setup
||||	  0x2ba input handler           hotkey/mouse trigger
||||	  0x338 state block             Interrupt+IOReq+MsgPort+cfg
||||	  0x3aa "input.device"/"GhostRider.Port"/"Setup ...Launcher"
||||	  0x3e1 libname, 0x3f4 idstr
||||

	.text

	.globl	_start
	.globl	_LibInit
	.globl	_LibOpen
	.globl	_LibClose
	.globl	_LibExpunge
	.globl	_LibNull
	.globl	_GRDispatch
	.globl	_GRArm
	.globl	_GRCall6
	.globl	_GRCall7
	.globl	_grstate
	.globl	_GRSupervisor
	.globl	_s_portname
	.globl	_s_launcher
	.globl	_s_inputdev

|||| entry point -- returns 20 (original quirk)

_start:
	moveq	#20,d0
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
	.ascii	"ghostrider.library"
	.byte	0
_idstr:
	.ascii	"GhostRider.library 37.2 (3 Aug 1994)"
	.byte	13,10,0

|||| InitTable (AUTOINIT)

	.even
_inittab:
	.long	0x2a			|||| dataSize
	.long	_functab
	.long	_datatab
	.long	_LibInit

_functab:
	.long	_LibOpen
	.long	_LibClose
	.long	_LibExpunge
	.long	_LibNull
	.long	_GRDispatch
	.long	_GRArm
	.long	_GRCall6
	.long	_GRCall7
	.long	-1
	.long	-1			|||| original has a second -1

|||| InitStruct data stream

_datatab:
	.byte	0xa0,0x08		|||| INITBYTE ln_Type (value in high
	.word	0x0900			||||  byte of the data word: NT_LIBRARY)
	.byte	0x80,0x0a		|||| INITLONG ln_Name
	.long	_libname
	.byte	0xa0,0x0e		|||| INITBYTE lib_Flags = LIBF_SUMUSED|
	.word	0x0600			||||  LIBF_CHANGED
	.byte	0x90,0x14		|||| INITWORD lib_Version = 37
	.word	0x0025
	.byte	0x90,0x16		|||| INITWORD lib_Revision = 2
	.word	0x0002
	.byte	0x80,0x18		|||| INITLONG lib_IdString
	.long	_idstr
	.word	0x0000			|||| terminator

|||| embedded state block (in the code hunk, as shipped)

	.even
_grstate:
	.space	0x78,0

|||| supervisor thunk: the original gates on AFF_68010 (SysBase+297
|||| bit0) and calls Exec Supervisor() to run 'movec d4,vbr; rte'.
|||| d4 holds whatever the caller left -- reproduced literally.
|||| (.word encoding keeps this file 68000-only)

_GRSupervisor:
	suba.l	a1,a1
	btst	#0,297(a6)
	beq.s	1$
	lea	_vbrthunk(pc),a5
	jsr	-30(a6)			|||| Supervisor
1$:
	rts
_vbrthunk:
	.word	0x4e7a,0x9801		|||| movec d4,vbr
	rte

|||| strings used by the code

	.even
_s_inputdev:
	.ascii	"input.device"
	.byte	0
_s_portname:
	.ascii	"GhostRider.Port"
	.byte	0
_s_launcher:
	.ascii	"Setup GhostRider Launcher"
	.byte	0

	.even
