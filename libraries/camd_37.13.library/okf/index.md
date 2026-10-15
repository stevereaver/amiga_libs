---
type: Library
title: camd_37.13.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:03.123613Z
---

# camd_37.13.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='camd.library' idstr[2b]='camd 37.13 (10.12.92)\r\n' init=44 endskip=3360
  inittab: datasize=dc functab@74 datatab@54 initfunc=110
  functab: 38 vectors (abs-long)
    LVO -6   -> 0136
    LVO -12  -> 0144
    LVO -18  -> 0154
    LVO -24  -> 01a2
    LVO -30  -> 0c64
    LVO -36  -> 0cba
    LVO -42  -> 186c
    LVO -48  -> 1a54
    LVO -54  -> 1600
    LVO -60  -> 1912
    LVO -66  -> 1b4e
    LVO -72  -> 1b2c
    LVO -78  -> 1ad8
    LVO -84  -> 04f4
    LVO -90  -> 0630
    LVO -96  -> 06ca
    LVO -102 -> 089c
    LVO -108 -> 0bb4
    LVO -114 -> 0bec
    LVO -120 -> 0c34
    LVO -126 -> 0b66
    LVO -132 -> 0b92
    LVO -138 -> 0e98
    LVO -144 -> 0eb4
    LVO -150 -> 0f08
    LVO -156 -> 0f40
    LVO -162 -> 1048
    LVO -168 -> 10ba
    LVO -174 -> 1102
    LVO -180 -> 1146
    LVO -186 -> 1152
    LVO -192 -> 1220
    LVO -198 -> 1ca2
    LVO -204 -> 02c0
    LVO -210 -> 0322
    LVO -216 -> 21bc
    LVO -222 -> 30c8
    LVO -228 -> 3114

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
