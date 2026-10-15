---
type: Library
title: xpkmaster_5.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:06.724792Z
---

# xpkmaster_5.2.library

## Structure scan

```
romtag@84 flags=80 ver=5 type=9 pri=0
  name[100]='xpkmaster.library' idstr[112]='xpkmaster 5.2 (08.09.1999)\r\n' init=74 endskip=9e
  inittab: datasize=22 functab@4 datatab@54 initfunc=226
  functab: 19 vectors (abs-long)
    LVO -6   -> 014c
    LVO -12  -> 0134
    LVO -18  -> 015a
    LVO -24  -> 0130
    LVO -30  -> 0130
    LVO -36  -> 0bbc
    LVO -42  -> 034c
    LVO -48  -> 0a3a
    LVO -54  -> 0ba0
    LVO -60  -> 0c06
    LVO -66  -> 0ec8
    LVO -72  -> 3654
    LVO -78  -> 1130
    LVO -84  -> 1348
    LVO -90  -> 1e28
    LVO -96  -> 1e48
    LVO -102 -> 1696
    LVO -108 -> 16f8
    LVO -114 -> 2c00

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
