---
type: Library
title: krsnake_1.012.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:06.790945Z
---

# krsnake_1.012.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[24e]='krsnake.library' idstr[25e]='$VER: krsnake.library 1.012 (16 Nov 1995)' init=1e endskip=146
  inittab: datasize=430 functab@1ed0 datatab@2e initfunc=4e
  functab: 22 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 1f52
    LVO -36  -> 1f64
    LVO -42  -> 1f7a
    LVO -48  -> 1f8c
    LVO -54  -> 1fa2
    LVO -60  -> 1fbc
    LVO -66  -> 1fd2
    LVO -72  -> 1fec
    LVO -78  -> 2002
    LVO -84  -> 2014
    LVO -90  -> 202a
    LVO -96  -> 2040
    LVO -102 -> 2056
    LVO -108 -> 206c
    LVO -114 -> 2082
    LVO -120 -> 2098
    LVO -126 -> 20b0
    LVO -132 -> 20c6

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
