---
type: Function
title: LibClose
description: Decrements lib_OpenCnt; expunges when it reaches 0 with DELEXP set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T21:10:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

Decrements `lib_OpenCnt` (only when non-zero).  When the old count
was 0 or 1 and `LIBF_DELEXP` is set, performs the expunge:
`CloseLibs()`, `Remove(base)`, frees the base block
(`NegSize+PosSize` below/above the base pointer) and returns the
seglist.  Returns 0 otherwise.

Note the 45.1-style edge case: a `LibClose` on an already-zero
`lib_OpenCnt` with DELEXP set still expunges.
