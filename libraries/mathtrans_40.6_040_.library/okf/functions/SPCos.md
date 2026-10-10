---
type: Function
title: SPCos
description: FFP cosine; quadrant reduction + polynomial, LVO -42.
---

# SPCos — LVO -42

`float SPCos(d0 parm)` — FFP arg, FFP result.

Same reduction machinery as SPSin (`floor(x*4/pi)`,
Cody-Waite remainder against pi/8) with the octant map
shifted for cosine; `_sin_poly`/`_cos_poly` selection
and sign flips handle the odd quadrants.
