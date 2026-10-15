/*
 * xpkRLEN.library 1.1 reconstruction - shared declarations
 *
 * Two-hunk Aztec-style build: CODE + DATA.  The DATA hunk holds an
 * InitTable, the "$VER: RLEN 1.1" string and a 256-byte XpkInfo /
 * XpkMode template that the init function copies to base+0x3a and
 * pointer-fixes via an embedded offset table (data+0x100).
 */
#ifndef XPKBASE_H
#define XPKBASE_H

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>

struct XpkSubParams {              /* codec argument block (a0) */
    APTR   xsp_InBuf;              /* 0x00 */
    ULONG  xsp_InLen;              /* 0x04 */
    APTR   xsp_OutBuf;             /* 0x08 */
    ULONG  xsp_OutBufLen;          /* 0x0c */
    ULONG  xsp_OutLen;             /* 0x10 result bytes */
    ULONG  xsp_Flags;
    ULONG  xsp_Number;
    ULONG  xsp_Mode;
    STRPTR xsp_Password;
    UWORD  xsp_LibVersion;
    UWORD  xsp_Pad;
    ULONG  xsp_Arg[3];
    ULONG  xsp_Sub[4];
};

struct XpkSubBase {
    struct Library xb_Lib;         /* 0x00 */
    ULONG xb_SegList;              /* 0x22 stored by init */
    ULONG  xb_Res0;                /* 0x26 */
    ULONG  xb_OpenCnt;             /* 0x2a? - open uses +32  */
    /* ... the copied data template lives at +0x3a */
};

/* LVO -30: returns the relocated XpkInfo inside the copied template */
#define XPKINFO_OFF  (0x3a + 0xa6)   /* base + 0xe0 */

#endif
