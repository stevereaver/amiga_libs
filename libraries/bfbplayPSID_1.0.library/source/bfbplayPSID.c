/*
**	bfbplayPSID.library V1.0 -- reconstructed implementation
**	"bfbplayPSID.library V1.0 (26.07.1996)"
**
**	PSID (C64 SID) module player: a thin tag-driven wrapper on
**	playsid.library (Hakan Sundell & Ron Birk).  InitModule(-30)
**	takes a TagItem list, loads the tune from a filename /
**	pre-opened handle / memory image, and hands it to playsid
**	vectors.  Play/stop/continue/subsong forward likewise.
**
**	Library base (dataSize 0xb2 = 178):
**	  +34 flag byte (bit3 delayed expunge), +36 exec, +40 dos,
**	  +44 seglist, +48 playsid base.
**
**	Session block (80 bytes, MEMF_CLEAR -- zeroed, unlike the
**	MED sibling's PUBLIC-only block):
**	  +0  byte=9 (player type), +1 playing, +2 modbuf,
**	  +6  buf2 (never set -- freed harmlessly by EndModule),
**	  +10 modlen, +14 len2, +20 songs-1, +24 cursong (1-based),
**	  +25 startSong, +26 "PSID", +30 name (buf+22), +34 30,
**	  +38 info record, +42 info size, +46 paused,
**	  +56 player-init flag.
**	  +2/+10 are offset%4==2 -- unaligned, 68020+ only.
**
**	InitModule tags: 0x80000007 session* (required; NULL data
**	-> 80B block alloc'd and written back to ti_Data),
**	0x80000001 filename, 0x80000002 open handle,
**	0x80000003 memory image (+ 0x80000008 length).
**
**	playsid.library vectors used: -30 player init (0 ok),
**	-36 shutdown, -54 load(a0=a1=buf,d0=len), -60 subsong(d0,
**	1-based), -66 stop-for-reload, -72 stop, -78 continue,
**	-96 volume(d0=50).
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
	APTR		 playsid;	/* +48			    */
	UBYTE		 pad52[126];
};

struct BfbSess {
	UBYTE	type;			/* +0  = 9		    */
	UBYTE	playing;		/* +1			    */
	APTR	modbuf;			/* +2  (unaligned!)	    */
	APTR	buf2;			/* +6  never set	    */
	ULONG	modlen;			/* +10 (unaligned)	    */
	ULONG	len2;			/* +14 never set	    */
	UBYTE	pad18[2];
	UWORD	songsm1;		/* +20 songs-1	    */
	UBYTE	pad22[2];
	UWORD	cursong;		/* +24 1-based; init'd by  */
					/*     a byte write to +25 */
					/*     = PSID startSong    */
	APTR	fmtname;		/* +26 "PSID"	    */
	APTR	name;			/* +30 buf+22	    */
	ULONG	namelen;		/* +34 = 30		    */
	APTR	info;			/* +38 info record	    */
	ULONG	infosz;			/* +42 = 16		    */
	UBYTE	paused;			/* +46			    */
	UBYTE	pad47[9];
	ULONG	pinit;			/* +56 player init'd	    */
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

/* playsid calls (a6 = playsid base) */
#define MPCALL(mp,lvo) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"\
    :\
    : "a"(__p_mp)\
    : "d0","a0","a1","fp0","fp1","cc","memory");})
#define MPCALL_D0(mp,lvo,arg) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register ULONG __p_a __asm("d0") = (ULONG)(arg);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(0 - " #lvo ":W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_mp), "d"(__p_a)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define MP_LOAD(mp,buf,len) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register APTR __p_a __asm("a0") = (APTR)(buf);\
  register APTR __p_b __asm("a1") = (APTR)(buf);\
  register ULONG __p_l __asm("d0") = (ULONG)(len);\
  __asm volatile ("jsr %/a6@(-54:W)\n"\
    : "+a"(__p_a), "+a"(__p_b), "+d"(__p_l)\
    : "a"(__p_mp)\
    : "d1","fp0","fp1","cc","memory");})
#define MP_STOPARG(mp,arg) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register APTR __p_a __asm("a0") = (APTR)(arg);\
  __asm volatile ("jsr %/a6@(-72:W)\n"\
    : "+a"(__p_a)\
    : "a"(__p_mp)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})
