---
type: Function
title: LibOpen
description: Standard skeleton open.
lvo: -6
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
struct DSP3210Base *LibOpen(struct DSP3210Base *base);  /* a6 -> d0 */
```

# Semantics

`addq.w #1,lib_OpenCnt` / `bclr #3,lib_Flags` / return base.
