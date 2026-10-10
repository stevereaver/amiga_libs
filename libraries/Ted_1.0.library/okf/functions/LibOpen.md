---
type: Function
title: LibOpen
description: Bump lib_OpenCnt, clear private flag, return base.
lvo: -6
registers: a6 base -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`lib_OpenCnt++`; `bclr #3,34(a6)` — clears bit 3 of the *private*
byte at base+34 (not lib_Flags); returns `a6`.
