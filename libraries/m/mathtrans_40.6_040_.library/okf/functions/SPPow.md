---
type: Function
title: SPPow
description: FFP power function, LVO -90.
---

# SPPow — LVO -90

`float SPPow(d1 power, d0 parm)` — FFP base in d0, FFP
exponent in d1, FFP result in d0.

General path: exp(y*log(x)) through the shared
`_log_core`/`_exp_dbl` machinery, with sign handling
for negative bases.  A dedicated `_pow_int` fast path
detects integral exponents and multiplies by repeated
squaring — notable for a nonstandard `mulul` extension
word (0x4c05 0x1001) emitted verbatim in the
reconstruction.
