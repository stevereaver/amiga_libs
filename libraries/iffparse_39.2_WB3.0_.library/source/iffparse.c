/*
**	iffparse.c -- iffparse.library 40.1 (Workbench 3.1)
**
**	C reconstruction of the shipped binary
**	"iffparse_40.1(WB3.1).library" ($VER: iffparse 40.1 (9.2.93)).
**
**	Every library vector offset (LVO -6 .. -270) is implemented.
**	All shared state lives in the library base (address held in the
**	file-scope IFFBase pointer, set once by LibInit -- equivalent to
**	the original's a6=base convention for a single-instance library).
*/

#include <exec/execbase.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/alerts.h>
#include <exec/ports.h>
#include <devices/clipboard.h>
#include <libraries/iffparse.h>
#include <libraries/dos.h>
#include <utility/hooks.h>
#include <string.h>

#include "iffbase.h"

/* library bases live in the iffparse base, not in globals */
#define EXEC_BASE_NAME    (IFFBase->ib_SysBase)
#define DOS_BASE_NAME     (IFFBase->ib_DOSBase)
#define UTILITY_BASE_NAME (IFFBase->ib_UtilityBase)

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#define REGARGS

/* internal LCI identifiers (as found in the binary) */
#define LCI_ENTRY   ID_FORM /* 'enhd' constants below are the real ids */
/* ident words used by the binary */
#define IDENT_ENTRY ((ULONG)0x656e6864) /* 'enhd' */
#define IDENT_EXIT  ((ULONG)0x65786864) /* 'exhd' */
#define IDENT_PROP  ((ULONG)0x70726f70) /* 'prop' */
#define IDENT_COLL  ((ULONG)0x636f6c6c) /* 'coll' */

/* built-in entry points (h_Entry): hook a0, cmd a1, object a2 */
typedef ULONG (*HookEntry)(struct Hook *hook __asm("a0"),
                           APTR msg __asm("a1"), APTR object __asm("a2"));

/* forward decls of everything exported */
struct IFFHandle *AllocIFF(void);
LONG OpenIFF(struct IFFHandle *iff __asm("a0"), LONG mode __asm("d0"));
LONG ParseIFF(struct IFFHandle *iff __asm("a0"), LONG mode __asm("d0"));
void CloseIFF(struct IFFHandle *iff __asm("a0"));
void FreeIFF(struct IFFHandle *iff __asm("a0"));
LONG ReadChunkBytes(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG n __asm("d0"));
LONG WriteChunkBytes(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG n __asm("d0"));
LONG ReadChunkRecords(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG sz __asm("d0"), LONG n __asm("d1"));
LONG WriteChunkRecords(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG sz __asm("d0"), LONG n __asm("d1"));
LONG PushChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"), LONG size __asm("d2"));
LONG PopChunk(struct IFFHandle *iff __asm("a0"));
LONG EntryHandler(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"),
                  LONG pos __asm("d2"), struct Hook *h __asm("a1"), APTR obj __asm("a2"));
LONG ExitHandler(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"),
                 LONG pos __asm("d2"), struct Hook *h __asm("a1"), APTR obj __asm("a2"));
LONG PropChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
LONG PropChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"));
LONG StopChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
LONG StopChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"));
LONG CollectionChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
LONG CollectionChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"));
LONG StopOnExit(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
struct StoredProperty *FindProp(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
struct CollectionItem *FindCollection(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));
struct ContextNode *FindPropContext(struct IFFHandle *iff __asm("a0"));
struct ContextNode *CurrentChunk(struct IFFHandle *iff __asm("a0"));
struct ContextNode *ParentChunk(struct ContextNode *cn __asm("a0"));
struct LocalContextItem *AllocLocalItem(LONG type __asm("d0"), LONG id __asm("d1"), LONG ident __asm("d2"), LONG size __asm("d3"));
APTR LocalItemData(struct LocalContextItem *lci __asm("a0"));
void SetLocalItemPurge(struct LocalContextItem *lci __asm("a0"), struct Hook *hook __asm("a1"));
void FreeLocalItem(struct LocalContextItem *lci __asm("a0"));
struct LocalContextItem *FindLocalItem(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"), LONG ident __asm("d2"));
LONG StoreLocalItem(struct IFFHandle *iff __asm("a0"), struct LocalContextItem *lci __asm("a1"), LONG pos __asm("d0"));
void StoreItemInContext(struct IFFHandle *iff __asm("a0"), struct LocalContextItem *lci __asm("a1"), struct ContextNode *cn __asm("a2"));
void InitIFF(struct IFFHandle *iff __asm("a0"), LONG flags __asm("d0"), struct Hook *hook __asm("a1"));
void InitIFFasDOS(struct IFFHandle *iff __asm("a0"));
void InitIFFasClip(struct IFFHandle *iff __asm("a0"));
struct ClipboardHandle *OpenClipboard(LONG unit __asm("d0"));
void CloseClipboard(struct ClipboardHandle *cbh __asm("a0"));
LONG GoodID(LONG id __asm("d0"));
LONG GoodType(LONG type __asm("d0"));
STRPTR IDtoStr(LONG id __asm("d0"), STRPTR buf __asm("a0"));

/* =================================================================
 * built-in hooks (live in the .data hunk in the original binary)
 * ================================================================= */

static ULONG PropHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), struct IFFHandle *iff __asm("a2"));
static ULONG CollHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), struct IFFHandle *iff __asm("a2"));
static ULONG StopHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), APTR obj __asm("a2"));
static ULONG ExitStopHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), APTR obj __asm("a2"));
static ULONG CollPurgeHook(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), struct LocalContextItem *lci __asm("a2"));
static ULONG DOSStreamHook(struct Hook *hook __asm("a0"), struct IFFStreamCmd *cmd __asm("a1"), struct IFFHandle *iff __asm("a2"));
static ULONG ClipStreamHook(struct Hook *hook __asm("a0"), struct IFFStreamCmd *cmd __asm("a1"), struct IFFHandle *iff __asm("a2"));

#define HOOK_INIT(fn) { {NULL,NULL}, (ULONG(*)())fn, NULL, NULL }

static struct Hook PropHook      = HOOK_INIT(PropHandler);     /* .data+0x00 */
static struct Hook StopHook      = HOOK_INIT(StopHandler);     /* .data+0x14 */
static struct Hook CollHook      = HOOK_INIT(CollHandler);     /* .data+0x28 */
static struct Hook ExitStopHook  = HOOK_INIT(ExitStopHandler); /* .data+0x3c */
static struct Hook CollPurge     = HOOK_INIT(CollPurgeHook);   /* .data+0x50 */
static struct Hook DOSHook       = HOOK_INIT(DOSStreamHook);   /* .data+0x64 */
static struct Hook ClipHook      = HOOK_INIT(ClipStreamHook);  /* .data+0x78 */

/* library base pointer, stored by LibInit */
struct IFFBase *IFFBase;

