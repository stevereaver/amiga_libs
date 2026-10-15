---
type: Function
title: IEEEDPNeg
description: Toggles the sign bit.
lvo: -60
registers: d0/d1 -> d0/d1
timestamp: 2026-10-10T23:00:00Z
---

# ``double IEEEDPNeg(double x)``

**LVO -60**

`bchg #31,d0; rts` — produces -0.0 for +0.0 input.
