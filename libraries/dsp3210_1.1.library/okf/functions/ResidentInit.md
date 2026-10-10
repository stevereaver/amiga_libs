---
type: Function
title: ResidentInit
description: rt_Init bootstrap for this non-AUTOINIT module.
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
ULONG ResidentInit(BPTR seglist);  /* a0 */
```

# Semantics

Called by exec's resident scan (rt_Init points at code, not an
AUTOINIT table — `rt_Flags` is 0):

```c
base = MakeLibrary(_functab, NULL, InitBase, 0x2a, seglist);  /* -84 */
if (base) { AddLibrary(base); return 1; }                     /* -396 */
return 0;
```

SysBase from `4.w`. The NULL structInit means no InitStruct data —
[InitBase](InitBase.md) fills the base fields manually.
