---
type: Function
title: SetG3
description: Store the a0 context pointer in global g3.
lvo: -54
registers: a0 value
timestamp: 2026-10-10T20:20:00Z
---

# ``void SetG3(APTR ctx)``

**LVO -54**

`g3 = a0`.  g3 anchors an external structure used by vectors
-60..-120 as a method/field table (offsets +12, +100..+116).
