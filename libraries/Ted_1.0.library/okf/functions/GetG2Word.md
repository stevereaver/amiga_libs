---
type: Function
title: GetG2Word
description: Return the uword at *g2, zero-extended.
lvo: -48
registers: -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``ULONG GetG2Word(void)``

**LVO -48**

`a0 = g2; d0 = (UWORD)*a0` — returns the 16-bit value global 2
points to, zero-extended.
