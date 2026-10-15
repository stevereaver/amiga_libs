/*
**	i2c.library 40.0 -- reconstructed implementation
**	"i2c.library 40.0 (09 Dec 21) for Apollo Core boards"
**
**	Apollo I2C bus driver.  The bus is bit-banged through a
**	custom control register: writes to $de0080 drive bit0=SDA
**	and bit1=SCL, reads at $de0081 sample SDA.  Edge timing is
**	a busy loop that must issue a hardware read per count --
**	the original reads CIAA PRA ($bfd000); the value is unused.
**
**	Bus clock stretch comes from base+68: ULONG "delay"
**	seeded from the I2CDELAY env var at init (0 default).
**
**	Transfer record (returned by SendI2C/ReceiveI2C):
**	  byte3: unused    byte2: last AllocI2C status (base+135)
**	  byte1: op error code    byte0: $ff iff byte1 == 0
**	Op codes: 0 ok, 1 partial send (NACK mid-data), 2 NACK on
**	address, 3/4/5 echo mismatch, 8 board not claimed.
**
**	Function args arrive in registers (d0,d1,a1,a6) per the
**	library vector convention, not the C stack.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/semaphores.h>
#include <exec/execbase.h>

struct I2CBase {
	struct Library	 lib;		/* +0  (OpenCnt at +32)	    */
	ULONG		 statOps[2];	/* +34 sendops, +38 sentbytes  */
	ULONG		 statOps2[2];	/* +42 recvops, +46 recvbytes  */
	ULONG		 statErr[4];	/* +50 busy, +54 nack,	    */
					/* +58 partial, +62 echo	    */
	UBYTE		 cfg42;		/* +66  =3 via datatab, unused */
	UBYTE		 flags;		/* +67  bit3 = delayed expunge */
	ULONG		 delay;		/* +68  I2CDELAY bus timing    */
	struct SignalSemaphore sem;	/* +72  transfer lock	    */
	struct ExecBase	*sys;		/* +118			    */
	ULONG		 resv122;	/* +122			    */
	APTR		 seglist;	/* +126			    */
	ULONG		 unk130;	/* +130 returned by -66	    */
	UBYTE		 claimed;	/* +134 board claimed	    */
	UBYTE		 laststat;	/* +135 last alloc status    */
	UBYTE		 shutdown;	/* +136 temp-shutdown flag   */
};

/* -------- hardware ------------------------------------------- */
#define I2C_CTRL	(*(volatile UWORD *)0xde0080)
#define I2C_SDAIN	(*(volatile UBYTE *)0xde0081)
#define CIAA_PRA	(*(volatile UBYTE *)0xbfd000)

/* -------- exec / dos LVO calls -------------------------------- */
#define OBSEM(b) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_sem __asm("a0") = &(b)->sem;\
  __asm volatile ("jsr %/a6@(-564:W)\n"\
    : "+a"(__p_sem)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define RELSEM(b) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_sem __asm("a0") = &(b)->sem;\
  __asm volatile ("jsr %/a6@(-570:W)\n"\
    : "+a"(__p_sem)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define INITSEM(b) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_sem __asm("a0") = &(b)->sem;\
  __asm volatile ("jsr %/a6@(-558:W)\n"\
    : "+a"(__p_sem)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define REMOVENODE(b,node) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define FREEMEM(b,mem,sz) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#define OPENLIB(b,name,ver) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register const char * __p_name __asm("a1") = (name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(ver);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=r"(__p_res), "+a"(__p_name)\
    : "a"(__p_sys), "d"(__p_ver)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})
#define CLOSLIB(b,lib) ({\
  register struct ExecBase * __p_sys __asm("a6") = (b)->sys;\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define GETVAR(dos,nm,bf,sz) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_n __asm("d1") = (nm);\
  register char * __p_b __asm("d2") = (bf);\
  register LONG __p_s __asm("d3") = (sz);\
  register LONG __p_f __asm("d4") = 0;\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-906:W)\n"\
    : "=r"(__p_res), "+d"(__p_n), "+d"(__p_b), "+d"(__p_s), "+d"(__p_f)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define STR2LONG(dos,str,out) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_s __asm("d1") = (str);\
  register LONG * __p_o __asm("d2") = (out);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-816:W)\n"\
    : "=r"(__p_res), "+d"(__p_s), "+d"(__p_o)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

