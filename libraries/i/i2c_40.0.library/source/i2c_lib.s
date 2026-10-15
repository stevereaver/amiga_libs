	.file	"i2c_lib.s"
	.text

/*
**	i2c.library 40.0 -- AUTOINIT skeleton
**	"i2c.library 40.0 (09 Dec 21) for Apollo Core boards"
**
**	Apollo I2C bus driver: bit-bangs SDA/SCL through a custom
**	control register at $de0080 (bit0=SDA out, bit1=SCL; SDA is
**	read back at $de0081 bit0) and times edges by counting reads
**	of CIAA PRA at $bfd000.  LibInit optionally reads the
**	I2CDELAY env var (dos GetVar + StrToLong) into base+68.
**
**	dataSize 0x89 (137), LONG-address functable, 14 vectors:
**	  -30 AllocI2C   claim board (sema'd); 0 or 5
**	  -36 FreeI2C    drop claim on last close
**	  -42 I2CDelay   get (d0<0) / set bus timing, returns old
**	  -48 ResetBus   idle the bus when claimed
**	  -54 SendI2C    addr+write bytes
**	  -60 ReceiveI2C addr+read bytes
**	  -66 I2CStatus  returns base+130 (never written -> 0)
**	  -72 I2CErrStr  packed code -> error string
**	  -78 ShutdownI2C temp-shutdown: release claim, block alloc
**	  -84 RestartI2C  clear shutdown, re-claim, reset bus
**
**	Module entry returns 10 (as shipped).  No $VER: cookie.
*/

	.globl	_start
_start:
	moveq	#10,%d0			/* returns 10, as shipped	   */
	rts

/* -------- RomTag (packed layout) -------------------------------- */
	.globl	rt_MatchTag
	.globl	rt_EndSkip
	.globl	rt_Init
rt_MatchTag:
	.word	0x4afc			/* UWORD	rt_MatchWord   */
	.long	rt_MatchTag		/* APTR		rt_MatchTag    */
	.long	rt_EndSkip		/* APTR		rt_EndSkip     */
	.byte	0x80			/* RTF_AUTOINIT		    */
	.byte	40			/* rt_Version = 40	    */
	.byte	0x09			/* rt_Type    = NT_LIBRARY  */
	.byte	0x00			/* rt_Pri		    */
	.long	libname			/* rt_Name		    */
	.long	idstring		/* rt_IdString		    */
	.long	rt_Init			/* rt_Init -> InitTable	    */

libname:
	.ascii	"i2c.library\0"
	.globl	_idstring
idstring:
	.ascii	"i2c.library 40.0 (09 Dec 21) for Apollo Core boards\015\012\0"
	.even

/* -------- InitTable --------------------------------------------- */
rt_Init:
	.long	0x00000089		/* dataSize 0x89 = 137	    */
	.long	functab			/* funcTable (LONG addrs)    */
	.long	datatab			/* initDataTable	    */
	.long	_LibInit		/* initRoutine		    */

/* -------- function table (14 long-address vectors) -------------- */
functab:
	.long	_LibOpen		/* -6  Open		   */
	.long	_LibClose		/* -12 Close		   */
	.long	_LibExpunge		/* -18 Expunge		   */
	.long	_LibNull		/* -24 Reserved		   */
	.long	_AllocI2C		/* -30 AllocI2C		   */
	.long	_FreeI2C		/* -36 FreeI2C		   */
	.long	_I2CDelay		/* -42 I2CDelay		   */
	.long	_ResetBus		/* -48 ResetBus		   */
	.long	_SendI2C		/* -54 SendI2C		   */
	.long	_ReceiveI2C		/* -60 ReceiveI2C	   */
	.long	_I2CStatus		/* -66 I2CStatus		   */
	.long	_I2CErrStr		/* -72 I2CErrStr		   */
	.long	_ShutdownI2C		/* -78 ShutdownI2C	   */
	.long	_RestartI2C		/* -84 RestartI2C	   */
	.word	0xffff
	.word	0xffff

/* -------- InitStruct DATATABLE (exact encoding) ----------------- */
/*	a008 09 / 800a libname / 8018 idstring / 9014 0028 /	   */
/*	9016 0000 / a00e 06 / a042 03 / 0000			   */
datatab:
	.byte	0xa0,0x08		/* INITBYTE @ 8	-> ln_Type  */
	.byte	0x09,0x00		/*  = 9 (NT_LIBRARY)	    */
	.byte	0x80,0x0a		/* INITLONG @ 0xa -> ln_Name */
	.long	libname
	.byte	0x80,0x18		/* INITLONG @ 0x18 -> IdString*/
	.long	idstring
	.byte	0x90,0x14		/* INITWORD @ 0x14 -> version */
	.word	0x0028			/*  = 40			    */
	.byte	0x90,0x16		/* INITWORD @ 0x16 -> revision*/
	.word	0x0000			/*  = 0			    */
	.byte	0xa0,0x0e		/* INITBYTE @ 0xe -> lib_Flags*/
	.byte	0x06,0x00		/*  = 6 (SUMUSED|CHANGED)    */
	.byte	0xa0,0x42		/* INITBYTE @ 0x42 (never read)*/
	.byte	0x03,0x00		/*  = 3			    */
	.byte	0x00,0x00		/* terminator		    */

/* -------- error-string index table + shared pool ---------------- */
/*	17 byte offsets into _errbase; entries 6/7/12/14/16 share   */
/*	the "???" string and entry 13 rides the tail of "no tem-    */
/*	porary shutdown" (-> "temporary shutdown"), as shipped.     */
	.globl	_erridx
_erridx:
	.byte	0x00,0x03,0x11,0x1a,0x26,0x34,0x8d,0x8d
	.byte	0x42,0x53,0x61,0x71,0x8d,0x74,0x8d,0x87,0x8d
	.globl	_errbase
_errbase:
	.ascii	"OK\0"
	.ascii	"data rejected\0"
	.ascii	"no reply\0"
	.ascii	"SDA trashed\0"
	.ascii	"SDA always LO\0"
	.ascii	"SDA always HI\0"
	.ascii	"hardware is busy\0"
	.ascii	"board is busy\0"
	.ascii	"board not found\0"
	.ascii	"no temporary shutdown\0"
	.ascii	"error\0"
	.ascii	"???\0"
	.even

/* -------- env-var scratch + names (in code hunk, as shipped) ---- */
	.globl	_envbuf
_envbuf:
	.long	0
	.long	0
	.long	0			/* 12-byte GetVar buffer	    */
	.globl	_envname
_envname:
	.ascii	"I2CDELAY\0"
	.globl	_dosname
_dosname:
	.ascii	"dos.library\0"
	.even
