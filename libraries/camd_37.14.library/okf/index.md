---
type: Library
title: camd_37.14.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:08.452660Z
---

# camd_37.14.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='camd.library' idstr[2b]='camd 37.14 (1.4.93)\r\n' init=42 endskip=3588
  inittab: datasize=dc functab@74 datatab@52 initfunc=110
  functab: 38 vectors (abs-long)
    LVO -6   -> 0136
    LVO -12  -> 0144
    LVO -18  -> 0154
    LVO -24  -> 01a2
    LVO -30  -> 0d50
    LVO -36  -> 0dae
    LVO -42  -> 1988
    LVO -48  -> 1b9c
    LVO -54  -> 16fc
    LVO -60  -> 1a38
    LVO -66  -> 1cac
    LVO -72  -> 1c88
    LVO -78  -> 1c28
    LVO -84  -> 052c
    LVO -90  -> 069a
    LVO -96  -> 0738
    LVO -102 -> 0938
    LVO -108 -> 0c96
    LVO -114 -> 0cdc
    LVO -120 -> 0d1c
    LVO -126 -> 0c42
    LVO -132 -> 0c72
    LVO -138 -> 0f94
    LVO -144 -> 0fb0
    LVO -150 -> 1004
    LVO -156 -> 103c
    LVO -162 -> 1144
    LVO -168 -> 11b6
    LVO -174 -> 11fe
    LVO -180 -> 1242
    LVO -186 -> 124e
    LVO -192 -> 131c
    LVO -198 -> 1e0e
    LVO -204 -> 02ec
    LVO -210 -> 0352
    LVO -216 -> 234c
    LVO -222 -> 32d0
    LVO -228 -> 331c

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
