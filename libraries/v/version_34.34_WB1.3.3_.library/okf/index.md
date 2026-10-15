---
type: Library
title: version.library 34.34 (WB1.3.3)
description: >-
  Complete reverse engineering of version.library 34.34 (WB1.3.3)
  ($VER: versionlib 34.34 (05 OCT 1990), 392 bytes).
timestamp: 2026-10-10T19:00:00Z
---

# version.library 34.34 (WB1.3.3)

Commodore's version-tracking stub library: it exists so tools can
query a version/revision via the library node; it exports no user
functions.  Single code hunk, 4 vectors (the standard Open, Close,
Expunge and a reserved null vector).

## Status

Fully disassembled and reconstructed.  `source/` builds with
m68k-amigaos-gcc into a loadable HUNK `.library`; RomTag, strings,
InitTable, function table and InitStruct data are byte-identical to
the shipped binary (sha256 `844df9bb92c2c585…`).  Only build with a 'moveq #-1,d0' module-entry instruction; first build with compact InitStruct command bytes.

## Contents

- [functions/](functions/index.md) — the four LVO vectors
- [structures/](structures/index.md) — VersionBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and rebuild deviations
- [log.md](log.md) — work journal

## Key files

- `binary/` — shipped binary (gitignored)
- `work/` — IRA disassembly + objdump (gitignored)
- `source/` — reconstruction + Makefile
