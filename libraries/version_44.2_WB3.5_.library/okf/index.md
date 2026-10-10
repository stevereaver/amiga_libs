---
type: Library
title: version.library 44.2 (WB3.5)
description: Workbench 3.5 version stub -- no public LVOs, but LibInit plants a hidden semaphore-probe routine in the extended library base.
tags: [version, wb3.5, stub-library]
---

# version.library 44.2 (WB3.5) — Knowledge Bundle

## Overview

`version_44.2(WB3.5).library`, 348 bytes, single code hunk
(0x10c bytes), sha256
`86cd464a9b8beab7f365df3b6bf172bfe3a6db2e2e487eb60e3da015b56d603e`.
ID string: `version 44.2 (11.8.99)\r\n`.

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
