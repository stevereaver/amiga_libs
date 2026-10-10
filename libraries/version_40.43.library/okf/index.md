---
type: Library
title: version.library 40.43
description: version stub (post-3.1 rebuild, idstring date 07.2.11) -- no public LVOs, exists only to carry name/version/revision/idstring for tools such as the Version shell command.
tags: [version, stub-library]
---

# version.library 40.43 — Knowledge Bundle

## Overview

`version_40.43.library`, 272 bytes, single code hunk
(0xc0 bytes), sha256
`ffe8886ebb3da1adc5cf851abf704b4c4d6d48badca931d695216fcdce95700b`.
ID string: `version 40.43 (07.2.11)\r\n`.

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
