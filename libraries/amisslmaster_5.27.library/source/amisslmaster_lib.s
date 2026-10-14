/* amisslmaster.library 5.27 -- resident/library skeleton
 *
 * Layout mirrors the original CODE hunk:
 *   +0x000 entry stub: moveq #-1,d0; rts
 *   +0x004 "amisslmaster.library\0" / +0x019 id string
 *   +0x047 "dos.library\0"   (+0x1d0 "amissl.library\0", mid-code)
 *   ...API code (C objects)...
 *   +0x484 InitTable: dataSize 50, functab -> DATA hunk
 *          (_mFuncTable), datatab NULL, initfn mLibInit
 *   +0x494 RomTag — NON-STANDARD: an extra relocated long sits
 *          between rt_EndSkip and the flags byte (value -> logname
 *          string), and rt_EndSkip points back at the matchtag.
 *   +0x4ae "RAM:awmaster.log\0" (debug logfile name)
 *   +0x4c0 logger tail ...
 * DATA hunk = absolute-long functab, 10 vectors + -1.
 *
 * Lib private data:
 *   +34 ExecBase  +38 SegList  +42 AmiSSLBase  +46 DOSBase
 */
	.text

/*------------------------- entry stub ----------------------------*/
	.globl	_start_stub
_start_stub:
	moveq	#-1,%d0
	rts

	.globl	_libname
_libname:
	.ascii	"amisslmaster.library\0"
	.globl	_idstr
_idstr:
	.ascii	"amisslmaster.library 5.27 (wolfSSL-Wrapper)\015\012\0"
	.globl	_dosname
_dosname:
	.ascii	"dos.library\0"
	.globl	_amisslname
_amisslname:
	.ascii	"amissl.library\0"

/*--------------------------- InitTable ---------------------------*/
	.globl	_inittab
_inittab:
	.long	50			/* dataSize */
	.long	_mFuncTable
	.long	0			/* datatab: NULL (no InitStruct) */
	.long	_mLibInit

/*--------------------------- RomTag ------------------------------*/
	.globl	_mRomTag
_mRomTag:
	.word	0x4afc
	.long	_mRomTag		/* rt_EndSkip -> own tag (quirk) */
	.long	_lognam			/* extra long: -> logfile name  */
	.byte	0x80,5,9,0		/* AUTOINIT, ver 5, LIB, pri 0  */
	.long	_libname
	.long	_idstr
	.long	_inittab

/*--------------------------- strings -----------------------------*/
	.globl	_lognam
_lognam:
	.ascii	"RAM:awmaster.log\0"
	.byte	0			/* original has a second pad NUL */

/*--------------------------- func table --------------------------*/
	.data
	.globl	_mFuncTable
_mFuncTable:
	.long	_mLibOpen
	.long	_mLibClose
	.long	_mLibExpunge
	.long	_mLibNull
	.long	_InitAmiSSLMaster
	.long	_OpenAmiSSL
	.long	_CloseAmiSSL
	.long	_OpenAmiSSLCipher
	.long	_CloseAmiSSLCipher
	.long	_OpenAmiSSLTagList
	.long	0xffffffff
