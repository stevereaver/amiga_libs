/*
 * mhimasstd.library 1.5 - MHI driver for parallel-port MAS decoder
 * ("MHI_MAS_Player_Pro").  SAS/C build: strings+code hunk, DATA
 * hunk holds RomTag/InitTable/FuncTab, BSS for bases.
 */
#ifndef MHIBASE_H
#define MHIBASE_H

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <proto/exec.h>

struct MhiBase {
    struct Library mb_Lib;
    APTR  mb_SegList;           /* 0x22 */
};

/* decoder handle (AllocMem'd, ~64KB ring + header) */
struct MhiDecoder {
    UBYTE  mh_pad0[8];
    APTR   mh_Task;             /* +8  signal task (a0 arg)     */
    ULONG  mh_SigMask;          /* +12 d0 arg                  */
    UBYTE  mh_pad16[1];
    UBYTE  mh_Flags;            /* +16 byte = 1 at alloc       */
    UBYTE  mh_pad17;
    UBYTE  mh_Volume;           /* +18 = 100 default           */
    UBYTE  mh_Params[6];        /* +19..+24 = 50 defaults       */
    /* 64KB data ring follows */
};

/* misc.resource units claimed: parallel port bits+alloc */
#define MR_PARBITS   2
#define MR_PARALLOCS 3

extern struct Library *g_DosBase, *g_GfxBase, *g_MiscBase, *g_MhiBase;
extern struct MinList g_BufList;   /* queued 20-byte buffer nodes */
extern WORD  g_MhiAllocated;
extern APTR  g_Owner;

#endif
