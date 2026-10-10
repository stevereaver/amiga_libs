---
type: Library
title: version.library 37.71 (WB2.05)
description: >-
  Complete reverse engineering of version.library 37.71 (WB2.05)
  ($VER: version 37.71 (9.1.92), 384 bytes).
timestamp: 2026-10-10T19:00:00Z
---

# version.library 37.71 (WB2.05)

Commodore's version-tracking stub library: it exists so tools can
query a version/revision via the library node; it exports no user
functions.  Single code hunk, 4 vectors (the standard Open, Close,
Expunge and a reserved null vector).

## Status

Fully disassembled and reconstructed.  `source/` builds with
m68k-amigaos-gcc into a loadable HUNK `.library`; RomTag, strings,
InitTable, function table and InitStruct data are byte-identical to
the shipped binary (sha256 `7aa6e88a38e95d70…`).

## Contents

- [functions/](functions/index.md) — the four LVO vectors
- [structures/](structures/index.md) — VersionBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and rebuild deviations
- [log.md](log.md) — work journal

## Key files

- `binary/` — shipped binary (gitignored)
- `work/` — IRA disassembly + objdump (gitignored)
- `source/` — reconstruction + Makefile
