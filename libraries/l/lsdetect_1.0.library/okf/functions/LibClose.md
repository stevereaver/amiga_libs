---
type: Function
title: LibClose
description: Decrement count; expunge at zero with private DELEXP flag.
lvo: -12
registers: a6 base -> d0
timestamp: 2026-10-10T20:40:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

`lib_OpenCnt--`; at zero with bit 3 of base+34 set, expunges.
