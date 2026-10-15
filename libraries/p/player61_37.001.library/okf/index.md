---
type: Library
title: player61_37.001.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:54.381754Z
---

# player61_37.001.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[24e]='player61.library' idstr[25f]='$VER: player61.library 37.001 (25 Aug 1995) by Petter E. Stokke' init=1e endskip=146
  inittab: datasize=430 functab@1e1a datatab@2e initfunc=4e
  functab: 9 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 1e68
    LVO -36  -> 1e82
    LVO -42  -> 1e94
    LVO -48  -> 1eaa
    LVO -54  -> 1ec0

```

## Status

FULL - `source/` rebuilds byte-identical to `binary/` (verified by
fixup.py + cmp).  Per-vector C reference model: see source/ (or the
canonical API docs in okf/functions/).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [algorithms/](algorithms/index.md)
- [log.md](log.md)
