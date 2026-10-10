---
type: Library
title: version.library 1.1 (WB1.1)
description: >-
  Complete reverse engineering of version.library 1.1 (WB1.1)
  ($VER: mylib 1.1 (04 Nov 1985), 392 bytes).
timestamp: 2026-10-10T19:00:00Z
---

# version.library 1.1 (WB1.1)

Commodore's version-tracking stub library: it exists so tools can
query a version/revision via the library node; it exports no user
functions.  Single code hunk, 4 vectors (the standard Open, Close,
Expunge and a reserved null vector).

## Status

Fully disassembled and reconstructed.  `source/` builds with
m68k-amigaos-gcc into a loadable HUNK `.library`; RomTag, strings,
InitTable, function table and InitStruct data are byte-identical to
the shipped binary (sha256 `f8d9d1663fe5ef1f…`).  Expunge is buggy (Remove via a0, longword NegSize math); InitStruct has a dead byte-write at offset 0x0c.

## Contents

- [functions/](functions/index.md) — the four LVO vectors
- [structures/](structures/index.md) — VersionBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and rebuild deviations
- [log.md](log.md) — work journal

## Key files

- `binary/` — shipped binary (gitignored)
- `work/` — IRA disassembly + objdump (gitignored)
- `source/` — reconstruction + Makefile
