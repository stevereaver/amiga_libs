|||
|||	epu1.library 1.1 (epu0 family) - RomTag, InitTable, strings,
|||	LONG functab.  Reconstruction; no original code remains.
|||
|||	Original layout (1,564 bytes, 4 hunks):
|||	  code0: RomTag/InitTable/datatab/init/vectors/ctx helpers/
|||	         requester glue + lib-name and message strings
|||	  code1: AutoRequest frame builder + RETRY/CANCEL texts
|||	  data : IntuiText templates
|||	  code2: AutoRequest trampoline (jsr -348 on intuition)
|||	Here folded into one code hunk; semantics preserved.
|||

	.section .text

	.globl	_start
_start:
	moveq	#-1,%d0
	rts

||| ---------------------------------------------------------------
||| RomTag / InitTable -- AUTOINIT, version 1, NT_LIBRARY
||| ---------------------------------------------------------------

romtag:
	.word	0x4afc
	.long	romtag
	.long	rt_EndSkip
	.byte	0x80			|| RTF_AUTOINIT
	.byte	1			|| version
	.byte	9			|| NT_LIBRARY
	.byte	0			|| pri
	.long	_libname
	.long	_idstr
	.long	inittab
	.globl	rt_EndSkip

_libname:
	.ascii	"epu1.library"
	.byte	0
_idstr:					|| second copy, used as IdString
	.ascii	"epu1.library"
	.byte	0
	.even
	.globl	_dosname
	.globl	_intuiname
_dosname:
	.ascii	"dos.library"
	.byte	0
	.even
_intuiname:
	.ascii	"intuition.library"
	.byte	0
	.even

inittab:
	.long	0x30			|| dataSize 48
	.long	functab			|| funcTable (LONG addrs)
	.long	datatab			|| initDataTable
	.long	_LibInit		|| initRoutine

functab:
	.long	_LibOpen		|| -6
	.long	_LibClose		|| -12
	.long	_LibExpunge		|| -18
	.long	_LibNull		|| -24 Reserved
	.long	_EpuPack		|| -30
	.long	_EpuUnpack		|| -36
	.long	-1

|||
|||	datatab -- same e0/d0/c0 InitStruct encoding as the
|||	original, including the dead BYTE@0x0c write that lands
|||	inside ln_Name and is overwritten by the next LONG entry
|||	(verbatim quirk: ln_Type@8 is never initialised by the
|||	datatab).
|||
datatab:
	.word	0xe000,0x000c,0x0900	|| BYTE @0x0c = 9 (dead write)
	.word	0xc000,0x000a
	.long	_libname		|| LONG @0x0a = ln_Name
	.word	0xe000,0x000e,0x0600	|| BYTE @0x0e = 6 (lib_Flags)
	.word	0xd000,0x0014,0x0001	|| WORD @0x14 = version 1
	.word	0xd000,0x0016,0x0001	|| WORD @0x16 = revision 1
	.word	0xc000,0x0018
	.long	_idstr			|| LONG @0x18 = lib_IdString
	.word	0x0000			|| end

||| ---------------------------------------------------------------
||| base layout (48 bytes): Library(34) + exec@34 + dos@38 +
||| seg@42 + flags@46.  lh/intuition bases live in code space.
||| ---------------------------------------------------------------

	.globl	_s_lh
	.globl	_s_intui
	.globl	_s_doscopy		|| dead mirror of dosbase
_s_lh:		.long	0		|| hunk 0x2fc -- lh.library base
_s_intui:	.long	0		|| hunk 0x304 -- intuition base
_s_doscopy:	.long	0		|| hunk 0x30c -- dead dosbase copy

||| ---------------------------------------------------------------
||| strings for the AutoRequest dialogs
||| ---------------------------------------------------------------

	.globl	_s_lhname
	.globl	_s_epuname
	.globl	_s_cantopen
	.globl	_s_oomtitle
	.globl	_s_callname
	.globl	_s_retry
	.globl	_s_cancel

_s_lhname:
	.ascii	"lh.library"
	.byte	0
_s_epuname:
	.ascii	"epu1.library"
	.byte	0
_s_cantopen:
	.ascii	"can not open"
	.byte	0
_s_oomtitle:
	.ascii	"epu1 error:Out of memory"
	.byte	0
_s_callname:
	.ascii	"Name of call is "
	.byte	0
_s_retry:
	.ascii	"RETRY"
	.byte	0
_s_cancel:
	.ascii	"CANCEL"
	.byte	0
	.align	2
