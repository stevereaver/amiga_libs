---
type: Function
title: SPAcos
description: FFP arccosine, LVO -120.
---

# SPAcos — LVO -120

`float SPAcos(d0 parm)` — FFP arg, FFP result.

Mirror of SPAsin: acos(x) = pi/2 - asin(x) semantics
via the same polynomial/sqrt machinery with the
complementary branch structure; |x| > 1 yields the
NaN pattern -> FFP error.
