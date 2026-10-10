---
type: Function
title: LibClose
description: Decrements lib_OpenCnt; falls through to Expunge when deferred.
lvo: -12
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
LONG LibClose(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`subq.w #1,lib_OpenCnt`; nonzero → branch to the shared
`moveq #0/rts` stub at .text+0x12e. Zero → `btst #3,lib_Flags`; clear →
return 0; set → falls through into [LibExpunge](LibExpunge.md) at
.text+0xf8. .text+0xea.
