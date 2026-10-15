---
type: Library
title: datamaster_2.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:06:26.809141Z
---

# datamaster_2.0.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='datamaster.library' idstr[31]='datamaster 2.0 (05.05.97) Release version © Alexis "Cyb" Nasr\r\n' init=72 endskip=72
  inittab: datasize=46 functab@82 datatab@122 initfunc=142
  functab: 39 vectors (abs-long)
    LVO -6   -> 01f2
    LVO -12  -> 0200
    LVO -18  -> 0214
    LVO -24  -> 0262
    LVO -30  -> 05c8
    LVO -36  -> 0606
    LVO -42  -> 07a8
    LVO -48  -> 09d6
    LVO -54  -> 0f72
    LVO -60  -> 1342
    LVO -66  -> 1384
    LVO -72  -> 1328
    LVO -78  -> 1338
    LVO -84  -> 0b38
    LVO -90  -> 0dba
    LVO -96  -> 0e68
    LVO -102 -> 0dcc
    LVO -108 -> 0f20
    LVO -114 -> 0ee4
    LVO -120 -> 0e0e
    LVO -126 -> 0e52
    LVO -132 -> 1396
    LVO -138 -> 13b4
    LVO -144 -> 13ca
    LVO -150 -> 13e0
    LVO -156 -> 13f6
    LVO -162 -> 1424
    LVO -168 -> 144c
    LVO -174 -> 1474
    LVO -180 -> 1286
    LVO -186 -> 168e
    LVO -192 -> 169a
    LVO -198 -> 1682
    LVO -204 -> 16a4
    LVO -210 -> 0adc
    LVO -216 -> 068e
    LVO -222 -> 06f4
    LVO -228 -> 0782
    LVO -234 -> 11b6

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
