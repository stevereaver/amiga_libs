---
type: Function
title: LibOpen
description: Bump lib_OpenCnt, return base.
lvo: -6
registers: a6 base -> d0
timestamp: 2026-10-10T20:40:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`lib_OpenCnt++`, returns `a6`.  Does not touch the private flag.
