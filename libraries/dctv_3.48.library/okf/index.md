---
type: Library
title: dctv_3.48.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:03.809791Z
---

# dctv_3.48.library

## Structure scan

```
romtag@5a flags=80 ver=3 type=9 pri=0
  name[4]='dctv.library' idstr[11]='dctv.library 3.48 (30.9.92)\r\n' init=74 endskip=3e2c
  inittab: datasize=2e functab@a4 datatab@84 initfunc=dc
  functab: 13 vectors (abs-long)
    LVO -6   -> 0102
    LVO -12  -> 0110
    LVO -18  -> 0120
    LVO -24  -> 016e
    LVO -30  -> 079e
    LVO -36  -> 0724
    LVO -42  -> 0bde
    LVO -48  -> 128a
    LVO -54  -> 1c86
    LVO -60  -> 0c1e
    LVO -66  -> 0872
    LVO -72  -> 1df6
    LVO -78  -> 1e7c

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
