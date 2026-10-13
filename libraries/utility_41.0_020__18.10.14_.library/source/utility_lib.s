|
| utility.library 41.0 (18.10.2014) — resident skeleton + asm routines
|
| RomTag at hunk+0, InitTable at +0x1a, word-offset functab
| (marker 0xffff, offsets relative to functab start, 0xffff term).
| datatab=NULL -> exec default init (ln_Type/Name/Version/IdString
| from the Resident struct); lib_Revision cleared by LibInit.
|
| The six m68020 stubs are patched over the software math vectors
| at init when AttnFlags shows a 68020+ (68060: first two only,
| since divl/64-bit mul are emulated there).
|

	.text
	.globl	_romtag

_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_endres
	.byte	0x81		| RTF_AUTOINIT | RTF_COLDSTART
	.byte	41		| rt_Version
	.byte	9		| NT_LIBRARY
	.byte	103		| rt_Pri
	.long	_libname
	.long	_idstr
	.long	_inittab

_inittab:
	.long	0x30		| dataSize = 48
	.long	_functab
	.long	0		| initData = NULL -> default init
	.long	_LibInit

_functab:
	.word	-1		| word-offset table marker
	.word	_vec_LibOpen-_functab
	.word	_vec_LibClose-_functab
	.word	_vec_LibExpunge-_functab
	.word	_vec_LibReserved-_functab
	.word	_vec_FindTagItem-_functab
	.word	_vec_GetTagData-_functab
	.word	_vec_PackBoolTags-_functab
	.word	_vec_NextTagItem-_functab
	.word	_vec_FilterTagChanges-_functab
	.word	_vec_MapTags-_functab
	.word	_vec_AllocateTagItems-_functab
	.word	_vec_CloneTagItems-_functab
	.word	_vec_FreeTagItems-_functab
	.word	_vec_RefreshTagItemClones-_functab
	.word	_vec_TagInArray-_functab
	.word	_vec_FilterTagItems-_functab
	.word	_CallHookPkt-_functab
	.word	_vec_LibReserved-_functab	| -108
	.word	_vec_LibReserved-_functab	| -114
	.word	_vec_Amiga2Date-_functab
	.word	_vec_Date2Amiga-_functab
	.word	_vec_CheckDate-_functab
	.word	_SMult32-_functab
	.word	_UMult32-_functab	| shares SMult32 impl
	.word	_SDivMod32-_functab
	.word	_UDivMod32-_functab
	.word	_vec_Stricmp-_functab
	.word	_vec_Strnicmp-_functab
	.word	_vec_ToUpper-_functab
	.word	_vec_ToLower-_functab
	.word	_vec_ApplyTagChanges-_functab
	.word	_vec_LibReserved-_functab	| -192
	.word	_SMult64-_functab
	.word	_UMult64-_functab
	.word	_vec_PackStructureTags-_functab
	.word	_vec_UnpackStructureTags-_functab
	.word	_vec_AddNamedObject-_functab
	.word	_vec_AllocNamedObjectA-_functab
	.word	_AttemptRemNamedObject-_functab
	.word	_vec_FindNamedObject-_functab
	.word	_vec_FreeNamedObject-_functab
	.word	_vec_NamedObjectName-_functab
	.word	_vec_ReleaseNamedObject-_functab
	.word	_vec_RemNamedObject-_functab
	.word	_vec_GetUniqueID-_functab
	.word	_vec_LibReserved-_functab	| -276
	.word	_vec_LibReserved-_functab	| -282
	.word	_vec_LibReserved-_functab	| -288
	.word	_vec_LibReserved-_functab	| -294
	.word	-1		| terminator

|| vector trampolines: same-section targets so the .word diffs
|| assemble exactly (cross-object .word A-B relocs are broken in
|| the amiga-hunk linker backend); the pc-relative bras is
|| resolved correctly at link time.
_vec_LibOpen:	.short	0x4ef9
	.long	_LibOpen
_vec_LibClose:	.short	0x4ef9
	.long	_LibClose
_vec_LibExpunge:	.short	0x4ef9
	.long	_LibExpunge