/* =================================================================
 * small helpers
 * ================================================================= */

static void InitMinList(struct MinList *list)
{
    list->mlh_Head = (struct MinNode *)&list->mlh_Tail;
    list->mlh_Tail = NULL;
    list->mlh_TailPred = (struct MinNode *)list;
}

/*
 * CallHookEntry: (a0=hook, a1=msg, a2=object)
 * jumps to hook->h_Entry; NULL hook or NULL entry -> IFFERR_NOHOOK.
 */
static LONG CallHookEntry(struct Hook *hook __asm("a0"),
                          APTR msg __asm("a1"), APTR object __asm("a2"))
{
    if (!hook || !hook->h_Entry)
        return IFFERR_NOHOOK;
    return ((HookEntry)hook->h_Entry)(hook, msg, object);
}

static LONG IFFSeek(struct IFFHandle *iff __asm("a0"), LONG n __asm("d0"));

/*
 * StreamCall: issue an IFFStreamCmd to iff_Hook.
 * (a0=iff, d0=command, d1=errcode, a1=buf, stack=nbytes)
 * Returns 0 if the hook reports success, otherwise the error code
 * supplied by the caller.
 */
static LONG StreamCall(struct IFFHandle *iff __asm("a0"),
                       LONG command __asm("d0"), LONG errcode __asm("d1"),
                       APTR buf __asm("a1"), LONG nbytes)
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct IFFStreamCmd cmd;

    cmd.sc_Command = command;
    cmd.sc_Buf     = buf;
    cmd.sc_NBytes  = nbytes;

    if (CallHookEntry(ih->iff_Hook, &cmd, iff))
        return errcode;
    return 0;
}

/*
 * WriteData: write raw bytes to the stream.
 * (a0=iff, a1=buf, d0=count)
 * Streams with IFFF_RSEEK go straight out; for streams that cannot
 * back-seek, the bytes are appended to iff_WriteList and flushed
 * when the outermost context is popped, so that unknown chunk sizes
 * can be backpatched in memory.
 */
static LONG WriteData(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG count __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct WriteBuf *wb;
    UBYTE *d;
    LONG i;

    if (ih->iff_Flags & IFFF_RSEEK)
        return StreamCall(iff, IFFCMD_WRITE, IFFERR_WRITE, buf, count);

    wb = (struct WriteBuf *)AllocMem(count + 16, 0);
    if (!wb)
        return IFFERR_WRITE;
    wb->wb_Size = count;
    wb->wb_Data = (UBYTE *)(wb + 1);
    d = wb->wb_Data;
    for (i = 0; i < count; i++)
        d[i] = ((UBYTE *)buf)[i];
    AddTail((struct List *)&ih->iff_WriteList, (struct Node *)wb);
    return 0;
}

/* free all deferred write buffers without writing them (write-mode close) */
static void FreeWriteBufs(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct WriteBuf *wb;

    while ((wb = (struct WriteBuf *)RemHead((struct List *)&ih->iff_WriteList)))
        FreeMem(wb, wb->wb_Size + 16);
}

/* flush deferred write buffers to the stream, oldest first */
static LONG FlushWriteBufs(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct WriteBuf *wb;
    LONG err;

    if (ih->iff_Flags & IFFF_RSEEK)
        return 0;
    while ((wb = (struct WriteBuf *)RemHead((struct List *)&ih->iff_WriteList))) {
        err = StreamCall(iff, IFFCMD_WRITE, IFFERR_WRITE, wb->wb_Data, wb->wb_Size);
        FreeMem(wb, wb->wb_Size + 16);
        if (err)
            return err;
    }
    return 0;
}

/*
 * BackPatch: overwrite 4 bytes at distance "offset" before the current
 * stream position with "value".
 * (a0=iff, d0=offset, d1=value)
 * Seek streams seek back, write, then seek forward again.  Streams
 * without IFFF_RSEEK patch the deferred write buffer list instead.
 */
