---
type: Function
title: SPTan
description: FFP tangent routine at LVO -48.
---

# SPTan — LVO -48

`float SPTan(d0 parm)` — FFP format arg, FFP result.

Wrapper around the 68881 single-precision op `ftans`:
the FFP argument in d0 is converted to IEEE single by the
shared SPTieee routine, `ftans d0,fp0` runs, and the shared
tail (`fmoves fp0,d0` + SPFieee) converts the result back to
FFP in d0.

LVO verified against `mathtrans_lib.fd` (bias 30).
