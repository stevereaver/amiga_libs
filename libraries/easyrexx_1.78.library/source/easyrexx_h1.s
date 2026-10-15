/* easyrexx.library 1.78 -- hunk1: DATA, 24 B.
 * +0    dead rebase count (0: initfn's fixup loop never runs)
 * +4    InitTable: dsize 0x54, ftab->_functab, dtab=0, initfn->_initfn
 * +0x14 spare longword
 * NB: the four tail thunks load (abs.l) a6 from _gd+0x18 -- one
 * longword past the end of this 24-byte hunk; reproduced verbatim. */
	.data
	.globl	_gd
_gd:	.long	0,0x54,_functab,0,_initfn,0
