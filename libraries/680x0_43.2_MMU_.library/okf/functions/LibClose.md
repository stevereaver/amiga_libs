---
type: Function
title: LibClose
description: Decrements OpenCnt when non-zero, always returns 0.
lvo: -12
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``LONG LibClose(void)``

**LVO -12** — registers `-`

If `lib_OpenCnt != 0` it is decremented.  Returns 0 -
this library never expunges itself from Close (see LibExpunge).
