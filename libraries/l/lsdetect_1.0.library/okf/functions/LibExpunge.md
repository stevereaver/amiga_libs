---
type: Function
title: LibExpunge
description: Defer while open, else unlink/close libs/free.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T20:40:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

If `lib_OpenCnt` nonzero: `bset #3,34(a5)` (private flag, not
`lib_Flags`), return 0.  Else open-coded `Remove`, conditional
`CloseLibrary` of locale/dos/lowlevel/graphics (in that order),
`FreeMem`, return seglist (base+64).
