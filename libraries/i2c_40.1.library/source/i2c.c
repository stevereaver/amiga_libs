/*
**	i2c.library 40.1 -- reconstructed implementation
**	"i2c.library 40.1 (18 Jul 99) for PFC8584 bus controller"
**
**	Polled driver for a PFC8584 I2C controller sitting on a
**	Zorro expansion board (expansion.library FindConfigDev,
**	manufacturer 0x1389 / product 15).  Board register file is
**	accessed directly: data register at base+0, control/status
**	at base+2.
**
**	Library base (dataSize 0xc2):
**	  +34..+62  statistics counters (wrCalls, wrBytes, rdCalls,
**		    rdBytes, notPresent, noReply, rejected, errors)
**	  +66	  byte = 4 (datatab; type byte of the vestigial
**		    node area -- see below)
**	  +68	  delay index (ENV:I2CDELAY, clamped 0..3 at use)
**	  +72	  SignalSemaphore (34B)
**	  +118	  execbase, +122 ConfigDev*, +126 seglist
**	  +130	  clock prescaler table (4 bytes, from ENV:I2CXTAL)
**	  +134	  controller-present flag
**	  +135	  last probe result (board state 0..6)
**	  +136	  shutdown flag
**	  +140	  poll timeout (VBlank-decremented by the server)
**	  +150	  struct Interrupt (int 5/VERTB; is_Data = base,
**		    is_Code = the decrementer at hunk tail)
**	  +172	  second struct Interrupt (type/pri 0x7d/name set,
**		    is_Data/is_Code zero, never AddIntServer'd -- dead)
**
**	InitFunction opens dos.library v36 for GetVar(I2CDELAY /
**	I2CXTAL) config, opens expansion.library, FindConfigDev's
**	the board, seeds the semaphore, hooks the VBlank server.
**
**	Return packing: (old_state<<16) | (err<<8) | (ok ? 0xff:0)
**	-- I2CErrText decodes: state 1..6 -> board errors,
**	err 1..8 -> i2c errors, ok!=0 -> "OK".
**
**	Defects reproduced: dead `lea $bfd000,a0` (CIAB leftover),
**	Open() discards the probe result, -48 always returns 0,
**	state byte of a closed library leaks into the next return.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/interrupts.h>
#include <exec/semaphores.h>
#include <exec/execbase.h>
#include <libraries/configvars.h>

struct I2CBase {
	struct Library	 lib;		/* +0x00 (OpenCnt +0x20) */
	ULONG		 stat_wrc;	/* +0x22 write calls	    */
	ULONG		 stat_wrb;	/* +0x26 bytes sent	    */
	ULONG		 stat_rdc;	/* +0x2a read calls	    */
	ULONG		 stat_rdb;	/* +0x2e bytes received	    */
	ULONG		 stat_nopres;	/* +0x32 "no controller"    */
	ULONG		 stat_noreply;	/* +0x36 address NAK	    */
	ULONG		 stat_rej;	/* +0x3a mid-data NAK	    */
	ULONG		 stat_err;	/* +0x3e timeout/arblost    */
	UBYTE		 flag42;	/* +0x42 datatab = 4	    */
	UBYTE		 dexp;		/* +0x43 delayed-expunge    */
	ULONG		 delay;		/* +0x44 I2CDELAY value	    */
	struct SignalSemaphore sem;	/* +0x48 (46B: ends 0x76)   */
	struct ExecBase *sys;		/* +0x76			    */
	struct ConfigDev *cfgdev;	/* +0x7a			    */
	APTR		 seglist;	/* +0x7e			    */
	UBYTE		 clk[4];	/* +0x82 prescaler table    */
	UBYTE		 present;	/* +0x86			    */
	UBYTE		 state;		/* +0x87 last probe code    */
	UBYTE		 sdown;		/* +0x88 shutdown flag	    */
	UBYTE		 pad89[3];
	volatile UWORD	 timeout;	/* +0x8c VBlank decremented */
	UBYTE		 pad8e[8];
	struct Interrupt intr;		/* +0x96 server node	    */
	struct Interrupt intr2;		/* +0xac dead spare node    */
};

