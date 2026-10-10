---
type: Function
title: LibClose
description: Decrement count; expunge at zero when the private flag is set.
lvo: -12
registers: a6 base -> d0
timestamp: 2026-10-10T20:20:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

`lib_OpenCnt--`; when it reaches 0 and bit 3 of base+34 is set,
runs the expunge path; returns d0 (0 or the expunge result).
