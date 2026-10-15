---
type: Function
title: SPAsin
description: FFP arcsine, LVO -114.
---

# SPAsin — LVO -114

`float SPAsin(d0 parm)` — FFP arg, FFP result.

For |x| < 0.5 a direct minimax polynomial in x^2;
otherwise asin(x) = pi/2 - 2*asin(sqrt((1-x)/2))-style
transform using `fsqrts` for the square root (the
kernel calls into the SPSqrt machinery).  |x| > 1
returns the NaN pattern -> FFP error; sign is
preserved.
