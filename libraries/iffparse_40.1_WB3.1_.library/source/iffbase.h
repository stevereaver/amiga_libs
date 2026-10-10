#ifndef IFFBASE_H
#define IFFBASE_H
/*
**	iffbase.h
**
**	Private structures for iffparse.library 40.1 (Workbench 3.1).
**	Layout was recovered by disassembling the shipped binary
**	"iffparse_40.1(WB3.1).library" ($VER: iffparse 40.1 (9.2.93)).
**
**	Public structures (IFFHandle, ContextNode, LocalContextItem,
**	StoredProperty, CollectionItem, ClipboardHandle, IFFStreamCmd)
**	are in <libraries/iffparse.h>; the fields below extend them
**	exactly as the original binary does.
*/

#include <exec/types.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/ports.h>
#include <exec/io.h>
#include <utility/hooks.h>
#include <libraries/iffparse.h>

/*
 * Library base.  InitResident/InitTable was built with dataSize=0x44:
 * struct Library (34 bytes, padded to 0x24) + 7 private longs.
 * The last four are caches of utility.library jump-table slots,
 * installed by the init function so the library can call SMult32,
 * UMult32, SDivMod32 and UDivMod32 without reloading a6.
 */
struct IFFBase
{
    struct Library  ib_Lib;         /* 0x00 */
    UWORD           ib_Pad;         /* 0x22 unused alignment word     */
    APTR            ib_SysBase;     /* 0x24 */
    APTR            ib_DOSBase;     /* 0x28 */
    APTR            ib_UtilityBase; /* 0x2c */
    BPTR            ib_SegList;     /* 0x30 */
    APTR            ib_SMult32;     /* 0x34 &UtilityBase[-138] */
    APTR            ib_UMult32;     /* 0x38 &UtilityBase[-144] */
    APTR            ib_SDivMod32;   /* 0x3c &UtilityBase[-150] */
    APTR            ib_UDivMod32;   /* 0x40 &UtilityBase[-156] */
};                                  /* 0x44 */

/* library base pointer -- stored once by LibInit */
extern struct IFFBase *IFFBase;

/*
 * Internal IFFHandle.  AllocIFF allocates 40 bytes; the first three
 * fields are public (libraries/iffparse.h), the rest are private.
 */
struct IFFHandleInt
{
    ULONG           iff_Stream;         /* 0x00 stream cookie/BPTR/cbh */
    ULONG           iff_Flags;          /* 0x04 */
    LONG            iff_Depth;          /* 0x08 */
    struct MinList  iff_ContextStack;   /* 0x0c head = top ContextNode */
    struct MinList  iff_WriteList;      /* 0x18 deferred write buffers */
    struct Hook    *iff_Hook;           /* 0x24 stream hook            */
};

#define IHANDLE(iff) ((struct IFFHandleInt *)(iff))

/* private iff_Flags bits (upper word lives in byte offset 5) */
#define IFFF_FIRSTCHUNK 0x00010000L     /* first chunk pending/validating */
#define IFFF_PENDINGPOP 0x00020000L     /* pop this context on next step  */

/*
 * Internal ContextNode.  Allocated 40 bytes.  Succ chain points from
 * the current (top) context down towards the root node; the root node
 * sits at the tail of iff_ContextStack and has cn_ID == 0.
 */
struct ContextNodeInt
{
    struct MinNode  cn_Node;            /* 0x00 */
    LONG            cn_ID;              /* 0x08 chunk id               */
    LONG            cn_Type;            /* 0x0c form type context      */
    LONG            cn_Size;            /* 0x10 declared size          */
    LONG            cn_Scan;            /* 0x14 bytes consumed (public)*/
    struct MinList  cn_LCIList;         /* 0x18 local context items    */
    LONG            cn_Used;            /* 0x24 internal byte counter  */
};

#define ICNODE(cn) ((struct ContextNodeInt *)(cn))

/*
 * Internal LocalContextItem.  Header is 24 bytes; caller data follows.
 * lci_Purge at +0x14 is invisible to clients.
 */
struct LocalContextItemInt
{
    struct MinNode  lci_Node;           /* 0x00 */
    ULONG           lci_ID;             /* 0x08 */
    ULONG           lci_Type;           /* 0x0c */
    ULONG           lci_Ident;          /* 0x10 */
    struct Hook    *lci_Purge;          /* 0x14 purge hook or NULL     */
};

#define ILCI(lci)    ((struct LocalContextItemInt *)(lci))
#define ILCI_DATA(l) ((APTR)((UBYTE *)(l) + 24))

/* entry/exit handler payload (8 bytes): { hook, object } */
struct HandlerData
{
    struct Hook *hd_Hook;
    APTR         hd_Object;
};

/* stored property payload: { sp_Size, sp_Data, data[] } */
struct StoredPropertyInt
{
    LONG   sp_Size;
    APTR   sp_Data;
    /* data follows */
};

/* collection item payload prefix (12 bytes, data follows) */
struct CollectionItemInt
{
    struct CollectionItemInt *ci_Next;  /* chain crosses contexts */
    LONG                    ci_Size;
    APTR                    ci_Data;
};

/* 'coll' LCI payload (12 bytes) */
struct CollectionList
{
    struct CollectionItemInt *cl_Head;  /* chain head (what FindCollection returns) */
    struct CollectionItemInt *cl_Stop;  /* first item owned by an outer scope      */
    struct ContextNodeInt    *cl_Scope; /* context this list was stored in         */
};

/* deferred write block (for streams without IFFF_RSEEK): 16 hdr + data */
struct WriteBuf
{
    struct MinNode  wb_Node;    /* 0x00 */
    LONG            wb_Size;    /* 0x08 */
    UBYTE          *wb_Data;    /* 0x0c = this+16 */
    /* data bytes at +0x10 */
};

/*
 * The 40.1 binary allocates its ClipboardHandle as 120 bytes and
 * touches io_Command@28, io_Offset@44, io_ClipID@48 -- exactly the
 * standard NDK <devices/clipboard.h> IOClipReq (52 bytes) and
 * <libraries/iffparse.h> ClipboardHandle (52+34+34 = 120 bytes).
 * No private layout is needed; the earlier suspicion of a legacy
 * 6-byte-shifted request was unfounded.
 */

/* clipboard stream units */
#ifndef PRIMARY_CLIP
#define PRIMARY_CLIP 0
#endif

#endif /* IFFBASE_H */
