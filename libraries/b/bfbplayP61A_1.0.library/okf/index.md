---
type: Library
title: bfbplayP61A_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:01.780396Z
---

# bfbplayP61A_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayP61A.library' idstr[32]='bfbplayP61A.library V1.0 (07.07.1996)\r\n' init=dc endskip=2368
  inittab: datasize=b2 functab@ec datatab@128 initfunc=148
  functab: 14 vectors (abs-long)
    LVO -6   -> 016a
    LVO -12  -> 0178
    LVO -18  -> 018c
    LVO -24  -> 01d2
    LVO -30  -> 01d6
    LVO -36  -> 04e6
    LVO -42  -> 0578
    LVO -48  -> 05e4
    LVO -54  -> 061e
    LVO -60  -> 0642
    LVO -66  -> 064e
    LVO -72  -> 065a
    LVO -78  -> 0666
    LVO -84  -> 0672

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
