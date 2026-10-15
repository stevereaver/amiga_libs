---
type: Library
title: als_6.12.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:34.317612Z
---

# als_6.12.library

## Structure scan

```
romtag@4 flags=80 ver=6 type=9 pri=0
  name[254]='als.library' idstr[260]='Advanced Lawnmower Simulator 6.12 (14.02.98)' init=1e endskip=146
  inittab: datasize=430 functab@28ec datatab@2e initfunc=4e
  functab: 20 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 2966
    LVO -36  -> 297c
    LVO -42  -> 298e
    LVO -48  -> 29a0
    LVO -54  -> 29b6
    LVO -60  -> 29d0
    LVO -66  -> 29ea
    LVO -72  -> 2a02
    LVO -78  -> 2a18
    LVO -84  -> 2a2a
    LVO -90  -> 2a44
    LVO -96  -> 2a56
    LVO -102 -> 2a68
    LVO -108 -> 2a80
    LVO -114 -> 2a98
    LVO -120 -> 2aae

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
