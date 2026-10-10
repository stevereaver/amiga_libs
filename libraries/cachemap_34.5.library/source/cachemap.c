/*
**	cachemap.c -- cachemap.library 34.5 (10.3.92)
**
**	C reconstruction of the shipped binary (1004 bytes, sha256
**	a9c68c0f089da8c82ec3eed6a41bf3f3fa0ca089c674417c2ac1b2101903973e).
**
**	CacheMap: a tiny library that allocates "cache map" nodes —
**	a list node, a small caller-defined data area and an
**	embedded struct BitMap whose plane buffers are owned by
**	the node.  Opened graphics.library at init (InitBitMap is
**	used to compute plane geometry).
**
**	Public API (names reconstructed, no fd shipped):
**	  LVO -30  CreateMap(width, height, depth, dataSize, flags) -> node
**	  LVO -36  DeleteMap(node)
**	  LVO -42  AllocMapPlanes(node) -> &data | 0
**	  LVO -48  LockMap(node) -> &data | 0 (locks; NULL if no planes)
**	  LVO -54  UnlockMap(node)
**	  LVO -60  MapPlaneSize(node) -> bytes per plane
**	  LVO -66  FillMapPlanes(mask, node) -- plane i filled with bit i
**	  LVO -72  ScaleBits(srcBits, dstBits, src, dst) -- bit stretch
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <inline/exec.h>
#include <inline/graphics.h>

/*
 * Cache map node.  Only ln_Succ/ln_Pred are used for linkage; the
 * node's private fields overlap the rest of a Node.
 *
 *   +0  ln_Succ / ln_Pred          (8)
 *   +8  allocSize                  (4) total allocation
 *   +12 dataSize                   (4) bytes of caller data at +28
 *   +16 lock                       (2)
 *   +18 depth                      (2) bitmap depth / plane count
 *   +20 planeSize                  (4) BytesPerRow * Rows
 *   +24 flags                      (4) AllocMem flags for planes
 *   +28 dataSize bytes of caller data
 *   +28+dataSize  struct BitMap    (8 header + 4*depth plane ptrs)
 */
struct CacheNode
{
    struct MinNode  cn_Link;      /* 0:  succ/pred only           */
    ULONG           cn_AllocSize; /* 8:  total AllocMem size      */
    ULONG           cn_DataSize;  /* 12: bytes before the BitMap  */
    UWORD           cn_Lock;      /* 16: lock count               */
    UWORD           cn_Depth;     /* 18: plane count              */
    ULONG           cn_PlaneSize; /* 20: bytes per plane          */
    ULONG           cn_Flags;     /* 24: plane alloc flags        */
};

#define CN_DATA(n)    ((UBYTE *)(n) + 28)
#define CN_BITMAP(n)  ((struct BitMap *)(CN_DATA(n) + (n)->cn_DataSize))
#define CN_PLANES(n)  ((APTR *)CN_BITMAP(n)->Planes)

/*
 * Private library base, InitTable dataSize = 0x3c (60).
 * The original keeps a private open count at base+34 and leaves
 * exec's lib_OpenCnt (base+32) at zero.
 */
struct CacheMapBase
{
    struct Library   lb_Lib;      /* 0x00 */
    UWORD            lb_OpenCnt;  /* 0x22 private open count      */
    BPTR             lb_SegList;  /* 0x24 */
    struct ExecBase *lb_SysBase;  /* 0x28 */
    struct GfxBase  *lb_GfxBase;  /* 0x2c */
    struct MinList   lb_List;     /* 0x30 live nodes              */
};

extern const char gfxname[];
extern const char libname[];
extern const char idstr[];

/*
 * LibInit -- called by MakeLibrary, d0 = base, a0 = seglist,
 * a6 = SysBase.  No InitStruct data: the routine writes ln_Name,
 * lib_IdString, lib_Version and lib_Revision itself.
 */
struct Library *LibInit(struct CacheMapBase *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sys __asm("a6");

    base->lb_SysBase = sys;
    base->lb_SegList = seglist;
    base->lb_OpenCnt = 0;
    base->lb_Lib.lib_OpenCnt = 0;

    base->lb_List.mlh_Head     = (struct MinNode *)&base->lb_List.mlh_Tail;
    base->lb_List.mlh_Tail     = NULL;
    base->lb_List.mlh_TailPred = (struct MinNode *)&base->lb_List.mlh_Head;

    base->lb_Lib.lib_Node.ln_Name = (char *)libname;
    base->lb_Lib.lib_IdString     = (char *)idstr;
    base->lb_Lib.lib_Version      = 34;
    base->lb_Lib.lib_Revision     = 5;

    base->lb_GfxBase = (struct GfxBase *)
        __OpenLibrary_base(sys, (STRPTR)gfxname, 0);
    if (!base->lb_GfxBase)
        return 0;
    return (struct Library *)base;
}

