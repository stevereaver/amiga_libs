---
type: Library
title: identify_8.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:28.187942Z
---

# identify_8.2.library

## Structure scan

```
romtag@4 flags=80 ver=8 type=9 pri=0
  name[1e]='identify.library' idstr[2f]='identify.library 8.2 (4.12.97)\r\n' init=a8 endskip=2674
  inittab: datasize=2c functab@b8 datatab@e4 initfunc=104
  functab: 10 vectors (abs-long)
    LVO -6   -> 01e6
    LVO -12  -> 01f4
    LVO -18  -> 020e
    LVO -24  -> 0298
    LVO -30  -> 0302
    LVO -36  -> 0d4c
    LVO -42  -> 09c0
    LVO -48  -> 1e3e
    LVO -54  -> 0c1c
    LVO -60  -> 11f6

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
