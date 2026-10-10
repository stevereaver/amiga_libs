---
type: Function
title: LibOpen
description: Increments lib_OpenCnt, clears LIBF_DELEXP, returns the library base.
lvo: -6
timestamp: 2026-10-10T19:15:00Z
---

# Signature

```c
struct FWFilterBase *LibOpen(struct FWFilterBase *base);  /* a6 -> d0 */
```

# Semantics

`addq.w #1,32(a6)` (lib_OpenCnt), `bclr #3,14(a6)` (lib_Flags &=
~LIBF_DELEXP), `move.l a6,d0` — standard library Open.
