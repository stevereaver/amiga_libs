---
type: Function
title: LibNull
description: Shared stub for the reserved vector and unimplemented XPK slots.
lvo: -24, -42, -48, -60
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
APTR LibNull(void);
```

# Semantics

`moveq #0,d0 / rts`. One stub address fills four table entries: the
reserved vector (-24) and the unimplemented XPK slots XpksPackFree
(-42), XpksPackReset (-48), XpksUnpackFree (-60). It is also the
dead-code hook called by `_LibInit` (see
[InitStubCall](../findings/InitStubCall.md)).
