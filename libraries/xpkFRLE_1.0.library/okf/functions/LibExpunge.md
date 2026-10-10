---
type: Function
title: LibExpunge
description: Textbook expunge — deferred if open, else Remove + FreeMem.
lvo: -18
registers: a6 base -> d0 0 or seglist
---

# ``BPTR LibExpunge(void)``

**LVO -18**

If `lib_OpenCnt != 0`, sets `LIBF_DELEXP` and returns 0.
Otherwise saves the seglist (base+0x22), calls Exec Remove
(LVO -252) on the node and FreeMem (LVO -210) on
`base - lib_NegSize` of `NegSize + PosSize` bytes via the
absolute SysBase at 4.W.  Returns the saved seglist.
