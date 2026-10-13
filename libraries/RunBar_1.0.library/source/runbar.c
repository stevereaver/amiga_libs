/*
**	runbar.c -- C reconstruction of RunBar.library 1.0 (24.11.96)
**
**	SAS/C-style handler-registration library: a lib-private table of
**	16 slots (15 usable -- see loop bound note below), each holding a
**	registration key, an anonymous reply MsgPort, two user fields and
**	a handler object pointer.  External clients post synchronous
**	requests ({0x80800000,arg} / teardown {0x80800001,0} 28-byte
**	messages) to the registered port and WaitPort/GetMsg the reply.
**
**	Register-parameter ABI: a6 = library base, args in d0/a0..a3.
**
**	Vectors:
**	  -30 RB_LockTable   flag=1, return &ent[0] (array base)
**	  -36 RB_Add         register (key,f8,fc,obj); 0 ok,2 full,
**	                     3 dup,4 null key,5 port-alloc fail
**	  -42 RB_Remove      drain+delete slot port (no-op while flag==1)
**	  -48 RB_Send        sync request msg {0x80800000,arg} to slot port
**	  -54 RB_Reset       clear 15 keys + magic + flag (ports leak)
**	  -60 RB_Teardown    notify all {0x80800001,0}, drain, delete
**	  -66 RB_Update      patch slot fields +8/+0xc by key
**	  -72 RB_Unlock      flag=0
**
**	Library: dataSize 0x194 = 34(struct Node)..47 Library + 356 priv.
**	priv = lib+48: 32-long copy of the DATA-hunk template (the shipped
**	template is only 36 bytes; the original reads 92 bytes past it --
**	this rebuild extends the file image with zeros), magic at +20,
**	lock flag at +24, slot array at +36.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/ports.h>
#include <exec/lists.h>
#include <exec/tasks.h>
#include <exec/memory.h>

#define RB_MAGIC	0xa3b5f9d1L
#define RB_NSLOTS	16	/* allocated */
#define RB_NUSED	15	/* iterated  (d7==15 exits before slot 15) */

struct RBEntry
{
	APTR	key;		/* +0x00  registration key		 */
	APTR	port;		/* +0x04  anonymous MsgPort		 */
	APTR	f8;		/* +0x08  user field			 */
	APTR	fc;		/* +0x0c  user field			 */
	APTR	obj;		/* +0x10  handler object			 */
};

struct RBObj			/* handler object layout the lib assumes */
{
	UWORD		o0;	/* +0					*/
	STRPTR		name;	/* +2  name string for dedup (packed,	*/
				/*      unaligned!)			*/
	ULONG		flag;	/* +6  1 -> dedup by name too		*/
} __attribute__((packed));

struct RBPriv			/* at lib+48; overlaid by the 128-byte
					   template copy from the DATA hunk */
{
	ULONG		g[5];	/* +0   DATA-hunk template copy		*/
	ULONG		magic;	/* +20  RB_MAGIC once initialised	*/
	ULONG		flag;	/* +24  set by -30, cleared by -72	*/
	ULONG		pad[2];	/* +28					*/
	struct RBEntry	ent[RB_NSLOTS]; /* +36				*/
};

struct RunBarBase		/* 0x194 bytes				  */
{
	UBYTE		LibNode[14];		/* +0			*/
	UBYTE		LibFlags;		/* +14			*/
	UBYTE		LibPad;			/* +15			*/
	UWORD		NegSize;		/* +16			*/
	UWORD		PosSize;		/* +18			*/
	UWORD		Version;		/* +20			*/
	UWORD		Revision;		/* +22			*/
	ULONG		IdString;		/* +24			*/
	ULONG		Sum;			/* +28			*/
	UWORD		OpenCnt;		/* +32			*/
	ULONG		SegList;		/* +34			*/
	UBYTE		pad[10];		/* +38..47		*/
	struct RBPriv	Priv;			/* +48 .. 0x193		*/
};

extern const UBYTE rbtempl[];	/* DATA hunk image (128 bytes) */
extern char verstr[];		/* "RunBar.library 1.0 (24.11.96)"   */
extern LONG rb_LibHook(void);	/* shipped stubs: moveq#0/rts + rts  */
extern void rb_LibHookDead(void);

/* ------------------------------------------------------------------ */
/* exec primitives -- moveal 4,a6 as in the original			  */
/* ------------------------------------------------------------------ */

#define SYSBASE()	(*(void **)4)

static APTR rb_AllocSignal(LONG sig)
{
	register ULONG d0 __asm("d0") = sig;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-330)"
			: "+r"(d0) : "r"(a6)
			: "memory");
	return (APTR)d0;
}

