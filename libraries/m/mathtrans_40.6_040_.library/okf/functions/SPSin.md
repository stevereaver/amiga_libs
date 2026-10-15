---
type: Function
title: SPSin
description: FFP sine; quadrant reduction + polynomial, LVO -36.
---

# SPSin — LVO -36

`float SPSin(d0 parm)` — FFP arg, FFP result.

Software kernel: FFP->double, quadrant reduction
`j = floor(x * (4/pi))` mod 16 (constant
0x3ff45f306dc9c883 = 1.2732395447351628), Cody-Waite
style remainder `r = x - n*(pi/8)` computed in pieces,
then the `_sin_poly`/`_cos_poly` helpers selected by
octant (with flips for odd octants).  IEEE->FFP via
SPFieee.