static LONG BackPatch(struct IFFHandle *iff __asm("a0"), LONG offset __asm("d0"), LONG value __asm("d1"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct WriteBuf *wb;
    LONG accum;
    LONG err;

    if (ih->iff_Flags & IFFF_RSEEK) {
        if ((err = IFFSeek(iff, -offset)))
            return err;
        if ((err = StreamCall(iff, IFFCMD_WRITE, IFFERR_WRITE, &value, 4)))
            return err;
        return IFFSeek(iff, offset - 4);
    }

    /* walk the deferred buffer list backwards from its tail */
    accum = 0;
    wb = (struct WriteBuf *)ih->iff_WriteList.mlh_TailPred;
    for (;;) {
        accum += wb->wb_Size;
        if (accum >= offset)
            break;
        if (!wb->wb_Node.mln_Pred)
            return IFFERR_SEEK;
        wb = (struct WriteBuf *)wb->wb_Node.mln_Pred;
    }
    *(LONG *)(wb->wb_Data + accum - offset) = value;
    return 0;
}

/*
 * IFFSeek: move the stream position by n bytes.
 * (a0=iff, d0=n)
 * Negative offsets require IFFF_RSEEK.  Streams with no seek ability
 * are wound forward by reading and discarding 512 bytes at a time.
 */
static LONG IFFSeek(struct IFFHandle *iff __asm("a0"), LONG n __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    APTR buf;
    LONG err, c;

    if (n < 0 && !(ih->iff_Flags & IFFF_RSEEK))
        return IFFERR_SEEK;

    if (n <= 0 || (ih->iff_Flags & (IFFF_FSEEK | IFFF_RSEEK)))
        return StreamCall(iff, IFFCMD_SEEK, IFFERR_SEEK, NULL, n);

    c = (n > 512) ? 512 : n;
    buf = AllocMem(c, 0);
    if (!buf)
        return IFFERR_SEEK;
    err = 0;
    while (!err && n) {
        LONG cnt = (n > 512) ? 512 : n;
        err = StreamCall(iff, IFFCMD_READ, IFFERR_READ, buf, cnt);
        n -= cnt;
    }
    FreeMem(buf, c);
    return err;
}

/* free a context node and purge its local context items */
static void FreeContext(struct IFFHandle *iff __asm("a0"), struct ContextNodeInt *cn __asm("a1"));

typedef LONG (*ChunkFn)(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"));

/* read exactly n bytes of chunk data, or fail */
static LONG ReadExact(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG n __asm("d0"))
{
    LONG got = ReadChunkBytes(iff, buf, n);

    if (got == n)
        return 0;
    if (got > 0)
        return IFFERR_READ;
    return got;
}

/* =================================================================
 * context helpers
 * ================================================================= */

/* CurrentChunk (LVO -174) */
struct ContextNode *CurrentChunk(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn = (struct ContextNodeInt *)ih->iff_ContextStack.mlh_Head;

    if (cn->cn_ID == 0)
        return NULL;
    return (struct ContextNode *)cn;
}

/* ParentChunk (LVO -180): parent context of cn, NULL at the root */
struct ContextNode *ParentChunk(struct ContextNode *cn __asm("a0"))
{
    struct ContextNodeInt *p = (struct ContextNodeInt *)((struct ContextNodeInt *)cn)->cn_Node.mln_Succ;

    if (!p->cn_Node.mln_Succ)
        return NULL;
    if (p->cn_ID == 0)
        return NULL;
    return (struct ContextNode *)p;
}

/* FindPropContext (LVO -168): topmost FORM/LIST context above the current one */
struct ContextNode *FindPropContext(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn = (struct ContextNodeInt *)ih->iff_ContextStack.mlh_Head;

    for (cn = (struct ContextNodeInt *)cn->cn_Node.mln_Succ; cn;
         cn = (struct ContextNodeInt *)cn->cn_Node.mln_Succ) {
        if (cn->cn_ID == ID_FORM || cn->cn_ID == ID_LIST)
            return (struct ContextNode *)cn;
    }
    return NULL;
}

/* FindLocalItem (LVO -210): scan every context's LCI list, top first */
struct LocalContextItem *FindLocalItem(struct IFFHandle *iff __asm("a0"),
                                     LONG type __asm("d0"), LONG id __asm("d1"), LONG ident __asm("d2"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn;
    struct LocalContextItemInt *lci;

    for (cn = (struct ContextNodeInt *)ih->iff_ContextStack.mlh_Head; cn;
         cn = (struct ContextNodeInt *)cn->cn_Node.mln_Succ) {
        for (lci = (struct LocalContextItemInt *)cn->cn_LCIList.mlh_Head;
             lci->lci_Node.mln_Succ;
             lci = (struct LocalContextItemInt *)lci->lci_Node.mln_Succ) {
            if (lci->lci_Ident == (ULONG)ident &&
                lci->lci_ID == (ULONG)id &&
                lci->lci_Type == (ULONG)type)
                return (struct LocalContextItem *)lci;
        }
    }
    return NULL;
}

/*
 * purge one LCI: run its purge hook with an IFFCMD_PURGELCI message,
 * or just free it when no hook is installed.
 */
static void PurgeLCI(struct IFFHandle *iff __asm("a0"), struct LocalContextItemInt *lci)
{
    struct IFFStreamCmd cmd;

    if (lci->lci_Purge) {
        cmd.sc_Command = IFFCMD_PURGELCI;
        CallHookEntry(lci->lci_Purge, &cmd, lci);
    } else {
        FreeLocalItem((struct LocalContextItem *)lci);
    }
}

/* free a context node and every LCI still attached to it */
static void FreeContext(struct IFFHandle *iff __asm("a0"), struct ContextNodeInt *cn __asm("a1"))
{
    struct LocalContextItemInt *lci;

    while ((lci = (struct LocalContextItemInt *)RemHead((struct List *)&cn->cn_LCIList)))
        PurgeLCI(iff, lci);
    FreeMem(cn, 40);
}

/* =================================================================
 * local context items
 * ================================================================= */

/* AllocLocalItem (LVO -186): header(24) + data, AllocVec+MEMF_CLEAR */
struct LocalContextItem *AllocLocalItem(LONG type __asm("d0"), LONG id __asm("d1"),
                                        LONG ident __asm("d2"), LONG size __asm("d3"))
{
    struct LocalContextItemInt *lci;

    lci = (struct LocalContextItemInt *)AllocVec(size + 24, MEMF_CLEAR);
    if (!lci)
        return NULL;
    lci->lci_ID = id;
    lci->lci_Type = type;
    lci->lci_Ident = ident;
    return (struct LocalContextItem *)lci;
}

/* LocalItemData (LVO -192) */
APTR LocalItemData(struct LocalContextItem *lci __asm("a0"))
{
    if (!lci)
        return NULL;
    return ILCI_DATA(lci);
}

/* SetLocalItemPurge (LVO -198) */
void SetLocalItemPurge(struct LocalContextItem *lci __asm("a0"), struct Hook *hook __asm("a1"))
{
    ILCI(lci)->lci_Purge = hook;
}

/* FreeLocalItem (LVO -204) */
void FreeLocalItem(struct LocalContextItem *lci __asm("a0"))
{
    FreeVec(lci);
}

/* StoreItemInContext (LVO -222): link lci into cn, purge duplicates */
void StoreItemInContext(struct IFFHandle *iff __asm("a0"),
                        struct LocalContextItem *lci __asm("a1"),
                        struct ContextNode *cn __asm("a2"))
{
    struct ContextNodeInt *icn = ICNODE(cn);
    struct LocalContextItemInt *il = ILCI(lci);
    struct LocalContextItemInt *p, *next;

    AddHead((struct List *)&icn->cn_LCIList, (struct Node *)il);

    for (p = (struct LocalContextItemInt *)il->lci_Node.mln_Succ;
         p && p->lci_Node.mln_Succ; p = next) {
        next = (struct LocalContextItemInt *)p->lci_Node.mln_Succ;
        if (p->lci_Ident == il->lci_Ident &&
            p->lci_ID == il->lci_ID &&
            p->lci_Type == il->lci_Type) {
            Remove((struct Node *)p);
            PurgeLCI(iff, p);
        }
    }
}

/* StoreLocalItem (LVO -216) */
LONG StoreLocalItem(struct IFFHandle *iff __asm("a0"),
                    struct LocalContextItem *lci __asm("a1"), LONG pos __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn = NULL;

    if (pos == IFFSLI_TOP)
        cn = (struct ContextNodeInt *)ih->iff_ContextStack.mlh_Head;
    else if (pos == IFFSLI_ROOT)
        cn = (struct ContextNodeInt *)ih->iff_ContextStack.mlh_TailPred;
    else if (pos == IFFSLI_PROP)
        cn = ICNODE(FindPropContext(iff));

    if (!cn)
        return IFFERR_NOSCOPE;
    StoreItemInContext(iff, lci, (struct ContextNode *)cn);
    return 0;
}

/* =================================================================
 * handler registration
 * ================================================================= */

static LONG InstallHandler(struct IFFHandle *iff __asm("a0"), LONG ident,
                           LONG type __asm("d0"), LONG id __asm("d1"), LONG pos __asm("d2"),
                           struct Hook *handler __asm("a1"), APTR object __asm("a2"))
{
    struct LocalContextItem *lci;
    struct HandlerData *hd;
    LONG err;

    lci = AllocLocalItem(type, id, ident, sizeof(struct HandlerData));
    if (!lci)
        return IFFERR_NOMEM;
    hd = (struct HandlerData *)LocalItemData(lci);
    hd->hd_Hook = handler;
    hd->hd_Object = object;
    err = StoreLocalItem(iff, lci, pos);
    if (err) {
        FreeLocalItem(lci);
        return err;
    }
    return 0;
}

/* EntryHandler (LVO -102) */
LONG EntryHandler(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"),
                  LONG pos __asm("d2"), struct Hook *handler __asm("a1"), APTR object __asm("a2"))
{
    return InstallHandler(iff, IDENT_ENTRY, type, id, pos, handler, object);
}

/* ExitHandler (LVO -108) */
LONG ExitHandler(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"),
                 LONG pos __asm("d2"), struct Hook *handler __asm("a1"), APTR object __asm("a2"))
{
    return InstallHandler(iff, IDENT_EXIT, type, id, pos, handler, object);
}

/* PropChunk (LVO -114) */
LONG PropChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    return EntryHandler(iff, type, id, IFFSLI_TOP, (struct Hook *)&PropHook, iff);
}

/* StopChunk (LVO -126) */
LONG StopChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    return EntryHandler(iff, type, id, IFFSLI_TOP, (struct Hook *)&StopHook, iff);
}

/* CollectionChunk (LVO -138) */
LONG CollectionChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    return EntryHandler(iff, type, id, IFFSLI_TOP, (struct Hook *)&CollHook, iff);
}

