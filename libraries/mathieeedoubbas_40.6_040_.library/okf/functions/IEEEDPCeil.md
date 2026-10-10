---
type: Function
title: IEEEDPCeil
description: ceil(x) = -floor(-x); sign not restored when result is zero.
lvo: -96
registers: d0/d1 -> d0/d1
timestamp: 2026-10-10T23:00:00Z
---

# ``double IEEEDPCeil(double x)``

**LVO -96**

`bchg #31,d0` (negate), `bsr IEEEDPFloor`, then `bchg #31,d0`
again — unless the floored result is all zeros, in which case the
flip is skipped so `+0` never becomes `-0`.
