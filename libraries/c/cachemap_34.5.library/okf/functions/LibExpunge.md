---
type: Function
title: LibExpunge
description: Frees plane buffers of unlocked nodes, unloads when the count is 0.
lvo: -18
registers: a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

`Forbid()`; walks the node list (base+48): for every node whose
lock word (+16) is 0, each non-NULL plane buffer is `FreeMem()`ed
and its slot cleared (the *node block is not* freed).  `Permit()`.

If the private count (+34) is non-zero returns 0.  Otherwise the
standard teardown: `Remove()`, `FreeMem(base - NegSize,
NegSize+PosSize)`, return seglist.
