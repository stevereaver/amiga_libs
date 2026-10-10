---
type: Structure
title: VersionBase
description: Private library base — 0x2a bytes, SysBase + seglist only.
timestamp: 2026-10-10T21:55:00Z
---

# VersionBase

```c
struct VersionBase
{
    struct Library   vb_Lib;        /* 0x00 */
    struct ExecBase *vb_SysBase;    /* 0x22 -- a6 saved by init */
    BPTR             vb_SegList;    /* 0x26 -- a0 saved by init */
};                                  /* 0x2a */
```

The compact base used by the 1.x–40.x line and kept for 47.x —
the 44.x/45.x builds expanded the base to 0x36 with a
self-pointer, a hardcoded build date and a hidden
semaphore-probe function pointer; none of that exists here.
