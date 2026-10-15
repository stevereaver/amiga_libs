---
type: Function
title: GetG3Ptr116Field
description: Return the longword 2 bytes before *(g3+116).
lvo: -120
registers: -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``LONG GetG3Ptr116Field(void)``

**LVO -120**

`a1 = *(g3+116); d0 = *(a1 - 2)` — same shape as LVO -114 for
context field +116.
