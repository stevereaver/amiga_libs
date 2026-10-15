---
type: Library
title: ShowFile_1.11.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:57.397684Z
---

# ShowFile_1.11.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='ShowFile.library' idstr[2f]='ShowFile 1.11 (22.05.95) Copyright © 1995  Imdad Shah\r\n' init=74 endskip=2ea
  inittab: datasize=30 functab@84 datatab@a8 initfunc=c8
  functab: 8 vectors (abs-long)
    LVO -6   -> 0100
    LVO -12  -> 010e
    LVO -18  -> 0122
    LVO -24  -> 0168
    LVO -30  -> 016c
    LVO -36  -> 02ba
    LVO -42  -> 02c6
    LVO -48  -> 02d8

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
