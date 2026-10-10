---
type: Algorithm
title: IEEESPPow sign fixup
description: exp(y*ln|x|) with sign restoration for negative base.
timestamp: 2026-10-10T22:30:00Z
---

# IEEESPPow sign fixup

`pow(x,y)` is implemented as `exp(y * ln|x|)`:

1. `x > 0` → straight to the core (`flogn`/`fmul`/`fetox`).
2. `x ≤ 0` → clear the sign bit (`bclr #31`), then require y
   integral: `fint(y) - y` tested with `fbne` — a non-integer
   exponent with negative base returns **0.0** (branch to the
   module entry), not NaN.
3. After computing `|x|**y`, `fmod(y, 2.0)` decides the result
   sign: y even → positive (already correct), y odd → `bset #31`
   restores the negative sign.
4. `x = 0` falls into the |x| path naturally: `ln(0) = -inf`,
   `y*-inf = -inf` (y>0), `exp(-inf) = 0` → returns ±0.

Edge cases vs IEEE semantics: negative base with non-integer y
returns 0.0 rather than NaN; x=0 with y<0 likewise flows through
the sign path.  See [IEEESPPow](../functions/IEEESPPow.md) for
the instruction listing.
