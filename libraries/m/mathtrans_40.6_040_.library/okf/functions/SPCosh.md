---
type: Function
title: SPCosh
description: FFP hyperbolic cosine; exponential-based kernel, LVO -66.
---

# SPCosh — LVO -66

`float SPCosh(d0 parm)` — FFP arg, FFP result.

cosh(x) = (e^x + e^-x)/2 via `_exp_dbl`; for large |x|
the e^-x term is dropped and the result is e^|x|/2.
