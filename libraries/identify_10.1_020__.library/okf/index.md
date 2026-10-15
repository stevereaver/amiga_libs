---
type: Library
title: identify_10.1(020+).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:33.100408Z
---

# identify_10.1(020+).library

## Structure scan

```
romtag@4 flags=80 ver=10 type=9 pri=0
  name[1e]='identify.library' idstr[2f]='identify.library 10.1 (14.11.98)\r\n' init=ba endskip=2b0c
  inittab: datasize=2c functab@ca datatab@f6 initfunc=116
  functab: 10 vectors (abs-long)
    LVO -6   -> 01f8
    LVO -12  -> 0206
    LVO -18  -> 0220
    LVO -24  -> 02aa
    LVO -30  -> 0316
    LVO -36  -> 0dbe
    LVO -42  -> 0a2c
    LVO -48  -> 21fe
    LVO -54  -> 0c88
    LVO -60  -> 12be

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
