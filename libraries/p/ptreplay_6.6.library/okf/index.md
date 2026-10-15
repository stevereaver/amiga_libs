---
type: Library
title: ptreplay_6.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:54.712476Z
---

# ptreplay_6.6.library

## Structure scan

```
romtag@4 flags=80 ver=6 type=9 pri=0
  name[1e]='ptreplay.library' idstr[30]='ptreplay.library 6.6 (1996-03-20)\r\n' init=60 endskip=27a
  inittab: datasize=34 functab@70 datatab@e4 initfunc=104
  functab: 28 vectors (abs-long)
    LVO -6   -> 0148
    LVO -12  -> 01ca
    LVO -18  -> 0230
    LVO -24  -> 0276
    LVO -30  -> 027a
    LVO -36  -> 036e
    LVO -42  -> 03a6
    LVO -48  -> 04c0
    LVO -54  -> 0514
    LVO -60  -> 0528
    LVO -66  -> 0538
    LVO -72  -> 059e
    LVO -78  -> 05b6
    LVO -84  -> 05c8
    LVO -90  -> 05e2
    LVO -96  -> 05fa
    LVO -102 -> 060e
    LVO -108 -> 062c
    LVO -114 -> 0666
    LVO -120 -> 06a2
    LVO -126 -> 06c2
    LVO -132 -> 06ea
    LVO -138 -> 0772
    LVO -144 -> 07fe
    LVO -150 -> 0810
    LVO -156 -> 087a
    LVO -162 -> 0884
    LVO -168 -> 08c6

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
