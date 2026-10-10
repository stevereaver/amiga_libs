---
type: Finding
title: CloseLibrary(SysBase) on open failure
description: The relay tail's failure path branches into the close sequence with a6 = exec base.
timestamp: 2026-10-10T18:00:00Z
---

# CloseLibrary(SysBase) on open failure

When the inner `jsr (a0)` returns 0, the tail pops the saved
arguments, sets d0=0 and falls into the shared close sequence —
where `movea.l a6,a1 / jsr -414(a6)` is executed with a6 still
holding SysBase.  `CloseLibrary(exec.library)` decrements exec's
OpenCnt (it cannot be expunged, so harm is limited, but it is
clearly a bug — the intended target was the just-opened base, which
doesn't exist on this path).  Reproduced verbatim in
`source/asl_relay.s`.
