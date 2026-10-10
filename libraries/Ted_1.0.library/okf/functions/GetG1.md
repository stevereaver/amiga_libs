---
type: Function
title: GetG1
description: Return the longword at *g1.
lvo: -42
registers: -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``LONG GetG1(void)``

**LVO -42**

`a0 = g1; d0 = *a0` — dereferences global 1 and returns the long
it points to.
