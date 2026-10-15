---
type: Library
title: xpkmaster_4.33.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:55.284122Z
---

# xpkmaster_4.33.library

## Structure scan

```
romtag@84 flags=80 ver=4 type=9 pri=0
  name[100]='xpkmaster.library' idstr[112]='xpkmaster 4.33 (09.05.1998)\r\n' init=74 endskip=9e
  inittab: datasize=22 functab@4 datatab@54 initfunc=226
  functab: 19 vectors (abs-long)
    LVO -6   -> 014c
    LVO -12  -> 0134
    LVO -18  -> 015a
    LVO -24  -> 0130
    LVO -30  -> 0130
    LVO -36  -> 0b9a
    LVO -42  -> 034c
    LVO -48  -> 0a18
    LVO -54  -> 0b7e
    LVO -60  -> 0be4
    LVO -66  -> 0ea0
    LVO -72  -> 1100
    LVO -78  -> 1116
    LVO -84  -> 12d6
    LVO -90  -> 1ca6
    LVO -96  -> 1cc6
    LVO -102 -> 1614
    LVO -108 -> 1676
    LVO -114 -> 2a4c

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
