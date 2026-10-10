---
type: Library
title: iffparse.library 40.1 (WB3.1)
description: >-
  Complete reverse engineering of the Workbench 3.1 iffparse.library
  ($VER: iffparse 40.1 (9.2.93), 6832 bytes, 2 hunks).
timestamp: 2026-10-10T18:00:00Z
---

# iffparse.library 40.1 (WB3.1)

IFF FORM/chunk parser shipped with Workbench 3.1.  Small library:
0x1974 bytes of code, 0x8c bytes of data, 45 vectors (4 system +
41 API, including the reserved LVO -96 slot).

## Status

Fully disassembled and reconstructed in C.  The reconstruction in
`source/` builds with m68k-amigaos-gcc 16.2 into a loadable HUNK
`.library` whose vector table, RomTag, autoinit data and `.data`
hook block all match the original layout.  Code size and register
allocation differ (different compiler); semantics were verified
function-by-function against the disassembly.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -270)
- [structures/](structures/index.md) — library base, hunk map,
  autoinit table, internal structs
- [findings/](findings/index.md) — quirks, deviations, corrected
  mis-reads, open questions
- [log.md](log.md) — chronological work log

## Key files

- `binary/iffparse_40.1(WB3.1).library` — shipped binary (gitignored)
- `iffparse_40.1(WB3.1).asm` — IRA disassembly (annotated)
- `work/objdump.txt` — raw objdump of both hunks
- `source/` — C reconstruction + build machinery
