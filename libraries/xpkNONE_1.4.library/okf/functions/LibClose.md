---
type: Function
title: LibClose
description: Decrements lib_OpenCnt; expunges if it reaches 0 with LIBF_DELEXP set.
lvo: -12
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
APTR LibClose(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

Standard skeleton: `subq.w #1,lib_OpenCnt`; on reaching zero with
LIBF_DELEXP set, calls [LibExpunge](LibExpunge.md) and returns its
result; otherwise returns NULL.
