/*
**	bfbplayGMOD.library V1.0 -- reconstructed implementation
**	"bfbplayGMOD.library V1.0 (13.06.1996)"
**
**	GMOD module player (Bryan Ford module structure) -- same bfb
**	tag-driven template as bfbplayPSID/MED, but the module image
**	itself is 68k code: the player calls fixed offsets inside the
**	loaded buffer (+20 play song, +24 stop, +40 CIA tick, +64 song
**	count) and drives the tick from a CIA timer interrupt grabbed
**	via ciaa/ciab.resource AddICRVector, bounced through exec Cause
**	to a softint trampoline.
**
**	Library base (dataSize 0xb2 = 178):
**	  +34 flag byte (bit3 delayed expunge), +36 exec, +40 dos,
**	  +44 seglist, +158 CIA period word (0x3781), +160 ciaa res,
**	  +164 ciab res, +168 CIA chip base, +172 resource used,
**	  +176 timer byte (0=A,1=B).
**
**	Session block (80 bytes, MEMF_CLEAR):
**	  +0  byte type=7, +1 module-running byte, +2 modbuf,
**	  +10 modlen, +20 songs-1 (word, from modbuf+64()),
**	  +24 cursong (word, 0-based), +26 "GMOD", +38/+42 second
**	  buffer (never set -- freed harmlessly), +56 playing flag.
**
**	InitModule tags: 0x80000007 session* (required; NULL data
**	-> 80B block alloc'd and written back), 0x80000001 filename,
**	0x80000002 open handle (not closed), 0x80000003 memory image
**	(+ 0x80000008 length).  modbuf is MEMF_CHIP|MEMF_CLEAR.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <utility/tagitem.h>

struct BfbBase {
	struct Library	 lib;		/* +0  (OpenCnt at +32)	    */
	UBYTE		 flags;		/* +34 bit3 delayed expunge  */
	UBYTE		 pad35;
	struct ExecBase	*sys;		/* +36			    */
	APTR		 dos;		/* +40			    */
	APTR		 seglist;	/* +44			    */
	UBYTE		 pad48[110];
	UWORD		 period;	/* +158 CIA timer period    */
	APTR		 ciaa_res;	/* +160			    */
	APTR		 ciab_res;	/* +164			    */
	APTR		 cia_base;	/* +168 chip in use	    */
	APTR		 cia_res;	/* +172 resource in use	    */
	UBYTE		 timer;		/* +176 0=A 1=B		    */
	UBYTE		 pad177;
};

struct BfbSess {
	UBYTE	type;			/* +0  = 7		    */
	UBYTE	running;		/* +1  module code active    */
	APTR	modbuf;			/* +2  (unaligned!)	    */
	APTR	buf2;			/* +6  never set		    */
	ULONG	modlen;			/* +10 (unaligned)	    */
	ULONG	len2;			/* +14 never set	    */
	UBYTE	pad18[2];
	UWORD	songsm1;		/* +20 songs-1	    */
	UBYTE	pad22[2];
	UWORD	cursong;		/* +24 0-based	    */
	APTR	fmtname;		/* +26 "GMOD"	    */
	APTR	name;			/* +30 never set	    */
	ULONG	namelen;		/* +34 never set	    */
	APTR	buf3;			/* +38 second buffer	    */
	ULONG	len3;			/* +42			    */
	UBYTE	pad46[10];
	ULONG	playing;		/* +56			    */
	UBYTE	pad60[20];
} __attribute__((packed));

#define SESS_SIZE	80

/* -------- exec / dos LVO calls ---------------------------------- */
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
#define OPENRES(name) ({\
  register struct ExecBase * __p_sys __asm("a6") = (struct ExecBase *)4;\
  register const char * __p_name __asm("a1") = (name);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-498:W)\n"\
    : "=r"(__p_res), "+a"(__p_name)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_res;})
#define ALLOCMEM(sys,size,fl) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define FREEMEM(sys,mem,sz) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#define CLOSLIB(sys,lib) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
#define REMOVENODE(sys,node) ({\
  register struct ExecBase * __p_sys __asm("a6") = (sys);\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})

#define MODE_OLDFILE	1005
#define OFFSET_END	1
#define OFFSET_BEGIN	(-1)

#define DOS_OPEN(dos,name,mode) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_n __asm("d1") = (name);\
  register ULONG __p_m __asm("d2") = (ULONG)(mode);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-30:W)\n"\
    : "=r"(__p_res), "+d"(__p_n), "+d"(__p_m)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define DOS_CLOSE(dos,h) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register ULONG __p_h __asm("d1") = (ULONG)(h);\
  __asm volatile ("jsr %/a6@(-36:W)\n"\
    : "+d"(__p_h)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");})
