---
type: Function
title: LibOpen
description: Bumps the private open count, returns the base.
lvo: -6
registers: a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`addq.w #1,34(a6)` (private count), returns `a6`.  exec's
`lib_OpenCnt` at +32 is never touched (it stays 0).