/* -------- exec calls --------------------------------------------- */
#define OPENLIB_E(name,ver) ({\
  register struct ExecBase * __p_sys __asm("a6") = (struct ExecBase *)4;\
  register const char * __p_name __asm("a1") = (name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(ver);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=r"(__p_res), "+a"(__p_name)\
    : "a"(__p_sys), "d"(__p_ver)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})
#define CLOSLIB_E(sys,lib) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define INITSEM(sys,sem) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_s __asm("a0") = (APTR)(sem);\
  __asm volatile ("jsr %/a6@(-558:W)\n"\
    : "+a"(__p_s)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define OBTAINSEM(sys,sem) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_s __asm("a0") = (APTR)(sem);\
  __asm volatile ("jsr %/a6@(-564:W)\n"\
    : "+a"(__p_s)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define RELSEM(sys,sem) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_s __asm("a0") = (APTR)(sem);\
  __asm volatile ("jsr %/a6@(-570:W)\n"\
    : "+a"(__p_s)\
    : "a"(__p_sys)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define ADDINT(sys,num,intr) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register ULONG __p_n __asm("d0") = (ULONG)(num);\
  register APTR __p_i __asm("a1") = (APTR)(intr);\
  __asm volatile ("jsr %/a6@(-168:W)\n"\
    : "+d"(__p_n), "+a"(__p_i)\
    : "a"(__p_sys)\
    : "a0","fp0","fp1","cc","memory");})
#define REMINT(sys,num,intr) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register ULONG __p_n __asm("d0") = (ULONG)(num);\
  register APTR __p_i __asm("a1") = (APTR)(intr);\
  __asm volatile ("jsr %/a6@(-174:W)\n"\
    : "+d"(__p_n), "+a"(__p_i)\
    : "a"(__p_sys)\
    : "a0","fp0","fp1","cc","memory");})
#define ALERT(num) ({\
  register struct ExecBase * __p_sys __asm("a6") = (struct ExecBase *)4;\
  register ULONG __p_n __asm("d7") = (ULONG)(num);\
  __asm volatile ("jsr %/a6@(-108:W)\n"\
    : "+d"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","a1","fp0","fp1","cc","memory");})
#define REMOVENODE(sys,node) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define FREEMEM(sys,mem,sz) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})

/* -------- dos calls (a6 = DOSBase) ------------------------------- */
#define DOS_GETVAR(dos,name,buf,len,fl) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_n __asm("d1") = (name);\
  register char * __p_b __asm("d2") = (buf);\
  register ULONG __p_l __asm("d3") = (ULONG)(len);\
  register ULONG __p_f __asm("d4") = (ULONG)(fl);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-906:W)\n"\
    : "=r"(__p_res), "+d"(__p_n), "+d"(__p_b), "+d"(__p_l), "+d"(__p_f)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define DOS_STRTOLONG(dos,str,pres) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_s __asm("d1") = (str);\
  register LONG * __p_p __asm("d2") = (pres);\
  __asm volatile ("jsr %/a6@(-816:W)\n"\
    : "+d"(__p_s), "+d"(__p_p)\
    : "a"(__p_dos)\
    : "d0","a0","a1","fp0","fp1","cc","memory");})

/* -------- expansion calls ---------------------------------------- */
#define FINDCFG(exp,old,mfg,prod) ({\
  register APTR __p_exp __asm("a6") = (exp);\
  register APTR __p_o __asm("a0") = (old);\
  register ULONG __p_m __asm("d0") = (ULONG)(mfg);\
  register ULONG __p_p __asm("d1") = (ULONG)(prod);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-72:W)\n"\
    : "=r"(__p_res), "+a"(__p_o)\
    : "a"(__p_exp), "d"(__p_m), "d"(__p_p)\
    : "a1","fp0","fp1","cc","memory");\
  __p_res;})

/* -------- external data (in i2c_lib.s) --------------------------- */
extern char varbuf[];			/* 12-byte GetVar buffer	    */
extern char vardelay[];			/* "I2CDELAY"			    */
extern char varxtal[];			/* "I2CXTAL"			    */
extern char dosname[];			/* "dos.library"		    */
extern char expname[];			/* "expansion.library"	    */
extern const UBYTE errtab[];		/* code -> string-offset table	    */
extern const char errstr[];		/* "OK" + packed error strings	    */

LONG I2CProbe(struct I2CBase *b __asm("a6"));
LONG I2CReset(struct I2CBase *b __asm("a6"));
LONG I2CReserved(struct I2CBase *b __asm("a6"));
APTR LibExpunge(struct I2CBase *b __asm("a6"));

