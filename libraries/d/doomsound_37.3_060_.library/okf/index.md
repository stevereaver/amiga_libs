---
type: Library
title: doomsound_37.3(060).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:43.895287Z
---

# doomsound_37.3(060).library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='doomsound.library' idstr[30]='doomsound.library 37.3 (27.9.18) ©1998 by Joe Fenton.' init=68 endskip=170
  inittab: datasize=22 functab@78 datatab@c0 initfunc=e0
  functab: 17 vectors (abs-long)
    LVO -6   -> 0110
    LVO -12  -> 0120
    LVO -18  -> 0130
    LVO -24  -> 016c
    LVO -30  -> 0510
    LVO -36  -> 0520
    LVO -42  -> 0590
    LVO -48  -> 05f0
    LVO -54  -> 0610
    LVO -60  -> 0630
    LVO -66  -> 0640
    LVO -72  -> 07c0
    LVO -78  -> 07f0
    LVO -84  -> 0800
    LVO -90  -> 0930
    LVO -96  -> 0940
    LVO -102 -> 0950

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
