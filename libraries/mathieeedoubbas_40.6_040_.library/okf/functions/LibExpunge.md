---
type: Function
title: LibExpunge
description: Mark-or-expunge against the private flag byte.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T23:00:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

Saves `d1-d2/a0-a1/a5-a6`, a5=base, a6=SysBase from base+0x22.
OpenCnt nonzero → `bset #3,0x2a(a5)`, return 0.  Else: seglist→d2,
`jsr -252(a6)` Remove, `FreeMem(base-NegSize, NegSize+PosSize)`
via -210, return seglist.  Identical tail to the 40.6 singtrans.