#define DOS_READ(dos,h,buf,len) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register ULONG __p_h __asm("d1") = (ULONG)(h);\
  register APTR __p_b __asm("d2") = (APTR)(buf);\
  register ULONG __p_l __asm("d3") = (ULONG)(len);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-42:W)\n"\
    : "=r"(__p_res), "+d"(__p_h), "+d"(__p_b), "+d"(__p_l)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define DOS_SEEK(dos,h,off,mode) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register ULONG __p_h __asm("d1") = (ULONG)(h);\
  register LONG __p_o __asm("d2") = (LONG)(off);\
  register LONG __p_m __asm("d3") = (LONG)(mode);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-66:W)\n"\
    : "=r"(__p_res), "+d"(__p_h), "+d"(__p_o), "+d"(__p_m)\
    : "a"(__p_dos)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

/* calls into the loaded GMOD image (a0 = modbuf, offset in bytes) */
#define MODCALL(buf,off) ({\
  register APTR __p_b __asm("a0") = (buf);\
  __asm volatile ("jsr %/a0@(0 + " #off ":W)\n"\
    :\
    : "a"(__p_b)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define MODCALL_D0(buf,off,arg) ({\
  register APTR __p_b __asm("a0") = (buf);\
  register ULONG __p_a __asm("d0") = (ULONG)(arg);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a0@(0 + " #off ":W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_b), "d"(__p_a)\
    : "d1","a1","fp0","fp1","cc","memory");\
  __p_res;})

/* cia resource calls (a6 = resource base) */
#define ADDICR(res,bit,intr) ({\
  register APTR __p_r __asm("a6") = (res);\
  register ULONG __p_bit __asm("d0") = (ULONG)(bit);\
  register APTR __p_i __asm("a1") = (APTR)(intr);\
  __asm volatile ("jsr %/a6@(-6:W)\n"\
    : "+d"(__p_bit), "+a"(__p_i)\
    : "a"(__p_r)\
    : "d1","a0","fp0","fp1","cc","memory");\
  __p_bit;})
#define REMICR(res,intr) ({\
  register APTR __p_r __asm("a6") = (res);\
  register APTR __p_i __asm("a1") = (APTR)(intr);\
  __asm volatile ("jsr %/a6@(-12:W)\n"\
    : "+a"(__p_i)\
    : "a"(__p_r)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})

extern char cianame[], gmodname[], dosname[], desc[];
extern struct BfbSess *cur_sess;	/* LAB_001D code-hunk global  */
extern char icr_intr[];			/* LAB_0053 interrupt chain   */

/* -------- LibInit: open dos.library ------------------------------ */
struct BfbBase * LibInit(struct BfbBase *b __asm("d0"),
			 APTR seglist __asm("a0"),
			 struct ExecBase *sys __asm("a6"))
{
	b->sys = sys;
	b->seglist = seglist;
	b->dos = OPENLIB_E(dosname, 0);
	return b;
}

struct BfbBase * LibOpen(struct BfbBase *b __asm("a6"))
{
	b->lib.lib_OpenCnt++;
	b->flags &= ~8;
	return b;
}

LONG LibClose(struct BfbBase *b __asm("a6"));

APTR LibExpunge(struct BfbBase *b __asm("a6"))
{
	APTR seg;

	if (b->lib.lib_OpenCnt) {
		b->flags |= 8;
		return 0;
	}
	seg = b->seglist;
	REMOVENODE(b->sys, b);
	CLOSLIB(b->sys, b->dos);
	FREEMEM(b->sys,
		(UBYTE *)b - b->lib.lib_NegSize,
		b->lib.lib_NegSize + b->lib.lib_PosSize);
	return seg;
}

LONG LibClose(struct BfbBase *b __asm("a6"))
{
	if (--b->lib.lib_OpenCnt == 0 && (b->flags & 8))
		LibExpunge(b);
	return 0;
}

LONG LibNull(struct BfbBase *b __asm("a6"))
{
	return 0;
}
LONG RetM1(struct BfbBase *b __asm("a6"))
{
	return -1;
}

/* -------- tag scanner (LAB_0047) ----------------------------------- */
static struct TagItem * findtag(struct TagItem *t, ULONG tag)
{
	for (;;) {
		if (t->ti_Tag == tag)
			return t;
		if (t->ti_Tag == 0)
			return 0;
		t++;
	}
}

