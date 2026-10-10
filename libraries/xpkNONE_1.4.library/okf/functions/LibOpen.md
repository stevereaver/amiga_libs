---
type: Function
title: LibOpen
description: Clears LIBF_DELEXP, increments lib_OpenCnt, returns base.
lvo: -6
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
struct XpkSubBase *LibOpen(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`bclr #3,lib_Flags` then `addq.w #1,lib_OpenCnt` then return a6.
Standard skeleton (flag clear precedes the increment here; order is
immaterial).
