---
type: Library
title: dctv_1.31.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:12.046700Z
---

# dctv_1.31.library

## Structure scan

```
romtag@5a flags=80 ver=1 type=9 pri=0
  name[4]='dctv.library' idstr[11]='dctv.library 1.31 (8.4.91)\r\n' init=74 endskip=2700
  inittab: datasize=32 functab@a4 datatab@84 initfunc=d0
  functab: 10 vectors (abs-long)
    LVO -6   -> 0122
    LVO -12  -> 0130
    LVO -18  -> 0140
    LVO -24  -> 019c
    LVO -30  -> 04f6
    LVO -36  -> 0400
    LVO -42  -> 06f6
    LVO -48  -> 0d76
    LVO -54  -> 15f4
    LVO -60  -> 0796

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