_vec_LibReserved:	.short	0x4ef9
	.long	_LibReserved
_vec_FindTagItem:	.short	0x4ef9
	.long	_FindTagItem
_vec_GetTagData:	.short	0x4ef9
	.long	_GetTagData
_vec_PackBoolTags:	.short	0x4ef9
	.long	_PackBoolTags
_vec_NextTagItem:	.short	0x4ef9
	.long	_NextTagItem
_vec_FilterTagChanges:	.short	0x4ef9
	.long	_FilterTagChanges
_vec_MapTags:	.short	0x4ef9
	.long	_MapTags
_vec_AllocateTagItems:	.short	0x4ef9
	.long	_AllocateTagItems
_vec_CloneTagItems:	.short	0x4ef9
	.long	_CloneTagItems
_vec_FreeTagItems:	.short	0x4ef9
	.long	_FreeTagItems
_vec_RefreshTagItemClones:	.short	0x4ef9
	.long	_RefreshTagItemClones
_vec_TagInArray:	.short	0x4ef9
	.long	_TagInArray
_vec_FilterTagItems:	.short	0x4ef9
	.long	_FilterTagItems
_vec_Amiga2Date:	.short	0x4ef9
	.long	_Amiga2Date
_vec_Date2Amiga:	.short	0x4ef9
	.long	_Date2Amiga
_vec_CheckDate:	.short	0x4ef9
	.long	_CheckDate
_vec_Stricmp:	.short	0x4ef9
	.long	_Stricmp
_vec_Strnicmp:	.short	0x4ef9
	.long	_Strnicmp
_vec_ToUpper:	.short	0x4ef9
	.long	_ToUpper
_vec_ToLower:	.short	0x4ef9
	.long	_ToLower
_vec_ApplyTagChanges:	.short	0x4ef9
	.long	_ApplyTagChanges
_vec_PackStructureTags:	.short	0x4ef9
	.long	_PackStructureTags
_vec_UnpackStructureTags:	.short	0x4ef9
	.long	_UnpackStructureTags
_vec_AddNamedObject:	.short	0x4ef9
	.long	_AddNamedObject
_vec_AllocNamedObjectA:	.short	0x4ef9
	.long	_AllocNamedObjectA
_vec_FindNamedObject:	.short	0x4ef9
	.long	_FindNamedObject
_vec_FreeNamedObject:
	| original bug: FreeVec arg goes to a0, not a1 -> frees stale a1
	movel	a0,d0
	beqs	1f
	movel	a6,sp@-
	movel	a6@(36),a6
	lea	a0@(-16),a0
	jsr	a6@(-690)
	movel	sp@+,a6
1:	rts
_vec_NamedObjectName:	.short	0x4ef9
	.long	_NamedObjectName
_vec_ReleaseNamedObject:	.short	0x4ef9
	.long	_ReleaseNamedObject
_vec_RemNamedObject:	.short	0x4ef9
	.long	_RemNamedObject
_vec_GetUniqueID:	.short	0x4ef9
	.long	_GetUniqueID
	.even

| --- 68020+ replacement vectors (patched in by LibInit) -------
	.globl	_stub_smult32,_stub_umult32,_stub_sdivmod32
	.globl	_stub_udivmod32,_stub_smult64,_stub_umult64

_stub_smult32:
	muls.l	d1,d0
	rts
_stub_umult32:
	mulu.l	d1,d0
	rts
_stub_sdivmod32:
	divsl.l	d1,d1:d0
	rts
_stub_udivmod32:
	divul.l	d1,d1:d0
	rts
_stub_smult64:
	muls.l	d1,d1:d0
	rts
_stub_umult64:
	mulu.l	d1,d1:d0
	rts

| --- patch table: {word vector-offset, long stub} --------------
	.globl	_patchtab
_patchtab:
	.word	-138
	.long	_stub_smult32
	.word	-144
	.long	_stub_umult32
	.word	-150
	.long	_stub_sdivmod32
	.word	-156
	.long	_stub_udivmod32
	.word	-198
	.long	_stub_smult64
	.word	-204
	.long	_stub_umult64

