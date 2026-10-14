---
type: Library
title: version.library 37.67 (WB2.04)
description: >-
  Complete reverse engineering of version.library 37.67 (WB2.04)
  ($VER: version 37.67 (16.7.91), 384 bytes).
timestamp: 2026-10-10T19:00:00Z
---

# version.library 37.67 (WB2.04)

Commodore's version-tracking stub library: it exists so tools can
query a version/revision via the library node; it exports no user
functions.  Single code hunk, 4 vectors (the standard Open, Close,
Expunge and a reserved null vector).

## Status

Fully disassembled and reconstructed.  `source/version.s` +
`fixup.py` rebuild the binary **byte-identically**, including the
empty second CODE hunk record and original RELOC32 ordering
(`make`); the earlier C model remains under `make cmodel`.
machine68k oracle: InitStruct header fill, lifecycle vectors and
the lib+42 DELEXP bit all trace-identical to the original.

## Contents

- [functions/](functions/index.md) — the four LVO vectors
- [structures/](structures/index.md) — VersionBase, InitTable, hunk map
- [findings/](findings/index.md) — quirks and rebuild deviations
- [log.md](log.md) — work journal

## Key files

- `binary/` — shipped binary (gitignored)
- `work/` — IRA disassembly + objdump (gitignored)
- `source/` — reconstruction + Makefile
