|||
|||	intuisupport_lib.s -- resident module header + AUTOINIT tables
|||	for intuisupport.library 1.1
|||
|||	The shipped binary is non-standard: its RomTag rt_Init is
|||	patched by a hunk-1 relocation to point at an InitTable stored
|||	in the DATA hunk, whose funcTable/initRoutine fields hold raw
|||	code offsets rather than relocated pointers (a custom-loader
|||	convention -- stock exec cannot bootstrap it).  This rebuild
|||	uses a conventional AUTOINIT InitTable in .data; the DATA hunk
|||	contents themselves are preserved as the private template that
|||	LibInit copies into the library base at +46.
|||
|||	Vectors: -6 Open, -12 Close, -18 Expunge, -24 reserved,
|||	-30 Make3DBorder, -36 FreeBorder, -42 AllocBufList,
|||	-48 FreeBufList, -54 ResetBufList, -60 FillBuf, -66 ClrBuf,
|||	-72 StrLen, -78 ISCopyMem, -84 AbortAlert, -90 DrawText.
|||

	.section .text

||| executable entry for non-resident loaders: returns 0
	moveq	#0,d0
	rts

_romtag:
	.word	0x4afc			| RT_MATCHWORD
	.long	_romtag			| RT_MATCHTAG
	.long	_end			| RT_ENDSKIP
	.byte	0x80			| RTF_AUTOINIT
	.byte	1			| RT_VERSION
	.byte	9			| NT_LIBRARY
	.byte	0			| RT_PRI
	.long	_libname		| RT_NAME
	.long	_idstr			| RT_IDSTRING
	.long	_inittab		| RT_INIT

	.globl	_libname
	.globl	_idstr
	.globl	_istempl

	.section .data

||| InitTable: dataSize 0xb2 = sizeof(struct ISBase) (34 lib + 4 seg
||| + 8 pad + 132 private area)
_inittab:
	.long	0xb2			| dataSize
	.long	_functab
	.long	0			| no InitStruct data
	.long	_LibInit

||| absolute-longword function table, -1 terminated
||| (first word != 0xffff so exec uses pointer mode -- same scheme
|||  as the original's table at code+0x67c)
_functab:
	.long	_LibOpen		| -6
	.long	_LibClose		| -12
	.long	_LibExpunge		| -18
	.long	0			| -24 reserved
	.long	_Make3DBorder		| -30
	.long	_FreeBorder		| -36
	.long	_AllocBufList		| -42
	.long	_FreeBufList		| -48
	.long	_ResetBufList		| -54
	.long	_FillBuf		| -60
	.long	_ClrBuf			| -66
	.long	_StrLen			| -72
	.long	_ISCopyMem		| -78
	.long	_AbortAlert		| -84
	.long	_DrawText		| -90
	.long	-1

||| the shipped DATA hunk, used by LibInit as the 124-byte private
||| template (the last long is the fixup count, always 0)
_istempl:
	.long	0			| +0   pad
	.long	0xb2			| +4   dead inittab image
	.long	0x67c			| +8   dead inittab image
	.long	0			| +12
	.long	0x20			| +16
	.ascii	"Nach Bet\344tigung einer Maustaste wird das Programm beendet !!"
	.byte	0			| +80  NUL
	.byte	0,0,0			| +81,82,83 pad
	.byte	0x00,0x50,0x10,0x1c	| +84..87 alert bytes
	.ascii	"intuition.library"
	.byte	0			| +105
	.ascii	"graphics.library"
	.byte	0,0			| +122,123
	.long	0			| +124 fixup count (0)

_libname:
	.ascii	"intuisupport.library"
	.byte	0
_idstr:
	.ascii	"intuisupport.library"
	.byte	0,0,0,0			| pad to long

	.even
_end:

||| ------------------------------------------------------------------
|||	vector entry stubs -- the original uses a register-parameter
|||	ABI (args in d0-d7/a0-a5); each stub pushes the args and jsr's
|||	the normal-ABI C body, then cleans the stack.
||| ------------------------------------------------------------------
	.section .text

	.globl	_Make3DBorder
	.globl	_FreeBorder
	.globl	_AllocBufList
	.globl	_FreeBufList
	.globl	_ResetBufList
	.globl	_FillBuf
	.globl	_ClrBuf
	.globl	_StrLen
	.globl	_ISCopyMem
	.globl	_AbortAlert
	.globl	_DrawText

||| -30: Make3DBorder(w=d0,h=d1,x=d2,y=d3,penA=d4,penB=d5,next=a0)
_Make3DBorder:
	movel	a6,sp@-			| base
	movel	a0,sp@-			| next
	movel	d5,sp@-
	movel	d4,sp@-
	movel	d3,sp@-
	movel	d2,sp@-
	movel	d1,sp@-
	movel	d0,sp@-			| w
	jbsr	_is_Make3DBorder
	lea	sp@(32),sp
	rts

||| -36: FreeBorder(b=a3)
_FreeBorder:
	movel	a6,sp@-
	movel	a3,sp@-
	jbsr	_is_FreeBorder
	addqw	#8,sp
	rts

||| -42: AllocBufList(size=d0)
_AllocBufList:
	movel	a6,sp@-
	movel	d0,sp@-
	jbsr	_is_AllocBufList
	addqw	#8,sp
	rts

||| -48: FreeBufList(h=a3)
_FreeBufList:
	movel	a6,sp@-
	movel	a3,sp@-
	jbsr	_is_FreeBufList
	addqw	#8,sp
	rts

||| -54: ResetBufList(obj=a3)
_ResetBufList:
	movel	a6,sp@-
	movel	a3,sp@-
	jbsr	_is_ResetBufList
	addqw	#8,sp
	rts

||| -60: FillBuf(dst=a5,byte=d7,len=d6)
_FillBuf:
	movel	a6,sp@-
	movel	d6,sp@-
	movel	d7,sp@-
	movel	a5,sp@-
	jbsr	_is_FillBuf
	lea	sp@(16),sp
	rts

||| -66: ClrBuf(dst=a5,len=d7)
_ClrBuf:
	movel	a6,sp@-
	movel	d7,sp@-
	movel	a5,sp@-
	jbsr	_is_ClrBuf
	lea	sp@(12),sp
	rts

||| -72: StrLen(s=a5) -> d0
_StrLen:
	movel	a6,sp@-
	movel	a5,sp@-
	jbsr	_is_StrLen
	addqw	#8,sp
	rts

||| -78: ISCopyMem(src=a3,dst=a5,len=d7)
_ISCopyMem:
	movel	a6,sp@-
	movel	d7,sp@-
	movel	a5,sp@-
	movel	a3,sp@-
	jbsr	_is_ISCopyMem
	lea	sp@(16),sp
	rts

||| -84: AbortAlert(text=a5,callback=a3)
_AbortAlert:
	movel	a6,sp@-
	movel	a3,sp@-
	movel	a5,sp@-
	jbsr	_is_AbortAlert
	lea	sp@(12),sp
	rts

||| -90: DrawText(obj=a3,pen=d5,bgpen=d4,x=d7,y=d6,text=a5)
_DrawText:
	movel	a6,sp@-
	movel	a5,sp@-
	movel	d6,sp@-
	movel	d7,sp@-
	movel	d4,sp@-
	movel	d5,sp@-
	movel	a3,sp@-			| obj
	jbsr	_is_DrawText
	lea	sp@(28),sp
	rts