static LONG cleanup(struct BfbBase *b, struct BfbSess *sess,
		    int ishandle, ULONG h, LONG rc);
LONG StopModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"));

/* -------- -30 InitModule ------------------------------------------ */
LONG InitModule(struct TagItem *tags __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	struct TagItem	*t;
	struct BfbSess	*sess;
	ULONG	 h;
	int	 ishandle = 0;

	t = findtag(tags, 0x80000007);
	if (!t)
		return cleanup(b, sess, ishandle, 0, -17);
	if (!t->ti_Data) {
		t->ti_Data = (ULONG)ALLOCMEM(b->sys, SESS_SIZE,
					     MEMF_CLEAR);
		if (!t->ti_Data)
			return -8;
	}
	sess = (struct BfbSess *)t->ti_Data;

	t = findtag(tags, 0x80000001);
	if (t) {
		h = (ULONG)DOS_OPEN(b->dos, (const char *)t->ti_Data,
				    MODE_OLDFILE);
		if (!h)
			return cleanup(b, sess, ishandle, 0, -6);
	} else {
		t = findtag(tags, 0x80000002);
		if (!t) {
			ULONG img, len;
			t = findtag(tags, 0x80000003);
			if (!t || !t->ti_Data)
				return cleanup(b, sess, ishandle, 0,
					       -17);
			img = t->ti_Data;
			t = findtag(tags, 0x80000008);
			if (!t)
				return cleanup(b, sess, ishandle, 0,
					       -17);
			len = t->ti_Data;
			sess->modbuf = (APTR)img;
			sess->modlen = len;
			goto havemod;
		}
		ishandle = 1;
		h = t->ti_Data;
		if (!h)
			return cleanup(b, sess, ishandle, h, -17);
	}
	/* file path: Seek(END) then Seek(BEGIN) -- the second Seek's
	   return is the pre-END position = the file size	    */
	DOS_SEEK(b->dos, h, 0, OFFSET_END);
	sess->modlen = DOS_SEEK(b->dos, h, 0, OFFSET_BEGIN);
	sess->modbuf = ALLOCMEM(b->sys, sess->modlen,
			      MEMF_CHIP | MEMF_CLEAR);
	if (!sess->modbuf)
		return cleanup(b, sess, ishandle, h, -8);
	if (DOS_READ(b->dos, h, sess->modbuf, sess->modlen)
	    != sess->modlen)
		return cleanup(b, sess, ishandle, h, -7);
	if (!ishandle)
		DOS_CLOSE(b->dos, h);

havemod:
	sess->type = 7;
	sess->fmtname = gmodname;
	/* modbuf+64: embedded routine returns the song count	    */
	sess->songsm1 = (UWORD)(MODCALL_D0(sess->modbuf, 64, 1) - 1);
	cur_sess = sess;
	return 0;
}

/* error unwind: frees modbuf + session, closes owned handle.	    */
static LONG cleanup(struct BfbBase *b, struct BfbSess *sess,
		    int ishandle, ULONG h, LONG rc)
{
	if (sess) {
		if (sess->modbuf) {
			FREEMEM(b->sys, sess->modbuf, sess->modlen);
			sess->modbuf = 0;
		}
		FREEMEM(b->sys, sess, SESS_SIZE);
	}
	if (!ishandle && h)
		DOS_CLOSE(b->dos, h);
	return rc;
}

/* -------- CIA helpers ---------------------------------------------- */
/* ensure_resources (LAB_0044): lazily opens ciaa.resource at +160,
** then patches the name string's 'a' -> 'b' in place and opens
** ciab.resource at +164.  The string mutation is permanent (idempotent
** on later calls).							    */
static LONG ensure_resources(struct BfbBase *b)
{
	if (!b->ciaa_res) {
		b->ciaa_res = OPENRES(cianame);
		if (!b->ciaa_res)
			return -1;
		cianame[3] = 'b';		/* "ciaa" -> "ciab"  */
		b->ciab_res = OPENRES(cianame);
		if (!b->ciab_res)
			return -1;
	}
	return 0;
}

/* cia_stop (LAB_004F): stop the running timer + RemICRVector	    */
static void cia_stop(struct BfbBase *b)
{
	UBYTE *chip;

	if (!b->cia_base)
		return;
	chip = b->cia_base;
	if (!b->timer)
		chip[0x0e00] = 0;		/* CRA = 0	    */
	else
		chip[0x0f00] = 0;		/* CRB = 0	    */
	REMICR(b->cia_res, icr_intr);
	b->cia_base = 0;
	b->timer = 0;
}

