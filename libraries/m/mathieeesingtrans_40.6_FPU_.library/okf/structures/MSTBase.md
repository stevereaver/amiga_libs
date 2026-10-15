---
type: Structure
title: MSTBase
description: Private library base — 0x2c bytes with a private flag byte.
timestamp: 2026-10-10T22:30:00Z
---

# MSTBase

```c
struct MSTBase
{
    struct Library   mst_Lib;       /* 0x00 */
    struct ExecBase *mst_SysBase;   /* 0x22 -- a6 saved by init */
    BPTR             mst_SegList;   /* 0x26 -- a0 saved by init */
    UBYTE            mst_Flags;     /* 0x2a -- bit3 = DELEXP    */
    UBYTE            mst_pad;       /* 0x2b                     */
};                                  /* 0x2c                     */
```

Smaller than the 10.881 base (0x3c): no NoFPU fallback fields,
no seglist-in-code-hunk cell.  The DELEXP bit lives at +0x2a
rather than in `lib_Flags` — see [Quirks](../findings/Quirks.md).
