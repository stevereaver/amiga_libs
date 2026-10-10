---
type: Function
title: SPTanh
description: FFP hyperbolic tangent, LVO -72.
---

# SPTanh — LVO -72

`float SPTanh(d0 parm)` — FFP arg, FFP result.

For |x| large: ±1.  Mid range: tanh(x) =
(e^{2x}-1)/(e^{2x}+1) through the shared exponential
helper; near zero a polynomial/rational in x handles
the small-argument cancellation.
