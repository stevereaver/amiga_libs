---
type: Library
title: version.library 40.42 (WB3.1)
description: Workbench 3.1 version stub -- no public LVOs, exists only to carry name/version/revision/idstring for tools such as the Version shell command.
tags: [version, wb3.1, stub-library]
---

# version.library 40.42 (WB3.1) — Knowledge Bundle

## Overview

`version_40.42(WB3.1).library`, 272 bytes, single code hunk
(0xc0 bytes), sha256
`b39739aab1efcda75be831b4fa2355eed2e726f427a2e55187a9dee3b44da9ee`.
ID string: `version 40.42 (18.2.94)\r\n`.

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
