---
type: Library
title: toccata_12.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:01.919283Z
---

# toccata_12.0.library

## Structure scan

```
romtag@4 flags=80 ver=12 type=9 pri=0
  name[1e]='toccata.library' idstr[2f]='toccata 12.0 (4.2.97)\r\n' init=d0 endskip=408
  inittab: datasize=572 functab@e0 datatab@17c initfunc=19c
  functab: 38 vectors (abs-long)
    LVO -6   -> 035c
    LVO -12  -> 036a
    LVO -18  -> 038c
    LVO -24  -> 0404
    LVO -30  -> 1c14
    LVO -36  -> 1c30
    LVO -42  -> 1924
    LVO -48  -> 17a2
    LVO -54  -> 20fe
    LVO -60  -> 2a6c
    LVO -66  -> 20f6
    LVO -72  -> 2358
    LVO -78  -> 1cd8
    LVO -84  -> 1d74
    LVO -90  -> 141c
    LVO -96  -> 0b06
    LVO -102 -> 0b7e
    LVO -108 -> 3470
    LVO -114 -> 0ab2
    LVO -120 -> 087c
    LVO -126 -> 09e4
    LVO -132 -> 0a14
    LVO -138 -> 07a2
    LVO -144 -> 1430
    LVO -150 -> 0782
    LVO -156 -> 3d60
    LVO -162 -> 3d66
    LVO -168 -> 3d64
    LVO -174 -> 0404
    LVO -180 -> 0404
    LVO -186 -> 0404
    LVO -192 -> 0404
    LVO -198 -> 0404
    LVO -204 -> 0404
    LVO -210 -> 0e3e
    LVO -216 -> 0e54
    LVO -222 -> 1754
    LVO -228 -> 1778

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