/* LibOpen (LVO -6): bump the private count, return the base. */
struct Library *LibOpen(struct CacheMapBase *base __asm("a6"))
{
    base->lb_OpenCnt++;
    return (struct Library *)base;
}

/* LibClose (LVO -12): decrement the private count, always 0. */
LONG LibClose(struct CacheMapBase *base __asm("a6"))
{
    base->lb_OpenCnt--;
    return 0;
}

/* free every allocated plane buffer of a node (LAB_0011) */
static void FreeMapPlanes(struct CacheMapBase *base, struct CacheNode *n)
{
    struct ExecBase *sys = base->lb_SysBase;
    APTR            *p   = CN_PLANES(n);
    WORD             i;

    for (i = 0; i < n->cn_Depth; i++) {
        if (p[i])
            __FreeMem_base(sys, p[i], n->cn_PlaneSize);
        p[i] = NULL;
    }
}

/* free the node block itself (LAB_0010) */
static void FreeMapNode(struct CacheMapBase *base, struct CacheNode *n)
{
    __FreeMem_base(base->lb_SysBase, n, n->cn_AllocSize);
}

/*
 * LibExpunge (LVO -18): Forbid; free the plane buffers of every
 * unlocked node (the node blocks themselves are NOT freed --
 * original behaviour); Permit; if the private count is zero the
 * library removes itself and returns its seglist.
 */
BPTR LibExpunge(struct CacheMapBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    struct CacheNode *n;
    BPTR             seg;
    UBYTE           *block;
    ULONG            size;

    __Forbid_base(sys);
    for (n = (struct CacheNode *)base->lb_List.mlh_Head;
         n->cn_Link.mln_Succ;
         n = (struct CacheNode *)n->cn_Link.mln_Succ) {
        if (!n->cn_Lock)
            FreeMapPlanes(base, n);
    }
    __Permit_base(sys);

    if (base->lb_OpenCnt)
        return 0;

    seg = base->lb_SegList;
    __Remove_base(sys, (struct Node *)base);
    block = (UBYTE *)base - base->lb_Lib.lib_NegSize;
    size  = (ULONG)base->lb_Lib.lib_NegSize + base->lb_Lib.lib_PosSize;
    __FreeMem_base(sys, block, size);
    return seg;
}

/*
 * AllocMapPlanes (LVO -42): allocate the depth plane buffers
 * (cn_PlaneSize bytes each, cn_Flags).  On failure frees all
 * partial allocations and returns 0; on success returns the
 * caller-data pointer (node+28).
 */
APTR AllocMapPlanes(struct CacheNode *n __asm("a1"),
                    struct CacheMapBase *base __asm("a6"))
{
    struct ExecBase *sys = base->lb_SysBase;
    APTR            *p   = CN_PLANES(n);
    WORD             i;

    for (i = 0; i < n->cn_Depth; i++) {
        p[i] = __AllocMem_base(sys, n->cn_PlaneSize, n->cn_Flags);
        if (!p[i]) {
            FreeMapPlanes(base, n);
            return 0;
        }
    }
    return CN_DATA(n);
}

/*
 * CreateMap (LVO -30): allocate a cache map node.
 *   d0 width, d1 height, d2 depth, d3 caller-data size (multiple
 *   of 4), d4 AllocMem flags for the plane buffers.
 * Returns the node or 0.
 */
struct CacheNode *CreateMap(ULONG width  __asm("d0"),
                            ULONG height __asm("d1"),
                            ULONG depth  __asm("d2"),
                            ULONG dsize  __asm("d3"),
                            ULONG flags  __asm("d4"),
                            struct CacheMapBase *base __asm("a6"))
{
    struct CacheNode *n;
    struct BitMap    *bm;
    ULONG             size;

    if (dsize & 3)
        return 0;

    size = 36 + dsize + depth * 4;
    n = __AllocMem_base(base->lb_SysBase, size, 0x00010001);
    if (!n)
        return 0;

    n->cn_AllocSize = size;
    n->cn_DataSize  = dsize;
    n->cn_Depth     = (UWORD)depth;
    n->cn_Flags     = flags;

    bm = CN_BITMAP(n);
    __InitBitMap_base(base->lb_GfxBase, bm, depth, width, height);
    n->cn_PlaneSize = (ULONG)bm->BytesPerRow * bm->Rows;

    if (!AllocMapPlanes(n, base)) {
        FreeMapNode(base, n);
        return 0;
    }