/* cia_start (LAB_004A): release any current timer, then grab the
** first free timer trying ciaa A, ciaa B, ciab A, ciab B via
** AddICRVector.  Programs TALO/TAHI (or TB) with the 0x3781 period
** and starts the timer (CRA/CRB = 0x11 = LOAD|START).		    */
static LONG cia_start(struct BfbBase *b)
{
	UBYTE *chip;
	APTR res;
	ULONG t;

	cia_stop(b);
	b->period = 0x3781;
	chip = (UBYTE *)0xbfe001;		/* CIAA_PRA	    */
	t = 0;
	if (b->ciaa_res) {
		res = b->ciaa_res;
		if (!ADDICR(res, 0, icr_intr))
			goto got;
		t = 1;
		if (!ADDICR(res, 1, icr_intr))
			goto got;
	}
	chip = (UBYTE *)0xbfd000;		/* CIAB_PRA	    */
	t = 0;
	if (b->ciab_res) {
		res = b->ciab_res;
		if (!ADDICR(res, 0, icr_intr))
			goto got;
		t = 1;
		if (!ADDICR(res, 1, icr_intr))
			goto got;
	}
	return -1;
got:
	b->cia_base = chip;
	b->cia_res = res;
	b->timer = (UBYTE)t;
	if (!t)
		chip[0x0400] = ((UBYTE *)&b->period)[1];	/* TALO */
	else
		chip[0x0600] = ((UBYTE *)&b->period)[1];	/* TBLO */
	if (!t)
		chip[0x0500] = ((UBYTE *)&b->period)[0];	/* TAHI */
	else
		chip[0x0700] = ((UBYTE *)&b->period)[0];	/* TBHI */
	chip[t ? 0x0f00 : 0x0e00] = 0x11;		/* CRx = load|start */
	return 0;
}

/* -------- -36 EndModule ------------------------------------------- */
LONG EndModule(struct BfbSess *s __asm("a0"),
	       struct BfbBase *b __asm("a6"))
{
	if (!s)
		goto done;
	if (s->playing) {
		StopModule(s, b);
		cia_stop(b);
		s->playing = 0;
	}
	if (s->modbuf) {
		FREEMEM(b->sys, s->modbuf, s->modlen);
		s->modbuf = 0;
	}
	if (s->buf3) {
		FREEMEM(b->sys, s->buf3, s->len3);
		s->buf3 = 0;
	}
	FREEMEM(b->sys, s, SESS_SIZE);
done:
	cur_sess = 0;
	return 0;
}

/* -------- -42 PlayModule ------------------------------------------ */
LONG PlayModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (ensure_resources(b) < 0)
		return -13;
	if (s->running)
		StopModule(s, b);
	MODCALL_D0(s->modbuf, 20, s->cursong);	/* mod+20: play n  */
	if (!s->playing && cia_start(b) < 0)
		return -13;
	s->running = 1;
	s->playing = 1;
	return 0;
}

/* -------- -48 StopModule ------------------------------------------ */
LONG StopModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (s->running) {
		MODCALL(s->modbuf, 24);		/* mod+24: stop    */
		s->running = 0;
	}
	return 0;
}

/* -------- -72 SetSubsong ------------------------------------------- */
/*	d0 = 0-based song; if running, restarts via modbuf+20;	    */
/*	stores raw (0-based) at sess+24; returns it.		    */
LONG SetSubsong(struct BfbSess *s __asm("a0"), LONG n __asm("d0"),
		struct BfbBase *b __asm("a6"))
{
	UBYTE wasrun;

	if (n < 0)
		return s->cursong;
	wasrun = s->running;
	if (wasrun)
		StopModule(s, b);
	if ((SHORT)s->songsm1 >= (SHORT)n) {
		s->cursong = (UWORD)n;
		if (!wasrun)
			return s->cursong;
	}
	MODCALL_D0(s->modbuf, 20, s->cursong);
	s->running = 1;
	return s->cursong;
}

/* -------- -78 GetInfo ---------------------------------------------- */
LONG GetInfo(struct BfbSess *s __asm("a0"),
	     struct BfbBase *b __asm("a6"))
{
	return 0;
}

/* -------- -84 GetDesc ---------------------------------------------- */
const char * GetDesc(struct BfbBase *b __asm("a6"))
{
	return desc;
}
