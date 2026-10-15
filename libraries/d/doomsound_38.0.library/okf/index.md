---
type: Library
title: doomsound_38.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:42.876823Z
---

# doomsound_38.0.library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=0
  name[1e]='doomsound.library' idstr[30]='doomsound.library 38.0 (2.9.22) ©1998 by Joe Fenton.' init=68 endskip=180
  inittab: datasize=22 functab@78 datatab@cc initfunc=f0
  functab: 20 vectors (abs-long)
    LVO -6   -> 0120
    LVO -12  -> 0130
    LVO -18  -> 0140
    LVO -24  -> 017c
    LVO -30  -> 0520
    LVO -36  -> 0530
    LVO -42  -> 0540
    LVO -48  -> 0590
    LVO -54  -> 05b0
    LVO -60  -> 05d0
    LVO -66  -> 05e0
    LVO -72  -> 0760
    LVO -78  -> 0790
    LVO -84  -> 07a0
    LVO -90  -> 08d0
    LVO -96  -> 08e0
    LVO -102 -> 08f0
    LVO -108 -> 0900
    LVO -114 -> 0970
    LVO -120 -> 0544

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
