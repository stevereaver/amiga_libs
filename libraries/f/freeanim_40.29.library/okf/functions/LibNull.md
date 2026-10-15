---
type: Function
title: LibNull (shared stub)
description: Single `moveq #0,d0 / rts` routine used by every vector and the init routine.
lvo: -6 -12 -18 -24
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# `LONG LibNull(void)`

**code+0x66** — registers `-`

The only executable code in the library besides the resident entry.
Returns 0 in d0.  Reached by all four function-table entries and also
installed as the InitTable init routine.

Because the init routine returns 0, `MakeLibrary`/`InitResident`
reports failure: this binary cannot be installed as a real library by
exec.  See [findings/InitReturnsZero](../findings/InitReturnsZero.md).
