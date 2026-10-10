---
type: Function
title: SPLog10
description: FFP base-10 logarithm routine at LVO -126.
---

# SPLog10 — LVO -126

`float SPLog10(d0 parm)` — FFP format arg, FFP result.

Wrapper around the 68881 single-precision op `flog10s`:
the FFP argument in d0 is converted to IEEE single by the
shared SPTieee routine, `flog10s d0,fp0` runs, and the shared
tail (`fmoves fp0,d0` + SPFieee) converts the result back to
FFP in d0.

LVO verified against `mathtrans_lib.fd` (bias 30).
