/*
**	lowmem.c -- asdg-low-mem.library (10-Jun-87)
**
**	C reconstruction of the shipped binary (900 bytes, sha256
**	d9b6df26368c8960bcc6f11a2f8e0d276a625a1708a4df4266626b2d062e5c52).
**
**	ASDG low memory alert server by Perry S. Kivolowitz.
**	Processes register a port name plus a LowMemMsg with the
**	library; when the low-memory alert fires (the Expunge vector
**	is the trigger entry point - it never actually expunges),
**	each client's message is examined and PutMsg()ed back to the
**	client's port so no client reply is ever needed.
**
**	Public API (from the LowMem.lha documentation):
**	  LVO -30  RegLowMemReq(portName, lowMemMsg) -> 0/-1/-2
**	  LVO -36  DeRegLowMemReq(portName)
**	  LVO -42  unnamed query, always returns 1
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/ports.h>
#include <dos/dos.h>
#include <inline/exec.h>

/*
 * Client registration node (20 bytes, private allocation).
 */
struct RegNode
{
    struct Node     rn_Node;      /* ln_Name = strdup'd port name  */
    struct Message *rn_Msg;       /* client's LowMemMsg            */
    UWORD           rn_NameLen;   /* allocation size of ln_Name    */
};

/*
 * struct LowMemMsg as shipped in low-mem.h:
 *   struct Message lm_msg;   (20 bytes)
 *   long lm_flag;            ('ASDG' = LM_CONDITION_ACKNOWLEDGED)
 */
#define LM_CONDITION_ACKNOWLEDGED  0x41534447   /* 'ASDG' */
#define LM_LOW_MEMORY_CONDITION    0x00000000
#define LM_BADNAME                 -1
#define LM_NOMEM                   -2

/*
 * Private library base, InitTable dataSize = 0x3c (60).
 * The original keeps its own open count at base+0x38 and resets
 * exec's lib_OpenCnt on every Open().
 */
struct LowMemBase
{
    struct Library   lb_Lib;      /* 0x00 */
    struct ExecBase *lb_SysBase;  /* 0x22 */
    BPTR             lb_SegList;  /* 0x26 */
    struct MinList   lb_List;     /* 0x2a: head/tail/tailpred */
    UWORD            lb_Pad;      /* 0x36 */
    UWORD            lb_OpenCnt;  /* 0x38: private open count  */
    UWORD            lb_Pad2;     /* 0x3a */
};

/*
 * LibInit -- called by MakeLibrary with d0 = base, a0 = seglist,
 * a6 = SysBase.  Stores both pointers and news the client list.
 * d0 (the base) is returned unchanged.
 */
struct Library *LibInit(struct LowMemBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6");

    base->lb_SysBase = sysbase;
    base->lb_SegList = seglist;

    base->lb_List.mlh_Head     = (struct MinNode *)&base->lb_List.mlh_Tail;
    base->lb_List.mlh_Tail     = NULL;
    base->lb_List.mlh_TailPred = (struct MinNode *)&base->lb_List.mlh_Head;

    return (struct Library *)base;
}

/*
 * LibOpen (LVO -6): bump the private open count and clear exec's
 * lib_OpenCnt (the original deliberately keeps the public count at
 * zero so expunge-by-opencount never interferes).
 */
struct Library *LibOpen(struct LowMemBase *base __asm("a6"))
{
    base->lb_OpenCnt++;
    base->lb_Lib.lib_OpenCnt = 0;
    return (struct Library *)base;
}

/* Free a registration node: its name string, then the 20-byte node. */
static void FreeRegNode(struct LowMemBase *base, struct RegNode *n)
{
    __FreeMem_base(base->lb_SysBase, n->rn_Node.ln_Name, n->rn_NameLen);
    __FreeMem_base(base->lb_SysBase, n, 20);
}

/* RemHead + free every registered client node. */
static void FreeAllClients(struct LowMemBase *base)
{
    struct RegNode *n;

    while ((n = (struct RegNode *)
            __RemHead_base(base->lb_SysBase, (struct List *)&base->lb_List)))
        FreeRegNode(base, n);
}

