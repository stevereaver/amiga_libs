---
type: Library
title: dragndrop_1.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:57.063446Z
---

# dragndrop_1.4.library

## Structure scan

```
romtag@1cb0 flags=80 ver=1 type=9 pri=0
  name[1cca]='dragndrop.library' idstr[1cdc]='dragndrop.library 1.4 11-Mai-2001\r\n' init=1d84 endskip=1d82
  inittab: datasize=3e functab@1d94 datatab@1e1c initfunc=1e48
  functab: 33 vectors (abs-long)
    LVO -6   -> 1eb8
    LVO -12  -> 1ec8
    LVO -18  -> 1ee4
    LVO -24  -> 1f44
    LVO -30  -> 162c
    LVO -36  -> 1638
    LVO -42  -> 1754
    LVO -48  -> 19d8
    LVO -54  -> 19b8
    LVO -60  -> 19a0
    LVO -66  -> 1980
    LVO -72  -> 16b0
    LVO -78  -> 17c8
    LVO -84  -> 19d0
    LVO -90  -> 1634
    LVO -96  -> 15a0
    LVO -102 -> 15dc
    LVO -108 -> 153c
    LVO -114 -> 1578
    LVO -120 -> 13bc
    LVO -126 -> 14b4
    LVO -132 -> 1434
    LVO -138 -> 134c
    LVO -144 -> 111c
    LVO -150 -> 1100
    LVO -156 -> 10c8
    LVO -162 -> 1084
    LVO -168 -> 10ac
    LVO -174 -> 1b1c
    LVO -180 -> 115c
    LVO -186 -> 11d0
    LVO -192 -> 1240
    LVO -198 -> 12c4

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
