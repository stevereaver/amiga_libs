* newicon_lib.s -- resident/library skeleton for the newicon.library
* 44.0 emulation (C) 2000 Stephan Rupprecht reconstruction.
*
* Layout follows the original binary:
*   CODE hunk: fail stub / LibNull / init entry (all real code lives in
*              newicon.c; the C functions are entered directly)
*   DATA hunk: absolute functab (13 vectors), name/idstring,
*              InitTable (PosSize 50, datatab 0), AUTOINIT RomTag
*   BSS  hunk: g_icon (+0) = icon.library v44 base, g_sys (+4) = SysBase
*
* Public vectors (LVO):
*   -30  ni_xgeticon   X(name, lib, dtype=0, mode=0)
*   -36  ni_puticon    store handle back via icon.library
*   -42  ni_freedobj   FreeDiskObject(*handle)
*   -48  ret 0
*   -54  ret 0
*   -60  bare rts
*   -66  ni_mkdef      build def icon from image record
*   -72  ni_freedef    FreeDiskObject(handle->dob @ +20)
*   -78  ni_xgetdef    X(NULL, lib, d0&0xffff, 0)

	.text
	.globl	_start
_start:
	moveq	#-1,d0
	rts
	nop
	.globl	_LibNull
_LibNull:
	clrl	d0
	rts
	nop

* init is a C function: ni_init(d0=lib, a0=seglist, a6=SysBase)
* vector wrappers keep a6=lib semantics out of the C file.

	.globl	_vec_geticon
_vec_geticon:				/* -30: X(a0, a6, 0, 0) */
	movel	a6,sp@-
	moveal	a6,a1
	clrl	d1
	clrl	d0
	jbsr	_ni_xgeticon
	moveal	sp@+,a6
	rts

	.globl	_vec_getdef
_vec_getdef:				/* -78: X(NULL, a6, d0&0xffff, 0) */
	movel	a6,sp@-
	moveal	a6,a1
	clrl	d1
	andil	#0xffff,d0
	subal	a0,a0
	jbsr	_ni_xgeticon
	moveal	sp@+,a6
	rts

	.globl	_vec_ret0a, _vec_ret0b, _vec_retrts
_vec_ret0a:				/* -48 */
	clrl	d0
	rts
	nop
_vec_ret0b:				/* -54 */
	clrl	d0
	rts
	nop
_vec_retrts:				/* -60: bare rts (d0 undefined) */
	rts
	nop

	.globl	_vec_freedobj
_vec_freedobj:				/* -42: FreeDiskObject(*a0) if a0 */
	movel	a6,sp@-
	movel	a0,d0
	beqs	1f
	moveal	a0@,a0
	moveal	_g_icon,a6
	jsr	a6@(-90)
1:	moveal	sp@+,a6
	rts
	nop

	.globl	_vec_freedef
_vec_freedef:				/* -72: FreeDiskObject(a0@(20)) */
	movel	a6,sp@-
	moveal	_g_icon,a6
	moveal	a0@(20),a0
	jsr	a6@(-90)
	moveal	sp@+,a6
	rts

* ---- DATA hunk --------------------------------------------------
	.data
	.globl	_functab
_functab:
	.long	_ni_open		/* -6  LibOpen   */
	.long	_ni_close		/* -12 LibClose  */
	.long	_ni_expunge		/* -18 LibExpunge */
	.long	_LibNull		/* -24 */
	.long	_vec_geticon		/* -30 */
	.long	_ni_puticon		/* -36 */
	.long	_vec_freedobj		/* -42 */
	.long	_vec_ret0a		/* -48 */
	.long	_vec_ret0b		/* -54 */
	.long	_vec_retrts		/* -60 */
	.long	_ni_mkdef		/* -66 */
	.long	_vec_freedef		/* -72 */
	.long	_vec_getdef		/* -78 */
	.long	-1

_name:	.ascii	"newicon.library\0"
_idstr:	.ascii	"newicon.library 44.0 (30.12.99) emulation (C) 2000 by Stephan Rupprecht\0"
	.even

	.globl	_inittab
_inittab:
	.long	50			/* dataSize: Library(34)+seglist(4)+spare */
	.long	_functab
	.long	0			/* no datatab */
	.long	_ni_init

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag			/* rt_MatchTag */
	.long	_TagEnd			/* rt_EndSkip -> end of data hunk */
	.byte	0x80			/* RTF_AUTOINIT */
	.byte	44			/* rt_Version */
	.byte	9			/* NT_LIBRARY */
	.byte	0			/* rt_Pri */
	.long	_name			/* rt_Name */
	.long	_idstr			/* rt_IdString */
	.long	_inittab		/* rt_Init */
_TagEnd:

* ---- BSS hunk ---------------------------------------------------
	.bss
	.globl	_g_icon, _g_sys
_g_icon:
	.long	0			/* icon.library v44 base */
_g_sys:
	.long	0			/* SysBase saved by init */
