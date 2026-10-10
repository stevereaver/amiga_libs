---
type: Function
title: SPAtan
description: FFP arctangent; double-precision rational kernel, LVO -30.
---

# SPAtan — LVO -30

`float SPAtan(d0 parm)` — FFP arg, FFP result.

Software kernel: FFP->double via SPTieee, then a
double-precision rational/polynomial atan:

- |x| >= huge: result ±pi/2.
- |x| > 1: identity atan(x) = pi/2 - atan(1/x).
- mid ranges: argument preconditioning with the
  tan(pi/8)-style reduction.
- core: z = x*x; atan ~ x * P(z)/Q(z) with inline
  IEEE-64 coefficient immediates.
- sign restored from the original argument.
