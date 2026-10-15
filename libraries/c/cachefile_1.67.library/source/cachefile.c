/*
 * cachefile.c -- cachefile.library 1.67 (25.8.94)
 *
 * Disk-file cache: CacheFile_Load reads a whole file into a named node,
 * arms a dos StartNotify on it, and the embedded "CacheFile_Notify"
 * daemon (cachefile_lib.s) reloads the node whenever the file changes.
 *
 * Vectors:
 *   -30  CacheFile_Find(a1=name)            -> node / 0
 *   -36  CacheFile_Load(d0=fh, a1=name)     -> node / 0
 *   -42  CacheFile_Free(a1=node)
 *   -48  CacheFile_FreeAll()                (deadlocks, see below)
 *   -54  CacheFile_GetList()                -> &base->list
 *   -60  CacheFile_Data(a1=node)            -> data buffer
 *   -66  CacheFile_Size(a1=node)            -> filesize
 *
 * Node: Node + embedded NotifyRequest + 256B path buf + filesize +
 * data ptr + name string; data is the whole file, NUL padded.
 *
 * Shipped quirk: CacheFile_FreeAll obtains the semaphore, then calls
 * CacheFile_Free which obtains it AGAIN -> guaranteed deadlock on a
 * non-empty list (exec semaphores are not recursive).  Verbatim.
 */

typedef long           LONG;
typedef unsigned long  ULONG;
typedef unsigned short UWORD;
typedef unsigned char  UBYTE;
typedef char          *STRPTR;
typedef void          *APTR;
typedef ULONG          BPTR;

struct Node {
	struct Node *succ, *pred;	/* +0,+4 */
	UBYTE		type;		/* +8   */
	UBYTE		pri;		/* +9   */
	STRPTR		name;		/* +10  */
};
struct List { struct Node *head, *tail, *tailpred; };

/* cache node -- 588 bytes fixed + name + data (single AllocVec) */
struct CFNode {
	struct Node	n;		/* +0   ln_Name -> name buf */
	/* embedded NotifyRequest @ +14 .. +57 */
	STRPTR		nr_Name;	/* +14  -> path buf at +318 */
	STRPTR		nr_FullName;	/* +18  = 0 */
	struct CFNode  *nr_UserData;	/* +22  = node itself */
	ULONG		nr_Flags;	/* +26  = 9 */
	APTR		nr_Port;	/* +30  -> daemon MsgPort */
	ULONG		nr_pad[6];	/* +34  NotifyRequest rest */
	UBYTE		pad58[260];	/* +58 .. +317 */
	char		path[256];	/* +318 NameFromFH buffer */
	ULONG		filesize;	/* +576 */
	UBYTE	       *data;		/* +580 -> file contents */
	char		namebuf[4];	/* +584 name string, data after */
};

struct CFileBase {
	UBYTE		lib[36];	/* Library node + header */
	APTR		sysbase;	/* +36  */
	APTR		dosbase;	/* +40  */
	BPTR		seglist;	/* +44  */
	UBYTE		sem[46];	/* +48  SignalSemaphore */
	struct List	list;		/* +94  */
	ULONG		count;		/* +106 node count */
	APTR		nport;		/* +110 daemon port */
	UBYTE		pad114[4];	/* +114 .. +117 (size 0x76) */
};

/* semaphore helpers in cachefile_lib.s -- take the base in a5 */
#define SEMCALL(fn) do {\
  register struct CFileBase *_b5 __asm("a5") = b;\
  __asm volatile("jsr " #fn "\n"\
    : : "a"(_b5)\
    : "d0","d1","a0","a1","a6","fp0","fp1","cc","memory");\
  } while (0)
#define sem_obtain()	SEMCALL(_sem_obtain)
#define sem_release()	SEMCALL(_sem_release)
#define sem_locksh()	SEMCALL(_sem_locksh)
#define sem_unlocksh()	SEMCALL(_sem_unlocksh)

/* ---- exec/dos LVO helpers (epu1 convention) ------------------------ */

#define REMOVE(n) ({\
  register APTR __p_sys __asm("a6") = b->sysbase;\
  register APTR __p_n __asm("a1") = (APTR)(n);\
  __asm volatile("jsr a6@(-252)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory"); })

#define ALLOCVEC(sz,fl) ({\
  register APTR __p_sys __asm("a6") = b->sysbase;\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  register ULONG __p_f __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile("jsr a6@(-684)\n"\
    : "=r"(__p_res), "+d"(__p_f)\
    : "a"(__p_sys), "d"(__p_s)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res; })

#define FREEVEC(p) ({\
  register APTR __p_sys __asm("a6") = b->sysbase;\
  register APTR __p_p __asm("a1") = (APTR)(p);\
  __asm volatile("jsr a6@(-690)\n"\
    : "+a"(__p_p)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory"); })

#define DOSOP(lvo, r1, r2, r3) ({\
  register APTR __p_db __asm("a6") = b->dosbase;\
  register ULONG __p_1 __asm("d1") = (ULONG)(r1);\
  register ULONG __p_2 __asm("d2") = (ULONG)(r2);\
  register ULONG __p_3 __asm("d3") = (ULONG)(r3);\
  register ULONG __p_res __asm("d0");\
  __asm volatile("jsr a6@(" #lvo ")\n"\
    : "=r"(__p_res), "+d"(__p_1), "+d"(__p_2), "+d"(__p_3)\
    : "a"(__p_db)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res; })

