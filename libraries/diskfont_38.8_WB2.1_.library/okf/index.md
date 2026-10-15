---
type: Library
title: diskfont_38.8(WB2.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:49.744406Z
---

# diskfont_38.8(WB2.1).library

## Structure scan

```
romtag@4 flags=84 ver=38 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 38.8 (26.3.92)\r\n' init=108 endskip=49
  inittab: datasize=86 functab@2a0 datatab@274 initfunc=118
  functab: 9 vectors (abs-long)
    LVO -6   -> 0388
    LVO -12  -> 0396
    LVO -18  -> 02c8
    LVO -24  -> 037c
    LVO -30  -> 2fb6
    LVO -36  -> 0ca4
    LVO -42  -> 13f0
    LVO -48  -> 175a
    LVO -54  -> 03ac

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
