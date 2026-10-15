---
type: Function
title: SPAtan
description: FFP arctangent routine at LVO -30.
---

# SPAtan — LVO -30

`float SPAtan(d0 parm)` — FFP format arg, FFP result.

Wrapper around the 68881 single-precision op `fatans`:
the FFP argument in d0 is converted to IEEE single by the
shared SPTieee routine, `fatans d0,fp0` runs, and the shared
tail (`fmoves fp0,d0` + SPFieee) converts the result back to
FFP in d0.

LVO verified against `mathtrans_lib.fd` (bias 30).
