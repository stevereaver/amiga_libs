---
type: Function
title: SPSqrt
description: FFP square root, LVO -96.
---

# SPSqrt — LVO -96

`float SPSqrt(d0 parm)` — FFP arg, FFP result.

The one transcendental the 68040 FPU does keep:
FFP->IEEE single via SPTieee, `fsqrts d0,fp0`, then
IEEE->FFP via SPFieee — same shape as the FPU sibling
build.  Negative input produces the SPFieee error
convention.
