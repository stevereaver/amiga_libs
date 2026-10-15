---
type: Function
title: LibClose
description: Decrements OpenCnt; falls into Expunge at 0 with DELEXP set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T22:45:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

`subq.w #1,lib_OpenCnt(a6)`; nonzero → return 0 via the shared null
stub; else `btst #3,lib_Flags(a6)` — DELEXP clear → return 0, set →
falls through into [LibExpunge](LibExpunge.md).
