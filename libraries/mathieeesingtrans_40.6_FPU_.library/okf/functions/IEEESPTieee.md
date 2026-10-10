---
type: Function
title: IEEESPTieee
description: FFP→IEEE conversion — a bare rts in this IEEE-native build.
lvo: -102
registers: d0 -> d0 (unchanged)
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPTieee(float x)``

**LVO -102**

The fd promises a fast-float→IEEE-single conversion.  In this
IEEE-native build both Tieee and [Fieee](IEEESPFieee.md) point at
the same **bare `rts`** (literally the trailing rts of the
preceding vector): the input in d0 is returned untouched — an
identity conversion, which is the only meaningful behavior when
the library's format is already IEEE single.
