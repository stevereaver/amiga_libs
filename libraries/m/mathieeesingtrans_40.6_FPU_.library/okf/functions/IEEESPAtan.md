---
type: Function
title: IEEESPAtan
description: arc tangent of x — single-instruction 68881 stub.
lvo: -30
registers: d0 x (IEEE single) -> d0 result
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPAtan(float x)``

**LVO -30**

```asm
fatans    d0, fp0
fmoves  fp0, d0
rts
```

One-instruction 68881 body: the argument arrives in d0 (IEEE
single), is evaluated in fp0, and the single-precision result
leaves in d0.  No frame, no other registers touched.
