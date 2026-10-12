	.file	"pointer_lib.s"
	.text

/*
**	pointer_lib.s -- resident module structure for
**	pointer.library 33.2 "PointerLibrary 33.2 (5 Jan 1991)".
**
**	Three hunks: CODE + DATA|CHIP (embedded pointer bitmap) +
**	DATA (InitTable + copied data block + fixup table).
**
**	hunk+0:   run stub returning 20 (RETURN_ERROR under the shell)
**	hunk+4:   IdString "PointerLibrary 33.2 (5 Jan 1991)\r\n"
**	hunk+0x24:-24 functab slot lands on the idstr's \r\n\0\0 tail
**	hunk+0x28:RomTag (RTF_AUTOINIT, ver 33, NT_LIBRARY)
**		  rt_Name -> "pointer.library", rt_IdString -> hunk+4,
**		  rt_Init -> data hunk +4 (the embedded InitTable),
**		  rt_EndSkip -> data hunk +0x50
**
**	InitTable (.data+4): { dataSize=0x8a, funcTable=_functab,
**	dataTable=0, initFunc=_LibInit } -- MakeLibrary creates the
**	0x8a-byte base, installs the LONG-address functab, then calls
**	LibInit which fills the node fields and manually copies the
**	0x50-byte data block into lib+0x32 applying the fixup list.
**
**	Original vector map (LONG functab):
**	  -6  Open            -30 LibFunc0 SetPointer(window)
**	  -12 Close           -36 LibFunc1 LoadSpec(path)
**	  -18 Expunge         -42 LibFunc2 FreeSpec(spec)
**	  -24 idstr tail (\r\n\0\0 -> movep/illegal)
*/

	.globl	_start
_start:
	moveq	#20,%d0
	rts

	.globl	_idstr
_idstr:
	.ascii	"PointerLibrary 33.2 (5 Jan 1991)"
	.globl	_reserved
_reserved:
	.byte	0x0d,0x0a,0,0

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_datablk+0x50		/* rt_EndSkip -> data+0x50   */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	33			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_datablk+4		/* rt_Init -> InitTable	    */
	.word	0

/* ------------------------------------------------------------------ */
/* strings used by the code hunk					    */
/* ------------------------------------------------------------------ */

	.globl	_libname
_libname:
	.ascii	"pointer.library"
	.byte	0
	.globl	_libdesc
_libdesc:
	.ascii	"Pointer Library"
	.byte	0

/* ------------------------------------------------------------------ */
/* LONG-offset function table (terminated by -1)			    */
/* ------------------------------------------------------------------ */

	.globl	_functab
_functab:
	.long	_LibOpen		/* -6			    */
	.long	_LibClose		/* -12			    */
	.long	_LibExpunge		/* -18			    */
	.long	_reserved		/* -24 -> idstr tail	    */
	.long	_PtrSetPointer		/* -30 SetPointer wrapper   */
	.long	_PtrLoadSpec		/* -36 ILBM spec loader	    */
	.long	_PtrFreeSpec		/* -42 spec destructor	    */
	.long	-1

/* ------------------------------------------------------------------ */
/* hunk 1: DATA|CHIP -- embedded fallback 16x16 pointer bitmap	    */
/* ------------------------------------------------------------------ */

	.section .datachip
	.globl	_bitmap
_bitmap:
	.long	0			/* sprite control pad	    */
	.long	0x040007c0,0x000007c0,0x01000380,0x000007e0
	.long	0x07c01ff8,0x1ff03fec,0x3ff87fde,0x3ff87fbe
	.long	0x7ffcff7f,0x7efcffff,0x7ffcffff,0x3ff87ffe
	.long	0x3ff87ffe,0x1ff03ffc,0x07c01ff8,0x000007e0
	.long	0

/* ------------------------------------------------------------------ */
/* hunk 2: DATA -- InitTable at +4, copied block, fixup table	    */
/* ------------------------------------------------------------------ */

	.data
	.globl	_datablk
_datablk:
	.long	0			/* +0x00 reserved	    */
	.globl	_inittab		/* +0x04 InitTable (rt_Init)*/
_inittab:
	.long	0x8a			/* dataSize		    */
	.long	_functab		/* funcTable		    */
	.long	0			/* dataTable		    */
	.long	_LibInit		/* initFunc		    */
	.long	0			/* +0x14 exec slot	    */
	.long	0			/* +0x18 intuition slot	    */
	.long	_bitmap			/* +0x1c spec[0] image	    */
	.long	0x10			/* +0x20 spec[1] height	    */
	.long	0x10			/* +0x24 spec[2] width	    */
	.long	-6			/* +0x28 spec[3] xoff	    */
	.long	0			/* +0x2c spec[4] yoff	    */
	.long	0			/* +0x30 spec[5] bodysize   */
	.long	0x1c			/* +0x34 spec ptr -> blk+0x1c*/
	.long	0x494c424d		/* +0x38 'ILBM' prop list   */
	.long	0x424d4844		/*	'BMHD'		    */
	.long	0x494c424d		/*	'ILBM'		    */
	.long	0x434d4150		/*	'CMAP'		    */
	.long	0x494c424d		/*	'ILBM'		    */
	.long	0x47524142		/*	'GRAB'		    */
	.globl	_fixuptab		/* +0x50 fixup table (rt_EndSkip) */
_fixuptab:
	.long	1			/* count		    */
	.long	0x34			/* offset -> spec ptr slot  */
