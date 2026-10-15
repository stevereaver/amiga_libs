---
type: Library
title: diskfont_36.66(WB2.04).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:57.751285Z
---

# diskfont_36.66(WB2.04).library

## Structure scan

```
romtag@4 flags=84 ver=36 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 36.66 (10.6.91)\r\n' init=ac endskip=4a
  inittab: datasize=4c functab@1d0 datatab@1b4 initfunc=bc
  functab: 9 vectors (abs-long)
    LVO -6   -> 02b8
    LVO -12  -> 02c6
    LVO -18  -> 01f8
    LVO -24  -> 02ac
    LVO -30  -> 19ec
    LVO -36  -> 0bf2
    LVO -42  -> 1070
    LVO -48  -> 1410
    LVO -54  -> 02dc

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
