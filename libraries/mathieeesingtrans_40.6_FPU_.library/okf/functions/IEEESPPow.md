---
type: Function
title: IEEESPPow
description: exp(y*ln|x|) with sign restoration for negative base and odd-integer exponent.
lvo: -90
registers: d0 x, d1 y (IEEE singles) -> d0 x**y
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPPow(float y, float x)``

**LVO -90**

Not a one-instruction stub — the only real routine among the
math vectors:

```asm
tst.l   d0
bpl.s   core            ; x > 0: straight exp(y*ln x)
bclr    #31, d0         ; x = |x|
fints   d1, fp0         ; fp0 = int(y)
fsubs   d1, fp0         ; fp0 = int(y) - y
fbne    module_entry    ; non-integer y -> return 0.0
bsr.s   core            ; d0 = |x|**y
fmoves  d1, fp0
fmods   #2.0, fp0       ; fmod(y, 2)
fbeq.s  done            ; y even -> keep positive
bset    #31, d0         ; y odd  -> restore sign
done:   rts
core:
flogns  d0, fp0         ; ln |x|
fmuls   d1, fp0         ; y * ln|x|
fetoxx  fp0, fp0        ; exp()
fmoves  fp0, d0
rts
```

Notes:

- x ≤ 0 goes through the |x| path; x = 0 yields ±0 as
  logn(0) → −inf → exp(−inf) = 0.
- y non-integer with x < 0 → **returns 0.0** by branching to the
  module entry `moveq #0,d0; rts`, not a NaN.
- y must be integral for a negative result — `fmod(y,2)` picks
  the sign.
- Both FPU branches use word displacements (f28e/f281 forms).