/* StopOnExit (LVO -150) */
LONG StopOnExit(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    return ExitHandler(iff, type, id, IFFSLI_TOP, (struct Hook *)&ExitStopHook, iff);
}

/* pair-list helper for PropChunks/StopChunks/CollectionChunks */
static LONG ChunkList(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"),
                      LONG n __asm("d0"), ChunkFn fn __asm("a2"))
{
    LONG err = 0;

    while (n--) {
        err = fn(iff, pairs[0], pairs[1]);
        pairs += 2;
        if (err)
            break;
    }
    return err;
}

/* PropChunks (LVO -120) */
LONG PropChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"))
{
    return ChunkList(iff, pairs, n, PropChunk);
}

/* StopChunks (LVO -132) */
LONG StopChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"))
{
    return ChunkList(iff, pairs, n, StopChunk);
}

/* CollectionChunks (LVO -144) */
LONG CollectionChunks(struct IFFHandle *iff __asm("a0"), LONG *pairs __asm("a1"), LONG n __asm("d0"))
{
    return ChunkList(iff, pairs, n, CollectionChunk);
}

/* =================================================================
 * lookup functions
 * ================================================================= */

/* FindProp (LVO -156) */
struct StoredProperty *FindProp(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    struct LocalContextItem *lci = FindLocalItem(iff, type, id, IDENT_PROP);

    return lci ? (struct StoredProperty *)LocalItemData(lci) : NULL;
}

