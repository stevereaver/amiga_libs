---
type: Library
title: sz_support_0.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:45.579961Z
---

# sz_support_0.4.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[254]='sz_support.library' idstr[267]='$VER: sz_support V0.4  10.03.2000  by Rainer Müller' init=1e endskip=146
  inittab: datasize=430 functab@2f16 datatab@2e initfunc=4e
  functab: 24 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 2fa0
    LVO -36  -> 2fba
    LVO -42  -> 2fce
    LVO -48  -> 2fe8
    LVO -54  -> 3004
    LVO -60  -> 301c
    LVO -66  -> 3036
    LVO -72  -> 304e
    LVO -78  -> 3068
    LVO -84  -> 3084
    LVO -90  -> 30a0
    LVO -96  -> 30bc
    LVO -102 -> 30d8
    LVO -108 -> 30f0
    LVO -114 -> 310c
    LVO -120 -> 3124
    LVO -126 -> 3140
    LVO -132 -> 3158
    LVO -138 -> 3170
    LVO -144 -> 318c

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
