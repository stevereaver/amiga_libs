---
type: Function
title: LibExpunge
description: Textbook mark-or-expunge; SysBase reloaded from 4.w.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T22:45:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

`tst.w lib_OpenCnt(a6)` nonzero → `bset #3,lib_Flags(a6)` (mark
DELEXP) and return 0.  Otherwise: push seglist (base+0x22), reload
SysBase from absolute `4.w` (the base has no SysBase field —
dataSize is only 0x26), `jsr -252(a6)` Remove, `FreeMem` of
base-NegSize over NegSize+PosSize via -210, return seglist.