/* -------- helpers ------------------------------------------------ */

/* LAB_0033: pull I2CDELAY / I2CXTAL out of the environment via
** dos.library v36.  I2CXTAL's numeric value is remapped to the
** 4-byte prescaler table (3/4/6/8 MHz crystals; anything else
** falls back to the 20 MHz row).  Missing/failed vars leave the
** defaults.							    */
static void read_config(struct I2CBase *b, struct ExecBase *sys)
{
	struct Library *dos;

	dos = OPENLIB_E(dosname, 36);
	if (!dos)
		return;
	if (DOS_GETVAR(dos, vardelay, varbuf, 12, 0) >= 0)
		DOS_STRTOLONG(dos, varbuf, (LONG *)&b->delay);
	UBYTE v = 0;
	if (DOS_GETVAR(dos, varxtal, varbuf, 12, 0) >= 0) {
		DOS_STRTOLONG(dos, varbuf, (LONG *)b->clk);
		v = b->clk[3];		/* CMPI.B on the low byte   */
	}
	*(ULONG *)b->clk =
		v == 3 ? 0x00010203 :
		v == 4 ? 0x10111213 :
		v == 6 ? 0x14151617 :
		v == 8 ? 0x18191a1b : 0x1c1d1e1f;
	CLOSLIB_E(sys, dos);
}

/* LAB_0051: program the PFC8584 -- reset, own-address 0x55,
** clock byte from the prescaler table indexed by the clamped
** delay value, then enable (0xc1).  a1 = board base.	    */
static void ctrl_init(struct I2CBase *b, volatile UBYTE *regs)
{
	ULONG d = b->delay;

	regs[2] = 0x80;
	regs[0] = 0x55;
	if (d > 3)
		d = 3;
	regs[2] = 0xa0;
	regs[0] = b->clk[d];
	regs[2] = 0xc1;
}

/* -------- LibInit ------------------------------------------------ */
struct I2CBase * LibInit(struct I2CBase *b __asm("d0"),
			 APTR seglist __asm("a0"),
			 struct ExecBase *sys __asm("a6"))
{
	APTR exp;

	b->sys = sys;
	b->seglist = seglist;
	read_config(b, sys);
	exp = OPENLIB_E(expname, 0);
	if (!exp) {
		ALERT(0x0003800a);	/* AG_OpenLib|AO_Expansion   */
		b->state = 3;
	} else {
		b->cfgdev = FINDCFG(exp, NULL, 0x1389, 15);
		CLOSLIB_E(sys, exp);
	}
	INITSEM(sys, &b->sem);
	b->intr.is_Data = b;
	ADDINT(sys, 5, &b->intr);	/* INTB_VERTB		    */
	return b;
}

/* -------- -6 LibOpen --------------------------------------------- */
struct I2CBase * LibOpen(struct I2CBase *b __asm("a6"))
{
	++b->lib.lib_OpenCnt;
	b->dexp &= ~8;			/* private delayed-expunge  */
	I2CProbe(b);			/* result discarded!	    */
	I2CReserved(b);			/* dead no-op		    */
	return b;
}

/* -------- -12 LibClose ------------------------------------------- */
LONG LibClose(struct I2CBase *b __asm("a6"))
{
	I2CReset(b);			/* last-close state reset   */
	if (!--b->lib.lib_OpenCnt && (b->dexp & 8))
		return (LONG)LibExpunge(b);
	return 0;
}

/* -------- -18 LibExpunge ----------------------------------------- */
APTR LibExpunge(struct I2CBase *b __asm("a6"))
{
	struct ExecBase *sys = b->sys;
	ULONG seg;

	if (b->lib.lib_OpenCnt) {
		b->dexp |= 8;
		return NULL;
	}
	REMINT(sys, 5, &b->intr);
	seg = (ULONG)b->seglist;
	REMOVENODE(sys, b);
	FREEMEM(sys, (UBYTE *)b - b->lib.lib_NegSize,
		b->lib.lib_NegSize + b->lib.lib_PosSize);
	return (APTR)seg;
}

/* -------- -24 reserved ------------------------------------------- */
LONG LibNull(struct I2CBase *b __asm("a6"))
{
	return 0;
}

