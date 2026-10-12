/*
**	screennotify.library 1.2 -- reconstructed library code
**
**	Watches the system for screen/workbench events by patching
**	four intuition vectors (OpenScreenTagList, CloseScreen,
**	CloseWorkBench, PubScreenStatus) and broadcasting
**	synchronous messages to registered client message ports.
**
**	A worker process ("scn service process") owns a private
**	message port; the OpenScreenTagList patch posts to it, and
**	the worker rebroadcasts a type-3 event after a 10 tick delay.
*/

#include <exec/types.h>
#include <exec/lists.h>
#include <exec/ports.h>
#include <exec/semaphores.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <exec/tasks.h>

/* -------- lib base layout ---------------------------------------- */

struct SNBlk {
	struct MinList		list;		/* +0   client nodes      */
	UWORD			pad0;		/* +12			*/
	struct SignalSemaphore	sem;		/* +14  46 bytes	*/
	struct Message		msg;		/* +60  mn_Length = 28	*/
	ULONG			body[2];	/* +80  {type, arg}	*/
	struct MsgPort		port;		/* +88			*/
};						/* = 122 bytes		*/

struct SNBase {
	struct Library		lib;		/* +0			*/
	UBYTE			flag;		/* +34 "wb open" flag	*/
	UBYTE			pad0;
	APTR			seglist;	/* +36			*/
	struct Library		*exec;		/* +40			*/
	struct Library		*intu;		/* +44			*/
	struct Library		*gfx;		/* +48			*/
	struct Library		*dos;		/* +52			*/
	struct Message		msg;		/* +56  handshake msg	*/
	ULONG			body;		/* +76  out:in param	*/
	struct MsgPort		*replyport;	/* +80			*/
	struct MsgPort		*workerport;	/* +84			*/
	struct SNBlk		blk1;		/* +88  screen close	*/
	struct SNBlk		blk2;		/* +210 pub status	*/
	struct SNBlk		blk3;		/* +332 workbench	*/
	APTR			oldostl;	/* +454			*/
	APTR			oldcs;		/* +458			*/
	APTR			oldcwb;		/* +462			*/
	APTR			oldpss;		/* +466			*/
	UBYTE			tmpl[0x1b0];	/* +470 patch code copy	*/
};

/* node allocated by the add functions (18 bytes):
**   MinNode	@0	ln_Pri  = client priority
**   	    	    	ln_Name = client message port
**   arg	@14	client argument filter
*/
struct SNNode {
	struct Node	n;
	APTR		arg;
};

/* -------- imported code images (screennotify_lib.s) -------------- */

extern const UBYTE	sn_worker_img[];	/* worker proc code	*/
extern const UBYTE	sn_patch_img[];		/* patch template	*/
extern const char	sn_intu_name[];
extern const char	sn_dos_name[];
extern const char	sn_gfx_name[];

#define	WORKER_IMG_SIZE	0x9c
#define	PATCH_IMG_SIZE	0x1b0

/* -------- exec/dos/gfx stubs ------------------------------------- */

#define CALL0(sys,lvo,res) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "=d"(__p_res) : "a"(__p_e)\
    : "d1","a0","a1","cc","memory");\
  __p_res;})

#define CALL_A0(sys,lvo,a0) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_a0 __asm("a0") = (APTR)(a0);\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "+a"(__p_a0) : "a"(__p_e)\
    : "d0","d1","a1","cc","memory");})

#define CALL_A0R(sys,lvo,a0,res) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_a0 __asm("a0") = (APTR)(a0);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "=d"(__p_res), "+a"(__p_a0) : "a"(__p_e)\
    : "d1","a1","cc","memory");\
  __p_res;})

#define CALL_A1(sys,lvo,a1) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_a1 __asm("a1") = (APTR)(a1);\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "+a"(__p_a1) : "a"(__p_e)\
    : "d0","d1","a0","cc","memory");})

#define CALL_A1D0(sys,lvo,a1,d0) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_a1 __asm("a1") = (APTR)(a1);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(d0);\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "+a"(__p_a1), "+d"(__p_d0) : "a"(__p_e)\
    : "d1","a0","cc","memory");})

#define CALL_A1D0R(sys,lvo,a1,d0,res) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_a1 __asm("a1") = (APTR)(a1);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(d0);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "=d"(__p_res), "+a"(__p_a1) : "a"(__p_e), "d"(__p_d0)\
    : "d1","a0","cc","memory");\
  __p_res;})

