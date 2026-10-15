---
type: Library
title: als_6.33.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:46.626293Z
---

# als_6.33.library

## Structure scan

```
romtag@4 flags=80 ver=6 type=9 pri=0
  name[254]='als.library' idstr[260]='ALS 6.33 (15.01.2000)' init=1e endskip=146
  inittab: datasize=430 functab@2f0c datatab@2e initfunc=4e
  functab: 20 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 2f86
    LVO -36  -> 2f9c
    LVO -42  -> 2fae
    LVO -48  -> 2fc0
    LVO -54  -> 2fd6
    LVO -60  -> 2ff0
    LVO -66  -> 300a
    LVO -72  -> 3022
    LVO -78  -> 3038
    LVO -84  -> 304a
    LVO -90  -> 3064
    LVO -96  -> 3076
    LVO -102 -> 3088
    LVO -108 -> 30a0
    LVO -114 -> 30b8
    LVO -120 -> 30ce

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