    __Forbid_base(base->lb_SysBase);
    __AddHead_base(base->lb_SysBase,
                   (struct List *)&base->lb_List, (struct Node *)n);
    __Permit_base(base->lb_SysBase);
    return n;
}

/*
 * DeleteMap (LVO -36): unlink a node under Forbid, free its plane
 * buffers and the node block.
 */
void DeleteMap(struct CacheNode *n __asm("a1"),
               struct CacheMapBase *base __asm("a6"))
{
    __Forbid_base(base->lb_SysBase);
    __Remove_base(base->lb_SysBase, (struct Node *)n);
    __Permit_base(base->lb_SysBase);
    FreeMapPlanes(base, n);
    FreeMapNode(base, n);
}

/*
 * LockMap (LVO -48): lock count++, return the caller-data pointer
 * or 0 when the first plane buffer is not allocated.
 */
APTR LockMap(struct CacheNode *n __asm("a1"))
{
    n->cn_Lock++;
    if (!CN_PLANES(n)[0])
        return 0;
    return CN_DATA(n);
}

/* UnlockMap (LVO -54): lock count--. */
void UnlockMap(struct CacheNode *n __asm("a1"))
{
    n->cn_Lock--;
}

/* MapPlaneSize (LVO -60): return the bytes-per-plane value. */
ULONG MapPlaneSize(struct CacheNode *n __asm("a1"))
{
    return n->cn_PlaneSize;
}

/*
 * FillMapPlanes (LVO -66): plane i is filled with all-ones when
 * bit i of d0 is set, all-zeros otherwise.  Fills planeSize longs
 * then planeSize&3 tail bytes.  Brackets the fill with lock++/--
 */
void FillMapPlanes(ULONG bits __asm("d0"),
                   struct CacheNode *n __asm("a1"))
{
    APTR *p = CN_PLANES(n);
    WORD  i;

    n->cn_Lock++;
    for (i = 0; i < n->cn_Depth; i++) {
        ULONG fill;
        ULONG *l;
        ULONG  j;

        fill = (bits & 1) ? ~0UL : 0;
        bits >>= 1;
        if (!p[i])
            continue;

        l = (ULONG *)p[i];
        for (j = 0; j < (n->cn_PlaneSize >> 2); j++)
            *l++ = fill;
        {
            UBYTE *b = (UBYTE *)l;
            for (j = 0; j < (n->cn_PlaneSize & 3); j++)
                *b++ = (UBYTE)fill;
        }
    }
    n->cn_Lock--;
}

/*
 * ScaleBits (LVO -72): nearest-neighbour replication of a bit
 * stream.  The nsrc MSB-first source bits at a0 are stretched to
 * ndst MSB-first output bits at a1 (Bresenham: each source bit is
 * emitted quot or quot+1 times).  Output accumulator is flushed
 * in 32-bit units; a trailing partial long is stored as one word
 * when fewer than 17 bits remain.
 *
 * Faithful port of the register-level original.
 */
void ScaleBits(ULONG nsrc __asm("d0"), ULONG ndst __asm("d1"),
               ULONG *src __asm("a0"), ULONG *dst __asm("a1"))
{
    ULONG packed;
    SHORT e;
    ULONG remain = ndst;
    ULONG acc    = 0;
    ULONG freebits = 32;          /* free bits in acc            */
    ULONG srcword  = 0;
    WORD  srccnt   = 1;
    ULONG i;

    packed = ndst;
    /* 68000 DIVU: low word quotient, high word remainder */
    __asm volatile("divu %1,%0" : "+d"(packed) : "d"((UWORD)nsrc));
    e = -(SHORT)(nsrc >> 1);

    for (i = nsrc; i; i--) {
        WORD rep;

        srcword <<= 1;
        if (--srccnt == 0) {
            srcword = *src++;
            srccnt = 32;
        }
        e += (SHORT)(packed >> 16);   /* error term += remainder */
        rep = (WORD)(packed & 0xffff); /* quotient */
        if (e >= 0) {
            e -= (SHORT)nsrc;
            rep += 1;
        }
        while (rep > 0) {
            WORD cnt = rep;

            if ((SHORT)freebits < cnt)
                cnt = (WORD)freebits;
            acc <<= cnt;
            if ((LONG)srcword < 0)
                acc |= (1UL << cnt) - 1;
            freebits -= cnt;
            if (freebits == 0) {
                *dst++ = acc;
                freebits = 32;
                remain  -= 32;
                rep     -= cnt;
            } else {
                break;
            }
        }
    }

    if (remain) {
        acc <<= freebits;
        if (remain < 17)
            *((UWORD *)dst) = (UWORD)(acc >> 16);
        else
            *dst = acc;
    }
}