#define CALL_D0D1R(sys,lvo,d0,d1,res) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(d0);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(d1);\
  __asm volatile ("jsr %/a6@(" #lvo ":W)\n"\
    : "+d"(__p_d0) : "a"(__p_e), "d"(__p_d1)\
    : "a0","a1","cc","memory");\
  (APTR)__p_d0;})

#define OPENLIB_E(sys,name,ver) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register const char * __p_n __asm("a1") = (name);\
  register ULONG __p_v __asm("d0") = (ULONG)(ver);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=d"(__p_res), "+a"(__p_n) : "a"(__p_e), "d"(__p_v)\
    : "d1","a0","cc","memory");\
  __p_res;})

#define COPYMEM(sys,s,d,n) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register const void * __p_s __asm("a0") = (s);\
  register void * __p_d __asm("a1") = (d);\
  register ULONG __p_n __asm("d0") = (ULONG)(n);\
  __asm volatile ("jsr %/a6@(-624:W)\n"\
    : "+a"(__p_s), "+a"(__p_d), "+d"(__p_n) : "a"(__p_e)\
    : "d1","cc","memory");})

#define PUTMSG(sys,p,m) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register struct MsgPort * __p_p __asm("a0") = (p);\
  register struct Message * __p_m __asm("a1") = (m);\
  __asm volatile ("jsr %/a6@(-366:W)\n"\
    : "+a"(__p_p), "+a"(__p_m) : "a"(__p_e)\
    : "d0","d1","cc","memory");})

#define SETFUNC(sys,lib,off,fn) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_l __asm("a1") = (lib);\
  register LONG __p_o __asm("a0") = (LONG)(off);\
  register APTR __p_f __asm("d0") = (fn);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-420:W)\n"\
    : "=d"(__p_res), "+a"(__p_l), "+a"(__p_o)\
    : "a"(__p_e), "d"(__p_f)\
    : "d1","cc","memory");\
  __p_res;})

#define SIGNAL(sys,t,m) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register struct Task * __p_t __asm("a1") = (t);\
  register ULONG __p_m __asm("d0") = (ULONG)(m);\
  __asm volatile ("jsr %/a6@(-324:W)\n"\
    : "+a"(__p_t), "+d"(__p_m) : "a"(__p_e)\
    : "d1","a0","cc","memory");})

#define FREEMEM(sys,p,n) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register APTR __p_p __asm("a1") = (p);\
  register ULONG __p_n __asm("d0") = (ULONG)(n);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_p), "+d"(__p_n) : "a"(__p_e)\
    : "d1","a0","cc","memory");})

#define ENQUEUE(sys,l,n) ({\
  register struct Library * __p_e __asm("a6") = (sys);\
  register struct List * __p_l __asm("a0") = (l);\
  register struct Node * __p_n __asm("a1") = (n);\
  __asm volatile ("jsr %/a6@(-270:W)\n"\
    : "+a"(__p_l), "+a"(__p_n) : "a"(__p_e)\
    : "d0","d1","cc","memory");})

#define DELAY(dos,t) ({\
  register struct Library * __p_e __asm("a6") = (dos);\
  register ULONG __p_t __asm("d1") = (ULONG)(t);\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "+d"(__p_t) : "a"(__p_e)\
    : "d0","a0","a1","cc","memory");})

#define NEWPROC(dos,tags) ({\
  register struct Library * __p_e __asm("a6") = (dos);\
  register ULONG * __p_t __asm("d1") = (tags);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-498:W)\n"\
    : "=d"(__p_res), "+d"(__p_t) : "a"(__p_e)\
    : "a0","a1","cc","memory");\
  __p_res;})

#define NP_ENTRY	0x800003eb
#define NP_NAME		0x800003f4

/* -------- list block init (original: subroutine @0xd4) ----------- */

/* lh_Head -> lh_Tail, lh_Tail = NULL, lh_TailPred -> lh_Head */
static void newlist(ULONG *l)
{
	l[2] = (ULONG)l;
	l[1] = 0;
	l[0] = (ULONG)&l[1];
}

static void blk_init(struct SNBlk *b, struct Library *e)
{
	newlist((ULONG *)&b->list);
	CALL_A0(e,-558,&b->sem);
	b->msg.mn_ReplyPort = &b->port;
	b->msg.mn_Length = 0x1c;
	newlist((ULONG *)&b->port.mp_MsgList);
	b->port.mp_Node.ln_Type = NT_MSGPORT;
}

/* -------- shared add/remove helpers ------------------------------ */

