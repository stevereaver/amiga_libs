---
type: Library
title: diskfont_44.2(WB3.5).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:56.670957Z
---

# diskfont_44.2(WB3.5).library

## Structure scan

```
romtag@4 flags=84 ver=44 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 44.2 (7.9.99)\r\n' init=2be8 endskip=48
  inittab: datasize=86 functab@2d80 datatab@2d54 initfunc=2bf8
  functab: 9 vectors (abs-long)
    LVO -6   -> 2e62
    LVO -12  -> 2e70
    LVO -18  -> 2da8
    LVO -24  -> 2e82
    LVO -30  -> 10ec
    LVO -36  -> 02b6
    LVO -42  -> 0858
    LVO -48  -> 0b88
    LVO -54  -> 2e88

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
