---
type: Function
title: XpksPackerInfo
description: Returns a pointer to the embedded XpkInfo descriptor.
lvo: -30
---

# Signature

```c
struct XpkInfo *XpksPackerInfo(struct XpkSubBase *base /* a6 */);
/* a0 result (copied to d0) */
```

# Semantics

`lea a6@(0x26),a0; move.l a0,d0; rts` — returns the embedded
[XpkInfo](../structures/XpkInfo.md) at base+0x26 (unlike 0.3 where it
is a code island).  The descriptor's `xi_ModeDesc` is linked to the
embedded XpkMode by LibInit.
