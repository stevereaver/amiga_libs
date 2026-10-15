---
type: Function
title: LibExpunge
description: Real expunge — DELEXP mark while open, else unlink and free.
lvo: -18
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T21:55:00Z
---

# ``BPTR LibExpunge(void)``

**LVO -18**

`tst.w lib_OpenCnt`: while open, `bset #3, lib_Flags`
(LIBF_DELEXP) and return 0.  With OpenCnt 0, fall into the shared
expunge tail (`movem.l d2/a5-a6` save, inlined `Remove()`,
`FreeMem`, return seglist in d2→d0).

Unlike the 39/40.x builds — where -18 was a null stub and Close
did all the work — this build has a functional Expunge again.
