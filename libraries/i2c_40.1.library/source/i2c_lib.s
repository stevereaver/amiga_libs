	.file	"i2c_lib.s"
	.text

/*
**	i2c.library 40.1 -- AUTOINIT skeleton + data tables
**
**	Reconstructed layout (original hunk offsets):
**	  0x000  EndSkip stub (moveq #10,d0; rts)
**	  0x004  RomTag 0x4afc / AUTOINIT, rt_EndSkip -> libname
**	  0x01e  "i2c.library"
**	  0x02a  idstring
**	  0x064  init table (dataSize 0xc2)
**	  0x074  function table -- 14 absolute longs + ffffffff
**	  0x0b0  data table
**	  0x0f0  error-code -> string-offset table (17 entries)
**	  0x101  "OK" + error string block
**	  0x19c  code (LibInit ...)
**
**	The last table entry's byte (0x4f) doubles as the 'O' of the
**	"OK" string -- the string base used by I2CErrText is that
**	very byte, so the table is exactly 17 entries.
*/

	.globl	_start
_start:
	moveq	#10,%d0
	rts

/* -------- RomTag ------------------------------------------------- */
	.globl	_romtag
_romtag:
	.word	0x4afc
	.long	_romtag
	.long	_libname		/* rt_EndSkip -> name	    */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	40			/* version = 40		    */
	.byte	0x09			/* NT_LIBRARY		    */
	.byte	0x00			/* pri			    */
	.long	_libname
	.long	_idstr
	.long	_inittab

_libname:
	.ascii	"i2c.library"
	.byte	0
_idstr:
	.ascii	"i2c.library 40.1 (18 Jul 99) for PFC8584 bus controller"
	.byte	13,10,0

/* -------- InitTable ---------------------------------------------- */
_inittab:
	.long	0x000000c2		/* dataSize 0xc2 = 194	    */
	.long	_functab
	.long	_datatab
	.long	_LibInit

_functab:
	.long	_LibOpen		/* -6			   */
	.long	_LibClose		/* -12			   */
	.long	_LibExpunge		/* -18			   */
	.long	_LibNull		/* -24			   */
	.long	_I2CProbe		/* -30			   */
	.long	_I2CReset		/* -36			   */
	.long	_I2CDelay		/* -42			   */
	.long	_I2CReserved		/* -48			   */
	.long	_I2CWrite		/* -54			   */
	.long	_I2CRead		/* -60			   */
	.long	_I2CStub		/* -66			   */
	.long	_I2CErrText		/* -72			   */
	.long	_I2CShutdown		/* -78			   */
	.long	_I2CReEnable		/* -84			   */
	.word	0xffff
	.word	0xffff

/* -------- datatab (exact bytes) ---------------------------------- */
	.globl	_datatab
_datatab:
	.byte	0xa0,0x08		/* INITBYTE @8 -> ln_Type   */
	.byte	0x09,0x00		/*  = 9			    */
	.byte	0x80,0x0a		/* INITLONG @0xa -> ln_Name */
	.long	_libname
	.byte	0x80,0x18		/* INITLONG @0x18 -> IdStr  */
	.long	_idstr
	.byte	0x90,0x14		/* INITWORD @0x14 -> ver    */
	.word	0x0028			/*  = 40		    */
	.byte	0x90,0x16		/* INITWORD @0x16 -> rev    */
	.word	0x0001			/*  = 1			    */
	.byte	0xa0,0x0e		/* INITBYTE @0xe -> flags   */
	.byte	0x06,0x00		/*  = 6			    */
	.byte	0xa0,0x42		/* INITBYTE @0x42 = 4	    */
	.byte	0x04,0x00
	.byte	0xa0,0x9e		/* INITBYTE @0x9e = 2	    */
	.byte	0x02,0x00		/*  intr.ln_Type	    */
	.byte	0x80,0xa0		/* INITLONG @0xa0	    */
	.long	_libname		/*  intr.ln_Name	    */
	.byte	0x80,0xa8		/* INITLONG @0xa8	    */
	.long	_I2CIntr		/*  intr.is_Code	    */
	.byte	0xa0,0xb4		/* INITBYTE @0xb4 = 2	    */
	.byte	0x02,0x00		/*  intr2.ln_Type	    */
	.byte	0xa0,0xb5		/* INITBYTE @0xb5 = 0x7d    */
	.byte	0x7d,0x00		/*  intr2.ln_Pri	    */
	.byte	0x80,0xb6		/* INITLONG @0xb6	    */
	.long	_libname		/*  intr2.ln_Name	    */
	.word	0			/* terminator		    */

/* -------- error table + strings ---------------------------------- */
	.globl	_errtab
_errtab:
	.byte	0x00,0x03,0x11,0x1a,0x96,0x96,0x29,0x96
	.byte	0x39,0x4a,0x58,0x68,0x96,0x7d,0x96,0x90
	.byte	0x96
	.globl	_errstr
_errstr:
	.ascii	"OK"			/* entry 0		    */
	.byte	0
	.ascii	"data rejected"
	.byte	0
	.ascii	"no reply"
	.byte	0
	.ascii	"protocol error"
	.byte	0
	.ascii	"timeout occured"
	.byte	0
	.ascii	"hardware is busy"
	.byte	0
	.ascii	"board is busy"
	.byte	0
	.ascii	"board not found"
	.byte	0
	.ascii	"no "
	.globl	_expname
_expname:
	.ascii	"expansion.library"	/* inside "no expansion.."  */
	.byte	0
	.ascii	"temporary shutdown"
	.byte	0
	.ascii	"error"
	.byte	0
	.ascii	"???"			/* three marks, not four    */
	.byte	0

/* -------- config strings + scratch ------------------------------- */
	.even
	.globl	_varbuf
_varbuf:
	.long	0,0,0			/* 12B GetVar scratch	    */
	.globl	_vardelay
_vardelay:
	.ascii	"I2CDELAY"
	.byte	0
	.globl	_varxtal
_varxtal:
	.ascii	"I2CXTAL"
	.byte	0
	.globl	_dosname
_dosname:
	.ascii	"dos.library"
	.byte	0
	.even