/* FindCollection (LVO -162) */
struct CollectionItem *FindCollection(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"), LONG id __asm("d1"))
{
    struct LocalContextItem *lci = FindLocalItem(iff, type, id, IDENT_COLL);
    struct CollectionList *cl;

    if (!lci)
        return NULL;
    cl = (struct CollectionList *)LocalItemData(lci);
    return (struct CollectionItem *)cl->cl_Head;
}

/* =================================================================
 * id/type validation
 * ================================================================= */

/* GoodID (LVO -258): printable, no leading space unless ID_NULL */
LONG GoodID(LONG id __asm("d0"))
{
    UBYTE *p = (UBYTE *)&id;
    LONG i;

    if (p[0] == ' ' && id != ID_NULL)
        return FALSE;
    for (i = 0; i < 4; i++)
        if (p[i] < 0x20 || p[i] > 0x7e)
            return FALSE;
    return TRUE;
}

/* GoodType (LVO -264): printable id, uppercase letters/digits/space only */
LONG GoodType(LONG type __asm("d0"))
{
    UBYTE *p = (UBYTE *)&type;
    LONG i;
    UBYTE c;

    if (!GoodID(type))
        return FALSE;
    for (i = 0; i < 4; i++) {
        c = p[i];
        if (!((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == ' '))
            return FALSE;
    }
    return TRUE;
}

/* IDtoStr (LVO -270): unpack the id into a NUL-terminated buffer */
STRPTR IDtoStr(LONG id __asm("d0"), STRPTR buf __asm("a0"))
{
    UBYTE *p = (UBYTE *)&id;
    LONG i;

    for (i = 0; i < 4; i++)
        buf[i] = p[i];
    buf[4] = 0;
    return buf;
}

/* =================================================================
 * handle management
 * ================================================================= */

/* AllocIFF (LVO -30): handle (40) + root context node (40), MEMF_CLEAR */
struct IFFHandle *AllocIFF(void)
{
    struct IFFHandleInt *ih;
    struct ContextNodeInt *root;

    ih = (struct IFFHandleInt *)AllocMem(40, MEMF_CLEAR);
    if (!ih)
        return NULL;
    InitMinList(&ih->iff_ContextStack);
    InitMinList(&ih->iff_WriteList);

    root = (struct ContextNodeInt *)AllocMem(40, MEMF_CLEAR);
    if (!root) {
        FreeMem(ih, 40);
        return NULL;
    }
    InitMinList(&root->cn_LCIList);
    AddHead((struct List *)&ih->iff_ContextStack, (struct Node *)root);
    return (struct IFFHandle *)ih;
}

/* FreeIFF (LVO -54): frees the handle and the top context node */
void FreeIFF(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn;

    if (!ih)
        return;
    cn = (struct ContextNodeInt *)RemHead((struct List *)&ih->iff_ContextStack);
    FreeContext(iff, cn);
    FreeMem(ih, 40);
}

/* OpenIFF (LVO -36): clear write bit, set mode, mark first chunk, IFFCMD_INIT */
LONG OpenIFF(struct IFFHandle *iff __asm("a0"), LONG mode __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct IFFStreamCmd cmd;

    if (!ih)
        return IFFERR_NOMEM;
    ih->iff_Depth = 0;
    ih->iff_Flags &= ~IFFF_WRITE;
    ih->iff_Flags |= (mode & IFFF_WRITE) | IFFF_FIRSTCHUNK;
    cmd.sc_Command = IFFCMD_INIT;
    cmd.sc_Buf = NULL;
    cmd.sc_NBytes = 0;
    return CallHookEntry(ih->iff_Hook, &cmd, iff);
}

/* CloseIFF (LVO -48): pop everything, discard write buffers, IFFCMD_CLEANUP */
void CloseIFF(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct IFFStreamCmd cmd;
    struct ContextNodeInt *cn;
    LONG err;

    if (!ih)
        return;

    err = 0;
    while (!err && (cn = ICNODE(CurrentChunk(iff))))
        err = PopChunk(iff);

    if (err) {
        while ((cn = ICNODE(CurrentChunk(iff)))) {
            Remove((struct Node *)cn);
            FreeContext(iff, cn);
            ih->iff_Depth--;
        }
    }

    if (ih->iff_Flags & IFFF_WRITE)
        FreeWriteBufs(iff);

    cmd.sc_Command = IFFCMD_CLEANUP;
    cmd.sc_Buf = NULL;
    cmd.sc_NBytes = 0;
    CallHookEntry(ih->iff_Hook, &cmd, iff);
}

/* =================================================================
 * the parser
 * ================================================================= */

/* read the chunk's 4-byte form type into cn_Type and validate it */
static LONG ReadFormType(struct IFFHandle *iff __asm("a0"))
{
    struct ContextNodeInt *cn = ICNODE(CurrentChunk(iff));
    LONG type;

    if (ReadChunkBytes(iff, &type, 4) != 4)
        return IFFERR_READ;
    cn->cn_Type = type;
    if (!GoodType(type))
        return IFFERR_MANGLED;
    return 0;
}

/*
 * ReadChunkHdr: read an 8-byte chunk header and push a context.
 * "top" non-zero reads the very first header straight from the stream
 * (no enclosing context to bound it); otherwise the header is read
 * through ReadChunkBytes so the parent scan count is updated, and the
 * declared size is checked against the parent's remaining bytes.
 */
static LONG ReadChunkHdr(struct IFFHandle *iff __asm("a0"), LONG top __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *parent, *cn;
    LONG formtype;
    struct { LONG id; LONG size; } hdr;
    LONG err;

    parent = ICNODE(CurrentChunk(iff));
    if (!parent && !top)
        return IFFERR_EOF;
    formtype = parent ? parent->cn_Type : 0;

    if (top) {
        err = StreamCall(iff, IFFCMD_READ, IFFERR_READ, &hdr, 8);
        if (err)
            return err;
    } else {
        if (ReadChunkBytes(iff, &hdr, 8) != 8)
            return IFFERR_READ;
        if (hdr.size > parent->cn_Size - parent->cn_Used)
            return IFFERR_MANGLED;
    }

    if (!GoodID(hdr.id))
        return (ih->iff_Flags & IFFF_FIRSTCHUNK) ? IFFERR_NOTIFF : IFFERR_SYNTAX;
    if (hdr.size < 0)
        return IFFERR_MANGLED;

    cn = (struct ContextNodeInt *)AllocMem(40, 0);
    if (!cn)
        return IFFERR_NOMEM;
    cn->cn_Type = formtype;
    cn->cn_ID = hdr.id;
    cn->cn_Size = hdr.size;
    cn->cn_Scan = 0;
    cn->cn_Used = 0;
    InitMinList(&cn->cn_LCIList);
    AddHead((struct List *)&ih->iff_ContextStack, (struct Node *)cn);
    ih->iff_Depth++;
    return 0;
}

/*
 * Step: advance the raw parser by one primitive operation.
 * Returns 0 when a chunk was entered/stopped on, IFFERR_EOC at the
 * end of a context (the context is flagged for popping), or an error.
 */
static LONG Step(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn;
    LONG parentID;
    LONG err;

    if (ih->iff_Flags & IFFF_FIRSTCHUNK) {
        err = ReadChunkHdr(iff, 1);
        ih->iff_Flags &= ~(IFFF_FIRSTCHUNK | IFFF_PENDINGPOP);
        if (err)
            return err;
        cn = ICNODE(CurrentChunk(iff));
        if (cn->cn_ID != ID_FORM && cn->cn_ID != ID_CAT && cn->cn_ID != ID_LIST)
            return IFFERR_NOTIFF;
        if (cn->cn_Size & 1)
            return IFFERR_MANGLED;
        return ReadFormType(iff);
    }

    if (ih->iff_Flags & IFFF_PENDINGPOP) {
        err = PopChunk(iff);
        if (err)
            return err;
        ih->iff_Flags &= ~IFFF_PENDINGPOP;
    }

    cn = ICNODE(CurrentChunk(iff));
    if (!cn)
        return IFFERR_EOF;
    parentID = cn->cn_ID;

    if (parentID == ID_FORM || parentID == ID_CAT ||
        parentID == ID_LIST || parentID == ID_PROP) {
        if (cn->cn_Used < cn->cn_Size) {
            err = ReadChunkHdr(iff, 0);
            if (err)
                return err;
            cn = ICNODE(CurrentChunk(iff));
            if (cn->cn_ID == ID_FORM || cn->cn_ID == ID_CAT ||
                cn->cn_ID == ID_LIST || cn->cn_ID == ID_PROP) {
                if (cn->cn_ID == ID_PROP && parentID != ID_LIST)
                    return IFFERR_SYNTAX;
                return ReadFormType(iff);
            }
            if (parentID == ID_FORM || parentID == ID_PROP)
                return 0;
            return IFFERR_SYNTAX;
        }
        if (cn->cn_Used != cn->cn_Size)
            return IFFERR_MANGLED;
    }

    ih->iff_Flags |= IFFF_PENDINGPOP;
    return IFFERR_EOC;
}

/* ParseIFF (LVO -42): run the parser state machine */
LONG ParseIFF(struct IFFHandle *iff __asm("a0"), LONG mode __asm("d0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct IFFStreamCmd cmd;
    struct ContextNodeInt *cn;
    struct LocalContextItem *lci;
    struct HandlerData *hd;
    LONG err, res;

    for (;;) {
        err = Step(iff);
        if (err != 0 && err != IFFERR_EOC)
            return err;
        if (mode == IFFPARSE_RAWSTEP)
            return err;

        cn = ICNODE(CurrentChunk(iff));
        if (!cn)
            return IFFERR_EOF;
        lci = FindLocalItem(iff, cn->cn_Type, cn->cn_ID,
                            err ? IDENT_EXIT : IDENT_ENTRY);
        if (lci) {
            hd = (struct HandlerData *)LocalItemData(lci);
            cmd.sc_Command = err ? IFFCMD_EXIT : IFFCMD_ENTRY;
            res = CallHookEntry(hd->hd_Hook, &cmd, hd->hd_Object);
            if (res == IFF_RETURN2CLIENT)
                return 0;
            if (res)
                return res;
        }
        if (mode == IFFPARSE_STEP)
            return err;
    }
}

/* =================================================================
 * chunk I/O
 * ================================================================= */

/* ReadChunkRecords (LVO -72) */
LONG ReadChunkRecords(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"),
                    LONG recsize __asm("d0"), LONG numrec __asm("d1"))
{
    struct ContextNodeInt *cn;
    LONG avail, bytes;

    cn = ICNODE(CurrentChunk(iff));
    if (!cn)
        return IFFERR_EOF;

    /* the original clamps unconditionally here (cn_Size can never
       be -1 on the read side since negative sizes are rejected as
       MANGLED when the header is pushed) */
    avail = cn->cn_Size - cn->cn_Used;
    if (recsize != 1)
        avail = SDivMod32(avail, recsize);
    if (numrec > avail)
        numrec = avail;
    bytes = (recsize == 1) ? numrec : SMult32(numrec, recsize);
    if (!bytes)
        return 0;
    if (StreamCall(iff, IFFCMD_READ, IFFERR_READ, buf, bytes))
        return IFFERR_READ;
    cn->cn_Used += bytes;
    cn->cn_Scan = cn->cn_Used;
    return numrec;
}

/* ReadChunkBytes (LVO -60) */
LONG ReadChunkBytes(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG n __asm("d0"))
{
    return ReadChunkRecords(iff, buf, 1, n);
}

/* WriteChunkRecords (LVO -78) */
LONG WriteChunkRecords(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"),
                     LONG recsize __asm("d0"), LONG numrec __asm("d1"))
{
    struct ContextNodeInt *cn;
    LONG avail, bytes, err;

    cn = ICNODE(CurrentChunk(iff));
    if (!cn)
        return IFFERR_EOF;

    if (cn->cn_Size != IFFSIZE_UNKNOWN) {
        avail = cn->cn_Size - cn->cn_Used;
        if (recsize != 1)
            avail = SDivMod32(avail, recsize);
        if (numrec > avail)
            numrec = avail;
    }
    bytes = (recsize == 1) ? numrec : SMult32(numrec, recsize);
    if (!bytes)
        return 0;
    err = WriteData(iff, buf, bytes);
    if (err)
        return err;
    cn->cn_Used += bytes;
    cn->cn_Scan = cn->cn_Used;
    return numrec;
}

/* WriteChunkBytes (LVO -66) */
LONG WriteChunkBytes(struct IFFHandle *iff __asm("a0"), APTR buf __asm("a1"), LONG n __asm("d0"))
{
    return WriteChunkRecords(iff, buf, 1, n);
}

/* =================================================================
 * push/pop
 * ================================================================= */

/*
 * WritePush: create a chunk header + context in write mode.
 * (a0=iff, d0=type, d1=id, stack=size)
 */
static LONG WritePush(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"),
                      LONG id __asm("d1"), LONG size)
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *parent, *cn;
    struct { LONG id; LONG size; } hdr;
    LONG formtype = 0;
    BOOL first = FALSE;
    LONG err;

    parent = ICNODE(CurrentChunk(iff));
    if (parent) {
        formtype = parent->cn_Type;
    } else {
        if (ih->iff_Flags & IFFF_FIRSTCHUNK) {
            first = TRUE;
            ih->iff_Flags &= ~IFFF_FIRSTCHUNK;
        } else {
            return IFFERR_EOF;
        }
    }

    if (!GoodID(id))
        return IFFERR_SYNTAX;
    if (first) {
        if (id != ID_FORM && id != ID_CAT && id != ID_LIST)
            return IFFERR_NOTIFF;
    } else if (id == ID_PROP) {
        if (parent->cn_ID != ID_LIST)
            return IFFERR_SYNTAX;
    } else if (id == ID_FORM || id == ID_CAT ||
               id == ID_LIST || id == ID_PROP) {
        if (!GoodType(type))
            return IFFERR_NOTIFF;
    } else {
        if (parent->cn_ID != ID_FORM && parent->cn_ID != ID_PROP)
            return IFFERR_SYNTAX;
    }

    hdr.id = id;
    hdr.size = size;
    if (first) {
        err = WriteData(iff, &hdr, 8);
        if (err)
            return err;
    } else {
        if (WriteChunkBytes(iff, &hdr, 8) != 8)
            return IFFERR_WRITE;
    }

    cn = (struct ContextNodeInt *)AllocMem(40, 0);
    if (!cn)
        return IFFERR_NOMEM;
    cn->cn_ID = id;
    cn->cn_Size = size;
    cn->cn_Scan = 0;
    cn->cn_Used = 0;
    InitMinList(&cn->cn_LCIList);
    AddHead((struct List *)&ih->iff_ContextStack, (struct Node *)cn);
    ih->iff_Depth++;

    if (id == ID_FORM || id == ID_CAT || id == ID_LIST || id == ID_PROP) {
        if (WriteChunkBytes(iff, &type, 4) != 4)
            return IFFERR_WRITE;
        cn->cn_Type = type;
    } else {
        cn->cn_Type = formtype;
    }
    return 0;
}

/* PushChunk (LVO -84) */
LONG PushChunk(struct IFFHandle *iff __asm("a0"), LONG type __asm("d0"),
               LONG id __asm("d1"), LONG size __asm("d2"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);

    if (ih->iff_Flags & IFFF_WRITE)
        return WritePush(iff, type, id, size);
    return ReadChunkHdr(iff, 0);
}

/* write-mode pop: pad, backpatch unknown size, update the parent */
static LONG WritePop(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn, *parent;
    static const UBYTE pad = 0;
    LONG size, padded;
    BOOL patch = FALSE;
    LONG err;

    cn = ICNODE(CurrentChunk(iff));
    if (!cn)
        return IFFERR_EOF;

    if (cn->cn_Size == IFFSIZE_UNKNOWN) {
        patch = TRUE;
        size = cn->cn_Used;
    } else {
        size = cn->cn_Size;
        if (cn->cn_Used != size)
            return IFFERR_MANGLED;
    }
    padded = (size + 1) & ~1;
    if (padded > size) {
        err = WriteData(iff, (APTR)&pad, 1);
        if (err)
            return err;
    }

    Remove((struct Node *)cn);
    FreeMem(cn, 40);
    ih->iff_Depth--;

    if (patch) {
        err = BackPatch(iff, padded + 4, size);
        if (err)
            return err;
    }

    parent = ICNODE(CurrentChunk(iff));
    if (!parent)
        return FlushWriteBufs(iff);

    parent->cn_Used += padded;
    parent->cn_Scan = parent->cn_Used;
    if (parent->cn_Size != IFFSIZE_UNKNOWN && parent->cn_Used > parent->cn_Size)
        return IFFERR_MANGLED;
    return 0;
}

/* read-mode pop: skip to the chunk end, free the context, credit parent */
static LONG ReadPop(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ContextNodeInt *cn, *parent;
    LONG padded;
    LONG err;

    cn = ICNODE(CurrentChunk(iff));
    if (!cn)
        return IFFERR_EOF;

    padded = (cn->cn_Size + 1) & ~1;
    if (cn->cn_Used < padded) {
        err = IFFSeek(iff, padded - cn->cn_Used);
        if (err)
            return err;
    }

    Remove((struct Node *)cn);
    ih->iff_Depth--;
    FreeContext(iff, cn);

    parent = ICNODE(CurrentChunk(iff));
    if (parent) {
        parent->cn_Used += padded;
        parent->cn_Scan = parent->cn_Used;
    }
    return 0;
}

/* PopChunk (LVO -90) */
LONG PopChunk(struct IFFHandle *iff __asm("a0"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);

    if (ih->iff_Flags & IFFF_WRITE)
        return WritePop(iff);
    return ReadPop(iff);
}

/* =================================================================
 * built-in handlers
 * ================================================================= */

/* 'prop' handler: read the chunk into an allocated StoredProperty,
   store the LCI in the enclosing FORM/LIST (IFFSLI_PROP) context. */
static ULONG PropHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"),
                         struct IFFHandle *iff __asm("a2"))
{
    struct ContextNodeInt *cn;
    struct LocalContextItem *lci;
    struct StoredPropertyInt *sp;
    LONG size;
    LONG err;

    cn = ICNODE(CurrentChunk(iff));
    size = cn->cn_Size;
    lci = AllocLocalItem(cn->cn_Type, cn->cn_ID, IDENT_PROP, size + 8);
    if (!lci)
        return IFFERR_NOMEM;
    sp = (struct StoredPropertyInt *)LocalItemData(lci);
    err = ReadExact(iff, (UBYTE *)sp + 8, size);
    if (err) {
        FreeLocalItem(lci);
        return err;
    }
    sp->sp_Size = size;
    sp->sp_Data = (UBYTE *)sp + 8;
    err = StoreLocalItem(iff, lci, IFFSLI_PROP);
    if (err) {
        FreeLocalItem(lci);
        return err;
    }
    return 0;
}

/* 'coll' handler: read the chunk into a CollectionItem and link it
   into the 'coll' list of the enclosing FORM/LIST context, inheriting
   outer-scope items when a 'coll' list already exists elsewhere. */
static ULONG CollHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"),
                         struct IFFHandle *iff __asm("a2"))
{
    struct ContextNodeInt *cn;
    struct ContextNodeInt *scope;
    struct LocalContextItem *lci, *existing;
    struct CollectionItemInt *item;
    struct CollectionList *cl, *oldcl = NULL;
    LONG size;
    LONG err;

