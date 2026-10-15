/*
 * genesiskey.library 45.3 - structural sections.
 *
 * The original is a generated three-hunk file (code + data + bss):
 * a RomTag lives mid-code but rt_Init is the *data-hunk offset* (16)
 * of a MakeLibrary InitTable, so the file needs a custom loader
 * (genesis.library installs/registers it).  Data hunk holds runtime
 * library-base slots, the InitTable, and the embedded registration
 * strings whose offsets are returned by vectors -66/-78.
 */

	.text

/* ---- hunk+0: entry stub ---------------------------------------------
 * Executing the file as a program lands here and exits with d0=30
 * (RETURN_FAIL) - the classic "not a program" idiom.
 */
	.globl	_gk_entry
_gk_entry:
	linkw	a5,#0
	moveq	#30,d0
	unlk	a5
	rts

/* ---- hunk+0xa: dependency names (code-resident, like the original) -- */
	.globl	_gk_dosname
_gk_dosname:	.asciz	"dos.library"
	.globl	_gk_intuname
_gk_intuname:	.asciz	"intuition.library"
	.globl	_gk_utilname
_gk_utilname:	.asciz	"utility.library"

/* ---- absolute-pointer function table --------------------------------
 * 15 vectors (-6..-90) + -1 terminator.  The last two stub slots are
 * crossed in the original: -84 -> later stub, -90 -> earlier stub.
 */
	.globl	_gk_functab
_gk_functab:
	dc.l	_gk_open		/* -6  LibOpen        */
	dc.l	_gk_close		/* -12 LibClose       */
	dc.l	_gk_expunge		/* -18 LibExpunge     */
	dc.l	_gk_resv		/* -24 reserved -> 0  */
	dc.l	_gk_e1			/* -30 stub           */
	dc.l	_gk_e2			/* -36 stub           */
	dc.l	_gk_e3			/* -42 stub           */
	dc.l	_gk_e4			/* -48 stub           */
	dc.l	_gk_check		/* -54 socket probe   */
	dc.l	_gk_e5			/* -60 stub           */
	dc.l	_gk_retserial		/* -66 ret 0x20       */
	dc.l	_gk_e6			/* -72 stub           */
	dc.l	_gk_retos		/* -78 ret 0x120      */
	dc.l	_gk_e8			/* -84 stub (crossed) */
	dc.l	_gk_e7			/* -90 stub (crossed) */
	dc.l	-1

/* ---- RomTag ----------------------------------------------------------
 * RTC_MATCHWORD / self MatchTag / RTF_COLDSTART / v45 / NT_LIBRARY.
 * rt_Init = 16: offset of the InitTable inside hunk 1 (the data hunk),
 * interpreted by the Genesis loader rather than InitResident.
 */
	.globl	_gk_romtag
_gk_romtag:
	dc.w	0x4afc
	dc.l	_gk_romtag
	dc.l	_gk_endskip
	dc.b	0x80, 45, 9, 0
	dc.l	_gk_name
	dc.l	_gk_idstr
	dc.l	16

	.globl	_gk_idstr
_gk_idstr:
	.ascii	"genesiskey.library 45.3 (20.11.2000)\r\n"
	.byte	0
	.globl	_gk_name
_gk_name:	.asciz	"genesiskey.library"

	.globl	_gk_endskip
_gk_endskip:
	dc.l	0

	.globl	_gk_genesisname
_gk_genesisname:	.asciz	"genesis.library"
	.globl	_gk_sockname
_gk_sockname:	.asciz	"bsdsocket.library"

/* ---- data hunk -------------------------------------------------------
 * +0x00 runtime slots: exec, dos, intuition, utility bases
 * +0x10 MakeLibrary InitTable: { dataSize=0x52, funcTab, NULL, initFn }
 * +0x20 registration serial string (offset returned by vector -66)
 * +0x120 OS string (offset returned by vector -78); hunk ends at 0x220
 */
	.data
	.globl	_gk_exec
_gk_exec:	dc.l	0
	.globl	_gk_dos
_gk_dos:	dc.l	0
	.globl	_gk_intu
_gk_intu:	dc.l	0
	.globl	_gk_util
_gk_util:	dc.l	0

	.globl	_gk_initab
_gk_initab:
	dc.l	0x52			/* dataSize: Lib(34)+pad(2)+sem(46) */
	dc.l	_gk_functab
	dc.l	0
	dc.l	_gk_init

	.globl	_gk_serial
_gk_serial:
	.asciz	"454545"
	.space	0x120 - (0x20 + 7), 0
	.globl	_gk_osstr
_gk_osstr:
	.asciz	"AmigaOS 3.9"
	.space	0x220 - (0x120 + 12), 0

/* ---- bss hunk -------------------------------------------------------- */
	.bss
	.globl	_gk_seglist
_gk_seglist:
	.space	4
