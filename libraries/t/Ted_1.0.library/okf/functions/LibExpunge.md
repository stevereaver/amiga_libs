---
type: Function
title: LibExpunge
description: Set deferred-expunge flag or unlink/close/free the library.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T20:20:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

If `lib_OpenCnt` non-zero: `bset #3,34(a5)` (private deferred
flag), return 0.  Else: `Remove` the node, `CloseLibrary` the dos
base, `FreeMem(NegSize+PosSize)`, return seglist (base+44).
