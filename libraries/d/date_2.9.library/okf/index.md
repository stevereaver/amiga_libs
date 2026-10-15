---
type: Library
title: date_2.9.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:09.999846Z
---

# date_2.9.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[5c]='date.library' idstr[6c]='date.library 2.9 (27.12.95)' init=1e endskip=9d
  inittab: datasize=22 functab@88 datatab@2e initfunc=224c
  functab: 3 vectors (abs-long)
    LVO -6   -> 227c
    LVO -12  -> 22a2
    LVO -18  -> 22c2

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