static void rb_FreeSignal(LONG sig)
{
	register ULONG d0 __asm("d0") = sig;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-336)"
			: "+r"(d0) : "r"(a6)
			: "memory");
}

static APTR rb_AllocMem(ULONG size, ULONG flags)
{
	register ULONG d0 __asm("d0") = size;
	register ULONG d1 __asm("d1") = flags;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-198)"
			: "+r"(d0) : "r"(d1), "r"(a6)
			: "memory");
	return (APTR)d0;
}

static void rb_FreeMem(APTR p, ULONG size)
{
	register APTR  a1 __asm("a1") = p;
	register ULONG d0 __asm("d0") = size;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-210)"
			: "+r"(d0) : "r"(a1), "r"(a6)
			: "memory");
}

static APTR rb_FindTask(APTR name)
{
	register APTR  a1 __asm("a1") = name;
	register ULONG d0 __asm("d0");
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-294)"
			: "=r"(d0) : "r"(a1), "r"(a6)
			: "memory");
	return (APTR)d0;
}

static void rb_AddPort(APTR port)
{
	register APTR  a1 __asm("a1") = port;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-354)"
			: : "r"(a1), "r"(a6)
			: "memory");
}

static void rb_RemPort(APTR port)
{
	register APTR  a1 __asm("a1") = port;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-360)"
			: : "r"(a1), "r"(a6)
			: "memory");
}

static void rb_PutMsg(APTR port, APTR msg)
{
	register APTR  a0 __asm("a0") = port;
	register APTR  a1 __asm("a1") = msg;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-366)"
			: : "r"(a0), "r"(a1), "r"(a6)
			: "memory");
}

static APTR rb_GetMsg(APTR port)
{
	register APTR  a0 __asm("a0") = port;
	register ULONG d0 __asm("d0");
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-372)"
			: "=r"(d0) : "r"(a0), "r"(a6)
			: "memory");
	return (APTR)d0;
}

static void rb_ReplyMsg(APTR msg)
{
	register APTR  a1 __asm("a1") = msg;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-378)"
			: : "r"(a1), "r"(a6)
			: "memory");
}

static void rb_WaitPort(APTR port)
{
	register APTR  a0 __asm("a0") = port;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-384)"
			: : "r"(a0), "r"(a6)
			: "memory");
}

static void rb_Forbid(void)
{
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-132)"
			: : "r"(a6) : "memory");
}

static void rb_Permit(void)
{
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-138)"
			: : "r"(a6) : "memory");
}

static void rb_Remove(APTR node)
{
	register APTR  a1 __asm("a1") = node;
	register void *a6 __asm("a6") = SYSBASE();
	__asm volatile ("jsr a6@(-252)"
			: : "r"(a1), "r"(a6)
			: "memory");
}

/* ------------------------------------------------------------------ */
/* CreateMsgPort / DeleteMsgPort clones (amiga.lib equivalents)	  */
/* ------------------------------------------------------------------ */

/* the original's inline NewList on &port->mp_MsgList		   */
static void rb_NewList(struct List *l)
{
	l->lh_Tail     = 0;
	l->lh_TailPred = (struct Node *)l;
	l->lh_Head     = (struct Node *)&l->lh_Tail;
}

static struct MsgPort *rb_CreatePort(STRPTR name, LONG pri)
{
	LONG sig;
	struct MsgPort *mp;

	sig = (LONG)rb_AllocSignal(-1);
	if (sig <= 0)
		return 0;
	mp = (struct MsgPort *)rb_AllocMem(sizeof(struct MsgPort), MEMF_PUBLIC|MEMF_CLEAR);
	if (!mp) {
		rb_FreeSignal(sig);
		return 0;
	}
	mp->mp_Node.ln_Name = (char *)name;
	mp->mp_Node.ln_Pri  = (UBYTE)pri;
	mp->mp_Node.ln_Type = NT_MSGPORT;
	mp->mp_Flags  = 0;
	mp->mp_SigBit = (UBYTE)sig;
	mp->mp_SigTask = rb_FindTask(0);
	if (name)
		rb_AddPort(mp);
	else
		rb_NewList(&mp->mp_MsgList);
	return mp;
}

static void rb_DeletePort(struct MsgPort *mp)
{
	if (mp->mp_Node.ln_Name)
		rb_RemPort(mp);
	mp->mp_Node.ln_Type = 0xff;
	mp->mp_MsgList.lh_Head = (struct Node *)-1;
	rb_FreeSignal((LONG)mp->mp_SigBit);
	rb_FreeMem(mp, sizeof(struct MsgPort));
}

