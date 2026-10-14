---
type: Library
title: version.library 45.5
description: Workbench 3.5 version stub -- no public LVOs, but LibInit plants a hidden semaphore-probe routine in the extended library base.
tags: [version, wb3.5, stub-library]
---

# version.library 45.5 — Knowledge Bundle

## Overview

`version_45.5.library`, 352 bytes, single code hunk
(0x110 bytes), sha256
`1640a650cb7480344b301fbbbe14ee7d7d1bfd385d23af3ef689ec841bcf6267`.
ID string: `version 45.5 (25.4.2010)\r\n`.

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
reconstructed; `source/version.s` rebuilds **byte-identically**
(`make`); earlier C model retained under `make cmodel`.
machine68k oracle trace identical to original.

## Categories

- [functions/](functions/index.md) — the four LVO entries + hidden probe
- [structures/](structures/index.md) — VersionBase layout, InitTable, hunk map
- [algorithms/](algorithms/index.md) — the XOR obfuscation of the semaphore name
- [findings/](findings/index.md) — quirks and reconstruction notes
- [log.md](log.md) — work journal
