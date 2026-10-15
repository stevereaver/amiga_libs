---
type: Library
title: diskfont_45.3(WB3.9).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:10.478767Z
---

# diskfont_45.3(WB3.9).library

## Structure scan

```
romtag@4 flags=84 ver=45 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 45.3 (16.11.2000)\r\n' init=3750 endskip=4c
  inittab: datasize=5d4 functab@38de datatab@38b2 initfunc=3760
  functab: 11 vectors (abs-long)
    LVO -6   -> 39ca
    LVO -12  -> 39d8
    LVO -18  -> 390e
    LVO -24  -> 39ea
    LVO -30  -> 1a58
    LVO -36  -> 04f8
    LVO -42  -> 111c
    LVO -48  -> 1492
    LVO -54  -> 39f0
    LVO -60  -> 35c4
    LVO -66  -> 3642

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
