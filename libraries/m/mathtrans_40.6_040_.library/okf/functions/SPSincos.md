---
type: Function
title: SPSincos
description: FFP combined sine/cosine, LVO -54.
---

# SPSincos — LVO -54

`float SPSincos(d1 cosResult, d0 parm)` — FFP arg; sine
returned in d0, FFP cosine stored through the pointer in
d1 (fd signature `(cosResult,parm)(d1,d0)`).

Single quadrant reduction computes both the `_sin_poly`
and `_cos_poly` evaluations with octant-dependent
signs; cosine is converted and stored via `a1 = d1`.
