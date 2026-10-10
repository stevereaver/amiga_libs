---
type: Function
title: SPSincos
description: FFP combined sine/cosine routine at LVO -54.
---

# SPSincos — LVO -54

`float SPSincos(d1 cosResult, d0 parm)` — parm is FFP; the
sine is returned in d0 (FFP) and the FFP cosine is stored
through the pointer in d1.

`fsincoss d0,fp0:fp1` yields cos in fp0, sin in fp1.  The
shipped code converts the IEEE cosine first (`fmoves fp0,d0`
+ SPFieee), stores it at `a0 = d1`, then converts the sine
from fp1 — so the register convention matches the fd's
`(cosResult,parm)(d1,d0)` exactly.