    cn = ICNODE(CurrentChunk(iff));
    size = cn->cn_Size;

    item = (struct CollectionItemInt *)AllocMem(size + 12, 0);
    if (!item)
        return IFFERR_NOMEM;
    err = ReadExact(iff, (UBYTE *)item + 12, size);
    if (err) {
        FreeMem(item, size + 12);
        return err;
    }
    item->ci_Size = size;
    item->ci_Data = (UBYTE *)item + 12;

    scope = ICNODE(FindPropContext(iff));
    if (!scope) {
        FreeMem(item, size + 12);
        return IFFERR_NOSCOPE;
    }

    existing = FindLocalItem(iff, cn->cn_Type, cn->cn_ID, IDENT_COLL);
    if (existing)
        oldcl = (struct CollectionList *)LocalItemData(existing);

    if (oldcl && oldcl->cl_Scope == scope) {
        cl = oldcl;
    } else {
        lci = AllocLocalItem(cn->cn_Type, cn->cn_ID, IDENT_COLL, sizeof(struct CollectionList));
        if (!lci) {
            FreeMem(item, size + 12);
            return IFFERR_NOMEM;
        }
        SetLocalItemPurge(lci, (struct Hook *)&CollPurge);
        cl = (struct CollectionList *)LocalItemData(lci);
        cl->cl_Scope = scope;
        cl->cl_Stop = NULL;
        if (oldcl)
            cl->cl_Stop = oldcl->cl_Head;
        cl->cl_Head = cl->cl_Stop;
        err = StoreLocalItem(iff, lci, IFFSLI_PROP);
        if (err) {
            FreeLocalItem(lci);
            FreeMem(item, size + 12);
            return err;
        }
    }

