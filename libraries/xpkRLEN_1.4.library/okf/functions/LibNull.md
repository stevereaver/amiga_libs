---
type: Function
title: LibNull
description: Shared return-0 stub for the reserved and unused vectors.
lvo: -24
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
LONG LibNull(void);  /* -> d0 */
```

# Semantics

`moveq #0,d0; rts` at .text+0x12e — a dedicated stub (the hunk entry
here returns -1, so unlike xpkNONE_1.5 it cannot double as the null
vector). Shared by LVO -24 (ExtFunc), -42 (XpksPackFree), -48
(XpksPackReset) and -60 (XpksUnpackFree). LibClose and the decoder
also branch here to return 0.