/*
 * LibClose (LVO -12): decrement the private count; at zero the
 * library removes itself from the exec library list, frees all
 * client nodes and its own memory, and returns the seglist.
 */
BPTR LibClose(struct LowMemBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    BPTR             seg;
    UBYTE           *block;
    ULONG            size;

    if (--base->lb_OpenCnt != 0)
        return 0;

    seg = base->lb_SegList;
    __Remove_base(sys, (struct Node *)base);
    FreeAllClients(base);

    block = (UBYTE *)base - base->lb_Lib.lib_NegSize;
    size  = (ULONG)base->lb_Lib.lib_NegSize + base->lb_Lib.lib_PosSize;
    __FreeMem_base(sys, block, size);

    return seg;
}

/*
 * LibExpunge (LVO -18): the alert trigger.  For every registered
 * client whose LowMemMsg is still marked LM_CONDITION_ACKNOWLEDGED
 * ('ASDG'), the flag is cleared to LM_LOW_MEMORY_CONDITION and the
 * message is re-initialized and PutMsg()ed to the client's port.
 * Always returns 0: the library itself is never expunged here;
 * Close-at-zero performs the real teardown.
 */
LONG LibExpunge(struct LowMemBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    struct RegNode  *n;

    for (n = (struct RegNode *)base->lb_List.mlh_Head; n;
         n = (struct RegNode *)n->rn_Node.ln_Succ) {

        struct MsgPort *port =
            __FindPort_base(sys, n->rn_Node.ln_Name);
        if (port) {
            struct Message *msg = n->rn_Msg;
            if (*(ULONG *)((UBYTE *)msg + 20) == LM_CONDITION_ACKNOWLEDGED) {
                *(ULONG *)((UBYTE *)msg + 20) = LM_LOW_MEMORY_CONDITION;
                msg->mn_Node.ln_Type = NT_MESSAGE;
                msg->mn_ReplyPort    = NULL;
                msg->mn_Node.ln_Pri  = 0;
                msg->mn_Length       = 4;
                __PutMsg_base(sys, port, msg);
            }
        }
    }
    return 0;
}

/*
 * RegLowMemReq (LVO -30): register a port name + LowMemMsg.
 * Returns 0, LM_BADNAME (-1) if the port name is already
 * registered, or LM_NOMEM (-2) on allocation failure.
 */
LONG RegLowMemReq(STRPTR portname __asm("a0"),
                  struct Message *msg __asm("a1"),
                  struct LowMemBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    struct RegNode  *n;
    STRPTR           copy;
    ULONG            len;
    STRPTR           s;
    UBYTE           *d;

    if (__FindName_base(sys, (struct List *)&base->lb_List, portname))
        return LM_BADNAME;

    /* strlen + NUL */
    len = 1;
    for (s = portname; *s++; )
        len++;

    copy = __AllocMem_base(sys, len, 0);
    if (!copy)
        return LM_NOMEM;

    d = (UBYTE *)copy;
    while ((*d++ = *portname++))
        ;

    n = __AllocMem_base(sys, 20, 0);
    if (!n) {
        __FreeMem_base(sys, copy, len);
        return LM_NOMEM;
    }

    n->rn_Node.ln_Name = (char *)copy;
    n->rn_Msg          = msg;
    n->rn_NameLen      = (UWORD)len;
    n->rn_Node.ln_Type = 0;
    n->rn_Node.ln_Pri  = 0;
    __AddHead_base(sys, (struct List *)&base->lb_List,
                   (struct Node *)n);
    return 0;
}

/*
 * DeRegLowMemReq (LVO -36): remove a registration by port name and
 * free it.  Always returns 0.
 */
LONG DeRegLowMemReq(STRPTR portname __asm("a0"),
                    struct LowMemBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    struct RegNode  *n;

    n = (struct RegNode *)
        __FindName_base(sys, (struct List *)&base->lb_List, portname);
    if (n) {
        __Remove_base(sys, (struct Node *)n);
        FreeRegNode(base, n);
    }
    return 0;
}

/*
 * LVO -42: undocumented query function, always returns 1
 * (presence/version probe).
 */
LONG LMSQuery(void)
{
    return 1;
}
