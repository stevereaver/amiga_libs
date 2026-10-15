---
type: Library
title: rawin_1.21.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:12.380784Z
---

# rawin_1.21.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[c4]='rawin.library' idstr[d4]='rawin.library 1.21 (2 January 1995)\n' init=1e endskip=1d48
  inittab: datasize=28 functab@2e datatab@96 initfunc=fc
  functab: 25 vectors (abs-long)
    LVO -6   -> 014c
    LVO -12  -> 015a
    LVO -18  -> 016e
    LVO -24  -> 01bc
    LVO -30  -> 022c
    LVO -36  -> 02fc
    LVO -42  -> 03a6
    LVO -48  -> 03ca
    LVO -54  -> 0492
    LVO -60  -> 051a
    LVO -66  -> 0e40
    LVO -72  -> 0e86
    LVO -78  -> 0f80
    LVO -84  -> 0fae
    LVO -90  -> 10be
    LVO -96  -> 1158
    LVO -102 -> 196c
    LVO -108 -> 18f0
    LVO -114 -> 17f8
    LVO -120 -> 19d6
    LVO -126 -> 1a60
    LVO -132 -> 1aea
    LVO -138 -> 1c2e
    LVO -144 -> 1cda
    LVO -150 -> 1d16

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
