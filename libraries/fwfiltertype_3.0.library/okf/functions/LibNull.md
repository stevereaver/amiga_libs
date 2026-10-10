---
type: Function
title: LibNull
description: Shared reserved-slot stub (ExtFunc/reserved), returns 0.
lvo: -24
timestamp: 2026-10-10T19:15:00Z
---

# Signature

```c
APTR LibNull(void);
```

# Semantics

`moveq #0,d0 / rts`. The same stub address fills both reserved slots:
LVO -24 (ExtFunc) and LVO -36 — so the function table has six entries
but only five distinct targets.
