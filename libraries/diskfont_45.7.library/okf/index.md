---
type: Library
title: diskfont_45.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:14.981718Z
---

# diskfont_45.7.library

## Structure scan

```
romtag@4 flags=84 ver=45 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 45.7 (26.1.2002)\r\n' init=38a0 endskip=4b
  inittab: datasize=5d4 functab@3a2e datatab@3a02 initfunc=38b0
  functab: 11 vectors (abs-long)
    LVO -6   -> 3b1a
    LVO -12  -> 3b28
    LVO -18  -> 3a5e
    LVO -24  -> 3b3a
    LVO -30  -> 1b94
    LVO -36  -> 050c
    LVO -42  -> 1258
    LVO -48  -> 15ce
    LVO -54  -> 3b40
    LVO -60  -> 3700
    LVO -66  -> 377e

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
