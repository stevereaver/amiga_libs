---
type: Library
title: amigaini_1.01b.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:06.880855Z
---

# amigaini_1.01b.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[254]='amigaini.library' idstr[265]='$VER: amigaini.library 1.01b (11.08.2001) INI lib for AmigaOS' init=1e endskip=146
  inittab: datasize=430 functab@1b52 datatab@2e initfunc=4e
  functab: 21 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 1bd0
    LVO -36  -> 1be6
    LVO -42  -> 1bfc
    LVO -48  -> 1c12
    LVO -54  -> 1c28
    LVO -60  -> 1c3e
    LVO -66  -> 1c56
    LVO -72  -> 1c6e
    LVO -78  -> 1c86
    LVO -84  -> 1c9e
    LVO -90  -> 1cb4
    LVO -96  -> 1cca
    LVO -102 -> 1ce4
    LVO -108 -> 1cfe
    LVO -114 -> 1d18
    LVO -120 -> 1d32
    LVO -126 -> 1d4c

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
