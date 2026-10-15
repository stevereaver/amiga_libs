/* ppipc.library 2.2 -- hunk0 CODE (0x58 bytes)
 * moveq#20/rts stub + RomTag (AUTOINIT, rt_Version 1, NT_LIBRARY)
 *   name    -> hunk2+0    "ppipc.library"
 *   idstr   -> hunk2+0xe  "PPIPC version 2.2 89:04:17\n"
 *   init    -> hunk2+0x8a (InitTable)
 * helpers: NewList @0x20 (stack arg -> a0, standard 3-store init),
 * strlen @0x34, strcpy @0x48 (stack args, amiga.lib style). */

	.globl	_libname,_idstr,_inittab,_newlist,_strlen,_strcpy

	.text

/* ==== 0x00 run-stub + RomTag ===================================== */
	moveq	#20,%d0				/* 0x00: returns 20 */
	rts
_romtag:					/* 0x04 */
	.short	0x4afc
	.long	_romtag				/* matchtag -> h0+4 */
	.long	_endskip			/* endskip  -> h0+0x1e */
	.byte	0x80,1				/* RTF_AUTOINIT, version 1 */
	.byte	9,0				/* NT_LIBRARY, pri 0 */
	.long	_libname			/* -> hunk2+0 */
	.long	_idstr				/* -> hunk2+0xe */
	.long	_inittab			/* -> hunk2+0x8a */
_endskip:
	.short	0				/* 0x1e pad */

/* ==== 0x20 NewList(arg): stack arg -> a0 ========================== */
_newlist:
	moveal	%sp@(4),%a0
	movel	%a0,%a0@			/* *arg = arg */
	addql	#4,%a0@				/* lh_Head = &lh_Tail */
	clrl	%a0@(4)				/* lh_Tail = 0 */
	movel	%a0,%a0@(8)			/* lh_TailPred = &lh_Head */
	rts
	.short	0				/* 0x32 pad */

/* ==== 0x34 strlen(str): -> d0 ==================================== */
_strlen:
	moveal	%sp@(4),%a0
	movel	%a0,%d0
1:	tstb	%a0@+
	bnes	1b
	subqw	#1,%a0
	subal	%d0,%a0
	movel	%a0,%d0
	rts
	.short	0				/* 0x46 pad */

/* ==== 0x48 strcpy(dst,src): -> d0 = dst ========================== */
_strcpy:
	moveal	%sp@(8),%a0			/* src */
	moveal	%sp@(4),%a1			/* dst */
	movel	%a1,%d0
2:	moveb	%a0@+,%a1@+
	bnes	2b
	rts
