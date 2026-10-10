---
type: Function
title: LibClose
description: Decrements OpenCnt; expunges only at 0 with DELEXP set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T21:55:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

`lib_OpenCnt--`; non-zero → return 0.  At zero it tests
`LIBF_DELEXP`: only when set does it run the expunge tail —
inlined `Remove()` (`ln_Pred->ln_Succ`/`ln_Succ->ln_Pred` swaps),
`FreeMem(base-NegSize, NegSize+PosSize)` via SysBase (jsr -210),
returns the seglist BPTR in d0.

This is the textbook variant: the 39/40.x line expunged
unconditionally at count 0 with no DELEXP test.
