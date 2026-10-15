---
type: Function
title: GetG3Ptr112Field
description: Return the longword 2 bytes before *(g3+112).
lvo: -114
registers: -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``LONG GetG3Ptr112Field(void)``

**LVO -114**

`a1 = *(g3+112); d0 = *(a1 - 2)` — returns the longword stored
2 bytes before the pointer in context field +112.
