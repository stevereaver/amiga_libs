---
type: Function
title: LibClose
description: Decrements the private count; at zero the library unloads itself.
lvo: -12
registers: a6 base
timestamp: 2026-10-10T19:00:00Z
---

# ``BPTR LibClose(void)``

**LVO -12** — `a6` = library base

`subq.w #1,56(a6)`; if the result is non-zero returns 0.

At zero: `Remove()`s the library node, drains the client list with
`RemHead()` freeing every RegNode's name string and 20-byte node,
`FreeMem()`s `lib_NegSize + lib_PosSize` at `base - lib_NegSize`,
and returns the stored seglist (base+0x26).
