---
type: Library
title: version.library 39.29 (WB3.0)
description: Workbench 3.0 version stub -- no public LVOs, exists only to carry name/version/revision/idstring for tools such as the Version shell command.
tags: [version, wb3.0, stub-library]
---

# version.library 39.29 (WB3.0) — Knowledge Bundle

## Overview

`version_39.29(WB3.0).library`, 272 bytes, single code hunk
(0xc0 bytes), sha256
`cb03ae35232cdb7a8f3f4d3c642908dee08c64aae1bc60748a548beb8d283bb6`.
ID string: `version 39.29 (2.9.92)\r\n`.

version.library exports **no** public functions -- the AUTOINIT
function table contains only the four system vectors
(Open/Close/Expunge/ExtFunc), and Expunge/ExtFunc share one
`moveq #0,d0 / rts` stub.  The library exists purely so that tools
can OpenLibrary("version.library") and read `lib_Version`,
`lib_Revision` and `lib_IdString`.

Status: **FULL** -- all four LVOs reconstructed, `source/` rebuilds
a working .library.

## Categories

- [functions/](functions/index.md) — the four LVO entries
- [structures/](structures/index.md) — VersionBase layout, InitTable, hunk map
- [algorithms/](algorithms/index.md) — none (stub library)
- [findings/](findings/index.md) — quirks and reconstruction notes
- [log.md](log.md) — work journal
