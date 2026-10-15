---
type: Function
title: ModuleEntry
description: Reserved vector aliased to the module entry point.
lvo: -24
registers: -
timestamp: 2026-10-10T19:00:00Z
---

# ``void ModuleEntry(void)``

**LVO -24** — reserved

The fourth function-table entry points at file offset 0, the
non-resident-loader entry `clr.l d0 / rts`, not the usual
`moveq #0,d0` stub.  Effectively a reserved vector that returns 0.
