/*
**	bfbplayMED!.library V1.0 -- reconstructed implementation
**	"bfbplayMED!.library V1.0 (28.03.1996)" by Teijo Kinnunen
**
**	MED / OctaMED module player: a thin tag-driven wrapper on
**	medplayer.library.  InitModule(-30) takes a TagItem list,
**	loads the module from a filename / pre-opened handle / memory
**	image, and hands it to medplayer -102.  Play control and
**	volume forward to medplayer vectors.
**
**	Library base (dataSize 0xb2 = 178):
**	  +34 flag byte (bit3 delayed expunge), +36 exec, +40 dos,
**	  +44 seglist, +48 medplayer base, +156 word "MP player
**	  initialized" flag.
**
**	Session block (80 bytes, MEMF_PUBLIC -- NOT cleared):
**	  +0 byte=4, +1 playing, +2 modbuf (unaligned LONG!),
**	  +10 modlen (unaligned), +20 maxvol (uninitialized),
**	  +21 module byte 51, +26 =120, +46 stopped flag.
**	  All LONG fields sit at offset%4==2 -- requires 68020+
**	  unaligned access, as shipped.
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
	APTR		 medplayer;	/* +48			    */
	UBYTE		 pad52[104];	/* +52 .. +155		    */
	UWORD		 mpinit;	/* +156 MP player up	    */
	UBYTE		 pad158[20];
};

struct BfbSess {
	UBYTE	type;			/* +0  = 4		    */
	UBYTE	playing;		/* +1			    */
	APTR	modbuf;			/* +2  (unaligned!)	    */
	UBYTE	pad6[4];
	ULONG	modlen;			/* +10 (unaligned)	    */
	UBYTE	pad14[6];
	UWORD	maxvol;			/* +20 never written	    */
	UBYTE	modhdr51;		/* +21 module[51]	    */
	UBYTE	pad22[4];
	ULONG	unk120;			/* +26 = 120		    */
	UBYTE	pad30[16];
	UBYTE	stopped;		/* +46			    */
	UBYTE	pad47[33];
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
#define CLOSLIB_E(lib) ({\
  register struct ExecBase * __p_sys __asm("a6") = (struct ExecBase *)4;\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})
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

/* dos calls through b->dos */
#define DOSCALL(lvo) \
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"
#define DOS_OPEN(dos,name,mode) ({\
  register APTR __p_dos __asm("a6") = (dos);\
  register const char * __p_n __asm("d1") = (name);\
  register ULONG __p_m __asm("d2") = (ULONG)(mode);\
  register ULONG __p_res __asm("d0");\
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
    : "d0","a0","a1","fp0","fp1","cc","memory");})
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

/* medplayer calls (a6 = medplayer base) */
#define MPCALL(mp,lvo) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"\
    :\
    : "a"(__p_mp)\
    : "d0","a0","a1","fp0","fp1","cc","memory");})
#define MPCALL_A0(mp,lvo,arg) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register APTR __p_a __asm("a0") = (APTR)(arg);\
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"\
    : "+a"(__p_a)\
    : "a"(__p_mp)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define MPCALL_D0(mp,lvo,arg) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register ULONG __p_a __asm("d0") = (ULONG)(arg);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_mp), "d"(__p_a)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})

extern char mpname[], dosname[], desc[];

static LONG cleanup(struct BfbBase *b, struct BfbSess *sess,
		    ULONG srchdl, int ishandle, ULONG h, LONG rc);

#define MODE_OLDFILE	1005
#define OFFSET_END	1
#define OFFSET_BEGIN	(-1)

