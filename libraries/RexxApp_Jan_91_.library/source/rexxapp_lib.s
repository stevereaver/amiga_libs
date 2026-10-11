/*
** rexxapp.library "(dissidents Jan 91)" reconstruction
** Old-style non-AUTOINIT library: the library node is carved out of the
** code hunk itself at hunk+0x72 and the vectors are a 14-entry JMP table
** laid down before it (vector -84 first, -6 last).  LibInit performs
** AddLibrary() directly; there is no InitStruct/MakeLibrary call.
*/

	.text
	.even

/* ---- hunk+0: null/reserved stub (returns 0) ----------------------- */
	.globl	_rax_stub
_rax_stub:
	moveq	#0,d0
	rts

/* ---- hunk+4: Resident tag ----------------------------------------- */
	.globl	_RomTag
_RomTag:
	.word	0x4afc
	.long	_RomTag			/* matchtag -> self */
	.long	_TagEnd			/* endskip */
	.byte	0,0			/* flags=0 (NOT autoinit), version=0 */
	.byte	9,0			/* NT_LIBRARY, pri=0 */
	.long	_rex_name
	.long	_rex_idstr
	.long	_LibInit
_TagEnd:

/* ---- hunk+0x1e: vector jump table (14 x jmp abs) ------------------ */
/* order on disk = -84,-78,-72,-66,-60,-54,-48,-42,-36,-30,-24,-18,-12,-6 */
	.word	0x4ef9
	.long	_rax_stub		/* -84 jmp hunk+0 (relocated) */
	.word	0x4ef9
	.long	_rax_stub		/* -78 */
	.word	0x4ef9
	.long	_rax_stub		/* -72 */
	.word	0x4ef9
	.long	_rax_result		/* -66 RAX_SetResult */
	.word	0x4ef9
	.long	_rax_sendfwd		/* -60 RAX_SendForward */
	.word	0x4ef9
	.long	_rax_sendcmd		/* -54 RAX_SendCommand */
	.word	0x4ef9
	.long	_rax_send		/* -48 RAX_SendEx */
	.word	0x4ef9
	.long	_rax_cleanup		/* -42 RAX_Cleanup */
	.word	0x4ef9
	.long	_rax_dispatch		/* -36 RAX_Dispatch */
	.word	0x4ef9
	.long	_rax_setup		/* -30 RAX_Setup */
	.word	0x4ef9
	.long	_rax_stub		/* -24 null */
	.word	0x4ef9
	.long	_LibExpunge		/* -18 */
	.word	0x4ef9
	.long	_LibClose		/* -12 */
	.word	0x4ef9
	.long	_LibOpen		/* -6 */

/* ---- hunk+0x72: the library node/base (static, self-hosted) ------- */
	.globl	_rx_base
_rx_base:
	.long	0,0			/* ln_Succ, ln_Pred */
	.byte	9,0			/* ln_Type=NT_LIBRARY, ln_Pri */
	.long	_rex_name		/* ln_Name */
	.byte	6,0			/* lib_Flags, lib_pad */
	.word	0x54,0x3a		/* lib_NegSize, lib_PosSize */
	.word	0,1			/* lib_Version, lib_Revision */
	.long	_rex_idstr		/* lib_IdString */
	.long	0			/* lib_Sum */
	.word	0			/* lib_OpenCnt */
	.globl	_rx_seg
_rx_seg:
	.long	0			/* +34 seglist slot */
	.globl	_rx_exec
_rx_exec:
	.long	0			/* +38 execbase slot */

/* ---- hunk+0x9c: LibInit ------------------------------------------- */
/* stores seglist+execbase in the private slots then AddLibrary(base)  */
	.globl	_LibInit
_LibInit:
	movel	a3,sp@-
	lea	_rx_seg,a3
	movel	a0,a3@+			/* seglist */
	movel	a6,a3@+			/* execbase */
	lea	_rx_base,a1
	moveal	a1,a3
	jsr	a6@(-396)		/* AddLibrary */
	movel	a3,d0
	moveal	sp@+,a3
	rts

/* ---- hunk+0xb6: LibOpen -------------------------------------------- */
	.globl	_LibOpen
_LibOpen:
	addqw	#1,a6@(32)		/* OpenCnt++ */
	bclr	#3,a6@(14)		/* clear LIBF_DELEXP */
	movel	a6,d0
	rts

/* ---- hunk+0xc4: LibClose ------------------------------------------- */
	.globl	_LibClose
_LibClose:
	subqw	#1,a6@(32)		/* OpenCnt-- */
	bnes	lc_ret
	bset	#3,a6@(14)		/* set LIBF_DELEXP */
	bnes	le_exp			/* was set -> expunge now */
lc_ret:	moveq	#0,d0
	rts

/* ---- hunk+0xd6: LibExpunge ----------------------------------------- */
	.globl	_LibExpunge
_LibExpunge:
	bset	#3,a6@(14)		/* set LIBF_DELEXP */
	movew	a6@(32),d1
	bnes	lc_ret			/* still open -> 0 */
le_exp:	movel	a6,sp@-
	moveal	_rx_exec,a6		/* stored execbase */
	lea	_rx_base,a1
	jsr	a6@(-252)		/* Remove */
	movel	_rx_seg,d0		/* return seglist */
	moveal	sp@+,a6
	rts

/* ---- strings -------------------------------------------------------- */
	.globl	_rex_name
_rex_name:
	.ascii	"rexxapp.library\0"

/* original idstr points mid-string (off-by-1 shipped quirk):          */
/* "dissidents..." is part of "(dissidents Jan 91) rexxapp.library"     */
	.globl	_rex_idstr
	.globl	_rex_fullid
_rex_fullid:
	.ascii	"("
_rex_idstr:
	.ascii	"dissidents Jan 91) rexxapp.library\0"
	.even