/* the synchronous 28-byte request message the lib posts:		*/
/* mn_ReplyPort = reply port, mn_Length = 28, body = {cmd, arg}		*/
struct RBMsg
{
	struct Message	m;
	ULONG		cmd;
	ULONG		arg;
};

/* ------------------------------------------------------------------ */
/* LibInit -- d0 = base, a0 = seglist, a6 = SysBase			  */
/* ------------------------------------------------------------------ */

struct RunBarBase *LibInit(register struct RunBarBase *base __asm("d0"),
			   register APTR seglist __asm("a0"),
			   register void *sysbase __asm("a6"))
{
	struct RBPriv *p = &base->Priv;
	const ULONG *fix;
	LONG n, i;

	base->SegList = (ULONG)seglist;
	base->LibNode[8] = NT_LIBRARY;
	*(ULONG *)&base->LibNode[10] = (ULONG)"RunBar.library";
	base->LibFlags  = 6;
	base->Version   = 1;
	base->Revision  = 0;
	base->IdString  = (ULONG)"RunBar.library 1.0";

	/* template copy: 32 longs from the DATA hunk into priv	   */
	for (i = 0; i < 128; i++)
		((UBYTE *)p)[i] = rbtempl[i];

	/* base-relative fixups; shipped count (templ[8]) is 0	   */
	n = *(const ULONG *)&rbtempl[32];
	fix = (const ULONG *)&rbtempl[36];
	for (i = 0; i < n; i++)
		*(ULONG *)((UBYTE *)p + fix[i]) += (ULONG)p;

	if (rb_LibHook())		/* shipped stub: always 0	   */
		return 0;
	return base;
}

/* ------------------------------------------------------------------ */
/* lifecycle								  */
/* ------------------------------------------------------------------ */

struct RunBarBase *LibOpen(register struct RunBarBase *b __asm("a6"))
{
	b->OpenCnt++;
	b->LibFlags &= ~8;
	return b;
}

ULONG LibExpunge(register struct RunBarBase *b __asm("a6"));

ULONG LibClose(register struct RunBarBase *b __asm("a6"))
{
	if (--b->OpenCnt == 0 && (b->LibFlags & 8))
		return LibExpunge(b);	/* bsr into the -18 vector body */
	return 0;
}

ULONG LibExpunge(register struct RunBarBase *b __asm("a6"))
{
	ULONG seg;
	b->LibFlags |= 8;
	if (b->OpenCnt)
		return 0;
	rb_LibHookDead();		/* shipped dead hook (bare rts)   */
	seg = b->SegList;
	rb_Remove(b);
	rb_FreeMem((UBYTE *)b - b->NegSize, b->NegSize + b->PosSize);
	return seg;
}

/* ------------------------------------------------------------------ */
/* -30: lock the table and hand out the slot array base		  */
/* ------------------------------------------------------------------ */

struct RBEntry *RB_LockTable(register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	p->flag = 1;
	return p->ent;
}

/* ------------------------------------------------------------------ */
/* -36: register.  a0=key, a1=fc, a2=f8, a3=obj			  */
/* ------------------------------------------------------------------ */

LONG RB_Add(register APTR key __asm("a0"), register APTR fc __asm("a1"),
	    register APTR f8 __asm("a2"), register struct RBObj *obj __asm("a3"),
	    register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	struct RBEntry *e;
	APTR port;
	int i;

	if (p->magic != RB_MAGIC) {
		for (i = 0; i < RB_NUSED; i++)
			p->ent[i].key = 0;
		p->magic = RB_MAGIC;
		p->flag  = 0;
	}
	if (!key)
		return 4;
	for (i = 0; i < RB_NUSED; i++) {
		struct RBEntry *e = &p->ent[i];
		if (e->key == key)
			return 3;
		if (e->key && obj->flag == 1) {
			const UBYTE *s1 = (const UBYTE *)obj->name;
			const UBYTE *s2 = (const UBYTE *)((struct RBObj *)e->obj)->name;
			while (*s1 == *s2) {
				if (!*s1)
					return 3;
				s1++; s2++;
			}
		}
	}
	for (i = 0; i < RB_NUSED; i++)
		if (!p->ent[i].key)
			break;
	if (i == RB_NUSED)
		return 2;
	port = (APTR)rb_CreatePort(0, 0);
	e = &p->ent[i];
	e->port = port;
	if (!port)
		return 5;
	e->f8  = f8;
	e->fc  = fc;
	e->key = key;
	e->obj = obj;
	return 0;
}

/* ------------------------------------------------------------------ */
/* -42: unregister a key.  a0 = key					  */
/* ------------------------------------------------------------------ */