/* -------- -30 I2CProbe (LAB_002A) -------------------------------- */
/* Semaphore-locked controller detect.  Caches the result in
** ->state; sets ->present on success.  Codes: 0 ok, 1 board busy
** (cd_Driver claimed), 2 board not found, 3 expansion missing,
** 5 shutdown pending.						    */
LONG I2CProbe(struct I2CBase *b __asm("a6"))
{
	LONG r = 0;

	OBTAINSEM(b->sys, &b->sem);
	if (!b->present) {
		r = b->state;
		if (r != 3) {
			r = 5;
			if (!b->sdown) {
				r = 2;
				if (b->cfgdev) {
					r = 1;
					if (!b->cfgdev->cd_Driver) {
						b->present = ~0;	/* ST		    */
						r = 0;
					}
				}
			}
		}
	}
	b->state = r;
	RELSEM(b->sys, &b->sem);
	return r;
}

/* -------- -36 I2CReset ------------------------------------------- */
/* Called by LibClose before the count drops: on the LAST close
** the present/shutdown flags are cleared so the next open
** re-probes (and re-enables a shut-down board). 		    */
LONG I2CReset(struct I2CBase *b __asm("a6"))
{
	if (b->lib.lib_OpenCnt == 1) {
		b->sdown = 0;
		b->present = 0;
	}
	return 0;
}

/* -------- -42 I2CDelay ------------------------------------------- */
/* d0 >= 0: store new delay index; always returns the old one.    */
LONG I2CDelay(LONG d0 __asm("d0"), struct I2CBase *b __asm("a6"))
{
	ULONG old = b->delay;

	if (d0 >= 0)
		b->delay = d0;
	return old;
}

/* -------- -48 dead stub ------------------------------------------ */
/* The original tests ->present and both branches land on the
** same `moveq #0,rts` -- a compiled-out wait-ready.		    */
LONG I2CReserved(struct I2CBase *b __asm("a6"))
{
	return 0;
}

/* -------- -54 I2CWrite ------------------------------------------- */
/* d0 = slave address, a1 = buffer, d1 = count (word).
** Polled send: 0xc5 start, wait BB clear, check AL/LRB per byte,
** 0xc3 stop; 25 VBlanks per byte of slack (~0.5 s).		    */
ULONG I2CWrite(register UBYTE *buf __asm("a1"),
	       register ULONG addr __asm("d0"),
	       register ULONG len_w __asm("d1"),
	       struct I2CBase *b __asm("a6"))
{
	volatile UBYTE *regs;
	SHORT len = (UWORD)len_w, orig = len;
	ULONG err = 8;
	UBYTE st;

	OBTAINSEM(b->sys, &b->sem);
	++b->stat_wrc;
	if (!b->present) {
		++b->stat_nopres;
		goto fin;
	}
	regs = (volatile UBYTE *)b->cfgdev->cd_BoardAddr;
	ctrl_init(b, regs);
	addr &= ~1UL;			/* R/W = 0: write	    */
	regs[0] = (UBYTE)addr;
	regs[2] = 0xc5;			/* start condition	    */
	for (;;) {
		b->timeout = 25;
		do {
			st = regs[2];
			if (!b->timeout) {
				err = 6;
				goto tout;
			}
		} while (st & 0x80);	/* BB: bus busy		    */
		err = 0;
		if (st & 0x10) {	/* AL: arbitration lost	    */
			err = 3;
			goto tout;
		}
		if (st & 0x08) {	/* LRB: no ack		    */
			if (len == orig) {
				err = 2;
				++b->stat_noreply;
				goto done;
			}
			err = 0;
			if (!len)
				goto done;
			err = 1;
			++b->stat_rej;
			goto done;
		}
		if (--len < 0)
			goto done;	/* err = 0		    */
		regs[0] = *buf++;
		++b->stat_wrb;
	}
tout:
	++b->stat_err;
done:
	regs[2] = 0xc3;			/* stop			    */
	b->timeout = 25;
	while (b->timeout && !(regs[2] & 1))
		;
fin:
	err = (b->state << 16) | (err << 8) | (err ? 0 : 0xff);
	RELSEM(b->sys, &b->sem);
	return err;
}

/* -------- -60 I2CRead -------------------------------------------- */
/* d0 = slave address, a1 = buffer, d1 = count (word).  Same
** protocol; R/W bit set, dummy read primes the receiver, 0x40
** NAKs the last byte, 0xc3 stops.				    */
ULONG I2CRead(register UBYTE *buf __asm("a1"),
	      register ULONG addr __asm("d0"),
	      register ULONG len_w __asm("d1"),
	      struct I2CBase *b __asm("a6"))
{
	volatile UBYTE *regs;
	SHORT len = (UWORD)len_w;
	ULONG err = 8;
	UBYTE st;