/* -------- LibInit: open dos.library ------------------------------ */
struct BfbBase * LibInit(struct BfbBase *b __asm("d0"),
			 APTR seglist __asm("a0"),
			 struct ExecBase *sys __asm("a6"))
{
	b->sys = sys;
	b->seglist = seglist;
	b->dos = OPENLIB_E(dosname, 0);	/* any version	*/
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
	if (b->medplayer) {
		register APTR __p_mp __asm("a6") = b->medplayer;
		/* calls medplayer's own Close vector, then exec
		   CloseLibrary on it -- a double-close, as shipped */
		__asm volatile ("jsr %/a6@(-36:W)\n"
			:
			: "a"(__p_mp)
			: "d0","a0","a1","fp0","fp1","cc","memory");
		CLOSLIB(b->sys, b->medplayer);
	}
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

/* -------- tag scanner (internal 0x53e) ---------------------------- */
/*	Scans {tag,data} pairs; tag==0 terminates.  Returns &tag or 0. */
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

/* -------- -30 InitModule ------------------------------------------ */
/*	tags: 0x80000007 session* (required; value!=0 -> caller's      */
/*	80B struct, else alloc'd -- the store-back encodes a1@(4),    */
/*	a latent stray write, see defects), 0x80000001 filename,     */
/*	0x80000002 open handle, 0x80000003 mem image + 0x80000008 len.*/
LONG InitModule(struct TagItem *tags __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	struct TagItem	*t;
	struct BfbSess	*sess;		/* uninit on early errs,	   */
					/* as shipped (see defects)  */
	ULONG	 srchdl = 0;
	int	 ishandle = 0;
	ULONG	 h;

	b->medplayer = OPENLIB_E(mpname, 2);
	if (!b->medplayer)
		return -4;

	t = findtag(tags, 0x80000007);
	if (!t)
		goto err17;
	if (!t->ti_Data) {
		APTR m = ALLOCMEM(b->sys, SESS_SIZE, MEMF_PUBLIC);
		t->ti_Data = (ULONG)m;	/* shipped code writes	*/
					/* a1@(4) here - stray	*/
		if (!m)
			return -8;
	}
	sess = (struct BfbSess *)t->ti_Data;

	t = findtag(tags, 0x80000001);
	if (!t) {
		t = findtag(tags, 0x80000002);
		if (!t) {
			t = findtag(tags, 0x80000003);
			if (!t)
				goto err17;
			if (!t->ti_Data)
				goto err17;
			srchdl = t->ti_Data;	/* module image	    */
			t = findtag(tags, 0x80000008);
			if (!t)
				goto err17;
			sess->modbuf = (APTR)srchdl;
			sess->modlen = t->ti_Data;
			goto havemod;
		}
		ishandle = 1;
		h = t->ti_Data;
		if (!h)
			goto err17;
	} else {
		h = DOS_OPEN(b->dos, (const char *)t->ti_Data,
			     MODE_OLDFILE);
		if (!h)
			goto err6;
	}
	/* h = BCPL handle: size via END+BEGIN seek pair	    */
	DOS_SEEK(b->dos, h, 0, OFFSET_END);
	sess->modlen = DOS_SEEK(b->dos, h, 0, OFFSET_BEGIN);
	sess->modbuf = ALLOCMEM(b->sys, sess->modlen,
			      MEMF_PUBLIC | MEMF_CLEAR);
	if (!sess->modbuf)
		goto err8;
	if (DOS_READ(b->dos, h, sess->modbuf, sess->modlen)
	    != sess->modlen)
		goto err7;
	if (!ishandle)
		DOS_CLOSE(b->dos, h);
	srchdl = 0;

havemod:
	sess->type = 4;
	sess->unk120 = 120;
	MPCALL_A0(b->medplayer, 102, sess->modbuf);
	sess->modhdr51 = ((UBYTE *)sess->modbuf)[51];
	return 0;

err6:	return cleanup(b, sess, srchdl, ishandle, h, -6);
err7:	return cleanup(b, sess, srchdl, ishandle, h, -7);
err8:	return cleanup(b, sess, srchdl, ishandle, h, -8);
err17:	return cleanup(b, sess, srchdl, ishandle, h, -17);
}

/* error unwind: frees modbuf + session, closes owned handle	    */
static LONG cleanup(struct BfbBase *b, struct BfbSess *sess,
		    ULONG srchdl, int ishandle, ULONG h, LONG rc)
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

/* -------- -36 EndModule ------------------------------------------- */
LONG EndModule(struct BfbSess *s __asm("a0"),
	       struct BfbBase *b __asm("a6"))
{
	if (b->medplayer) {
		if (s) {
			if (s->playing) {
				MPCALL(b->medplayer, 54);
				s->playing = 0;
			}
			if (b->mpinit) {
				MPCALL(b->medplayer, 36);
				b->mpinit = 0;
			}
			if (s->modbuf)
				FREEMEM(b->sys, s->modbuf, s->modlen);
		}
		CLOSLIB(b->sys, b->medplayer);
		b->medplayer = 0;
	}
	if (s)
		FREEMEM(b->sys, s, SESS_SIZE);
	return 0;
}

/* -------- -42 PlayModule ------------------------------------------ */
LONG PlayModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (!b->medplayer)
		return -1;
	if (!b->mpinit) {
		if (MPCALL_D0(b->medplayer, 30, 0))
			return -1;
		b->mpinit = 1;
	}
	if (s->playing)
		MPCALL(b->medplayer, 54);
	MPCALL_A0(b->medplayer, 42, s->modbuf);
	s->playing = 1;
	s->stopped = 0;
	return 0;
}

/* -------- -48 StopModule ------------------------------------------ */
void StopModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (b->medplayer) {
		MPCALL(b->medplayer, 54);
		s->playing = 0;
		s->stopped = 1;
	}
}

/* -------- -54 ContModule ------------------------------------------ */
LONG ContModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (b->medplayer && !s->playing && s->stopped) {
		MPCALL_A0(b->medplayer, 48, s->modbuf);
		s->playing = 1;
		s->stopped = 0;
	}
	return 0;
}

/* -------- -72 SetVolume -------------------------------------------- */
LONG SetVolume(struct BfbSess *s __asm("a0"), LONG vol __asm("d0"),
	       struct BfbBase *b __asm("a6"))
{
	int wasplaying = s->playing;

	if (wasplaying)
		StopModule(s, b);
	if (b->medplayer) {
		if (vol >= (SHORT)s->maxvol)
			vol = (SHORT)s->maxvol;
		MPCALL_D0(b->medplayer, 96, vol);
		if (wasplaying)
			PlayModule(s, b);
	}
	return vol;
}

/* -------- -84 GetDesc --------------------------------------------- */
const char * GetDesc(struct BfbBase *b __asm("a6"))
{
	return desc;
}