extern char envbuf[12], envname[], dosname[];
extern const UBYTE erridx[];
extern const char errbase[];

/* -------- bit timing ------------------------------------------ */
/*	Each wait must issue a hardware read per count; CIAA PRA    */
/*	is read and discarded exactly like the original.	    */
static void i2c_wait(ULONG n)
{
	if (!n)
		n = 1;
	do {
		(void)CIAA_PRA;
	} while (--n);
}
static void i2c_wait_long(ULONG d5)
{
	ULONG n = d5 + 1;

	n += n;				/* (d5+1)*2, wraps	   */
	i2c_wait(n);
}

/* -------- 9-clock byte shift ----------------------------------- */
/*	Clocks out tx.w bits 7..0 then bit15 (the "flag" bit =	   */
/*	SDA release for the ACK slot) and simultaneously clocks	   */
/*	in SDA into rx bits 8..0; returns rx rotated so the byte	   */
/*	is in bits 7..0 and the flag bit at bit15.  *txp and *ctlp   */
/*	carry the word being shifted and the live control value.    */
static UWORD i2c_shift(UWORD *txp, ULONG d5, UWORD *ctlp)
{
	UWORD	tx = *txp, ctl = *ctlp, rx = 0;
	WORD	bit;

	tx = (tx << 1) | (tx >> 15);			/* rol.w #1  */
	for (bit = 8; bit >= 0; bit--) {
		i2c_wait(d5 >> 1);
		if (tx & (1 << bit))
			ctl |= 1;
		else
			ctl &= ~1;
		I2C_CTRL = ctl;				/* SDA out   */
		i2c_wait((d5 + 1) >> 1);
		ctl |= 2;
		I2C_CTRL = ctl;				/* SCL hi    */
		i2c_wait(d5);
		if (I2C_SDAIN & 1)			/* SDA in    */
			rx |= (1 << bit);
		ctl &= ~2;
		I2C_CTRL = ctl;				/* SCL lo    */
	}
	*txp = (tx >> 1) | (tx << 15);			/* ror.w #1  */
	*ctlp = ctl;
	return (rx >> 1) | (rx << 15);			/* ror.w #1  */
}

/* -------- START / STOP sequences ------------------------------- */
static void i2c_start(ULONG d5, UWORD *ctlp)
{
	UWORD ctl = *ctlp;

	ctl &= ~1;
	I2C_CTRL = ctl;					/* SDA lo    */
	i2c_wait_long(d5);
	ctl &= ~2;
	I2C_CTRL = ctl;					/* SCL lo    */
	i2c_wait_long(d5);
	*ctlp = ctl;
}
static void i2c_stop(ULONG d5, UWORD *ctlp)
{
	UWORD ctl = *ctlp;

	ctl &= ~1;
	I2C_CTRL = ctl;					/* SDA lo    */
	i2c_wait_long(d5);
	ctl |= 2;
	I2C_CTRL = ctl;					/* SCL hi    */
	i2c_wait_long(d5);
	ctl |= 1;
	I2C_CTRL = ctl;					/* SDA hi    */
	i2c_wait_long(d5);
	*ctlp = ctl;
}

/* -------- init-time env read (internal 0x272) ------------------- */
static void i2c_readenv(struct I2CBase *b)
{
	APTR dos = OPENLIB(b, dosname, 36);

	if (!dos)
		return;
	if (GETVAR(dos, envname, envbuf, 12) >= 0)
		STR2LONG(dos, envbuf, (LONG *)&b->delay);
	CLOSLIB(b, dos);
}

/* -------- vectors ---------------------------------------------- */
struct I2CBase * LibInit(struct I2CBase *b __asm("d0"),
			 APTR seglist __asm("a0"),
			 struct ExecBase *sys __asm("a6"))
{
	b->sys = sys;
	b->seglist = seglist;
	i2c_readenv(b);
	INITSEM(b);
	return b;
}

LONG LibNull(void)
{
	return 0;
}

