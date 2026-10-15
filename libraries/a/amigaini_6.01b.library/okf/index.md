---
type: Library
title: amigaini_6.01b.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:34.654621Z
---

# amigaini_6.01b.library

## Structure scan

```
romtag@4 flags=80 ver=6 type=9 pri=0
  name[254]='amigaini.library' idstr[265]='$VER: amigaini.library 6.01b (27.09.2001) INI lib for AmigaOS' init=1e endskip=146
  inittab: datasize=430 functab@2726 datatab@2e initfunc=4e
  functab: 34 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 27d8
    LVO -36  -> 27f0
    LVO -42  -> 2806
    LVO -48  -> 281c
    LVO -54  -> 2834
    LVO -60  -> 284c
    LVO -66  -> 2864
    LVO -72  -> 287e
    LVO -78  -> 2898
    LVO -84  -> 28b2
    LVO -90  -> 28cc
    LVO -96  -> 28e6
    LVO -102 -> 2900
    LVO -108 -> 291a
    LVO -114 -> 2934
    LVO -120 -> 294e
    LVO -126 -> 2964
    LVO -132 -> 297c
    LVO -138 -> 2992
    LVO -144 -> 29a8
    LVO -150 -> 29be
    LVO -156 -> 29d4
    LVO -162 -> 29ee
    LVO -168 -> 2a06
    LVO -174 -> 2a1e
    LVO -180 -> 2a34
    LVO -186 -> 2a4a
    LVO -192 -> 2a60
    LVO -198 -> 2a7a
    LVO -204 -> 2a94

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