#define SEEK(f,o,m)        DOSOP(-66,  f, o, m)	/* Seek  */
#define DOSREAD(f,bp,n)    DOSOP(-42,  f, bp,n)	/* Read  */
#define DOSCLOSE(f)        DOSOP(-36,  f, 0, 0)	/* Close */
#define NAMEFROMFH(f,bp,l) DOSOP(-408, f, bp,l)	/* NameFromFH */
#define STARTNOTIFY(nr)    DOSOP(-888, nr,0, 0)	/* StartNotify */
#define ENDNOTIFY(nr)      DOSOP(-894, nr,0, 0)	/* EndNotify */

/* locale-less case fold: 'a'-'z' and 0xe0-0xf6,0xf8-0xfe -> &0xdf */
static UBYTE fold(UBYTE c)
{
	if (c < 'a')		return c;
	if (c < 123)		goto f;
	if (c < 0xe0)		return c;
	if (c == 0xf7)		return c;	/* division sign */
	if (c >= 0xff)		return c;
f:	return c & 0xdf;
}

/* -30: find node by name (case-insensitive), shared-locked walk */
APTR cf_find(STRPTR name __asm("a1"), struct CFileBase *base __asm("a6"))
{
	register struct CFileBase *b __asm("a5") = base;
	struct Node *n;
	UBYTE *a, *p;

	sem_locksh();
	for (n = b->list.head; n->succ; n = n->succ) {
		a = (UBYTE *)((struct CFNode *)n)->n.name;
		p = (UBYTE *)name;
		for (;;) {
			UBYTE d1 = fold(*a++);
			UBYTE d0 = fold(*p++);
			if (d1 != d0)
				goto next;
			if (!d0)
				break;
		}
		sem_unlocksh();
		return n;
next:;
	}
	sem_unlocksh();
	return 0;
}

/* -36: read fh into a new named node, arm notify, AddTail to list */
APTR cf_load(BPTR fh __asm("d0"), STRPTR name __asm("a1"),
	     struct CFileBase *base __asm("a6"))
{
	register struct CFileBase *b __asm("a5") = base;
	struct CFNode *nd;
	UBYTE *dst;
	char *p;
	ULONG fsize, namelen;

	sem_obtain();
	p = name; while (*p++) ;		/* namelen = strlen+1 */
	namelen = (ULONG)p - (ULONG)name;
	SEEK(fh, 0, 1);				/* OFFSET_END */
	fsize = SEEK(fh, 0, -1);		/* OFFSET_BEGIN -> size */
	nd = ALLOCVEC(fsize + 1 + namelen + 588, 0x10001);
	if (!nd)
		goto fail;
	p = name; dst = (UBYTE *)nd->namebuf;
	while ((*dst++ = *p++)) ;
	dst = (UBYTE *)(((ULONG)dst + 1) & ~1UL);
	nd->data = dst;
	nd->filesize = fsize;
	{ LONG rd = (LONG)DOSREAD(fh, dst, fsize);
	  if (rd < 0) {
		DOSCLOSE(fh);
		FREEVEC(nd);
		goto fail;
	  }
	  dst[rd] = 0;				/* NUL pad at read len */
	}
	nd->n.name = nd->namebuf;
	nd->nr_UserData = nd;
	nd->nr_Flags = 9;
	nd->nr_Port = b->nport;
	nd->nr_Name = nd->path;
	NAMEFROMFH(fh, nd->path, 256);
	if (!STARTNOTIFY(&nd->nr_Name))
		nd->nr_Name = 0;
	nd->n.succ = b->list.tail;
	nd->n.pred = b->list.tailpred;
	b->list.tailpred->succ = &nd->n;
	b->list.tailpred = &nd->n;
	b->count++;
	sem_release();
	return nd;
fail:	sem_release();
	return 0;
}

/* -42: free one node (EndNotify if armed, Remove, FreeVec, count--) */
void cf_free(struct CFNode *nd __asm("a1"), struct CFileBase *base __asm("a6"))
{
	register struct CFileBase *b __asm("a5") = base;

	sem_obtain();
	if (nd->nr_Name)
		ENDNOTIFY(&nd->nr_Name);
	REMOVE(&nd->n);
	FREEVEC(nd);
	sem_release();
	base->count--;
}

/* -48: free all nodes -- deadlocks (nested sem obtain), verbatim */
void cf_freeall(struct CFileBase *base __asm("a6"))
{
	register struct CFileBase *b __asm("a5") = base;
	struct Node *n, *nx;

	sem_obtain();
	for (n = b->list.head; n->succ; n = nx) {
		nx = n->succ;
		cf_free((struct CFNode *)n, base);
	}
	sem_release();
}

/* expunge helper (dead code, 0x574): free all nodes, no lock */
void cf_freenodes(struct CFileBase *base __asm("a6"))
{
	register struct CFileBase *b __asm("a5") = base;
	struct Node *n, *nx;

	for (n = b->list.head; n->succ; n = nx) {
		nx = n->succ;
		if (((struct CFNode *)n)->nr_Name)
			ENDNOTIFY(&((struct CFNode *)n)->nr_Name);
		REMOVE(n);
		FREEVEC(n);
	}
}

/* -54: return &base->list */
APTR cf_getlist(struct CFileBase *base __asm("a6"))
{
	return &base->list;
}

/* -60: return node->data */
APTR cf_data(struct CFNode *nd __asm("a1"))
{
	return nd->data;
}

/* -66: return node->filesize */
ULONG cf_size(struct CFNode *nd __asm("a1"))
{
	return nd->filesize;
}
