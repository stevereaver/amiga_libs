---
type: Library
title: rexxreqtools_37.95.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:25.480034Z
---

# rexxreqtools_37.95.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='rexxreqtools.library' idstr[34]='rexxreqtools.library 37.95 (16.8.94)\r\n' init=5c endskip=cc
  inittab: datasize=96 functab@6c datatab@84 initfunc=cc
  functab: 5 vectors (abs-long)
    LVO -6   -> 00a8
    LVO -12  -> 00b6
    LVO -18  -> 08fc
    LVO -24  -> 00a4
    LVO -30  -> 0964

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
