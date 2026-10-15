---
type: Library
title: diskfont_39.3(WB3.0).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:52.197599Z
---

# diskfont_39.3(WB3.0).library

## Structure scan

```
romtag@4 flags=84 ver=39 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 39.3 (14.7.92)\r\n' init=174 endskip=49
  inittab: datasize=86 functab@30c datatab@2e0 initfunc=184
  functab: 9 vectors (abs-long)
    LVO -6   -> 03f4
    LVO -12  -> 0402
    LVO -18  -> 0334
    LVO -24  -> 03e8
    LVO -30  -> 30a0
    LVO -36  -> 0d0c
    LVO -42  -> 145c
    LVO -48  -> 17ca
    LVO -54  -> 0418

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
