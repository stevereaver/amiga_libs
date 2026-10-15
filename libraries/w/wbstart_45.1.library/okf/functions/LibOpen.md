---
type: Function
title: LibOpen
description: Clear LIBF_DELEXP, bump lib_OpenCnt, return base.
lvo: -6
registers: a6 base -> d0
timestamp: 2026-10-10T20:00:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`lib_Flags &= ~LIBF_DELEXP` (`andi.b #$f7`), `lib_OpenCnt++`,
returns `a6`.
