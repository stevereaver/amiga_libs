---
type: Library
title: cgxbootpic_41.7(020)(Bvision)(CGX3).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:05.400313Z
---

# cgxbootpic_41.7(020)(Bvision)(CGX3).library

## Structure scan

```
romtag@4 flags=80 ver=41 type=9 pri=0
  name[1e]='cgxbootpic.library' idstr[32]='cgxbootpic.library 41.7 (16.8.97) \r\n' init=ac endskip=8230
  inittab: datasize=52 functab@bc datatab@e8 initfunc=0
  functab: 1 vectors (abs-long)
    LVO -6   -> 0086

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
