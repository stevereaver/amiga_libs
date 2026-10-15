---
type: Function
title: XpksPackerInfo
description: Returns a pointer to the static XpkInfo descriptor.
lvo: -30
---

# Signature

```c
struct XpkInfo *XpksPackerInfo(struct XpkSubBase *base /* a6 */);
/* a0 result (copied to d0) */
```

# Semantics

`lea _xinfo(pc),a0; move.l a0,d0; rts` — returns the code-island
[XpkInfo](../structures/XpkInfo.md) at code+0x15a.
