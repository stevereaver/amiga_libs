---
type: Structure
title: XpkSubBase
description: 0x26-byte library base — just Library plus the saved seglist.
timestamp: 2026-10-10T22:45:00Z
---

# XpkSubBase

```c
struct XpkSubBase
{
    struct Library xsb_Lib;     /* 0x00 */
    BPTR           xsb_SegList; /* 0x22 -- written by LibInit   */
};                              /* 0x26 == InitTable dataSize    */
```

No SysBase field: [LibExpunge](../functions/LibExpunge.md) reloads
SysBase from absolute `4.w` instead.