    item->ci_Next = cl->cl_Head;
    cl->cl_Head = item;
    return 0;
}

/* 'stop' handler: returning IFF_RETURN2CLIENT stops ParseIFF cleanly */
static ULONG StopHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), APTR obj __asm("a2"))
{
    return IFF_RETURN2CLIENT;
}

/* 'stop on exit' handler: returning IFFERR_EOC stops at context exit */
static ULONG ExitStopHandler(struct Hook *hook __asm("a0"), APTR cmd __asm("a1"), APTR obj __asm("a2"))
{
    return IFFERR_EOC;
}

/* 'coll' purge hook: frees this scope's CollectionItems, stops at
   cl_Stop (items owned by an outer scope survive the context pop). */
static ULONG CollPurgeHook(struct Hook *hook __asm("a0"),
                           APTR cmd __asm("a1"), struct LocalContextItem *lci __asm("a2"))
{
    struct CollectionList *cl = (struct CollectionList *)LocalItemData(lci);
    struct CollectionItemInt *item, *next;

    for (item = cl->cl_Head; item && item != cl->cl_Stop; item = next) {
        next = item->ci_Next;
        FreeMem(item, item->ci_Size + 12);
    }
    FreeLocalItem(lci);
    return 0;
}

/* =================================================================
 * stream hooks
 * ================================================================= */

