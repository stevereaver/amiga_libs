---
type: Function
title: LibClose
description: System vector -12; aliases the shared null stub.
lvo: -12
registers: a6 = library base (per convention; never used)
timestamp: 2026-10-10T18:00:00Z
---

# `LONG LibClose(void)`

**LVO -12** — registers `-`

Function-table entry 2 → code+0x66.  Returns 0; does not decrement
`lib_OpenCnt` and never expunges.  Semantics identical to
[LibNull](LibNull.md).
