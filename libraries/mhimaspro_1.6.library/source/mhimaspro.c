/*
 * mhimaspro.library 1.5 (26.08.2022) - MHI driver for the parallel-
 * port "MAS Player Pro" (MAS3507-class MP3 decoder on CIA-B).
 * Semantic C port of the shipped SAS/C build.
 */
#include "mhibase.h"
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/interrupts.h>
#include <clib/exec_protos.h>
#include <hardware/cia.h>

struct Library *g_DosBase, *g_GfxBase, *g_MiscBase, *g_MhiBase;
struct MinList  g_BufList;
WORD   g_MhiAllocated;
APTR   g_Owner;

#define CIAA_PRA  (*(volatile UBYTE *)0xBFE001)
#define CIAA_PRB  (*(volatile UBYTE *)0xBFE101)
#define CIAA_DDRB (*(volatile UBYTE *)0xBFE301)
#define CIAB_PRA  (*(volatile UBYTE *)0xBFD000)
#define CIAB_DDRA (*(volatile UBYTE *)0xBFD200)

/* exec helpers used by the shipped code */
#define OpenLib(n)  __OldOpenLibrary_base(*(void **)4,(UBYTE *)(n))
#define CloseLib(b) __CloseLibrary_base(*(void **)4,(APTR)(b))
extern ULONG AllocMiscResource(ULONG unit, UBYTE *name);
extern void  FreeMiscResource(ULONG unit);

/* ------------------------------------------------------------------ */

APTR LibInit(ULONG d0 __asm("d0"), APTR seg __asm("a0"),
             struct MhiBase *base __asm("a6"))
{
    (void)d0;
    base->mb_SegList = seg;
    g_DosBase = OpenLib("dos.library");
    { struct List *l = (struct List *)&g_BufList;
      l->lh_Head = (struct Node *)&l->lh_Tail;
      l->lh_Tail = NULL;
      l->lh_TailPred = (struct Node *)&l->lh_Head;
      l->lh_Type = NT_USER; }
    return base;
}

/* -30: allocate decoder handle (64KB ring + control header).
   Claims parallel port via misc.resource units 2 and 3; only one
   decoder allowed (g_MhiAllocated latch).  d0=sigmask a0=task. */
APTR MHIAllocDecoder(ULONG sigmask __asm("d0"), APTR task __asm("a0"))
{
    struct MhiDecoder *h;
    if (!OpenLib("graphics.library"))
        return NULL;
    g_GfxBase = g_GfxBase;                 /* stored */
    if (g_MhiAllocated) { CloseLib(g_GfxBase); return NULL; }
    h = __AllocMem_base(*(void **)4, 0x10019, MEMF_PUBLIC | MEMF_CLEAR);
    if (!h) { CloseLib(g_GfxBase); return NULL; }
    h->mh_Task    = task;
    h->mh_SigMask = sigmask;
    h->mh_Flags   = 1;
    h->mh_Volume  = 100;
    h->mh_Params[0]=h->mh_Params[1]=h->mh_Params[2]=
    h->mh_Params[3]=h->mh_Params[4]=h->mh_Params[5]=50;
    g_MiscBase = OpenLib("misc.resource");
    if (!g_MiscBase) goto fail;
    if (!(g_Owner = (APTR)AllocMiscResource(MR_PARBITS,
                        (UBYTE *)"MHI_MAS_Player_Pro"))) {
        if (!(g_Owner = (APTR)AllocMiscResource(MR_PARALLOCS,
                        (UBYTE *)"MHI_MAS_Player_Pro")))
            goto fail;
    }
    g_MhiAllocated = 1;
    return h;
fail:
    __FreeMem_base(*(void **)4, h, 0x10019);
    CloseLib(g_MiscBase); CloseLib(g_GfxBase);
    return NULL;
}

/* -36: tear down: free buffer ring, drain queue list, release
   misc.resource units, close gfx, clear the allocated latch. */
void MHIFreeDecoder(APTR h __asm("a0"))
{
    struct MinNode *n;
    if (!h) return;
    __FreeMem_base(*(void **)4, h, 0x10019);
    FreeMiscResource(MR_PARBITS);
    FreeMiscResource(MR_PARALLOCS);
    while ((n = (struct MinNode *)__RemHead_base(*(void **)4, (struct List *)&g_BufList)))
        __FreeMem_base(*(void **)4, n, 20);
    g_MhiAllocated = 0;
    CloseLib(g_GfxBase);
}

/* -42: queue a data buffer (20-byte node) for playback */
LONG MHIQueueBuffer(APTR h __asm("a0"), APTR buf __asm("a1"),
                    ULONG size __asm("d0"))
{
    struct MinNode *n = (struct MinNode *)__AllocMem_base(*(void **)4, 20, MEMF_PUBLIC);
    if (!n) return -1;
    *(APTR *)(n + 1)      = buf;
    *(ULONG *)((char *)n + 12) = size;
    __AddTail_base(*(void **)4, (struct List *)&g_BufList, (struct Node *)n);
    return 0;
}

/* -48: pop a finished buffer node */
APTR MHIGetEmpty(APTR h __asm("a0"))
{
    return __RemHead_base(*(void **)4, (struct List *)&g_BufList);
}

/* -54: copy driver status into caller's struct */
void MHIGetStatus(APTR h __asm("a0"), APTR st __asm("a1"))
{
    __CopyMem_base(*(void **)4, h, st, 25);
}

/* -60: start playback - CIA-B strobe/parallel enable */
void MHIPlay(APTR h __asm("a0"))  { CIAA_PRB |= 0x10; }
/* -66: stop playback - release port bits */
void MHIStop(APTR h __asm("a0"))  { CIAA_PRB &= ~0x10; }
/* -72: pause - deassert without releasing */
void MHIPause(APTR h __asm("a0")) { CIAA_PRB &= ~0x10; }

/* -78: capability query */
ULONG MHIQuery(ULONG q __asm("d0")) { return 0x1f; }
/* -84: set decoder parameter (param, value) */
LONG MHISetParam(APTR h __asm("a0"), ULONG p __asm("d0"),
                 ULONG v __asm("d1"))
{
    if (p < 6) ((struct MhiDecoder *)h)->mh_Params[p] = (UBYTE)v;
    return 0;
}