/* -30 AllocI2C: claim the board under the semaphore.	    */
/*	0 = claimed/already ours, 5 = temp-shutdown pending.	    */
LONG AllocI2C(struct I2CBase *b __asm("a6"))
{
	LONG rc;

	OBSEM(b);
	rc = 0;
	if (!b->claimed) {
		rc = 5;
		if (!b->shutdown) {
			b->claimed = 0xff;
			rc = 0;
		}
	}
	b->laststat = (UBYTE)rc;
	RELSEM(b);
	return rc;
}

/* -36 FreeI2C: on the final close drop claim + shutdown flag.    */
LONG FreeI2C(struct I2CBase *b __asm("a6"))
{
	if (b->lib.lib_OpenCnt == 1) {
		b->shutdown = 0;
		b->claimed = 0;
	}
	return 0;
}

/* -42 I2CDelay: d0<0 queries, d0>=0 sets; returns previous.	    */
ULONG I2CDelay(LONG d0 __asm("d0"), struct I2CBase *b __asm("a6"))
{
	ULONG old = b->delay;

	if (d0 >= 0)
		b->delay = d0;
	return old;
}

/* -48 ResetBus: drive idle (SDA+SCL hi) when the board is ours.   */
LONG ResetBus(struct I2CBase *b __asm("a6"))
{
	if (b->claimed)
		I2C_CTRL = 3;
	return 0;
}

APTR LibExpunge(struct I2CBase *b __asm("a6"));

/* -6 Open */
struct I2CBase * LibOpen(struct I2CBase *b __asm("a6"))
{
	b->lib.lib_OpenCnt++;
	b->flags &= ~8;			/* clear delayed-expunge bit */
	AllocI2C(b);
	ResetBus(b);
	return b;
}

/* -12 Close */
LONG LibClose(struct I2CBase *b __asm("a6"))
{
	FreeI2C(b);
	if (--b->lib.lib_OpenCnt == 0 && (b->flags & 8))
		LibExpunge(b);
	return 0;
}

/* -18 Expunge */
APTR LibExpunge(struct I2CBase *b __asm("a6"))
{
	APTR seg;
	ULONG sz;

	if (b->lib.lib_OpenCnt) {
		b->flags |= 8;		/* arm delayed expunge	    */
		return 0;
	}
	seg = b->seglist;
	REMOVENODE(b, b);
	sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
	FREEMEM(b, (UBYTE *)b - b->lib.lib_NegSize, sz);
	return seg;
}

/* shared transfer tail: STOP + result compose + unlock	    */
static ULONG i2c_done(struct I2CBase *b, ULONG d5, UWORD ctl,
		      WORD err, int do_stop)
{
	ULONG res;

	if (do_stop)
		i2c_stop(d5, &ctl);
	res = ((ULONG)b->laststat << 16) | ((ULONG)err << 8) |
	      (err == 0 ? 0xff : 0);
	RELSEM(b);
	return res;
}

/* -54 SendI2C: d0 = address word, d1 = byte count, a1 = buffer.   */
ULONG SendI2C(ULONG d0 __asm("d0"), LONG d1 __asm("d1"),
	      UBYTE *buf __asm("a1"), struct I2CBase *b __asm("a6"))
{
	ULONG	d5;
	UWORD	ctl = 3, txw, rx;
	WORD	d6, err = 8;

	b->statOps[0]++;
	if (!b->claimed) {
		b->statErr[0]++;
		return i2c_done(b, 0, 0, err, 0);
	}
	OBSEM(b);
	/* NOTE: shipped code takes the sema BEFORE the claim test
	   and bumps statOps inside it; ordering kept equivalent.  */
	d5 = b->delay;
	d6 = (WORD)d1;				/* orig count	    */
	d0 = (d0 & ~1) | 0x8000;		/* W + flag bit	    */
	txw = (UWORD)d0;
	i2c_start(d5, &ctl);
	rx = i2c_shift(&txw, d5, &ctl);
	err = 0;
	for (;;) {
		if ((UBYTE)txw != (UBYTE)rx)
			goto echo_err;		/* echo != sent	    */
		if ((SHORT)rx < 0) {		/* NACK		    */
			if ((WORD)d1 == d6) {
				err = 2;
				b->statErr[1]++;
			} else {
				err = 0;
				if ((WORD)d1 != 0) {
					err = 1;
					b->statErr[2]++;
				}
			}
			goto done;
		}
		d1 = (WORD)d1 - 1;
		if ((WORD)d1 < 0)
			goto done;
		txw = (txw & 0xff00) | *buf++;	/* moveb keeps hi byte */
		b->statOps[1]++;
		rx = i2c_shift(&txw, d5, &ctl);
		err = 0;
	}
echo_err:
	b->statErr[3]++;
	if ((UBYTE)rx == 0xff)
		err = 5;
	else if ((UBYTE)rx == 0)
		err = 4;
	else
		err = 3;
done:
	return i2c_done(b, d5, ctl, err, 1);
}

