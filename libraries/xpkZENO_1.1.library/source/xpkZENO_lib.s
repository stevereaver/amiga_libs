|||
|||	xpkZENO_lib.s -- resident/AutoInit structure, XPK info
|||	descriptor and mode chain for xpkZENO.library 1.1.
||||
||||	Reconstructed layout (original hunk offsets):
||||	  0x00  entry stub (moveq #0,d0; rts), EndSkip 0x85a
||||	  0x04  RomTag 0x4afc / AUTOINIT
||||	  0x1e  pad long (20-byte inittab image source)
||||	  0x22  InitTable {dataSize 0x44, functab, datatab 0, LibInit}
||||	  0x36  word-offset functab, 10 vectors
||||	  0x4e  "xpkZENO.library"
||||	  0x5e  "xpkZENO 1.1\r\n"
||||	  0x6c  descriptor strings
||||	  0xb2  rehash modulus table (pack reads it out of code)
||||	  0xbc  dead "15 bit" mode record (old 30-byte format,
||||	        unlinked -- nothing points at it)
||||	  0xe4  "14 bit" mode record
||||	  0x10e "13 bit"
||||	  0x138 "12 bit" (list head)
||||	  0x162 XpkInfo descriptor
||||	  0x1ba LibInit
|||

	.section .text

	.globl	_start
_start:
	moveq	#0,%d0
	rts

	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_end			/* EndSkip -> end of hunk	    */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	1			/* version		    */
	.byte	9			/* NT_LIBRARY		    */
	.byte	0			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

/* the 20-byte image LibInit clones to lib+48:
 * pad long + InitTable + fixup count (0 = empty)		    */
	.globl	_inittab_img
_inittab_img:
	.long	0
	.globl	_inittab
_inittab:
	.long	0x44			/* dataSize 68: Library+seg@34   */
	.long	_functab		/*   +20 bytes cloned to +48     */
	.long	0			/* datatab: none		    */
	.long	_LibInit		/* init function		    */
	.long	0			/* fixup count = 0		    */

	.globl	_libname
_libname:
	.ascii	"xpkZENO.library"
	.byte	0
	.globl	_idstr
_idstr:
	.ascii	"xpkZENO 1.1"
	.byte	13,10,0
	.even

/* ------------------------------------------------------------ */
/* XpkInfo descriptor + mode chain + strings			    */
/* ------------------------------------------------------------ */

	.globl	_xpkinfo
_xpkinfo:
	.word	1			/* xi_XpkInfoVersion	    */
	.word	0			/* xi_LibVersion	    */
	.word	0			/* xi_MasterVersion	    */
	.word	0			/* xi_ModesVersion	    */
	.long	_s_name			/* xi_Name "ZENO"	    */
	.long	_s_longname		/* xi_LongName "Zeno 1.1"    */
	.long	_s_basedesc		/* xi_Description	    */
	.long	0x5a454e4f		/* xi_ID = 'ZENO'	    */
	.long	0xa009			/* xi_Flags		    */
	.long	0x7fffffff		/* xi_MaxPkInChunk	    */
	.long	0x80			/* xi_MinPkInChunk (=128;    */
					/*   pack reads this as its  */
					/*   short-input gate const) */
	.long	0x8000			/* xi_DefPkInChunk	    */
	.long	_s_packmsg		/* xi_PackMsg		    */
	.long	_s_unpackmsg		/* xi_UnpackMsg		    */
	.long	_s_packedmsg		/* xi_PackedMsg		    */
	.long	_s_unpackedmsg		/* xi_UnpackedMsg	    */
	.word	0x32			/* xi_DefMode = 50	    */
	.word	0			/* xi_Pad		    */
	.long	_s_mode12		/* xi_ModeDesc		    */
	.long	0,0,0,0,0,0		/* xi_Reserved		    */

/* dead "15 bit" mode record at original hunk+0xbc: the old
 * 30-byte record format (no xm_ChunkSize pad word).  Nothing in
 * the mode chain points at it -- leftover from a 15-bit mode
 * that was dropped.  Kept for fidelity.			    */
_s_mode15:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	6			/* xm_Flags		    */
	.long	170			/* xm_PackMemory	    */
	.long	96			/* xm_UnpackMemory	    */
	.long	140			/* xm_PackSpeed	    */
	.long	240			/* xm_UnpackSpeed	    */
	.word	0x0140			/* xm_Ratio = 320	    */
	.ascii	"15 bit"
	.byte	0,0,0,0			/* name padded to 10	    */

_s_mode14:
	.long	0			/* xm_Next		    */
	.long	100			/* xm_Upto		    */
	.long	6			/* xm_Flags		    */
	.long	90			/* xm_PackMemory	    */
	.long	48			/* xm_UnpackMemory	    */
	.long	140			/* xm_PackSpeed	    */
	.long	240			/* xm_UnpackSpeed	    */
	.word	0x0140			/* xm_Ratio = 320	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"14 bit"
	.byte	0,0,0,0

_s_mode13:
	.long	_s_mode14		/* xm_Next		    */
	.long	66			/* xm_Upto		    */
	.long	6			/* xm_Flags		    */
	.long	50			/* xm_PackMemory	    */
	.long	24			/* xm_UnpackMemory	    */
	.long	140			/* xm_PackSpeed	    */
	.long	240			/* xm_UnpackSpeed	    */
	.word	0x0140			/* xm_Ratio = 320	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"13 bit"
	.byte	0,0,0,0

_s_mode12:
	.long	_s_mode13		/* xm_Next		    */
	.long	33			/* xm_Upto		    */
	.long	6			/* xm_Flags		    */
	.long	30			/* xm_PackMemory	    */
	.long	12			/* xm_UnpackMemory	    */
	.long	140			/* xm_PackSpeed	    */
	.long	240			/* xm_UnpackSpeed	    */
	.word	0x0140			/* xm_Ratio = 320	    */
	.word	0			/* xm_ChunkSize	    */
	.ascii	"12 bit"
	.byte	0,0,0,0

_s_name:
	.ascii	"ZENO"
	.byte	0
_s_longname:
	.ascii	"Zeno 1.1"
	.byte	0
_s_basedesc:
	.ascii	"LZ78 12-14bit"
	.byte	0
_s_packmsg:
	.ascii	"compressing"
	.byte	0
_s_unpackmsg:
	.ascii	"expanding"
	.byte	0
_s_packedmsg:
	.ascii	"compressed"
	.byte	0
_s_unpackedmsg:
	.ascii	"expanded"
	.byte	0

/* rehash modulus table (the original reads it out of code bytes
 * at hunk+0xb2+2*(bits-12)); the C keeps it inline, emitted here
 * for completeness/fidelity					    */
_modtab:
	.word	0x1003			/* bits 12		    */
	.word	0x2011			/* bits 13		    */
	.word	0x47fb			/* bits 14		    */
	.word	0x87f7			/* bits 15 (dead)	    */
	.even

	.globl	_end
_end:
