---
type: Function
title: LibExpunge
description: Close support libraries, unlink and free the base.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T20:00:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

While `lib_OpenCnt` is non-zero: sets `LIBF_DELEXP` and returns 0.
Otherwise closes workbench/dos/utility bases, `Remove()`s the
library node, `FreeMem`s NegSize+PosSize and returns the seglist
stored at base+36.
