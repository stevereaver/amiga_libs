---
type: Library
title: version.library 45.1 (WB3.9)
description: Workbench 3.5 version stub -- no public LVOs, but LibInit plants a hidden semaphore-probe routine in the extended library base.
tags: [version, wb3.5, stub-library]
---

# version.library 45.1 (WB3.9) — Knowledge Bundle

## Overview

`version_45.1(WB3.9).library`, 352 bytes, single code hunk
(0x110 bytes), sha256
`d3d1cf6f1787949de55f65e6a9aeedd65ed9cdbbed5ed8639ff838a0485847ec`.
ID string: `version 45.1 (13.11.2000)\r\n`.

version.library exports **no** public functions -- the AUTOINIT
function table contains only the four system vectors
(Open/Close/Expunge/ExtFunc), and Expunge/ExtFunc share one
`moveq #0,d0 / rts` stub.

New versus the 39/40.x builds: the library base grew to 0x36 bytes
(self-pointer, hardcoded date `0x11081999`, function pointer) and
the code hunk contains a **hidden routine** (not in the vector
table) that XOR-deobfuscates a semaphore name and calls exec
`FindSemaphore`.  See
[findings/HiddenSemaphoreCheck](findings/HiddenSemaphoreCheck.md).

Status: **FULL** -- all four LVOs plus the hidden routine
reconstructed, `source/` rebuilds a working .library.

## Categories

- [functions/](functions/index.md) — the four LVO entries + hidden probe
- [structures/](structures/index.md) — VersionBase layout, InitTable, hunk map
- [algorithms/](algorithms/index.md) — the XOR obfuscation of the semaphore name
- [findings/](findings/index.md) — quirks and reconstruction notes
- [log.md](log.md) — work journal
