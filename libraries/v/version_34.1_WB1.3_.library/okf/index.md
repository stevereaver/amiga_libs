---
type: Library
title: version.library 34.1 (WB1.3)
description: >-
  Complete reverse engineering of version.library 34.1 (WB1.3)
  ($VER: versionlib 34.1 (06 JUL 1988), 404 bytes).
timestamp: 2026-10-10T19:00:00Z
---

# version.library 34.1 (WB1.3)

Commodore's version-tracking stub library: it exists so tools can
query a version/revision via the library node; it exports no user
functions.  Single code hunk, 4 vectors (the standard Open, Close,
Expunge and a reserved null vector).

## Status

Fully disassembled and reconstructed.  `source/` builds with
m68k-amigaos-gcc into a loadable HUNK `.library`; RomTag, strings,
InitTable, function table and InitStruct data are byte-identical to
the shipped binary (sha256 `af29c17c4214aff6…`).  lib_Revision is 28; the only difference vs version_34.1.library (rev 32).

## Contents

- [functions/](functions/index.md) — the four LVO vectors
- [structures/](structures/index.md) — VersionBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and rebuild deviations
- [log.md](log.md) — work journal

## Key files

- `binary/` — shipped binary (gitignored)
- `work/` — IRA disassembly + objdump (gitignored)
- `source/` — reconstruction + Makefile
