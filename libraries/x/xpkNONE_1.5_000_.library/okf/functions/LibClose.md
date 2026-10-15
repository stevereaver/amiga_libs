---
type: Function
title: LibClose
description: Decrements lib_OpenCnt; falls through to Expunge when deferred.
lvo: -12
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
LONG LibClose(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`subq.w #1,lib_OpenCnt`; nonzero → branch to the shared `moveq #0/rts`
entry stub. Zero → `btst #3,lib_Flags` (LIBF_DELEXP); clear → same
return-0 branch; set → falls through into
[LibExpunge](LibExpunge.md) at .text+0xd2 (no call, just fallthrough).
.text+0xc0.