/* DOS stream hook: iff_Stream is a BPTR file handle */
static ULONG DOSStreamHook(struct Hook *hook __asm("a0"),
                           struct IFFStreamCmd *cmd __asm("a1"),
                           struct IFFHandle *iff __asm("a2"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    BPTR file = (BPTR)ih->iff_Stream;
    APTR buf = cmd->sc_Buf;
    LONG len = cmd->sc_NBytes;

    switch (cmd->sc_Command) {
    case IFFCMD_READ:
        return (Read(file, buf, len) != len);
    case IFFCMD_WRITE:
        return (Write(file, buf, len) != len);
    case IFFCMD_SEEK:
        return (Seek(file, len, OFFSET_CURRENT) == -1);
    default:
        return 0;
    }
}

/* clipboard stream hook: iff_Stream is a ClipboardHandle*
   (the binary's 120-byte layout) */
static ULONG ClipStreamHook(struct Hook *hook __asm("a0"),
                            struct IFFStreamCmd *cmd __asm("a1"),
                            struct IFFHandle *iff __asm("a2"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);
    struct ClipboardHandle *cbh = (struct ClipboardHandle *)ih->iff_Stream;
    struct IOClipReq *req = &cbh->cbh_Req;
    APTR buf = cmd->sc_Buf;
    LONG len = cmd->sc_NBytes;

    switch (cmd->sc_Command) {
    case IFFCMD_INIT:
        req->io_Offset = 0;
        req->io_ClipID = 0;
        return 0;
    case IFFCMD_CLEANUP:
        if (ih->iff_Flags & IFFF_WRITE) {
            req->io_Command = CMD_UPDATE;
        } else {
            req->io_Command = CMD_READ;
            req->io_Data = NULL;
            req->io_Length = 1;
            req->io_Offset = 0x7fffffff;
        }
        return (UBYTE)DoIO((struct IORequest *)req);
    case IFFCMD_READ:
        req->io_Command = CMD_READ;
        req->io_Data = buf;
        req->io_Length = len;
        return (UBYTE)DoIO((struct IORequest *)req);
    case IFFCMD_WRITE:
        req->io_Command = CMD_WRITE;
        req->io_Data = buf;
        req->io_Length = len;
        return (UBYTE)DoIO((struct IORequest *)req);
    case IFFCMD_SEEK:
        if ((LONG)(req->io_Offset + len) < 0)
            return IFFERR_SEEK;
        req->io_Offset += len;
        return 0;
    default:
        return 0;
    }
}

/* =================================================================
 * stream initialisation / clipboard management
 * ================================================================= */

/* InitIFF (LVO -228) */
void InitIFF(struct IFFHandle *iff __asm("a0"), LONG flags __asm("d0"), struct Hook *hook __asm("a1"))
{
    struct IFFHandleInt *ih = IHANDLE(iff);

    ih->iff_Hook = hook;
    ih->iff_Flags = flags;
}

/* InitIFFasDOS (LVO -234): install the DOS stream hook, FSEEK|RSEEK */
void InitIFFasDOS(struct IFFHandle *iff __asm("a0"))
{
    InitIFF(iff, IFFF_FSEEK | IFFF_RSEEK, (struct Hook *)&DOSHook);
}

/* InitIFFasClip (LVO -240): install the clipboard stream hook.
   The caller is expected to have stored an OpenClipboard() handle
   in iff_Stream beforehand. */
void InitIFFasClip(struct IFFHandle *iff __asm("a0"))
{
    InitIFF(iff, IFFF_FSEEK | IFFF_RSEEK, (struct Hook *)&ClipHook);
}

/* OpenClipboard (LVO -246): build a ClipboardHandle for "unit".
   On any failure the binary calls its own CloseClipboard() on the
   partially-initialised block. */
struct ClipboardHandle *OpenClipboard(LONG unit __asm("d0"))
{
    struct ClipboardHandle *cbh;
    LONG sig1, sig2;

    cbh = (struct ClipboardHandle *)AllocVec(sizeof(struct ClipboardHandle), 0);
    if (!cbh)
        return NULL;

    sig1 = AllocSignal(-1);
    sig2 = AllocSignal(-1);
    if (sig1 < 0 || sig2 < 0) {
        CloseClipboard((struct ClipboardHandle *)cbh);
        return NULL;
    }

    cbh->cbh_CBport.mp_Node.ln_Type = NT_MSGPORT;
    cbh->cbh_CBport.mp_Flags = 0;
    cbh->cbh_CBport.mp_SigBit = sig1;
    cbh->cbh_CBport.mp_SigTask = FindTask(NULL);
    InitMinList((struct MinList *)&cbh->cbh_CBport.mp_MsgList);

    cbh->cbh_SatisfyPort.mp_Node.ln_Type = NT_MSGPORT;
    cbh->cbh_SatisfyPort.mp_Flags = 0;
    cbh->cbh_SatisfyPort.mp_SigBit = sig2;
    cbh->cbh_SatisfyPort.mp_SigTask = FindTask(NULL);
    InitMinList((struct MinList *)&cbh->cbh_SatisfyPort.mp_MsgList);

    cbh->cbh_Req.io_Message.mn_ReplyPort = &cbh->cbh_CBport;
    if (OpenDevice((CONST_STRPTR)"clipboard.device", unit,
                   (struct IORequest *)&cbh->cbh_Req, 0)) {
        CloseClipboard((struct ClipboardHandle *)cbh);
        return NULL;
    }
    return (struct ClipboardHandle *)cbh;
}

/* CloseClipboard (LVO -252) */
void CloseClipboard(struct ClipboardHandle *cbh __asm("a0"))
{
    struct ClipboardHandle *c = (struct ClipboardHandle *)cbh;

    if (!c)
        return;
    CloseDevice((struct IORequest *)&c->cbh_Req);
    FreeSignal(c->cbh_CBport.mp_SigBit);
    FreeSignal(c->cbh_SatisfyPort.mp_SigBit);
    FreeVec(c);
}

/* =================================================================
 * library skeleton
 * ================================================================= */

struct Library *LibInit(struct IFFBase *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
BPTR LibClose(void);
BPTR LibExpunge(void);
LONG LibNull(void);

/*
 * LibInit: InitResident calls with d0=base, a0=seglist, a6=SysBase.
 * Opens dos.library and utility.library v37+, caches four utility
 * vector slots at +0x34..+0x43.
 */
struct Library *LibInit(struct IFFBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */
    APTR util;

    IFFBase = base;
    base->ib_SegList = seglist;
    base->ib_SysBase = sysbase;
    base->ib_Lib.lib_Revision = 1;

    base->ib_DOSBase = OpenLibrary((CONST_STRPTR)"dos.library", 37);
    if (!base->ib_DOSBase) {
        CloseLibrary((struct Library *)base->ib_DOSBase);
        CloseLibrary((struct Library *)base->ib_UtilityBase);
        Alert(0x38007);
        return NULL;
    }
    util = OpenLibrary((CONST_STRPTR)"utility.library", 37);
    base->ib_UtilityBase = util;
    if (!util) {
        CloseLibrary((struct Library *)base->ib_DOSBase);
        CloseLibrary((struct Library *)base->ib_UtilityBase);
        Alert(0x3800c);
        return NULL;
    }

    /* cache the four utility jump-table slots at +0x34..+0x43 */
    base->ib_SMult32   = (APTR)((UBYTE *)util - 138);
    base->ib_UMult32   = (APTR)((UBYTE *)util - 144);
    base->ib_SDivMod32 = (APTR)((UBYTE *)util - 150);
    base->ib_UDivMod32 = (APTR)((UBYTE *)util - 156);

    return (struct Library *)base;
}

/* LibOpen (LVO -6) */
struct Library *LibOpen(void)
{

    IFFBase->ib_Lib.lib_OpenCnt++;
    IFFBase->ib_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)IFFBase;
}

/* LibExpunge: shared by Expunge and the Close path.
   The binary unlinks the library node, closes dos.library then
   utility.library, frees the base memory and returns the seglist. */
static BPTR DoExpunge(struct IFFBase *IFFBase)
{
    struct IFFBase *base = IFFBase;
    BPTR seg;
    ULONG size;

    Remove((struct Node *)base);
    seg = base->ib_SegList;
    CloseLibrary(base->ib_DOSBase);
    CloseLibrary(base->ib_UtilityBase);
    size = base->ib_Lib.lib_NegSize + base->ib_Lib.lib_PosSize;
    FreeMem((UBYTE *)base - base->ib_Lib.lib_NegSize, size);
    return seg;
}

/* LibClose (LVO -12) */
BPTR LibClose(void)
{

    IFFBase->ib_Lib.lib_OpenCnt--;
    if (!(IFFBase->ib_Lib.lib_Flags & LIBF_DELEXP))
        return 0;
    if (IFFBase->ib_Lib.lib_OpenCnt == 0)
        return DoExpunge(IFFBase);
    IFFBase->ib_Lib.lib_Flags &= ~LIBF_DELEXP;
    return 0;
}

/* LibExpunge (LVO -18) */
BPTR LibExpunge(void)
{

    if (IFFBase->ib_Lib.lib_OpenCnt) {
        IFFBase->ib_Lib.lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    return DoExpunge(IFFBase);
}

/* LibNull: LVO -24 (ExtFunc) and LVO -96 (reserved) */
LONG LibNull(void)
{
    return 0;
}