| --- CallHookPkt: tail-jump hook->h_Entry ---------------------
	.globl	_CallHookPkt
_CallHookPkt:
	movel	a0@(8),sp@-
	rts

| --- AttemptRemNamedObject: RemNamedObject(obj, NULL) ---------
	.globl	_AttemptRemNamedObject
_AttemptRemNamedObject:
	subal	a1,a1
	bra	_RemNamedObject

| --- software math defaults (68000-compatible) -----------------
| UMult32/SMult32 shared: low 32 bits of product, sign-agnostic
	.globl	_SMult32,_UMult32
_SMult32:
_UMult32:
	movel	d2,sp@-
	movel	d0,sp@-
	muluw	d1,d0		| lo*lo
	movel	d1,d2
	muluw	sp@+,d1		| hi(a)*lo(b)   (pops a.hi word)
	swap	d2
	muluw	sp@+,d2		| lo(a)*hi(b)   (pops a.lo word)
	addw	d2,d1
	swap	d1
	movel	sp@+,d2
	clrw	d1
	addl	d1,d0
	rts

| SDivMod32 -> sign fixup around UDivMod32
	.globl	_SDivMod32,_UDivMod32
_SDivMod32:
	tstl	d0
	bpls	1f
	negl	d0
	tstl	d1
	bpls	2f
	negl	d1
	bsrs	_UDivMod32
	negl	d1
	rts
2:	bsrs	_UDivMod32
	negl	d0
	negl	d1
	rts
1:	tstl	d1
	bpls	_UDivMod32
	negl	d1
	bsrs	_UDivMod32
	negl	d0
	rts

| UDivMod32(d0,d1) -> d0=quot d1=rem
_UDivMod32:
	movel	d1,sp@-
	tstw	sp@+
	bnes	5f
	swap	d0
	movew	d0,d1
	beqs	4f
	divuw	sp@,d1
	movew	d1,d0
4:	swap	d0
	movew	d0,d1
	divuw	sp@+,d1
	movew	d1,d0
	clrw	d1
	swap	d1
	rts
5:	movew	d2,sp@
	movel	d3,sp@-
	moveq	#15,d3
	movew	d3,d2
	exg	d3,d1
	swap	d0
	movew	d0,d1
	clrw	d0
6:	addl	d0,d0
	addxl	d1,d1
	cmpl	d1,d3
	bhis	7f
	subl	d3,d1
	addqw	#1,d0
7:	dbf	d2,6b
	movel	sp@+,d3
	movew	sp@+,d2
	rts

| SMult64 -> sign fixup around UMult64
	.globl	_SMult64,_UMult64
_SMult64:
	movel	d2,sp@-
	moveq	#0,d2
	tstl	d0
	bpls	8f
	negl	d0
	moveq	#1,d2
8:	tstl	d1
	bpls	9f
	negl	d1
	subqw	#1,d2
9:	bsrs	_UMult64
	tstl	d2
	beqs	10f
	moveq	#0,d2
	notl	d0
	notl	d1
	addql	#1,d0
	addxl	d2,d1
10:	movel	sp@+,d2
	rts

| UMult64(d0,d1) -> d0:hi d1:lo
_UMult64:
	movel	d2,sp@-
	movew	d0,sp@-
	movel	d1,d2
	swap	d2
	movel	d2,sp@-
	muluw	d0,d1		| P0 = alo*blo
	swap	d0
	muluw	d0,d2		| P3 = ahi*bhi
	swap	d1
	muluw	sp@+,d0		| P1 = ahi*blo
	addw	d0,d1
	clrw	d0
	swap	d0
	addxl	d2,d0
	movew	sp@+,d2
	muluw	sp@+,d2		| P2 = bhi*alo
	addw	d2,d1
	clrw	d2
	swap	d2
	addxl	d2,d0
	movel	sp@+,d2
	swap	d1
	rts

| --- strings --------------------------------------------------
	.globl	_libname,_idstr
_libname:
	.asciz	"utility.library"
_idstr:
	.ascii	"utility 41.0 (18.10.2014)\r\n\0"