#define MP_CONTARG(mp,arg) ({\
  register APTR __p_mp __asm("a6") = (mp);\
  register APTR __p_a __asm("a0") = (APTR)(arg);\
  __asm volatile ("jsr %/a6@(-78:W)\n"\
    : "+a"(__p_a)\
    : "a"(__p_mp)\
    : "d0","d1","a1","fp0","fp1","cc","memory");})

extern char mpname[], dosname[], psidname[], desc[];

#define SESS_FLAGS	MEMF_CLEAR		/* 0x10000	    */
#define BUF_FLAGS	(MEMF_PUBLIC|MEMF_CLEAR)	/* 0x10001  */

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
	if (b->playsid)
		CLOSLIB(b->sys, b->playsid);
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

/* -------- tag scanner -------------------------------------------- */
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

/* -------- -30 InitModule ------------------------------------------ */
LONG InitModule(struct TagItem *tags __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	struct TagItem	*t;
	struct BfbSess	*sess;		/* uninit on the tag7-miss
					   error path, as shipped  */
	ULONG	 h;
	int	 ishandle = 0;

	b->playsid = OPENLIB_E(mpname, 1);
	if (!b->playsid)
		return -5;

	t = findtag(tags, 0x80000007);
	if (!t)
		return cleanup(b, sess, ishandle, 0, -17);
	if (!t->ti_Data) {
		t->ti_Data = (ULONG)ALLOCMEM(b->sys, SESS_SIZE,
					     SESS_FLAGS);
		if (!t->ti_Data)
			return -8;
	}
	sess = (struct BfbSess *)t->ti_Data;

	t = findtag(tags, 0x80000001);
	if (t) {
		h = DOS_OPEN(b->dos, (const char *)t->ti_Data,
			     MODE_OLDFILE);
		if (!h)
			return cleanup(b, sess, ishandle, 0, -6);
	} else {
		t = findtag(tags, 0x80000002);
		if (!t) {
			t = findtag(tags, 0x80000003);
			if (!t || !t->ti_Data)
				return cleanup(b, sess, ishandle, 0,
					       -17);
			sess->modbuf = (APTR)t->ti_Data;
			t = findtag(tags, 0x80000008);
			if (!t)
				return cleanup(b, sess, ishandle, 0,
					       -17);
			sess->modlen = t->ti_Data;
			goto havemod;
		}
		ishandle = 1;
		h = t->ti_Data;
		if (!h)
			return cleanup(b, sess, ishandle, h, -17);
	}
	/* file path: size via END+BEGIN seek pair, alloc, read	*/
	DOS_SEEK(b->dos, h, 0, OFFSET_END);
	sess->modlen = DOS_SEEK(b->dos, h, 0, OFFSET_BEGIN);
	sess->modbuf = ALLOCMEM(b->sys, sess->modlen, BUF_FLAGS);
	if (!sess->modbuf)
		return cleanup(b, sess, ishandle, h, -8);
	if (DOS_READ(b->dos, h, sess->modbuf, sess->modlen)
	    != sess->modlen)
		return cleanup(b, sess, ishandle, h, -7);
	if (!ishandle)
		DOS_CLOSE(b->dos, h);

havemod:
	sess->type = 9;
	sess->fmtname = psidname;
	sess->name = (UBYTE *)sess->modbuf + 22;
	sess->namelen = 30;
	/* shipped: byte write to +21 then word@20 decrement;
	   byte write to +25 (cursong's low byte) = startSong --
	   upper bytes keep prior contents for caller-supplied
	   sessions (only low bytes are initialized)		    */
	((UBYTE *)&sess->songsm1)[1] = ((UBYTE *)sess->modbuf)[15];
	sess->songsm1 -= 1;
	((UBYTE *)&sess->cursong)[1] = ((UBYTE *)sess->modbuf)[17];
	return 0;
}

/* error unwind: frees modbuf + session, closes owned handle.
   The tag7 ti_Data slot keeps pointing at the freed session --
   stale-pointer defect, as shipped.			    */
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

