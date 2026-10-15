---
type: Function
title: IEEESPCosh
description: hyperbolic cosine of x — single-instruction 68881 stub.
lvo: -66
registers: d0 x (IEEE single) -> d0 result
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPCosh(float x)``

**LVO -66**

```asm
fcoshs    d0, fp0
fmoves  fp0, d0
rts
```

One-instruction 68881 body: the argument arrives in d0 (IEEE
single), is evaluated in fp0, and the single-precision result
leaves in d0.  No frame, no other registers touched.