LONG RB_Remove(register APTR key __asm("a0"),
	       register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	APTR m;
	int i;

	if (p->flag == 1)
		return 1;	/* quirk: stale moveq#1 residue, not 0 */
	for (i = 0; i < RB_NUSED && p->ent[i].key != key; i++)
		;
	if (i == RB_NUSED)
		return 0;
	p->ent[i].key = 0;
	while ((m = rb_GetMsg(p->ent[i].port)))
		rb_ReplyMsg(m);
	rb_DeletePort(p->ent[i].port);
	return 0;
}

/* ------------------------------------------------------------------ */
/* -48: synchronous request.  d0 = arg, a0 = key			  */
/* ------------------------------------------------------------------ */

LONG RB_Send(register ULONG arg __asm("d0"), register APTR key __asm("a0"),
	     register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	struct MsgPort *rp;
	struct RBMsg *msg;
	APTR reply; /* dead store, as shipped */
	int i;

	for (i = 0; i < RB_NUSED && p->ent[i].key != key; i++)
		;
	if (i == RB_NUSED)
		return 0;
	rp = rb_CreatePort(0, 0);
	if (!rp)
		return 0;
	msg = (struct RBMsg *)rb_AllocMem(sizeof(struct RBMsg), MEMF_PUBLIC|MEMF_CLEAR);
	if (msg) {
		msg->m.mn_Node.ln_Type = NT_REPLYMSG;	/* 5 */
		msg->m.mn_Length = sizeof(struct RBMsg);
		msg->m.mn_ReplyPort = rp;
		msg->cmd = 0x80800000;
		msg->arg = arg;
		rb_Forbid();
		rb_PutMsg(p->ent[i].port, msg);
		rb_Permit();
		rb_WaitPort(rp);
		reply = rb_GetMsg(rp);	/* kept in a dead local, as shipped */
		rb_FreeMem(msg, sizeof(struct RBMsg));
	}
	rb_DeletePort(rp);
	return 0;
}

/* ------------------------------------------------------------------ */
/* -54: clear all keys + magic + flag (slot ports leak, as shipped)	  */
/* ------------------------------------------------------------------ */

LONG RB_Reset(register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	int i;

	for (i = 0; i < RB_NUSED; i++)
		p->ent[i].key = 0;
	p->magic = RB_MAGIC;
	p->flag  = 0;
	return 0;
}

/* ------------------------------------------------------------------ */
/* -60: teardown: shutdown-notify + drain + delete for every used slot  */
/* ------------------------------------------------------------------ */

LONG RB_Teardown(register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	int i;

	for (i = 0; i < RB_NUSED; i++) {
		struct RBEntry *e = &p->ent[i];
		struct MsgPort *rp;
		struct RBMsg *msg;
		APTR m, reply;

		if (!e->key)
			continue;
		e->key = 0;
		rp = rb_CreatePort(0, 0);
		if (rp) {
			msg = (struct RBMsg *)rb_AllocMem(sizeof(struct RBMsg),
							  MEMF_PUBLIC|MEMF_CLEAR);
			if (msg) {
				msg->m.mn_Node.ln_Type = NT_REPLYMSG;
				msg->m.mn_Length = sizeof(struct RBMsg);
				msg->m.mn_ReplyPort = rp;
				msg->cmd = 0x80800001;
				msg->arg = 0;
				rb_Forbid();
				rb_PutMsg(e->port, msg);
				rb_Permit();
				rb_WaitPort(rp);
				reply = rb_GetMsg(rp);
				rb_FreeMem(msg, sizeof(struct RBMsg));
			}
			rb_DeletePort(rp);
		}
		while ((m = rb_GetMsg(e->port)))
			rb_ReplyMsg(m);
		rb_DeletePort(e->port);
	}
	p->magic = 0;
	return 0;
}

/* ------------------------------------------------------------------ */
/* -66: patch slot fields.  a0=key, a1->fc(if!=0), a2->f8(if!=0)	  */
/* ------------------------------------------------------------------ */

LONG RB_Update(register APTR key __asm("a0"), register APTR fc __asm("a1"),
	       register APTR f8 __asm("a2"),
	       register struct RunBarBase *b __asm("a6"))
{
	struct RBPriv *p = &b->Priv;
	int i;

	for (i = 0; i < RB_NUSED && p->ent[i].key != key; i++)
		;
	if (i == RB_NUSED)
		return 0;
	if (f8)
		p->ent[i].f8 = f8;
	if (fc)
		p->ent[i].fc = fc;
	return 0;
}

/* ------------------------------------------------------------------ */
/* -72: clear the lock flag						  */
/* ------------------------------------------------------------------ */

LONG RB_Unlock(register struct RunBarBase *b __asm("a6"))
{
	b->Priv.flag = 0;
	return 0;
}
