---
type: Function
title: LibClose
description: Decrements lib_OpenCnt; expunges if it reaches 0 with LIBF_DELEXP set.
lvo: -12
timestamp: 2026-10-10T19:15:00Z
---

# Signature

```c
APTR LibClose(struct FWFilterBase *base);  /* a6 -> d0 */
```

# Semantics

`moveq #0,d0` then `subq.w #1,32(a6)`; if the count reaches 0 and bit 3
of lib_Flags (LIBF_DELEXP) is set, calls [LibExpunge](LibExpunge.md) and
returns its result; otherwise returns NULL. Standard skeleton.
