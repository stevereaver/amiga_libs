/*
 * toshstart.library 1.0 - "Toshstart.Library" by Kevin McIntosh
 * Private base (InitTable dataSize 0x4c) - offsets as shipped.
 */
#ifndef TOSHBASE_H
#define TOSHBASE_H

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <proto/exec.h>

struct ToshBase {
    struct Library tb_Lib;      /* 0x00 */
    APTR  tb_SegList;           /* 0x22 */
    APTR  tb_SysBase2;          /* 0x26 - kept copy        */
    /* private state (the LAB_009x..LAB_00Bx cluster) */
    UWORD tb_wd28;              /* 0x28 */
    UBYTE tb_pad2a[14];
    APTR  tb_IOReq;             /* 0x38 IORequest block    */
    UBYTE tb_pad3c[4];
    APTR  tb_MiscA;             /* 0x40 */
    APTR  tb_MiscB;             /* 0x44 */
    UWORD tb_TickWord;          /* 0x48 polled by tickwait */
    UWORD tb_AllocFlag;         /* 0x4a AllocEntry state   */
};

#define CIAA_SDR  (*(volatile UBYTE *)0xBFEC01)
#define DMACONR   (*(volatile UWORD *)0xDFF002)
#define DMACON    (*(volatile UWORD *)0xDFF096)
#define COP1LCH   (*(volatile UWORD *)0xDFF080)

#endif
