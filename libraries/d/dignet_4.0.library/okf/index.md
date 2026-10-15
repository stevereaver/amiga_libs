---
type: Library
title: dignet_4.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:35.673321Z
---

# dignet_4.0.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[44]='dignet.library' idstr[1e]='dignet.library version 4.0 (11.07.97)' init=54 endskip=2fb5
  inittab: datasize=44 functab@64 datatab@14c initfunc=182
  functab: 57 vectors (abs-long)
    LVO -6   -> 019c
    LVO -12  -> 01aa
    LVO -18  -> 01be
    LVO -24  -> 0204
    LVO -30  -> 031e
    LVO -36  -> 0496
    LVO -42  -> 0562
    LVO -48  -> 0616
    LVO -54  -> 0692
    LVO -60  -> 06d0
    LVO -66  -> 0772
    LVO -72  -> 07c2
    LVO -78  -> 07fa
    LVO -84  -> 0a96
    LVO -90  -> 0ab2
    LVO -96  -> 0b32
    LVO -102 -> 0afa
    LVO -108 -> 0b7e
    LVO -114 -> 0b90
    LVO -120 -> 0ce6
    LVO -126 -> 0cd0
    LVO -132 -> 0dfc
    LVO -138 -> 0fb0
    LVO -144 -> 103e
    LVO -150 -> 0708
    LVO -156 -> 105a
    LVO -162 -> 0c4a
    LVO -168 -> 10a0
    LVO -174 -> 10be
    LVO -180 -> 10de
    LVO -186 -> 10fc
    LVO -192 -> 111c
    LVO -198 -> 113e
    LVO -204 -> 11c8
    LVO -210 -> 122e
    LVO -216 -> 1298
    LVO -222 -> 12ec
    LVO -228 -> 1314
    LVO -234 -> 164c
    LVO -240 -> 16a8
    LVO -246 -> 1704
    LVO -252 -> 174e
    LVO -258 -> 176e
    LVO -264 -> 168e
    LVO -270 -> 166c
    LVO -276 -> 135e
    LVO -282 -> 13cc
    LVO -288 -> 13fc
    LVO -294 -> 145c
    LVO -300 -> 148a
    LVO -306 -> 151c
    LVO -312 -> 1574
    LVO -318 -> 15a6
    LVO -324 -> 15dc
    LVO -330 -> 15f4
    LVO -336 -> 160c
    LVO -342 -> 162c

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
