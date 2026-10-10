---
type: Structure
title: MDBBase
description: 0x2c-byte private base — same shape as the 40.6 singtrans.
timestamp: 2026-10-10T23:00:00Z
---

# MDBBase

```c
struct MDBBase
{
    struct Library   mdb_Lib;       /* 0x00 */
    struct ExecBase *mdb_SysBase;   /* 0x22 -- a6 saved by init */
    BPTR             mdb_SegList;   /* 0x26 -- a0 saved by init */
    UBYTE            mdb_Flags;     /* 0x2a -- bit3 = DELEXP    */
    UBYTE            mdb_pad;       /* 0x2b                     */
};                                  /* 0x2c                     */
```

DELEXP lives in the private flag byte, not `lib_Flags` — see
[Quirks](../findings/Quirks.md).