/* -60 ReceiveI2C: d0 = address word, d1 = byte count, a1 = buf.   */
ULONG ReceiveI2C(ULONG d0 __asm("d0"), LONG d1 __asm("d1"),
		 UBYTE *buf __asm("a1"), struct I2CBase *b __asm("a6"))
{
	ULONG	d5;
	UWORD	ctl = 3, txw, rx;
	WORD	err = 8;

	b->statOps2[0]++;
	if (!b->claimed) {
		b->statErr[0]++;
		return i2c_done(b, 0, 0, err, 0);
	}
	OBSEM(b);
	d5 = b->delay;
	d0 = d0 | 0x8001;			/* R + flag bit	    */
	txw = (UWORD)d0;
	i2c_start(d5, &ctl);
	rx = i2c_shift(&txw, d5, &ctl);
	if ((UBYTE)txw != (UBYTE)rx)
		goto echo_err;
	if ((SHORT)rx < 0) {
		err = 2;
		b->statErr[1]++;
		goto done;
	}
	for (;;) {
		txw = 0xffff;
		d1 = (WORD)d1 - 1;
		if ((WORD)d1 > 0)
			txw >>= 1;		/* 0x7fff = ACK,	    */
						/* else ffff = NACK	    */
		rx = i2c_shift(&txw, d5, &ctl);
		if ((WORD)d1 < 0)
			break;			/* byte clocked, not stored */
		*buf++ = (UBYTE)rx;
		b->statOps2[1]++;
		if ((WORD)d1 == 0)
			break;
	}
	err = 0;
	goto done;
echo_err:
	b->statErr[3]++;
	if ((UBYTE)rx == 0xff)
		err = 5;
	else if ((UBYTE)rx == 0)
		err = 4;
	else
		err = 3;
done:
	return i2c_done(b, d5, ctl, err, 1);
}

/* -66 I2CStatus: returns the longword at base+130 (never written) */
ULONG I2CStatus(struct I2CBase *b __asm("a6"))
{
	return b->unk130;
}

/* -72 I2CErrStr: packed 3-byte code -> static string.		    */
/*	byte2 (23-16): 0 clear / 1-5 board errs(+8) / >=6 "???"	    */
/*	byte1 (15-8):  1-7 bus errs / >=8 "???"			    */
/*	byte0 (7-0):   nonzero -> "OK", zero -> "error"		    */
const char * I2CErrStr(ULONG code __asm("d0"),
		       struct I2CBase *b __asm("a6"))
{
	ULONG idx, v;

	v = code >> 24;
	if (v >= 6)
		idx = 16;
	else if (v)
		idx = v + 8;
	else {
		v = (code >> 16) & 0xff;
		if (v >= 8)
			idx = 16;
		else if (v)
			idx = v;
		else {
			v = (code >> 8) & 0xff;
			idx = v ? 0 : 15;
		}
	}
	return errbase + erridx[idx];
}

/* -78 ShutdownI2C: temp-shutdown -- release claim, block allocs.   */
LONG ShutdownI2C(struct I2CBase *b __asm("a6"))
{
	OBSEM(b);
	b->shutdown = 0xff;
	b->claimed = 0;
	RELSEM(b);
	b->laststat = 5;
	return 0;
}

/* -84 RestartI2C: clear shutdown, re-claim, idle the bus.	    */
LONG RestartI2C(struct I2CBase *b __asm("a6"))
{
	LONG rc;

	b->shutdown = 0;		/* cleared outside the sema  */
	rc = AllocI2C(b);
	ResetBus(b);
	return rc;
}
