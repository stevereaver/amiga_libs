---
type: Function
title: SPSinh
description: FFP hyperbolic sine; exponential-based kernel, LVO -60.
---

# SPSinh — LVO -60

`float SPSinh(d0 parm)` — FFP arg, FFP result.

Built on the shared `_exp_dbl` engine: for large |x|,
sinh(x) = sign(x)*(e^|x|/2); near zero a minimax
polynomial in x^2 is used instead (avoids the
e^x - e^-x cancellation).
