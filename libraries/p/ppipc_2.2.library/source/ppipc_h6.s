/* ppipc.library 2.2 -- hunk6 BSS (16 bytes)
 * internal port list head (NewList'd by init, AddHead/FindName/
 * Remove via exec list calls). */

	.globl	_portlist

	.bss
_portlist:
	.space	16				/* 4 longs */
