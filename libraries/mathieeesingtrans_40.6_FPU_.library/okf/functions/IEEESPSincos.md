---
type: Function
title: IEEESPSincos
description: Combined sine/cosine — sin in d0, cos stored through a0.
lvo: -54
registers: d0 x (IEEE single), a0 cosptr -> d0 sin(x)
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPSincos(float *cosptr, float x)``

**LVO -54**

```asm
fsincoss d0, fp1:fp0        ; fp1 = cos(x), fp0 = sin(x)
fmoves   fp0, d0            ; return value = sin
fmoves   fp1, (a0)          ; *cosptr = cos
rts
```

The only multi-value vector: `fsincoss` computes both results in
one pass; sine goes to d0 (the documented return) and cosine is
stored through the pointer in a0.