/* a0 = client port, a1 = list block, d0 = node priority -> d0 = node */
static struct SNNode *addnode(struct SNBase *b, APTR port,
			      struct MinList *l, ULONG pri)
{
	struct SNNode *n = NULL;
	struct SNBlk *blk = (struct SNBlk *)l;
	struct Library *e = b->exec;
	struct Library *g = b->gfx;
	int i;

	for (i = 9; ; i--) {
		if (CALL_A0R(e,-576,&blk->sem,0))
			break;
		if (!g)
			return NULL;
		CALL0(g,-270,0);
		if (i == 0)
			return NULL;
	}
	n = CALL_D0D1R(e,-198,18,1,0);
	if (n) {
		n->n.ln_Pri = pri;
		n->n.ln_Name = port;
		ENQUEUE(e, (struct List *)&blk->list, (struct Node *)n);
		CALL_A0(e,-570,&blk->sem);
	}
	return n;
}

/* a0 = node, a1 = list semaphore -> d0 = 1 removed / 0 busy */
static ULONG remnode(struct SNBase *b, struct SNNode *n,
		     struct SignalSemaphore *sem)
{
	struct Library *e = b->exec;
	struct Message *m;

	if (CALL_A0R(e,-576,sem,0)) {
		CALL_A1(e,-252,n);
		CALL_A0(e,-570,sem);
		FREEMEM(e, n, 18);
		return 1;
	}
	m = CALL_A0R(e,-372,n->n.ln_Name,0);
	if (m)
		CALL_A1(e,-378,m);
	return 0;
}

/* -------- public vectors ------------------------------------------ */

APTR LibOpen(struct SNBase *b __asm("a6"))
{
	b->lib.lib_OpenCnt++;
	return b;
}

APTR LibExpunge(struct SNBase *b __asm("a6"));

APTR LibClose(struct SNBase *b __asm("a6"))
{
	if (b->lib.lib_OpenCnt > 0 &&
	    --b->lib.lib_OpenCnt == 0 &&
	    (b->lib.lib_Flags & 8))
		return LibExpunge(b);
	return NULL;
}

APTR LibExpunge(struct SNBase *b __asm("a6"))
{
	struct Library *e, *i;
	APTR seg, prev;
	ULONG sz;

	if (b->lib.lib_OpenCnt > 0) {
		b->lib.lib_Flags |= 8;	/* LIBF_DELEXP */
		return NULL;
	}
	i = b->intu;
	e = b->exec;
	seg = NULL;

	/* try to unchain each patched vector; when another library
	** repatched after us, restore whatever was found instead.
	** all paths still remove and free the library below. */
	prev = SETFUNC(e, i, -0x228, b->oldpss);	/* PubScreenStatus */
	if (prev == (APTR)(b->tmpl + 218)) {	/* lib+688 */
		prev = SETFUNC(e, i, -0x4e, b->oldcwb);	/* CloseWorkBench */
		if (prev == (APTR)(b->tmpl + 366)) {	/* lib+836 */
			prev = SETFUNC(e, i, -0x42, b->oldcs); /* CloseScreen */
			if (prev == (APTR)(b->tmpl + 58)) {	/* lib+528 */
				prev = SETFUNC(e, i, -0x264, b->oldostl);
				if (prev == (APTR)b->tmpl) {	/* lib+470 */
					CALL_A1(e,-252,b);
					SIGNAL(e, b->workerport->mp_SigTask,
						1UL << b->workerport->mp_SigBit);
					CALL_A0(e,-672,b->replyport);
					CALL_A1(e,-414,b->dos);
					CALL_A1(e,-414,b->gfx);
					CALL_A1(e,-414,i);
					goto out;
				}
				SETFUNC(e, i, -0x264, prev);
				prev = b->oldcs;
			}
			SETFUNC(e, i, -0x42, prev);
			prev = b->oldcwb;
		}
		SETFUNC(e, i, -0x4e, prev);
		prev = b->oldpss;
	}
	SETFUNC(e, i, -0x228, prev);

out:
	seg = b->seglist;
	sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
	FREEMEM(e, (UBYTE *)b - b->lib.lib_NegSize, sz);
	return seg;
}

APTR LibNull(struct SNBase *b __asm("a6"))
{
	return NULL;
}

