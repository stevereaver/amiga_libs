---
type: Function
title: LibClose
description: Decrement lib_OpenCnt; expunge when it hits zero with DELEXP set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T20:00:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

If the old count was 0 or becomes 0 and `LIBF_DELEXP` is set,
runs the expunge path (returns seglist), else returns 0.
