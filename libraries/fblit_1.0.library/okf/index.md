---
type: Library
title: fblit_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:17.487341Z
---

# fblit_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='fblit.library' idstr[74]='fblit.library 1.0 (26.01.2001)' init=94 endskip=4448
  inittab: datasize=5a functab@a4 datatab@164 initfunc=184
  functab: 47 vectors (abs-long)
    LVO -6   -> 0280
    LVO -12  -> 028e
    LVO -18  -> 02a0
    LVO -24  -> 0320
    LVO -30  -> 0324
    LVO -36  -> 0a74
    LVO -42  -> 0bca
    LVO -48  -> 0bfa
    LVO -54  -> 0c60
    LVO -60  -> 0c78
    LVO -66  -> 0eca
    LVO -72  -> 0ffc
    LVO -78  -> 1026
    LVO -84  -> 0c60
    LVO -90  -> 0c60
    LVO -96  -> 1cf8
    LVO -102 -> 4420
    LVO -108 -> 4436
    LVO -114 -> 1d0e
    LVO -120 -> 1ebc
    LVO -126 -> 2068
    LVO -132 -> 2210
    LVO -138 -> 25ce
    LVO -144 -> 298c
    LVO -150 -> 2d3a
    LVO -156 -> 30f8
    LVO -162 -> 3130
    LVO -168 -> 31de
    LVO -174 -> 36d2
    LVO -180 -> 37a4
    LVO -186 -> 3822
    LVO -192 -> 38a0
    LVO -198 -> 391c
    LVO -204 -> 399a
    LVO -210 -> 3a8a
    LVO -216 -> 3b04
    LVO -222 -> 3ba4
    LVO -228 -> 3c4a
    LVO -234 -> 3d02
    LVO -240 -> 3da2
    LVO -246 -> 3e96
    LVO -252 -> 3f6c
    LVO -258 -> 4060
    LVO -264 -> 4138
    LVO -270 -> 41b0
    LVO -276 -> 4262
    LVO -282 -> 434a

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