/* -30: add client to screen-close list (a0=arg a1=port d0=pri) */
APTR SNAdd1(ULONG pri __asm("d0"), APTR arg __asm("a0"),
	    APTR port __asm("a1"), struct SNBase *b __asm("a6"))
{
	struct SNNode *n = addnode(b, port, &b->blk1.list, pri);
	if (n)
		n->arg = arg;
	return n;
}

/* -36: remove client from screen-close list (a0=node) */
ULONG SNRem1(APTR node __asm("a0"), struct SNBase *b __asm("a6"))
{
	return remnode(b, node, &b->blk1.sem);
}

/* -42: add client to pub-status list */
APTR SNAdd2(ULONG pri __asm("d0"), APTR arg __asm("a0"),
	    APTR port __asm("a1"), struct SNBase *b __asm("a6"))
{
	struct SNNode *n = addnode(b, port, &b->blk2.list, pri);
	if (n)
		n->arg = arg;
	return n;
}

/* -48: remove client from pub-status list */
ULONG SNRem2(APTR node __asm("a0"), struct SNBase *b __asm("a6"))
{
	return remnode(b, node, &b->blk2.sem);
}

/* -54: add client to workbench list */
APTR SNAdd3(ULONG pri __asm("d0"), APTR arg __asm("a0"),
	    APTR port __asm("a1"), struct SNBase *b __asm("a6"))
{
	struct SNNode *n = addnode(b, port, &b->blk3.list, pri);
	if (n)
		n->arg = arg;
	return n;
}

/* -60: remove client from workbench list */
ULONG SNRem3(APTR node __asm("a0"), struct SNBase *b __asm("a6"))
{
	return remnode(b, node, &b->blk3.sem);
}

/* -------- init ---------------------------------------------------- */

APTR LibInit(struct SNBase *b __asm("d0"), APTR seg __asm("a0"),
	     struct Library *e __asm("a6"))
{
	APTR wcode, proc;
	struct Message *m;
	ULONG tags[5];

	b->exec = e;
	b->seglist = seg;
	if (e->lib_Version < 37)
		return NULL;
	b->intu = OPENLIB_E(e, sn_intu_name + 1, 37);
	if (!b->intu)
		return NULL;
	b->dos = OPENLIB_E(e, sn_dos_name, 37);
	if (!b->dos)
		goto fail_i;
	b->replyport = CALL0(e,-666,0);
	if (!b->replyport)
		goto fail_d;
	b->msg.mn_ReplyPort = b->replyport;
	wcode = CALL_D0D1R(e,-684,WORKER_IMG_SIZE,0,0);
	if (!wcode)
		goto fail_p;
	COPYMEM(e, sn_worker_img, wcode, WORKER_IMG_SIZE);
	tags[0] = NP_NAME;
	tags[1] = (ULONG)(wcode + 136);
	tags[2] = NP_ENTRY;
	tags[3] = (ULONG)wcode;
	tags[4] = 0;
	proc = NEWPROC(b->dos, tags);
	if (!proc) {
		CALL_A1(e,-690,wcode);
		goto fail_p;
	}
	/* handshake: send lib base, get worker port back */
	b->msg.mn_Length = 0x18;
	b->body = (ULONG)b;
	PUTMSG(e, (struct MsgPort *)((UBYTE *)proc + 92), &b->msg);
	CALL_A0(e,-384,b->replyport);
	m = CALL_A0R(e,-372,b->replyport,0);
	b->workerport = *(struct MsgPort **)((UBYTE *)m + 20);
	if (!b->workerport)
		goto fail_p;
	blk_init(&b->blk1, e);
	blk_init(&b->blk2, e);
	blk_init(&b->blk3, e);
	COPYMEM(e, sn_patch_img, b->tmpl, PATCH_IMG_SIZE);
	CALL0(e,-132,0);
	b->oldostl = SETFUNC(e, b->intu, -0x264, b->tmpl);	/* -612 */
	b->oldcs   = SETFUNC(e, b->intu, -0x42,  b->tmpl + 58);	/* -66  */
	b->oldcwb  = SETFUNC(e, b->intu, -0x4e,  b->tmpl + 366);	/* -78  */
	b->oldpss  = SETFUNC(e, b->intu, -0x228, b->tmpl + 218);	/* -552 */
	CALL0(e,-138,0);
	CALL0(e,-636,0);
	b->gfx = OPENLIB_E(e, sn_gfx_name + 1, 37);
	return b;

fail_p:
	CALL_A0(e,-672,b->replyport);
fail_d:
	CALL_A1(e,-414,b->dos);
fail_i:
	CALL_A1(e,-414,b->intu);
	return NULL;
}