/* -------- -36 EndModule ------------------------------------------- */
LONG EndModule(struct BfbSess *s __asm("a0"),
	       struct BfbBase *b __asm("a6"))
{
	if (!s)
		return 0;
	if (b->playsid && s->pinit) {
		MPCALL(b->playsid, 66);		/* stop-for-reload  */
		MPCALL(b->playsid, 36);		/* shutdown	    */
		s->pinit = 0;
		s->paused = 0;
		s->playing = 0;
	}
	if (s->modbuf) {
		FREEMEM(b->sys, s->modbuf, s->modlen);
		s->modbuf = 0;
	}
	if (s->buf2) {
		FREEMEM(b->sys, s->buf2, s->len2);
		s->buf2 = 0;
	}
	if (b->playsid) {
		CLOSLIB(b->sys, b->playsid);
		b->playsid = 0;
	}
	FREEMEM(b->sys, s, SESS_SIZE);
	return 0;
}

/* -------- -42 PlayModule ------------------------------------------ */
LONG PlayModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	/* shipped code checks ExecBase SoftVer >= 36 (OS 2.0)  */
	if (*(UWORD *)((UBYTE *)b->sys + 34) < 36)
		return -16;
	if (!s->pinit) {
		if (MPCALL_D0(b->playsid, 30, 0))
			return -9;
	}
	s->pinit = 1;
	if (s->playing)
		MPCALL(b->playsid, 66);
	MP_LOAD(b->playsid, s->modbuf, s->modlen);
	MPCALL_D0(b->playsid, 96, 50);
	MPCALL_D0(b->playsid, 60, s->cursong);
	s->playing = 1;
	s->paused = 0;
	return 0;
}

/* -------- -48 StopModule ------------------------------------------ */
/* shipped code takes the session in A5, not A0 -- odd ABI.
   a5 is reserved under this backend, so the register is read
   out with an explicit move instead of a param binding.	    */
void StopModule(struct BfbBase *b __asm("a6"))
{
	struct BfbSess *s;

	__asm volatile ("movel %%a5,%0" : "=a"(s));
	MP_STOPARG(b->playsid, s);	/* playsid -72, a0=sess */
	s->playing = 0;
	s->paused = 1;
}

/* -------- -54 ContModule ------------------------------------------ */
LONG ContModule(struct BfbSess *s __asm("a0"),
		struct BfbBase *b __asm("a6"))
{
	if (!s->playing && s->paused) {
		MP_CONTARG(b->playsid, s);	/* -78, a0=sess	    */
		s->paused = 0;
		s->playing = 1;
	}
	return 0;
}

/* -------- -72 SetSubsong ------------------------------------------- */
/*	d0 = 0-based song; clamps to songs-1 without changing;	    */
/*	stores 1-based internally; returns the 0-based index.	    */
LONG SetSubsong(struct BfbSess *s __asm("a0"), LONG n __asm("d0"),
		struct BfbBase *b __asm("a6"))
{
	UBYTE wasplaying = s->playing;
	ULONG songs = s->songsm1;
	ULONG ret = songs;

	if ((LONG)songs < n)
		return (LONG)ret;
	n++;
	s->cursong = (UWORD)n;
	ret = n;
	if (wasplaying) {
		MPCALL(b->playsid, 66);
		MPCALL_D0(b->playsid, 60, ret);
	}
	return (LONG)(ret - 1);
}

/* -------- -78 GetInfo ---------------------------------------------- */
/*	lazily builds {2, 30, author(buf+54), released(buf+86)};	    */
/*	uses absolute 4 for execbase, as shipped.		    */
APTR GetInfo(struct BfbSess *s __asm("a0"),
	     struct BfbBase *b __asm("a6"))
{
	ULONG *rec;

	if (!s->info) {
		rec = ALLOCMEM((struct ExecBase *)4, 16, MEMF_CLEAR);
		s->info = rec;
		if (!rec)
			return 0;
		s->infosz = 16;
		rec[0] = 2;
		rec[1] = 30;
		rec[2] = (ULONG)((UBYTE *)s->modbuf + 54);
		rec[3] = (ULONG)((UBYTE *)s->modbuf + 86);
	}
	return s->info;
}

/* -------- -84 GetDesc ---------------------------------------------- */
const char * GetDesc(struct BfbBase *b __asm("a6"))
{
	return desc;
}