	OBTAINSEM(b->sys, &b->sem);
	++b->stat_rdc;
	if (!b->present) {
		++b->stat_nopres;
		goto fin;
	}
	regs = (volatile UBYTE *)b->cfgdev->cd_BoardAddr;
	ctrl_init(b, regs);
	addr |= 1;			/* R/W = 1: read	    */
	regs[0] = (UBYTE)addr;
	regs[2] = 0xc5;
	b->timeout = 25;
	do {
		st = regs[2];
		if (!b->timeout) {
			err = 6;
			goto tout;
		}
	} while (st & 0x80);
	if (st & 0x10) {
		err = 3;
		goto tout;
	}
	if (st & 0x08) {		/* address NAK		    */
		err = 2;
		++b->stat_noreply;
		goto done;
	}
	if (len <= 1)
		regs[2] = 0x40;		/* NAK the final byte	    */
	(void)regs[0];			/* dummy read: start recv   */
	for (;;) {
		b->timeout = 25;
		for (;;) {
			st = regs[2];
			if (!b->timeout) {
				err = 6;
				goto tout;
			}
			if (!(st & 0x80))
				break;
		}
		if (--len == 1)
			regs[2] = 0x40;
		if (len <= 0)
			regs[2] = 0xc3;
		st = regs[0];
		if (len < 0)
			goto rdone;
		*buf++ = st;
		++b->stat_rdb;
		if (!len)
			break;
	}
rdone:
	err = 0;
	goto done;
tout:
	++b->stat_err;
done:
	regs[2] = 0xc3;
	b->timeout = 25;
	while (b->timeout && !(regs[2] & 1))
		;
fin:
	err = (b->state << 16) | (err << 8) | (err ? 0 : 0xff);
	RELSEM(b->sys, &b->sem);
	return err;
}

/* -------- -66 stub ----------------------------------------------- */
LONG I2CStub(struct I2CBase *b __asm("a6"))
{
	return 0;
}

/* -------- -72 I2CErrText ----------------------------------------- */
/* Decode a packed result into an error string.  Byte2 (state)
** wins: 1..6 -> board errors 9..14; else byte1 (i2c error)
** 1..8 -> 1..8; else byte0 -> "OK", all-zero -> "error".
** Out-of-range bytes -> "????".				    */
const char * I2CErrText(ULONG code __asm("d0"),
			struct I2CBase *b __asm("a6"))
{
	ULONG idx;
	UBYTE v = (code >> 16) & 0xff;

	if (v > 6)
		idx = 16;
	else if (v)
		idx = v + 8;
	else {
		v = (code >> 8) & 0xff;
		if (v > 8)
			idx = 16;
		else if (v)
			idx = v;
		else
			idx = (code & 0xff) ? 0 : 15;
	}
	/* EXT.W: table bytes >= 0x80 sign-extend to NEGATIVE offsets --
	** the author intended "+0x96 -> ???" / "+0x90 -> error" but
	** those slots actually point into the functab.  Faithful bug.  */
	return errstr + (BYTE)errtab[idx];
}

/* -------- -78 I2CShutdown ---------------------------------------- */
/* Mark the board shut down: clear present, force state 5.	    */
LONG I2CShutdown(struct I2CBase *b __asm("a6"))
{
	OBTAINSEM(b->sys, &b->sem);
	b->sdown = ~0;			/* ST			    */
	b->present = 0;
	RELSEM(b->sys, &b->sem);
	b->state = 5;
	return 0;
}

/* -------- -84 I2CReEnable ---------------------------------------- */
LONG I2CReEnable(struct I2CBase *b __asm("a6"))
{
	LONG r;

	b->sdown = 0;
	r = I2CProbe(b);
	I2CReserved(b);			/* dead no-op		    */
	return r;
}

/* -------- VBlank server (datatab is_Code) ------------------------- */
/* a1 = is_Data = libbase; ticks the poll timeout down, always
** returns 0 (keep chaining other servers).			    */
LONG I2CIntr(register struct I2CBase *b __asm("a1"))
{
	if (b->timeout)
		--b->timeout;
	return 0;
}
